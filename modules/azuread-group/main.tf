# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
resource "azuread_group" "this" {

  display_name     = var.name

  assignable_to_role = true

  security_enabled = true

  members = local.direct_members

  # This is a conditional expression that checks if the owners_object_ids list is not empty.
  # The list should be populated, but a empty list is not a valid value for the azuread API
  owners = length(local.direct_owners) > 0 ? local.direct_owners : null

}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy#require_justification
resource "azuread_group_role_management_policy" "members" {
  group_id = azuread_group.this.id
  role_id  = "member"

  activation_rules {
    maximum_duration = "PT${var.pim_maximum_duration_hours}H"
    require_justification = var.pim_require_justification
  }
  
  eligible_assignment_rules {
    expiration_required = var.expiration_required
  }
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy#require_justification
resource "azuread_group_role_management_policy" "owners" {
  group_id = azuread_group.this.id
  role_id  = "owner"

  activation_rules {
    maximum_duration = "PT${var.pim_maximum_duration_hours}H"
    require_justification = var.pim_require_justification
  }

  eligible_assignment_rules {
    expiration_required = var.expiration_required
  }
}
