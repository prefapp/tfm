module "public_ip" {
  source = "../../"

  public_ip = {
    name                = "public-ip-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    sku                 = "Standard"
    allocation_method   = "Static"
    public_ip_zones     = ["1","2","3"]
    tags_from_rg        = true
}
