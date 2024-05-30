<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-cache-redis

This module implements the AVM version of the Azure Cache for Redis and supporting resources.  It includes the standard AVM interfaces.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.105)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.105)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) (resource)
- [azurerm_redis_cache.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) (resource)
- [azurerm_redis_cache_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache_access_policy) (resource)
- [azurerm_redis_cache_access_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache_access_policy_assignment) (resource)
- [azurerm_redis_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_firewall_rule) (resource)
- [azurerm_redis_linked_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_linked_server) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure region where this and supporting resources should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_cache_access_policies"></a> [cache\_access\_policies](#input\_cache\_access\_policies)

Description: A map of objects describing one or more Redis cache access policies.
- `<map key>` - The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
  - `name` - (Required) - The name string of the Redis Cache Access Policy. Changing this forces a new policy to be created.
  - `permissions - (Required) - A string describing the permissions to be assigned to this Redis Cache Access Policy. Changing this forces a new policy to be created.
`

Type:

```hcl
map(object({
    name        = string
    permissions = string
  }))
```

Default: `{}`

### <a name="input_cache_access_policy_assignments"></a> [cache\_access\_policy\_assignments](#input\_cache\_access\_policy\_assignments)

Description: A map of objects defining one or more Redis Cache access policy assignments.
- `<map key>` - The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
  - `name` - (Required) - The name of the Redis Cache Access Policy Assignment.  Changing this forces a new policy assignment to be created.
  - `access_policy_name` - (Required) - The name of the Access Policy to be assigned. Changing this forces a new policy assignment to be created.
  - `object_id` - (Required) - The principal ID to be assigned to the Access Policy. Changing this forces a new policy assignment to be created.
  - `object_id_alias` - (Required) - The alias of the principal ID. User-Friendly name for object ID.  Also represents the username for token-based authentication. Changing this forces a new policy assignment to be created.

Type:

```hcl
map(object({
    name               = string
    access_policy_name = string
    object_id          = string
    object_id_alias    = string
  }))
```

Default: `{}`

### <a name="input_cache_firewall_rules"></a> [cache\_firewall\_rules](#input\_cache\_firewall\_rules)

Description: A map of objects defining one or more Redis Cache firewall rules.
- `<map key>` - The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
  - `name` - (Required) - The name for the firewall rule
  - `start_ip` - (Required) - The starting IP Address for clients that are allowed to access the Redis Cache.
  - `end_ip` - (Required) - The ending IP Address for clients that are allowed to access the Redis Cache.

Type:

```hcl
map(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
```

Default: `{}`

### <a name="input_capacity"></a> [capacity](#input\_capacity)

Description: (Required) - The size of the Redis Cache to deploy.  Valid values for Basic and Standard skus are 0-6, and for the premium sku is 1-5

Type: `number`

Default: `2`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_non_ssl_port"></a> [enable\_non\_ssl\_port](#input\_enable\_non\_ssl\_port)

Description: (Optional) - Enable the non-ssl port 6379.  Disabled by default

Type: `bool`

Default: `false`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_linked_redis_caches"></a> [linked\_redis\_caches](#input\_linked\_redis\_caches)

Description: A map of objects defining one or linked Redis Cache instances to use as secondaries.
- `<map key>` - The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
  - linked\_redis\_cache\_resource\_id = (Required) - The Azure resource ID of the Redis Cache that is being linked. Changing this forces a new Redis to be created.
  - linked\_redis\_cache\_location = (Required) - The location value for the Redis Cache that is being linked. Changing this forces a new Redis to be created.
  - server\_role - (Required) - The role of the linked Redis Cache.  Possible values are `Primary` and `Secondary`. Changing this forces a new Redis to be created.

Type:

```hcl
map(object({
    linked_redis_cache_resource_id = string
    linked_redis_cache_location    = string
    server_role                    = string
  }))
```

Default: `{}`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version)

Description: (Optional) - The minimum TLS version.  Possible values are `1.0`, `1.1`, and `1.2`.  Defaults to `1.2`

Type: `string`

Default: `"1.2"`

### <a name="input_patch_schedule"></a> [patch\_schedule](#input\_patch\_schedule)

Description: A set of objects describing the following patch schedule attributes. If no value is configured defaults to an empty set.
- `day_of_week` - (Optional) - A string value for the day of week to start the patch schedule.  Valid values are `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, and `Sunday`.
- `maintenance_window` - (Optional) - A string value following the ISO 8601 timespan system which specifies the length of time the Redis Cache can be updated from the start hour. Defaults to `PT5H`.
- `start_hour_utc` - (Optional) - The start hour for maintenance in UTC. Possible values range from 0-23.  Defaults to 0.

Type:

```hcl
set(object({
    day_of_week        = optional(string, "Saturday")
    maintenance_window = optional(string, "PT5H")
    start_hour_utc     = optional(number, 0)
  }))
```

Default: `[]`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description: A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
```

Default: `{}`

### <a name="input_private_static_ip_address"></a> [private\_static\_ip\_address](#input\_private\_static\_ip\_address)

Description: (Optional) - The static IP Address to assign to the Redis Cache when hosted inside a virtual network. Configuring this value implies that the `subnet_id` value has been set.

Type: `string`

Default: `null`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: (Optional) - Identifies whether the public network access is allowed for the Redis Cache. `True` means that both public and private endpoint access is allowed. `False` limits access to the private endpoint only. Defaults to `True`.

Type: `bool`

Default: `true`

### <a name="input_redis_configuration"></a> [redis\_configuration](#input\_redis\_configuration)

Description: Describes redis configuration block.  
      aof\_backup\_enabled                      = (Optional) Enable or disable AOF persistence for this Redis Cache. Defaults to false. Note: `aof_backup_enabled` can only be set when SKU is Premium.  
      aof\_storage\_connection\_string\_0         = (Optional) First Storage Account connection string for AOF persistence.  
      aof\_storage\_connection\_string\_1         = (Optional) Second Storage Account connection string for AOF persistence.  
      enable\_authentication                   = (Optional) If set to false, the Redis instance will be accessible without authentication. Defaults to true.  
      active\_directory\_authentication\_enabled = (Optional) Enable Microsoft Entra (AAD) authentication. Defaults to false.  
      maxmemory\_reserved                      = (Optional) Value in megabytes reserved for non-cache usage e.g. failover. Defaults are shown below.  
      maxmemory\_delta                         = (Optional) The max-memory delta for this Redis instance. Defaults are shown below.  
      maxmemory\_policy                        = (Optional) How Redis will select what to remove when maxmemory is reached. Defaults to volatile-lru.  
      data\_persistence\_authentication\_method  = (Optional) Preferred auth method to communicate to storage account used for data persistence. Possible values are SAS and ManagedIdentity. Defaults to SAS.  
      maxfragmentationmemory\_reserved         = (Optional) Value in megabytes reserved to accommodate for memory fragmentation. Defaults are shown below.  
      rdb\_backup\_enabled                      = (Optional) Is Backup Enabled? Only supported on Premium SKUs. Defaults to false. Note - If rdb\_backup\_enabled set to true, rdb\_storage\_connection\_string must also be set.  
      rdb\_backup\_frequency                    = (Optional) The Backup Frequency in Minutes. Only supported on Premium SKUs. Possible values are: 15, 30, 60, 360, 720 and 1440.  
      rdb\_backup\_max\_snapshot\_count           = (Optional) The maximum number of snapshots to create as a backup. Only supported for Premium SKUs.  
      rdb\_storage\_connection\_string           = (Optional) The Connection String to the Storage Account. Only supported for Premium SKUs. In the format: DefaultEndpointsProtocol=https;BlobEndpoint=\$\{azurerm\_storage\_account.example.primary\_blob\_endpoint\};AccountName=\$\{azurerm\_storage\_account.example.name\};AccountKey=\$\{azurerm\_storage\_account.example.primary\_access\_key\}.  
      storage\_account\_subscription\_id         = (Optional) The ID of the Subscription containing the Storage Account.  
      notify\_keyspace\_events                  = (Optional) Keyspace notifications allows clients to subscribe to Pub/Sub channels in order to receive events affecting the Redis data set in some way. Reference

Type:

```hcl
object({
    aof_backup_enabled                      = optional(bool)
    aof_storage_connection_string_0         = optional(string)
    aof_storage_connection_string_1         = optional(string)
    enable_authentication                   = optional(bool)
    active_directory_authentication_enabled = optional(bool)
    maxmemory_reserved                      = optional(number)
    maxmemory_delta                         = optional(number)
    maxfragmentationmemory_reserved         = optional(number)
    maxmemory_policy                        = optional(string)
    data_persistence_authentication_method  = optional(string) #TODO: research the managed identity vs. SAS key and determine level of effort required to default to ManagedIdentity as the more secure option, and review what happens if data persistence is not enabled.
    rdb_backup_enabled                      = optional(bool)   #TODO: Research if we want backups to be true. Given this is cache, probably not required.
    rdb_backup_frequency                    = optional(number)
    rdb_backup_max_snapshot_count           = optional(number)
    rdb_storage_connection_string           = optional(string)
    storage_account_subscription_id         = optional(string)
    notify_keyspace_events                  = optional(string)
  })
```

Default: `{}`

### <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version)

Description: (Optional) Redis version.  Only major version needed.  Valid values are: `4` and `6`

Type: `number`

Default: `null`

### <a name="input_replicas_per_master"></a> [replicas\_per\_master](#input\_replicas\_per\_master)

Description: (Optional) - The quantity of replicas to create per master for this Redis Cache.

Type: `number`

Default: `null`

### <a name="input_replicas_per_primary"></a> [replicas\_per\_primary](#input\_replicas\_per\_primary)

Description: (Optional) Quantity of replicas to create per primary for this Redis Cache.

Type: `number`

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_shard_count"></a> [shard\_count](#input\_shard\_count)

Description: (Optional) - Only available when using the `Premium` SKU. The number of shards to create on the Redis Cluster.

Type: `number`

Default: `null`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: (Required) - The Redis SKU to use.  Possible values are `Basic`, `Standard`, `Premium`, and `Enterprise`. Note: Downgrading the sku will force new resource creation.

Type: `string`

Default: `"Premium"`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: (Optional) - Only available when using the `Premium` SKU. The ID of the Subnet within which the Redis Cache should be deployed. This Subnet must only contain Azure Cache for Redis instances without any other type of resources.  Changing this forces a new resource to be created.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_tenent_settings"></a> [tenent\_settings](#input\_tenent\_settings)

Description: (Optional) A mapping of tenant settings to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: (Optional) - Specifies a list of Availability Zones in which this Redis Cache should be located.  Changing this forces a new Redis Cache to be created.

Type: `list(string)`

Default:

```json
[
  "1",
  "2",
  "3"
]
```

## Outputs

The following outputs are exported:

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of private endpoints. The map key is the supplied input to var.private\_endpoints. The map value is the entire azurerm\_private\_endpoint resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource id of the redis cache resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->