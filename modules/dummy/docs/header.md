# **Dummy Terraform Module**

## Overview

This Terraform module is designed for DevOps testing and CI/CD pipeline validation. It provides controls to simulate latency and failures at every phase of the Terraform lifecycle — plan, apply, and destroy — without affecting real infrastructure.

The module uses the `external` data source to execute a Node.js script for plan-time diagnostics and `null_resource` with `local-exec` provisioners for apply-time and destroy-time behavior. This makes it easy to reproduce slow or failing pipeline runs in a controlled, repeatable way.

Typical use cases include testing CI/CD pipeline timeouts, verifying failure-handling logic, and validating destroy-phase behavior in automated workflows.

## Key Features

- **Plan-time controls**: Simulate slow or failing `terraform plan` runs via a Node.js script executed by the `external` data source.
- **Apply-time controls**: Introduce configurable delays or intentional failures during `terraform apply` using `null_resource` provisioners.
- **Destroy-time controls**: Reliably gate sleep and crash behavior during `terraform destroy`, always present in state so destroy provisioners execute as expected.
- **Deterministic destroy ordering**: The crash resource depends on the sleep resource, ensuring sleep always runs before crash when both are enabled.
- **Input validation**: The `sleep_on_destroy` variable is validated to require a non-negative integer, preventing silent misconfigurations.

## Basic Usage

### Simulate apply-time delay and destroy-time failure

```hcl
module "dummy" {
  source = "git::https://github.com/prefapp/tfm.git//modules/dummy"

  instance_name    = "ci-pipeline-check"

  sleep_on_apply   = 10
  crash_on_destroy = true
}
```

### Simulate plan-time crash and destroy-time delay

```hcl
module "dummy" {
  source = "git::https://github.com/prefapp/tfm.git//modules/dummy"

  instance_name    = "ci-pipeline-check"

  crash_on_plan    = true
  sleep_on_destroy = 30
}
```

## File Structure

```
dummy/
├── .terraform-docs.yml       # terraform-docs configuration
├── README.md                 # Auto-generated documentation
├── main.tf                   # Module resources and provisioners
├── variables.tf              # Input variable definitions
├── outputs.tf                # Output value definitions
├── script.js                 # Node.js script for plan-time diagnostics
├── _examples/                # Usage examples
│   └── basic/                # Basic configuration example
│       └── main.tf
└── docs/                     # Documentation source files
    ├── header.md             # This file
    └── footer.md             # Additional resources and support
```
