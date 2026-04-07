## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-vmss/_examples/basic) — Skeleton with placeholders; replace RG, VNet, subnet, SSH key, and public IP prefix before apply.
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-vmss/_examples/comprehensive) — **`module.reference.hcl`** / **`values.reference.yaml`**: legacy-style Rolling + Ubuntu 18.04 example from the old README, completed with required `vmss` fields; **`legacy-readme-fragment.txt`** notes the old fencing mistakes.

## Remote resources

- **Virtual Machine Scale Sets**: [https://learn.microsoft.com/azure/virtual-machine-scale-sets/](https://learn.microsoft.com/azure/virtual-machine-scale-sets/)
- **Terraform `azurerm_linux_virtual_machine_scale_set`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
