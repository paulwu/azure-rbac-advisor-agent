# Azure Arc

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.HybridCompute` |
| **Resource Types** | `Microsoft.HybridCompute/machines`, `Microsoft.HybridCompute/machines/extensions`, `Microsoft.Kubernetes/connectedClusters` |
| **Azure Portal Category** | Management > Azure Arc |
| **Landing Zone Context** | Platform Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/azure-arc/overview) |
| **Pricing** | [Azure Arc Pricing](https://azure.microsoft.com/pricing/details/azure-arc/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/azure-arc/) |

## Overview

Azure Arc extends Azure management and governance to resources running outside of Azure — on-premises servers, edge infrastructure, and multi-cloud environments. In a Platform Landing Zone, Arc provides centralized inventory, policy compliance, and monitoring for hybrid resources. Arc-enabled servers appear as Azure resources and support Azure Policy, Microsoft Defender for Cloud, and Azure Monitor.

## Least-Privilege RBAC Reference

> Azure Arc uses purpose-built roles for onboarding (`Azure Connected Machine Onboarding`) and management (`Azure Connected Machine Resource Administrator`). These roles are narrower than `Contributor` and should always be preferred.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Onboard a server to Azure Arc | Resource Group | `Azure Connected Machine Onboarding` | Minimum role to register machines; does not allow post-onboarding management. |
| Onboard a Kubernetes cluster to Azure Arc | Resource Group | `Kubernetes Cluster - Azure Arc Onboarding` | Registers an external Kubernetes cluster as an Arc-connected cluster. |
| Install a machine extension (post-onboarding) | Arc machine resource | `Azure Connected Machine Resource Administrator` | Extensions include Azure Monitor Agent, Defender for Endpoint, custom scripts. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Update machine properties (tags, metadata) | Arc machine resource | `Azure Connected Machine Resource Administrator` | |
| Update/reconfigure a machine extension | Arc machine resource | `Azure Connected Machine Resource Administrator` | |
| Modify Arc-enabled Kubernetes cluster properties | Connected cluster resource | `Azure Arc Kubernetes Admin` | |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete (disconnect) an Arc-enabled server | Resource Group | `Azure Connected Machine Resource Administrator` | Removes the Azure representation; does not affect the physical server. |
| Remove a machine extension | Arc machine resource | `Azure Connected Machine Resource Administrator` | |
| Delete an Arc-enabled Kubernetes cluster | Resource Group | `Azure Arc Kubernetes Admin` | Removes the cluster registration from Azure. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| View Arc machine inventory and status | Arc machine resource | `Reader` | |
| Assign Azure Policy to Arc machines | Management Group / Subscription | `Resource Policy Contributor` | Policies for guest configuration, monitoring, and security baseline. |
| Configure Diagnostic Settings | Arc machine resource | `Monitoring Contributor` | |
| Enable SSH access to Arc-enabled servers | Arc machine resource | `Azure Connected Machine Resource Administrator` | Requires the SSH extension on the Arc agent. |
| View Arc-enabled Kubernetes cluster | Connected cluster resource | `Azure Arc Kubernetes Viewer` | Read-only access to cluster resources. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Log Analytics Workspace](./log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives monitoring data from Azure Monitor Agent installed on Arc-enabled servers for centralized log analysis. | Optional (strongly recommended) |
| [Azure Monitor](./azure-monitor.md) | `Microsoft.Insights/components` | Provides alert rules and insights for Arc-enabled server health, performance, and availability. | Optional (strongly recommended) |
| [Azure Policy](./azure-policy.md) | `Microsoft.Authorization/policyAssignments` | Enforces compliance baselines (security configuration, monitoring agent deployment) on Arc-enabled resources using guest configuration policies. | Optional (strongly recommended) |
| [Microsoft Defender for Cloud](./microsoft-defender-for-cloud.md) | `Microsoft.Security/pricings` | Extends Defender for Servers and Defender for Kubernetes protection to Arc-enabled resources. | Optional (strongly recommended) |

## Notes / Considerations

- **`Azure Connected Machine Onboarding`** is the minimum role for at-scale onboarding via service principal — do not use `Contributor` for onboarding scripts.
- **`Azure Connected Machine Resource Administrator`** covers all post-onboarding management; assign it only to operators who manage Arc machines.
- **Arc agent** must be installed on each on-premises server; the agent communicates outbound to Azure (no inbound ports required).
- **Guest Configuration** (Azure Policy) requires the Azure Connected Machine Agent and the Guest Configuration extension; the policy managed identity needs `Guest Configuration Resource Contributor`.
- **Arc-enabled Kubernetes** has its own role hierarchy: `Azure Arc Kubernetes Viewer`, `Azure Arc Kubernetes Writer`, `Azure Arc Kubernetes Admin`, and `Azure Arc Kubernetes Cluster Admin` — use the narrowest appropriate role.
- **Azure Update Manager** integrates with Arc-enabled servers for patch management without additional Arc-specific roles.

## Related Resources

- [Azure Policy](./azure-policy.md) — Compliance enforcement for Arc-enabled resources
- [Azure Monitor](./azure-monitor.md) — Monitoring and alerting for Arc servers
- [Microsoft Defender for Cloud](./microsoft-defender-for-cloud.md) — Security protection for Arc resources
- [Log Analytics Workspace](./log-analytics-workspace.md) — Log destination for Arc monitoring data
- [Managed Identity](./managed-identity.md) — System-assigned identity on Arc machines for resource access
