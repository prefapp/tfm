## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-nsg-nsr/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-nsg-nsr/_examples/basic) — NSG with two inbound rules; set a real resource group before apply (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-nsg-nsr/_examples/comprehensive) — Illustrative `values.reference.yaml` matching the HCL shape (see folder README).

## Resources

Terraform resource docs use **4.16.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.16.0`).

- **Azure network security groups**: [https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
- **azurerm_network_security_group**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/network_security_group)
- **azurerm_network_security_rule**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/network_security_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/network_security_rule)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
