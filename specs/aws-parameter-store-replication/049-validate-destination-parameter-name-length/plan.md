# Plan: Validate destination parameter name length after regional prefixing

1. Refactor `_build_destination_parameter_name` to compute `dest_name` in both path/non-path branches.
2. Add 2048-length guard and return final `dest_name`.
3. Run Python syntax check.
