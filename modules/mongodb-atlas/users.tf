# Users section
# Generate random passwords for the database users
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "db_passwords" {
  for_each = { for user in var.users : user.username => user }
  length   = var.password_length
  special  = var.password_special

  # Ensure passwords are generated after the cluster
  depends_on = [mongodbatlas_cluster.cluster]
}

# Azure Key Vault data source
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault
data "azurerm_key_vault" "key_vault" {
  count               = var.provider == "azure" ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = var.provider.global_resource_group_name
}

# Data source to fetch all secrets from the specified Azure Key Vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets
data "azurerm_key_vault_secrets" "key_vault_secrets" {
  count        = var.provider == "azure" ? 1 : 0
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
}

# Store the generated passwords in Azure Key Vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
resource "azurerm_key_vault_secret" "db_password_secrets" {
  count        = var.provider == "azure" ? 1 : 0
  for_each     = { for user in var.users : user.username => user }
  name         = "test-${var.prefix_pass_name}-${replace(each.key, "_", "-")}"
  value        = random_password.db_passwords[each.key].result
  key_vault_id = data.azurerm_key_vault.key_vault[0].id

  # Ensure secrets are created after passwords
  depends_on = [random_password.db_passwords]
}

# Create the MongoDB Atlas database users using the generated passwords
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
resource "mongodbatlas_database_user" "database_users" {
  for_each           = { for user in var.users : user.username => user }
  username           = each.value.username
  password           = azurerm_key_vault_secret.db_password_secrets[each.key].value
  project_id         = mongodbatlas_project.project.id
  auth_database_name = each.value.auth_db_name

  # Dynamic roles block
  dynamic "roles" {
    for_each = lookup(each.value, "roles", [])
    content {
      role_name     = roles.value.role_name
      database_name = roles.value.database_name
    }
  }

  # Dynamic scopes block
  dynamic "scopes" {
    for_each = lookup(each.value, "scopes", [])
    content {
      name = scopes.value.name
      type = scopes.value.type
    }
  }

  # Ensure users are created after the cluster and secrets
  depends_on = [
    mongodbatlas_cluster.cluster,
    azurerm_key_vault_secret.db_password_secrets
  ]
}
