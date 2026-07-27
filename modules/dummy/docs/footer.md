## Diagnostic Scenarios

### 1. Test Plan Failure

```bash
terraform plan -var="crash_on_plan=true"
```

Expected Result: `terraform plan` exits with a non-zero exit code as the `data.external` source executes the Node.js script, which calls `process.exit(1)`.

### 1b. Test Transient Plan Failures

```bash
terraform plan -var="crash_on_plan=true" -var="tries_before_plan_ok=2"
```

Expected Result: The first two plans fail. The counter file `/tmp/tfm-dummy-plan-counter-<instance_name>` is created and incremented each attempt. On the third plan the counter exceeds the threshold, the script exits 0, and the counter file is cleaned up. Also applies to the plan phase within `terraform apply`.

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

Expected Result: The first two applies fail. The counter file `/tmp/tfm-dummy-counter-<instance_name>` is created and incremented each attempt. On the third apply the counter exceeds the threshold, the provisioner exits 0, and the counter file is cleaned up.

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
