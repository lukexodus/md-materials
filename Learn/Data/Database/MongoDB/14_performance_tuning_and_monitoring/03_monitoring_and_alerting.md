## Monitoring and Alerting


### MongoDB Ops Manager/Cloud Manager

MongoDB Ops Manager and Cloud Manager provide comprehensive monitoring, automation, and backup solutions for MongoDB deployments, offering centralized management capabilities for production environments.

**Key points:**

- Ops Manager operates on-premises while Cloud Manager runs as a hosted service
- Provides real-time monitoring, automated backups, and deployment automation
- Supports performance optimization through query profiling and index recommendations
- Enables centralized management of multiple MongoDB clusters

Ops Manager installation requires dedicated infrastructure:

```bash
# Download and install Ops Manager
curl -OL https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-<version>.x86_64.rpm
sudo rpm -ivh mongodb-mms-<version>.x86_64.rpm

# Configure application database
sudo nano /opt/mongodb/mms/conf/conf-mms.properties
```

Basic configuration for monitoring agent deployment:

```properties
# conf-mms.properties
mms.centralUrl=http://opsmanager.company.com:8080
mongo.mongoUri=mongodb://localhost:27017
mongo.ssl=false

# Email configuration
mail.transport=smtp
mail.hostname=smtp.company.com
mail.port=587
```

Monitoring agent installation on target MongoDB instances:

```bash
# Download monitoring agent
curl -OL https://opsmanager.company.com:8080/download/agent/monitoring/mongodb-mms-monitoring-agent-<version>.linux_x86_64.tar.gz

# Extract and configure
tar -xzf mongodb-mms-monitoring-agent-<version>.linux_x86_64.tar.gz
cd mongodb-mms-monitoring-agent

# Configure agent
cat > local.config << EOF
mmsGroupId=<project-id>
mmsApiKey=<api-key>
mmsBaseUrl=http://opsmanager.company.com:8080
EOF

# Start monitoring agent
./mongodb-mms-monitoring-agent -conf=local.config
```

Cloud Manager API integration for programmatic access:

```javascript
const axios = require('axios');

class CloudManagerAPI {
  constructor(publicKey, privateKey, groupId) {
    this.publicKey = publicKey;
    this.privateKey = privateKey;
    this.groupId = groupId;
    this.baseURL = 'https://cloud.mongodb.com/api/atlas/v1.0';
  }

  async getClusterMetrics(clusterName, granularity = 'PT1M', period = 'PT1H') {
    const endpoint = `/groups/${this.groupId}/processes`;
    
    try {
      const response = await axios.get(`${this.baseURL}${endpoint}`, {
        auth: {
          username: this.publicKey,
          password: this.privateKey
        },
        params: {
          granularity,
          period
        }
      });
      
      return response.data;
    } catch (error) {
      console.error('Failed to fetch cluster metrics:', error.message);
      throw error;
    }
  }

  async createAlert(alertConfigName, eventTypeName, thresholdValue) {
    const alertConfig = {
      alertConfigName,
      enabled: true,
      eventTypeName,
      matchers: [{
        fieldName: 'HOSTNAME_AND_PORT',
        operator: 'EQUALS',
        value: 'mongodb.company.com:27017'
      }],
      notifications: [{
        typeName: 'EMAIL',
        emailAddress: 'ops@company.com',
        delayMin: 0
      }],
      threshold: {
        operator: 'GREATER_THAN',
        threshold: thresholdValue,
        units: 'RAW'
      }
    };

    const response = await axios.post(
      `${this.baseURL}/groups/${this.groupId}/alertConfigs`,
      alertConfig,
      {
        auth: {
          username: this.publicKey,
          password: this.privateKey
        }
      }
    );

    return response.data;
  }
}
```

Automation configuration for deployment management:

```json
{
  "options": {
    "downloadBase": "/var/lib/mongodb-mms-automation"
  },
  "mongoDbVersions": [
    {
      "name": "7.0.4"
    }
  ],
  "processes": [
    {
      "name": "mongodb_replica_set_1",
      "processType": "mongod",
      "version": "7.0.4",
      "hostname": "mongodb1.company.com",
      "args2_6": {
        "net": {
          "port": 27017
        },
        "storage": {
          "dbPath": "/data/db"
        },
        "replication": {
          "replSetName": "rs0"
        }
      }
    }
  ],
  "replicaSets": [
    {
      "_id": "rs0",
      "members": [
        {
          "_id": 0,
          "host": "mongodb1.company.com:27017"
        },
        {
          "_id": 1,
          "host": "mongodb2.company.com:27017"
        },
        {
          "_id": 2,
          "host": "mongodb3.company.com:27017"
        }
      ]
    }
  ]
}
```

### Third-party Monitoring Tools

Third-party monitoring solutions provide alternative approaches to MongoDB monitoring, offering integration with existing infrastructure monitoring platforms and specialized analytics capabilities.

**Key points:**

- Prometheus and Grafana provide open-source monitoring stack integration
- Datadog, New Relic offer comprehensive APM solutions with MongoDB support
- Custom exporters enable specialized metric collection and analysis
- Integration with existing alerting and incident management systems

Prometheus MongoDB Exporter configuration:

```yaml
# docker-compose.yml for MongoDB monitoring stack
version: '3.8'
services:
  mongodb-exporter:
    image: percona/mongodb_exporter:latest
    command:
      - '--mongodb.uri=mongodb://monitor:password@mongodb:27017'
      - '--collect-all'
      - '--compatible-mode'
    ports:
      - "9216:9216"
    depends_on:
      - mongodb

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-storage:/var/lib/grafana

volumes:
  grafana-storage:
```

Prometheus configuration for MongoDB metrics:

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "mongodb_rules.yml"

scrape_configs:
  - job_name: 'mongodb'
    static_configs:
      - targets: ['mongodb-exporter:9216']
    scrape_interval: 30s
    scrape_timeout: 10s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

Custom monitoring script using MongoDB native tools:

```javascript
const { MongoClient } = require('mongodb');
const axios = require('axios');

class MongoDBMonitor {
  constructor(uri, webhookUrl) {
    this.client = new MongoClient(uri);
    this.webhookUrl = webhookUrl;
    this.previousMetrics = {};
  }

  async collectMetrics() {
    await this.client.connect();
    const admin = this.client.db().admin();
    
    // Server status metrics
    const serverStatus = await admin.command({ serverStatus: 1 });
    
    // Database statistics
    const dbStats = await this.client.db().stats();
    
    // Connection metrics
    const currentOp = await admin.command({ currentOp: 1 });
    
    // Replication status
    let replStatus = null;
    try {
      replStatus = await admin.command({ replSetGetStatus: 1 });
    } catch (error) {
      // Not a replica set
    }

    const metrics = {
      timestamp: new Date(),
      connections: {
        current: serverStatus.connections.current,
        available: serverStatus.connections.available,
        totalCreated: serverStatus.connections.totalCreated
      },
      operations: {
        insert: serverStatus.opcounters.insert,
        query: serverStatus.opcounters.query,
        update: serverStatus.opcounters.update,
        delete: serverStatus.opcounters.delete,
        command: serverStatus.opcounters.command
      },
      memory: {
        resident: serverStatus.mem.resident,
        virtual: serverStatus.mem.virtual,
        mapped: serverStatus.mem.mapped || 0
      },
      storage: {
        dataSize: dbStats.dataSize,
        storageSize: dbStats.storageSize,
        indexSize: dbStats.indexSize
      },
      replication: replStatus ? {
        state: replStatus.myState,
        lag: this.calculateReplicationLag(replStatus)
      } : null
    };

    return metrics;
  }

  calculateReplicationLag(replStatus) {
    const primary = replStatus.members.find(member => member.state === 1);
    const secondary = replStatus.members.find(member => member.state === 2);
    
    if (primary && secondary && primary.optimeDate && secondary.optimeDate) {
      return primary.optimeDate.getTime() - secondary.optimeDate.getTime();
    }
    
    return 0;
  }

  async checkAlerts(metrics) {
    const alerts = [];
    
    // Connection utilization alert
    const connectionUtilization = (metrics.connections.current / metrics.connections.available) * 100;
    if (connectionUtilization > 80) {
      alerts.push({
        severity: 'warning',
        message: `High connection utilization: ${connectionUtilization.toFixed(2)}%`
      });
    }

    // Memory usage alert
    if (metrics.memory.resident > 8000) { // 8GB threshold
      alerts.push({
        severity: 'critical',
        message: `High memory usage: ${metrics.memory.resident}MB`
      });
    }

    // Replication lag alert
    if (metrics.replication && metrics.replication.lag > 30000) { // 30 seconds
      alerts.push({
        severity: 'critical',
        message: `High replication lag: ${metrics.replication.lag}ms`
      });
    }

    return alerts;
  }

  async sendAlert(alert) {
    try {
      await axios.post(this.webhookUrl, {
        text: `MongoDB Alert: ${alert.message}`,
        severity: alert.severity,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      console.error('Failed to send alert:', error.message);
    }
  }
}

// Usage
const monitor = new MongoDBMonitor(
  'mongodb://localhost:27017',
  'https://hooks.slack.com/webhook-url'
);

setInterval(async () => {
  try {
    const metrics = await monitor.collectMetrics();
    const alerts = await monitor.checkAlerts(metrics);
    
    for (const alert of alerts) {
      await monitor.sendAlert(alert);
    }
  } catch (error) {
    console.error('Monitoring error:', error);
  }
}, 60000); // Check every minute
```

Datadog integration configuration:

```yaml
# datadog.yaml
init_config:

instances:
  - hosts:
      - mongodb://datadog:password@localhost:27017/admin
    options:
      authSource: admin
    tags:
      - env:production
      - service:mongodb
    collections:
      - users
      - orders
      - products
    custom_queries:
      - metric_prefix: mongodb.custom
        query: {"find": "orders", "filter": {"status": "pending"}}
        fields:
          - field_name: count
            name: pending_orders
            type: gauge
```

### Key Metrics and Alerts

Critical MongoDB metrics require continuous monitoring to ensure optimal performance and availability, with appropriate alerting thresholds to enable proactive incident response.

**Key points:**

- Performance metrics include operation latency, throughput, and queue depth
- Resource utilization covers CPU, memory, disk I/O, and network bandwidth
- Operational metrics track connections, locks, and background operations
- Business metrics monitor application-specific KPIs and SLA compliance

Core performance metrics configuration:

```javascript
const criticalMetrics = {
  performance: {
    operationLatency: {
      threshold: 100, // milliseconds
      severity: 'warning',
      description: 'Average operation latency exceeds threshold'
    },
    queueDepth: {
      threshold: 50,
      severity: 'critical',
      description: 'Operation queue depth indicates performance bottleneck'
    },
    throughput: {
      threshold: 1000, // operations per second
      comparison: 'less_than',
      severity: 'warning',
      description: 'Throughput below expected baseline'
    }
  },
  
  resources: {
    cpuUtilization: {
      threshold: 80, // percentage
      severity: 'warning',
      sustainedMinutes: 5
    },
    memoryUtilization: {
      threshold: 85,
      severity: 'critical',
      sustainedMinutes: 2
    },
    diskUtilization: {
      threshold: 90,
      severity: 'critical',
      sustainedMinutes: 1
    },
    diskIOPS: {
      threshold: 10000,
      severity: 'warning',
      description: 'High disk I/O may indicate inefficient queries'
    }
  },
  
  operational: {
    connectionUtilization: {
      threshold: 80,
      severity: 'warning',
      calculation: '(current_connections / max_connections) * 100'
    },
    replicationLag: {
      threshold: 10000, // milliseconds
      severity: 'critical',
      description: 'Secondary nodes falling behind primary'
    },
    lockWaitTime: {
      threshold: 1000,
      severity: 'warning',
      description: 'Operations waiting for locks'
    }
  }
};
```

Alert rule definitions for Prometheus:

```yaml
# mongodb_rules.yml
groups:
  - name: mongodb
    rules:
      - alert: MongoDBDown
        expr: mongodb_up == 0
        for: 30s
        labels:
          severity: critical
        annotations:
          summary: "MongoDB instance is down"
          description: "MongoDB instance {{ $labels.instance }} is down"

      - alert: MongoDBHighConnections
        expr: (mongodb_connections{state="current"} / mongodb_connections{state="available"}) * 100 > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "MongoDB high connection usage"
          description: "MongoDB connection usage is {{ $value }}% on {{ $labels.instance }}"

      - alert: MongoDBReplicationLag
        expr: mongodb_replset_member_lag_seconds > 30
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "MongoDB replication lag"
          description: "MongoDB replication lag is {{ $value }}s on {{ $labels.instance }}"

      - alert: MongoDBHighMemoryUsage
        expr: (mongodb_memory{type="resident"} / 1024 / 1024) > 8000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "MongoDB high memory usage"
          description: "MongoDB memory usage is {{ $value }}MB on {{ $labels.instance }}"

      - alert: MongoDBSlowQueries
        expr: rate(mongodb_op_latencies_latency_total[5m]) > 100
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "MongoDB slow queries detected"
          description: "Average query latency is {{ $value }}ms on {{ $labels.instance }}"
```

Business metrics monitoring implementation:

```javascript
async function monitorBusinessMetrics() {
  const client = new MongoClient(process.env.MONGODB_URI);
  await client.connect();
  
  const db = client.db('ecommerce');
  
  // Order processing metrics
  const orderMetrics = await db.collection('orders').aggregate([
    {
      $match: {
        createdAt: {
          $gte: new Date(Date.now() - 60 * 60 * 1000) // Last hour
        }
      }
    },
    {
      $group: {
        _id: null,
        totalOrders: { $sum: 1 },
        totalRevenue: { $sum: '$amount' },
        avgOrderValue: { $avg: '$amount' },
        failedOrders: {
          $sum: {
            $cond: [{ $eq: ['$status', 'failed'] }, 1, 0]
          }
        }
      }
    }
  ]).toArray();

  // User engagement metrics
  const userMetrics = await db.collection('user_sessions').aggregate([
    {
      $match: {
        startTime: {
          $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // Last 24 hours
        }
      }
    },
    {
      $group: {
        _id: null,
        totalSessions: { $sum: 1 },
        uniqueUsers: { $addToSet: '$userId' },
        avgSessionDuration: { $avg: '$duration' },
        bounceRate: {
          $avg: {
            $cond: [{ $lte: ['$pageViews', 1] }, 1, 0]
          }
        }
      }
    },
    {
      $addFields: {
        uniqueUserCount: { $size: '$uniqueUsers' }
      }
    }
  ]).toArray();

  // Performance SLA metrics
  const performanceMetrics = await db.collection('api_requests').aggregate([
    {
      $match: {
        timestamp: {
          $gte: new Date(Date.now() - 60 * 60 * 1000)
        }
      }
    },
    {
      $group: {
        _id: '$endpoint',
        totalRequests: { $sum: 1 },
        avgResponseTime: { $avg: '$responseTime' },
        p95ResponseTime: {
          $percentile: {
            input: '$responseTime',
            p: [0.95],
            method: 'approximate'
          }
        },
        errorRate: {
          $avg: {
            $cond: [{ $gte: ['$statusCode', 400] }, 1, 0]
          }
        }
      }
    }
  ]).toArray();

  return {
    orders: orderMetrics[0] || {},
    users: userMetrics[0] || {},
    performance: performanceMetrics
  };
}
```

### Capacity Planning

Capacity planning ensures MongoDB deployments can handle projected growth while maintaining performance requirements, involving analysis of historical trends and resource utilization patterns.

**Key points:**

- Historical data analysis identifies growth trends and seasonal patterns
- Resource modeling predicts future infrastructure requirements
- Performance testing validates capacity assumptions under load
- Cost optimization balances performance requirements with budget constraints

Growth trend analysis implementation:

```javascript
async function analyzeGrowthTrends(timeRange = 90) { // days
  const client = new MongoClient(process.env.MONGODB_URI);
  await client.connect();
  
  const cutoffDate = new Date(Date.now() - timeRange * 24 * 60 * 60 * 1000);
  
  // Data growth analysis
  const dataGrowth = await client.db().admin().command({
    listCollections: 1
  });
  
  const growthMetrics = {};
  
  for (const collection of dataGrowth.cursor.firstBatch) {
    const collName = collection.name;
    const stats = await client.db().collection(collName).stats();
    
    // Daily document count growth
    const dailyGrowth = await client.db().collection(collName).aggregate([
      {
        $match: {
          createdAt: { $gte: cutoffDate }
        }
      },
      {
        $group: {
          _id: {
            $dateTrunc: { date: '$createdAt', unit: 'day' }
          },
          count: { $sum: 1 },
          avgSize: { $avg: { $bsonSize: '$$ROOT' } }
        }
      },
      {
        $sort: { '_id': 1 }
      }
    ]).toArray();
    
    // Calculate growth rate
    if (dailyGrowth.length >= 7) {
      const recentWeek = dailyGrowth.slice(-7);
      const previousWeek = dailyGrowth.slice(-14, -7);
      
      const recentAvg = recentWeek.reduce((sum, day) => sum + day.count, 0) / 7;
      const previousAvg = previousWeek.reduce((sum, day) => sum + day.count, 0) / 7;
      
      const weeklyGrowthRate = ((recentAvg - previousAvg) / previousAvg) * 100;
      
      growthMetrics[collName] = {
        currentSize: stats.size,
        currentCount: stats.count,
        avgDocumentSize: stats.avgObjSize,
        weeklyGrowthRate,
        dailyGrowthData: dailyGrowth
      };
    }
  }
  
  return growthMetrics;
}

async function projectCapacityRequirements(growthData, projectionMonths = 12) {
  const projections = {};
  
  for (const [collection, metrics] of Object.entries(growthData)) {
    const monthlyGrowthRate = metrics.weeklyGrowthRate * 4.33; // weeks per month
    const compoundGrowthFactor = Math.pow(1 + (monthlyGrowthRate / 100), projectionMonths);
    
    const projectedCount = Math.ceil(metrics.currentCount * compoundGrowthFactor);
    const projectedSize = Math.ceil(metrics.currentSize * compoundGrowthFactor);
    
    projections[collection] = {
      current: {
        count: metrics.currentCount,
        size: metrics.currentSize,
        avgDocSize: metrics.avgDocumentSize
      },
      projected: {
        count: projectedCount,
        size: projectedSize,
        additionalSize: projectedSize - metrics.currentSize
      },
      growthRate: monthlyGrowthRate
    };
  }
  
  return projections;
}
```

Resource utilization modeling:

```javascript
class CapacityPlanner {
  constructor(mongoClient) {
    this.client = mongoClient;
    this.resourceMetrics = [];
  }

  async collectResourceBaseline(samplingDays = 30) {
    const admin = this.client.db().admin();
    const samples = [];
    
    // Collect samples over time period
    for (let day = 0; day < samplingDays; day++) {
      const serverStatus = await admin.command({ serverStatus: 1 });
      const dbStats = await this.client.db().stats();
      
      samples.push({
        timestamp: new Date(),
        cpu: await this.getCPUUsage(), // [Unverified] - requires external CPU monitoring
        memory: {
          resident: serverStatus.mem.resident,
          virtual: serverStatus.mem.virtual,
          usage: (serverStatus.mem.resident / this.getTotalSystemMemory()) * 100
        },
        storage: {
          dataSize: dbStats.dataSize,
          storageSize: dbStats.storageSize,
          indexSize: dbStats.indexSize,
          freeSpace: await this.getDiskFreeSpace() // [Unverified] - requires system integration
        },
        operations: {
          insert: serverStatus.opcounters.insert,
          query: serverStatus.opcounters.query,
          update: serverStatus.opcounters.update,
          delete: serverStatus.opcounters.delete
        },
        connections: serverStatus.connections.current
      });
      
      // Wait between samples (simplified for example)
      await new Promise(resolve => setTimeout(resolve, 24 * 60 * 60 * 1000 / samplingDays));
    }
    
    this.resourceMetrics = samples;
    return this.analyzeResourceTrends();
  }

  analyzeResourceTrends() {
    const analysis = {
      memory: this.calculateTrend(this.resourceMetrics.map(s => s.memory.usage)),
      storage: this.calculateTrend(this.resourceMetrics.map(s => s.storage.dataSize)),
      operations: this.calculateTrend(this.resourceMetrics.map(s => 
        s.operations.insert + s.operations.query + s.operations.update + s.operations.delete
      )),
      connections: this.calculateTrend(this.resourceMetrics.map(s => s.connections))
    };
    
    return analysis;
  }

  calculateTrend(values) {
    if (values.length < 2) return { trend: 0, correlation: 0 };
    
    const n = values.length;
    const x = Array.from({length: n}, (_, i) => i);
    const sumX = x.reduce((a, b) => a + b, 0);
    const sumY = values.reduce((a, b) => a + b, 0);
    const sumXY = x.reduce((sum, xi, i) => sum + xi * values[i], 0);
    const sumXX = x.reduce((sum, xi) => sum + xi * xi, 0);
    
    const slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    const intercept = (sumY - slope * sumX) / n;
    
    // Calculate R-squared
    const avgY = sumY / n;
    const ssRes = values.reduce((sum, yi, i) => {
      const predicted = slope * i + intercept;
      return sum + Math.pow(yi - predicted, 2);
    }, 0);
    const ssTot = values.reduce((sum, yi) => sum + Math.pow(yi - avgY, 2), 0);
    const rSquared = 1 - (ssRes / ssTot);
    
    return {
      trend: slope,
      correlation: rSquared,
      dailyGrowthRate: slope,
      projectedValue: (days) => slope * days + intercept
    };
  }

  generateCapacityRecommendations(projectionMonths = 12) {
    const trends = this.analyzeResourceTrends();
    const days = projectionMonths * 30;
    
    const recommendations = {
      memory: {
        current: this.resourceMetrics[this.resourceMetrics.length - 1].memory.usage,
        projected: trends.memory.projectedValue(days),
        recommendation: this.getMemoryRecommendation(trends.memory.projectedValue(days))
      },
      storage: {
        current: this.resourceMetrics[this.resourceMetrics.length - 1].storage.dataSize,
        projected: trends.storage.projectedValue(days),
        recommendation: this.getStorageRecommendation(trends.storage.projectedValue(days))
      },
      scaling: {
        horizontal: this.shouldScaleHorizontally(trends),
        vertical: this.shouldScaleVertically(trends)
      }
    };
    
    return recommendations;
  }

  getMemoryRecommendation(projectedUsage) {
    if (projectedUsage > 80) {
      return {
        action: 'increase',
        priority: 'high',
        details: 'Memory usage will exceed 80% threshold'
      };
    } else if (projectedUsage > 60) {
      return {
        action: 'monitor',
        priority: 'medium',
        details: 'Memory usage approaching capacity limits'
      };
    }
    return {
      action: 'maintain',
      priority: 'low',
      details: 'Current memory allocation sufficient'
    };
  }

  shouldScaleHorizontally(trends) {
    const operationsTrend = trends.operations.trend;
    const connectionsTrend = trends.connections.trend;
    
    return operationsTrend > 1000 || connectionsTrend > 50; // [Inference] - based on typical scaling thresholds
  }
}
```

**Example** comprehensive capacity planning report:

```javascript
async function generateCapacityPlanningReport() {
  const client = new MongoClient(process.env.MONGODB_URI);
  await client.connect();
  
  const planner = new CapacityPlanner(client);
  
  // Collect historical data and analyze trends
  const [
    growthTrends,
    resourceTrends,
    capacityRecommendations,
    costProjections
  ] = await Promise.all([
    analyzeGrowthTrends(90),
    planner.collectResourceBaseline(30),
    planner.generateCapacityRecommendations(12),
    calculateCostProjections() // [Unverified] - requires cost modeling implementation
  ]);
  
  const report = {
    executiveSummary: {
      currentDataSize: formatBytes(getTotalDataSize(growthTrends)),
      projectedDataSize: formatBytes(getProjectedDataSize(growthTrends, 12)),
      recommendedActions: extractKeyRecommendations(capacityRecommendations),
      estimatedCost: costProjections.annual
    },
    dataGrowthAnalysis: growthTrends,
    resourceUtilization: resourceTrends,
    recommendations: capacityRecommendations,
    actionPlan: generateActionPlan(capacityRecommendations),
    timeline: generateImplementationTimeline(capacityRecommendations)
  };
  
  return report;
}

function generateActionPlan(recommendations) {
  const actions = [];
  
  if (recommendations.memory.recommendation.priority === 'high') {
    actions.push({
      action: 'Increase memory allocation',
      timeline: '1-2 weeks',
      impact: 'Prevent performance degradation',
      cost: 'Medium'
    });
  }
  
  if (recommendations.scaling.horizontal) {
    actions.push({
      action: 'Add replica set members',
      timeline: '2-4 weeks',
      impact: 'Distribute read load and improve availability',
      cost: 'High'
    });
  }
  
  return actions;
}
```

**Conclusion:** MongoDB monitoring and alerting requires comprehensive coverage of performance, resource, and business metrics through both native and third-party tools. Ops Manager and Cloud Manager provide integrated solutions for enterprise deployments, while open-source alternatives offer flexibility and cost control. [Inference] Effective capacity planning combines historical trend analysis with predictive modeling to ensure infrastructure can support projected growth while maintaining performance and cost efficiency. [Unverified] The specific threshold values and scaling recommendations should be validated against actual workload characteristics and business requirements.

---

