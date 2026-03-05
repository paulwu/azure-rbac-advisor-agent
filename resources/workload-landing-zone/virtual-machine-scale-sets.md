# Virtual Machine Scale Sets

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Compute` |
| **Resource Type** | `Microsoft.Compute/virtualMachineScaleSets` |
| **Azure Portal Category** | Compute > Virtual Machine Scale Sets |
| **Landing Zone Context** | Workload Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/virtual-machine-scale-sets/overview) |
| **Pricing** | [VM Scale Sets Pricing](https://azure.microsoft.com/pricing/details/virtual-machine-scale-sets/) |
| **SLA** | [99.95% (2+ instances across fault domains) to 99.99% (Availability Zones)](https://azure.microsoft.com/support/legal/sla/virtual-machine-scale-sets/) |

## Overview

Azure Virtual Machine Scale Sets enable deployment and management of a group of identical, auto-scaling VMs. In a Workload Landing Zone, VMSS provides elastic compute capacity for web tiers, batch processing, and microservices that require horizontal scaling. VMSS supports both Uniform and Flexible orchestration modes, with Flexible being the recommended mode for new deployments.

## Least-Privilege RBAC Reference

> VMSS management uses `Virtual Machine Contributor`, the same role used for individual VMs. Autoscale configuration requires `Monitoring Contributor` for the autoscale settings resource.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a VMSS | Resource Group | `Virtual Machine Contributor` | Also requires `Network Contributor` on the target subnet for NIC creation. |
| Create a VMSS with custom image | Resource Group + Image resource | `Virtual Machine Contributor` + `Reader` on image | Image can be from Azure Compute Gallery or a managed image. |
| Assign a managed identity to VMSS | VMSS resource | `Virtual Machine Contributor` + `Managed Identity Operator` | `Managed Identity Operator` is required on the user-assigned managed identity resource. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Scale out/in (manual) | VMSS resource | `Virtual Machine Contributor` | |
| Change VM SKU | VMSS resource | `Virtual Machine Contributor` | Requires reimaging or rolling upgrade. |
| Update VMSS model (extensions, data disks, OS image) | VMSS resource | `Virtual Machine Contributor` | Model updates may require instance reimaging depending on upgrade policy. |
| Reimage instances | VMSS resource | `Virtual Machine Contributor` | Replaces OS disk with a fresh image; data disks are preserved. |
| Modify upgrade policy (Manual, Rolling, Automatic) | VMSS resource | `Virtual Machine Contributor` | |
| Update tags | VMSS resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a VMSS | Resource Group | `Virtual Machine Contributor` | Deletes all instances, OS disks, and NICs. |
| Delete specific instances | VMSS resource | `Virtual Machine Contributor` | Individual instances can be deleted within a scale set. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure autoscale settings | VMSS resource group | `Monitoring Contributor` | Autoscale uses `Microsoft.Insights/autoscaleSettings` resource. |
| Start / Stop / Restart instances | VMSS resource | `Virtual Machine Contributor` | |
| Enable Entra ID login | VMSS instances | `Virtual Machine Administrator Login` or `Virtual Machine User Login` | Requires AAD login extension in the VMSS model. |
| Configure Diagnostic Settings | VMSS resource | `Monitoring Contributor` | |
| Run command on instances | VMSS resource | `Virtual Machine Contributor` | Executes scripts via the Azure VM agent. |
| Configure rolling upgrade policy | VMSS resource | `Virtual Machine Contributor` | Max batch percentage, pause time, health monitoring. |
| View VMSS metrics and instance health | VMSS resource | `Reader` | |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Spoke Virtual Network](./spoke-virtual-network.md) | `Microsoft.Network/virtualNetworks` | VMSS instances are deployed into a subnet within the spoke VNet; a VNet and subnet are required for NIC creation. | Required |
| [Azure Load Balancer](./azure-load-balancer.md) | `Microsoft.Network/loadBalancers` | Distributes traffic across VMSS instances; Standard SKU load balancer is required for cross-zone deployment. | Optional (strongly recommended) |
| [Network Security Groups](./network-security-groups.md) | `Microsoft.Network/networkSecurityGroups` | Controls inbound/outbound traffic to VMSS instances at the subnet or NIC level. | Optional (strongly recommended) |
| [Azure Key Vault](./azure-key-vault.md) | `Microsoft.KeyVault/vaults` | Stores disk encryption keys and application secrets; VMSS managed identity requires appropriate Key Vault roles. | Optional |
| [Recovery Services Vault](../platform-landing-zone/recovery-services-vault.md) | `Microsoft.RecoveryServices/vaults` | Manages backup policies for VMSS instances (Flexible orchestration mode). | Optional |

## Notes / Considerations

- **`Virtual Machine Contributor`** covers all VMSS compute operations but does NOT grant OS login access — use `Virtual Machine Administrator Login` or `Virtual Machine User Login` for Entra ID-based login.
- **Flexible orchestration mode** is recommended for new deployments; it supports mixed VM sizes, Availability Zones, and individual VM management.
- **Autoscale settings** are a separate `Microsoft.Insights` resource requiring `Monitoring Contributor` — `Virtual Machine Contributor` alone cannot configure autoscale.
- **Rolling upgrades** minimize disruption when updating the VMSS model; configure max batch percentage and pause time based on workload tolerance.
- **Spot instances** in VMSS can reduce costs for fault-tolerant workloads; eviction policy (deallocate/delete) is set at VMSS creation.
- The existing [Virtual Machines](./virtual-machines.md) file covers standalone VM and disk management; this file covers scale-set-specific operations.

## Related Resources

- [Virtual Machines](./virtual-machines.md) — Standalone VM management and shared RBAC model
- [Azure Load Balancer](./azure-load-balancer.md) — Traffic distribution across VMSS instances
- [Azure Managed Disks](./azure-managed-disks.md) — Disk management for VMSS instances
- [Network Security Groups](./network-security-groups.md) — Network access control
- [Spoke Virtual Network](./spoke-virtual-network.md) — Deployment subnet
