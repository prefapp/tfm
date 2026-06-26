# Specification: Skip stale tag pruning when source tag fetch fails

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

In update flows, stale-tag pruning currently runs whenever `enable_tag_replication = true`. If the initial source `ListTagsForResource` call fails (for example due to transient AWS errors or missing read permissions), the code proceeds with `source_tags = {}` and still computes stale tags against metadata-only `combined_tags`. This can unintentionally remove destination source tags.

## Goal

Preserve metadata-tag updates while preventing destructive stale-tag pruning when source tags could not be fetched successfully.

## Scope

- Track whether source-tag fetch succeeded when source-tag replication is enabled
- Skip stale-tag pruning when source-tag fetch fails
- Continue applying replication metadata tags in all cases

## Out of Scope

- Changes to destination parameter value replication
- Changes to IAM policy shape
- Any `CHANGELOG.md` modifications

## Acceptance Criteria

- If source tags are fetched successfully and `enable_tag_replication = true`, stale-tag pruning behaves as before
- If source tags cannot be fetched and `enable_tag_replication = true`, stale-tag pruning is skipped
- Metadata tags (`origin-account`, `origin-region`, `latest-version`) are still added/updated
- Replication does not fail solely due to source-tag fetch errors
