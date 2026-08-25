The inverted index
## The Inverted Index

### What the Inverted Index Is

The inverted index is the core data structure that makes full-text search possible in Lucene and, by extension, Elasticsearch. The name derives from the inversion of the natural document-centric view of data: rather than mapping documents to the words they contain, an inverted index maps words to the documents that contain them.

This inversion is what allows Elasticsearch to answer the question "which documents contain this term?" in sub-linear time relative to the total corpus size, rather than scanning every document sequentially.

**Key Points:**
- Every text field in an Elasticsearch document has its own inverted index within a segment
- The inverted index is built at index time and is immutable once written
- Multiple inverted indexes exist per shard — one per analyzed text field per segment
- Non-text fields (numeric, keyword, date) use different structures (BKD trees, doc values)

### Forward Index vs. Inverted Index

To understand the inversion, consider the contrast between a forward index and an inverted index.

**Forward Index (document-centric):**

```
Doc ID  →  Terms
──────────────────────────────────────
doc1    →  [error, timeout, server]
doc2    →  [warning, disk, space]
doc3    →  [error, disk, full]
```

**Inverted Index (term-centric):**

```
Term      →  Document IDs
──────────────────────────────────────
disk      →  [doc2, doc3]
error     →  [doc1, doc3]
full      →  [doc3]
server    →  [doc1]
space     →  [doc2]
timeout   →  [doc1]
warning   →  [doc2]
```

A search for `error` requires only a single lookup in the inverted index to retrieve the matching document list, regardless of how many total documents exist.

### Analysis and Tokenization

Before a document's text is stored in the inverted index, it passes through an analysis pipeline. Analysis transforms raw text into the normalized tokens actually stored in the index. The same analysis process is applied at search time to query strings, ensuring consistency between what is stored and what is searched.

**Analysis Pipeline:**

```
Raw Text Input
      ↓
  Character Filters      (optional: strip HTML, normalize characters)
      ↓
    Tokenizer            (split text into tokens)
      ↓
  Token Filters          (lowercase, stop words, stemming, synonyms)
      ↓
Normalized Token Stream  (stored in inverted index)
```

**Example:**

Input text: `"The Server encountered an ERROR during Timeout"`

After standard analysis:

```
[server] [encountered] [error] [during] [timeout]
```

Transformations applied:
- Lowercasing: `ERROR` → `error`
- Stop word removal: `The`, `an` removed
- Tokenization: split on whitespace and punctuation

**[Inference]** The choice of analyzer directly determines search behavior. Using different analyzers at index time and search time can cause mismatches that result in unexpected zero-result queries.

### Anatomy of a Postings List

The list of document IDs associated with a term in the inverted index is called a postings list. Each entry in a postings list is called a posting. Beyond document IDs, postings can optionally contain additional information depending on index configuration.

**Posting Components:**

```
Term: "error"
─────────────────────────────────────────────────────────
Posting 1:  doc_id=1,  freq=3,  positions=[2, 7, 14],   offsets=[(10,15),(32,37),(61,66)]
Posting 2:  doc_id=3,  freq=1,  positions=[0],           offsets=[(0,5)]
Posting 3:  doc_id=7,  freq=5,  positions=[1,4,8,11,19], offsets=[(5,10),(18,23),...]
```

**Posting Fields:**

- **doc_id**: The document identifier within the segment
- **freq**: Term frequency — how many times the term appears in the document; used in relevance scoring
- **positions**: Ordinal position of each occurrence; enables phrase queries and proximity queries
- **offsets**: Character start and end positions; used for highlighting

**Storage Trade-offs:**

Storing positions and offsets increases index size. Index options control what is stored:

| `index_options` Value | Stored Information |
|---|---|
| `docs` | Document IDs only |
| `freqs` | Document IDs + term frequency |
| `positions` | Document IDs + frequency + positions |
| `offsets` | Document IDs + frequency + positions + offsets |

The default for `text` fields is `positions`.

### Term Dictionary and Term Index

The inverted index is composed of two primary lookup structures working together: the term dictionary and the term index.

**Term Dictionary:**

The term dictionary is a sorted list of all unique terms across all documents in a segment. It is stored on disk and maps each term to its postings list. Because terms are sorted, binary search can locate any term efficiently.

```
Term Dictionary (sorted)
────────────────────────
disk      → [postings]
error     → [postings]
failed    → [postings]
full      → [postings]
server    → [postings]
timeout   → [postings]
warning   → [postings]
```

**Term Index:**

Scanning the term dictionary sequentially for every query would be slow for large dictionaries. Lucene maintains a term index — a sparse, in-memory structure (typically an FST: Finite State Transducer) that provides fast approximate lookup positions within the on-disk term dictionary.

```
Query Term: "server"
      ↓
Term Index (in-memory FST)
└── Approximate offset into term dictionary on disk
      ↓
Term Dictionary (disk seek to approximate position)
└── Binary search within range → exact match
      ↓
Postings List retrieved
```

**[Inference]** The term index is typically loaded into the JVM heap at segment open time. A large number of unique terms across many segments may contribute meaningfully to heap pressure, though the actual memory impact depends on term cardinality and field count.

### Finite State Transducers (FST)

Lucene uses Finite State Transducers as the in-memory representation of the term index. An FST is a compressed, directed acyclic graph that encodes a mapping from terms to values (offsets) with significant memory efficiency compared to a plain hash map.

**Properties of FSTs:**
- Shared prefixes and suffixes are stored only once, dramatically reducing memory usage
- Lookup is O(n) where n is the length of the term, not the number of terms
- Read-only after construction; rebuilt when segments merge
- Supports prefix-based iteration, enabling prefix queries and suggestions efficiently

**[Inference]** For fields with extremely high term cardinality (e.g., unique identifiers stored as text), FST memory consumption may become a concern. Using `keyword` fields with doc values instead of analyzed `text` fields is often more appropriate for such cases.

### Relevance Scoring and the Inverted Index

The inverted index stores the raw data that feeds Elasticsearch's relevance scoring. By default, Elasticsearch uses the BM25 ranking algorithm to score documents against a query.

**BM25 Key Inputs (sourced from inverted index):**

- **Term Frequency (TF)**: How often the query term appears in the document — retrieved from the postings list
- **Inverse Document Frequency (IDF)**: How rare the term is across all documents — derived from the term dictionary's document frequency count
- **Field Length Norm**: Penalizes longer documents for containing a term — stored in the norms component of the segment

**Scoring Intuition:**

```
Higher Score When:
├── Term appears frequently in the document (high TF)
├── Term is rare across the corpus (high IDF)
└── Document field is short relative to average (norm boost)
```

**[Inference]** Fields indexed with `index_options: docs` (no frequency stored) cannot use TF for scoring. All matching documents for a term will receive equal term-frequency contribution, which may affect ranking quality depending on the use case.

### Multi-Field Inverted Indexes

Each analyzed text field in a mapping creates its own independent inverted index within a segment. A document with multiple text fields contributes to multiple inverted indexes simultaneously.

**Example Mapping:**

```json
{
  "mappings": {
    "properties": {
      "title":   { "type": "text" },
      "body":    { "type": "text" },
      "tags":    { "type": "keyword" }
    }
  }
}
```

**Resulting Inverted Index Structure per Segment:**

```
Segment
├── Inverted Index: "title" field
│   └── Terms from title values → postings
├── Inverted Index: "body" field
│   └── Terms from body values → postings
└── (keyword field "tags" uses a separate posting structure
    with no analysis applied)
```

A `multi_field` mapping (using `fields`) creates additional inverted indexes for the same source value analyzed differently.

### Phrase Queries and Position Data

Phrase queries require that matching terms appear adjacent to one another and in the correct order. This is only possible because positions are stored in the postings list.

**Example:**

Query: `"disk full"`

```
Postings for "disk":    doc3 → positions [2]
Postings for "full":    doc3 → positions [3]
```

Since position of `full` (3) immediately follows position of `disk` (2), the phrase query matches `doc3`. A document where both terms appear but not adjacently would not match a strict phrase query.

**Proximity (Slop) Queries:**

A slop value allows terms to match within a positional distance:

```json
{
  "match_phrase": {
    "message": {
      "query": "disk full",
      "slop": 2
    }
  }
}
```

This permits up to 2 intervening tokens between `disk` and `full`.

### Keyword Fields and the Inverted Index

`keyword` fields are also stored in an inverted index, but without analysis. The entire field value is treated as a single token, normalized only by optional `normalizer` configuration (e.g., lowercasing).

**Behavior Comparison:**

| Behavior | `text` Field | `keyword` Field |
|---|---|---|
| Analysis applied | Yes | No (or normalizer only) |
| Supports full-text search | Yes | No (exact match only) |
| Supports term aggregations | No (high cardinality) | Yes |
| Supports sorting | Not directly | Yes (via doc values) |
| Postings list entries | One per token | One per full value |

### Stored Fields vs. the Inverted Index

The inverted index does not store the original document text — it stores analyzed tokens for search purposes. Original field values are stored separately in the stored fields structure within the segment.

```
Document: { "message": "The Server encountered an ERROR" }

Stored Fields:
└── message → "The Server encountered an ERROR"   ← original value

Inverted Index (message field):
└── server → [doc_id, freq, positions]
└── encountered → [doc_id, freq, positions]
└── error → [doc_id, freq, positions]
```

When Elasticsearch returns `_source` in search results, it retrieves data from stored fields (or the `_source` field), not from the inverted index.

### Configuring Inverted Index Behavior

Mapping parameters control what is stored in the inverted index for each field:

**Disabling Indexing:**

```json
{
  "mappings": {
    "properties": {
      "raw_payload": {
        "type": "text",
        "index": false
      }
    }
  }
}
```

Setting `index: false` prevents the field from being added to the inverted index entirely. The field can still be stored and returned in results but cannot be searched.

**Controlling Index Options:**

```json
{
  "mappings": {
    "properties": {
      "log_message": {
        "type": "text",
        "index_options": "freqs"
      }
    }
  }
}
```

**Disabling Norms:**

```json
{
  "mappings": {
    "properties": {
      "status_code": {
        "type": "text",
        "norms": false
      }
    }
  }
}
```

Disabling norms saves approximately one byte per document per field and is appropriate when field-length normalization is not needed for scoring.

### Inverted Index and Segment Merging

When segments are merged, their inverted indexes are also merged. The merge process combines term dictionaries, deduplicates entries, removes postings for deleted documents, and constructs a new FST for the merged segment's term index.

**Merge Impact on Inverted Index:**

```
Segment A Inverted Index:
└── error → [doc1, doc3]

Segment B Inverted Index:
└── error → [doc7, doc9]

After Merge → Segment C Inverted Index:
└── error → [doc1, doc3, doc7, doc9]
    (with deleted doc postings removed)
```

**[Inference]** Merging segments with large term dictionaries may be memory- and CPU-intensive, as FST construction for the merged segment requires processing the combined term set. Actual resource impact depends on segment sizes and term cardinality.

### Practical Implications for Index Design

**Field Mapping Decisions:**
- Use `text` fields only for fields requiring full-text search
- Use `keyword` fields for exact-match, aggregation, and sorting use cases
- Avoid indexing fields that are never searched; set `index: false` to reduce overhead
- Consider `index_options: docs` or `freqs` for fields where position-based queries are not needed

**Analyzer Selection:**
- Match the analyzer to the search behavior expected by the application
- Use the same analyzer at index time and search time unless intentionally asymmetric
- Custom analyzers allow fine-grained control over tokenization and normalization

**Cardinality Awareness:**
- High-cardinality text fields (UUIDs, raw URLs) produce very large term dictionaries
- Large term dictionaries increase FST memory consumption and segment merge cost
- [Inference] Consider whether such fields genuinely require full-text indexing or whether `keyword` with `index: false` and doc values only is more appropriate

**Conclusion:**

The inverted index is the foundational structure behind Elasticsearch's search capabilities. Its design — mapping terms to documents rather than documents to terms, enriched with frequency, position, and offset data — enables everything from basic keyword matching to complex phrase queries and relevance-ranked retrieval. Understanding its structure, the role of analysis in shaping what is stored, and the configuration options available through field mappings is essential for designing indices that are both performant and correctly tuned to application search requirements.