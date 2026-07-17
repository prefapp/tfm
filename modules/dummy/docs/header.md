# Terraform Diagnostic Executor Module

This module is designed for DevOps testing and CI/CD pipeline validation. It provides features to simulate network latency (sleep) and catastrophic failures (crash) at both the `terraform plan` and `terraform apply` stages.

It leverages the `external` data source (for plan-time checks) and `null_resource` with `local-exec` provisioners (for apply-time actions).

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

  # Retry controls (set to N > 0 to fail N times before succeeding)
  tries_before_plan_ok  = 2
  tries_before_apply_ok = 3
}
```
