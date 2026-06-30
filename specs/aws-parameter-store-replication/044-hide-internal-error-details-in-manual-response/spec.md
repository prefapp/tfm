# Specification: Hide internal exception details from manual invocation HTTP response

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

Manual invocation failure responses currently include raw exception text (`"error": str(e)`) in the HTTP body. Exception messages may leak internal details such as service responses, ARNs, and policy hints.

## Goal

Keep detailed exception content in logs while returning a sanitized error payload to the caller.

## Scope

- Update manual invocation error response in `src/handler.py`.
- Preserve detailed error logging (`log(..., error=str(e), exc_info=True)`).
- Return a generic, non-sensitive error message in HTTP body.

## Out of Scope

- Terraform/IAM changes.
- Changes to status codes or non-manual invocation paths.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Manual invocation `500` response does not include raw exception text.
- Logs still contain exception details for troubleshooting.
- Python syntax/diagnostics remain valid.
