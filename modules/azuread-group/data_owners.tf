# Get the user owners from the email addresses
data "azuread_users" "owners_from_emails" {

    user_principal_names = distinct( 
    
        compact(var.owners != null ? [for owner in var.owners : owner.email if lower(owner.type) == "user"] : [])
    
    )

}

# Get the user owners from the object_ids
data "azuread_users" "owners_from_object_ids" {

    object_ids = distinct( 
        
        compact(var.owners != null ? [for owner in var.owners : owner.object_id if lower(owner.type) == "user"] : [])
    
    )

}

# Get the group owners from the display names
data "azuread_groups" "owners_from_display_names" {

    display_names = distinct( 

        compact(var.owners != null ? [for owner in var.owners : owner.display_name if lower(owner.type) == "group" ] : [])

    )

}

# Get the group owners from the object_ids
data "azuread_groups" "owners_from_object_ids" {

    object_ids = distinct( 
      
        compact(var.owners != null ? [for owner in var.owners : owner.object_id if lower(owner.type) == "group" ] : [])
    
    )
}

# Get the service principal owners from the object_ids
data "azuread_service_principals" "owners_from_object_ids" {

    object_ids = distinct( 
      
        compact(var.owners != null ? [for owner in var.owners : owner.object_id if lower(owner.type) == "service_principal" ] : [])
    
    ) 

}

# Get the service principal owners from the display names
data "azuread_service_principals" "owners_from_display_name" {

  display_names = distinct( 
    
    compact(var.owners != null ? [for owner in var.owners : owner.display_name if lower(owner.type) == "service_principal" ] : [])
  
  )

}
