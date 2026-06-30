# Specification: Validate Lambda event payload type before dictionary access

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

`lambda_handler` assumes `event` is always a dictionary and delegates to helpers that call `.get(...)`. If Lambda is invoked with a non-object JSON payload (e.g., string, list, number), execution raises `AttributeError` instead of returning a controlled `400` response.

## Goal

Fail safely with a clear `400` response when the incoming event payload is not a JSON object/dictionary.

## Scope

- Add an early type check in `src/handler.py` before any `.get(...)` usage.
- Return an explicit `400` response for invalid event payload types.
- Preserve existing behavior for valid object payloads.

## Out of Scope

- Terraform or IAM changes.
- Changes to replication logic beyond request-shape validation.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Non-dict payloads return `400` with a clear message.
- Dict payloads follow current behavior unchanged.
- Python syntax/diagnostics for modified file remain valid.
