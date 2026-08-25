## Replica Sets Fundamentals


### Replica Set Architecture

A replica set is MongoDB's native replication solution that maintains multiple copies of data across different servers to provide high availability, data redundancy, and read scalability. The architecture consists of multiple MongoDB instances (nodes) that work together to maintain data consistency and automatic failover capabilities.

**Core Components:**

**Node Types:**

- **Primary**: Single node that receives all write operations
- **Secondary**: Nodes that replicate data from the primary
- **Arbiter**: Lightweight node that participates in elections but holds no data
- **Hidden**: Secondary node invisible to client applications
- **Delayed**: Secondary with intentional replication lag for backup purposes

**Replica Set Topology:**

```javascript
// Basic three-node replica set configuration
{
  _id: "myReplicaSet",
  members: [
    { _id: 0, host: "mongo1.example.com:27017", priority: 2 },
    { _id: 1, host: "mongo2.example.com:27017", priority: 1 },
    { _id: 2, host: "mongo3.example.com:27017", priority: 1 }
  ]
}
```

**Architectural Principles:**

**Data Synchronization Flow:**

1. Client writes to primary node
2. Primary logs operation to oplog (operations log)
3. Secondary nodes continuously poll primary's oplog
4. Secondary nodes apply operations in the same order
5. Write acknowledgment sent based on write concern settings

**Network Communication:**

- Replica set members communicate via heartbeat messages every 2 seconds
- Oplogs are replicated asynchronously from primary to secondaries
- Election communication occurs during primary unavailability
- Client connections use replica set connection strings for automatic discovery

**Oplog Structure:**

The oplog is a capped collection that records all operations modifying data:

```javascript
// Example oplog entry
{
  "ts": ObjectId("..."), // Timestamp
  "t": NumberLong(1),    // Term number
  "h": NumberLong(...),  // Hash
  "v": 2,                // Version
  "op": "i",             // Operation type (i=insert, u=update, d=delete)
  "ns": "mydb.users",    // Namespace
  "o": { ... }           // Operation document
}
```

**Read Preference Routing:**

[Inference] Clients can direct read operations to different replica set members based on application requirements:

- **Primary**: All reads from primary (default)
- **Secondary**: Reads from secondary nodes only
- **Preferred Secondary**: Secondary preferred, primary fallback
- **Nearest**: Lowest network latency node

### Primary and Secondary Nodes

The primary-secondary model forms the foundation of MongoDB's replica set architecture, with distinct roles and responsibilities for maintaining data consistency and availability.

**Primary Node Characteristics:**

**Write Operations:**

- Accepts all write operations (insert, update, delete)
- Maintains the authoritative copy of data
- Records all operations in the oplog
- Acknowledges writes based on write concern settings

**Primary Election Eligibility:**

```javascript
// Node configuration affecting primary eligibility
{
  _id: 0,
  host: "mongo1.example.com:27017",
  priority: 1,        // Higher priority increases election chances
  votes: 1,           // Voting member in elections
  arbiterOnly: false, // Can become primary
  hidden: false,      // Visible to client applications
  secondaryDelaySecs: 0 // No replication delay
}
```

**Secondary Node Functions:**

**Replication Process:**

1. Continuously fetch oplog entries from sync source
2. Apply operations in the same order as primary
3. Maintain local copy of data
4. Serve read operations when configured
5. Participate in primary elections

**Secondary Types:**

**Standard Secondary:**

```javascript
{
  _id: 1,
  host: "mongo2.example.com:27017",
  priority: 1,
  votes: 1
}
```

**Hidden Secondary:**

```javascript
{
  _id: 2,
  host: "mongo3.example.com:27017",
  priority: 0,
  votes: 1,
  hidden: true  // Invisible to client applications
}
```

**Delayed Secondary:**

```javascript
{
  _id: 3,
  host: "mongo4.example.com:27017",
  priority: 0,
  votes: 0,
  secondaryDelaySecs: 3600, // 1 hour delay
  hidden: true
}
```

**Sync Source Selection:**

[Inference] Secondary nodes choose sync sources based on several factors:

- Network proximity and latency
- Oplog freshness and availability
- Member priority and configuration
- Chaining preferences and restrictions

**Replication Lag Monitoring:**

```javascript
// Check replication lag
rs.status().members.forEach(function(member) {
  if (member.state === 2) { // Secondary
    print(member.name + " lag: " + 
          (rs.status().date - member.optimeDate) + "ms");
  }
});
```

**Data Consistency Models:**

**Eventual Consistency:**

- Secondary nodes may lag behind primary
- Read operations from secondaries may return stale data
- Write operations are immediately consistent on primary

**Strong Consistency:**

- Use majority write concern for durability guarantees
- Read from primary for most recent data
- Configure appropriate read preferences for consistency requirements

### Automatic Failover

Automatic failover ensures continuous database availability by promoting a secondary node to primary when the current primary becomes unavailable. This process occurs without manual intervention and maintains service continuity.

**Failover Trigger Conditions:**

**Primary Unavailability Detection:**

- Network connectivity loss between replica set members
- Primary node process termination or system failure
- Prolonged unresponsiveness to heartbeat messages
- Manual primary stepping down

**Heartbeat Mechanism:**

- Replica set members exchange heartbeat messages every 2 seconds
- Members mark nodes as unreachable after 10 seconds without response
- Election initiation occurs when primary becomes unreachable

**Failover Process Timeline:**

1. **Detection Phase (0-10 seconds)**: Members detect primary unavailability
2. **Election Initiation (10-12 seconds)**: Eligible secondaries call for election
3. **Voting Phase (12-15 seconds)**: Members vote for new primary
4. **Primary Selection (15-20 seconds)**: Candidate with majority becomes primary
5. **Catch-up Phase (Variable)**: New primary ensures data consistency
6. **Service Restoration (20+ seconds)**: Client connections redirect to new primary

**Write Concern and Failover:**

```javascript
// Majority write concern ensures durability across failover
db.users.insertOne(
  { name: "John", email: "john@example.com" },
  { writeConcern: { w: "majority", j: true, wtimeout: 5000 } }
);
```

**Client Behavior During Failover:**

[Inference] Client applications experience predictable behavior patterns during failover:

- Write operations may fail or timeout during transition period
- Read operations continue if reading from secondaries
- Connection pools automatically discover new primary
- Applications should implement retry logic for transient failures

**Rollback Scenarios:**

When a former primary rejoins the replica set after failover, operations not replicated to the majority may be rolled back:

```javascript
// Operations at risk of rollback
db.orders.insertOne({ customerId: 123, amount: 100 });
// If this write wasn't replicated to majority before failover,
// it may be rolled back when the node rejoins
```

**Rollback Prevention:**

```javascript
// Use majority write concern to prevent rollbacks
db.orders.insertOne(
  { customerId: 123, amount: 100 },
  { writeConcern: { w: "majority" } }
);
```

### Election Process

The election process determines which eligible secondary node becomes the new primary during failover situations. This distributed algorithm ensures consensus among replica set members and maintains data integrity.

**Election Trigger Events:**

- Primary node becomes unreachable or steps down
- Replica set initialization
- Manual election calls
- Configuration changes affecting member priorities

**Election Eligibility Requirements:**

**Voting Members:**

- Must have `votes: 1` in configuration
- Must be reachable by majority of voting members
- Cannot be arbiters (for primary candidacy)
- Must not be hidden with priority 0

**Candidate Qualifications:**

```javascript
// Eligible primary candidate configuration
{
  _id: 1,
  host: "mongo2.example.com:27017",
  priority: 1,    // Must be > 0 to become primary
  votes: 1,       // Must vote in elections
  arbiterOnly: false, // Cannot be arbiter
  hidden: false   // Can be hidden but needs priority > 0
}
```

**Election Algorithm:**

**Vote Calculation:**

- Majority of voting members must participate
- Each voting member gets exactly one vote
- Candidate with majority wins election
- Ties result in no primary (election retry)

**Priority-Based Selection:**

```javascript
// Higher priority members preferred as primary
{
  members: [
    { _id: 0, host: "mongo1:27017", priority: 2 }, // Preferred primary
    { _id: 1, host: "mongo2:27017", priority: 1 },
    { _id: 2, host: "mongo3:27017", priority: 1 }
  ]
}
```

**Election Factors:**

**Data Freshness:**

- Candidates with most recent oplog entries preferred
- Members significantly behind in replication may be ineligible
- Optime comparison determines data currency

**Network Partition Handling:**

- Elections require majority of voting members
- Network partitions prevent minority groups from electing primary
- Split-brain scenarios avoided through majority requirement

**Term Numbers:** Each election cycle uses incrementing term numbers to maintain consistency across distributed decisions.

**Manual Election Control:**

```javascript
// Step down current primary (triggers election)
rs.stepDown(60); // Step down for 60 seconds

// Force election call
rs.reconfig({
  _id: "myReplicaSet",
  members: [
    { _id: 0, host: "mongo1:27017", priority: 0 }, // Reduce priority
    { _id: 1, host: "mongo2:27017", priority: 2 }, // Increase priority
    { _id: 2, host: "mongo3:27017", priority: 1 }
  ]
});
```

**Election Monitoring:**

```javascript
// Monitor replica set status during elections
rs.status();

// Check election metrics
db.serverStatus().electionMetrics;

// View oplog positions
rs.printReplicationInfo();
```

**Election Edge Cases:**

**Arbiter Considerations:**

```javascript
// Arbiter configuration for tie-breaking
{
  _id: 2,
  host: "arbiter.example.com:27017",
  arbiterOnly: true,
  votes: 1,
  priority: 0
}
```

Arbiters participate in voting but cannot become primary, useful for odd-number voting member configurations.

**Priority 0 Members:**

```javascript
// Member that cannot become primary
{
  _id: 3,
  host: "analytics.example.com:27017",
  priority: 0, // Cannot become primary
  votes: 1,    // Can vote in elections
  tags: { "usage": "analytics" }
}
```

**Election Performance Considerations:**

[Inference] Election timing affects application availability:

- Faster elections reduce downtime but may compromise thorough candidate evaluation
- Network latency impacts election duration
- Replica set size affects voting coordination time
- Geographic distribution increases election complexity

**Best Practices:**

**Replica Set Sizing:**

- Use odd numbers of voting members to avoid ties
- Consider 3-member minimum for automatic failover
- Balance between fault tolerance and operational complexity

**Priority Configuration:**

- Assign higher priorities to preferred primary candidates
- Use priority 0 for specialized secondary roles
- Consider geographic distribution in priority assignment

**Monitoring and Alerting:**

- Monitor election frequency and duration
- Alert on frequent primary changes
- Track replication lag across members
- Monitor vote participation in elections

**Configuration Validation:**

```javascript
// Validate replica set configuration
rs.conf();

// Check member states
rs.status().members.forEach(function(member) {
  print(member.name + ": " + member.stateStr);
});
```

**Related Topics:** Write concern strategies for replica sets, read preference optimization, replica set monitoring and alerting, geographic distribution patterns, and replica set security configurations.

---

