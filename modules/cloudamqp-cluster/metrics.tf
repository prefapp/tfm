# Metrics integration
resource "cloudamqp_integration_metric" "this" {
  count = var.enable_metrics ? 1 : 0
  instance_id = cloudamqp_instance.instance.id
  name = var.metrics_name
  api_key = var.metrics_api_key
  region = var.metrics_region
  tags = join(",", [for k, v in var.metrics_tags : "${k}=${v}"])
}
