# Specification: Harden handler input normalization for EventBridge and manual payloads

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

`_extract_parameter_from_eventbridge` currently treats any truthy `detail.name` as valid. Non-string values and whitespace-only strings may be treated as valid input and later fail deeper in the flow with `500` instead of being ignored cleanly.

## Goal

Normalize and validate parameter-name inputs consistently so invalid EventBridge names are ignored and manual invalid names continue to return clear `400` errors.

## Scope

- Harden `_extract_parameter_from_eventbridge` in `src/handler.py` to validate detail shape and parameter name type/content.
- Reuse a shared name-normalization helper for consistency across EventBridge/manual paths.
- Preserve current explicit validation behavior for manual invocation and full-sync flags.

## Out of Scope

- Terraform/IAM changes.
- Replication logic changes outside handler input normalization.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- EventBridge events with non-string or whitespace-only `detail.name` are ignored (not treated as valid invocation).
- Manual `parameter_name` validation remains strict (`400` for invalid values), using consistent normalization.
- Handler syntax/diagnostics remain valid.
