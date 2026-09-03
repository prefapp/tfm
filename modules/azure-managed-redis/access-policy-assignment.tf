# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_access_policy_assignment
resource "azurerm_managed_redis_access_policy_assignment" "this" {
  for_each = { for idx, ap in var.access_policy_assignments : idx => ap }

  managed_redis_id = azurerm_managed_redis.this.id
  object_id        = each.value.object_id

  depends_on = [azurerm_managed_redis.this]
}
