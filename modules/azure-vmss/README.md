## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_virtual_machine_scale_set_extension.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.3.0/docs/resources/virtual_machine_scale_set_extension) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common"></a> [common](#input\_common) | Common configuration for the resource group and location. | <pre>object({<br/>    resource_group_name = string<br/>    location            = string<br/>    tags                = map(string)<br/>  })</pre> | N/A | True |
| <a name="input_vmss"></a> [vmss](#input\_vmss) | Configuration of the Virtual Machine Scale Set. | <pre>object({<br/>    name                        = string<br/>    sku                         = string<br/>    instances                   = optional(number)<br/>    admin_username              = string<br/>    admin_ssh_key_username      = string<br/>    first_public_key            = optional(string)<br/>    eviction_policy             = optional(string)<br/>    secure_boot_enabled         = optional(bool)<br/>    platform_fault_domain_count = optional(number)<br/>    encryption_at_host_enabled  = optional(bool)<br/>    vtpm_enabled                = optional(bool)<br/>    zones                       = optional(list(string))<br/>    computer_name_prefix        = optional(string)<br/><br/>    disk_storage_account_type = string<br/>    disk_caching              = string<br/>    data_disk = optional(object({<br/>      name                 = optional(string)<br/>      caching              = string<br/>      create_option        = optional(string)<br/>      disk_size_gb         = number<br/>      lun                  = number<br/>      storage_account_type = string<br/>    }))<br/><br/>    upgrade_mode                                                   = string<br/>    rolling_upgrade_policy_max_batch_instance_percent              = number<br/>    rolling_upgrade_policy_max_unhealthy_instance_percent          = number<br/>    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = number<br/>    rolling_upgrade_policy_pause_time_between_batches              = string<br/>    rolling_upgrade_policy_cross_zone_upgrades_enabled             = bool<br/>    rolling_upgrade_policy_maximum_surge_instances_enabled         = bool<br/>    rolling_upgrade_policy_prioritize_unhealthy_instances_enabled  = bool<br/><br/>    image_publisher = string<br/>    image_offer     = string<br/>    image_sku       = string<br/>    image_version   = string<br/><br/>    edge_zone                 = optional(string)<br/>    network_primary           = optional(bool)<br/>    network_ip_primary        = optional(bool)<br/>    network_security_group_id = optional(string)<br/>    subnet_output             = optional(list(string))<br/>    subnet_name               = optional(string)<br/>    prefix_length             = optional(number)<br/><br/>    scale_in_rule                    = optional(string)<br/>    scale_in_force_deletion_enabled = optional(bool)<br/><br/>    network_interface_ip_configuration_application_gateway_backend_address_pool_ids = optional(list(string))<br/>    network_interface_ip_configuration_application_security_group_ids               = optional(list(string))<br/>    network_interface_ip_configuration_load_balancer_backend_address_pool_ids       = optional(list(string))<br/>    network_interface_ip_configuration_load_balancer_inbound_nat_rules_ids          = optional(list(string))<br/>    network_interface_public_ip_adress_idle_timeout_in_minutes                      = optional(number)<br/>    network_interface_public_ip_adress_public_ip_prefix_id                          = string<br/><br/>    identity_type    = string<br/>    identity_ids     = optional(list(string))<br/>    identity_rg_name = optional(string)<br/><br/>    cloud_init = optional(string)<br/>    run_script = optional(string)<br/>  })</pre> | N/A | True |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_init"></a> [cloud_init](#output\_cloud\_init) | Base64-encoded cloud-init content. |
| <a name="output_run_script"></a> [run_script](#output\_run\_script) | JSON-encoded startup script. |
| <a name="output_vmss_id"></a> [vmss_id](#output\_vmss_id) | Unique identifier of the Virtual Machine Scale Set. |
| <a name="output_unique_id"></a> [unique_id](#output\_unique_id) | Generated unique ID for the Virtual Machine Scale Set. |
| <a name="output_vmss_identity"></a> [vmss_identity](#output\_vmss_identity) | Details of the assigned identity for the Virtual Machine Scale Set. |

## Example usage

```yaml
  common = {
    resource_group_name = "my-resource-group"
    location            = "eastus"
    tags = {
      environment = "production"
    }
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
´´´

