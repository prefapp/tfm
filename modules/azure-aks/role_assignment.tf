# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "role_assignment_network_contributor_over_public_ip_aks" {
    count                = var.create_role_assignment_public_ip && var.net_profile_outbound_type == "loadBalancer" && var.public_ip_name != null ? 1 : 0
    scope                = data.azurerm_public_ip.aks_public_ip[0].id
    role_definition_name = "Network Contributor"
    principal_id         = module.aks.cluster_identity.principal_id
}
