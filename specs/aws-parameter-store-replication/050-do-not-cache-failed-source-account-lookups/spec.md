# Specification: Do not cache failed source account STS lookups

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

`load_config()` caches the source account ID in `_SOURCE_ACCOUNT_CACHE`, but a transient STS failure currently stores an empty string permanently for the lifetime of the warm Lambda environment. That causes incorrect `origin-account` tags and any downstream logging that relies on `source_account`.

## Goal

Cache only successful STS `GetCallerIdentity` results. On transient failures, return an empty string for the current invocation only so later warm invocations can retry.

## Scope

- `src/common/config.py` only.

## Out of Scope

- Terraform, IAM, docs, examples.
- `CHANGELOG.md` changes.

## Acceptance Criteria

- `_SOURCE_ACCOUNT_CACHE` is updated only after successful `GetCallerIdentity`.
- On STS failure, `load_config()` returns `source_account=""` for that invocation without mutating the cache.
- Later warm invocations can retry STS lookup when cache is still empty (`None`).
