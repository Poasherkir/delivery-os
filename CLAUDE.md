# Delivery OS — Project Rules

Offline-first Flutter app for Algerian delivery drivers (livreurs). Manages daily
order batches from delivery companies, optimizes the route, tracks deliveries, and
reconciles money down to the dinar.

**Read `docs/ARCHITECTURE.md` before any non-trivial task.** It is the source of
truth for the schema, the money engine, the optimizer, and milestone scope.

---

## Non-negotiable invariants

Violating any of these is a bug, even if the code compiles and tests pass.

1. **Money is `int` centimes.** Never `double`, never `num`, never `String`
   arithmetic. Use the `Centimes` value type. Format only in the presentation
   layer. Round once, at the final step, banker's rounding.

   **One rounded value per order.** A payment rule evaluation produces at most
   *one* rounded monetary value per order. Every other component is derived by
   subtraction from `cod_amount`. Never round two components independently —
   that is how `Σ company_amount + Σ driver_commission == Σ collected_amount`
   silently stops holding. In practice `driver_commission` is the rounded value
   and `company_amount = cod_amount − driver_commission − other_fees`. Where a
   company's rule is naturally expressed the other way around, the rule spec
   designates which field is computed and which is the residual. See
   `docs/ARCHITECTURE.md` §12.2.
2. **IDs are UUIDv7, generated client-side.** No auto-increment, ever. Offline
   creation requires stable IDs.
3. **Every owned mutable entity table carries** `owner_id`, `created_at`,
   `updated_at`, `deleted_at`, `version`. Deletes are soft. These columns are
   dormant in MVP and become the sync + RLS foundation later. Do not
   "simplify" them away.

   Not every table is an owned mutable entity. Which columns a table gets is
   decided by its category, and the category is a design decision to make
   *before* writing the table, not after:

   | Category | Tables | Columns |
   |---|---|---|
   | **Owned mutable entity** | `companies`, `customers`, `customer_addresses`, `batches`, `orders`, `expenses`, `remittances`, `routes` | All five. Soft delete. `version` incremented on every write. |
   | **Append-only / immutable record** | `payment_rules`, `delivery_attempts`, `proof_of_delivery`, `daily_settlements`, `settlement_adjustments`, `audit_logs` | `owner_id` + `created_at` only. These rows are never updated, so `updated_at` and `version` would be lies and a soft delete would be a rewrite of history. |
   | **Bundled reference data** | `wilayas`, `communes` | None. Ships inside the APK, is not user data, never syncs. |
   | **Pure local cache** | `matrix_cache` | None — not even `owner_id`. **Purgeable:** droppable at any moment with zero data loss, and it must *never* sync. It is not a record of anything. |
   | **Local machinery** | `outbox` | `created_at` plus whatever mutable state the mechanism needs. No `version`, no soft delete, and **hard deletion is allowed** — a synced row is removed or trimmed by age, not tombstoned. It mutates (`attempts`, `last_error`, `synced_at`) but it is not an owned entity and it never syncs. |

   Two exceptions, both deliberate:

   - `route_stops` carries `created_at` + `updated_at`, no `version`, no soft
     delete. Stops mutate (`arrived_at`, `status`) but are owned by their route,
     and re-optimization replaces a route's stops wholesale.
   - `users` carries `created_at`, `updated_at`, `deleted_at`, but no `owner_id`
     (it *is* the owner) and no `version`.
4. **`lib/domain/` imports nothing from Flutter, Drift, or any HTTP client.**
   Pure Dart only. If you need `package:flutter/...` in domain, the design is
   wrong — move the dependency behind an interface.
5. **Every mutation runs inside a `db.transaction()` and writes an outbox row.**
   The outbox is never sent in MVP. It is written anyway.
6. **All order status changes go through `OrderStateMachine.transitionTo()`.**
   Never assign `status` directly. Illegal transitions throw.
7. **Settlements are immutable.** Once `daily_settlements` has a row for a batch,
   corrections insert into `settlement_adjustments`. Never `UPDATE`, never
   `DELETE`.
8. **`payment_rule_version` is pinned on the order at creation.** Editing a
   company rule creates version N+1 and never touches historical orders.
9. **Coordinates carry a confidence tier** (0 none → 4 GPS-confirmed at
   delivery). Never route a confidence-0 stop. Never silently downgrade a pin.
10. **AR and FR from the first screen**, with correct RTL mirroring. No
    hardcoded user-facing strings. Every new screen gets an RTL check.
11. **No background location. No geofencing.** Foreground-only, while a route is
    active. This is a deliberate decision, not an oversight.
12. **Routing and optimization sit behind `RoutingProvider` and `RouteOptimizer`
    interfaces.** No Mapbox type ever leaks into `domain/` or `features/`.

---

## Layering

```
lib/presentation (features/) → lib/domain ← lib/data
```

- `domain/` defines interfaces. `data/` implements them. `features/` consumes
  them through Riverpod providers.
- `features/` never imports from `data/` directly. Only `domain/` types and
  providers.
- `core/` holds cross-cutting primitives (theme, l10n, money, time, result).

State management is **Riverpod**. Navigation is **go_router**. Local DB is
**Drift** (SQLite + SQLCipher).

---

## PII in diagnostics

**No value object's `toString()`, and no exception message, ever contains full
PII.** Anything that can reach a log line or a crash payload is masked at the
source, not scrubbed downstream — a scrubber only catches what it was told to
look for.

- Phone numbers are masked: country code and last three digits.
- Coordinates are rounded to at most two decimal places.
- The raw input is never quoted back in a parse failure.

A customer's phone number and their home coordinates are the most sensitive data
in this system (`docs/ARCHITECTURE.md` §13). A leaked database is a list of
Algerian households, their addresses, and when they receive valuable
cash-on-delivery parcels. The full value stays available on a named accessor
(`e164`, `latitude`) for the code that legitimately needs it.

---

## Commands

```bash
flutter analyze                                          # must be clean
flutter test                                             # must be green
dart run build_runner build --delete-conflicting-outputs # after Drift/Riverpod changes
dart format .                                            # writes
dart format --output=none --set-exit-if-changed .        # checks, writes nothing
```

Run `flutter analyze` and `flutter test` before saying a task is done. Not after
being asked.

There is deliberately **no `flutter test integration_test/`** in this list.
`integration_test/` is empty, and `flutter test` against an empty directory
exits 0 — a gate command that runs nothing and reports success, which is the
same failure as piping a gate or formatting with `--output=none`. It comes back
when the first integration test exists, and not before.

---

## Standing authority

**Decide these yourself. Do not ask.** If it can be undone in one commit, it is
yours: test design, naming, file layout, refactors; how to implement a decision
already made; library choices inside existing constraints; deviations that
*unblock* the plan; provisional values where a real answer is pending — pick the
safest, mark it provisional in-source, move on. Anything you would previously
have asked about and then implemented exactly as proposed.

**Stop and ask only for these six.** Everything else is yours.

1. **Money math or settlement semantics** — what a driver is owed, or what a
   settlement records.
2. **Deleting or overwriting user data** — any new path that can destroy data.
3. **A new Android permission**, or the first network call in a milestone.
4. **User-facing copy** — draft it, show it once, then implement. Not per string.
5. **Building outside the current milestone.** Say what you need and stop.
6. **A decision that would not be reversed cheaply** and has no safe default.

Batch them. One escalation per task at most; if a task raises three, put all
three in one message and keep working on what is not blocked.

**Reporting cadence.** Per task: one short paragraph — what landed, commit hash,
gate results, anything escalated. No transcript, and no narration of
intermediate failures unless the failure changed a decision. Per milestone: the
full gate, as run for M0.

### Patterns to apply without asking

- **Allowlist over denylist.** Every guard fails closed. Assert the allowlist's
  contents, never its length.
- **Mechanical over remembered.** A property held by care becomes a test in the
  same commit.
- **A guard that must be deleted the first time it fires is the wrong guard.**
  Make it a list that grows by deliberate lines instead.
- **Name things for what they are**, not what you hoped they would be.
- **Never store the same fact twice.** Derive it.
- **Raw JSON for anything versioned or frozen.** No typed converter on data that
  must outlive the model that wrote it.
- **Fail loudly on data this app wrote itself.** No silent defaults.

---

## Workflow

- **Plan before coding.** For anything larger than a single file, state the plan
  and wait for confirmation. Do not generate thousands of lines unprompted.
  Superseded within the standing authority above: plan-and-proceed for anything
  on the "decide yourself" list, plan-and-wait only at a milestone boundary or
  when something on the escalation list is in scope.
- **One concern per commit.** Conventional commits: `feat(orders): ...`,
  `fix(money): ...`, `refactor(route): ...`, `test(rules): ...`.
- **Work only inside the current milestone.** If a task requires something from a
  later milestone, say so and stop rather than building ahead.
- **Every schema change needs a forward migration test** from the previous
  version against a seeded DB. No exceptions.
- **When you are uncertain about a domain rule** (commission formulas, retour
  handling, stop-desk behaviour), ask. Do not invent business logic.
- **Never pipe a gate command.** `flutter analyze | tail -3` reports the exit
  code of `tail`, not of `analyze`, so a failing gate passes silently — and the
  same is true of `| head`, `| grep`, `| tee`. Verification commands
  (`flutter analyze`, `flutter test`, `dart format --set-exit-if-changed`,
  `flutter build`) run bare, with their full output shown. If a pipe is
  genuinely unavoidable, `set -o pipefail` first and echo the real exit code.
- **Formatting and checking are two different commands. Never conflate them.**
  `dart format .` *writes*. `dart format --output=none --set-exit-if-changed .`
  *checks* and writes nothing. Running the check and believing you have
  formatted leaves unformatted files in a commit that then fails CI — which is
  exactly what happened at M0-22, where a pre-commit "format" was `--output=none`
  and therefore a no-op on disk. Same class of error as piping a gate: a
  verification step that silently does nothing.
- **Control and invisible characters are built from codepoints, never pasted.**
  Bidi marks, zero-width characters, BOMs and the like are invisible in an
  editor, unreviewable in a diff, and silently mangled by a copy-paste. Write
  `String.fromCharCode(0x200E)`, not the character. Prose in comments is exempt;
  string literals are not.
- **Write files with the Write tool, never a shell heredoc.** A heredoc mangles
  content under quoting — three times in M0, once writing a broken escape
  silently into a source file that only the analyzer caught. A tool that
  corrupts content under quoting is not a tool for content. Shell is for
  commands.
- **On a major version bump of any dependency that handles keys, crypto or
  persistent storage, re-read its defaults before upgrading.** Behaviour does
  not carry across a major, and the dangerous changes are the silent ones:
  `flutter_secure_storage` 11 flipped `resetOnError` from `false` to `true`, a
  flag its own docs say will "PERMANENTLY erase the data when an error occurs"
  — the only copy of the database key, on a transient error, with no prompt.
  Say in the commit message what was checked.
- **A commit that changes a table regenerates the schema dump in the same
  commit.** Otherwise `drift_schema/` describes a database that no longer
  exists, and every migration test after that is validating against fiction.
  A test enforces it; this is why.
- **Never `git add -A`. Stage explicitly, by path.** A blanket stage lets one
  commit silently swallow another concern's work — a docs commit absorbing a
  whole task's implementation — which defeats the point of splitting commits by
  concern at all. `git status` before every commit, and name what goes in.
- **A script written to verify an invariant during an audit becomes a test in
  that same commit, or the report says explicitly why it is a one-off.** An
  audit that proves something and leaves nothing behind is a measurement, not a
  guard. The M0 gate verified all twenty tables against invariant 3 with a
  throwaway script, printed `CATEGORY VIOLATIONS: none`, and deleted it — so
  every table written afterwards was unguarded, and the enforcement table said
  the invariant was mechanical when it was not. If a property was worth
  checking once by hand, the reason it was worth checking has not gone away.
- **A change to a session-bootstrap file cannot be verified by the session that
  makes it.** This file, skills, tool configuration — anything read at
  startup — takes effect on the *next* session. The current one already holds
  the old state, so nothing misbehaves and nothing surfaces. That is how the
  rename of this file to `CONTRIBUTING.md` spent four commits silently
  unloading every rule in it, while two more rules were written into it.

  So: any change to those files is flagged in the report as **unverifiable this
  session**, and the first thing the next session does is confirm it took.
  `project_rules_test.dart` is the mechanical half of this; the flag is the half
  a test cannot cover, because a test cannot tell you the file it is reading is
  not the file being loaded.
- **Amend freely while unpushed, never after.** A commit that fails its own CI
  gate must not sit permanently in history, so fix it by amending while the
  branch is still local. Once a commit is on the remote it is immutable: fix
  forward with a separate commit.

---

## Testing bar

- **A test that would pass against an empty implementation is not a test, and a
  check that would pass against an empty subject set is not a check.**

  The first clause: before writing the assertion, ask what it would do if the
  thing under test did nothing at all. Three caught this way — a widget test
  that replaced the whole tree with a `SizedBox` and asserted no exception, an
  Arabic test that compared a title against the string `'fr'`, and a money test
  whose expected value came from the same reasoning as the implementation.

  The second: ask what it does when it finds *nothing to look at*. A scan whose
  glob stops matching, a coverage gate whose path moved, `flutter test` against
  an empty `integration_test/` — each reports success while checking nothing,
  and stays green forever because the subject set never comes back. Three caught
  this way too, which is why it is here: assert the subject set is non-empty, or
  fail when it is.

  **Where it is cheap, prove the test by breaking the thing it guards.** Plant a
  real violation, watch the test fail, revert, confirm no residue. That is how
  the schema-divergence guard and the database-first write ordering were
  verified, and both of them found the failure message was as good as the
  failure. A guard that has never failed is a guard nobody has tested.
- `lib/domain/` requires **90%+ coverage**. It is pure and fast; there is no
  excuse.
- The money engine needs property tests, not just examples. Invariants that must
  hold for any generated batch:
  - `Σ company_amount + Σ driver_commission == Σ collected_amount`
  - no rule spec ever produces a negative commission
  - optimizer output is always a permutation containing every input stop exactly
    once
- **Expected values in money tests are derived independently of the
  implementation, and the derivation is stated in a comment.** Cite the
  arithmetic — a closed form, a hand computation, a known reference — so the
  number can be checked on paper without rerunning the code. A test whose
  expected value came from the same reasoning that wrote the implementation is
  not verification: both can be wrong together and agree. Twice in M0 a
  money-adjacent test was wrong before the implementation was. The model is the
  half-even bias test in `centimes_test.dart`: "the first 100 odd numbers sum
  to 100², so the exact half is 5000." M3's settlement tests are held to this
  hardest.
- DAO tests run against in-memory SQLite (`drift/native`).
- **Any widget test whose behaviour depends on locale sets the locale
  explicitly.** No test relies on the ambient device locale. The Flutter test
  runner reports `en-US`, which correctly falls back to Arabic — so a test that
  never names a locale is exercising AR while reading as though it were LTR,
  passes for the wrong reason, and flips the day the runner changes. This was
  caught in M0-07 by an RTL test that was comparing RTL against RTL.

---

## Explicitly out of scope

Do not build, scaffold, or "prepare for" any of these unless I say the milestone
has changed:

- backend, auth, accounts, sync engine
- dispatcher web app, live tracking, WebSockets
- OR-Tools, multi-vehicle VRP, time windows
- geofencing, background location
- AI assistants, heatmaps, push notifications
- signature capture, OTP proof of delivery

The MVP is a single-user, no-account, offline app. Adding server-shaped
abstractions "for later" is the failure mode to avoid. The invariants above are
the only future-proofing required.

**Network access.** No HTTP client of any kind before M4 — not `http`, not
`dio`, not a bare `HttpClient`, not a "just for testing" fetch. At M4 exactly
one arrives, and it is used only for the Mapbox Matrix API. Nothing else in the
MVP reaches the network. Map tiles come through the Mapbox SDK, which is not
yours to route through that client.

---

## UI rules

- Professional logistics aesthetic. High information density. Real maps.
- No gradients, no glassmorphism, no neon, no decorative animation.
- **The next action is always the largest tappable thing on screen.** The driver
  is holding a parcel in one hand.
- Minimum tap target 48dp. Test on a 2GB RAM device.
- Dark and light themes, both real, neither an afterthought.

### Navigation

**Five bottom-nav destinations. Not six.** Past five, targets drop below 40dp,
and this user is tapping one-handed while holding a parcel.

| Destination | Holds |
|---|---|
| **Home** | Dashboard — batch progress, next stop, money, route summary |
| **Orders** | Today's orders. Batch is the grouping and settlement unit *inside* Orders — a driver thinks "my orders today", not "my batch" |
| **Route** | The optimized route. Present but empty-stated until a route exists |
| **Money** | Settlement, expenses, remittance, cash on hand |
| **More** | Plain list screen: Customers, Companies, History, Settings |

- **Delivery is a modal flow**, launched from Route or Orders. Never a tab.
- **Ingestion is an action (FAB), not a destination.**
- `More` is a plain list, not a shell branch with its own stack.

The twelve `features/` folders in `docs/ARCHITECTURE.md` §8.4 are a code layout,
not a navigation design. Do not turn each one into a destination.

---

## How each rule is enforced

**A rule in this file is loaded. It is not thereby enforced.** Loading means it
has been read; a guard is what makes it impossible to violate. The distinction
is not academic — the first version of `project_rules_test.dart` was written
through a shell heredoc, by someone who had just read the no-heredoc rule and
was at that moment writing a test asserting the rule was still present.

Two uses for this table. A milestone gate should **not** re-verify the
mechanical rows: they prove themselves on every `flutter test`, and auditing
them is theatre. The audit is the soft rows, which is where the exposure is. And
the ratio is worth seeing — anything soft is riding on care, and naming it is
the first step to converting it, exactly as the forbidden-vocabulary guard was a
soft copy decision until it became a test.

**Soft is not a failure grade.** Some rules cannot have a guard: they are about
tool choice, sequencing, or judgement. Those stay soft permanently and that is
the correct answer for them.

### Invariants

| # | Enforced by |
|---|---|
| 1 Money is `int` centimes | `test/domain/value_objects/centimes_test.dart` (no `double`, no division), `test/data/db/schema_v1_ledger_test.dart` (column types). **One-rounded-value: soft** — no money engine before M3 |
| 2 UUIDv7, client-side | `test/core/utils/uuid_v7_test.dart`, `test/architecture/no_autoincrement_test.dart` |
| 3 Five-category audit columns | `test/data/db/table_categories_test.dart` — all twenty, plus a check that a new table fails until it is categorised |
| 4 `domain/` imports nothing | `test/architecture/domain_purity_test.dart` — allowlist, fails closed |
| 5 Transaction + outbox row | `test/architecture/outbox_guard_test.dart` — scans `daos/` for writers, then invokes each and asserts the queue grew by one. A writer with no registry entry fails by name |
| 6 `OrderStateMachine` | Not built (M2) |
| 7 Settlements immutable | `test/data/db/schema_v1_ledger_test.dart` — structural, the columns do not exist |
| 8 `payment_rule_version` pinned | `test/data/db/schema_v1_orders_test.dart` for the column. **Pinning logic: soft** until M3 |
| 9 Confidence tiers | `test/domain/value_objects/geo_confidence_test.dart`. "Never route a 0" has no router yet |
| 10 AR/FR, no hardcoded strings | `test/architecture/no_raw_text_test.dart`, `test/core/l10n/arb_parity_test.dart`, `test/widget/rtl_mirroring_test.dart` |
| 11 No background location | `test/architecture/android_permissions_test.dart` — permission allowlist (empty today), a separate forbidden list, and no foreground-service type or receiver |
| 12 Routing behind interfaces | Not built (M4) |

### PII in diagnostics

| Rule | Enforced by |
|---|---|
| Masked `toString`, no PII in exceptions | `test/domain/value_objects/phone_e164_test.dart`, `test/domain/value_objects/geo_point_test.dart` |
| Forbidden vocabulary in driver-facing copy | `test/widget/database_error_screen_test.dart` |

### Workflow

| Rule | Enforced by |
|---|---|
| Schema change needs a migration test | `test/data/db/migration_harness_test.dart` |
| Table change regenerates the dump | `test/data/db/migration_harness_test.dart` — divergence guard |
| Dependency major bump: re-read defaults | `test/data/db/encryption/secure_key_store_test.dart` pins the one known case. **The general rule: soft** |
| Session-bootstrap files | `test/architecture/project_rules_test.dart` — partial; a test cannot prove the file is *loaded* |
| Audit scripts become tests | soft — judgement |
| Plan before coding | soft — judgement |
| One concern per commit | soft — judgement |
| Work only inside the milestone | soft — judgement |
| Ask about domain rules | soft — judgement |
| Never pipe a gate command | soft — tool choice |
| Formatting vs checking | soft — tool choice |
| Codepoints, never pasted | soft — **convertible**: scan string literals for non-ASCII |
| Write tool, never a heredoc | soft — tool choice |
| Never `git add -A` | soft — tool choice |
| Amend only while unpushed | soft — judgement |

### Testing bar

| Rule | Enforced by |
|---|---|
| No test that passes against an empty implementation | soft — judgement. Three caught by review so far |
| Money expectations derived independently | soft — judgement |
| Locale set explicitly in widget tests | soft — **convertible**: scan `testWidgets` bodies for a locale |
| `lib/domain/` 90%+ coverage | `tool/check_domain_coverage.dart`, run in CI after `flutter test --coverage` |
| Money engine property tests | soft until M3 |

### UI

| Rule | Enforced by |
|---|---|
| Five bottom-nav destinations | `test/widget/router_test.dart` |
| Dark and light both real | `test/core/theme/app_theme_test.dart` |
| Minimum 48dp tap target | partial — `test/widget/database_error_screen_test.dart` only. Convertible |
| Next action is the largest thing | soft — judgement |
| No gradients, glassmorphism, neon | soft — judgement |
