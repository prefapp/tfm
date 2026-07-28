# ADR: Destroy-Time Values via `self.triggers`

**Context:** Terraform destroy-time provisioners can only reference `self`, `count.index`, or `each.key`. The module's `conditional_sleep_destroy` and `conditional_crash_destroy` resources need runtime values (sleep duration, crash flag, counter file path, retry count).

**Decision:** Pass these values through the resource's `triggers` map and reference them via `self.triggers["key"]`. A guard check using `self.triggers["crash_on_destroy"]` ensures resources created with `crash_on_destroy = false` always skip the destroy-time crash logic.

**Trade-offs:**
- Values are frozen at resource creation; toggling a variable requires a re-apply before destroy takes effect.
- Without a re-apply, the escape hatch is `terraform state rm` or letting the retry counter burn through.
- Simpler than the sentinel-file alternative (no extra resource, no `jq` dependency, no file-I/O side effect at apply time).
