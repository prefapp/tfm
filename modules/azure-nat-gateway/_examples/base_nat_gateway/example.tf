module "public_ip" {
  source = "../../"

  public_ip = {
    name                = "nat-gateway-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    nat_gateway_timeout = 4
    nat_gateway_sku     = "Standard"
    allocation_method   = "Static"
    public_ip_id        = "public-ip-id"
    subnet_id           = "subnet-id"
    tags_from_rg        = true
}
