# Specification: Reject invalid manual full-sync flag types

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The unified Lambda currently coerces non-boolean and non-string `enable_full_sync`/`initial_run` values with `bool(...)`. Payloads such as `{ "enable_full_sync": {} }` or `{ "enable_full_sync": [1] }` therefore evaluate as truthy and can unintentionally trigger a full-account sync.

## Goal

Reject unsupported full-sync flag types with a `400` response instead of coercing them.

## Scope

- Update flag parsing logic in `src/handler.py`.
- Accept booleans and string boolean-like values only.
- Return a clear `400` error for unsupported payload types.

## Out of Scope

- Terraform changes.
- IAM changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Boolean values continue to work.
- String values continue to be normalized using existing truthy parsing.
- Unsupported types such as objects, arrays, or numbers return `400` and do not trigger full sync.
