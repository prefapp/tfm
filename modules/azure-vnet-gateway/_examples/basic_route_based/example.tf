module "vnet_gateway" {
  source = "../../"
  vpn = {
    vnet_name            = "example-vnet"
    gateway_subnet_name  = "GatewaySubnet"
    location             = "westeurope"
    resource_group_name  = "example-rg"
    gateway_name         = "example-vpn-gw"
    ip_configurations = [
      {
        name                         = "gw-ipconfig1"
        public_ip_name               = "example-vpn-public-ip"
        private_ip_address_allocation = "Dynamic"
      }
    ]
    type                = "Vpn"
    vpn_type            = "RouteBased"
    active_active       = false
    enable_bgp          = false
    sku                 = "VpnGw1"
  }
  nat_rules = [
    {
      name                          = "egress-nat"
      mode                          = "EgressSnat"
      type                          = "Static"
      external_mapping_address_space = "203.0.113.0/24"
      internal_mapping_address_space = "10.0.0.0/24"
    }
  ]
  tags = {
    environment = "dev"
    application = "example-app"
  }
  # tags_from_rg = true
}
