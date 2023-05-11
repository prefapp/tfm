# Terraform Module: azurerm_postgresql_flexible_server

This Terraform module creates a PostgreSQL Flexible Server on Azure with the following features:

- Creates a single Flexible Server and a Resource Group
- Configurable backup retention days (7-35)

## Requirements

- AzureRM Provider version 3.55.0 or later.
- Access to a virtual network and subnet.
- An Azure Key Vault secret with the PostgreSQL administrator password.

## Usage

To use the module, include the following code in your Terraform configuration:

```hcl
module "postgresql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-flexible-server-postgresql?ref=azure-flexible-server-postgresql-v1.0.0"
  env                                  = "dev"
  cliente                              = "acme"
  producto                             = "my-product"
  location                             = "eastus"
  virtual_network_name                 = "my-virtual-network"
  virtual_network_rg                   = "my-virtual-network-rg"
  virtual_network_subnet_name          = "my-subnet"
  postgresql_name                      = "my-postgresql"
  postgresql_version                   = "14"
  backup_retention_days                = "7"
  authentication_password_auth_enabled = "true"
  administrator_login                  = "admin"
  administrator_password_key_vault     = "my-key-vault"
  administrator_password_secret_name   = "my-postgresql-secret"
  postgresql_disk_size                 = "5120"
  postgresql_sku_size                  = "Standard_D4s_v3"
}
```

|Name|Description|Type|Default|Required|
|----|-----------|----|-------|--------|
|env|The environment to deploy the resources into.|string|n/a|yes|
|cliente|The name of the client or organization.|string|n/a|yes|
|producto|The name of the product or application.|string|n/a|yes|
|location|The Azure region where resources will be created.|string|n/a|yes|
|virtual_network_name|The name of the existing virtual network.|string|n/a|yes|
|virtual_network_rg|The name of the existing resource group containing the virtual network.|string|n/a|yes|
|virtual_network_subnet_name|The name of the existing subnet where the server should be deployed.|string|n/a|yes|
|postgresql_name|The name of the PostgreSQL server to create.|string|n/a|yes|
|postgresql_version|The version of PostgreSQL to deploy.|string|"13|no|
|backup_retention_days|The number of days to retain backups for. Valid values are between 7 and 35.|string|"7"|no|
|authentication_active_directory_auth_enabled|Enable or disable Azure Active Directory authentication.|bool|"false"|no|
|authentication_password_auth_enabled|Enable or disable password authentication.|bool|"true"|no|
|administrator_login|The administrator login for the PostgreSQL server.|string|n/a|yes|
|administrator_password_key_vault|The name of the Key Vault containing the PostgreSQL administrator password.|string|n/a|yes|
|administrator_password_secret_name|The name of the secret containing the PostgreSQL administrator password.|string|n/a|yes|
|postgresql_disk_size|The size of disk in MiB|string|n/a|yes|
|postgresql_sku_size|The SKU name|string|n/a|yes|
|dns_private_zone_dns_name|The name of the Private DNS zone (without a terminating dot)|string|n/a|yes|
|dns_private_zone_dns_rg|Specifies the resource group where the Private DNS Zone exists.|string|n/a|yes|

## Note

Change de ref into source module `ref=1.0.0`
