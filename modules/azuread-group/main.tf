resource "azuread_group" "this" {

  display_name     = var.name

  assignable_to_role = true

  security_enabled = true

  members = local.members_object_ids

  # This is a conditional expression that checks if the owners_object_ids list is not empty.
  # The list should be populated, but a empty list is not a valid value for the azuread API
  owners = length(local.owners_object_ids) > 0 ? local.owners_object_ids : null

}
