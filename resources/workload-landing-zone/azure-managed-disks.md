# Azure Managed Disks

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Compute` |
| **Resource Types** | `Microsoft.Compute/disks`, `Microsoft.Compute/snapshots`, `Microsoft.Compute/diskEncryptionSets`, `Microsoft.Compute/diskAccesses` |
| **Azure Portal Category** | Compute > Disks |
| **Landing Zone Context** | Workload Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/virtual-machines/managed-disks-overview) |
| **Pricing** | [Managed Disks Pricing](https://azure.microsoft.com/pricing/details/managed-disks/) |
| **SLA** | Covered by [VM SLA](https://azure.microsoft.com/support/legal/sla/virtual-machines/) |

## Overview

Azure Managed Disks are block-level storage volumes managed by Azure and used with Azure Virtual Machines and VMSS. In a Workload Landing Zone, managed disks provide durable, high-performance storage for OS and data volumes. Managed disks support multiple tiers (Standard HDD, Standard SSD, Premium SSD, Ultra Disk, Premium SSD v2) and encryption options (platform-managed keys, customer-managed keys, double encryption).

## Least-Privilege RBAC Reference

> Managed disk management uses `Virtual Machine Contributor` for operations tied to VMs. For standalone disk data operations (upload, download, export), `Data Operator for Managed Disks` provides data-plane access without management-plane control.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a managed disk | Resource Group | `Virtual Machine Contributor` | Standalone disk creation or as part of VM provisioning. |
| Create a snapshot from a disk | Resource Group | `Disk Snapshot Contributor` | Snapshots are point-in-time copies of disks. |
| Create a Disk Encryption Set | Resource Group | `Contributor` | No purpose-built role; DES links disks to Key Vault CMK. Scope `Contributor` to the resource group. |
| Create a Disk Access resource (Private Endpoint) | Resource Group | `Contributor` | Disk Access enables private endpoint for disk export/import. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Resize a managed disk | Disk resource | `Virtual Machine Contributor` | Disk must be unattached or VM deallocated. Size can only be increased. |
| Change disk tier (Standard → Premium) | Disk resource | `Virtual Machine Contributor` | Tier change may require VM deallocation. |
| Change disk performance tier (Premium SSD) | Disk resource | `Virtual Machine Contributor` | Performance tier can be changed without detaching. |
| Attach/detach a data disk to a VM | VM + Disk resource | `Virtual Machine Contributor` | |
| Update disk tags | Disk resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a managed disk | Resource Group | `Virtual Machine Contributor` | Disk must be unattached from all VMs. |
| Delete a snapshot | Resource Group | `Disk Snapshot Contributor` | |
| Delete a Disk Encryption Set | Resource Group | `Contributor` | Must be disassociated from all disks first. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Grant disk export/upload access (generate SAS) | Disk resource | `Data Operator for Managed Disks` | Data-plane role for disk data transfer operations. |
| Configure Customer-Managed Key (CMK) encryption | Disk + Key Vault | `Virtual Machine Contributor` + `Key Vault Crypto Service Encryption User` | Disk Encryption Set's managed identity needs `Key Vault Crypto Service Encryption User` on the vault. |
| Configure disk bursting | Disk resource | `Virtual Machine Contributor` | On-demand bursting for Premium SSD and Standard SSD. |
| Enable shared disk (multi-attach) | Disk resource | `Virtual Machine Contributor` | Supports attaching a single disk to multiple VMs (for clustering). |
| Configure Private Endpoint for disk access | Disk Access resource | `Contributor` + `Network Contributor` | Restricts disk export/import to private network. |
| Restore a disk from backup | Recovery Services vault | `Disk Restore Operator` | Restores disk from Azure Backup recovery point. |
| Read disk from backup | Recovery Services vault | `Disk Backup Reader` | Required for backup operations to read disk metadata. |
| View disk metrics and status | Disk resource | `Reader` | |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Virtual Machines](./virtual-machines.md) | `Microsoft.Compute/virtualMachines` | Managed disks are attached to VMs as OS or data volumes; disks cannot serve workloads without an attached VM. | Required |
| [Azure Key Vault](./azure-key-vault.md) | `Microsoft.KeyVault/vaults` | Stores Customer-Managed Keys used by Disk Encryption Sets for server-side encryption; the DES managed identity requires `Key Vault Crypto Service Encryption User`. | Optional (for CMK encryption) |
| [Recovery Services Vault](../platform-landing-zone/recovery-services-vault.md) | `Microsoft.RecoveryServices/vaults` | Manages disk backup policies and recovery points; `Disk Backup Reader` is required on the disk for the vault's managed identity. | Optional |

## Notes / Considerations

- **`Virtual Machine Contributor`** covers most disk management operations because disks are typically managed in the context of VMs.
- **`Data Operator for Managed Disks`** is a purpose-built data-plane role for disk upload/download/export — use it instead of `Contributor` for data transfer scenarios.
- **`Disk Snapshot Contributor`** provides narrower access than `Virtual Machine Contributor` for snapshot-only workflows.
- **Disk Encryption Set** requires `Contributor` because no purpose-built role exists — consider a custom role with `Microsoft.Compute/diskEncryptionSets/*` actions.
- **Double encryption**: Combines platform-managed key (infrastructure) with customer-managed key (Disk Encryption Set) for defense in depth.
- **Ultra Disks** and **Premium SSD v2** require specific VM SKUs and availability zone deployment.
- **Shared disks** support up to 10 concurrent attachments (varies by disk type) for Windows Server Failover Clustering and similar scenarios.

## Related Resources

- [Virtual Machines](./virtual-machines.md) — Disks are attached to VMs as storage volumes
- [Virtual Machine Scale Sets](./virtual-machine-scale-sets.md) — VMSS instances use managed disks
- [Azure Key Vault](./azure-key-vault.md) — CMK encryption key storage
- [Recovery Services Vault](../platform-landing-zone/recovery-services-vault.md) — Disk backup and restore
