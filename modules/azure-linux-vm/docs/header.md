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
