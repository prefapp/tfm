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
