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
| [azurerm_public_ip_prefix.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_security_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common"></a> [common](#input\_common) | n/a | <pre>object({<br/>    resource_group_name = string<br/>    location            = string<br/>    tags                = map(string)<br/>  })</pre> | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | n/a | <pre>object({<br/>    enable_nsg     = bool<br/>    vnet_name      = string<br/>    subnet_name    = string<br/>    subnet_rg_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_public_ip_prefix"></a> [public\_ip\_prefix](#input\_public\_ip\_prefix) | n/a | <pre>object({<br/>    name                = string<br/>    location            = string<br/>    resource_group_name = string<br/>    prefix_length       = number<br/>    tags                = map(string)<br/>  })</pre> | n/a | yes |
| <a name="input_vmss"></a> [vmss](#input\_vmss) | n/a | <pre>object({<br/>    name                                                           = string<br/>    sku                                                            = string<br/>    instances                                                      = number<br/>    admin_username                                                 = string<br/>    first_public_key                                               = string<br/>    template_cloudinit_config                                      = string<br/>    upgrade_mode                                                   = string<br/>    rolling_upgrade_policy_max_batch_instance_percent              = number<br/>    rolling_upgrade_policy_max_unhealthy_instance_percent          = number<br/>    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = number<br/>    rolling_upgrade_policy_pause_time_between_batches              = string<br/>    admin_ssh_key_username                                         = string<br/>    image_publisher                                                = string<br/>    image_offer                                                    = string<br/>    image_sku                                                      = string<br/>    image_version                                                  = string<br/>    disk_storage_account_type                                      = string<br/>    disk_caching                                                   = string<br/>    network_primary                                                = bool<br/>    network_ip_primary                                             = bool<br/>    identity_type                                                  = string<br/>    run_script                                                     = string<br/>    prefix_length                                                  = number<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_output_run_script"></a> [output\_run\_script](#output\_output\_run\_script) | n/a |
| <a name="output_output_template_cloudinit_config"></a> [output\_template\_cloudinit\_config](#output\_output\_template\_cloudinit\_config) | Output section |
