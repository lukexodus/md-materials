## Geospatial Queries


### Geospatial Data Types

MongoDB supports GeoJSON objects and legacy coordinate pairs for storing geospatial data. GeoJSON is the recommended format for modern applications due to its standardization and comprehensive feature support.

#### Point

A Point represents a single location in space using longitude and latitude coordinates.

**Key Points:**

- Most basic geospatial data type
- Uses [longitude, latitude] coordinate order (X, Y format)
- Longitude range: -180 to 180 degrees
- Latitude range: -90 to 90 degrees
- Commonly used for addresses, landmarks, and user locations

**Example:**

```javascript
// Store a restaurant location
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef0"),
  name: "Mario's Italian Restaurant",
  cuisine: "Italian",
  location: {
    type: "Point",
    coordinates: [-74.0059, 40.7128] // [longitude, latitude] for NYC
  },
  address: {
    street: "123 Broadway",
    city: "New York",
    state: "NY",
    zipCode: "10001"
  },
  rating: 4.5,
  priceRange: "$$"
}

// Store user location with timestamp
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef1"),
  userId: ObjectId("64a1b2c3d4e5f6789abcdef2"),
  location: {
    type: "Point",
    coordinates: [-122.4194, 37.7749] // San Francisco coordinates
  },
  timestamp: ISODate("2024-01-15T14:30:00Z"),
  accuracy: 10, // meters
  source: "GPS"
}
```

#### LineString

A LineString represents a path or route defined by an array of coordinate points.

**Key Points:**

- Minimum of two coordinate points required
- Points are connected in sequential order
- Useful for routes, paths, boundaries, and transportation networks
- Can represent both straight lines and complex curved paths

**Example:**

```javascript
// Store a delivery route
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef0"),
  routeName: "Downtown Delivery Route A",
  driver: "John Smith",
  route: {
    type: "LineString",
    coordinates: [
      [-74.0059, 40.7128], // Starting point (NYC)
      [-74.0020, 40.7140], // Waypoint 1
      [-73.9980, 40.7160], // Waypoint 2
      [-73.9950, 40.7180], // Waypoint 3
      [-73.9920, 40.7200]  // End point
    ]
  },
  estimatedDuration: 45, // minutes
  distance: 12.5, // kilometers
  createdAt: ISODate("2024-01-15T08:00:00Z")
}

// Store a hiking trail
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef1"),
  trailName: "Mountain View Trail",
  difficulty: "Moderate",
  path: {
    type: "LineString",
    coordinates: [
      [-121.9680, 37.3387], // Trail start
      [-121.9685, 37.3395],
      [-121.9690, 37.3410],
      [-121.9698, 37.3425],
      [-121.9705, 37.3440], // Trail end at viewpoint
    ]
  },
  elevation: {
    start: 150, // meters
    end: 450,   // meters
    gain: 300   // meters
  },
  length: 2.3 // kilometers
}
```

#### Polygon

A Polygon represents an enclosed area defined by one or more LinearRings (closed LineStrings).

**Key Points:**

- First array represents the exterior boundary
- Additional arrays represent interior holes (exclusions)
- First and last coordinates must be identical to close the ring
- Minimum of four coordinate points required (including closing point)
- Coordinates must follow right-hand rule for exterior rings

**Example:**

```javascript
// Store a delivery zone
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef0"),
  zoneName: "Downtown Delivery Zone",
  deliveryFee: 5.99,
  estimatedTime: "30-45 minutes",
  area: {
    type: "Polygon",
    coordinates: [[
      [-74.0100, 40.7100], // Southwest corner
      [-74.0000, 40.7100], // Southeast corner
      [-74.0000, 40.7200], // Northeast corner
      [-74.0100, 40.7200], // Northwest corner
      [-74.0100, 40.7100]  // Close the polygon (same as first point)
    ]]
  },
  isActive: true,
  restrictions: ["No large items", "Cash only"]
}

// Store a park with an internal lake (hole)
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef1"),
  parkName: "Central Park",
  parkBoundary: {
    type: "Polygon",
    coordinates: [
      // Exterior boundary (park perimeter)
      [
        [-73.9820, 40.7681], // Southwest
        [-73.9581, 40.7681], // Southeast  
        [-73.9581, 40.7964], // Northeast
        [-73.9820, 40.7964], // Northwest
        [-73.9820, 40.7681]  // Close exterior
      ],
      // Interior hole (lake area)
      [
        [-73.9750, 40.7780], // Lake southwest
        [-73.9700, 40.7780], // Lake southeast
        [-73.9700, 40.7820], // Lake northeast
        [-73.9750, 40.7820], // Lake northwest
        [-73.9750, 40.7780]  // Close hole
      ]
    ]
  },
  facilities: ["playground", "tennis court", "walking trails"],
  area: 341 // hectares
}
```

### 2dsphere Indexes

The 2dsphere index supports queries on GeoJSON objects and provides spherical geometry calculations based on the WGS84 reference system.

#### Creating 2dsphere Indexes

**Key Points:**

- Required for GeoJSON object queries
- Supports compound indexes with other fields
- Automatically handles spherical geometry calculations
- Provides better accuracy for Earth-based coordinates than 2d indexes

**Example:**

```javascript
// Create a basic 2dsphere index
db.restaurants.createIndex({ location: "2dsphere" });

// Create a compound index for location and category
db.restaurants.createIndex({ 
  location: "2dsphere", 
  category: 1,
  rating: -1 
});

// Create index with custom options
db.locations.createIndex(
  { position: "2dsphere" },
  { 
    name: "location_index",
    background: true,
    sparse: true // Only index documents with the location field
  }
);

// Verify index creation
db.restaurants.getIndexes();
```

#### Index Performance Characteristics

**Key Points:**

- Queries without geospatial indexes scan entire collections [Inference]
- 2dsphere indexes significantly improve query performance for spatial operations
- Index selectivity affects query performance
- Consider compound indexes for frequently combined query patterns

**Example:**

```javascript
// Query performance comparison example
// Without index: scans all documents
db.restaurants.find({
  location: {
    $near: {
      $geometry: { type: "Point", coordinates: [-74.0059, 40.7128] },
      $maxDistance: 1000
    }
  }
}).explain("executionStats");

// With 2dsphere index: uses spatial index
// Much faster execution with proper index utilization
```

### Geospatial Query Operators

#### $near Operator

The `$near` operator finds documents with geospatial data closest to a specified point, sorted by distance.

**Key Points:**

- Returns results sorted by distance (closest first)
- Requires a 2dsphere index on the queried field
- Can specify maximum distance limits
- Distance calculations use spherical geometry for GeoJSON objects

**Example:**

```javascript
// Find restaurants within 1km of a location
const nearbyRestaurants = await db.restaurants.find({
  location: {
    $near: {
      $geometry: {
        type: "Point",
        coordinates: [-74.0059, 40.7128] // Times Square, NYC
      },
      $maxDistance: 1000 // 1000 meters (1km)
    }
  }
}).limit(10).toArray();

// Find closest gas stations with additional filters
const gasStations = await db.places.find({
  location: {
    $near: {
      $geometry: {
        type: "Point", 
        coordinates: [-122.4194, 37.7749] // San Francisco
      },
      $minDistance: 100,  // Minimum 100 meters away
      $maxDistance: 5000  // Maximum 5km away
    }
  },
  category: "gas_station",
  isOpen: true
}).toArray();

// Using $nearSphere for legacy coordinate pairs
const legacyNear = await db.locations.find({
  coordinates: {
    $nearSphere: [-74.0059, 40.7128],
    $maxDistance: 0.001 // Distance in radians for legacy format
  }
}).toArray();
```

#### $geoWithin Operator

The `$geoWithin` operator selects documents with geospatial data that exists entirely within a specified shape.

**Key Points:**

- Returns documents whose geometry is completely contained within the specified area
- Does not return results sorted by distance
- Supports various geometric shapes (Polygon, Circle, Box)
- More efficient than `$near` for area-based queries

**Example:**

```javascript
// Find all delivery locations within a service area
const deliveryZone = {
  type: "Polygon",
  coordinates: [[
    [-74.0200, 40.7000],
    [-73.9800, 40.7000], 
    [-73.9800, 40.7300],
    [-74.0200, 40.7300],
    [-74.0200, 40.7000]
  ]]
};

const locationsInZone = await db.deliveries.find({
  location: {
    $geoWithin: {
      $geometry: deliveryZone
    }
  }
}).toArray();

// Find stores within a circular area using $centerSphere
const storesInRadius = await db.stores.find({
  location: {
    $geoWithin: {
      $centerSphere: [
        [-74.0059, 40.7128], // Center point
        1 / 3963.2 // Radius in radians (1 mile / Earth radius in miles)
      ]
    }
  }
}).toArray();

// Find points within a bounding box
const pointsInBox = await db.locations.find({
  position: {
    $geoWithin: {
      $box: [
        [-74.1, 40.7], // Bottom left corner
        [-73.9, 40.8]  // Top right corner
      ]
    }
  }
}).toArray();
```

#### $geoIntersects Operator

The `$geoIntersects` operator selects documents with geospatial data that intersects with a specified GeoJSON object.

**Key Points:**

- Returns documents whose geometry intersects with the query geometry
- Works with any GeoJSON geometry types
- Useful for finding overlapping areas, crossing paths, or boundary intersections
- Does not require points to be completely contained within the query shape

**Example:**

```javascript
// Find delivery routes that intersect with a construction zone
const constructionZone = {
  type: "Polygon",
  coordinates: [[
    [-74.0080, 40.7120],
    [-74.0040, 40.7120],
    [-74.0040, 40.7160], 
    [-74.0080, 40.7160],
    [-74.0080, 40.7120]
  ]]
};

const affectedRoutes = await db.deliveryRoutes.find({
  route: {
    $geoIntersects: {
      $geometry: constructionZone
    }
  }
}).toArray();

// Find parks that intersect with a proposed bike path
const bikePath = {
  type: "LineString",
  coordinates: [
    [-73.9900, 40.7500],
    [-73.9850, 40.7520],
    [-73.9800, 40.7540],
    [-73.9750, 40.7560]
  ]
};

const intersectingParks = await db.parks.find({
  boundary: {
    $geoIntersects: {
      $geometry: bikePath
    }
  }
}).toArray();

// Find bus routes that cross a specific street
const street = {
  type: "LineString", 
  coordinates: [
    [-74.0100, 40.7200],
    [-73.9900, 40.7200]
  ]
};

const crossingBusRoutes = await db.busRoutes.find({
  path: {
    $geoIntersects: {
      $geometry: street
    }
  }
}).toArray();
```

### Location-Based Applications

#### Restaurant Finder Application

A comprehensive example demonstrating common patterns in location-based service applications.

**Data Model:**

```javascript
// Restaurants collection
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef0"),
  name: "Tony's Pizza Palace",
  location: {
    type: "Point",
    coordinates: [-74.0059, 40.7128]
  },
  address: {
    street: "456 Broadway",
    city: "New York", 
    state: "NY",
    zipCode: "10013"
  },
  cuisine: ["Italian", "Pizza"],
  priceRange: "$$",
  rating: 4.3,
  reviewCount: 127,
  hours: {
    monday: { open: "11:00", close: "22:00" },
    tuesday: { open: "11:00", close: "22:00" },
    // ... other days
  },
  features: ["delivery", "takeout", "outdoor_seating"],
  phone: "+1-555-0123",
  website: "https://tonyspizza.com"
}

// User preferences collection
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef1"),
  userId: ObjectId("64a1b2c3d4e5f6789abcdef2"),
  preferences: {
    cuisines: ["Italian", "Mexican", "Thai"],
    maxDistance: 2000, // meters
    priceRange: ["$", "$$"],
    dietaryRestrictions: ["vegetarian_options"]
  },
  homeLocation: {
    type: "Point",
    coordinates: [-74.0080, 40.7140]
  },
  workLocation: {
    type: "Point", 
    coordinates: [-73.9857, 40.7484]
  }
}
```

**Common Query Patterns:**

```javascript
// Find nearby restaurants with filters
async function findNearbyRestaurants(userLocation, preferences) {
  const query = {
    location: {
      $near: {
        $geometry: {
          type: "Point",
          coordinates: userLocation
        },
        $maxDistance: preferences.maxDistance || 1000
      }
    }
  };

  // Add cuisine filter if specified
  if (preferences.cuisines && preferences.cuisines.length > 0) {
    query.cuisine = { $in: preferences.cuisines };
  }

  // Add price range filter
  if (preferences.priceRange && preferences.priceRange.length > 0) {
    query.priceRange = { $in: preferences.priceRange };
  }

  // Add minimum rating filter
  if (preferences.minRating) {
    query.rating = { $gte: preferences.minRating };
  }

  const restaurants = await db.restaurants.find(query)
    .limit(20)
    .toArray();

  return restaurants;
}

// Find restaurants along a route
async function findRestaurantsAlongRoute(routeCoordinates, bufferDistance = 500) {
  const route = {
    type: "LineString",
    coordinates: routeCoordinates
  };

  // Create a buffer around the route [Inference]
  const bufferedRoute = {
    type: "Polygon",
    coordinates: [createBufferAroundLine(routeCoordinates, bufferDistance)]
  };

  const restaurants = await db.restaurants.find({
    location: {
      $geoWithin: {
        $geometry: bufferedRoute
      }
    }
  }).toArray();

  return restaurants;
}
```

#### Ride-Sharing Application

**Data Model and Queries:**

```javascript
// Drivers collection
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef0"),
  driverId: "DRV-001",
  name: "Alice Johnson",
  currentLocation: {
    type: "Point",
    coordinates: [-74.0059, 40.7128]
  },
  status: "available", // available, busy, offline
  vehicle: {
    make: "Toyota",
    model: "Camry",
    year: 2020,
    licensePlate: "ABC-123",
    color: "Blue"
  },
  rating: 4.8,
  totalRides: 1247,
  lastUpdated: ISODate("2024-01-15T14:30:00Z")
}

// Rides collection
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef1"),
  rideId: "RIDE-20240115-001",
  passengerId: ObjectId("64a1b2c3d4e5f6789abcdef2"),
  driverId: ObjectId("64a1b2c3d4e5f6789abcdef0"),
  pickup: {
    location: {
      type: "Point",
      coordinates: [-74.0080, 40.7140]
    },
    address: "123 Main St, New York, NY",
    timestamp: ISODate("2024-01-15T14:45:00Z")
  },
  dropoff: {
    location: {
      type: "Point", 
      coordinates: [-73.9857, 40.7484]
    },
    address: "456 Park Ave, New York, NY",
    timestamp: ISODate("2024-01-15T15:20:00Z")
  },
  route: {
    type: "LineString",
    coordinates: [
      [-74.0080, 40.7140],
      [-74.0070, 40.7150],
      // ... route waypoints
      [-73.9857, 40.7484]
    ]
  },
  fare: 18.50,
  distance: 5.2, // kilometers
  duration: 35, // minutes
  status: "completed"
}

// Find nearest available drivers
async function findNearestDrivers(pickupLocation, maxDistance = 2000, limit = 5) {
  const availableDrivers = await db.drivers.find({
    status: "available",
    currentLocation: {
      $near: {
        $geometry: {
          type: "Point",
          coordinates: pickupLocation
        },
        $maxDistance: maxDistance
      }
    }
  })
  .limit(limit)
  .toArray();

  return availableDrivers;
}
```

#### Delivery Service Application

**Zone-Based Delivery System:**

```javascript
// Service zones collection
{
  _id: ObjectId("64a1b2c3d4e5f6789abcdef0"),
  zoneName: "Manhattan Downtown",
  boundary: {
    type: "Polygon",
    coordinates: [[
      [-74.0200, 40.7000],
      [-73.9700, 40.7000],
      [-73.9700, 40.7500], 
      [-74.0200, 40.7500],
      [-74.0200, 40.7000]
    ]]
  },
  deliveryFee: 4.99,
  freeDeliveryMinimum: 25.00,
  averageDeliveryTime: 35, // minutes
  isActive: true,
  restrictions: {
    maxWeight: 50, // pounds
    allowedVehicles: ["bike", "scooter", "car"]
  }
}

// Check if delivery address is serviceable
async function checkDeliveryAvailability(deliveryAddress) {
  const addressPoint = {
    type: "Point",
    coordinates: deliveryAddress.coordinates
  };

  const serviceZone = await db.serviceZones.findOne({
    boundary: {
      $geoIntersects: {
        $geometry: addressPoint
      }
    },
    isActive: true
  });

  if (!serviceZone) {
    return {
      available: false,
      message: "Delivery not available in this area"
    };
  }

  return {
    available: true,
    zone: serviceZone.zoneName,
    deliveryFee: serviceZone.deliveryFee,
    estimatedTime: serviceZone.averageDeliveryTime
  };
}

// Optimize delivery routes within zones
async function optimizeDeliveryRoute(warehouseLocation, deliveries) {
  // Group deliveries by service zone
  const deliveriesByZone = await db.deliveries.aggregate([
    {
      $match: {
        _id: { $in: deliveries.map(d => d._id) },
        status: "pending"
      }
    },
    {
      $lookup: {
        from: "serviceZones",
        let: { deliveryLocation: "$address.location" },
        pipeline: [
          {
            $match: {
              $expr: {
                $geoIntersects: {
                  $geometry: "$$deliveryLocation",
                  $field: "$boundary"
                }
              }
            }
          }
        ],
        as: "zone"
      }
    },
    {
      $group: {
        _id: "$zone._id",
        deliveries: { $push: "$$ROOT" },
        zoneName: { $first: "$zone.zoneName" }
      }
    }
  ]).toArray();

  return deliveriesByZone;
}
```

**Key Points:**

- Always create appropriate 2dsphere indexes before performing geospatial queries
- Consider query performance implications when designing location-based features
- Use appropriate distance units and coordinate systems for your application's scope
- Implement proper error handling for invalid coordinates and missing location data
- [Inference] Cache frequently accessed geospatial data to improve application performance
- Consider data privacy implications when storing and querying user location information
- Plan for scalability with location-based queries as your dataset grows

**Important related topics:**

- GridFS for storing large geospatial datasets and map tiles
- Aggregation Pipeline optimization for complex geospatial analytics
- Sharding strategies for geospatially distributed data
- Real-time location tracking and change streams integration

---

