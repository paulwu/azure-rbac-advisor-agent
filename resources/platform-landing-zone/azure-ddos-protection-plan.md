# Azure DDoS Protection Plan

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Network` |
| **Resource Type** | `Microsoft.Network/ddosProtectionPlans` |
| **Azure Portal Category** | Networking > DDoS Protection Plans |
| **Landing Zone Context** | Platform Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/ddos-protection/ddos-protection-overview) |
| **Pricing** | [DDoS Protection Pricing](https://azure.microsoft.com/pricing/details/ddos-protection/) |
| **SLA** | [99.99%](https://azure.microsoft.com/support/legal/sla/ddos-protection/) |

## Overview

Azure DDoS Protection Plan provides enhanced DDoS mitigation for Azure resources with public IP addresses. In a Platform Landing Zone, a single DDoS Protection Plan is shared across all subscriptions and VNets, providing centralized protection and cost efficiency. The plan is associated with VNets; all public IP resources within protected VNets receive automatic mitigation.

## Least-Privilege RBAC Reference

> DDoS Protection Plan management uses `Network Contributor`. There is no purpose-built least-privilege role specific to DDoS Protection — `Network Contributor` is the minimum for plan and VNet association operations.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a DDoS Protection Plan | Resource Group | `Network Contributor` | Only one plan is needed per tenant/region; it can protect VNets across subscriptions. |
| Associate DDoS plan with a VNet | VNet resource | `Network Contributor` | Requires `Network Contributor` on both the DDoS plan and the target VNet. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Associate/disassociate VNets | DDoS plan + VNet | `Network Contributor` | Requires permissions on both resources. |
| Update DDoS plan tags | DDoS plan resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a DDoS Protection Plan | Resource Group | `Network Contributor` | All VNet associations must be removed first. Deleting the plan removes protection from all associated VNets. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure DDoS diagnostic logs and metrics | DDoS plan / Public IP | `Monitoring Contributor` | DDoS mitigation flow logs, metrics, and alerts are configured per public IP. |
| View DDoS protection status and metrics | DDoS plan | `Reader` | |
| Configure DDoS alerts (under attack, mitigation started) | Public IP resource | `Monitoring Contributor` | Set up alerts on `IfUnderDDoSAttack` metric. |
| Configure DDoS rapid response (DRR) engagement | DDoS plan | `Network Contributor` | Premium tier includes access to the DDoS Rapid Response team. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Hub Virtual Network](./hub-virtual-network.md) | `Microsoft.Network/virtualNetworks` | The DDoS plan is associated with VNets; hub and spoke VNets must be linked to receive protection. | Required |
| [Log Analytics Workspace](./log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives DDoS mitigation flow logs, metrics, and attack analytics via Diagnostic Settings. | Optional (strongly recommended) |
| [Azure Monitor](./azure-monitor.md) | `Microsoft.Insights/components` | Provides alert rules on DDoS attack metrics (under attack, mitigation status, packet count). | Optional (strongly recommended) |

## Notes / Considerations

- **One plan covers multiple VNets** across subscriptions — deploy a single plan in the platform subscription and associate spoke VNets to it. This reduces cost (DDoS Protection Plan has a fixed monthly fee plus per-IP charges).
- **`Network Contributor`** is broadly scoped — restrict assignments to the specific resource group containing the DDoS plan. For VNet association, the operator also needs `Network Contributor` on the target VNet.
- **DDoS Protection Standard** protects all public IP resources within associated VNets automatically; no per-resource configuration is needed.
- **Cost awareness**: The DDoS Protection Plan has a significant fixed monthly cost. Use Azure Policy to prevent uncontrolled plan creation.
- **DDoS IP Protection** (per-IP SKU) is an alternative for protecting individual public IPs without a full plan; it uses the same `Network Contributor` role.

## Related Resources

- [Hub Virtual Network](./hub-virtual-network.md) — Primary VNet associated with the DDoS plan
- [Azure Firewall](./azure-firewall.md) — Public IPs on the firewall are protected by the DDoS plan
- [Azure Front Door](./azure-front-door.md) — Front Door has built-in DDoS protection; DDoS plan is for backend public IPs
- [Log Analytics Workspace](./log-analytics-workspace.md) — DDoS mitigation logs destination
