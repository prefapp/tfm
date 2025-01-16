# VARIABLES SECTION

variable "common" {
  type = object({
    resource_group_name = string
    location            = string
    tags                = map(string)
  })
}

variable "network" {
  type = object({
    enable_nsg     = bool
    vnet_name      = string
    subnet_name    = string
    subnet_rg_name = string
  })
}

variable "public_ip_prefix" {
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    prefix_length       = number
    ip_version          = optional(string)
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
    data_disk_name                                                 = optional(string)
    data_disk_size_catching                                        = optional(string)
    data_disk_create_option                                        = optional(string)
    data_disk_disk_size_gb                                         = optional(number)
    data_disk_lun                                                  = optional(number)
    data_disk_storage_account_type                                 = optional(string)
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
    run_script                                                     = optional(string)
    prefix_length                                                  = optional(number)
  })
}
