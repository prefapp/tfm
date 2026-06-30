# Specification: Clarify tag replication behavior

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

The module documentation currently implies that `enable_tag_replication = false` disables all tags on replicated parameters. In practice, the Lambda always applies replication metadata tags such as `origin-account`, `origin-region`, and `latest-version`; the setting only controls copying and pruning of source parameter tags.

## Goal

Update the module documentation so it accurately describes the tag behavior, and regenerate `README.md` from the module docs so the rendered documentation matches the source content.

## Scope

- Clarify the `Tag Replication` section in `docs/header.md`
- Regenerate `modules/aws-parameter-store-replication/README.md` with `terraform-docs .`
- Keep the module behavior unchanged; this is a documentation-only fix

## Out of Scope

- Any Terraform resource or Lambda code changes
- Any `CHANGELOG.md` modification (handled by Release Please)
- Any ghaps compatibility refactor

## Acceptance Criteria

- Documentation explicitly states that replication metadata tags are always applied
- Documentation explicitly states that `enable_tag_replication` only controls source tag copying/pruning
- `README.md` is regenerated from `docs/header.md`/`docs/footer.md` using `terraform-docs .`
- The module remains behaviorally unchanged
