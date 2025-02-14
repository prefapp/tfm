# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/integration_metric
resource "cloudamqp_integration_metric" "this" {
  for_each          = var.metrics_integrations
  instance_id       = cloudamqp_instance.this.id
  name              = each.value.name
  api_key           = each.value.api_key
  region            = each.value.region
  tags              = join(",", [for k, v in each.value.tags : "${k}=${v}"])
  access_key_id     = each.value.access_key_id
  secret_access_key = each.value.secret_access_key
  iam_role          = each.value.iam_role
  iam_external_id   = each.value.iam_external_id
  email             = each.value.email
  project_id        = each.value.project_id
  private_key       = each.value.private_key
  client_email      = each.value.client_email
}
