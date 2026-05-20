# Basic example

Minimal storage account with **Allow** default network action (no subnet rules). Replace:

- `resource_group_name` with an existing resource group.
- `storage_account.name` with a **globally unique** name (3–24 chars, lowercase letters and numbers only).

## Usage

```bash
terraform init
terraform plan
```

## Configuration

See [`main.tf`](./main.tf).
