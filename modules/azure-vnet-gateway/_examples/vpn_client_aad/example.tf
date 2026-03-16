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
    sku                 = "VpnGw1"
    vpn_client_address_space = ["10.10.0.0/24"]
    vpn_client_protocols     = ["IkeV2", "OpenVPN"]
    vpn_client_aad_tenant    = "https://login.microsoftonline.com/<tenant_id>"
  }
  nat_rules = [
    {
      name = "egress-nat"
      mode = "EgressSnat"
      type = "Static"
      external_mapping = [ 
        {
          address_space = "203.0.113.0/24"
          port_range    = "1-65535"
        }
      ]
      internal_mapping = [
        {
          address_space = "10.0.0.0/24"
          port_range    = "1-65535"
        }
      ]
    }
  ]
  tags_from_rg = true
}
