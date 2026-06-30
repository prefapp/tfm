# Plan: Inline manual ParameterNotFound detection in handler

1. Replace helper usage in manual exception path with inline extraction of AWS error code.
2. Remove no-longer-used helper from `handler.py`.
3. Validate syntax and diagnostics.
