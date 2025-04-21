# Get the user members from the email addresses
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users
data "azuread_users" "members_from_emails" {
  user_principal_names = distinct(
    compact(var.members != null ? [for member in var.members : member.email if lower(member.type) == "user"] : [])
  )
}

# Get the user members from the object_ids
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users
data "azuread_users" "members_from_object_ids" {
  object_ids = distinct(
    compact(var.members != null ? [for member in var.members : member.object_id if lower(member.type) == "user"] : [])
  )
}

# Get the group members from the display names
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups
data "azuread_groups" "members_from_display_names" {
  display_names = distinct(
    compact(var.members != null ? [for member in var.members : member.display_name if lower(member.type) == "group"] : [])
  )
}

# Get the group members from the object_ids
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups
data "azuread_groups" "members_from_object_ids" {
  object_ids = distinct(
    compact(var.members != null ? [for member in var.members : member.object_id if lower(member.type) == "group"] : [])
  )
}

# Get the service principal members from the object_ids
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals
data "azuread_service_principals" "members_from_object_ids" {
  object_ids = distinct(
    compact(var.members != null ? [for member in var.members : member.object_id if lower(member.type) == "service_principal"] : [])
  )
}

# Get the service principal members from the display names
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals
data "azuread_service_principals" "members_from_display_name" {
  display_names = distinct(
    compact(var.members != null ? [for member in var.members : member.display_name if lower(member.type) == "service_principal"] : [])
  )
}
