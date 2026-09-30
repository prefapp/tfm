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

The module can also prepare the network infrastructure consumed by an OVHcloud Managed Kubernetes Service (MKS) cluster. The network and subnet are managed independently from the cluster; their regional OpenStack network ID and subnet ID are available as outputs for the MKS module. The network itself is regional and does not configure or select availability zones.

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

After applying the network configuration, use `network_openstack_id` and `subnet_id` as the network and subnet inputs for the MKS cluster. Complete standalone examples are linked below.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | >= 2.20.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | >= 2.20.0, < 3.0.0 |

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
| <a name="input_gateway_model"></a> [gateway\_model](#input\_gateway\_model) | Tamaño del gateway Public Cloud. | `string` | n/a | yes |
| <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name) | Nombre del gateway de la red privada. | `string` | n/a | yes |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | CIDR privado de la subred. | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Nombre de la red privada que usará Kubernetes. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID opcional del proyecto Public Cloud (project\_id o service\_name); tiene prioridad sobre project\_name. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nombre opcional del proyecto Public Cloud; se compara con project\_name y description de OVHcloud. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Región OVHcloud en la que crear la red, por ejemplo EU-WEST-PAR o GRA11. | `string` | n/a | yes |
| <a name="input_subnet_pool_end"></a> [subnet\_pool\_end](#input\_subnet\_pool\_end) | Última dirección del pool DHCP. | `string` | n/a | yes |
| <a name="input_subnet_pool_start"></a> [subnet\_pool\_start](#input\_subnet\_pool\_start) | Primera dirección del pool DHCP. | `string` | n/a | yes |
| <a name="input_vlan_id"></a> [vlan\_id](#input\_vlan\_id) | VLAN de la red privada. | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | ID del gateway asociado a la red privada. |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | ID OVHcloud (pn-...) de la red privada. |
| <a name="output_network_openstack_id"></a> [network\_openstack\_id](#output\_network\_openstack\_id) | ID regional OpenStack de la red, requerido por el clúster MKS. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | service\_name OVHcloud del proyecto Public Cloud resuelto. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | ID OVHcloud de la subred DHCP, requerido como nodes\_subnet\_id por MKS. |

## Examples

The examples are self-contained Terraform callers for this module. They use illustrative values only; replace the project, VLAN, CIDR, and gateway model with values available in your OVHcloud account.

- [Gravelines single-AZ MKS network](https://github.com/prefapp/tfm/tree/main/modules/ovh-network/_examples/gravelines-single-az) — creates regional networking for a downstream MKS cluster with node pools in one availability zone. AZ placement is configured by MKS, not by this module.
- [Paris three-AZ MKS network](https://github.com/prefapp/tfm/tree/main/modules/ovh-network/_examples/paris-three-az) — creates regional networking for a downstream MKS cluster with node pools across three availability zones. AZ placement is configured by MKS, not by this module.

## Resources

- **OVHcloud Public Cloud**: [Product information](https://www.ovhcloud.com/en/public-cloud/)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_network_private`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private), [`ovh_cloud_project_network_private_subnet`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private\_subnet), and [`ovh_cloud_project_gateway`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_gateway)
- **OVHcloud Terraform provider documentation**: [Provider and authentication configuration](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- **OVHcloud MKS module**: [`ovh-mks`](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->