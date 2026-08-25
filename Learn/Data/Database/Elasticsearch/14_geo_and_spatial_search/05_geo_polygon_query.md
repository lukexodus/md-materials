## Geo Polygon Query

### Overview

The `geo_polygon` query filters documents whose `geo_point` field falls within an arbitrary polygon defined by a list of vertex coordinates. Unlike `geo_bounding_box` (rectangular) or `geo_distance` (circular), `geo_polygon` allows matching against irregular shapes such as administrative boundaries, custom-drawn regions, or delivery zones.

**Note on deprecation status:** [Unverified — the `geo_polygon` query has been deprecated in some versions of Elasticsearch in favor of `geo_shape` queries with a polygon geometry, and may be removed in future major versions. Confirm current status against the documentation for the specific Elasticsearch version in use before adopting it in new applications.]

### Prerequisites

The target field must be mapped as `geo_point`.

```json
PUT /places
{
  "mappings": {
    "properties": {
      "name": { "type": "text" },
      "location": { "type": "geo_point" }
    }
  }
}
```

Sample documents:

```json
POST /places/_bulk
{ "index": { "_id": "1" } }
{ "name": "Cafe Aurora", "location": { "lat": 40.7128, "lon": -74.0060 } }
{ "index": { "_id": "2" } }
{ "name": "Riverside Diner", "location": { "lat": 40.7306, "lon": -73.9352 } }
{ "index": { "_id": "3" } }
{ "name": "Mountain Lodge", "location": { "lat": 39.7392, "lon": -104.9903 } }
```

### Basic Syntax

```json
GET /places/_search
{
  "query": {
    "geo_polygon": {
      "location": {
        "points": [
          { "lat": 40.8, "lon": -74.2 },
          { "lat": 40.8, "lon": -73.8 },
          { "lat": 40.6, "lon": -73.8 },
          { "lat": 40.6, "lon": -74.2 }
        ]
      }
    }
  }
}
```

This returns documents whose `location` falls within the polygon defined by the four listed vertices, connected in order.

### Accepted Point Formats

Each vertex in the `points` array can be expressed in the same formats accepted by `geo_distance` and `geo_bounding_box`:

**Object format**

```json
{ "lat": 40.8, "lon": -74.2 }
```

**String "lat,lon" format**

```json
"40.8,-74.2"
```

**Geohash format**

```json
"dr5rs"
```

**Array format `[lon, lat]`**

```json
[-74.2, 40.8]
```

A polygon definition can mix formats across different points in the same array, though maintaining a single consistent format is recommended for readability and to reduce the chance of coordinate-order mistakes.

```json
GET /places/_search
{
  "query": {
    "geo_polygon": {
      "location": {
        "points": [
          "40.8,-74.2",
          "40.8,-73.8",
          "40.6,-73.8",
          "40.6,-74.2"
        ]
      }
    }
  }
}
```

### Polygon Closure

The polygon does not need to explicitly repeat the first point at the end of the list to close the shape — Elasticsearch automatically connects the last point back to the first. [Inference — this closure behavior follows standard polygon-handling conventions used across geospatial libraries and is consistent with documented Elasticsearch behavior, though explicitly verifying against the current version's documentation is advisable for edge cases.]

### The `validation_method` Parameter

Controls how invalid coordinate values are handled:

- `STRICT` (default) — throws an exception for latitude/longitude values outside valid ranges.
- `IGNORE_MALFORMED` — accepts invalid coordinates without validation.
- `COERCE` — normalizes out-of-range coordinates into valid bounds.

```json
GET /places/_search
{
  "query": {
    "geo_polygon": {
      "validation_method": "COERCE",
      "location": {
        "points": [
          { "lat": 40.8, "lon": -74.2 },
          { "lat": 40.8, "lon": -73.8 },
          { "lat": 40.6, "lon": -73.8 },
          { "lat": 40.6, "lon": -74.2 }
        ]
      }
    }
  }
}
```

### Combining with Other Queries

As with other geo filters, `geo_polygon` is typically placed inside a `filter` clause of a `bool` query since it expresses a binary containment condition rather than a relevance signal.

```json
GET /places/_search
{
  "query": {
    "bool": {
      "must": {
        "match": { "name": "cafe" }
      },
      "filter": {
        "geo_polygon": {
          "location": {
            "points": [
              { "lat": 40.8, "lon": -74.2 },
              { "lat": 40.8, "lon": -73.8 },
              { "lat": 40.6, "lon": -73.8 },
              { "lat": 40.6, "lon": -74.2 }
            ]
          }
        }
      }
    }
  }
}
```

### geo_polygon vs geo_shape

- `geo_polygon` operates only against `geo_point` fields and only supports simple polygon containment checks.
- `geo_shape` operates against `geo_shape` fields (or `geo_point` in some relation modes) and supports far richer geometry types (polygons, multipolygons, lines, circles) and spatial relations (`intersects`, `within`, `contains`, `disjoint`).
- For new implementations requiring polygon-based filtering, `geo_shape` is generally the more future-proof and flexible choice. [Inference — this reflects the general direction of Elasticsearch's geo query capabilities toward `geo_shape`, but the right choice depends on specific version support and feature requirements.]

### Query Flow Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
  <text x="380" y="28" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">geo_polygon Query Flow (svg_diagram)</text>

  <rect x="60" y="60" width="260" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="190" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">points array</text>
  <text x="190" y="103" font-size="12" text-anchor="middle" fill="#444">ordered vertex list</text>

  <rect x="440" y="60" width="260" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="570" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">validation_method</text>
  <text x="570" y="103" font-size="12" text-anchor="middle" fill="#444">STRICT / COERCE</text>

  <line x1="190" y1="120" x2="380" y2="170" stroke="#999" stroke-width="1.5" />
  <line x1="570" y1="120" x2="380" y2="170" stroke="#999" stroke-width="1.5" />

  <rect x="255" y="170" width="250" height="55" rx="8" fill="#fff3cd" stroke="#e0a800" stroke-width="1.5" />
  <text x="380" y="203" font-size="13" text-anchor="middle" fill="#1a1a1a">Point-in-Polygon Check</text>

  <line x1="380" y1="225" x2="380" y2="255" stroke="#999" stroke-width="1.5" />

  <rect x="255" y="255" width="250" height="55" rx="8" fill="#d4edda" stroke="#28a745" stroke-width="1.5" />
  <text x="380" y="288" font-size="13" text-anchor="middle" fill="#1a1a1a">Documents Inside Polygon</text>
</svg>

### Performance Considerations

- Point-in-polygon evaluation is more computationally expensive than bounding box range checks, since it must resolve geometric containment rather than simple coordinate comparisons. [Inference — this follows from the general computational complexity of point-in-polygon algorithms relative to axis-aligned range checks; exact cost varies with implementation and vertex count.]
- Complex polygons with many vertices increase per-document evaluation cost; simplifying polygon geometry where high precision is not required can improve query speed. [Inference — this is a general geospatial optimization principle rather than an Elasticsearch-specific guarantee.]
- Using `filter` context allows caching, which is beneficial when the same polygon region is queried repeatedly (e.g., a fixed delivery zone).
- Pre-filtering with a `geo_bounding_box` around the polygon's extent before applying `geo_polygon` can reduce the candidate set. [Inference — this is a general query optimization pattern, and Elasticsearch's own query planner may already apply comparable internal optimizations, so manual pre-filtering benefit varies by version and dataset.]

### Common Pitfalls

- Providing too few points to form a valid polygon (fewer than three distinct vertices).
- Inconsistent coordinate order across points when mixing formats, leading to a malformed shape.
- Assuming self-intersecting polygons behave predictably — results for complex or self-crossing shapes may not match visual expectations. [Unverified — behavior for self-intersecting polygons is not consistently documented and should be tested against the specific version in use.]
- Relying on `geo_polygon` for new development despite its deprecated status in favor of `geo_shape`.
- Assuming the query contributes to relevance scoring — like other geo filters, it does not affect `_score` by default.

### Related Topics

- `geo_shape` query and spatial relations (`intersects`, `within`, `contains`, `disjoint`)
- `geo_distance` query
- `geo_bounding_box` query
- `geo_point` vs `geo_shape` field types
- Geohash grid and geotile grid aggregations
- Migrating deprecated geo queries to `geo_shape` equivalents