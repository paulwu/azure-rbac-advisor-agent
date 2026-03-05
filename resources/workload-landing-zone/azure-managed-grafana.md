# Azure Managed Grafana

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Dashboard` |
| **Resource Type** | `Microsoft.Dashboard/grafana` |
| **Azure Portal Category** | Monitor > Azure Managed Grafana |
| **Landing Zone Context** | Workload Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/managed-grafana/overview) |
| **Pricing** | [Azure Managed Grafana Pricing](https://azure.microsoft.com/pricing/details/managed-grafana/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/managed-grafana/) |

## Overview

Azure Managed Grafana is a fully managed Grafana instance for visualizing metrics, logs, and traces from Azure Monitor, Azure Data Explorer, Prometheus, and other data sources. In a Workload Landing Zone, Managed Grafana provides application teams with customizable observability dashboards. Data-plane access uses purpose-built Grafana roles (`Grafana Admin`, `Grafana Editor`, `Grafana Viewer`), separate from management-plane RBAC.

## Least-Privilege RBAC Reference

> Azure Managed Grafana separates **management plane** (creating/configuring the Grafana workspace via Azure RBAC) from **data plane** (dashboard and data source access via Grafana-specific roles). Users need Grafana data-plane roles to interact with dashboards.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Managed Grafana workspace | Resource Group | `Contributor` | No purpose-built management role exists for `Microsoft.Dashboard`. Scope `Contributor` to the resource group. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Modify workspace properties (SKU, API key settings) | Grafana workspace | `Contributor` | |
| Enable/disable Grafana Enterprise plugins | Grafana workspace | `Contributor` | |
| Update workspace tags | Grafana workspace | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a Managed Grafana workspace | Resource Group | `Contributor` | All dashboards, data sources, and configurations are permanently deleted. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Assign Grafana data-plane roles | Grafana workspace | User Access Administrator or Owner | Assigns `Grafana Admin`, `Grafana Editor`, or `Grafana Viewer` to users/groups. |
| Create/edit dashboards | Grafana workspace | `Grafana Editor` | Data-plane role; allows creating, editing, and deleting dashboards. |
| Manage data sources and plugins | Grafana workspace | `Grafana Admin` | Data-plane role; manages Grafana data source connections and plugins. |
| View dashboards (read-only) | Grafana workspace | `Grafana Viewer` | Data-plane role; read-only dashboard access. |
| Manage Grafana teams and permissions | Grafana workspace | `Grafana Admin` | Data-plane role; manages Grafana-internal team and folder permissions. |
| Configure Diagnostic Settings | Grafana workspace | `Monitoring Contributor` | |
| Configure Private Endpoint | Grafana workspace + VNet | `Contributor` + `Network Contributor` | Restricts Grafana access to private network. |
| View workspace metadata | Grafana workspace | `Reader` | Management-plane read access. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Azure Monitor](../platform-landing-zone/azure-monitor.md) | `Microsoft.Insights/components` | Primary data source for Grafana dashboards; the Grafana workspace's managed identity requires `Monitoring Reader` on target subscriptions/resources to query metrics and logs. | Required |
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Serves as a data source for log-based Grafana dashboards; the Grafana managed identity requires `Log Analytics Reader` on the workspace. | Optional (strongly recommended) |

## Notes / Considerations

- **Data-plane roles**: `Grafana Admin`, `Grafana Editor`, and `Grafana Viewer` are Azure built-in roles controlling Grafana UI access. They are separate from and in addition to any management-plane roles.
- **Managed Identity**: The Grafana workspace uses a system-assigned managed identity. This identity needs `Monitoring Reader` on target subscriptions/resources to read Azure Monitor metrics and logs as data sources.
- **No purpose-built management role**: Use `Contributor` scoped to the resource group for provisioning. Consider a custom role with `Microsoft.Dashboard/grafana/*` actions for stricter least privilege.
- **Standard vs. Essential tiers**: Standard includes zone redundancy, API key support, and Grafana Enterprise plugins. Essential is lower cost with fewer features.
- **Azure Monitor integration**: Managed Grafana natively integrates with Azure Monitor as a data source — no additional data source plugin configuration is required, but the managed identity must have read access to the monitored resources.
- **Prometheus data source**: For Kubernetes monitoring, connect Grafana to Azure Monitor managed Prometheus (requires `Monitoring Data Reader` on the Azure Monitor workspace).

## Related Resources

- [Azure Monitor](../platform-landing-zone/azure-monitor.md) — Primary observability data source
- [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) — Log query data source
- [Azure Kubernetes Service](./azure-kubernetes-service.md) — Common workload monitored via Grafana
