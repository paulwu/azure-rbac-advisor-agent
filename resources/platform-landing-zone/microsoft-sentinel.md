# Microsoft Sentinel

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.SecurityInsights` |
| **Resource Types** | `Microsoft.SecurityInsights/alertRules`, `Microsoft.SecurityInsights/incidents`, `Microsoft.SecurityInsights/dataConnectors`, `Microsoft.SecurityInsights/automationRules`, `Microsoft.SecurityInsights/watchlists` |
| **Azure Portal Category** | Security > Microsoft Sentinel |
| **Landing Zone Context** | Platform Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/sentinel/overview) |
| **Pricing** | [Sentinel Pricing](https://azure.microsoft.com/pricing/details/microsoft-sentinel/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/microsoft-sentinel/) |

## Overview

Microsoft Sentinel is a cloud-native SIEM and SOAR solution built on top of a Log Analytics workspace. In a Platform Landing Zone, Sentinel provides centralized security event aggregation, threat detection via analytics rules, and automated incident response through playbooks (Logic Apps). Sentinel RBAC is layered on top of the underlying Log Analytics workspace roles.

## Least-Privilege RBAC Reference

> Sentinel has its own set of purpose-built roles (`Microsoft Sentinel Contributor`, `Microsoft Sentinel Reader`, `Microsoft Sentinel Responder`) that layer on top of the Log Analytics workspace roles. Users need **both** Sentinel roles and at minimum `Log Analytics Reader` on the workspace.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Enable Sentinel on a Log Analytics workspace | Resource Group | `Microsoft Sentinel Contributor` + `Log Analytics Contributor` | Onboarding Sentinel installs the SecurityInsights solution on the workspace. |
| Create an analytics rule | Sentinel workspace | `Microsoft Sentinel Contributor` | Scheduled, NRT, Fusion, and Microsoft Security rules. |
| Create a data connector | Sentinel workspace | `Microsoft Sentinel Contributor` | Some connectors require additional permissions on the source (e.g., `Security Admin` for Defender connectors). |
| Create a workbook | Sentinel workspace | `Microsoft Sentinel Contributor` | Workbooks are shared via `Monitoring Contributor` on the resource group. |
| Create a watchlist | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Create an automation rule | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Create a playbook (Logic App) | Resource Group | `Logic App Contributor` | Playbooks are Logic Apps; Sentinel triggers them via automation rules. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Modify analytics rules | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Update incident (assign, change severity/status) | Sentinel workspace | `Microsoft Sentinel Responder` | Responders can triage incidents but cannot create/modify analytics rules. |
| Add comments to incidents | Sentinel workspace | `Microsoft Sentinel Responder` | |
| Modify watchlist items | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Update data connector configuration | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Modify automation rules | Sentinel workspace | `Microsoft Sentinel Contributor` | |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete an analytics rule | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Delete (close) an incident | Sentinel workspace | `Microsoft Sentinel Responder` | Incidents can be closed with a classification reason. |
| Remove a data connector | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Delete a watchlist | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Remove Sentinel from a workspace | Resource Group | `Microsoft Sentinel Contributor` + `Log Analytics Contributor` | Disabling Sentinel does not delete ingested data; data remains in the workspace. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| View incidents and alerts (read-only) | Sentinel workspace | `Microsoft Sentinel Reader` | Also requires `Log Analytics Reader` on the workspace. |
| Run hunting queries | Sentinel workspace | `Microsoft Sentinel Reader` + `Log Analytics Reader` | Hunting uses KQL against workspace tables. |
| Configure Sentinel settings (entity behavior, anomalies) | Sentinel workspace | `Microsoft Sentinel Contributor` | |
| Manage playbook permissions (authorize Sentinel to trigger) | Logic App resource | `Microsoft Sentinel Playbook Operator` | Grants Sentinel permission to run a specific playbook. |
| Configure Diagnostic Settings | Sentinel workspace | `Monitoring Contributor` | |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Log Analytics Workspace](./log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Sentinel is deployed as a solution on a Log Analytics workspace; all security data is stored and queried here. `Log Analytics Reader` (minimum) or `Log Analytics Contributor` is required on the workspace. | Required |
| [Azure Monitor](./azure-monitor.md) | `Microsoft.Insights/components` | Provides alert rules and workbook infrastructure for Sentinel dashboards and notifications. | Optional (strongly recommended) |
| Logic Apps (Playbooks) | `Microsoft.Logic/workflows` | Executes automated response actions triggered by Sentinel automation rules; `Logic App Contributor` is required to create playbooks, `Microsoft Sentinel Playbook Operator` to authorize Sentinel to run them. | Optional |

## Notes / Considerations

- **Role layering**: Sentinel roles control Sentinel-specific features; `Log Analytics Reader` is additionally required for users to query data. Without workspace-level read access, Sentinel UI shows metadata but not event data.
- **`Microsoft Sentinel Responder`** is ideal for SOC analysts who triage incidents but should not modify detection rules.
- **`Microsoft Sentinel Contributor`** is for detection engineers who author analytics rules, data connectors, and automation.
- **Playbook authorization** is a two-step process: (1) create the Logic App with `Logic App Contributor`, (2) authorize Sentinel to trigger it with `Microsoft Sentinel Playbook Operator` on the Logic App.
- **Multi-workspace Sentinel** is supported; each workspace requires its own role assignments.
- **Content Hub** solutions (packaged analytics rules, workbooks, data connectors) require `Microsoft Sentinel Contributor` to install.
- **UEBA (User Entity Behavior Analytics)** requires `Microsoft Sentinel Contributor` to enable and `Log Analytics Reader` to view behavioral insights.

## Related Resources

- [Log Analytics Workspace](./log-analytics-workspace.md) — Underlying data store for all Sentinel data
- [Azure Monitor](./azure-monitor.md) — Alert rules and workbook infrastructure
- [Microsoft Defender for Cloud](./microsoft-defender-for-cloud.md) — Security alerts forwarded to Sentinel via data connector
- [Azure SRE Agent](./azure-sre-agent.md) — Security incidents can trigger SRE Agent remediation
- [Azure Key Vault](./azure-key-vault.md) — Playbook secrets and credential storage
