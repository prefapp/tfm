# Output section
output "output_template_cloudinit_config" {
  value = base64encode(var.vmss.template_cloudinit_config)
}

output "output_run_script" {
  value = jsonencode({
    "script" = base64encode(var.vmss.run_script)
  })
}
