## Handling Large Files with Chunked Reading

### Overview

When a dataset is too large to comfortably fit in memory, or when only partial processing is needed, Pandas supports reading files in fixed-size chunks rather than loading the entire file at once. This applies primarily to `read_csv()` and `read_json()` (with `lines=True`), and conceptually to `read_sql()` via its own `chunksize` mechanism covered separately in SQL-specific contexts.

### Basic Chunked Reading with `read_csv`

```python
import pandas as pd

chunk_iter = pd.read_csv("large_file.csv", chunksize=100_000)

for chunk in chunk_iter:
    process(chunk)
```

`chunksize` causes `read_csv()` to return a `TextFileReader` iterator instead of a single DataFrame. Each iteration yields a DataFrame containing at most `chunksize` rows.

**Key Points**
- Column dtypes are inferred independently per chunk unless explicitly specified via `dtype`, which can cause inconsistent types across chunks if the underlying data varies (e.g., a column that's all integers in one chunk but contains a stray string in another).
- Explicitly setting `dtype` for each column avoids this per-chunk inference inconsistency.

```python
dtypes = {"id": "int64", "amount": "float64", "category": "category"}
chunk_iter = pd.read_csv("large_file.csv", chunksize=100_000, dtype=dtypes)
```

### Aggregating Across Chunks

A common pattern is accumulating a result across chunks rather than holding all data at once:

```python
total = 0
row_count = 0

for chunk in pd.read_csv("large_file.csv", chunksize=100_000):
    total += chunk["amount"].sum()
    row_count += len(chunk)

overall_mean = total / row_count
```

This computes a running sum and count instead of concatenating all chunks first, keeping peak memory usage bounded by chunk size rather than total file size.

For more complex aggregations (e.g., groupby across the full dataset), partial results per chunk typically need to be combined afterward:

```python
partial_sums = []

for chunk in pd.read_csv("large_file.csv", chunksize=100_000):
    partial_sums.append(chunk.groupby("category")["amount"].sum())

combined = pd.concat(partial_sums).groupby(level=0).sum()
```

### Filtering Rows While Reading

Chunked reading is also used to filter down a large file to only the rows of interest, without ever holding the full unfiltered file in memory:

```python
filtered_chunks = []

for chunk in pd.read_csv("large_file.csv", chunksize=100_000):
    filtered_chunks.append(chunk[chunk["status"] == "active"])

result = pd.concat(filtered_chunks, ignore_index=True)
```

**Key Points**
- Peak memory usage in this pattern is bounded by chunk size plus the accumulated filtered result, not the full original file size.
- [Inference] For very selective filters (where only a small fraction of rows match), this pattern is generally more memory-efficient than loading and then filtering the whole file — this follows directly from the filtered subset being much smaller than the source, but actual memory savings depend on selectivity and row width, which I have not measured for any specific dataset.

### Chunked Reading with JSON Lines

```python
chunk_iter = pd.read_json("large_file.jsonl", lines=True, chunksize=50_000)

for chunk in chunk_iter:
    process(chunk)
```

`chunksize` combined with `lines=True` works because JSON Lines format has one record per line, giving a natural row boundary to chunk on — unlike a single JSON array, which cannot be split into arbitrary chunks without parsing the full structure first. [Unverified] Whether standard (non-lines) `read_json()` supports `chunksize` at all, and under what conditions, is not something I can confirm without checking documentation for the specific Pandas version in use.

### Using `usecols` and `dtype` to Reduce Memory Footprint

Independent of chunking, memory usage per chunk (or per full read) can be reduced by:

```python
df = pd.read_csv(
    "large_file.csv",
    usecols=["id", "amount", "category"],
    dtype={"id": "int32", "amount": "float32", "category": "category"}
)
```

- `usecols` avoids loading columns that won't be used at all.
- Narrower numeric dtypes (`int32`/`float32` instead of default `int64`/`float64`) reduce per-value memory when the value range allows it.
- `category` dtype reduces memory for columns with many repeated string values, since it stores each unique value once alongside integer codes.

[Inference] Combining `usecols`, narrower dtypes, and `category` conversion is commonly presented as a memory-reduction strategy in Pandas documentation and community material, but the actual memory savings for any specific dataset depend on cardinality, value ranges, and column count — I have not benchmarked this for a specific file here.

### Alternative: `low_memory` Parameter

```python
df = pd.read_csv("large_file.csv", low_memory=False)
```

`low_memory` (default `True`) controls whether `read_csv()` processes the file in internal chunks for type inference purposes, independent of the user-facing `chunksize` argument. Setting it to `False` forces the entire file to be read before determining dtypes, which can avoid mixed-type warnings caused by per-internal-chunk inference, at the cost of higher peak memory during the read.

[Unverified] The precise internal chunking mechanism `low_memory` controls, and its exact interaction with the user-facing `chunksize` parameter, is implementation detail I cannot fully verify without inspecting Pandas' internal source for the specific version in use.

### When Chunking Alone Isn't Enough

For datasets that remain too large even with chunked processing — or workflows requiring random access, joins across the full dataset, or repeated queries — chunked `read_csv()` is often not the most practical tool. Common alternatives include:

- Converting to Parquet for columnar, partition-aware access
- Using Dask or Polars, which build chunked/lazy processing into their core execution model rather than requiring manual chunk loops
- Loading data into a database and querying with SQL, letting the database engine handle memory management

[Speculation] Whether any specific one of these alternatives is preferable for a given workload depends on factors like query patterns, team familiarity, and infrastructure — I don't have enough context about a specific use case to recommend one over another here.

### Common Pitfalls

| Pitfall | Cause |
|---|---|
| Inconsistent dtypes across chunks | Per-chunk type inference without explicit `dtype` |
| `MemoryError` despite chunking | Accumulating full-size results in a growing list without bounding total size |
| Slow performance despite chunking | Very small `chunksize` causing high per-chunk overhead relative to data processed |
| Lost data at chunk boundaries during row-dependent logic | Operations requiring context across rows (e.g., rolling windows) computed independently per chunk without carrying state between them |

### Diagram: Chunked Reading Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 260">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Chunked Reading Memory Flow (svg_diagram)</text>

  <rect x="20" y="60" width="150" height="150" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="95" y="45" text-anchor="middle" font-size="12" fill="#333">Large file on disk</text>
  <text x="95" y="100" text-anchor="middle" font-size="10" fill="#333">10,000,000 rows</text>
  <text x="95" y="120" text-anchor="middle" font-size="10" fill="#333">(not fully loaded)</text>

  <line x1="170" y1="135" x2="230" y2="135" stroke="#333" stroke-width="2" marker-end="url(#arrow4)" />

  <rect x="240" y="60" width="140" height="50" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="310" y="90" text-anchor="middle" font-size="11" fill="#222">Chunk 1 (100k)</text>

  <rect x="240" y="120" width="140" height="50" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="310" y="150" text-anchor="middle" font-size="11" fill="#222">Chunk 2 (100k)</text>

  <text x="310" y="200" text-anchor="middle" font-size="10" fill="#555">...only one chunk</text>
  <text x="310" y="215" text-anchor="middle" font-size="10" fill="#555">held in memory at a time</text>

  <line x1="380" y1="135" x2="440" y2="135" stroke="#333" stroke-width="2" marker-end="url(#arrow4)" />

  <rect x="450" y="100" width="150" height="70" rx="6" fill="#e5f5e0" stroke="#4a9159" />
  <text x="525" y="130" text-anchor="middle" font-size="11" fill="#222">Aggregated</text>
  <text x="525" y="148" text-anchor="middle" font-size="11" fill="#222">result</text>

  <line x1="600" y1="135" x2="660" y2="135" stroke="#333" stroke-width="2" marker-end="url(#arrow4)" />

  <rect x="670" y="105" width="80" height="60" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="710" y="140" text-anchor="middle" font-size="11" fill="#222">Output</text>

  </svg>

### Related Topics

- Using Dask DataFrames for out-of-core parallel processing
- Polars as a chunking-free alternative for large tabular data
- Converting large CSVs to Parquet for repeated downstream access
- Memory profiling techniques for Pandas workflows (`memory_usage()`, `df.info(memory_usage="deep")`)
- Streaming aggregation patterns for online/incremental statistics
- Rolling and windowed computations across chunk boundaries