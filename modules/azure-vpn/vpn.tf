## VPN SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway
resource "azurerm_virtual_network_gateway" "this" {
	name                = var.vpn.gateway_name
	location            = var.vpn.location
	resource_group_name = var.vpn.resource_group_name
	type                = var.vpn.type
	vpn_type            = var.vpn.vpn_type
	sku                 = var.vpn.sku
	ip_configuration {
		name                          = var.vpn.ip_name
		subnet_id                     = var.vpn.gateway_subnet_id
		public_ip_address_id          = var.vpn.public_ip_id
	}
	enable_bgp            = false
	vpn_client_configuration {
		address_space        = var.vpn.vpn_client_address_space
		vpn_client_protocols = var.vpn.vpn_client_protocols
		dynamic "root_certificate" {
			for_each = var.vpn.root_certificates
			content {
				name        = root_certificate.value.name
					public_cert_data = coalesce(
					  try(root_certificate.value.public_cert_data, null),
					  try(root_certificate.value.public_cert, null)
					)
			}
		}
	}
}
