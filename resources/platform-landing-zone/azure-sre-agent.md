# Azure SRE Agent

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Azure/sreAgents` |
| **Resource Type** | `Microsoft.Azure/sreAgents` |
| **Azure Portal Category** | Monitor > SRE Agent |
| **Landing Zone Context** | Platform Landing Zone |
| **Preview Status** | ⚠️ **Public Preview** — service is in preview; resource provider and role names may change before GA |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/sre-agent/overview) |
| **Pricing** | Consumption-based (preview pricing applies) |
| **SLA** | None (Public Preview) |

## Overview

Azure SRE Agent is an AI-powered site reliability engineering agent that autonomously monitors Azure resources, detects incidents, performs root cause analysis, and executes remediation actions. In a Platform Landing Zone, the SRE Agent provides centralized autonomous operations across subscriptions, reducing mean time to recovery (MTTR) by correlating signals from Azure Monitor, Log Analytics, and resource health. The SRE Agent requires a managed identity with scoped access to the resources it monitors and remediates.

## Least-Privilege RBAC Reference

> Azure SRE Agent is in **public preview** — purpose-built RBAC roles specific to the SRE Agent may not yet exist. The agent's managed identity requires roles on monitored resources to perform detection and remediation. Assign roles at the narrowest scope possible (resource group or resource level, not subscription).

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create an SRE Agent instance | Resource Group | `Contributor` | No purpose-built management role exists during preview. Scope `Contributor` to the resource group. |
| Assign managed identity to SRE Agent | SRE Agent resource | `Contributor` + `Managed Identity Operator` | The agent's managed identity is used for all monitoring and remediation actions. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Update agent configuration (monitoring scope, remediation policies) | SRE Agent resource | `Contributor` | |
| Modify remediation runbooks / actions | SRE Agent resource | `Contributor` | Define which automated actions the agent is authorized to perform. |
| Update monitored resource scope | SRE Agent resource | `Contributor` | Expand or narrow which resources the agent monitors. |
| Update tags | SRE Agent resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete an SRE Agent instance | Resource Group | `Contributor` | Deleting the agent stops all monitoring and remediation. Historical data is retained in Log Analytics. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| View SRE Agent status and incident history | SRE Agent resource | `Reader` | |
| Configure Diagnostic Settings | SRE Agent resource | `Monitoring Contributor` | Sends agent activity logs, incident reports, and remediation actions to Log Analytics. |
| Approve/reject remediation recommendations | SRE Agent resource | `Contributor` | Human-in-the-loop approval for high-risk remediations. |
| View monitoring dashboards | Azure Monitor | `Monitoring Reader` | SRE Agent insights surface through Azure Monitor dashboards. |

## SRE Agent Managed Identity — Required Roles on Monitored Resources

> The SRE Agent's managed identity needs read access for monitoring and write access for remediation on target resources. Apply the principle of least privilege — grant only the roles needed for the remediation actions you authorize.

### Monitoring (Read-Only)

| Target Resource | Required Role | Purpose |
|---|---|---|
| Subscription / Resource Group (monitoring scope) | `Reader` | Read resource health, configurations, and properties across monitored scope. |
| Log Analytics Workspace | `Log Analytics Reader` | Query logs for incident correlation and root cause analysis. |
| Azure Monitor | `Monitoring Reader` | Read metrics, alerts, and diagnostic data. |

### Remediation (Action-Specific)

| Target Resource | Required Role | Purpose |
|---|---|---|
| Virtual Machines | `Virtual Machine Contributor` | Restart, resize, or redeploy VMs during incident remediation. |
| App Service | `Website Contributor` | Restart app, swap deployment slots, scale instances. |
| Azure Kubernetes Service | `Azure Kubernetes Service Contributor Role` | Restart node pools, scale deployments. |
| Network Security Groups | `Network Contributor` | Modify NSG rules during security incident response. |
| Azure SQL Database | `SQL Server Contributor` | Failover, modify firewall rules, scale DTUs during database incidents. |
| Azure Storage Account | `Storage Account Contributor` | Modify network rules, rotate keys, update configurations. |

> **Principle**: Grant remediation roles only for the resource types and actions you want the SRE Agent to auto-remediate. For resources where human approval is required, grant only `Reader`.

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Log Analytics Workspace](./log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Primary data source for incident correlation and root cause analysis; the SRE Agent's managed identity requires `Log Analytics Reader` to query workspace data. | Required |
| [Azure Monitor](./azure-monitor.md) | `Microsoft.Insights/components` | Provides metrics, alerts, and resource health signals that the SRE Agent uses for anomaly detection and incident triggering; requires `Monitoring Reader`. | Required |
| [Microsoft Sentinel](./microsoft-sentinel.md) | `Microsoft.SecurityInsights/alertRules` | Security incidents detected by Sentinel can trigger SRE Agent remediation workflows for security-related operational issues. | Optional |
| [Azure Automation Account](./azure-automation-account.md) | `Microsoft.Automation/automationAccounts` | Executes complex remediation runbooks on behalf of the SRE Agent for multi-step recovery workflows; requires `Automation Operator` on the Automation Account. | Optional |
| [Azure Key Vault](./azure-key-vault.md) | `Microsoft.KeyVault/vaults` | Stores credentials and connection strings used by remediation workflows; the SRE Agent's managed identity requires `Key Vault Secrets User`. | Optional |

## Notes / Considerations

- **Preview service**: Azure SRE Agent is in public preview. The ARM resource provider, resource type, and any purpose-built RBAC roles may change before GA. Monitor the [Azure updates feed](https://azure.microsoft.com/updates/) for changes.
- **Managed Identity scoping**: The SRE Agent's managed identity should be granted the narrowest roles possible. For monitoring-only scenarios, `Reader` + `Log Analytics Reader` + `Monitoring Reader` is sufficient. Add write roles only for specific remediation actions.
- **Human-in-the-loop**: Configure the SRE Agent to require approval for high-risk remediation actions (e.g., VM deletion, NSG rule changes, database failover). Auto-remediation should be limited to low-risk actions (e.g., restart, scale out).
- **Audit trail**: All SRE Agent actions (detection, analysis, remediation) are logged to the connected Log Analytics Workspace. Enable Diagnostic Settings for compliance and incident review.
- **Scope of monitoring**: Define the agent's monitoring scope at the resource group level rather than subscription level to limit blast radius and align with landing zone boundaries.
- **Do not grant `Owner`** to the SRE Agent's managed identity — `Contributor` with appropriate resource-scoped roles provides sufficient remediation capability without role assignment permissions.

## Related Resources

- [Azure Monitor](./azure-monitor.md) — Metrics and alerts data source for the SRE Agent
- [Log Analytics Workspace](./log-analytics-workspace.md) — Log query and incident correlation
- [Microsoft Sentinel](./microsoft-sentinel.md) — Security incident integration
- [Azure Automation Account](./azure-automation-account.md) — Remediation runbook execution
- [Microsoft Defender for Cloud](./microsoft-defender-for-cloud.md) — Security posture signals
- [Azure Arc](./azure-arc.md) — Extends SRE Agent monitoring to hybrid and multi-cloud resources
