output "group_id" {
  description = "The ID of the Azure AD group"

  value = azuread_group.this.id

}
