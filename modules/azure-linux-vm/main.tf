# DATA SECTION
data "azurerm_subnet" "this" {
  count = var.nic.subnet_name != null && var.nic.virtual_network_name != null && var.nic.virtual_network_resource_group_name != null ? 1 : 0
  name                 = var.nic.subnet_name
  virtual_network_name = var.nic.virtual_network_name
  resource_group_name  = var.nic.virtual_network_resource_group_name
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
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.vm.name
  resource_group_name             = var.common.resource_group_name
  location                        = var.common.location
  size                            = var.vm.size
  admin_username                  = var.vm.admin_username
  admin_password                  = var.vm.disable_password_authentication ? null : try(data.azurerm_key_vault_secret.this[0].value, var.vm.admin_password)
  edge_zone                       = var.vm.edge_zone
  eviction_policy                 = var.vm.eviction_policy
  encryption_at_host_enabled      = var.vm.encryption_at_host_enabled
  secure_boot_enabled             = var.vm.secure_boot_enabled
  vtpm_enabled                    = var.vm.vtpm_enabled
  disable_password_authentication = var.vm.disable_password_authentication
  tags                            = local.tags

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  # template_cloudinit_config
  custom_data = var.vm.custom_data != null ? base64encode(var.vm.custom_data) : null

  dynamic "admin_ssh_key" {
    for_each = var.vm.admin_ssh_key != null ? [var.vm.admin_ssh_key] : []
    content {
      username   = admin_ssh_key.value.username
      public_key = admin_ssh_key.value.public_key
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
  name                           = var.nic.name != null ? var.nic.name : "${var.vm.name}-nic"  # O usa var.nic.name si lo tienes
  location                       = var.common.location
  resource_group_name            = var.common.resource_group_name
  auxiliary_mode                 = var.nic.auxiliary_mode
  auxiliary_sku                  = var.nic.auxiliary_sku
  accelerated_networking_enabled = var.nic.accelerated_networking_enabled
  ip_forwarding_enabled          = var.nic.ip_forwarding_enabled
  edge_zone                      = var.nic.edge_zone
  dns_servers                    = var.nic.dns_servers
  internal_dns_name_label        = var.nic.internal_dns_name_label
  tags                           = local.tags

  ip_configuration {
    name                                               = var.nic.ip_configuration_name != null ? var.nic.ip_configuration_name : "${var.vm.name}-ipconfig"
    gateway_load_balancer_frontend_ip_configuration_id = var.nic.gateway_load_balancer_frontend_ip_configuration_id
    subnet_id                                          = var.nic.subnet_id != null ? var.nic.subnet_id : data.azurerm_subnet.this[0].id
    private_ip_address_version                         = var.nic.private_ip_address_version
    private_ip_address_allocation                      = var.nic.private_ip_address_allocation
    public_ip_address_id                               = var.nic.public_ip_address_id
    primary                                            = var.nic.primary
    private_ip_address                                 = var.nic.private_ip_address
  }
}
