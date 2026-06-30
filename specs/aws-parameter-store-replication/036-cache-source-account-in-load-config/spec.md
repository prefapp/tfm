# Specification: Cache source account lookup in Lambda execution environment

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

`load_config()` calls STS `GetCallerIdentity` on every Lambda invocation to derive `source_account`. For EventBridge-driven replication this adds avoidable latency and an extra AWS API call per event, even though the source account is stable within a Lambda execution environment.

## Goal

Cache the derived source account ID for reuse across warm invocations in the same execution environment while preserving the existing behavior and fallback semantics.

## Scope

- Update `src/common/config.py` to cache the STS-derived source account value at module scope.
- Preserve existing fallback behavior (`""`) when STS lookup fails.
- Do not change the `Config` shape or downstream call sites.

## Out of Scope

- Terraform/doc changes.
- Changes to destination-role logic.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- First warm-environment lookup may call STS once.
- Subsequent `load_config()` calls in the same execution environment reuse the cached source account.
- Failure fallback remains `""` when STS lookup fails.
- Python syntax/diagnostics remain valid.
