# Same intent as values.reference.yaml, expressed as a module block.
# enable_rbac_authorization must be false when access_policies is non-empty.

module "key_vault" {
  source = "../.."

  name                         = "kv-myapp-ref01"
  resource_group               = "my-resource-group"
  enabled_for_disk_encryption  = true
  soft_delete_retention_days   = 7
  purge_protection_enabled     = true
  sku_name                     = "standard"
  enable_rbac_authorization    = false

  tags_from_rg = true
  tags = {
    extra = "from-module"
  }

  access_policies = [
    {
      name                    = "Name for the Object ID"
      type                    = ""
      object_id               = "1a9590f4-27d3-4abf-9e30-5be7f46959bb"
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = ["Get", "List"]
    },
    {
      name                    = "Group display name"
      type                    = "group"
      object_id               = ""
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = ["Get", "List"]
    },
    {
      name                    = "Service Principal display name"
      type                    = "service_principal"
      object_id               = ""
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = ["Get", "List"]
    },
    {
      name                    = "user@contoso.com"
      type                    = "user"
      object_id               = ""
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = ["Get", "List"]
    },
  ]
}
