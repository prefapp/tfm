# DATAS SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/data-sources/subscription
data "azurerm_subscription" "current" {}

data "azurerm_policy_definition" "this" {
  for_each = { for i, assignment in var.assignments : i => assignment if can(assignment.policy_name) && assignment.policy_type == "custom" }
  display_name = each.value.policy_name
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/resource_policy_assignment
resource "azurerm_resource_policy_assignment" "this" {
  for_each             = { for i, assignment in var.assignments : i => assignment if assignment.scope == "resource" }
  name                 = each.value.name
  policy_definition_id = try(
    lookup(each.value, "policy_definition_id", null),
    one([ for v in azurerm_policy_definition.this : v.id if v.display_name == each.value.policy_name ]),
    each.value.policy_type == "builtin" ?
      can(data.azurerm_policy_definition_built_in.this[each.key].id, null) :
      can(data.azurerm_policy_definition.this[each.key].id, null)
  )
  resource_id          = each.value.resource_id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

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
  depends_on = [ azurerm_policy_definition.this ]
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/resource_group_policy_assignment
resource "azurerm_resource_group_policy_assignment" "this" {
  for_each             = { for i, assignment in var.assignments : i => assignment if assignment.scope == "resource group" }
  name                 = each.value.name
  policy_definition_id = try(
    lookup(each.value, "policy_definition_id", null),
    one([ for v in azurerm_policy_definition.this : v.id if v.display_name == each.value.policy_name ]),
    each.value.policy_type == "builtin" ?
      try(data.azurerm_policy_definition_built_in.this[each.key].id, null) :
      try(data.azurerm_policy_definition.this[each.key].id, null)
  )
  resource_group_id    = each.value.resource_id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

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
  depends_on = [ azurerm_policy_definition.this ]
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/subscription_policy_assignment
resource "azurerm_subscription_policy_assignment" "this" {
  for_each             = { for i, assignment in var.assignments : i => assignment if assignment.scope == "subscription" }
  name                 = each.value.name
  policy_definition_id = try(
    lookup(each.value, "policy_definition_id", null),
    one([ for v in azurerm_policy_definition.this : v.id if v.display_name == each.value.policy_name ]),
    each.value.policy_type == "builtin" ?
      try(data.azurerm_policy_definition_built_in.this[each.key].id, null) :
      try(data.azurerm_policy_definition.this[each.key].id, null)
  )
  subscription_id      = data.azurerm_subscription.current.id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

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
  depends_on = [ azurerm_policy_definition.this ]
}

## https://registry.terraform.io/providers/hashicorp/azurerm/4.21.1/docs/resources/resource_policy_assignment
resource "azurerm_management_group_policy_assignment" "this" {
  for_each             = { for i, assignment in var.assignments : i => assignment if assignment.scope == "management group" }
  name                 = each.value.name
  policy_definition_id = try(
    lookup(each.value, "policy_definition_id", null),
    one([ for v in azurerm_policy_definition.this : v.id if v.display_name == each.value.policy_name ]),
    each.value.policy_type == "builtin" ?
      try(data.azurerm_policy_definition_built_in.this[each.key].id, null) :
      try(data.azurerm_policy_definition.this[each.key].id, null)
  )
  management_group_id  = each.value.management_group_id
  description          = each.value.description
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  location             = each.value.location
  metadata             = each.value.metadata
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes

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
  depends_on = [ azurerm_policy_definition.this ]
}
