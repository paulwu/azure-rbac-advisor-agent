# Azure HDInsight

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.HDInsight` |
| **Resource Type** | `Microsoft.HDInsight/clusters` |
| **Azure Portal Category** | Analytics > HDInsight clusters |
| **Landing Zone Context** | Data Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/hdinsight/hdinsight-overview) |
| **Pricing** | [HDInsight Pricing](https://azure.microsoft.com/pricing/details/hdinsight/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/hdinsight/) |

## Overview

Azure HDInsight is a managed open-source analytics service for running Apache Hadoop, Spark, Hive, Kafka, and HBase clusters. In a Data Landing Zone, HDInsight provides big-data processing for batch ETL, interactive queries, and streaming workloads. HDInsight clusters are provisioned as multi-node deployments with configurable head, worker, and edge nodes.

## Least-Privilege RBAC Reference

> HDInsight has a purpose-built `HDInsight Cluster Operator` role for cluster runtime operations. Management-plane operations (create, delete, scale) require `Contributor` as no narrower management role exists.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create an HDInsight cluster | Resource Group | `Contributor` | No purpose-built management role for cluster creation. Scope `Contributor` to the resource group. |
| Create a cluster with ESP (Enterprise Security Package) | Resource Group | `Contributor` + `HDInsight Domain Services Contributor` | ESP clusters integrate with Entra Domain Services for Kerberos authentication. |
| Create a cluster with VNet integration | Resource Group + VNet | `Contributor` + `Network Contributor` | Requires NSG and UDR configuration on the HDInsight subnet. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Scale worker nodes (manual) | Cluster resource | `HDInsight Cluster Operator` | Cluster operator can change worker node count without full contributor access. |
| Configure autoscale | Cluster resource | `HDInsight Cluster Operator` | Load-based or schedule-based autoscaling. |
| Modify cluster configuration (Ambari settings) | Cluster resource | `HDInsight Cluster Operator` | Changes to Hadoop/Spark/Hive configuration via Ambari. |
| Run script actions on nodes | Cluster resource | `HDInsight Cluster Operator` | Install libraries, modify node configuration. |
| Update tags | Cluster resource | `Tag Contributor` | Tag-only changes. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete an HDInsight cluster | Resource Group | `Contributor` | `HDInsight Cluster Operator` cannot delete clusters. All ephemeral data on local node disks is lost; data in linked Storage persists. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| View cluster status and Ambari dashboard | Cluster resource | `Reader` | Ambari portal access requires cluster HTTP credentials separately. |
| Configure Diagnostic Settings | Cluster resource | `Monitoring Contributor` | Sends cluster metrics and logs to Log Analytics. |
| Manage cluster HTTP (Ambari) credentials | Cluster resource | `HDInsight Cluster Operator` | |
| Manage cluster SSH credentials | Cluster resource | `HDInsight Cluster Operator` | |
| Configure NSG rules for HDInsight management IPs | NSG resource | `Network Contributor` | HDInsight requires specific inbound rules for cluster management traffic. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Azure Data Lake Storage Gen2](./azure-data-lake-storage-gen2.md) | `Microsoft.Storage/storageAccounts` | Primary storage for cluster data (HDFS-compatible); the cluster's managed identity requires `Storage Blob Data Contributor` on the storage account. | Required |
| [Azure Storage Account](../workload-landing-zone/azure-storage-account.md) | `Microsoft.Storage/storageAccounts` | Alternative primary storage (WASB) or additional linked storage; `Storage Blob Data Contributor` is required. | Optional (alternative to ADLS Gen2) |
| [Spoke Virtual Network](../workload-landing-zone/spoke-virtual-network.md) | `Microsoft.Network/virtualNetworks` | HDInsight cluster nodes are deployed into a subnet within a VNet for network isolation. | Optional (strongly recommended) |
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives HDInsight cluster diagnostic logs (Ambari metrics, YARN logs, Spark event logs) via Azure Monitor integration. | Optional (strongly recommended) |
| [Azure Key Vault](../workload-landing-zone/azure-key-vault.md) | `Microsoft.KeyVault/vaults` | Stores cluster encryption keys (Customer-Managed Key for disk encryption) and ESP Kerberos credentials; the cluster's managed identity requires `Key Vault Crypto Service Encryption User`. | Optional (required for CMK/ESP) |

## Notes / Considerations

- **`HDInsight Cluster Operator`** is the purpose-built role for day-to-day cluster operations — prefer it over `Contributor` for scaling, configuration, and script actions.
- **`HDInsight Domain Services Contributor`** is required only for ESP (Enterprise Security Package) clusters that integrate with Entra Domain Services for Kerberos-based authentication.
- **Cluster deletion** requires `Contributor`; `HDInsight Cluster Operator` intentionally cannot delete clusters to prevent accidental data loss.
- **Storage access**: Cluster identity needs `Storage Blob Data Contributor` on the primary storage account. Use managed identity (recommended) instead of storage access keys.
- **Network requirements**: HDInsight has specific NSG rule requirements for management traffic — use the [HDInsight management IP addresses](https://learn.microsoft.com/azure/hdinsight/hdinsight-management-ip-addresses) documentation for rule configuration.
- **Consider Azure Databricks** or **HDInsight on AKS** for new Spark workloads — they offer faster provisioning and lower operational overhead.

## Related Resources

- [Azure Data Lake Storage Gen2](./azure-data-lake-storage-gen2.md) — Primary cluster storage
- [Azure Databricks](./azure-databricks.md) — Alternative managed Spark service
- [Azure Event Hubs](./azure-event-hubs.md) — Streaming data source for Spark Structured Streaming / Kafka
- [Azure Data Factory](./azure-data-factory.md) — Orchestrates HDInsight activities
