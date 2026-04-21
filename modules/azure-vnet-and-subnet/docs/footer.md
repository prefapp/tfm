## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-and-subnet/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-and-subnet/_examples/basic) — Resource group, virtual network with one subnet (`internal`), no private DNS zones or peerings (see folder README for usage).

## Resources

Terraform resource docs use **4.21.1** as a baseline aligned with the `azurerm` constraint in `main.tf` (`>= 4.21.1`).

- **Azure Virtual Network**: [https://learn.microsoft.com/azure/virtual-network/virtual-networks-overview](https://learn.microsoft.com/azure/virtual-network/virtual-networks-overview)
- **Azure Private DNS**: [https://learn.microsoft.com/azure/dns/private-dns-overview](https://learn.microsoft.com/azure/dns/private-dns-overview)
- **azurerm_virtual_network**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/virtual_network)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
