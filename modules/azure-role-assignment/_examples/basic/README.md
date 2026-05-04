# Basic example

Runnable root module. The module accepts **any number** of **`role_assignments`** map entries (including **one** or **none** — an empty `{}` creates no resources). This example uses **two** keys only to show **different scope shapes** and **`role_definition_name`** vs **`role_definition_id`**; remove **`bar`** (or **`foo`**) if you only need a single assignment. **`foo`** sets **`type = "ServicePrincipal"`** explicitly; **`bar`** omits **`type`** and relies on the module default (`ServicePrincipal`).

Replace IDs and resource paths in [`main.tf`](./main.tf) before `terraform plan`.

## Usage

```bash
terraform init
terraform plan
```

## Configuration

See [`main.tf`](./main.tf).
