-- Replace pending/complete/missed with not_started/in_progress/complete,
-- add goals.verified, and replace the two status RPCs.
--
-- Clients map PostgREST error.code (SQLSTATE). The exception message repeats
-- the token. Class M0 is application-defined.
--
--   M0003 goal_not_found
--   M0005 cannot_verify_own_goal
--   M0008 not_authenticated
--   M0010 only_owner_can_change_status
--   M0011 goal_verified_locked
--   M0012 goal_not_complete
--   M0013 goal_already_verified
--
-- goal_not_found also covers a goal outside the caller's group (no separate
-- not_same_group). Old tokens M0004, M0006, and M0007 are unused.

drop function if exists public.verify_goal_complete(uuid);
drop function if exists public.mark_goal_missed(uuid);

-- The insert policy names the old enum value; drop it before the type swap.
drop policy if exists goals_insert_own_pending on public.goals;

truncate public.goal_events, public.goals;

-- ---------------------------------------------------------------------------
-- Enums. Truncate first so USING can ignore leftover values.
-- ---------------------------------------------------------------------------

alter table public.goals
  alter column status drop default;

alter type public.goal_status rename to goal_status_old;

create type public.goal_status as enum (
  'not_started',
  'in_progress',
  'complete'
);

alter table public.goals
  alter column status type public.goal_status
  using 'not_started'::public.goal_status;

alter table public.goals
  alter column status set default 'not_started'::public.goal_status;

drop type public.goal_status_old;

alter type public.goal_action rename to goal_action_old;

create type public.goal_action as enum (
  'status_changed',
  'verified'
);

alter table public.goal_events
  alter column action type public.goal_action
  using 'status_changed'::public.goal_action;

drop type public.goal_action_old;

-- ---------------------------------------------------------------------------
-- Columns. verified = true implies status = complete. new_status is set only
-- for status_changed events.
-- ---------------------------------------------------------------------------

alter table public.goals
  add column verified boolean not null default false,
  add constraint goals_verified_requires_complete
    check (not verified or status = 'complete'::public.goal_status);

alter table public.goal_events
  add column new_status public.goal_status null,
  add constraint goal_events_new_status_matches_action
    check (
      (action = 'status_changed'::public.goal_action)
      = (new_status is not null)
    );

create policy goals_insert_own_not_started
  on public.goals
  for insert
  to authenticated
  with check (
    owner_id = (select auth.uid())
    and group_id = (select public.my_group_id())
    and status = 'not_started'::public.goal_status
    and verified = false
  );

-- ---------------------------------------------------------------------------
-- RPCs. Security definer, so they can write tables the caller cannot UPDATE.
-- search_path is pinned. No deadline checks: status and verification are
-- allowed at any time. Verified is final.
-- ---------------------------------------------------------------------------

create function public.set_goal_status(
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

  insert into public.goal_events (goal_id, actor_id, action, new_status)
  values (
    v_goal.id,
    v_uid,
    'status_changed'::public.goal_action,
    p_status
  );

  return v_goal;
end;
$$;

create function public.verify_goal(p_goal_id uuid)
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

  insert into public.goal_events (goal_id, actor_id, action, new_status)
  values (
    v_goal.id,
    v_uid,
    'verified'::public.goal_action,
    null
  );

  return v_goal;
end;
$$;

comment on function public.set_goal_status(uuid, public.goal_status) is
  'Owner only. Sets status while unverified and inserts status_changed. Same status is a no-op. M0003 goal_not_found, M0010 only_owner_can_change_status, M0011 goal_verified_locked.';

comment on function public.verify_goal(uuid) is
  'Owner excluded. Sets verified and inserts verified. M0003 goal_not_found, M0005 cannot_verify_own_goal, M0012 goal_not_complete, M0013 goal_already_verified.';

revoke all on function public.set_goal_status(uuid, public.goal_status)
  from public, anon, authenticated, service_role;
revoke all on function public.verify_goal(uuid)
  from public, anon, authenticated, service_role;

grant execute on function public.set_goal_status(uuid, public.goal_status)
  to authenticated;
grant execute on function public.verify_goal(uuid) to authenticated;
