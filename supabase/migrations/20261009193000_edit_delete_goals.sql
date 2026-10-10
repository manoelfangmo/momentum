-- Renaming and deleting a goal. Owner only, and only while unverified.
--
-- Clients map PostgREST error.code (SQLSTATE). The exception message repeats
-- the token. Class M0 is application-defined.
--
--   M0003 goal_not_found
--   M0008 not_authenticated
--   M0011 goal_verified_locked
--   M0014 only_owner_can_edit
--   M0015 only_owner_can_delete
--   M0016 invalid_title
--
-- goal_not_found also covers a goal outside the caller's group, the same as
-- the status RPCs.
--
-- No UPDATE or DELETE policy is added to public.goals: both of these run as
-- the table owner, so the client still has no direct write on the table.
-- Nothing here writes goal_events; a rename is not an event, and a delete
-- takes the goal's events with it through goal_events_goal_id_fkey
-- (ON DELETE CASCADE, from the init migration).

-- ---------------------------------------------------------------------------
-- Rename. Only the title moves: type, deadline, status, and verified are not
-- arguments, so they cannot change. The trimmed title is what gets stored,
-- which is also what the 1..140 check on the column measures.
-- ---------------------------------------------------------------------------

create function public.update_goal_title(
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

  return v_goal;
end;
$$;

-- ---------------------------------------------------------------------------
-- Delete. Hard delete, no tombstone: a goal the owner removed should leave
-- nothing behind in the tabs, in History, or in the completion count.
-- ---------------------------------------------------------------------------

create function public.delete_goal(p_goal_id uuid)
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

  delete from public.goals
  where id = v_goal.id;
end;
$$;

comment on function public.update_goal_title(uuid, text) is
  'Owner only, unverified only. Stores the trimmed title and returns the row. M0003 goal_not_found, M0014 only_owner_can_edit, M0011 goal_verified_locked, M0016 invalid_title.';

comment on function public.delete_goal(uuid) is
  'Owner only, unverified only. Hard delete; goal_events cascade. M0003 goal_not_found, M0015 only_owner_can_delete, M0011 goal_verified_locked.';

revoke all on function public.update_goal_title(uuid, text)
  from public, anon, authenticated, service_role;
revoke all on function public.delete_goal(uuid)
  from public, anon, authenticated, service_role;

grant execute on function public.update_goal_title(uuid, text) to authenticated;
grant execute on function public.delete_goal(uuid) to authenticated;
