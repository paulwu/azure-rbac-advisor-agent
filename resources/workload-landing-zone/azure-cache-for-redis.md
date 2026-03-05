# Azure Cache for Redis

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Cache` |
| **Resource Type** | `Microsoft.Cache/redis` |
| **Azure Portal Category** | Databases > Azure Cache for Redis |
| **Landing Zone Context** | Workload Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-overview) |
| **Pricing** | [Azure Cache for Redis Pricing](https://azure.microsoft.com/pricing/details/cache/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/cache/) |

## Overview

Azure Cache for Redis is a fully managed in-memory data store based on Redis. In a Workload Landing Zone, it serves as the primary caching layer for web applications, providing session storage, response caching, message brokering, and real-time analytics. Azure Cache for Redis supports multiple tiers (Basic, Standard, Premium, Enterprise) with features like clustering, geo-replication, and VNet injection.

## Least-Privilege RBAC Reference

> Azure Cache for Redis management uses `Redis Cache Contributor` for management-plane operations. Data-plane access (reading/writing cached data) uses Redis access keys or Entra ID authentication with data access policies — there are no built-in Azure RBAC data-plane roles for Redis.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create an Azure Cache for Redis instance | Resource Group | `Redis Cache Contributor` | |
| Create a cache with VNet injection (Premium) | Resource Group + VNet | `Redis Cache Contributor` + `Network Contributor` | VNet injection requires a dedicated subnet. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Scale cache tier/SKU | Cache resource | `Redis Cache Contributor` | Scaling from Basic to Standard/Premium causes brief downtime. |
| Change cache size (within tier) | Cache resource | `Redis Cache Contributor` | |
| Configure Redis settings (maxmemory-policy, etc.) | Cache resource | `Redis Cache Contributor` | |
| Enable clustering (Premium/Enterprise) | Cache resource | `Redis Cache Contributor` | |
| Configure geo-replication | Cache resource | `Redis Cache Contributor` | Requires `Redis Cache Contributor` on both primary and secondary caches. |
| Regenerate access keys | Cache resource | `Redis Cache Contributor` | Rotates primary or secondary access key. |
| Update tags | Cache resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete an Azure Cache for Redis instance | Resource Group | `Redis Cache Contributor` | All data in the cache is permanently lost. Export data before deletion if needed. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure firewall rules | Cache resource | `Redis Cache Contributor` | IP-based access restrictions. |
| Configure Private Endpoint | Cache resource + VNet | `Redis Cache Contributor` + `Network Contributor` | |
| Configure Diagnostic Settings | Cache resource | `Monitoring Contributor` | Sends Redis metrics and connection logs to Log Analytics. |
| View cache metrics and status | Cache resource | `Reader` | Includes memory usage, cache hit ratio, connected clients. |
| Configure data persistence (RDB/AOF) | Cache resource | `Redis Cache Contributor` | Premium tier only; persists data to Azure Storage. |
| Configure Entra ID authentication | Cache resource | `Redis Cache Contributor` | Enables Entra ID-based data access via data access policies. |
| Enable non-TLS port (not recommended) | Cache resource | `Redis Cache Contributor` | Port 6379 for unencrypted connections; use TLS port 6380 instead. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Spoke Virtual Network](./spoke-virtual-network.md) | `Microsoft.Network/virtualNetworks` | Provides network isolation via VNet injection (Premium) or Private Endpoint for restricting cache access. | Optional (strongly recommended) |
| [Azure Storage Account](./azure-storage-account.md) | `Microsoft.Storage/storageAccounts` | Stores RDB/AOF persistence snapshots for Premium tier data durability; `Redis Cache Contributor` on the cache handles the Storage integration. | Optional (for data persistence) |
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives Redis diagnostic logs (connected clients, memory stats, slow log) via Diagnostic Settings. | Optional (strongly recommended) |
| [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) | `Microsoft.Network/privateDnsZones` | Resolves `privatelink.redis.cache.windows.net` for Private Endpoint-connected clients. | Required (if Private Endpoint enabled) |

## Notes / Considerations

- **`Redis Cache Contributor`** is a purpose-built role covering all management-plane operations — prefer it over `Contributor`.
- **Data-plane access** uses either access keys (connection string) or Entra ID authentication with data access policies. There are no built-in Azure RBAC data-plane roles for Redis.
- **Entra ID authentication** (recommended) uses data access policies configured on the cache resource to grant Entra ID principals specific Redis command permissions. This avoids shared access keys.
- **Access keys** should be stored in Azure Key Vault and rotated regularly. Avoid embedding keys in application configuration.
- **VNet injection** (Premium tier) deploys the cache into a dedicated subnet; the subnet cannot be shared. **Private Endpoint** is the preferred network isolation for Standard and Premium tiers.
- **Enterprise tier** (powered by Redis Enterprise) adds features like RediSearch, RedisJSON, and active-active geo-replication. Enterprise tier uses a different resource type (`Microsoft.Cache/redisEnterprise`).

## Related Resources

- [Azure Key Vault](./azure-key-vault.md) — Access key storage and rotation
- [Spoke Virtual Network](./spoke-virtual-network.md) — Network isolation
- [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) — `privatelink.redis.cache.windows.net`
- [Azure Storage Account](./azure-storage-account.md) — Data persistence storage
