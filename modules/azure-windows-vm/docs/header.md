# **Azure Windows Virtual Machine Terraform Module**

## Overview

This module provisions and manages a complete Azure Windows Virtual Machine (VM) environment, including Network Interface resources, Key Vault integration, boot diagnostics, WinRM, patch mode, license type, timezone, and support for additional unmanaged data disks.

It is suitable for development, staging, and production environments, and can be easily extended or embedded in larger Terraform projects.

## Key Features

- **Complete VM Provisioning**: Deploys a fully managed Azure Windows Virtual Machine with customizable size, OS image, disk configuration, and additional data disks.
- **Integrated Networking**: Automatically creates and attaches a Network Interface (NIC) with support for custom subnets, public IPs, and advanced options.
- **Key Vault Integration**: Optionally retrieves the VM admin password securely from Azure Key Vault, supporting best practices for secret management.
- **Password Authentication**: Supports password authentication, with the ability to securely provide the admin password from Azure Key Vault.
- **Boot Diagnostics**: Optionally enables boot diagnostics with a custom storage account URI.
- **WinRM Listener**: Supports WinRM configuration for remote management.
- **Patch Mode, License Type, Timezone**: Configure patching, licensing, and timezone for the VM.
- **Flexible Tagging and Resource Group Inheritance**: Inherits tags from the resource group or allows custom tags for all resources.
- **Network Security Group (NSG) Integration**: Optionally associates an existing NSG with the VM's NIC for enhanced security.

## Basic Usage

### Example 1: Basic Windows VM with NIC

```hcl
module "windows_vm" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-windows-vm"

  common = {
    resource_group_name = "example-resource-group"
    location            = "westeurope"
  }

  vm = {
    name       = "example-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    admin_password = "ExamplePassword123!" # Replace with a secure password
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
    os_disk = {
      caching              = "ReadWrite"
      disk_size_gb         = 64
      storage_account_type = "Standard_LRS"
    }
  }
  nic = {
    subnet_name = "example-subnet"
    virtual_network_name = "example-vnet"
    virtual_network_resource_group_name = "example-resource-group"
  }
}
```

### Example 2: Admin Password from Key Vault

```hcl
module "windows_vm" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-windows-vm"

  common = {
    resource_group_name = "my-rg"
    location            = "westeurope"
  }
  admin_password = {
    key_vault_name      = "my-keyvault"
    resource_group_name = "my-keyvault-rg"
    secret_name         = "windows-vm-admin-password"
  }
  vm = {
    name       = "my-windows-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    network_interface_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-group/providers/Microsoft.Network/networkInterfaces/example-nic"]
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
    os_disk = {
      caching              = "ReadWrite"
      disk_size_gb         = 128
      storage_account_type = "Standard_LRS"
    }
    identity = {
      type = "SystemAssigned"
    }
  }
}
```
