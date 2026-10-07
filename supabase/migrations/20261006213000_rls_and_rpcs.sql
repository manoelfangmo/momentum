-- RLS policies and the only writes that cross membership or goal status.
-- Tables and the auth trigger come from 20261006210421_init.sql.
--
-- Clients map PostgREST error.code (SQLSTATE). The exception message repeats
-- the token. Class M0 is application-defined.
--
--   M0001 already_in_group
--   M0002 group_not_found
--   M0003 goal_not_found
--   M0004 not_same_group
--   M0005 cannot_verify_own_goal
--   M0006 goal_not_pending
--   M0007 only_owner_can_mark_missed
--   M0008 not_authenticated
--   M0009 member_not_found

-- Security definer so a members policy can read group_id without going through
-- members RLS. An invoker read here would recurse. Null when the caller has
-- no row or no group. STABLE so a statement evaluates it once.
create function public.my_group_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select group_id
  from public.members
  where id = auth.uid();
$$;

comment on function public.my_group_id() is
  'group_id of auth.uid(), or null. Security definer to avoid recursive members RLS.';

-- ---------------------------------------------------------------------------
-- Policies. Authenticated only. No policy for a command means deny.
-- Do not FORCE ROW LEVEL SECURITY: these RPCs are security definer and run
-- as the table owner, which must bypass RLS to write goals and membership.
-- ---------------------------------------------------------------------------

create policy members_select_self_or_group
  on public.members
  for select
  to authenticated
  using (
    id = (select auth.uid())
    or group_id = (select public.my_group_id())
  );

-- id check only. group_id is not updatable because UPDATE is granted on name
-- alone (see grants below). A table-level UPDATE grant would undo that.
create policy members_update_own
  on public.members
  for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Join lookup is join_group, which is security definer. A policy that allowed
-- SELECT by arbitrary id would let a member read every group name.
create policy groups_select_own
  on public.groups
  for select
  to authenticated
  using (id = (select public.my_group_id()));

create policy goals_select_own_group
  on public.goals
  for select
  to authenticated
  using (group_id = (select public.my_group_id()));

-- Defaults fill status before WITH CHECK, so an omitted status is 'pending'.
-- An explicit complete or missed fails here.
create policy goals_insert_own_pending
  on public.goals
  for insert
  to authenticated
  with check (
    owner_id = (select auth.uid())
    and group_id = (select public.my_group_id())
    and status = 'pending'::public.goal_status
  );

create policy goal_events_select_own_group
  on public.goal_events
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.goals as g
      where g.id = goal_events.goal_id
        and g.group_id = (select public.my_group_id())
    )
  );

-- ---------------------------------------------------------------------------
-- RPCs. Security definer, so they can write tables the caller cannot UPDATE.
-- search_path is pinned. auth.uid() is schema-qualified because auth is not
-- on that path. Membership changes lock the caller row first.
-- ---------------------------------------------------------------------------

create function public.create_group(p_name text)
returns public.groups
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_caller_group uuid;
  v_group public.groups;
begin
  if v_uid is null then
    raise exception 'not_authenticated'
      using errcode = 'M0008',
            detail = 'Caller has no auth.uid().';
  end if;

  select m.group_id
  into v_caller_group
  from public.members as m
  where m.id = v_uid
  for update;

  if not found then
    raise exception 'member_not_found'
      using errcode = 'M0009',
            detail = 'No members row for the caller.';
  end if;

  if v_caller_group is not null then
    raise exception 'already_in_group'
      using errcode = 'M0001',
            detail = 'Caller already belongs to a group.';
  end if;

  insert into public.groups (name, created_by)
  values (p_name, v_uid)
  returning * into v_group;

  update public.members
  set group_id = v_group.id
  where id = v_uid;

  return v_group;
end;
$$;

create function public.join_group(p_group_id uuid)
returns public.groups
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_caller_group uuid;
  v_group public.groups;
begin
  if v_uid is null then
    raise exception 'not_authenticated'
      using errcode = 'M0008',
            detail = 'Caller has no auth.uid().';
  end if;

  -- Already-in-group before the existence check, so a member cannot probe ids.
  select m.group_id
  into v_caller_group
  from public.members as m
  where m.id = v_uid
  for update;

  if not found then
    raise exception 'member_not_found'
      using errcode = 'M0009',
            detail = 'No members row for the caller.';
  end if;

  if v_caller_group is not null then
    raise exception 'already_in_group'
      using errcode = 'M0001',
            detail = 'Caller already belongs to a group.';
  end if;

  select *
  into v_group
  from public.groups
  where id = p_group_id
  for share;

  if not found then
    raise exception 'group_not_found'
      using errcode = 'M0002',
            detail = 'No group exists with that id.';
  end if;

  update public.members
  set group_id = v_group.id
  where id = v_uid;

  return v_group;
end;
$$;

-- No deadline check: overdue pending goals can still be verified.
create function public.verify_goal_complete(p_goal_id uuid)
returns public.goals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_caller_group uuid;
  v_goal public.goals;
begin
  if v_uid is null then
    raise exception 'not_authenticated'
      using errcode = 'M0008',
            detail = 'Caller has no auth.uid().';
  end if;

  select *
  into v_goal
  from public.goals
  where id = p_goal_id
  for update;

  if not found then
    raise exception 'goal_not_found'
      using errcode = 'M0003',
            detail = 'No goal exists with that id.';
  end if;

  select m.group_id
  into v_caller_group
  from public.members as m
  where m.id = v_uid;

  if not found then
    raise exception 'member_not_found'
      using errcode = 'M0009',
            detail = 'No members row for the caller.';
  end if;

  if v_caller_group is null or v_goal.group_id is distinct from v_caller_group then
    raise exception 'not_same_group'
      using errcode = 'M0004',
            detail = 'Goal is not in the caller''s group.';
  end if;

  if v_goal.owner_id = v_uid then
    raise exception 'cannot_verify_own_goal'
      using errcode = 'M0005',
            detail = 'Owner cannot verify their own goal.';
  end if;

  if v_goal.status <> 'pending'::public.goal_status then
    raise exception 'goal_not_pending'
      using errcode = 'M0006',
            detail = 'Only a pending goal can change status.';
  end if;

  update public.goals
  set status = 'complete'
  where id = v_goal.id
  returning * into v_goal;

  insert into public.goal_events (goal_id, actor_id, action)
  values (v_goal.id, v_uid, 'verified_complete'::public.goal_action);

  return v_goal;
end;
$$;

-- No deadline check: overdue pending goals can still be marked missed.
create function public.mark_goal_missed(p_goal_id uuid)
returns public.goals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_caller_group uuid;
  v_goal public.goals;
begin
  if v_uid is null then
    raise exception 'not_authenticated'
      using errcode = 'M0008',
            detail = 'Caller has no auth.uid().';
  end if;

  select *
  into v_goal
  from public.goals
  where id = p_goal_id
  for update;

  if not found then
    raise exception 'goal_not_found'
      using errcode = 'M0003',
            detail = 'No goal exists with that id.';
  end if;

  select m.group_id
  into v_caller_group
  from public.members as m
  where m.id = v_uid;

  if not found then
    raise exception 'member_not_found'
      using errcode = 'M0009',
            detail = 'No members row for the caller.';
  end if;

  if v_caller_group is null or v_goal.group_id is distinct from v_caller_group then
    raise exception 'not_same_group'
      using errcode = 'M0004',
            detail = 'Goal is not in the caller''s group.';
  end if;

  if v_goal.owner_id is distinct from v_uid then
    raise exception 'only_owner_can_mark_missed'
      using errcode = 'M0007',
            detail = 'Only the owner can mark this goal missed.';
  end if;

  if v_goal.status <> 'pending'::public.goal_status then
    raise exception 'goal_not_pending'
      using errcode = 'M0006',
            detail = 'Only a pending goal can change status.';
  end if;

  update public.goals
  set status = 'missed'
  where id = v_goal.id
  returning * into v_goal;

  insert into public.goal_events (goal_id, actor_id, action)
  values (v_goal.id, v_uid, 'marked_missed'::public.goal_action);

  return v_goal;
end;
$$;

comment on function public.create_group(text) is
  'Creates a group and sets the caller membership. M0001 already_in_group, M0008 not_authenticated, M0009 member_not_found.';

comment on function public.join_group(uuid) is
  'Sets the caller membership. M0001 already_in_group, M0002 group_not_found, M0008 not_authenticated, M0009 member_not_found.';

comment on function public.verify_goal_complete(uuid) is
  'Owner excluded. Sets status complete and inserts verified_complete. M0003 goal_not_found, M0004 not_same_group, M0005 cannot_verify_own_goal, M0006 goal_not_pending.';

comment on function public.mark_goal_missed(uuid) is
  'Owner only. Sets status missed and inserts marked_missed. M0003 goal_not_found, M0004 not_same_group, M0006 goal_not_pending, M0007 only_owner_can_mark_missed.';

-- ---------------------------------------------------------------------------
-- Grants. New public tables and functions inherit ALL / EXECUTE for anon,
-- authenticated, and service_role. Column UPDATE is additive, so a leftover
-- table-level UPDATE would still allow changing group_id. Revoke first.
-- service_role keeps its default table grants (it bypasses RLS). It does not
-- keep EXECUTE on these functions.
-- ---------------------------------------------------------------------------

revoke all on table public.members from public, anon, authenticated;
revoke all on table public.groups from public, anon, authenticated;
revoke all on table public.goals from public, anon, authenticated;
revoke all on table public.goal_events from public, anon, authenticated;

grant select on table public.members to authenticated;
grant update (name) on table public.members to authenticated;

grant select on table public.groups to authenticated;

grant select, insert on table public.goals to authenticated;

grant select on table public.goal_events to authenticated;

revoke all on function public.my_group_id() from public, anon, authenticated, service_role;
revoke all on function public.create_group(text) from public, anon, authenticated, service_role;
revoke all on function public.join_group(uuid) from public, anon, authenticated, service_role;
revoke all on function public.verify_goal_complete(uuid) from public, anon, authenticated, service_role;
revoke all on function public.mark_goal_missed(uuid) from public, anon, authenticated, service_role;

grant execute on function public.my_group_id() to authenticated;
grant execute on function public.create_group(text) to authenticated;
grant execute on function public.join_group(uuid) to authenticated;
grant execute on function public.verify_goal_complete(uuid) to authenticated;
grant execute on function public.mark_goal_missed(uuid) to authenticated;
