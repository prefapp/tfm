# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.1/docs/resources/integration_log
resource "cloudamqp_integration_log" "this" {
  for_each           = var.logs_integrations
  instance_id        = cloudamqp_instance.this.id
  name               = each.value.name
  api_key            = each.value.api_key
  region             = join(",", each.value.region)
  tags               = join(",", [for k, v in each.value.tags : "${k}=${v}"])
  tenant_id          = each.value.tenant_id
  application_id     = each.value.application_id
  application_secret = each.value.application_secret
  dce_uri            = each.value.dce_uri
  table              = each.value.table
  dcr_id             = each.value.dcr_id
}
