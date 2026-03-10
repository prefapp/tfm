module "vnet_gateway" {
  source = "../../"
  vpn = {
    vnet_name                = "example-vnet"
    gateway_subnet_name      = "GatewaySubnet"
    location                 = "westeurope"
    resource_group_name      = "example-rg"
    gateway_name             = "example-vpn-gw"
    ip_name                  = "example-vpn-ip"
    public_ip_name           = "example-vpn-public-ip"
    ip_allocation_method     = "Dynamic"
    type                     = "Vpn"
    vpn_type                 = "RouteBased"
    active_active            = true
    enable_bgp               = true
    sku                      = "VpnGw2"
    bgp_route_translation_for_nat_enabled = true
  }
  tags_from_rg = true
}
