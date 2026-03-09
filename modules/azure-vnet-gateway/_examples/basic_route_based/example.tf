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
    active_active            = false
    enable_bgp               = false
    sku                      = "VpnGw1"
    tags                     = { environment = "dev" }
  }
}
