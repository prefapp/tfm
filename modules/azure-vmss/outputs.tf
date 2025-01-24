# Output section
output "cloud_init" {
  value = base64encode(var.vmss.cloud_init)
}

output "run_script" {
  value = jsonencode({
    "script" = base64encode(var.vmss.run_script)
  })
}

# Outputs for linux_virtual_machine_scale_set
output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.this.id
}

output "unique_id" {
  value = azurerm_linux_virtual_machine_scale_set.this.unique_id
}
