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

## Basic Usage

### Example 1: Basic Windows VM with Password

```hcl
module "windows_vm" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-windows-vm"

  common = {
    resource_group_name = "my-rg"
    location            = "westeurope"
  }
  vm = {
    name       = "my-windows-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    admin_password = "SuperSecretPassword123!"
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
    name                = "my-windows-vm-nic"
    subnet_name         = "default"
    virtual_network_name = "my-vnet"
    virtual_network_resource_group_name = "my-rg"
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
  nic = {
    name                = "my-windows-vm-nic"
    subnet_name         = "default"
    virtual_network_name = "my-vnet"
    virtual_network_resource_group_name = "my-rg"
  }
}
```

### Example 3: Windows VM with Additional Data Disks

```hcl
module "windows_vm" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-windows-vm"

  common = {
    resource_group_name = "my-rg"
    location            = "westeurope"
  }
  vm = {
    name       = "my-windows-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    admin_password = "SuperSecretPassword123!"
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
    data_disks = [
      {
        lun            = 0
        vhd_uri        = "https://myaccount.blob.core.windows.net/vhds/disk1.vhd"
        caching        = "ReadOnly"
        disk_size_gb   = 128
        name           = "datadisk1"
      },
      {
        lun            = 1
        vhd_uri        = "https://myaccount.blob.core.windows.net/vhds/disk2.vhd"
        caching        = "ReadWrite"
        disk_size_gb   = 256
        name           = "datadisk2"
      }
    ]
  }
  nic = {
    name                = "my-windows-vm-nic"
    subnet_name         = "default"
    virtual_network_name = "my-vnet"
    virtual_network_resource_group_name = "my-rg"
  }
}
```
