# DATA SECTION
data "azurerm_subnet" "this" {
  count = var.nic != null && var.nic.subnet_name != null && var.nic.virtual_network_name != null && var.nic.virtual_network_resource_group_name != null ? 1 : 0
  name                 = var.nic != null ? var.nic.subnet_name : null
  virtual_network_name = var.nic != null ? var.nic.virtual_network_name : null
  resource_group_name  = var.nic != null ? var.nic.virtual_network_resource_group_name : null
}

# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.common.resource_group_name
}

data "azurerm_key_vault" "this" {
  count               = var.admin_password != null ? 1 : 0
  name                = try(var.admin_password.key_vault_name, null)
  resource_group_name = try(var.admin_password.resource_group_name, null)
}

data "azurerm_key_vault_secret" "this" {
  count      = var.admin_password != null ? 1 : 0
  name       = try(var.admin_password.secret_name, null)
  key_vault_id = try(data.azurerm_key_vault.this[0].id, null)
}

# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "this" {
  name                            = var.vm.name
  resource_group_name             = var.common.resource_group_name
  location                        = var.common.location
  size                            = var.vm.size
  admin_username                  = var.vm.admin_username
  admin_password                  = try(data.azurerm_key_vault_secret.this[0].value, var.vm.admin_password)
  edge_zone                       = var.vm.edge_zone
  eviction_policy                 = var.vm.eviction_policy
  encryption_at_host_enabled      = var.vm.encryption_at_host_enabled
  secure_boot_enabled             = var.vm.secure_boot_enabled
  vtpm_enabled                    = var.vm.vtpm_enabled
  custom_data                     = var.vm.custom_data != null ? base64encode(var.vm.custom_data) : null
  tags                            = local.tags
  network_interface_ids           = var.nic != null ? [azurerm_network_interface.this[0].id] : var.vm.network_interface_ids
  provision_vm_agent              = var.vm.provision_vm_agent != null ? var.vm.provision_vm_agent : true
  license_type                    = var.vm.license_type != null ? var.vm.license_type : null
  timezone                        = var.vm.timezone != null ? var.vm.timezone : null
  patch_mode                      = var.vm.patch_mode != null ? var.vm.patch_mode : null

  dynamic "boot_diagnostics" {
    for_each = var.vm.boot_diagnostics_storage_uri != null ? [var.vm.boot_diagnostics_storage_uri] : []
    content {
      storage_account_uri = boot_diagnostics.value
    }
  }

  dynamic "winrm_listener" {
    for_each = var.vm.winrm_certificate_url != null ? [var.vm.winrm_certificate_url] : []
    content {
      protocol = var.vm.winrm_protocol != null ? var.vm.winrm_protocol : null
      certificate_url = var.vm.winrm_certificate_url != null ? var.vm.winrm_certificate_url : null
    }
  }

  source_image_reference {
    publisher = var.vm.source_image_reference.publisher
    offer     = var.vm.source_image_reference.offer
    sku       = var.vm.source_image_reference.sku
    version   = var.vm.source_image_reference.version
  }
  os_disk {
    caching              = var.vm.os_disk.caching
    disk_size_gb         = var.vm.os_disk.disk_size_gb
    storage_account_type = var.vm.os_disk.storage_account_type
  }
  dynamic "identity" {
    for_each = var.vm.identity != null ? [var.vm.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "this" {
  count = var.nic != null ? 1 : 0
  name                           = var.nic != null && var.nic.name != null ? var.nic.name : "${var.vm.name}-nic"
  location                       = var.common.location
  resource_group_name            = var.common.resource_group_name
  auxiliary_mode                 = var.nic != null ? var.nic.auxiliary_mode : null
  auxiliary_sku                  = var.nic != null ? var.nic.auxiliary_sku : null
  accelerated_networking_enabled = var.nic != null ? var.nic.accelerated_networking_enabled : null
  ip_forwarding_enabled          = var.nic != null ? var.nic.ip_forwarding_enabled : null
  edge_zone                      = var.nic != null ? var.nic.edge_zone : null
  dns_servers                    = var.nic != null ? var.nic.dns_servers : null
  internal_dns_name_label        = var.nic != null ? var.nic.internal_dns_name_label : null
  tags                           = local.tags

  ip_configuration {
    name                                               = var.nic != null && var.nic.ip_configuration_name != null ? var.nic.ip_configuration_name : "${var.vm.name}-ipconfig"
    gateway_load_balancer_frontend_ip_configuration_id = var.nic != null ? var.nic.gateway_load_balancer_frontend_ip_configuration_id : null
    subnet_id                                          = var.nic != null && var.nic.subnet_id != null ? var.nic.subnet_id : (var.nic != null ? data.azurerm_subnet.this[0].id : null)
    private_ip_address_version                         = var.nic != null ? var.nic.private_ip_address_version : null
    private_ip_address_allocation                      = var.nic != null ? var.nic.private_ip_address_allocation : null
    public_ip_address_id                               = var.nic != null ? var.nic.public_ip_address_id : null
    primary                                            = var.nic != null ? var.nic.primary : null
    private_ip_address                                 = var.nic != null ? var.nic.private_ip_address : null
  }
}
