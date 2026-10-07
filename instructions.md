PROJECT CONTEXT — "Momentum" (Flutter app)

What it is: a group accountability app. Members of ONE group create one-off goals
(Day/Week/Month/Year). Other members verify completion; owners mark their own misses.

Stack:
- Flutter (latest stable), Dart 3 (sealed classes, records, patterns OK)
- Supabase running LOCALLY via Supabase CLI (supabase start). Migrations in supabase/migrations.
- supabase_flutter for client access
- flutter_riverpod + riverpod_annotation + riverpod_generator (code-gen providers)
- go_router for navigation
- freezed + json_serializable for entities/DTOs
- build_runner for code gen

Architecture: clean architecture, FEATURE-FIRST. Each feature lives in lib/features/<feature>/
with exactly these layers:
  domain/        entities (freezed, no JSON), repository INTERFACES (abstract classes),
                 pure business logic. No Flutter, no Supabase imports.
  data/          DTOs (freezed + json_serializable, snake_case <-> camelCase mapping),
                 remote data sources (talk to SupabaseClient), repository IMPLEMENTATIONS,
                 DTO <-> entity mappers, and the Riverpod provider exposing the repository.
  application/   Riverpod notifiers/services: orchestrate repositories, hold screen state,
                 expose AsyncValue to the UI. No widgets.
  presentation/  screens + widgets only. Watch application providers. No Supabase calls.
Shared code lives in lib/core/ (router, supabase client provider, errors, period utils, theme).

Rules:
- Dependency direction: presentation -> application -> domain <- data. Domain imports nothing else.
- Repositories throw typed AppException subclasses (lib/core/errors). Application layer
  surfaces them via AsyncValue.error; presentation shows a SnackBar / error widget.
- All DB writes that change goal status go through Postgres RPC functions (never direct UPDATE).
- Times: store timestamptz in UTC; compute periods in the device's LOCAL time. MVP assumes the
  whole group shares one timezone. Weeks start Monday (ISO).
- A goal's deadline = the last instant of its period (period end minus 1 ms).
- A goal belongs to the period that contains its deadline.
- Keep files small; one widget/class per file where reasonable. Add unit tests for pure logic.
- After generating code, list every file created/changed and the exact commands to run
  (e.g. dart run build_runner build -d, supabase migration up).

Data model (Postgres):
  members(id uuid PK = auth.users.id, name text, group_id uuid NULL FK groups)
  groups(id uuid PK, name text, created_by uuid FK members)
  goals(id, owner_id FK members, group_id FK groups, title, type goal_type,
        deadline timestamptz, status goal_status default 'pending', created_at)
  goal_events(id, goal_id FK goals, actor_id FK members, action goal_action, timestamp)
  enums: goal_type(daily|weekly|monthly|yearly), goal_status(pending|complete|missed),
         goal_action(verified_complete|marked_missed)

Product rules:
- A member belongs to at most one group.
- Goals are created from a tab; type comes from the tab; deadline defaults to end of
  the current period. Members only create goals for themselves.
- Any member EXCEPT the owner can verify a goal complete. Only the owner can mark it missed.
- Only pending goals can change status; complete/missed are final for MVP.
- No expiry: overdue pending goals can still be verified or marked missed.
- Completion % = complete / all goals for member+type+period (pending counts as a miss).