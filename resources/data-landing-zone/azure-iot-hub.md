# Azure IoT Hub

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Devices` |
| **Resource Type** | `Microsoft.Devices/IotHubs` |
| **Azure Portal Category** | Internet of Things > IoT Hub |
| **Landing Zone Context** | Data Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/iot-hub/iot-concepts-and-iot-hub) |
| **Pricing** | [IoT Hub Pricing](https://azure.microsoft.com/pricing/details/iot-hub/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/iot-hub/) |

## Overview

Azure IoT Hub is a managed service for bidirectional communication between IoT applications and devices. In a Data Landing Zone, IoT Hub serves as the central ingestion point for device telemetry, enabling downstream processing via Event Hubs-compatible endpoints, message routing to storage and analytics services, and device management at scale. IoT Hub separates management-plane operations from data-plane device and service access.

## Least-Privilege RBAC Reference

> IoT Hub has purpose-built data-plane roles (`IoT Hub Data Contributor`, `IoT Hub Data Reader`, `IoT Hub Registry Contributor`, `IoT Hub Twin Contributor`). Management-plane operations require `Contributor` as no purpose-built management role exists for `Microsoft.Devices/IotHubs`.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create an IoT Hub | Resource Group | `Contributor` | No purpose-built management role for IoT Hub. Scope `Contributor` to the resource group. |
| Create a consumer group | IoT Hub resource | `Contributor` | Consumer groups on the built-in Event Hubs-compatible endpoint. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Scale IoT Hub tier/units | IoT Hub resource | `Contributor` | |
| Configure message routing (to Storage, Event Hubs, Service Bus) | IoT Hub resource | `Contributor` | Also requires appropriate roles on the routing destination. |
| Update IoT Hub settings | IoT Hub resource | `Contributor` | |
| Update tags | IoT Hub resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete an IoT Hub | Resource Group | `Contributor` | All device registrations and data are permanently lost. |

### ⚙️ Configure — Management Plane

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure IP filter rules | IoT Hub resource | `Contributor` | |
| Configure Private Endpoint | IoT Hub + VNet | `Contributor` + `Network Contributor` | |
| Configure Diagnostic Settings | IoT Hub resource | `Monitoring Contributor` | Sends device connection events, routing metrics, and twin operations to Log Analytics. |
| View IoT Hub metrics | IoT Hub resource | `Reader` | |
| Configure file upload | IoT Hub + Storage Account | `Contributor` + `Storage Blob Data Contributor` | Devices upload files to a linked Storage account. |

### ⚙️ Configure — Data Plane

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Register/delete devices in the identity registry | IoT Hub resource | `IoT Hub Registry Contributor` | Create, update, and delete device identities. |
| Read device identity registry | IoT Hub resource | `IoT Hub Data Reader` | Read-only access to device registry and twin data. |
| Send cloud-to-device messages | IoT Hub resource | `IoT Hub Data Contributor` | Full data-plane access: send messages, invoke methods, update twins. |
| Read device-to-cloud messages | IoT Hub resource | `IoT Hub Data Reader` | Read telemetry from the built-in Event Hubs-compatible endpoint. |
| Invoke direct methods on devices | IoT Hub resource | `IoT Hub Data Contributor` | |
| Read/write device twins | IoT Hub resource | `IoT Hub Twin Contributor` | Update desired properties; read reported properties. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Azure Event Hubs](./azure-event-hubs.md) | `Microsoft.EventHub/namespaces` | Custom message routing destination for device telemetry; IoT Hub's managed identity requires `Azure Event Hubs Data Sender` on the Event Hub. | Optional |
| [Azure Storage Account](../workload-landing-zone/azure-storage-account.md) | `Microsoft.Storage/storageAccounts` | Stores device file uploads and serves as a message routing destination; `Storage Blob Data Contributor` is required for the IoT Hub managed identity. | Optional |
| [Azure Data Lake Storage Gen2](./azure-data-lake-storage-gen2.md) | `Microsoft.Storage/storageAccounts` | Message routing destination for storing raw device telemetry in a data lake for batch analytics. | Optional |
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives IoT Hub diagnostic logs (device connections, message routing, twin operations) via Diagnostic Settings. | Optional (strongly recommended) |

## Notes / Considerations

- **No purpose-built management-plane role** for IoT Hub — use `Contributor` scoped to the resource group. Consider a custom role with `Microsoft.Devices/IotHubs/*` actions for stricter least privilege.
- **Data-plane roles** are purpose-built and should be preferred for service-to-IoT Hub integration: `IoT Hub Data Contributor` for full access, `IoT Hub Data Reader` for read-only telemetry consumption, `IoT Hub Registry Contributor` for device lifecycle management.
- **`IoT Hub Twin Contributor`** provides narrower access than `IoT Hub Data Contributor` when only twin read/write is needed.
- **Built-in Event Hubs-compatible endpoint**: IoT Hub exposes device telemetry via an Event Hubs-compatible endpoint; consumers need `IoT Hub Data Reader` (not Event Hubs roles) to read from it.
- **Message routing** to external endpoints (Storage, Event Hubs, Service Bus) uses IoT Hub's managed identity — configure the appropriate data-plane role on each destination.
- **Device Provisioning Service (DPS)** (`Microsoft.Devices/provisioningServices`) is a companion service for zero-touch device provisioning; it has its own role requirements.

## Related Resources

- [Azure Event Hubs](./azure-event-hubs.md) — Telemetry routing and stream processing
- [Azure Data Lake Storage Gen2](./azure-data-lake-storage-gen2.md) — Raw telemetry storage
- [Azure Event Grid](./azure-event-grid.md) — React to IoT Hub events (device connected/disconnected)
- [Azure Stream Analytics](./azure-stream-analytics.md) — Real-time telemetry processing
