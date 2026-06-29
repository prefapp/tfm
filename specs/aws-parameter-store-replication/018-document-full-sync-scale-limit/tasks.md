# Tasks: Document full-sync scale and timeout limitations

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add full-sync timeout/scale caveat in `docs/header.md`
- [x] 2. Include mitigation guidance for large DR bootstrap runs
- [x] 3. Regenerate module `README.md` with `terraform-docs .`

## Validation Notes

- Added `Full Sync Scale and Timeout Considerations` section in `docs/header.md`.
- Documented default timeout (600s), AWS max timeout (900s), and lack of built-in continuation/resume.
- Added mitigation guidance (increase timeout + batching, iterative re-runs, Step Functions/external orchestration).
- Ran `terraform-docs .` successfully in module directory.
