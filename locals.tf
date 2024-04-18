# TODO: insert locals here.
locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  redis_cache_family                 = var.sku_name == "Basic" || var.sku_name == "Standard" ? "C" : "P"
}

# Private endpoint application security group associations
# Remove if this resource does not support private endpoints
locals {
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
}
