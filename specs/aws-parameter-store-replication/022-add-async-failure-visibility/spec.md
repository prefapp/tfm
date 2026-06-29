# Specification: Add async failure visibility for EventBridge-triggered replication

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

EventBridge invokes Lambda asynchronously. On repeated failures, retries are exhausted and events can be dropped without strong operator visibility if no DLQ/alarming is configured.

## Goal

Provide built-in, configurable visibility for async replication failures through:
- Lambda async invoke config with failure destination (SQS DLQ)
- CloudWatch alarms for Lambda errors and DLQ backlog

## Scope

- Add Terraform variables to control async failure visibility.
- Add SQS DLQ and required queue policy for Lambda async destination.
- Add `aws_lambda_function_event_invoke_config` for retry/failure destination.
- Add CloudWatch alarms.
- Expose relevant outputs and update docs.

## Out of Scope

- Runtime Python logic changes.
- External incident routing setup beyond provided alarm actions.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- When EventBridge is enabled and failure visibility is enabled, failed async invocations are routed to DLQ after retries.
- CloudWatch alarms can be attached via configurable alarm actions.
- Module remains valid when visibility is disabled.
