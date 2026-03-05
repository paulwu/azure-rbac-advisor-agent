# Azure Front Door

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Cdn` |
| **Resource Types** | `Microsoft.Cdn/profiles` (Standard/Premium SKU), `Microsoft.Cdn/profiles/afdEndpoints`, `Microsoft.Cdn/profiles/originGroups`, `Microsoft.Cdn/profiles/securityPolicies`, `Microsoft.Network/frontDoorWebApplicationFirewallPolicies` |
| **Azure Portal Category** | Networking > Front Door and CDN profiles |
| **Landing Zone Context** | Platform Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/frontdoor/front-door-overview) |
| **Pricing** | [Azure Front Door Pricing](https://azure.microsoft.com/pricing/details/frontdoor/) |
| **SLA** | [99.99%](https://azure.microsoft.com/support/legal/sla/frontdoor/) |

## Overview

Azure Front Door is a global, cloud-native application delivery network that provides Layer 7 load balancing, SSL offloading, WAF protection, and caching at Microsoft's edge PoPs. In a Platform Landing Zone, Front Door serves as the global entry point for internet-facing workloads, providing centralized WAF policy enforcement and traffic routing across regions. Front Door Standard/Premium (built on the `Microsoft.Cdn` provider) is the current recommended tier; Front Door classic (`Microsoft.Network/frontDoors`) is deprecated.

## Least-Privilege RBAC Reference

> Front Door management uses `CDN Profile Contributor` for profile and endpoint operations. WAF policy management requires separate `Microsoft.Network` permissions — typically `Network Contributor` — because WAF policies use the `Microsoft.Network/frontDoorWebApplicationFirewallPolicies` resource type.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Front Door profile (Standard/Premium) | Resource Group | `CDN Profile Contributor` | Creates the `Microsoft.Cdn/profiles` resource with Front Door SKU. |
| Create an endpoint | Front Door profile | `CDN Endpoint Contributor` | Endpoint receives a `*.z01.azurefd.net` hostname. |
| Create an origin group and origins | Front Door profile | `CDN Endpoint Contributor` | Origins can be App Services, Storage, VMs, or any public/private endpoint. |
| Create a route (endpoint → origin group) | Front Door profile | `CDN Endpoint Contributor` | Routes bind patterns (e.g., `/api/*`) to origin groups with caching/forwarding rules. |
| Create a WAF policy | Resource Group | `Network Contributor` | WAF policy is a `Microsoft.Network/frontDoorWebApplicationFirewallPolicies` resource — `CDN Profile Contributor` does not cover this. |
| Create a security policy (associate WAF with endpoint) | Front Door profile | `CDN Profile Contributor` | Links a WAF policy to one or more endpoints via a `securityPolicies` sub-resource. |
| Add a custom domain | Front Door profile | `CDN Profile Contributor` | Requires DNS TXT validation; if using Azure DNS, also requires `DNS Zone Contributor` on the DNS zone. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Modify route rules (caching, forwarding protocol, URL rewrite) | Front Door profile | `CDN Endpoint Contributor` | |
| Add/remove origins in an origin group | Front Door profile | `CDN Endpoint Contributor` | |
| Update health probe settings | Front Door profile | `CDN Endpoint Contributor` | |
| Update load balancing settings (sample size, latency sensitivity) | Front Door profile | `CDN Endpoint Contributor` | |
| Modify WAF custom rules | WAF Policy | `Network Contributor` | |
| Switch WAF mode (Detection → Prevention) | WAF Policy | `Network Contributor` | Start in Detection mode, validate logs, then switch to Prevention. |
| Update managed rule set version | WAF Policy | `Network Contributor` | |
| Modify custom domain TLS settings | Front Door profile | `CDN Profile Contributor` | Supports Front Door-managed or customer-managed (Key Vault) certificates. |
| Purge cached content | Endpoint | `CDN Endpoint Contributor` | Purge by URL path or wildcard. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete an endpoint | Front Door profile | `CDN Endpoint Contributor` | Remove associated routes and security policies first. |
| Delete a Front Door profile | Resource Group | `CDN Profile Contributor` | All endpoints, routes, and custom domains must be removed first. |
| Delete a WAF policy | Resource Group | `Network Contributor` | Must be disassociated from all Front Door security policies before deletion. |
| Remove a custom domain | Front Door profile | `CDN Profile Contributor` | Update DNS records after removal to avoid dangling CNAME entries. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure Diagnostic Settings (access logs, WAF logs, health probe logs) | Front Door profile | `Monitoring Contributor` | WAF logs are critical for security monitoring — always enable. |
| View Front Door metrics and health | Front Door profile | `CDN Profile Reader` | Includes request count, latency, cache hit ratio, WAF block count. |
| Configure Private Link origin (Premium SKU) | Front Door profile + origin resource | `CDN Profile Contributor` + approval on origin | Premium only. The origin owner must approve the Private Link connection request. |
| Configure Rules Engine (request/response header manipulation) | Front Door profile | `CDN Endpoint Contributor` | URL redirect, URL rewrite, and header modification rules. |
| Configure caching rules | Front Door profile | `CDN Endpoint Contributor` | Per-route caching with query string and compression settings. |
| Associate customer-managed TLS certificate (Key Vault) | Front Door profile + Key Vault | `CDN Profile Contributor` + `Key Vault Secrets User` | Front Door's managed identity needs `Key Vault Secrets User` to read the certificate from Key Vault. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| WAF Policy | `Microsoft.Network/frontDoorWebApplicationFirewallPolicies` | Provides OWASP managed rule sets and custom rules for request filtering; `Network Contributor` on the WAF policy is required to manage rules. | Optional (strongly recommended) |
| [Azure Key Vault](./azure-key-vault.md) | `Microsoft.KeyVault/vaults` | Stores customer-managed TLS certificates for custom domains; Front Door's managed identity requires `Key Vault Secrets User` on the vault. | Optional (for customer-managed TLS) |
| [Log Analytics Workspace](./log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives Front Door diagnostic logs (access logs, WAF logs, health probe logs) via Diagnostic Settings for traffic analysis and security monitoring. | Optional (strongly recommended) |
| [Azure Monitor](./azure-monitor.md) | `Microsoft.Insights/components` | Provides alert rules on Front Door metrics (origin health, latency spikes, WAF block rate anomalies). | Optional |
| [Private DNS Zones](./private-dns-zones.md) | `Microsoft.Network/privateDnsZones` | Required when using Private Link origins so Front Door can resolve private endpoint DNS names. | Optional (Premium with Private Link origins) |

## Notes / Considerations

- **`CDN Profile Contributor`** vs **`CDN Endpoint Contributor`**: Use `CDN Endpoint Contributor` for day-to-day routing and origin management; reserve `CDN Profile Contributor` for profile-level operations (create/delete profiles, manage custom domains, security policies).
- **WAF policy is a separate `Microsoft.Network` resource** — `CDN Profile Contributor` alone cannot create or modify WAF policies. Assign `Network Contributor` (scoped to the WAF policy's resource group) to teams that manage WAF rules.
- **Front Door Premium** is required for Private Link origins, bot protection managed rule sets, and enhanced WAF analytics.
- **Dangling DNS prevention**: When removing custom domains from Front Door, update or delete the corresponding CNAME record immediately to avoid subdomain takeover.
- **Origin types**: Front Door supports App Service, Storage (static website), Application Gateway, API Management, VMs with public IPs, and any public hostname as origins. For Private Link origins (Premium), the origin owner must approve the connection.
- **Managed Identity** is automatically created for Front Door profiles that use Key Vault-based custom TLS certificates. Ensure the identity has `Key Vault Secrets User` on the vault.
- **Front Door classic** (`Microsoft.Network/frontDoors`) is deprecated — migrate to Standard/Premium. Classic uses different RBAC roles under `Microsoft.Network`.

## Related Resources

- [Application Gateway / WAF](../workload-landing-zone/application-gateway.md) — Regional L7 alternative; use Application Gateway for single-region, Front Door for multi-region
- [Azure Firewall](./azure-firewall.md) — Can sit behind Front Door for layered network security
- [Azure Key Vault](./azure-key-vault.md) — TLS certificate storage for custom domains
- [Private DNS Zones](./private-dns-zones.md) — Required for Private Link origin resolution
- [Log Analytics Workspace](./log-analytics-workspace.md) — Diagnostic log destination
- [API Management](./api-management.md) — Common Front Door origin for API workloads
