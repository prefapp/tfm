# DATAS SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/data-sources/subscription
data "azurerm_subscription" "current" {}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/data-sources/policy_definition
data "azurerm_policy_definition" "this" {
  for_each     = { for k, v in var.assignments : k => v if can(v.policy_name) }
  display_name = each.value.policy_name
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  for_each = { for k, v in var.assignments : k => v if v.scope == "resource group" && v.resource_group_id == null }
  name     = each.value.resource_group_name
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/data-sources/management_group
data "azurerm_management_group" "this" {
  for_each     = { for k, v in var.assignments : k => v if v.scope == "management group" && v.management_group_id == null }
  display_name = each.value.management_group_name
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_policy_assignment
resource "azurerm_resource_policy_assignment" "this" {
  for_each = { for i, assignment in var.assignments : i => assignment if assignment.scope == "resource" }
  name     = each.value.name
  policy_definition_id = coalesce(
    lookup(each.value, "policy_definition_id", null),
    try(data.azurerm_policy_definition.this[each.key].id, null)
  )
  resource_id  = each.value.resource_id
  description  = each.value.description
  display_name = each.value.display_name
  enforce      = each.value.enforce
  location     = each.value.location
  metadata     = each.value.metadata
  parameters   = each.value.parameters != null ? jsonencode(each.value.parameters) : null
  not_scopes   = each.value.not_scopes

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [each.value.non_compliance_message] : []
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides != null ? [each.value.overrides] : []
    content {
      value = overrides.value.value
    }
  }

  dynamic "resource_selectors" {
    for_each = each.value.resource_selectors != null ? [each.value.resource_selectors] : []
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = each.value.selectors != null ? [each.value.selectors] : []
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_group_policy_assignment
resource "azurerm_resource_group_policy_assignment" "this" {
  for_each = { for i, assignment in var.assignments : i => assignment if assignment.scope == "resource group" }
  name     = each.value.name
  policy_definition_id = coalesce(
    lookup(each.value, "policy_definition_id", null),
    try(lookup(data.azurerm_policy_definition.this, each.key, null).id, null)
  )
  resource_group_id = coalesce(
    lookup(each.value, "resource_group_id", null),
    try(lookup(data.azurerm_resource_group.this, each.key, null).id, null)
  )
  description  = each.value.description
  display_name = each.value.display_name
  enforce      = each.value.enforce
  location     = each.value.location
  metadata     = each.value.metadata
  parameters   = each.value.parameters != null ? jsonencode(each.value.parameters) : null
  not_scopes   = each.value.not_scopes

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [each.value.non_compliance_message] : []
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides != null ? [each.value.overrides] : []
    content {
      value = overrides.value.value
    }
  }

  dynamic "resource_selectors" {
    for_each = each.value.resource_selectors != null ? [each.value.resource_selectors] : []
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = each.value.selectors != null ? [each.value.selectors] : []
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/subscription_policy_assignment
resource "azurerm_subscription_policy_assignment" "this" {
  for_each = { for i, assignment in var.assignments : i => assignment if assignment.scope == "subscription" }
  name     = each.value.name
  policy_definition_id = coalesce(
    lookup(each.value, "policy_definition_id", null),
    try(lookup(data.azurerm_policy_definition.this, each.key, null).id, null)
  )
  subscription_id = data.azurerm_subscription.current.id
  description     = each.value.description
  display_name    = each.value.display_name
  enforce         = each.value.enforce
  location        = each.value.location
  metadata        = each.value.metadata
  parameters      = each.value.parameters != null ? jsonencode(each.value.parameters) : null
  not_scopes      = each.value.not_scopes

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [each.value.non_compliance_message] : []
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides != null ? [each.value.overrides] : []
    content {
      value = overrides.value.value
    }
  }

  dynamic "resource_selectors" {
    for_each = each.value.resource_selectors != null ? [each.value.resource_selectors] : []
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = each.value.selectors != null ? [each.value.selectors] : []
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/management_group_policy_assignment
resource "azurerm_management_group_policy_assignment" "this" {
  for_each = { for i, assignment in var.assignments : i => assignment if assignment.scope == "management group" }
  name     = each.value.name
  policy_definition_id = coalesce(
    lookup(each.value, "policy_definition_id", null),
    try(lookup(data.azurerm_policy_definition.this, each.key, null).id, null)
  )
  management_group_id = coalesce(
    lookup(each.value, "management_group_id", null),
    try(lookup(data.azurerm_management_group.this, each.key, null).id, null)
  )
  description  = each.value.description
  display_name = each.value.display_name
  enforce      = each.value.enforce
  location     = each.value.location
  metadata     = each.value.metadata
  parameters   = each.value.parameters != null ? jsonencode(each.value.parameters) : null
  not_scopes   = each.value.not_scopes

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [each.value.non_compliance_message] : []
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "overrides" {
    for_each = each.value.overrides != null ? [each.value.overrides] : []
    content {
      value = overrides.value.value
      dynamic "selectors" {
        for_each = each.value.selectors != null ? [each.value.selectors] : []
        content {
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }

  dynamic "resource_selectors" {
    for_each = each.value.resource_selectors != null ? [each.value.resource_selectors] : []
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = each.value.selectors != null ? [each.value.selectors] : []
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = {
    for ra in var.policy_identity_role_assignments :
    "${ra.assignment_name}-${ra.scope}-${ra.role_definition_name}" => ra
    if (
      ra.scope == "subscription" && try(azurerm_subscription_policy_assignment.this[ra.assignment_name].identity[0].principal_id, null) != null ||
      ra.scope == "resource group" && try(azurerm_resource_group_policy_assignment.this[ra.assignment_name].identity[0].principal_id, null) != null ||
      ra.scope == "management group" && try(azurerm_management_group_policy_assignment.this[ra.assignment_name].identity[0].principal_id, null) != null ||
      ra.scope == "resource" && try(azurerm_resource_policy_assignment.this[ra.assignment_name].identity[0].principal_id, null) != null
    )
  }

  principal_id = (
    each.value.scope == "subscription" ? azurerm_subscription_policy_assignment.this[each.value.assignment_name].identity[0].principal_id :
    each.value.scope == "resource group" ? azurerm_resource_group_policy_assignment.this[each.value.assignment_name].identity[0].principal_id :
    each.value.scope == "management group" ? azurerm_management_group_policy_assignment.this[each.value.assignment_name].identity[0].principal_id :
    each.value.scope == "resource" ? azurerm_resource_policy_assignment.this[each.value.assignment_name].identity[0].principal_id :
    null
  )
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope

  depends_on = [
    azurerm_subscription_policy_assignment.this,
    azurerm_resource_group_policy_assignment.this,
    azurerm_management_group_policy_assignment.this,
    azurerm_resource_policy_assignment.this
  ]
}
