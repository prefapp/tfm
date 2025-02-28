# DATAS SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/data-sources/subscription
data "azurerm_subscription" "current" {}

# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/policy_definition
resource "azurerm_policy_definition" "this" {
  name                = var.policy.name
  policy_type         = var.policy.policy_type
  mode                = var.policy.mode
  display_name        = var.policy.display_name
  description         = var.policy.description
  management_group_id = var.policy.management_group_id
  policy_rule         = var.policy.policy_rule
  metadata            = var.policy.metadata
  parameters          = var.policy.parameters
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/resource_policy_assignment
resource "azurerm_resource_policy_assignment" "this" {
  for_each             = var.assignment.scope == "resource" ? var.assignments : {}
  name                 = each.value.name
  policy_definition_id = azurerm_policy_definition.this.id
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
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides
    content {
      value = overrides.value.value
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

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/resource_group_policy_assignment
resource "azurerm_resource_group_policy_assignment" "this" {
  for_each             = var.assignment.scope == "resource group" ? var.assignments : {}
  name                 = each.value.name
  policy_definition_id = azurerm_policy_definition.this.id
  resource_group_id    = each.value.resource_id
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
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides
    content {
      value = overrides.value.value
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

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/subscription_policy_assignment
resource "azurerm_subscription_policy_assignment" "this" {
  for_each             = var.assignment.scope == "subscription" ? var.assignments : {}
  name                 = each.value.name
  policy_definition_id = azurerm_policy_definition.this.id
  subscription_id      = data.azurerm_subscription.current.id
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
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides
    content {
      value = overrides.value.value
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
