########## Required variables
variable "location" {
  type        = string
  description = "The Azure region where this and supporting resources should be deployed."
}

variable "name" {
  type        = string
  description = "The name of the this resource."

  validation {
    condition     = can(regex("^[-A-Za-z0-9]{1,63}$", var.name))
    error_message = "The name must be between 1 and 63 characters long and can only contain alphanumerics and hyphens."
  }
}

#TODO come back to this and see if Enterprise has similar configuration blocks that can be plumbed up here. Confirm if we need to mark this as sensitive
# Q - this block is not limited to following vars only. Other vars such as "enable_authentication", "active_directory_authentication_enabled", "data_persistence_authentication_method" etc are also part of this block. Should we include them here? or those vars were intentaionally separated and kept outside this block?
variable "redis_configuration" {
  type = object({
    aof_backup_enabled                      = optional(bool)
    aof_storage_connection_string_0         = optional(string)
    aof_storage_connection_string_1         = optional(string)
    enable_authentication                   = optional(bool)
    active_directory_authentication_enabled = optional(bool)
    maxmemory_reserved                      = optional(number)
    maxmemory_delta                         = optional(number)
    maxfragmentationmemory_reserved         = optional(number)
    maxmemory_policy                        = optional(string)
    data_persistence_authentication_method  = optional(string)
    rdb_backup_enabled                      = optional(bool) #TODO: Research if we want backups to be true. Given this is cache, probably not required.
    rdb_backup_frequency                    = optional(number)
    rdb_backup_max_snapshot_count           = optional(number)
    rdb_storage_connection_string           = optional(string)
    storage_account_subscription_id         = optional(string)
    notify_keyspace_events                  = optional(string)
  })

  default = {}

  description = <<DESCRIPTION
      aof_backup_enabled                      = (Optional) Enable or disable AOF persistence for this Redis Cache. Defaults to false. Note: `aof_backup_enabled` can only be set when SKU is Premium.
      aof_storage_connection_string_0         = (Optional) First Storage Account connection string for AOF persistence.
      aof_storage_connection_string_1         = (Optional) Second Storage Account connection string for AOF persistence.
      enable_authentication                   = (Optional) If set to false, the Redis instance will be accessible without authentication. Defaults to true.
      active_directory_authentication_enabled = (Optional) Enable Microsoft Entra (AAD) authentication. Defaults to false.
      maxmemory_reserved                      = (Optional) Value in megabytes reserved for non-cache usage e.g. failover. Defaults are shown below.
      maxmemory_delta                         = (Optional) The max-memory delta for this Redis instance. Defaults are shown below.
      maxmemory_policy                        = (Optional) How Redis will select what to remove when maxmemory is reached. Defaults to volatile-lru.
      data_persistence_authentication_method  = (Optional) Preferred auth method to communicate to storage account used for data persistence. Possible values are SAS and ManagedIdentity. Defaults to SAS.
      maxfragmentationmemory_reserved         = (Optional) Value in megabytes reserved to accommodate for memory fragmentation. Defaults are shown below.
      rdb_backup_enabled                      = (Optional) Is Backup Enabled? Only supported on Premium SKUs. Defaults to false. Note - If rdb_backup_enabled set to true, rdb_storage_connection_string must also be set.
      rdb_backup_frequency                    = (Optional) The Backup Frequency in Minutes. Only supported on Premium SKUs. Possible values are: 15, 30, 60, 360, 720 and 1440.
      rdb_backup_max_snapshot_count           = (Optional) The maximum number of snapshots to create as a backup. Only supported for Premium SKUs.
      rdb_storage_connection_string           = (Optional) The Connection String to the Storage Account. Only supported for Premium SKUs. In the format: DefaultEndpointsProtocol=https;BlobEndpoint=\$\{azurerm_storage_account.example.primary_blob_endpoint\};AccountName=\$\{azurerm_storage_account.example.name\};AccountKey=\$\{azurerm_storage_account.example.primary_access_key\}.
      storage_account_subscription_id         = (Optional) The ID of the Subscription containing the Storage Account.
      notify_keyspace_events                  = (Optional) Keyspace notifications allows clients to subscribe to Pub/Sub channels in order to receive events affecting the Redis data set in some way. Reference
   DESCRIPTION
}


variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "cache_access_policies" {
  type = map(object({
    name        = string
    permissions = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of objects describing one or more Redis cache access policies.
- `<map key>` - The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
  - `name` - (Required) - The name string of the Redis Cache Access Policy. Changing this forces a new policy to be created.
  - `permissions - (Required) - A string describing the permissions to be assigned to this Redis Cache Access Policy. Changing this forces a new policy to be created.
DESCRIPTION
}

#TODO - verify what the access policy name represents and the scope of the policy name.  Is this a set of defaults or does it include any custom policies and do they have to be in the same RG or sub?
variable "cache_access_policy_assignments" {
  type = map(object({
    name               = string
    access_policy_name = string
    object_id          = string
    object_id_alias    = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of objects defining one or more Redis Cache access policy assignments.
- `<map key>` - The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
  - `name` - (Required) - The name of the Redis Cache Access Policy Assignment.  Changing this forces a new policy assignment to be created.
  - `access_policy_name` - (Required) - The name of the Access Policy to be assigned. Changing this forces a new policy assignment to be created.
  - `object_id` - (Required) - The principal ID to be assigned to the Access Policy. Changing this forces a new policy assignment to be created.
  - `object_id_alias` - (Required) - The alias of the principal ID. User-Friendly name for object ID.  Also represents the username for token-based authentication. Changing this forces a new policy assignment to be created.
DESCRIPTION
}

#TODO - Can we review this with the PG to determine if they intend to improve the target representation? (single value CIDR syntax as an option?)
variable "cache_firewall_rules" {
  type = map(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of objects defining one or more Redis Cache firewall rules.
- `<map key>` - The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
  - `name` - (Required) - The name for the firewall rule
  - `start_ip` - (Required) - The starting IP Address for clients that are allowed to access the Redis Cache.
  - `end_ip` - (Required) - The ending IP Address for clients that are allowed to access the Redis Cache.
DESCRIPTION
}

variable "capacity" {
  type        = number
  default     = 2
  description = "(Required) - The size of the Redis Cache to deploy.  Valid values for Basic and Standard skus are 0-6, and for the premium sku is 1-5"
  # TODO: is it worth mentioning that this var is not used for Enterprise sku? it is optional anyway so might not be necessary
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id              = optional(string)
    key_name                           = optional(string)
    key_version                        = optional(string, null)
    user_assigned_identity_resource_id = optional(string, null)
  })
  default     = {}
  description = "Customer managed keys that should be associated with the resource."
}

#TODO: research the managed identity vs. SAS key and determine level of effort required to default to ManagedIdentity as the more secure option, and review what happens if data persistence is not enabled.
# variable "data_persistence_authentication_method" {
#   type        = string
#   default     = "ManagedIdentity"
#   description = "(Optional) - Preferred authentication method to communicate with the storage account used for data persistence. Possible values are `SAS` and `ManagedIdentity`."
# }

variable "diagnostic_settings" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}


variable "enable_non_ssl_port" {
  type        = bool
  default     = false
  description = "(Optional) - Enable the non-ssl port 6379.  Disabled by default"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

#TODO: Determine the valid linking hierarchies. We will create linkages assuming this instance is the primary.
variable "linked_redis_caches" {
  type = map(object({
    linked_redis_cache_resource_id = string
    linked_redis_cache_location    = string
    server_role                    = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of objects defining one or linked Redis Cache instances to use as secondaries.
- `<map key>` - The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.
  - linked_redis_cache_resource_id = (Required) - The Azure resource ID of the Redis Cache that is being linked. Changing this forces a new Redis to be created.
  - linked_redis_cache_location = (Required) - The location value for the Redis Cache that is being linked. Changing this forces a new Redis to be created.
  - server_role - (Required) - The role of the linked Redis Cache.  Possible values are `Primary` and `Secondary`. Changing this forces a new Redis to be created.
DESCRIPTION
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
  default     = {}
  description = "The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`."
  nullable    = false

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind)
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "Managed identities to be created for the resource."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "(Optional) - The minimum TLS version.  Possible values are `1.0`, `1.1`, and `1.2`.  Defaults to `1.2`"
}

variable "patch_schedule" {
  type = set(object({
    day_of_week        = optional(string, "Saturday")
    maintenance_window = optional(string, "PT5H")
    start_hour_utc     = optional(number, 0)
  }))
  default     = []
  description = <<DESCRIPTION
A set of objects describing the following patch schedule attributes. If no value is configured defaults to an empty set.
- `day_of_week` - (Optional) - A string value for the day of week to start the patch schedule.  Valid values are `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, and `Sunday`.
- `maintenance_window` - (Optional) - A string value following the ISO 8601 timespan system which specifies the length of time the Redis Cache can be updated from the start hour. Defaults to `PT5H`.
- `start_hour_utc` - (Optional) - The start hour for maintenance in UTC. Possible values range from 0-23.  Defaults to 0.
DESCRIPTION
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
    lock = optional(object({
      name = optional(string, null)
      kind = optional(string, "None")
    }), {})
    tags                                    = optional(map(any), null)
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
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
DESCRIPTION
}

variable "private_static_ip_address" {
  type        = string
  default     = null
  description = "(Optional) - The static IP Address to assign to the Redis Cache when hosted inside a virtual network. Configuring this value implies that the `subnet_id` value has been set."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "(Optional) - Identifies whether the public network access is allowed for the Redis Cache. `True` means that both public and private endpoint access is allowed. `False` limits access to the private endpoint only. Defaults to `True`."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
}

variable "sku_name" {
  type        = string
  default     = "Premium"
  description = "(Required) - The Redis SKU to use.  Possible values are `Basic`, `Standard`, `Premium`, and `Enterprise`. Note: Downgrading the sku will force new resource creation." #TODO validate whether we can merge Open Source and Premium skus
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(any)
  default     = {}
  description = "The map of tags to be applied to the resource"
}
