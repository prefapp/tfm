# Output section
output "custom_data" {
  value = var.vm.custom_data != null ? base64encode(var.vm.custom_data) : null
}

# Outputs for linux_virtual_machine_scale_set
output "vm_id" {
  value = azurerm_linux_virtual_machine.this
}
