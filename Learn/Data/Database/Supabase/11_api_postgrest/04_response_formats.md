## Response Formats


PostgREST returns JSON by default with configurable representations.

**Standard JSON response:**

```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-01-15T10:30:00Z"
  }
]
```

**Response headers:**

- `Content-Type: application/json` - response format
- `Content-Range: 0-9/100` - pagination info (start-end/total)
- `Content-Profile: public` - database schema used
- `Preference-Applied: return=representation` - confirms preference handling

**Single object return:** Add `Accept: application/vnd.pgrst.object+json` header to return a single object instead of array. [Inference: This throws an error if query returns zero or multiple rows, based on PostgREST's typical behavior]

**CSV format:** Set `Accept: text/csv` header to receive comma-separated values.

**Response preferences:** Set `Prefer` header to control response behavior:

- `return=representation` - return the modified data
- `return=minimal` - return only status code (faster)
- `return=headers-only` - return only headers
- `resolution=merge-duplicates` - handle upsert conflicts
- `resolution=ignore-duplicates` - skip duplicate inserts
- `count=exact` - include exact total count (slower)
- `count=planned` - use query planner estimate (faster)
- `count=estimated` - use statistics estimate

