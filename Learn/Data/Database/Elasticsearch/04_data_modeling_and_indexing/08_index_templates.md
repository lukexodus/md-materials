## Index Templates in Elasticsearch

---

### What Are Index Templates?

An index template is a pre-defined configuration that Elasticsearch automatically applies when a new index is created whose name matches a specified pattern. Templates can define settings, mappings, aliases, and other index-level configurations — eliminating the need to specify them manually each time a matching index is created.

Templates are particularly important in environments where indices are created programmatically and repeatedly, such as time-series data pipelines, log ingestion, and rolling index strategies.

Elasticsearch supports two generations of index templates:

- **Legacy templates** (`_template` API) — the original implementation, still functional but superseded
- **Composable templates** (`_index_template` API) — the current standard, introduced in Elasticsearch 7.8

---

### Legacy Index Templates

Legacy templates are defined using the `_template` API. They remain supported but are not recommended for new implementations.

**Creating a legacy template:**

```json
PUT /_template/logs_template
{
  "index_patterns": ["logs-*"],
  "order": 1,
  "settings": {
    "number_of_shards":   2,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "timestamp": { "type": "date"    },
      "message":   { "type": "text"    },
      "level":     { "type": "keyword" }
    }
  },
  "aliases": {
    "all_logs": {}
  }
}
```

When a new index named `logs-2024-01` is created, Elasticsearch detects the pattern match and applies this template automatically.

**Key parameters:**

| Parameter | Description |
|---|---|
| `index_patterns` | Glob patterns matched against the new index name |
| `order` | Priority when multiple templates match; higher value wins |
| `settings` | Index-level settings (shards, replicas, analyzers, etc.) |
| `mappings` | Field mappings applied to the index |
| `aliases` | Aliases automatically added to the index |

---

### Composable Index Templates

Composable templates replace legacy templates and introduce a more modular architecture. They separate reusable configuration fragments (component templates) from the final template definition, allowing shared configuration to be maintained in one place and composed into multiple index templates.

**Creating a composable template:**

```json
PUT /_index_template/logs_template
{
  "index_patterns": ["logs-*"],
  "priority":       100,
  "template": {
    "settings": {
      "number_of_shards":   2,
      "number_of_replicas": 1
    },
    "mappings": {
      "properties": {
        "timestamp": { "type": "date"    },
        "message":   { "type": "text"    },
        "level":     { "type": "keyword" }
      }
    },
    "aliases": {
      "all_logs": {}
    }
  }
}
```

**Key differences from legacy templates:**

| Aspect | Legacy (`_template`) | Composable (`_index_template`) |
|---|---|---|
| Priority parameter | `order` | `priority` |
| Configuration wrapper | Top-level keys | Nested under `template` |
| Component template support | No | Yes (`composed_of`) |
| Data stream support | No | Yes |
| Recommended for new use | No | Yes |

---

### Component Templates

Component templates are reusable building blocks that hold partial configurations — settings, mappings, or aliases. They have no effect on their own and must be referenced by a composable index template via `composed_of`.

**Creating a component template for common mappings:**

```json
PUT /_component_template/common_mappings
{
  "template": {
    "mappings": {
      "properties": {
        "timestamp":  { "type": "date"    },
        "@timestamp": { "type": "date"    },
        "host":       { "type": "keyword" },
        "environment":{ "type": "keyword" }
      }
    }
  }
}
```

**Creating a component template for index settings:**

```json
PUT /_component_template/standard_settings
{
  "template": {
    "settings": {
      "number_of_shards":             1,
      "number_of_replicas":           1,
      "index.refresh_interval":       "30s",
      "index.mapping.total_fields.limit": 500
    }
  }
}
```

**Composing component templates into an index template:**

```json
PUT /_index_template/application_logs
{
  "index_patterns": ["applogs-*"],
  "priority":       100,
  "composed_of":    ["standard_settings", "common_mappings"],
  "template": {
    "mappings": {
      "properties": {
        "service":    { "type": "keyword" },
        "log_level":  { "type": "keyword" },
        "message":    { "type": "text"    }
      }
    }
  }
}
```

**Merge behavior:** Settings and mappings from component templates are merged in the order listed in `composed_of`. The inline `template` block in the index template is applied last and takes precedence over any conflicting values from component templates.

> [Inference] When component templates define overlapping fields or settings, the last one listed in `composed_of` takes precedence, with the inline template block winning over all components. Behavior may vary across versions — verify merge semantics in your specific version.

---

### Priority and Pattern Matching

When a new index is created and multiple composable templates match its name, Elasticsearch applies the one with the highest `priority` value. If two matching templates share the same priority, Elasticsearch raises an error.

```json
PUT /_index_template/generic_logs
{
  "index_patterns": ["logs-*"],
  "priority": 50,
  "template": { ... }
}

PUT /_index_template/security_logs
{
  "index_patterns": ["logs-security-*"],
  "priority": 100,
  "template": { ... }
}
```

An index named `logs-security-2024-01` matches both templates. The `security_logs` template is applied because it has the higher priority.

**Built-in templates:** Elasticsearch ships with built-in index templates for certain index patterns (e.g., `.logs-*`, `.metrics-*`). These use reserved priority ranges. Custom templates should use priority values of 100 or above to avoid conflicts with built-in templates.

> [Inference] Priority values below 100 may conflict with Elasticsearch's built-in templates in some distributions and versions. Verify the reserved ranges for your specific version before assigning priority values. Behavior may vary.

---

### Template Simulation API

Before applying a template to a live index, you can simulate what the resolved configuration would look like using the simulate API.

**Simulate the template that would apply to a given index name:**

```json
POST /_index_template/_simulate_index/logs-2024-01
```

**Output (abbreviated):**

```json
{
  "template": {
    "settings": { ... },
    "mappings": { ... },
    "aliases":  { ... }
  },
  "overlapping": []
}
```

**Simulate the resolved output of a specific template definition:**

```json
POST /_index_template/_simulate/application_logs
```

This returns the fully merged configuration of the named template, including all composed component templates.

The simulate API is valuable for verifying merge behavior and priority resolution before deploying template changes to production.

---

### Index Templates and Data Streams

Composable index templates are required for creating data streams. A data stream is an abstraction over a sequence of backing indices, suited for append-only time-series data.

A template that enables data streams must include a `data_stream` block:

```json
PUT /_index_template/metrics_template
{
  "index_patterns": ["metrics-*"],
  "priority":       200,
  "data_stream":    {},
  "template": {
    "settings": {
      "number_of_shards":   1,
      "number_of_replicas": 1
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "value":      { "type": "float" }
      }
    }
  }
}
```

When a document is indexed to `metrics-app-01` and no index by that name exists, Elasticsearch creates a data stream backed by an auto-generated index, using this template.

---

### Dynamic Mapping Templates Inside Index Templates

Index templates can include `dynamic_templates` within their `mappings` block, combining the automatic field creation of dynamic mapping with the rules-based control of dynamic templates.

```json
PUT /_index_template/structured_logs
{
  "index_patterns": ["structlogs-*"],
  "priority": 100,
  "template": {
    "mappings": {
      "dynamic_templates": [
        {
          "strings_as_keyword": {
            "match_mapping_type": "string",
            "mapping": {
              "type": "keyword"
            }
          }
        }
      ],
      "properties": {
        "@timestamp": { "type": "date" },
        "message":    { "type": "text" }
      }
    }
  }
}
```

All string fields not explicitly mapped will be indexed as `keyword` rather than the default `text` + `keyword` multi-field.

---

### Managing Templates

**List all composable templates:**

```json
GET /_index_template
```

**Retrieve a specific template:**

```json
GET /_index_template/application_logs
```

**Retrieve all component templates:**

```json
GET /_component_template
```

**Delete a composable template:**

```json
DELETE /_index_template/application_logs
```

**Delete a component template:**

```json
DELETE /_component_template/common_mappings
```

Deleting a component template that is still referenced by an active index template does not immediately raise an error — but the referencing index template will fail to resolve correctly when next applied.

> [Inference] Removing a component template while it is still referenced by active index templates may cause unexpected behavior when those index templates are applied to new indices. Verify references before deleting component templates. Behavior may vary.

---

### Template Versioning

Both composable and component templates support a `version` field. This is an arbitrary integer for external management and documentation purposes — Elasticsearch does not enforce version ordering or use it for conflict resolution.

```json
PUT /_index_template/application_logs
{
  "version": 3,
  "index_patterns": ["applogs-*"],
  "priority": 100,
  "template": { ... }
}
```

A `_meta` field is also available for storing arbitrary metadata such as ownership, description, or change history:

```json
{
  "_meta": {
    "description": "Template for application log indices",
    "owner":       "platform-team",
    "updated":     "2024-11-01"
  }
}
```

---

### Template Application Order Summary

When a new index is created, Elasticsearch resolves its configuration in the following order (later steps override earlier ones):

1. Cluster-level default settings
2. Component templates, merged in `composed_of` list order
3. Inline `template` block in the matched composable index template
4. Any settings or mappings specified explicitly in the index creation request itself

---

### Comparison: Legacy vs Composable Templates

| Feature | Legacy (`_template`) | Composable (`_index_template`) |
|---|---|---|
| API endpoint | `/_template` | `/_index_template` |
| Priority field | `order` | `priority` |
| Component template support | No | Yes |
| Data stream support | No | Yes |
| Simulate API | No | Yes |
| Conflict handling on equal priority | Last write wins | Error raised |
| Recommended for new deployments | No | Yes |

---

### Best Practices

- **Use composable templates exclusively for new deployments.** Legacy templates are superseded and offer no advantages over composable templates.
- **Extract shared configuration into component templates.** Settings and mappings common across multiple index templates should live in component templates to avoid duplication and drift.
- **Use the simulate API before deploying template changes.** Verifying resolved configuration prevents unexpected mapping or settings from being applied to new indices.
- **Assign explicit priority values and document them.** Undocumented priority assignments across templates become difficult to reason about as the number of templates grows.
- **Keep `index_patterns` as specific as possible.** Overly broad patterns (e.g., `*`) risk matching unintended indices.
- **Version and annotate templates using `version` and `_meta`.** This supports operational visibility and change tracking without adding application-layer overhead.
- **Test template changes against non-production index names** before applying to production pipelines, especially when modifying component templates shared across multiple index templates.

---