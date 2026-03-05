# Azure Web Application Firewall (WAF) Policy

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Network` |
| **Resource Types** | `Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies`, `Microsoft.Network/frontDoorWebApplicationFirewallPolicies` |
| **Azure Portal Category** | Networking > Web Application Firewall policies |
| **Landing Zone Context** | Platform Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/web-application-firewall/overview) |
| **Pricing** | [WAF Pricing (Application Gateway)](https://azure.microsoft.com/pricing/details/web-application-firewall/) |
| **SLA** | Covered by associated resource SLA (Application Gateway or Front Door) |

## Overview

Azure Web Application Firewall (WAF) Policy is a standalone security resource that provides OWASP-based managed rule sets and custom rules for filtering HTTP/S traffic. WAF policies can be associated with Application Gateway, Azure Front Door, or Azure CDN. In a Platform Landing Zone, WAF policies are centrally managed by the security team and shared across multiple application entry points.

## Least-Privilege RBAC Reference

> WAF policies are `Microsoft.Network` resources. There is no purpose-built WAF-specific role — management requires `Network Contributor`. For Front Door association, `CDN Profile Contributor` is additionally needed on the Front Door profile.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a WAF policy for Application Gateway | Resource Group | `Network Contributor` | Resource type: `Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies`. |
| Create a WAF policy for Front Door | Resource Group | `Network Contributor` | Resource type: `Microsoft.Network/frontDoorWebApplicationFirewallPolicies`. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Add/modify custom rules | WAF policy | `Network Contributor` | Custom rules for IP filtering, geo-filtering, rate limiting, request body inspection. |
| Switch WAF mode (Detection → Prevention) | WAF policy | `Network Contributor` | Start in Detection mode, review logs, then switch to Prevention. |
| Update managed rule set version | WAF policy | `Network Contributor` | OWASP CRS 3.2 is recommended; DRS (Default Rule Set) 2.1 for Front Door. |
| Add/modify rule exclusions | WAF policy | `Network Contributor` | Exclude specific request attributes from managed rule inspection. |
| Configure per-rule overrides (disable/redirect individual rules) | WAF policy | `Network Contributor` | |
| Associate WAF policy with Application Gateway | App Gateway + WAF policy | `Network Contributor` | Requires permissions on both resources. |
| Associate WAF policy with Front Door (security policy) | Front Door profile | `CDN Profile Contributor` | Creates a `securityPolicies` sub-resource linking the WAF policy to endpoints. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a WAF policy | Resource Group | `Network Contributor` | Must be disassociated from all Application Gateways and Front Door profiles first. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| View WAF policy configuration | WAF policy | `Reader` | |
| Configure WAF diagnostic logs (via associated resource) | Application Gateway / Front Door profile | `Monitoring Contributor` | WAF logs are emitted by the associated resource, not the policy itself. |
| Enable bot protection managed rule set | WAF policy | `Network Contributor` | Bot protection is available for Front Door Premium and Application Gateway WAF v2. |
| Configure rate limiting rules | WAF policy | `Network Contributor` | Supported on Front Door WAF policies. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Application Gateway / WAF](../workload-landing-zone/application-gateway.md) | `Microsoft.Network/applicationGateways` | WAF policy is associated with an Application Gateway to enforce rules on regional HTTP/S traffic; `Network Contributor` is required on the Application Gateway for association. | Optional (one target required) |
| [Azure Front Door](./azure-front-door.md) | `Microsoft.Cdn/profiles` | WAF policy is associated with Front Door endpoints via security policies to enforce rules on global traffic; `CDN Profile Contributor` is required on the Front Door profile. | Optional (one target required) |
| [Log Analytics Workspace](./log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives WAF logs (blocked/allowed requests, rule match details) via the associated resource's Diagnostic Settings. | Optional (strongly recommended) |

## Notes / Considerations

- **Two distinct resource types**: Application Gateway WAF policies and Front Door WAF policies are separate resource types with different schemas and managed rule sets. They are not interchangeable.
- **Detection vs. Prevention**: Always deploy in Detection mode first, review WAF logs to identify false positives, add exclusions, then switch to Prevention.
- **Managed rule sets**: OWASP CRS (Core Rule Set) for Application Gateway; DRS (Default Rule Set) for Front Door. Both provide OWASP Top 10 protection.
- **WAF policy per-site association**: Application Gateway v2 supports associating different WAF policies per HTTP listener, enabling per-application rule tuning on a shared gateway.
- **No standalone diagnostic logs**: WAF logs are part of the associated resource's diagnostics (Application Gateway access logs or Front Door WAF logs), not the policy resource itself.
- **Centralized management**: Use Azure Policy to enforce that all Application Gateways and Front Door profiles have an associated WAF policy.

## Related Resources

- [Azure Front Door](./azure-front-door.md) — Global entry point protected by Front Door WAF policies
- [Application Gateway / WAF](../workload-landing-zone/application-gateway.md) — Regional entry point protected by Application Gateway WAF policies
- [Azure Firewall](./azure-firewall.md) — Network-layer firewall complementing WAF (L7) protection
- [Log Analytics Workspace](./log-analytics-workspace.md) — WAF log analysis destination
- [Microsoft Sentinel](./microsoft-sentinel.md) — Security analytics on WAF events
