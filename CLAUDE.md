# Read `CONTRIBUTING.md` before doing anything else in this repository.

It holds the twelve non-negotiable invariants, the layering rule, the PII rule,
the workflow rules, the testing bar, the out-of-scope list and the UI rules.
Violating one of those invariants is a bug even when the code compiles and the
tests pass.

Then read `docs/ARCHITECTURE.md` before any non-trivial task. It is the source
of truth for the schema, the money engine, the optimizer and milestone scope.

---

**This file is a pointer, not a copy.** It exists only because this file is the
one loaded automatically at the start of a session and `CONTRIBUTING.md` is not
— a rule that has to be remembered before it applies is documentation, not a
constraint.

Nothing else belongs here. A rule written in this file instead of in
`CONTRIBUTING.md` would create two places to look, which is worse than either
one alone: the next person adds to whichever they happen to open, and the two
drift apart without anyone noticing.
