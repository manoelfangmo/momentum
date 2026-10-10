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
│   └── widgets/              # buttons, day selector, empty/error states used by more than one feature
└── features/
    ├── auth/
    ├── groups/
    ├── goals/
    ├── admin/
    ├── history/
    └── stats/

supabase/
├── config.toml
├── migrations/               # schema, RLS policies, RPC functions
└── seed.sql
```

Every feature uses the same four folders. A small feature can leave out `application/` when nothing needs to coordinate more than one repository. `stats` has no `data/` folder at all. It computes from goals other features already loaded, and `admin` is `presentation/` only: it is a second way to read goals the goals feature already fetches, and it assigns one through that feature's `GoalService`.

`app/lib/core/domain/` is for types that more than one feature needs. `Member` is used by auth, groups, and goals. `GoalType` and `Period` are used by goals, history, and stats. A type used by only one feature stays in that feature's `domain/`.

## Goals, folder by folder

```
features/goals/
├── domain/
│   ├── goal.dart                     # goal record the rest of the app uses
│   ├── goal_status.dart              # not_started / in_progress / complete
│   ├── goal_event.dart               # created / assigned / status_changed / …
│   └── goal_permissions.dart         # what one viewer may do to one goal
├── data/
│   ├── goals_repository.dart         # Supabase for goal rows and the goal RPCs
│   └── models.dart                   # command objects sent to the database
├── application/
│   └── goal_service.dart             # create and assign goals; viewer permissions
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

`groupGoalsForPeriodProvider(groupId, period)` is the admin's read: one query for every member's goals in that period, ordered by owner and then `created_at` so the page can group rows under a member without sorting them again. It is a separate provider rather than a loop over `goalsForPeriodProvider` because the admin tab shows the whole group at once.

## The admin tab

`features/admin/` is the `/admin` branch, and it owns no data of its own:

```
features/admin/presentation/
├── admin_page.dart                     # Day / Week / Month / Year tabs, and the assign button
├── controllers/
│   ├── admin_view_controller.dart      # the day the Day tab is on
│   ├── admin_tab_controller.dart       # adminPeriod + adminTabData
│   └── assign_goal_form_notifier.dart  # the draft behind the assign sheet
├── models/
│   ├── member_goals.dart               # one member and their goals
│   └── assign_goal_form_state.dart     # who the goal is for, and its title
└── widgets/
    ├── admin_tab_view.dart             # the member sections of one tab
    └── assign_goal_sheet.dart          # give one member one goal
```

`adminTabData(type)` is the goals tabs' `goalTabData` read sideways. It takes the period from `adminPeriod(type)` — the selected day on Day, the period containing now on the other three — then awaits `groupGoalsForPeriodProvider` and `groupMembersProvider` together and files each goal under its owner. Every member gets a `MemberGoals`, including the ones with nothing set, because an empty section is what the admin is looking for. The admin's own section is first, then everyone else in the order the members read returns them, which is by name.

`AdminViewController` holds the Day tab's date and nothing else. It is deliberately not a field on `GoalsViewController`: the admin moves between the two screens to compare one member's view with the group's, and a date picked on one has no business moving the other. Week, Month and Year have no date to move at all — ended periods are History's, and the admin has no History.

The sections are drawn with the widgets that already exist: `GoalTile` for each goal, so the admin gets whatever `goalPermissions` grants them on another member's goal, and `CompletionBadge(completionFor(goals))` for each member's rate. The Day tab's date control is `DaySelector` in `core/widgets/`, which holds nothing: it takes the day on screen and gives back the one chosen, so the goals tabs and the admin tabs can each point it at their own notifier.

`AssignGoalSheet` is the one thing the admin feature writes, and the only part of it that is not a read of somebody else's provider. The page's floating button opens it on the type of the tab in front, the way the goals page opens `CreateGoalSheet`. The sheet is that sheet plus the field it has no use for: a dropdown of `groupMembersProvider` with the admin listed as "Me". Nothing is selected when it opens, because assigning to the wrong person leaves a goal somebody has to delete. The deadline is shown and not chosen — both sheets render `CurrentPeriodDueLabel`, which reads `clockProvider` and names the end of the current period, so the Day tab's date picker never reaches it.

`AssignGoalFormNotifier` holds the draft and submits it through `GoalService.assignGoal`, then invalidates `groupGoalsForPeriodProvider` and `goalsForPeriodProvider`: the new goal lands on the admin tab it was made from and on its owner's own tab. The admin picking themselves is not a branch in Dart. `assign_goal` writes `assigned_by` only when the owner is somebody else, so a goal the admin sets for themselves comes back as a normal own goal.

## Writing data: two patterns

### One repository, one call

Joining a group is a single RPC. `JoinGroupForm` calls the repository, then invalidates the current member so the router sees the new `groupId` and leaves onboarding:

```dart
await ref.read(groupsRepositoryProvider).joinGroup(groupId);
ref.invalidate(currentMemberProvider);
```

Verifying a goal is the same shape. The tile calls `GoalsRepository.verify(goalId)`, then invalidates the tab, history, and stats providers that show that goal. Changing status calls `GoalsRepository.setStatus(goalId, status)` the same way, as does `unverify(goalId)`, and so do `updateTitle(goalId, title)` and `deleteGoal(goalId)` behind the tile's menu. All five go through `GoalActionController`, a family keyed by goal id that holds one call's progress and runs the invalidations.

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

`GoalService.assignGoal` is the admin's version of the same shape and is there for the same reason: it computes the deadline from the clock, builds an `AssignGoalCommand`, and calls `assign_goal`. It takes the owner because the admin picks one, and the deadline is always the end of the current period — never the day the Day tab happens to be showing. It takes no group and makes no check that the caller is the admin: the RPC reads both from the caller and refuses anyone else.

Put logic in `application/` when it:

- calls more than one repository, or
- runs several repository calls that must succeed as one user action, or
- decides something from data owned by another feature.

`goalPermissions` is the third case. It answers what the signed-in member may do to one goal, as five independent booleans on a `GoalPermissions`: `canChangeStatus`, `canVerify`, `canUnverify`, `canEdit`, `canDelete`. Independent rather than one choice, because they combine — the admin looking at another member's complete goal may move its status, verify it, rename it, and delete it, all at once. `GoalActions` draws a control for each flag it finds set and a lock when a verified goal offers none; `GoalMenu` shows itself only when `canEdit` or `canDelete` is. Neither widget compares member ids.

Because they combine, `GoalTile` gives them two different places. `GoalMenu` is one icon and sits in the tile's trailing slot. `GoalActions` is a `Wrap` in a row of its own under the tile, which is what keeps a status picker, a Verify and a menu on the same goal from squeezing the title off the card. The flags the admin alone can hold are the ones that say so in the copy: un-verifying confirms that the goal stays complete and can be verified again, and deleting a verified goal adds that it removes a verified completion. `AssignedByLabel` is the other side of that reach — on a goal where `Goal.isAssigned`, it names the admin from `groupMembersProvider`, so the owner who finds no menu can see why.

The rule itself is `permissionsFor(goal, viewerId:, isAdmin:)`, a pure function in `domain/`. The provider exists only to feed it the two facts it cannot reach from a `Goal`: the signed-in member from auth, and `isGroupAdminProvider` from groups. An admin flag that has not resolved yet counts as not the admin, so the first frame never offers a control the viewer cannot use.

The database enforces the same rules again inside `set_goal_status`, `verify_goal`, `unverify_goal`, `update_goal_title`, and `delete_goal`. The app's check decides what to show. The RPC decides what is allowed. Verifying closes a goal to its owner: no status change, no rename, no delete.

The group admin — the member who created the group, `groups.created_by` — is the exception to all of that, and `isGroupAdminProvider` is how the app asks. The admin may change the status of any unverified goal, rename or delete any goal including a verified one, un-verify a goal they do not own through `unverify_goal`, and give a goal to one member through `assign_goal`. Un-verifying is the only way out of the verified state: the goal stays complete, unlocks, and can be verified again. A goal the admin assigned is the mirror of the admin's reach: `goals.assigned_by` names them, `Goal.isAssigned` reads it, and the owner may move its status and nothing else. There is no expiry — every rule above holds after the deadline, in the app and in SQL.

## What each layer is allowed to do

| Layer | Put it here | Leave it out |
| --- | --- | --- |
| `presentation/` | Widgets, route classes, form state, validators, UI-only models | Supabase calls, multi-step workflows |
| `application/` | Services that order repository calls or combine features | Widgets, `BuildContext` |
| `data/` | Repositories, command objects passed into those repositories | UI state, navigation |
| `domain/` | Entities, value objects, decisions (`GoalPermissions`) | Flutter, Supabase, Riverpod |

Table and column names are not string literals scattered through repositories. They live on classes in `app/lib/core/database/`, for example `GoalsTable.deadline` and `MembersTable.groupId`. RPC names live there too, on `Rpc.setGoalStatus` and `Rpc.verifyGoal`.

A repository or service method with more than two or three parameters takes one **command** object, defined next to the repository in `data/models.dart`. `CreateGoalCommand` is the goals example: the service builds it, `toJson()` is the insert payload. `AssignGoalCommand` is the same idea for an RPC, so its `toJson()` keys are the function's argument names (`Rpc.pOwnerId` and the rest) rather than column names.

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

After you add or change a `@riverpod`, `@freezed`, `@JsonSerializable`, or `@GenerateNiceMocks` annotation, regenerate from the project root:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Do not edit `*.g.dart`, `*.freezed.dart`, or `*.mocks.dart`. Change the source file and regenerate.

## Tests

Tests live in `app/test/`, mirroring `app/lib/`, and run with `flutter test`. Nothing in the suite talks to a running Supabase stack.

Test doubles come from **mockito**, not from hand-written fakes. `app/test/mocks.dart` carries one annotation for the whole suite and re-exports what `build_runner` generates:

```dart
@GenerateNiceMocks([MockSpec<AuthRepository>(), MockSpec<MemberRepository>()])
export 'mocks.mocks.dart';
```

That writes `app/test/mocks.mocks.dart` with `MockAuthRepository` and `MockMemberRepository`. When a new repository or service needs a double, add a `MockSpec` there and regenerate. Do not write a class that `implements` a repository by hand.

`GenerateNiceMocks` returns a harmless default from every member you do not stub — null, an empty stream, a completed future — so a test only sets up the calls it is about. Inject the mock by overriding the provider that builds the real one:

```dart
final repository = MockAuthRepository();
final container = ProviderContainer(
  overrides: [authRepositoryProvider.overrideWithValue(repository)],
);

when(
  repository.signIn(email: anyNamed('email'), password: anyNamed('password')),
).thenThrow(const AuthException('Invalid login credentials'));

await container.read(authControllerProvider.notifier).signIn(
      email: 'ada@example.com',
      password: 'wrong',
    );

verify(repository.signIn(email: 'ada@example.com', password: 'wrong')).called(1);
```

Two Riverpod behaviours trip people up in tests:

- An async provider does not start until something listens to it. Call `container.listen(provider, (_, _) {})` before awaiting `provider.future`, and pass `onError` when the test expects a failure.
- A provider that throws is retried ten times with a growing backoff, which outlasts the test timeout. Give `ProviderContainer` a `retry: (count, error) => null` when asserting on an error.

## Domain models

`Goal` is a Freezed class with `fromJson`. Freezed gives you `copyWith`, equality, and (for a sealed class) exhaustive cases. `verified` is a boolean on the goal; it can only be true when `status` is complete, and only `unverify_goal` takes it back. `GoalPermissions` is a Freezed value object with no JSON at all — the equality is what lets a test compare a whole answer against one named constant instead of five fields. `Goal.countsAsDone` is true only for complete and verified.

JSON field renaming is configured for the project (`field_rename: snake` in `build.yaml`), so `ownerId` in Dart matches `owner_id` from Postgres without a manual map at every call. Timestamps arrive as UTC. `Goal.fromJson` converts `deadline` and `createdAt` to local time, and command objects convert back to UTC in `toJson()`.

Computed facts that depend only on the entity live on the domain type. `Goal.isOverdue(now)` and `Goal.period` are examples. `Period` in `app/lib/core/domain/` owns all period math: `Period.containing(date, type)`, `start`, `end`, `deadline`, `previous()`, `label`. Weeks start Monday. Widgets read these. They do not reimplement the date math.

Completion percentage is a domain function in `features/stats/domain/`. `completionFor(goals)` counts goals where `goal.countsAsDone` (complete and verified) over all goals. Everything else is a miss, including complete-but-unverified. An empty list is 0 of 0 with no percent. The tab header and each History period header call it on goals they already have. The badge label reads `"2/3 verified · 67%"`.

## Routing

Signed-in sections are branches of one `StatefulShellRoute` in `app/lib/core/routing/go_router.dart`. Each branch has its own navigator key, so switching from Goals to History keeps each section's tab and scroll position. The branches are `/goals`, `/history`, `/group`, and `/admin`, in that order. The shell widget is `HomePage`, which draws the bottom navigation bar.

Path strings live in `AppRoutes` (`app/lib/core/routing/app_routes.dart`). The router's `redirect` does four things:

- sends signed-out users to sign-in
- sends signed-in users with no group to `/onboarding`
- sends signed-in users who have a group away from sign-in and onboarding
- sends anyone but the group admin away from `/admin`, to `/goals`

`AppRoutes.publicRoutes` lists pages that work without a session: sign-in and sign-up. The router is built once in a provider and refreshed through `refreshListenable` when `currentMemberProvider` or `isGroupAdminProvider` changes. It is never rebuilt on each change. The admin flag is read the same way everywhere: one that has not resolved yet counts as not the admin.

`HomePage` hides the Admin destination from everyone else, so the bar it draws has three destinations for most members and four for the admin. Branch order and bar order are not the same list — Admin was appended as the last branch and sits second in the bar — so each destination names its route and `HomePage` looks up the branch holding that route before calling `goBranch`. Adding a branch means appending it in `go_router.dart` and adding a `_Destination` wherever it belongs in the bar.

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

Schema, RLS policies, and SQL functions live in `supabase/migrations/` in this repo. Apply them with `supabase db reset` locally. Rules the database must enforce belong in SQL functions called with `supabase.rpc(...)`. Every status change goes through `set_goal_status`, every verification through `verify_goal`, every un-verification through `unverify_goal`, every rename through `update_goal_title`, and every delete through `delete_goal`. All five write a `goal_events` row in the same transaction, through `log_goal_event`, and a trigger on `goals` writes `created` or `assigned` for an insert. A member inserts their own goals directly; `assign_goal` is how the admin makes one for someone else, and the only writer of `goals.assigned_by`. Only `status_changed` carries a `new_status`. An event stores the goal's group, owner, and title as they were at the time, and `goal_events.goal_id` is a plain uuid with no foreign key, so deleting a goal leaves its events in place. Clients have no direct `UPDATE` or `DELETE` on `goals`. Do not add Supabase Edge Functions for this logic.

Each function raises a stable token with an application-defined SQLSTATE in class `M0`, listed at the top of the migration that adds it. `GoalsRepository` maps those codes to an `AppException` with copy a widget can show. `supabase/tests/rls_check.sql` is the manual two-user script that exercises every one of them.

When running on an Android emulator, the local Supabase URL uses `10.0.2.2` instead of `localhost`. `app/lib/core/constants/environment.dart` handles this.