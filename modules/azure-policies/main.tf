# DATAS SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/data-sources/subscription
data "azurerm_subscription" "current" {}

data "azurerm_policy_definition_built_in" "this" {
  for_each = { for i, assignment in var.assignments : i => assignment if can(assignment.policy_name) }
  name     = each.value.policy_name
}

# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/policy_definition
resource "azurerm_policy_definition" "this" {
  for_each            = { for i, policy in var.policies : i => policy }
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

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/resource_policy_assignment
resource "azurerm_resource_policy_assignment" "this" {
  for_each             = { for i, assignment in var.assignments : i => assignment if assignment.scope == "resource" }
  name                 = each.value.name
  policy_definition_id = can(each.value.policy_definition_id) ? each.value.policy_definition_id : data.azurerm_policy_definition.this[each.key].id
  resource_id          = each.value.resource_id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

  dynamic "identity" {
    for_each = can(each.value.identity) ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "non_compliance_message" {
    for_each = can(each.value.non_compliance_message) ? each.value.non_compliance_message : []
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = can(each.value.overrides) ? each.value.overrides : []
    content {
      value = overrides.value.value
      dynamic "selectors" {
        for_each = can(overrides.value.selectors) ? overrides.value.selectors : []
        content {
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }

  dynamic "resource_selectors" {
    for_each = can(each.value.resource_selectors) ? each.value.resource_selectors : []
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = can(resource_selectors.value.selectors) ? resource_selectors.value.selectors : []
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
  for_each             = { for i, assignment in var.assignments : i => assignment if assignment.scope == "resource group" }
  name                 = each.value.name
  policy_definition_id = can(each.value.policy_definition_id) ? each.value.policy_definition_id : data.azurerm_policy_definition.this[each.key].id
  resource_group_id    = each.value.resource_id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

  dynamic "identity" {
    for_each = can(each.value.identity) ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "non_compliance_message" {
    for_each = can(each.value.non_compliance_message) ? each.value.non_compliance_message : []
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = can(each.value.overrides) ? each.value.overrides : []
    content {
      value = overrides.value.value
    }
  }

  dynamic "resource_selectors" {
    for_each = can(each.value.resource_selectors) ? each.value.resource_selectors : []
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = can(resource_selectors.value.selectors) ? resource_selectors.value.selectors : []
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
  for_each             = { for i, assignment in var.assignments : i => assignment if assignment.scope == "subscription" }
  name                 = each.value.name
  policy_definition_id = can(each.value.policy_definition_id) ? each.value.policy_definition_id : data.azurerm_policy_definition.this[each.key].id
  subscription_id      = data.azurerm_subscription.current.id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

  dynamic "identity" {
    for_each = can(each.value.identity) ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "non_compliance_message" {
    for_each = can(each.value.non_compliance_message) ? each.value.non_compliance_message : []
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = can(each.value.overrides) ? each.value.overrides : []
    content {
      value = overrides.value.value
    }
  }

  dynamic "resource_selectors" {
    for_each = can(each.value.resource_selectors) ? each.value.resource_selectors : []
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = can(resource_selectors.value.selectors) ? resource_selectors.value.selectors : []
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/resource_policy_assignment
resource "azurerm_management_group_policy_assignment" "this" {
  for_each             = { for i, assignment in var.assignments : i => assignment if assignment.scope == "management group" }
  name                 = each.value.name
  policy_definition_id = can(each.value.policy_definition_id) ? each.value.policy_definition_id : data.azurerm_policy_definition.this[each.key].id
  management_group_id  = each.value.management_group_id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

  dynamic "identity" {
    for_each = can(each.value.identity) ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "non_compliance_message" {
    for_each = can(each.value.non_compliance_message) ? each.value.non_compliance_message : []
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = can(each.value.overrides) ? each.value.overrides : []
    content {
      value = overrides.value.value
      dynamic "selectors" {
        for_each = can(overrides.value.selectors) ? overrides.value.selectors : []
        content {
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }

  dynamic "resource_selectors" {
    for_each = can(each.value.resource_selectors) ? each.value.resource_selectors : []
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = can(resource_selectors.value.selectors) ? resource_selectors.value.selectors : []
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}
