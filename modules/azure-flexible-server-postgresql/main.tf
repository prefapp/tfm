locals {
  # Let's read the data first
  data = var.data
  # Ok let's calculate the subnet_id
  subnet_id = lookup(local.data.subnet, "name", "NOT_DEFINED") == "NOT_DEFINED" ? local.data.subnet.id : data.azurerm_subnet.subnet[0].id
}
