# Use the decoded data in your resources
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  for_each              = local.input.aks.extra_node_pools # Loop over each extra node pool defined in the input
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes.id # The ID of the AKS cluster where the node pool will be created
  vnet_subnet_id        = data.azurerm_subnet.aks_subnet.id # The ID of the subnet for the node pool
  name                  = each.value.name # The name of the node pool
  vm_size               = each.value.vm_size # The size of the VMs in the node pool
  node_labels           = each.value.node_labels # The labels to apply to the nodes in the node pool
  os_disk_size_gb       = each.value.os_disk_size_gb # The size of the OS disk in GB for the node pool
  enable_auto_scaling   = each.value.enable_auto_scaling # Whether auto-scaling is enabled for the node pool
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null # The minimum number of nodes for the node pool if auto-scaling is enabled
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null # The maximum number of nodes for the node pool if auto-scaling is enabled
  node_count            = each.value.node_count # The number of nodes in the node pool
  tags                  = local.input.aks.tags # The tags to apply to the node pool
  depends_on = [
    azurerm_kubernetes_cluster.kubernetes # This node pool depends on the AKS cluster resource
  ]
}
