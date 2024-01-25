# Terraform Module: azurerm_postgresql_flexible_server

This Terraform Module creates a [Azure PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/) with the following features:

- It creates a single Flexible Server
- It can create it from a PITr
- It updates the admin password or takes if from an Azure KeyVault Secret
- It can update and manage Server additional configurations

## Usage

Module usage:

```hcl
module "postgresql" {
 source = "<module url>"
 location = "<region>"
 data = yamldecode(file("<path to yaml file with the data>"))
}
```

## Requirements

### Inputs

- A DNS private zone
- A resource group
- A subnet with a Service Delegation for ```Microsoft.DBforPostgreSQL/flexibleServers``` and service endpoints to ```Microsoft.Storage```
- A keyvault to store/read a secret with the PostgreSQL admin pass

### Yaml input

The module can be used with data expressed in a yaml file such as:

```yaml

server:
  name: mi-server
  version: 12
  disk_size: 32768
  sku_name: "GP_Standard_D2ds_v4"
  tags: {}
  zone: "1"
  replication_role:

server_creation:
  mode: Default
  #mode: PointInTimeRestore
  #from_pitr:
  #  source_server_name: "mi-original-server"
  #  source_server_resource_group: "mi-original-server-rg"
  #  pitr: "2018-03-13T13:59:00Z"

server_parameters:
  azure_extensions:
    - PG_BUFFERCACHE
    - PG_STAT_STATEMENTS
    - PLPGSQL
    - UNACCENT
    - UUID-OSSP

backup_retention_days: 12

administrator_login: pgadmin

maintainance_window:
  day_of_week: 6
  start_hour: 0
  start_minute: 0

authentication:
  password_auth_enabled: true
  active_directory_auth_enabled: false

password:
  key_vault_name: test-tfm-prefapp2
  key_vault_resource_group: test-modulo
  key_vault_secret_name: pg-pass2
  create: true

resource_group:
  name: test-modulo

subnet:
  id: "/subscriptions/152234234/resourceGroups/test-modulo/providers/Microsoft.Network/virtualNetworks/test-modulo/subnets/default"
  #name: default
  vnet:
    name: test-modulo
    resource_group: test-modulo

dns:
  private:
    name: test.tfm.postgres.database.azure.com
    resource_group: test-modulo
```

## PITR creation explanation

The creation of a server from a PITR will create a new server. If the source is different and is deleted, the new server will not be affected, however, you will have to change the `server_creation.mode` to `Default` after its creation so that it is not tried to restore again and thus be able to apply a `terraform plan` or` terraform apply` without trying to restore again.

## Get list of PiTRs backups

```yaml
az postgres flexible-server backup list --resource-group test-modulo --names mi-server
```

## Optional Password creation

Now it suffises to pass a key vault , a resource group and a key name to have a random password created, inserted as a secret in the KV and as the pass of the server. 

```yaml
password:
  key_vault_name: test-tfm-prefapp
  key_vault_resource_group: test-modulo
  key_vault_secret_name: pg-pass
  create: true
```

If the password is to be supplied not created by the module:

```yaml
password:
  key_vault_name: test-tfm-prefapp
  key_vault_resource_group: test-modulo
  key_vault_secret_name: pg-pass
  create: false
```
