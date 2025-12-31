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

## Terraform Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.1 |

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
