-- goal_events becomes a standalone log. Every row carries its own copy of
-- what it described, so an event outlives the goal: goal_id is a plain uuid
-- with no foreign key and no cascade. Adds goals.assigned_by and the
-- created/assigned trigger that reads it.
--
-- No new error tokens. The four goal RPCs keep the rules and SQLSTATEs from
-- 20261008001604_status_rework.sql and 20261009193000_edit_delete_goals.sql;
-- only where they write the event changes here. The admin permission rework
-- is a later migration.

-- The log cannot be backfilled: the group, owner, and title an event needs
-- are the ones at the time it happened, and goals only holds today's. Local
-- test data, so the rows go.
truncate public.goal_events;

-- ---------------------------------------------------------------------------
-- goal_events. goal_id still says which goal, but it no longer references
-- one. The snapshot columns are what a deleted goal leaves behind.
-- ---------------------------------------------------------------------------

alter table public.goal_events
  drop constraint goal_events_goal_id_fkey;

alter table public.goal_events
  add column group_id uuid not null references public.groups (id),
  add column goal_owner_id uuid not null references public.members (id),
  add column goal_title text not null;

-- The SELECT policy below reads group_id instead of joining goals.
create index goal_events_group_id_idx
  on public.goal_events (group_id);

-- ---------------------------------------------------------------------------
-- goal_action. BEFORE / AFTER place the new values in lifecycle order, so
-- ordering by action reads the way a goal moves. A value added here cannot be
-- used until this transaction commits; nothing below uses one, function
-- bodies only resolve them when they run.
-- ---------------------------------------------------------------------------

alter type public.goal_action add value 'created' before 'status_changed';
alter type public.goal_action add value 'assigned' before 'status_changed';
alter type public.goal_action add value 'unverified' after 'verified';
alter type public.goal_action add value 'title_edited' after 'unverified';
alter type public.goal_action add value 'deleted' after 'title_edited';

-- goal_events_new_status_matches_action (from the status rework) still holds:
-- status_changed is the only action that carries a new_status, and none of
-- the five new ones changes status.

-- ---------------------------------------------------------------------------
-- goals.assigned_by. Null is an own goal. Set, it is the admin who assigned
-- the goal to its owner. The insert trigger reads it to tell the two apart.
-- ---------------------------------------------------------------------------

alter table public.goals
  add column assigned_by uuid null references public.members (id);

-- ---------------------------------------------------------------------------
-- Writing an event. The RPCs pass the whole goal row rather than its columns,
-- so the snapshot cannot drift from the goal the RPC acted on.
--
-- Granted to no role: every caller is security definer and runs as the table
-- owner, so a client still cannot write goal_events by any route.
-- ---------------------------------------------------------------------------

create function public.log_goal_event(
  g public.goals,
  p_action public.goal_action,
  p_new_status public.goal_status default null
)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.goal_events (
    goal_id,
    group_id,
    goal_owner_id,
    goal_title,
    actor_id,
    action,
    new_status
  )
  values (
    g.id,
    g.group_id,
    g.owner_id,
    g.title,
    auth.uid(),
    p_action,
    p_new_status
  );
$$;

-- ---------------------------------------------------------------------------
-- created / assigned. AFTER INSERT, so the goal exists before an event names
-- it. This one names its actor instead of calling log_goal_event: both
-- candidates are on the new row, which keeps the event correct even for an
-- insert made without a session.
-- ---------------------------------------------------------------------------

create function public.log_goal_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.goal_events (
    goal_id,
    group_id,
    goal_owner_id,
    goal_title,
    actor_id,
    action
  )
  values (
    new.id,
    new.group_id,
    new.owner_id,
    new.title,
    coalesce(new.assigned_by, new.owner_id),
    case
      when new.assigned_by is null then 'created'::public.goal_action
      else 'assigned'::public.goal_action
    end
  );

  return null;
end;
$$;

create trigger goals_log_insert
  after insert on public.goals
  for each row
  execute function public.log_goal_insert();

-- ---------------------------------------------------------------------------
-- The four goal RPCs, replaced to log through log_goal_event. Same arguments
-- and same checks in the same order, so CREATE OR REPLACE keeps their grants.
-- A rename now writes title_edited, which it did not before, and a delete
-- writes deleted before the row goes, which is the only way the event can
-- read the goal.
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

  if v_goal.owner_id is distinct from v_uid then
    raise exception 'only_owner_can_change_status'
      using errcode = 'M0010',
            detail = 'Only the owner can change this goal''s status.';
  end if;

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

create or replace function public.verify_goal(p_goal_id uuid)
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

  if v_goal.owner_id = v_uid then
    raise exception 'cannot_verify_own_goal'
      using errcode = 'M0005',
            detail = 'Owner cannot verify their own goal.';
  end if;

  if v_goal.status <> 'complete'::public.goal_status then
    raise exception 'goal_not_complete'
      using errcode = 'M0012',
            detail = 'Only a complete goal can be verified.';
  end if;

  if v_goal.verified then
    raise exception 'goal_already_verified'
      using errcode = 'M0013',
            detail = 'This goal is already verified.';
  end if;

  update public.goals
  set verified = true
  where id = v_goal.id
  returning * into v_goal;

  perform public.log_goal_event(v_goal, 'verified'::public.goal_action);

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

  if v_goal.owner_id is distinct from v_uid then
    raise exception 'only_owner_can_edit'
      using errcode = 'M0014',
            detail = 'Only the owner can edit this goal.';
  end if;

  if v_goal.verified then
    raise exception 'goal_verified_locked'
      using errcode = 'M0011',
            detail = 'A verified goal cannot be edited.';
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

  -- Logged after the update, so the event's goal_title is the new title. A
  -- title_edited event carries nothing else: who and when is the whole record.
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

  if v_goal.owner_id is distinct from v_uid then
    raise exception 'only_owner_can_delete'
      using errcode = 'M0015',
            detail = 'Only the owner can delete this goal.';
  end if;

  if v_goal.verified then
    raise exception 'goal_verified_locked'
      using errcode = 'M0011',
            detail = 'A verified goal cannot be deleted.';
  end if;

  perform public.log_goal_event(v_goal, 'deleted'::public.goal_action);

  delete from public.goals
  where id = v_goal.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- RLS. group_id is on the event now, so the policy stops joining goals —
-- which is also what keeps an event readable once its goal is gone. Still no
-- INSERT policy and still no insert grant: the functions above are the only
-- writers.
-- ---------------------------------------------------------------------------

drop policy goal_events_select_own_group on public.goal_events;

create policy goal_events_select_own_group
  on public.goal_events
  for select
  to authenticated
  using (group_id = (select public.my_group_id()));

comment on function public.log_goal_event(
  public.goals,
  public.goal_action,
  public.goal_status
) is
  'Inserts one goal_events row from a goal and the action, actor auth.uid(). The only writer the goal RPCs use.';

comment on function public.log_goal_insert() is
  'AFTER INSERT on goals: logs assigned when assigned_by is set, created otherwise, actor coalesce(assigned_by, owner_id).';

comment on function public.set_goal_status(uuid, public.goal_status) is
  'Owner only. Sets status while unverified and logs status_changed. Same status is a no-op. M0003 goal_not_found, M0010 only_owner_can_change_status, M0011 goal_verified_locked.';

comment on function public.verify_goal(uuid) is
  'Owner excluded. Sets verified and logs verified. M0003 goal_not_found, M0005 cannot_verify_own_goal, M0012 goal_not_complete, M0013 goal_already_verified.';

comment on function public.update_goal_title(uuid, text) is
  'Owner only, unverified only. Stores the trimmed title, logs title_edited, returns the row. M0003 goal_not_found, M0014 only_owner_can_edit, M0011 goal_verified_locked, M0016 invalid_title.';

comment on function public.delete_goal(uuid) is
  'Owner only, unverified only. Logs deleted, then hard deletes; the goal''s events remain. M0003 goal_not_found, M0015 only_owner_can_delete, M0011 goal_verified_locked.';

-- ---------------------------------------------------------------------------
-- Grants. New functions inherit EXECUTE for anon, authenticated, and
-- service_role; both of these lose it. CREATE OR REPLACE does not touch
-- privileges, so the four RPCs keep the grants from their own migrations.
-- ---------------------------------------------------------------------------

revoke all on function public.log_goal_event(
  public.goals,
  public.goal_action,
  public.goal_status
) from public, anon, authenticated, service_role;

revoke all on function public.log_goal_insert()
  from public, anon, authenticated, service_role;
