# Specification: Fix stale-pruning skip log parameter context

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

The warning log emitted when stale-tag pruning is skipped currently includes `parameter_name` from the source context, while the pruning operation applies to the destination parameter (`dest_param_name`) in a destination account/region. This can mislead troubleshooting.

## Goal

Adjust warning log context so destination parameter identity is explicit.

## Scope

- Update the stale-pruning-skip warning in `src/common/replication.py`

## Out of Scope

- Any replication behavior changes
- Any Terraform/docs/changelog changes

## Acceptance Criteria

- The stale-pruning-skip warning includes destination parameter context
- Source parameter context can remain as supplemental context
