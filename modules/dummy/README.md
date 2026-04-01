<!-- BEGIN_TF_DOCS -->
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

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.conditional_crash](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.conditional_destroy_crash](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.conditional_destroy_sleep](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.conditional_sleep](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.diagnostic_base_logic](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [external_external.script_executor](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_crash_on_apply"></a> [crash\_on\_apply](#input\_crash\_on\_apply) | Set to true to force a non-zero exit code during the 'apply' phase. | `bool` | `false` | no |
| <a name="input_crash_on_destroy"></a> [crash\_on\_destroy](#input\_crash\_on\_destroy) | Set to true to force a non-zero exit code during the 'destroy' phase. | `bool` | `false` | no |
| <a name="input_crash_on_plan"></a> [crash\_on\_plan](#input\_crash\_on\_plan) | Set to true to force a non-zero exit code during the 'plan' phase. | `bool` | `false` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | A unique identifier for this module instance. | `string` | n/a | yes |
| <a name="input_sleep_on_apply"></a> [sleep\_on\_apply](#input\_sleep\_on\_apply) | Number of seconds to sleep during the 'apply' phase. | `number` | `0` | no |
| <a name="input_sleep_on_destroy"></a> [sleep\_on\_destroy](#input\_sleep\_on\_destroy) | Number of seconds to sleep during the 'destroy' phase. | `number` | `0` | no |
| <a name="input_sleep_on_plan"></a> [sleep\_on\_plan](#input\_sleep\_on\_plan) | Number of seconds to sleep during the 'plan' phase. | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apply_resource_id"></a> [apply\_resource\_id](#output\_apply\_resource\_id) | The ID of the base null resource, indicating apply logic executed. |
| <a name="output_script_message"></a> [script\_message](#output\_script\_message) | The message returned by the external script (ran during plan). |
| <a name="output_script_timestamp"></a> [script\_timestamp](#output\_script\_timestamp) | The timestamp returned by the external script (ran during plan). |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/dummy/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/dummy/_examples/basic) - Minimal configuration showing plan, apply, and destroy controls

## Resources

- **Terraform null provider**: [https://registry.terraform.io/providers/hashicorp/null/latest](https://registry.terraform.io/providers/hashicorp/null/latest)
- **Terraform external provider**: [https://registry.terraform.io/providers/hashicorp/external/latest](https://registry.terraform.io/providers/hashicorp/external/latest)
- **Terraform local-exec provisioner**: [https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec](https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->

