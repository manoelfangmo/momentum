-- Momentum initial schema. RLS is on with no policies so the Data API stays
-- denied for anon/authenticated until policies land in T03.

create type public.goal_type as enum ('daily', 'weekly', 'monthly', 'yearly');

create type public.goal_status as enum ('pending', 'complete', 'missed');

create type public.goal_action as enum ('verified_complete', 'marked_missed');

-- char_length counts characters, so a 60-character name is valid in any script.
create table public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 60),
  created_by uuid not null,
  -- NOT NULL so a default of now() cannot be overwritten with null.
  created_at timestamptz not null default now()
);

create table public.members (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null,
  group_id uuid null references public.groups (id) on delete set null,
  created_at timestamptz not null default now()
);

-- Immediate, not deferred: the auth trigger inserts the member before any group row.
-- Default ON DELETE NO ACTION: deleting the creator does not drop or reassign the group.
alter table public.groups
  add constraint groups_created_by_fkey
  foreign key (created_by) references public.members (id);

-- id defaults to gen_random_uuid() so clients can omit it, same as groups.
create table public.goals (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.members (id),
  group_id uuid not null references public.groups (id),
  title text not null check (char_length(title) between 1 and 140),
  type public.goal_type not null,
  deadline timestamptz not null,
  status public.goal_status not null default 'pending',
  created_at timestamptz not null default now()
);

-- goal_id and actor_id are NOT NULL so an event always names a goal and a member.
-- "timestamp" is quoted because timestamp is a reserved word.
create table public.goal_events (
  id uuid primary key default gen_random_uuid(),
  goal_id uuid not null references public.goals (id) on delete cascade,
  actor_id uuid not null references public.members (id),
  action public.goal_action not null,
  "timestamp" timestamptz not null default now()
);

-- (owner_id, type, deadline) matches completion lookups: member + type + period.
create index goals_owner_id_type_deadline_idx
  on public.goals (owner_id, type, deadline);

create index goals_group_id_idx
  on public.goals (group_id);

create index goal_events_goal_id_idx
  on public.goal_events (goal_id);

create index members_group_id_idx
  on public.members (group_id);

-- Last-resort name 'member' keeps signup from failing when metadata and email are both empty.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.members (id, name)
  values (
    new.id,
    coalesce(
      nullif(btrim(new.raw_user_meta_data ->> 'name'), ''),
      nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
      'member'
    )
  );
  return new;
end;
$$;

-- Data API roles lose execute; only supabase_auth_admin (the auth insert role) keeps it.
revoke all on function public.handle_new_user() from public, anon, authenticated, service_role;
grant execute on function public.handle_new_user() to supabase_auth_admin;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

alter table public.groups enable row level security;
alter table public.members enable row level security;
alter table public.goals enable row level security;
alter table public.goal_events enable row level security;
