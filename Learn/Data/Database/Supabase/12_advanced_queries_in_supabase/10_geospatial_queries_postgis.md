## Geospatial Queries (PostGIS)


PostGIS extends PostgreSQL with geospatial capabilities for storing and querying geographic data.

### Setup

```sql
-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add geometry column
ALTER TABLE locations 
ADD COLUMN geom geometry(Point, 4326);

-- Create spatial index
CREATE INDEX idx_locations_geom ON locations USING GIST (geom);
```

### Storing Geographic Data

```javascript
// Insert location
const { data, error } = await supabase
  .rpc('insert_location', {
    name: 'Coffee Shop',
    latitude: 40.7128,
    longitude: -74.0060
  })
```

```sql
CREATE OR REPLACE FUNCTION insert_location(
  name text,
  latitude double precision,
  longitude double precision
)
RETURNS bigint AS $$
DECLARE
  new_id bigint;
BEGIN
  INSERT INTO locations (name, geom)
  VALUES (name, ST_SetSRID(ST_MakePoint(longitude, latitude), 4326))
  RETURNING id INTO new_id;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;
```

### Distance Queries

```sql
CREATE OR REPLACE FUNCTION find_nearby_locations(
  lat double precision,
  lon double precision,
  radius_meters double precision
)
RETURNS TABLE (
  id bigint,
  name text,
  distance_meters double precision
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.name,
    ST_Distance(
      l.geom::geography,
      ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography
    ) as distance_meters
  FROM locations l
  WHERE ST_DWithin(
    l.geom::geography,
    ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography,
    radius_meters
  )
  ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;
```

```javascript
const { data, error } = await supabase
  .rpc('find_nearby_locations', {
    lat: 40.7128,
    lon: -74.0060,
    radius_meters: 5000
  })
```

### Spatial Relationships

```sql
-- Point in polygon
SELECT * FROM locations
WHERE ST_Within(
  geom,
  ST_GeomFromText('POLYGON((...))', 4326)
);

-- Intersects
SELECT * FROM zones z1, zones z2
WHERE ST_Intersects(z1.geom, z2.geom);

-- Contains
SELECT * FROM regions
WHERE ST_Contains(
  geom,
  ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326)
);

-- Nearest neighbor
SELECT name, ST_Distance(geom, ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326)) as dist
FROM locations
ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326)
LIMIT 5;
```

### Working with Polygons

```sql
-- Create polygon
INSERT INTO zones (name, geom)
VALUES (
  'Downtown',
  ST_GeomFromText('POLYGON((
    -74.0060 40.7128,
    -74.0050 40.7128,
    -74.0050 40.7138,
    -74.0060 40.7138,
    -74.0060 40.7128
  ))', 4326)
);

-- Calculate area (in square meters)
SELECT name, ST_Area(geom::geography) as area_sqm
FROM zones;

-- Buffer (create area around point)
SELECT ST_Buffer(geom::geography, 1000)::geometry as buffered_geom
FROM locations;
```

### GeoJSON Export

```sql
SELECT 
  name,
  ST_AsGeoJSON(geom)::json as geojson
FROM locations;
```

### Advanced Spatial Operations

```sql
-- Centroid
SELECT ST_Centroid(geom) FROM zones;

-- Convex hull
SELECT ST_ConvexHull(ST_Collect(geom)) FROM locations;

-- Union of geometries
SELECT ST_Union(geom) FROM zones WHERE category = 'residential';

-- Intersection
SELECT ST_Intersection(z1.geom, z2.geom)
FROM zones z1, zones z2
WHERE z1.id != z2.id;

-- Line of sight
SELECT ST_MakeLine(
  (SELECT geom FROM locations WHERE id = 1),
  (SELECT geom FROM locations WHERE id = 2)
);
```

**Key Points:**

- Complex joins enable data combination from multiple tables using Supabase's nested select syntax or PostgreSQL functions
- Subqueries provide filtering and calculations within larger queries, supporting scalar and correlated patterns
- CTEs improve query readability and enable recursive operations for hierarchical data
- Window functions calculate across row sets without collapsing results, useful for rankings and running calculations
- Recursive queries traverse hierarchical structures like organization charts, category trees, and graphs
- JSONB operations allow flexible schema design with efficient indexing and querying of JSON data
- Array operations enable multi-value storage with containment, overlap, and aggregation capabilities
- Full-text search with tsvector provides ranked search results with stemming, phrase matching, and highlighting
- Fuzzy matching using pg_trgm enables typo-tolerant searches with similarity scoring
- PostGIS extends PostgreSQL with comprehensive geospatial capabilities for location-based queries

**Important subtopics to explore:**

- Query performance optimization (EXPLAIN, indexes, query planning)
- Database functions and stored procedures (PL/pgSQL, security definers)
- Materialized views for complex query caching
- Database triggers for automated data workflows
- Real-time subscriptions with PostgreSQL's LISTEN/NOTIFY
- Row Level Security (RLS) integration with advanced queries

---

