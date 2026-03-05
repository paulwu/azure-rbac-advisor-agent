# Azure Virtual Desktop

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.DesktopVirtualization` |
| **Resource Types** | `Microsoft.DesktopVirtualization/hostPools`, `Microsoft.DesktopVirtualization/applicationGroups`, `Microsoft.DesktopVirtualization/workspaces`, `Microsoft.DesktopVirtualization/scalingPlans` |
| **Azure Portal Category** | Compute > Azure Virtual Desktop |
| **Landing Zone Context** | Workload Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/virtual-desktop/overview) |
| **Pricing** | [Azure Virtual Desktop Pricing](https://azure.microsoft.com/pricing/details/virtual-desktop/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/virtual-desktop/) |

## Overview

Azure Virtual Desktop (AVD) is a desktop and app virtualization service that runs in Azure. In a Workload Landing Zone, AVD provides secure remote access to desktops and applications for end users. AVD has a multi-resource architecture: host pools contain session host VMs, application groups define published apps or desktops, and workspaces aggregate application groups for user access.

## Least-Privilege RBAC Reference

> AVD has purpose-built roles for each resource type (host pools, application groups, workspaces) with contributor/reader granularity. `Desktop Virtualization Contributor` covers all AVD resource types; narrower roles like `Desktop Virtualization Host Pool Contributor` scope access to specific resource types.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a host pool | Resource Group | `Desktop Virtualization Contributor` | |
| Create an application group | Resource Group | `Desktop Virtualization Contributor` | Application groups are linked to a host pool. |
| Create a workspace | Resource Group | `Desktop Virtualization Contributor` | Workspaces aggregate application groups for user access. |
| Create a scaling plan | Resource Group | `Desktop Virtualization Contributor` | Automated start/stop of session host VMs. |
| Deploy session host VMs | Resource Group | `Virtual Machine Contributor` + `Network Contributor` | Session hosts are standard VMs; AVD roles do not cover VM creation. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Modify host pool properties (max sessions, load balancing) | Host pool resource | `Desktop Virtualization Host Pool Contributor` | |
| Update application group assignments | Application group resource | `Desktop Virtualization Application Group Contributor` | |
| Modify workspace properties | Workspace resource | `Desktop Virtualization Workspace Contributor` | |
| Modify scaling plan schedules | Scaling plan resource | `Desktop Virtualization Contributor` | |
| Update published application settings | Application group resource | `Desktop Virtualization Application Group Contributor` | |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a host pool | Resource Group | `Desktop Virtualization Contributor` | Remove all session hosts and application groups first. |
| Delete an application group | Resource Group | `Desktop Virtualization Contributor` | Must be unregistered from workspace first. |
| Delete a workspace | Resource Group | `Desktop Virtualization Contributor` | All application groups must be unregistered first. |
| Delete session host VMs | Resource Group | `Virtual Machine Contributor` | Session host VMs are standard VM resources. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Assign users to application groups | Application group resource | `Desktop Virtualization User Session Operator` | Users need `Desktop Virtualization User` role to connect. |
| Grant user access to connect | Application group resource | `Desktop Virtualization User` | Data-plane role enabling user connections to desktops/apps. |
| Manage user sessions (log off, disconnect, send message) | Host pool resource | `Desktop Virtualization Session Host Operator` | |
| Start/stop session host VMs (via scaling plan) | VMSS / VMs | `Desktop Virtualization Power On Off Contributor` | Required on the compute resource (VMs) for automated scaling. |
| View host pool, sessions, and diagnostics | Host pool resource | `Desktop Virtualization Reader` | |
| Configure Diagnostic Settings | AVD resources | `Monitoring Contributor` | Sends connection, host health, and session data to Log Analytics. |
| Configure RDP properties (multi-monitor, drive redirection) | Host pool resource | `Desktop Virtualization Host Pool Contributor` | |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Spoke Virtual Network](./spoke-virtual-network.md) | `Microsoft.Network/virtualNetworks` | Session host VMs are deployed into a subnet within the spoke VNet for network connectivity and access to corporate resources. | Required |
| [Azure Key Vault](./azure-key-vault.md) | `Microsoft.KeyVault/vaults` | Stores domain join credentials, local admin passwords, and certificates used during session host provisioning. | Optional (strongly recommended) |
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives AVD diagnostic logs (connection events, session host health, user activity, errors) via Diagnostic Settings. | Optional (strongly recommended) |
| [Azure Storage Account](./azure-storage-account.md) | `Microsoft.Storage/storageAccounts` | Hosts FSLogix user profile containers on Azure Files or Azure NetApp Files for persistent user profiles across session hosts. | Optional (required for persistent profiles) |

## Notes / Considerations

- **Multi-layer RBAC**: AVD requires roles on both the AVD service resources (host pools, app groups, workspaces) AND the underlying compute resources (VMs). `Desktop Virtualization Contributor` does not grant VM management.
- **`Desktop Virtualization User`** is the data-plane role that allows end users to connect to desktops/apps. Assign it on the application group, not the host pool.
- **Scaling plans** require `Desktop Virtualization Power On Off Contributor` on session host VMs or VMSS to start/stop VMs based on schedules and demand.
- **FSLogix profiles** stored on Azure Files require `Storage File Data SMB Share Contributor` for user identities on the file share.
- **Session host VMs** can be domain-joined (Active Directory) or Entra ID-joined. Entra ID join simplifies identity management but requires compatible application configurations.
- **Prefer narrower roles** (`Desktop Virtualization Host Pool Contributor`, `Desktop Virtualization Application Group Contributor`) over the broad `Desktop Virtualization Contributor` for day-to-day operations.

## Related Resources

- [Virtual Machines](./virtual-machines.md) — Session host VMs
- [Virtual Machine Scale Sets](./virtual-machine-scale-sets.md) — Pooled session hosts using VMSS
- [Azure Storage Account](./azure-storage-account.md) — FSLogix profile storage
- [Spoke Virtual Network](./spoke-virtual-network.md) — Session host networking
- [Network Security Groups](./network-security-groups.md) — Session host network access control
