# Architecture Decision Records (repo-wide)

This directory holds **repo-wide** ADRs — decisions that span more than one module.
Module-scoped decisions live in `modules/<module>/docs/adr/` instead; use the
narrowest scope that fully contains the decision.

No repo-wide ADRs yet.

## Format

- One file per decision, named `NNNN-slug.md`, numbered sequentially **per
  directory** starting at `0001`.
- A title and one to three sentences covering context, decision and trade-off is
  enough. Add `Status`, `Considered Options` or `Consequences` sections only when they
  carry real information.
- Add the new file to the list in this `README.md` in the same change.

## When to write one

All three must hold, or don't write it:

1. **Hard to reverse** — changing your mind later has a real cost.
2. **Surprising without context** — a future reader would ask "why on earth was it
   done this way?".
3. **The result of a real trade-off** — there were genuine alternatives.

Routine field additions, forced provider deprecations, doc fixes and bug fixes get no
ADR. See [`CONSTITUTION.md`](../../CONSTITUTION.md) §9.
