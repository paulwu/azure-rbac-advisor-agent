# Traffic Manager

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Network` |
| **Resource Type** | `Microsoft.Network/trafficManagerProfiles` |
| **Azure Portal Category** | Networking > Traffic Manager profiles |
| **Landing Zone Context** | Platform Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-overview) |
| **Pricing** | [Traffic Manager Pricing](https://azure.microsoft.com/pricing/details/traffic-manager/) |
| **SLA** | [99.99%](https://azure.microsoft.com/support/legal/sla/traffic-manager/) |

## Overview

Azure Traffic Manager is a DNS-based global traffic load balancer that distributes traffic across Azure regions or external endpoints using routing methods such as priority, weighted, performance, and geographic. In a Platform Landing Zone, Traffic Manager provides global failover and traffic distribution for platform-managed services. Unlike Azure Front Door, Traffic Manager operates at the DNS layer (no inline traffic proxying).

## Least-Privilege RBAC Reference

> Traffic Manager management uses `Network Contributor`. There is no purpose-built least-privilege role specific to Traffic Manager profiles or endpoints.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Traffic Manager profile | Resource Group | `Network Contributor` | Profile receives a `*.trafficmanager.net` DNS name. |
| Add an endpoint (Azure, External, or Nested) | Traffic Manager profile | `Network Contributor` | Azure endpoints require `Reader` on the target resource to validate the endpoint. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Change routing method (Priority, Weighted, Performance, Geographic) | Traffic Manager profile | `Network Contributor` | |
| Update endpoint weights or priorities | Traffic Manager profile | `Network Contributor` | |
| Enable/disable an endpoint | Traffic Manager profile | `Network Contributor` | Disabled endpoints are excluded from DNS responses. |
| Modify health check settings (path, interval, timeout) | Traffic Manager profile | `Network Contributor` | |
| Update DNS TTL | Traffic Manager profile | `Network Contributor` | Lower TTL means faster failover but more DNS queries. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a Traffic Manager profile | Resource Group | `Network Contributor` | Remove CNAME records pointing to the profile first to avoid dangling DNS. |
| Remove an endpoint | Traffic Manager profile | `Network Contributor` | |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| View Traffic Manager profile and endpoint health | Traffic Manager profile | `Reader` | |
| Configure Diagnostic Settings | Traffic Manager profile | `Monitoring Contributor` | Traffic Manager supports diagnostic logs for endpoint status changes. |
| Configure Real User Measurements (RUM) | Traffic Manager profile | `Network Contributor` | RUM provides client-side latency data for performance routing. |
| Configure Traffic View | Traffic Manager profile | `Network Contributor` | Provides traffic analytics by endpoint and geography. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Log Analytics Workspace](./log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives Traffic Manager diagnostic logs (endpoint health changes, probe results) via Diagnostic Settings. | Optional (strongly recommended) |
| [Azure Monitor](./azure-monitor.md) | `Microsoft.Insights/components` | Provides alert rules on endpoint health degradation and probe failure metrics. | Optional |

## Notes / Considerations

- **`Network Contributor`** is broadly scoped — restrict assignments to the specific resource group containing the Traffic Manager profile.
- **DNS-level routing** means Traffic Manager does not see or proxy traffic — it only returns DNS answers. TLS termination and WAF must be handled by the endpoint (e.g., Application Gateway or Front Door).
- **Nested profiles** allow combining routing methods (e.g., performance routing to a region, then weighted routing within the region).
- **Health probes** check endpoint availability; unhealthy endpoints are automatically removed from DNS rotation.
- **Consider Azure Front Door** for new deployments where L7 features (WAF, caching, SSL offloading) are needed. Traffic Manager is appropriate for DNS-only failover without inline proxying.

## Related Resources

- [Azure Front Door](./azure-front-door.md) — L7 global load balancer alternative with WAF and caching
- [Azure Firewall](./azure-firewall.md) — Backend endpoint protection
- [Hub Virtual Network](./hub-virtual-network.md) — VNet hosting backend endpoints
- [Log Analytics Workspace](./log-analytics-workspace.md) — Diagnostic log destination
