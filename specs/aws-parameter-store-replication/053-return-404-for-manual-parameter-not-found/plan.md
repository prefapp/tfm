# Plan: Return 404 for manual ParameterNotFound

1. Add helper in `handler.py` to identify parameter-not-found exceptions robustly.
2. Update manual replication exception handling to return 404 when helper matches.
3. Keep existing 500 path for non-not-found errors.
4. Validate Python syntax/diagnostics.
