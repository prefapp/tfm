# Basic example

Configures **Azure Files** backup only (`backup_share`). Replace:

- `backup_resource_group_name` — existing resource group for the Recovery Services vault.
- `storage_account_id` — full ID of the storage account to back up.
- Vault name, policy name, and `source_file_share_name` (share must exist).

`backup_blob` is disabled (`null`).

## Usage

```bash
terraform init
terraform plan
```

## Configuration

See [`main.tf`](./main.tf).
