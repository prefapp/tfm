# Plan: Update addon conflict settings for aws-eks defaults

**Spec:** `spec.md`
**Module:** `modules/aws-eks`

## Steps

1. Inspect `modules/aws-eks/addons_locals.tf` and identify all base addon entries using `resolve_conflicts`.
2. Replace deprecated key with `resolve_conflicts_on_create` and `resolve_conflicts_on_update` in each base addon entry.
3. Add `most_recent = "false"` to each base addon entry.
4. Run formatting and quick validation checks.
5. Mark tasks as complete in `tasks.md`.
