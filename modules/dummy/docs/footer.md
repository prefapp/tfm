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
