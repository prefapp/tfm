# Tasks: Lazy-load config after EventBridge no-op filtering

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Move `load_config()` after EventBridge no-op decision point
- [x] 2. Preserve behavior for replicable EventBridge/manual/full-sync paths
- [x] 3. Validate syntax and diagnostics

## Validation Notes

- Refactor applied in `src/handler.py`:
	- Removed eager `config = load_config()` before EventBridge extraction.
	- EventBridge branch now loads config only when `param_name_eb` is present (replicable).
	- Non-EventBridge paths still initialize config once before manual/full-sync logic.
- Ran `python3 -m py_compile handler.py` from `src/` (success).
- Diagnostics show only pre-existing editor environment warning: unresolved `boto3` import.
