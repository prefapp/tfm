
<!-- BEGIN_TF_DOCS -->
# Terraform Diagnostic Executor Module

This module is designed for DevOps testing and CI/CD pipeline validation. It provides features to simulate network latency (sleep) and catastrophic failures (crash) at the `terraform plan`, `terraform apply`, and `terraform destroy` stages.

It leverages the `external` data source (for plan-time checks) and `null_resource` with `local-exec` provisioners (for apply-time and destroy-time actions).

## Prerequisites

- Terraform ~> 1.0 or OpenTofu >= 1.6.
- Node.js installed and accessible via PATH.
- Required providers: `hashicorp/external` and `hashicorp/null`.

## Basic Usage

```hcl
module "diagnostic_test" {
  source = "git::https://github.com/prefapp/tfm.git//modules/dummy?ref=<version>"

  instance_name    = "ci-pipeline-check"

  # Plan-time controls
  sleep_on_plan    = 5
  crash_on_plan    = false

  # Apply-time controls
  sleep_on_apply   = 10
  crash_on_apply   = false

  # Destroy-time controls
  sleep_on_destroy   = 5
  crash_on_destroy   = false

  # Retry controls (set to N > 0 to fail N times before succeeding)
  tries_before_plan_ok    = 2
  tries_before_apply_ok   = 3
  tries_before_destroy_ok = 2
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [null_resource.conditional_crash](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.conditional_crash_destroy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.conditional_sleep](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.conditional_sleep_destroy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.diagnostic_base_logic](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [external_external.script_executor](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_crash_on_apply"></a> [crash\_on\_apply](#input\_crash\_on\_apply) | Set to true to force a non-zero exit code during the 'apply' phase. | `bool` | `false` | no |
| <a name="input_crash_on_destroy"></a> [crash\_on\_destroy](#input\_crash\_on\_destroy) | Set to true to force a non-zero exit code during the 'destroy' phase. | `bool` | `false` | no |
| <a name="input_crash_on_plan"></a> [crash\_on\_plan](#input\_crash\_on\_plan) | Set to true to force a non-zero exit code during the 'plan' phase. | `bool` | `false` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | A unique identifier for this module instance. | `string` | n/a | yes |
| <a name="input_sleep_on_apply"></a> [sleep\_on\_apply](#input\_sleep\_on\_apply) | Number of seconds to sleep during the 'apply' phase. | `number` | `0` | no |
| <a name="input_sleep_on_destroy"></a> [sleep\_on\_destroy](#input\_sleep\_on\_destroy) | Number of seconds to sleep during the 'destroy' phase. | `number` | `0` | no |
| <a name="input_sleep_on_plan"></a> [sleep\_on\_plan](#input\_sleep\_on\_plan) | Number of seconds to sleep during the 'plan' phase. | `number` | `0` | no |
| <a name="input_tries_before_apply_ok"></a> [tries\_before\_apply\_ok](#input\_tries\_before\_apply\_ok) | Number of apply attempts that should fail before succeeding. Set to 0 or lower (default) to crash every time when crash\_on\_apply is true. Setting this to a value greater than 0 requires crash\_on\_apply to be true. | `number` | `0` | no |
| <a name="input_tries_before_destroy_ok"></a> [tries\_before\_destroy\_ok](#input\_tries\_before\_destroy\_ok) | Number of destroy attempts that should fail before succeeding. Set to 0 or lower (default) to crash every time when crash\_on\_destroy is true. Setting this to a value greater than 0 requires crash\_on\_destroy to be true. | `number` | `0` | no |
| <a name="input_tries_before_plan_ok"></a> [tries\_before\_plan\_ok](#input\_tries\_before\_plan\_ok) | Number of plan attempts that should fail before succeeding. Set to 0 or lower (default) to crash every time when crash\_on\_plan is true. Setting this to a value greater than 0 requires crash\_on\_plan to be true. | `number` | `0` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_apply_resource_id"></a> [apply\_resource\_id](#output\_apply\_resource\_id) | The ID of the base null resource, indicating apply logic executed. |
| <a name="output_script_message"></a> [script\_message](#output\_script\_message) | The message returned by the external script (ran during plan). |
| <a name="output_script_timestamp"></a> [script\_timestamp](#output\_script\_timestamp) | The timestamp returned by the external script (ran during plan). |

## Diagnostic Scenarios

Counter file paths use `<safe_instance_name>` — derived from the `instance_name` variable by removing all characters except `[a-zA-Z0-9_-]`.

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
<!-- END_TF_DOCS -->