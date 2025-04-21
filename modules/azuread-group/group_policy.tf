# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy#require_justification
resource "azuread_group_role_management_policy" "members" {
  group_id = azuread_group.this.id
  role_id  = "member"

  activation_rules {
    maximum_duration      = "PT${var.pim_maximum_duration_hours}H"
    require_justification = var.pim_require_justification
    require_approval      = false
  }

  eligible_assignment_rules {
    expiration_required = var.expiration_required
  }

  lifecycle {
    ignore_changes = [
      activation_rules[0].approval_stage,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy#require_justification
resource "azuread_group_role_management_policy" "owners" {
  group_id = azuread_group.this.id
  role_id  = "owner"

  activation_rules {
    maximum_duration      = "PT${var.pim_maximum_duration_hours}H"
    require_justification = var.pim_require_justification
    require_approval      = false
  }

  eligible_assignment_rules {
    expiration_required = var.expiration_required
  }

  lifecycle {
    ignore_changes = [
      activation_rules[0].approval_stage,
    ]
  }
}
