# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account
resource "azurerm_cognitive_account" "this" {
  name                               = var.name
  location                           = var.location
  resource_group_name                = var.resource_group_name
  kind                               = var.kind
  sku_name                           = var.sku_name
  custom_subdomain_name              = var.custom_subdomain_name
  dynamic_throttling_enabled         = var.dynamic_throttling_enabled
  local_auth_enabled                 = var.local_auth_enabled
  public_network_access_enabled      = var.public_network_access_enabled
  outbound_network_access_restricted = var.outbound_network_access_restricted
  project_management_enabled         = var.project_management_enabled
  tags                               = local.tags

  lifecycle {
    precondition {
      condition     = !var.project_management_enabled || var.kind == "AIServices"
      error_message = "project_management_enabled can only be true when kind is AIServices."
    }

    precondition {
      condition     = var.dynamic_throttling_enabled == null || !contains(["OpenAI", "AIServices"], var.kind)
      error_message = "dynamic_throttling_enabled must be null when kind is OpenAI or AIServices."
    }

    precondition {
      condition     = var.network_acls.bypass != "AzureServices" || contains(["OpenAI", "AIServices", "TextAnalytics"], var.kind)
      error_message = "network_acls.bypass can be AzureServices only when kind is OpenAI, AIServices, or TextAnalytics."
    }
  }

  network_acls {
    bypass         = var.network_acls.bypass
    default_action = var.network_acls.default_action
    ip_rules       = var.network_acls.ip_rules

    dynamic "virtual_network_rules" {
      for_each = var.network_acls.virtual_network_rules

      content {
        subnet_id                            = virtual_network_rules.value.subnet_id
        ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
      }
    }
  }
}
