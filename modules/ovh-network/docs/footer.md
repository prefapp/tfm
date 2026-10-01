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
- **OVHcloud Terraform provider**: [`ovh_cloud_project_network_private`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private), [`ovh_cloud_project_network_private_subnet`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private_subnet), and [`ovh_cloud_project_gateway`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_gateway)
- **OVHcloud Terraform provider documentation**: [Provider and authentication configuration](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- **OVHcloud MKS module**: [`ovh-mks`](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
