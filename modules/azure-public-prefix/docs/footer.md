## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-public-prefix/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-public-prefix/_examples/basic) — Minimal module call for one public IP prefix; set RG, location, and prefix options per Azure constraints (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-public-prefix/_examples/comprehensive) — Illustrative `values.reference.yaml` for module inputs (documentation-oriented; see folder README).

## Resources

Terraform resource docs use **4.16.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.16.0`).

- **Public IP address prefix (Azure)**: [https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-address-prefix](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-address-prefix)
- **azurerm_public_ip_prefix**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/public_ip_prefix](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/public_ip_prefix)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
