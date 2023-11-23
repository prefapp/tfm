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
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-aks?ref=v1.2.3"
}
```

### Set a data input.yaml

#### Example whit additional node pools

```yaml
aks:

  cluster_name: aks-cluster # The name of the AKS cluster
  location: westeurope # The location where the AKS cluster will be created
  resource_group_name: example-resources # The name of the resource group where the AKS cluster will be created
  kubernetes_version: 1.26.6 # The version of Kubernetes to use for the AKS cluster
  sku_tier: Free # The SKU tier for the AKS cluster
  automatic_channel_upgrade: patch # Whether automatic channel upgrades are enabled for the AKS cluster

  network:
    dns_prefix: foo-test # The DNS prefix for the AKS cluster
    network_plugin: azure # The network plugin to use for the AKS cluster
    service_cidr: 192.21.0.0/16 # The service CIDR for the AKS cluster
    dns_service_ip: 192.21.1.10 # The DNS service IP for the AKS cluster
    subnet:
      subnet_name: default # The name of the subnet for the AKS cluster
      vnet_name: vnet4 # The name of the virtual network for the AKS cluster
      vnet_name_resource_group: example-resources # The name of the resource group where the virtual network is located

  identity:
    azure_policy_enabled: true # Whether Azure Policy is enabled for the AKS cluster
    workload_identity_enabled: true # Whether workload identity is enabled for the AKS cluster
    oidc_issuer_enabled: true # Whether OIDC issuer is enabled for the AKS cluster
    identity_type: SystemAssigned # The type of identity used for the AKS cluster

  default_node_pool:
    name: defaultnp # The name of the default node pool
    enable_auto_scaling: true # Whether auto-scaling is enabled for the default node pool
    min_count: 1 # The minimum number of nodes for the default node pool if auto-scaling is enabled
    max_count: 2 # The maximum number of nodes for the default node pool if auto-scaling is enabled
    node_count: 1 # The number of nodes in the default node pool
    vm_size: Standard_F8s_v2 # The size of the VMs in the default node pool
    os_disk_type: Managed # The type of OS disk for the default node pool
    os_disk_size_gb: 30 # The size of the OS disk in GB for the default node pool
    max_pods: 110 # The maximum number of pods that can be run on a node in the default node pool

  key_vault_secrets:
    key_vault_secrets_provider_enabled: true # Whether secret rotation is enabled for the Key Vault secrets provider
    key_vault_secrets_provider_interval: 2m # The interval for secret rotation for the Key Vault secrets provider

  tags:
    environment: dev # The environment tag for the AKS cluster
    costcenter: it # The cost center tag for the AKS cluster
    project: aks # The project tag for the AKS cluster
    owner: me # The owner tag for the AKS cluster

  extra_node_pools: # Additional node pools for the AKS cluster
  
    np1:
      name: np1 # The name of the first extra node pool
      vm_size: Standard_F8s_v2 # The size of the VMs in the first extra node pool
      node_count: 1 # The number of nodes in the first extra node pool
      min_count: 1 # The minimum number of nodes for the first extra node pool
      max_count: 2 # The maximum number of nodes for the first extra node pool
      os_disk_type: Managed # The type of OS disk for the first extra node pool
      os_disk_size_gb: 30 # The size of the OS disk in GB for the first extra node pool
      max_pods: 110 # The maximum number of pods that can be run on a node in the first extra node pool
      enable_auto_scaling: false # Whether auto-scaling is enabled for the first extra node pool
      tags: # The tags for the first extra node pool
        environment: dev
        costcenter: it
        project: aks
        owner: me
      node_labels: # The labels for the nodes in the first extra node pool
        nodepool: np1
        
    np2:
      name: np2 # The name of the second extra node pool
      vm_size: Standard_F8s_v2 # The size of the VMs in the second extra node pool
      node_count: 1 # The number of nodes in the second extra node pool
      min_count: 1 # The minimum number of nodes for the second extra node pool
      max_count: 2 # The maximum number of nodes for the second extra node pool
      os_disk_type: Managed # The type of OS disk for the second extra node pool
      os_disk_size_gb: 30 # The size of the OS disk in GB for the second extra node pool
      max_pods: 110 # The maximum number of pods that can be run on a node in the second extra node pool
      enable_auto_scaling: true # Whether auto-scaling is enabled for the second extra node pool
      tags: # The tags for the second extra node pool
        environment: dev
        costcenter: it
        project: aks
        owner: me
      node_labels: # The labels for the nodes in the second extra node pool
        nodepool: np2
```

#### Example whitout additional node pools

```yaml
aks:

  cluster_name: aks-cluster
  location: westeurope
  resource_group_name: example-resources
  kubernetes_version: 1.26.6
  sku_tier: Free
  automatic_channel_upgrade: patch

  network:
    dns_prefix: foo-test
    network_plugin: azure
    service_cidr: 192.21.0.0/16
    dns_service_ip: 192.21.1.10
    subnet:
      subnet_name: default
      vnet_name: vnet4
      vnet_name_resource_group: example-resources

  identity:
    azure_policy_enabled: true
    workload_identity_enabled: true
    oidc_issuer_enabled: true
    identity_type: SystemAssigned

  default_node_pool:
    name: defaultnp
    enable_auto_scaling: true
    min_count: 1
    max_count: 2
    node_count: 1
    vm_size: Standard_F8s_v2
    os_disk_type: Managed
    os_disk_size_gb: 30
    max_pods: 110

  key_vault_secrets:
    key_vault_secrets_provider_enabled: true
    key_vault_secrets_provider_interval: 2m

  tags:
    environment: dev
    costcenter: it
    project: aks
    owner: me

  extra_node_pools: {} # Without additional node pools
```

## Output

```output
######################
####      AKS     ####
######################

AKS Cluster Name:   aks-cluster
AKS Location:       westeurope
AKS Resource Group: example-resources
AKS Cluster ID:     /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.ContainerService/managedClusters/aks-cluster   
AKS Kubernetes Version:   1.26.6
AKS Azure Policy Enabled: true
AKS Auto Upgrade Channel: patch
AKS SKU Tier:             Free

AKS Workload Identity Enabled: true
AKS OIDC Issuer Enabled:       true
AKS Identity Type:             SystemAssigned

AKS DNS Prefix:     foo-test
AKS Network Plugin: azure
AKS Service CIDR:   192.21.0.0/16
AKS DNS Service IP: 192.21.1.10

AKS Default Node Pool Name:            defaultnp
AKS Default Node Pool Node Count:      1
AKS Default Node Pool VM Size:         Standard_F8s_v2
AKS Default Node Pool OS Disk Type:    Managed
AKS Default Node Pool OS Disk Size GB: 30
AKS Default Node Pool Max Pods:        110

AKS Key Vault Secrets Provider Enabled:  true
AKS Key Vault Secrets Provider Interval: 2m

Tags: {"costcenter":"it","environment":"dev","owner":"me","project":"aks"}

############################
#### Extra node Pool(s) ####
############################

- Node Pool 'np1':
  - ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.ContainerService/managedClusters/aks-cluster/agentPools/np1  - VM Size: Standard_F8s_v2
  - Node Count: 1
  - Min Count: 1
  - Max Count: 2
  - OS Disk Type: Managed
  - OS Disk Size GB: 30
  - Max Pods: 110
  - Auto Scaling Enabled: false
  - Tags: {"costcenter":"it","environment":"dev","owner":"me","project":"aks"}
  - Node Labels: {"nodepool":"np1"}

- Node Pool 'np2':
  - ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.ContainerService/managedClusters/aks-cluster/agentPools/np2  - VM Size: Standard_F8s_v2
  - Node Count: 1
  - Min Count: 1
  - Max Count: 2
  - OS Disk Type: Managed
  - OS Disk Size GB: 30
  - Max Pods: 110
  - Auto Scaling Enabled: true
  - Tags: {"costcenter":"it","environment":"dev","owner":"me","project":"aks"}
  - Node Labels: {"nodepool":"np2"}


######################
####  VNET (DATA) ####
######################

AKS Subnet Name:         default
AKS VNET Name:           vnet4
AKS VNET Resource Group: example-resources
AKS Subnet ID:           /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet4/subnets/default
```
