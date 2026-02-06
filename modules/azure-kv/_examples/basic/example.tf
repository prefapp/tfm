// Basic example: Azure Key Vault with a simple access policy

module "azure_kv" {
  source = "../../"

  name                        = "example-kv"
  resource_group              = "example-rg"
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = false

  access_policies = [
    {
      type                    = "User"
      name                    = "example-user"
      object_id               = "00000000-0000-0000-0000-000000000000"
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List", "Set"]
      certificate_permissions = []
      storage_permissions     = []
    }
  ]

  tags = {
    environment = "dev"
    application = "example"
  }
}

