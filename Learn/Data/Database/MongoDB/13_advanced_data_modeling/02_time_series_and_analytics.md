## Time-Series and Analytics


### Time-Series Collections

MongoDB's time-series collections provide specialized storage and querying optimizations for time-stamped data, enabling efficient handling of metrics, logs, sensor readings, and other temporal datasets.

**Key points:**

- Automatically clusters documents by time and metadata fields
- Reduces storage overhead through columnar compression
- Optimizes query performance for time-based operations
- Supports automatic data expiration and retention policies

Time-series collection creation requires specific configuration:

```javascript
db.createCollection("weatherData", {
  timeseries: {
    timeField: "timestamp",
    metaField: "metadata",
    granularity: "hours"
  }
});
```

The timeField specifies the required timestamp field, while metaField groups related measurements. Granularity options include "seconds", "minutes", and "hours" to optimize storage bucketing.

**Example** sensor data structure:

```javascript
const sensorReading = {
  timestamp: new Date("2024-01-15T14:30:00Z"),
  metadata: {
    sensorId: "temp_01",
    location: "warehouse_a",
    zone: "storage"
  },
  temperature: 22.5,
  humidity: 65.2,
  pressure: 1013.25
};

// Insert time-series data
await db.weatherData.insertOne(sensorReading);
```

Bulk insertion patterns for high-throughput scenarios:

```javascript
const readings = [];
const startTime = new Date();

for (let i = 0; i < 1000; i++) {
  readings.push({
    timestamp: new Date(startTime.getTime() + (i * 60000)), // 1-minute intervals
    metadata: {
      sensorId: `sensor_${i % 10}`,
      location: "datacenter_1"
    },
    cpuUsage: Math.random() * 100,
    memoryUsage: Math.random() * 100,
    diskIO: Math.random() * 1000
  });
}

await db.systemMetrics.insertMany(readings, { ordered: false });
```

Index optimization for time-series queries:

```javascript
// Compound index on metadata and time
db.weatherData.createIndex({
  "metadata.sensorId": 1,
  "timestamp": 1
});

// Partial index for specific conditions
db.systemMetrics.createIndex(
  { "timestamp": 1, "metadata.location": 1 },
  {
    partialFilterExpression: {
      "metadata.location": { $exists: true }
    }
  }
);
```

### Data Retention Policies

Data retention policies automatically remove aged time-series data, preventing unbounded storage growth while maintaining system performance and compliance requirements.

**Key points:**

- TTL (Time To Live) indexes automatically delete expired documents
- ExpireAfterSeconds parameter controls retention duration
- Background processes handle deletion without application intervention
- Retention policies can be modified after collection creation

TTL index creation for automatic expiration:

```javascript
// Expire documents after 30 days
db.weatherData.createIndex(
  { "timestamp": 1 },
  { expireAfterSeconds: 2592000 } // 30 days in seconds
);

// Different retention for different data types
db.detailedMetrics.createIndex(
  { "timestamp": 1 },
  { expireAfterSeconds: 604800 } // 7 days
);

db.summaryMetrics.createIndex(
  { "timestamp": 1 },
  { expireAfterSeconds: 31536000 } // 1 year
);
```

Dynamic retention policy adjustment:

```javascript
// Modify existing TTL index
db.runCommand({
  collMod: "weatherData",
  index: {
    keyPattern: { "timestamp": 1 },
    expireAfterSeconds: 5184000 // Change to 60 days
  }
});
```

Conditional retention based on metadata:

```javascript
// Different retention for different sensor types
db.sensorData.createIndex(
  { "timestamp": 1 },
  {
    expireAfterSeconds: 86400, // 1 day default
    partialFilterExpression: {
      "metadata.type": "debug"
    }
  }
);

db.sensorData.createIndex(
  { "timestamp": 1 },
  {
    expireAfterSeconds: 2592000, // 30 days for production data
    partialFilterExpression: {
      "metadata.type": "production"
    }
  }
);
```

Manual cleanup strategies for complex retention logic:

```javascript
async function customRetentionCleanup() {
  const cutoffDate = new Date(Date.now() - (90 * 24 * 60 * 60 * 1000)); // 90 days ago
  
  // Remove old debug data but keep error logs longer
  const result = await db.applicationLogs.deleteMany({
    timestamp: { $lt: cutoffDate },
    "metadata.level": { $in: ["debug", "info"] },
    "metadata.severity": { $ne: "critical" }
  });
  
  console.log(`Cleaned up ${result.deletedCount} old log entries`);
}
```

### Aggregation for Time-Series Data

MongoDB's aggregation pipeline provides powerful operations for analyzing time-series data, including temporal grouping, statistical calculations, and trend analysis.

**Key points:**

- $dateTrunc operator enables time-based bucketing
- $group stage supports statistical aggregation functions
- $sort and $limit optimize query performance
- Pipeline stages can be combined for complex analytics

Basic time-based aggregation:

```javascript
// Hourly temperature averages
const hourlyAverages = await db.weatherData.aggregate([
  {
    $match: {
      timestamp: {
        $gte: new Date("2024-01-01T00:00:00Z"),
        $lt: new Date("2024-01-02T00:00:00Z")
      }
    }
  },
  {
    $group: {
      _id: {
        hour: { $dateTrunc: { date: "$timestamp", unit: "hour" } },
        sensorId: "$metadata.sensorId"
      },
      avgTemperature: { $avg: "$temperature" },
      minTemperature: { $min: "$temperature" },
      maxTemperature: { $max: "$temperature" },
      count: { $sum: 1 }
    }
  },
  {
    $sort: { "_id.hour": 1, "_id.sensorId": 1 }
  }
]).toArray();
```

Multi-metric statistical analysis:

```javascript
// System performance statistics by 15-minute intervals
const performanceStats = await db.systemMetrics.aggregate([
  {
    $match: {
      timestamp: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } // Last 24 hours
    }
  },
  {
    $group: {
      _id: {
        interval: {
          $dateTrunc: {
            date: "$timestamp",
            unit: "minute",
            binSize: 15
          }
        },
        server: "$metadata.serverId"
      },
      metrics: {
        $push: {
          cpu: "$cpuUsage",
          memory: "$memoryUsage",
          disk: "$diskIO"
        }
      },
      avgCpu: { $avg: "$cpuUsage" },
      maxCpu: { $max: "$cpuUsage" },
      avgMemory: { $avg: "$memoryUsage" },
      maxMemory: { $max: "$memoryUsage" },
      totalDiskIO: { $sum: "$diskIO" },
      sampleCount: { $sum: 1 }
    }
  },
  {
    $addFields: {
      cpuUtilization: {
        $cond: {
          if: { $gt: ["$avgCpu", 80] },
          then: "high",
          else: { $cond: { if: { $gt: ["$avgCpu", 50] }, then: "medium", else: "low" } }
        }
      }
    }
  }
]).toArray();
```

Trend analysis and rate calculations:

```javascript
// Calculate data ingestion rate over time
const ingestionRates = await db.dataIngestion.aggregate([
  {
    $match: {
      timestamp: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } // Last week
    }
  },
  {
    $group: {
      _id: {
        day: { $dateTrunc: { date: "$timestamp", unit: "day" } },
        source: "$metadata.source"
      },
      recordCount: { $sum: "$recordsProcessed" },
      totalBytes: { $sum: "$bytesProcessed" },
      errorCount: { $sum: "$errors" }
    }
  },
  {
    $addFields: {
      errorRate: {
        $multiply: [
          { $divide: ["$errorCount", "$recordCount"] },
          100
        ]
      },
      avgRecordSize: { $divide: ["$totalBytes", "$recordCount"] }
    }
  },
  {
    $sort: { "_id.day": 1 }
  }
]).toArray();
```

Percentile calculations for performance analysis:

```javascript
// Response time percentiles
const responseTimePercentiles = await db.apiMetrics.aggregate([
  {
    $match: {
      timestamp: { $gte: new Date(Date.now() - 60 * 60 * 1000) }, // Last hour
      "metadata.endpoint": "/api/users"
    }
  },
  {
    $group: {
      _id: {
        minute: { $dateTrunc: { date: "$timestamp", unit: "minute" } }
      },
      responseTimes: { $push: "$responseTime" }
    }
  },
  {
    $addFields: {
      p50: { $percentile: { input: "$responseTimes", p: [0.5], method: "approximate" } },
      p95: { $percentile: { input: "$responseTimes", p: [0.95], method: "approximate" } },
      p99: { $percentile: { input: "$responseTimes", p: [0.99], method: "approximate" } }
    }
  }
]).toArray();
```

### Windowing Functions

Windowing functions analyze time-series data within specified time windows, enabling moving averages, cumulative calculations, and comparative analysis across temporal boundaries.

**Key points:**

- $setWindowFields stage provides window-based operations
- Supports various window types including time-based and document-based
- Enables ranking, running totals, and lag/lead operations
- Optimizes performance through proper partitioning and sorting

Moving average calculations:

```javascript
// 7-day moving average for stock prices
const movingAverages = await db.stockPrices.aggregate([
  {
    $match: {
      symbol: "AAPL",
      timestamp: { $gte: new Date("2024-01-01") }
    }
  },
  {
    $setWindowFields: {
      partitionBy: "$symbol",
      sortBy: { timestamp: 1 },
      fields: {
        movingAvg7Day: {
          $avg: "$closePrice",
          window: {
            range: [-6, 0],
            unit: "day"
          }
        },
        movingAvg30Day: {
          $avg: "$closePrice",
          window: {
            range: [-29, 0],
            unit: "day"
          }
        }
      }
    }
  }
]).toArray();
```

Cumulative metrics and growth analysis:

```javascript
// Cumulative user registrations and daily growth
const userGrowth = await db.userRegistrations.aggregate([
  {
    $group: {
      _id: { $dateTrunc: { date: "$registrationDate", unit: "day" } },
      dailyRegistrations: { $sum: 1 }
    }
  },
  {
    $sort: { "_id": 1 }
  },
  {
    $setWindowFields: {
      sortBy: { "_id": 1 },
      fields: {
        cumulativeUsers: {
          $sum: "$dailyRegistrations",
          window: { range: ["unbounded", "current"] }
        },
        previousDayRegistrations: {
          $first: "$dailyRegistrations",
          window: { range: [-1, -1], unit: "day" }
        }
      }
    }
  },
  {
    $addFields: {
      growthRate: {
        $cond: {
          if: { $gt: ["$previousDayRegistrations", 0] },
          then: {
            $multiply: [
              {
                $divide: [
                  { $subtract: ["$dailyRegistrations", "$previousDayRegistrations"] },
                  "$previousDayRegistrations"
                ]
              },
              100
            ]
          },
          else: null
        }
      }
    }
  }
]).toArray();
```

Ranking and comparative analysis:

```javascript
// Server performance ranking within time windows
const serverRankings = await db.serverMetrics.aggregate([
  {
    $match: {
      timestamp: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }
    }
  },
  {
    $group: {
      _id: {
        hour: { $dateTrunc: { date: "$timestamp", unit: "hour" } },
        serverId: "$metadata.serverId"
      },
      avgCpuUsage: { $avg: "$cpuUsage" },
      avgMemoryUsage: { $avg: "$memoryUsage" },
      maxResponseTime: { $max: "$responseTime" }
    }
  },
  {
    $setWindowFields: {
      partitionBy: "$_id.hour",
      sortBy: { avgCpuUsage: -1 },
      fields: {
        cpuRank: { $rank: {} },
        cpuPercentileRank: { $percentRank: {} }
      }
    }
  },
  {
    $setWindowFields: {
      partitionBy: "$_id.hour",
      sortBy: { maxResponseTime: -1 },
      fields: {
        responseTimeRank: { $rank: {} }
      }
    }
  }
]).toArray();
```

Time-based lag and lead operations:

```javascript
// Compare current values with previous periods
const periodicComparison = await db.salesData.aggregate([
  {
    $group: {
      _id: {
        month: { $dateTrunc: { date: "$saleDate", unit: "month" } },
        region: "$region"
      },
      monthlySales: { $sum: "$amount" },
      transactionCount: { $sum: 1 }
    }
  },
  {
    $setWindowFields: {
      partitionBy: "$_id.region",
      sortBy: { "_id.month": 1 },
      fields: {
        previousMonthSales: {
          $first: "$monthlySales",
          window: { range: [-1, -1], unit: "month" }
        },
        nextMonthSales: {
          $first: "$monthlySales",
          window: { range: [1, 1], unit: "month" }
        },
        rollingQuarterlySales: {
          $sum: "$monthlySales",
          window: { range: [-2, 0], unit: "month" }
        }
      }
    }
  },
  {
    $addFields: {
      monthOverMonthGrowth: {
        $cond: {
          if: { $gt: ["$previousMonthSales", 0] },
          then: {
            $multiply: [
              {
                $divide: [
                  { $subtract: ["$monthlySales", "$previousMonthSales"] },
                  "$previousMonthSales"
                ]
              },
              100
            ]
          },
          else: null
        }
      }
    }
  }
]).toArray();
```

**Example** comprehensive time-series analytics dashboard query:

```javascript
async function generateTimeSeriesDashboard(startDate, endDate) {
  const [
    hourlyMetrics,
    dailyTrends,
    performanceRankings,
    anomalies
  ] = await Promise.all([
    // Hourly system metrics
    db.systemMetrics.aggregate([
      { $match: { timestamp: { $gte: startDate, $lte: endDate } } },
      {
        $group: {
          _id: { $dateTrunc: { date: "$timestamp", unit: "hour" } },
          avgCpu: { $avg: "$cpuUsage" },
          avgMemory: { $avg: "$memoryUsage" },
          maxResponseTime: { $max: "$responseTime" }
        }
      }
    ]).toArray(),
    
    // Daily trends with moving averages
    db.applicationMetrics.aggregate([
      { $match: { timestamp: { $gte: startDate, $lte: endDate } } },
      {
        $group: {
          _id: { $dateTrunc: { date: "$timestamp", unit: "day" } },
          dailyRequests: { $sum: "$requestCount" },
          avgLatency: { $avg: "$latency" }
        }
      },
      {
        $setWindowFields: {
          sortBy: { "_id": 1 },
          fields: {
            movingAvgRequests: {
              $avg: "$dailyRequests",
              window: { range: [-6, 0], unit: "day" }
            }
          }
        }
      }
    ]).toArray(),
    
    // Performance rankings
    db.serverMetrics.aggregate([
      { $match: { timestamp: { $gte: startDate, $lte: endDate } } },
      {
        $group: {
          _id: "$metadata.serverId",
          avgPerformanceScore: { $avg: "$performanceScore" }
        }
      },
      {
        $setWindowFields: {
          sortBy: { avgPerformanceScore: -1 },
          fields: { rank: { $rank: {} } }
        }
      }
    ]).toArray(),
    
    // Anomaly detection
    db.networkMetrics.aggregate([
      { $match: { timestamp: { $gte: startDate, $lte: endDate } } },
      {
        $setWindowFields: {
          partitionBy: "$metadata.interface",
          sortBy: { timestamp: 1 },
          fields: {
            avgThroughput: {
              $avg: "$throughput",
              window: { range: [-10, -1], unit: "minute" }
            },
            stdDevThroughput: {
              $stdDevPop: "$throughput",
              window: { range: [-10, -1], unit: "minute" }
            }
          }
        }
      },
      {
        $addFields: {
          zScore: {
            $divide: [
              { $subtract: ["$throughput", "$avgThroughput"] },
              "$stdDevThroughput"
            ]
          }
        }
      },
      {
        $match: {
          zScore: { $abs: { $gt: 3 } } // Outliers beyond 3 standard deviations
        }
      }
    ]).toArray()
  ]);
  
  return {
    hourlyMetrics,
    dailyTrends,
    performanceRankings,
    anomalies
  };
}
```

**Conclusion:** MongoDB's time-series capabilities provide comprehensive solutions for temporal data management and analytics. Time-series collections optimize storage and query performance, while retention policies ensure sustainable data lifecycle management. The aggregation framework enables sophisticated temporal analysis through grouping, statistical functions, and windowing operations. [Inference] These features collectively support real-time monitoring, historical analysis, and predictive analytics workflows essential for modern data-driven applications.

---

