# DATA SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "this" {
  for_each = {
    for subnet in var.allowed_subnets : subnet.name => subnet
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
  name                             = var.storage_account.name
  resource_group_name              = data.azurerm_resource_group.this.name
  location                         = data.azurerm_resource_group.this.location
  account_tier                     = var.storage_account.account_tier
  account_replication_type         = var.storage_account.account_replication_type
  account_kind                     = var.storage_account.account_kind
  access_tier                      = var.storage_account.access_tier
  cross_tenant_replication_enabled = var.storage_account.cross_tenant_replication_enabled
  edge_zone                        = var.storage_account.edge_zone
  allow_nested_items_to_be_public  = var.storage_account.allow_nested_items_to_be_public
  https_traffic_only_enabled       = var.storage_account.https_traffic_only_enabled
  min_tls_version                  = var.storage_account.min_tls_version
  public_network_access_enabled    = var.storage_account.public_network_access_enabled
  tags                             = var.tags
  dynamic "identity" {
    for_each = var.storage_account.identity != null ? [var.storage_account.identity] : []
    content {
      type         = lookup(identity.value, "type", null)
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id         = azurerm_storage_account.this.id
  default_action             = var.network_rules.default_action
  virtual_network_subnet_ids = concat([for subnet in data.azurerm_subnet.this : subnet.id], coalesce(var.additional_allowed_subnet_ids, []))
  ip_rules                   = concat(coalesce(var.network_rules.ip_rules, []))
  bypass                     = [var.network_rules.bypass]
  dynamic "private_link_access" {
    for_each = var.network_rules.private_link_access != null ? var.network_rules.private_link_access : []
    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", null)
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container.html
resource "azurerm_storage_container" "this" {
  for_each                          = var.containers != null ? { for container in var.containers : container.name => container } : {}
  name                              = each.value.name
  storage_account_name              = azurerm_storage_account.this.name
  container_access_type             = each.value.container_access_type
  default_encryption_scope          = each.value.default_encryption_scope
  encryption_scope_override_enabled = each.value.encryption_scope_override_enabled
  metadata                          = each.value.metadata
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
resource "azurerm_storage_share" "this" {
  for_each             = var.shares != null ? { for share in var.shares : share.name => share } : {}
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
      dynamic "access_policy" {
        for_each = acl.value.access_policy != null ? [acl.value.access_policy] : []
        content {
          permissions = lookup(access_policy.value, "permissions", null)
          start       = lookup(access_policy.value, "start", null)
          expiry      = lookup(access_policy.value, "expiry", null)
        }
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue
resource "azurerm_storage_queue" "this" {
  for_each             = var.queues != null ? { for queue in var.queues : queue.name => queue } : {}
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  metadata             = each.value.metadata
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table
resource "azurerm_storage_table" "this" {
  for_each             = var.tables != null ? { for table in var.tables : table.name => table } : {}
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  dynamic "acl" {
    for_each = each.value.acl != null ? [each.value.acl] : []
    content {
      id = acl.value.id
      access_policy {
        permissions = lookup(acl.value.access_policy, "permissions", null)
        start       = lookup(acl.value.access_policy, "start", null)
        expiry      = lookup(acl.value.access_policy, "expiry", null)
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy
resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id
  dynamic "rule" {
    for_each = var.lifecycle_policy_rules
    content {
      name    = rule.value.name
      enabled = rule.value.enabled
      filters {
        blob_types   = rule.value.filters.blob_types
        prefix_match = lookup(rule.value.filters, "prefix_match", null)
        dynamic "match_blob_index_tag" {
          for_each = rule.value.filters.match_blob_index_tag
          content {
            name      = match_blob_index_tag.value.name
            operation = lookup(match_blob_index_tag.value, "operation", "==")
            value     = match_blob_index_tag.value.value
          }
        }
      }
      actions {
        dynamic "base_blob" {
          for_each = rule.value.actions.base_blob != null ? [rule.value.actions.base_blob] : []
          content {
            tier_to_cool_after_days_since_modification_greater_than        = lookup(base_blob.value, "tier_to_cool_after_days_since_modification_greater_than", null)
            tier_to_cool_after_days_since_last_access_time_greater_than    = lookup(base_blob.value, "tier_to_cool_after_days_since_last_access_time_greater_than", null)
            tier_to_cool_after_days_since_creation_greater_than            = lookup(base_blob.value, "tier_to_cool_after_days_since_creation_greater_than", null)
            auto_tier_to_hot_from_cool_enabled                             = lookup(base_blob.value, "auto_tier_to_hot_from_cool_enabled", false)
            tier_to_archive_after_days_since_modification_greater_than     = lookup(base_blob.value, "tier_to_archive_after_days_since_modification_greater_than", null)
            tier_to_archive_after_days_since_last_access_time_greater_than = lookup(base_blob.value, "tier_to_archive_after_days_since_last_access_time_greater_than", null)
            tier_to_archive_after_days_since_creation_greater_than         = lookup(base_blob.value, "tier_to_archive_after_days_since_creation_greater_than", null)
            delete_after_days_since_modification_greater_than              = lookup(base_blob.value, "delete_after_days_since_modification_greater_than", null)
            delete_after_days_since_last_access_time_greater_than          = lookup(base_blob.value, "delete_after_days_since_last_access_time_greater_than", null)
            delete_after_days_since_creation_greater_than                  = lookup(base_blob.value, "delete_after_days_since_creation_greater_than", null)
          }
        }
        dynamic "snapshot" {
          for_each = rule.value.actions.snapshot != null ? [rule.value.actions.snapshot] : []
          content {
            change_tier_to_archive_after_days_since_creation               = lookup(snapshot.value, "change_tier_to_archive_after_days_since_creation", null)
            tier_to_archive_after_days_since_last_tier_change_greater_than = lookup(snapshot.value, "tier_to_archive_after_days_since_last_tier_change_greater_than", null)
            change_tier_to_cool_after_days_since_creation                  = lookup(snapshot.value, "change_tier_to_cool_after_days_since_creation", null)
            tier_to_cold_after_days_since_creation_greater_than            = lookup(snapshot.value, "tier_to_cold_after_days_since_creation_greater_than", null)
            delete_after_days_since_creation_greater_than                  = lookup(snapshot.value, "delete_after_days_since_creation_greater_than", null)
          }
        }
        dynamic "version" {
          for_each = rule.value.actions.version != null ? [rule.value.actions.version] : []
          content {
            change_tier_to_archive_after_days_since_creation               = lookup(version.value, "change_tier_to_archive_after_days_since_creation", null)
            tier_to_archive_after_days_since_last_tier_change_greater_than = lookup(version.value, "tier_to_archive_after_days_since_last_tier_change_greater_than", null)
            change_tier_to_cool_after_days_since_creation                  = lookup(version.value, "change_tier_to_cool_after_days_since_creation", null)
            tier_to_cold_after_days_since_creation_greater_than            = lookup(version.value, "tier_to_cold_after_days_since_creation_greater_than", null)
            delete_after_days_since_creation                               = lookup(version.value, "delete_after_days_since_creation", null)
          }
        }
      }
    }
  }
}
