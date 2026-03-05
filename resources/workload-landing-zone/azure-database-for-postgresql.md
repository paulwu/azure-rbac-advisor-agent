# Azure Database for PostgreSQL Flexible Server

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.DBforPostgreSQL` |
| **Resource Type** | `Microsoft.DBforPostgreSQL/flexibleServers` |
| **Azure Portal Category** | Databases > Azure Database for PostgreSQL Flexible Servers |
| **Landing Zone Context** | Workload Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/postgresql/flexible-server/overview) |
| **Pricing** | [PostgreSQL Flexible Server Pricing](https://azure.microsoft.com/pricing/details/postgresql/flexible-server/) |
| **SLA** | [99.99% (zone-redundant HA)](https://azure.microsoft.com/support/legal/sla/postgresql/) |

## Overview

Azure Database for PostgreSQL Flexible Server is a fully managed relational database service based on the open-source PostgreSQL engine. In a Workload Landing Zone, it serves as the primary relational database for applications requiring PostgreSQL compatibility. Flexible Server provides granular control over database configuration, maintenance windows, and high-availability architecture.

## Least-Privilege RBAC Reference

> Azure Database for PostgreSQL separates **management plane** (Azure RBAC — create/configure the server) from **data plane** (PostgreSQL authentication — access to databases and tables). Azure RBAC does NOT grant database query access. Data access requires PostgreSQL roles configured via Entra ID authentication or PostgreSQL native credentials.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a PostgreSQL Flexible Server | Resource Group | `Contributor` | No purpose-built management role exists for `Microsoft.DBforPostgreSQL`. Scope `Contributor` to the resource group. |
| Create a database on the server | Server resource | `Contributor` | Database creation is a management-plane operation. |
| Create a firewall rule | Server resource | `Contributor` | |
| Create a server with VNet integration | Resource Group + VNet | `Contributor` + `Network Contributor` | Requires a delegated subnet (`Microsoft.DBforPostgreSQL/flexibleServers`). |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Change compute tier/SKU | Server resource | `Contributor` | May cause brief connectivity interruption. |
| Modify storage size | Server resource | `Contributor` | Storage can only be increased, not decreased. |
| Update server parameters | Server resource | `Contributor` | PostgreSQL configuration parameters (e.g., `max_connections`, `shared_buffers`). |
| Configure high availability (zone-redundant) | Server resource | `Contributor` | |
| Update maintenance window | Server resource | `Contributor` | |
| Update firewall rules | Server resource | `Contributor` | |
| Modify tags | Server resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a PostgreSQL Flexible Server | Resource Group | `Contributor` | Deleting the server deletes all databases. Backups are retained per the configured retention period. |
| Delete a database | Server resource | `Contributor` | |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure Entra ID authentication | Server resource | `Contributor` | Set an Entra ID admin for the server; enables Entra ID-based database login. |
| Configure Private Endpoint / VNet integration | Server + VNet | `Contributor` + `Network Contributor` | VNet integration uses a delegated subnet. |
| Configure Diagnostic Settings | Server resource | `Monitoring Contributor` | Sends PostgreSQL logs (query logs, error logs, audit logs) to Log Analytics. |
| View server metrics and status | Server resource | `Reader` | |
| Configure read replicas | Server resource | `Contributor` | Cross-region read replicas for read scale-out. |
| Configure backup retention | Server resource | `Contributor` | 7–35 days retention; geo-redundant backup available. |

### ⚙️ Configure — Data Plane (PostgreSQL Authentication)

> The following require **PostgreSQL authentication** (SQL commands) rather than Azure RBAC. The Entra ID admin or PostgreSQL superuser must grant these permissions inside the database.

| Operation | PostgreSQL Permission Required | Notes |
|---|---|---|
| Create a database user (Entra ID) | `azure_pg_admin` role + `CREATE USER` | `CREATE USER [user@domain] IN ROLE azure_ad_user;` |
| Grant read access to tables | `SELECT` on schema/tables | `GRANT SELECT ON ALL TABLES IN SCHEMA public TO reader_role;` |
| Grant read/write access | `SELECT, INSERT, UPDATE, DELETE` | |
| Grant schema creation | `CREATE` on database | |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Spoke Virtual Network](./spoke-virtual-network.md) | `Microsoft.Network/virtualNetworks` | Provides a delegated subnet for VNet-integrated deployment, restricting database access to private network traffic only. | Optional (strongly recommended) |
| [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) | `Microsoft.Network/privateDnsZones` | Resolves `privatelink.postgres.database.azure.com` for Private Endpoint or VNet-integrated clients. | Required (if VNet integration or Private Endpoint enabled) |
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives PostgreSQL diagnostic logs (query logs, error logs, connection logs, audit logs) via Diagnostic Settings. | Optional (strongly recommended) |
| [Azure Key Vault](./azure-key-vault.md) | `Microsoft.KeyVault/vaults` | Stores Customer-Managed Keys for data encryption at rest; the server's managed identity requires `Key Vault Crypto Service Encryption User` on the vault. | Optional (for CMK encryption) |

## Notes / Considerations

- **No purpose-built Azure RBAC role** exists for PostgreSQL Flexible Server management — `Contributor` scoped to the resource group is the minimum. Consider a custom role with `Microsoft.DBforPostgreSQL/flexibleServers/*` actions for stricter least privilege.
- **Management plane ≠ data plane**: `Contributor` cannot query or modify database data. Data access requires PostgreSQL roles via Entra ID authentication or native PostgreSQL credentials.
- **Entra ID authentication** is strongly recommended over password-based auth. Set an Entra ID admin on the server and create contained database users.
- **VNet integration** uses subnet delegation (`Microsoft.DBforPostgreSQL/flexibleServers`); the subnet cannot be shared with other services.
- **`pgAudit` extension** is available for detailed SQL audit logging to Diagnostic Settings.
- **High availability**: Zone-redundant HA uses synchronous replication with automatic failover; same-zone HA is also available at lower cost.

## Related Resources

- [Azure Key Vault](./azure-key-vault.md) — CMK encryption key storage
- [Spoke Virtual Network](./spoke-virtual-network.md) — VNet integration subnet
- [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) — `privatelink.postgres.database.azure.com`
- [Azure SQL Database](./azure-sql-database.md) — Alternative managed relational database (SQL Server engine)
