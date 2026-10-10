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
--   M0010 not_allowed_to_change_status
--   M0011 goal_verified_locked
--   M0012 goal_not_complete
--   M0013 goal_already_verified
--   M0014 not_allowed_to_edit
--   M0015 not_allowed_to_delete
--   M0016 invalid_title
--   M0017 assigned_goal_admin_only
--   M0018 admin_only
--   M0019 cannot_unverify_own_goal
--   M0020 goal_not_verified
--   M0021 member_not_in_group
--   42501 permission denied, or a row-level security violation
--
-- Ada creates the group, so Ada is its admin and Ben is not. Sections 1 to 9
-- are the member rules; section 10 is what the admin may do on top of them.

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
    raise exception 'expected not_allowed_to_change_status';
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

  raise notice 'ok: not_allowed_to_change_status, goal_not_complete';
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
    raise exception 'expected not_allowed_to_change_status on goal two';
  exception
    when sqlstate 'M0010' then
      null;
  end;

  raise notice 'ok: not_allowed_to_change_status on goal two';
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
    raise exception 'expected not_allowed_to_edit';
  exception
    when sqlstate 'M0014' then
      null;
  end;

  begin
    perform public.delete_goal(target);
    raise exception 'expected not_allowed_to_delete';
  exception
    when sqlstate 'M0015' then
      null;
  end;

  if (select title from public.goals where id = target) <> 'Ada goal two' then
    raise exception 'Ben changed the title';
  end if;

  raise notice 'ok: not_allowed_to_edit, not_allowed_to_delete';
end;
$$;

-- The verified lock no longer catches Ada: she created the group, so she is
-- its admin and may rename or delete anything (section 10). The owner half of
-- the rule needs an owner who is not the admin. Ben makes a goal, completes
-- it, Ada verifies it, and then it is closed to him.
do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  target uuid;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  insert into public.goals (owner_id, group_id, title, type, deadline)
  values (
    ben,
    public.my_group_id(),
    'Ben goal one',
    'daily',
    timestamptz '2026-10-08 03:59:59.999+00'
  )
  returning id into target;

  perform public.set_goal_status(target, 'complete');
  perform set_config('momentum.ben_goal_one', target::text, false);

  raise notice 'ok: Ben inserted and completed his own goal';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  target uuid := current_setting('momentum.ben_goal_one')::uuid;
  updated public.goals;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  updated := public.verify_goal(target);
  if not updated.verified then
    raise exception 'Ada should have verified Ben''s goal';
  end if;

  raise notice 'ok: Ada verified Ben''s goal';
end;
$$;

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  target uuid := current_setting('momentum.ben_goal_one')::uuid;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.update_goal_title(target, 'Renamed after verify');
    raise exception 'expected goal_verified_locked from update_goal_title';
  exception
    when sqlstate 'M0011' then
      null;
  end;

  begin
    perform public.delete_goal(target);
    raise exception 'expected goal_verified_locked from delete_goal';
  exception
    when sqlstate 'M0011' then
      null;
  end;

  if (select count(*) from public.goals where id = target) <> 1 then
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

-- ---------------------------------------------------------------------------
-- 10. The admin. Ada created the group, so she is it and Ben is not.
--     Assigning, un-verifying, and editing or deleting any goal are hers
--     alone; an assigned goal is out of its owner's hands except for status.
-- ---------------------------------------------------------------------------

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

  if not public.is_group_admin() then
    raise exception 'Ada created the group and should be its admin';
  end if;
end;
$$;

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  own_verified uuid := current_setting('momentum.ben_goal_one')::uuid;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  if public.is_group_admin() then
    raise exception 'Ben joined the group and should not be its admin';
  end if;

  begin
    perform public.assign_goal(
      ben,
      'Ben assigns himself work',
      'daily',
      timestamptz '2026-10-10 03:59:59.999+00'
    );
    raise exception 'expected admin_only from assign_goal';
  exception
    when sqlstate 'M0018' then
      null;
  end;

  -- Owner and verified both hold here; admin_only is still what he gets.
  begin
    perform public.unverify_goal(own_verified);
    raise exception 'expected admin_only from unverify_goal';
  exception
    when sqlstate 'M0018' then
      null;
  end;

  raise notice 'ok: is_group_admin, admin_only on assign and un-verify';
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
    perform public.assign_goal(
      '99999999-9999-4999-8999-999999999999',
      'For a stranger',
      'daily',
      timestamptz '2026-10-10 03:59:59.999+00'
    );
    raise exception 'expected member_not_in_group';
  exception
    when sqlstate 'M0021' then
      null;
  end;

  begin
    perform public.assign_goal(
      '22222222-2222-4222-8222-222222222222',
      '     ',
      'daily',
      timestamptz '2026-10-10 03:59:59.999+00'
    );
    raise exception 'expected invalid_title for spaces only';
  exception
    when sqlstate 'M0016' then
      null;
  end;

  begin
    perform public.assign_goal(
      '22222222-2222-4222-8222-222222222222',
      repeat('a', 141),
      'daily',
      timestamptz '2026-10-10 03:59:59.999+00'
    );
    raise exception 'expected invalid_title for 141 characters';
  exception
    when sqlstate 'M0016' then
      null;
  end;

  raise notice 'ok: member_not_in_group, invalid_title on assign_goal';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  ben uuid := '22222222-2222-4222-8222-222222222222';
  ada_group uuid;
  assigned public.goals;
  seen int;
begin
  select group_id into ada_group from public.members where id = ada;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  assigned := public.assign_goal(
    ben,
    '  Ben assigned goal  ',
    'daily',
    timestamptz '2026-10-10 03:59:59.999+00'
  );

  if assigned.owner_id <> ben
     or assigned.assigned_by <> ada
     or assigned.group_id <> ada_group then
    raise exception 'assigned goal went to % by % in %',
      assigned.owner_id, assigned.assigned_by, assigned.group_id;
  end if;
  if assigned.title <> 'Ben assigned goal' then
    raise exception 'assigned title was not trimmed, got "%"', assigned.title;
  end if;
  if assigned.status <> 'not_started'::public.goal_status
     or assigned.verified then
    raise exception 'assigned goal starts at % / verified %',
      assigned.status, assigned.verified;
  end if;

  -- The A01 trigger reads assigned_by: set, so the event is assigned, and its
  -- actor is the admin while its goal_owner_id is the member.
  select count(*) into seen
  from public.goal_events
  where goal_id = assigned.id
    and action = 'assigned'
    and actor_id = ada
    and goal_owner_id = ben
    and goal_title = 'Ben assigned goal'
    and new_status is null;
  if seen <> 1 then
    raise exception 'assign should log one assigned event, saw %', seen;
  end if;

  perform set_config('momentum.assigned_goal', assigned.id::text, false);

  raise notice 'ok: admin assigned a goal to Ben';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  mine public.goals;
  renamed public.goals;
  seen int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  -- A goal the admin makes for herself is an own goal: assigned_by stays
  -- null, the trigger logs created, and she can still rename it.
  mine := public.assign_goal(
    ada,
    'Ada self assigned',
    'weekly',
    timestamptz '2026-10-12 03:59:59.999+00'
  );

  if mine.assigned_by is not null then
    raise exception 'a self-assigned goal should have assigned_by null';
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = mine.id
    and action = 'created'
    and actor_id = ada;
  if seen <> 1 then
    raise exception 'self-assign should log one created event, saw %', seen;
  end if;

  renamed := public.update_goal_title(mine.id, 'Ada self assigned, renamed');
  if renamed.title <> 'Ada self assigned, renamed' then
    raise exception 'the admin could not rename her own goal';
  end if;

  raise notice 'ok: admin assigning to herself makes a normal own goal';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  ben uuid := '22222222-2222-4222-8222-222222222222';
  assigned uuid := current_setting('momentum.assigned_goal')::uuid;
  moved public.goals;
  own uuid;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  -- The owner of an assigned goal keeps the status and nothing else.
  begin
    perform public.update_goal_title(assigned, 'Not my homework');
    raise exception 'expected assigned_goal_admin_only from update_goal_title';
  exception
    when sqlstate 'M0017' then
      null;
  end;

  begin
    perform public.delete_goal(assigned);
    raise exception 'expected assigned_goal_admin_only from delete_goal';
  exception
    when sqlstate 'M0017' then
      null;
  end;

  moved := public.set_goal_status(assigned, 'in_progress');
  if moved.status <> 'in_progress'::public.goal_status then
    raise exception 'the owner should still move an assigned goal, got %',
      moved.status;
  end if;

  -- assigned_by is the admin's to write: the insert policy rejects a member
  -- who tries to dress their own goal up as one they were given.
  begin
    insert into public.goals (
      owner_id, group_id, title, type, deadline, assigned_by
    )
    values (
      ben,
      public.my_group_id(),
      'Pretend it was assigned',
      'daily',
      timestamptz '2026-10-10 03:59:59.999+00',
      ada
    );
    raise exception 'expected RLS to reject assigned_by on a direct insert';
  exception
    when insufficient_privilege then
      if sqlerrm not like '%row-level security%' then
        raise;
      end if;
  end;

  insert into public.goals (owner_id, group_id, title, type, deadline)
  values (
    ben,
    public.my_group_id(),
    'Ben goal two',
    'daily',
    timestamptz '2026-10-11 03:59:59.999+00'
  )
  returning id into own;

  -- Unassigned and unverified, so his own rules still let him rename it.
  perform public.update_goal_title(own, 'Ben goal two, renamed');
  perform set_config('momentum.ben_goal_two', own::text, false);

  raise notice 'ok: member keeps status on an assigned goal and nothing else';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  assigned uuid := current_setting('momentum.assigned_goal')::uuid;
  moved public.goals;
  verified public.goals;
  seen int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  moved := public.set_goal_status(assigned, 'complete');
  if moved.status <> 'complete'::public.goal_status then
    raise exception 'the admin should move any status, got %', moved.status;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = assigned
    and action = 'status_changed'
    and actor_id = ada
    and new_status = 'complete'::public.goal_status;
  if seen <> 1 then
    raise exception 'the admin status change should log one event, saw %', seen;
  end if;

  -- Verify is a member rule and the admin is a member: she did not own it,
  -- and setting the status herself does not disqualify her.
  verified := public.verify_goal(assigned);
  if not verified.verified then
    raise exception 'the admin should be able to verify a goal she does not own';
  end if;

  raise notice 'ok: admin changes status on any goal, then verifies it';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  assigned uuid := current_setting('momentum.assigned_goal')::uuid;
  ben_unverified uuid := current_setting('momentum.ben_goal_two')::uuid;
  own_verified uuid;
  unverified public.goals;
  seen int;
begin
  select id into own_verified from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  begin
    perform public.unverify_goal(own_verified);
    raise exception 'expected cannot_unverify_own_goal';
  exception
    when sqlstate 'M0019' then
      null;
  end;

  begin
    perform public.unverify_goal(ben_unverified);
    raise exception 'expected goal_not_verified';
  exception
    when sqlstate 'M0020' then
      null;
  end;

  begin
    perform public.unverify_goal('99999999-9999-4999-8999-999999999999');
    raise exception 'expected goal_not_found from unverify_goal';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  unverified := public.unverify_goal(assigned);
  if unverified.verified
     or unverified.status <> 'complete'::public.goal_status then
    raise exception 'un-verify returned status % verified %',
      unverified.status, unverified.verified;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = assigned
    and action = 'unverified'
    and actor_id = ada
    and new_status is null;
  if seen <> 1 then
    raise exception 'un-verify should log one unverified event, saw %', seen;
  end if;

  raise notice 'ok: cannot_unverify_own_goal, goal_not_verified, un-verified';
end;
$$;

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  assigned uuid := current_setting('momentum.assigned_goal')::uuid;
  moved public.goals;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  -- Un-verified means unlocked, not reset: the status the admin left is the
  -- one the owner picks up from.
  moved := public.set_goal_status(assigned, 'in_progress');
  if moved.status <> 'in_progress'::public.goal_status then
    raise exception 'an un-verified goal should move again, got %',
      moved.status;
  end if;

  moved := public.set_goal_status(assigned, 'complete');
  if moved.status <> 'complete'::public.goal_status then
    raise exception 'back to complete returned %', moved.status;
  end if;

  raise notice 'ok: an un-verified goal takes status changes again';
end;
$$;

do $$
declare
  ada uuid := '11111111-1111-4111-8111-111111111111';
  ben uuid := '22222222-2222-4222-8222-222222222222';
  assigned uuid := current_setting('momentum.assigned_goal')::uuid;
  again public.goals;
  renamed public.goals;
  seen int;
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ada, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  again := public.verify_goal(assigned);
  if not again.verified then
    raise exception 'an un-verified goal should be verifiable again';
  end if;

  -- Verified and assigned, which closes it to its owner and to no one else.
  renamed := public.update_goal_title(assigned, 'Admin renamed it');
  if renamed.title <> 'Admin renamed it' or not renamed.verified then
    raise exception 'admin rename returned "%" verified %',
      renamed.title, renamed.verified;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = assigned
    and action = 'title_edited'
    and actor_id = ada
    and goal_title = 'Admin renamed it';
  if seen <> 1 then
    raise exception 'the admin rename should log one event, saw %', seen;
  end if;

  perform public.delete_goal(assigned);

  if (select count(*) from public.goals where id = assigned) <> 0 then
    raise exception 'the admin should have deleted the verified goal';
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = assigned;
  if seen <> 10 then
    raise exception 'the deleted goal should keep its ten events, saw %', seen;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = assigned
    and action = 'deleted'
    and actor_id = ada
    and goal_owner_id = ben;
  if seen <> 1 then
    raise exception 'the delete should log one deleted event, saw %', seen;
  end if;

  raise notice 'ok: admin re-verified, renamed, and deleted a verified goal';
end;
$$;

-- Out of the group, the admin questions never come up: an outsider cannot see
-- the goal to be told anything about it, and has no group to be admin of.
update public.members
set group_id = null
where id = '22222222-2222-4222-8222-222222222222';

do $$
declare
  ben uuid := '22222222-2222-4222-8222-222222222222';
  ada_verified uuid;
begin
  select id into ada_verified from public.goals where title = 'Ada goal one';

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', ben, 'role', 'authenticated')::text,
    true
  );
  execute 'set local role authenticated';

  if public.is_group_admin() then
    raise exception 'a member with no group is no one''s admin';
  end if;

  begin
    perform public.unverify_goal(ada_verified);
    raise exception 'expected goal_not_found from unverify_goal (outsider)';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  begin
    perform public.assign_goal(
      ben,
      'Outsider assigns',
      'daily',
      timestamptz '2026-10-10 03:59:59.999+00'
    );
    raise exception 'expected admin_only from assign_goal (outsider)';
  exception
    when sqlstate 'M0018' then
      null;
  end;

  raise notice 'ok: outsider is not an admin and sees no goal';
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
begin
  execute 'set local role anon';

  begin
    perform public.is_group_admin();
    raise exception 'expected anon execute denied on is_group_admin';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    perform public.unverify_goal('99999999-9999-4999-8999-999999999999');
    raise exception 'expected anon execute denied on unverify_goal';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    perform public.assign_goal(
      '99999999-9999-4999-8999-999999999999',
      'Anon',
      'daily',
      timestamptz '2026-10-10 03:59:59.999+00'
    );
    raise exception 'expected anon execute denied on assign_goal';
  exception
    when insufficient_privilege then
      null;
  end;

  raise notice 'ok: anon cannot assign or un-verify';
end;
$$;
