

locals {

    direct_members = [for member in local.members : member.object_id if lower(member.pim_type) == "disabled" ]

    members = concat( 

        # We build a single flat list of objects with the following attributes:
        
        # Users:
        # - object_id
        # - user_principal_name
        # - kind
        # - pim_expiration_hours
        # - pim_type
        
        # Groups:
        # - object_id
        # - display_name
        # - kind
        # - pim_expiration_hours
        # - pim_type

        # Service Principals:
        # - object_id
        # - display_name
        # - kind
        # - pim_expiration_hours
        # - pim_type

        # This objects will be used in the azuread_privileged_access_group_eligibility_schedule resources and
        # in the azuread_group_member resources.

        # First, we iterate over the users from the emails
        [for user in data.azuread_users.members_from_emails.users : {
        
            object_id = user.object_id
        
            user_principal_name = user.user_principal_name
        
            pim_expiration_hours = lookup(
                
                element([for member in var.members : member if member.email == user.user_principal_name], 0).pim, 
                
                "expiration_hours",

                null

            )
        
            pim_type = element([for member in var.members : member if member.email == user.user_principal_name], 0).pim.type
        
            permanent_assignment = element([for member in var.members : member if member.email == user.user_principal_name], 0).pim.permanent_assignment
        
        }],

        # Next, we iterate over the users from the object_ids
        [for user in data.azuread_users.members_from_object_ids.users : {
        
            object_id = user.object_id
        
            user_principal_name = user.user_principal_name
        
            pim_expiration_hours = lookup(
                
                element([for member in var.members : member if member.object_id == user.object_id], 0).pim, 
                
                "expiration_hours",

                null

            )
        
            pim_type = element([for member in var.members : member if member.object_id == user.object_id], 0).pim.type

            permanent_assignment = element([for member in var.members : member if member.object_id == user.object_id], 0).pim.permanent_assignment
        
        }],
    
        # Next, we iterate over the groups from the display names
        [for index, group in data.azuread_groups.members_from_display_names.display_names : {
        
            object_id = data.azuread_groups.members_from_display_names.object_ids[index]

            display_name = group
        
            pim_expiration_hours = lookup(
                
                element([for member in var.members : member if member.display_name == group], 0).pim, "expiration_hours", 
                
                null
                
            )
        
            pim_type = element([for member in var.members : member if member.display_name == group], 0).pim.type

            permanent_assignment = element([for member in var.members : member if member.display_name == group], 0).pim.permanent_assignment
        
        }],

        # Next, we iterate over the groups from the object_ids
        [for index, group in data.azuread_groups.members_from_object_ids.object_ids : {
        
            object_id = group

            display_name = data.azuread_groups.members_from_object_ids.display_names[index]
        
            pim_expiration_hours = lookup(
                
                element([for member in var.members : member if member.object_id == group], 0).pim, 
                
                "expiration_hours",

                null

            )
        
            pim_type = element([for member in var.members : member if member.object_id == group], 0).pim.type

            permanent_assignment = element([for member in var.members : member if member.object_id == group], 0).pim.permanent_assignment
        
        }],

        # Next, we iterate over the service principals from the object_ids
        [for service_principal in data.azuread_service_principals.members_from_object_ids.service_principals : {
        
            object_id = service_principal.object_id
        
            display_name = service_principal.display_name
        
            pim_expiration_hours = lookup(
                
                element([for member in var.members : member if member.object_id == service_principal.object_id], 0).pim, 
                
                "expiration_hours",

                null
            
            )
        
            pim_type = element([for member in var.members : member if member.object_id == service_principal.object_id], 0).pim.type

            permanent_assignment = element([for member in var.members : member if member.object_id == service_principal.object_id], 0).pim.permanent_assignment
        
        }],

        # Finally, we iterate over the service principals from the display names
        [for service_principal in data.azuread_service_principals.members_from_display_name.service_principals : {
        
            object_id = service_principal.object_id
        
            display_name = service_principal.display_name
        
            pim_expiration_hours = lookup(
                
                element([for member in var.members : member if member.display_name == service_principal.display_name], 0).pim, 
                
                "expiration_hours",

                null

            )
        
            pim_type = element([for member in var.members : member if member.display_name == service_principal.display_name], 0).pim.type

            permanent_assignment = element([for member in var.members : member if member.display_name == service_principal.display_name], 0).pim.permanent_assignment
        
        }]
    )
        
}
