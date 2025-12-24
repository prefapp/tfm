# Output section
output "custom_data" {
  value = base64encode(var.vm.custom_data)  
}

# Outputs for linux_virtual_machine_scale_set
output "vm_id" {
  value = azurerm_linux_virtual_machine.this
}

output "unique_id" {
  value = azurerm_linux_virtual_machine.this.unique_id
}
