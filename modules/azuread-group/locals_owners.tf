locals {
  direct_owners = [for owner in local.owners : owner.object_id if lower(owner.pim_type) == "disabled"]
  owners = concat(

    # We build a single flat list of objects with the following attributes:

    # Users:
    # - object_id
    # - user_principal_name
    # - pim_expiration_hours
    # - pim_type

    # Groups:
    # - object_id
    # - display_name
    # - pim_expiration_hours
    # - pim_type

    # Service Principals:
    # - object_id
    # - display_name
    # - pim_expiration_hours
    # - pim_type

    # First, we iterate over the users from the emails
    [for user in data.azuread_users.owners_from_emails.users : {
      object_id           = user.object_id
      user_principal_name = user.user_principal_name
      pim_expiration_hours = lookup(
        element([for owner in var.owners : owner if owner.email == user.user_principal_name], 0).pim,
        "expiration_hours",
        null
      )
      pim_type             = element([for owner in var.owners : owner if owner.email == user.user_principal_name], 0).pim.type
      permanent_assignment = element([for owner in var.owners : owner if owner.email == user.user_principal_name], 0).pim.permanent_assignment
    }],

    # Next, we iterate over the users from the object_ids
    [for user in data.azuread_users.owners_from_object_ids.users : {
      object_id           = user.object_id
      user_principal_name = user.user_principal_name
      pim_expiration_hours = lookup(
        element([for owner in var.owners : owner if owner.object_id == user.object_id], 0).pim,
        "expiration_hours",
        null
      )
      pim_type             = element([for owner in var.owners : owner if owner.object_id == user.object_id], 0).pim.type
      permanent_assignment = element([for owner in var.owners : owner if owner.object_id == user.object_id], 0).pim.permanent_assignment
    }],

    # Next, we iterate over the groups from the display names
    [for index, group in data.azuread_groups.owners_from_display_names.display_names : {
      object_id    = data.azuread_groups.owners_from_display_names.object_ids[index]
      display_name = group
      pim_expiration_hours = lookup(
        element([for owner in var.owners : owner if owner.display_name == group], 0).pim, "expiration_hours",
        null
      )
      pim_type             = element([for owner in var.owners : owner if owner.display_name == group], 0).pim.type
      permanent_assignment = element([for owner in var.owners : owner if owner.display_name == group], 0).pim.permanent_assignment
    }],

    # Next, we iterate over the groups from the object_ids
    [for index, group in data.azuread_groups.owners_from_object_ids.object_ids : {
      object_id    = group
      display_name = data.azuread_groups.owners_from_object_ids.display_names[index]
      pim_expiration_hours = lookup(
        element([for owner in var.owners : owner if owner.object_id == group], 0).pim,
        "expiration_hours",
        null
      )
      pim_type             = element([for owner in var.owners : owner if owner.object_id == group], 0).pim.type
      permanent_assignment = element([for owner in var.owners : owner if owner.object_id == group], 0).pim.permanent_assignment
    }],

    # Next, we iterate over the service principals from the object_ids
    [for service_principal in data.azuread_service_principals.owners_from_object_ids.service_principals : {
      object_id    = service_principal.object_id
      display_name = service_principal.display_name
      pim_expiration_hours = lookup(
        element([for owner in var.owners : owner if owner.object_id == service_principal.object_id], 0).pim,
        "expiration_hours",
        null
      )
      pim_type             = element([for owner in var.owners : owner if owner.object_id == service_principal.object_id], 0).pim.type
      permanent_assignment = element([for owner in var.owners : owner if owner.object_id == service_principal.object_id], 0).pim.permanent_assignment
    }],

    # Next, we iterate over the service principals from the display names
    [for service_principal in data.azuread_service_principals.owners_from_display_name.service_principals : {
      object_id    = service_principal.object_id
      display_name = service_principal.display_name
      pim_expiration_hours = lookup(
        element([for owner in var.owners : owner if owner.display_name == service_principal.display_name], 0).pim,
        "expiration_hours",
        null
      )
      pim_type             = element([for owner in var.owners : owner if owner.display_name == service_principal.display_name], 0).pim.type
      permanent_assignment = element([for owner in var.owners : owner if owner.display_name == service_principal.display_name], 0).pim.permanent_assignment
    }]
  )
}

