#Create the azurerm redis access policy and assignment resources here.
resource "azurerm_redis_cache_access_policy" "this" {
  for_each = var.cache_access_policies

  name           = each.value.name
  permissions    = each.value.permissions
  redis_cache_id = azurerm_redis_cache.this.id
}

resource "azurerm_redis_cache_access_policy_assignment" "this" {
  for_each = var.cache_access_policy_assignments

  name               = each.value.name
  redis_cache_id     = azurerm_redis_cache.this.id
  access_policy_name = each.value.access_policy_name
  object_id          = each.value.object_id
  object_id_alias    = each.value.object_id_alias
}
