# Foundry IQ (Microsoft Foundry)

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.CognitiveServices` (Foundry resource) · `Microsoft.Search` (knowledge base infrastructure) |
| **Resource Type** | `Microsoft.CognitiveServices/accounts` (kind: Foundry) |
| **Azure Portal Category** | AI + Machine Learning > Microsoft Foundry |
| **Landing Zone Context** | AI Landing Zone |
| **Preview Status** | ⚠️ **Public Preview** — no SLA; not recommended for production workloads without acceptance of preview terms |
| **Announced** | Microsoft Ignite 2025 |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/what-is-foundry-iq) |
| **Pricing** | Billed by underlying services (Azure AI Search, Storage, Foundry consumption) |
| **SLA** | None (Public Preview) |

## Overview

Foundry IQ is a managed knowledge layer for enterprise AI agents within **Microsoft Foundry**, unveiled at Microsoft Ignite 2025. It connects AI agents to a permission-aware, multi-source knowledge base — spanning Azure Blob Storage, SharePoint, OneLake, and the public web — using **agentic retrieval** built on Azure AI Search. Rather than relying on a single static index, Foundry IQ uses AI Search's agentic retrieval capability to dynamically compose and retrieve the most relevant knowledge at agent query time.

Foundry IQ is currently in **public preview** with no SLA guarantee. In an AI Landing Zone, it serves as the retrieval intelligence layer that connects Foundry-hosted agents to governed, enterprise-wide data sources. Permissions are enforced at query time via **Microsoft Entra ID** (data plane), and **Microsoft Purview sensitivity labels** are honored at retrieval time to prevent over-disclosure of classified content.

## Foundry IQ Architecture Model

```
AI Landing Zone Subscription
└── Foundry Account (Microsoft.CognitiveServices/accounts, kind: Foundry)
    ├── Connected Resources: AI Search, Storage, Key Vault
    ├── Foundry Project A
    │   └── Foundry IQ Knowledge Base
    │       ├── Data Source: Azure Blob Storage
    │       ├── Data Source: SharePoint / OneLake
    │       └── Retrieval Engine: Azure AI Search (agentic retrieval)
    └── Foundry Project B
        └── Foundry IQ Knowledge Base
```

**RBAC is enforced at two scopes:**
- **Foundry resource scope** — account-level administration (models, capacity, resource-level connections)
- **Foundry project scope** — knowledge base creation, data source configuration, and agent query access

## Least-Privilege RBAC Reference

> Foundry IQ RBAC separates **management plane** (Foundry resource and project administration) from **data plane** (knowledge base queries and agent execution). Assign the minimum Foundry role at the appropriate scope (resource vs. project), and grant additional roles on connected resources (AI Search, Blob Storage, Key Vault) to the Foundry project's managed identity.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create Foundry Account (resource provisioning) | Resource Group | `Contributor` | Creates the Foundry account and linked infrastructure. No narrower built-in role is available for `Microsoft.CognitiveServices/accounts` provisioning. |
| Create a Foundry IQ knowledge base | Foundry Project | `Azure AI Project Manager` | Minimum project-scoped role to create and configure Foundry IQ knowledge bases. |
| Connect a data source (Blob, SharePoint, OneLake, web) | Foundry Project | `Azure AI Project Manager` | Data source connections are configured at the project level. The Foundry project's managed identity also requires roles on the connected data source (see managed identity table below). |
| Connect Azure AI Search as retrieval backend | Foundry Project + Search Service | `Azure AI Project Manager` (Project) + `Search Index Data Contributor` (Search Service) | Agentic retrieval requires the Foundry project's managed identity to create and manage indexes on the AI Search service. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Update knowledge base data sources | Foundry Project | `Azure AI Project Manager` | Modify which sources (Blob, SharePoint, OneLake, web) are included in the knowledge base. |
| Update agentic retrieval settings | Foundry Project | `Azure AI Project Manager` | Tune retrieval parameters (chunking strategy, embedding configuration, ranking). |
| Update Foundry resource network settings | Foundry Resource | `Azure AI Account Owner` | Resource-level network and capacity configuration. |
| Update project-level settings | Foundry Project | `Azure AI Project Manager` | |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a Foundry IQ knowledge base | Foundry Project | `Azure AI Project Manager` | Removes the knowledge base configuration. Does not automatically delete the underlying AI Search index. |
| Delete a Foundry Project | Foundry Resource | `Azure AI Account Owner` | Removes the project and all associated Foundry IQ knowledge bases. |
| Delete the Foundry Account | Resource Group | `Contributor` | Deletes the Foundry resource and all projects and knowledge bases within it. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Use Foundry IQ in agent workflows (query knowledge base) | Foundry Project | `Azure AI User` | Minimum role for AI agent developers to build with and query Foundry IQ knowledge bases. Data-plane access is enforced via Entra ID at query time. |
| Create and manage knowledge bases and data sources | Foundry Project | `Azure AI Project Manager` | Full project-level knowledge base lifecycle management. |
| Manage resource-level settings (models, capacity, connections) | Foundry Resource | `Azure AI Account Owner` | Resource-scope administration including shared connections and model configuration. |
| Full ownership and role assignment | Foundry Resource | `Azure AI Owner` | Includes the ability to assign roles on the Foundry resource to other principals. |
| Configure Private Endpoint for Foundry resource | Foundry Resource + VNet | `Contributor` + `Network Contributor` | Restricts Foundry API access to the private network. |
| Configure Diagnostic Settings | Foundry Resource or Project | `Monitoring Contributor` | Sends retrieval operation logs and query traces to Log Analytics. |

## Foundry IQ Role Summary

| Role | Query Knowledge Bases | Create / Manage Knowledge Bases | Manage Foundry Projects | Resource-Level Admin | Assign Roles |
|---|---|---|---|---|---|
| `Azure AI Owner` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `Azure AI Account Owner` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `Azure AI Project Manager` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `Azure AI User` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `Reader` | ❌ | ❌ | ❌ | ❌ | ❌ |

## Foundry Project Managed Identity — Required Roles on Connected Resources

| Connected Resource | Role Required | Purpose |
|---|---|---|
| Azure AI Search | `Search Index Data Contributor` | Create and manage agentic retrieval indexes; read and write index documents at runtime. |
| Azure Blob Storage | `Storage Blob Data Contributor` | Read documents from connected Blob Storage data sources during knowledge base ingestion and retrieval. |
| Azure Key Vault | `Key Vault Secrets User` | Read connection secrets (data source credentials, service endpoint keys) stored in Key Vault. |

## Runtime Dependencies

| Dependency | Resource Type | Purpose | Required / Optional |
|---|---|---|---|
| [Azure AI Search](./azure-ai-search.md) | `Microsoft.Search/searchServices` | Provides the agentic retrieval infrastructure for Foundry IQ knowledge bases. The Foundry project's managed identity requires `Search Index Data Contributor` to create and manage retrieval indexes at runtime. | Required |
| [Azure AI Foundry](./azure-ai-foundry.md) | `Microsoft.CognitiveServices/accounts` | Parent Foundry resource hosting the projects and managed identity under which Foundry IQ knowledge bases operate. Foundry IQ is a feature within a Foundry project, not a standalone resource. | Required |
| [Azure Storage Account](../workload-landing-zone/azure-storage-account.md) | `Microsoft.Storage/storageAccounts` | Source of documents for Blob Storage–connected knowledge base data sources. The Foundry project's managed identity requires `Storage Blob Data Contributor` to read source content during ingestion and retrieval. | Optional (required for Blob data sources) |
| [Azure Key Vault](../workload-landing-zone/azure-key-vault.md) | `Microsoft.KeyVault/vaults` | Stores connection secrets for data sources and service connections. The Foundry project's managed identity requires `Key Vault Secrets User` to read secrets at runtime. | Optional (required if secrets stored in Key Vault) |
| [Log Analytics Workspace](../platform-landing-zone/log-analytics-workspace.md) | `Microsoft.OperationalInsights/workspaces` | Receives diagnostic logs (retrieval operations, query traces, latency metrics) via Diagnostic Settings for monitoring and troubleshooting. | Optional (strongly recommended) |
| [Spoke Virtual Network](../workload-landing-zone/spoke-virtual-network.md) | `Microsoft.Network/virtualNetworks` | Provides Private Endpoint connectivity for the Foundry resource and AI Search service in isolated enterprise network environments. | Optional (strongly recommended) |
| [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) | `Microsoft.Network/privateDnsZones` | Resolves private endpoint hostnames for the Foundry resource and AI Search service connections. | Required (if Private Endpoint enabled) |

## Notes / Considerations

- **Public Preview status**: Foundry IQ was announced at Microsoft Ignite 2025 and is currently in public preview with **no SLA**. Built-in role names, capabilities, and RBAC behavior may change before general availability. Verify current role availability in your subscription before deployment.
- **`Azure AI User`** is the minimum role for agent developers to query and build with Foundry IQ knowledge bases — never assign `Contributor` or `Owner` to application or agent identities for data-plane access.
- **`Azure AI Project Manager`** is the minimum role for knowledge base lifecycle management — creating knowledge bases, connecting data sources, and configuring agentic retrieval settings.
- **Entra ID enforcement**: All data-plane operations (knowledge base queries executed by AI agents) are enforced via **Microsoft Entra ID** at query time. Disable local/key-based authentication in production environments.
- **Microsoft Purview sensitivity labels**: Foundry IQ honors Purview sensitivity labels at retrieval time. Documents bearing restricted or confidential sensitivity labels are filtered from agent responses for principals without the appropriate clearance. Ensure Microsoft Purview labeling policies are consistently applied across all connected data sources (Blob, SharePoint, OneLake) before connecting them to Foundry IQ.
- **Dual resource provider**: Foundry IQ spans two resource providers — `Microsoft.CognitiveServices` (Foundry account and project) and `Microsoft.Search` (agentic retrieval infrastructure). RBAC assignments are needed on **both** resource types; configuring only the Foundry side will prevent knowledge base ingestion and retrieval from functioning.
- **`Search Index Data Contributor` — not Reader**: The Foundry project's managed identity requires `Search Index Data Contributor` on the AI Search service, **not** `Search Index Data Reader`. Agentic retrieval creates and manages index structures dynamically at runtime — read-only access is insufficient.
- **Scope discipline**: Assign Foundry IQ roles at the **project scope** wherever possible. Avoid granting broad roles at the Foundry resource scope unless resource-level administration is explicitly required — this limits the blast radius of any compromised principal.
- **SharePoint and OneLake data sources**: RBAC for SharePoint (Microsoft 365) and OneLake (Microsoft Fabric) data sources is governed by their respective permission models — Microsoft Entra / Microsoft Graph permissions for SharePoint, and Fabric workspace roles for OneLake. These are **not** controlled by Azure RBAC. Consult those platforms' access control documentation for least-privilege configurations on those sources.
- **Residual AI Search indexes**: Deleting a Foundry IQ knowledge base removes the project-level configuration but does **not** automatically delete the underlying Azure AI Search index. Clean up orphaned indexes manually using `Search Index Data Contributor` on the AI Search service to avoid ongoing storage and cost.

## Related Resources

- [Azure AI Foundry](./azure-ai-foundry.md) — Parent Foundry platform hosting the projects within which Foundry IQ knowledge bases operate
- [Azure AI Search](./azure-ai-search.md) — Agentic retrieval infrastructure powering Foundry IQ knowledge base indexing and query
- [Azure OpenAI](./azure-openai.md) — LLM model serving for AI agents that use Foundry IQ as their knowledge retrieval layer
- [Azure Storage Account](../workload-landing-zone/azure-storage-account.md) — Blob Storage data source for Foundry IQ knowledge bases
- [Azure Key Vault](../workload-landing-zone/azure-key-vault.md) — Storing data source connection secrets for Foundry projects
- [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) — Private endpoint resolution for Foundry and AI Search service connections
