# Metrics integration
resource "cloudamqp_integration_metric" "this" {
  count = var.enable_metrics ? 1 : 0
  instance_id = cloudamqp_instance.this.id
  name = var.metrics_name
  api_key = var.metrics_api_key
  region = var.metrics_region
  tags = join(",", var.metrics_tags)
}
