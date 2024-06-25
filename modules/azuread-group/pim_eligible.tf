# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_eligibility_schedule
resource "azuread_privileged_access_group_eligibility_schedule" "members" {

    for_each = { for member in local.members : member.object_id  => member if lower(member.pim_type) == "eligible"}

    group_id        = azuread_group.this.id

    principal_id    = each.value.object_id 

    assignment_type = "member"

    duration        = "PT${each.value.pim_expiration_hours != null ? each.value.pim_expiration_hours : var.default_pim_duration}H"

    permanent_assignment = each.value.permanent_assignment != null ? each.value.permanent_assignment : false

    depends_on = [ 
    
        azuread_group_role_management_policy.members,
    
        azuread_group_role_management_policy.owners
    
    ]

}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_eligibility_schedule
resource "azuread_privileged_access_group_eligibility_schedule" "owners" {

    for_each = { for owner in local.owners : owner.object_id  => owner if lower(owner.pim_type) == "eligible"}

    group_id        = azuread_group.this.id

    principal_id    = each.value.object_id 

    assignment_type = "owner"

    #duration        = "PT${each.value.pim_expiration_hours != null ? each.value.pim_expiration_hours : var.default_pim_duration}H"

    permanent_assignment = each.value.permanent_assignment != null ? each.value.permanent_assignment : false

    depends_on = [ 
    
        azuread_group_role_management_policy.members,
    
        azuread_group_role_management_policy.owners
    
    ]
}
