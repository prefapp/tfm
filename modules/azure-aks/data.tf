# Data section
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

# Interface

# outbound_public_ips:
#  - id: # me pasas el id de la ip publica
# or # me pasas el grupo de recursos y el nombre de la ip publica y yo me encargo de buscarla
#  - resource_group:
#  - name:

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip
data "azurerm_public_ip" "aks_public_ip" {
  for_each            = var.outbound_public_ips != null ? { for idx, ip in var.outbound_public_ips : idx => ip if lookup(ip, "id", null) != null } : {}
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
}
