# Output section
output "cloud_init" {
  value = base64encode(var.vm.cloud_init)
}

output "run_script" {
  value = jsonencode({
    "script" = base64encode(var.vm.run_script)
  })
}

# Outputs for linux_virtual_machine_scale_set
output "vm_id" {
  value = azurerm_linux_virtual_machine.this
}

output "unique_id" {
  value = azurerm_linux_virtual_machine.this.unique_id
}
