# Specification: Update addon conflict settings for aws-eks defaults

**Date:** 2026-06-04
**Module:** `modules/aws-eks`

## Problem

The default addon definitions in `addons_locals.tf` still use the deprecated `resolve_conflicts` key. We need to align with the newer create/update-specific keys and set `most_recent` as requested.

## Goal

Update default addon maps in `locals.base_addons` to:
- replace `resolve_conflicts = "OVERWRITE"` with:
  - `resolve_conflicts_on_create = "OVERWRITE"`
  - `resolve_conflicts_on_update = "OVERWRITE"`
- add `most_recent = "false"`

## Scope

- Update only `modules/aws-eks/addons_locals.tf` default addon blocks.
- Keep existing addon defaults and merge behavior unchanged otherwise.

## Out of Scope

- Changes to examples, other modules, or variable schemas.
- Any changelog updates (handled by Release Please automation).

## Acceptance Criteria

- `resolve_conflicts` no longer appears in `modules/aws-eks/addons_locals.tf` base addons.
- Each base addon entry includes both `resolve_conflicts_on_create` and `resolve_conflicts_on_update` set to `"OVERWRITE"`.
- Each base addon entry includes `most_recent = "false"`.
- Formatting/validation checks pass for touched files.
