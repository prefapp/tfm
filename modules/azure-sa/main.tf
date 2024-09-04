# DATA SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "this" {
  for_each = {
    for subnet in var.subnet : subnet.name => subnet
  }
  name                 = each.value.name
  virtual_network_name = each.value.vnet
  resource_group_name  = each.value.resource_group
}

# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  name                       = var.storage_account.name
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = data.azurerm_resource_group.this.location
  account_kind               = var.storage_account.account_kind
  account_tier               = var.storage_account.account_tier
  account_replication_type   = var.storage_account.account_replication_type
  https_traffic_only_enabled = var.storage_account.https_traffic_only_enabled
  min_tls_version            = var.storage_account.min_tls_version
  tags = var.tags
  blob_properties {
    versioning_enabled  = var.versioning_enabled
    change_feed_enabled = var.change_feed_enabled
    delete_retention_policy {
      days = var.blob_retention_soft_delete
    }
    container_delete_retention_policy {
      days = var.container_retention_soft_delete
    }
  }
  share_properties {
    retention_policy {
      days = var.storage_account.share_properties.retention_policy.days
    }
  }

  ## always from data outside
  identity {
    type         = var.storage_account.identity.type
    identity_ids = var.storage_account.identity.identity_ids
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id         = azurerm_storage_account.this.id
  default_action             = var.storage_account_network_rules.default_action
  virtual_network_subnet_ids = concat([for subnet in data.azurerm_subnet.this : subnet.id], var.additional_subnet_ids) # and values provided as string or list(string)
  bypass                     = [var.storage_account_network_rules.bypass]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container.html
resource "azurerm_storage_container" "this" {
  for_each                          = var.storage_container != null ? { for container in var.storage_container : container.name => container } : {}
  name                              = each.value.name
  storage_account_name              = azurerm_storage_account.this.name
  container_access_type             = each.value.container_access_type
  default_encryption_scope          = each.value.default_encryption_scope
  encryption_scope_override_enabled = each.value.encryption_scope_override_enabled
  metadata                          = each.value.metadata
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob
resource "azurerm_storage_blob" "this" {
  for_each = {
  for blob in var.storage_blob : "${blob.storage_container_name}-${blob.name}" => blob }
  name                   = each.value.name
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = each.value.storage_container_name
  type                   = each.value.type
  source                 = each.value.source
  size                   = each.value.size
  cache_control          = each.value.cache_control
  content_type           = each.value.content_type
  content_md5            = each.value.content_md5
  access_tier            = each.value.access_tier
  encryption_scope       = each.value.encryption_scope
  source_content         = each.value.source_content
  source_uri             = each.value.source_uri
  parallelism            = each.value.parallelism
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue
resource "azurerm_storage_queue" "this" {
  for_each             = var.storage_queue != null ? { for queue in var.storage_queue : queue.name => queue } : {}
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  metadata             = each.value.metadata
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
resource "azurerm_storage_share" "this" {
  for_each             = var.storage_share != null ? { for share in var.storage_share : share.name => share } : {}
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  access_tier          = each.value.access_tier
  enabled_protocol     = each.value.enabled_protocol
  quota                = each.value.quota
  metadata             = each.value.metadata
  dynamic "acl" {
    for_each = each.value.acl != null ? each.value.acl : []
    content {
      id = acl.value.id
      access_policy {
        permissions = acl.value.access_policy.permissions
        start       = acl.value.access_policy.start
        expiry      = acl.value.access_policy.expiry
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table
resource "azurerm_storage_table" "this" {
  for_each             = var.storage_table != null ? { for table in var.storage_table : table.name => table } : {}
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  acl {
    id = each.value.acl.id
    access_policy {
      permissions = each.value.acl.access_policy.permissions
      start       = each.value.acl.access_policy.start
      expiry      = each.value.acl.access_policy.expiry
    }
  }
}

# IAM **identity user managed outside**
