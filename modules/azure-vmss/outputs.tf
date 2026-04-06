# Output section
output "cloud_init" {
  description = "Base64-encoded `vmss.cloud_init` (same encoding as scale set `custom_data`)."
  value       = base64encode(var.vmss.cloud_init)
}

output "run_script" {
  description = "JSON settings for the CustomScript extension when `vmss.run_script` is set."
  value = var.vmss.run_script != null ? jsonencode({
    "script" = base64encode(var.vmss.run_script)
  }) : null
}

# Outputs for linux_virtual_machine_scale_set
output "vmss_id" {
  description = "Resource ID of the Linux virtual machine scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "unique_id" {
  description = "Platform-assigned unique ID of the scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.unique_id
}
