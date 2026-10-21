mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {
  mock_resource "azurerm_redis_cache" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Cache/Redis/test"
    }
  }
  mock_resource "azurerm_private_endpoint" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/privateEndpoints/test"
    }
  }
}

mock_provider "terraform" {}

variables {
  name                = "test"
  location            = "uksouth"
  resource_group_name = "test"
  enable_telemetry    = false
}

run "empty_defaults" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = apply

  assert {
    condition = (
      length(output.private_endpoints) == 0 &&
      length(azurerm_role_assignment.private_endpoints) == 0 &&
      length(azurerm_management_lock.private_endpoints) == 0 &&
      length(azurerm_private_endpoint_application_security_group_association.this) == 0
    )
    error_message = "Omitted endpoints must not create endpoints, assignments, locks, or associations."
  }
}

run "managed_defaults" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = apply

  variables {
    private_endpoints = {
      endpoint = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/test"
        ip_configurations = {
          static = {
            name               = "static"
            private_ip_address = "10.0.0.4"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].name == "pep-test" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].private_service_connection[0].name == "pse-test" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].private_service_connection[0].subresource_names == tolist(["redisCache"]) &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].ip_configuration).member_name == "Azure redis cache" &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].ip_configuration).subresource_name == "redisCache" &&
      length(azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].private_dns_zone_group) == 0 &&
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0 &&
      length(azurerm_role_assignment.private_endpoints) == 0 &&
      length(azurerm_management_lock.private_endpoints) == 0 &&
      output.private_endpoints["endpoint"].id == azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].id
    )
    error_message = "Managed endpoints must preserve existing addresses, names, member defaults, and DNS-off behavior."
  }
}

run "unmanaged_defaults" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = apply

  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      endpoint = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/test"
        ip_configurations = {
          static = {
            name               = "static"
            private_ip_address = "10.0.0.4"
          }
        }
      }
    }
  }

  assert {
    condition = (
      one(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["endpoint"].ip_configuration).member_name == "redisCache" &&
      azurerm_private_endpoint.this_unmanaged_dns_zone_groups["endpoint"].private_service_connection[0].subresource_names == tolist(["redisCache"]) &&
      length(azurerm_private_endpoint.this_managed_dns_zone_groups) == 0 &&
      length(azurerm_role_assignment.private_endpoints) == 0 &&
      length(azurerm_management_lock.private_endpoints) == 0 &&
      output.private_endpoints["endpoint"].id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["endpoint"].id
    )
    error_message = "Unmanaged endpoints must preserve their address, member default, and output selection."
  }
}

run "managed_overrides" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = apply

  variables {
    private_endpoints = {
      endpoint = {
        name                            = "custom-endpoint"
        subnet_resource_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/test"
        subresource_name                = "custom-service"
        resource_group_name             = "endpoint-group"
        private_service_connection_name = "custom-connection"
        network_interface_name          = "custom-nic"
        private_dns_zone_group_name     = "custom-dns"
        private_dns_zone_resource_ids   = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"]
        tags                            = { endpoint = "custom" }
        application_security_group_associations = {
          asg = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/applicationSecurityGroups/test"
        }
        ip_configurations = {
          static = {
            name               = "custom-static"
            private_ip_address = "10.0.0.5"
            member_name        = "custom-member"
          }
        }
        role_assignments = {
          reader = {
            name                                   = "11111111-1111-1111-1111-111111111111"
            role_definition_id_or_name             = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            principal_id                           = "22222222-2222-2222-2222-222222222222"
            description                            = "Endpoint reader"
            skip_service_principal_aad_check       = true
            condition                              = "!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})"
            condition_version                      = "2.0"
            delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test"
            principal_type                         = "ServicePrincipal"
          }
        }
        lock = {
          kind  = "ReadOnly"
          name  = "custom-lock"
          notes = "Endpoint lock notes"
        }
      }
    }
  }

  assert {
    condition = (
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].name == "custom-endpoint" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].resource_group_name == "endpoint-group" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].custom_network_interface_name == "custom-nic" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].tags["endpoint"] == "custom" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].private_service_connection[0].name == "custom-connection" &&
      azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].private_service_connection[0].subresource_names == tolist(["custom-service"]) &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].ip_configuration).member_name == "custom-member" &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].ip_configuration).subresource_name == "custom-service" &&
      one(azurerm_private_endpoint.this_managed_dns_zone_groups["endpoint"].private_dns_zone_group).name == "custom-dns"
    )
    error_message = "Managed endpoints must consume explicit connection, network, DNS, member, and service settings."
  }

  assert {
    condition = alltrue([
      for key, assignment in azurerm_role_assignment.private_endpoints :
      key == jsonencode(["endpoint", "reader"]) &&
      assignment.name == var.private_endpoints.endpoint.role_assignments.reader.name &&
      assignment.principal_id == var.private_endpoints.endpoint.role_assignments.reader.principal_id &&
      assignment.scope == output.private_endpoints["endpoint"].id &&
      assignment.role_definition_id == var.private_endpoints.endpoint.role_assignments.reader.role_definition_id_or_name &&
      assignment.description == "Endpoint reader" &&
      assignment.skip_service_principal_aad_check &&
      assignment.condition == var.private_endpoints.endpoint.role_assignments.reader.condition &&
      assignment.condition_version == "2.0" &&
      assignment.delegated_managed_identity_resource_id == var.private_endpoints.endpoint.role_assignments.reader.delegated_managed_identity_resource_id &&
      assignment.principal_type == "ServicePrincipal"
    ]) && length(azurerm_role_assignment.private_endpoints) == 1
    error_message = "Every role-assignment field must reach an assignment scoped to the endpoint."
  }

  assert {
    condition = (
      azurerm_management_lock.private_endpoints["endpoint"].name == "custom-lock" &&
      azurerm_management_lock.private_endpoints["endpoint"].lock_level == "ReadOnly" &&
      azurerm_management_lock.private_endpoints["endpoint"].notes == "Endpoint lock notes" &&
      azurerm_management_lock.private_endpoints["endpoint"].scope == output.private_endpoints["endpoint"].id &&
      azurerm_private_endpoint_application_security_group_association.this["endpoint-asg"].private_endpoint_id == output.private_endpoints["endpoint"].id
    )
    error_message = "Endpoint locks and existing association addresses must use the managed endpoint scope."
  }
}

run "unmanaged_overrides" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = apply

  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      endpoint = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/test"
        subresource_name              = "custom-service"
        private_dns_zone_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"]
        application_security_group_associations = {
          asg = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/applicationSecurityGroups/test"
        }
        ip_configurations = {
          static = {
            name               = "custom-static"
            private_ip_address = "10.0.0.5"
            member_name        = "custom-member"
          }
        }
        role_assignments = {
          reader = {
            name                       = "11111111-1111-1111-1111-111111111111"
            role_definition_id_or_name = "Reader"
            principal_id               = "22222222-2222-2222-2222-222222222222"
          }
        }
        lock = {
          kind  = "ReadOnly"
          name  = "custom-lock"
          notes = "Endpoint lock notes"
        }
      }
    }
  }

  assert {
    condition = (
      one(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["endpoint"].ip_configuration).member_name == "custom-member" &&
      one(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["endpoint"].ip_configuration).subresource_name == "custom-service" &&
      azurerm_private_endpoint.this_unmanaged_dns_zone_groups["endpoint"].private_service_connection[0].subresource_names == tolist(["custom-service"]) &&
      length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["endpoint"].private_dns_zone_group) == 0 &&
      azurerm_management_lock.private_endpoints["endpoint"].scope == output.private_endpoints["endpoint"].id &&
      one(values(azurerm_role_assignment.private_endpoints)).scope == output.private_endpoints["endpoint"].id &&
      azurerm_private_endpoint_application_security_group_association.this["endpoint-asg"].private_endpoint_id == output.private_endpoints["endpoint"].id
    )
    error_message = "Unmanaged mode must wire member, service, assignment, lock, and association settings without managing DNS."
  }
}

run "assignment_and_lock_defaults" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = apply

  variables {
    private_endpoints = {
      endpoint = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/test"
        role_assignments = {
          reader = {
            role_definition_id_or_name = "Reader"
            principal_id               = "22222222-2222-2222-2222-222222222222"
          }
        }
        lock = { kind = "CanNotDelete" }
      }
    }
  }

  assert {
    condition = (
      one(values(azurerm_role_assignment.private_endpoints)).name != null &&
      one(values(azurerm_role_assignment.private_endpoints)).role_definition_name == "Reader" &&
      !one(values(azurerm_role_assignment.private_endpoints)).skip_service_principal_aad_check &&
      azurerm_management_lock.private_endpoints["endpoint"].name == "lock-CanNotDelete" &&
      azurerm_management_lock.private_endpoints["endpoint"].notes == null
    )
    error_message = "An omitted assignment name must be provider-generated; role names and default lock names must work."
  }
}

run "invalid_subnet" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = plan

  variables {
    private_endpoints = {
      endpoint = { subnet_resource_id = "not-a-subnet" }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_dns_zone" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = plan

  variables {
    private_endpoints = {
      endpoint = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/test"
        private_dns_zone_resource_ids = ["not-a-zone"]
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_asg" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = plan

  variables {
    private_endpoints = {
      endpoint = {
        subnet_resource_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/test"
        application_security_group_associations = { asg = "not-an-asg" }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_delegated_identity" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = plan

  variables {
    private_endpoints = {
      endpoint = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/test"
        role_assignments = {
          reader = {
            role_definition_id_or_name             = "Reader"
            principal_id                           = "22222222-2222-2222-2222-222222222222"
            delegated_managed_identity_resource_id = "not-an-identity"
          }
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "metadata_backed_telemetry_enabled" {
  providers = {
    azapi     = azapi
    azurerm   = azurerm
    terraform = terraform
  }
  command = apply

  variables {
    enable_telemetry = true
  }

  assert {
    condition     = length(azapi_resource.telemetry) == 1 && length(terraform_data.telemetry) == 1 && length(data.azapi_client_config.telemetry) == 1
    error_message = "Enabled metadata-backed telemetry must create its deployment, stable instance and client data using only mocked providers."
  }
}
