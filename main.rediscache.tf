#create the main azurerm redis resource here
# NOTE: the Name used for Redis needs to be globally unique

resource "azurerm_redis_cache" "this" {
  capacity                      = var.capacity
  family                        = local.redis_cache_family # family is inferred from the SKU name
  location                      = var.location
  name                          = var.name
  resource_group_name           = var.resource_group_name
  sku_name                      = var.sku_name
  enable_non_ssl_port           = var.enable_non_ssl_port
  minimum_tls_version           = var.minimum_tls_version
  private_static_ip_address     = var.private_static_ip_address
  public_network_access_enabled = var.public_network_access_enabled
  redis_version                 = var.redis_version
  replicas_per_master           = var.replicas_per_master
  replicas_per_primary          = var.replicas_per_primary
  shard_count                   = var.shard_count
  subnet_id                     = var.subnet_id
  tags                          = var.tags
  tenant_settings               = var.tenent_settings
  zones                         = var.zones

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned
    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  dynamic "patch_schedule" {
    for_each = tolist(var.patch_schedule)
    content {
      day_of_week        = patch_schedule.value.day_of_week
      maintenance_window = patch_schedule.value.maintenance_window
      start_hour_utc     = patch_schedule.value.start_hour_utc
    }
  }
  redis_configuration {
    active_directory_authentication_enabled = var.redis_configuration.active_directory_authentication_enabled
    aof_backup_enabled                      = var.redis_configuration.aof_backup_enabled
    aof_storage_connection_string_0         = var.redis_configuration.aof_storage_connection_string_0
    aof_storage_connection_string_1         = var.redis_configuration.aof_storage_connection_string_1
    data_persistence_authentication_method  = var.redis_configuration.data_persistence_authentication_method
    enable_authentication                   = var.redis_configuration.enable_authentication
    maxfragmentationmemory_reserved         = var.redis_configuration.maxfragmentationmemory_reserved
    maxmemory_delta                         = var.redis_configuration.maxmemory_delta
    maxmemory_policy                        = var.redis_configuration.maxmemory_policy
    maxmemory_reserved                      = var.redis_configuration.maxmemory_reserved
    notify_keyspace_events                  = var.redis_configuration.notify_keyspace_events
    rdb_backup_enabled                      = var.redis_configuration.rdb_backup_enabled
    rdb_backup_frequency                    = var.redis_configuration.rdb_backup_frequency
    rdb_backup_max_snapshot_count           = var.redis_configuration.rdb_backup_max_snapshot_count
    rdb_storage_connection_string           = var.redis_configuration.rdb_storage_connection_string
    storage_account_subscription_id         = var.redis_configuration.storage_account_subscription_id
  }
}
