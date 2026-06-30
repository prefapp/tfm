# Specification: Guard full-sync exception logging against missing parameter name

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

During full sync, `param_name` is assigned inside the `try` block from `param_meta["Name"]`. If this lookup fails due to unexpected payload shape, the `except` block logs with `parameter_name=param_name`, which can raise `UnboundLocalError` and interrupt the loop.

## Goal

Ensure exception logging in full-sync mode is resilient when the parameter name is missing, so failures are counted and iteration continues.

## Scope

- Update `src/lambda_manual_replication/handler.py` exception logging in the full-sync loop to use a safe fallback name.

## Out of Scope

- Changes to replication logic or pagination behavior
- Terraform/doc changes
- Any `CHANGELOG.md` edits

## Acceptance Criteria

- No `UnboundLocalError` can be raised from the full-sync `except` block when `param_meta["Name"]` is missing.
- Errors are still logged and counted via `error_count += 1`.
