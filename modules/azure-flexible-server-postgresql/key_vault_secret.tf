# Data source to get the Key Vault details
data "azurerm_key_vault" "key_vault" {
  name                = local.data.password.key_vault_name
  resource_group_name = local.data.password.key_vault_resource_group
}

# Always create the random password (even if it may not be used)
resource "random_password" "password" {
  length  = 20
  special = true
}

# Create the Key Vault secret
resource "azurerm_key_vault_secret" "password_create" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = local.data.password.key_vault_secret_name
  value        = random_password.password.result
  depends_on = [ random_password.password ]
  lifecycle {
    # Ignore changes to the secret's value to prevent overwriting it after the initial creation
    ignore_changes = [value]
  }
}
