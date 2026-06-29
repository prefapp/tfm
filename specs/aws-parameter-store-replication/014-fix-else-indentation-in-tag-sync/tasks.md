# Tasks: Fix else indentation in tag-sync update path

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Correct indentation under update-time tag-sync `else:` branch
- [x] 2. Validate diagnostics for `src/common/replication.py`

## Validation Notes

- File-level diagnostics checked after edit.
- Only unresolved imports (`boto3`, `botocore`) are reported; these are environment-related and pre-existing.
