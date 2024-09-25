# Azure MongoDB Atlas
## Overview

This module creates a MongoDB Atlas resource in Azure with the following features:
- MongoDB Atlas project.
- MongoDB Atlas cluster.
- MongoDB Atlas database users.
- User passwords stored in Azure Key Vault.
- MongoDB Atlas network access.
- MongoDB Atlas private link endpoint.
- MongoDB Atlas private link endpoint service.
- Azure private endpoint.
- Datadog API key.
- Datadog API key secret in Azure Key Vault.
- MongoDB Atlas third party integration for Datadog.

## Requirements

- Subnet created (VNet).
- Azure Key Vault created.
- MongoDB Atlas organization (ID).
- Set the MongoDB Atlas `Require IP Access List for the Atlas Administration API` into Organization Settings on `disabled` eventuality. When you provision the cluster, the module will create the IP access list. Afterward, you can enable it again.

## DOC

### MongoDB Atlas Resources
- [Resource project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project)
- [Resource cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster)
- [Resource database user](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user)
- [Resource project IP access list](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list)
- [Resource private link endpoint](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/privatelink_endpoint)
- [Resource private link endpoint service](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/privatelink_endpoint_service)
- [Resource third party integration](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/third_party_integration)

### Datadog Resources
- [Resource API key](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/api_key)
- [Data source API key](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/data-sources/api_key)

### Azure Resources
- [Resource key vault secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)
- [Data source key vault secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets)
- [Data source subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)
- [Resource private endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
- [Data source key vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault)
- [Data source key vault secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets)

### HashiCorp Resources
- [Resource random password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)

## Usage

### Set a module

```terraform
module "mongodb-atlas" {
  source = "git::https://github.com/prefapp/tfm.git//modules/mongodb-atlas?ref=<module_version>"
}
```

#### Example

```terraform
module "mongodb-atlas" {
  source = "git::https://github.com/prefapp/tfm.git//modules/mongodb-atlas?ref=1.0.0"
}
```

### Set providers

```hcl
provider "mongodbatlas" {
  public_key  = "your_public_key" # Or use a own variable
  private_key = "your_private_key" # Or use a own variable
}

provider "azurerm" {
  features {}
  subscription_id = "your_subscription_id" # Or use a own variable
}

provider "datadog" {
  api_key = "your_api_key" # Or use a own variable
  app_key = "your_app_key" # Or use a own variable
  api_url = "https://api.datadoghq.com" # Optional if you use the default URL || "https://api.datadoghq.eu"
}
```

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| mongo_region | The mongo region | `string` | n/a | yes |
| provider | The provider configuration | `object({ provider_name = string, global_resource_group_name = string, cluster_provider_disk_type_name = string, cluster_provider_instance_size_name = string, network = object({ subnet_name = string, vnet_name = string, vnet_resource_group_name = string, endpoint_name = string, endpoint_location = string, endpoint_resource_group_name = string, endpoint_connection_is_manual_connection = bool, endpoint_connection_request_message = string }) })` | n/a | yes |
| org_id | The organization ID | `string` | n/a | yes |
| project_name | The name of the project | `string` | n/a | yes |
| cluster_name | The name of the cluster | `string` | n/a | yes |
| cluster_type | The type of the cluster | `string` | n/a | yes |
| cluster_replication_specs_config_analytics_nodes | The number of analytics nodes | `number` | n/a | yes |
| cluster_replication_specs_config_electable_nodes | The number of electable nodes | `number` | n/a | yes |
| cluster_replication_specs_config_priority | Priority value | `number` | n/a | yes |
| cluster_replication_specs_config_read_only_nodes | The number of read only nodes | `number` | n/a | yes |
| cluster_cloud_backup | Whether or not cloud backup is enabled | `bool` | n/a | yes |
| cluster_auto_scaling_disk_gb_enabled | Whether or not disk autoscaling is enabled | `bool` | n/a | yes |
| cluster_mongo_db_major_version | MongoDB major version | `string` | n/a | yes |
| cluster_provider_disk_type_name | Provider disk type name | `string` | n/a | yes |
| cluster_provider_instance_size_name | Provider instance size name | `string` | n/a | yes |
| cluster_num_shards | The number of shards | `number` | n/a | yes |
| cluster_zone | The zones of the cluster | `string` | n/a | yes |
| key_vault_name | The key vault name (only if provider is AZURE) | `string` | n/a | yes |
| key_vault_resource_group_name | The key vault resource group name (only if provider is AZURE) | `string` | `""` | no |
| users | List of users with their roles and scopes | `list(object({ username = string, auth_db_name = string, roles = optional(list(object({ role_name = string, database_name = string }))), scopes = optional(list(object({ name = string, type = string }))) }))` | n/a | yes |
| password_length | The password length | `number` | n/a | yes |
| password_special | Whether or not the password has special characters | `bool` | n/a | yes |
| prefix_pass_name | The prefix of the password name | `string` | n/a | yes |
| subnet_name | Name of the Azure subnet (only if provider is AZURE) | `string` | n/a | yes |
| vnet_name | Name of the Azure vnet (only if provider is AZURE) | `string` | n/a | yes |
| vnet_resource_group_name | Name of the Azure vnet resource group (only if provider is AZURE) | `string` | `""` | no |
| endpoint_name | Name of the Azure endpoint (only if provider is AZURE) | `string` | n/a | yes |
| endpoint_location | Location of the Azure endpoint (only if provider is AZURE) | `string` | n/a | yes |
| endpoint_resource_group_name | Name of the Azure endpoint resource group (only if provider is AZURE) | `string` | `""` | no |
| endpoint_connection_is_manual_connection | Whether or not the endpoint's private service connection is manual (only if provider is AZURE) | `bool` | n/a | yes |
| endpoint_connection_request_message | Request message of the endpoint's private service connection (only if provider is AZURE) | `string` | n/a | yes |
| whitelist_ips | The whitelist IPs | `list(object({ ip = string, name = string }))` | n/a | yes |
| enabled_datadog_integration | Whether or not the Datadog integration is enabled | `bool` | `false` | no |
| datadog_api_key_name | The Datadog API key name | `string` | `""` | no |

### Set a data .tfvars

```hcl
# Global variables
mongo_region               = "EUROPE_WEST"

# Project section variables
org_id       = "example-org-id"
project_name = "example-project"

# Cluster section variables
cluster_name                                     = "example-cluster"
cluster_type                                     = "REPLICASET"
cluster_replication_specs_config_analytics_nodes = 0
cluster_replication_specs_config_electable_nodes = 3
cluster_replication_specs_config_priority        = 7
cluster_replication_specs_config_read_only_nodes = 0
cluster_cloud_backup                             = true
cluster_auto_scaling_disk_gb_enabled             = true
cluster_mongo_db_major_version                   = "6.0"
cluster_num_shards                               = 1
cluster_zone                                     = "Zone 1"

# Key Vault section variables
key_vault_name                = "example-key-vault"
key_vault_resource_group_name = "example-key-vault-rg"
prefix_pass_name              = "example-prefix"
password_length               = 20
password_special              = false

# Users section variables
users = [
  {
    username     = "user1"
    auth_db_name = "admin"
    roles = [
      {
        role_name     = "readWrite"
        database_name = "db1"
      }
    ]
    scopes = [
      {
        name = "example-scope"
        type = "CLUSTER"
      }
    ]
  },
  {
    username     = "user2"
    auth_db_name = "admin"
    roles = [
      {
        role_name     = "readWrite"
        database_name = "db2"
      }
    ]
  },
  {
    username     = "user3"
    auth_db_name = "admin"
    roles = [
      {
        role_name     = "readWrite"
        database_name = "db3"
      }
    ]
    scopes = [
      {
        name = "example-scope"
        type = "CLUSTER"
      },
      {
        name = "example-scope-alt"
        type = "CLUSTER"
      }
    ]
  }
]

# Private variables
provider = {
  provider_name                              = "AZURE"
  global_resource_group_name                 = "example"
  cluster_provider_disk_type_name            = "P6"
  cluster_provider_instance_size_name        = "M10"
  network = {
    subnet_name                                = "example-subnet"
    vnet_name                                  = "example-vnet"
    vnet_resource_group_name                   = "example-vnet-rg"
    endpoint_name                              = "example-endpoint"
    endpoint_location                          = "westeurope"
    endpoint_resource_group_name               = "example-endpoint-rg"
    endpoint_connection_is_manual_connection   = true
    endpoint_connection_request_message        = "Example request message"
  }
}

# Datadog API key section variables
enabled_datadog_integration = true
datadog_api_key_name        = "example_datadog_api_key"

# Locals
whitelist_ips = [
  {
    ip   = "192.168.1.1"
    name = "example-ip1"
  },
  {
    ip   = "192.168.1.2"
    name = "example-ip2"
  }
]
```
