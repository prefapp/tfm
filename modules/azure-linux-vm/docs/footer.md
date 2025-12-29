
## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-linux-vm/_examples):

- [vault_with_nic](https://github.com/prefapp/tfm/tree/main/modules/azure-linux-vm/_examples/vault_with_nic) - Example using Azure Key Vault for admin password and custom network interface configuration.
- [with_custom_data](https://github.com/prefapp/tfm/tree/main/modules/azure-linux-vm/_examples/with_custom_data) - Example provisioning a VM with custom cloud-init data.
- [with_vault_admin_pass](https://github.com/prefapp/tfm/tree/main/modules/azure-linux-vm/_examples/with_vault_admin_pass) - Example using Key Vault to securely provide the VM admin password.

## Remote resources

- **Azure Linux Virtual Machine**: [azurerm_linux_virtual_machine documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
- **Azure Network Interface**: [azurerm_network_interface documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
- **Azure Key Vault**: [azurerm_key_vault documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
