## Query DSL – Sorting by Geo Distance

### Overview

Elasticsearch supports sorting documents by their geographic distance from a reference point using the `_geo_distance` sort type. Documents are ranked by how far their stored geo coordinates are from a specified origin point, in ascending or descending order.

This is used in location-aware applications: finding the nearest store, sorting events by proximity, ranking delivery options by distance, and similar use cases.

---

### Prerequisites

#### Field mapping

The sort field must be mapped as `geo_point`:

```json
PUT /locations
{
  "mappings": {
    "properties": {
      "coordinates": {
        "type": "geo_point"
      }
    }
  }
}
```

`geo_point` fields store latitude and longitude pairs and support distance computation, bounding box filtering, and geo aggregations.

---

### Basic Syntax

```json
GET /locations/_search
{
  "sort": [
    {
      "_geo_distance": {
        "coordinates": {
          "lat": 14.5995,
          "lon": 120.9842
        },
        "order": "asc",
        "unit": "km",
        "distance_type": "arc"
      }
    }
  ],
  "query": {
    "match_all": {}
  }
}
```

Documents are sorted by distance from the point `{ lat: 14.5995, lon: 120.9842 }`, nearest first.

---

### Reference Point Formats

The origin point can be specified in multiple formats.

#### Object with `lat` and `lon`

```json
"coordinates": {
  "lat": 14.5995,
  "lon": 120.9842
}
```

#### GeoJSON (longitude first)

```json
"coordinates": [120.9842, 14.5995]
```

**Key point:** GeoJSON uses `[longitude, latitude]` order — the reverse of the object format. This is a common source of error.

#### Well-Known Text (WKT)

```json
"coordinates": "POINT (120.9842 14.5995)"
```

WKT also uses longitude-first ordering.

#### Geohash string

```json
"coordinates": "wdw1hzp"
```

Geohashes are base-32 encoded strings representing a bounding box. Longer strings represent smaller, more precise areas.

---

### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `order` | string | `asc` | Sort direction: `asc` (nearest first) or `desc` (farthest first) |
| `unit` | string | `m` | Distance unit for the returned sort value |
| `distance_type` | string | `arc` | Algorithm used to compute distance |
| `mode` | string | `min` | How to handle multi-value geo fields |
| `nested` | object | — | Required when the geo field is inside a `nested` object |
| `ignore_unmapped` | boolean | `false` | If `true`, ignores documents where the field is not mapped instead of raising an error |

---

### Distance Units

The `unit` parameter controls the unit of the distance value returned in the `sort` array of each hit. It does not affect ranking — only the reported value.

| Unit | Value |
|---|---|
| `m` | Meters |
| `km` | Kilometers |
| `mi` | Miles |
| `yd` | Yards |
| `ft` | Feet |
| `in` | Inches |
| `cm` | Centimeters |
| `mm` | Millimeters |
| `NM` or `nmi` | Nautical miles |

---

### Distance Algorithms

Controlled by `distance_type`:

| Value | Description | Trade-off |
|---|---|---|
| `arc` | Haversine formula; accounts for Earth's curvature | More accurate; slightly higher computation cost |
| `plane` | Flat-earth (Euclidean) approximation | Faster; less accurate over large distances or near poles |

[Inference] `arc` is appropriate for most use cases. `plane` may be acceptable for very short distances (sub-kilometer) where curvature error is negligible, but its accuracy degrades with distance and at high latitudes. Behavior and error magnitude may vary.

---

### Sort Value in Response

The distance value used for sorting is returned in the `sort` array of each hit, expressed in the specified `unit`:

```json
"hits": [
  {
    "_id": "7",
    "_score": null,
    "_source": { ... },
    "sort": [2.347]
  }
]
```

This means the document's `coordinates` field is approximately 2.347 km from the reference point.

---

### Multi-Value Geo Fields

A document may have multiple geo coordinates stored in a single `geo_point` field (as an array). The `mode` parameter determines which distance is used for sorting:

| Mode | Description |
|---|---|
| `min` | Use the shortest distance among all stored points (default) |
| `max` | Use the longest distance |
| `avg` | Use the average distance across all points |
| `sum` | [Inference] Sum of distances; semantically unusual for geo use cases |

```json
{
  "sort": [
    {
      "_geo_distance": {
        "coordinates": { "lat": 14.5995, "lon": 120.9842 },
        "order": "asc",
        "unit": "km",
        "mode": "min"
      }
    }
  ]
}
```

**Key point:** `min` mode with `asc` order returns documents sorted by their closest point to the reference — the most intuitive behavior for nearest-location queries.

---

### Combining with a Query

Geo distance sort is independent of the query clause. Any query can be paired with it:

```json
{
  "sort": [
    {
      "_geo_distance": {
        "coordinates": { "lat": 14.5995, "lon": 120.9842 },
        "order": "asc",
        "unit": "km"
      }
    }
  ],
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "restaurant" } },
        { "term": { "open_now": true } }
      ]
    }
  }
}
```

The query restricts which documents are returned; the geo distance sort orders them by proximity.

---

### Filtering by Distance vs Sorting by Distance

These are distinct operations:

| Operation | Mechanism | Effect |
|---|---|---|
| **Filter by distance** | `geo_distance` query in filter context | Excludes documents outside a radius |
| **Sort by distance** | `_geo_distance` sort | Orders all matched documents by proximity |

They are commonly combined — filter to a radius first, then sort within it:

```json
{
  "sort": [
    {
      "_geo_distance": {
        "coordinates": { "lat": 14.5995, "lon": 120.9842 },
        "order": "asc",
        "unit": "km"
      }
    }
  ],
  "query": {
    "bool": {
      "filter": {
        "geo_distance": {
          "distance": "10km",
          "coordinates": { "lat": 14.5995, "lon": 120.9842 }
        }
      }
    }
  }
}
```

This returns only documents within 10 km, sorted nearest first.

---

### Multi-Field Sort with Geo Distance

Geo distance sort participates in multi-field sort chains:

```json
{
  "sort": [
    {
      "_geo_distance": {
        "coordinates": { "lat": 14.5995, "lon": 120.9842 },
        "order": "asc",
        "unit": "km"
      }
    },
    { "rating": { "order": "desc" } },
    { "_score": { "order": "desc" } }
  ]
}
```

Primary sort: proximity. Tie-break: rating descending. Final tie-break: relevance score.

---

### Nested Geo Fields

When the `geo_point` field is inside a `nested` mapping, the `nested` parameter is required:

```json
{
  "sort": [
    {
      "_geo_distance": {
        "branches.coordinates": { "lat": 14.5995, "lon": 120.9842 },
        "order": "asc",
        "unit": "km",
        "mode": "min",
        "nested": {
          "path": "branches",
          "filter": {
            "term": { "branches.active": true }
          }
        }
      }
    }
  ]
}
```

- `nested.path` — the nested object path containing the geo field.
- `nested.filter` — restricts which nested objects contribute to the distance calculation. Only active branches are considered in this example.

---

### `ignore_unmapped`

When querying across multiple indices where the geo field may not be mapped in all of them, `ignore_unmapped: true` prevents an error:

```json
{
  "sort": [
    {
      "_geo_distance": {
        "coordinates": { "lat": 14.5995, "lon": 120.9842 },
        "order": "asc",
        "unit": "km",
        "ignore_unmapped": true
      }
    }
  ]
}
```

Documents from indices where the field is unmapped are treated as having no value and are placed according to the effective `missing` behavior.

[Inference] The placement of unmapped documents (first or last) when `ignore_unmapped` is `true` may depend on `order` and internal defaults. Verify behavior against your Elasticsearch version if precise placement of unmapped documents matters.

---

### Missing Values

Documents without a value in the sort geo field are placed at the end by default when sorting `asc`, and at the beginning when sorting `desc`.

[Inference] Unlike field value sorts, `_geo_distance` sort does not expose a direct `missing` parameter equivalent to field sort's `_first` / `_last` options. Placement of documents with missing geo fields follows internal defaults. Behavior may vary by version.

---

### Multiple Reference Points

`_geo_distance` sort accepts an array of reference points. The distance used for sorting is the minimum distance from the document's field to any of the provided points:

```json
{
  "sort": [
    {
      "_geo_distance": {
        "coordinates": [
          { "lat": 14.5995, "lon": 120.9842 },
          { "lat": 10.3157, "lon": 123.8854 }
        ],
        "order": "asc",
        "unit": "km"
      }
    }
  ]
}
```

[Inference] Each document is ranked by its closest distance to any of the reference points. This can be useful for multi-origin proximity queries (e.g., nearest to any of several depots). Behavior may vary.

---

### Performance Considerations

- Geo distance sort requires computing distances for all matched documents. On large result sets this adds per-document computation cost.
- `arc` distance type is more accurate but marginally slower than `plane`. For most production workloads at city-scale distances, the difference is [Inference] unlikely to be significant.
- Combining a `geo_distance` filter with a geo distance sort reduces the document set before sorting, improving overall performance.
- [Inference] Geo distance sort does not benefit from the filter cache since it produces a continuous distance value per document rather than a binary match result. Behavior may vary.

---

### Coordinate Ordering Pitfalls

A frequent source of incorrect results is coordinate order confusion:

| Format | Order |
|---|---|
| Object (`lat`/`lon` keys) | Latitude first, longitude second |
| Array | Longitude first, latitude second (GeoJSON convention) |
| WKT | Longitude first, latitude second |
| Geohash | Encodes both; no ordering issue |

Swapping latitude and longitude produces distances computed from a reflected point, resulting in silently wrong sort order with no error.

---

### Summary

| Aspect | Detail |
|---|---|
| Sort type | `_geo_distance` |
| Required field mapping | `geo_point` |
| Reference point formats | Object, GeoJSON array, WKT, geohash |
| Distance algorithms | `arc` (Haversine, default), `plane` (Euclidean) |
| Distance unit | `m`, `km`, `mi`, `ft`, and others; affects reported value only |
| Multi-value mode | `min` (default), `max`, `avg` |
| Nested geo fields | Requires `nested.path`; optionally `nested.filter` |
| Multi-index safety | `ignore_unmapped: true` |
| Multiple origins | Array of points; minimum distance used |
| Common pitfall | Coordinate order varies by format; array format is longitude-first |
| Filter vs sort | `geo_distance` query filters by radius; `_geo_distance` sort orders by distance |