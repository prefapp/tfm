# Plan: Clarify overwrite log when destination existence is unknown

1. Update the pre-`put_parameter` logging branch in `replication.py`.
2. Keep API behavior unchanged (`Overwrite=True` path remains intact).
3. Validate syntax and diagnostics.
