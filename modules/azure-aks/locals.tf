locals {
  subnet_id  = var.subnet_id ? var.subnet_id : data.azurerm_subnet.aks_subnet.id
}
