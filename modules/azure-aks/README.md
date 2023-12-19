# Azure aks module

## Overview

This module creates a AKS cluster whit a default node pool and (optionally) other node pools in Azure.

## Requirements

- Resource group created.
- Subnet created (VNet).

## DOC

- [Resource terraform - aks_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster).
- [Resource terraform - aks_node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool).

## Usage

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-aks?ref=<version>"
}
```

#### Example

```terraform
module "azure-aks" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-aks?ref=v1.2.3"
}
```

### Set a data .tfvars

#### Example whitout additional node pools

```hcl
aks_cluster_name                        = "aks-cluster"
aks_location                            = "westeurope"
aks_resource_group_name                 = "test-aks-cluster-rg"
aks_aks_dns_prefix                      = "foo-test"
aks_kubernetes_version                  = "1.26.6"
aks_azure_policy_enabled                = true
aks_automatic_channel_upgrade           = "patch"
aks_sku_tier                            = "Free"
aks_workload_identity_enabled           = true
aks_oidc_issuer_enabled                 = true
aks_identity_type                       = "SystemAssigned"
aks_default_node_pool_name              = "defaultnp"
aks_default_node_pool_enable_auto_scaling = false
aks_default_node_pool_node_count        = 1
aks_default_node_pool_vm_size           = "Standard_F8s_v2"
aks_default_node_pool_os_disk_type      = "Managed"
aks_default_node_pool_os_disk_size_gb   = 30
aks_default_node_pool_max_pods          = 110
aks_key_vault_secrets_provider_enabled  = true
aks_key_vault_secrets_provider_interval = "2m"
aks_network_plugin                      = "azure"
aks_service_cidr                        = "10.110.0.0/16"
aks_dns_service_ip                      = "10.110.0.10"
aks_tags = {
  environment = "dev"
  costcenter  = "it"
  project     = "aks"
  owner       = "me"
}
node_pool_additionals = {}
aks_subnet_name              = "test-subnet-module-aks"
aks_vnet_name                = "test-test-aks-cluster"
aks_vnet_name_resource_group = "test-aks-cluster-rg"
```

#### Example whit additional node pools

```hcl
aks_cluster_name                        = "aks-cluster"
aks_location                            = "westeurope"
aks_resource_group_name                 = "test-aks-cluster-rg"
aks_aks_dns_prefix                      = "foo-test"
aks_kubernetes_version                  = "1.26.6"
aks_azure_policy_enabled                = true
aks_automatic_channel_upgrade           = "patch"
aks_sku_tier                            = "Free"
aks_workload_identity_enabled           = true
aks_oidc_issuer_enabled                 = true
aks_identity_type                       = "SystemAssigned"
aks_default_node_pool_name              = "defaultnp"
aks_default_node_pool_enable_auto_scaling = true
aks_default_node_pool_min_count         = 1
aks_default_node_pool_max_count         = 2
aks_default_node_pool_node_count        = 1
aks_default_node_pool_vm_size           = "Standard_F8s_v2"
aks_default_node_pool_os_disk_type      = "Managed"
aks_default_node_pool_os_disk_size_gb   = 30
aks_default_node_pool_max_pods          = 110
aks_key_vault_secrets_provider_enabled  = true
aks_key_vault_secrets_provider_interval = "2m"
aks_network_plugin                      = "azure"
aks_service_cidr                        = "10.110.0.0/16"
aks_dns_service_ip                      = "10.110.0.10"
aks_tags = {
  environment = "dev"
  costcenter  = "it"
  project     = "aks"
  owner       = "me"
}
node_pool_additionals = {
  np1 = {
    name                = "np1"
    vm_size             = "Standard_F8s_v2"
    node_count          = 1
    min_count           = 1
    max_count           = 2
    os_disk_type        = "Managed"
    os_disk_size_gb     = 30
    max_pods            = 110
    enable_auto_scaling = false
    tags = {
      environment = "dev"
      costcenter  = "it"
      project     = "aks"
      owner       = "me"
    }
    node_labels = {
      "nodepool" = "np1"
    }
  },
  np2 = {
    name                = "np2"
    vm_size             = "Standard_F8s_v2"
    node_count          = 1
    min_count           = 1
    max_count           = 2
    os_disk_type        = "Managed"
    os_disk_size_gb     = 30
    max_pods            = 110
    enable_auto_scaling = true
    tags = {
      environment = "dev"
      costcenter  = "it"
      project     = "aks"
      owner       = "me"
    }
    node_labels = {
      "nodepool" = "np2"
    }
  }
}
aks_subnet_name              = "test-subnet-module-aks"
aks_vnet_name                = "test-test-aks-cluster"
aks_vnet_name_resource_group = "test-aks-cluster-rg"
```

## Output

```output
aks_cluster_automatic_channel_upgrade_output = "patch"
aks_cluster_azure_policy_enabled_output = true
aks_cluster_default_node_pool_max_pods_output = 110
aks_cluster_default_node_pool_name_output = "defaultnp"
aks_cluster_default_node_pool_node_count_output = 1
aks_cluster_default_node_pool_os_disk_size_gb_output = 30
aks_cluster_default_node_pool_os_disk_type_output = "Managed"
aks_cluster_default_node_pool_vm_size_output = "Standard_F8s_v2"
aks_cluster_dns_prefix_output = "foo-test"
aks_cluster_dns_service_ip_output = "10.110.0.10"
aks_cluster_id_output = "/subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/test-aks-cluster-rg/providers/Microsoft.ContainerService/managedClusters/aks-cluster"
aks_cluster_identity_type_output = "SystemAssigned"
aks_cluster_key_vault_secrets_provider_enabled_output = true
aks_cluster_key_vault_secrets_provider_interval_output = "2m"
aks_cluster_kubernetes_version_output = "1.26.6"
aks_cluster_location_output = "westeurope"
aks_cluster_name_output = "aks-cluster"
aks_cluster_network_plugin_output = "azure"
aks_cluster_node_pool_additionals_output = tomap({
  "np1" = {
    "enable_auto_scaling" = false
    "max_count" = 2
    "max_pods" = 110
    "min_count" = 1
    "name" = "np1"
    "node_count" = 1
    "node_labels" = tomap({
      "nodepool" = "np1"
    })
    "os_disk_size_gb" = 30
    "os_disk_type" = "Managed"
    "tags" = tomap({
      "costcenter" = "it"
      "environment" = "dev"
      "owner" = "me"
      "project" = "aks"
    })
    "vm_size" = "Standard_F8s_v2"
  }
  "np2" = {
    "enable_auto_scaling" = true
    "max_count" = 2
    "max_pods" = 110
    "min_count" = 1
    "name" = "np2"
    "node_count" = 1
    "node_labels" = tomap({
      "nodepool" = "np2"
    })
    "os_disk_size_gb" = 30
    "os_disk_type" = "Managed"
    "tags" = tomap({
      "costcenter" = "it"
      "environment" = "dev"
      "owner" = "me"
      "project" = "aks"
    })
    "vm_size" = "Standard_F8s_v2"
  }
})
aks_cluster_oidc_issuer_enabled_output = true
aks_cluster_resource_group_name_output = "test-aks-cluster-rg"
aks_cluster_service_cidr_output = "10.110.0.0/16"
aks_cluster_sku_tier_output = "Free"
aks_cluster_subnet_id_output = "/subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/test-aks-cluster-rg/providers/Microsoft.Network/virtualNetworks/test-test-aks-cluster/subnets/test-subnet-module-aks"
aks_cluster_subnet_name_output = "test-subnet-module-aks"
aks_cluster_tags_output = tomap({
  "costcenter" = "it"
  "environment" = "dev"
  "owner" = "me"
  "project" = "aks"
})
aks_cluster_vnet_name_output = "test-test-aks-cluster"
aks_cluster_vnet_name_resource_group_output = "test-aks-cluster-rg"
aks_cluster_workload_identity_enabled_output = true
```
