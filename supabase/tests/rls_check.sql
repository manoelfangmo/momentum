-- Manual RLS / RPC check for two users in the Studio SQL editor.
-- Not a pgTAP file. Do not pass it to `supabase test db`.
--
-- Run the whole script in one session. It raises if a rule fails.
-- Setup must run first; each later block can also be pasted on its own.
-- Rows are left in place. Running the script again deletes them first.
--
-- The editor connects as postgres. The table owner bypasses RLS, so setting
-- request.jwt.claims does nothing until SET LOCAL ROLE authenticated.
-- Set the claims first. The third argument true keeps them in this transaction.
--
--   begin;
--   select set_config('request.jwt.claims', json_build_object(
--     'sub', '<user uuid>',
--     'role', 'authenticated'
--   )::text, true);
--   set local role authenticated;
--   -- statement under test
--   commit;
--
-- Ids of the other person's rows are read before the role switch. That read
-- is the harness. After the switch those rows are what the policy hides.
--
--   M0001 already_in_group
--   M0002 group_not_found
--   M0003 goal_not_found
--   M0005 cannot_verify_own_goal
--   M0008 not_authenticated
--   M0010 only_owner_can_change_status
--   M0011 goal_verified_locked
--   M0012 goal_not_complete
--   M0013 goal_already_verified
--   M0014 only_owner_can_edit
--   M0015 only_owner_can_delete
--   M0016 invalid_title
--   42501 permission denied, or a row-level security violation

-- ---------------------------------------------------------------------------
-- Setup. Ada and Ben. The auth trigger inserts their members rows.
-- ---------------------------------------------------------------------------

-- Events go first: they reference groups and members, and they no longer
-- reference goals, so nothing takes them along.
delete from public.goal_events
where goal_owner_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222'
)
or group_id in (
  select id
  from public.groups
  where created_by in (
    '11111111-1111-4111-8111-111111111111',
    '22222222-2222-4222-8222-222222222222'
  )
);

delete from public.goals
where owner_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222'
)
or group_id in (
  select id
  from public.groups
  where created_by in (
    '11111111-1111-4111-8111-111111111111',
    '22222222-2222-4222-8222-222222222222'
  )
);

delete from public.groups
where created_by in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222'
);

delete from auth.users
where id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222'
);

-- Password is unused. These sessions impersonate with claims; they do not
-- sign in through GoTrue.
insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values
  (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-4111-8111-111111111111',
    'authenticated',
    'authenticated',
    'ada@momentum.test',
    'not-used',
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Ada"}'::jsonb,
    now(),
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '22222222-2222-4222-8222-222222222222',
    'authenticated',
    'authenticated',
    'ben@momentum.test',
    'not-used',
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Ben"}'::jsonb,
    now(),
    now()
  );

-- ---------------------------------------------------------------------------
-- 1. Ben has no group. A missing id is group_not_found. He sees only himself.
-- ---------------------------------------------------------------------------

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  seen int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  if current_user <> 'authenticated' then
    raise exception 'role is %', current_user;
  end if;
  if public.my_group_id() is not null then
    raise exception 'Ben should have no group yet';
  end if;

  select count(*) into seen from public.groups;
  if seen <> 0 then
    raise exception 'Ben should see no groups, saw %', seen;
  end if;

  select count(*) into seen from public.members;
  if seen <> 1 then
    raise exception 'Ben should see only himself, saw %', seen;
  end if;

  begin
    perform public.join_group('99999999-9999-4999-8999-999999999999');
    raise exception 'expected group_not_found';
  exception
    when sqlstate 'M0002' then
      null;
  end;

  raise notice 'ok: group_not_found, Ben sees only himself';
end;
$$;

-- ---------------------------------------------------------------------------
-- 2. Ada creates a group. A second create is already_in_group.
--    Authenticated with no JWT is not_authenticated.
-- ---------------------------------------------------------------------------

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  created public.groups;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  created := public.create_group('Ada group');
  if created.created_by is distinct from ada or created.name <> 'Ada group' then
    raise exception 'create_group returned %', created;
  end if;
  if public.my_group_id() is distinct from created.id then
    raise exception 'my_group_id() did not match the new group';
  end if;

  begin
    perform public.create_group('Another');
    raise exception 'expected already_in_group';
  exception
    when sqlstate 'M0001' then
      null;
  end;

  raise notice 'ok: create_group, second create is already_in_group';
end;
$$;

do $$
begin
  execute 'set local role authenticated';
  begin
    perform public.create_group('No JWT');
    raise exception 'expected not_authenticated';
  exception
    when sqlstate 'M0008' then
      null;
  end;

  raise notice 'ok: not_authenticated';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  ben uuid := '22222222-2222-4222-8222-222222222222';
begin
  if (select group_id from public.members where id = ada) is null then
    raise exception 'Ada group_id was not set';
  end if;
  if (select group_id from public.members where id = ben) is not null then
    raise exception 'Ben group_id should still be null';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Ben cannot select Ada's group by id. Ada sees only herself, can change
--    her name, cannot change Ben's name, and cannot write group_id.
-- ---------------------------------------------------------------------------

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  ada_group uuid;
  seen int;
begin
  select group_id into ada_group
  from public.members
  where id = '11111111-1111-4111-8111-111111111111';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  select count(*) into seen from public.groups where id = ada_group;
  if seen <> 0 then
    raise exception 'Ben must not look up Ada''s group by id';
  end if;

  raise notice 'ok: no group lookup by id before join';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  ben uuid := '22222222-2222-4222-8222-222222222222';
  seen int;
  updated int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  select count(*) into seen from public.members;
  if seen <> 1 then
    raise exception 'Ada should see only herself before Ben joins, saw %', seen;
  end if;

  update public.members set name = 'Ada Lovelace' where id = ada;
  get diagnostics updated = row_count;
  if updated <> 1 then
    raise exception 'Ada should update her own name, updated %', updated;
  end if;

  update public.members set name = 'Not Ben' where id = ben;
  get diagnostics updated = row_count;
  if updated <> 0 then
    raise exception 'Ada should not update Ben, updated %', updated;
  end if;

  begin
    update public.members set group_id = null where id = ada;
    raise exception 'expected permission denied for group_id';
  exception
    when insufficient_privilege then
      if sqlerrm not like '%permission denied%' then
        raise;
      end if;
  end;

  raise notice 'ok: self-only member visibility, name-only update';
end;
$$;

do $$
begin
  if (select name from public.members where id = '22222222-2222-4222-8222-222222222222') <> 'Ben' then
    raise exception 'Ben''s name changed';
  end if;
  if (select name from public.members where id = '11111111-1111-4111-8111-111111111111')
       <> 'Ada Lovelace' then
    raise exception 'Ada''s name was not saved';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 4. Ada inserts a not_started unverified goal for herself. complete-on-insert,
--    verified-on-insert, and an insert owned by Ben are rejected. Ben cannot
--    insert or select goals. Direct goal update/delete and group insert are
--    denied.
-- ---------------------------------------------------------------------------

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  ben uuid := '22222222-2222-4222-8222-222222222222';
  inserted int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  insert into public.goals (owner_id, group_id, title, type, deadline)
  values (
    ada,
    public.my_group_id(),
    'Ada goal one',
    'daily',
    timestamptz '2026-10-07 03:59:59.999+00'
  );
  get diagnostics inserted = row_count;
  if inserted <> 1 then
    raise exception 'Ada should insert one goal, inserted %', inserted;
  end if;

  if (
    select status from public.goals where title = 'Ada goal one'
  ) is distinct from 'not_started'::public.goal_status then
    raise exception 'new goal status should be not_started';
  end if;
  if (select verified from public.goals where title = 'Ada goal one') then
    raise exception 'new goal should be unverified';
  end if;

  begin
    insert into public.goals (owner_id, group_id, title, type, deadline, status)
    values (
      ada,
      public.my_group_id(),
      'Already done',
      'daily',
      timestamptz '2026-10-07 03:59:59.999+00',
      'complete'
    );
    raise exception 'expected RLS to reject status complete';
  exception
    when insufficient_privilege then
      if sqlerrm not like '%row-level security%' then
        raise;
      end if;
  end;

  begin
    insert into public.goals (
      owner_id, group_id, title, type, deadline, status, verified
    )
    values (
      ada,
      public.my_group_id(),
      'Already verified',
      'daily',
      timestamptz '2026-10-07 03:59:59.999+00',
      'complete',
      true
    );
    raise exception 'expected RLS to reject verified true';
  exception
    when insufficient_privilege then
      if sqlerrm not like '%row-level security%' then
        raise;
      end if;
  end;

  begin
    insert into public.goals (owner_id, group_id, title, type, deadline)
    values (
      ben,
      public.my_group_id(),
      'For Ben',
      'daily',
      timestamptz '2026-10-07 03:59:59.999+00'
    );
    raise exception 'expected RLS to reject owner_id Ben';
  exception
    when insufficient_privilege then
      if sqlerrm not like '%row-level security%' then
        raise;
      end if;
  end;

  raise notice 'ok: insert own not_started goal; reject complete, verified, other owner';
end;
$$;

-- Harness as postgres: the verified invariant and the event new_status rule.
do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  ada_group uuid;
begin
  select group_id into ada_group from public.members where id = ada;

  begin
    insert into public.goals (
      owner_id, group_id, title, type, deadline, status, verified
    )
    values (
      ada,
      ada_group,
      'Invalid verified',
      'daily',
      timestamptz '2026-10-07 03:59:59.999+00',
      'not_started',
      true
    );
    raise exception 'expected goals_verified_requires_complete';
  exception
    when check_violation then
      null;
  end;

  begin
    insert into public.goal_events (
      goal_id, group_id, goal_owner_id, goal_title, actor_id, action, new_status
    )
    select id, group_id, owner_id, title, owner_id, 'verified', 'complete'
    from public.goals
    where title = 'Ada goal one';
    raise exception 'expected goal_events_new_status_matches_action';
  exception
    when check_violation then
      null;
  end;

  raise notice 'ok: verified and new_status constraints';
end;
$$;

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  ada_group uuid;
  seen int;
begin
  select group_id into ada_group
  from public.members
  where id = '11111111-1111-4111-8111-111111111111';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    insert into public.goals (owner_id, group_id, title, type, deadline)
    values (
      ben,
      ada_group,
      'Ben sneaks in',
      'daily',
      timestamptz '2026-10-07 03:59:59.999+00'
    );
    raise exception 'expected RLS to reject Ben''s insert';
  exception
    when insufficient_privilege then
      if sqlerrm not like '%row-level security%' then
        raise;
      end if;
  end;

  select count(*) into seen from public.goals;
  if seen <> 0 then
    raise exception 'Ben should see no goals before he joins, saw %', seen;
  end if;

  raise notice 'ok: outsider cannot insert or select goals';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  seen int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  select count(*) into seen from public.goals;
  if seen <> 1 then
    raise exception 'Ada should see her goal, saw %', seen;
  end if;

  begin
    update public.goals set status = 'complete' where owner_id = ada;
    raise exception 'expected permission denied for goals update';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    delete from public.goals where owner_id = ada;
    raise exception 'expected permission denied for goals delete';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    insert into public.groups (name, created_by) values ('Direct', ada);
    raise exception 'expected permission denied for groups insert';
  exception
    when insufficient_privilege then
      null;
  end;

  raise notice 'ok: no direct goal update/delete, no direct group insert';
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. Unknown id is goal_not_found on both RPCs. Ada cannot verify her own
--    goal. Ben is not in the group, so both RPCs are also goal_not_found.
-- ---------------------------------------------------------------------------

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  target uuid;
begin
  select id into target from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.verify_goal('99999999-9999-4999-8999-999999999999');
    raise exception 'expected goal_not_found from verify';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  begin
    perform public.set_goal_status(
      '99999999-9999-4999-8999-999999999999',
      'in_progress'
    );
    raise exception 'expected goal_not_found from set_goal_status';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  begin
    perform public.verify_goal(target);
    raise exception 'expected cannot_verify_own_goal';
  exception
    when sqlstate 'M0005' then
      null;
  end;

  raise notice 'ok: goal_not_found, cannot_verify_own_goal';
end;
$$;

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  target uuid;
begin
  select id into target from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.verify_goal(target);
    raise exception 'expected goal_not_found from verify (outsider)';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  begin
    perform public.set_goal_status(target, 'complete');
    raise exception 'expected goal_not_found from set_goal_status (outsider)';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  raise notice 'ok: outsider goal_not_found';
end;
$$;

-- Harness insert as postgres. Authenticated has no insert on goal_events.
insert into public.goal_events (
  goal_id, group_id, goal_owner_id, goal_title, actor_id, action, new_status
)
select id, group_id, owner_id, title, owner_id, 'status_changed', 'not_started'
from public.goals
where title = 'Ada goal one';

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  seen int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  -- Two: the created event the insert trigger wrote, and the harness row.
  select count(*) into seen from public.goal_events;
  if seen <> 2 then
    raise exception 'Ada should see both events, saw %', seen;
  end if;

  raise notice 'ok: owner group can select goal_events';
end;
$$;

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  seen int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  select count(*) into seen from public.goal_events;
  if seen <> 0 then
    raise exception 'Ben should not see Ada''s event, saw %', seen;
  end if;

  begin
    insert into public.goal_events (
      goal_id, group_id, goal_owner_id, goal_title, actor_id, action, new_status
    )
    values (
      '99999999-9999-4999-8999-999999999999',
      '99999999-9999-4999-8999-999999999999',
      ben,
      'Forged event',
      ben,
      'status_changed',
      'in_progress'
    );
    raise exception 'expected permission denied for goal_events insert';
  exception
    when insufficient_privilege then
      null;
  end;

  raise notice 'ok: outsider cannot select events, no direct insert';
end;
$$;

delete from public.goal_events
where goal_id in (select id from public.goals where title = 'Ada goal one');

-- ---------------------------------------------------------------------------
-- 6. Ben joins. Joining again is already_in_group, including when the id
--    does not exist. Both see the group and both members. No direct
--    group update or delete.
-- ---------------------------------------------------------------------------

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  ada_group uuid;
  joined public.groups;
  seen int;
begin
  select group_id into ada_group
  from public.members
  where id = '11111111-1111-4111-8111-111111111111';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  joined := public.join_group(ada_group);
  if joined.id is distinct from ada_group then
    raise exception 'join_group returned %', joined.id;
  end if;

  begin
    perform public.join_group(ada_group);
    raise exception 'expected already_in_group';
  exception
    when sqlstate 'M0001' then
      null;
  end;

  begin
    perform public.join_group('99999999-9999-4999-8999-999999999999');
    raise exception 'expected already_in_group before group_not_found';
  exception
    when sqlstate 'M0001' then
      null;
  end;

  select count(*) into seen from public.groups;
  if seen <> 1 then
    raise exception 'Ben should see one group after joining, saw %', seen;
  end if;

  select count(*) into seen from public.members;
  if seen <> 2 then
    raise exception 'Ben should see both members, saw %', seen;
  end if;

  raise notice 'ok: join_group and already_in_group';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  ada_group uuid;
  seen int;
begin
  select id into ada_group from public.groups where created_by = ada;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  select count(*) into seen from public.members;
  if seen <> 2 then
    raise exception 'Ada should see both members, saw %', seen;
  end if;

  select count(*) into seen from public.goals;
  if seen <> 1 then
    raise exception 'Ada should still see her goal, saw %', seen;
  end if;

  begin
    update public.groups set name = 'Renamed' where id = ada_group;
    raise exception 'expected permission denied for groups update';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    delete from public.groups where id = ada_group;
    raise exception 'expected permission denied for groups delete';
  exception
    when insufficient_privilege then
      null;
  end;

  raise notice 'ok: shared member visibility, no direct group write';
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. Owner can move status any direction while unverified. Same status is a
--    no-op (no extra event). Non-owner cannot change status. Verify is only
--    for a complete goal, never the owner, and is final.
-- ---------------------------------------------------------------------------

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  target uuid;
begin
  select id into target from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.set_goal_status(target, 'in_progress');
    raise exception 'expected only_owner_can_change_status';
  exception
    when sqlstate 'M0010' then
      null;
  end;

  begin
    perform public.verify_goal(target);
    raise exception 'expected goal_not_complete';
  exception
    when sqlstate 'M0012' then
      null;
  end;

  raise notice 'ok: only_owner_can_change_status, goal_not_complete';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  target uuid;
  updated public.goals;
  seen int;
  before_count int;
begin
  select id into target from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  select count(*) into before_count
  from public.goal_events
  where goal_id = target;

  updated := public.set_goal_status(target, 'not_started');
  if updated.status <> 'not_started'::public.goal_status then
    raise exception 'no-op returned status %', updated.status;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = target;
  if seen <> before_count then
    raise exception 'same status must not write an event, had % now %',
      before_count, seen;
  end if;

  updated := public.set_goal_status(target, 'in_progress');
  if updated.status <> 'in_progress'::public.goal_status
     or updated.verified then
    raise exception 'in_progress returned % / verified %',
      updated.status, updated.verified;
  end if;

  updated := public.set_goal_status(target, 'complete');
  if updated.status <> 'complete'::public.goal_status then
    raise exception 'complete returned status %', updated.status;
  end if;

  updated := public.set_goal_status(target, 'in_progress');
  if updated.status <> 'in_progress'::public.goal_status then
    raise exception 'back to in_progress returned status %', updated.status;
  end if;

  updated := public.set_goal_status(target, 'complete');
  if updated.status <> 'complete'::public.goal_status then
    raise exception 'complete again returned status %', updated.status;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and actor_id = ada
    and action = 'status_changed'
    and new_status is not null;
  if seen <> 4 then
    raise exception 'Ada should have 4 status_changed events, saw %', seen;
  end if;

  begin
    perform public.verify_goal(target);
    raise exception 'expected cannot_verify_own_goal on complete';
  exception
    when sqlstate 'M0005' then
      null;
  end;

  raise notice 'ok: owner status any direction, same-status no-op';
end;
$$;

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  target uuid;
  updated public.goals;
  seen int;
begin
  select id into target from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  updated := public.verify_goal(target);
  if not updated.verified
     or updated.status <> 'complete'::public.goal_status then
    raise exception 'verify returned status % verified %',
      updated.status, updated.verified;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and actor_id = ben
    and action = 'verified'
    and new_status is null;
  if seen <> 1 then
    raise exception 'Ben should see his verified event, saw %', seen;
  end if;

  begin
    perform public.verify_goal(target);
    raise exception 'expected goal_already_verified';
  exception
    when sqlstate 'M0013' then
      null;
  end;

  raise notice 'ok: verify_goal, then goal_already_verified';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  target uuid;
  seen int;
begin
  select id into target from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  select count(*) into seen
  from public.goal_events
  where goal_id = target and action = 'verified';
  if seen <> 1 then
    raise exception 'Ada should see the verified event, saw %', seen;
  end if;

  begin
    perform public.set_goal_status(target, 'in_progress');
    raise exception 'expected goal_verified_locked';
  exception
    when sqlstate 'M0011' then
      null;
  end;

  begin
    perform public.set_goal_status(target, 'complete');
    raise exception 'expected goal_verified_locked on same status';
  exception
    when sqlstate 'M0011' then
      null;
  end;

  raise notice 'ok: goal_verified_locked';
end;
$$;

-- ---------------------------------------------------------------------------
-- 8. A second goal: Ben still cannot change Ada's status. Ada can move it
--    after the deadline. Old RPCs are gone. anon has no execute or table
--    access.
-- ---------------------------------------------------------------------------

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  inserted int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  insert into public.goals (owner_id, group_id, title, type, deadline)
  values (
    ada,
    public.my_group_id(),
    'Ada goal two',
    'weekly',
    timestamptz '2026-10-12 03:59:59.999+00'
  );
  get diagnostics inserted = row_count;
  if inserted <> 1 then
    raise exception 'Ada should insert goal two, inserted %', inserted;
  end if;

  raise notice 'ok: second goal inserted';
end;
$$;

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  target uuid;
begin
  select id into target from public.goals where title = 'Ada goal two';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.set_goal_status(target, 'complete');
    raise exception 'expected only_owner_can_change_status on goal two';
  exception
    when sqlstate 'M0010' then
      null;
  end;

  raise notice 'ok: only_owner_can_change_status on goal two';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  target uuid;
  updated public.goals;
  seen int;
begin
  select id into target from public.goals where title = 'Ada goal two';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  -- Deadline is in the past relative to a later check date; still allowed.
  updated := public.set_goal_status(target, 'complete');
  if updated.status <> 'complete'::public.goal_status or updated.verified then
    raise exception 'overdue complete returned % / verified %',
      updated.status, updated.verified;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and actor_id = ada
    and action = 'status_changed'
    and new_status = 'complete'::public.goal_status;
  if seen <> 1 then
    raise exception 'Ada should see her status_changed event, saw %', seen;
  end if;

  raise notice 'ok: set_goal_status after deadline';
end;
$$;

do $$
begin
  if to_regprocedure('public.verify_goal_complete(uuid)') is not null then
    raise exception 'verify_goal_complete should be dropped';
  end if;
  if to_regprocedure('public.mark_goal_missed(uuid)') is not null then
    raise exception 'mark_goal_missed should be dropped';
  end if;

  raise notice 'ok: old RPCs dropped';
end;
$$;

do $$
declare
  seen int;
begin
  execute 'set local role anon';

  begin
    perform public.create_group('Anon');
    raise exception 'expected anon execute denied';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    select count(*) into seen from public.goals;
    raise exception 'expected anon table access denied';
  exception
    when insufficient_privilege then
      null;
  end;

  raise notice 'ok: anon has no execute and no table access';
end;
$$;

-- ---------------------------------------------------------------------------
-- 9. Rename and delete. Owner only, unverified only, title trimmed to 1..140.
--    A goal the caller cannot see is goal_not_found on both. An insert logs
--    created, a rename logs title_edited, and a delete logs deleted and then
--    leaves every event behind. Still no direct UPDATE or DELETE on goals.
-- ---------------------------------------------------------------------------

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  target uuid;
begin
  select id into target from public.goals where title = 'Ada goal two';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.update_goal_title(target, 'Ben renames it');
    raise exception 'expected only_owner_can_edit';
  exception
    when sqlstate 'M0014' then
      null;
  end;

  begin
    perform public.delete_goal(target);
    raise exception 'expected only_owner_can_delete';
  exception
    when sqlstate 'M0015' then
      null;
  end;

  if (select title from public.goals where id = target) <> 'Ada goal two' then
    raise exception 'Ben changed the title';
  end if;

  raise notice 'ok: only_owner_can_edit, only_owner_can_delete';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  verified_goal uuid;
begin
  select id into verified_goal from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.update_goal_title(verified_goal, 'Renamed after verify');
    raise exception 'expected goal_verified_locked from update_goal_title';
  exception
    when sqlstate 'M0011' then
      null;
  end;

  begin
    perform public.delete_goal(verified_goal);
    raise exception 'expected goal_verified_locked from delete_goal';
  exception
    when sqlstate 'M0011' then
      null;
  end;

  if (select count(*) from public.goals where id = verified_goal) <> 1 then
    raise exception 'the verified goal was deleted';
  end if;

  raise notice 'ok: goal_verified_locked on edit and delete';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.update_goal_title(
      '99999999-9999-4999-8999-999999999999',
      'Nothing to rename'
    );
    raise exception 'expected goal_not_found from update_goal_title';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  begin
    perform public.delete_goal('99999999-9999-4999-8999-999999999999');
    raise exception 'expected goal_not_found from delete_goal';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  raise notice 'ok: unknown id is goal_not_found on edit and delete';
end;
$$;

-- Ben leaves the group for one block, so his own group is not Ada's and both
-- RPCs have to hide her goal behind goal_not_found rather than naming it.
update public.members
set group_id = null
where id = '22222222-2222-4222-8222-222222222222';

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  target uuid;
begin
  select id into target from public.goals where title = 'Ada goal two';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.update_goal_title(target, 'Outsider rename');
    raise exception 'expected goal_not_found from update_goal_title (outsider)';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  begin
    perform public.delete_goal(target);
    raise exception 'expected goal_not_found from delete_goal (outsider)';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  raise notice 'ok: outsider goal_not_found on edit and delete';
end;
$$;

update public.members
set group_id = (
  select group_id
  from public.members
  where id = '11111111-1111-4111-8111-111111111111'
)
where id = '22222222-2222-4222-8222-222222222222';

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  target uuid;
  updated public.goals;
begin
  select id into target from public.goals where title = 'Ada goal two';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.update_goal_title(target, '');
    raise exception 'expected invalid_title for empty';
  exception
    when sqlstate 'M0016' then
      null;
  end;

  begin
    perform public.update_goal_title(target, '     ');
    raise exception 'expected invalid_title for spaces only';
  exception
    when sqlstate 'M0016' then
      null;
  end;

  begin
    perform public.update_goal_title(target, null);
    raise exception 'expected invalid_title for null';
  exception
    when sqlstate 'M0016' then
      null;
  end;

  begin
    perform public.update_goal_title(target, repeat('a', 141));
    raise exception 'expected invalid_title for 141 characters';
  exception
    when sqlstate 'M0016' then
      null;
  end;

  -- 140 is the last accepted length, and it is measured after the trim.
  updated := public.update_goal_title(target, ' ' || repeat('a', 140) || ' ');
  if char_length(updated.title) <> 140 then
    raise exception '140 characters returned length %',
      char_length(updated.title);
  end if;

  updated := public.update_goal_title(target, '  Ada goal two  ');
  if updated.title <> 'Ada goal two' then
    raise exception 'title was not trimmed, got "%"', updated.title;
  end if;
  if updated.type <> 'weekly'::public.goal_type
     or updated.status <> 'complete'::public.goal_status
     or updated.verified then
    raise exception 'rename moved more than the title: % % %',
      updated.type, updated.status, updated.verified;
  end if;

  raise notice 'ok: invalid_title, trimmed rename, nothing else moved';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  target uuid;
  seen int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  insert into public.goals (owner_id, group_id, title, type, deadline)
  values (
    ada,
    public.my_group_id(),
    'Ada goal three',
    'daily',
    timestamptz '2026-10-07 03:59:59.999+00'
  )
  returning id into target;

  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and action = 'created'
    and actor_id = ada
    and goal_title = 'Ada goal three';
  if seen <> 1 then
    raise exception 'the insert should log one created event, saw %', seen;
  end if;

  perform public.set_goal_status(target, 'in_progress');
  perform public.update_goal_title(target, 'Ada goal three renamed');

  -- title_edited carries the new title and no status.
  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and action = 'title_edited'
    and actor_id = ada
    and goal_title = 'Ada goal three renamed'
    and new_status is null;
  if seen <> 1 then
    raise exception 'the rename should log one title_edited event, saw %', seen;
  end if;

  perform set_config('momentum.goal_three', target::text, false);

  perform public.delete_goal(target);

  select count(*) into seen from public.goals where id = target;
  if seen <> 0 then
    raise exception 'goal three should be gone, saw %', seen;
  end if;

  raise notice 'ok: created and title_edited logged, owner deletes the goal';
end;
$$;

-- The events outlive the goal: goal_id references nothing, and the SELECT
-- policy reads goal_events.group_id, so Ada still sees all four of them.
-- The goal row itself is counted as postgres, before RLS could hide it.
do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  target uuid := current_setting('momentum.goal_three')::uuid;
  ada_group uuid;
  seen int;
begin
  select group_id into ada_group from public.members where id = ada;

  select count(*) into seen from public.goals where id = target;
  if seen <> 0 then
    raise exception 'goal three row survived';
  end if;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  select count(*) into seen
  from public.goal_events
  where goal_id = target;
  if seen <> 4 then
    raise exception 'goal three should keep its four events, saw %', seen;
  end if;

  -- The snapshots are what names the goal now that it is gone.
  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and group_id = ada_group
    and goal_owner_id = ada
    and goal_title in ('Ada goal three', 'Ada goal three renamed');
  if seen <> 4 then
    raise exception 'every event should snapshot the deleted goal, saw %', seen;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and action = 'deleted'
    and actor_id = ada
    and goal_title = 'Ada goal three renamed';
  if seen <> 1 then
    raise exception 'the delete should log one deleted event, saw %', seen;
  end if;

  raise notice 'ok: a deleted goal keeps its events';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  seen int;
begin
  select count(*) into seen
  from pg_policies
  where schemaname = 'public'
    and tablename = 'goals'
    and cmd in ('UPDATE', 'DELETE');
  if seen <> 0 then
    raise exception 'goals should have no UPDATE/DELETE policy, saw %', seen;
  end if;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    update public.goals set title = 'Direct rename' where owner_id = ada;
    raise exception 'expected permission denied for goals update';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    delete from public.goals where owner_id = ada;
    raise exception 'expected permission denied for goals delete';
  exception
    when insufficient_privilege then
      null;
  end;

  raise notice 'ok: still no direct goal update or delete';
end;
$$;

do $$
begin
  execute 'set local role anon';

  begin
    perform public.delete_goal('99999999-9999-4999-8999-999999999999');
    raise exception 'expected anon execute denied on delete_goal';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    perform public.update_goal_title(
      '99999999-9999-4999-8999-999999999999',
      'Anon'
    );
    raise exception 'expected anon execute denied on update_goal_title';
  exception
    when insufficient_privilege then
      null;
  end;

  raise notice 'ok: anon cannot edit or delete';
end;
$$;
