## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.16.0 |

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
| <a name="input_common"></a> [common](#input\_common) | VARIABLES SECTION | <pre>object({<br/>    resource_group_name = string<br/>    location            = string<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_vmss"></a> [vmss](#input\_vmss) | n/a | <pre>object({<br/>    name                        = string<br/>    sku                         = string<br/>    instances                   = optional(number)<br/>    admin_username              = string<br/>    admin_ssh_key_username      = string<br/>    first_public_key            = optional(string)<br/>    eviction_policy             = optional(string)<br/>    secure_boot_enabled         = optional(bool)<br/>    platform_fault_domain_count = optional(number)<br/>    encryption_at_host_enabled  = optional(bool)<br/>    vtpm_enabled                = optional(bool)<br/>    zones                       = optional(list(string))<br/>    computer_name_prefix        = optional(string)<br/><br/>    disk_storage_account_type = string<br/>    disk_caching              = string<br/>    data_disk = optional(object({<br/>      name                 = optional(string)<br/>      caching              = string<br/>      create_option        = optional(string)<br/>      disk_size_gb         = number<br/>      lun                  = number<br/>      storage_account_type = string<br/>    }))<br/><br/>    upgrade_mode                                                   = string<br/>    rolling_upgrade_policy_max_batch_instance_percent              = number<br/>    rolling_upgrade_policy_max_unhealthy_instance_percent          = number<br/>    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = number<br/>    rolling_upgrade_policy_pause_time_between_batches              = string<br/>    rolling_upgrade_policy_cross_zone_upgrades_enabled             = bool<br/>    rolling_upgrade_policy_maximum_surge_instances_enabled         = bool<br/>    rolling_upgrade_policy_prioritize_unhealthy_instances_enabled  = bool<br/><br/>    image_publisher = string<br/>    image_offer     = string<br/>    image_sku       = string<br/>    image_version   = string<br/><br/>    edge_zone                           = optional(string)<br/>    network_primary                     = optional(bool)<br/>    network_ip_primary                  = optional(bool)<br/>    network_security_group_id           = optional(string)<br/>    subnet_name                         = optional(string)<br/>    virtual_network_name                = optional(string)<br/>    virtual_network_resource_group_name = optional(string)<br/>    prefix_length                       = optional(number)<br/><br/>    scale_in_rule                   = optional(string)<br/>    scale_in_force_deletion_enabled = optional(bool)<br/><br/>    network_interface_ip_configuration_application_gateway_backend_address_pool_ids = optional(list(string))<br/>    network_interface_ip_configuration_application_security_group_ids               = optional(list(string))<br/>    network_interface_ip_configuration_load_balancer_backend_address_pool_ids       = optional(list(string))<br/>    network_interface_ip_configuration_load_balancer_inbound_nat_rules_ids          = optional(list(string))<br/>    network_interface_public_ip_adress_idle_timeout_in_minutes                      = optional(number)<br/>    network_interface_public_ip_adress_public_ip_prefix_id                          = string<br/><br/>    identity_type    = string<br/>    identity_ids     = optional(list(string))<br/>    identity_rg_name = optional(string)<br/><br/>    cloud_init = optional(string)<br/>    run_script = optional(string)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_init"></a> [cloud\_init](#output\_cloud\_init) | Output section |
| <a name="output_run_script"></a> [run\_script](#output\_run\_script) | n/a |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | n/a |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | Outputs for linux\_virtual\_machine\_scale\_set |

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

