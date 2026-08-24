# azure-aks

Owns an AKS cluster by wrapping the upstream `Azure/terraform-azurerm-aks` module, plus the role assignments that let it pull from container registries.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**upstream module**:
This module delegates the cluster itself to `github.com/Azure/terraform-azurerm-aks` pinned at a `ref`. Its own resources are only the surrounding role assignments, so cluster behaviour follows that pinned version, not this repository.
_Avoid_: child module

**agent pool**:
The node pool vocabulary this module exposes (`aks_agents_*`): count, max pods, drain timeout and max surge during upgrades. Azure calls these *agents*; Kubernetes calls them nodes.
_Avoid_: node group (that is the EKS term)

**ACR link**:
An `acr_map` entry — a container registry the cluster's identity is granted pull rights on, expressed as a role assignment rather than a cluster setting.

**network lookup**:
The cluster's subnet is found by `subnet_name` inside `vnet_name` in `vnet_resource_group_name`, which may differ from the cluster's own resource group.
