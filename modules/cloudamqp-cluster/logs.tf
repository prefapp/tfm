# Logs Integration (Añadir integración para API KEY de archivo externo (data sobre keyvault))
resource "cloudamqp_integration_log" "logs" {
  count = var.enable_logs ? 1 : 0
  instance_id = cloudamqp_instance.this.id
  name = var.logs_name
  api_key = var.logs_api_key
  region = join(",", var.logs_region)
  tags = join(",", var.logs_tags)
}
