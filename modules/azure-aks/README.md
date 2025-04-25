# Azure aks module

## Overview

This module uses the official AKS module and allows you to create an AKS with some configurations like creating extra node groups, active and define node autoscaling profile or attaching acrs..

## Requirements

- Resource group created.
- Subnet created (VNet).
- ACR/s (optional).
- If you set a Public IP, you need to create a public IP resource.

## DOC

- [Resource terraform - AKS module](https://registry.terraform.io/modules/Azure/aks/azurerm/latest).

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

## Note

The following values are not configurable:

- `log_analytics_workspace_enabled`: `false`
- `rbac_aad_azure_rbac_enabled`: `true`
- `rbac_aad_managed`: `true`
- `role_based_access_control_enabled`: `true`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_agents_count"></a> [aks\_agents\_count](#input\_aks\__agents\_count) | The number of Agents that should exist in the Agent Pool. Please set `aks_agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `aks_agents_count` changes. | `number` | `2` | no |
| <a name="input_aks_default_pool_custom_labels"></a> [aks\_agents\_labels](#input\_aks\_agents\_labels) | (Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created. | `map(string)` | `{}` | no |
| <a name="input_agents_aks_max_pods"></a> [aks\_agents\_max\_pods](#input\_aks\_agents\_max\_pods) | (Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created. | `number` | `null` | no |
| <a name="input_aks_agents_pool_drain_timeout_in_minutes"></a> [aks\_agents\_pool\_drain\_timeout\_in\_minutes](#input\_aks\_agents\_pool\_drain\_timeout\_in\_minutes) | (Optional) The amount of time in minutes to wait on eviction of pods and graceful termination per node. This eviction wait time honors waiting on pod disruption budgets. If this time is exceeded, the upgrade fails. Unsetting this after configuring it will force a new resource to be created. | `number` | `null` | no |
| <a name="input_aks_agents_pool_max_surge"></a> [aks\_agents\_pool\_max\_surge](#input\_aks\_agents\_pool\_max\_surge) | The maximum number or percentage of nodes which will be added to the Default Node Pool size during an upgrade. | `string` | `"10%"` | no |
| <a name="input_aks_agents_pool_name"></a> [aks\_agents\_pool\_name](#input\_aks\_agents\_pool\_name) | The default Azure AKS agentpool (nodepool) name. | `string` | `"nodepool"` | no |
| <a name="input_aks_agents_size"></a> [aks\_agents\_size](#input\_aks\_agents\_size) | The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | (Optional) The IP ranges to allow for incoming traffic to the server nodes. | `set(string)` | `null` | no |
| <a name="input_attached_acr_id_map"></a> [attached\_acr\_id\_map](#input\_attached\_acr\_id\_map) | Azure Container Registry ids that need an authentication mechanism with Azure Kubernetes Service (AKS). Map key must be static string as acr's name, the value is acr's resource id. Changing this forces some new resources to be created. | `map(string)` | `{}` | no |
| <a name="input_auto_scaler_profile_enabled"></a> [auto\_scaler\_profile\_enabled](#input\_auto\_scaler\_profile\_enabled) | Enable configuring the auto scaler profile | `bool` | `false` | no |
| <a name="input_auto_scaler_profile_expander"></a> [auto\_scaler\_profile\_expander](#input\_auto\_scaler\_profile\_expander) | Expander to use. Possible values are `least-waste`, `priority`, `most-pods` and `random`. Defaults to `random`. | `string` | `"random"` | no |
| <a name="input_auto_scaler_profile_max_graceful_termination_sec"></a> [auto\_scaler\_profile\_max\_graceful\_termination\_sec](#input\_auto\_scaler\_profile\_max\_graceful\_termination\_sec) | Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. Defaults to `600`. | `string` | `"600"` | no |
| <a name="input_auto_scaler_profile_max_node_provisioning_time"></a> [auto\_scaler\_profile\_max\_node\_provisioning\_time](#input\_auto\_scaler\_profile\_max\_node\_provisioning\_time) | Maximum time the autoscaler waits for a node to be provisioned. Defaults to `15m`. | `string` | `"15m"` | no |
| <a name="input_auto_scaler_profile_max_unready_nodes"></a> [auto\_scaler\_profile\_max\_unready\_nodes](#input\_auto\_scaler\_profile\_max\_unready\_nodes) | Maximum Number of allowed unready nodes. Defaults to `3`. | `number` | `3` | no |
| <a name="input_auto_scaler_profile_max_unready_percentage"></a> [auto\_scaler\_profile\_max\_unready\_percentage](#input\_auto\_scaler\_profile\_max\_unready\_percentage) | Maximum percentage of unready nodes the cluster autoscaler will stop if the percentage is exceeded. Defaults to `45`. | `number` | `45` | no |
| <a name="input_auto_scaler_profile_new_pod_scale_up_delay"></a> [auto\_scaler\_profile\_new\_pod\_scale\_up\_delay](#input\_auto\_scaler\_profile\_new\_pod\_scale\_up\_delay) | For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. Defaults to `10s`. | `string` | `"10s"` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_add"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_add](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_add) | How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to `10m`. | `string` | `"10m"` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_delete"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_delete](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_delete) | How long after node deletion that scale down evaluation resumes. Defaults to the value used for `scan_interval`. | `string` | `null` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_failure"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_failure](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_failure) | How long after scale down failure that scale down evaluation resumes. Defaults to `3m`. | `string` | `"3m"` | no |
| <a name="input_auto_scaler_profile_scale_down_unneeded"></a> [auto\_scaler\_profile\_scale\_down\_unneeded](#input\_auto\_scaler\_profile\_scale\_down\_unneeded) | How long a node should be unneeded before it is eligible for scale down. Defaults to `10m`. | `string` | `"10m"` | no |
| <a name="input_auto_scaler_profile_scale_down_unready"></a> [auto\_scaler\_profile\_scale\_down\_unready](#input\_auto\_scaler\_profile\_scale\_down\_unready) | How long an unready node should be unneeded before it is eligible for scale down. Defaults to `20m`. | `string` | `"20m"` | no |
| <a name="input_auto_scaler_profile_scale_down_utilization_threshold"></a> [auto\_scaler\_profile\_scale\_down\_utilization\_threshold](#input\_auto\_scaler\_profile\_scale\_down\_utilization\_threshold) | Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to `0.5`. | `string` | `"0.5"` | no |
| <a name="input_auto_scaler_profile_scan_interval"></a> [auto\_scaler\_profile\_scan\_interval](#input\_auto\_scaler\_profile\_scan\_interval) | How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to `10s`. | `string` | `"10s"` | no |
| <a name="input_auto_scaler_profile_skip_nodes_with_local_storage"></a> [auto\_scaler\_profile\_skip\_nodes\_with\_local\_storage](#input\_auto\_scaler\_profile\_skip\_nodes\_with\_local\_storage) | If `true` cluster autoscaler will never delete nodes with pods with local storage, for example, EmptyDir or HostPath. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_auto_scaler_profile_skip_nodes_with_system_pods"></a> [auto\_scaler\_profile\_skip\_nodes\_with\_system\_pods](#input\_auto\_scaler\_profile\_skip\_nodes\_with\_system\_pods) | If `true` cluster autoscaler will never delete nodes with pods from kube-system (except for DaemonSet or mirror pods). Defaults to `true`. | `bool` | `true` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | (Optional) Whether to use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster. For more details: https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver | `bool` | `false` | no |
| <a name="input_aks_kubernetes_version"></a> [aks\_kubernetes\_version](#input\_aks\_kubernetes\_version) | Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region | `string` | `null` | no |
| <a name="input_load_balancer_profile_enabled"></a> [load\_balancer\_profile\_enabled](#input\_load\_balancer\_profile\_enabled) | (Optional) Enable a load\_balancer\_profile block. This can only be used when load\_balancer\_sku is set to `standard`. | `bool` | `false` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | (Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`. Defaults to `standard`. Changing this forces a new kubernetes cluster to be created. | `string` | `"standard"` | no |
| <a name="input_aks_network_plugin"></a> [aks\_network\_plugin](#input\_aks\_network\_plugin) | Network plugin to use for networking. | `string` | `"kubenet"` | no |
| <a name="input_aks_network_policy"></a> [aks\_network\_policy](#input\_aks\_network\_policy) | (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_node_os_channel_upgrade"></a> [node\_os\_channel\_upgrade](#input\_node\_os\_channel\_upgrade) | (Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`. | `string` | `null` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Enable or Disable the OIDC issuer URL. Defaults to false. | `bool` | `false` | no |
| <a name="input_aks_orchestrator_version"></a> [aks\_orchestrator\_version](#input\_aks\_orchestrator\_version) | Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region | `string` | `null` | no |
| <a name="input_aks_os_disk_size_gb"></a> [aks\_os\_disk\_size\_gb](#input\_aks\_os\_disk\_size\_gb) | Disk size of nodes in GBs. | `number` | `50` | no |
| <a name="input_aks_prefix"></a> [aks\_prefix](#input\_aks\_prefix) | (Optional) The prefix for the resources created in the specified Azure Resource Group. Omitting this variable requires both `var.cluster_log_analytics_workspace_name` and `var.cluster_name` have been set. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name to be imported | `string` | n/a | yes |
| <a name="input_secret_rotation_enabled"></a> [secret\_rotation\_enabled](#input\_secret\_rotation\_enabled) | Is secret rotation enabled? This variable is only used when `key_vault_secrets_provider_enabled` is `true` and defaults to `false` | `bool` | `false` | no |
| <a name="input_secret_rotation_interval"></a> [secret\_rotation\_interval](#input\_secret\_rotation\_interval) | The interval to poll for secret rotation. This attribute is only set when `secret_rotation` is `true` and defaults to `2m` | `string` | `"2m"` | no |
| <a name="input_aks_sku_tier"></a> [aks\_sku\_tier](#input\_aks\_sku\_tier) | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are `Free`, `Standard` and `Premium` | `string` | `"Free"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Any tags that should be present on the AKS cluster resources | `map(string)` | `{}` | no |
| <a name="input_temporary_name_for_rotation"></a> [temporary\_name\_for\_rotation](#input\_temporary\_name\_for\_rotation) | (Optional) Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing. the `var.agents_size` is no longer ForceNew and can be resized by specifying `temporary_name_for_rotation` | `string` | `null` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Enable or Disable Workload Identity. Defaults to false. | `bool` | `false` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet to be used for the AKS cluster. | `string` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the virtual network to be used for the AKS cluster. | `string` | n/a | yes |
| <a name="input_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#input\_vnet\_resource\_group\_name) | The name of the resource group where the virtual network is located. | `string` | n/a | yes |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | The name of the public IP to be used for the AKS cluster. | `string` | n/a | yes |
| <a name="input_create_role_assignment_public_ip"></a> [create\_role\_assignment\_public\_ip](#input\_create\_role\_assignment\_public\_ip) | Whether to create a role assignment for the public IP. | `bool` | `false` | no |
| <a name="input_extra_node_pools"></a> [extra\_node\_pools](#input\_extra\_node\_pools) | (Optional) A list of maps defining additional node pools. Each map should contain the following keys: `name` (Required) The name of the node pool, `pool_name` (Required) The name of the pool, `vm_size` (Required) The size of the virtual machine, `node_count` (Optional) The number of nodes in the pool, `enable_auto_scaling` (Optional) Whether to enable auto-scaling for the node pool, `max_count` (Optional) The maximum number of nodes for auto-scaling, `min_count` (Optional) The minimum number of nodes for auto-scaling, `max_pod_per_node` (Optional) The maximum number of pods per node, `os_disk_type` (Optional) The type of OS disk, `custom_labels` (Optional) A map of custom labels to apply to the nodes, `create_before_destroy` (Optional) Whether to create the new node pool before destroying the old one, `mode` (Optional) The mode of the node pool, `orchestrator_version` (Optional) The orchestrator version for the node pool, `upgrade_settings` (Optional) Settings for upgrading the node pool. | `list(map(string))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_id"></a> [aks\_id](#output_aks_id) | The ID of the AKS cluster. |
| <a name="output_aks_name"></a> [aks\_name](#output_aks_name) | The name of the AKS cluster. |
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output_cluster_fqdn) | The FQDN of the AKS cluster. |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output_cluster_identity) | The cluster identity of the AKS cluster. |
| <a name="output_cluster_issuer"></a> [cluster\_issuer](#output_cluster_issuer) | The OIDC issuer URL of the AKS cluster. |
| <a name="output_kubelet_identity_client_id"></a> [kubelet\_identity](#output_kubelet_identity) | The client ID of the kubelet identity of the AKS cluster. |
| <a name="output_kubelet_identity_object_id"></a> [kubelet\_identity](#output_kubelet_identity) | The object ID of the kubelet identity of the AKS cluster. |
| <a name="output_network_profile"></a> [network\_profile](#output_network_profile) | The network profile of the AKS cluster. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output_node_resource_group) | The node resource group of the AKS cluster. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output_oidc_issuer_url) | The OIDC issuer URL of the AKS cluster. |
| <a name="output_outbound_ip_address"></a> [outbound\_ip\_address](#output_outbound_ip_address) | The outbound IP address of the AKS cluster. |
| <a name="output_subnet_id"></a> [subnet\_id](#output_subnet_id) | The subnet ID of the AKS cluster. |
| <a name="output_vnet"></a> [vnet](#output_vnet) | The virtual network name of the AKS cluster. |

### Explanation description of the outputs

### Explanation description of the outputs

- **aks_id**: The ID of the AKS cluster. Example: `/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxx-common-predev/providers/Microsoft.ContainerService/managedClusters/xxxx-predev-aks` (string)
- **aks_name**: The name of the AKS cluster. Example: `xxxx-predev-aks` (string)
- **cluster_fqdn**: The FQDN of the AKS cluster. Example: `xxxx-predev-xxxxxxxx.hcp.westeurope.azmk8s.io` (string)
- **cluster_identity**: The cluster identity of the AKS cluster. This is a complex object with the following fields:
  - **identity_ids**: A set of identity IDs. (set of strings)
  - **principal_id**: The principal ID of the cluster identity. (string)
  - **tenant_id**: The tenant ID of the cluster identity. (string)
  - **type**: The type of the cluster identity. Example: `SystemAssigned` (string)
- **cluster_issuer**: The OIDC issuer URL of the AKS cluster. Example: `https://westeurope.oic.prod-aks.azure.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/` (string)
- **kubelet_identity**: The kubelet identity of the AKS cluster. This is a list of objects with the following fields:
  - **client_id**: The client ID of the kubelet identity. (string)
  - **object_id**: The object ID of the kubelet identity. (string)
  - **user_assigned_identity_id**: The user-assigned identity ID of the kubelet identity. (string)
- **network_profile**: The network profile of the AKS cluster. This is a list of objects with the following fields:
  - **dns_service_ip**: The DNS service IP. (string)
  - **docker_bridge_cidr**: The Docker bridge CIDR. (string)
  - **ebpf_data_plane**: The eBPF data plane. (string)
  - **ip_versions**: A list of IP versions. (list of strings)
  - **load_balancer_profile**: A list of load balancer profiles with the following fields:
    - **effective_outbound_ips**: A set of effective outbound IPs. (set of strings)
    - **idle_timeout_in_minutes**: The idle timeout in minutes. (number)
    - **managed_outbound_ip_count**: The managed outbound IP count. (number)
    - **managed_outbound_ipv6_count**: The managed outbound IPv6 count. (number)
    - **outbound_ip_address_ids**: A set of outbound IP address IDs. (set of strings)
    - **outbound_ip_prefix_ids**: A set of outbound IP prefix IDs. (set of strings)
    - **outbound_ports_allocated**: The number of outbound ports allocated. (number)
  - **load_balancer_sku**: The SKU of the load balancer. (string)
  - **nat_gateway_profile**: A list of NAT gateway profiles. (list of objects)
  - **network_data_plane**: The network data plane. (string)
  - **network_mode**: The network mode. (string)
  - **network_plugin**: The network plugin. (string)
  - **network_plugin_mode**: The network plugin mode. (string)
  - **network_policy**: The network policy. (string)
  - **outbound_ip_address_ids**: A set of outbound IP address IDs. (set of strings)
  - **outbound_ip_prefix_ids**: A set of outbound IP prefix IDs. (set of strings)
  - **outbound_type**: The outbound type. (string)
  - **pod_cidr**: The pod CIDR. (string)
  - **pod_cidrs**: A list of pod CIDRs. (list of strings)
  - **service_cidr**: The service CIDR. (string)
  - **service_cidrs**: A list of service CIDRs. (list of strings)

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
