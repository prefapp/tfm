## Examples

The examples are self-contained Terraform callers for this module. They use illustrative values only; replace the project, VLAN, CIDR, and gateway model with values available in your OVHcloud account.

- [Gravelines single-AZ MKS network](https://github.com/prefapp/tfm/tree/main/modules/ovh-network/_examples/gravelines-single-az) — creates regional networking for a downstream MKS cluster with node pools in one availability zone. AZ placement is configured by MKS, not by this module.
- [Paris three-AZ MKS network](https://github.com/prefapp/tfm/tree/main/modules/ovh-network/_examples/paris-three-az) — creates regional networking for a downstream MKS cluster with node pools across three availability zones. AZ placement is configured by MKS, not by this module.

## Resources

- **OVHcloud Public Cloud**: [Product information](https://www.ovhcloud.com/en/public-cloud/)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_network_private`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private), [`ovh_cloud_project_network_private_subnet`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_network_private_subnet), and [`ovh_cloud_project_gateway`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_gateway)
- **OVHcloud Terraform provider documentation**: [Provider and authentication configuration](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- **OVHcloud MKS module**: [`ovh-mks`](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
