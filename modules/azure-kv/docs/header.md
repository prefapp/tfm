# Azure Key Vault Terraform Module

## Overview

This Terraform module allows you to create and manage an Azure Key Vault with support for:
- Custom access policies and/or RBAC authorization.
- Integration with Resource Group and tag inheritance.
- Soft delete protection and retention configuration.
- Detailed permissions for keys, secrets, certificates, and storage.

## Main features
- Create Key Vault with advanced security options.
- Support for access policies and RBAC.
- Integration with Azure AD groups, users, and service principals.
- Realistic configuration example.

## Complete usage example

```yaml
# kv.yaml
values:
  name: "keyvault_name"
  tags_from_rg: true
  tags:
    extra_tags: "example"
  enabled_for_disk_encryption: true
  resource_group: "resource_group_name"
  soft_delete_retention_days: 7
  purge_protection_enabled: true
  sku_name: "standard"
  enable_rbac_authorization: false # If RBAC is true, access policies will fail if any are defined.
  access_policies:
    - name: "Name for the Object ID"
      type: "" # Leave empty if you provide the object ID directly
      object_id: "1a9590f4-27d3-4abf-9e30-5be7f46959bb"
      key_permissions: ["Get", "List"]
      secret_permissions: ["Get", "List"]
      certificate_permissions: ["Get", "List"]
      storage_permissions: ["Get", "List"]
    - name: "Group display name"
      type: "group"
      object_id: ""  # Leave empty to look up the group ID
      key_permissions: ["Get", "List"]
      secret_permissions: ["Get", "List"]
      certificate_permissions: ["Get", "List"]
      storage_permissions: ["Get", "List"]
    - name: "Service Principal display name"
      type: "service_principal"
      object_id: ""  # Leave empty to look up the service principal ID
      key_permissions: ["Get", "List"]
      secret_permissions: ["Get", "List"]
      certificate_permissions: ["Get", "List"]
      storage_permissions: ["Get", "List"]
    - name: "User principal name"
      type: "user"
      object_id: "" # Leave empty to look up the user ID
      key_permissions: ["Get", "List"]
      secret_permissions: ["Get", "List"]
```

## Notes
- If `enable_rbac_authorization` is true, you must not define access policies.
- You can inherit tags from the resource group with `tags_from_rg`.
- Configure retention and soft delete protection according to your security needs.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
  ├── header.md
  └── footer.md
```