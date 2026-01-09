<!-- BEGIN_TF_DOCS -->
# **Azure Linux Virtual Machine Terraform Module**

## Overview

This module provisions and manages a complete Azure Linux Virtual Machine (VM) environment, including the Network Interface resources.

The module creates a Linux VM with support for SSH key authentication, optional admin password from Azure Key Vault, managed disks, and advanced networking options. It integrates seamlessly with Azure Resource Groups, Virtual Networks, Subnets, and Key Vault for secret management.

The module is suitable for development, staging, and production environments, and can be easily extended or embedded in larger Terraform projects.

## Key Features

- **Complete VM Provisioning**: Deploys a fully managed Azure Linux Virtual Machine with customizable size, OS image, and disk configuration.
- **Integrated Networking**: Automatically creates and attaches a Network Interface (NIC) with support to custom subnets, public IPs, and advanced options.
- **Key Vault Integration**: Optionally retrieves the VM admin password securely from Azure Key Vault, supporting best practices for secret management.
- **SSH and Password Authentication**: Supports both SSH key and password authentication, with the ability to disable password login for enhanced security.
- **Flexible Tagging and Resource Group Inheritance**: Inherits tags from the resource group or allows custom tags for all resources.
- **Network Security Group (NSG) Integration**: Optionally associates an existing NSG with the VM's NIC for enhanced security.
- **Public IP Configuration**: Optionally associates a public IP address with the VM's NIC for external access.
## Basic Usage

### Minimal Example: SSH Authentication Only

```hcl
module "linux_vm" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-linux-vm"

  common = {
    resource_group_name = "my-rg"
    location            = "westeurope"
  }
  vm = {
    name       = "my-linux-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "server"
      version   = "latest"
    }
    os_disk = {
      caching              = "ReadWrite"
      disk_size_gb         = 64
      storage_account_type = "Standard_LRS"
    }
    admin_ssh_key = {
      username   = "azureuser"
      public_key = "<your-ssh-public-key>"
    }
  }
  nic = {
    name                = "my-linux-vm-nic"
    subnet_name         = "default"
    virtual_network_name = "my-vnet"
    virtual_network_resource_group_name = "my-rg"
  }
}
```

### Example: Admin Password from Key Vault

```hcl
module "linux_vm" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-linux-vm"

  common = {
    resource_group_name = "my-rg"
    location            = "westeurope"
  }
  admin_password = {
    key_vault_name      = "my-keyvault"
    resource_group_name = "my-keyvault-rg"
    secret_name         = "linux-vm-admin-password"
  }
  vm = {
    name       = "my-linux-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "server"
      version   = "latest"
    }
    os_disk = {
      caching              = "ReadWrite"
      disk_size_gb         = 128
      storage_account_type = "Standard_LRS"
    }
    admin_ssh_key = {
      username   = "azureuser"
      public_key = "<your-ssh-public-key>"
    }
    identity = {
      type = "SystemAssigned"
    }
  }
  nic = {
    name                = "my-linux-vm-nic"
    subnet_name         = "default"
    virtual_network_name = "my-vnet"
    virtual_network_resource_group_name = "my-rg"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/network_interface) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/key_vault_secret) | data source |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/network_security_group) | data source |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/public_ip) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for the VM. If not provided, it will be fetched from Key Vault. | <pre>object({<br/>    key_vault_name        = string<br/>    resource_group_name   = string<br/>    secret_name          = string<br/>  })</pre> | n/a | yes |
| <a name="input_common"></a> [common](#input\_common) | VARIABLES SECTION | <pre>object({<br/>    resource_group_name = string<br/>    location            = string<br/>  })</pre> | n/a | yes |
| <a name="input_nic"></a> [nic](#input\_nic) | n/a | <pre>object({<br/>    name                                               = optional(string)<br/>    subnet_name                                        = optional(string)<br/>    virtual_network_name                               = optional(string)<br/>    virtual_network_resource_group_name                = optional(string)<br/>    subnet_id                                          = optional(string)<br/>    auxiliary_mode                                     = optional(string)<br/>    auxiliary_sku                                      = optional(string)<br/>    accelerated_networking_enabled                     = optional(bool)<br/>    ip_forwarding_enabled                              = optional(bool)<br/>    ip_configuration_name                              = optional(string)<br/>    edge_zone                                          = optional(string)<br/>    dns_servers                                        = optional(list(string))<br/>    internal_dns_name_label                            = optional(string)<br/>    gateway_load_balancer_frontend_ip_configuration_id = optional(string)<br/>    private_ip_address_version                         = optional(string)<br/>    private_ip_address_allocation                      = optional(string, "Dynamic")<br/>    public_ip_address_id                               = optional(string)<br/>    primary                                            = optional(bool)<br/>    private_ip_address                                 = optional(string)<br/>    nsg = optional(object({<br/>      name                = optional(string)<br/>      resource_group_name = optional(string)<br/>    }))<br/>    public_ip = optional(object({<br/>      name                = optional(string)<br/>      resource_group_name = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_vm"></a> [vm](#input\_vm) | n/a | <pre>object({<br/>    name                            = string<br/>    size                            = string<br/>    admin_username                  = optional(string)<br/>    admin_password                  = optional(string)<br/>    edge_zone                       = optional(string)<br/>    eviction_policy                 = optional(string)<br/>    encryption_at_host_enabled      = optional(bool)<br/>    secure_boot_enabled             = optional(bool)<br/>    os_managed_disk_id             = optional(string)<br/>    vtpm_enabled                    = optional(bool)<br/>    disable_password_authentication = optional(bool)<br/>    custom_data                     = optional(string)<br/>    provision_vm_agent                     = optional(string)<br/>    license_type                     = optional(string)<br/>    patch_mode                     = optional(string)<br/><br/>    admin_ssh_key = object({<br/>      username   = string<br/>      public_key = string<br/>    })<br/><br/>    source_image_reference = optional(object({<br/>      publisher = string<br/>      offer     = string<br/>      sku       = string<br/>      version   = string<br/>    }))<br/><br/>    os_disk = object({<<br/>      name              = optional(string)<br/>      caching              = string<br/>      disk_size_gb         = optional(number)<br/>      storage_account_type = optional(string)<br/>    })<br/><br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/><br/>    adittional_capabilities = optional(object({<br/>      ultra_ssd_enabled         = optional(bool)<br/>      hibernation_enabled = optional(bool)<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_data"></a> [custom\_data](#output\_custom\_data) | Output section |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_virtual_machine_id"></a> [virtual\_machine\_id](#output\_virtual\_machine\_id) | n/a |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-linux-vm/_examples):

- [with\_nic](https://github.com/prefapp/tfm/tree/main/modules/azure-linux-vm/_examples/with\_nic) - Example using Azure Key Vault for admin password and custom network interface configuration.
- [with\_custom\_data](https://github.com/prefapp/tfm/tree/main/modules/azure-linux-vm/_examples/with\_custom\_data) - Example provisioning a VM with custom cloud-init data.
- [with\_vault\_admin\_pass](https://github.com/prefapp/tfm/tree/main/modules/azure-linux-vm/_examples/with\_vault\_admin\_pass) - Example using Key Vault to securely provide the VM admin password.

## Remote resources

- **Azure Linux Virtual Machine**: [azurerm\_linux\_virtual\_machine documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
- **Azure Network Interface**: [azurerm\_network\_interface documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
- **Azure Key Vault**: [azurerm\_key\_vault documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
