
locals {
    members_object_ids = distinct(
        
        concat(
    
            data.azuread_users.members_from_object_ids.object_ids, 
        
            data.azuread_users.members_from_emails.object_ids,

            data.azuread_groups.members_from_object_ids.object_ids,

            data.azuread_groups.members_from_display_names.object_ids,

            data.azuread_service_principals.members_from_object_ids.object_ids,

            data.azuread_service_principals.members_from_display_name.object_ids,
        )
    )
}
