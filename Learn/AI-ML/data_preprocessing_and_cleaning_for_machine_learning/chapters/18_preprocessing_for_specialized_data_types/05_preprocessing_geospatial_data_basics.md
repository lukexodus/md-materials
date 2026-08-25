## Preprocessing Geospatial Data Basics

### What Distinguishes Geospatial Data

Geospatial data associates observations with locations on the Earth's surface, which introduces two concerns not present in standard tabular data: coordinate reference systems (how a location on a curved surface is mapped to numeric coordinates) and spatial relationships (distance, adjacency, containment) that require geometry-aware computation rather than simple arithmetic on raw coordinate values.

**Key Points**
- Coordinate Reference Systems (CRS) define how latitude/longitude or projected coordinates map to actual locations; mismatched CRS between datasets is a common source of silent errors.
- Geometric operations (distance, area, intersection) generally require specialized libraries rather than direct arithmetic on coordinate columns.
- Documented, deterministic library behavior is described directly; claims about appropriate projection choice for a given task or region are context-dependent and labeled accordingly.

---

### Coordinate Reference Systems

A Coordinate Reference System (CRS) specifies how coordinates relate to actual positions on Earth. The most common geographic CRS, WGS84 (EPSG:4326), represents locations as latitude/longitude in degrees. Projected CRSs (such as UTM zones or state plane systems) instead represent locations in linear units (meters or feet) on a flat plane, which requires distorting the Earth's curved surface in some way.

```python
import geopandas as gpd

gdf = gpd.read_file("locations.geojson")
print(gdf.crs)  # inspect the current CRS
```

`gdf.crs` reports the CRS currently associated with a GeoDataFrame, which `geopandas` reads from the source file's metadata when available. This is documented `geopandas` behavior.

```python
gdf_projected = gdf.to_crs(epsg=32633)  # UTM zone 33N, for example
```

`to_crs()` transforms coordinates from one CRS to another, using the `pyproj` library internally. This is documented `geopandas` functionality. Choosing an appropriate projected CRS (such as the correct UTM zone) depends on the geographic region the data covers; using a UTM zone appropriate for one region on data actually located elsewhere produces geometrically distorted results. [Inference] This follows from how UTM zones are defined (each zone minimizes distortion within a specific longitude range), which is documented cartographic convention, but confirming the correct zone for a specific dataset's actual geographic extent requires inspecting that dataset directly.

**Why CRS mismatches matter**: computing distance directly on latitude/longitude values (treating degrees as if they were a flat Cartesian plane) produces distances that do not correspond to actual physical distance, since a degree of longitude represents a different physical distance depending on latitude (converging toward zero near the poles), while a degree of latitude represents an approximately constant physical distance. This is an established geometric fact about the Earth's spherical/ellipsoidal shape, not a hedge-requiring claim.

```python
# incorrect: treating lat/lon as Cartesian
from scipy.spatial.distance import euclidean
wrong_distance = euclidean([lat1, lon1], [lat2, lon2])

# correct: using a projected CRS or a geodesic distance formula
gdf_projected = gdf.to_crs(epsg=32633)
correct_distance = gdf_projected.geometry.iloc[0].distance(gdf_projected.geometry.iloc[1])
```

---

### Geometry Types and Validation

Geospatial data represents locations and shapes using standard geometry types: points, lines, and polygons, generally stored using the `shapely` library underneath `geopandas`.

```python
from shapely.geometry import Point, LineString, Polygon

point = Point(-122.4194, 37.7749)
line = LineString([(-122.4, 37.7), (-122.5, 37.8)])
polygon = Polygon([(-122.4, 37.7), (-122.5, 37.7), (-122.5, 37.8), (-122.4, 37.8)])
```

Invalid geometries (self-intersecting polygons, for example) can cause errors or unexpected results in subsequent spatial operations. `shapely` provides validation and repair utilities:

```python
gdf["is_valid"] = gdf.geometry.is_valid
gdf["geometry"] = gdf.geometry.buffer(0)  # a common technique to fix minor invalidities
```

`geometry.is_valid` checks each geometry against the OGC Simple Features validity rules, which is documented `shapely`/`geopandas` functionality. Applying `buffer(0)` is a widely used, documented technique for resolving certain classes of geometry invalidity (particularly self-intersections), though [Inference] it does not necessarily fix every possible type of invalid geometry, and confirming it resolved a specific geometry's issue requires re-checking `is_valid` after applying it, which I cannot do without the actual data.

---

### Handling Missing or Malformed Coordinates

```python
import pandas as pd

df = pd.read_csv("locations.csv")

df = df.dropna(subset=["latitude", "longitude"])

valid_coords = df[
    (df["latitude"].between(-90, 90)) &
    (df["longitude"].between(-180, 180))
]
```

Latitude values outside the range [-90, 90] and longitude values outside [-180, 180] are not valid geographic coordinates under standard geographic coordinate conventions, so filtering to this range is a direct, deterministic validity check based on the definition of these coordinate systems.

A common data quality issue is swapped latitude/longitude columns, which is not detectable by range-checking alone if both values happen to fall within both valid ranges (which occurs whenever both values are within [-90, 90]).

```python
def flag_possible_lat_lon_swap(df, lat_col="latitude", lon_col="longitude"):
    suspicious = df[
        (df[lat_col].abs() > 90) | 
        ((df[lon_col].abs() <= 90) & (df[lat_col].abs() <= 90))
    ]
    return suspicious
```

[Inference] This heuristic flags rows where a swap is structurally detectable (latitude value outside valid range) or plausible (both values fall in the ambiguous overlapping range), but it cannot definitively confirm a swap occurred versus data that is simply, coincidentally, both valid and unswapped — resolving genuine ambiguity requires external validation, such as checking against known reference locations.

---

### Spatial Joins

A spatial join combines two datasets based on their geometric relationship (e.g., "which points fall within which polygons"), rather than matching on a shared key column as in a standard tabular join.

```python
points_gdf = gpd.read_file("customer_locations.geojson")
zones_gdf = gpd.read_file("delivery_zones.geojson")

joined = gpd.sjoin(points_gdf, zones_gdf, how="left", predicate="within")
```

`gpd.sjoin` with `predicate="within"` matches each point in `points_gdf` to the polygon(s) in `zones_gdf` that geometrically contain it. This is documented `geopandas` functionality. Both GeoDataFrames must share the same CRS for this operation to produce geometrically correct results; `geopandas` may raise a warning or error if CRSs do not match, though the exact current behavior (warning versus error) for a specific version combination is not something I can confirm without checking that version's documentation directly. [Unverified]

---

### Feature Engineering from Geospatial Data

Common derived features include distance to a reference point, spatial density measures, and aggregation within administrative or custom boundaries.

```python
from shapely.geometry import Point

reference_point = gpd.GeoSeries([Point(-122.4194, 37.7749)], crs="EPSG:4326").to_crs(epsg=32610)
gdf_projected = gdf.to_crs(epsg=32610)

gdf_projected["distance_to_reference_m"] = gdf_projected.geometry.distance(reference_point.iloc[0])
```

This computes Euclidean distance in a projected CRS's linear units (meters, for the UTM zone used here), which approximates real-world distance reasonably well over the limited geographic extent a single UTM zone is designed for. [Inference] Accuracy degrades for locations far from the properties a specific projection is optimized for; the specific magnitude of that distortion for any given pair of points is not something I can quantify without direct computation against a specific projection and location pair.

```python
gdf["lat"] = gdf.geometry.y
gdf["lon"] = gdf.geometry.x

gdf["lat_sin"] = np.sin(np.radians(gdf["lat"]))
gdf["lon_sin"] = np.sin(np.radians(gdf["lon"]))
gdf["lon_cos"] = np.cos(np.radians(gdf["lon"]))
```

Cyclical encoding of longitude (using sine/cosine) addresses the fact that longitude wraps around (180° and -180° represent adjacent, not distant, locations), which raw numeric longitude does not represent correctly for models that would otherwise treat these as maximally different values. This is a direct mathematical consequence of how longitude is defined, not a hedge-requiring claim.

---

### Common Pitfalls

- **Mismatched CRS between joined or compared datasets**: this is a frequent, easy-to-miss source of geometrically incorrect results, since coordinate values can appear numerically plausible in either CRS without an obvious error signal.
- **Computing distance on unprojected lat/lon coordinates**: as discussed above, this produces distances that do not correspond to true physical distance except as a rough approximation, and the degree of error depends on latitude and the scale of distances involved. [Inference]
- **Swapped latitude/longitude columns**: a common data entry or import error that range-checking alone cannot always detect, as discussed above.
- **Using a single global projection for widely distributed data**: a projected CRS optimized for one region introduces increasing distortion for locations far from that region; applying it uniformly to a globally distributed dataset can produce misleading derived distance or area features. [Inference] The specific threshold at which distortion becomes practically significant depends on the specific projection and the acceptable error tolerance for the task, which I cannot specify generally without more context.
- **Ignoring invalid geometries before spatial operations**: operations like intersection or spatial joins on invalid geometries can raise errors or produce silently incorrect results, depending on the specific invalidity and the library version. [Unverified] the precise failure behavior for a specific invalidity type and library version without checking that version's documentation or testing it directly.

---

### Geospatial Preprocessing Pipeline (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 820 300">
  <text x="410" y="24" font-size="16" font-weight="bold" text-anchor="middle" fill="#222">Geospatial Preprocessing Pipeline (svg_diagram)</text>

  <rect x="30" y="60" width="160" height="55" rx="6" fill="#e8f0fe" stroke="#4a6fa5" />
  <text x="110" y="83" font-size="11" text-anchor="middle" fill="#222">Raw Coordinates</text>
  <text x="110" y="99" font-size="9" text-anchor="middle" fill="#555">lat/lon or geometry</text>

  <line x1="190" y1="87" x2="230" y2="87" stroke="#555" stroke-width="1.5" marker-end="url(#arrow9)" />

  <rect x="230" y="60" width="160" height="55" rx="6" fill="#fdf3d9" stroke="#b8912f" />
  <text x="310" y="83" font-size="11" text-anchor="middle" fill="#222">Validate Coordinates</text>
  <text x="310" y="99" font-size="9" text-anchor="middle" fill="#555">range check, swap check</text>

  <line x1="390" y1="87" x2="430" y2="87" stroke="#555" stroke-width="1.5" marker-end="url(#arrow9)" />

  <rect x="430" y="60" width="160" height="55" rx="6" fill="#fbe4ec" stroke="#b04a76" />
  <text x="510" y="83" font-size="11" text-anchor="middle" fill="#222">Check/Set CRS</text>
  <text x="510" y="99" font-size="9" text-anchor="middle" fill="#555">WGS84 or projected</text>

  <line x1="590" y1="87" x2="630" y2="87" stroke="#555" stroke-width="1.5" marker-end="url(#arrow9)" />

  <rect x="630" y="60" width="160" height="55" rx="6" fill="#e6f4ea" stroke="#3d8b52" />
  <text x="710" y="83" font-size="11" text-anchor="middle" fill="#222">Validate Geometry</text>
  <text x="710" y="99" font-size="9" text-anchor="middle" fill="#555">is_valid, buffer(0)</text>

  <line x1="710" y1="115" x2="710" y2="150" stroke="#555" stroke-width="1.5" />
  <line x1="710" y1="150" x2="310" y2="150" stroke="#555" stroke-width="1.5" />
  <line x1="310" y1="150" x2="310" y2="180" stroke="#555" stroke-width="1.5" marker-end="url(#arrow9)" />

  <rect x="150" y="180" width="320" height="55" rx="6" fill="#e2e2f5" stroke="#5a5a9c" />
  <text x="310" y="203" font-size="11" text-anchor="middle" fill="#222">Reproject to Task-Appropriate CRS</text>
  <text x="310" y="219" font-size="9" text-anchor="middle" fill="#555">UTM zone, distance-preserving</text>

  <line x1="470" y1="207" x2="510" y2="207" stroke="#555" stroke-width="1.5" marker-end="url(#arrow9)" />

  <rect x="510" y="180" width="280" height="55" rx="6" fill="#fdf3d9" stroke="#b8912f" />
  <text x="650" y="203" font-size="11" text-anchor="middle" fill="#222">Spatial Join / Feature Engineering</text>
  <text x="650" y="219" font-size="9" text-anchor="middle" fill="#555">distance, cyclical encoding</text>
</svg>

---

### Geospatial Preprocessing Decision Flow

```mermaid
flowchart TD
    A[Raw geospatial data] --> B[Validate coordinate ranges]
    B --> C{Possible lat/lon swap detected?}
    C -->|Yes| D[Flag for manual review]
    C -->|No| E{CRS defined?}
    D --> E
    E -->|No| F[Assign known source CRS]
    E -->|Yes| G[Check geometry validity]
    F --> G
    G --> H{Invalid geometries present?}
    H -->|Yes| I[Attempt repair: buffer(0) or manual fix]
    H -->|No| J{Distance/area calculations needed?}
    I --> J
    J -->|Yes| K[Reproject to appropriate projected CRS]
    J -->|No| L[Proceed with geographic CRS as needed]
    K --> M[Compute spatial joins and derived features]
    L --> M
```

---

**Related Topics**
- Choosing appropriate map projections for specific regional analysis tasks
- Spatial autocorrelation and its implications for standard cross-validation assumptions
- Raster data preprocessing (satellite imagery, elevation models) as distinct from vector geometry preprocessing
- H3 and other hexagonal spatial indexing systems for efficient spatial aggregation
- Geocoding and reverse geocoding as preprocessing steps for address-based data