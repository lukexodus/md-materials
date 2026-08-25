## Geo Bounding Box Query

### Overview

The `geo_bounding_box` query filters documents whose `geo_point` field falls within a rectangular area defined by two corner coordinates: a top-left (upper-left) point and a bottom-right (lower-right) point. It is computationally cheaper than `geo_distance` because it only requires comparing latitude and longitude ranges rather than calculating actual distances, making it a common choice for map-viewport-based searches ("show me everything visible on this map").

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
    "geo_bounding_box": {
      "location": {
        "top_left": {
          "lat": 40.8,
          "lon": -74.1
        },
        "bottom_right": {
          "lat": 40.7,
          "lon": -73.9
        }
      }
    }
  }
}
```

This returns documents whose `location` falls inside the rectangle bounded by the specified corners.

### Corner Naming Conventions

Elasticsearch accepts multiple aliases for the corner parameters, which can be used interchangeably:

- `top_left` / `bottom_right`
- `topLeft` / `bottomRight`
- `top_right` / `bottom_left`
- `topRight` / `bottomLeft`

```json
GET /places/_search
{
  "query": {
    "geo_bounding_box": {
      "location": {
        "top_right": {
          "lat": 40.8,
          "lon": -73.9
        },
        "bottom_left": {
          "lat": 40.7,
          "lon": -74.1
        }
      }
    }
  }
}
```

Some naming schemes also support `top`, `left`, `bottom`, `right` as four separate scalar values instead of nested points:

```json
GET /places/_search
{
  "query": {
    "geo_bounding_box": {
      "location": {
        "top": 40.8,
        "left": -74.1,
        "bottom": 40.7,
        "right": -73.9
      }
    }
  }
}
```

### Accepted Point Formats

Corners can be expressed in the same formats supported by `geo_distance`:

**Object format**

```json
"top_left": { "lat": 40.8, "lon": -74.1 }
```

**String "lat,lon" format**

```json
"top_left": "40.8,-74.1"
```

**Geohash format**

```json
"top_left": "dr5rs"
```

**Array format `[lon, lat]`**

```json
"top_left": [-74.1, 40.8]
```

As with `geo_distance`, mixing up array order (`[lon, lat]`) with object/string order (`lat, lon`) is a common source of errors.

### Handling the Antimeridian (Date Line)

If the bounding box crosses the 180°/-180° antimeridian (for example, spanning from the Pacific into eastern Russia), specify the longitude of `top_left` as greater than the longitude of `bottom_right`. Elasticsearch interprets this as a box that wraps around the date line rather than throwing an error.

```json
GET /places/_search
{
  "query": {
    "geo_bounding_box": {
      "location": {
        "top_left": {
          "lat": 40.0,
          "lon": 170.0
        },
        "bottom_right": {
          "lat": 30.0,
          "lon": -170.0
        }
      }
    }
  }
}
```

### The `validation_method` Parameter

Controls how invalid coordinate values (latitude outside ±90, longitude outside ±180) are treated:

- `STRICT` (default) — throws an exception on invalid coordinates.
- `IGNORE_MALFORMED` — accepts invalid coordinates without validation.
- `COERCE` — attempts to normalize out-of-range values into valid bounds.

```json
GET /places/_search
{
  "query": {
    "geo_bounding_box": {
      "validation_method": "COERCE",
      "location": {
        "top_left": { "lat": 40.8, "lon": -74.1 },
        "bottom_right": { "lat": 40.7, "lon": -73.9 }
      }
    }
  }
}
```

### The `type` Execution Parameter

`geo_bounding_box` supports a `type` parameter controlling the execution strategy:

- `memory` — checks coordinates directly against the box in memory.
- `indexed` — relies on indexed spatial structures to resolve the query.

```json
GET /places/_search
{
  "query": {
    "geo_bounding_box": {
      "type": "indexed",
      "location": {
        "top_left": { "lat": 40.8, "lon": -74.1 },
        "bottom_right": { "lat": 40.7, "lon": -73.9 }
      }
    }
  }
}
```

[Unverified — the availability and default value of the `type` parameter has varied across Elasticsearch versions, so its current default and effect should be confirmed against the documentation for the specific version in use.]

### Combining with Other Queries

Like `geo_distance`, `geo_bounding_box` is typically placed in a `filter` clause within a `bool` query, since it expresses a binary inclusion condition rather than contributing to relevance scoring.

```json
GET /places/_search
{
  "query": {
    "bool": {
      "must": {
        "match": { "name": "diner" }
      },
      "filter": {
        "geo_bounding_box": {
          "location": {
            "top_left": { "lat": 40.8, "lon": -74.1 },
            "bottom_right": { "lat": 40.7, "lon": -73.9 }
          }
        }
      }
    }
  }
}
```

### geo_bounding_box vs geo_distance

- `geo_bounding_box` defines a rectangular region; `geo_distance` defines a circular region around a point.
- `geo_bounding_box` is generally faster to evaluate since it only compares coordinate ranges, while `geo_distance` requires distance computation (`arc` or `plane`) per candidate.
- `geo_bounding_box` is a natural fit for map-viewport queries; `geo_distance` is a natural fit for radius-based "near me" queries.
- The two are often combined: a bounding box as a coarse pre-filter, followed by a distance filter for precise radius matching. [Inference — this is a common optimization pattern rather than a strict requirement, and its usefulness depends on data volume and query patterns.]

### Query Flow Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
  <text x="380" y="28" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">geo_bounding_box Query Flow (svg_diagram)</text>

  <rect x="30" y="60" width="210" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="135" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">top_left corner</text>
  <text x="135" y="103" font-size="12" text-anchor="middle" fill="#444">(lat, lon)</text>

  <rect x="270" y="60" width="210" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="375" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">bottom_right corner</text>
  <text x="375" y="103" font-size="12" text-anchor="middle" fill="#444">(lat, lon)</text>

  <rect x="520" y="60" width="210" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="625" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">validation_method</text>
  <text x="625" y="103" font-size="12" text-anchor="middle" fill="#444">STRICT / COERCE</text>

  <line x1="135" y1="120" x2="380" y2="170" stroke="#999" stroke-width="1.5" />
  <line x1="375" y1="120" x2="380" y2="170" stroke="#999" stroke-width="1.5" />
  <line x1="625" y1="120" x2="380" y2="170" stroke="#999" stroke-width="1.5" />

  <rect x="255" y="170" width="250" height="55" rx="8" fill="#fff3cd" stroke="#e0a800" stroke-width="1.5" />
  <text x="380" y="203" font-size="13" text-anchor="middle" fill="#1a1a1a">Coordinate Range Check</text>

  <line x1="380" y1="225" x2="380" y2="255" stroke="#999" stroke-width="1.5" />

  <rect x="255" y="255" width="250" height="55" rx="8" fill="#d4edda" stroke="#28a745" stroke-width="1.5" />
  <text x="380" y="288" font-size="13" text-anchor="middle" fill="#1a1a1a">Documents Inside Rectangle</text>
</svg>

### Performance Considerations

- Prefer `filter` context to allow caching, since bounding box results are typically reused across identical viewport queries (e.g., repeated map pans/zooms to similar areas).
- Bounding box checks are inherently cheaper than distance-based checks because they avoid trigonometric or planar distance calculations.
- Very large or very small boxes near the poles can behave counterintuitively because lines of longitude converge; results should be validated against expected behavior for high-latitude regions. [Inference — this follows from the geometry of latitude/longitude coordinate systems rather than being an Elasticsearch-specific quirk.]

### Common Pitfalls

- Swapping `top_left` and `bottom_right`, which can produce an empty or unexpected result set.
- Forgetting antimeridian handling when the box spans the 180°/-180° line, leading to an inverted or empty region.
- Mixing up `[lon, lat]` array order with `lat, lon` object/string order.
- Assuming the query returns proximity-ranked results — like `geo_distance`, `geo_bounding_box` does not affect `_score` by default.

### Related Topics

- `geo_distance` query
- `geo_polygon` and `geo_shape` queries
- `_geo_distance` sort for proximity ranking
- `geo_point` vs `geo_shape` field types
- Geohash grid and geotile grid aggregations
- Map-based UI patterns using viewport bounding boxes