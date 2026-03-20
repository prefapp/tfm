module "private_dns_zone" {
  source              = "../../.."
  dns_zone_name       = "privatelink.example.com"
  resource_group_name = "my-rg"
  vnet_ids            = {
    vnet1 = "<vnet1_id>"
    vnet2 = "<vnet2_id>"
  }
}
