# Output section
output "custom_data" {
  value = var.vm.custom_data != null ? base64encode(var.vm.custom_data) : null
}

output "id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.this.virtual_machine_id
}
