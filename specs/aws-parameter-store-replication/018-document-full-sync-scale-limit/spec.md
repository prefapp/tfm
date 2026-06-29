# Specification: Document full-sync scale and timeout limitations

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

`lambda_timeout` defaults to 600 seconds and Lambda is capped at 900 seconds. Full sync runs sequentially across parameters and destination regions/accounts, so large inventories can time out mid-run without continuation/resume support.

## Goal

Document this operational scale limit clearly and provide guidance for DR bootstrap scenarios.

## Scope

- Update `docs/header.md` with explicit full-sync scale/timeout caveat and recommendations.
- Regenerate `README.md` via `terraform-docs .`.

## Out of Scope

- Implementing chunking/continuation/self-invocation.
- Introducing Step Functions in this module.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- Docs explicitly mention 600s default, 900s Lambda hard cap, and timeout risk for large full syncs.
- Docs include practical guidance (scope runs, repeat invocations, Step Functions/external orchestration for very large bootstrap jobs).
- Regenerated README contains the new note.
