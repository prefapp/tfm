# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
resource "azuread_group" "this" {

  display_name     = var.name

  assignable_to_role = var.assignable_to_role

  security_enabled = true

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
# resource "azuread_group_member" "this" {

#   for_each = local.direct_members

#   group_object_id  = azuread_group.this.id

#   member_object_id = each.value

# }

output "Debug" {
  value = local.direct_members
}
