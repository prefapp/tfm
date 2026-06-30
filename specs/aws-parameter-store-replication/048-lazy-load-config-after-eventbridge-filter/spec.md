# Specification: Lazy-load config after EventBridge no-op filtering

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

`load_config()` currently runs before deciding whether an EventBridge `Parameter Store Change` event is non-replicable and should be ignored. This adds avoidable latency and unnecessary AWS API calls (notably first-call STS `GetCallerIdentity`) for intentional no-op events.

## Goal

Avoid loading config for EventBridge events that are recognized as non-replicable and therefore ignored.

## Scope

- `src/handler.py` only.
- Preserve existing response behavior for manual/full-sync paths.

## Out of Scope

- Terraform, IAM, docs, examples.
- `CHANGELOG.md` updates.

## Acceptance Criteria

- For EventBridge events with `is_eventbridge=True` and `parameter_name=None`, handler returns early without calling `load_config()`.
- For EventBridge replicable events, config is loaded and replication proceeds as before.
- Manual/full-sync behavior remains unchanged functionally.
