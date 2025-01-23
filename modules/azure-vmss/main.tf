# LOCAL SECTION
locals {
  split_subnet = [for subnet in var.vmss.subnet_output : split("/", subnet)]
  last_elements = [for split_subnet in local.split_subnet : split_subnet[length(split_subnet) - 1]]
  subnet = [for i, last_element in range(local.last_elements) : var.vmss.subnet_output[i] if last_element == "soups"][0]
}

output "last_element" {
  value = local.last_elements
}

output "subnet" {
  value = local.subnet
}


# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/linux_virtual_machine_scale_set
resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = var.vmss.name
  resource_group_name = var.common.resource_group_name
  location            = var.common.location
  sku                 = var.vmss.sku
  instances           = var.vmss.instances
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
    public_key = var.vmss.first_public_key
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
    network_security_group_id = var.vmss.network_security_group_id

    ip_configuration {
      name      = var.vmss.name
      primary   = var.vmss.network_ip_primary
      # subnet_id = var.vmss.subnet_id
      # subnet_id = [for id in var.vmss.subnet_output : id if contains(id, var.vmss.subnet_name)][0]
      subnet_id = var.vmss.subnet_output[0]

      public_ip_address {
        name                = "${var.vmss.name}-publicIP"
      }
    }
  }

  identity {
    type         = var.vmss.identity_type
    identity_ids = var.vmss.identity_ids
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

  dynamic "data_disk" {
    for_each = var.vmss.data_disk != null ? [var.vmss.data_disk] : []
    content {
      name                 = data_disk.value.name
      caching              = data_disk.value.caching
      create_option        = data_disk.value.create_option
      disk_size_gb         = data_disk.value.disk_size_gb
      lun                  = data_disk.value.lun
      storage_account_type = data_disk.value.storage_account_type
    }
  }
}

