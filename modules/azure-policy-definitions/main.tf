# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/policy_definition
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
