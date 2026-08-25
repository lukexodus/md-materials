## Spatial Data and Mapping


### Spatial Data Infrastructure in R

R's spatial capabilities have evolved significantly with the sf (simple features) package becoming the modern standard for spatial data handling, replacing older sp-based workflows.

**Core Spatial Packages:**

- `sf` implements simple features standard for vector data
- `stars` handles spatiotemporal arrays and raster data
- `terra` provides high-performance raster data analysis
- `lwgeom` offers additional geometric operations
- `s2` implements spherical geometry operations

**Spatial Data Structures:**

```r
library(sf)
library(terra)
library(tmap)

# Read spatial data
spatial_points <- st_read("data/points.shp")
raster_data <- rast("data/elevation.tif")

# Coordinate reference system handling
spatial_points_projected <- st_transform(spatial_points, crs = 3857)
```

### Geometric Operations and Spatial Analysis

Sophisticated spatial analysis involves geometric computations, topological relationships, and spatial statistics.

**Spatial Operations:**

- `st_intersection()`, `st_union()` for geometric operations
- `st_buffer()`, `st_centroid()` for geometric transformations
- `st_distance()`, `st_area()` for spatial measurements
- `st_within()`, `st_intersects()` for spatial predicates

**Spatial Statistics:** Advanced spatial analysis incorporates autocorrelation, clustering, and interpolation techniques.

```r
library(spdep)
library(gstat)

# Spatial autocorrelation analysis
neighbors <- poly2nb(spatial_polygons)
weights <- nb2listw(neighbors)
moran_test <- moran.test(spatial_polygons$variable, weights)

# Spatial interpolation
variogram_model <- variogram(value ~ 1, spatial_points)
fitted_variogram <- fit.variogram(variogram_model, model = vgm("Sph"))
kriged_surface <- krige(value ~ 1, spatial_points, grid, fitted_variogram)
```

### Mapping and Visualization

Modern spatial visualization combines static and interactive mapping capabilities with sophisticated cartographic design.

**Static Mapping with tmap:**

```r
# Thematic mapping
tm_shape(world_data) +
  tm_polygons("gdp_per_capita",
              style = "quantile",
              palette = "viridis") +
  tm_layout(title = "Global GDP per Capita",
            legend.outside = TRUE)
```

**Interactive Mapping:**

- `leaflet` creates interactive web maps with multiple layers
- `mapview` provides quick interactive visualization
- `plotly` enables interactive statistical graphics with spatial data
- `shiny` builds interactive spatial applications

