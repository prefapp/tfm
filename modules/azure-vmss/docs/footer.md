## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-vmss/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-vmss/_examples/basic) — Skeleton with placeholders; replace RG, VNet, subnet, SSH key, and public IP prefix before a real apply (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-vmss/_examples/comprehensive) — Documentation-oriented reference: `module.reference.hcl`, `values.reference.yaml`, and notes on the legacy README example (see folder README).

## Resources

Terraform resource docs use **4.16.0**, matching the pinned `azurerm` version in `versions.tf`.

- **Virtual Machine Scale Sets (Azure)**: [https://learn.microsoft.com/azure/virtual-machine-scale-sets/](https://learn.microsoft.com/azure/virtual-machine-scale-sets/)
- **azurerm_linux_virtual_machine_scale_set**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/linux_virtual_machine_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/linux_virtual_machine_scale_set)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
