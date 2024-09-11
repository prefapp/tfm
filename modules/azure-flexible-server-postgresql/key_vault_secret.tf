# We only generate the password if necessary
resource "random_password" "password" {
  count   = local.data.password.create ? 1 : 0
  length  = 20
  special = true
}

# We only upload the password if necessary
# Once created we ignore it
resource "azurerm_key_vault_secret" "password_create" {
  count        = local.data.password.create ? 1 : 0
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = local.data.password.key_vault_secret_name
  value        = random_password.password.result
  lifecycle {
    ignore_changes = [value]
  }
}

# Checkers and data access
data "azurerm_key_vault" "key_vault" {
  name                = local.data.password.key_vault_name
  resource_group_name = local.data.password.key_vault_resource_group
}

data "azurerm_key_vault_secret" "password" {
  name         = local.data.password.key_vault_secret_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault_secret.password_create
  ]
}
