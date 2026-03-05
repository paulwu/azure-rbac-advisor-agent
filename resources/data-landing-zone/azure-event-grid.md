# Azure Event Grid

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.EventGrid` |
| **Resource Types** | `Microsoft.EventGrid/topics`, `Microsoft.EventGrid/eventSubscriptions`, `Microsoft.EventGrid/domains`, `Microsoft.EventGrid/systemTopics`, `Microsoft.EventGrid/namespaces` |
| **Azure Portal Category** | Integration > Event Grid |
| **Landing Zone Context** | Data Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/event-grid/overview) |
| **Pricing** | [Event Grid Pricing](https://azure.microsoft.com/pricing/details/event-grid/) |
| **SLA** | [99.99%](https://azure.microsoft.com/support/legal/sla/event-grid/) |

## Overview

Azure Event Grid is a fully managed event routing service that enables event-driven architectures using a publish-subscribe model. In a Data Landing Zone, Event Grid connects data sources (Storage, IoT Hub, custom applications) to event handlers (Functions, Logic Apps, Event Hubs, Service Bus) for real-time data pipeline triggers. Event Grid supports custom topics, system topics (Azure resource events), and domains (multi-tenant event management).

## Least-Privilege RBAC Reference

> Event Grid has purpose-built roles separating management-plane operations (`EventGrid Contributor`) from data-plane event publishing (`EventGrid Data Sender`). Event subscription management has its own dedicated role (`EventGrid EventSubscription Contributor`).

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a custom topic | Resource Group | `EventGrid Contributor` | |
| Create an event domain | Resource Group | `EventGrid Contributor` | Domains enable multi-tenant event publishing with up to 100,000 domain topics. |
| Create a system topic | Resource Group | `EventGrid Contributor` | System topics are created for Azure resource events (e.g., Storage blob created). |
| Create an event subscription | Topic / System Topic / Domain | `EventGrid EventSubscription Contributor` | May also require `Reader` on the event handler (e.g., Function, Event Hub) to validate the endpoint. |
| Create an Event Grid namespace (MQTT) | Resource Group | `EventGrid Contributor` | Namespaces support MQTT protocol for IoT scenarios. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Modify event subscription filters | Event subscription resource | `EventGrid EventSubscription Contributor` | Subject filtering, advanced filtering, and dead-letter configuration. |
| Update event subscription endpoint | Event subscription resource | `EventGrid EventSubscription Contributor` | |
| Modify topic/domain settings | Topic / Domain resource | `EventGrid Contributor` | |
| Update tags | Topic / Domain resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a custom topic | Resource Group | `EventGrid Contributor` | All event subscriptions on the topic must be removed first. |
| Delete an event subscription | Topic / System Topic | `EventGrid EventSubscription Contributor` | |
| Delete an event domain | Resource Group | `EventGrid Contributor` | |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Publish events to a topic (data plane) | Topic resource | `EventGrid Data Sender` | Data-plane role for publishing events. |
| View topic metrics and event delivery status | Topic resource | `EventGrid EventSubscription Reader` | |
| Configure Private Endpoint for topic | Topic + VNet | `EventGrid Contributor` + `Network Contributor` | |
| Configure Diagnostic Settings | Topic / Domain resource | `Monitoring Contributor` | Sends delivery failure logs and publish operation metrics to Log Analytics. |
| Configure dead-letter destination | Event subscription | `EventGrid EventSubscription Contributor` + `Storage Blob Data Contributor` | Dead-letter events are written to a Storage blob container. |
| Configure managed identity for delivery | Topic resource | `EventGrid Contributor` | Topic's managed identity can authenticate to event handlers. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Azure Storage Account](../workload-landing-zone/azure-storage-account.md) | `Microsoft.Storage/storageAccounts` | Serves as dead-letter destination for undeliverable events; `Storage Blob Data Contributor` is required on the container for the Event Grid managed identity. | Optional (strongly recommended) |
| [Azure Event Hubs](./azure-event-hubs.md) | `Microsoft.EventHub/namespaces` | Common event handler for high-throughput event processing; Event Grid can route events to Event Hubs for stream processing pipelines. | Optional |
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives Event Grid diagnostic logs (delivery failures, publish operations) via Diagnostic Settings. | Optional (strongly recommended) |

## Notes / Considerations

- **`EventGrid Data Sender`** is the purpose-built data-plane role for publishing events — prefer it over using access keys for topic authentication.
- **`EventGrid EventSubscription Contributor`** is narrower than `EventGrid Contributor` — use it for teams that only need to manage event subscriptions without creating/deleting topics.
- **System topics** are automatically created when an Azure resource event subscription is configured; they represent events from first-party Azure services.
- **Event domains** enable publishing events to thousands of topics within a single domain — useful for SaaS multi-tenant architectures.
- **Dead-letter configuration** should always be enabled for critical event subscriptions to capture undeliverable events.
- **Managed identity delivery** is recommended over key-based authentication for event handlers, especially for Event Hubs, Service Bus, and Storage Queue endpoints.

## Related Resources

- [Azure Event Hubs](./azure-event-hubs.md) — Common event handler for stream processing
- [Azure Data Factory](./azure-data-factory.md) — Event-triggered data pipelines
- [Azure Data Lake Storage Gen2](./azure-data-lake-storage-gen2.md) — Storage events trigger data processing
