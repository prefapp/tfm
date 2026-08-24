# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
resource "azuread_group" "this" {
  display_name       = var.name
  assignable_to_role = var.assignable_to_role
  security_enabled   = true
  description        = var.description

  # This is a conditional expression that checks if the owners_object_ids list is not empty.
  # The list should be populated, but a empty list is not a valid value for the azuread API
  owners = length(local.direct_owners) > 0 ? sort(local.direct_owners) : null

  lifecycle {
    ignore_changes = [
      members,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member
resource "azuread_group_member" "this" {
  for_each         = { for member in local.direct_members : member => member }
  group_object_id  = azuread_group.this.id
  member_object_id = each.value
}


import {
  to = azuread_group_member.this["435d9f63-11a7-402a-aa30-743a31181bbc"]

  id = "2f435ad9-cffa-4d07-9d6c-9bedc8b37ba4/member/435d9f63-11a7-402a-aa30-743a31181bbc"
}
