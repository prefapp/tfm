# Specification: Document delete-event behavior as intentional design choice

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

The EventBridge rule filters only `Create` and `Update`, and the unified handler ignores `Delete`. This behavior may be intentional for DR safety, but it is not explicitly documented.

## Goal

Document clearly that delete events are intentionally not replicated by default, including the operational consequence (stale destination parameters may accumulate).

## Scope

- Update module documentation in `docs/header.md`.
- Regenerate module `README.md` via `terraform-docs .`.

## Out of Scope

- Any runtime behavior changes.
- Any Terraform behavior changes.
- Any `CHANGELOG.md` modifications.

## Acceptance Criteria

- Header documentation explicitly states delete events are not replicated by design.
- Documentation explains DR/safety rationale and stale-parameter consequence.
- Regenerated `README.md` includes the updated section.
