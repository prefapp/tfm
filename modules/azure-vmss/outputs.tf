# Output section
output "output_template_cloudinit_config" {
  value = base64encode(var.vmss.template_cloudinit_config)
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
output "principal_id" {
  value = azurerm_linux_virtual_machine_scale_set.this.principal_id
}
output "tenant_id" {
  value = azurerm_linux_virtual_machine_scale_set.this.tenant_id
}
output "unique_id" {
  value = azurerm_linux_virtual_machine_scale_set.this.unique_id
}
