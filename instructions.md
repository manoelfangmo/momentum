PROJECT CONTEXT — "Momentum" (Flutter app)

What it is: a group accountability app. Members of ONE group create one-off goals
(Day/Week/Month/Year). Other members verify completion; owners mark their own misses.

Stack:
- Flutter (latest stable), Dart 3 (sealed classes, records, patterns OK)
- Supabase running LOCALLY via Supabase CLI (supabase start). Migrations in supabase/migrations.
- supabase_flutter, flutter_riverpod + riverpod_annotation + riverpod_generator (code gen),
  go_router, freezed + json_serializable (field_rename: snake in build.yaml), build_runner.

Architecture (follow ARCHITECTURE.md exactly). Feature-first; each feature in
lib/features/<feature>/ with these layers. Dependencies point down only:
  presentation -> application -> data -> domain
  domain/        Freezed entities (with fromJson), value objects, sealed decisions,
                 computed facts on the entity. NO Flutter, Supabase or Riverpod imports.
                 NO repository interfaces.
  data/          <name>_repository.dart: a concrete class taking SupabaseClient in its
                 constructor, plus a @riverpod provider that reads supabaseProvider.
                 @riverpod Future providers for each read the UI needs.
                 data/models.dart: command objects (with toJson) for methods with >2-3 params.
  application/   ONLY when an action calls >1 repository, runs several steps as one action,
                 or decides something from another feature's data. Services, no BuildContext.
                 Omit the folder otherwise.
  presentation/  <name>_page.dart pages (ConsumerWidget composing small widgets),
                 controllers/ (Riverpod notifiers + combined providers),
                 models/ (UI-only state), validators/, widgets/, routes.dart.

Shared code in lib/core/:
  constants/     theme, environment.dart (local Supabase URL + anon key; 10.0.2.2 on Android)
  database/      table/column/RPC name constants (GoalsTable.deadline, Rpc.verifyGoalComplete).
                 Repositories never use string literals for table or column names.
  domain/        types shared by several features: Member, GoalType, Period
  routing/       go_router.dart, app_routes.dart (AppRoutes paths + publicRoutes),
                 routing_interfaces.dart (ParamAppRoute, SimpleAppRoute)
  utils/         providers.dart (supabaseProvider, clockProvider), app_exception.dart,
                 extensions, toasts
  widgets/       shared buttons, sheets, empty/error/loading widgets

Conventions:
- Never call Supabase.instance or DateTime.now() in features: use supabaseProvider and
  clockProvider.
- Writes: single call -> widget/notifier calls the repository directly; multi-step or
  cross-feature -> the service. Afterwards ref.invalidate every provider showing old data.
- Repositories throw AppException subclasses (core/utils/app_exception.dart); widgets
  handle AsyncValue with .when(data, loading, error).
- Never edit *.g.dart / *.freezed.dart. Regenerate with
  dart run build_runner build --delete-conflicting-outputs
- Times: timestamptz stored UTC; entities convert to local in fromJson; commands convert to
  UTC in toJson. Periods computed in local time; weeks start Monday; one timezone per group.
- A goal's deadline = last instant of its period (period end minus 1 ms). A goal belongs to
  the period containing its deadline.
- All goal status changes go through Postgres RPCs (no client UPDATE on goals).
- After generating code, list every file created/changed and the exact commands to run.

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