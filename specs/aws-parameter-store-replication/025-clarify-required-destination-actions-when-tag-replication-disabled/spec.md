# Specification: Clarify required destination SSM actions when tag replication is disabled

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The permissions note currently states that when `enable_tag_replication = false`, only `ssm:PutParameter` is required. In practice, update flows still perform a destination existence probe (`ssm:GetParameters`) and apply replication metadata tags (`ssm:AddTagsToResource`) because AWS does not support combining tags and overwrite in a single `PutParameter` update path.

## Goal

Correct the documentation to avoid under-permissioned destination replication roles and resulting AccessDenied warnings/failures.

## Scope

- Update permission wording in `modules/aws-parameter-store-replication/docs/header.md`.
- Regenerate `modules/aws-parameter-store-replication/README.md` with `terraform-docs .`.

## Out of Scope

- No runtime code behavior changes.
- No IAM policy template changes.
- No `CHANGELOG.md` edits.

## Acceptance Criteria

- The docs clearly state that with `enable_tag_replication = false`, `ssm:PutParameter`, `ssm:GetParameters`, and `ssm:AddTagsToResource` are still required.
- The docs also state that only `ssm:ListTagsForResource` and `ssm:RemoveTagsFromResource` can be omitted in that mode.
- README reflects the updated wording after regeneration.
