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
dart format .
flutter test integration_test/                           # before a milestone gate
```

Run `flutter analyze` and `flutter test` before saying a task is done. Not after
being asked.

---

## Workflow

- **Plan before coding.** For anything larger than a single file, state the plan
  and wait for confirmation. Do not generate thousands of lines unprompted.
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
- **Never `git add -A`. Stage explicitly, by path.** A blanket stage lets one
  commit silently swallow another concern's work — a docs commit absorbing a
  whole task's implementation — which defeats the point of splitting commits by
  concern at all. `git status` before every commit, and name what goes in.
- **Amend freely while unpushed, never after.** A commit that fails its own CI
  gate must not sit permanently in history, so fix it by amending while the
  branch is still local. Once a commit is on the remote it is immutable: fix
  forward with a separate commit.

---

## Testing bar

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
