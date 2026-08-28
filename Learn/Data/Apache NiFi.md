# Comprehensive Guide to Apache NiFi

## 1. What Is Apache NiFi?

Apache NiFi is a **dataflow automation and management system**. It was originally developed inside the U.S. National Security Agency under the name "Niagarafiles," released to the public in 2014, and became an Apache Software Foundation top-level project shortly after. Its purpose is to move, route, transform, and mediate data between systems — files, APIs, databases, message queues, cloud storage — reliably, with visibility into every step.

The core idea NiFi is built around is **flow-based programming**: you build a dataflow visually, as a directed graph, by wiring together small, single-purpose units of work. Each unit does one job (fetch a file, filter records, convert a format, write to a database), and NiFi's engine handles the plumbing — queuing, backpressure, retries, prioritization, and full data lineage tracking — so that you rarely have to write "glue code."

**Where NiFi fits relative to similar tools**, since this comes up constantly when people are evaluating it:

- **vs. Apache Kafka** — Kafka is a distributed log/message broker; NiFi is a dataflow *orchestrator*. They're often used together: NiFi ingests from varied sources and hands records to Kafka, or Kafka feeds NiFi for downstream routing/transformation. NiFi is not a replacement for Kafka's storage/replay guarantees.
- **vs. Apache Airflow** — Airflow schedules and orchestrates *batch jobs* (DAGs of tasks that run and finish). NiFi is designed for *continuous, streaming-style* dataflow where FlowFiles are flowing through the graph constantly, not triggered on a schedule (though NiFi can do scheduled/batch-like work too).
- **vs. Logstash** — Logstash is purpose-built for log ingestion into stores like Elasticsearch. NiFi is general-purpose and handles a much broader variety of data types and destinations, with a visual UI and finer-grained control.

## 2. Core Concepts

This is the conceptual foundation everything else builds on. Get these solid first.

### FlowFile

A **FlowFile** is the fundamental unit of data in NiFi. It has two parts:

1. **Content** — the actual data payload (bytes), stored in the **Content Repository**.
2. **Attributes** — key-value metadata about that content (e.g., `filename`, `path`, `mime.type`, or anything custom you set), stored in the **FlowFile Repository**.

Crucially, NiFi does not copy the content around as a FlowFile moves through the flow. Instead, it manipulates pointers/references to content in the repository, which is why NiFi can handle very large files efficiently — a "copy" or "clone" operation (like splitting or merging) doesn't necessarily duplicate bytes on disk.

### Processor

A **Processor** is the basic unit of work — the "verb" of NiFi. Each processor does one thing: fetches data, transforms it, routes it, or sends it somewhere. NiFi ships with several hundred built-in processors, and you can write custom ones (in Java, or — as of NiFi 2.x — natively in Python).

Every processor has:
- **Properties** — its configuration (e.g., a file path, a URL, a SQL query)
- **Relationships** — named outputs a FlowFile can be routed to after processing (commonly `success` and `failure`, but often more specific ones like `retry`, `not found`, `original`)
- **Scheduling** — how often/how it runs (timer-driven, cron-driven, or event-driven)

### Connection

A **Connection** is the queue between two processors (or between a processor and a process group boundary). This is where FlowFiles sit while waiting to be picked up by the next processor. Connections are where **backpressure** and **prioritization** are configured (more on this in section 8).

### Process Group

A **Process Group** is a container for organizing a set of processors, connections, and other process groups into a logical unit — like a subroutine or a folder. Process Groups can have Input Ports and Output Ports, letting them act as reusable, composable building blocks. You can nest them arbitrarily deep.

### The Three Repositories

This trips up a lot of newcomers, so it's worth being explicit:

| Repository | Stores | Notes |
|---|---|---|
| **FlowFile Repository** | FlowFile attributes + pointers to content | Write-ahead log; used to recover in-flight FlowFiles after a crash |
| **Content Repository** | The actual data bytes | Content is often not copied on split/merge/clone — just referenced |
| **Provenance Repository** | Historical record of every event that happened to every FlowFile | Powers the Data Provenance UI; can be large and needs its own retention policy |

For real production deployments, these three repositories are typically placed on **separate physical disks** to avoid I/O contention, since they have very different access patterns (the content repo does heavy sequential writes, the provenance repo does heavy indexed writes, etc.).

### Controller Services

A **Controller Service** is a shared, reusable piece of configuration or connection logic that multiple processors can reference — think connection pools, SSL contexts, or record readers/writers. Defining a `DBCPConnectionPool` once and having five different processors reference it (rather than each processor holding its own DB credentials) is the standard pattern.

### Reporting Tasks

**Reporting Tasks** run in the background and push NiFi's internal metrics/status out to external systems — Prometheus, Ambari, a Slack webhook, etc. Useful for monitoring NiFi itself as infrastructure.

## 3. Architecture

### Standalone vs. Clustered

NiFi can run as a **single standalone instance** or as a **cluster** of multiple nodes.

Since NiFi 1.0, clustering uses a **Zero-Master Clustering** model. This is a common point of confusion, so it's worth stating precisely: in a NiFi cluster, **every node runs the exact same flow**. There's no primary/replica split of *the dataflow itself* — each node processes its own data independently, in parallel, using the identical flow definition. What *is* elected is a **Cluster Coordinator** (handles node connect/disconnect, cluster-wide flow synchronization) and, separately, a **Primary Node** (used for processors that should only execute on one node cluster-wide — e.g., a processor polling a single external API endpoint where you don't want every node hitting it redundantly; you'd schedule that processor to run "On Primary Node" only).

**Apache ZooKeeper** coordinates this: it handles Cluster Coordinator election, Primary Node election, and (via a ZooKeeper-backed state provider) cluster-wide state storage for processors that need to remember things across restarts (like "which files have I already ingested"). This remains true and current for NiFi 2.x — despite some inconsistent claims floating around that ZooKeeper was removed in 2.0, it was not; it's still the standard coordination mechanism. What *has* emerged as an additional option (not a replacement) is a **Kubernetes-native coordination path** for NiFi clusters deployed via certain Kubernetes operators, using K8s-native primitives (Leases, ConfigMaps) instead of standing up a separate ZooKeeper ensemble — useful specifically if you're already fully committed to running on Kubernetes and want one less stateful service to operate. If you're not on such an operator-managed K8s setup, ZooKeeper (either external, or NiFi's embedded ZooKeeper for small/test clusters) is what you'll be running.

A practical note from real deployment threads: ZooKeeper needs an **odd number of nodes, minimum three**, for proper quorum in production. Running an even number, or running NiFi's *embedded* ZooKeeper on just two NiFi nodes, is a common early misconfiguration that causes "unable to elect cluster coordinator" errors — you generally want an *external*, properly-quorumed ZooKeeper ensemble for anything beyond a small test cluster.

### Site-to-Site

**Site-to-Site (S2S)** is NiFi's protocol for transferring FlowFiles directly between two NiFi instances (or between a NiFi cluster and another system that speaks the protocol), with load-balancing across cluster nodes handled automatically. It's commonly used to bridge NiFi instances across security zones or data centers.

### NiFi Registry / Flow Versioning

**NiFi Registry** is (traditionally, a separate application; increasingly integrated more tightly in the 2.x line) where you store **versioned Process Group definitions**. This is how you do "Git for your NiFi flows" — you can version a Process Group, commit changes, and promote a specific version from a dev environment to staging to production, rather than manually recreating flows or relying on ad-hoc export/import.

A major architectural change in NiFi 2.x: **XML Templates are gone entirely**, replaced by **JSON Flow Definitions** as the one canonical way to represent, export, import, and version a flow. If you're reading older tutorials that reference "Templates" as a NiFi feature, know that this refers to the pre-2.x mechanism and it no longer exists in current NiFi.

## 4. Getting Started with the UI

The NiFi canvas is where you build flows. The basic loop:

1. **Drag a Processor** onto the canvas (from the toolbar, or right-click → Add Processor). You'll be prompted to search/select from the processor catalog.
2. **Configure it** — double-click, or right-click → Configure. You'll see tabs:
   - **Settings** — name, penalty duration, relationships to auto-terminate
   - **Scheduling** — run schedule (timer-driven with an interval, CRON-driven, or event-driven), concurrent tasks, run duration
   - **Properties** — the processor-specific configuration (varies entirely by processor type)
   - **Comments** — free-text notes
3. **Draw a Connection** by dragging from one processor's edge to another. You'll be asked which relationship(s) to route through that connection.
4. **Start it** — right-click → Start, or select multiple components and use the Start button in the Operate palette.

For any relationship you don't explicitly route somewhere, you generally need to either connect it or **auto-terminate** it (tell NiFi "I don't care about this outcome, discard it") — an unrouted, non-auto-terminated relationship will prevent the processor from starting, which is a very common early stumbling block.

### Parameter Contexts

**Parameter Contexts** (replacing the older "Variable Registry") let you define named parameters (e.g., `db.host`, `api.key`) at a Process Group level, then reference them in processor properties as `#{db.host}`. This is how you make a flow portable across environments — you build the flow once, and swap the Parameter Context values between dev/staging/prod instead of hand-editing every processor.

## 5. Key Processors, Organized by Function

NiFi ships with an enormous processor catalog. Here's a practical map of the ones you'll actually reach for most often, grouped by what they do.

**Ingestion (Get/List/Fetch pattern):**
- `GetFile` — pulls files from a local/mounted filesystem directory (deletes or moves source files — use carefully)
- `ListFile` + `FetchFile` — the modern, safer pattern: `ListFile` tracks state and emits zero-byte FlowFiles representing *available* files, `FetchFile` then retrieves the actual content. This List/Fetch split pattern repeats across NiFi's ecosystem (`ListSFTP`/`FetchSFTP`, `ListS3`/`FetchS3Object`, `ListDatabaseTables`/etc.) specifically so listing and retrieval can be scaled/scheduled independently.
- `ListenHTTP` — runs an embedded HTTP endpoint that receives POSTed data
- `GetHTTP` / `InvokeHTTP` — polls or calls external HTTP(S) endpoints
- `ConsumeKafka` (record-aware variants exist) — pulls messages from Kafka topics

**Routing & Transformation:**
- `UpdateAttribute` — adds/modifies FlowFile attributes, often using Expression Language
- `RouteOnAttribute` — sends a FlowFile down different relationships based on attribute values/expressions
- `RouteOnContent` — routes based on matching content against a pattern
- `QueryRecord` — runs SQL-like queries directly against record-formatted FlowFile content, routing results to different relationships — extremely powerful for filtering/reshaping structured data without writing custom code
- `ConvertRecord` — converts between record formats (e.g., CSV → JSON → Avro) using a Reader/Writer Controller Service pair (see section 9)
- `JoltTransformJSON` — applies JOLT specifications for JSON-to-JSON structural transformation
- `ExecuteScript` / native scripted processors — for when built-in processors don't cover your logic; supports Groovy, Python, and other JVM-scripting languages. As of NiFi 2.x, Python has first-class, native processor support (you can write a real custom Processor class in Python, not just an inline script) — this is a significant upgrade from the 1.x era, where Jython was the (now security-flagged and removed) way to run Python-like code inline.

**Splitting & Merging:**
- `SplitRecord` / `SplitJson` / `SplitText` — break one FlowFile into many
- `MergeRecord` / `MergeContent` — combine many FlowFiles into fewer, larger ones (important for downstream efficiency — writing 10,000 tiny files to S3 individually is far worse than merging into a handful of larger objects)

**Egress:**
- `PutFile` — writes to local/mounted filesystem
- `PutS3Object`, `PutAzureBlobStorage`, `PutGCSObject` — cloud object storage
- `PutDatabaseRecord` — writes record-formatted data into a relational database via a DB connection pool
- `PublishKafka` (record-aware variants exist)
- `PutElasticsearchRecord`

**A critical modern-best-practice note:** older NiFi tutorials (much of what's still floating around from the 1.x era) teach a pattern of manipulating raw content directly — splitting a CSV line-by-line, doing string manipulation, etc. Since the introduction of **Record-oriented processing**, the strongly preferred approach for anything structured (CSV, JSON, Avro, XML, log formats) is to use **Record processors** (`ConvertRecord`, `QueryRecord`, `PutDatabaseRecord`, etc.) paired with **Record Reader/Writer Controller Services**, rather than chains of Split/manipulate/Merge processors. It's dramatically more efficient (avoids the overhead of physically splitting into thousands of FlowFiles) and easier to maintain.

## 6. Expression Language (EL)

NiFi's **Expression Language** is how you write dynamic, attribute-driven processor properties. It's not a general-purpose scripting language — it's a focused expression syntax embedded inside `${...}`.

Basic attribute reference:
```
${filename}
${path}
```

Chaining functions (EL supports a rich function library — string manipulation, math, date/time, encoding, etc.):
```
${filename:substringBeforeLast('.')}
${filename:toUpper()}
${now():format('yyyy-MM-dd')}
${fileSize:toNumber():multiply(2)}
```

Conditional logic:
```
${status:equals('active')}
${amount:isEmpty()}
```

You'll write EL constantly — in `UpdateAttribute` to derive new attributes, in `RouteOnAttribute` to build routing conditions, and inside many processors' Properties fields wherever dynamic values make sense. Getting comfortable with EL early pays off disproportionately.

## 7. FlowFile Attributes & Data Provenance

As a FlowFile moves through a flow, processors read and write its **attributes**. Some attributes are set automatically by NiFi or by specific processors (`filename`, `uuid`, `path`, `mime.type` after certain conversions), and you add your own with `UpdateAttribute` or as side effects of other processors (e.g., `ExecuteSQL` might set `executesql.row.count`).

**Data Provenance** is one of NiFi's standout features: every event that happens to every FlowFile — created, received, sent, dropped, modified, routed, cloned — is recorded in the Provenance Repository with a full timeline. From the UI, you can:

- Search provenance events by FlowFile UUID, component, time range, or attribute values
- View the complete **lineage graph** of a FlowFile — trace it backward to its origin, or forward to everywhere it ended up (including after splits/merges/clones)
- **Replay** a FlowFile from any provenance event, which is invaluable for debugging — you can literally resend a FlowFile from three steps ago through the flow again without needing the original source system to resend it

This is a genuinely differentiating feature relative to most other dataflow tools — the audit trail is built-in and automatic, not something you have to instrument yourself.

## 8. Backpressure & Prioritization

Every **Connection** (queue) has two backpressure thresholds, configurable in the connection's settings:

- **Object Threshold** — max number of FlowFiles allowed to queue (default 10,000)
- **Size Threshold** — max total data size allowed to queue (default 1 GB)

When either threshold is hit, NiFi stops feeding new FlowFiles into that queue from the upstream processor, applying backpressure upstream through the graph — this is what keeps a fast producer from overwhelming a slow consumer and exhausting memory or disk. It's not optional plumbing; it's core to why NiFi is safe to run unattended with unpredictable data volumes.

**Prioritizers** determine the *order* FlowFiles are pulled off a queue when there's a choice:
- `FirstInFirstOutPrioritizer` (default-ish behavior)
- `NewestFlowFileFirstPrioritizer` / `OldestFlowFileFirstPrioritizer`
- `PriorityAttributePrioritizer` — order by a custom attribute you set

Ignoring backpressure configuration is one of the most common causes of production incidents with NiFi — either queues balloon unbounded (if you've set thresholds too high or disabled them) and exhaust disk, or a naive default setup silently stalls dataflow more than expected. Tuning these deliberately, per-connection, based on expected volume, is a real operational task, not a "set once and forget" default.

## 9. Controller Services in Depth

The most important Controller Service pattern to internalize is the **Record Reader / Record Writer** pair, since it underlies all modern Record-oriented processing:

- **Readers**: `JsonTreeReader`, `CSVReader`, `AvroReader`, `XMLReader`, `GrokReader` (for log parsing), etc. — each parses a specific input format into NiFi's internal record representation, using a **Schema** (which can come from an embedded schema, an Avro schema registry, or be inferred).
- **Writers**: `JsonRecordSetWriter`, `CSVRecordSetWriter`, `AvroRecordSetWriter`, `ParquetRecordSetWriter`, etc. — serialize records back out to a specific format.

A processor like `ConvertRecord` simply takes a Reader and a Writer as configured properties — read as format A, write as format B — and that's your entire format conversion, no custom code required. This same Reader/Writer pairing powers `QueryRecord` (read as A, run SQL, write results as B), `PutDatabaseRecord`, `PublishKafkaRecord`, and dozens more.

Other essential Controller Services:
- `DBCPConnectionPool` — JDBC connection pooling, referenced by any DB-interacting processor
- `SSLContextService` (often `StandardSSLContextService` or a provider based on your keystore/truststore config) — TLS configuration shared across processors/reporting tasks that need it
- `SchemaRegistry` implementations (`AvroSchemaRegistry`, `ConfluentSchemaRegistry`) — centralized schema management for Record processing

## 10. Error Handling Patterns

Every processor's relationships model success and failure explicitly — there's no hidden exception-swallowing. A few standard patterns:

**Route failures to a dead-letter path**: connect a processor's `failure` relationship to a subflow that logs the failed FlowFile's attributes, writes it somewhere durable (a "dead letter" directory, an error topic, an alerting webhook), and stops — rather than silently dropping it or looping it back in a way that could cause an infinite retry storm.

**Bounded retry with a counter**: use `UpdateAttribute` to increment a `retry.count` attribute, `RouteOnAttribute` to check if it's under a threshold, and loop failed FlowFiles back through — but only up to N times, after which they're routed to the dead-letter path instead. This avoids an unbounded retry loop consuming resources forever on a permanently-failing FlowFile.

**Penalization**: many processors support a "penalty duration" (Settings tab) — when a FlowFile fails, it's held (penalized) for a configured time before being retried, preventing tight failure loops from hammering a downed downstream system.

## 11. Security

Security in NiFi spans several independent layers:

**Transport security**: TLS/SSL for the web UI, the REST API, and Site-to-Site connections. In a cluster, mutual TLS between nodes (each node holding a certificate trusted by the others) is standard for production.

**Authentication** (who are you): NiFi supports several pluggable providers — LDAP, Kerberos (SPNEGO), OpenID Connect (OIDC), and mutual TLS (client certificates). For local/dev setups, there's a "Single User" provider that auto-generates a username/password — explicitly documented as unsuitable for real multi-tenant production use.

**Authorization** (what can you do): NiFi has a fine-grained, **policy-based access control** model. You can grant different users/groups different permissions on different Process Groups, individual components, or even specific data — this is how NiFi supports genuine multi-tenancy, where different teams can manage separate parts of the same NiFi instance without seeing or touching each other's flows.

**Sensitive property encryption**: any processor property marked "sensitive" (passwords, API keys, etc.) is encrypted at rest in the flow definition, using a master encryption key configured in `nifi.properties` (`nifi.sensitive.props.key`). Losing/changing this key without the proper migration tooling can make previously-configured sensitive properties unreadable, so it's treated as a critical piece of configuration to back up securely.

## 12. State Management

Many processors need to **remember something across restarts** to function correctly — most obviously, `ListFile`/`ListS3`/etc. need to remember which files they've already listed, so a restart doesn't cause them to reprocess everything from scratch.

NiFi's **State Manager** provides two scopes:
- **Local State** — stored per-node, appropriate for standalone instances or state that's genuinely node-specific
- **Clustered State** — stored via a cluster-wide provider (backed by ZooKeeper, typically) so that state is consistent no matter which node picks up the work — critical in a cluster, since (remember) every node runs the same flow and any node might be the one servicing a given piece of state-dependent logic.

## 13. Monitoring & Operations

**Bulletins** — small red/yellow indicators that appear directly on processors on the canvas when they log a WARN or ERROR, with the message visible on hover. This is your first line of "something's wrong" visibility.

**Data Provenance UI** — covered in section 7; also your operational debugging tool, not just an audit feature.

**Status History** — per-component and per-connection graphs of throughput, queue size, and other metrics over time, viewable directly from the canvas.

**Summary Table** — a global table view of every processor/connection/process group with sortable columns for things like queued count, in/out throughput, and run status — useful for finding "which of my 200 processors is actually the bottleneck" at a glance.

**REST API** — this deserves particular emphasis: **the NiFi UI is itself just a client of NiFi's own REST API.** Everything the UI does — starting/stopping components, changing configuration, querying provenance, managing users — can be done via the API directly. This makes NiFi genuinely automatable: you can script flow deployment, build custom monitoring dashboards, or integrate NiFi management into CI/CD pipelines without touching the UI at all.

**Reporting Tasks** (introduced in section 2) are how you push these metrics *out* to external monitoring systems (Prometheus being a very common target) rather than only viewing them in the NiFi UI itself.

## 14. Flow Versioning & CI/CD

The practical workflow for managing NiFi flows like real software artifacts:

1. Develop your flow in a Process Group in a dev NiFi instance.
2. Version-control that Process Group against a **NiFi Registry** (traditionally a separate deployable application; the exact packaging/integration has evolved through NiFi's 2.x line, so check current docs for how tightly integrated Registry functionality is in whatever specific 2.x release you're deploying).
3. Commit meaningful versions as you iterate, with commit messages describing what changed.
4. In staging/production NiFi instances, import that Process Group **by reference to the Registry**, and simply change its version to promote a new release — rather than manually recreating or copy-pasting flows between environments.
5. Combine with **Parameter Contexts** (section 4) so the *same* versioned flow definition can run with environment-appropriate values (different DB hosts, different credentials, etc.) in each environment.

This is the modern equivalent of what used to be done with the now-removed XML Template export/import mechanism, and it's a substantially more robust story for anyone treating NiFi flows as things that go through a real release process.

## 15. Performance Tuning

**Repository placement**: as mentioned in section 2, put the FlowFile, Content, and Provenance repositories on physically separate disks in any real deployment — their I/O patterns interfere with each other badly if colocated, and this is one of the highest-leverage tuning changes available.

**JVM heap sizing**: NiFi runs on the JVM; heap sizing (`bootstrap.conf`'s `java.arg.2`/`java.arg.3` for min/max heap) needs to be set deliberately based on your flow's complexity and FlowFile volume, not left at defaults for production workloads.

**Concurrent Tasks**: each processor's Scheduling tab lets you set how many threads it can use concurrently. Bumping this for a genuinely parallelizable, I/O-bound processor (like one making outbound HTTP calls) can meaningfully increase throughput — but doing it indiscriently across many processors can also just create thread contention, so it's a per-processor tuning decision based on actual bottleneck analysis (via Status History/Summary Table), not a blanket "turn everything up."

**Run Duration**: some processors let you configure how long they batch work per trigger before yielding the thread — trading a small amount of added latency for a meaningful increase in throughput on high-volume, low-per-item-cost processors.

**Back to Record processing**: this is worth repeating as a performance point, not just a "best practice" one — using Record-oriented processors instead of Split/Merge chains for structured data isn't just cleaner, it measurably avoids the overhead of instantiating and repository-tracking potentially millions of tiny individual FlowFiles for what's conceptually one dataset.

## 16. Common Pitfalls

Collecting these together since a purely conceptual list doesn't help as much as knowing where people actually get bitten:

- **Ignoring backpressure thresholds** until a slow downstream system causes a queue to grow unbounded and exhaust disk/memory.
- **Not separating repositories onto different disks**, then being confused why performance craters under real load.
- **Using content-manipulation/Split-Merge patterns for structured data** instead of Record processors, leading to excessive FlowFile counts and repository overhead.
- **Misunderstanding Primary Node**: forgetting to schedule single-source-of-truth processors (like one polling a single external REST endpoint) as "On Primary Node only," causing every cluster node to hit that external system redundantly.
- **Undersized or misconfigured ZooKeeper** for clustering — running an even number of ZK nodes, or relying on embedded ZooKeeper across more than a small test cluster, leading to flaky coordinator/leader election.
- **Letting the Provenance Repository grow unbounded** without a sensible retention policy (`nifi.provenance.repository.max.storage.time`/`.size` in `nifi.properties`), eventually filling disk.
- **Relying on outdated tutorials that reference XML Templates**, which no longer exist as of NiFi 2.x — if you're following a guide that talks about "Templates" as a current feature, it's describing the pre-2.x world.

## 17. A Worked Example

To tie the concepts together, here's a description of a small but realistic flow: **poll a REST API for records, filter out ones you don't want, convert to Avro, load into a database, with proper error handling.**

1. **`InvokeHTTP`** (timer-driven, e.g. every 5 minutes) — calls the source API, returns JSON in the FlowFile content.
2. **`QueryRecord`** (using a `JsonTreeReader` and an `AvroRecordSetWriter`, both Controller Services configured with the appropriate schema) — runs a SQL-like `SELECT * FROM FLOWFILE WHERE status = 'active'` against the incoming JSON, and writes matching records out as Avro in one step — this single processor is doing the job that would otherwise take a Split + filter + Merge chain.
3. Route the `QueryRecord` **failure** relationship (malformed JSON, schema mismatch, etc.) to an `UpdateAttribute` that sets an `error.reason` attribute, then to a `PutFile` writing into a local `dead-letter/` directory for later inspection — this is the dead-letter pattern from section 10.
4. Route the **matched** results relationship into **`PutDatabaseRecord`** (configured with an `AvroReader` and a `DBCPConnectionPool` Controller Service pointing at your target database) — this writes the Avro records directly into a table, again without any manual row-by-row logic.
5. Route `PutDatabaseRecord`'s **failure** relationship (a bad connection, a constraint violation) through the bounded-retry pattern from section 10: `UpdateAttribute` increments `retry.count`, `RouteOnAttribute` checks if it's under, say, 3, loops back to `PutDatabaseRecord` if so, or diverts to the same dead-letter path if the retries are exhausted.
6. On the connection *into* `PutDatabaseRecord`, set backpressure thresholds appropriate to expected volume (section 8), and consider a `PriorityAttributePrioritizer` if some records are more time-sensitive than others.
7. If this whole Process Group runs in a cluster and the API in step 1 is a single shared endpoint you don't want hit by every node, schedule `InvokeHTTP` to run **"On Primary Node"** only.

This single small flow already demonstrates: Record-oriented processing, Controller Service reuse, Expression Language (implicitly, wherever you'd parameterize the query or file paths), dead-letter error handling, bounded retry, backpressure/prioritization, and Primary Node awareness — which is most of what a real production NiFi flow actually needs to get right.

## 18. Where to Go Next

- **Official documentation**: `nifi.apache.org` — the User Guide, Admin Guide, and Developer Guide are all thorough and are the authoritative source, especially since NiFi's 2.x line is still actively evolving (currently well past 2.10.0, per the release history) and specifics can shift release to release.
- **Processor-specific documentation**: every processor has detailed built-in documentation (right-click → View Usage, or the `?` icon) explaining every property and relationship — this is often more useful than external tutorials, and it's guaranteed to match your actual installed version.
- **The NiFi mailing lists / Apache JIRA**: for anything you suspect might be a bug, or for tracking what's changing in upcoming releases.
- **Community content on Record-oriented processing and Parameter Contexts specifically**: since a large fraction of tutorials and Stack Overflow answers still in circulation predate these patterns (and predate 2.x entirely), it's worth deliberately seeking out newer material when learning these two areas in particular, rather than the first search result.