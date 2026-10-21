package Azure_Proactive_Resiliency_Library_v2

import rego.v1

# Basic tier does not support zone redundancy: https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-high-availability
exception contains rules if {
  rules = ["enable_zone_redundancy_for_azure_cache_for_redis"]
}
