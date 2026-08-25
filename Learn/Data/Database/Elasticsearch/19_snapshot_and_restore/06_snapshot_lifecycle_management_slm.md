## Snapshot Lifecycle Management (SLM)

### Purpose and Overview

Snapshot Lifecycle Management automates the creation and retention of Elasticsearch snapshots on a defined schedule, removing the need for external cron jobs or manual snapshot API calls. SLM policies define when snapshots are taken, what they include, where they're stored, and how long they're retained before being automatically deleted.

SLM builds directly on top of the snapshot and restore subsystem: it doesn't introduce a new storage mechanism, but rather orchestrates calls to the existing snapshot APIs against a configured repository.

### Core Concepts

**Key Points**
- **Policy** — a named configuration specifying schedule, snapshot naming, target indices, repository, and retention rules.
- **Repository** — the underlying storage location (e.g., a shared filesystem, S3 bucket, Azure blob container, or GCS bucket) where snapshots are physically stored. A repository must exist before an SLM policy can reference it.
- **Schedule** — expressed as a cron expression, controlling how frequently the policy runs.
- **Retention** — rules for how many snapshots to keep and for how long, after which older ones are automatically deleted.

### Prerequisites: Registering a Repository

Before creating an SLM policy, a snapshot repository must be registered. For example, registering a filesystem repository:

```
PUT _snapshot/my_backup_repo
{
  "type": "fs",
  "settings": {
    "location": "/mnt/snapshots/my_backup_repo"
  }
}
```

Or an S3-backed repository (requires the `repository-s3` plugin):

```
PUT _snapshot/my_s3_repo
{
  "type": "s3",
  "settings": {
    "bucket": "my-elasticsearch-backups",
    "region": "us-east-1"
  }
}
```

[Unverified] Exact required settings for cloud-based repository types (credentials handling, endpoint overrides, storage class options) vary by plugin version and cloud provider configuration, so the specific plugin's current documentation should be checked when setting one up.

### Creating an SLM Policy

```
PUT _slm/policy/daily_snapshots
{
  "schedule": "0 30 1 * * ?",
  "name": "<daily-snap-{now/d}>",
  "repository": "my_backup_repo",
  "config": {
    "indices": ["*"],
    "ignore_unavailable": false,
    "include_global_state": true
  },
  "retention": {
    "expire_after": "30d",
    "min_count": 5,
    "max_count": 50
  }
}
```

**Field breakdown:**
- `schedule` — a cron expression (here, 1:30 AM daily). SLM uses the same cron syntax as Watcher.
- `name` — the snapshot name template; `<daily-snap-{now/d}>` uses date math to produce names like `daily-snap-2026.08.24`.
- `repository` — the target repository registered earlier.
- `config.indices` — which indices to include; `*` captures all, but patterns or explicit lists can scope this down.
- `config.include_global_state` — whether cluster state (templates, ILM policies, etc.) is included in the snapshot.
- `retention.expire_after` — snapshots older than this age become eligible for deletion.
- `retention.min_count` / `max_count` — floor and ceiling on the number of snapshots retained regardless of age, evaluated alongside `expire_after`.

### Retention Logic in Detail

**Key Points**
- Retention is evaluated on its own schedule (configurable separately, defaulting to a periodic sweep), not immediately upon snapshot creation.
- A snapshot is deleted only when it satisfies the age condition (`expire_after`) **and** doing so wouldn't bring the count below `min_count`.
- `max_count` acts as a hard ceiling — even snapshots within `expire_after` may be deleted if the count exceeds it.
- This means `min_count` and `expire_after` interact: an old snapshot may be retained past its `expire_after` window if deleting it would violate `min_count`.

### Manually Executing a Policy

Policies run automatically per their cron schedule, but can also be triggered on demand — useful for testing a policy immediately rather than waiting for its scheduled time:

```
POST _slm/policy/daily_snapshots/_execute
```

### Viewing Policy Status and History

**Example: Getting policy details and execution history**

```
GET _slm/policy/daily_snapshots?human
```

This returns the policy definition along with `last_success`, `last_failure`, and `stats` blocks showing counts of snapshots taken, deleted, and any failures — critical for confirming a policy is actually running as expected rather than silently failing.

**Example: Cluster-wide SLM stats**

```
GET _slm/stats
```

Returns aggregate counters across all policies: total snapshots taken, deleted, failed, and per-policy breakdowns.

### Pausing and Resuming SLM

The entire SLM subsystem can be paused cluster-wide, which is useful during maintenance windows or troubleshooting:

```
POST _slm/stop
```

And resumed:

```
POST _slm/start
```

Checking current operating mode:

```
GET _slm/status
```

### Deleting a Policy

```
DELETE _slm/policy/daily_snapshots
```

**Key Points**
- Deleting a policy does **not** delete snapshots it already created — those remain in the repository until manually removed or cleaned up via a separate retention run.
- To also remove associated snapshots, they must be deleted explicitly via the standard snapshot delete API.

### SLM and ILM Integration

SLM policies can be invoked directly from an Index Lifecycle Management (ILM) policy's `wait_for_snapshot` action, which pauses ILM progression (typically before deleting an index) until a named SLM policy has successfully run. This ensures an index isn't deleted by ILM before a snapshot capturing it has completed.

```
PUT _ilm/policy/my_ilm_policy
{
  "policy": {
    "phases": {
      "delete": {
        "actions": {
          "wait_for_snapshot": {
            "policy": "daily_snapshots"
          }
        }
      }
    }
  }
}
```

### SLM Workflow

```plaintext
===MERMAID_DIAGRAM===
flowchart TD
    A[Cron schedule triggers] --> B[SLM policy executes]
    B --> C[Snapshot API called against repository]
    C --> D{Snapshot succeeds?}
    D -- Yes --> E[Update last_success stats]
    D -- No --> F[Update last_failure stats]
    E --> G[Retention sweep runs on its own schedule]
    G --> H{Snapshot meets expire_after AND count > min_count?}
    H -- Yes --> I[Snapshot deleted]
    H -- No --> J[Snapshot retained]
```

### Illustration: Policy, Repository, and Retention Relationship

<svg viewBox="0 0 760 320" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
  <text x="380" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">SLM Policy Components (svg_diagram)</text>

  <rect x="40" y="60" width="200" height="90" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5"/>
  <text x="140" y="90" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">SLM Policy</text>
  <text x="140" y="110" text-anchor="middle" font-size="11" fill="#555">schedule (cron)</text>
  <text x="140" y="126" text-anchor="middle" font-size="11" fill="#555">name template</text>

  <rect x="300" y="60" width="200" height="90" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5"/>
  <text x="400" y="90" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Repository</text>
  <text x="400" y="110" text-anchor="middle" font-size="11" fill="#555">fs / s3 / azure / gcs</text>
  <text x="400" y="126" text-anchor="middle" font-size="11" fill="#555">physical storage target</text>

  <rect x="560" y="60" width="180" height="90" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5"/>
  <text x="650" y="90" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Snapshots</text>
  <text x="650" y="110" text-anchor="middle" font-size="11" fill="#555">daily-snap-2026.08.24</text>
  <text x="650" y="126" text-anchor="middle" font-size="11" fill="#555">daily-snap-2026.08.23 ...</text>

  <line x1="240" y1="105" x2="295" y2="105" stroke="#555" stroke-width="1.5" marker-end="url(#a1)"/>
  <line x1="500" y1="105" x2="555" y2="105" stroke="#555" stroke-width="1.5" marker-end="url(#a1)"/>

  <rect x="300" y="210" width="200" height="80" rx="8" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5"/>
  <text x="400" y="238" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Retention Rules</text>
  <text x="400" y="256" text-anchor="middle" font-size="11" fill="#555">expire_after / min_count</text>
  <text x="400" y="272" text-anchor="middle" font-size="11" fill="#555">max_count</text>

  <line x1="650" y1="150" x2="650" y2="250" stroke="#999" stroke-width="1.5" stroke-dasharray="4,3"/>
  <line x1="650" y1="250" x2="505" y2="250" stroke="#999" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#a2)"/>
  <text x="580" y="245" text-anchor="middle" font-size="10" fill="#777">governs deletion</text>

  <defs>
    <marker id="a1" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="#555"/></marker>
    <marker id="a2" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="#999"/></marker>
  </defs>
</svg>

### Common Operational Pitfalls

**Key Points**
- A policy with `include_global_state: false` will not capture index templates, ILM policies, or SLM policies themselves — restoring from such a snapshot won't bring back that cluster-level configuration.
- If a repository becomes unreachable (e.g., network issue to an S3 bucket), SLM records the failure in `last_failure` but does not alert by default — pairing SLM with monitoring/alerting on `_slm/stats` failure counts is advisable.
- Retention doesn't run instantly after a snapshot is deleted from being "expired" — depending on the retention schedule interval, an expired snapshot might persist briefly before being cleaned up. [Unverified] The exact default retention sweep interval and whether it is user-configurable may differ across versions, so the running cluster's settings should be checked directly.
- Snapshots within the same repository are incremental at the segment level, meaning storage growth per snapshot is typically much smaller than a full copy — but this is a repository/Lucene-level optimization detail rather than something SLM configures directly.

### Security Considerations

Repository access (read/write to the underlying storage, e.g. S3 IAM permissions or filesystem permissions) is independent of Elasticsearch's own role-based access control. A user needs both the appropriate Elasticsearch privileges (`manage_slm`, `manage` on the repository) and the underlying storage backend must be reachable and writable by the Elasticsearch node processes performing the snapshot.

**Related Topics**
- Snapshot and Restore APIs (manual snapshot/restore operations)
- Index Lifecycle Management (ILM) and its phases
- Repository types and cloud storage plugin configuration
- Searchable snapshots and cold/frozen tier storage
- Cross-cluster replication vs. snapshot-based backup strategies
- Disaster recovery planning with SLM and repository redundancy