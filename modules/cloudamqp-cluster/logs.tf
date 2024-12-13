# Logs Integration
resource "cloudamqp_integration_log" "logs" {
  count = var.enable_logs ? 1 : 0
  instance_id = cloudamqp_instance.instance.id
  name = var.logs_name
  api_key = var.logs_api_key
  region = join(",", var.logs_region)
  tags = join(",", var.logs_tags)
  tenant_id = var.tenant_id
  application_id = var.application_id
  application_secret = var.application_secret
  dce_uri = var.dce_uri
  table = var.table
  dcr_id = var.dcr_id
}
