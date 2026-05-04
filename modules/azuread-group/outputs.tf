output "group_id" {
  description = "Object ID of the Microsoft Entra ID (Azure AD) group created by this module."

  value = azuread_group.this.id

}
