## Replication Management


### Monitoring Replica Set Health

Effective replica set monitoring requires tracking multiple metrics to ensure data availability, consistency, and performance. MongoDB provides various tools and commands to assess replica set health in real-time.

**Basic Health Monitoring:**

```javascript
// Check replica set status
rs.status()

// Monitor individual member health
rs.isMaster()

// View replica set configuration
rs.conf()

// Check replication lag
db.runCommand({replSetGetStatus: 1}).members.forEach(member => {
  if (member.state === 2) { // Secondary
    console.log(`Member ${member.name}: ${member.optimeDate}`);
  }
});
```

**Key Health Indicators:**

- **Member State**: Primary (1), Secondary (2), Recovering (3), Down (8)
- **Replication Lag**: Time difference between primary and secondary oplog positions
- **Election Activity**: Frequency of primary elections indicates stability issues
- **Oplog Window**: Available time window before oplog wraps around

**Automated Health Monitoring:**

```javascript
async function monitorReplicaSetHealth() {
  try {
    const status = await db.adminCommand({replSetGetStatus: 1});
    const primary = status.members.find(m => m.state === 1);
    const secondaries = status.members.filter(m => m.state === 2);
    
    if (!primary) {
      console.error('No primary member available');
      return { healthy: false, reason: 'No primary' };
    }
    
    // Check replication lag
    const maxLag = Math.max(...secondaries.map(s => 
      (primary.optimeDate - s.optimeDate) / 1000
    ));
    
    if (maxLag > 60) { // 60 seconds threshold
      console.warn(`High replication lag: ${maxLag}s`);
      return { healthy: false, reason: `Replication lag: ${maxLag}s` };
    }
    
    // Check member availability
    const downMembers = status.members.filter(m => m.state === 8);
    if (downMembers.length > 0) {
      console.warn(`${downMembers.length} members down`);
    }
    
    return { 
      healthy: true, 
      primary: primary.name,
      secondaries: secondaries.length,
      maxLag: maxLag
    };
    
  } catch (error) {
    console.error('Health check failed:', error);
    return { healthy: false, reason: error.message };
  }
}
```

**Oplog Monitoring:**

```javascript
// Check oplog size and utilization
use local
db.oplog.rs.stats()

// Find oplog time window
const firstEntry = db.oplog.rs.find().sort({$natural: 1}).limit(1).next();
const lastEntry = db.oplog.rs.find().sort({$natural: -1}).limit(1).next();
const windowHours = (lastEntry.ts.getTime() - firstEntry.ts.getTime()) / (1000 * 60 * 60);
console.log(`Oplog window: ${windowHours} hours`);
```

**Key points:**

- Monitor primary election frequency to detect instability
- Track replication lag across all secondary members
- Ensure oplog window exceeds maintenance and backup durations
- Implement automated alerting for critical health metrics

### Handling Network Partitions

Network partitions can split replica sets into isolated groups, potentially causing data inconsistency or service unavailability. Understanding partition handling is crucial for maintaining system reliability.

**Partition Scenarios:**

- **Majority partition**: Contains majority of members, can elect primary
- **Minority partition**: Lacks majority, cannot elect primary, becomes read-only
- **Split-brain prevention**: MongoDB's election algorithm prevents multiple primaries

```javascript
// Configure replica set for partition tolerance
rs.reconfig({
  _id: "myReplicaSet",
  members: [
    { _id: 0, host: "mongo1:27017", priority: 2 },
    { _id: 1, host: "mongo2:27017", priority: 1 },
    { _id: 2, host: "mongo3:27017", priority: 1 },
    // Arbiter in different network segment
    { _id: 3, host: "arbiter:27017", arbiterOnly: true }
  ],
  settings: {
    electionTimeoutMillis: 10000,  // Faster election detection
    heartbeatIntervalMillis: 2000, // More frequent health checks
    heartbeatTimeoutSecs: 10       // Quicker failure detection
  }
});
```

**Partition Detection and Response:**

```javascript
async function handlePartitionScenario() {
  try {
    const status = await db.adminCommand({replSetGetStatus: 1});
    const totalMembers = status.members.length;
    const availableMembers = status.members.filter(m => 
      m.state === 1 || m.state === 2
    ).length;
    
    // Check if in minority partition
    if (availableMembers <= totalMembers / 2) {
      console.warn('In minority partition - read-only mode');
      
      // Implement read-only application logic
      return { 
        canWrite: false, 
        reason: 'Minority partition detected' 
      };
    }
    
    // Check primary availability
    const hasPrimary = status.members.some(m => m.state === 1);
    if (!hasPrimary) {
      console.warn('No primary available - election in progress');
      return { 
        canWrite: false, 
        reason: 'Primary election in progress' 
      };
    }
    
    return { canWrite: true };
    
  } catch (error) {
    console.error('Partition check failed:', error);
    return { canWrite: false, reason: 'Cannot determine partition status' };
  }
}
```

**Application-Level Partition Handling:**

```javascript
// Implement circuit breaker pattern for partition tolerance
class MongoCircuitBreaker {
  constructor(threshold = 5, resetTime = 60000) {
    this.failureCount = 0;
    this.threshold = threshold;
    this.resetTime = resetTime;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.lastFailureTime = null;
  }
  
  async execute(operation) {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailureTime > this.resetTime) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('Circuit breaker OPEN - service unavailable');
      }
    }
    
    try {
      const result = await operation();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }
  
  onFailure() {
    this.failureCount++;
    this.lastFailureTime = Date.now();
    
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
    }
  }
}
```

**Key points:**

- Deploy odd numbers of voting members to ensure clear majorities
- Consider arbiter placement in separate network segments
- Implement application-level partition detection and graceful degradation
- Configure appropriate election and heartbeat timeouts for your network conditions

### Read Preferences and Read Scaling

Read preferences determine which replica set members receive read operations, enabling read scaling and geographic distribution of read workloads.

**Read Preference Modes:**

- **primary**: All reads from primary (default, strongest consistency)
- **primaryPreferred**: Primary if available, otherwise secondary
- **secondary**: Only from secondary members
- **secondaryPreferred**: Secondary if available, otherwise primary
- **nearest**: Lowest network latency member

```javascript
// Configure read preferences at connection level
const client = new MongoClient(uri, {
  readPreference: 'secondaryPreferred',
  readPreferenceTags: [
    { 'region': 'us-east' },
    { 'datacenter': 'primary' },
    {} // fallback to any member
  ]
});

// Per-operation read preference
await db.collection('users')
  .find({ status: 'active' })
  .readPref('secondary')
  .toArray();

// Read preference with max staleness
await db.collection('analytics')
  .find({})
  .readPref('secondaryPreferred', null, { maxStalenessSeconds: 120 })
  .toArray();
```

**Geographic Read Scaling:**

```javascript
// Configure replica set with geographic tags
rs.reconfig({
  _id: "globalReplicaSet",
  members: [
    { 
      _id: 0, 
      host: "primary-us:27017", 
      priority: 2,
      tags: { region: "us-east", datacenter: "primary" }
    },
    { 
      _id: 1, 
      host: "secondary-us:27017", 
      priority: 1,
      tags: { region: "us-east", datacenter: "secondary" }
    },
    { 
      _id: 2, 
      host: "secondary-eu:27017", 
      priority: 0,
      tags: { region: "europe", datacenter: "primary" }
    }
  ]
});

// Application-specific read routing
class RegionalReadRouter {
  constructor(client, userRegion) {
    this.client = client;
    this.userRegion = userRegion;
  }
  
  getReadPreference(operationType) {
    const preferences = {
      'analytics': {
        mode: 'secondary',
        tags: [{ region: this.userRegion }]
      },
      'user-profile': {
        mode: 'primaryPreferred',
        maxStalenessSeconds: 30
      },
      'critical': {
        mode: 'primary'
      }
    };
    
    return preferences[operationType] || { mode: 'secondaryPreferred' };
  }
  
  async find(collection, query, operationType = 'default') {
    const readPref = this.getReadPreference(operationType);
    
    return await this.client
      .db()
      .collection(collection)
      .find(query)
      .readPref(readPref.mode, readPref.tags, {
        maxStalenessSeconds: readPref.maxStalenessSeconds
      })
      .toArray();
  }
}
```

**Read Scaling Performance Monitoring:**

```javascript
async function monitorReadDistribution() {
  const adminDb = client.db('admin');
  
  // [Inference] This monitoring approach would track read operations
  const serverStatus = await adminDb.command({serverStatus: 1});
  const opcounters = serverStatus.opcounters;
  
  console.log('Read operations:', {
    query: opcounters.query,
    getmore: opcounters.getmore,
    command: opcounters.command
  });
  
  // Monitor replication lag impact on reads
  const replStatus = await adminDb.command({replSetGetStatus: 1});
  const secondaries = replStatus.members.filter(m => m.state === 2);
  
  secondaries.forEach(secondary => {
    const lagSeconds = (Date.now() - secondary.optimeDate) / 1000;
    if (lagSeconds > 60) {
      console.warn(`Secondary ${secondary.name} lag: ${lagSeconds}s`);
    }
  });
}
```

**Key points:**

- Choose read preferences based on consistency requirements and performance needs
- Use tags for geographic or hardware-based routing
- Monitor replication lag to ensure read preference effectiveness
- Consider maxStalenessSeconds for time-sensitive read operations

### Oplog and Change Streams

The oplog (operations log) records all write operations and enables replication, while change streams provide real-time notifications of data changes.

**Oplog Structure and Management:**

```javascript
// Examine oplog entries
use local
db.oplog.rs.find().limit(5).sort({$natural: -1});

// Typical oplog entry structure
{
  "ts": ...,      // Timestamp
  "t": ...,       // Term
  "h": ...,       // Hash
  "v": 2,         // Version
  "op": "i",      // Operation type: i(nsert), u(pdate), d(elete)
  "ns": "mydb.users",
  "o": {...}      // Operation document
}

// Monitor oplog utilization
const stats = db.oplog.rs.stats();
console.log(`Oplog size: ${stats.size / (1024*1024)} MB`);
console.log(`Max size: ${stats.maxSize / (1024*1024)} MB`);
console.log(`Usage: ${(stats.size / stats.maxSize * 100).toFixed(2)}%`);
```

**Oplog Sizing Considerations:**

```javascript
// Calculate appropriate oplog size
function calculateOplogSize(peakWriteRate, maintenanceWindow) {
  // peakWriteRate: operations per second during peak
  // maintenanceWindow: hours of maintenance buffer needed
  
  const bufferMultiplier = 2; // Safety margin
  const avgOperationSize = 1024; // bytes, [Inference] estimated average
  
  const requiredSize = peakWriteRate * 
                      maintenanceWindow * 3600 * 
                      avgOperationSize * 
                      bufferMultiplier;
  
  return Math.ceil(requiredSize / (1024 * 1024 * 1024)); // Convert to GB
}

// Example: 1000 ops/sec peak, 8-hour maintenance window
const recommendedSize = calculateOplogSize(1000, 8);
console.log(`Recommended oplog size: ${recommendedSize} GB`);
```

**Change Streams Implementation:**

```javascript
// Basic change stream
const changeStream = db.collection('users').watch();

changeStream.on('change', (change) => {
  console.log('Change detected:', change);
  
  switch(change.operationType) {
    case 'insert':
      handleUserCreated(change.fullDocument);
      break;
    case 'update':
      handleUserUpdated(change.documentKey._id, change.updateDescription);
      break;
    case 'delete':
      handleUserDeleted(change.documentKey._id);
      break;
  }
});

// Filtered change stream with pipeline
const pipeline = [
  { $match: { 
    'fullDocument.status': 'premium',
    operationType: { $in: ['insert', 'update'] }
  }}
];

const premiumUserStream = db.collection('users').watch(pipeline, {
  fullDocument: 'updateLookup'
});

// Resume change stream from specific point
const resumeToken = /* saved from previous session */;
const resumableStream = db.collection('orders').watch([], {
  resumeAfter: resumeToken
});
```

**Advanced Change Stream Patterns:**

```javascript
// Change stream with error handling and reconnection
class ResilientChangeStream {
  constructor(collection, pipeline = [], options = {}) {
    this.collection = collection;
    this.pipeline = pipeline;
    this.options = options;
    this.resumeToken = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }
  
  start() {
    const streamOptions = {
      ...this.options,
      ...(this.resumeToken && { resumeAfter: this.resumeToken })
    };
    
    this.changeStream = this.collection.watch(this.pipeline, streamOptions);
    
    this.changeStream.on('change', (change) => {
      this.resumeToken = change._id;
      this.handleChange(change);
      this.reconnectAttempts = 0; // Reset on successful operation
    });
    
    this.changeStream.on('error', (error) => {
      console.error('Change stream error:', error);
      this.handleReconnection();
    });
    
    this.changeStream.on('end', () => {
      console.log('Change stream ended');
      this.handleReconnection();
    });
  }
  
  handleReconnection() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      const delay = Math.pow(2, this.reconnectAttempts) * 1000;
      
      console.log(`Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);
      setTimeout(() => this.start(), delay);
    } else {
      console.error('Max reconnection attempts reached');
    }
  }
  
  handleChange(change) {
    // [Inference] Application-specific change handling would be implemented here
    console.log('Processing change:', change.operationType);
  }
  
  close() {
    if (this.changeStream) {
      this.changeStream.close();
    }
  }
}
```

**Change Stream Performance Considerations:**

```javascript
// Optimize change stream performance
const optimizedOptions = {
  batchSize: 1000,           // Larger batches for high-volume streams
  maxAwaitTimeMS: 1000,      // Reduce latency for time-sensitive apps
  fullDocument: 'default',   // Avoid 'updateLookup' unless necessary
  collation: {               // Specify collation if needed
    locale: 'en_US',
    strength: 2
  }
};

// Monitor change stream lag
let lastProcessedTime = Date.now();
changeStream.on('change', (change) => {
  const currentTime = Date.now();
  const lagMs = currentTime - change.clusterTime.getHighBits() * 1000;
  
  if (lagMs > 5000) { // 5 second threshold
    console.warn(`Change stream lag: ${lagMs}ms`);
  }
  
  lastProcessedTime = currentTime;
});
```

**Key points:**

- Size oplog appropriately for peak write loads and maintenance windows
- Implement resilient change streams with error handling and reconnection logic
- Use pipeline filters to reduce network traffic and processing overhead
- Monitor change stream performance and lag for real-time applications

**Example** of comprehensive replication monitoring:

```javascript
async function comprehensiveReplicationMonitor() {
  const metrics = {
    timestamp: new Date(),
    replicaSet: {},
    oplog: {},
    changeStreams: {}
  };
  
  // Replica set health
  const rsStatus = await db.adminCommand({replSetGetStatus: 1});
  metrics.replicaSet = {
    primary: rsStatus.members.find(m => m.state === 1)?.name,
    secondaries: rsStatus.members.filter(m => m.state === 2).length,
    maxLag: Math.max(...rsStatus.members
      .filter(m => m.state === 2)
      .map(m => (Date.now() - m.optimeDate) / 1000)
    )
  };
  
  // Oplog metrics
  const oplogStats = await db.getSiblingDB('local').oplog.rs.stats();
  metrics.oplog = {
    sizeGB: oplogStats.size / (1024*1024*1024),
    utilizationPercent: (oplogStats.size / oplogStats.maxSize) * 100
  };
  
  return metrics;
}
```

Understanding replication management enables building robust, scalable MongoDB deployments that maintain data consistency and availability across network partitions and member failures.

---

