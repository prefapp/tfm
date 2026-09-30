<!-- BEGIN_TF_DOCS -->
> [!WARNING]
> **Avoid MKS-reserved private network CIDRs.** If this network will be attached to an OVHcloud MKS cluster, do not use these ranges for `network_cidr`:
>
> - **Free plan:** `10.2.0.0/16`, `10.3.0.0/16`, and `172.17.0.0/16`.
> - **Standard plan:** `10.240.0.0/13` and `10.3.0.0/16`.
>
> Standard plan pod and service ranges can be customized when creating or resetting a cluster. Changing them on a running cluster requires a reset and can cause data loss. See [OVHcloud MKS known limits](https://docs.ovhcloud.com/en/guides/public-cloud/containers-orchestration/managed-kubernetes/known-limits/).

# **OVHcloud Private Network Terraform Module**

## Overview

This Terraform module creates an OVHcloud Public Cloud private network, a DHCP-enabled subnet, and a Public Cloud gateway in one selected region. It can be used as a reusable network foundation for workloads that need private connectivity and outbound access through an OVHcloud gateway.

The module can also create network infrastructure for an OVHcloud Managed Kubernetes Service (MKS) cluster. The network and subnet are managed independently from the cluster, and their IDs are exposed as outputs for consumers that accept IDs directly. The `ovh-mks` module instead discovers an existing network by exact name and its subnet by CIDR in the selected project and region; pass the same `network_name` and CIDR to that module. The network itself is regional and does not configure or select availability zones.

The Public Cloud project can be selected by `project_name` or by `project_id` (which also accepts the OVHcloud `service_name` and takes precedence when set).

## Key Features

- **Private network provisioning**: Creates a private network in the selected OVHcloud Public Cloud region with a configurable name and VLAN ID.
- **DHCP subnet**: Creates a subnet with a configurable CIDR and DHCP address-pool range.
- **Public Cloud gateway**: Creates a gateway attached to the new network and subnet using the requested gateway model.
- **Flexible project selection**: Resolves the Public Cloud project by name or by project ID/service name.
- **MKS-ready outputs**: Exposes the regional network ID and subnet ID required when configuring an MKS cluster.

## Basic Usage

Use a released module tag in the Git source. Replace the example project, network, CIDR, VLAN, region, and gateway model with values supported by your OVHcloud account. Configure OVHcloud credentials using the provider's supported authentication methods; do not put credentials in these examples.

### Network for a single-AZ MKS scenario in Gravelines

This creates regional networking resources for a workload or MKS cluster in Gravelines. The single-AZ placement is configured later on the MKS cluster and is not managed by this module.

```hcl
module "ovh_network" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-network?ref=ovh-network-vx.y.z"

  project_name      = "example-project"
  network_name      = "example-gra-private-network"
  gateway_name      = "example-gra-gateway"
  region            = "GRA11"
  vlan_id           = 101
  network_cidr      = "10.41.0.0/16"
  subnet_pool_start = "10.41.0.10"
  subnet_pool_end   = "10.41.255.254"
  gateway_model     = "<available-gateway-model>"
}
```

### Network for a three-AZ MKS scenario in Paris

The same regional network can serve an MKS cluster whose node pools are placed across three Paris availability zones. Configure those zones on the MKS cluster, not on this network module.

```hcl
module "ovh_network" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-network?ref=ovh-network-vx.y.z"

  project_name      = "example-project"
  network_name      = "example-par-private-network"
  gateway_name      = "example-par-gateway"
  region            = "EU-WEST-PAR"
  vlan_id           = 102
  network_cidr      = "10.40.0.0/16"
  subnet_pool_start = "10.40.0.10"
  subnet_pool_end   = "10.40.255.254"
  gateway_model     = "<available-gateway-model>"
}
```

After applying the network configuration, configure the `ovh-mks` module with the same network name as `network_name` and the same subnet CIDR as `subnet_cidr`. The `network_openstack_id` and `subnet_id` outputs are available to other consumers that accept resource IDs directly. Complete standalone examples are linked below.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | >= 2.20.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | 2.21.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ovh_cloud_project_gateway.kubernetes](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_gateway) | resource |
| [ovh_cloud_project_network_private.kubernetes](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private) | resource |
| [ovh_cloud_project_network_private_subnet.kubernetes](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private_subnet) | resource |
| [ovh_cloud_projects.projects](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_projects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gateway_model"></a> [gateway\_model](#input\_gateway\_model) | Public Cloud gateway model. | `string` | n/a | yes |
| <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name) | Name of the private network gateway. | `string` | n/a | yes |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Private subnet CIDR. | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of the private network Kubernetes will use. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional Public Cloud project ID (project\_id or service\_name); takes precedence over project\_name. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Optional Public Cloud project name; matched against OVHcloud project\_name and description. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | OVHcloud region in which to create the network, for example EU-WEST-PAR or GRA11. | `string` | n/a | yes |
| <a name="input_subnet_pool_end"></a> [subnet\_pool\_end](#input\_subnet\_pool\_end) | Last address in the DHCP pool. | `string` | n/a | yes |
| <a name="input_subnet_pool_start"></a> [subnet\_pool\_start](#input\_subnet\_pool\_start) | First address in the DHCP pool. | `string` | n/a | yes |
| <a name="input_vlan_id"></a> [vlan\_id](#input\_vlan\_id) | VLAN ID for the private network. | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | ID of the gateway attached to the private network. |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | OVHcloud ID (pn-...) of the private network. |
| <a name="output_network_openstack_id"></a> [network\_openstack\_id](#output\_network\_openstack\_id) | Regional OpenStack network ID for consumers that accept resource IDs directly; ovh-mks discovers the network by name. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | OVHcloud service\_name of the resolved Public Cloud project. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | OVHcloud ID of the DHCP subnet for consumers that require resource IDs directly; ovh-mks discovers the subnet by CIDR. |

## Examples

The examples are self-contained Terraform callers for this module. They use illustrative values only; replace the project, VLAN, CIDR, and gateway model with values available in your OVHcloud account.

- [Gravelines single-AZ MKS network](https://github.com/prefapp/tfm/tree/main/modules/ovh-network/_examples/gravelines-single-az) — creates regional networking for a downstream MKS cluster with node pools in one availability zone. AZ placement is configured by MKS, not by this module.
- [Paris three-AZ MKS network](https://github.com/prefapp/tfm/tree/main/modules/ovh-network/_examples/paris-three-az) — creates regional networking for a downstream MKS cluster with node pools across three availability zones. AZ placement is configured by MKS, not by this module.

## Import and Lifecycle

This module is intended to create new networking resources for an OVHcloud project. Import is not part of the normal setup flow. If adopting existing resources becomes necessary, use these resource addresses (assuming the caller names the module `ovh_network`; substitute the actual module block name) and import ID formats from OVH provider 2.21.0:

| Resource | Terraform address | Import ID |
|----------|-------------------|-----------|
| Private network | `module.ovh_network.ovh_cloud_project_network_private.kubernetes` | `<service_name>/<network_id>` (network ID has the `pn-...` format) |
| DHCP subnet | `module.ovh_network.ovh_cloud_project_network_private_subnet.kubernetes` | `<service_name>/<network_id>/<subnet_id>` |
| Public Cloud gateway | `module.ovh_network.ovh_cloud_project_gateway.kubernetes` | `<service_name>/<region>/<gateway_id>` |

The OVH provider 2.21.0 does not restore a gateway's `network_id` and `subnet_id` attributes into state when it is imported. The next plan may therefore propose replacing the gateway. Because the gateway resource is encapsulated in this module, callers cannot add a lifecycle rule to suppress that change. Review the plan carefully and do not apply a replacement unless it is intended. This module is designed to create new networking resources; it is not currently a safe adoption path for an existing gateway.

Destroying this module deletes the gateway, DHCP subnet, and private network in dependency order. The MKS module manages clusters separately, so Terraform cannot automatically account for clusters that still use this network. Detach or migrate those clusters and workloads before destroying the network; removing their network connectivity can disrupt cluster operation. Review the plan before applying destructive changes.

## Resources

- **OVHcloud Public Cloud**: [Product information](https://www.ovhcloud.com/en/public-cloud/)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_network_private`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private), [`ovh_cloud_project_network_private_subnet`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private\_subnet), and [`ovh_cloud_project_gateway`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_gateway)
- **OVHcloud Terraform provider documentation**: [Provider and authentication configuration](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- **OVHcloud MKS module**: [`ovh-mks`](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->