# **Azure AKS Terraform Module**

## Overview

This Terraform module leverages the official AKS module to provision and manage production-ready Azure Kubernetes Service (AKS) clusters. It supports advanced configurations such as extra node pools, autoscaling profiles, Azure Container Registry (ACR) integration, and flexible networking, making it suitable for a wide range of deployment scenarios on Microsoft Azure.

### Requirements

- Resource group created
- Subnet created (VNet)
- ACR(s) (optional)
- If you set a Public IP, you need to create a public IP resource

For more details, see the [Terraform AKS module documentation](https://registry.terraform.io/modules/Azure/aks/azurerm/latest).

This module provisions an **AKS cluster on Azure**, including:

- AKS cluster
- Node pools (including extra pools)
- Autoscaling profile
- Azure Container Registry (ACR) integration
- Network configuration (VNet/Subnet)
- Optional public IP assignment

> **Note:**
> The following values are not configurable:
> - `log_analytics_workspace_enabled`: `false`
> - `rbac_aad_azure_rbac_enabled`: `true`
> - `rbac_aad_managed`: `true`
> - `role_based_access_control_enabled`: `true`

It is designed to be flexible, production-ready, and easy to integrate into existing infrastructures.

## Key Features

- **AKS Cluster & Node Pools**: Creates a managed AKS cluster and allows custom node pool definitions.
- **Autoscaling**: Supports autoscaling profiles and advanced node pool configuration.
- **ACR Integration**: Allows associating one or more Azure Container Registries to the cluster.
- **Flexible Networking**: Selection of existing VNet and Subnet.
- **Advanced Configuration**: Supports OIDC, Workload Identity, security profiles, and more.

## Basic Usage

### Minimal Example

```hcl
module "azure-aks" {
	source = "github.com/prefapp/tfm/modules/azure-aks"
	# ...module variables...
}
```
