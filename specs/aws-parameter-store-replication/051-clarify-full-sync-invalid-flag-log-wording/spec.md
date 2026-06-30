# Specification: Clarify full-sync invalid flag warning wording

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The warning log message says "Invalid full sync flag type", but the same branch is also used when the flag is a string with an invalid value (e.g. "maybe").

## Goal

Use wording that accurately covers both invalid types and invalid values to improve troubleshooting clarity.

## Scope

- `src/handler.py` log message text only.

## Out of Scope

- Behavior changes to flag parsing.
- Terraform/docs changes.
- `CHANGELOG.md` changes.

## Acceptance Criteria

- Warning log text in the invalid full-sync flag branch no longer implies type-only failures.
- Existing behavior and response semantics remain unchanged.
