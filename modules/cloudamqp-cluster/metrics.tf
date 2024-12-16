# Metrics integration
resource "cloudamqp_integration_metric" "this" {
  for_each    = var.metrics_integrations
  instance_id = cloudamqp_instance.instance.id
  name        = each.value.name
  api_key     = each.value.api_key
  region      = each.value.region
  tags        = join(",", [for k, v in each.value.tags : "${k}=${v}"])
}
