# Azure Linux Virtual Machine Scale Set (VMSS) Terraform module

## Overview

This module creates a **Linux Virtual Machine Scale Set** in an existing resource group, attaches it to an existing **subnet** (via data sources), applies optional **tags** (with optional merge from a resource group data source), and can run a **CustomScript** extension when `run_script` is set.

The module does **not** create the resource group, virtual network, or subnet. `vmss.resource_group_name` is used by the `azurerm_resource_group` data source (for `tags_from_rg`); it is often the same value as `common.resource_group_name`.

## Key features

- **Compute**: `azurerm_linux_virtual_machine_scale_set` with marketplace image, admin SSH key, OS disk, optional data disk, rolling upgrade policy, and managed identity.
- **Networking**: NIC in the resolved subnet; optional LB/AGW/ASG associations; public IP configuration with a **public IP prefix** ID.
- **Bootstrap**: `cloud_init` is passed as `custom_data` (base64-encoded by Terraform). Optional `run_script` enables the CustomScript extension.

## Prerequisites

- Existing **resource group** (`common.resource_group_name`) and **location** (`common.location`).
- Existing **VNet** and **subnet** matching `vmss.subnet_name`, `vmss.virtual_network_name`, and `vmss.virtual_network_resource_group_name`.
- **SSH public key** and a valid **`network_interface_public_ip_adress_public_ip_prefix_id`** for your subscription.

## Basic usage

Pass `common`, `vmss`, and optionally `tags` / `tags_from_rg`. The `vmss` object has many fields; see the **Inputs** table for types and required attributes.

### Example

```hcl
module "vmss" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vmss?ref=<version>"

  common = {
    resource_group_name = "my-resource-group"
    location            = "westeurope"
  }

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  vmss = {
    name                   = "my-vmss"
    resource_group_name    = "my-resource-group"
    sku                    = "Standard_B2s"
    instances              = 2
    admin_username         = "azureuser"
    admin_ssh_key_username = "azureuser"
    first_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB..."

    disk_storage_account_type = "Standard_LRS"
    disk_caching              = "ReadWrite"

    upgrade_mode                                                   = "Rolling"
    rolling_upgrade_policy_max_batch_instance_percent              = 20
    rolling_upgrade_policy_max_unhealthy_instance_percent          = 20
    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = 20
    rolling_upgrade_policy_pause_time_between_batches              = "PT5M"
    rolling_upgrade_policy_cross_zone_upgrades_enabled             = false
    rolling_upgrade_policy_maximum_surge_instances_enabled         = false
    rolling_upgrade_policy_prioritize_unhealthy_instances_enabled  = false

    image_publisher = "Canonical"
    image_offer     = "0001-com-ubuntu-server-jammy"
    image_sku       = "22_04-lts"
    image_version   = "latest"

    subnet_name                         = "my-subnet"
    virtual_network_name                = "my-vnet"
    virtual_network_resource_group_name = "my-resource-group"

    network_interface_public_ip_adress_public_ip_prefix_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/publicIPPrefixes/my-prefix"

    identity_type = "SystemAssigned"

    cloud_init = "#cloud-config\n"
    run_script = null
  }
}
```

Use `run_script` with a shell script body when you need the CustomScript extension. The module outputs `cloud_init` and `run_script` are `null` when those optional inputs are unset; you must still pass a non-null `cloud_init` if you use the default `custom_data` wiring in `main.tf`.

## File structure

```
.
├── CHANGELOG.md
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   └── basic
├── README.md
└── .terraform-docs.yml
```
