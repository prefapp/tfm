# ADR: Destroy-Time Values via `self.triggers`

**Context:** Terraform destroy-time provisioners can only reference `self`, `count.index`, or `each.key`. The module's `conditional_sleep_destroy` and `conditional_crash_destroy` resources need runtime values (sleep duration, crash flag, counter file path, retry count).

**Decision:** Pass these values through the resource's `triggers` map and reference them via `self.triggers["key"]`. A guard check using `self.triggers["crash_on_destroy"]` ensures resources created with `crash_on_destroy = false` always skip the destroy-time crash logic.

**Trade-offs:**
- Values are frozen at resource creation; toggling `crash_on_destroy` from `true` to `false` requires either a retry counter burn-through during apply or `terraform state rm`.
- The sentinel-file alternative would allow an arbitrary file-delete escape hatch but requires an extra resource and `jq` on the system.
- Simpler than the sentinel-file alternative (no extra resource, no `jq` dependency, no file-I/O side effect at apply time).
