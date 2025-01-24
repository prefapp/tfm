# VARIABLES SECTION
variable "common" {
  type = object({
    resource_group_name = string
    location            = string
    tags                = map(string)
  })
}

variable "vmss" {
  type = object({
    name                        = string
    sku                         = string
    instances                   = optional(number)
    admin_username              = string
    admin_ssh_key_username      = string
    first_public_key            = optional(string)
    eviction_policy             = optional(string)
    secure_boot_enabled         = optional(bool)
    platform_fault_domain_count = optional(number)
    encryption_at_host_enabled  = optional(bool)
    vtpm_enabled                = optional(bool)
    zones                       = optional(list(string))
    computer_name_prefix        = optional(string)

    disk_storage_account_type = string
    disk_caching              = string
    data_disk = optional(object({
      name                 = optional(string)
      caching              = string
      create_option        = optional(string)
      disk_size_gb         = number
      lun                  = number
      storage_account_type = string
    }))

    upgrade_mode                                                   = string
    rolling_upgrade_policy_max_batch_instance_percent              = number
    rolling_upgrade_policy_max_unhealthy_instance_percent          = number
    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = number
    rolling_upgrade_policy_pause_time_between_batches              = string
    rolling_upgrade_policy_cross_zone_upgrades_enabled             = bool
    rolling_upgrade_policy_maximum_surge_instances_enabled         = bool
    rolling_upgrade_policy_prioritize_unhealthy_instances_enabled  = bool

    image_publisher = string
    image_offer     = string
    image_sku       = string
    image_version   = string

    edge_zone                 = optional(string)
    network_primary           = optional(bool)
    network_ip_primary        = optional(bool)
    network_security_group_id = optional(string)
    subnet_output             = optional(list(string))
    subnet_name               = optional(string)
    prefix_length             = optional(number)

    scale_in_rule                    = optional(string)
    scale_in_force_deletion_enabled = optional(bool)

    network_interface_ip_configuration_application_gateway_backend_address_pool_ids = optional(list(string))
    network_interface_ip_configuration_application_security_group_ids               = optional(list(string))
    network_interface_ip_configuration_load_balancer_backend_address_pool_ids       = optional(list(string))
    network_interface_ip_configuration_load_balancer_inbound_nat_rules_ids          = optional(list(string))
    network_interface_public_ip_adress_idle_timeout_in_minutes                      = optional(number)
    network_interface_public_ip_adress_public_ip_prefix_id                          = string

    identity_type    = string
    identity_ids     = optional(list(string))
    identity_rg_name = optional(string)

    cloud_init = optional(string)
    run_script = optional(string)
  })

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.vmss.identity_type)
    error_message = "identity_type must be one of 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }

  validation {
    condition = (
      var.vmss.identity_type == "UserAssigned" || var.vmss.identity_type == "SystemAssigned, UserAssigned"
    ) ? (var.vmss.identity_ids != null) : true
    error_message = "identity_ids must be provided when identity_type is 'UserAssigned' or 'SystemAssigned, UserAssigned'."
  }
}
