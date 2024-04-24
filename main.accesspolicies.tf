#Create the azurerm redis access policy and assignment resources here.
resource "azurerm_redis_cache_access_policy" "this" {
  for_each       = var.cache_access_policies
  name           = each.name
  permissions    = each.permissions
  redis_cache_id = azurerm_redis_cache.this
}

resource "azurerm_redis_cache_access_policy_assignment" "this" {
  for_each           = var.cache_access_policy_assignments
  name               = each.name
  redis_cache_id     = azurerm_redis_cache.this
  access_policy_name = each.access_policy_name
  object_id          = each.object_id
  object_id_alias    = each.object_id_alias
}
