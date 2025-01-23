# Output section
output "output_template_cloudinit_config" {
  value = base64encode(var.vmss.cloud_init)
}

output "output_run_script" {
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

output "vmss_identity" {
  value = {
    principal_id = azurerm_linux_virtual_machine_scale_set.this.identity[0].principal_id
    tenant_id    = azurerm_linux_virtual_machine_scale_set.this.identity[0].tenant_id
  }
}
