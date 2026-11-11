# Full sync requires explicit event flag

Full-account sync (replicating all parameters matching a prefix) only runs when the invocation event contains an explicit `enable_full_sync: true` or `initial_run: true` flag. The module's `enable_full_sync` config variable acts as an allow/deny guardrail, not a trigger. This prevents accidental full syncs from empty or malformed invocations, which could be expensive and disruptive at scale.
