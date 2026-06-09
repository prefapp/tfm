# Specification: Fix origin-region naming semantics in aws-secretsmanager-replication

**Date:** 2026-06-09
**Module:** `modules/aws-secretsmanager-replication`

## Problem

The current replication logic prefixes destination secret names with the destination region when `add_region_prefix_to_name = true`. For disaster-recovery traceability, the prefix must represent the source region (where the secret originated).

Additionally, the `origin-region` replication tag is currently populated with destination region values, which is semantically incorrect.

## Goal

Ensure replicated secrets in destination accounts/regions identify their source correctly by:

- Prefixing names with source region when the prefix feature is enabled.
- Setting `origin-region` tag to source region.
- Updating module documentation to match behavior.

## Scope

- Update Python replication logic in `modules/aws-secretsmanager-replication/src/common/replication.py`.
- Update module docs text (`docs/header.md`, and generated `README.md`) describing prefix behavior.
- Keep behavior unchanged when `add_region_prefix_to_name = false`.

## Out of Scope

- Any replication direction redesign (failback orchestration, bidirectional sync).
- IAM/KMS policy model redesign.
- Any `CHANGELOG.md` modification.

## Acceptance Criteria

- With `add_region_prefix_to_name = true`, destination secret name uses `<source-region>-<source-secret-name>`.
- `origin-region` tag stores the source region value.
- Documentation clearly states source-region prefix semantics and remains consistent with implementation.
- `README.md` is regenerated using `terraform-docs`.
