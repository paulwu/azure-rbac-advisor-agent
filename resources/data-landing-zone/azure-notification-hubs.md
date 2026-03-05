# Azure Notification Hubs

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.NotificationHubs` |
| **Resource Types** | `Microsoft.NotificationHubs/namespaces`, `Microsoft.NotificationHubs/namespaces/notificationHubs` |
| **Azure Portal Category** | Mobile > Notification Hubs |
| **Landing Zone Context** | Data Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/notification-hubs/notification-hubs-push-notification-overview) |
| **Pricing** | [Notification Hubs Pricing](https://azure.microsoft.com/pricing/details/notification-hubs/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/notification-hubs/) |

## Overview

Azure Notification Hubs is a scalable push notification engine for sending notifications to any platform (iOS, Android, Windows, Kindle) from any back end. In a Data Landing Zone, Notification Hubs integrates with event-driven data pipelines to deliver real-time push notifications triggered by data events, alerts, or analytics insights. The service operates as namespaces containing one or more notification hubs.

## Least-Privilege RBAC Reference

> Notification Hubs does not have purpose-built Azure RBAC roles. Management-plane operations require `Contributor`. Data-plane operations (sending notifications, managing registrations) use Shared Access Signature (SAS) policies configured on the hub, not Azure RBAC.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Notification Hub namespace | Resource Group | `Contributor` | No purpose-built management role. Scope `Contributor` to the resource group. |
| Create a notification hub within a namespace | Namespace resource | `Contributor` | |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Update notification hub settings | Hub resource | `Contributor` | |
| Configure platform notification services (APNs, FCM, WNS) | Hub resource | `Contributor` | Platform credentials (certificates, API keys) are configured on the hub. |
| Update SAS authorization rules | Hub / Namespace | `Contributor` | Manages Listen, Send, and Manage policies for data-plane access. |
| Update tags | Namespace / Hub resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a notification hub | Namespace resource | `Contributor` | All registrations and pending notifications are lost. |
| Delete a namespace | Resource Group | `Contributor` | All hubs within the namespace are deleted. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| View hub metrics and status | Hub resource | `Reader` | Includes push success/failure rates, registration counts. |
| Configure Diagnostic Settings | Namespace resource | `Monitoring Contributor` | Sends push result logs and error details to Log Analytics. |
| Send notifications (data plane) | Hub resource | SAS policy with `Send` claim | Not an Azure RBAC role; uses SAS connection string from the hub's authorization rules. |
| Manage device registrations (data plane) | Hub resource | SAS policy with `Listen` + `Manage` claim | Not an Azure RBAC role; uses SAS connection string. |
| View registrations (data plane) | Hub resource | SAS policy with `Listen` claim | Not an Azure RBAC role. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives Notification Hub diagnostic logs (push results, errors, registration operations) via Diagnostic Settings. | Optional (strongly recommended) |

## Notes / Considerations

- **No purpose-built Azure RBAC roles** for Notification Hubs — all management-plane operations require `Contributor` scoped to the resource group. Consider a custom role with `Microsoft.NotificationHubs/*` actions for stricter least privilege.
- **Data-plane access** uses SAS (Shared Access Signature) policies, not Azure RBAC. Three permission levels: `Listen` (receive registrations), `Send` (push notifications), `Manage` (full access including registration management).
- **SAS connection strings** should be stored in Azure Key Vault and rotated regularly. Use the most restrictive policy (e.g., `Send` only for backend services that only push).
- **Platform credentials** (APNs certificates, FCM API keys, WNS client secrets) are stored in the hub configuration — protect management access to prevent credential exposure.
- **Namespace-level vs. hub-level SAS**: Namespace SAS policies grant access to all hubs in the namespace; hub-level policies scope access to a single hub. Prefer hub-level policies for least privilege.

## Related Resources

- [Azure Event Grid](./azure-event-grid.md) — Event triggers for notification workflows
- [Azure Event Hubs](./azure-event-hubs.md) — High-throughput event ingestion upstream of notifications
