# Specification: Isolate stale-tag pruning failures from tag-apply path

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

In destination update flows, a single `try` block currently wraps both destination tag listing/pruning and `add_tags_to_resource`. If listing/pruning fails (for example due to missing `ssm:ListTagsForResource`/`ssm:RemoveTagsFromResource`), the code skips `add_tags_to_resource`, so replication metadata tags may not be applied even though value replication succeeded.

## Goal

Ensure that add/update of desired tags (especially replication metadata tags) is attempted independently from stale-tag pruning.

## Scope

- Refactor update tag sync logic in `src/common/replication.py` to separate:
  - prune path error handling
  - add/update path error handling

## Out of Scope

- Any change to source tag fetch behavior
- Any change to parameter value replication
- Terraform/docs changes and changelog changes

## Acceptance Criteria

- If pruning path fails, `add_tags_to_resource` is still attempted.
- If add/update path fails, replication still logs warning and continues as before.
- Existing pruning guard (`source_tags_fetched`) remains intact.
