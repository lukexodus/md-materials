# Comprehensive Guide to Learning and Mastering OpenObserve

*Note on sourcing: OpenObserve (O2) is a smaller, faster-moving project than OpenTelemetry or Sentry, and my baseline knowledge of it was too thin to write reliably from memory. The architecture, terminology, and configuration details below are grounded in OpenObserve's official documentation, fetched directly for this guide. Where I'm reasoning from general observability-systems principles rather than an OpenObserve-specific source, I've said so.*

## 1. The Mental Model: What OpenObserve Actually Is

OpenObserve is a **cloud-native observability platform** that unifies logs, metrics, and traces into a single backend, built in Rust and positioned as a lower-cost, lower-operational-complexity alternative to the Elasticsearch/ELK stack and to the multi-component Grafana LGTM stack (Loki, Mimir, Tempo, Grafana) or commercial vendors like Datadog.

It's worth being precise about what makes it structurally different from OpenTelemetry and Sentry, since those were the last two things covered:

- **Unlike OpenTelemetry**, OpenObserve is not a vendor-neutral instrumentation standard — it's an actual backend with storage and a query engine. It happens to *accept* OTLP as one of several ingestion protocols, but its own data model and query layer are its own.
- **Unlike Sentry**, which is error-tracking-first with tracing added later, OpenObserve was built from the start as a unified store for all three signal types, with a single ingestion → storage → query pipeline underneath logs, metrics, and traces alike.

The two headline architectural choices that shape everything else about the product:

- **Object storage as the source of truth.** Ingested data is converted to **Parquet** files and written to object storage (S3, GCS, Azure Blob, or MinIO for self-hosted). This is the main lever behind OpenObserve's cost claims relative to Elasticsearch-style systems, which typically keep indexed data on more expensive local/attached disk.
- **SQL and PromQL, not a proprietary query language.** Logs and traces are queried with SQL; metrics with PromQL. If you already know either, you don't have to learn a new query DSL to use OpenObserve — this is a deliberate design choice, not an incidental one.

## 2. The Core Primitive: Streams

If OTel's load-bearing concept is context propagation and Sentry's is fingerprinting, OpenObserve's is the **Stream**.

A Stream is a logical container that holds exactly one type of observability data (logs, metrics, or traces), belongs to an organization, and has a unique name. Every single record — every log line, every metric point, every trace span — must be associated with a Stream at ingestion time; there's no such thing as ingesting data without one.

**Schema behavior is the first real decision point you'll hit**, and it differs between OpenObserve Cloud and self-hosted:

- **On Cloud**, defining fields when you create a Stream is optional — if you don't, OpenObserve auto-detects fields from whatever you send, and they show up under "All Fields" in the Stream Details page.
- **Self-hosted**, the "Add Stream" UI button is hidden by default; you enable it by setting `ZO_ALLOW_USER_DEFINED_SCHEMAS=true`. Once enabled, defining at least one field (name + data type) becomes *mandatory* at Stream creation, establishing a **User Defined Schema** — fields you didn't predefine still land, but under "All Fields" rather than the schema you declared.

Each field can also be assigned an **index type** (Secondary Index, Full Text Search, KeyValue Partition, Prefix Partition, or Hash Partition) — this is where you make the tradeoff between query flexibility and ingest/storage overhead per field, conceptually similar to deciding which columns to index in a traditional database.

**Practical implication**: unlike Sentry (where you mostly don't think about schema) or a raw OTel Collector (which is schema-agnostic and just forwards whatever it receives), OpenObserve makes you make a real schema decision — even if that decision is "let it auto-detect for now." Knowing this exists, and knowing where to look (Stream Details page) when a field isn't showing up where you expect, will save you real debugging time.

## 3. Architecture: How Data Actually Moves

This is the layer I'd flag as most worth understanding deeply if you're operating this in production, not just using it.

### 3.1 The Five Node Types

In HA (High Availability) mode, OpenObserve is composed of five horizontally-scalable node types:

- **Router** — a lightweight proxy that dispatches incoming requests to either an Ingester or a Querier, and also serves the web GUI.
- **Ingester** — receives ingestion requests, converts data to Parquet, and writes it to object storage (details below).
- **Compactor** — merges small Parquet files into larger ones for query efficiency, enforces retention policy, and handles stream deletions.
- **Querier** — stateless nodes that execute searches.
- **AlertManager** — runs scheduled alert queries and sends notifications.

In **single-node mode** (the default, meant for lighter usage/testing), all of this collapses into one process, backed by either local disk or, optionally, object storage, with SQLite for metadata. In **HA mode**, this is explicitly not supported on local disk — you need object storage, plus **NATS** as the cluster coordinator and **PostgreSQL** for metadata (organizations, users, stream schemas, the file-list index).

### 3.2 The Ingestion Pipeline (What Actually Happens to a Log Line)

This is worth understanding step by step, because each stage explains a real operational property:

1. The Ingester receives data via HTTP or gRPC.
2. Any configured **ingest functions** (transform logic) run, in order.
3. A timestamp is resolved — from the record if present, otherwise set to ingest time.
4. The Stream's schema is checked; if it needs to evolve (new fields, changed types), a lock is acquired to update it.
5. Real-time alerts defined on the Stream are evaluated.
6. Data is written to a **WAL (Write-Ahead Log)** file in hourly buckets, and simultaneously converted to an Arrow RecordBatch in an in-memory **Memtable** (one Memtable per organization/stream-type pair).
7. When the Memtable hits `ZO_MAX_FILE_SIZE_IN_MEMORY` (default 256 MB) or its paired WAL file hits `ZO_MAX_FILE_SIZE_ON_DISK` (default 128 MB), it's marked Immutable and a fresh Memtable/WAL pair starts.
8. Every `ZO_MEM_PERSIST_INTERVAL` (default 5 seconds), Immutables are flushed to local-disk Parquet files.
9. Every `ZO_FILE_PUSH_INTERVAL` (default 10 seconds), small local Parquet files that have exceeded a size or age threshold get merged into a larger file (up to `ZO_COMPACT_MAX_FILE_SIZE`, default 2 GB) and pushed to object storage.

**Why this matters practically**: at any given moment, unflushed data lives in three places — the in-memory Memtable, the Immutable-but-not-yet-pushed state, and local Parquet files not yet in object storage — and a query needs to account for all three, which the Querier does. If you're debugging "why isn't my just-ingested data showing up," the answer is often "it hasn't crossed one of these flush intervals yet," not that ingestion failed.

### 3.3 Why a Single In-Flight Copy Is an Intentional Choice, Not a Gap

OpenObserve's own architecture documentation makes an explicit, reasoned case for *not* replicating data multiple times before it reaches object storage, and it's worth understanding the reasoning rather than just the conclusion: modern block storage (e.g., AWS EBS gp3/io2) is already highly durable within an availability zone, cross-AZ replication carries a real cost (their docs cite roughly 2¢/GB round-trip on AWS), and once data lands in S3-class storage, durability is effectively total. Given that, additional in-app replication before the object-storage handoff mostly adds cost and complexity without a proportionate durability gain. This is a deliberate simplicity-and-cost tradeoff, not an oversight — and it's a good example of a design decision that only makes sense once you understand modern cloud storage durability guarantees, which is presumably why they explain it rather than just asserting it.

### 3.4 How Queries Execute

Queries follow a **LEADER/WORKER** pattern: whichever Querier node receives the search request becomes the LEADER for that query, other Queriers become WORKERs. The LEADER parses the SQL, determines the relevant file list from the time range, partitions that file list evenly across available Queriers (including itself), dispatches the sub-searches over gRPC, and merges the results. Queriers also cache Parquet files in memory (by default up to 50% of available memory, tunable via `ZO_MEMORY_CACHE_MAX_SIZE`), and each Querier in a distributed setup only caches part of the overall dataset. Enterprise deployments additionally support **Federated Search**, extending this same LEADER/WORKER pattern across multiple *clusters*, not just nodes within one cluster.

## 4. Getting It Running

### 4.1 Cloud vs. Self-Hosted

**OpenObserve Cloud** is the fastest path: sign up, then get an ingestion cURL command from the Data Sources section that already contains your credentials and endpoint (shaped like `https://api.openobserve.ai/api/[YOUR_ORG]/default/_json`).

**Self-hosted**, for single-node testing, the minimal Docker path is:

```bash
docker run -v $PWD/data:/data \
  -e ZO_DATA_DIR="/data" \
  -p 5080:5080 \
  -e ZO_ROOT_USER_EMAIL="root@example.com" \
  -e ZO_ROOT_USER_PASSWORD="Complexpass#123" \
  o2cr.ai/openobserve/openobserve-enterprise:latest
```

`ZO_ROOT_USER_EMAIL` and `ZO_ROOT_USER_PASSWORD` only need to be set on first startup — they're not required on subsequent runs. After that, the web UI is at `http://localhost:5080`.

**A concrete trap worth naming explicitly**: the ingestion URL path is shaped `/api/{organization}/{stream_name}/_json`. Self-hosted, both default to literally `default` — so the URL looks like `/api/default/default/_json`, where the first `default` is the *organization* and the second is the *stream*. It's easy to misread this as one redundant segment rather than two distinct identifiers, and that confusion is a genuinely common source of "why is my data going to the wrong place" for people setting this up for the first time.

### 4.2 Verifying and Loading Sample Data

The documented quickstart loads a real sample Kubernetes log dataset via curl, then confirms ingestion via a JSON response like `{"code":200,"status":"ok","records":1000}` — checking for that response shape (rather than just "the request didn't error") is a reasonable sanity check to build into any setup script.

## 5. Querying Your Data

Because OpenObserve deliberately avoids inventing a proprietary query language:

- **Logs and traces** are queried with **SQL** against the Stream, directly in the Logs UI, or via the Search API.
- **Metrics** are queried with **PromQL**, which — if you're coming from Prometheus or Grafana — means your existing query knowledge transfers directly rather than needing to be relearned.

Basic log searches in the UI can be as simple as a bare `match_all('error')` full-text search, or a structured filter like `level='error'` against a field, depending on whether you're doing full-text search or filtering on a specific typed field from your schema (Section 2).

## 6. Pipelines: Controlling Data After Ingestion

**Pipelines** are OpenObserve's mechanism for transforming, filtering, and routing data after it's ingested but as (or after) it flows through the system. Every pipeline shares the same three building blocks — **Source** (where data is read from), **Transform** (how it's changed or filtered), **Destination** (where it's written) — and comes in two types:

### 6.1 Real-Time Pipelines

Process data as it's ingested into the source Stream. A meaningful constraint: **each Stream can be the source of only one real-time pipeline** — this forces a single, predictable processing path per Stream rather than letting multiple competing pipelines race on the same data.

A safety behavior worth knowing explicitly: when you set a source Stream for a real-time pipeline, OpenObserve **automatically adds a default destination pointing back to that same Stream**, so your original, unfiltered data keeps landing there even after you add transforms. If you remove that default destination and only keep filtered/routed ones, anything that doesn't match your filter conditions gets silently dropped rather than falling back to the source Stream — worth knowing before you're debugging "missing" data that was actually filtered out by design.

### 6.2 Scheduled Pipelines

Run a SQL (or PromQL, for metrics) query against historical data in a source Stream at a defined interval — configured via **Frequency** (how often it runs), **Period** (how much data it reads per run), and an optional **Cron** expression for custom schedules in a specific timezone. Useful for periodic ETL, report generation, or batch processing rather than continuous real-time transformation. Destinations can additionally include **Enrichment Tables** — a destination type that's valid *only* for scheduled pipelines, not real-time ones.

### 6.3 Functions vs. Pipelines

**Functions** are the actual transform logic (parsing, enrichment, filtering rules) that get referenced inside a Pipeline's Transform stage — Pipelines are the routing/orchestration layer; Functions are what actually runs on the data within them. Treat "create a Function" and "wire it into a Pipeline" as two separate steps in your mental model, not one.

## 7. Alerts

Alerts follow the same real-time/scheduled conceptual split as Pipelines, which is a genuinely useful pattern to recognize once you see it: **Real-time alerts** evaluate conditions as data is ingested (this is literally step 5 of the ingestion pipeline in Section 3.2 — alert evaluation happens inline during ingest, not as a separate afterthought process). **Scheduled alerts** run periodic queries against a Stream, similar in structure to scheduled pipelines. This shared real-time/scheduled split across both Pipelines and Alerts isn't a coincidence worth memorizing as two unrelated facts — it reflects one underlying execution model (inline-at-ingest vs. periodic-query) applied to two different features.

## 8. Retention, Compaction, and Operating at Scale

- **Retention** is set per-Stream, in days, at creation (with an option for Extended Retention beyond the default window) — after which OpenObserve automatically removes the data.
- **Compaction** (Section 3.1) isn't just a performance nicety — it's also the mechanism that enforces retention and handles full-stream deletion, so the Compactor node is doing real operational work, not just query optimization.
- **Caching** at the Querier level (Section 3.4) is the main lever for query performance at scale; `ZO_MEMORY_CACHE_MAX_SIZE` is the knob most worth knowing about if searches feel slow under load.

## 9. Organizations and Access Control

Streams belong to **Organizations**, and access is governed by **RBAC** (available on Cloud and Enterprise self-hosted): roles range from **Root** (full cross-organization access) through **Admin/Editor** (full stream management within their org), **Viewer** (read-only), and **User** (no stream visibility), plus custom roles with granularly-assigned permissions. This is the layer to reach for once more than one person or team is operating the same OpenObserve instance — pipeline and stream permissions are both gated through the same RBAC/role system, not separate ad hoc mechanisms.

## 10. A Path to Mastery — Self-Check

You can consider yourself genuinely competent, not just familiar, with OpenObserve when you can:

1. Explain what a Stream is, the self-hosted vs. Cloud difference in schema behavior, and correctly predict where an unexpected field will show up (Section 2)
2. Walk through what happens to a single ingested log line from HTTP request to queryable Parquet file in object storage, including which flush/push intervals govern each stage (Section 3.2)
3. Correctly construct a self-hosted ingestion URL and explain why `/api/default/default/_json` has two distinct `default` segments, not one redundant one (Section 4.1)
4. Write both a real-time and a scheduled Pipeline, and explain the default-destination safety behavior well enough to predict when data would be silently dropped instead of routed (Section 6)
5. Explain why real-time alert evaluation happens as part of the ingestion pipeline rather than as a separate polling process (Section 7)
6. Explain, in your own words, why OpenObserve's docs argue that skipping in-app data replication before the object-storage handoff is a reasoned tradeoff rather than a durability gap (Section 3.3)
7. Query the same dataset comfortably in both SQL (logs/traces) and PromQL (metrics) without needing to look up either

If you can do all seven, you've moved from "I got OpenObserve running" to actually operating it as a mature part of your stack.