## Kibana Essentials — Stack Management

### Overview

Stack Management is Kibana's centralized administration hub, covering configuration that spans data structure (index patterns/data views, index lifecycle policies), Kibana-level settings (advanced settings, spaces), content organization (saved objects, tags), and security/access control (roles, users, API keys) where security features are enabled. It's the equivalent of a control panel for both Kibana's own behavior and much of the Elasticsearch cluster configuration reachable through the UI rather than the Dev Tools Console.

### Section Overview

Stack Management is organized into several major groupings, though exact naming/grouping can vary slightly by version.

**Key Points**

- **Data** — Data Views, Index Management, Index Lifecycle Policies, Snapshot and Restore, Rollup Jobs, Transforms, Remote Clusters.
- **Alerts and Insights** — Rules, Connectors, Maintenance Windows (feeds Kibana's alerting framework).
- **Kibana** — Data Views, Saved Objects, Tags, Spaces, Advanced Settings, Reporting.
- **Stack** — Upgrade Assistant, License Management, API Keys, Role Mappings (in security-enabled deployments).

[Inference] The precise section groupings and naming shown in the left navigation have changed across Kibana versions, so the exact menu structure should be checked against the deployed version.

### Data Views

**Key Points**

- Central management screen for creating, editing, and deleting data views (index pattern definitions) used throughout Lens, Discover, Maps, and dashboards.
- Supports defining custom field formatters (e.g., displaying a numeric field as a percentage or a byte size), field-level custom labels, and runtime fields.
- Deleting a data view does not delete the underlying Elasticsearch index; it only removes Kibana's reference to it, though any saved visualizations depending on that data view will break until repointed.

### Index Management

**Key Points**

- Lists all indices, data streams, and index templates visible to the current user, with per-index stats (document count, size, health status).
- Supports common administrative actions directly in the UI: opening/closing an index, force-merging, refreshing, flushing, adding/removing aliases, and editing mappings/settings for existing indices (within what Elasticsearch allows without reindexing).
- Index templates and component templates can be created and edited here, defining default mappings/settings automatically applied to new indices matching a name pattern — particularly relevant for data streams.

### Index Lifecycle Management (ILM)

**Key Points**

- ILM policies define automated transitions of an index through phases: **Hot** (actively written/queried), **Warm** (read-only, less frequently accessed), **Cold** (rarely accessed, often on cheaper storage), **Frozen** (archival, minimal resource footprint), and **Delete**.
- Each phase can configure actions like rollover (creating a new backing index once a size/age/doc-count threshold is met), shrink, force-merge, and searchable snapshots.
- ILM policies are commonly attached to data streams via an index template, so that time-series data (like logs or metrics) automatically ages through phases without manual intervention.

### ILM Phase Transition Diagram

```mermaid
flowchart LR
    A[Hot: actively indexed and queried] --> B[Warm: read-only, reduced resources]
    B --> C[Cold: infrequent access, cheaper storage]
    C --> D[Frozen: archival, minimal footprint]
    D --> E[Delete: index removed per retention policy]
```

### Transforms

**Key Points**

- Transforms create a new, summarized index (or data view) from an existing index using pivot or latest aggregations, materializing aggregated data as its own searchable index rather than recomputing aggregations on every query.
- Useful for turning high-cardinality raw event data into pre-aggregated entity-centric indices (e.g., per-customer summary metrics) for faster dashboard queries.
- Transforms can run in **batch** mode (one-time) or **continuous** mode (incrementally updating as new source data arrives).

### Snapshot and Restore

**Key Points**

- Manages backup ("snapshot") and restore operations against a configured snapshot repository (e.g., a registered S3 bucket, shared filesystem, or other supported repository type).
- Snapshot Lifecycle Management (SLM) policies automate recurring snapshots on a schedule, with configurable retention.
- Restoring a snapshot can target the original indices or rename them, allowing point-in-time data recovery or cloning of a dataset into a new environment.

### Saved Objects

**Key Points**

- Saved Objects is the registry of nearly everything persisted in Kibana: dashboards, visualizations, data views, Canvas workpads, alerting rules, and more.
- Supports searching, inspecting relationships between objects (e.g., which dashboards use a given visualization), and bulk export/import as NDJSON files.
- Exporting saved objects is the standard mechanism for migrating Kibana content between environments (e.g., dev to production), alongside relationship-aware export that pulls in dependent objects automatically.

### Spaces

**Key Points**

- Spaces partition Kibana's saved objects and UI into isolated or semi-isolated sections, commonly used to separate content by team, business unit, or environment within a single Kibana instance.
- Each space can have its own set of enabled features (e.g., disabling Canvas in a space meant only for monitoring dashboards) and its own default route.
- Role-based access control can restrict which spaces a given user or role can access, and to what degree (read-only vs. full access) within each space.

### Advanced Settings

**Key Points**

- Exposes low-level Kibana configuration options not covered by dedicated UI screens, such as default data view, date formatting preferences, query language default (KQL vs. Lucene), and dark mode.
- Changes here are cluster/instance-wide (or space-wide, depending on the specific setting) rather than per-user, so changes should be made deliberately in shared environments.
- [Inference] Which settings are space-scoped versus global has evolved across Kibana versions, so behavior for a specific setting should be verified in the deployed version rather than assumed.

### Roles, Users, and API Keys

Relevant when Elasticsearch security features are enabled (the standard configuration in most modern deployments, including Elastic Cloud).

**Key Points**

- **Roles** define sets of privileges — cluster-level, index-level, and Kibana feature-level (e.g., access to specific spaces, apps, or saved object types).
- **Users** are assigned one or more roles, either created natively in Elasticsearch's internal user store or mapped in via an external authentication provider (LDAP, SAML, OIDC).
- **API keys** provide scoped, revocable programmatic access credentials, commonly used for scripts, ingest agents, and application integrations rather than sharing a user's own credentials.
- **Role mappings** connect external identity provider group/role claims to internal Elasticsearch roles when using SSO-based authentication.

### Upgrade Assistant

**Key Points**

- Scans the current cluster and Kibana configuration for deprecated settings, mappings, or APIs that will be removed or changed in the next major version.
- Surfaces actionable remediation steps (e.g., reindexing an index using a deprecated mapping type) before initiating an actual version upgrade.
- Running the Upgrade Assistant's checks ahead of a planned upgrade is a standard practice for reducing the risk of a failed or degraded upgrade.

### Stack Management Navigation Map

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 780 420">
\<style\>
.box { fill: #ffffff; stroke: #4a4a4a; stroke-width: 1.5; }
.title { font-family: sans-serif; font-size: 15px; fill: #1a1a1a; font-weight: bold; }
.label { font-family: sans-serif; font-size: 12px; fill: #1a1a1a; font-weight: bold; }
.item { font-family: sans-serif; font-size: 11px; fill: #333333; }
\</style\>
<text x="20" y="25" class="title">Stack Management Structure (svg_diagram)</text>
<rect x="20" y="45" width="230" height="150" class="box" rx="4" />
<text x="35" y="68" class="label">Data</text>
<text x="35" y="88" class="item">Data Views</text>
<text x="35" y="106" class="item">Index Management</text>
<text x="35" y="124" class="item">ILM Policies</text>
<text x="35" y="142" class="item">Transforms</text>
<text x="35" y="160" class="item">Snapshot and Restore</text>
<text x="35" y="178" class="item">Remote Clusters</text>
<rect x="270" y="45" width="230" height="110" class="box" rx="4" />
<text x="285" y="68" class="label">Kibana</text>
<text x="285" y="88" class="item">Saved Objects</text>
<text x="285" y="106" class="item">Spaces</text>
<text x="285" y="124" class="item">Advanced Settings</text>
<text x="285" y="142" class="item">Tags / Reporting</text>
<rect x="520" y="45" width="230" height="110" class="box" rx="4" />
<text x="535" y="68" class="label">Alerts and Insights</text>
<text x="535" y="88" class="item">Rules</text>
<text x="535" y="106" class="item">Connectors</text>
<text x="535" y="124" class="item">Maintenance Windows</text>
<rect x="270" y="175" width="480" height="130" class="box" rx="4" />
<text x="285" y="198" class="label">Stack (Security-Enabled)</text>
<text x="285" y="218" class="item">Roles / Users</text>
<text x="285" y="236" class="item">API Keys</text>
<text x="285" y="254" class="item">Role Mappings</text>
<text x="285" y="272" class="item">License Management</text>
<text x="285" y="290" class="item">Upgrade Assistant</text>
</svg>

### Common Pitfalls

**Key Points**

- Deleting a data view that multiple dashboards and visualizations depend on without checking relationships first via Saved Objects, breaking those panels until repointed.
- Applying an ILM policy retroactively expecting existing indices to immediately reorganize, when in practice phase transitions apply going forward based on the policy's configured thresholds and rollover conditions.
- Granting overly broad roles (e.g., cluster-wide `all` privileges) for convenience rather than scoping API keys and roles to the minimum required access.
- Changing global Advanced Settings in a shared production environment without communicating the change, since settings like default data view or date format affect all users of that space/instance.

### Conclusion

Stack Management consolidates the administrative surface of both Kibana and much of Elasticsearch into a single UI, spanning data structure and lifecycle (data views, ILM, transforms, snapshots), Kibana content organization (saved objects, spaces, tags), and security (roles, users, API keys). Familiarity with this section is necessary for anyone responsible for maintaining a Kibana deployment beyond building individual dashboards or visualizations.

### Related Topics

- Index Lifecycle Management — Phase Actions and Rollover Strategies
- Elasticsearch Security — Roles, Privileges, and SSO Integration
- Saved Objects Relationships and Migration Between Environments
- Transforms — Pivot vs. Latest Aggregation Use Cases
- Snapshot Lifecycle Management (SLM) and Repository Configuration
- Kibana Spaces for Multi-Tenant Deployments
- Upgrade Planning and Deprecation Remediation