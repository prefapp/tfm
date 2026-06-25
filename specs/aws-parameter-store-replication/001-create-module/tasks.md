# Tasks: Create aws-parameter-store-replication module

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Verify module structure (variables.tf, main.tf, outputs.tf, versions.tf exist and are complete)
- [x] 2. Verify Lambda function code handles automatic, manual, and full-sync replication modes
- [x] 3. Verify IAM role and policy resources follow least-privilege principles
- [x] 4. Verify EventBridge integration code (if included)
- [x] 5. Verify CloudTrail logging configuration (if included)
- [x] 6. Verify docs/header.md documentation and examples are comprehensive
- [x] 7. Regenerate README.md using `terraform-docs .`
- [x] 8. Run `terraform fmt -check` on module files
- [x] 9. Run `terraform validate` on module
- [x] 10. Final review and spec artifact completion

## Validation Notes

- `terraform-docs .` executed successfully in `modules/aws-parameter-store-replication` (per terminal context, exit code 0).
- `terraform fmt -check` executed in `modules/aws-parameter-store-replication` with no output (format check passed).
- `terraform init -backend=false -input=false` executed successfully to install required child modules/providers for validation.
- `terraform validate` completed successfully (`Success! The configuration is valid`) with upstream warnings from downloaded lambda module outputs about deprecated provider attribute `name`.

## Follow-up Task (2026-06-25)

- [x] 11. Correct `add_region_prefix_to_name` destination naming examples in `docs/header.md` to match implementation behavior for path-style and simple names.
- [x] 12. Regenerate `README.md` via `terraform-docs .` after header documentation change.
- [x] 13. Refine the destination-name wording to a single sentence with both path-style and simple-name examples, and regenerate `README.md`.
- [x] 14. Add fail-fast `destinations_json` validation for required destination shape (`role_arn`, `regions`) and non-empty `role_arn`.
- [x] 15. Declare `source_ssm` explicitly in the `Config` dataclass (default `None`) to avoid dynamic attribute injection from handlers.
- [x] 16. Skip source `list_tags_for_resource` calls when `enable_tag_replication = false` to reduce unnecessary API usage during automatic/full-sync replication.
- [x] 17. Harden `load_config()` region parsing to treat non-dict region values (null, string, etc.) as `{}` to prevent AttributeError on invalid inputs.
- [x] 18. Skip destination `list_tags_for_resource` calls on parameter update when `enable_tag_replication = false` (no stale-tag pruning needed).
- [x] 19. Clarify permissions documentation to reference destination role and destination parameter name format (including region-prefix transformation) so users correctly scope IAM policies.
- [x] 20. Enforce that `destinations_json` decodes to a top-level JSON object/map (not array/list) to match `load_config()` expectations.
- [x] 21. Clarify `add_region_prefix_to_name` variable description to document both simple-name and path-style region-prefix formats, then regenerate `README.md`.
- [x] 22. Update IAM ARN example to use `parameter<destination_parameter_name>` so slash-prefixed destination names do not imply an extra `/` in policy examples, then regenerate `README.md`.
- [x] 23. Change tag merge order so replication metadata tags (`origin-account`, `origin-region`, `latest-version`) override source tags when keys collide.
- [x] 24. Tighten `lambda_manual_kms` least-privilege policy by removing unused `kms:Encrypt` and `kms:GenerateDataKey` actions (manual Lambda only decrypts source parameters).
- [x] 25. Tighten `lambda_kms` (automatic Lambda) least-privilege policy by removing unused `kms:Encrypt` and `kms:GenerateDataKey` actions.
- [x] 26. Require `destinations_json` to contain at least one destination account entry to prevent empty `sts:AssumeRole` resource lists in generated IAM policies.
- [x] 27. Make `ssm:ListTagsForResource` permission conditional on `enable_tag_replication` in both automatic and manual Lambda source-read IAM policies.
- [x] 28. Clarify destination IAM policy docs to show both SSM parameter ARN formats (simple-name and path-style) so users scope destination permissions correctly.
- [x] 29. Correct `enable_tag_replication` variable description to reflect Terraform-side effects (Lambda env configuration and conditional IAM permissions), then regenerate `README.md`.
- [x] 30. Handle destination `AccessDeniedException` on `get_parameter` existence probe by proceeding in overwrite mode, so write-scoped destination roles do not break replication.
- [x] 31. Refine destination existence-probe error handling to catch `ClientError` and branch by `Error.Code` (`ParameterNotFound` / `AccessDeniedException`) while re-raising unexpected errors.
- [x] 32. Change `local.common_tags.Name` to use module instance base name (`local.naming_base`) instead of the automatic Lambda name, so shared tags remain accurate across manual/EventBridge/IAM resources.
- [x] 33. Scope KMS `kms:ViaService` condition from wildcard (`ssm.*.amazonaws.com`) to deployment region (`ssm.${data.aws_region.current.name}.amazonaws.com`) in both automatic and manual Lambda KMS policies.
- [x] 34. Use `StringEquals` (instead of `StringLike`) for exact `kms:ViaService = ssm.${data.aws_region.current.name}.amazonaws.com` matching in both Lambda KMS policies.
