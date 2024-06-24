locals{

  active_owners = [for owner in local.owners : owner.object_id if lower(owner.pim_type) == "active" ]

  active_members = [for member in local.members : member.object_id if lower(member.pim_type) == "active" ]

}


resource "azuread_group" "this" {

  display_name     = var.name

  assignable_to_role = true

  security_enabled = true

  members = local.members

  # This is a conditional expression that checks if the owners_object_ids list is not empty.
  # The list should be populated, but a empty list is not a valid value for the azuread API
  owners = length(local.active_owners) > 0 ? local.active_owners : null

}
