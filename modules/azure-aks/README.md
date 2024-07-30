# Azure aks module

## Overview

This module uses the official AKS module and allows you to create an AKS with some configurations like creating extra node groups, active and define node autoscaling profile or attaching acrs..

## Requirements

- Resource group created.
- Subnet created (VNet).
- ACR/s (optional).

## DOC

- [Resource terraform - AKS module](https://registry.terraform.io/modules/Azure/aks/azurerm/latest).

## Usage

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-aks?ref=<version/tag/commit/branch>"
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

```yaml
---
# Global variables
location: "westeurope"
resource_group_name: "my-rg"
tags:
  application: "common"
  env: "predev"
# AKS variables
# aks_agents_count: "1" | not needed when enable_auto_scaling is true
aks_agents_count: "2"
aks_agents_max_pods: "110"
aks_agents_pool_max_surge: "10%"
aks_agents_pool_name: "myng"
aks_agents_size: "Standard_D8as_v5"
aks_node_os_channel_upgrade: "None"
aks_kubernetes_version: "1.28.10"
aks_network_plugin: "azure"
aks_network_policy: "azure"
aks_orchestrator_version: "1.28.10"
aks_os_disk_size_gb: "256"
aks_prefix: "predev"
aks_sku_tier: "Free"
key_vault_secrets_provider_enabled: true
secret_rotation_enabled: true
secret_rotation_interval: 30s
aks_default_pool_custom_labels:
  nodepool-group: "myng"

# AKS autoscaler variables
auto_scaler_profile_enabled: true
auto_scaler_profile_expander: "least-waste"
auto_scaler_profile_max_graceful_termination_sec: "1800"
auto_scaler_profile_max_node_provisioning_time: "15m"
auto_scaler_profile_max_unready_nodes: 2
auto_scaler_profile_max_unready_percentage: 10
auto_scaler_profile_new_pod_scale_up_delay: "10s"
auto_scaler_profile_scale_down_delay_after_add: "15m"
auto_scaler_profile_scale_down_delay_after_delete: "10s"
auto_scaler_profile_scale_down_delay_after_failure: "3m"
auto_scaler_profile_scale_down_unneeded: "5m"
auto_scaler_profile_scale_down_unready: "15m"
auto_scaler_profile_scale_down_utilization_threshold: "0.7"
auto_scaler_profile_scan_interval: "10s"
auto_scaler_profile_skip_nodes_with_local_storage: false
auto_scaler_profile_skip_nodes_with_system_pods: false

# Extra node pools
extra_node_pools :
  - name: "foo"
    pool_name: "captpre"
    vm_size: "Standard_F8s_v2"
    # node_count: "1"
    enable_auto_scaling: true
    max_count: 5
    min_count: 2
    max_pod_per_node: 30
    os_disk_type: "Managed"
    custom_labels:
      nodepool-group: "foo"
  - name: "bar"
    pool_name: "genhpa"
    vm_size: "Standard_D4as_v5"
    # node_count: "1"
    enable_auto_scaling: true
    min_count: 2
    max_count: 20
    max_pod_per_node: 110
    os_disk_type: "Managed"
    custom_labels:
      nodepool-group: "bar"

# Network variables
subnet_name: "internal"
vnet_name: "spoke-common-predev-vnet"
vnet_resource_group_name: "my-rg"
public_ip_name: "my-output-aks-public-ip"
aks_network_profile: "foo"

# ACR variable
acr_map:
  acrxxx: "/xxx/xxx/xxx"
  acryyy: "/yyy/yyy/yyy"

# Access control variables
oidc_issuer_enabled: "true"
workload_identity_enabled: "true"
```
