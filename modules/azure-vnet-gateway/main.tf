## VPN SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway
resource "azurerm_virtual_network_gateway" "this" {
	name                = var.vpn.gateway_name
	location            = var.vpn.location
	resource_group_name = var.vpn.resource_group_name
	type                = var.vpn.type
	vpn_type            = var.vpn.vpn_type
	sku                 = var.vpn.sku
	tags                = local.tags
	active_active       = var.vpn.active_active
	enable_bgp          = var.vpn.enable_bgp
	generation          = var.vpn.generation
	default_local_network_gateway_id = var.vpn.default_local_network_gateway_id
	edge_zone           = var.vpn.edge_zone
	private_ip_address_enabled = var.vpn.private_ip_address_enabled
	bgp_route_translation_for_nat_enabled = var.vpn.bgp_route_translation_for_nat_enabled
	dns_forwarding_enabled = var.vpn.dns_forwarding_enabled
	ip_sec_replay_protection_enabled = var.vpn.ip_sec_replay_protection_enabled
	remote_vnet_traffic_enabled = var.vpn.remote_vnet_traffic_enabled
	virtual_wan_traffic_enabled = var.vpn.virtual_wan_traffic_enabled

	ip_configuration {
		name                          = var.vpn.ip_name
		subnet_id                     = data.azurerm_subnet.this.id
		public_ip_address_id          = data.azurerm_public_ip.this.id
		private_ip_address_allocation = var.vpn.private_ip_address_allocation
	}

		custom_route {
			address_prefixes = var.vpn.custom_route_address_prefixes
		}

		dynamic "vpn_client_configuration" {
			for_each = length(var.vpn.vpn_client_address_space) > 0 ? [1] : []
			content {
				address_space        = var.vpn.vpn_client_address_space
				vpn_client_protocols = var.vpn.vpn_client_protocols
				aad_tenant           = var.vpn.vpn_client_aad_tenant
				aad_audience         = var.vpn.vpn_client_aad_audience
				aad_issuer           = var.vpn.vpn_client_aad_issuer
				dynamic "root_certificate" {
					for_each = var.vpn.root_certificates
					content {
						name = root_certificate.value.name
						public_cert_data = coalesce(
							root_certificate.value.public_cert_data,
							root_certificate.value.public_cert
						)
					}
				}
				dynamic "revoked_certificate" {
					for_each = var.vpn.revoked_certificates
					content {
						name       = revoked_certificate.value.name
						thumbprint = revoked_certificate.value.thumbprint
					}
				}
				vpn_auth_types = var.vpn.vpn_auth_types
			}
		}

		dynamic "bgp_settings" {
			for_each = var.vpn.bgp_settings != null ? [1] : []
			content {
				asn         = var.vpn.bgp_settings.asn
				peer_weight = var.vpn.bgp_settings.peer_weight
				dynamic "peering_addresses" {
					for_each = try(var.vpn.bgp_settings.peering_addresses, [])
					content {
						ip_configuration_name = peering_addresses.value.ip_configuration_name
						apipa_addresses      = peering_addresses.value.apipa_addresses
					}
				}
			}
		}

		dynamic "timeouts" {
			for_each = var.vpn.timeouts != null ? [1] : []
			content {
				create = var.vpn.timeouts.create
				read   = var.vpn.timeouts.read
				update = var.vpn.timeouts.update
				delete = var.vpn.timeouts.delete
			}
		}
}
