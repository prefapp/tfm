# Specification: Document async error alarm scope for Lambda invocation modes

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

The `lambda_async_errors` alarm uses AWS/Lambda `Errors`. This correctly captures unhandled async invocation failures (EventBridge path), but manual/full-sync paths can catch exceptions and return HTTP-style payloads, which may not increment `Errors` in the same way.

## Goal

Explicitly document the scope and limitation of the async error alarm so operators interpret it correctly.

## Scope

- Update `docs/header.md` async visibility section.
- Regenerate `README.md` via `terraform-docs .`.

## Out of Scope

- Runtime behavior changes in handler logic.
- Alarm metric changes.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- Docs explicitly state async alarm scope and manual/full-sync caveat.
- README reflects the update.
