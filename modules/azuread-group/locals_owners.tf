locals {
    owners_object_ids = distinct(
        
        concat(
    
            data.azuread_users.owners_from_object_ids.object_ids, 
        
            data.azuread_users.owners_from_emails.object_ids,

            data.azuread_groups.owners_from_object_ids.object_ids,

            data.azuread_groups.owners_from_display_names.object_ids,

            data.azuread_service_principals.owners_from_object_ids.object_ids,

            data.azuread_service_principals.owners_from_display_name.object_ids,
        
        )
    )
}
