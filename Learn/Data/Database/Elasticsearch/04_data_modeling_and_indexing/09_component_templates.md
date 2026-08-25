## Component Templates

---

### What Are Component Templates?

Component templates are reusable, named configuration fragments that store partial index configurations — mappings, settings, aliases, or any combination of the three. They have no direct effect on any index on their own. They take effect only when referenced by a composable index template via the `composed_of` parameter.

The primary purpose of component templates is to eliminate duplication across index templates. Rather than repeating the same mapping definitions or settings in every index template, shared configuration is defined once in a component template and composed into as many index templates as needed.

---

### Creating a Component Template

The API endpoint for component templates is `/_component_template/<name>`.

**Basic structure:**

```json
PUT /_component_template/<name>
{
  "_meta": { ... },
  "version": 1,
  "template": {
    "settings": { ... },
    "mappings":  { ... },
    "aliases":   { ... }
  }
}
```

All three blocks — `settings`, `mappings`, `aliases` — are optional. A component template may contain any one, any two, or all three.

---

### Component Template for Mappings

```json
PUT /_component_template/base_mappings
{
  "_meta": {
    "description": "Common fields shared across all indices",
    "owner": "platform-team"
  },
  "template": {
    "mappings": {
      "properties": {
        "@timestamp":  { "type": "date"    },
        "host":        { "type": "keyword" },
        "environment": { "type": "keyword" },
        "service":     { "type": "keyword" },
        "trace_id":    { "type": "keyword" }
      }
    }
  }
}
```

---

### Component Template for Settings

```json
PUT /_component_template/standard_settings
{
  "_meta": {
    "description": "Standard shard and performance settings"
  },
  "template": {
    "settings": {
      "number_of_shards":                  1,
      "number_of_replicas":                1,
      "index.refresh_interval":            "30s",
      "index.mapping.total_fields.limit":  500,
      "index.mapping.depth.limit":         10
    }
  }
}
```

---

### Component Template for Aliases

```json
PUT /_component_template/common_aliases
{
  "template": {
    "aliases": {
      "all_data":    {},
      "recent_data": {
        "filter": {
          "range": {
            "@timestamp": {
              "gte": "now-7d/d"
            }
          }
        }
      }
    }
  }
}
```

---

### Component Template for All Three Blocks

```json
PUT /_component_template/full_base_config
{
  "_meta": {
    "description": "Mappings, settings, and aliases for standard log indices"
  },
  "version": 2,
  "template": {
    "settings": {
      "number_of_shards":       1,
      "number_of_replicas":     1,
      "index.refresh_interval": "15s"
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "@timestamp": { "type": "date"    },
        "level":      { "type": "keyword" },
        "message":    { "type": "text"    }
      }
    },
    "aliases": {
      "logs_all": {}
    }
  }
}
```

---

### Composing Component Templates into an Index Template

Component templates are referenced in the `composed_of` array of a composable index template. They are applied in the order listed — later entries override earlier entries on any conflicting keys.

```json
PUT /_index_template/application_logs
{
  "index_patterns": ["applogs-*"],
  "priority":       100,
  "composed_of":    ["standard_settings", "base_mappings", "common_aliases"],
  "template": {
    "mappings": {
      "properties": {
        "request_id":   { "type": "keyword" },
        "response_code":{ "type": "integer" },
        "duration_ms":  { "type": "long"    }
      }
    }
  }
}
```

**Merge resolution order:**

1. `standard_settings` is applied first
2. `base_mappings` is merged on top — conflicting keys override those from `standard_settings`
3. `common_aliases` is merged on top
4. The inline `template` block is merged last — it takes precedence over everything from `composed_of`

---

### Merge Behavior in Detail

Understanding how component templates merge is essential for predictable behavior.

#### Settings Merge

Settings are merged by key. If two component templates define the same setting key, the one listed later in `composed_of` wins.

```json
// Component A
"settings": { "number_of_replicas": 1, "index.refresh_interval": "30s" }

// Component B
"settings": { "number_of_replicas": 2 }

// composed_of: ["A", "B"]
// Result: { "number_of_replicas": 2, "index.refresh_interval": "30s" }
```

#### Mappings Merge

Mappings are merged recursively by field name. Component templates can add fields to the same `properties` block without conflict, as long as the same field name is not defined in two different templates with different types.

```json
// Component A defines:
"properties": {
  "@timestamp": { "type": "date" },
  "host":       { "type": "keyword" }
}

// Component B defines:
"properties": {
  "service":    { "type": "keyword" },
  "duration_ms":{ "type": "long" }
}

// composed_of: ["A", "B"]
// Result merges all four fields into properties
```

If two component templates define the **same field name with conflicting types**, the later component's definition overrides the earlier one.

> [Inference] Conflicting field type definitions across component templates do not raise an error at template creation time — the override is silent. Verifying merged output with the simulate API before applying to production is strongly advised. Behavior may vary.

#### Aliases Merge

Aliases from all component templates and the inline template block are collected and merged. If the same alias name appears in multiple templates, the last definition wins.

---

### Dynamic Templates in Component Templates

Component templates can include `dynamic_templates` inside the `mappings` block. These are merged and concatenated — dynamic templates from multiple component templates are combined into a single list in the order they appear.

```json
PUT /_component_template/dynamic_string_rules
{
  "template": {
    "mappings": {
      "dynamic_templates": [
        {
          "strings_as_keyword": {
            "match_mapping_type": "string",
            "unmatch": "message",
            "mapping": { "type": "keyword" }
          }
        }
      ]
    }
  }
}
```

When composed with other component templates that also define `dynamic_templates`, all lists are concatenated. The first matching template in the combined list is applied.

> [Inference] The order of dynamic template evaluation after merging across multiple component templates depends on the order of `composed_of` and the inline block. Unexpected rule precedence may occur if dynamic templates are not carefully ordered. Behavior may vary.

---

### Versioning and Metadata

Component templates support `version` and `_meta` as top-level fields. Neither affects Elasticsearch behavior — they exist for documentation and external management tooling.

```json
PUT /_component_template/base_mappings
{
  "version": 5,
  "_meta": {
    "description":  "Core field definitions for all log-type indices",
    "owner":        "data-platform",
    "last_updated": "2024-10-15",
    "changelog":    "Added trace_id field in v5"
  },
  "template": { ... }
}
```

Using `_meta` consistently across component templates supports auditing and reduces ambiguity when multiple teams manage templates in the same cluster.

---

### Managing Component Templates

**List all component templates:**

```json
GET /_component_template
```

**Retrieve a specific component template:**

```json
GET /_component_template/base_mappings
```

**Retrieve multiple by pattern:**

```json
GET /_component_template/base_*
```

**Update a component template (full replacement):**

```json
PUT /_component_template/base_mappings
{
  "version": 6,
  "template": {
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date"    },
        "host":       { "type": "keyword" },
        "region":     { "type": "keyword" }
      }
    }
  }
}
```

Component templates do not support partial updates. A `PUT` replaces the entire definition.

**Delete a component template:**

```json
DELETE /_component_template/base_mappings
```

---

### Effect of Updating a Component Template

Updating a component template does **not** retroactively affect existing indices. The new definition is applied only when a new index is created that matches an index template referencing the updated component template.

> [Inference] If existing indices need to reflect updated component template definitions, they must be reindexed or have their mappings/settings updated individually. There is no mechanism to propagate component template changes to existing indices automatically. Behavior may vary.

---

### Simulating Component Template Resolution

The simulate API resolves what the final merged configuration would look like for a given index name or template definition.

**Simulate what would apply to a new index named `applogs-2024-01`:**

```json
POST /_index_template/_simulate_index/applogs-2024-01
```

**Simulate the resolved output of a named index template (shows full merge of all component templates):**

```json
POST /_index_template/_simulate/application_logs
```

**Output (abbreviated):**

```json
{
  "template": {
    "settings": {
      "index": {
        "number_of_shards":   "1",
        "number_of_replicas": "1",
        "refresh_interval":   "30s"
      }
    },
    "mappings": {
      "properties": {
        "@timestamp":    { "type": "date"    },
        "host":          { "type": "keyword" },
        "service":       { "type": "keyword" },
        "request_id":    { "type": "keyword" },
        "response_code": { "type": "integer" },
        "duration_ms":   { "type": "long"    }
      }
    },
    "aliases": {
      "all_data": {}
    }
  },
  "overlapping": []
}
```

The `overlapping` array lists any other index templates that also match the index pattern at a lower priority — useful for diagnosing unexpected template competition.

---

### Dependency Awareness

Elasticsearch does not enforce referential integrity between component templates and the index templates that reference them. You can delete a component template that is still listed in an active index template's `composed_of` array without receiving an error at deletion time.

The failure occurs later — when a new index is created and the index template attempts to resolve a now-missing component template.

**Checking which index templates reference a component template:**

There is no built-in reverse-lookup API. To find references manually:

```json
GET /_index_template
```

Then inspect the `composed_of` arrays in the response for the component template name.

> [Inference] In clusters with many templates managed by multiple teams, the absence of referential integrity enforcement may lead to silent resolution failures. A process for auditing `composed_of` references before deleting component templates reduces this risk. Behavior may vary.

---

### Practical Decomposition Strategy

A common pattern is to separate component templates by concern, allowing each to be updated independently:

| Component Template | Contains |
|---|---|
| `base_timestamps` | `@timestamp`, `event.created` date fields |
| `base_host_fields` | `host`, `ip`, `region` keyword fields |
| `standard_settings` | Shard count, replica count, refresh interval |
| `strict_dynamic` | `"dynamic": "strict"` mapping setting |
| `default_aliases` | Common aliases applied across index families |
| `ilm_policy_link` | ILM policy reference in settings |

Index templates for specific use cases then compose the relevant subset:

```json
"composed_of": [
  "standard_settings",
  "strict_dynamic",
  "base_timestamps",
  "base_host_fields",
  "default_aliases"
]
```

This structure makes it possible to change, for example, the ILM policy reference or the shard count across all affected index templates by updating a single component template.

---

### Best Practices

- **Design component templates around a single concern.** A component template that mixes settings, mappings, and aliases for a specific use case is harder to reuse than one that holds only common timestamp fields.
- **Name component templates descriptively.** Names like `base_log_mappings` or `high_throughput_settings` communicate intent more clearly than `template_v2` or `common`.
- **Always simulate after changes.** Use `_simulate` or `_simulate_index` to verify merged output before deploying component template updates.
- **Document the `composed_of` dependency graph.** Because Elasticsearch does not enforce referential integrity, maintaining a record of which index templates depend on which component templates prevents accidental deletion breakage.
- **Use `version` and `_meta` consistently.** These fields cost nothing and provide significant operational value when diagnosing issues or coordinating changes across teams.
- **Do not define conflicting field types across component templates that are composed together.** Silent overrides are difficult to detect without the simulate API.
- **Treat component template updates as additive where possible.** Adding new fields is lower risk than modifying or removing existing ones, since existing indices are unaffected but new indices must be compatible with downstream consumers.

---