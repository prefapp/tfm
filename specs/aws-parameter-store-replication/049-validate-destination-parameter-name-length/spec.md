# Specification: Validate destination parameter name length after regional prefixing

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

When `add_region_prefix_to_name` is enabled, destination names can exceed SSM's 2048-character limit even if the source parameter name was valid.

## Goal

Fail fast with a clear error in Python before calling AWS APIs when computed destination name exceeds 2048.

## Scope

- `src/common/replication.py`

## Acceptance Criteria

- `_build_destination_parameter_name` validates computed name length.
- Raises `ValueError` with clear message when destination name > 2048.
- Existing behavior for valid names remains unchanged.
