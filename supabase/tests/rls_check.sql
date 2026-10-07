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
--   M0004 not_same_group
--   M0005 cannot_verify_own_goal
--   M0006 goal_not_pending
--   M0007 only_owner_can_mark_missed
--   M0008 not_authenticated
--   42501 permission denied, or a row-level security violation

-- ---------------------------------------------------------------------------
-- Setup. Ada and Ben. The auth trigger inserts their members rows.
-- ---------------------------------------------------------------------------

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
-- 4. Ada inserts a pending goal for herself. complete-on-insert and an
--    insert owned by Ben are rejected. Ben cannot insert or select goals.
--    Direct goal update/delete and group insert are denied.
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

  raise notice 'ok: insert own pending goal; reject complete and other owner';
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
-- 5. Unknown id is goal_not_found. Ada cannot verify her own goal.
--    Ben is not in the group, so verify and mark are not_same_group.
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
    perform public.verify_goal_complete('99999999-9999-4999-8999-999999999999');
    raise exception 'expected goal_not_found from verify';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  begin
    perform public.mark_goal_missed('99999999-9999-4999-8999-999999999999');
    raise exception 'expected goal_not_found from mark';
  exception
    when sqlstate 'M0003' then
      null;
  end;

  begin
    perform public.verify_goal_complete(target);
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
    perform public.verify_goal_complete(target);
    raise exception 'expected not_same_group from verify';
  exception
    when sqlstate 'M0004' then
      null;
  end;

  begin
    perform public.mark_goal_missed(target);
    raise exception 'expected not_same_group from mark';
  exception
    when sqlstate 'M0004' then
      null;
  end;

  raise notice 'ok: not_same_group';
end;
$$;

-- Harness insert as postgres. Authenticated has no insert on goal_events.
insert into public.goal_events (goal_id, actor_id, action)
select id, owner_id, 'verified_complete'
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

  select count(*) into seen from public.goal_events;
  if seen <> 1 then
    raise exception 'Ada should see the event, saw %', seen;
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
    insert into public.goal_events (goal_id, actor_id, action)
    values (
      '99999999-9999-4999-8999-999999999999',
      ben,
      'marked_missed'
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
-- 7. Ben verifies Ada's pending goal. A second call is goal_not_pending.
--    Ada cannot mark that completed goal missed.
-- ---------------------------------------------------------------------------

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

  updated := public.verify_goal_complete(target);
  if updated.status <> 'complete'::public.goal_status then
    raise exception 'verify returned status %', updated.status;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and actor_id = ben
    and action = 'verified_complete';
  if seen <> 1 then
    raise exception 'Ben should see his verified_complete event, saw %', seen;
  end if;

  begin
    perform public.verify_goal_complete(target);
    raise exception 'expected goal_not_pending';
  exception
    when sqlstate 'M0006' then
      null;
  end;

  raise notice 'ok: verify_goal_complete, then goal_not_pending';
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
  where goal_id = target and action = 'verified_complete';
  if seen <> 1 then
    raise exception 'Ada should see the verified_complete event, saw %', seen;
  end if;

  begin
    perform public.mark_goal_missed(target);
    raise exception 'expected goal_not_pending from owner on a complete goal';
  exception
    when sqlstate 'M0006' then
      null;
  end;

  raise notice 'ok: complete goal stays complete';
end;
$$;

-- ---------------------------------------------------------------------------
-- 8. Ben cannot mark Ada's new goal missed. Ada can. It then stays missed.
--    anon cannot execute RPCs or read the tables.
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
    perform public.mark_goal_missed(target);
    raise exception 'expected only_owner_can_mark_missed';
  exception
    when sqlstate 'M0007' then
      null;
  end;

  raise notice 'ok: only_owner_can_mark_missed';
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

  updated := public.mark_goal_missed(target);
  if updated.status <> 'missed'::public.goal_status then
    raise exception 'mark returned status %', updated.status;
  end if;

  select count(*) into seen
  from public.goal_events
  where goal_id = target
    and actor_id = ada
    and action = 'marked_missed';
  if seen <> 1 then
    raise exception 'Ada should see her marked_missed event, saw %', seen;
  end if;

  begin
    perform public.mark_goal_missed(target);
    raise exception 'expected goal_not_pending after missed';
  exception
    when sqlstate 'M0006' then
      null;
  end;

  raise notice 'ok: mark_goal_missed, then goal_not_pending';
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
    perform public.verify_goal_complete(target);
    raise exception 'expected goal_not_pending for a missed goal';
  exception
    when sqlstate 'M0006' then
      null;
  end;

  raise notice 'ok: missed goal cannot be verified';
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
