<!-- BEGIN_TF_DOCS -->
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
- **SSH public key** and a valid **`network_interface_public_ip_adress_public_ip_prefix_id`** for your subscription when using the default public IP block.

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_virtual_machine_scale_set_extension.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common"></a> [common](#input\_common) | Resource group and region where the scale set is created (must already exist). | <pre>object({<br/>    resource_group_name = string<br/>    location            = string<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_vmss"></a> [vmss](#input\_vmss) | Scale set, image, disks, upgrade policy, networking, identity, and optional cloud-init / custom script. See Inputs table for the full object shape. | <pre>object({<br/>    name                        = string<br/>    resource_group_name         = string<br/>    sku                         = string<br/>    instances                   = optional(number)<br/>    admin_username              = string<br/>    admin_ssh_key_username      = string<br/>    first_public_key            = optional(string)<br/>    eviction_policy             = optional(string)<br/>    secure_boot_enabled         = optional(bool)<br/>    platform_fault_domain_count = optional(number)<br/>    encryption_at_host_enabled  = optional(bool)<br/>    vtpm_enabled                = optional(bool)<br/>    zones                       = optional(list(string))<br/>    computer_name_prefix        = optional(string)<br/><br/>    disk_storage_account_type = string<br/>    disk_caching              = string<br/>    data_disk = optional(object({<br/>      name                 = optional(string)<br/>      caching              = string<br/>      create_option        = optional(string)<br/>      disk_size_gb         = number<br/>      lun                  = number<br/>      storage_account_type = string<br/>    }))<br/><br/>    upgrade_mode                                                   = string<br/>    rolling_upgrade_policy_max_batch_instance_percent              = number<br/>    rolling_upgrade_policy_max_unhealthy_instance_percent          = number<br/>    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = number<br/>    rolling_upgrade_policy_pause_time_between_batches              = string<br/>    rolling_upgrade_policy_cross_zone_upgrades_enabled             = bool<br/>    rolling_upgrade_policy_maximum_surge_instances_enabled         = bool<br/>    rolling_upgrade_policy_prioritize_unhealthy_instances_enabled  = bool<br/><br/>    image_publisher = string<br/>    image_offer     = string<br/>    image_sku       = string<br/>    image_version   = string<br/><br/>    edge_zone                           = optional(string)<br/>    network_primary                     = optional(bool)<br/>    network_ip_primary                  = optional(bool)<br/>    network_security_group_id           = optional(string)<br/>    subnet_name                         = optional(string)<br/>    virtual_network_name                = optional(string)<br/>    virtual_network_resource_group_name = optional(string)<br/>    prefix_length                       = optional(number)<br/><br/>    scale_in_rule                   = optional(string)<br/>    scale_in_force_deletion_enabled = optional(bool)<br/><br/>    network_interface_ip_configuration_application_gateway_backend_address_pool_ids = optional(list(string))<br/>    network_interface_ip_configuration_application_security_group_ids               = optional(list(string))<br/>    network_interface_ip_configuration_load_balancer_backend_address_pool_ids       = optional(list(string))<br/>    network_interface_ip_configuration_load_balancer_inbound_nat_rules_ids          = optional(list(string))<br/>    network_interface_public_ip_adress_idle_timeout_in_minutes                      = optional(number)<br/>    network_interface_public_ip_adress_public_ip_prefix_id                          = string<br/><br/>    identity_type    = string<br/>    identity_ids     = optional(list(string))<br/>    identity_rg_name = optional(string)<br/><br/>    cloud_init = optional(string)<br/>    run_script = optional(string)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_init"></a> [cloud\_init](#output\_cloud\_init) | Base64-encoded `vmss.cloud_init` when set (same encoding as scale set `custom_data`). |
| <a name="output_run_script"></a> [run\_script](#output\_run\_script) | JSON settings for the CustomScript extension when `vmss.run_script` is set. |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | Platform-assigned unique ID of the scale set. |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | Resource ID of the Linux virtual machine scale set. |

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-vmss/_examples/basic) — Skeleton with placeholders; replace RG, VNet, subnet, SSH key, and public IP prefix before apply.

## Remote resources

- **Virtual Machine Scale Sets**: [https://learn.microsoft.com/azure/virtual-machine-scale-sets/](https://learn.microsoft.com/azure/virtual-machine-scale-sets/)
- **Terraform `azurerm_linux_virtual_machine_scale_set`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->