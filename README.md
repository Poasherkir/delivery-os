# Delivery OS

Offline-first Flutter app for Algerian delivery drivers (livreurs). Manages daily
order batches from delivery companies, optimizes the route, tracks deliveries,
and reconciles money down to the dinar.

- **Project rules and invariants:** [`CLAUDE.md`](CLAUDE.md)
- **Architecture, schema, milestones:** [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

Read both before making a non-trivial change. The invariants in `CLAUDE.md` are
not style preferences; violating one is a bug even when the code compiles.

## Development

```bash
flutter analyze                                          # must be clean
flutter test                                             # must be green
dart run build_runner build --delete-conflicting-outputs # after Drift/Riverpod changes
dart format .
```

Target platform is Android only. The MVP is single-user, account-less and
offline: it makes no network calls at all until the Mapbox Matrix API arrives
in M4.
