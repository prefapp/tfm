# LOCAL SECTION
locals {
  split_subnet  = [for subnet in var.vmss.subnet_output : split("/", subnet)]
  last_elements = [for split_subnet in local.split_subnet : split_subnet[length(split_subnet) - 1]]
  subnet        = [for i, last_element in local.last_elements : var.vmss.subnet_output[i] if last_element == var.vmss.subnet_name][0]
}

# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/4.3.0/docs/resources/linux_virtual_machine_scale_set
resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                        = var.vmss.name
  resource_group_name         = var.common.resource_group_name
  location                    = var.common.location
  sku                         = var.vmss.sku
  instances                   = var.vmss.instances
  admin_username              = var.vmss.admin_username
  tags                        = var.common.tags
  edge_zone                   = var.vmss.edge_zone
  eviction_policy             = var.vmss.eviction_policy
  encryption_at_host_enabled  = var.vmss.encryption_at_host_enabled
  platform_fault_domain_count = var.vmss.platform_fault_domain_count
  secure_boot_enabled         = var.vmss.secure_boot_enabled
  vtpm_enabled                = var.vmss.vtpm_enabled
  zones                       = var.vmss.zones
  computer_name_prefix        = var.vmss.computer_name_prefix
  # template_cloudinit_config
  custom_data  = base64encode(var.vmss.cloud_init)
  upgrade_mode = var.vmss.upgrade_mode
  rolling_upgrade_policy {
    max_batch_instance_percent              = var.vmss.rolling_upgrade_policy_max_batch_instance_percent
    max_unhealthy_instance_percent          = var.vmss.rolling_upgrade_policy_max_unhealthy_instance_percent
    max_unhealthy_upgraded_instance_percent = var.vmss.rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent
    pause_time_between_batches              = var.vmss.rolling_upgrade_policy_pause_time_between_batches
    cross_zone_upgrades_enabled             = var.vmss.rolling_upgrade_policycross_zone_upgrades_enabled
    maximum_surge_instances_enabled         = var.vmss.rolling_upgrade_policymaximum_surge_instances_enabled
    prioritize_unhealthy_instances_enabled  = var.vmss.rolling_upgrade_policyprioritize_unhealthy_instances_enabled
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
      name                                         = var.vmss.name
      primary                                      = var.vmss.network_ip_primary
      subnet_id                                    = local.subnet
      application_gateway_backend_address_pool_ids = var.vmss.network_interface_ip_configuration_application_gateway_backend_address_pool_ids
      application_security_group_ids               = var.vmss.network_interface_ip_configuration_application_security_group_ids
      load_balancer_backend_address_pool_ids       = var.vmss.network_interface_ip_configuration_load_balancer_inbound_nat_rules_ids
      load_balancer_inbound_nat_rules_ids          = var.vmss.network_interface_ip_configuration_load_balancer_inbound_nat_rules_ids

      public_ip_address {
        name = "${var.vmss.name}-publicIP"
        idle_timeout_in_minutes = var.vmss.network_interface_public_ip_adress_idle_timeout_in_minutes
        #public_ip_prefix        = var.vmss.network_interface_public_ip_adress_public_ip_prefix
      }
    }
  }

  scale_in {
    force_detention_enabled = var.vmss.force_detention_enabled
    rule = var.vmss.rule
  }

  identity {
    type         = var.vmss.identity_type
    identity_ids = var.vmss.identity_ids
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

# https://registry.terraform.io/providers/hashicorp/azurerm/4.3.0/docs/resources/virtual_machine_scale_set_extension
resource "azurerm_virtual_machine_scale_set_extension" "this" {
  name                         = "${var.vmss.name}-extension"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.this.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.1"
  auto_upgrade_minor_version   = false
  settings = jsonencode({
    "script" = base64encode(var.vmss.run_script)
  })
}

