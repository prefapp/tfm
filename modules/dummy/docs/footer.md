## Diagnostic Scenarios

Counter file paths use `<safe_instance_name>` — derived from the `instance_name` variable by removing all characters except `[a-zA-Z0-9_-]`. If no allowed characters remain, the fallback is `unnamed-<md5(instance_name)>` to avoid collisions across module instances.

### 1. Test Plan Failure

```bash
terraform plan -var="crash_on_plan=true"
```

Expected Result: `terraform plan` exits with a non-zero exit code as the `data.external` source executes the Node.js script, which calls `process.exit(1)`.

### 1b. Test Transient Plan Failures

```bash
terraform plan -var="crash_on_plan=true" -var="tries_before_plan_ok=2"
```

Expected Result: The first two plans fail. The counter file `/tmp/tfm-dummy-plan-counter-<safe_instance_name>` is created and incremented each attempt. On the third plan the counter exceeds the threshold, the script exits 0, and the counter file is cleaned up. Also applies to the plan phase within `terraform apply`.

### 2. Test Apply Failure

```bash
terraform apply -auto-approve -var="crash_on_apply=true"
```

Expected Result: `terraform apply` fails when `null_resource.conditional_crash`'s `local-exec` provisioner runs `exit 1`.

### 3. Test Apply Timeout / Latency

```bash
terraform apply -auto-approve -var="sleep_on_apply=30"
```

### 4. Test Transient Apply Failures

```bash
terraform apply -auto-approve -var="crash_on_apply=true" -var="tries_before_apply_ok=2"
```

Expected Result: The first two applies fail. The counter file `/tmp/tfm-dummy-counter-<safe_instance_name>` is created and incremented each attempt. On the third apply the counter exceeds the threshold, the provisioner exits 0, and the counter file is cleaned up.

### 5. Test Destroy Failure

Destroy-time provisioners only run on resources that already exist in state. The two-step workflow is:

**Step 1 — Create the destroy-trigger resources (no-op create, succeeds immediately):**
```bash
terraform apply -auto-approve -var="crash_on_destroy=true"
```

**Step 2 — Trigger the destroy failure:**
```bash
terraform destroy -auto-approve -var="crash_on_destroy=true"
```

Expected Result: `terraform destroy` fails when `null_resource.conditional_crash_destroy`'s destroy-time `local-exec` provisioner runs `exit 1`. The resource remains in state.

### 6. Test Destroy Timeout / Latency

**Step 1 — Create the destroy-trigger resource:**
```bash
terraform apply -auto-approve -var="sleep_on_destroy=30"
```

**Step 2 — Trigger the destroy delay:**
```bash
terraform destroy -auto-approve -var="sleep_on_destroy=30"
```

### 7. Test Transient Destroy Failures

**Step 1 — Create the destroy-trigger resource:**
```bash
terraform apply -auto-approve -var="crash_on_destroy=true" -var="tries_before_destroy_ok=2"
```

**Step 2 — Trigger the transient failures (repeat until success):**
```bash
terraform destroy -auto-approve -var="crash_on_destroy=true" -var="tries_before_destroy_ok=2"
```

Expected Result: The first two destroys fail. The counter file `/tmp/tfm-dummy-destroy-counter-<safe_instance_name>` is created and incremented each attempt. On the third destroy the counter exceeds the threshold, the provisioner exits 0, the counter file is cleaned up, and the resource is destroyed.

### Destroy-Time Toggle Limitation

Destroy-time provisioners in Terraform can only reference `self.triggers` — values are **frozen at resource creation time**. If you create a resource with `crash_on_destroy = true` then change it to `false` before destroying, the guard in `self.triggers["crash_on_destroy"]` still sees `"true"` and the crash runs. The skip guard **only works** when the resource was *created* with `crash_on_destroy = false`.

Since changing triggers on a `null_resource` causes Terraform to **destroy the old resource first** (default `create_before_destroy = false`), a plain `terraform apply -var="crash_on_destroy=false"` will also trigger the crash — the old resource runs its destroy provisioner with the frozen `crash_on_destroy = "true"` before the new resource is created.

**To toggle safely, use one of these approaches:**

**Approach A — Burn through with a retry counter (in-place, no state manipulation):**
```bash
terraform apply -auto-approve \
  -var="crash_on_destroy=false" \
  -var="tries_before_destroy_ok=3"
```
This apply triggers the destroy of the old resource, which crashes N times (here 3) then succeeds, allowing the new resource (with `crash_on_destroy = false`) to be created. Subsequent destroys exit cleanly.

**Approach B — Remove from state (quick escape at the cost of an orphan):**
```bash
terraform state rm 'module.<NAME>.null_resource.conditional_crash_destroy[0]'
terraform destroy
```
