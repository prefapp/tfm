# Azure Virtual Machine Scale Set (VMSS) Terraform Module

## Overview

This Terraform module allows you to create and manage Azure Linux Virtual Machine Scale Sets (VMSS) with advanced configuration options, including rolling upgrades, custom images, and cloud-init scripts.

## Main features
- Create a VMSS with custom name, SKU, and instance count.
- Support for rolling upgrades, secure boot, and disk configuration.
- Flexible network, identity, and tag options.
- Use cloud-init and custom scripts for provisioning.
- Realistic configuration example.

## Example usage

```yaml
  common = {
    resource_group_name = "my-resource-group"
    location            = "eastus"
    tags_from_rg     = true

  vmss = {
    name                        = "my-vmss"
    sku                         = "Standard_DS2_v2"
    instances                   = 3
    admin_username              = "azureuser"
    admin_ssh_key_username      = "ssh-user"
    first_public_key            = "ssh-rsa AAAAB3NzaC1yc2..."
    eviction_policy             = "Delete"
    secure_boot_enabled         = true
    disk_storage_account_type   = "Standard_LRS"
    disk_caching                = "ReadWrite"
    upgrade_mode                = "Rolling"
    rolling_upgrade_policy_max_batch_instance_percent = 20
    rolling_upgrade_policy_max_unhealthy_instance_percent = 20
    image_publisher = "Canonical"
    image_offer     = "UbuntuServer"
    image_sku       = "18.04-LTS"
    image_version   = "latest"
    identity_type   = "SystemAssigned"
    cloud_init      = file("./cloud-init.yml")
    run_script      = file("./init-script.sh")
  }
}
```

```hcl
  common = {
    resource_group_name = "my-resource-group"
    location            = "eastus"
    tags_from_rg     = true
  }

  vmss = {
    name                        = "my-vmss"
    sku                         = "Standard_DS2_v2"
    instances                   = 3
    admin_username              = "azureuser"
    admin_ssh_key_username      = "ssh-user"
    first_public_key            = "ssh-rsa AAAAB3NzaC1yc2..."
    eviction_policy             = "Delete"
    secure_boot_enabled         = true
    disk_storage_account_type   = "Standard_LRS"
    disk_caching                = "ReadWrite"
    upgrade_mode                = "Rolling"
    rolling_upgrade_policy_max_batch_instance_percent = 20
    rolling_upgrade_policy_max_unhealthy_instance_percent = 20
    image_publisher = "Canonical"
    image_offer     = "UbuntuServer"
    image_sku       = "18.04-LTS"
    image_version   = "latest"
    identity_type   = "SystemAssigned"
    cloud_init      = file("./cloud-init.yml")
    run_script      = file("./init-script.sh")
  }
}
```

## Notes
- You can use both HCL and YAML for configuration.
- Supports advanced VMSS features like rolling upgrades, custom images, and cloud-init.
- Tags can be inherited from the resource group.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
