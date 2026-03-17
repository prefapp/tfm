module "dns_zone" {
  source              = "../../.."
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
}
