resource "azuread_privileged_access_group_eligibility_schedule" "this" {

    for_each = var.

    group_id        = azuread_group.example.id

    principal_id    = "695f9ea0-9c1d-4a43-b764-eb2f3c0f3d3d" 

    assignment_type = "member"

    duration        = "P30D"

}
