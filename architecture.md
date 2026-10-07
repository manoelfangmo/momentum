# Application architecture

This guide explains how the Momentum app is structured. The **goals** feature is the example. Open it while you read.

Setup, environment files, and how to run the app and the local Supabase stack are in the [README](README.md).

## The idea

Each product area is a **feature**. A feature owns its screens, its state, its business rules, and its database access. Shared infrastructure lives in `app/lib/core/`. That includes routing, theme, the Supabase client, period math, and widgets used by many features.

Inside a feature, code is split into four layers. A widget never talks to Supabase. A repository never builds UI.

```
presentation   screens, widgets, and the state those widgets watch
      │
      ▼
application    coordinates more than one repository, or more than one step
      │
      ▼
data           Supabase queries, RPC calls
      │
      ▼
domain         the types those layers pass around
```

Dependencies point downward. `domain` imports none of the other three. `data` imports `domain`. `application` imports `data` and `domain`. `presentation` may use all three.

## Where the code lives

```
app/lib/
├── main.dart                 # starts Supabase (local), then runs App
├── app.dart                  # MaterialApp.router wired to goRouterProvider
├── core/
│   ├── constants/            # theme, environment (local Supabase URL / anon key)
│   ├── database/             # table name classes (GoalsTable, MembersTable, …)
│   ├── domain/               # types shared by several features: Member, GoalType, Period
│   ├── routing/              # GoRouter, AppRoutes, route base classes
│   ├── utils/                # providers.dart (Supabase client, clock), extensions, toasts
│   └── widgets/              # buttons, sheets, empty/error states used by more than one feature
└── features/
    ├── auth/
    ├── groups/
    ├── goals/
    ├── history/
    └── stats/

supabase/
├── config.toml
├── migrations/               # schema, RLS policies, RPC functions
└── seed.sql
```

Every feature uses the same four folders. A small feature can leave out `application/` when nothing needs to coordinate more than one repository. `stats` has no `data/` folder at all. It computes from goals other features already loaded.

`app/lib/core/domain/` is for types that more than one feature needs. `Member` is used by auth, groups, and goals. `GoalType` and `Period` are used by goals, history, and stats. A type used by only one feature stays in that feature's `domain/`.

## Goals, folder by folder

```
features/goals/
├── domain/
│   ├── goal.dart                     # goal record the rest of the app uses
│   ├── goal_status.dart              # pending / complete / missed
│   ├── goal_event.dart
│   └── goal_action_availability.dart # verify / markMissed / none
├── data/
│   ├── goals_repository.dart         # Supabase for goal rows and status RPCs
│   └── models.dart                   # command objects sent to the database
├── application/
│   └── goal_service.dart             # create goal; check permission before an action
└── presentation/
    ├── goals_page.dart               # Day / Week / Month / Year tabs
    ├── controllers/                  # Riverpod notifiers and combined providers
    ├── models/                       # state that exists only for the UI
    ├── validators/
    └── widgets/
```

Open `goals_page.dart` first. It is a `Scaffold` with a `TabBar` and a member picker. It does not fetch data itself. Each tab is a `GoalTabView` that watches the provider it needs.

## Reading data: a goal tab

A tab needs the selected member's goals for one period. Which member and which period come from UI state. The goals come from the repository. A controller combines them.

```
GoalTabView(type)
  watches goalTabDataProvider(type)
    watches goalsViewControllerProvider          → selected member, selected day (UI state)
    watches goalsForPeriodProvider(memberId, period) → GoalsRepository.fetchGoals
  builds GoalTabData
```

The controller is a generated async provider:

```dart
@riverpod
Future<GoalTabData> goalTabData(Ref ref, GoalType type) async {
  final view = ref.watch(goalsViewControllerProvider);
  final now = ref.watch(clockProvider)();
  final period = type == GoalType.daily
      ? Period.containing(view.selectedDay, GoalType.daily)
      : Period.containing(now, type);

  final goals = await ref.watch(
    goalsForPeriodProvider(view.selectedMemberId, period).future,
  );
  return GoalTabData(memberId: view.selectedMemberId, period: period, goals: goals);
}
```

`type` makes this a **family** provider: `goalTabDataProvider(GoalType.daily)` and `goalTabDataProvider(GoalType.weekly)` are two caches. The widget handles loading, data, and error in one place:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final tabAsync = ref.watch(goalTabDataProvider(type));

  return tabAsync.when(
    data: (tab) => _buildGoalList(context, tab),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => ErrorRetry(
      onRetry: () => ref.invalidate(goalTabDataProvider(type)),
    ),
  );
}
```

The repository is the only class that knows table names, columns, and RPC names:

```dart
Future<List<Goal>> fetchGoals({
  required String ownerId,
  required Period period,
}) async {
  final rows = await _supabase
      .from(GoalsTable.name)
      .select()
      .eq(GoalsTable.ownerId, ownerId)
      .eq(GoalsTable.type, period.type.toDb())
      .gte(GoalsTable.deadline, period.start.toUtc().toIso8601String())
      .lt(GoalsTable.deadline, period.end.toUtc().toIso8601String())
      .order(GoalsTable.createdAt);
  return rows.map(Goal.fromJson).toList();
}
```

`Goal` is the domain type. `GoalTabData` is the presentation type: the goals plus the member and period the tab header needs. Domain types describe the business. Presentation models describe what one screen needs to render.

A simpler read skips the controller. The group page watches `groupMembersProvider(groupId)`, which calls `GroupsRepository.fetchMembers` directly. Use a controller when the widget needs data assembled from more than one provider. Use the repository provider when one query is the whole story.

## Writing data: two patterns

### One repository, one call

Joining a group is a single RPC. `JoinGroupForm` calls the repository, then invalidates the current member so the router sees the new `groupId` and leaves onboarding:

```dart
await ref.read(groupsRepositoryProvider).joinGroup(groupId);
ref.invalidate(currentMemberProvider);
```

Verifying a goal is the same shape. The tile calls `GoalsRepository.verifyComplete(goalId)`, then invalidates the tab, history, and stats providers that show that goal.

`ref.watch` subscribes and rebuilds. `ref.read` fires an action and does not subscribe. `ref.invalidate` drops the cached value so the next watch refetches.

### Several steps, or data from another feature

Creating a goal needs the signed-in member's `groupId`, which the groups and auth features own. It also needs a deadline computed from the tab's type. That belongs in `GoalService`, which the create-goal notifier calls:

```dart
Future<void> submit({required GoalType type}) async {
  await ref.read(goalServiceProvider).createGoal(
        title: state.title.trim(),
        type: type,
      );
  ref.invalidate(goalTabDataProvider(type));
}
```

The service reads the current member, computes `Period.containing(now, type).deadline`, builds a `CreateGoalCommand`, and calls the repository. The notifier only holds what the user typed (`CreateGoalFormState`).

Put logic in `application/` when it:

- calls more than one repository, or
- runs several repository calls that must succeed as one user action, or
- decides something from data owned by another feature.

`getGoalActionAvailability` is the third case. A pending goal shows **Verify** when the viewer is not the owner. It shows **Mark missed** when the viewer is the owner. Complete and missed goals show nothing. The service reads the current member and the goal, then returns a `GoalActionAvailability`. `GoalTile` renders a button for each case. The tile does not compare user ids itself.

The database enforces the same rules again inside `verify_goal_complete` and `mark_goal_missed`. The app's check decides what to show. The RPC decides what is allowed.

## What each layer is allowed to do

| Layer | Put it here | Leave it out |
| --- | --- | --- |
| `presentation/` | Widgets, route classes, form state, validators, UI-only models | Supabase calls, multi-step workflows |
| `application/` | Services that order repository calls or combine features | Widgets, `BuildContext` |
| `data/` | Repositories, command objects passed into those repositories | UI state, navigation |
| `domain/` | Entities, value objects, decisions (`GoalActionAvailability`) | Flutter, Supabase, Riverpod |

Table and column names are not string literals scattered through repositories. They live on classes in `app/lib/core/database/`, for example `GoalsTable.deadline` and `MembersTable.groupId`. RPC names live there too, on `Rpc.verifyGoalComplete`.

A repository or service method with more than two or three parameters takes one **command** object, defined next to the repository in `data/models.dart`. `CreateGoalCommand` is the goals example: the service builds it, `toJson()` is the insert payload.

## Riverpod

State and dependency injection both go through Riverpod code generation. Annotate a function or class, then run build_runner. The generated `*.g.dart` file creates the provider (`goalTabData` becomes `goalTabDataProvider`).

| Annotation | What you get | Momentum example |
| --- | --- | --- |
| `@riverpod` on a `Future` function | Async provider, disposed when nothing watches it | `groupMembers`, `goalsForPeriod` |
| `@riverpod` with an extra argument | Family provider, one cache per argument | `goalTabData(ref, type)` |
| `@riverpod` on a class extending the generated notifier | Mutable state, usually a form or view selection | `GoalsViewController`, `CreateGoalFormNotifier` |
| `@Riverpod(keepAlive: true)` | Provider that survives after the last listener | `supabase`, `goalService`, `currentMember` |

Widgets that read providers extend `ConsumerWidget` or `ConsumerStatefulWidget`.

Repositories and services are constructed by providers, not by `new` at the call site:

```dart
@riverpod
GoalsRepository goalsRepository(Ref ref) {
  final SupabaseClient supabase = ref.read(supabaseProvider);
  return GoalsRepository(supabase);
}
```

`supabaseProvider` in `app/lib/core/utils/providers.dart` is the one Supabase client. Features depend on that provider. They do not call `Supabase.instance` themselves.

`clockProvider` in the same file returns the current time. Anything that asks "what period is it now" reads `clockProvider`, never `DateTime.now()`, so tests can freeze time.

After you add or change a `@riverpod`, `@freezed`, or `@JsonSerializable` annotation, regenerate from the project root:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Do not edit `*.g.dart` or `*.freezed.dart`. Change the source file and regenerate.

## Domain models

`Goal` is a Freezed class with `fromJson`. Freezed gives you `copyWith`, equality, and (for a sealed class) exhaustive cases. `GoalActionAvailability` is the sealed example: `verify`, `markMissed`, and `none`. The goal tile branches on those cases.

JSON field renaming is configured for the project (`field_rename: snake` in `build.yaml`), so `ownerId` in Dart matches `owner_id` from Postgres without a manual map at every call. Timestamps arrive as UTC. `Goal.fromJson` converts `deadline` and `createdAt` to local time, and command objects convert back to UTC in `toJson()`.

Computed facts that depend only on the entity live on the domain type. `Goal.isOverdue(now)` and `Goal.period` are examples. `Period` in `app/lib/core/domain/` owns all period math: `Period.containing(date, type)`, `start`, `end`, `deadline`, `previous()`, `label`. Weeks start Monday. Widgets read these. They do not reimplement the date math.

Completion percentage is a domain function in `features/stats/domain/`. `completionFor(goals)` counts complete goals over all goals, with pending counted as missed. The tab header and each History period header call it on goals they already have.

## Routing

Signed-in sections are branches of one `StatefulShellRoute` in `app/lib/core/routing/go_router.dart`. Each branch has its own navigator key, so switching from Goals to History keeps each section's tab and scroll position. The branches are `/goals`, `/history`, and `/group`. The shell widget is `HomePage`, which draws the bottom navigation bar.

Path strings live in `AppRoutes` (`app/lib/core/routing/app_routes.dart`). The router's `redirect` does three things:

- sends signed-out users to sign-in
- sends signed-in users with no group to `/onboarding`
- sends signed-in users who have a group away from sign-in and onboarding

`AppRoutes.publicRoutes` lists pages that work without a session: sign-in and sign-up. The router is built once in a provider and refreshed through `refreshListenable` when `currentMemberProvider` changes. It is never rebuilt on each change.

Routes that take parameters are classes in the feature, not inline `GoRoute`s. Each one extends `ParamAppRoute` or `SimpleAppRoute` from `app/lib/core/routing/routing_interfaces.dart` and lives in that feature's `presentation/routes.dart`.

## How a new feature should look

1. Create `app/lib/features/<name>/domain/` with the entities. Use `@freezed` when the type is sent to or from JSON, or when the UI copies it. If another feature needs the type, put it in `app/lib/core/domain/` instead.
2. Create `data/<name>_repository.dart`. Take `SupabaseClient` in the constructor. Expose a `@riverpod` provider that reads `supabaseProvider`. Add a `Future` provider per read the UI needs. Add table and column constants to `app/lib/core/database/`.
3. Add an `application/` service only when a user action needs more than one repository call or another feature's data.
4. Build the page as a `ConsumerWidget` that composes smaller widgets. Each widget watches the provider it renders.
5. Keep form drafts and view selections in a notifier under `presentation/controllers/`. Submit through the service or, for a single call, through the repository. Then `ref.invalidate` every provider that displayed the old value.
6. Register a shell branch in `go_router.dart` for a main nav destination. Add a class in `presentation/routes.dart` for a page that takes arguments. Add the path to `AppRoutes`.

## Backend

The app talks to a Supabase stack running locally through the Supabase CLI (`supabase start`). There is no application server. Queries and RPCs are called from repositories.

Schema, RLS policies, and SQL functions live in `supabase/migrations/` in this repo. Apply them with `supabase db reset` locally. Rules the database must enforce belong in SQL functions called with `supabase.rpc(...)`. Every goal status change goes through `verify_goal_complete` or `mark_goal_missed`. Those functions also write the `goal_events` row in the same transaction. Clients have no direct `UPDATE` on `goals`. Do not add Supabase Edge Functions for this logic.

When running on an Android emulator, the local Supabase URL uses `10.0.2.2` instead of `localhost`. `app/lib/core/constants/environment.dart` handles this.