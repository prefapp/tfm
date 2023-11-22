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
tags = {
  environment = "dev"
  costcenter  = "it"
  project     = "aks"
  owner       = "me"
}
aks_node_pools = {}
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
tags = {
  environment = "dev"
  costcenter  = "it"
  project     = "aks"
  owner       = "me"
}
aks_node_pools = {
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

```text
#######################
###       AKS       ###
#######################

AKSClusterName:aks-cluster
AKSLocation:westeurope
AKSResourceGroup:test-aks-cluster-rg
AKSClusterID:/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/test-aks-cluster-rg/providers/Microsoft.ContainerService/managedClusters/aks-cluster

AKSKubernetesVersion:1.26.6
AKSAzurePolicyEnabled:true
AKSAutoUpgradeChannel:patch
AKSSKUTier:Free
AKSWorkloadIdentityEnabled:true
AKSOIDCIssuerEnabled:true
AKSIdentityType:SystemAssigned

AKS DNS Prefix:     foo-test
AKS Network Plugin: azure
AKS Service CIDR:   10.110.0.0/16
AKS DNS Service IP: 10.110.0.10

AKS Default Node Pool Name:            defaultnp
AKS Default Node Pool Node Count:      1
AKS Default Node Pool VM Size:         Standard_F8s_v2
AKS Default Node Pool OS Disk Type:    Managed
AKS Default Node Pool OS Disk Size GB: 30
AKS Default Node Pool Max Pods:        110

AKS Key Vault Secrets Provider Enabled:  true
AKS Key Vault Secrets Provider Interval: 2m

Tags: {"costcenter":"it","environment":"dev","owner":"me","project":"aks"}

######################
#### Node Pool(s) ####
######################

- Node Pool 'np1':
  - ID: /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/test-aks-cluster-rg/providers/Microsoft.ContainerService/managedClusters/aks-cluster/agentPools/
  - VM Size: Standard_F8s_v2
  - Node Count: 1
  - Min Count: 1
  - Max Count: 2
  - OS Disk Type: Managed
  - OS Disk Size GB: 30
  - Max Pods: 110
  - Auto Scaling Enabled: false
  - Tags: {"costcenter":"it","environment":"dev","owner":"me","project":"aks"}
  - Node Labels: {"nodepool":"defaultnp"}

- Node Pool 'np2':
  - ID: /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/test-aks-cluster-rg/providers/Microsoft.ContainerService/managedClusters/aks-cluster/agentPools/
  - VM Size: Standard_F8s_v2
  - Node Count: 1
  - Min Count: 1
  - Max Count: 2
  - OS Disk Type: Managed
  - OS Disk Size GB: 30
  - Max Pods: 110
  - Auto Scaling Enabled: true
  - Tags: {"costcenter":"it","environment":"dev","owner":"me","project":"aks"}
  - Node Labels: {"nodepool":"np1"}


######################
####      VNET    ####
######################

AKS Subnet Name:         test-subnet-module-aks
AKS VNET Name:           test-test-aks-cluster
AKS VNET Resource Group: test-aks-cluster-rg
AKS Subnet ID:           /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/test-aks-cluster-rg/providers/Microsoft.Network/virtualNetworks/test-test-aks-cluster/subnets/test-subnet-module-aks
```
