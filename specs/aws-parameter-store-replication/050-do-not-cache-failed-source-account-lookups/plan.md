# Plan: Do not cache failed source account STS lookups

1. Adjust `load_config()` cache flow so `_SOURCE_ACCOUNT_CACHE` is assigned only on successful STS lookup.
2. Keep current fallback return value (`""`) for a single failing invocation without persisting it.
3. Validate Python syntax and diagnostics.
