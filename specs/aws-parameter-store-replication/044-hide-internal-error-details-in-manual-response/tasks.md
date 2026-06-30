# Tasks: Hide internal exception details from manual invocation HTTP response

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Remove raw exception text from manual `500` response in `src/handler.py`
- [x] 2. Preserve exception details in logs
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Manual invocation `500` response body no longer includes raw exception text.
- Exception detail logging remains unchanged (`error=str(e), exc_info=True`) for troubleshooting in CloudWatch logs.
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
