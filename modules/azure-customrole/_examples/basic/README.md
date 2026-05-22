# Basic example — `azure-customrole`

Creates one custom role in the current subscription scope.

From the **repository root** `tfm`:

```bash
cd modules/azure-customrole/_examples/basic
```

Then:

```bash
az login
terraform init -backend=false
terraform plan -var="subscription_id=$(az account show --query id -o tsv)"
```

You need permission to create role definitions on that subscription. `apply` creates a real custom role.
