# Basic example

Minimal runnable root: two **`role_assignments`** entries — **`foo`** at resource group scope with **`role_definition_name`**, **`bar`** at a VM resource scope with **`role_definition_id`**. Principal **`type`** defaults to `ServicePrincipal` in the module.

Replace IDs and resource paths in [`main.tf`](./main.tf) before `terraform plan`.

## Usage

```bash
terraform init
terraform plan
```

## Configuration

See [`main.tf`](./main.tf).
