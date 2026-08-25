## Reading and Writing JSON Files

### Overview

Pandas provides `read_json()` and `to_json()` for converting between JSON text and DataFrame objects. Unlike Excel, JSON parsing in Pandas is built in and does not require an external engine package, though the structure of the JSON (nested vs. flat, orientation) significantly affects how cleanly it maps to a DataFrame.

### Basic Reading

```python
import pandas as pd

df = pd.read_json("data.json")
```

This works directly when the JSON is a simple array of flat objects with consistent keys, e.g.:

```json
[
  {"name": "Alice", "age": 30},
  {"name": "Bob", "age": 25}
]
```

### The `orient` Parameter

JSON has no single canonical tabular layout, so Pandas supports several `orient` values describing how the JSON structure maps to rows/columns:

| `orient` value | JSON shape |
|---|---|
| `"records"` | list of `{column -> value}` dicts, one per row |
| `"columns"` (default for dict-of-dicts) | `{column -> {index -> value}}` |
| `"index"` | `{index -> {column -> value}}` |
| `"split"` | `{"index": [...], "columns": [...], "data": [...]}` |
| `"values"` | just the raw nested value array, no labels |
| `"table"` | JSON Table Schema format (includes dtype/schema metadata) |

```python
df = pd.read_json("data.json", orient="records")
```

**Key Points**
- If `orient` is not specified, `read_json()` attempts to infer the layout, but [Inference] explicit `orient` is more reliable for production code than relying on inference, particularly for less common shapes like `"split"` or `"table"` — I cannot verify the exact inference heuristics used internally without checking source code or documentation directly, so I will not describe them further.
- Mismatched `orient` between writing and reading is a common source of malformed DataFrames.

### Writing to JSON

```python
df.to_json("output.json", orient="records", indent=2)
```

**Key Points**
- `orient="records"` is commonly used for output meant to be consumed by web APIs or JavaScript, since it produces a straightforward array-of-objects structure.
- `indent` controls pretty-printing; omitting it produces a single-line compact JSON string.
- `date_format` and `date_unit` parameters control how datetime columns are serialized (ISO 8601 strings vs. epoch timestamps).

```python
df.to_json("output.json", orient="records", date_format="iso", date_unit="s")
```

### Handling Nested JSON

Deeply nested JSON (objects containing lists of objects, or objects within objects) does not flatten automatically with `read_json()` alone. `pd.json_normalize()` is the tool typically used for this:

```python
import json

with open("nested.json") as f:
    raw = json.load(f)

df = pd.json_normalize(raw, sep="_")
```

Given:

```json
[
  {"id": 1, "user": {"name": "Alice", "location": {"city": "Manila"}}}
]
```

`json_normalize` with `sep="_"` produces flat columns like `user_name` and `user_location_city`.

For arrays nested under a key, `record_path` and `meta` control how the nested array is expanded into rows while pulling in outer fields as repeated columns:

```python
df = pd.json_normalize(
    raw,
    record_path="orders",
    meta=["customer_id", "customer_name"]
)
```

[Inference] `json_normalize` is generally the recommended approach for semi-structured nested JSON rather than manual recursive flattening, based on it being the documented purpose of the function, but I cannot verify this is optimal for every nesting pattern without testing specific cases.

### Reading JSON Lines Format (NDJSON)

JSON Lines (one JSON object per line, not wrapped in an array) requires the `lines=True` argument:

```python
df = pd.read_json("data.jsonl", lines=True)
```

Writing in this format uses the same flag:

```python
df.to_json("output.jsonl", orient="records", lines=True)
```

[Unverified] Whether `lines=True` is compatible with every `orient` value is not something I can confirm here; `orient="records"` is the combination most commonly documented alongside `lines=True`.

### Handling Missing and Irregular Data

JSON does not have a native concept matching Pandas' `NaN`. Missing keys across records commonly translate to `NaN` after `read_json()`/`json_normalize()`, and `NaN` values on write are serialized as JSON `null` by default.

```python
df.to_json("output.json", orient="records", default_handler=str)
```

`default_handler` provides a fallback serialization function for objects `to_json()` does not know how to encode natively (e.g., custom Python objects, some NumPy scalar types in edge cases).

### Data Type Considerations

JSON's type system is narrower than Pandas'/NumPy's — it distinguishes only strings, numbers, booleans, null, objects, and arrays. This means:

- Integer vs. float distinctions can be lost or altered on round-trip in some cases. [Unverified] The exact conditions under which this occurs depend on the Pandas version and data content, and I do not have a verified, complete list of edge cases.
- Datetime objects have no native JSON type and are always serialized as either strings or numeric timestamps, controlled by `date_format`.
- Very large integers (beyond IEEE 754 double precision, roughly $2^{53}$) may lose precision when represented as JSON numbers, since JSON numbers are conventionally interpreted as doubles by many parsers.

### Common Errors and Causes

| Error | Likely cause |
|---|---|
| `ValueError: Expected object or value` | File is empty, malformed, or `lines=True` needed but not set |
| `ValueError: Trailing data` | File is JSON Lines format but `lines=True` was omitted |
| Nested dicts appearing as single object-column values | `json_normalize` not used; plain `read_json()` does not recursively flatten |
| Unexpected `NaN` in output where a key was simply absent | Inconsistent keys across JSON records |

### Performance Considerations

[Inference] JSON parsing is generally slower than binary columnar formats like Parquet for large datasets, since JSON is text-based and requires full parsing of nested structure rather than direct binary decoding — this is a reasoned inference based on general format characteristics, not a benchmarked claim I can cite here.

### Diagram: JSON-to-DataFrame Structural Mapping

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 280">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">JSON Structure to DataFrame Mapping (svg_diagram)</text>

  <rect x="30" y="60" width="300" height="180" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="180" y="82" text-anchor="middle" font-size="13" font-weight="bold" fill="#222">Nested JSON</text>
  <text x="45" y="105" font-size="11" fill="#333">[</text>
  <text x="55" y="122" font-size="11" fill="#333">{"id": 1,</text>
  <text x="65" y="139" font-size="11" fill="#333">"user": {</text>
  <text x="75" y="156" font-size="11" fill="#333">"name": "Alice",</text>
  <text x="75" y="173" font-size="11" fill="#333">"loc": {"city":"Manila"}</text>
  <text x="65" y="190" font-size="11" fill="#333">}}</text>
  <text x="45" y="207" font-size="11" fill="#333">]</text>

  <line x1="330" y1="150" x2="420" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrow2)" />
  <text x="375" y="140" text-anchor="middle" font-size="10" fill="#555">json_normalize()</text>

  <rect x="430" y="60" width="300" height="180" rx="6" fill="#e5f5e0" stroke="#4a9159" />
  <text x="580" y="82" text-anchor="middle" font-size="13" font-weight="bold" fill="#222">Flat DataFrame</text>

  <line x1="440" y1="100" x2="720" y2="100" stroke="#999" stroke-width="1" />
  <text x="455" y="97" font-size="10" fill="#222">id</text>
  <text x="500" y="97" font-size="10" fill="#222">user_name</text>
  <text x="600" y="97" font-size="10" fill="#222">user_loc_city</text>

  <line x1="440" y1="125" x2="720" y2="125" stroke="#ddd" stroke-width="1" />
  <text x="455" y="120" font-size="10" fill="#333">1</text>
  <text x="500" y="120" font-size="10" fill="#333">Alice</text>
  <text x="600" y="120" font-size="10" fill="#333">Manila</text>

  </svg>

### Related Topics

- `pd.json_normalize()` deep dive: `record_prefix`, `errors="ignore"`, multi-level nesting
- Reading and writing Parquet files
- Converting between JSON, CSV, and Excel formats in a single pipeline
- Handling schema drift across JSON records from APIs
- Working with `orient="table"` and JSON Table Schema for type-preserving round-trips
- Streaming large JSON files with chunked reading approaches