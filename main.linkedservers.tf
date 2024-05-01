#create the linked server azurerm resources here
resource "azurerm_redis_linked_server" "this" {
  for_each                    = var.linked_redis_caches
  target_redis_cache_name     = azurerm_redis_cache.this.name
  resource_group_name         = var.resource_group_name
  linked_redis_cache_id       = each.value.linked_redis_cache_resource_id
  linked_redis_cache_location = each.value.linked_redis_cache_location
  server_role                 = each.value.server_role
}
