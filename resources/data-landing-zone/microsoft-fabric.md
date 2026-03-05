# Microsoft Fabric

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Fabric` |
| **Resource Type** | `Microsoft.Fabric/capacities` |
| **Azure Portal Category** | Analytics > Microsoft Fabric |
| **Landing Zone Context** | Data Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/fabric/get-started/microsoft-fabric-overview) |
| **Pricing** | [Fabric Pricing](https://azure.microsoft.com/pricing/details/microsoft-fabric/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/microsoft-fabric/) |

## Overview

Microsoft Fabric is a unified analytics platform that combines data engineering, data warehousing, real-time intelligence, data science, and business intelligence into a single SaaS experience backed by OneLake. In a Data Landing Zone, Fabric serves as the consolidated analytics layer, replacing or complementing separate services like Synapse Analytics and Data Factory. RBAC is split between **Azure RBAC** (management plane — provisioning and managing Fabric capacities as ARM resources) and **Fabric workspace permissions** (data plane — controlling access to workspaces, lakehouses, warehouses, notebooks, and other items within the Fabric platform).

## Least-Privilege RBAC Reference

> Azure RBAC controls Fabric capacity provisioning (ARM resources). All data-plane operations (workspace items, data access, pipeline execution) are governed by Fabric's own workspace permission model, which is separate from Azure RBAC.

---

### Azure RBAC — Capacity Management

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Fabric capacity | Resource Group | `Contributor` | No Fabric-specific management-plane create role exists. Creates the `Microsoft.Fabric/capacities` ARM resource. |
| Create a Fabric capacity with Private Link | Resource Group + VNet | `Contributor` + `Network Contributor` | Private Link configuration requires network permissions on the target VNet. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Scale capacity (change SKU/CU size) | Fabric Capacity | `Contributor` | Scaling may cause brief interruption to running workloads. |
| Pause / Resume capacity | Fabric Capacity | `Contributor` | Paused capacities stop billing but workspaces become read-only. |
| Modify capacity settings (workload management) | Fabric Capacity | `Contributor` | |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a Fabric capacity | Resource Group | `Contributor` | Workspaces assigned to the capacity must be reassigned or will lose compute. Data in OneLake persists independently. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure Diagnostic Settings | Fabric Capacity | `Monitoring Contributor` | |
| Assign capacity to a Fabric workspace | Fabric Capacity | `Contributor` | Workspace assignment is also controlled from the Fabric admin portal. |
| Configure Private Endpoints | Fabric Capacity + VNet | `Contributor` + `Network Contributor` | |

---

## Fabric Workspace Permissions (Data Plane)

> Fabric workspace permissions are managed within the Fabric portal or via Fabric REST APIs — they are **not** Azure RBAC roles. These roles control access to all items within a Fabric workspace (lakehouses, warehouses, notebooks, pipelines, reports, dataflows).

### Workspace Role Summary

| Role | View Items | Use / Run Items | Create / Edit Items | Share Items | Manage Workspace |
|---|---|---|---|---|---|
| Admin | ✅ | ✅ | ✅ | ✅ | ✅ |
| Member | ✅ | ✅ | ✅ | ✅ | ❌ |
| Contributor | ✅ | ✅ | ✅ | ❌ | ❌ |
| Viewer | ✅ | ❌ | ❌ | ❌ | ❌ |

### Workspace Role Descriptions

| Role | Capabilities |
|---|---|
| **Admin** | Full control over the workspace — manage members, delete workspace, configure settings, and all capabilities of Member. |
| **Member** | Create, edit, and delete all items in the workspace. Share items and grant access. Cannot manage workspace settings or membership at Admin level. |
| **Contributor** | Create, edit, and delete items in the workspace. Cannot share items or manage workspace membership. |
| **Viewer** | View all items in the workspace. Cannot create, edit, delete, or share items. |

---

## Fabric Managed Identity — Required Roles on External Resources

| Target Resource | Required Role | Purpose |
|---|---|---|
| Azure Data Lake Storage Gen2 (OneLake Shortcut) | `Storage Blob Data Contributor` | Read/write external data via OneLake shortcuts |
| Azure Data Lake Storage Gen2 (read-only) | `Storage Blob Data Reader` | Read external data via OneLake shortcuts |
| Azure Key Vault | `Key Vault Secrets User` | Read connection secrets for external data sources |
| Azure SQL Database | `SQL DB Contributor` + SQL contained user | External data source for warehouses and lakehouses |
| Azure Event Hubs | `Azure Event Hubs Data Receiver` | Real-time data ingestion via Eventstreams |

## Notes / Considerations

- **Fabric workspace permissions are separate from Azure RBAC** — having `Contributor` on the Azure capacity does not grant access to workspace items. Workspace roles must be assigned within the Fabric portal.
- **Fabric Admin role** is a tenant-level Microsoft 365 admin role (formerly Power BI Admin). It is distinct from both Azure RBAC and workspace-level roles and grants administration of all Fabric capacities and workspaces within the tenant.
- **OneLake** is the unified storage layer for all Fabric workspaces. OneLake shortcuts to external ADLS Gen2 require the Fabric workspace identity to have appropriate `Storage Blob Data *` roles on the target storage account.
- Use **Managed Identities** (workspace identity) for connections to external Azure resources instead of credentials or shared keys.
- **Capacity pausing** stops all compute and makes workspaces read-only — data in OneLake is not affected.
- Fabric inherits **Microsoft Purview** integration for data governance and lineage tracking when Purview is configured in the same tenant.
- Prefer assigning workspace roles at the workspace level rather than granting broad Azure RBAC at the subscription scope.

## Related Resources

- [Azure Data Lake Storage Gen2](./azure-data-lake-storage-gen2.md) — External data accessed via OneLake shortcuts
- [Azure Synapse Analytics](./azure-synapse-analytics.md) — Predecessor/complement for analytics workloads
- [Azure Data Factory](./azure-data-factory.md) — Data integration and orchestration (also available as Fabric Pipelines)
- [Azure Event Hubs](./azure-event-hubs.md) — Real-time data ingestion for Fabric Eventstreams
- [Microsoft Purview](./microsoft-purview.md) — Data governance and lineage for Fabric assets
- [Azure Data Explorer](./azure-data-explorer.md) — Complement for advanced real-time analytics (Fabric Real-Time Intelligence is built on Kusto)
