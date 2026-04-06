module "localnet_gateway" {
  source = "../../"
  localnet = [{
    local_gateway_name          = "multi-space-gw"
    location                    = "westeurope"
    resource_group_name         = "example-rg"
    local_gateway_ip            = "203.0.113.2"
    local_gateway_address_space = ["10.1.0.0/16", "10.2.0.0/16"]
    tags_from_rg                = false
    tags                        = { environment = "test" }
  }]
}
