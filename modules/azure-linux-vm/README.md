## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/network_interface) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/key_vault_secret) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for the VM. If not provided, it will be fetched from Key Vault. | <pre>optional(object({<br/>    key_vault_name        = string<br/>    resource_group_name   = string<br/>    secret_name          = string<br/>  }))</pre> | n/a | yes |
| <a name="input_nic"></a> [nic](#input\_nic) | n/a | <pre>object({<br/>    name                                               = string<br/>    location                                           = string<br/>    resource_group_name                                = string<br/>    subnet_name                                        = optional(string)<br/>    virtual_network_name                               = optional(string)<br/>    virtual_network_resource_group_name                = optional(string)<br/>    subnet_id                                          = optional(string)<br/>    auxiliary_mode                                     = optional(string)<br/>    auxiliary_sku                                      = optional(string)<br/>    accelerated_networking_enabled                     = optional(bool)<br/>    ip_forwarding_enabled                              = optional(bool)<br/>    edge_zone                                          = optional(string)<br/>    dns_servers                                        = optional(list(string))<br/>    internal_dns_name_label                            = optional(string)<br/>    gateway_load_balancer_frontend_ip_configuration_id = optional(string)<br/>    private_ip_address_version                         = optional(string)<br/>    private_ip_address_allocation                      = optional(string)<br/>    public_ip_address_id                               = optional(string)<br/>    primary                                            = optional(bool)<br/>    private_ip_address                                 = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_vm"></a> [vm](#input\_vm) | n/a | <pre>object({<br/>    name                            = string<br/>    resource_group_name             = string<br/>    location                        = string<br/>    size                            = string<br/>    admin_username                  = string<br/>    admin_password                  = optional(string)<br/>    edge_zone                       = optional(string)<br/>    eviction_policy                 = optional(string)<br/>    encryption_at_host_enabled      = optional(bool)<br/>    secure_boot_enabled             = optional(bool)<br/>    vtpm_enabled                    = optional(bool)<br/>    disable_password_authentication = optional(bool)<br/>    network_interface_ids           = list(string)<br/>    custom_data                     = optional(string)<br/><br/>    admin_ssh_key = object({<br/>      username   = string<br/>      public_key = string<br/>    })<br/><br/>    source_image_reference = object({<br/>      publisher = string<br/>      offer     = string<br/>      sku       = string<br/>      version   = string<br/>    })<br/><br/>    os_disk = object({<br/>      caching              = string<br/>      disk_size_gb         = number<br/>      storage_account_type = string<br/>    })<br/><br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/><br/>    data_disk = optional(object({<br/>      name                 = optional(string)<br/>      caching              = string<br/>      create_option        = optional(string)<br/>      disk_size_gb         = number<br/>      lun                  = number<br/>      storage_account_type = string<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_init"></a> [cloud\_init](#output\_cloud\_init) | Output section |
| <a name="output_run_script"></a> [run\_script](#output\_run\_script) | n/a |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | n/a |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | Outputs for linux\_virtual\_machine\_scale\_set |

## Example Usage

```hcl
module "azure_linux_vm" {
  source              = "../modules/azure-linux-vm"
  tags_from_rg        = true
  admin_password = {
    key_vault_name      = "example-kv"
    resource_group_name = "example-rg"
    secret_name        = "vm-admin-password"
  }
  vm = {
    name                = "example-vm"
    resource_group_name = "example-rg"
    location            = "East US"
    size                = "Standard_DS1_v2"
    admin_username      = "adminuser"
    network_interface_ids = [module.azure_nic.nic_id]
    source_image_reference = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }
    os_disk = {
      caching              = "ReadWrite"
      disk_size_gb         = 30
      storage_account_type = "Standard_LRS"
    }
    admin_ssh_key = {
      username   = "adminuser"
      public_key = file("~/.ssh/id_rsa.pub")
    }
  }
  nic = {
    name                 = "example-nic"
    location             = "East US"
    resource_group_name  = "example-rg"
    subnet_name          = "example-subnet"
    virtual_network_name = "example-vnet"
    virtual_network_resource_group_name = "example-rg"
  }
}
```

```yaml
values:
  tags_from_rg: true
  admin_password:
    key_vault_name: example-kv
    resource_group_name: example-rg
    secret_name: vm-admin-password
  vm:
    name: example-vm
    resource_group_name: example-rg
    location: East US
    size: Standard_DS1_v2
    admin_username: adminuser
    network_interface_ids:
      - ${module.azure_nic.nic_id}
    source_image_reference:
      publisher: Canonical
      offer: UbuntuServer
      sku: 18.04-LTS
      version: latest
    os_disk:
      caching: ReadWrite
      disk_size_gb: 30
      storage_account_type: Standard_LRS
    admin_ssh_key:
      username: adminuser
      public_key: ${file("~/.ssh/id_rsa.pub")}
  nic:
    name: example-nic
    location: East US
    resource_group_name: example-rg
    subnet_name: example-subnet
    virtual_network_name: example-vnet
    virtual_network_resource_group_name: example-rg
```
