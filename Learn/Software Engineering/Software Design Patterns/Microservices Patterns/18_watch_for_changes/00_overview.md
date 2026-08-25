## Overview

etcdctl watch /services/payment-service/ --prefix
```

**Use Cases:**

- Kubernetes environments
- Systems requiring strong consistency
- Configuration management alongside service discovery
- Distributed coordination needs

#### Zookeeper

Apache's coordination service that can be used for service registry.

**Features:**

- Proven reliability and maturity
- Strong consistency
- Hierarchical namespace
- Watches for notifications
- Used by many distributed systems (Kafka, Hadoop)

**Registration Example:**

```java
String servicePath = "/services/order-service";
String instancePath = servicePath + "/instance-1";
String instanceData = "{\"host\":\"10.0.2.10\",\"port\":9090}";

// Create ephemeral node (automatically removed on disconnect)
zookeeper.create(
    instancePath,
    instanceData.getBytes(),
    ZooDefs.Ids.OPEN_ACL_UNSAFE,
    CreateMode.EPHEMERAL
);
```

**Discovery Example:**

```java
String servicePath = "/services/order-service";

// Get all instances
List<String> instances = zookeeper.getChildren(servicePath, true);

for (String instance : instances) {
    byte[] data = zookeeper.getData(
        servicePath + "/" + instance,
        false,
        null
    );
    // Parse instance data
}
```

**Use Cases:**

- Organizations already using Zookeeper
- Systems requiring distributed locking and coordination
- Legacy microservices migrations
- Big data ecosystems

#### AWS Cloud Map

AWS managed service discovery for cloud resources.

**Features:**

- Fully managed by AWS
- Integration with ECS, EKS, EC2
- Health checking via Route 53
- API and DNS discovery methods
- No infrastructure to manage

**Registration Example:**

```bash
