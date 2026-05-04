# Basic example — `azure-kv`

Creates a resource group and a Key Vault with **one access policy** keyed by object ID.

1. From the **`tfm`** repo root: `cd modules/azure-kv/_examples/basic`
2. Replace the placeholder **`object_id`** in `main.tf` with a principal that may access the vault (and optionally change `name` / vault `name` so it is globally unique).
3. Run:

```bash
az login
terraform init -backend=false
terraform plan -backend=false -var="subscription_id=$(az account show --query id -o tsv)"
```

`apply` creates billable resources.
