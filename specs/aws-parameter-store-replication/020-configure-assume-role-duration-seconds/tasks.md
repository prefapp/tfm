# Tasks: Configure STS AssumeRole DurationSeconds for destination clients

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add Terraform input variable for assume-role duration
- [x] 2. Pass duration through Lambda environment variables
- [x] 3. Extend Python config/runtime to parse and carry duration
- [x] 4. Apply duration in assume-role helper and call sites
- [x] 5. Update docs and regenerate README
- [x] 6. Validate changed files

## Validation Notes

- Added `assume_role_duration_seconds` input with validation range `900..43200` in `variables.tf`.
- Propagated `ASSUME_ROLE_DURATION_SECONDS` env var in `lambda.tf`.
- Extended runtime config to parse and carry assume-role duration with fallback/range guard in `src/common/config.py`.
- Updated `assume_role` helper to pass `DurationSeconds` when provided in `src/common/utils.py`.
- Applied duration in destination assume-role call sites in `src/handler.py` and `src/common/replication.py`.
- Updated docs in `docs/header.md` and regenerated `README.md` via `terraform-docs .`.
- Validated with `terraform validate` (success; existing provider deprecation warnings unchanged).
- Validated Python syntax with `python3 -m py_compile handler.py common/config.py common/utils.py common/replication.py`.
