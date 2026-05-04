# Cloud-init and bootstrap outputs
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

# Core VMSS outputs
output "vmss_id" {
  description = "Resource ID of the Linux virtual machine scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "name" {
  description = "Name of the Linux virtual machine scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}

output "unique_id" {
  description = "Platform-assigned unique ID of the scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.unique_id
}

# Managed Identity
output "principal_id" {
  description = "Principal ID of the scale set managed identity when Azure exposes it (e.g. SystemAssigned)."
  value       = try(azurerm_linux_virtual_machine_scale_set.this.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "Tenant ID of the scale set managed identity when Azure exposes it (e.g. SystemAssigned)."
  value       = try(azurerm_linux_virtual_machine_scale_set.this.identity[0].tenant_id, null)
}

# Extension
output "virtual_machine_scale_set_extension_id" {
  description = "Resource ID of the CustomScript extension; null if `vmss.run_script` is not set."
  value       = try(azurerm_virtual_machine_scale_set_extension.this[0].id, null)
}
