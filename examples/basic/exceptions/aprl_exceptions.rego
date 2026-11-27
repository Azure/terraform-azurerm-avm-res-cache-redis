# Basic SKU does not support zone redundancy.
# See: https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-high-availability#zone-redundancy
package Azure_Proactive_Resiliency_Library_v2

import rego.v1

exception contains rules if {
	rules := ["enable_zone_redundancy_for_azure_cache_for_redis"]
}
