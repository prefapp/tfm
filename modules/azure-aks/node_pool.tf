# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  for_each              = var.node_pool_additionals
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes.id
  vnet_subnet_id        = data.azurerm_subnet.aks_subnet.id
  name                  = each.value.name
  vm_size               = each.value.vm_size
  node_labels           = each.value.node_labels
  os_disk_size_gb       = each.value.os_disk_size_gb
  enable_auto_scaling   = each.value.enable_auto_scaling
  # `max_count` and `min_count` must be set to `null` when enable_auto_scaling is set to `false`
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  node_count            = each.value.node_count
  tags                  = each.value.tags
  depends_on = [
    azurerm_kubernetes_cluster.kubernetes
   ]
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      tags["cliente"],
      tags["producto"],
      tags["env"]
    ]
  }
}
