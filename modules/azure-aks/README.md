<!-- BEGIN_TF_DOCS -->
# **Azure AKS Terraform Module**

## Overview

This module enables you to provision and manage Azure Kubernetes Service (AKS) clusters on Microsoft Azure using Terraform. It is designed for both simple and complex scenarios, making it suitable for production environments as well as development and testing setups. By leveraging the official AKS module, it ensures compatibility with the latest Azure features and best practices.

This module provisions an **AKS cluster on Azure**, including:

- AKS cluster
- Node pools (including extra pools)
- Autoscaling profile
- Azure Container Registry (ACR) integration
- Network configuration (VNet/Subnet)
- Optional public IP assignment

With this module, you can easily configure core AKS resources such as the cluster itself, node pools (including multiple and custom pools), and network integration with existing or new VNets and subnets. It also supports advanced options like autoscaling profiles, Azure Container Registry (ACR) integration, OIDC, Workload Identity, and security settings, allowing you to tailor the deployment to your organization’s needs.

To get started, add the module to your Terraform configuration and provide the required variables, such as resource group, location, and network details. You can further customize the deployment by specifying additional options for node pools, autoscaling, and integrations. Refer to the minimal example below for a quick start, and explore the examples directory for more advanced scenarios.

## Key Features

- **AKS Cluster & Node Pools**: Creates a managed AKS cluster and allows custom node pool definitions.
- **Autoscaling**: Supports autoscaling profiles and advanced node pool configuration.
- **ACR Integration**: Allows associating one or more Azure Container Registries to the cluster.
- **Flexible Networking**: Selection of existing VNet and Subnet.
- **Advanced Configuration**: Supports OIDC, Workload Identity, security profiles, and more.

## Infrastructure Prerequisites

- Resource group created
- Subnet created (VNet)
- ACR(s) (optional)
- If you set a Public IP, you need to create a public IP resource

For more details, see the [Terraform AKS module documentation](https://registry.terraform.io/modules/Azure/aks/azurerm/latest).

> **Note:**
> The following values are not configurable:
> - `log_analytics_workspace_enabled`: `false`
> - `rbac_aad_azure_rbac_enabled`: `true`
> - `rbac_aad_managed`: `true`
> - `role_based_access_control_enabled`: `true`

It is designed to be flexible, production-ready, and easy to integrate into existing infrastructures.

## Basic Usage

### Minimal Example

```hcl
module "azure_aks" {
	source                  = "github.com/prefapp/tfm/modules/azure-aks"
	location                = "westeurope"
	resource_group_name     = "example-rg"
	vnet_name               = "example-vnet"
	vnet_resource_group_name = "example-rg"
	subnet_name             = "example-subnet"
	aks_prefix              = "example"
	aks_kubernetes_version  = "1.28.3"
	aks_agents_count        = 2
	aks_agents_size         = "Standard_DS2_v2"
	aks_agents_pool_name    = "default"
	aks_agents_max_pods     = 30
	aks_agents_pool_max_surge = "33%"
	aks_sku_tier            = "Free"
	aks_network_plugin      = "azure"
	aks_network_policy      = "azure"
	aks_orchestrator_version = "1.28.3"
	aks_os_disk_size_gb     = 30
	oidc_issuer_enabled     = true
	workload_identity_enabled = true
	key_vault_secrets_provider_enabled = true
	secret_rotation_enabled = false
	public_ip_name          = "example-public-ip"
	tags                    = { environment = "dev" }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks"></a> [aks](#module\_aks) | github.com/Azure/terraform-azurerm-aks | 9.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.role_assignment_network_contributor_over_public_ip_aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_public_ip.aks_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.aks_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_map"></a> [acr\_map](#input\_acr\_map) | The map of Azure Container Registries to link to the AKS cluster | `map(string)` | `{}` | no |
| <a name="input_aks_agents_count"></a> [aks\_agents\_count](#input\_aks\_agents\_count) | The number of agents in the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_agents_max_pods"></a> [aks\_agents\_max\_pods](#input\_aks\_agents\_max\_pods) | The maximum number of pods that can run on an agent | `any` | n/a | yes |
| <a name="input_aks_agents_pool_drain_timeout_in_minutes"></a> [aks\_agents\_pool\_drain\_timeout\_in\_minutes](#input\_aks\_agents\_pool\_drain\_timeout\_in\_minutes) | The maximum time in minutes to wait for a node to drain during a node pool upgrade | `number` | `30` | no |
| <a name="input_aks_agents_pool_max_surge"></a> [aks\_agents\_pool\_max\_surge](#input\_aks\_agents\_pool\_max\_surge) | The maximum number of agents that can be added to the agent pool during an upgrade | `any` | n/a | yes |
| <a name="input_aks_agents_pool_name"></a> [aks\_agents\_pool\_name](#input\_aks\_agents\_pool\_name) | The name of the agent pool | `any` | n/a | yes |
| <a name="input_aks_agents_size"></a> [aks\_agents\_size](#input\_aks\_agents\_size) | The size of the agents in the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_default_pool_custom_labels"></a> [aks\_default\_pool\_custom\_labels](#input\_aks\_default\_pool\_custom\_labels) | Default pool custom labels to apply to all nodes | `map(any)` | `{}` | no |
| <a name="input_aks_kubernetes_version"></a> [aks\_kubernetes\_version](#input\_aks\_kubernetes\_version) | The version of Kubernetes to use for the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_network_plugin"></a> [aks\_network\_plugin](#input\_aks\_network\_plugin) | The network plugin to use for networking in the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_network_policy"></a> [aks\_network\_policy](#input\_aks\_network\_policy) | The network policy to use for networking in the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_orchestrator_version"></a> [aks\_orchestrator\_version](#input\_aks\_orchestrator\_version) | The version of Kubernetes to use for the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_os_disk_size_gb"></a> [aks\_os\_disk\_size\_gb](#input\_aks\_os\_disk\_size\_gb) | The size of the OS disk in GB | `any` | n/a | yes |
| <a name="input_aks_prefix"></a> [aks\_prefix](#input\_aks\_prefix) | The prefix for all resources in this example | `any` | n/a | yes |
| <a name="input_aks_sku_tier"></a> [aks\_sku\_tier](#input\_aks\_sku\_tier) | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium | `any` | n/a | yes |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | The IP ranges authorized to access the AKS API server | `list(string)` | `null` | no |
| <a name="input_auto_scaler_profile_enabled"></a> [auto\_scaler\_profile\_enabled](#input\_auto\_scaler\_profile\_enabled) | Whether to enable the auto scaler profile | `bool` | `false` | no |
| <a name="input_auto_scaler_profile_expander"></a> [auto\_scaler\_profile\_expander](#input\_auto\_scaler\_profile\_expander) | The expander to use for the auto scaler profile | `string` | `"random"` | no |
| <a name="input_auto_scaler_profile_max_graceful_termination_sec"></a> [auto\_scaler\_profile\_max\_graceful\_termination\_sec](#input\_auto\_scaler\_profile\_max\_graceful\_termination\_sec) | The maximum graceful termination time in seconds for the auto scaler profile | `number` | `600` | no |
| <a name="input_auto_scaler_profile_max_node_provisioning_time"></a> [auto\_scaler\_profile\_max\_node\_provisioning\_time](#input\_auto\_scaler\_profile\_max\_node\_provisioning\_time) | The maximum node provisioning time in seconds for the auto scaler profile | `string` | `15` | no |
| <a name="input_auto_scaler_profile_max_unready_nodes"></a> [auto\_scaler\_profile\_max\_unready\_nodes](#input\_auto\_scaler\_profile\_max\_unready\_nodes) | The maximum number of unready nodes for the auto scaler profile | `number` | `0` | no |
| <a name="input_auto_scaler_profile_max_unready_percentage"></a> [auto\_scaler\_profile\_max\_unready\_percentage](#input\_auto\_scaler\_profile\_max\_unready\_percentage) | The maximum percentage of unready nodes for the auto scaler profile | `number` | `0` | no |
| <a name="input_auto_scaler_profile_new_pod_scale_up_delay"></a> [auto\_scaler\_profile\_new\_pod\_scale\_up\_delay](#input\_auto\_scaler\_profile\_new\_pod\_scale\_up\_delay) | The new pod scale up delay in seconds for the auto scaler profile | `string` | `0` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_add"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_add](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_add) | The scale down delay after add in seconds for the auto scaler profile | `string` | `10` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_delete"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_delete](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_delete) | The scale down delay after delete in seconds for the auto scaler profile | `string` | `10` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_failure"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_failure](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_failure) | The scale down delay after failure in seconds for the auto scaler profile | `string` | `3` | no |
| <a name="input_auto_scaler_profile_scale_down_unneeded"></a> [auto\_scaler\_profile\_scale\_down\_unneeded](#input\_auto\_scaler\_profile\_scale\_down\_unneeded) | The scale down unneeded for the auto scaler profile | `string` | `0` | no |
| <a name="input_auto_scaler_profile_scale_down_unready"></a> [auto\_scaler\_profile\_scale\_down\_unready](#input\_auto\_scaler\_profile\_scale\_down\_unready) | The scale down unready for the auto scaler profile | `string` | `0` | no |
| <a name="input_auto_scaler_profile_scale_down_utilization_threshold"></a> [auto\_scaler\_profile\_scale\_down\_utilization\_threshold](#input\_auto\_scaler\_profile\_scale\_down\_utilization\_threshold) | The scale down utilization threshold for the auto scaler profile | `number` | `0.5` | no |
| <a name="input_auto_scaler_profile_scan_interval"></a> [auto\_scaler\_profile\_scan\_interval](#input\_auto\_scaler\_profile\_scan\_interval) | The scan interval for the auto scaler profile | `string` | `10` | no |
| <a name="input_auto_scaler_profile_skip_nodes_with_local_storage"></a> [auto\_scaler\_profile\_skip\_nodes\_with\_local\_storage](#input\_auto\_scaler\_profile\_skip\_nodes\_with\_local\_storage) | Whether to skip nodes with local storage for the auto scaler profile | `bool` | `false` | no |
| <a name="input_auto_scaler_profile_skip_nodes_with_system_pods"></a> [auto\_scaler\_profile\_skip\_nodes\_with\_system\_pods](#input\_auto\_scaler\_profile\_skip\_nodes\_with\_system\_pods) | Whether to skip nodes with system pods for the auto scaler profile | `bool` | `false` | no |
| <a name="input_create_role_assignment_public_ip"></a> [create\_role\_assignment\_public\_ip](#input\_create\_role\_assignment\_public\_ip) | Boolean value to create a role assignment for the public IP | `bool` | `false` | no |
| <a name="input_extra_node_pools"></a> [extra\_node\_pools](#input\_extra\_node\_pools) | A list of extra node pools to create | <pre>list(object({<br/>    name                  = string<br/>    pool_name             = string<br/>    vm_size               = string<br/>    node_count            = optional(number, 1)<br/>    create_before_destroy = optional(bool, true)<br/>    enable_auto_scaling   = optional(bool, false)<br/>    min_count             = optional(number, null)<br/>    max_count             = optional(number, null)<br/>    max_pod_per_node      = optional(number, 110)<br/>    os_disk_type          = optional(string, "Ephemeral")<br/>    mode                  = optional(string, "User")<br/>    custom_labels         = map(string)<br/>    orchestrator_version  = optional(string, "")<br/>    upgrade_settings = optional(object({<br/>      drain_timeout_in_minutes      = number<br/>      node_soak_duration_in_minutes = number<br/>      max_surge                     = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | Boolean value to activate the csi-secrets-store-driver | `any` | n/a | yes |
| <a name="input_load_balancer_profile_enabled"></a> [load\_balancer\_profile\_enabled](#input\_load\_balancer\_profile\_enabled) | Value to enable or not the load balancer profile | `bool` | `true` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | Load balancer sku (basic or standard) | `string` | `"standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where all resources in this example should be created | `any` | n/a | yes |
| <a name="input_node_os_channel_upgrade"></a> [node\_os\_channel\_upgrade](#input\_node\_os\_channel\_upgrade) | The automatic node channel upgrade setting for the AKS cluster | `string` | `"None"` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Whether to enable OIDC Issuer for the AKS cluster | `any` | n/a | yes |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | The name of the public IP address to use for the AKS cluster | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the resources | `any` | n/a | yes |
| <a name="input_secret_rotation_enabled"></a> [secret\_rotation\_enabled](#input\_secret\_rotation\_enabled) | Boolean value to activate the secrets rotation csi-secrets-store-driver | `any` | n/a | yes |
| <a name="input_secret_rotation_interval"></a> [secret\_rotation\_interval](#input\_secret\_rotation\_interval) | String value to activate the secrets rotation interval csi-secrets-store-driver | `any` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet to use for the AKS cluster | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_temporary_name_for_rotation"></a> [temporary\_name\_for\_rotation](#input\_temporary\_name\_for\_rotation) | Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing | `string` | `"temppool"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the virtual network where the subnet is located | `any` | n/a | yes |
| <a name="input_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#input\_vnet\_resource\_group\_name) | The name of the resource group in which the virtual network is located | `any` | n/a | yes |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Whether to enable Workload Identity for the AKS cluster | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id) | The ID of the AKS cluster. Example: `/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxx-common-predev/providers/Microsoft.ContainerService/managedClusters/xxxx-predev-aks` |
| <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name) | The name of the AKS cluster. Example: `xxxx-predev-aks` |
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | The FQDN of the AKS cluster. Example: `xxxx-predev-xxxxxxxx.hcp.westeurope.azmk8s.io` |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | The cluster identity of the AKS cluster. See README for structure. |
| <a name="output_cluster_issuer"></a> [cluster\_issuer](#output\_cluster\_issuer) | The OIDC issuer URL of the AKS cluster. |
| <a name="output_kubelet_identity_client_id"></a> [kubelet\_identity\_client\_id](#output\_kubelet\_identity\_client\_id) | The kubelet identity of the AKS cluster. See README for structure. |
| <a name="output_kubelet_identity_object_id"></a> [kubelet\_identity\_object\_id](#output\_kubelet\_identity\_object\_id) | The network profile of the AKS cluster. See README for structure. |
| <a name="output_network_profile"></a> [network\_profile](#output\_network\_profile) | The node resource group of the AKS cluster. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The OIDC issuer URL of the AKS cluster. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | The outbound IP address of the AKS cluster. |
| <a name="output_outbound_ip_address"></a> [outbound\_ip\_address](#output\_outbound\_ip\_address) | The outbound IP address of the AKS cluster. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The subnet ID of the AKS cluster. |
| <a name="output_vnet"></a> [vnet](#output\_vnet) | The virtual network name of the AKS cluster. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples/basic) – Minimal AKS cluster deployment
- [With VNet](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples/with\_vnet) – AKS cluster using a custom VNet/Subnet
- [Extra node pools](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples/extra\_node\_pools) – AKS with additional node pools
- [Autoscaling](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples/autoscaling) – AKS with autoscaler profile enabled

### Example .tfvars

```yaml
# Example variables for AKS module
location: "westeurope"
resource_group_name: "my-rg"
tags_from_rg: false
tags:
	application: "common"
	env: "predev"
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
extra_node_pools :
	- name: "foo"
		pool_name: "captpre"
		vm_size: "Standard_F8s_v2"
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
		enable_auto_scaling: true
		min_count: 2
		max_count: 20
		max_pod_per_node: 110
		os_disk_type: "Managed"
		custom_labels:
			nodepool-group: "bar"
subnet_name: "internal"
vnet_name: "spoke-common-predev-vnet"
vnet_resource_group_name: "my-rg"
public_ip_name: "my-output-aks-public-ip"
aks_network_profile: "foo"
acr_map:
	acrxxx: "/xxx/xxx/xxx"
	acryyy: "/yyy/yyy/yyy"
oidc_issuer_enabled: "true"
workload_identity_enabled: "true"
```

## Remote resources
 - Terraform: https://www.terraform.io/
 - Azure Kubernetes Service: https://azure.microsoft.com/en-us/services/kubernetes-service/
 - Terraform Azure Provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest
 - Azure Container Registry: https://azure.microsoft.com/en-us/services/container-registry/

## Support

For issues, questions, or contributions related to this module, please visit the [repository’s issue tracker](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->
