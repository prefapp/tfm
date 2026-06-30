# Specification: Fix async DLQ delivery permission on Lambda execution role

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

Async on-failure destination delivery to SQS requires `sqs:SendMessage` permission on the Lambda execution role. Current module adds DLQ resources and invoke config, but no corresponding role permission.

## Goal

Grant `sqs:SendMessage` on the async failure DLQ to the replication Lambda execution role, gated by the same condition used to create visibility resources.

## Scope

- Update `iam.tf` to add conditional SQS send policy on `aws_iam_role.lambda_replication`.

## Out of Scope

- Runtime Python changes.
- Removing existing SQS queue resource policy.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- Execution role includes `sqs:SendMessage` to `aws_sqs_queue.lambda_async_failure_dlq[0].arn` when async visibility is enabled.
- Terraform validate succeeds.
