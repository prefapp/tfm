locals {
  subnet_id  = var.subnet_id ? var.aks_subnet_id : data.azurerm_subnet.aks_subnet.id
}
