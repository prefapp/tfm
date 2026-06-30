# Specification: Return 404 for manual ParameterNotFound

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

Manual invocation currently returns HTTP 500 when the source parameter does not exist (`ParameterNotFound`). This is a not-found/resource-state issue rather than an internal server failure.

## Goal

Return HTTP 404 for manual invocations when replication fails specifically due to source parameter not found, while preserving 500 for other failures.

## Scope

- `src/handler.py` manual invocation error handling only.

## Out of Scope

- EventBridge/full-sync behavior changes.
- Terraform/docs changes.
- `CHANGELOG.md` changes.

## Acceptance Criteria

- Manual path returns `statusCode=404` for parameter-not-found errors.
- Other manual replication failures still return 500.
- Logging clearly distinguishes not-found from internal errors.
