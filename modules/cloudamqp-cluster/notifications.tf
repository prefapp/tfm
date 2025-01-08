# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets
data "azurerm_key_vault_secret" "secret_cloudamqp_slack_webhook_dev" {
  name         = "cloudamqp-slack-webhook"
  key_vault_id = data.azurerm_key_vault.key_vault_corpme_common_predev.id
  depends_on   = [cloudamqp_instance.this]
}

# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/notification
resource "cloudamqp_notification" "this" {
  for_each    = var.recipients
  instance_id = cloudamqp_instance.this.id

  value = each.value.value
  name  = each.value.name
  type  = each.value.type
}

