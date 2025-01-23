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
    name                                                           = string
    sku                                                            = string
    instances                                                      = optional(number)
    admin_username                                                 = string
    first_public_key                                               = optional(string)
    edge_zone                                                      = optional(string)
    eviction_policy                                                = optional(string)
    data_disk = optional(object({
      name                                                         = optional(string)
      caching                                                      = string
      create_option                                                = optional(string)
      disk_size_gb                                                 = number
      lun                                                          = number
      storage_account_type                                         = string
    }))
    template_cloudinit_config                                      = string
    upgrade_mode                                                   = string
    rolling_upgrade_policy_max_batch_instance_percent              = number
    rolling_upgrade_policy_max_unhealthy_instance_percent          = number
    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = number
    rolling_upgrade_policy_pause_time_between_batches              = string
    admin_ssh_key_username                                         = string
    image_publisher                                                = string
    image_offer                                                    = string
    image_sku                                                      = string
    image_version                                                  = string
    disk_storage_account_type                                      = string
    disk_caching                                                   = string
    network_primary                                                = optional(bool)
    network_ip_primary                                             = optional(bool)
    identity_type                                                  = string
    identity_ids                                                   = optional(list(string))
    identity_rg_name                                               = optional(string)
    run_script                                                     = optional(string)
    prefix_length                                                  = optional(number)
  })
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.vmss.identity_type)
    error_message = "identity_type must be one of 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }
  validation {
    condition     = (
      var.vmss.identity_type == "UserAssigned" || var.vmss.identity_type == "SystemAssigned, UserAssigned"
    ) ? (var.vmss.identity_ids != null) : true
    error_message = "identity_ids must be provided when identity_type is 'UserAssigned' or 'SystemAssigned, UserAssigned'."
  }
}
