# DATAS SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/data-sources/subscription
data "azurerm_subscription" "current" {}

# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/policy_definition
resource "azurerm_policy_definition" "this" {
  for_each            = var.policy_definition
  name                = each.value.name
  policy_type         = each.value.policy_type
  mode                = each.value.mode
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = each.value.management_group_id
  policy_rule         = each.value.policy_rule
  metadata            = each.value.metadata
  parameters          = each.value.parameters
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/resource_policy_assignment
resource "azurerm_resource_policy_assignment" "this" {
  for_each             = var.resource_policy_assignments
  name                 = each.value.name
  policy_definition_id = each.value.policy_definition_id
  resource_id          = each.value.resource_id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

  identity {
    type         = each.value.identity.type
    identity_ids = each.value.identity.identity_ids
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message
    content {
      content                       = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides
    content {
      value     = overrides.value.value
      dynamic "override_selector" {
        for_each = overrides.value.override_selector
        content {
          in     = override_selector.value.in
          not_in = override_selector.value.not_in
        }
      }
    }
  }

  dynamic "resource_selectors" {
    for_each = each.value.resource_selectors
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = resource_selectors.value.selectors
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        } 
      }
    }
  }
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.20.0/docs/resources/subscription_policy_assignment
resource "azurerm_subscription_policy_assignment" "this" {
  for_each             = var.subscription_policy_assignments
  name                 = each.value.name
  policy_definition_id = each.value.policy_definition_id
  subscription_id      = each.value.subscription_id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

  identity {
    type         = each.value.identity.type
    identity_ids = each.value.identity.identity_ids
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message
    content {
      content                       = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides
    content {
      value     = overrides.value.value
      dynamic "override_selector" {
        for_each = overrides.value.override_selector
        content {
          in     = override_selector.value.in
          not_in = override_selector.value.not_in
        }
      }
    }
  }

  dynamic "resource_selectors" {
    for_each = each.value.resource_selectors
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = resource_selectors.value.selectors
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        } 
      }
    }
  }
}
