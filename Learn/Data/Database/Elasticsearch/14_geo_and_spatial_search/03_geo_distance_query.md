## Geo Distance Query

### Overview

The `geo_distance` query filters documents based on their distance from a specified geographic point. It returns documents whose `geo_point` field value falls within a given radius of an origin coordinate. This is commonly used for "find things near me" style search features, such as locating stores, restaurants, or points of interest within a certain range of a user's location.

### Prerequisites

The field being queried must be mapped as a `geo_point` type. Attempting to run a `geo_distance` query against a field mapped as `text`, `keyword`, or an unmapped field will fail.

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
    "geo_distance": {
      "distance": "10km",
      "location": {
        "lat": 40.7128,
        "lon": -74.0060
      }
    }
  }
}
```

This returns all documents where `location` is within 10 kilometers of the point `(40.7128, -74.0060)`.

### Distance Units

The `distance` parameter accepts a number followed by a unit. Supported units include:

- `mi` or `miles`
- `yd` or `yards`
- `ft` or `feet`
- `in` or `inch`
- `km` or `kilometers`
- `m` or `meters`
- `cm` or `centimeters`
- `mm` or `millimeters`
- `nmi` or `NM` (nautical miles)

Examples: `"5mi"`, `"2000m"`, `"3nmi"`. If no unit is specified, meters is the default. [Inference — defaulting to meters when a unit is omitted is documented Elasticsearch behavior, but always specify a unit explicitly to avoid ambiguity in production queries.]

### Accepted Point Formats

The origin point can be expressed in several formats:

**Object format**

```json
"location": {
  "lat": 40.7128,
  "lon": -74.0060
}
```

**String "lat,lon" format**

```json
"location": "40.7128,-74.0060"
```

**Geohash format**

```json
"location": "dr5regw3p"
```

**Array format `[lon, lat]`** — note the reversed order compared to the string and object formats, following GeoJSON convention:

```json
"location": [-74.0060, 40.7128]
```

Mixing up the array order (which is `[lon, lat]`) with the object/string order (`lat, lon`) is a frequent source of bugs.

### The `distance_type` Parameter

`distance_type` controls the algorithm used to compute distance:

- `arc` (default) — treats the Earth as a sphere and calculates the shortest path along its surface. More accurate over long distances.
- `plane` — treats the coordinates as points on a flat plane. Faster to compute, but less accurate, especially near the poles or over long distances.

```json
GET /places/_search
{
  "query": {
    "geo_distance": {
      "distance": "500km",
      "distance_type": "plane",
      "location": { "lat": 40.7128, "lon": -74.0060 }
    }
  }
}
```

[Inference — `plane` is intended for cases where query performance matters more than precision over large areas; the actual error margin depends on latitude and distance involved and isn't fixed.]

### The `validation_method` Parameter

Controls how out-of-range coordinates (latitude outside ±90, longitude outside ±180) are handled:

- `STRICT` (default) — throws an exception for invalid coordinates.
- `IGNORE_MALFORMED` — accepts invalid coordinates without validation.
- `COERCE` — attempts to normalize invalid coordinates into valid ranges.

```json
GET /places/_search
{
  "query": {
    "geo_distance": {
      "distance": "50km",
      "validation_method": "COERCE",
      "location": { "lat": 40.7128, "lon": -74.0060 }
    }
  }
}
```

### Combining with Other Queries

`geo_distance` is typically used inside a `bool` query alongside other filters, since it only expresses a radius constraint on its own.

```json
GET /places/_search
{
  "query": {
    "bool": {
      "must": {
        "match": { "name": "cafe" }
      },
      "filter": {
        "geo_distance": {
          "distance": "20km",
          "location": {
            "lat": 40.7128,
            "lon": -74.0060
          }
        }
      }
    }
  }
}
```

Placing `geo_distance` in the `filter` clause rather than `must` is standard practice, since distance filtering is a yes/no constraint that does not need to contribute to relevance scoring, and filter clauses are cacheable.

### Sorting by Distance

`geo_distance` restricts *which* documents are returned, but does not order results by proximity. To sort by actual distance from a point, use geo-distance sorting:

```json
GET /places/_search
{
  "query": {
    "geo_distance": {
      "distance": "50km",
      "location": { "lat": 40.7128, "lon": -74.0060 }
    }
  },
  "sort": [
    {
      "_geo_distance": {
        "location": { "lat": 40.7128, "lon": -74.0060 },
        "order": "asc",
        "unit": "km"
      }
    }
  ]
}
```

### How It Works Internally

`geo_point` fields are indexed using a structure derived from geohashing/quad-tree-like encoding internally, allowing spatial range checks to be resolved efficiently rather than computing exact distance for every document at query time. [Inference — the precise indexing structure has evolved across Elasticsearch versions (e.g. moves toward BKD-tree-based geo indexing), so exact internal mechanics may differ depending on the Elasticsearch version in use.] The distance calculation itself (`arc` vs `plane`) is applied to filter and refine candidates against the origin point.

### Query Flow Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 360">
  <text x="380" y="28" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">geo_distance Query Flow (svg_diagram)</text>

  <rect x="30" y="60" width="200" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="130" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Origin Point</text>
  <text x="130" y="103" font-size="12" text-anchor="middle" fill="#444">(lat, lon)</text>

  <rect x="280" y="60" width="200" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="380" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Distance + Unit</text>
  <text x="380" y="103" font-size="12" text-anchor="middle" fill="#444">e.g. 10km</text>

  <rect x="530" y="60" width="200" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="630" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">distance_type</text>
  <text x="630" y="103" font-size="12" text-anchor="middle" fill="#444">arc / plane</text>

  <line x1="130" y1="120" x2="380" y2="170" stroke="#999" stroke-width="1.5" />
  <line x1="380" y1="120" x2="380" y2="170" stroke="#999" stroke-width="1.5" />
  <line x1="630" y1="120" x2="380" y2="170" stroke="#999" stroke-width="1.5" />

  <rect x="255" y="170" width="250" height="55" rx="8" fill="#fff3cd" stroke="#e0a800" stroke-width="1.5" />
  <text x="380" y="203" font-size="13" text-anchor="middle" fill="#1a1a1a">Spatial Index Lookup (geo_point)</text>

  <line x1="380" y1="225" x2="380" y2="255" stroke="#999" stroke-width="1.5" />

  <rect x="255" y="255" width="250" height="55" rx="8" fill="#d4edda" stroke="#28a745" stroke-width="1.5" />
  <text x="380" y="288" font-size="13" text-anchor="middle" fill="#1a1a1a">Documents Within Radius</text>

  <line x1="380" y1="310" x2="380" y2="335" stroke="#999" stroke-width="1.5" />
  <polygon points="375,335 385,335 380,345" fill="#999" />
  <text x="380" y="358" font-size="12" text-anchor="middle" fill="#444">Optional: sort by _geo_distance</text>
</svg>

### Performance Considerations

- Use `geo_distance` inside a `filter` context when relevance scoring by distance is not needed, allowing Elasticsearch to cache the filter.
- Smaller radii generally reduce the candidate set and improve query speed. [Behavior may vary depending on data distribution, shard count, and cluster configuration.]
- For very large datasets with heavy geo filtering, consider combining `geo_distance` with a `geo_bounding_box` pre-filter, since bounding box calculations are computationally cheaper than precise distance calculations. [Inference — this is a common optimization pattern rather than a strictly documented requirement, and its benefit depends on query patterns.]

### Common Pitfalls

- Confusing the `[lon, lat]` array order with the `lat, lon` object/string order.
- Forgetting to map the field as `geo_point`, resulting in query errors.
- Omitting distance units, leading to unexpected default behavior.
- Using `geo_distance` for sorting purposes without adding an explicit `_geo_distance` sort clause.
- Assuming `geo_distance` alone provides ranking by proximity — it does not affect `_score` unless explicitly used in scoring context (e.g., via function score or distance feature queries).

### Related Topics

- `geo_bounding_box` query
- `geo_polygon` and `geo_shape` queries
- `_geo_distance` sort and distance-based ranking
- `geo_point` vs `geo_shape` field types
- Distance feature queries for scoring by proximity
- Geohash grid aggregations for spatial bucketing