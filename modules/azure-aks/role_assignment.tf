# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "role_assignment_network_contributor_over_public_ip_aks_predev" {
    count               = var.create_role_assignment_public_ip ? 1 : 0
    scope               = data.azurerm_public_ip.aks_public_ip.id
    role_definition_name = "Network Contributor"
    principal_id        = module.aks.cluster_identity.principal_id
}
