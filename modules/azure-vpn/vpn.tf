resource "azurerm_virtual_network_gateway" "this" {
  name                = var.vpn.name
  location            = var.vpn.location
  resource_group_name = var.vpn.resource_group_name
  type                = var.vpn.type
  vpn_type            = var.vpn.vpn_type
  active_active       = var.vpn.active_active
  enable_bgp          = var.vpn.enable_bgp
  sku                 = var.vpn.sku
  tags                = local.tags

  ip_configuration {
    name                          = "${var.vpn.ip.name}-ipconfig"
    public_ip_address_id          = data.azurerm_public_ip.this.id
    private_ip_address_allocation = var.vpn.ip.allocation_method
    subnet_id                     = data.azurerm_subnet.this.id
  }

  custom_route {
    address_prefixes = var.vpn.custom_route.address_prefixes
  }

  vpn_client_configuration {
    address_space = var.vpn.vpn_client.address_space
    aad_audience  = var.vpn.vpn_client.aad_audience
    aad_issuer    = var.vpn.vpn_client.aad_issuer
    aad_tenant     = var.vpn.vpn_client.aad_tenant
    dynamic "root_certificate" {
      for_each = var.vpn.vpn_client.public_cert_data != null ? [var.vpn.vpn_client] : []
      content {
        name             = root_certificate.value.root_certificate_name
        public_cert_data = root_certificate.value.public_cert_data
      }
    }
  }
}
