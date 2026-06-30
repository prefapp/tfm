# Specification: Inline manual ParameterNotFound detection in handler

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

Manual replication should return HTTP 404 when the source parameter does not exist. The implementation can be simplified by using an inline AWS error-code check in the manual exception block.

## Goal

Adopt inline `error_code == "ParameterNotFound"` detection in the manual exception handler while preserving existing status semantics.

## Scope

- `src/handler.py` only.

## Out of Scope

- Behavior changes outside manual path.
- Terraform/docs changes.
- `CHANGELOG.md` changes.

## Acceptance Criteria

- Manual `except` block checks `error_code` inline from exception response.
- Returns 404 for `ParameterNotFound`, 500 otherwise.
- No functional regression in other paths.
