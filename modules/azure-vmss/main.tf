# DATA SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/subnet
data "azurerm_subnet" "this" {
  name                 = var.network.subnet_name
  virtual_network_name = var.network.vnet_name
  resource_group_name  = var.network.subnet_rg_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/network_security_group
data "azurerm_network_security_group" "this" {
  count               = var.network.enable_nsg ? 1 : 0
  name                = "${var.vmss.name}-nsg"
  resource_group_name = var.common.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/user_assigned_identity
data "azurerm_user_assigned_identity" "this" {
  count               = strcontains(var.vmss.identity_type, "UserAssigned") ? 1 : 0
  name                = "${var.vmss.name}-mi"
  resource_group_name = var.common.resource_group_name
}

# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix
resource "azurerm_public_ip_prefix" "this" {
  count               = var.vmss.prefix_length != null ? 1 : 0
  name                = var.public_ip_prefix.name
  location            = var.common.location
  resource_group_name = var.common.resource_group_name
  prefix_length       = var.vmss.prefix_length
  tags                = var.common.tags
  ip_version          = var.public_ip_prefix.ip_version
}

# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/linux_virtual_machine_scale_set
resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = var.vmss.name
  resource_group_name = var.common.resource_group_name
  location            = var.common.location
  sku                 = var.vmss.sku
  instances           = var.vmss_.instances
  admin_username      = var.vmss.admin_username
  tags                = var.common.tags
  edge_zone           = var.vmss.edge_zone
  eviction_policy     = var.vmss.eviction_policy
  # template_cloudinit_config
  custom_data  = base64encode(var.vmss.template_cloudinit_config)
  upgrade_mode = var.vmss.upgrade_mode
  rolling_upgrade_policy {
    max_batch_instance_percent              = var.vmss.rolling_upgrade_policy_max_batch_instance_percent
    max_unhealthy_instance_percent          = var.vmss.rolling_upgrade_policy_max_unhealthy_instance_percent
    max_unhealthy_upgraded_instance_percent = var.vmss.rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent
    pause_time_between_batches              = var.vmss.rolling_upgrade_policy_pause_time_between_batches
  }

  admin_ssh_key {
    username   = var.vmss.admin_ssh_key_username
    public_key = var.common.first_public_key
  }

  source_image_reference {
    publisher = var.vmss.image_publisher
    offer     = var.vmss.image_offer
    sku       = var.vmss.image_sku
    version   = var.vmss.image_version
  }

  os_disk {
    storage_account_type = var.vmss.disk_storage_account_type
    caching              = var.vmss.disk_caching
  }

  network_interface {
    name                      = var.vmss.name
    primary                   = var.vmss.network_primary
    network_security_group_id = data.azurerm_network_security_group.this[count.index].id

    ip_configuration {
      name      = var.vmss.name
      primary   = var.vmss.network_ip_primary
      subnet_id = data.azurerm_subnet.this.id

      public_ip_address {
        name                = "${var.vmss.name}-publicIP"
        public_ip_prefix_id = azurerm_public_ip_prefix.this[count.index].id
      }
    }
  }

  identity {
    type         = var.vmss.identity_type
    identity_ids = [data.azurerm_user_assigned_identity.this[count.index].id]
  }

  extension {
    name                       = "${var.vmss.name}-extension"
    publisher                  = "Microsoft.Azure.Extensions"
    type                       = "CustomScript"
    type_handler_version       = "2.1"
    auto_upgrade_minor_version = false
    # run_script
    settings = jsonencode({
      "script" = base64encode(var.vmss.run_script)
    })
  }

  data_disk {
    name                 = var.vmss.data_disk_name
    caching              = var.vmss.data_disk_catching
    create_option        = var.vmss.data_disk_create_option
    disk_size_gb         = var.vmss.data_disk_disk_size_gb
    lun                  = var.vmss.data_disk_lun
    storage_account_type = var.vmss.data_disk_storage_account_type
  }
}

