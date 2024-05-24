#Create the azurerm resource for redis firewall rules here
resource "azurerm_redis_firewall_rule" "this" {
  for_each = var.cache_firewall_rules

  end_ip              = each.value.end_ip
  name                = each.value.name
  redis_cache_name    = azurerm_redis_cache.this.name
  resource_group_name = var.resource_group_name
  start_ip            = each.value.start_ip
}

