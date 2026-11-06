resource "azurerm_private_endpoint" "this_managed_dns_zone_groups" {
  for_each = { for k, v in var.private_endpoints : k => v if var.private_endpoints_manage_dns_zone_group }

  location                      = coalesce(each.value.location, var.location)
  name                          = each.value.name != null ? each.value.name : "pep-${var.name}"
  resource_group_name           = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${var.name}"
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = [coalesce(each.value.subresource_name, "redisCache")]
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = coalesce(ip_configuration.value.member_name, "Azure redis cache")
      subresource_name   = coalesce(each.value.subresource_name, "redisCache")
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_resource_ids) > 0 ? ["this"] : []

    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_resource_ids
    }
  }
}

resource "azurerm_private_endpoint" "this_unmanaged_dns_zone_groups" {
  for_each = { for k, v in var.private_endpoints : k => v if !var.private_endpoints_manage_dns_zone_group }

  location                      = coalesce(each.value.location, var.location)
  name                          = each.value.name != null ? each.value.name : "pep-${var.name}"
  resource_group_name           = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${var.name}"
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = [coalesce(each.value.subresource_name, "redisCache")]
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = coalesce(ip_configuration.value.member_name, "redisCache")
      subresource_name   = coalesce(each.value.subresource_name, "redisCache")
    }
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_private_endpoint_application_security_group_association" "this" {
  for_each = local.private_endpoint_application_security_group_associations

  application_security_group_id = each.value.asg_resource_id
  private_endpoint_id           = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this_managed_dns_zone_groups[each.value.pe_key].id : azurerm_private_endpoint.this_unmanaged_dns_zone_groups[each.value.pe_key].id
}

resource "azurerm_role_assignment" "private_endpoints" {
  for_each = local.private_endpoint_role_assignments

  principal_id                           = each.value.assignment.principal_id
  scope                                  = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this_managed_dns_zone_groups[each.value.pe_key].id : azurerm_private_endpoint.this_unmanaged_dns_zone_groups[each.value.pe_key].id
  condition                              = each.value.assignment.condition
  condition_version                      = each.value.assignment.condition_version
  delegated_managed_identity_resource_id = each.value.assignment.delegated_managed_identity_resource_id
  description                            = each.value.assignment.description
  name                                   = each.value.assignment.name
  principal_type                         = each.value.assignment.principal_type
  role_definition_id                     = strcontains(lower(each.value.assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.assignment.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.assignment.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.assignment.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.assignment.skip_service_principal_aad_check
}

resource "azurerm_management_lock" "private_endpoints" {
  for_each = { for key, endpoint in var.private_endpoints : key => endpoint.lock if endpoint.lock != null }

  lock_level = each.value.kind
  name       = coalesce(each.value.name, "lock-${each.value.kind}")
  scope      = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this_managed_dns_zone_groups[each.key].id : azurerm_private_endpoint.this_unmanaged_dns_zone_groups[each.key].id
  notes      = each.value.notes

  depends_on = [
    azurerm_private_endpoint_application_security_group_association.this,
    azurerm_role_assignment.private_endpoints
  ]
}
