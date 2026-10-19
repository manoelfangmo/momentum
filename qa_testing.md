# Momentum — Manual QA Test Plan

Covers the final MVP: groups, goal tabs, owner-set status, peer verification, edit/delete, History, stats, and the group admin features.

Tick each box when it passes. If a test fails, log it with the template at the end and keep going.

---

## 0. Setup

**Environment**

- [ ] `supabase start` is running and `supabase db reset` completed with no errors
- [ ] `flutter analyze` and `flutter test` are clean
- [ ] App runs on at least one iOS simulator **and** one Android emulator (Android uses `10.0.2.2` for local Supabase)

**Test accounts** — use two devices/simulators, or sign out and in between steps.

| Name | Role | Email |
| --- | --- | --- |
| Alex | Admin (group creator) | alex@test.dev |
| Bri | Member | bri@test.dev |
| Cam | Member | cam@test.dev |
| Dee | Member of a *different* group | dee@test.dev |

**Changing a deadline for past-date tests** — run in Studio's SQL editor (localhost:54323):

```sql
update goals set deadline = now() - interval '8 days' where title = 'Past goal';
```

---

## 1. Auth & routing

- [ ] **AUTH-01** Sign up as Alex with name, email, password → lands on Onboarding. A `members` row exists with that name.
- [ ] **AUTH-02** Sign up validation: invalid email, password < 6 chars, empty name → inline errors, no request sent.
- [ ] **AUTH-03** Sign in with a wrong password → error message, stays on Sign in.
- [ ] **AUTH-04** Kill and relaunch the app while signed in → session restored, no sign-in screen.
- [ ] **AUTH-05** Sign out from the Group tab → returns to Sign in. Back button/gesture does not return to the app.
- [ ] **AUTH-06** While signed out, deep link / navigate to `/goals` → redirected to Sign in.
- [ ] **AUTH-07** Signed in with no group, navigate to `/goals` → redirected to Onboarding.
- [ ] **AUTH-08** No screen flicker or redirect loop on launch in any of the three states (signed out / no group / in group).

## 2. Groups

- [ ] **GRP-01** Alex creates group "Lock-in" → lands on Goals. Group tab shows the name and Alex marked as "you".
- [ ] **GRP-02** Create with empty name or > 60 chars → validation error.
- [ ] **GRP-03** Copy group code → success toast; pasted value is the group's UUID.
- [ ] **GRP-04** Bri and Cam join with the code → both land on Goals. All three see each other in the Group tab.
- [ ] **GRP-05** Join with a malformed code → validation error, no request sent.
- [ ] **GRP-06** Join with a valid-format UUID that doesn't exist → "group not found" message.
- [ ] **GRP-07** Dee creates a separate group. Dee tries to join Lock-in → "already in a group" error.
- [ ] **GRP-08** Dee never sees any Lock-in member, goal or event anywhere in the app.

## 3. Creating goals

- [ ] **NEW-01** As Bri, on each tab (Day/Week/Month/Year) tap + → sheet title matches the tab ("New Week goal").
- [ ] **NEW-02** The "Due" line shows end of today / this Sunday / last day of this month / Dec 31.
- [ ] **NEW-03** Save → goal appears in that tab immediately as **Not started**, not verified.
- [ ] **NEW-04** Title empty, whitespace only, or 141 chars → validation error; 140 chars saves.
- [ ] **NEW-05** Create a Day goal from the current period → deadline is end of **today**. There is no UI to backdate: the + button is hidden on any other day.
- [ ] **NEW-06** Pick another member in the member picker → + button is hidden.
- [ ] **NEW-07** Goal does not appear in other tabs (a Week goal is not on the Day tab).

## 4. Viewing goals

- [ ] **VIEW-01** Each tab defaults to the signed-in member's goals, header shows the period ("Week of Oct 5") and "Your goals".
- [ ] **VIEW-02** Member picker → choose Cam → every tab now shows Cam's goals with "Cam's goals". Switching tabs keeps Cam selected.
- [ ] **VIEW-03** Every tab has the same navigator (chevrons, label, jump-to-date, reset). Day: ‹ › move one day; label reads Today / Yesterday / Tomorrow / date; "Today" returns. Reset is hidden while already on today.
- [ ] **VIEW-04** Date picker on any tab → choose a past date with goals → those goals show. All four tabs follow that date.
- [ ] **VIEW-05** Shared date: changing the date on any tab changes the other three to the period of that type that contains the same date (not "now"). Header is always `Period.label`; the navigator uses Today / This week / This month / This year (and Yesterday / Last week / … when adjacent).
- [ ] **VIEW-06** Changing member keeps the selected date on every tab.
- [ ] **VIEW-07** Empty tab shows an empty state, not a blank screen. An empty past period is the same empty state, not an error.
- [ ] **VIEW-08** Pull to refresh picks up a goal another account just created (for the visible period).
- [ ] **VIEW-09** Overdue badge appears on a goal past its deadline that isn't Complete + Verified (use the SQL snippet). Still shows on a past incomplete goal.
- [ ] **VIEW-10** Week ‹ › keeps the weekday (not Monday). Month ‹ › keeps the day-of-month; 31 Oct → previous month is 30 Sep, not 1 Oct; 31 Jan → 31 Dec. Year ‹ › from 29 Feb 2028 → 28 Feb 2027 / 28 Feb 2029. Opening Day afterwards shows that date, not the period start.
- [ ] **VIEW-11** Reset copy matches the tab in front (Today / This week / This month / This year) and returns every tab on this screen to the current period. Hidden while the visible period is already current.
- [ ] **VIEW-12** + button is hidden when the front tab's period is not current (yesterday, last week, tomorrow, …) and when viewing another member. It returns on yourself and the current period. Switching to Week while Day is on yesterday (still this week) shows the Week + button.
- [ ] **VIEW-13** Leave Goals, visit History / Group, come back → date, tab, and member still as left.
- [ ] **VIEW-14** Previous disables at 1 Jan 2020 and next at today + 5 years, on every type. Date picker first/last date are the same bounds.

## 5. Status changes (owner)

- [ ] **STAT-01** Bri changes own goal Not started → In progress → Complete → In progress → Complete. Chip updates each time.
- [ ] **STAT-02** Choosing Complete shows the hint "A groupmate needs to verify this." Card shows "Awaiting verification".
- [ ] **STAT-03** Cam views Bri's goals → no status control on any of Bri's goals.
- [ ] **STAT-04** Setting the same status again does nothing (no error, no new event in Studio).
- [ ] **STAT-05** Status can be changed on an overdue goal (no expiry).
- [ ] **STAT-06** After a goal is verified, Bri's status control is gone and a lock shows.

## 6. Verification

- [ ] **VER-01** Cam views Bri → **Verify** shows only on Bri's Complete, unverified goals; not on Not started / In progress.
- [ ] **VER-02** Verify shows a confirm dialog warning it can't be undone. Cancel → nothing changes.
- [ ] **VER-03** Confirm → Verified badge appears for everyone after refresh.
- [ ] **VER-04** Bri never sees a Verify button on Bri's own goals.
- [ ] **VER-05** Stale screen: Bri and Cam both open the same Complete goal; Cam verifies; Alex (also viewing) taps Verify → readable "already verified" error.
- [ ] **VER-06** Stale screen: Bri moves a goal back to In progress while Cam's screen still shows Complete; Cam taps Verify → readable "not complete" error.
- [ ] **VER-07** Verifying an overdue goal works (no expiry).

## 7. Edit & delete (owner)

- [ ] **ED-01** Bri's own unverified goal → ⋮ menu → Edit → title prefilled, type/deadline read-only → save → new title shows.
- [ ] **ED-02** Edit validation: blank / 141 chars → error.
- [ ] **ED-03** Delete → confirm dialog → goal disappears; success toast.
- [ ] **ED-04** Bri's verified goal → no ⋮ menu.
- [ ] **ED-05** Cam viewing Bri's goals → no ⋮ menu.
- [ ] **ED-06** Goal assigned to Bri by Alex → no ⋮ menu for Bri (see §10).

## 8. Admin tab

- [ ] **ADM-01** Alex sees an **Admin** tab in the bottom nav. Bri and Cam do not.
- [ ] **ADM-02** Bri navigates to `/admin` → redirected to Goals.
- [ ] **ADM-03** Other bottom-nav tabs still open the correct screens for both Alex and Bri (hidden tab doesn't shift destinations).
- [ ] **ADM-04** Admin tab has Day/Week/Month/Year. Each lists **every** member (Alex first, then by name) with their goals and completion badge. Every tab shows the period navigator, not only Day.
- [ ] **ADM-05** A member with no goals in that period still appears with "No goals" (including a past period they sat out).
- [ ] **ADM-06** Shared date: changing the date on any Admin tab changes the other three Admin tabs to the period of that type that contains that date. Every member section is for that period.
- [ ] **ADM-07** Admin's selected date is independent of Goals on all four tabs. Moving Goals does not move Admin; moving Admin does not move Goals. Leave Admin, visit Goals / History, come back → Admin date and tab still as left.
- [ ] **ADM-08** Pull to refresh shows goals other members just created (for the visible period).
- [ ] **ADM-09** Assign + is hidden when the front tab's period is not current, and returns on the current period. Reset copy is Today / This week / This month / This year. Stepping and bounds match Goals (weekday / day-of-month clamp / leap-day clamp; 1 Jan 2020 … today + 5 years).

## 9. Admin: assigning goals

- [ ] **ASN-01** Alex taps + on Admin Week tab → sheet with member dropdown (Alex as "Me"), title, "Due: end of this week".
- [ ] **ASN-02** Assign to Bri → appears under Bri in the Admin tab and in Bri's Week tab as Not started.
- [ ] **ASN-03** Bri's card shows "Assigned by Alex".
- [ ] **ASN-04** Assign a Day goal from the current period → deadline is end of **today**. There is no UI to backdate: the assign button is hidden on any other day.
- [ ] **ASN-05** Alex assigns to "Me" → normal own goal: no "Assigned by" label, Alex can edit/delete it like any own goal.
- [ ] **ASN-06** Submitting without choosing a member → validation error.

## 10. Admin: acting on members' goals

- [ ] **ACT-01** Bri can change the status of an assigned goal, but has no edit/delete menu on it.
- [ ] **ACT-02** Alex changes the status of one of Cam's unverified goals → succeeds; Cam sees the change.
- [ ] **ACT-03** Alex verifies a Complete goal of Bri's — including one Alex set to Complete.
- [ ] **ACT-04** Alex renames and deletes members' goals, including **verified** ones. Deleting a verified goal shows the extra warning.
- [ ] **ACT-05** Alex cannot change the status of a verified goal without un-verifying first.
- [ ] **ACT-06** **Un-verify**: Alex sees it on members' verified goals only. Confirm → goal stays Complete, shows "Awaiting verification", Bri's status control returns.
- [ ] **ACT-07** An un-verified goal can be verified again by Cam or Alex.
- [ ] **ACT-08** Alex never sees Verify or Un-verify on Alex's own goals; Bri can verify Alex's Complete goals.
- [ ] **ACT-09** Alex's own verified goal: Alex can still edit/delete it (admin rule), but cannot change status or un-verify it.
- [ ] **ACT-10** Admin last week: Alex renames Bri's **unverified** week goal → title updates on Admin, on Bri's Goals Week (when on that week), and in History.
- [ ] **ACT-11** Admin last week: Alex renames Bri's **verified** week goal → succeeds; ⋮ menu still present for Alex.
- [ ] **ACT-12** Admin last month: Alex deletes Cam's unverified month goal → confirm → gone; success toast; `deleted` event in Studio.
- [ ] **ACT-13** Admin last year: Alex deletes a verified year goal → extra verified-delete warning, then gone.
- [ ] **ACT-14** Admin past Day: Alex changes Cam's status → succeeds; Cam sees it when on that day. Locked while verified, same as today.
- [ ] **ACT-15** Admin past Week: Alex verifies Bri's complete goal → verified for everyone after refresh. Un-verify → stays complete, "Awaiting verification", Bri's status control returns.
- [ ] **ACT-16** Admin past period: Alex's own verified goal — edit/delete yes, status / un-verify no (same as ACT-09). Bri's assigned goal — Bri still has no ⋮; Alex can edit/delete/status as today.
- [ ] **ACT-17** Bri on Goals, past week, viewing Cam → no edit/delete (Bri is not admin). Nothing extra expires just because the period has ended.

## 11. History

- [ ] **HIS-01** Use the SQL snippet to push some of Bri's goals into past days/weeks/months.
- [ ] **HIS-02** Bri's History shows Day/Week/Month/Year tabs, only Bri's goals, no member picker.
- [ ] **HIS-03** Goals grouped under period headers, newest period first; current-period goals are **not** in History.
- [ ] **HIS-04** All statuses appear (Not started, In progress, Complete, Verified).
- [ ] **HIS-05** Actions work from History exactly as in the tabs (status change, edit, delete, verify by others via Goals picker).
- [ ] **HIS-06** Empty type shows "No past Week goals yet."
- [ ] **HIS-07** History is still the archive: current period absent, ended periods listed, no member picker. Visiting last week on Goals Week or Admin Week does **not** remove it from History. Same goals in all three places; after Alex edits/deletes a last-week goal on Admin, Goals and History reflect it after refresh.

## 12. Stats

- [ ] **STA-01** Tab header shows e.g. "1/3 verified · 33%" for the displayed member and period.
- [ ] **STA-02** Complete-but-unverified goals do **not** count; verifying one increases the % immediately after refresh.
- [ ] **STA-03** Un-verifying lowers the % again.
- [ ] **STA-04** Zero goals shows "—", never 0% or NaN.
- [ ] **STA-05** Each History period header shows that period's %.
- [ ] **STA-06** Admin tab: each member's badge matches what that member sees on their own tab.
- [ ] **STA-07** Deleting a goal removes it from the denominator.

## 13. Event log (Studio)

Run after the tests above: `select action, goal_title, actor_id, new_status, timestamp from goal_events order by timestamp;`

- [ ] **LOG-01** `created` for own goals, `assigned` for admin-assigned goals.
- [ ] **LOG-02** One `status_changed` per real change, with the right `new_status`; none for same-status taps.
- [ ] **LOG-03** `verified`, `unverified`, `title_edited` rows with the correct actor.
- [ ] **LOG-04** `deleted` rows remain after the goal is gone, with title, owner and group filled in.
- [ ] **LOG-05** Signed in as Dee, no Lock-in events are readable.

## 14. Time & period edge cases

Set the device clock (or use goals edited in Studio) to test these.

- [ ] **TIME-01** A Day goal created at 11:58 pm belongs to that day, not the next.
- [ ] **TIME-02** Sunday night: a Week goal belongs to the week that started the previous Monday.
- [ ] **TIME-03** Month and year rollover (Dec 31 → Jan 1): current-period goals move into History.
- [ ] **TIME-04** Feb 29 (set clock to 2028): Day and Month goals land correctly.
- [ ] **TIME-05** Week containing a DST change (e.g. early November in the US): the week still runs Monday to Sunday.

## 15. Security spot checks

Full SQL checks are in `supabase/tests/rls_check.md`. Re-run them, and confirm:

- [ ] **SEC-01** No client can `UPDATE` or `DELETE` `goals` directly; all changes go through RPCs.
- [ ] **SEC-02** A member calling `assign_goal` or `unverify_goal` gets `admin_only`.
- [ ] **SEC-03** A member cannot verify their own goal or change another member's status via RPC.
- [ ] **SEC-04** Inserting a goal with another member's `owner_id`, or a status other than `not_started`, is rejected.

## 16. General UX

- [ ] **UX-01** Every action button shows loading and can't be double-tapped.
- [ ] **UX-02** Stop Supabase (`supabase stop`) and use the app → readable error with retry, no crash. Restart and retry works.
- [ ] **UX-03** Long titles (140 chars) and long member names don't overflow cards or headers.
- [ ] **UX-04** Light and dark mode both readable.
- [ ] **UX-05** Switching bottom-nav tabs keeps each tab's state (selected tab, scroll, member, date).

---

## Bug report template

```
ID / title:
Test ID:
Account(s):
Device / OS:
Steps:
Expected:
Actual:
Screenshot / logs:
Severity: blocker | major | minor
```
