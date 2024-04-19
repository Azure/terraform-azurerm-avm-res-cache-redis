#create the main azurerm redis resource here
# NOTE: the Name used for Redis needs to be globally unique

resource "azurerm_redis_cache" "this" {
  # TODO: what if user wants multiple instances of redis?
  count               = var.sku_name != "Enterprise" ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = local.redis_cache_family # family is inferred from the SKU name
  sku_name            = var.sku_name
  enable_non_ssl_port = var.enable_non_ssl_port
  minimum_tls_version = var.minimum_tls_version

  dynamic "patch_schedule" {
    for_each = tolist(var.patch_schedule)
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = patch_schedule.value.start_hour_utc
      maintenance_window = patch_schedule.value.maintenance_window
    }
  }

  private_static_ip_address     = var.private_static_ip_address
  public_network_access_enabled = var.public_network_access_enabled

  redis_configuration {
    aof_backup_enabled              = var.redis_configuration.aof_backup_enabled
    aof_storage_connection_string_0 = var.redis_configuration.aof_storage_connection_string_0
    aof_storage_connection_string_1 = var.redis_configuration.aof_storage_connection_string_1
  }

}
