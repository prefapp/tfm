module "public_ip" {
  source = "../../"

  public_ip = {
    name                = "public-ip-name"
    resource_group_name = "resource-group-name"
    location            = "westeurope"
    sku                 = "Standard"
    allocation_method   = "Static"
    domain_name_label   = "domain-name"
    tags_from_rg        = true
}
