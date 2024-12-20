# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/integration_log
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
  project_id         = each.value.project_id
  access_key_id      = each.value.access_key_id
  endpoint           = each.value.endpoint
  secret_access_key  = each.value.secret_access_key
  application        = each.value.application
  subsystem          = each.value.subsystem
  token              = each.value.token
  url                = each.value.url
  host               = each.value.host
  host_port          = each.value.host_port
  sourcetype         = each.value.sourcetype
  client_email       = each.value.client_email
  private_key        = each.value.private_key
}
