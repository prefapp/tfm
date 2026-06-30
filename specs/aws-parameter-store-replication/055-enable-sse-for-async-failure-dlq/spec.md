# Specification: Enable SSE for async failure DLQ

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The async failure DLQ is created without server-side encryption. Even if messages do not include secret values, they can include parameter names and metadata.

## Goal

Enable encryption at rest for the async failure DLQ as a low-cost security hardening step.

## Scope

- `eventbridge.tf` only.
- Use SQS-managed SSE for the DLQ resource.

## Out of Scope

- Introducing customer-managed KMS keys.
- Terraform interface changes (no new variables/outputs).
- `CHANGELOG.md` updates.

## Acceptance Criteria

- `aws_sqs_queue.lambda_async_failure_dlq` has SSE enabled.
- No module input/output changes required.
