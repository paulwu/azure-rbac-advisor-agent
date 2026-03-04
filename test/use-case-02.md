# Use Case 02: Agentic AI Workload — Microsoft Foundry + AI Foundry Hub with Private Endpoint Network Isolation (16 Resources)

## Section 1 — Prompt

I want to create an Agentic AI Workload in Azure with the following resources. Show me the roles I need:
Application Insights
Azure AI Search
Azure AI Services
Azure Cosmos DB
Azure DNS Private Resolver
Azure Key Vault
Azure Open AI Service
Azure Storage Account
Document Intelligence
Foundry IQ
Foundry Project
Log Analytics Workspace
Microsoft AI Foundry
Private DNS Zone
Private endpoint
Virtual Network

## Section 2 — Expected Output

This scenario covers an **Agentic AI workload** built on **Microsoft Foundry** (Foundry Account + Foundry IQ knowledge layer) and **Azure AI Foundry** (Hub + Project), grounded in enterprise data via **Azure AI Search** and **Azure Storage**, with document intake via **Document Intelligence**, multi-modal AI capabilities via **Azure AI Services**, model serving via **Azure OpenAI**, agent state and memory persistence via **Azure Cosmos DB**, secrets management via **Azure Key Vault**, observability via **Application Insights** and a dedicated **Log Analytics Workspace**, DNS forwarding via **Azure DNS Private Resolver**, and full **Private Endpoint** network isolation across all services using a **Spoke Virtual Network** and **Private DNS Zones**.

RBAC is structured across four identity types:
- **AI Developer** — builds agents, authors prompt flows, queries Foundry IQ
- **AI Platform Admin** — manages Foundry Hub/resource, network, monitoring, and connected service configuration
- **Foundry Project Managed Identity** — runtime access to connected resources (data plane)
- **CI/CD Service Principal** — optional deployment identity for infrastructure and model promotion pipelines

---

## Consolidated Role Assignment Table

### All Resources × All Personas

| Resource | Identity / Persona | Least-Privileged Role | Scope | Plane | Notes |
|---|---|---|---|---|---|
| **Microsoft AI Foundry (Hub)** | AI Platform Admin | `Azure AI Administrator` | AI Foundry Hub | Management + Data | Hub-level admin: manages connections, projects, and network config. |
| **Microsoft AI Foundry (Hub)** | AI Developer | `Azure AI Developer` | AI Foundry Hub | Data | Create projects, author prompt flows, deploy models within the hub. |
| **Microsoft AI Foundry (Hub)** | CI/CD Service Principal | `Contributor` | Resource Group | Management | Required to provision the Hub resource and link Storage, Key Vault, ACR, App Insights. No narrower built-in role available for Hub creation. |
| **Foundry Project** | AI Developer | `Azure AI Developer` | Foundry Project | Data | Modify project settings, update model deployments, update prompt flows. |
| **Foundry Project** | AI Developer (inference only) | `Azure AI User` | Foundry Project | Data | Minimum role to invoke deployed model endpoints within a project. |
| **Foundry Project** | CI/CD Service Principal | `Azure AI Developer` | AI Foundry Hub | Data | Projects are created from hub scope; `Azure AI Developer` on the hub grants project creation rights. |
| **Foundry IQ** | AI Platform Admin | `Azure AI Account Owner` | Foundry Resource | Management + Data | Resource-level administration: shared connections, model config, capacity. |
| **Foundry IQ** | AI Developer (KB management) | `Azure AI Project Manager` | Foundry Project | Data | Create and manage knowledge bases, connect data sources, configure agentic retrieval. ⚠️ Public Preview. |
| **Foundry IQ** | AI Developer (query only) | `Azure AI User` | Foundry Project | Data | Minimum role for building with and querying Foundry IQ knowledge bases. Data-plane enforced via Entra ID. |
| **Foundry IQ** | CI/CD Service Principal | `Contributor` | Resource Group | Management | Required to provision the Foundry Account (`Microsoft.CognitiveServices/accounts` kind: Foundry). No narrower role available. |
| **Azure OpenAI Service** | AI Platform Admin | `Cognitive Services Contributor` | OpenAI Resource | Management | Deploy models, configure resource network settings, manage content filters. |
| **Azure OpenAI Service** | AI Developer | `Cognitive Services OpenAI Contributor` | OpenAI Resource | Data | Deploy and test models, manage fine-tuning jobs via Azure OpenAI Studio. |
| **Azure OpenAI Service** | Foundry Project Managed Identity | `Cognitive Services OpenAI User` | OpenAI Resource | Data | Minimum role for application inference (chat, completions, embeddings). |
| **Azure OpenAI Service** | CI/CD Service Principal | `Cognitive Services Contributor` | Resource Group | Management | Provision the OpenAI resource and connect it to the AI Foundry Hub. |
| **Azure AI Search** | AI Platform Admin | `Search Service Contributor` | Search Service | Management | Manage service capacity, network rules, and private endpoint configuration. |
| **Azure AI Search** | AI Developer | `Search Index Data Contributor` | Search Service | Data | Create, update, and manage indexes, indexers, skillsets, and data sources. |
| **Azure AI Search** | Foundry Project Managed Identity | `Search Index Data Contributor` | Search Service | Data | Agentic retrieval (Foundry IQ) creates and manages index structures dynamically — `Search Index Data Reader` is **insufficient** for runtime. |
| **Azure AI Search** | CI/CD Service Principal | `Search Service Contributor` | Resource Group | Management | Provision the Search service and connect it to the AI Foundry Hub. |
| **Azure AI Services** | AI Platform Admin | `Cognitive Services Contributor` | AI Services Resource | Management | Deploy multi-service endpoint, configure network settings, manage content filtering and API configuration. |
| **Azure AI Services** | AI Developer | `Cognitive Services User` | AI Services Resource | Data | Call multi-modal APIs (Vision, Language, Speech, Translator, Content Safety, etc.) during development. |
| **Azure AI Services** | Foundry Project Managed Identity | `Cognitive Services User` | AI Services Resource | Data | Runtime multi-modal API access for agentic pipelines (Vision, Language, Speech). |
| **Azure AI Services** | CI/CD Service Principal | `Cognitive Services Contributor` | Resource Group | Management | Provision the AI Services multi-service endpoint resource. Separate from Azure OpenAI provisioning. |
| **Azure Storage Account** | AI Platform Admin | `Storage Account Contributor` | Storage Account | Management | Manage account settings, network rules, lifecycle policies, and lifecycle management. |
| **Azure Storage Account** | AI Developer | `Storage Blob Data Contributor` | Storage Account / Container | Data | Read and write project data, prompt flow artifacts, and evaluation outputs. |
| **Azure Storage Account** | Foundry Project Managed Identity | `Storage Blob Data Contributor` | Storage Account / Container | Data | Read/write during Foundry IQ knowledge base ingestion and retrieval from Blob data sources. |
| **Azure Storage Account** | CI/CD Service Principal | `Storage Account Contributor` | Resource Group | Management | Provision the storage account linked to AI Foundry Hub. |
| **Azure Cosmos DB** | AI Platform Admin | `Cosmos DB Account Reader Role` | Cosmos DB Account | Management | Read-only view of account properties, throughput configuration, and region settings. |
| **Azure Cosmos DB** | AI Platform Admin | `DocumentDB Account Contributor` | Cosmos DB Account | Management | Provision account, create/modify databases and containers, configure network rules, manage throughput. |
| **Azure Cosmos DB** | AI Developer | `Cosmos DB Built-in Data Contributor` | Account / Database / Container | Data | Read and write documents for agent state, conversation history, and memory stores during development. |
| **Azure Cosmos DB** | Foundry Project Managed Identity | `Cosmos DB Built-in Data Contributor` | Container scope | Data | Runtime agent memory, conversation state, and vector store read/write. Assign at container scope for least privilege. |
| **Azure Cosmos DB** | CI/CD Service Principal | `DocumentDB Account Contributor` | Resource Group | Management | Provision the Cosmos DB account and configure databases and containers as part of IaC pipeline. |
| **Document Intelligence** | AI Platform Admin | `Cognitive Services Contributor` | Document Intelligence Resource | Management | Create resource, build custom models, configure network settings. |
| **Document Intelligence** | AI Developer | `Cognitive Services User` | Document Intelligence Resource | Data | Analyze documents using pre-built and custom models (invoice, layout, read, OCR). |
| **Document Intelligence** | Foundry Project Managed Identity | `Cognitive Services User` | Document Intelligence Resource | Data | Runtime document analysis for agentic AI pipeline document ingestion. |
| **Document Intelligence** | CI/CD Service Principal | `Cognitive Services Contributor` | Resource Group | Management | Provision the Document Intelligence resource. |
| **Application Insights** | AI Platform Admin | `Monitoring Contributor` | Resource Group / Resource | Management | Create and configure alert rules, diagnostic settings, availability tests, dashboards. |
| **Application Insights** | AI Developer | `Monitoring Reader` | Resource Group / Resource | Read | View telemetry, metrics, and alert states for application troubleshooting. |
| **Application Insights** | CI/CD Service Principal | `Monitoring Contributor` | Resource Group | Management | Provision Application Insights component and configure diagnostic settings on connected resources. |
| **Log Analytics Workspace** | AI Platform Admin | `Log Analytics Contributor` | Workspace | Management | Create workspace, configure data collection rules, manage agents, set retention and pricing tier. |
| **Log Analytics Workspace** | AI Developer | `Log Analytics Reader` | Workspace | Read | Query logs, view saved searches, and access telemetry for troubleshooting. |
| **Log Analytics Workspace** | Foundry Project Managed Identity | `Monitoring Metrics Publisher` | Workspace | Data | Publish custom metrics and agent telemetry from Foundry Project runtime to the workspace. |
| **Log Analytics Workspace** | CI/CD Service Principal | `Log Analytics Contributor` | Resource Group | Management | Provision the workspace and configure diagnostic settings on all connected resources. |
| **Azure Key Vault** | AI Platform Admin | `Key Vault Secrets Officer` | Key Vault | Data | Manage secrets lifecycle: create, update, rotate, and delete connection strings and API endpoint URLs. |
| **Azure Key Vault** | AI Platform Admin | `Key Vault Contributor` | Key Vault | Management | Create/configure vault, update network rules and firewall, enable diagnostic settings. |
| **Azure Key Vault** | AI Developer | `Key Vault Secrets User` | Key Vault | Data | Read-only access to secret values during development and testing (break-glass pattern). |
| **Azure Key Vault** | Foundry Project Managed Identity | `Key Vault Secrets User` | Key Vault | Data | Read connection secrets (data source credentials, service endpoint URLs) at runtime. |
| **Azure Key Vault** | CI/CD Service Principal | `Key Vault Secrets Officer` | Key Vault | Data | Deploy and rotate secrets in pipeline; provision connection strings for connected services. |
| **Virtual Network** | AI Platform Admin | `Network Contributor` | Spoke VNet / Resource Group | Management | Create subnets, configure private endpoints, assign NSGs and route tables, manage VNet peering. |
| **Virtual Network** | CI/CD Service Principal | `Network Contributor` | Resource Group | Management | Provision the spoke VNet, subnets, and initiate hub-side peering (platform team approves hub side). |
| **Azure DNS Private Resolver** | AI Platform Admin | `Network Contributor` | Resource Group / DNS Resolver Resource | Management | Create and manage inbound endpoints, outbound endpoints, and DNS forwarding rulesets for conditional DNS forwarding from on-premises to Azure Private DNS Zones. |
| **Azure DNS Private Resolver** | CI/CD Service Principal | `Network Contributor` | Resource Group | Management | Provision the DNS Private Resolver and configure forwarding rulesets as part of IaC pipeline. Typically owned by Platform team in the hub subscription. |
| **Private Endpoint** | AI Platform Admin | `Network Contributor` | Subnet + Target Resource | Management | Create and manage private endpoints (`Microsoft.Network/privateEndpoints/write`) for all AI services. |
| **Private Endpoint** | CI/CD Service Principal | `Network Contributor` | Resource Group | Management | Provision private endpoints as part of IaC deployment pipeline. |
| **Private DNS Zone** | AI Platform Admin | `Private DNS Zone Contributor` | Private DNS Zone Resource | Management | Create zones, VNet links, and DNS A-records for private endpoint hostname resolution. |
| **Private DNS Zone** | CI/CD Service Principal | `Private DNS Zone Contributor` | Private DNS Zone Resource | Management | Auto-register DNS A-records during private endpoint provisioning. |

---

## Foundry Project Managed Identity — Role Assignments on Connected Resources

The Foundry Project's system-assigned managed identity must be granted the following roles on each connected resource so that agents and Foundry IQ can operate at runtime:

| Connected Resource | Role | Scope | Purpose |
|---|---|---|---|
| Azure OpenAI Service | `Cognitive Services OpenAI User` | OpenAI Resource | Inference API calls (chat, completions, embeddings) for agent reasoning. |
| Azure AI Search | `Search Index Data Contributor` | Search Service | Create and manage agentic retrieval indexes; read and write index documents at runtime. `Search Index Data Reader` is **not sufficient** — Foundry IQ dynamically creates index structures. |
| Azure Storage Account | `Storage Blob Data Contributor` | Storage Account / Container | Read source documents during Foundry IQ knowledge base ingestion and retrieval from Blob data sources. |
| Azure AI Services | `Cognitive Services User` | AI Services Resource | Runtime multi-modal API access (Vision, Language, Speech, Translator) for agentic pipeline steps. |
| Azure Cosmos DB | `Cosmos DB Built-in Data Contributor` | Container scope | Read and write agent memory, conversation state, and vector store data at runtime. Assign at container scope for least privilege. |
| Document Intelligence | `Cognitive Services User` | Document Intelligence Resource | Analyze and extract content from documents fed into the agentic pipeline at runtime. |
| Azure Key Vault | `Key Vault Secrets User` | Key Vault | Read connection secrets (data source credentials, service endpoint URLs) stored in Key Vault. |
| Log Analytics Workspace | `Monitoring Metrics Publisher` | Workspace | Publish custom agent metrics and runtime telemetry to the Log Analytics Workspace. |

---

## Network Isolation — Private Endpoint + Private DNS Zone Setup

All services in this Agentic AI workload should be deployed with **public network access disabled** and accessed exclusively via **Azure Private Endpoints**. The following zones and roles are required:

### Private DNS Zones Required

| Azure Service | Private DNS Zone | Role to Manage Zone |
|---|---|---|
| Azure OpenAI Service | `privatelink.openai.azure.com` | `Private DNS Zone Contributor` |
| Azure AI Search | `privatelink.search.windows.net` | `Private DNS Zone Contributor` |
| Azure Storage (Blob) | `privatelink.blob.core.windows.net` | `Private DNS Zone Contributor` |
| Azure AI Services | `privatelink.cognitiveservices.azure.com` | `Private DNS Zone Contributor` |
| Azure Cosmos DB (NoSQL / SQL API) | `privatelink.documents.azure.com` | `Private DNS Zone Contributor` |
| Azure Key Vault | `privatelink.vaultcore.azure.net` | `Private DNS Zone Contributor` |
| Document Intelligence | `privatelink.cognitiveservices.azure.com` | `Private DNS Zone Contributor` |
| Azure AI Foundry / AML | `privatelink.api.azureml.ms` | `Private DNS Zone Contributor` |
| Log Analytics Workspace (OMS agent) | `privatelink.oms.opinsights.azure.com` | `Private DNS Zone Contributor` |
| Log Analytics Workspace (ODS ingest) | `privatelink.ods.opinsights.azure.com` | `Private DNS Zone Contributor` |
| Azure DNS Private Resolver | *(no dedicated privatelink zone)* — acts as a conditional DNS forwarder; resolves to the Private DNS Zones above | `Network Contributor` (for inbound/outbound endpoint configuration) |

> ⚠️ **Note on shared zones**: **Azure AI Services** and **Document Intelligence** share the `privatelink.cognitiveservices.azure.com` zone. When both are deployed in the same workload, use a single zone with separate A-records for each private endpoint.

### Network Roles Summary

| Operation | Role | Scope |
|---|---|---|
| Create / manage Spoke VNet and subnets | `Network Contributor` | Resource Group / Spoke VNet |
| Create Private Endpoints for AI services | `Network Contributor` | Subnet + Target Resource |
| Create / manage Private DNS Zones | `Private DNS Zone Contributor` | Private DNS Zone Resource |
| Create VNet Links (zone → VNet) | `Private DNS Zone Contributor` | Private DNS Zone Resource |
| Auto-register DNS A-records during PE provisioning | `Private DNS Zone Contributor` | Private DNS Zone Resource |
| Configure Private Endpoint on AI Foundry Hub | `Contributor` + `Network Contributor` | Hub Resource + VNet |
| Configure Private Endpoint on OpenAI resource | `Cognitive Services Contributor` + `Network Contributor` | OpenAI Resource + VNet |
| Configure Private Endpoint on AI Search | `Search Service Contributor` + `Network Contributor` | Search Service + VNet |
| Configure Private Endpoint on Azure AI Services | `Cognitive Services Contributor` + `Network Contributor` | AI Services Resource + VNet |
| Configure Private Endpoint on Azure Cosmos DB | `DocumentDB Account Contributor` + `Network Contributor` | Cosmos DB Account + VNet |
| Configure Private Endpoint on Key Vault | `Key Vault Contributor` + `Network Contributor` | Key Vault + VNet |
| Configure Private Endpoint on Log Analytics Workspace | `Log Analytics Contributor` + `Network Contributor` | Workspace + VNet |
| Deploy Azure DNS Private Resolver (inbound/outbound endpoints) | `Network Contributor` | Resource Group / DNS Resolver Resource |
| Configure DNS forwarding rulesets | `Network Contributor` | Resource Group / DNS Resolver Resource |

> 💡 In a Platform Landing Zone, Private DNS Zones are centrally managed in the hub subscription. Use **Azure Policy (`DeployIfNotExists`)** to auto-create DNS A-records when private endpoints are provisioned in spoke subscriptions — the policy managed identity needs `Private DNS Zone Contributor` on the centralized zones.

> 💡 **Azure DNS Private Resolver** is typically owned and operated by the **Platform team** in the hub subscription. It enables conditional DNS forwarding from on-premises networks to Azure Private DNS Zones. The spoke workload team should coordinate with the Platform team to add forwarding ruleset entries for new `privatelink.*` zones rather than deploying their own resolver.

---

## Key Points / Notes

- **Entra ID for all data-plane access**: Disable local/key-based authentication (`disableLocalAuth: true`) on Azure OpenAI, AI Search, Document Intelligence, Azure AI Services, and Key Vault. All application and managed identity access must use **Microsoft Entra ID token authentication**. Never embed API keys or connection strings in application code or container images.

- **No storage account keys or API keys in production**: The Foundry Project managed identity must use **Entra ID data-plane roles** (`Storage Blob Data Contributor`, `Cognitive Services OpenAI User`, `Search Index Data Contributor`) — not account keys or resource keys. Assign `Key Vault Secrets User` to managed identities for any secrets that must be stored in Key Vault.

- **Scope discipline — resource > resource group > subscription**: All role assignments should be scoped to the **specific resource** (e.g., the individual Key Vault, the specific Search Service) rather than the resource group or subscription. The only exceptions are management-plane provisioning roles for CI/CD (`Contributor` scoped to a dedicated resource group), which must be reviewed and time-bounded.

- **Foundry IQ requires `Search Index Data Contributor` — not `Search Index Data Reader`**: Foundry IQ's agentic retrieval dynamically creates and manages index structures on Azure AI Search at runtime. Assigning only `Search Index Data Reader` to the Foundry Project managed identity will cause knowledge base ingestion and retrieval to fail.

- **⚠️ Foundry IQ is Public Preview (announced Microsoft Ignite 2025)**: The `Azure AI Project Manager` and `Azure AI Account Owner` roles for Foundry IQ may change before GA. Built-in role names, capabilities, and RBAC behavior are subject to change. Verify role availability in your subscription before deployment and do not use Foundry IQ for SLA-dependent production workloads without acceptance of preview terms.

- **Management plane vs. data plane separation is critical for AI services**: `Cognitive Services Contributor` (management plane) does not grant inference access to Azure OpenAI, Azure AI Services, or Document Intelligence. Conversely, `Cognitive Services OpenAI User` and `Cognitive Services User` (data plane) do not allow model deployment or resource configuration. Assign both planes' roles only to the identities that genuinely require them — never combine them unnecessarily.

- **Azure AI Services vs. Azure OpenAI**: These are separate resources with separate RBAC roles. **Azure AI Services** (`Microsoft.CognitiveServices/accounts` kind: `AIServices` or `CognitiveServices`) covers the multi-service endpoint for Vision, Language, Speech, Translator, Content Safety, etc. **Azure OpenAI** (`Microsoft.CognitiveServices/accounts` kind: `OpenAI`) is a dedicated resource for LLM models with its own `Cognitive Services OpenAI User` / `Cognitive Services OpenAI Contributor` roles. Do not conflate the two — deploy them as separate resources and assign distinct roles.

- **Azure Cosmos DB: disable key-based auth, use Entra ID RBAC**: `DocumentDB Account Contributor` can list account keys, which grants equivalent full data-plane access without an audit trail — scope this role tightly to CI/CD only. For the Foundry Project managed identity and AI Developer data access, assign `Cosmos DB Built-in Data Contributor` (or `Cosmos DB Built-in Data Reader` for read-only agents) via ARM/CLI — **Cosmos DB data-plane RBAC roles are not assignable through the Azure portal** as of this writing. For read-only agents, use `Cosmos DB Built-in Data Reader` at container scope instead of `Cosmos DB Built-in Data Contributor`.

- **Log Analytics Workspace: Application Insights is backed by Log Analytics**: In workspace-based Application Insights (the current default), all telemetry is stored in the linked Log Analytics Workspace. `Log Analytics Contributor` on the workspace covers both Application Insights telemetry configuration and raw log access. Deploy a **dedicated workspace per workload** (rather than a shared platform workspace) to limit blast radius and enforce data isolation. The `Monitoring Metrics Publisher` role on the workspace is sufficient for managed identities that only need to publish custom metrics — do not over-provision `Log Analytics Contributor`.

- **Azure DNS Private Resolver: Platform team ownership**: The DNS Private Resolver is typically deployed in the **hub subscription** by the Platform team and shared across all spoke workloads. Spoke teams should not deploy their own resolver — instead, request that the Platform team add forwarding ruleset entries for the new `privatelink.*` zones required by the workload. All DNS resolver management uses `Network Contributor` — there is no separate data-plane RBAC for DNS query routing.

---

> 📄 Sources:
> - `resources/ai-landing-zone/azure-ai-foundry.md`
> - `resources/ai-landing-zone/foundry-iq.md`
> - `resources/ai-landing-zone/azure-openai.md`
> - `resources/ai-landing-zone/azure-ai-search.md`
> - `resources/ai-landing-zone/azure-ai-services.md`
> - `resources/ai-landing-zone/azure-ai-document-intelligence.md`
> - `resources/data-landing-zone/azure-cosmos-db.md`
> - `resources/workload-landing-zone/azure-storage-account.md`
> - `resources/workload-landing-zone/azure-key-vault.md`
> - `resources/platform-landing-zone/azure-key-vault.md`
> - `resources/platform-landing-zone/azure-monitor.md`
> - `resources/platform-landing-zone/log-analytics-workspace.md`
> - `resources/workload-landing-zone/spoke-virtual-network.md`
> - `resources/platform-landing-zone/private-dns-zones.md`
