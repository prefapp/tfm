# VARIABLES SECTION
variable "common" {
  type = object({
    resource_group_name = string
    location            = string
  })
}

variable "admin_password" {
  description = "Admin password for the VM. If not provided, it will be fetched from Key Vault."
  type = object({
    key_vault_name      = string
    resource_group_name = string
    secret_name         = string
  })
  default = null
}

variable "vm" {
  type = object({
    name                         = string
    size                         = string
    admin_username               = string
    admin_password               = optional(string)
    network_interface_ids        = optional(list(string))
    edge_zone                    = optional(string)
    eviction_policy              = optional(string)
    encryption_at_host_enabled   = optional(bool)
    secure_boot_enabled          = optional(bool)
    vtpm_enabled                 = optional(bool)
    custom_data                  = optional(string)
    provision_vm_agent           = optional(bool)
    enable_automatic_updates     = optional(bool)
    license_type                 = optional(string)
    timezone                     = optional(string)
    patch_mode                   = optional(string)
    boot_diagnostics_storage_uri = optional(string)
    winrm_certificate_url        = optional(string)
    winrm_protocol               = optional(string)

    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })

    os_disk = object({
      caching              = string
      disk_size_gb         = number
      storage_account_type = string
    })

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
  })

  validation {
    condition = var.vm.identity == null ? true : contains(
      ["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"],
      var.vm.identity.type
    )
    error_message = "identity_type must be one of 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }

  validation {
    condition = var.vm.identity == null ? true : (
      (
        var.vm.identity.type == "UserAssigned" ||
        var.vm.identity.type == "SystemAssigned, UserAssigned"
      ) ? (var.vm.identity.identity_ids != null) : true
    )
    error_message = "identity_ids must be provided when identity_type is 'UserAssigned' or 'SystemAssigned, UserAssigned'."
  }
}

variable "nic" {
  type = object({
    name                                               = optional(string)
    subnet_name                                        = optional(string)
    virtual_network_name                               = optional(string)
    virtual_network_resource_group_name                = optional(string)
    subnet_id                                          = optional(string)
    auxiliary_mode                                     = optional(string)
    auxiliary_sku                                      = optional(string)
    accelerated_networking_enabled                     = optional(bool)
    ip_forwarding_enabled                              = optional(bool)
    ip_configuration_name                              = optional(string)
    edge_zone                                          = optional(string)
    dns_servers                                        = optional(list(string))
    internal_dns_name_label                            = optional(string)
    gateway_load_balancer_frontend_ip_configuration_id = optional(string)
    private_ip_address_version                         = optional(string)
    private_ip_address_allocation                      = optional(string, "Dynamic")
    public_ip_address_id                               = optional(string)
    primary                                            = optional(bool)
    private_ip_address                                 = optional(string)
    nsg = object({
      name                = optional(string)
      resource_group_name = optional(string)
    })
    public_ip = object({
      name                = optional(string)
      resource_group_name = optional(string)
    })
  })
  default = null
}

variable "tags_from_rg" {
  description = "Use resource group tags as base for module tags"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
