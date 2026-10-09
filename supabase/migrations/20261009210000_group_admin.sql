-- Group admin. The admin is the group creator (groups.created_by): one per
-- group, fixed, no transfer. There is no admin column and no admin table —
-- the row that already names the creator is the whole mechanism.
--
-- This migration is where the admin gets powers, so it widens the owner-only
-- rules the earlier goal RPCs set. Where the two disagree, this one wins.
--
-- Clients map PostgREST error.code (SQLSTATE). The exception message repeats
-- the token. Class M0 is application-defined.
--
--   M0003 goal_not_found
--   M0008 not_authenticated
--   M0010 not_allowed_to_change_status
--   M0011 goal_verified_locked
--   M0014 not_allowed_to_edit
--   M0015 not_allowed_to_delete
--   M0016 invalid_title
--   M0017 assigned_goal_admin_only
--   M0018 admin_only
--   M0019 cannot_unverify_own_goal
--   M0020 goal_not_verified
--   M0021 member_not_in_group
--
-- M0010, M0014, and M0015 keep their SQLSTATE under a new token. The check is
-- in the same place and means the same thing to a caller; the rule behind it
-- widened from the owner to the owner or the admin, so the old names
-- (only_owner_can_change_status, only_owner_can_edit, only_owner_can_delete)
-- no longer describe it.
--
-- Who may do what, with V for a verified goal:
--
--   change status   owner while not V; admin on any goal while not V
--   verify          anyone but the owner, status complete, while not V
--   un-verify       admin only, on a goal they do not own, while V
--   edit / delete   owner while not V and the goal is not assigned;
--                   admin on any goal, verified ones included
--   assign          admin only, to one member of their own group
--
-- Nothing expires: every rule above holds after the deadline.

-- ---------------------------------------------------------------------------
-- is_group_admin. Security definer for the same reason as my_group_id: the
-- groups SELECT policy calls my_group_id, and an invoker read here would
-- evaluate that policy to answer a question the policy depends on. False,
-- never null, when the caller has no session, no member row, or no group.
-- ---------------------------------------------------------------------------

create function public.is_group_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.groups
    where id = public.my_group_id()
      and created_by = auth.uid()
  );
$$;

-- ---------------------------------------------------------------------------
-- Insert policy. A client insert is always an own goal, so assigned_by has to
-- be null there: otherwise a member could write the admin's id onto their own
-- goal and both claim it was assigned and lock themselves out of editing it.
-- assign_goal is the only way to set the column, and it is security definer,
-- so it writes as the table owner and this policy does not apply to it.
-- ---------------------------------------------------------------------------

drop policy goals_insert_own_not_started on public.goals;

create policy goals_insert_own_not_started
  on public.goals
  for insert
  to authenticated
  with check (
    owner_id = (select auth.uid())
    and group_id = (select public.my_group_id())
    and status = 'not_started'::public.goal_status
    and verified = false
    and assigned_by is null
  );

-- ---------------------------------------------------------------------------
-- The goal RPCs the admin changes. Same arguments, same checks in the same
-- order, so CREATE OR REPLACE keeps their grants. Only the permission test in
-- the middle moves.
--
-- verify_goal is not here. Its rule already covers the admin: a verifier is
-- anyone but the owner, and the admin is a member like the rest. Taking a
-- verification back is a separate power and gets its own RPC below.
-- ---------------------------------------------------------------------------

create or replace function public.set_goal_status(
  p_goal_id uuid,
  p_status public.goal_status
)
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

  if not found
     or v_caller_group is null
     or v_goal.group_id is distinct from v_caller_group then
    raise exception 'goal_not_found'
      using errcode = 'M0003',
            detail = 'No goal exists with that id.';
  end if;

  if v_goal.owner_id is distinct from v_uid and not public.is_group_admin() then
    raise exception 'not_allowed_to_change_status'
      using errcode = 'M0010',
            detail = 'Only the owner or the group admin can change this goal''s status.';
  end if;

  -- The admin is locked out too. Moving a verified goal starts with
  -- unverify_goal, which only the admin can call.
  if v_goal.verified then
    raise exception 'goal_verified_locked'
      using errcode = 'M0011',
            detail = 'A verified goal cannot change status.';
  end if;

  if v_goal.status is not distinct from p_status then
    return v_goal;
  end if;

  update public.goals
  set status = p_status
  where id = v_goal.id
  returning * into v_goal;

  perform public.log_goal_event(
    v_goal,
    'status_changed'::public.goal_action,
    p_status
  );

  return v_goal;
end;
$$;

create or replace function public.update_goal_title(
  p_goal_id uuid,
  p_title text
)
returns public.goals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_caller_group uuid;
  v_goal public.goals;
  v_title text := btrim(coalesce(p_title, ''));
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

  if not found
     or v_caller_group is null
     or v_goal.group_id is distinct from v_caller_group then
    raise exception 'goal_not_found'
      using errcode = 'M0003',
            detail = 'No goal exists with that id.';
  end if;

  -- The admin has no conditions: any goal in the group, verified or not,
  -- assigned or not. Everyone else is held to the owner's three.
  if not public.is_group_admin() then
    if v_goal.owner_id is distinct from v_uid then
      raise exception 'not_allowed_to_edit'
        using errcode = 'M0014',
              detail = 'Only the owner or the group admin can edit this goal.';
    end if;

    if v_goal.verified then
      raise exception 'goal_verified_locked'
        using errcode = 'M0011',
              detail = 'A verified goal cannot be edited.';
    end if;

    if v_goal.assigned_by is not null then
      raise exception 'assigned_goal_admin_only'
        using errcode = 'M0017',
              detail = 'Only the group admin can edit an assigned goal.';
    end if;
  end if;

  if char_length(v_title) not between 1 and 140 then
    raise exception 'invalid_title'
      using errcode = 'M0016',
            detail = 'A trimmed title must be 1 to 140 characters.';
  end if;

  update public.goals
  set title = v_title
  where id = v_goal.id
  returning * into v_goal;

  perform public.log_goal_event(v_goal, 'title_edited'::public.goal_action);

  return v_goal;
end;
$$;

create or replace function public.delete_goal(p_goal_id uuid)
returns void
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

  if not found
     or v_caller_group is null
     or v_goal.group_id is distinct from v_caller_group then
    raise exception 'goal_not_found'
      using errcode = 'M0003',
            detail = 'No goal exists with that id.';
  end if;

  if not public.is_group_admin() then
    if v_goal.owner_id is distinct from v_uid then
      raise exception 'not_allowed_to_delete'
        using errcode = 'M0015',
              detail = 'Only the owner or the group admin can delete this goal.';
    end if;

    if v_goal.verified then
      raise exception 'goal_verified_locked'
        using errcode = 'M0011',
              detail = 'A verified goal cannot be deleted.';
    end if;

    if v_goal.assigned_by is not null then
      raise exception 'assigned_goal_admin_only'
        using errcode = 'M0017',
              detail = 'Only the group admin can delete an assigned goal.';
    end if;
  end if;

  perform public.log_goal_event(v_goal, 'deleted'::public.goal_action);

  delete from public.goals
  where id = v_goal.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- un-verify. The one way out of the verified state, and the admin's alone.
-- Not on their own goal: that would be the admin verifying themselves in
-- reverse, which is the rule cannot_verify_own_goal already draws.
--
-- The goal stays complete. verified = false is what unlocks it, so its owner
-- can move the status again and anyone but the owner can verify it again.
-- ---------------------------------------------------------------------------

create function public.unverify_goal(p_goal_id uuid)
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

  -- Before admin_only, so a goal in another group stays invisible rather than
  -- answering "you are not the admin here".
  if not found
     or v_caller_group is null
     or v_goal.group_id is distinct from v_caller_group then
    raise exception 'goal_not_found'
      using errcode = 'M0003',
            detail = 'No goal exists with that id.';
  end if;

  if not public.is_group_admin() then
    raise exception 'admin_only'
      using errcode = 'M0018',
            detail = 'Only the group admin can un-verify a goal.';
  end if;

  if v_goal.owner_id = v_uid then
    raise exception 'cannot_unverify_own_goal'
      using errcode = 'M0019',
            detail = 'The admin cannot un-verify their own goal.';
  end if;

  if not v_goal.verified then
    raise exception 'goal_not_verified'
      using errcode = 'M0020',
            detail = 'Only a verified goal can be un-verified.';
  end if;

  update public.goals
  set verified = false
  where id = v_goal.id
  returning * into v_goal;

  perform public.log_goal_event(v_goal, 'unverified'::public.goal_action);

  return v_goal;
end;
$$;

-- ---------------------------------------------------------------------------
-- assign. One member per call. The member owns the goal; assigned_by names
-- the admin, which is what makes it theirs to edit and not the owner's. An
-- admin assigning to themselves gets a normal own goal, assigned_by null, and
-- the A01 trigger logs it as created rather than assigned.
--
-- The deadline is an argument because it is the end of the current period in
-- the device's timezone, and the server does not know that timezone. Null
-- deadline and null type fail on the column constraints: the client always
-- computes both.
-- ---------------------------------------------------------------------------

create function public.assign_goal(
  p_owner_id uuid,
  p_title text,
  p_type public.goal_type,
  p_deadline timestamptz
)
returns public.goals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_group uuid := public.my_group_id();
  v_title text := btrim(coalesce(p_title, ''));
  v_goal public.goals;
begin
  if v_uid is null then
    raise exception 'not_authenticated'
      using errcode = 'M0008',
            detail = 'Caller has no auth.uid().';
  end if;

  if not public.is_group_admin() then
    raise exception 'admin_only'
      using errcode = 'M0018',
            detail = 'Only the group admin can assign a goal.';
  end if;

  if not exists (
    select 1
    from public.members as m
    where m.id = p_owner_id
      and m.group_id = v_group
  ) then
    raise exception 'member_not_in_group'
      using errcode = 'M0021',
            detail = 'That member is not in the admin''s group.';
  end if;

  if char_length(v_title) not between 1 and 140 then
    raise exception 'invalid_title'
      using errcode = 'M0016',
            detail = 'A trimmed title must be 1 to 140 characters.';
  end if;

  insert into public.goals (
    owner_id,
    group_id,
    title,
    type,
    deadline,
    status,
    verified,
    assigned_by
  )
  values (
    p_owner_id,
    v_group,
    v_title,
    p_type,
    p_deadline,
    'not_started'::public.goal_status,
    false,
    case when p_owner_id = v_uid then null else v_uid end
  )
  returning * into v_goal;

  return v_goal;
end;
$$;

comment on function public.is_group_admin() is
  'True when auth.uid() created their own group. False for everyone else, including a caller with no group. Security definer to avoid evaluating the groups policy.';

comment on function public.set_goal_status(uuid, public.goal_status) is
  'Owner or group admin, while unverified. Logs status_changed. Same status is a no-op. M0003 goal_not_found, M0010 not_allowed_to_change_status, M0011 goal_verified_locked.';

comment on function public.update_goal_title(uuid, text) is
  'Admin on any goal; owner only while unverified and unassigned. Stores the trimmed title, logs title_edited. M0003 goal_not_found, M0014 not_allowed_to_edit, M0011 goal_verified_locked, M0017 assigned_goal_admin_only, M0016 invalid_title.';

comment on function public.delete_goal(uuid) is
  'Admin on any goal; owner only while unverified and unassigned. Logs deleted, then hard deletes; the goal''s events remain. M0003 goal_not_found, M0015 not_allowed_to_delete, M0011 goal_verified_locked, M0017 assigned_goal_admin_only.';

comment on function public.unverify_goal(uuid) is
  'Admin only, never on their own goal. Clears verified, leaves status complete, logs unverified. M0003 goal_not_found, M0018 admin_only, M0019 cannot_unverify_own_goal, M0020 goal_not_verified.';

comment on function public.assign_goal(uuid, text, public.goal_type, timestamptz) is
  'Admin only. Inserts a not_started goal owned by a member of the group, assigned_by the admin unless they own it. The insert trigger logs assigned. M0018 admin_only, M0021 member_not_in_group, M0016 invalid_title.';

-- ---------------------------------------------------------------------------
-- Grants. New functions inherit EXECUTE for anon, authenticated, and
-- service_role. CREATE OR REPLACE does not touch privileges, so the three
-- rewritten RPCs keep the grants from their own migrations.
-- ---------------------------------------------------------------------------

revoke all on function public.is_group_admin()
  from public, anon, authenticated, service_role;
revoke all on function public.unverify_goal(uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.assign_goal(
  uuid,
  text,
  public.goal_type,
  timestamptz
) from public, anon, authenticated, service_role;

grant execute on function public.is_group_admin() to authenticated;
grant execute on function public.unverify_goal(uuid) to authenticated;
grant execute on function public.assign_goal(
  uuid,
  text,
  public.goal_type,
  timestamptz
) to authenticated;
