# Delivery OS

Offline-first Flutter app for Algerian delivery drivers (*livreurs*). It takes
the daily batches of orders a driver collects from delivery companies,
optimizes the route, tracks each delivery attempt, and reconciles the money
down to the dinar.

The driver is the user. Not a dispatcher, not a fleet manager — one person,
holding a parcel in one hand, standing at a door, often with no signal.

---

## Status

**Milestone M0 (foundations), 21 of 22 tasks complete.** The app builds, runs,
switches Arabic↔French with correct RTL, and opens an encrypted database. There
are no delivery features yet: the five navigation destinations exist as
placeholder screens, and ingestion, batches, the money engine and the route
optimizer all belong to later milestones.

| | |
|---|---|
| Tests | 574, all green |
| Analyzer | clean under `--fatal-infos` |
| Schema | v1, 20 tables, dumped and migration-tested |
| Locales | `ar`, `fr` — both real, from the first screen |
| Network calls | none, by design, until M4 |

Remaining in M0: the bundled wilaya/commune dataset (task 22), then the
milestone gate.

---

## Why the constraints are what they are

Most of this codebase's shape comes from four facts about the problem.

**The money must reconcile exactly.** A driver settles cash with an agency at
the end of the day. If the app says 47 300 DA and the agency counts 47 250, the
driver pays the difference out of pocket. So money is `int` centimes end to
end — never `double` — and a payment rule produces exactly **one** rounded value
per order, with every other component derived by subtraction. Rounding two
components independently is how `Σ company + Σ commission == Σ collected`
silently stops holding.

**There is often no signal.** Everything works offline: IDs are UUIDv7 generated
on the device, every mutation writes to an outbox that nothing sends yet, and
the app makes no network call at all before M4.

**The data is sensitive.** The database is a list of Algerian households, their
addresses, and when they receive valuable cash-on-delivery parcels. It is
encrypted with SQLCipher, and no value object's `toString()` or exception
message ever contains full PII — phone numbers are masked to country code plus
last three digits, coordinates rounded to two decimals, and raw input is never
quoted back in a parse failure.

**Most drivers read Arabic first.** Arabic and French are both first-class from
the first screen, with real RTL mirroring, and the fallback for an unsupported
device language is Arabic rather than French.

---

## Invariants

[`CONTRIBUTING.md`](CONTRIBUTING.md) holds twelve non-negotiable invariants.
They are not style preferences — violating one is a bug even when the code
compiles and the tests pass. In brief:

1. Money is `int` centimes, one rounded value per order
2. IDs are UUIDv7, generated client-side
3. Every owned mutable entity table carries the five audit columns; deletes are soft
4. `lib/domain/` imports nothing from Flutter, Drift, or any HTTP client
5. Every mutation runs in a transaction and writes an outbox row
6. Order status changes go through `OrderStateMachine.transitionTo()`
7. Settlements are immutable; corrections are adjustments
8. `payment_rule_version` is pinned on the order at creation
9. Coordinates carry a confidence tier; never route a confidence-0 stop
10. AR and FR from the first screen, no hardcoded user-facing strings
11. No background location, no geofencing
12. Routing sits behind interfaces; no Mapbox type reaches `domain/`

Several are enforced mechanically rather than by review — see
[Guard tests](#guard-tests).

---

## Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter 3.44.4 / Dart 3.12.2, Android only |
| State | Riverpod 3.4.2 |
| Navigation | go_router 18 |
| Database | Drift 2.34.0 over SQLite, encrypted with SQLCipher 4.18 |
| Encryption key | `flutter_secure_storage` 11 (Android Keystore) |
| Typography | IBM Plex Sans + IBM Plex Sans Arabic, bundled |
| Maps (M4) | `mapbox_maps_flutter` |
| Build | JDK 21, `compileSdk` 37, `minSdk` 24, `targetSdk` 36 |

Application ID is `dz.deliveryos.driver`.

SQLCipher arrives through `package:sqlite3`'s Dart hooks — selected in
[`pubspec.yaml`](pubspec.yaml) via `hooks.user_defines.sqlite3.source:
sqlcipher` — so the encrypted build is used on the Dart VM test host too, not
just on device. Encryption is therefore exercised by ordinary `flutter test`
rather than only in integration tests.

> **Note on the drift pin.** `drift` and `drift_dev` are both pinned to exactly
> `2.34.0`. This is a temporary workaround for an analyzer version skew in the
> test toolchain, not a decision about drift. The reason and the test that
> releases it are written next to the constraint in `pubspec.yaml`.

---

## Layout

```
lib/presentation (features/) → lib/domain ← lib/data
```

`domain/` declares interfaces, `data/` implements them, `features/` consumes
them through Riverpod providers. `features/` never imports from `data/`.

```
lib/
  app/          router, shell, DI roots
  core/         cross-cutting primitives
    device/     installation identity
    l10n/       locales, ARB bundles, generated strings
    money/      Centimes formatting
    theme/      design tokens, typography
    time/       Clock — the app's only source of "now"
    utils/      UUIDv7
  domain/       pure Dart: value objects, state machines, interfaces
  data/
    db/         Drift schema, DAOs, encryption, migrations
  features/     one folder per feature, presentation + controllers
  shared/       widgets used across features
```

`docs/ARCHITECTURE.md` is the source of truth for the schema, the money engine,
the optimizer, and milestone scope. Read it before any non-trivial change.

---

## Getting started

Requires the Flutter SDK and JDK 21.

```bash
flutter pub get
```

```bash
flutter run
```

After changing any Drift table or Riverpod provider:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files are committed, so a clean checkout builds without running the
generator first.

---

## Checks

These are the gates. CI runs all three on every push and pull request.

```bash
flutter analyze --fatal-infos
```

```bash
flutter test
```

```bash
dart format .
```

To check formatting without writing (what CI runs):

```bash
dart format --output=none --set-exit-if-changed .
```

> **Never pipe a gate command.** `flutter analyze | tail -3` reports the exit
> code of `tail`, so a failing gate passes silently. The same is true of
> `| head`, `| grep` and `| tee`. If a pipe is genuinely unavoidable, set
> `pipefail` first and echo the real exit code.

---

## Database

Schema version 1, 20 tables. Which columns a table gets is decided by its
category, not by habit — five categories, documented in `CONTRIBUTING.md`:

| Category | Columns |
|---|---|
| Owned mutable entity | all five audit columns, soft delete, `version` |
| Append-only record | `owner_id` + `created_at` only |
| Bundled reference data | none — ships in the APK, never syncs |
| Pure local cache | none, not even `owner_id`; droppable at any moment |
| Local machinery | `created_at` plus whatever the mechanism needs; hard delete allowed |

### Migrations

Every commit that changes a table regenerates the schema dump in the same
commit, and a test fails when the live schema diverges from what is committed:

```bash
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schema/
```

```bash
dart run drift_dev schema generate drift_schema/ test/data/db/schema_versions/
```

The harness in `test/data/db/migration_harness_test.dart` seeds one row in every
table — money deliberately negative and non-round, JSON documents carrying
fields no build has ever seen — migrates, and asserts everything survives.

### Encryption

The key is 256 bits, generated on first launch and held in the Android Keystore.
Two rules govern it, both enforced by tests:

- **A key is never generated when a database file already exists.** A
  read-or-create helper that falls through to "create" on a transient keystore
  error would mint a fresh key and leave the driver's database permanently
  unreadable, with nothing anywhere to notice.
- **`resetOnError` stays `false`.** `flutter_secure_storage` 11 flipped this
  default to `true`, a flag its own docs say will "PERMANENTLY erase the data
  when an error occurs". A test pins it, and asserts the bare default differs so
  the difference is proven rather than assumed.

A database that will not open fails loudly with the file intact. It never
self-repairs.

---

## Testing

`lib/domain/` requires 90%+ coverage. It is pure and fast; there is no excuse.

Two rules worth stating outside `CONTRIBUTING.md`, because both were learned from
tests that passed for the wrong reason:

**Expected values in money tests are derived independently of the
implementation, and the derivation is written in a comment.** A test whose
expected value came from the same reasoning that wrote the implementation is not
verification — both can be wrong together and agree. Twice in M0 a money-adjacent
test was wrong before the implementation was.

**Any widget test whose behaviour depends on locale sets the locale
explicitly.** The Flutter test runner reports `en-US`, which correctly falls
back to Arabic — so a test that never names a locale is exercising RTL while
reading as though it were LTR.

### Guard tests

Conventions that cannot be made structural are enforced mechanically:

| Guard | Catches |
|---|---|
| `domain_purity_test.dart` | any import into `lib/domain/` outside a two-entry allowlist — fails **closed** |
| `no_raw_text_test.dart` | a raw `Text(` widget instead of the l10n-aware `AppText` |
| `no_drift_datetime_test.dart` | Drift's `dateTime()` instead of the millisecond converter |
| owner-FK guard | reads constraints back out of `sqlite_master`, so a missing `references()` cannot hide |
| schema divergence | a live schema that no longer matches the committed dump |

Guards are verified by planting a real violation and confirming they fire, then
reverting. A guard that has never failed is a guard nobody has tested.

---

## Milestones

| | Weeks | Scope | Gate |
|---|---|---|---|
| **M0** | 1–2 | Skeleton, theme, AR/FR/RTL, schema v1, encryption, CI | App builds, switches AR↔FR, empty DB opens encrypted |
| **M1** | 2–3 | Ingestion + customers: scan, fast entry, phone normalization, duplicates | 15 orders in under 4 minutes, stopwatch-measured |
| **M2** | 3–5 | Batches, order list, state machine, delivery flows, photo POD | A full day simulated end to end in airplane mode |
| **M3** | 5–6 | Money engine, expenses, settlement snapshot, remittance | Property tests pass; totals match a hand-computed sheet to the centime |
| **M4** | 6–8 | Map, matrix cache, NN/2-opt/Or-opt, route screen | 20 stops solved under 100 ms; works offline from cache |
| **M5** | 8–10 | Dashboard, history, settings, backup, performance, signed APK | Cold start under 1.5 s on a mid-range Android |

---

## Out of scope

Deliberately not built, and not "prepared for":

backend, auth, accounts, sync engine · dispatcher web app · live tracking ·
OR-Tools, multi-vehicle VRP, time windows · geofencing · background location ·
AI assistants, heatmaps, push notifications · signature capture · OTP proof of
delivery

The MVP is single-user, account-less and offline. Adding server-shaped
abstractions "for later" is the specific failure mode being avoided; the twelve
invariants are the only future-proofing required.

**No HTTP client of any kind before M4** — not `http`, not `dio`, not a bare
`HttpClient`, not a "just for testing" fetch. At M4 exactly one arrives, used
only for the Mapbox Matrix API.

---

## Documentation

| | |
|---|---|
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | project rules, invariants, workflow, testing bar |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | schema, money engine, optimizer, milestone scope |

---

## License

Not yet licensed. All rights reserved.
