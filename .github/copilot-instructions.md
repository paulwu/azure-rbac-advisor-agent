# GitHub Copilot Instructions — Azure Landing Zone RBAC Reference

These instructions govern how GitHub Copilot should create, modify, and extend files in the `resources/` directory of this repository.

---

## Purpose of This Repository

This repository is an **Azure RBAC least-privilege reference** for four Azure Landing Zone archetypes. Every file documents the minimum Azure built-in roles required to Create, Edit, Delete, and Configure each Azure resource, with granular sub-resource breakdowns where applicable (e.g., Blob vs. File vs. Queue vs. Table for Azure Storage).

---

## Authoritative Sources

All RBAC role names, permission actions, and role descriptions **must** be drawn from the following official Microsoft sources. Never invent role names or permission strings.

| Source | URL | What It Covers |
|---|---|---|
| **Azure built-in roles** | https://learn.microsoft.com/azure/role-based-access-control/built-in-roles | Canonical list of all built-in role names, IDs, and included actions |
| **Azure RBAC best practices** | https://learn.microsoft.com/azure/role-based-access-control/best-practices | Least-privilege guidance, scope recommendations |
| **Azure resource provider operations** | https://learn.microsoft.com/azure/role-based-access-control/resource-provider-operations | Full `Microsoft.*/*/action` permission strings per provider |
| **Cloud Adoption Framework — Landing Zones** | https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/ | Landing zone archetype definitions (Platform, Workload, Data, AI) |
| **Per-service RBAC documentation** | Each service's own "Authenticate and authorize" or "Security" doc page (linked in each resource file's Documentation row) | Service-specific roles and data plane access models |

> **Rule**: If a role name cannot be verified in the Azure built-in roles list above, it must **not** be included. Note it as requiring a custom role with a justification comment instead.

---

## Directory Structure

```
resources/
├── README.md                          ← Overview and general principles
├── platform-landing-zone/             ← Shared connectivity, governance, management (Platform team)
├── workload-landing-zone/             ← Application infrastructure (App/Dev team)
├── data-landing-zone/                 ← Data ingestion, processing, storage (Data Engineering team)
└── ai-landing-zone/                   ← ML, GenAI, Cognitive services (AI/Data Science team)
```

**One file per Azure resource.** File names are lowercase kebab-case matching the resource's common name (e.g., `azure-key-vault.md`, `azure-storage-account.md`).

---

## Mandatory File Structure

Every resource file **must** contain all of the following sections in this exact order:

### 1. H1 Title
```markdown
# Azure [Resource Display Name]
```

### 2. Resource Metadata Table
```markdown
## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.XXX` |
| **Resource Type** | `Microsoft.XXX/resourceType` |
| **Azure Portal Category** | Category > Sub-category |
| **Landing Zone Context** | [Platform / Workload / Data / AI] Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/...) |
| **Pricing** | [Pricing Page](https://azure.microsoft.com/pricing/details/...) |
| **SLA** | [X.XX%](https://azure.microsoft.com/support/legal/sla/...) |
```

- `Resource Provider` and `Resource Type` must use the exact ARM namespace (e.g., `Microsoft.Storage/storageAccounts`).
- If a resource has multiple relevant resource types (e.g., parent + child), list the primary type and mention others in the Overview.
- The Documentation link must point to the Microsoft Learn overview page for that specific service.

### 3. Overview
```markdown
## Overview

[2–4 sentence description of what the resource does and its specific role within the named landing zone context.]
```

### 4. Least-Privilege RBAC Reference

Opening note:
```markdown
## Least-Privilege RBAC Reference

> [One sentence describing the key role-separation concept for this resource, e.g., management plane vs. data plane split.]
```

Then four sub-sections using the exact emoji + heading format:

```markdown
### 🟢 Create
### 🟡 Edit / Update
### 🔴 Delete
### ⚙️ Configure
```

Each section contains a table with these exact columns:

```markdown
| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
```

- **Operation**: Plain-language description of what is being done (e.g., "Create a blob container").
- **Scope**: The Azure scope level at which the role must be assigned — one of: `Tenant Root`, `Management Group`, `Subscription`, `Resource Group`, `[Resource Name]` (specific resource), or a combination.
- **Least-Privileged Role**: Backtick-quoted exact built-in role name (e.g., `` `Storage Blob Data Contributor` ``). If multiple roles are required, list all with ` + ` separator. If no built-in role exists, write `Custom role required` with an explanation in Notes.
- **Notes**: Important caveats — prerequisites, combinations, irreversible actions, managed identity patterns, etc.

### 5. Sub-Resource Permissions (conditional)

Include this section **only** when a resource has distinct sub-resource types with different permission models. Use H2 for the main section and H3 for each sub-resource:

```markdown
## [Sub-Resource Name] Permissions

### 🟢 Create ([Sub-Resource])
### 🟡 Edit / Update ([Sub-Resource])
### 🔴 Delete ([Sub-Resource])
### ⚙️ Configure ([Sub-Resource])
```

Required for: Azure Storage Account (Blob, File, Queue, Table), Azure Key Vault (Secrets, Keys, Certificates), Azure Kubernetes Service (Azure RBAC layer + Kubernetes RBAC layer), Azure Synapse Analytics (Azure RBAC + Synapse RBAC).

For **summary tables** within sub-resource sections use this format:
```markdown
## [Sub-Resource] Role Summary

| Role | [Capability A] | [Capability B] | [Capability C] |
|---|---|---|---|
| `Role Name` | ✅ | ❌ | ✅ |
```

### 6. Notes / Considerations
```markdown
## Notes / Considerations

- Bullet-point list of important caveats, gotchas, and best practices.
- Always include a note on Managed Identity as the preferred auth pattern where applicable.
- Always include a note on disabling key/credential-based auth where Entra ID data-plane roles exist.
- Include scope guidance (avoid broad assignments).
```

### 7. Related Resources
```markdown
## Related Resources

- [Display Name](./relative-path.md) — One-line explanation of the relationship
```

Use relative paths. Cross-landing-zone links must use `../landing-zone-dir/file.md` format.

---

## RBAC Content Rules

### Role Name Accuracy
- Copy role names **exactly** as they appear in the [Azure built-in roles list](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles).
- Do not abbreviate, paraphrase, or combine role names (e.g., `Storage Blob Data Contributor` not "Blob Contributor").
- Roles in tables must always be wrapped in backticks: `` `Role Name` ``.

### Scope Accuracy
- Use the narrowest correct scope. Do not default to Subscription when Resource Group or resource-level works.
- When a role must be assigned on multiple resources, list all (e.g., `Key Vault + Storage Account`).

### Management Plane vs. Data Plane Separation
- Always explicitly separate management plane operations (ARM-level: create/configure the resource) from data plane operations (service API level: access data inside the resource).
- This separation is mandatory for: Storage, Key Vault, Cosmos DB, Event Hubs, Service Bus, SQL Database, Synapse, AI Services, OpenAI, AI Search.
- Include a callout note when these planes are split.

### Custom Roles
- If no built-in role satisfies least privilege, write `Custom role required` in the Role column.
- Add a Notes entry explaining which permission actions the custom role needs (using `Microsoft.XXX/YYY/action` format from the resource provider operations reference).

### Deprecated / Preview Roles
- If a role is in preview, note it: `` `Role Name` *(preview)* ``.
- Do not use deprecated roles (e.g., classic administrator roles). Note if only a deprecated path exists.

---

## Style and Formatting Rules

- **Markdown only** — no HTML.
- Tables use `|---|---|` column separators (no padding alignment).
- Section headings: H1 for title, H2 for major sections, H3 for sub-sections. No H4 or deeper.
- Emoji prefixes on operation sections (`🟢`, `🟡`, `🔴`, `⚙️`) are mandatory — do not substitute or remove them.
- Code blocks for CLI examples use ` ```bash ` fencing.
- ARM resource types in backticks: `` `Microsoft.Storage/storageAccounts` ``.
- Role names in backticks everywhere they appear (tables, prose, bullet lists).
- Links: Use descriptive anchor text, never raw URLs in prose.
- Avoid filler phrases ("it is worth noting that", "please be aware"). Be direct.
- Maximum line length is not enforced (markdown files).

---

## When Adding a New Resource File

1. Determine the correct landing zone directory based on the resource's primary ownership context:
   - `platform-landing-zone/` — Shared platform services (networking hub, governance, observability)
   - `workload-landing-zone/` — Application-tier services (compute, app PaaS, databases, containers)
   - `data-landing-zone/` — Data ingestion, processing, and governance services
   - `ai-landing-zone/` — ML, GenAI, Cognitive, and AI platform services
2. Name the file `<azure-resource-name>.md` in lowercase kebab-case.
3. Follow the mandatory file structure above in full — all 7 sections required.
4. Verify every role name against the [Azure built-in roles reference](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles) before including it.
5. Add a `Related Resources` entry in any existing files that logically connect to the new resource.
6. Update `resources/README.md` if a new landing zone directory is created.

---

## When Modifying an Existing Resource File

- Do not remove or rename any of the 7 mandatory sections.
- Do not change the emoji prefix on operation sub-sections.
- When a new built-in role becomes available that is more specific than the current one, update the role and add a note explaining the change.
- When Microsoft renames a service or role, update the H1 title, metadata table, and all role references consistently.
- Preserve all existing `Related Resources` links; add new ones but do not remove valid existing ones.

---

## What Copilot Should NOT Do

- ❌ Invent role names not present in the Azure built-in roles list.
- ❌ Use `Owner` or `Contributor` as the answer when a narrower purpose-built role exists.
- ❌ Omit the management plane vs. data plane distinction for services where it applies.
- ❌ Add sections not defined in the mandatory structure without noting them as extensions.
- ❌ Use H4 (`####`) or deeper heading levels.
- ❌ Store credentials, keys, connection strings, or subscription IDs in any file.
- ❌ Reference internal Microsoft documentation that is not publicly accessible.
- ❌ Recommend disabling security features (soft-delete, purge protection, private endpoints) for convenience.
