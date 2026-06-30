# Specification: Require explicit event flag to run full sync

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The unified Lambda currently falls back to `config.enable_full_sync` when no full-sync event flag is present. This means an empty/manual invocation without `parameter_name` can trigger full-account sync whenever module config enables full sync, which is risky and unintuitive.

## Goal

Require an explicit event flag (`enable_full_sync` or `initial_run`) to request full sync. Keep `config.enable_full_sync` as an allow/deny guardrail only.

## Scope

- Update full-sync request resolution in `src/handler.py`.
- Preserve explicit false handling and flag precedence.
- Keep existing guardrail behavior returning 403 when full sync is requested but not allowed by config.

## Out of Scope

- Terraform/IAM changes.
- Runtime changes outside full-sync decision logic.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Empty event without `parameter_name` does not trigger full sync, even if config enables it.
- `{"enable_full_sync": true}` or `{"initial_run": true}` requests full sync (subject to config guardrail).
- `{"enable_full_sync": false}` and `{"initial_run": false}` do not trigger full sync.
