module "azure_public_prefix" {
  source = "../../"

  name                = "example_name"
  resource_group_name = "example_rg"
  location            = "westeurope"
  sku                 = "Standard"
  sku_tier            = "Regional"
  ip_version          = "IPv4"
  prefix_length       = 29
  zones               = ["1"]
  tags_from_rg        = false
  tags = {
    application = "example_app"
    env         = "example_env"
    tenant      = "example_tenant"
  }
}