# Basic example — `azure-application`

Minimal Entra ID app registration with one **Web** redirect URI.

From the **`tfm`** repository root:

```bash
cd modules/azure-application/_examples/basic
az login
terraform init -backend=false
terraform plan -backend=false -var="subscription_id=$(az account show --query id -o tsv)"
```

`subscription_id` is required for the `azurerm` provider even if this minimal stack only uses `azuread` resources (the module still declares `azurerm` in `versions.tf`). Grant your identity permission to create app registrations.
