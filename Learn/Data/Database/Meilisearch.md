# The Definitive Meilisearch Guide
### For Production Web Development with PostgreSQL, Node.js, Fastify, React, Next.js, and TypeScript

---

> **Accuracy conventions used throughout this document**
>
> - `[Inference]` — logically reasoned from available information, not independently confirmed
> - `[Speculation]` — unconfirmed possibility; behavior not guaranteed
> - `[Unverified]` — no reliable primary source confirmed at time of writing
>
> LLM behavior claims and version-specific details are labeled where applicable. Always verify against the official Meilisearch documentation at [https://www.meilisearch.com/docs](https://www.meilisearch.com/docs) before making architectural decisions.

---

## Table of Contents

1. [Search Fundamentals](#part-1--search-fundamentals)
2. [Why Databases Are Not Search Engines](#part-2--why-databases-are-not-search-engines)
3. [Search Engine Concepts](#part-3--search-engine-concepts)
4. [Meilisearch Fundamentals](#part-4--meilisearch-fundamentals)
5. [Internal Architecture](#part-5--internal-architecture)
6. [Installation and Environment Setup](#part-6--installation-and-environment-setup)
7. [Security Fundamentals](#part-7--security-fundamentals)
8. [Core API Usage](#part-8--core-api-usage)
9. [Document Management](#part-9--document-management)
10. [Search Operations](#part-10--search-operations)
11. [Ranking and Relevance](#part-11--ranking-and-relevance)
12. [Filters](#part-12--filters)
13. [Sorting](#part-13--sorting)
14. [Faceted Search](#part-14--faceted-search)
15. [Typo Tolerance and Synonyms](#part-15--typo-tolerance-and-synonyms)
16. [Frontend Integration](#part-16--frontend-integration)
17. [Backend Integration](#part-17--backend-integration)
18. [PostgreSQL + Meilisearch Architecture](#part-18--postgresql--meilisearch-architecture)
19. [Synchronization Strategies](#part-19--synchronization-strategies)
20. [Data Modeling](#part-20--data-modeling)
21. [Performance Engineering](#part-21--performance-engineering)
22. [Scaling](#part-22--scaling)
23. [Production Operations](#part-23--production-operations)
24. [Multi-Tenancy](#part-24--multi-tenancy)
25. [Comparisons](#part-25--comparisons)
26. [Common Pitfalls](#part-26--common-pitfalls)
27. [Complete Production Project](#part-27--complete-production-project)

---

## Part 1 — Search Fundamentals

### What Search Actually Is

Search is the problem of retrieving a small, relevant subset of a large collection in response to a human-expressed intent.

That definition contains two hard sub-problems:

1. **Relevance** — determining which items from the collection best match the intent
2. **Ranking** — ordering those items so the most relevant appear first

A database can answer "give me all rows where `title = 'PostgreSQL'`." That is a lookup, not a search. Search must handle the fuzzier question: "give me the things most likely to satisfy what this person is trying to accomplish."

### Information Retrieval

**Information retrieval (IR)** is the academic field underlying search. It formalizes problems like:

- How do you represent documents mathematically?
- How do you score a document's relevance to a query?
- How do you rank a result set?

Modern search engines are applied IR systems. Understanding a few core IR concepts makes Meilisearch's design decisions legible.

#### The Vocabulary Mismatch Problem

Users and authors often use different words for the same concept. A user searches "car" but articles use "automobile." This mismatch is a fundamental IR challenge. Solutions include synonyms, stemming, and embedding-based semantic search.

### Relevance

Relevance is a measure of how well a document satisfies a query's underlying intent. It is inherently subjective and context-dependent.

There is no universal relevance function. A search for "Python" in a programming context should rank language documentation above snake articles. The same query in a wildlife database should rank the opposite way. Relevance is always relative to the corpus and the user population.

Search engines approximate relevance using signals:

- **Term frequency** — how often the query term appears in a document
- **Inverse document frequency** — how rare the term is across all documents (rare terms are more discriminating)
- **Field weight** — a match in a title is usually more relevant than a match in body text
- **Position** — a match at the start of a field often signals more relevance than a match at the end

**TF-IDF** (term frequency–inverse document frequency) is the classic relevance model. BM25 is an improved variant used widely today, including in Elasticsearch and Typesense.

Meilisearch uses a different approach: a **ranking rule pipeline** that applies deterministic rules in order rather than a single floating-point score. This is discussed in Part 11.

### Ranking

Ranking is the ordering of a result set by estimated relevance. Good ranking is what separates useful search from useless search.

Ranking is difficult because:

- Relevance is multidimensional (text match, freshness, popularity, user context)
- Different users want different orderings for the same query
- Business rules often override pure relevance (promoted products, editorial picks)

### Search Quality

Search quality is measured in terms of:

- **Precision** — of the returned results, how many are actually relevant?
- **Recall** — of all relevant documents, how many were returned?

These metrics trade off. A search that returns everything has perfect recall but poor precision. A search that returns only one perfect result has perfect precision but poor recall.

Production search systems tune this tradeoff based on their use case. Autocomplete favors precision. Document search often favors recall.

### Exact, Partial, and Fuzzy Matching

**Exact matching** requires the query string to appear verbatim in the document. Fast and deterministic. Used in database `=` operators. Fails if the user spells anything differently.

**Partial matching** requires part of the query to match. A prefix match on `"Post"` returns `"PostgreSQL"`. Used for autocomplete. Still brittle to typos.

**Fuzzy matching** tolerates differences between the query and the document. A fuzzy match on `"Postgras"` can still return `"PostgreSQL"` by allowing a small edit distance. This is the edit distance (Levenshtein distance): the minimum number of single-character insertions, deletions, or substitutions to transform one string into the other.

`"Postgras"` → `"PostgreSQL"` requires several edits. A fuzzy search engine sets a threshold — typically 1 or 2 edits — and allows matches within that distance.

Meilisearch has built-in typo tolerance. This is covered in Part 15.

### Full-Text Search

**Full-text search** operates on the content of text fields rather than exact field values. The text is analyzed (tokenized, normalized, stemmed) and stored in an inverted index. Queries are also analyzed the same way before matching.

Full-text search answers: "find all documents containing words related to this query."

### Structured Search

**Structured search** uses explicit field-level predicates: `price < 100`, `category = "electronics"`, `published_at > 2024-01-01`. These are not text searches. They require indexed, typed field values.

Modern search engines support both full-text and structured search simultaneously: "find documents matching the query text, then filter by structured criteria."

### Why Search Is a Separate Problem from Data Storage

Databases are optimized for storing and retrieving structured records with transactional consistency. Their indexes (B-trees, hash indexes) are built for equality and range lookups.

Search engines are optimized for text analysis and relevance ranking. Their indexes (inverted indexes) are built for fast multi-term lookups with ranking.

The data structures, consistency models, and query semantics are fundamentally different. Trying to do search well in a general-purpose database produces friction. This is not a limitation of databases — it is a consequence of different design goals.

---

## Part 2 — Why Databases Are Not Search Engines

### PostgreSQL `LIKE` and `ILIKE`

`LIKE` performs pattern matching using `%` (any sequence) and `_` (any single character) wildcards.

```sql
SELECT * FROM products WHERE name LIKE '%laptop%';
```

`ILIKE` is the case-insensitive variant.

**Problems:**

- A leading `%` (e.g. `'%laptop%'`) prevents index use. PostgreSQL must scan the full table.
- No relevance ranking. Results are unordered beyond the query's `ORDER BY`.
- No typo tolerance.
- No partial word matching except through explicit wildcards.
- Performance degrades linearly with table size.

### PostgreSQL Full-Text Search

PostgreSQL includes a real full-text search subsystem based on `tsvector` and `tsquery`.

```sql
-- Create a search vector
SELECT to_tsvector('english', 'The quick brown fox jumps over the lazy dog');
-- Result: 'brown':3 'dog':9 'fox':4 'jump':5 'lazi':8 'quick':2

-- Search using tsquery
SELECT * FROM articles
WHERE to_tsvector('english', body) @@ to_tsquery('english', 'jump & fox');
```

A `GIN` index on the `tsvector` column makes this fast:

```sql
CREATE INDEX idx_articles_fts ON articles
USING GIN(to_tsvector('english', body));
```

**Strengths:**

- No external dependency
- Transactionally consistent with your data
- Supports stemming (via dictionaries)
- Supports ranking via `ts_rank()`
- Supports phrase search

**Limitations:**

- Configuration is complex and verbose
- Ranking is basic compared to dedicated engines
- No built-in typo tolerance
- Facet generation requires manual SQL aggregation
- No instant search or autocomplete without significant extra work
- Schema changes require reindexing
- Performance with complex queries on large tables can be an issue
- No built-in synonym management UI

### Comparing PostgreSQL and Meilisearch

| Capability | PostgreSQL FTS | Meilisearch |
|---|---|---|
| Transactional consistency | ✅ Full ACID | ❌ Eventually consistent |
| Typo tolerance | ❌ Not built-in | ✅ Built-in |
| Relevance ranking | Basic `ts_rank` | Configurable pipeline |
| Facets | Manual SQL | Built-in |
| Autocomplete / instant search | Complex | Built-in |
| Synonyms UI | No | Yes |
| Configuration complexity | High | Low |
| External dependency | None | Separate service |
| Operational burden | Low (already running PG) | Additional service |
| Horizontal scaling | Via read replicas | Limited (see Part 22) |

### Where Each Belongs in a Modern Architecture

Use PostgreSQL for:

- All write operations (source of truth)
- Transactional queries requiring consistency
- Relational joins
- Reporting and aggregation
- Queries that require row-level security integrated with your auth model

Use Meilisearch for:

- User-facing search boxes
- Autocomplete
- Faceted navigation
- Any query that needs typo tolerance
- Any query that needs relevance ranking
- Any feature where search UX quality matters to users

The canonical architecture: **PostgreSQL is the source of truth; Meilisearch is a read replica optimized for search.** All writes go to PostgreSQL. Changes are synchronized to Meilisearch asynchronously.

---

## Part 3 — Search Engine Concepts

### Documents

A **document** is the atomic unit of search. Everything you search for is a document. A document is a flat or nested collection of key-value pairs.

```json
{
  "id": "prod-123",
  "title": "Mechanical Keyboard - TKL Layout",
  "brand": "Keychron",
  "price": 89.99,
  "category": "keyboards",
  "in_stock": true,
  "description": "80% tenkeyless layout with hot-swap switches..."
}
```

Documents are not tables. They do not have enforced schemas. Different documents in the same index can have different fields (though consistency is a good practice).

### Indexes

An **index** is a named collection of documents with its own settings (ranking rules, filterable attributes, synonyms, etc.).

An index is analogous to a table in a database, but the analogy breaks down quickly. Indexes hold documents; they are configured for search behavior; they are asynchronously updated.

Every index has exactly one **primary key** — the field that uniquely identifies each document.

### Fields and Attributes

A **field** is a key-value pair within a document. The term **attribute** is used in Meilisearch to refer specifically to fields that have been configured for search behavior (filterable, sortable, searchable).

The distinction matters: all attributes are fields, but not all fields need to be configured as attributes unless you need to filter, sort, or search on them.

### Tokens and Tokenization

**Tokenization** is the process of splitting text into individual units called **tokens** for indexing.

For example, the string `"The quick brown fox"` tokenizes to:
`["The", "quick", "brown", "fox"]`

Tokenization is language-dependent. English splits on whitespace and punctuation. Chinese and Japanese require different approaches (character-based or dictionary-based segmentation).

After tokenization, tokens are typically **normalized**: lowercased, stripped of diacritics, etc.

```
"Café au Lait" → ["cafe", "au", "lait"]
```

The normalized tokens are stored in an **inverted index**: a data structure mapping each token to the list of documents containing it.

```
"cafe" → [doc-4, doc-17, doc-88]
"lait" → [doc-4, doc-99]
```

A search query is tokenized the same way, then the system looks up which documents contain all (or most) of the query tokens.

### Stop Words

**Stop words** are common words that appear in almost every document and carry little discriminating value: "the", "a", "is", "in", "of".

Including stop words in the index wastes space and degrades ranking. Most search engines filter them out during tokenization.

You can configure custom stop words for domain-specific terms. In a legal document corpus, "hereby" and "whereas" might behave as stop words.

### Synonyms

**Synonyms** allow semantically equivalent terms to match each other even when the exact word is absent.

Examples:
- `"car"` ↔ `"automobile"` ↔ `"vehicle"`
- `"js"` ↔ `"javascript"`
- `"kb"` ↔ `"kilobyte"`

Synonyms can be **bidirectional** (searching either returns the same results) or **one-directional** (searching "js" returns JavaScript content, but searching "javascript" does not necessarily return js-tagged content).

### Stemming

**Stemming** reduces words to their root form so that morphological variants match each other.

Examples:
- `"running"`, `"runs"`, `"ran"` all stem to `"run"`
- `"keyboards"` stems to `"keyboard"`

This increases recall: a search for "run" also matches "running." Meilisearch does not use traditional stemming by default. It uses a different approach for handling word variations. [Unverified: exact stemming implementation details vary by Meilisearch version — verify in official docs.]

### Typo Tolerance

**Typo tolerance** allows queries containing spelling errors to match correct documents by permitting a small edit distance between query tokens and index tokens.

This is distinct from synonyms. Synonyms handle semantic equivalence. Typo tolerance handles mechanical transcription errors.

### Facets

A **facet** is a dimension of the data that can be used to narrow search results interactively.

Facets appear as filter panels in search UIs:

```
Brand
  ☑ Keychron (42)
  ☐ Ducky (18)
  ☐ Leopold (11)

Price Range
  ☐ Under $50 (12)
  ☑ $50–$100 (38)
  ☐ $100+ (21)
```

The numbers in parentheses are **facet counts** — the number of documents matching that facet value within the current result set.

Facets require the engine to perform aggregations as part of search. This is computationally expensive if not built into the engine's architecture.

### Filters

**Filters** narrow the result set using structured criteria: equality, range, boolean, null checks.

Filters are applied before ranking — they constrain which documents are candidates.

```
brand = "Keychron" AND price < 100 AND in_stock = true
```

### Ranking

**Ranking** is the process of ordering the candidate documents by estimated relevance.

The ranking algorithm is the heart of a search engine. Poor ranking ruins the user experience even when the result set is correct.

### Relevance Scoring

Different engines compute relevance differently:

- Elasticsearch/OpenSearch: BM25 floating-point score
- Meilisearch: Ordered ranking rules pipeline (deterministic)
- Algolia: Similar pipeline approach to Meilisearch

Meilisearch does not expose numeric scores in search results by default. Results are sorted by the ranking rules pipeline outcome.

---

## Part 4 — Meilisearch Fundamentals

### What Meilisearch Is

Meilisearch is an open-source, RESTful search engine written in Rust. It is designed to be fast, easy to configure, and developer-friendly.

Key design properties:

- **Instant search** — responses in under 50ms for typical datasets
- **Typo tolerance by default** — no configuration required to get started
- **Simple HTTP API** — no complex query DSL
- **Easy self-hosting** — single binary or Docker container
- **Open source** — MIT-licensed core

### Design Philosophy

Meilisearch is deliberately opinionated. Where Elasticsearch gives you hundreds of configuration knobs, Meilisearch gives you fewer, with sensible defaults.

The tradeoff: Meilisearch is faster to get working and easier to operate, but offers less flexibility for highly specialized search requirements.

### Typical Use Cases

- E-commerce product search
- Documentation site search
- SaaS application search boxes
- Content management system search
- Directory search (users, companies, locations)
- Any feature where users type into a search box

### When Not to Use Meilisearch

- When you need **log analytics** at scale (use Elasticsearch/OpenSearch)
- When you need **full ACID consistency** for search (use PostgreSQL FTS if correctness is paramount)
- When you need **vector/semantic search** as the primary feature (dedicated vector DBs or Elasticsearch with dense_vector)
- When your dataset is hundreds of millions of documents with petabyte-scale indexes [Unverified: exact upper limits — verify against current Meilisearch documentation]
- When you need **complex aggregations and analytics** (use Elasticsearch or a data warehouse)

### Core Concepts

#### Instance

A **Meilisearch instance** is a running Meilisearch process. It exposes an HTTP API, typically on port 7700. One instance manages multiple indexes.

#### Index

An **index** is a named collection of documents with its own settings. Settings are per-index: ranking rules, filterable attributes, searchable attributes, synonyms, stop words, typo tolerance, and pagination limits.

Creating an index:

```
POST /indexes
{ "uid": "products", "primaryKey": "id" }
```

#### Document

A **document** is a JSON object stored in an index. It must contain the primary key field.

```json
{
  "id": "prod-123",
  "title": "Mechanical Keyboard",
  "price": 89.99
}
```

#### Primary Key

The **primary key** is the field that uniquely identifies each document in an index. It must be unique across all documents. If not specified when creating the index, Meilisearch infers it from the first document added.

Best practice: always specify the primary key explicitly when creating the index.

#### Tasks

Meilisearch operations that modify data (adding documents, updating settings, deleting documents) are **asynchronous**. When you send such a request, Meilisearch immediately returns a **task** object:

```json
{
  "taskUid": 42,
  "indexUid": "products",
  "status": "enqueued",
  "type": "documentAdditionOrUpdate",
  "enqueuedAt": "2024-01-15T10:30:00Z"
}
```

The task is queued and processed in the background. You can poll the task endpoint to check completion.

This asynchronous design is fundamental. Read operations (search) are always available. Write operations are queued and applied without blocking.

#### Settings

**Settings** control search behavior at the index level. Key settings:

- `searchableAttributes` — which fields are searched
- `filterableAttributes` — which fields can be filtered
- `sortableAttributes` — which fields can be sorted
- `rankingRules` — the ranking pipeline order
- `synonyms` — synonym mappings
- `stopWords` — words to ignore
- `typoTolerance` — typo tolerance configuration
- `faceting` — facet result limits
- `pagination` — max results per search

Settings changes are also asynchronous tasks.

---

## Part 5 — Internal Architecture

### Indexing Pipeline

When you add a document to Meilisearch, it passes through a multi-stage pipeline:

```mermaid
flowchart LR
    A[HTTP Request\nwith documents] --> B[Task Queue\nenqueue]
    B --> C[Task Worker\ndequeue]
    C --> D[Document\nValidation]
    D --> E[Tokenization\n& Normalization]
    E --> F[Inverted Index\nUpdate]
    F --> G[Field Store\nUpdate]
    G --> H[Task marked\nProcessed]
```

**Stage by stage:**

1. **HTTP Request** — You POST documents to `/indexes/{uid}/documents`
2. **Task Queue** — The request is serialized to the task queue immediately; the HTTP response returns the task ID
3. **Task Worker** — A background worker dequeues and processes tasks sequentially per index
4. **Document Validation** — Documents are checked for the primary key; invalid documents are rejected
5. **Tokenization and Normalization** — Text fields are tokenized, normalized (lowercased, diacritics removed), and processed through the configured stop-word list
6. **Inverted Index Update** — Each token is mapped to the documents containing it, with position information
7. **Field Store Update** — The raw document fields are stored for result retrieval and filtering
8. **Task Completion** — The task status is updated to `succeeded` or `failed`

### Search Pipeline

```mermaid
flowchart LR
    A[Search Query] --> B[Query\nTokenization]
    B --> C[Candidate\nRetrieval\nfrom Inverted Index]
    C --> D[Filter\nApplication]
    D --> E[Ranking\nPipeline]
    E --> F[Pagination]
    F --> G[Result\nFormatting]
    G --> H[HTTP Response]
```

1. **Query Tokenization** — The query string is tokenized and normalized the same way as documents
2. **Candidate Retrieval** — The inverted index is consulted to find documents matching query tokens, including typo-tolerant candidates
3. **Filter Application** — Structured filters (price < 100, category = "X") narrow the candidate set
4. **Ranking Pipeline** — Candidates are ordered by the ranking rules (Part 11)
5. **Pagination** — The result window (offset/limit or page/hitsPerPage) is applied
6. **Result Formatting** — Matched fields are highlighted; facet counts are computed
7. **HTTP Response** — Results returned, typically within tens of milliseconds

### Storage

Meilisearch uses LMDB (Lightning Memory-Mapped Database) as its embedded storage engine. LMDB is a key-value store that maps directly to memory, enabling fast reads. [Unverified: internal storage engine details — verify against current Meilisearch documentation as this may have changed across versions.]

Data is stored on disk. The storage path is configurable (default: `./data.ms`).

### Task Queue

Tasks are processed sequentially per index by default. Multiple indexes can be updated concurrently but within one index, tasks are ordered.

This sequential processing ensures no partial state during indexing: a search always reflects a consistent snapshot of completed tasks.

### What Happens When a Document Is Indexed

1. Client sends `POST /indexes/products/documents` with 1000 documents
2. Meilisearch enqueues a single `documentAdditionOrUpdate` task, returns `{ taskUid: 5 }`
3. Worker picks up task
4. Each document is parsed and validated
5. Existing documents with matching primary keys are updated (upsert semantics)
6. All text fields in `searchableAttributes` are tokenized
7. Inverted index entries are written to LMDB
8. Raw documents are written to the document store
9. Task status updated to `succeeded`

### What Happens When a Search Is Executed

1. Client sends `GET /indexes/products/search?q=keyboard&filter=price<100`
2. Query `"keyboard"` is tokenized to `["keyboard"]`
3. Inverted index lookup returns all documents containing `"keyboard"` (and typo variants within tolerance)
4. Filter `price < 100` is applied — documents with price ≥ 100 are excluded
5. Remaining candidates are scored by the ranking pipeline
6. Top N results are returned with hit highlighting

---

## Part 6 — Installation and Environment Setup

### Local Development

#### Docker (Recommended)

```bash
docker run -it --rm \
  -p 7700:7700 \
  -v $(pwd)/meili_data:/meili_data \
  getmeili/meilisearch:latest \
  meilisearch --master-key="your-dev-master-key"
```

Verify:

```bash
curl http://localhost:7700/health
# {"status":"available"}
```

#### Docker Compose

Create `docker-compose.yml`:

```yaml
version: "3.8"

services:
  meilisearch:
    image: getmeili/meilisearch:latest
    container_name: meilisearch
    ports:
      - "7700:7700"
    environment:
      MEILI_MASTER_KEY: ${MEILI_MASTER_KEY:-dev-master-key-change-in-production}
      MEILI_ENV: development
    volumes:
      - meilisearch_data:/meili_data
    restart: unless-stopped

  postgres:
    image: postgres:16
    container_name: postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-appuser}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-apppassword}
      POSTGRES_DB: ${POSTGRES_DB:-appdb}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  meilisearch_data:
  postgres_data:
```

`.env`:

```
MEILI_MASTER_KEY=dev-master-key-change-in-production
POSTGRES_USER=appuser
POSTGRES_PASSWORD=apppassword
POSTGRES_DB=appdb
```

Start:

```bash
docker compose up -d
```

#### Binary Installation

```bash
# Linux/macOS
curl -L https://install.meilisearch.com | sh

# Start with master key
./meilisearch --master-key="your-master-key"
```

### Production Deployment

#### VPS Deployment with Systemd

Create `/etc/systemd/system/meilisearch.service`:

```ini
[Unit]
Description=Meilisearch
After=network.target

[Service]
User=meilisearch
Group=meilisearch
WorkingDirectory=/var/lib/meilisearch
ExecStart=/usr/bin/meilisearch \
  --db-path /var/lib/meilisearch/data \
  --http-addr 127.0.0.1:7700 \
  --master-key ${MEILI_MASTER_KEY} \
  --env production \
  --log-level INFO
Restart=on-failure
EnvironmentFile=/etc/meilisearch/env

[Install]
WantedBy=multi-user.target
```

`/etc/meilisearch/env`:

```
MEILI_MASTER_KEY=your-secure-random-master-key
```

```bash
sudo useradd -r -s /bin/false meilisearch
sudo mkdir -p /var/lib/meilisearch/data
sudo chown -R meilisearch:meilisearch /var/lib/meilisearch
sudo systemctl enable meilisearch
sudo systemctl start meilisearch
```

#### Nginx Reverse Proxy

`/etc/nginx/sites-available/meilisearch`:

```nginx
server {
    listen 443 ssl http2;
    server_name search.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/search.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/search.yourdomain.com/privkey.pem;

    # Only allow specific endpoints for public access
    location /indexes/ {
        # Block admin operations from public internet
        # The search API key in the frontend limits what can be done
        proxy_pass http://127.0.0.1:7700;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Rate limiting
        limit_req zone=search_limit burst=20 nodelay;
    }

    # Block master-key-requiring endpoints from public internet
    location ~ ^/(keys|tasks|stats|health|version|dumps|snapshots)/ {
        allow 10.0.0.0/8;  # Internal network only
        deny all;
        proxy_pass http://127.0.0.1:7700;
    }
}

# Rate limiting zone
http {
    limit_req_zone $binary_remote_addr zone=search_limit:10m rate=30r/m;
}
```

#### Production Docker Compose

```yaml
version: "3.8"

services:
  meilisearch:
    image: getmeili/meilisearch:v1.7.0  # Pin the version in production
    container_name: meilisearch_prod
    environment:
      MEILI_MASTER_KEY: ${MEILI_MASTER_KEY}
      MEILI_ENV: production
      MEILI_DB_PATH: /meili_data
      MEILI_LOG_LEVEL: INFO
      MEILI_MAX_INDEXING_MEMORY: 2Gb
    volumes:
      - meilisearch_data:/meili_data
    restart: always
    networks:
      - internal
    # Do NOT expose port 7700 directly to the internet
    # Access via nginx reverse proxy

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - meilisearch
    networks:
      - internal
      - external
    restart: always

networks:
  internal:
    internal: true
  external:

volumes:
  meilisearch_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/meilisearch  # Mount a dedicated volume
```

#### Persistence and Storage

Always mount a volume at the Meilisearch data path. If the container restarts without a mounted volume, all indexed data is lost.

For production, the data directory should be on a fast SSD. Meilisearch is I/O-intensive during indexing.

Recommended disk sizing [Inference based on general search engine guidance — verify with Meilisearch documentation]:

- Index size is typically 2–10× the size of the raw JSON data
- Add headroom for temporary files during indexing
- For 1M small documents (~1KB each): plan for ~10–20GB

#### Backups

Meilisearch supports **dumps**: full snapshots of all indexes and settings.

```bash
# Create a dump via API
curl -X POST "http://localhost:7700/dumps" \
  -H "Authorization: Bearer YOUR_MASTER_KEY"

# Response: { "taskUid": 1, ... }
# Wait for task to complete, then dump appears in dumps/ directory
```

Automate with a cron job:

```bash
#!/bin/bash
# /opt/scripts/backup-meilisearch.sh

MEILI_URL="http://localhost:7700"
MEILI_KEY="your-master-key"
BACKUP_DIR="/backups/meilisearch"
DATE=$(date +%Y%m%d-%H%M%S)

# Trigger dump
TASK=$(curl -s -X POST "$MEILI_URL/dumps" \
  -H "Authorization: Bearer $MEILI_KEY" | jq -r '.taskUid')

# Wait for completion (poll with timeout)
for i in $(seq 1 60); do
  STATUS=$(curl -s "$MEILI_URL/tasks/$TASK" \
    -H "Authorization: Bearer $MEILI_KEY" | jq -r '.status')
  if [ "$STATUS" = "succeeded" ]; then
    break
  fi
  sleep 5
done

# Copy dump to backup directory with timestamp
cp -r /var/lib/meilisearch/dumps/. "$BACKUP_DIR/$DATE/"
```

---

## Part 7 — Security Fundamentals

### Master Key

The **master key** is the root credential for a Meilisearch instance. It must be set when running in `production` mode. Without it, all endpoints are public.

The master key unlocks all capabilities including creating and deleting indexes, managing API keys, and accessing all data.

**Never expose the master key to client applications.** Store it in environment variables, not in code.

```bash
# Set via environment variable
MEILI_MASTER_KEY=your-very-long-random-string meilisearch

# Generate a secure random key
openssl rand -base64 32
```

### API Keys

API keys are derived credentials created from the master key. Each key has:

- A name (for identification)
- An expiry date (optional)
- A set of **actions** it can perform
- A set of **indexes** it can access

```typescript
// Create a search-only API key (do this server-side, not in the client)
const key = await client.createKey({
  name: "Frontend Search Key",
  description: "Read-only key for the product search interface",
  actions: ["search"],
  indexes: ["products"],
  expiresAt: null,  // null = never expires; prefer setting a date
});
```

### Search-Only Keys

A **search-only key** has only the `search` action. Even if an attacker obtains this key, they can only perform search queries on the permitted indexes. They cannot add documents, delete data, or read other keys.

This is the key you embed in your frontend applications.

### Administrative Keys

Administrative keys have extended actions (`documents.add`, `indexes.create`, `settings.update`, etc.). These belong only in server-side code.

### Key Management

```typescript
import { MeiliSearch } from "meilisearch";

const adminClient = new MeiliSearch({
  host: "https://search.yourdomain.com",
  apiKey: process.env.MEILI_MASTER_KEY,
});

// List all keys
const keys = await adminClient.getKeys();

// Create a search-only key for a specific index
const searchKey = await adminClient.createKey({
  name: "product-search-frontend",
  actions: ["search"],
  indexes: ["products"],
  expiresAt: null,
});

console.log(searchKey.key);  // The actual key string to embed

// Rotate a key (delete old, create new)
await adminClient.deleteKey(oldKeyUid);
```

### Common Security Mistakes

1. **Putting the master key in frontend code** — Never. Use a search-only key with minimal index access.
2. **Using the master key as the application key** — Create purpose-specific API keys.
3. **Exposing port 7700 to the internet without a reverse proxy** — Put Nginx or a load balancer in front.
4. **Not setting a master key in development** — Develop with a key to catch security issues early.
5. **Never rotating keys** — Rotate keys periodically, especially after team member changes.
6. **Not setting key expiry** — Consider time-limited keys for external integrations.

### Public Frontend Access

The correct pattern:

```mermaid
flowchart LR
    Browser -->|search-only API key| Nginx
    Nginx -->|search-only API key| Meilisearch
    Backend -->|admin API key| Meilisearch
    Backend -->|writes| PostgreSQL
    PostgreSQL -->|sync| Backend
```

The frontend has a search-only key. The backend has an admin key. The master key is used only for key management operations from secure infrastructure.

---

## Part 8 — Core API Usage

### TypeScript Client Setup

```bash
npm install meilisearch
```

```typescript
// src/lib/meilisearch.ts
import { MeiliSearch } from "meilisearch";

if (!process.env.MEILI_HOST) throw new Error("MEILI_HOST is required");
if (!process.env.MEILI_ADMIN_KEY) throw new Error("MEILI_ADMIN_KEY is required");

export const meiliAdmin = new MeiliSearch({
  host: process.env.MEILI_HOST,
  apiKey: process.env.MEILI_ADMIN_KEY,
});

// Separate client with search-only key for server-side search (SSR)
export const meiliSearch = new MeiliSearch({
  host: process.env.MEILI_HOST,
  apiKey: process.env.MEILI_SEARCH_KEY,
});
```

### Creating Indexes

```typescript
// Create an index with an explicit primary key
const task = await meiliAdmin.createIndex("products", {
  primaryKey: "id",
});

// Wait for the task to complete
const completedTask = await meiliAdmin.waitForTask(task.taskUid);
console.log(completedTask.status); // "succeeded"
```

### Listing Indexes

```typescript
const indexesResult = await meiliAdmin.getIndexes();
// Returns: { results: [{ uid, primaryKey, createdAt, updatedAt }], ... }

for (const index of indexesResult.results) {
  console.log(index.uid, index.primaryKey);
}
```

### Getting an Index

```typescript
const index = meiliAdmin.index("products");
// This does not make a network call; it returns a local index reference

// Fetch index stats
const stats = await index.getStats();
console.log(stats.numberOfDocuments);
```

### Updating Index Settings

```typescript
const index = meiliAdmin.index("products");

const task = await index.updateSettings({
  searchableAttributes: ["title", "description", "brand", "tags"],
  filterableAttributes: ["category", "brand", "price", "in_stock"],
  sortableAttributes: ["price", "created_at", "rating"],
  rankingRules: [
    "words",
    "typo",
    "proximity",
    "attribute",
    "sort",
    "exactness",
  ],
  synonyms: {
    "keyboard": ["mechanical keyboard", "typing board"],
    "laptop": ["notebook", "portable computer"],
  },
  stopWords: ["the", "a", "an", "and", "or"],
  typoTolerance: {
    enabled: true,
    minWordSizeForTypos: {
      oneTypo: 5,
      twoTypos: 9,
    },
  },
});

await meiliAdmin.waitForTask(task.taskUid);
```

### Deleting Indexes

```typescript
const task = await meiliAdmin.deleteIndex("products");
await meiliAdmin.waitForTask(task.taskUid);
```

### Tasks

All write operations return a task. Tasks have a lifecycle:

```
enqueued → processing → succeeded | failed | canceled
```

```typescript
// Get task by UID
const task = await meiliAdmin.getTask(42);
console.log(task.status, task.error);

// Wait for a task with timeout
const completed = await meiliAdmin.waitForTask(task.taskUid, {
  timeOutMs: 30000,   // 30 seconds
  intervalMs: 500,   // Poll every 500ms
});

if (completed.status === "failed") {
  console.error("Task failed:", completed.error);
}

// List recent tasks
const tasks = await meiliAdmin.getTasks({
  limit: 20,
  indexUids: ["products"],
  statuses: ["failed"],
});
```

### Error Handling

```typescript
import { MeiliSearchApiError } from "meilisearch";

try {
  const task = await meiliAdmin.createIndex("products", { primaryKey: "id" });
  await meiliAdmin.waitForTask(task.taskUid);
} catch (error) {
  if (error instanceof MeiliSearchApiError) {
    console.error(`Meilisearch API error: ${error.message}`);
    console.error(`HTTP status: ${error.httpStatus}`);
    console.error(`Error code: ${error.code}`);
  } else {
    throw error;
  }
}
```

---

## Part 9 — Document Management

### Adding Documents

```typescript
const index = meiliAdmin.index("products");

// Add a single document
const task = await index.addDocuments([
  {
    id: "prod-001",
    title: "Keychron K2 Mechanical Keyboard",
    brand: "Keychron",
    price: 89.99,
    category: "keyboards",
    in_stock: true,
  },
]);

await meiliAdmin.waitForTask(task.taskUid);
```

### Adding Documents in Batches

Meilisearch performs best when documents are sent in batches. Very large single requests may time out.

```typescript
async function indexInBatches<T extends object>(
  index: ReturnType<MeiliSearch["index"]>,
  documents: T[],
  batchSize: number = 1000,
): Promise<void> {
  const tasks: number[] = [];

  for (let i = 0; i < documents.length; i += batchSize) {
    const batch = documents.slice(i, i + batchSize);
    const task = await index.addDocuments(batch);
    tasks.push(task.taskUid);
    console.log(
      `Enqueued batch ${Math.floor(i / batchSize) + 1}, task ${task.taskUid}`
    );
  }

  // Wait for all tasks
  for (const taskUid of tasks) {
    const completed = await meiliAdmin.waitForTask(taskUid, {
      timeOutMs: 60000,
    });
    if (completed.status === "failed") {
      throw new Error(`Indexing task ${taskUid} failed: ${completed.error?.message}`);
    }
  }

  console.log(`Indexed ${documents.length} documents successfully`);
}
```

### Updating Documents (Partial Updates)

Meilisearch uses **upsert semantics** for `addDocuments`. If a document with the same primary key exists, it is replaced entirely.

For **partial updates** (update only specific fields), use `updateDocuments`:

```typescript
// Only update the price and in_stock fields of existing documents
const task = await index.updateDocuments([
  { id: "prod-001", price: 79.99 },
  { id: "prod-002", price: 129.99, in_stock: false },
]);
```

`updateDocuments` merges the provided fields into the existing document. Fields not specified are preserved.

### Deleting Documents

```typescript
// Delete by primary key
const task = await index.deleteDocument("prod-001");

// Delete multiple by primary key
const task2 = await index.deleteDocuments({
  ids: ["prod-001", "prod-002", "prod-003"],
});

// Delete all documents in an index (keeps index and settings)
const task3 = await index.deleteAllDocuments();
```

### Fetching Documents

```typescript
// Get a single document by primary key
const doc = await index.getDocument("prod-001");

// Get multiple documents (no search, just retrieval)
const docs = await index.getDocuments({
  limit: 20,
  offset: 0,
  fields: ["id", "title", "price"],  // Return only these fields
});
```

### Reindexing

**Reindexing** is the process of rebuilding an index from scratch. Required when:

- You change `searchableAttributes` or `filterableAttributes` in a way that requires full rebuild
- Your document schema changes significantly
- You want to apply a new tokenizer or language configuration

The safest reindexing pattern is **blue-green**:

```typescript
async function reindex(
  newDocuments: Product[],
  liveIndexUid: string = "products",
): Promise<void> {
  const stagingUid = `${liveIndexUid}_staging_${Date.now()}`;

  // 1. Create a staging index
  await meiliAdmin.createIndex(stagingUid, { primaryKey: "id" });

  // 2. Apply settings
  const stagingIndex = meiliAdmin.index(stagingUid);
  const settingsTask = await stagingIndex.updateSettings(PRODUCTS_SETTINGS);
  await meiliAdmin.waitForTask(settingsTask.taskUid);

  // 3. Index all documents into staging
  await indexInBatches(stagingIndex, newDocuments);

  // 4. Swap indexes atomically (live becomes staging, staging becomes live)
  // [Unverified: swap indexes API syntax — verify against current Meilisearch docs]
  const swapTask = await meiliAdmin.swapIndexes([
    { indexes: [liveIndexUid, stagingUid] },
  ]);
  await meiliAdmin.waitForTask(swapTask.taskUid);

  // 5. Delete the old index (now at stagingUid)
  await meiliAdmin.deleteIndex(stagingUid);
}
```

---

## Part 10 — Search Operations

### Basic Search

```typescript
const index = meiliSearch.index("products");

const results = await index.search("mechanical keyboard");
/*
{
  hits: [
    { id: "prod-001", title: "Keychron K2 Mechanical Keyboard", ... },
    ...
  ],
  query: "mechanical keyboard",
  processingTimeMs: 3,
  limit: 20,
  offset: 0,
  estimatedTotalHits: 42,
}
*/
```

### Search Parameters

#### `q` — Query String

```typescript
// Empty query returns all documents (useful for browsing)
const all = await index.search("", { limit: 20 });

// Quoted phrase search (exact phrase)
const phrase = await index.search('"mechanical keyboard"');
```

#### `limit` and `offset` — Classic Pagination

```typescript
// Page 1: first 20 results
const page1 = await index.search("keyboard", { limit: 20, offset: 0 });

// Page 2: next 20
const page2 = await index.search("keyboard", { limit: 20, offset: 20 });
```

**Limitation:** `offset + limit` cannot exceed `maxTotalHits` (default 1000). For deep pagination, use cursor-based pagination at the application level.

#### `page` and `hitsPerPage` — Page-Based Pagination

```typescript
const page1 = await index.search("keyboard", { page: 1, hitsPerPage: 20 });
/*
{
  hits: [...],
  page: 1,
  hitsPerPage: 20,
  totalPages: 5,
  totalHits: 92,
}
*/
```

This mode returns exact totals (more expensive) vs. estimated totals.

#### `attributesToRetrieve` — Field Selection

```typescript
const results = await index.search("keyboard", {
  attributesToRetrieve: ["id", "title", "price", "in_stock"],
  // Only these fields are returned in hits
});
```

#### `attributesToHighlight` — Hit Highlighting

```typescript
const results = await index.search("mechanical keyboard", {
  attributesToHighlight: ["title", "description"],
  highlightPreTag: "<mark>",
  highlightPostTag: "</mark>",
});
// results.hits[0]._formatted.title = "Keychron K2 <mark>Mechanical</mark> <mark>Keyboard</mark>"
```

#### `attributesToCrop` — Snippet Generation

```typescript
const results = await index.search("mechanical keyboard", {
  attributesToCrop: ["description"],
  cropLength: 100,
  cropMarker: "…",
});
// results.hits[0]._formatted.description = "…a 80% tenkeyless layout with <mark>mechanical</mark> …"
```

### Realistic Search Service

```typescript
// src/services/search.service.ts
import { MeiliSearch, SearchParams, SearchResponse } from "meilisearch";

export interface ProductSearchParams {
  query: string;
  page?: number;
  hitsPerPage?: number;
  filters?: string;
  sort?: string[];
  facets?: string[];
}

export interface ProductHit {
  id: string;
  title: string;
  brand: string;
  price: number;
  category: string;
  in_stock: boolean;
  _formatted?: Record<string, string>;
}

export class ProductSearchService {
  private index: ReturnType<MeiliSearch["index"]>;

  constructor(client: MeiliSearch) {
    this.index = client.index("products");
  }

  async search(params: ProductSearchParams): Promise<SearchResponse<ProductHit>> {
    const searchParams: SearchParams = {
      page: params.page ?? 1,
      hitsPerPage: params.hitsPerPage ?? 20,
      attributesToHighlight: ["title", "description"],
      highlightPreTag: "<mark>",
      highlightPostTag: "</mark>",
      attributesToRetrieve: [
        "id", "title", "brand", "price", "category", "in_stock",
      ],
    };

    if (params.filters) {
      searchParams.filter = params.filters;
    }

    if (params.sort?.length) {
      searchParams.sort = params.sort;
    }

    if (params.facets?.length) {
      searchParams.facets = params.facets;
    }

    return this.index.search<ProductHit>(params.query, searchParams);
  }
}
```

---

## Part 11 — Ranking and Relevance

### The Ranking Rule Pipeline

Meilisearch ranks documents by applying a sequence of rules in order. When two documents are tied after the first rule, the second rule breaks the tie. When still tied, the third rule applies, and so on.

This is different from BM25's single floating-point score. It is deterministic and more controllable.

### Default Ranking Rules

```
1. words
2. typo
3. proximity
4. attribute
5. sort
6. exactness
```

#### `words`

Sorts by the number of query terms present in the document. A document containing more of the query words ranks higher.

Query: `"fast mechanical keyboard"`

- Doc A contains all three words → ranked higher
- Doc B contains only "keyboard" → ranked lower

#### `typo`

Among documents with the same word count, those matched with fewer typos rank higher.

- Exact match beats 1-typo match beats 2-typo match

#### `proximity`

Among documents tied on words and typos, those where the query words appear closer together rank higher.

Query: `"mechanical keyboard"`

- Doc A: "This mechanical keyboard is great" — words adjacent → higher
- Doc B: "This mechanical beast is also called a keyboard" — words separated → lower

#### `attribute`

Matches in earlier `searchableAttributes` rank higher than matches in later ones.

```typescript
// With this configuration:
searchableAttributes: ["title", "brand", "description"]

// A match in title beats a match in brand beats a match in description
```

#### `sort`

When `sort` is specified in the search query, it applies here in the pipeline. If you specify `sort: ["price:asc"]`, this is where the sort criteria is applied.

#### `exactness`

Documents where a query word matches exactly (not via typo tolerance) rank higher than typo-corrected matches.

### Custom Ranking Rules

You can add custom rules using `_geo` (geographic distance) or document attribute values.

```typescript
await index.updateSettings({
  rankingRules: [
    "words",
    "typo",
    "proximity",
    "attribute",
    "sort",
    "exactness",
    // Add after built-in rules for attribute-based boosting
  ],
  // For custom attribute ranking, use sort: in your search query
});
```

### Boosting Relevance with Attribute Order

The simplest relevance tuning in Meilisearch: ordering `searchableAttributes` to prioritize field importance.

```typescript
await index.updateSettings({
  searchableAttributes: [
    "title",         // Matches here rank highest
    "tags",          // Then here
    "brand",
    "description",   // Matches here rank lowest
  ],
});
```

This is the primary lever for relevance tuning in Meilisearch.

### Practical Ranking Example

E-commerce product search:

```typescript
await productIndex.updateSettings({
  searchableAttributes: [
    "title",          // Product names are most important
    "sku",            // SKU matches should rank high (exact lookup pattern)
    "brand",
    "category",
    "tags",
    "description",   // Body text is less discriminating
  ],
  rankingRules: [
    "words",
    "typo",
    "proximity",
    "attribute",
    "sort",           // Allows query-time sort override
    "exactness",
  ],
});
```

---

## Part 12 — Filters

### Why Filters Require Configuration

Filters are not available on all fields by default. You must explicitly declare `filterableAttributes`. This is because Meilisearch builds separate data structures for filterable fields during indexing. Adding a field to `filterableAttributes` after documents are indexed requires a full re-indexing of affected data.

```typescript
await index.updateSettings({
  filterableAttributes: [
    "category",
    "brand",
    "price",
    "in_stock",
    "tags",
    "created_at",
    "rating",
  ],
});
```

### Filter Syntax

Meilisearch uses a SQL-like filter expression language.

#### Equality

```
category = "keyboards"
brand = "Keychron"
in_stock = true
```

#### Inequality

```
price > 50
price >= 50
price < 100
price <= 100
price != 0
```

#### Range

```
price 50 TO 100
```

Equivalent to `price >= 50 AND price <= 100`.

#### Boolean Logic

```
category = "keyboards" AND in_stock = true
category = "keyboards" OR category = "mice"
NOT in_stock = true
```

#### Array Contains

```
tags = "sale"
```

If `tags` is an array, this returns documents where the array contains "sale".

#### NULL Checks

```
description IS NULL
description IS NOT NULL
description IS EMPTY
description IS NOT EMPTY
```

#### Nested Filtering

```
(category = "keyboards" OR category = "mice") AND price < 100 AND in_stock = true
```

### Using Filters in TypeScript

```typescript
const results = await index.search("keyboard", {
  filter: 'category = "keyboards" AND price < 100 AND in_stock = true',
});

// Dynamic filter construction
function buildProductFilter(params: {
  category?: string;
  brand?: string;
  minPrice?: number;
  maxPrice?: number;
  inStockOnly?: boolean;
}): string {
  const clauses: string[] = [];

  if (params.category) {
    clauses.push(`category = "${params.category}"`);
  }
  if (params.brand) {
    clauses.push(`brand = "${params.brand}"`);
  }
  if (params.minPrice !== undefined && params.maxPrice !== undefined) {
    clauses.push(`price ${params.minPrice} TO ${params.maxPrice}`);
  } else if (params.minPrice !== undefined) {
    clauses.push(`price >= ${params.minPrice}`);
  } else if (params.maxPrice !== undefined) {
    clauses.push(`price <= ${params.maxPrice}`);
  }
  if (params.inStockOnly) {
    clauses.push(`in_stock = true`);
  }

  return clauses.join(" AND ");
}
```

### Performance Considerations

- Filters on `filterableAttributes` use optimized data structures and are fast
- Boolean combinations of filters remain fast
- Very high-cardinality filterable fields (e.g., unique user IDs per document) consume significant memory
- Adding new filterable attributes requires waiting for a re-indexing task to complete

---

## Part 13 — Sorting

### Sortable Attributes

Like filters, sortable attributes must be declared before use:

```typescript
await index.updateSettings({
  sortableAttributes: [
    "price",
    "created_at",
    "rating",
    "name",
  ],
});
```

### Sorting in Queries

```typescript
// Sort by price ascending
const results = await index.search("keyboard", {
  sort: ["price:asc"],
});

// Sort by price descending
const results2 = await index.search("keyboard", {
  sort: ["price:desc"],
});

// Multi-field sort: primary sort by rating desc, secondary by price asc
const results3 = await index.search("keyboard", {
  sort: ["rating:desc", "price:asc"],
});
```

### Sorting vs Ranking

This distinction is important and commonly confused.

**Ranking** is relevance ordering: how well does a document match the query? It is implicit and query-dependent.

**Sorting** is deterministic ordering: sort all matching documents by this field, regardless of relevance.

When you add `sort` to a search query, the `sort` ranking rule in the pipeline is where sort takes effect. Rules before `sort` in the pipeline still apply: a document that matches more query words still ranks higher than a document that matches fewer words, even with sort applied — **unless you move `sort` before `words` in the ranking rules.**

For "browse mode" (e.g., display all products in a category sorted by price, no text query), you typically want `sort` to dominate:

```typescript
await index.updateSettings({
  rankingRules: [
    "sort",     // Sort dominates when specified
    "words",
    "typo",
    "proximity",
    "attribute",
    "exactness",
  ],
});
```

For "search mode" (user typed a query), you want `words` and `typo` to dominate, with sort as a tiebreaker:

```typescript
// Default rule order — sort is a tiebreaker
rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"]
```

[Inference: having two separate ranking rule configurations per use case is a common recommendation; practical behavior depends on your data and query patterns.]

---

## Part 14 — Faceted Search

### What Facets Are

Facets provide users with interactive, self-narrowing navigation. Rather than typing a filter, users click checkboxes that represent dimensions of the data.

A faceted search request returns both the hits and the facet distribution:

```json
{
  "hits": [...],
  "facetDistribution": {
    "category": {
      "keyboards": 42,
      "mice": 18,
      "monitors": 11
    },
    "brand": {
      "Keychron": 23,
      "Logitech": 31,
      "Dell": 8
    },
    "in_stock": {
      "true": 60,
      "false": 12
    }
  }
}
```

### Requirements

Faceted fields must be in both `filterableAttributes` and requested in the `facets` search parameter.

### Requesting Facets

```typescript
const results = await index.search("", {
  facets: ["category", "brand", "in_stock"],
  filter: 'category = "keyboards"',  // Facets are computed within filtered results
  limit: 20,
});

console.log(results.facetDistribution);
```

### Facet Stats for Numeric Fields

```typescript
const results = await index.search("keyboard", {
  facets: ["price", "rating"],
});

console.log(results.facetStats);
// { price: { min: 29.99, max: 299.99 }, rating: { min: 2.1, max: 4.9 } }
```

### Facet Configuration

```typescript
await index.updateSettings({
  faceting: {
    maxValuesPerFacet: 100,  // Max distinct values returned per facet
    sortFacetValuesBy: {
      "*": "count",          // Sort by count (default) or alpha
    },
  },
});
```

### React Facet Component Pattern

```tsx
// src/components/FacetPanel.tsx
import { useState } from "react";

interface FacetValue {
  value: string;
  count: number;
}

interface FacetPanelProps {
  title: string;
  facetKey: string;
  values: Record<string, number>;
  selectedValues: string[];
  onToggle: (facetKey: string, value: string) => void;
}

export function FacetPanel({
  title,
  facetKey,
  values,
  selectedValues,
  onToggle,
}: FacetPanelProps) {
  const [expanded, setExpanded] = useState(true);

  const sortedValues: FacetValue[] = Object.entries(values)
    .map(([value, count]) => ({ value, count }))
    .sort((a, b) => b.count - a.count);

  return (
    <div className="facet-panel">
      <button
        className="facet-title"
        onClick={() => setExpanded(!expanded)}
      >
        {title} {expanded ? "▲" : "▼"}
      </button>

      {expanded && (
        <ul className="facet-values">
          {sortedValues.map(({ value, count }) => (
            <li key={value}>
              <label>
                <input
                  type="checkbox"
                  checked={selectedValues.includes(value)}
                  onChange={() => onToggle(facetKey, value)}
                />
                {value}
                <span className="facet-count">({count})</span>
              </label>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

---

## Part 15 — Typo Tolerance and Synonyms

### Typo Tolerance

Typo tolerance is enabled by default. Meilisearch allows 1 typo for words of 5+ characters and 2 typos for words of 9+ characters (configurable).

```typescript
await index.updateSettings({
  typoTolerance: {
    enabled: true,
    minWordSizeForTypos: {
      oneTypo: 5,    // Words of 5+ chars allow 1 typo
      twoTypos: 9,   // Words of 9+ chars allow 2 typos
    },
    disableOnWords: [
      // Words where typo tolerance should be disabled (e.g., SKUs, codes)
      "SKU123",
    ],
    disableOnAttributes: [
      // Fields where typo tolerance should be disabled
      "sku",
      "barcode",
    ],
  },
});
```

#### When to Disable Typo Tolerance

Disable for:
- Product codes, SKUs, barcodes — typo-tolerant matches would return wrong products
- Identifiers, reference numbers
- Fields where exact matching is critical

### Benefits and Drawbacks of Typo Tolerance

**Benefits:**
- Dramatically improves search experience for real users who make mistakes
- Reduces "zero results" dead ends
- Works without any configuration for most use cases

**Drawbacks:**
- Slightly increases query processing time (more candidates to consider)
- Can return unexpected results if thresholds are set too loosely
- Not appropriate for all field types (codes, identifiers)

### Synonyms

```typescript
await index.updateSettings({
  synonyms: {
    // Bidirectional synonyms
    "keyboard": ["typing board", "keys"],
    "laptop": ["notebook", "portable computer"],
    "js": ["javascript"],

    // One-directional: searching "tv" also returns "television" results
    // but "television" doesn't necessarily match "tv"
    // (Meilisearch currently only supports bidirectional synonyms)
    // [Unverified: one-directional synonym support — verify current documentation]
  },
});
```

#### Synonym Strategies

**Abbreviation synonyms:**
```json
{
  "kb": ["kilobyte"],
  "mb": ["megabyte"],
  "ssd": ["solid state drive"]
}
```

**Brand and product synonyms:**
```json
{
  "apple": ["mac", "iphone", "ipad"],
  "google": ["alphabet", "gmail", "android"]
}
```

**Domain-specific synonyms:**
```json
{
  "physician": ["doctor", "md", "medical doctor"],
  "attorney": ["lawyer", "counsel", "solicitor"]
}
```

---

## Part 16 — Frontend Integration

### Vanilla JavaScript

```html
<!-- Install: npm install meilisearch -->
<!-- Or CDN: -->
<script src="https://cdn.jsdelivr.net/npm/meilisearch/dist/bundles/meilisearch.umd.js"></script>
```

```typescript
// src/search.ts
import { MeiliSearch } from "meilisearch";

const client = new MeiliSearch({
  host: "https://search.yourdomain.com",
  apiKey: "your-search-only-key",  // Public, search-only key
});

const index = client.index("products");
```

#### Debouncing

Debouncing prevents a search request for every keystroke.

```typescript
function debounce<T extends (...args: unknown[]) => unknown>(
  fn: T,
  delayMs: number,
): (...args: Parameters<T>) => void {
  let timeoutId: ReturnType<typeof setTimeout> | null = null;

  return (...args: Parameters<T>) => {
    if (timeoutId !== null) clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delayMs);
  };
}

const searchInput = document.getElementById("search") as HTMLInputElement;
const resultsContainer = document.getElementById("results") as HTMLDivElement;

const handleSearch = debounce(async (query: string) => {
  if (!query.trim()) {
    resultsContainer.innerHTML = "";
    return;
  }

  const results = await index.search(query, {
    limit: 10,
    attributesToHighlight: ["title"],
    highlightPreTag: "<mark>",
    highlightPostTag: "</mark>",
  });

  resultsContainer.innerHTML = results.hits
    .map(
      (hit) => `
        <div class="result-item">
          <a href="/products/${hit.id}">
            ${hit._formatted?.title ?? hit.title}
          </a>
          <span class="price">$${hit.price}</span>
        </div>
      `,
    )
    .join("");
}, 200);

searchInput.addEventListener("input", (e) => {
  handleSearch((e.target as HTMLInputElement).value);
});
```

### React

#### Custom Search Hook

```typescript
// src/hooks/useSearch.ts
import { useState, useEffect, useCallback, useRef } from "react";
import { SearchResponse } from "meilisearch";
import { searchClient } from "@/lib/meilisearch";

interface UseSearchOptions<T> {
  indexUid: string;
  initialQuery?: string;
  searchParams?: Record<string, unknown>;
  debounceMs?: number;
}

interface UseSearchResult<T> {
  results: SearchResponse<T> | null;
  isLoading: boolean;
  error: Error | null;
  query: string;
  setQuery: (query: string) => void;
}

export function useSearch<T>({
  indexUid,
  initialQuery = "",
  searchParams = {},
  debounceMs = 200,
}: UseSearchOptions<T>): UseSearchResult<T> {
  const [query, setQuery] = useState(initialQuery);
  const [results, setResults] = useState<SearchResponse<T> | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const abortRef = useRef<AbortController | null>(null);

  const performSearch = useCallback(
    async (searchQuery: string) => {
      // Cancel any in-flight request
      if (abortRef.current) abortRef.current.abort();
      abortRef.current = new AbortController();

      setIsLoading(true);
      setError(null);

      try {
        const index = searchClient.index(indexUid);
        const response = await index.search<T>(searchQuery, searchParams);
        setResults(response);
      } catch (err) {
        if (err instanceof Error && err.name !== "AbortError") {
          setError(err);
        }
      } finally {
        setIsLoading(false);
      }
    },
    [indexUid, JSON.stringify(searchParams)],
  );

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => performSearch(query), debounceMs);

    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [query, performSearch, debounceMs]);

  return { results, isLoading, error, query, setQuery };
}
```

#### Search Component

```tsx
// src/components/ProductSearch.tsx
"use client";

import { useSearch } from "@/hooks/useSearch";
import type { Product } from "@/types/product";

interface ProductSearchProps {
  initialQuery?: string;
}

export function ProductSearch({ initialQuery = "" }: ProductSearchProps) {
  const { results, isLoading, error, query, setQuery } = useSearch<Product>({
    indexUid: "products",
    initialQuery,
    searchParams: {
      attributesToHighlight: ["title"],
      highlightPreTag: "<mark>",
      highlightPostTag: "</mark>",
      limit: 20,
      facets: ["category", "brand"],
    },
  });

  return (
    <div className="product-search">
      <div className="search-input-wrapper">
        <input
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search products…"
          className="search-input"
          autoComplete="off"
          autoFocus
        />
        {isLoading && <span className="loading-indicator">Searching…</span>}
      </div>

      {error && (
        <div className="search-error">
          Search unavailable. Please try again.
        </div>
      )}

      {results && (
        <div className="search-results">
          <p className="result-count">
            {results.estimatedTotalHits} results for &ldquo;{query}&rdquo;
            <span className="processing-time">
              ({results.processingTimeMs}ms)
            </span>
          </p>

          <ul className="hits-list">
            {results.hits.map((hit) => (
              <li key={hit.id} className="hit-item">
                <a href={`/products/${hit.id}`}>
                  <span
                    dangerouslySetInnerHTML={{
                      __html: hit._formatted?.title ?? hit.title,
                    }}
                  />
                </a>
                <span className="hit-price">${hit.price.toFixed(2)}</span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
```

**Security note:** `dangerouslySetInnerHTML` is safe here because Meilisearch only injects the configured `highlightPreTag`/`highlightPostTag` around matched substrings. However, if your documents can contain user-generated HTML content, sanitize before indexing.

### Next.js — App Router Integration

#### Server-Side Search (Server Component)

```tsx
// app/products/page.tsx
import { meiliSearch } from "@/lib/meilisearch-server";  // Server-only client
import { ProductCard } from "@/components/ProductCard";
import { SearchInput } from "@/components/SearchInput";

interface ProductsPageProps {
  searchParams: {
    q?: string;
    page?: string;
    category?: string;
  };
}

export default async function ProductsPage({ searchParams }: ProductsPageProps) {
  const query = searchParams.q ?? "";
  const page = parseInt(searchParams.page ?? "1", 10);
  const category = searchParams.category;

  const filter = category ? `category = "${category}"` : undefined;

  const results = await meiliSearch
    .index("products")
    .search(query, {
      page,
      hitsPerPage: 24,
      filter,
      facets: ["category", "brand"],
      attributesToHighlight: ["title"],
      highlightPreTag: "<strong>",
      highlightPostTag: "</strong>",
    });

  return (
    <main>
      <SearchInput initialValue={query} />

      <div className="product-grid">
        {results.hits.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>

      {/* Pagination */}
      <nav className="pagination">
        {Array.from({ length: results.totalPages ?? 1 }, (_, i) => (
          <a
            key={i + 1}
            href={`/products?q=${query}&page=${i + 1}`}
            className={page === i + 1 ? "active" : ""}
          >
            {i + 1}
          </a>
        ))}
      </nav>
    </main>
  );
}
```

#### Client-Side Search (Client Component)

```tsx
// app/search/page.tsx
import { Suspense } from "react";
import { ProductSearch } from "@/components/ProductSearch";

export default function SearchPage() {
  return (
    <main>
      <h1>Search</h1>
      <Suspense fallback={<div>Loading search…</div>}>
        <ProductSearch />
      </Suspense>
    </main>
  );
}
```

#### API Route for Search

```typescript
// app/api/search/route.ts
import { NextRequest, NextResponse } from "next/server";
import { meiliSearch } from "@/lib/meilisearch-server";
import { z } from "zod";

const SearchQuerySchema = z.object({
  q: z.string().default(""),
  page: z.coerce.number().int().min(1).default(1),
  hitsPerPage: z.coerce.number().int().min(1).max(100).default(20),
  category: z.string().optional(),
  brand: z.string().optional(),
  minPrice: z.coerce.number().optional(),
  maxPrice: z.coerce.number().optional(),
});

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const params = Object.fromEntries(searchParams.entries());

  const parsed = SearchQuerySchema.safeParse(params);
  if (!parsed.success) {
    return NextResponse.json(
      { error: "Invalid search parameters", issues: parsed.error.issues },
      { status: 400 },
    );
  }

  const { q, page, hitsPerPage, category, brand, minPrice, maxPrice } =
    parsed.data;

  const filterClauses: string[] = [];
  if (category) filterClauses.push(`category = "${category}"`);
  if (brand) filterClauses.push(`brand = "${brand}"`);
  if (minPrice !== undefined && maxPrice !== undefined) {
    filterClauses.push(`price ${minPrice} TO ${maxPrice}`);
  }

  try {
    const results = await meiliSearch.index("products").search(q, {
      page,
      hitsPerPage,
      filter: filterClauses.length > 0 ? filterClauses.join(" AND ") : undefined,
      facets: ["category", "brand"],
      attributesToHighlight: ["title", "description"],
      highlightPreTag: "<mark>",
      highlightPostTag: "</mark>",
    });

    return NextResponse.json(results);
  } catch (error) {
    console.error("Search error:", error);
    return NextResponse.json(
      { error: "Search temporarily unavailable" },
      { status: 503 },
    );
  }
}
```

---

## Part 17 — Backend Integration

### Fastify Plugin Architecture

Fastify uses a plugin system for dependency injection and encapsulation. The correct pattern for Meilisearch integration is a Fastify plugin that decorates the Fastify instance with the client.

```typescript
// src/plugins/meilisearch.ts
import fp from "fastify-plugin";
import { FastifyInstance, FastifyPluginOptions } from "fastify";
import { MeiliSearch } from "meilisearch";

declare module "fastify" {
  interface FastifyInstance {
    meili: MeiliSearch;
  }
}

interface MeiliSearchPluginOptions extends FastifyPluginOptions {
  host: string;
  apiKey: string;
}

async function meilisearchPlugin(
  fastify: FastifyInstance,
  options: MeiliSearchPluginOptions,
): Promise<void> {
  const client = new MeiliSearch({
    host: options.host,
    apiKey: options.apiKey,
  });

  // Verify connectivity
  const health = await client.health();
  if (health.status !== "available") {
    throw new Error(`Meilisearch not available: ${health.status}`);
  }

  fastify.decorate("meili", client);

  fastify.log.info(`Connected to Meilisearch at ${options.host}`);
}

export default fp(meilisearchPlugin, {
  name: "meilisearch",
  dependencies: [],
});
```

### App Entrypoint

```typescript
// src/app.ts
import Fastify from "fastify";
import meilisearchPlugin from "./plugins/meilisearch.js";
import searchRoutes from "./routes/search.js";
import { config } from "./config.js";

export async function buildApp() {
  const app = Fastify({
    logger: {
      level: config.LOG_LEVEL,
      transport:
        config.NODE_ENV === "development"
          ? { target: "pino-pretty" }
          : undefined,
    },
  });

  // Register plugins
  await app.register(meilisearchPlugin, {
    host: config.MEILI_HOST,
    apiKey: config.MEILI_ADMIN_KEY,
  });

  // Register routes
  await app.register(searchRoutes, { prefix: "/api/search" });

  return app;
}
```

### Search Endpoints with Validation

```typescript
// src/routes/search.ts
import { FastifyInstance } from "fastify";
import { Type, Static } from "@sinclair/typebox";

const ProductSearchQuery = Type.Object({
  q: Type.Optional(Type.String({ default: "" })),
  page: Type.Optional(Type.Integer({ minimum: 1, default: 1 })),
  hitsPerPage: Type.Optional(
    Type.Integer({ minimum: 1, maximum: 100, default: 20 }),
  ),
  category: Type.Optional(Type.String()),
  brand: Type.Optional(Type.String()),
  minPrice: Type.Optional(Type.Number({ minimum: 0 })),
  maxPrice: Type.Optional(Type.Number({ minimum: 0 })),
  sort: Type.Optional(
    Type.Union([
      Type.Literal("price:asc"),
      Type.Literal("price:desc"),
      Type.Literal("rating:desc"),
      Type.Literal("created_at:desc"),
    ]),
  ),
});

type ProductSearchQueryType = Static<typeof ProductSearchQuery>;

export default async function searchRoutes(fastify: FastifyInstance) {
  fastify.get<{ Querystring: ProductSearchQueryType }>(
    "/products",
    {
      schema: {
        querystring: ProductSearchQuery,
        response: {
          200: Type.Object({
            hits: Type.Array(Type.Unknown()),
            query: Type.String(),
            processingTimeMs: Type.Number(),
            estimatedTotalHits: Type.Optional(Type.Number()),
            totalHits: Type.Optional(Type.Number()),
            totalPages: Type.Optional(Type.Number()),
            page: Type.Optional(Type.Number()),
            facetDistribution: Type.Optional(Type.Unknown()),
          }),
        },
      },
    },
    async (request, reply) => {
      const {
        q = "",
        page = 1,
        hitsPerPage = 20,
        category,
        brand,
        minPrice,
        maxPrice,
        sort,
      } = request.query;

      const filterClauses: string[] = [];

      if (category) {
        // Sanitize: prevent filter injection
        if (!/^[a-zA-Z0-9_\-\s]+$/.test(category)) {
          return reply.code(400).send({ error: "Invalid category format" });
        }
        filterClauses.push(`category = "${category}"`);
      }

      if (brand) {
        if (!/^[a-zA-Z0-9_\-\s]+$/.test(brand)) {
          return reply.code(400).send({ error: "Invalid brand format" });
        }
        filterClauses.push(`brand = "${brand}"`);
      }

      if (minPrice !== undefined && maxPrice !== undefined) {
        if (minPrice > maxPrice) {
          return reply.code(400).send({
            error: "minPrice cannot be greater than maxPrice",
          });
        }
        filterClauses.push(`price ${minPrice} TO ${maxPrice}`);
      } else if (minPrice !== undefined) {
        filterClauses.push(`price >= ${minPrice}`);
      } else if (maxPrice !== undefined) {
        filterClauses.push(`price <= ${maxPrice}`);
      }

      try {
        const results = await fastify.meili.index("products").search(q, {
          page,
          hitsPerPage,
          filter: filterClauses.length > 0 ? filterClauses.join(" AND ") : undefined,
          sort: sort ? [sort] : undefined,
          facets: ["category", "brand", "in_stock"],
          attributesToHighlight: ["title"],
          highlightPreTag: "<mark>",
          highlightPostTag: "</mark>",
          attributesToRetrieve: [
            "id", "title", "brand", "price", "category",
            "in_stock", "image_url", "rating",
          ],
        });

        return results;
      } catch (error) {
        fastify.log.error({ error }, "Search failed");
        return reply.code(503).send({ error: "Search temporarily unavailable" });
      }
    },
  );
}
```

### Filter Injection Warning

Meilisearch filter strings are not parameterized queries — they are string-interpolated. Always validate and sanitize user-provided values before including them in filter expressions.

```typescript
// DANGEROUS — Never do this:
const filter = `category = "${req.query.category}"`;

// A user could send: category = "" OR 1=1
// (This would return all documents)

// SAFE — Validate first:
const VALID_CATEGORIES = ["keyboards", "mice", "monitors", "headphones"];
if (!VALID_CATEGORIES.includes(req.query.category)) {
  return reply.code(400).send({ error: "Invalid category" });
}
const filter = `category = "${req.query.category}"`;
```

---

## Part 18 — PostgreSQL + Meilisearch Architecture

### The Fundamental Principle

**PostgreSQL is the source of truth. Meilisearch is a derived, eventually-consistent read layer optimized for search.**

All writes go to PostgreSQL. Meilisearch is populated from PostgreSQL data. If Meilisearch data is lost, it can be rebuilt from PostgreSQL. PostgreSQL data must never be lost.

```mermaid
flowchart TB
    Client -->|Write: create/update/delete| API[Backend API]
    Client -->|Read: search| API

    API -->|All writes| PG[(PostgreSQL\nSource of Truth)]
    API -->|Search queries| MS[(Meilisearch\nSearch Layer)]

    PG -->|Sync| SyncService[Sync Service]
    SyncService -->|Index documents| MS

    subgraph "Source of Truth"
        PG
    end

    subgraph "Derived Layer"
        MS
    end
```

### Data Ownership

PostgreSQL owns:
- Canonical product data
- User data
- Order history
- All transactional records

Meilisearch owns:
- A **search-optimized representation** of data from PostgreSQL
- Denormalized documents optimized for search
- No data that is not derivable from PostgreSQL

### Synchronization

The synchronization problem: keeping Meilisearch consistent with PostgreSQL.

Changes to PostgreSQL rows must be reflected in Meilisearch documents. There are four main strategies (Part 19), but the consistency concern is always the same:

**Meilisearch may briefly reflect stale data after a PostgreSQL write.**

For most search use cases, this is acceptable. A new product becoming searchable a few seconds after creation is usually fine. A deleted product appearing in search results for a few seconds after deletion may be acceptable or unacceptable depending on business requirements.

### Architecture Diagram: PostgreSQL + Meilisearch Integration

```mermaid
flowchart LR
    subgraph "Write Path"
        W[HTTP Write Request] --> FastifyW[Fastify API]
        FastifyW --> PG[(PostgreSQL)]
        PG --> Queue[Message Queue\ne.g. BullMQ / PG Notify]
        Queue --> SyncWorker[Sync Worker]
        SyncWorker --> Meili[(Meilisearch)]
    end

    subgraph "Read Path"
        R[HTTP Search Request] --> FastifyR[Fastify API]
        FastifyR --> Meili
    end
```

---

## Part 19 — Synchronization Strategies

### Strategy 1: Application-Driven Sync

After writing to PostgreSQL, the application also writes to Meilisearch in the same request handler.

```typescript
// After updating a product in PostgreSQL, also update Meilisearch
async function updateProduct(id: string, data: UpdateProductDto) {
  // 1. Write to PostgreSQL (source of truth)
  const updated = await db.query(
    `UPDATE products SET title=$1, price=$2, updated_at=NOW() WHERE id=$3 RETURNING *`,
    [data.title, data.price, id],
  );

  // 2. Sync to Meilisearch
  const task = await meili.index("products").updateDocuments([
    {
      id: updated.rows[0].id,
      title: updated.rows[0].title,
      price: updated.rows[0].price,
    },
  ]);

  // 3. Optionally wait for task (adds latency to the API call)
  // await meili.waitForTask(task.taskUid);

  return updated.rows[0];
}
```

**Advantages:**
- Simple to implement
- No additional infrastructure

**Disadvantages:**
- If Meilisearch is unavailable, the write still succeeds in PostgreSQL but Meilisearch goes out of sync
- Adds Meilisearch latency to every write operation
- Inconsistent state if Meilisearch write fails after PostgreSQL write succeeds

**Failure mode:** PostgreSQL write succeeds, Meilisearch update fails → data divergence. Must be detected and repaired manually or via periodic reconciliation.

**Best for:** Low-volume, non-critical applications where operational simplicity matters more than strict consistency.

### Strategy 2: Queue-Driven Sync

Write to PostgreSQL, then publish a message to a queue. A separate worker consumes the queue and updates Meilisearch.

```typescript
// Using BullMQ
import { Queue, Worker, Job } from "bullmq";
import { createClient } from "redis";

const redis = createClient({ url: process.env.REDIS_URL });
const syncQueue = new Queue("meili-sync", { connection: redis });

// In the write handler
async function updateProduct(id: string, data: UpdateProductDto) {
  const updated = await db.query(/* ... */);

  // Publish job to queue (fast, non-blocking)
  await syncQueue.add("sync-product", {
    type: "update",
    id: updated.rows[0].id,
  });

  return updated.rows[0];
}

// Separate sync worker process
const syncWorker = new Worker(
  "meili-sync",
  async (job: Job) => {
    const { type, id } = job.data;

    if (type === "update" || type === "create") {
      // Fetch full document from PostgreSQL
      const result = await db.query(
        `SELECT p.*, c.name as category_name, b.name as brand_name
         FROM products p
         JOIN categories c ON p.category_id = c.id
         JOIN brands b ON p.brand_id = b.id
         WHERE p.id = $1`,
        [id],
      );

      if (result.rows[0]) {
        const doc = transformToSearchDocument(result.rows[0]);
        await meili.index("products").updateDocuments([doc]);
      }
    } else if (type === "delete") {
      await meili.index("products").deleteDocument(id);
    }
  },
  { connection: redis, concurrency: 5 },
);
```

**Advantages:**
- Decouples write path from Meilisearch
- Failed sync jobs can be retried
- Meilisearch outages don't fail write requests
- Queue provides backpressure and rate limiting

**Disadvantages:**
- Requires a message queue (Redis + BullMQ, or similar)
- Additional infrastructure to operate
- Meilisearch lag is proportional to queue depth

**Best for:** Production systems where write availability is more important than search freshness.

### Strategy 3: Event-Driven Sync (PostgreSQL NOTIFY)

Use PostgreSQL's built-in `LISTEN`/`NOTIFY` mechanism to emit events on data changes.

```sql
-- PostgreSQL trigger
CREATE OR REPLACE FUNCTION notify_product_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify(
    'product_changes',
    json_build_object(
      'type', TG_OP,
      'id', COALESCE(NEW.id, OLD.id)
    )::text
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_after_change
  AFTER INSERT OR UPDATE OR DELETE ON products
  FOR EACH ROW EXECUTE FUNCTION notify_product_change();
```

```typescript
// Worker listening for PostgreSQL NOTIFY events
import pg from "pg";

const listenerClient = new pg.Client({ connectionString: process.env.DATABASE_URL });
await listenerClient.connect();
await listenerClient.query("LISTEN product_changes");

listenerClient.on("notification", async (msg) => {
  if (!msg.payload) return;
  const event = JSON.parse(msg.payload) as { type: string; id: string };

  if (event.type === "DELETE") {
    await meili.index("products").deleteDocument(event.id);
  } else {
    const result = await db.query(
      `SELECT * FROM products WHERE id = $1`, [event.id]
    );
    if (result.rows[0]) {
      const doc = transformToSearchDocument(result.rows[0]);
      await meili.index("products").addDocuments([doc]);
    }
  }
});
```

**Advantages:**
- No additional queue infrastructure
- Low latency (notification arrives immediately after commit)
- Transactions ensure notification is sent only on committed changes

**Disadvantages:**
- NOTIFY payloads have a size limit (8000 bytes)
- Notifications are not persisted — if the listener is down, events are lost
- Connection-based: listener must maintain a persistent DB connection

**Best for:** Lower-scale systems where the simplicity of no message queue is valued, and brief data loss (on listener restart) is acceptable.

### Strategy 4: CDC-Based Sync (Change Data Capture)

CDC tools like Debezium capture PostgreSQL WAL (Write-Ahead Log) events and publish them to a message queue (Kafka, etc.).

```mermaid
flowchart LR
    PG[(PostgreSQL\nWAL)] --> Debezium[Debezium\nCDC Connector]
    Debezium --> Kafka[Kafka Topic\nproducts.changes]
    Kafka --> Worker[Meili Sync\nConsumer]
    Worker --> Meili[(Meilisearch)]
```

**Advantages:**
- No application code changes required for sync
- WAL-based — every change is captured, including bulk SQL updates
- Replay capability — can rebuild Meilisearch from WAL history
- Scales to very high write volumes

**Disadvantages:**
- Complex infrastructure (Kafka, Debezium, Zookeeper)
- Operational overhead is significant
- Requires WAL replication slot maintenance
- Overkill for most applications

**Best for:** High-volume systems, multi-consumer architectures, or when you need audit trail and replay capabilities.

### Reconciliation

All sync strategies can drift over time. Implement periodic reconciliation:

```typescript
// Full reconciliation: rebuild from PostgreSQL
async function reconcile(batchSize: number = 1000): Promise<void> {
  let offset = 0;
  let processedCount = 0;

  while (true) {
    const result = await db.query(
      `SELECT * FROM products ORDER BY id LIMIT $1 OFFSET $2`,
      [batchSize, offset],
    );

    if (result.rows.length === 0) break;

    const docs = result.rows.map(transformToSearchDocument);
    const task = await meili.index("products").addDocuments(docs);
    await meili.waitForTask(task.taskUid);

    processedCount += result.rows.length;
    offset += batchSize;
    console.log(`Reconciled ${processedCount} products`);
  }

  console.log(`Reconciliation complete. Total: ${processedCount}`);
}
```

---

## Part 20 — Data Modeling

### The Core Principle: Denormalize for Search

Relational databases normalize data to reduce redundancy. Search engines work best with denormalized documents where all searchable and filterable data is present in a single flat or minimally-nested structure.

### Relational Schema to Search Document

PostgreSQL schema:

```sql
CREATE TABLE brands (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  country TEXT
);

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  parent_id INTEGER REFERENCES categories(id)
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  price NUMERIC(10, 2) NOT NULL,
  brand_id INTEGER REFERENCES brands(id),
  category_id INTEGER REFERENCES categories(id),
  tags TEXT[],
  in_stock BOOLEAN DEFAULT true,
  rating NUMERIC(3, 2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

The JOIN query that builds a search document:

```sql
SELECT
  p.id,
  p.title,
  p.description,
  p.price::float,
  p.tags,
  p.in_stock,
  p.rating::float,
  EXTRACT(EPOCH FROM p.created_at)::integer AS created_at_ts,
  b.name AS brand,
  b.country AS brand_country,
  c.name AS category,
  parent_cat.name AS parent_category
FROM products p
JOIN brands b ON p.brand_id = b.id
JOIN categories c ON p.category_id = c.id
LEFT JOIN categories parent_cat ON c.parent_id = parent_cat.id
WHERE p.id = $1;
```

The resulting search document:

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Keychron K2 Mechanical Keyboard",
  "description": "80% tenkeyless layout with hot-swap switches",
  "price": 89.99,
  "tags": ["mechanical", "tenkeyless", "hot-swap"],
  "in_stock": true,
  "rating": 4.7,
  "created_at_ts": 1705315200,
  "brand": "Keychron",
  "brand_country": "US",
  "category": "Mechanical Keyboards",
  "parent_category": "Keyboards"
}
```

Key observations:
- `brand_id` is gone — replaced by `brand` (the name humans search for)
- `category_id` is gone — replaced by `category` (facetable)
- `created_at` is converted to a Unix timestamp (integer) for range filtering
- `price` is cast to float (Meilisearch handles JSON numbers)

### Transform Function

```typescript
// src/services/product-transformer.ts

interface ProductRow {
  id: string;
  title: string;
  description: string | null;
  price: string;  // PostgreSQL NUMERIC returns as string
  tags: string[] | null;
  in_stock: boolean;
  rating: string | null;
  created_at: Date;
  brand: string;
  brand_country: string | null;
  category: string;
  parent_category: string | null;
}

interface ProductSearchDocument {
  id: string;
  title: string;
  description: string;
  price: number;
  tags: string[];
  in_stock: boolean;
  rating: number | null;
  created_at_ts: number;
  brand: string;
  brand_country: string | null;
  category: string;
  parent_category: string | null;
}

export function transformProductToSearchDocument(
  row: ProductRow,
): ProductSearchDocument {
  return {
    id: row.id,
    title: row.title,
    description: row.description ?? "",
    price: parseFloat(row.price),
    tags: row.tags ?? [],
    in_stock: row.in_stock,
    rating: row.rating ? parseFloat(row.rating) : null,
    created_at_ts: Math.floor(new Date(row.created_at).getTime() / 1000),
    brand: row.brand,
    brand_country: row.brand_country,
    category: row.category,
    parent_category: row.parent_category,
  };
}
```

### Domain-Specific Modeling Examples

#### CMS (Blog / Documentation)

```json
{
  "id": "article-456",
  "title": "Building APIs with Fastify",
  "slug": "building-apis-fastify",
  "content": "Fastify is a web framework for Node.js...",
  "excerpt": "Learn how to build fast APIs using Fastify",
  "author_name": "Jane Smith",
  "author_slug": "jane-smith",
  "tags": ["nodejs", "fastify", "api", "backend"],
  "category": "Backend",
  "published_at_ts": 1705315200,
  "updated_at_ts": 1705401600,
  "status": "published",
  "reading_time_minutes": 8
}
```

#### E-commerce with Variants

```json
{
  "id": "product-789",
  "title": "USB-C Cable",
  "brand": "Anker",
  "category": "Cables",
  "min_price": 9.99,
  "max_price": 24.99,
  "available_colors": ["black", "white", "red"],
  "available_lengths_cm": [100, 180, 200],
  "in_stock": true,
  "rating": 4.5,
  "review_count": 2847
}
```

Flatten variants to ranges and available values — don't nest variant objects (filtering becomes complex).

#### Government / Directory

```json
{
  "id": "service-101",
  "title": "Vehicle Registration Renewal",
  "department": "Department of Motor Vehicles",
  "description": "Renew your vehicle registration online or in person",
  "keywords": ["car", "truck", "registration", "renewal", "DMV", "plates"],
  "service_type": "renewal",
  "available_online": true,
  "fee_usd": 45,
  "state": "California",
  "languages": ["en", "es", "zh"],
  "last_updated_ts": 1705315200
}
```

---

## Part 21 — Performance Engineering

### Indexing Performance

**Batch size** is the primary lever for indexing throughput.

- Very small batches (1–10 documents): high per-document overhead from task queue management
- Optimal batches (500–5000 documents): best throughput for most datasets
- Very large batches (50,000+): may time out or exhaust memory

```typescript
// Benchmark your optimal batch size
const BATCH_SIZES = [100, 500, 1000, 5000];

for (const batchSize of BATCH_SIZES) {
  const start = Date.now();
  await indexInBatches(index, testDocuments, batchSize);
  const elapsed = Date.now() - start;
  console.log(
    `Batch size ${batchSize}: ${elapsed}ms (${Math.floor(testDocuments.length / (elapsed / 1000))} docs/sec)`
  );
}
```

**Memory allocation** for indexing:

```
MEILI_MAX_INDEXING_MEMORY=4Gb  # More memory = faster indexing
```

**Concurrent index updates**: Meilisearch processes tasks sequentially per index. Sending updates to multiple indexes concurrently is fine; updates to the same index are always queued.

### Query Performance

Query time is affected by:

- **Result set size**: more candidates to rank = slower
- **Number of filterable attributes**: each adds index overhead but is needed for fast filtering
- **Facet computation**: requesting many facets is more expensive than requesting few
- **Document size**: larger documents take longer to retrieve and format
- **Highlighting on large fields**: avoid highlighting on very large text fields

```typescript
// Return only needed fields
const results = await index.search(q, {
  attributesToRetrieve: ["id", "title", "price", "brand"],  // Don't return description for list views
  attributesToHighlight: ["title"],  // Only highlight the most visible field
});
```

### Memory Usage

Meilisearch is memory-intensive. Key memory consumers:

- **LMDB memory-mapped files**: the entire index can be mmap'd into virtual memory
- **Indexing buffers**: temporary memory during document processing
- **Facet data structures**: facetable fields add to memory usage

Rule of thumb [Inference — not a confirmed figure from official documentation]:

- Plan for RAM ≈ 2–4× the compressed index size for comfortable operation
- Monitor resident memory with `GET /stats` (per-index document count and size)

### Disk Usage

```typescript
// Check index stats
const stats = await meili.index("products").getStats();
console.log(stats.numberOfDocuments);
// Disk usage is visible via filesystem; no built-in disk usage API per index
// [Unverified: verify if current Meilisearch version exposes per-index disk usage via API]
```

### Capacity Planning

For a rough starting estimate [Inference — actual figures vary widely by document structure]:

| Documents | Avg Doc Size | Estimated Index Size | RAM (comfortable) |
|---|---|---|---|
| 100K | 1KB | ~2–3GB | 4–8GB |
| 1M | 1KB | ~20–30GB | 32–64GB |
| 10M | 1KB | ~200–300GB | 256GB+ |

These are rough estimates. Always benchmark with your actual data. Document field count and text length are the dominant factors.

---

## Part 22 — Scaling

### Vertical Scaling

The most straightforward scaling approach: give Meilisearch more CPU, RAM, and faster disks.

- More RAM: improves query performance via mmap caching
- Faster SSDs (NVMe): reduces indexing and query latency
- More CPU: improves concurrent query handling

### Horizontal Scaling

As of current Meilisearch versions, horizontal scaling (running multiple Meilisearch instances with automatic data sharding) is not a core feature. [Unverified: verify current horizontal scaling capabilities in the latest Meilisearch documentation — this has been an area of active development.]

**Read scaling** can be achieved by running multiple Meilisearch instances with identical data and load-balancing search queries across them:

```mermaid
flowchart LR
    LB[Load Balancer] --> M1[Meilisearch\nInstance 1]
    LB --> M2[Meilisearch\nInstance 2]
    LB --> M3[Meilisearch\nInstance 3]
    SyncWorker[Sync Worker] --> M1
    SyncWorker --> M2
    SyncWorker --> M3
```

The sync worker must push updates to all instances. This is operationally complex and introduces consistency windows between instances.

### High Availability

For high availability without official clustering, the recommended approach is:

1. Run multiple instances on different hosts
2. Sync data to all instances from the same source
3. Use a load balancer with health checks to route away from unhealthy instances
4. Accept brief inconsistency between instances during sync

### Operational Limits

Meilisearch is well-suited for:
- Millions of documents (tested at scale by many users)
- Sub-100ms queries on well-configured indexes

Meilisearch may require reconsideration at:
- Hundreds of millions of documents
- Very high write throughput requiring instant search freshness
- Complex analytics on top of search (use Elasticsearch for this)

[Unverified: exact upper limits change with versions and hardware — always benchmark with your actual workload.]

---

## Part 23 — Production Operations

### Monitoring

#### Health Check Endpoint

```bash
curl https://search.yourdomain.com/health
# {"status":"available"}
```

Use this for load balancer health checks and uptime monitoring.

#### Stats

```typescript
// Overall instance stats
const stats = await meili.getStats();
console.log(stats);
/*
{
  databaseSize: 2048000,
  lastUpdate: "2024-01-15T10:30:00Z",
  indexes: {
    products: { numberOfDocuments: 50000, isIndexing: false, fieldDistribution: {...} }
  }
}
*/

// Per-index stats
const indexStats = await meili.index("products").getStats();
```

#### Prometheus Metrics

Meilisearch exposes Prometheus metrics at `/metrics` (requires enabling in configuration):

```bash
MEILI_EXPERIMENTAL_ENABLE_METRICS=true meilisearch --master-key="..."
```

```yaml
# prometheus.yml scrape config
scrape_configs:
  - job_name: meilisearch
    static_configs:
      - targets: ['localhost:7700']
    bearer_token: your-master-key
```

Key metrics to alert on:
- `meilisearch_http_response_time_seconds` — query latency
- `meilisearch_db_size_bytes` — disk usage
- `meilisearch_index_docs_count` — document count
- `meilisearch_task_queue_size` — queue depth

### Logging

Configure log level and format:

```bash
meilisearch \
  --log-level INFO \
  --log-format json  # For structured log aggregation
```

Log levels: `ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE`

Use `INFO` in production. `DEBUG` is very verbose and will impact performance.

### Alerting Checklist

Alert on:
- Health endpoint returning non-`available` status
- Query p95 latency > 200ms (adjust to your SLA)
- Task queue depth > 1000 (sync is falling behind)
- Failed tasks accumulating (check `GET /tasks?statuses=failed`)
- Disk usage > 80% of allocated storage
- Memory usage > 80% of available RAM

### Backups

Automated backup script (cron):

```bash
#!/bin/bash
set -euo pipefail

MEILI_URL="${MEILI_URL:-http://localhost:7700}"
MEILI_KEY="${MEILI_MASTER_KEY}"
BACKUP_BUCKET="${S3_BACKUP_BUCKET}"
DATE=$(date +%Y%m%d-%H%M%S)

# 1. Trigger dump
echo "Creating Meilisearch dump..."
TASK_UID=$(curl -sf -X POST "$MEILI_URL/dumps" \
  -H "Authorization: Bearer $MEILI_KEY" | jq -r '.taskUid')

# 2. Poll for completion
for i in $(seq 1 60); do
  STATUS=$(curl -sf "$MEILI_URL/tasks/$TASK_UID" \
    -H "Authorization: Bearer $MEILI_KEY" | jq -r '.status')
  echo "Task $TASK_UID status: $STATUS"
  if [ "$STATUS" = "succeeded" ]; then
    break
  elif [ "$STATUS" = "failed" ]; then
    echo "Dump task failed" >&2
    exit 1
  fi
  sleep 10
done

# 3. Upload to S3
DUMP_FILE=$(ls -t /var/lib/meilisearch/dumps/*.dump 2>/dev/null | head -1)
if [ -z "$DUMP_FILE" ]; then
  echo "No dump file found" >&2
  exit 1
fi

aws s3 cp "$DUMP_FILE" "s3://$BACKUP_BUCKET/meilisearch/dumps/$DATE.dump"
echo "Backup uploaded: $DATE.dump"

# 4. Clean up old local dumps (keep last 3)
ls -t /var/lib/meilisearch/dumps/*.dump | tail -n +4 | xargs -r rm
```

### Disaster Recovery

Restore from a dump:

```bash
# Start Meilisearch in import mode
meilisearch \
  --import-dump /path/to/backup.dump \
  --master-key "your-master-key"

# Meilisearch will import the dump and then start normally
```

Alternatively, rebuild from PostgreSQL using the reconciliation function from Part 19.

**Always test your restore procedure before you need it.**

### Upgrade Strategy

1. Read the release notes for breaking changes before upgrading
2. Test the upgrade in a staging environment first
3. Create a dump before upgrading production
4. Upgrade in-place (stop service, update binary/image, restart)
5. Monitor for errors after upgrade

For zero-downtime upgrades: use the blue-green instance approach (two instances; switch traffic after upgrade is verified).

### Reindexing Strategy

When index settings change in ways that require rebuild:

1. Use the blue-green reindexing pattern from Part 9
2. Or: rebuild using the swap indexes API
3. Always have a tested rollback path

### Operations Checklist

**Daily:**
- [ ] Health endpoint responding with `available`
- [ ] No failed tasks accumulating
- [ ] Query latency within SLA

**Weekly:**
- [ ] Backup completed successfully
- [ ] Disk usage trending check
- [ ] Document count matches PostgreSQL row count (reconciliation check)

**Monthly:**
- [ ] Review and prune old dump files
- [ ] Review API key expiry dates
- [ ] Test restore from backup
- [ ] Review search quality metrics (zero-result rate, click-through rate)

---

## Part 24 — Multi-Tenancy

### What Multi-Tenancy Means for Search

A multi-tenant search system serves multiple tenants (customers, organizations, users) from the same infrastructure while ensuring tenant data isolation.

### Strategy 1: Shared Index with Tenant Filter

All tenants' data lives in one index. Each document has a `tenant_id` field. Searches are filtered by `tenant_id`.

```typescript
// Index documents with tenant_id
await index.addDocuments([
  { id: "doc-1", tenant_id: "tenant-abc", content: "..." },
  { id: "doc-2", tenant_id: "tenant-xyz", content: "..." },
]);

// Search is always filtered by tenant
const results = await index.search(query, {
  filter: `tenant_id = "${tenantId}"`,
});
```

**Advantages:**
- Simple to manage (one index)
- No index provisioning per tenant
- Efficient for large numbers of tenants

**Disadvantages:**
- One tenant's data volume can affect all tenants' performance
- Settings (synonyms, stop words, ranking) are shared across tenants
- Must sanitize `tenant_id` carefully to prevent cross-tenant data leaks

### Strategy 2: Per-Tenant Index

Each tenant gets a dedicated index: `products_tenant_abc`, `products_tenant_xyz`.

```typescript
function getTenantIndexUid(tenantId: string, baseIndex: string): string {
  // Validate tenantId to prevent index name injection
  if (!/^[a-zA-Z0-9_-]+$/.test(tenantId)) {
    throw new Error("Invalid tenant ID format");
  }
  return `${baseIndex}_${tenantId}`;
}

// Create index for a new tenant
async function provisionTenant(tenantId: string): Promise<void> {
  const uid = getTenantIndexUid(tenantId, "products");
  const task = await meili.createIndex(uid, { primaryKey: "id" });
  await meili.waitForTask(task.taskUid);

  const settingsTask = await meili.index(uid).updateSettings(PRODUCTS_SETTINGS);
  await meili.waitForTask(settingsTask.taskUid);
}

// Tenant-specific search
async function searchForTenant(tenantId: string, query: string) {
  const uid = getTenantIndexUid(tenantId, "products");
  return meili.index(uid).search(query);
}
```

**Advantages:**
- Complete isolation: one tenant's settings don't affect others
- Per-tenant ranking and synonyms customization
- Easier to delete all data for a tenant (delete the index)

**Disadvantages:**
- Index provisioning adds complexity
- Large numbers of tenants (thousands) may hit operational limits
- More complex backup and monitoring

### Tenant Tokens

Meilisearch supports **tenant tokens**: short-lived signed tokens that scope a search key to a specific filter.

```typescript
// Server-side: generate a tenant token for the current user's tenant
const tenantToken = meili.generateTenantToken(
  "your-search-only-api-key",     // The base search key UID
  { filter: `tenant_id = "${tenantId}"` },  // Embedded filter
  {
    expiresAt: new Date(Date.now() + 3600 * 1000),  // 1 hour
    apiKey: "your-search-only-api-key",
  },
);

// Send tenantToken to the frontend — it can only search within its tenant
```

The tenant token is a JWT. The client uses it like an API key, but the embedded filter is cryptographically enforced by Meilisearch.

This is the most secure multi-tenancy pattern: the filter constraint cannot be bypassed by the frontend.

---

## Part 25 — Comparisons

### Meilisearch vs PostgreSQL Full-Text Search

| | Meilisearch | PostgreSQL FTS |
|---|---|---|
| Typo tolerance | Built-in | Requires custom work or extensions |
| Facets | Built-in | Manual SQL aggregation |
| Setup | Separate service | No extra infra |
| Consistency | Eventually consistent | Transactionally consistent |
| Ranking | Configurable pipeline | `ts_rank()` (basic) |
| Synonyms | Built-in UI/API | Manual dictionary config |
| Autocomplete | Built-in | Complex to implement |
| Maintenance | Separate service to operate | Zero (runs with PG) |
| Best for | User-facing search boxes | Small datasets, no extra infra tolerance |

### Meilisearch vs Elasticsearch / OpenSearch

| | Meilisearch | Elasticsearch/OpenSearch |
|---|---|---|
| Complexity | Low | High |
| Query DSL | Simple REST | Complex JSON DSL |
| Typo tolerance | Built-in | Configurable (fuzzy queries) |
| Analytics | Not designed for it | Excellent (Kibana/OpenSearch Dashboards) |
| Scalability | Limited horizontal scaling | Full distributed scaling |
| Operational burden | Low | High (JVM tuning, cluster management) |
| Log ingestion | Not designed for it | Excellent |
| Vector search | Developing [Unverified] | Mature (dense_vector) |
| Self-hosting cost | Low | High (RAM-hungry JVM) |
| Best for | Developer-friendly app search | Enterprise search + analytics + logs |

### Meilisearch vs Typesense

| | Meilisearch | Typesense |
|---|---|---|
| Language | Rust | C++ |
| Open source license | MIT | GPL (self-hosted) / proprietary (cloud) |
| Clustering | Not native | Built-in |
| API design | Similar | Similar |
| Typo tolerance | ✅ | ✅ |
| Facets | ✅ | ✅ |
| Vector search | Developing | ✅ (hybrid search) |
| Managed cloud | Meilisearch Cloud | Typesense Cloud |
| Community | Large | Smaller but growing |
| Best for | Self-hosted simplicity | When built-in clustering matters |

### Meilisearch vs Algolia

| | Meilisearch | Algolia |
|---|---|---|
| Hosting | Self-hosted or Meilisearch Cloud | SaaS only |
| Pricing | Free self-hosted; cloud pricing | Expensive at scale |
| Features | Subset of Algolia | Full-featured |
| SLA | Yours to provide | 99.99% guaranteed |
| InstantSearch.js | Compatible | Natively built for it |
| Compliance | Yours to manage | SOC 2, GDPR, etc. |
| Best for | Self-hosted or cost-sensitive | Mission-critical search, no ops team |

---

## Part 26 — Common Pitfalls

### 1. Poor Document Design

**Problem:** Indexing normalized relational records with foreign key IDs.

```json
// BAD: Users search "Keychron" — this document has brand_id = 42, not "Keychron"
{ "id": "prod-1", "title": "K2 Keyboard", "brand_id": 42, "category_id": 5 }
```

**Solution:** Denormalize. Join before indexing (Part 20).

### 2. Missing `filterableAttributes` Configuration

**Problem:** Calling `filter: 'price < 100'` on an attribute not declared filterable. Returns an error.

**Solution:** Declare all fields you'll filter on in `filterableAttributes` before indexing documents. Remember that changing `filterableAttributes` after documents are indexed triggers a re-indexing task.

### 3. Embedding the Master Key in Frontend Code

**Problem:** Using the master key in a JavaScript client bundle. It is visible to anyone who opens DevTools.

**Solution:** Create a search-only API key with limited index access. Use that in the frontend.

### 4. Sync Failures Causing Silent Data Divergence

**Problem:** Meilisearch update fails silently while PostgreSQL write succeeds. Search results become stale.

**Solution:**
- Use a queue-based sync with retry logic
- Implement periodic reconciliation (diff PostgreSQL vs Meilisearch document counts)
- Alert on sync worker errors

### 5. Not Handling the Asynchronous Nature of Meilisearch

**Problem:** Adding documents and immediately searching — documents aren't visible yet.

```typescript
// BAD: Documents may not be indexed yet
await index.addDocuments([newProduct]);
const results = await index.search("keyword");  // newProduct may not appear
```

**Solution:** In tests and one-off scripts, wait for tasks. In production, communicate to users that new items appear in search within a few seconds.

### 6. Using `LIKE '%term%'` When You Have Meilisearch

**Problem:** Developer adds a PostgreSQL `ILIKE '%keyword%'` query for search after Meilisearch is already in the stack.

**Solution:** Route all text search through Meilisearch. Use PostgreSQL only for structured lookups.

### 7. Reindexing Without a Staging Index

**Problem:** Deleting all documents and re-adding them — index returns zero results during the window between deletion and re-indexing completion.

**Solution:** Use the blue-green pattern with `swapIndexes`.

### 8. Not Pinning the Docker Image Version

**Problem:** Using `getmeili/meilisearch:latest` in production. An update breaks your schema or API.

**Solution:** Pin to a specific version: `getmeili/meilisearch:v1.7.0`. Update intentionally.

### 9. Ignoring Filter Injection

**Problem:** Including unsanitized user input directly in filter strings.

**Solution:** Validate all filter values against allowlists before interpolation (Part 17).

### 10. Expecting Horizontal Scaling Out of the Box

**Problem:** Assuming Meilisearch has Elasticsearch-style automatic sharding for very large datasets.

**Solution:** Plan vertically first. For very large datasets, evaluate whether Meilisearch is the right tool or plan custom read-replica architecture.

---

## Part 27 — Complete Production Project

This section builds a production-grade search system for an e-commerce catalog.

### Architecture

```mermaid
flowchart TB
    subgraph "Client Layer"
        Next[Next.js Frontend\nApp Router]
    end

    subgraph "API Layer"
        Fastify[Fastify API\nNode.js + TypeScript]
    end

    subgraph "Data Layer"
        PG[(PostgreSQL 16\nSource of Truth)]
        Redis[(Redis\nQueue Backend)]
        Meili[(Meilisearch\nSearch Layer)]
    end

    subgraph "Sync Layer"
        Worker[BullMQ Worker\nSync Service]
    end

    Next -->|HTTP| Fastify
    Fastify -->|Reads/Writes| PG
    Fastify -->|Search| Meili
    Fastify -->|Enqueue jobs| Redis
    Redis -->|Dequeue jobs| Worker
    Worker -->|Fetch full data| PG
    Worker -->|Index documents| Meili
```

### Directory Structure

```
project/
├── docker-compose.yml
├── docker-compose.prod.yml
├── .env.example
├── packages/
│   ├── api/           # Fastify backend
│   │   ├── src/
│   │   │   ├── app.ts
│   │   │   ├── config.ts
│   │   │   ├── plugins/
│   │   │   │   ├── postgres.ts
│   │   │   │   ├── meilisearch.ts
│   │   │   │   └── bullmq.ts
│   │   │   ├── routes/
│   │   │   │   ├── products.ts
│   │   │   │   └── search.ts
│   │   │   ├── services/
│   │   │   │   ├── product.service.ts
│   │   │   │   └── search.service.ts
│   │   │   └── workers/
│   │   │       └── sync.worker.ts
│   │   ├── migrations/
│   │   │   └── 001_initial.sql
│   │   └── package.json
│   └── web/           # Next.js frontend
│       ├── app/
│       │   ├── page.tsx
│       │   ├── products/
│       │   │   └── page.tsx
│       │   └── api/
│       │       └── search/
│       │           └── route.ts
│       └── package.json
```

### Docker Compose (Development)

```yaml
version: "3.9"

services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppassword
      POSTGRES_DB: shopdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./packages/api/migrations:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d shopdb"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  meilisearch:
    image: getmeili/meilisearch:v1.7.0
    environment:
      MEILI_MASTER_KEY: dev-master-key
      MEILI_ENV: development
    volumes:
      - meilisearch_data:/meili_data
    ports:
      - "7700:7700"

  api:
    build: ./packages/api
    environment:
      DATABASE_URL: postgresql://appuser:apppassword@postgres:5432/shopdb
      REDIS_URL: redis://redis:6379
      MEILI_HOST: http://meilisearch:7700
      MEILI_MASTER_KEY: dev-master-key
      MEILI_SEARCH_KEY: ""  # Generated at startup
      PORT: "3001"
      NODE_ENV: development
    ports:
      - "3001:3001"
    depends_on:
      postgres:
        condition: service_healthy
      meilisearch:
        condition: service_started
      redis:
        condition: service_started
    volumes:
      - ./packages/api/src:/app/src

  web:
    build: ./packages/web
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:3001
      MEILI_HOST: http://meilisearch:7700
      MEILI_SEARCH_KEY: ""  # Injected at build or runtime
    ports:
      - "3000:3000"
    depends_on:
      - api

volumes:
  postgres_data:
  redis_data:
  meilisearch_data:
```

### Database Schema

```sql
-- packages/api/migrations/001_initial.sql

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE brands (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  country TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  parent_id INTEGER REFERENCES categories(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  price NUMERIC(10, 2) NOT NULL,
  brand_id INTEGER NOT NULL REFERENCES brands(id),
  category_id INTEGER NOT NULL REFERENCES categories(id),
  tags TEXT[] DEFAULT '{}',
  in_stock BOOLEAN NOT NULL DEFAULT true,
  rating NUMERIC(3, 2),
  image_url TEXT,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_deleted_at ON products(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_updated_at ON products(updated_at);

-- Trigger to update updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_set_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Trigger to notify sync worker
CREATE OR REPLACE FUNCTION notify_product_sync()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify(
    'product_sync',
    json_build_object(
      'operation', TG_OP,
      'id', COALESCE(NEW.id, OLD.id)::text
    )::text
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_sync_notify
  AFTER INSERT OR UPDATE OR DELETE ON products
  FOR EACH ROW EXECUTE FUNCTION notify_product_sync();

-- Seed data
INSERT INTO brands (name, country) VALUES
  ('Keychron', 'US'),
  ('Logitech', 'CH'),
  ('Dell', 'US');

INSERT INTO categories (name, slug) VALUES
  ('Keyboards', 'keyboards'),
  ('Mice', 'mice'),
  ('Monitors', 'monitors');
```

### Search Index Configuration

```typescript
// packages/api/src/config/search-index.ts
import type { Settings } from "meilisearch";

export const PRODUCTS_INDEX_UID = "products";

export const PRODUCTS_INDEX_SETTINGS: Settings = {
  searchableAttributes: [
    "title",
    "brand",
    "tags",
    "category",
    "description",
  ],
  filterableAttributes: [
    "category",
    "brand",
    "price",
    "in_stock",
    "tags",
    "rating",
    "created_at_ts",
  ],
  sortableAttributes: [
    "price",
    "rating",
    "created_at_ts",
  ],
  rankingRules: [
    "words",
    "typo",
    "proximity",
    "attribute",
    "sort",
    "exactness",
  ],
  typoTolerance: {
    enabled: true,
    minWordSizeForTypos: {
      oneTypo: 5,
      twoTypos: 9,
    },
  },
  faceting: {
    maxValuesPerFacet: 50,
  },
  pagination: {
    maxTotalHits: 1000,
  },
};
```

### Fastify API — Core Files

```typescript
// packages/api/src/config.ts
import { z } from "zod";

const ConfigSchema = z.object({
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  PORT: z.coerce.number().default(3001),
  DATABASE_URL: z.string(),
  REDIS_URL: z.string(),
  MEILI_HOST: z.string(),
  MEILI_MASTER_KEY: z.string(),
  LOG_LEVEL: z.string().default("info"),
});

const parsed = ConfigSchema.safeParse(process.env);
if (!parsed.success) {
  console.error("Invalid configuration:", parsed.error.format());
  process.exit(1);
}

export const config = parsed.data;
```

```typescript
// packages/api/src/plugins/postgres.ts
import fp from "fastify-plugin";
import { FastifyInstance } from "fastify";
import pg from "pg";

declare module "fastify" {
  interface FastifyInstance {
    db: pg.Pool;
  }
}

export default fp(async (fastify: FastifyInstance) => {
  const pool = new pg.Pool({
    connectionString: process.env.DATABASE_URL,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  });

  // Verify connectivity
  const client = await pool.connect();
  await client.query("SELECT 1");
  client.release();

  fastify.decorate("db", pool);

  fastify.addHook("onClose", async () => {
    await pool.end();
  });

  fastify.log.info("Connected to PostgreSQL");
});
```

```typescript
// packages/api/src/workers/sync.worker.ts
import { Worker, Job } from "bullmq";
import { createClient } from "redis";
import { MeiliSearch } from "meilisearch";
import pg from "pg";
import { PRODUCTS_INDEX_UID } from "../config/search-index.js";

interface SyncJob {
  operation: "INSERT" | "UPDATE" | "DELETE";
  id: string;
}

const FETCH_PRODUCT_SQL = `
  SELECT
    p.id::text,
    p.title,
    p.description,
    p.price::float,
    p.tags,
    p.in_stock,
    p.rating::float,
    EXTRACT(EPOCH FROM p.created_at)::integer AS created_at_ts,
    b.name AS brand,
    c.name AS category
  FROM products p
  JOIN brands b ON p.brand_id = b.id
  JOIN categories c ON p.category_id = c.id
  WHERE p.id = $1 AND p.deleted_at IS NULL
`;

export function createSyncWorker(
  redisUrl: string,
  meiliHost: string,
  meiliKey: string,
  dbUrl: string,
) {
  const redis = createClient({ url: redisUrl });
  const meili = new MeiliSearch({ host: meiliHost, apiKey: meiliKey });
  const db = new pg.Pool({ connectionString: dbUrl, max: 5 });

  const worker = new Worker<SyncJob>(
    "product-sync",
    async (job: Job<SyncJob>) => {
      const { operation, id } = job.data;

      if (operation === "DELETE") {
        await meili.index(PRODUCTS_INDEX_UID).deleteDocument(id);
        return;
      }

      const result = await db.query(FETCH_PRODUCT_SQL, [id]);

      if (result.rows.length === 0) {
        // Product was deleted after job was enqueued
        await meili.index(PRODUCTS_INDEX_UID).deleteDocument(id);
        return;
      }

      await meili.index(PRODUCTS_INDEX_UID).addDocuments([result.rows[0]]);
    },
    {
      connection: redis,
      concurrency: 3,
      defaultJobOptions: {
        attempts: 5,
        backoff: { type: "exponential", delay: 1000 },
        removeOnComplete: 100,
        removeOnFail: 500,
      },
    },
  );

  worker.on("failed", (job, err) => {
    console.error(`Sync job ${job?.id} failed:`, err.message);
  });

  return worker;
}
```

```typescript
// packages/api/src/routes/search.ts
import { FastifyInstance } from "fastify";
import { Type, Static } from "@sinclair/typebox";

const ProductSearchQuery = Type.Object({
  q: Type.Optional(Type.String({ default: "" })),
  page: Type.Optional(Type.Integer({ minimum: 1, default: 1 })),
  hitsPerPage: Type.Optional(
    Type.Integer({ minimum: 1, maximum: 100, default: 20 }),
  ),
  category: Type.Optional(Type.String()),
  brand: Type.Optional(Type.String()),
  minPrice: Type.Optional(Type.Number({ minimum: 0 })),
  maxPrice: Type.Optional(Type.Number({ minimum: 0 })),
  inStockOnly: Type.Optional(Type.Boolean({ default: false })),
  sort: Type.Optional(
    Type.Union([
      Type.Literal("price:asc"),
      Type.Literal("price:desc"),
      Type.Literal("rating:desc"),
      Type.Literal("newest"),
    ]),
  ),
});

type SearchQuery = Static<typeof ProductSearchQuery>;

// Allowlist for filterable string values
const VALID_CATEGORIES = new Set([
  "keyboards", "mice", "monitors", "headphones",
]);
const VALID_BRANDS = new Set([
  "keychron", "logitech", "dell",
]);

export default async function searchRoutes(fastify: FastifyInstance) {
  fastify.get<{ Querystring: SearchQuery }>(
    "/",
    { schema: { querystring: ProductSearchQuery } },
    async (request, reply) => {
      const {
        q = "",
        page = 1,
        hitsPerPage = 20,
        category,
        brand,
        minPrice,
        maxPrice,
        inStockOnly = false,
        sort,
      } = request.query;

      const filterClauses: string[] = [];

      if (category) {
        if (!VALID_CATEGORIES.has(category.toLowerCase())) {
          return reply.code(400).send({ error: "Invalid category" });
        }
        filterClauses.push(`category = "${category}"`);
      }

      if (brand) {
        if (!VALID_BRANDS.has(brand.toLowerCase())) {
          return reply.code(400).send({ error: "Invalid brand" });
        }
        filterClauses.push(`brand = "${brand}"`);
      }

      if (minPrice !== undefined && maxPrice !== undefined) {
        filterClauses.push(`price ${minPrice} TO ${maxPrice}`);
      } else if (minPrice !== undefined) {
        filterClauses.push(`price >= ${minPrice}`);
      } else if (maxPrice !== undefined) {
        filterClauses.push(`price <= ${maxPrice}`);
      }

      if (inStockOnly) {
        filterClauses.push(`in_stock = true`);
      }

      const sortParam =
        sort === "newest"
          ? ["created_at_ts:desc"]
          : sort
            ? [sort]
            : undefined;

      try {
        const results = await fastify.meili
          .index("products")
          .search(q, {
            page,
            hitsPerPage,
            filter: filterClauses.length > 0 ? filterClauses.join(" AND ") : undefined,
            sort: sortParam,
            facets: ["category", "brand", "in_stock"],
            attributesToHighlight: ["title"],
            highlightPreTag: "<mark>",
            highlightPostTag: "</mark>",
            attributesToRetrieve: [
              "id", "title", "brand", "price", "category",
              "in_stock", "rating", "image_url",
            ],
          });

        return results;
      } catch (error) {
        fastify.log.error({ error, query: q }, "Search failed");
        return reply.code(503).send({ error: "Search temporarily unavailable" });
      }
    },
  );
}
```

### Next.js Frontend — Search Page

```tsx
// packages/web/app/products/page.tsx
import { Suspense } from "react";
import { ProductGrid } from "@/components/ProductGrid";
import { FacetSidebar } from "@/components/FacetSidebar";
import { SearchBar } from "@/components/SearchBar";
import { Pagination } from "@/components/Pagination";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3001";

interface ProductsPageProps {
  searchParams: {
    q?: string;
    page?: string;
    category?: string;
    brand?: string;
    sort?: string;
  };
}

async function fetchProducts(params: Record<string, string>) {
  const qs = new URLSearchParams(params).toString();
  const res = await fetch(`${API_URL}/api/search?${qs}`, {
    next: { revalidate: 60 },  // Cache for 60 seconds
  });
  if (!res.ok) throw new Error(`Search failed: ${res.status}`);
  return res.json();
}

export default async function ProductsPage({
  searchParams,
}: ProductsPageProps) {
  const params: Record<string, string> = {};
  if (searchParams.q) params.q = searchParams.q;
  if (searchParams.page) params.page = searchParams.page;
  if (searchParams.category) params.category = searchParams.category;
  if (searchParams.brand) params.brand = searchParams.brand;
  if (searchParams.sort) params.sort = searchParams.sort;

  const results = await fetchProducts(params);

  return (
    <main className="products-page">
      <div className="search-header">
        <SearchBar initialValue={searchParams.q ?? ""} />
      </div>

      <div className="search-layout">
        <aside className="facets">
          <FacetSidebar
            facetDistribution={results.facetDistribution}
            activeCategory={searchParams.category}
            activeBrand={searchParams.brand}
          />
        </aside>

        <section className="results">
          <div className="results-header">
            <span>
              {results.estimatedTotalHits ?? results.totalHits ?? 0} results
            </span>
            <span className="processing-time">
              {results.processingTimeMs}ms
            </span>
          </div>

          <Suspense fallback={<div>Loading products…</div>}>
            <ProductGrid products={results.hits} />
          </Suspense>

          <Pagination
            currentPage={results.page ?? 1}
            totalPages={results.totalPages ?? 1}
            baseUrl="/products"
            searchParams={searchParams}
          />
        </section>
      </div>
    </main>
  );
}
```

### Monitoring Configuration

```yaml
# monitoring/docker-compose.monitoring.yml
version: "3.9"

services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    ports:
      - "3030:3000"
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  grafana_data:
```

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: meilisearch
    static_configs:
      - targets: ['meilisearch:7700']
    bearer_token: "dev-master-key"
    metrics_path: /metrics

  - job_name: node_api
    static_configs:
      - targets: ['api:3001']
    metrics_path: /metrics
```

### Production Deployment Checklist

**Before going live:**

- [ ] Meilisearch instance is running with a strong master key
- [ ] Master key is not in version control
- [ ] A search-only API key is created and used in the frontend
- [ ] Port 7700 is not directly exposed to the internet
- [ ] Nginx reverse proxy is configured with TLS
- [ ] Volume for Meilisearch data directory is mounted and persisted
- [ ] Docker image version is pinned (not `latest`)
- [ ] Backup script is configured and tested
- [ ] Restore from backup has been tested
- [ ] Health check is configured in load balancer
- [ ] Sync worker is running and monitored
- [ ] Failed job alerts are configured
- [ ] Disk usage alert is configured
- [ ] Meilisearch version is documented

---

## Summary

This guide has covered the full lifecycle of a Meilisearch deployment:

**Conceptual foundation** (Parts 1–5): What search is, why databases are not search engines, how search engines work internally, and how Meilisearch's indexing and query pipelines operate.

**Operations** (Parts 6–7): How to run Meilisearch in development and production, secure it, and manage API keys.

**Core API** (Parts 8–15): Documents, settings, search parameters, ranking, filtering, sorting, facets, typo tolerance, and synonyms.

**Integration** (Parts 16–17): Frontend patterns in React and Next.js, backend patterns with Fastify and Node.js.

**Architecture** (Parts 18–20): How PostgreSQL and Meilisearch work together, synchronization strategies and their tradeoffs, and how to model documents for search.

**Production engineering** (Parts 21–24): Performance, scaling, operations, and multi-tenancy.

**Reference** (Parts 25–27): Comparisons, common pitfalls, and a complete production project.

---

> **Reminder:** Search engine behavior, API specifics, and performance characteristics change with software versions. Always verify decisions against the official Meilisearch documentation at [https://www.meilisearch.com/docs](https://www.meilisearch.com/docs) before deploying to production.