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

For more details, see the [Terraform AKS module documentation](https://registry.terraform.io/modules/Azure/avm-res-containerservice-managedcluster/azurerm/latest).

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
	aks_sku_tier            = "Free"
	aks_sku_name			      = "Base"
	aks_network_plugin      = "azure"
	aks_network_policy      = "azure"
	aks_network_dataplane	= "azure"
	aks_orchestrator_version = "1.28.3"
	oidc_issuer_enabled     = true
	workload_identity_enabled = true
	key_vault_secrets_provider_enabled = true
	secret_rotation_enabled = false
	public_ip_name          = "example-public-ip"
  auto_upgrade_profile {
    node_os_upgrade_channel = "None"
    upgrade_channel         = "none"
  }
	upgrade_settings {
		override_settings {
      force_upgrade = false
      until		      = "2026-09-18T14:30:00Z"
		}
	}
	tags                    = { environment = "dev" }

  default_node_pool {
    name = "default"
    vm_size = "Standard_D8as_v5"
    count_of = 1
    enable_auto_scaling = false
    max_pods = 30
    os_disk_size_gb = 128
    node_labels {
      pool = "default"
    }
    upgrade_settings {
      drain_timeout_in_minutes = 30
      node_soak_duration_in_minutes = 0
      max_surge = "10%"
    }
  }
}
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.1 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0, < 3.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0, < 5.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0, < 5.0.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aks"></a> [aks](#module\_aks) | github.com/Azure/terraform-azurerm-avm-res-containerservice-managedcluster | v0.8.3 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_role_assignment.acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.role_assignment_network_contributor_over_public_ip_aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.role_assignment_network_contributor_over_subnet_aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_public_ip.aks_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.aks_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_acr_map"></a> [acr\_map](#input\_acr\_map) | The map of Azure Container Registries to link to the AKS cluster | `map(string)` | `{}` | no |
| <a name="input_aks_api_version"></a> [aks\_api\_version](#input\_aks\_api\_version) | API version used for the Microsoft.ContainerService/managedClusters resource | `string` | `"2026-01-02-preview"` | no |
| <a name="input_aks_kubernetes_version"></a> [aks\_kubernetes\_version](#input\_aks\_kubernetes\_version) | The version of Kubernetes to use for the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_network_dataplane"></a> [aks\_network\_dataplane](#input\_aks\_network\_dataplane) | The network dataplane to use for the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_network_plugin"></a> [aks\_network\_plugin](#input\_aks\_network\_plugin) | The network plugin to use for networking in the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_network_policy"></a> [aks\_network\_policy](#input\_aks\_network\_policy) | The network policy to use for networking in the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_orchestrator_version"></a> [aks\_orchestrator\_version](#input\_aks\_orchestrator\_version) | The version of Kubernetes to use for the AKS cluster | `any` | n/a | yes |
| <a name="input_aks_prefix"></a> [aks\_prefix](#input\_aks\_prefix) | The prefix for all resources in this example | `any` | n/a | yes |
| <a name="input_aks_sku_name"></a> [aks\_sku\_name](#input\_aks\_sku\_name) | The SKU name that should be used for this Kubernetes Cluster. Possible values are Automatic and Base | `any` | n/a | yes |
| <a name="input_aks_sku_tier"></a> [aks\_sku\_tier](#input\_aks\_sku\_tier) | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium | `any` | n/a | yes |
| <a name="input_aks_upgrade_settings"></a> [aks\_upgrade\_settings](#input\_aks\_upgrade\_settings) | Upgrade settings for the AKS cluster. | <pre>object({<br/>    override_settings = optional(object({<br/>      force_upgrade = optional(bool)<br/>      until         = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | The IP ranges authorized to access the AKS API server | `list(string)` | `null` | no |
| <a name="input_auto_scaler_profile"></a> [auto\_scaler\_profile](#input\_auto\_scaler\_profile) | Configuration for the AKS cluster autoscaler profile | <pre>object({<br/>    balance_similar_node_groups           = optional(string, "false")<br/>    daemonset_eviction_for_empty_nodes    = optional(bool, false)<br/>    daemonset_eviction_for_occupied_nodes = optional(bool, true)<br/>    expander                              = optional(string, "random")<br/>    ignore_daemonsets_utilization         = optional(bool, false)<br/>    max_empty_bulk_delete                 = optional(string, "10")<br/>    max_graceful_termination_sec          = optional(string, "600")<br/>    max_node_provision_time               = optional(string, "15")<br/>    max_total_unready_percentage          = optional(string, "0")<br/>    new_pod_scale_up_delay                = optional(string, "0")<br/>    ok_total_unready_count                = optional(string, "0")<br/>    scale_down_delay_after_add            = optional(string, "10")<br/>    scale_down_delay_after_delete         = optional(string, "10")<br/>    scale_down_delay_after_failure        = optional(string, "3")<br/>    scale_down_unneeded_time              = optional(string, "0")<br/>    scale_down_unready_time               = optional(string, "0")<br/>    scale_down_utilization_threshold      = optional(string, "0.5")<br/>    scan_interval                         = optional(string, "10")<br/>    skip_nodes_with_local_storage         = optional(string, "false")<br/>    skip_nodes_with_system_pods           = optional(string, "false")<br/>  })</pre> | `null` | no |
| <a name="input_auto_upgrade_profile"></a> [auto\_upgrade\_profile](#input\_auto\_upgrade\_profile) | Auto upgrade profile for a managed cluster | <pre>object({<br/>    node_os_upgrade_channel = optional(string, "NodeImage")<br/>    upgrade_channel         = optional(string, "none")<br/>  })</pre> | `null` | no |
| <a name="input_create_role_assignment_public_ip"></a> [create\_role\_assignment\_public\_ip](#input\_create\_role\_assignment\_public\_ip) | Boolean value to create a role assignment for the public IP | `bool` | `false` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Configuration for the default AKS node pool | <pre>object({<br/>    name                = string<br/>    vm_size             = string<br/>    count_of            = number<br/>    max_pods            = number<br/>    os_disk_size_gb     = number<br/>    node_labels         = optional(map(string), {})<br/>    enable_auto_scaling = optional(bool, false)<br/><br/>    upgrade_settings = optional(object({<br/>      drain_timeout_in_minutes      = optional(number, 30)<br/>      node_soak_duration_in_minutes = optional(number, 0)<br/>      max_surge                     = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_extra_node_pools"></a> [extra\_node\_pools](#input\_extra\_node\_pools) | A list of extra node pools to create | <pre>list(object({<br/>    name                  = string<br/>    pool_name             = string<br/>    vm_size               = string<br/>    count_of              = optional(number, 1)<br/>    create_before_destroy = optional(bool, true)<br/>    enable_auto_scaling   = optional(bool, false)<br/>    min_count             = optional(number, null)<br/>    max_count             = optional(number, null)<br/>    max_pod_per_node      = optional(number, 110)<br/>    os_disk_type          = optional(string, "Ephemeral")<br/>    os_disk_size_gb       = optional(number)<br/>    mode                  = optional(string, "User")<br/>    custom_labels         = map(string)<br/>    orchestrator_version  = optional(string, "")<br/>    upgrade_settings = optional(object({<br/>      drain_timeout_in_minutes      = number<br/>      node_soak_duration_in_minutes = number<br/>      max_surge                     = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | Boolean value to activate the csi-secrets-store-driver | `any` | n/a | yes |
| <a name="input_load_balancer_profile_enabled"></a> [load\_balancer\_profile\_enabled](#input\_load\_balancer\_profile\_enabled) | Value to enable or not the load balancer profile | `bool` | `true` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | Load balancer sku (basic or standard) | `string` | `"standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where all resources should be created | `any` | n/a | yes |
| <a name="input_net_profile_outbound_type"></a> [net\_profile\_outbound\_type](#input\_net\_profile\_outbound\_type) | The outbound (egress) routing method which should be used for this Kubernetes Cluster | `string` | `"loadBalancer"` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Whether to enable OIDC Issuer for the AKS cluster | `bool` | n/a | yes |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | The name of an existing public IP address in the same resource group as resource\_group\_name to use for the AKS load balancer outbound profile. This variable is only used when net\_profile\_outbound\_type is set to 'loadBalancer'; for other values it is ignored. If null, AKS manages outbound IPs automatically. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the resources | `any` | n/a | yes |
| <a name="input_secret_rotation_enabled"></a> [secret\_rotation\_enabled](#input\_secret\_rotation\_enabled) | Boolean value to activate the secrets rotation csi-secrets-store-driver | `any` | n/a | yes |
| <a name="input_secret_rotation_interval"></a> [secret\_rotation\_interval](#input\_secret\_rotation\_interval) | String value to activate the secrets rotation interval csi-secrets-store-driver | `any` | n/a | yes |
| <a name="input_storage_profile"></a> [storage\_profile](#input\_storage\_profile) | Storage profile for the AKS cluster | <pre>object({<br/>    disk_csi_driver = optional(object({<br/>      enabled = optional(bool, true)<br/>    }))<br/>    file_csi_driver = optional(object({<br/>      enabled = optional(bool, true)<br/>    }))<br/>    snapshot_controller = optional(object({<br/>      enabled = optional(bool, true)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "disk_csi_driver": {<br/>    "enabled": true<br/>  },<br/>  "file_csi_driver": {<br/>    "enabled": true<br/>  },<br/>  "snapshot_controller": {<br/>    "enabled": true<br/>  }<br/>}</pre> | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet to use for the AKS cluster | `any` | n/a | yes |
| <a name="input_support_plan"></a> [support\_plan](#input\_support\_plan) | Support plan for the AKS cluster | `string` | `"KubernetesOfficial"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the virtual network where the subnet is located | `any` | n/a | yes |
| <a name="input_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#input\_vnet\_resource\_group\_name) | The name of the resource group in which the virtual network is located | `any` | n/a | yes |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Whether to enable Workload Identity for the AKS cluster | `any` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id) | The ID of the AKS cluster. Example: `/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxx-common-predev/providers/Microsoft.ContainerService/managedClusters/xxxx-predev-aks` |
| <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name) | The name of the AKS cluster. Example: `xxxx-predev-aks` |
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | The FQDN of the AKS cluster. Example: `xxxx-predev-xxxxxxxx.hcp.westeurope.azmk8s.io` |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | The cluster identity of the AKS cluster. See README for structure. |
| <a name="output_cluster_issuer"></a> [cluster\_issuer](#output\_cluster\_issuer) | The OIDC issuer URL of the AKS cluster. |
| <a name="output_kubelet_identity_client_id"></a> [kubelet\_identity\_client\_id](#output\_kubelet\_identity\_client\_id) | The kubelet identity client ID of the AKS cluster. |
| <a name="output_kubelet_identity_object_id"></a> [kubelet\_identity\_object\_id](#output\_kubelet\_identity\_object\_id) | The kubelet identity object ID of the AKS cluster. |
| <a name="output_network_profile"></a> [network\_profile](#output\_network\_profile) | The network profile of the AKS cluster. See README for structure. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The node resource group of the AKS cluster. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | The OIDC issuer URL of the AKS cluster. |
| <a name="output_outbound_ip_address"></a> [outbound\_ip\_address](#output\_outbound\_ip\_address) | The outbound IP address of the AKS cluster. |
| <a name="output_outbound_public_ip_id"></a> [outbound\_public\_ip\_id](#output\_outbound\_public\_ip\_id) | The outbound public IP resource ID of the AKS cluster. |
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
aks_kubernetes_version: "1.28.10"
aks_network_plugin: "azure"
aks_network_policy: "azure"
aks_network_dataplane: "azure"
aks_orchestrator_version: "1.28.10"
aks_prefix: "predev"
aks_sku_name: "Base"
aks_sku_tier: "Free"
key_vault_secrets_provider_enabled: true
secret_rotation_enabled: true
secret_rotation_interval: 30s
auto_upgrade_profile:
  node_os_upgrade_channel: "None"
  upgrade_channel: "none"
upgrade_settings:
  override_settings:
	  force_upgrade: true
	  until: "2026-09-18T14:30:00Z"
default_node_pool:
  name: "myng"
  vm_size: "Standard_D8as_v5"
  count_of: "2"
  enable_auto_scaling: false
  max_pods: 110
  os_disk_size_gb: 256
  node_labels:
    nodepool-group: "myng"
  upgrade_settings:
    drain_timeout_in_minutes: 30
    node_soak_duration_in_minutes: 0
    max_surge: "10%"
auto_scaler_profile:
  balance_similar_node_groups: false
  daemonset_eviction_for_empty_nodes: false
  daemonset_eviction_for_occupied_nodes: true
  ignore_daemonsets_utilization: false
  max_empty_bulk_delete: 10
  expander: "least-waste"
  max_graceful_termination_sec: "1800"
  max_node_provision_time: "15m"
  ok_total_unready_count: 2
  max__total_unready_percentage: 10
  new_pod_scale_up_delay: "10s"
  scale_down_delay_after_add: "15m"
  scale_down_delay_after_delete: "10s"
  scale_down_delay_after_failure: "3m"
  scale_down_unneeded: "5m"
  scale_down_unready: "15m"
  scale_down_utilization_threshold: "0.7"
  scan_interval: "10s"
  skip_nodes_with_local_storage: false
  skip_nodes_with_system_pods: false

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
