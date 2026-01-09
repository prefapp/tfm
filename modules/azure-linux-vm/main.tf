# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.vm.name
  resource_group_name             = var.common.resource_group_name
  location                        = var.common.location
  size                            = var.vm.size
  admin_username                  = var.vm.admin_username
  admin_password                  = coalesce(var.vm.disable_password_authentication, false) ? null : try(data.azurerm_key_vault_secret.this[0].value, var.vm.admin_password)
  edge_zone                       = var.vm.edge_zone
  eviction_policy                 = var.vm.eviction_policy
  encryption_at_host_enabled      = var.vm.encryption_at_host_enabled
  secure_boot_enabled             = var.vm.secure_boot_enabled
  vtpm_enabled                    = var.vm.vtpm_enabled
  os_managed_disk_id              = var.vm.os_managed_disk_id
  disable_password_authentication = var.vm.disable_password_authentication
  custom_data                     = var.vm.custom_data != null ? base64encode(var.vm.custom_data) : null
  provision_vm_agent              = var.vm.provision_vm_agent
  license_type                    = var.vm.license_type != null ? var.vm.license_type : null
  patch_mode                      = var.vm.patch_mode != null ? var.vm.patch_mode : null
  tags                            = local.tags

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  dynamic "admin_ssh_key" {
    for_each = var.vm.admin_ssh_key != null ? [var.vm.admin_ssh_key] : []
    content {
      username   = admin_ssh_key.value.username
      public_key = admin_ssh_key.value.public_key
    }
  }

  dynamic "source_image_reference" {
    for_each = var.vm.source_image_reference != null ? [var.vm.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  os_disk {
    name                 = var.vm.os_disk.name
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

  dynamic "additional_capabilities" {
    for_each = var.vm.additional_capabilities != null ? [var.vm.additional_capabilities] : []
    content {
      ultra_ssd_enabled   = additional_capabilities.value.ultra_ssd_enabled
      hibernation_enabled = additional_capabilities.value.hibernation_enabled
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "this" {
  count                          = var.nic != null ? 1 : 0
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
    public_ip_address_id = (
      var.nic != null && var.nic.public_ip != null ? data.azurerm_public_ip.this[0].id :
      var.nic != null ? var.nic.public_ip_address_id :
      null
    )
    primary                                            = var.nic.primary
    private_ip_address                                 = var.nic.private_ip_address
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association
resource "azurerm_network_interface_security_group_association" "this" {
  count                     = var.nic != null && var.nic.nsg != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.this[0].id
  network_security_group_id = data.azurerm_network_security_group.this[0].id
}
