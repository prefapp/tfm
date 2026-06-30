# Tasks: Unify manual and automatic parameter replication into one Lambda

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Implement unified Python handler with mode routing
- [x] 2. Replace dual Lambda Terraform resources with one
- [x] 3. Replace dual IAM role/policy resources with one
- [x] 4. Preserve compatibility outputs/flags or add explicit migration notes
- [x] 5. Update docs/examples and regenerate `README.md`
- [x] 6. Validate diagnostics and Terraform checks

## Validation Notes

- `src/handler.py`: unified handler created with three invocation modes (EventBridge, manual, full sync).
- `lambda.tf`: consolidated to single `module.lambda_replication` with all env vars.
- `locals.tf`: simplified naming for single Lambda function and role.
- `iam.tf`: single role + policies with conditional `ssm:DescribeParameters` on `enable_full_sync`.
- `eventbridge.tf`: updated to target unified Lambda function.
- `outputs.tf`: added primary `lambda_replication_*` outputs + deprecated backward-compatible outputs.
- `variables.tf`: marked `manual_replication_enabled` as deprecated.
- `docs/header.md`: clarified unified invocation modes.
- `terraform-docs .` executed successfully (`README.md updated successfully`).
- File diagnostics: no errors in handler.py, lambda.tf, iam.tf.
- Old handler directories (`src/lambda_automatic_replication/`, `src/lambda_manual_replication/`) should be removed in cleanup step.
