Running multiple nodes locally
## Running Multiple Nodes Locally

---

### Overview

Running multiple Elasticsearch nodes on a single machine is useful for testing cluster behavior, shard allocation, replication, master election, and failover scenarios without requiring multiple physical or virtual hosts. It is not suitable for production — local multi-node setups share CPU, RAM, and disk, eliminating the fault isolation that makes clustering valuable in real deployments.

This topic covers multi-node setups via TAR archive, Docker Compose, and key configuration requirements common to all approaches.

---

### When to Run Multiple Nodes Locally

| Use Case | Suitable |
|---|---|
| Testing shard allocation and replication | Yes |
| Simulating node failure and recovery | Yes |
| Verifying cluster formation and master election | Yes |
| Learning distributed Elasticsearch behavior | Yes |
| Development against a realistic cluster topology | Yes |
| Production workloads | No |
| High-availability requirements | No |

---

### Core Requirements for a Local Multi-Node Cluster

Regardless of the method used, every multi-node cluster requires the following to be correctly configured.

#### 1 — Shared Cluster Name

All nodes must share the same `cluster.name`. Nodes with different cluster names will not join each other.

```yaml
cluster.name: local-dev-cluster
```

#### 2 — Unique Node Names

Each node must have a distinct `node.name`.

```yaml
# Node 1
node.name: node-1

# Node 2
node.name: node-2
```

#### 3 — Unique Ports

On a single host, each node must bind to different ports for both HTTP and transport communication.

| Node | HTTP Port | Transport Port |
|---|---|---|
| node-1 | 9200 | 9300 |
| node-2 | 9201 | 9301 |
| node-3 | 9202 | 9302 |

#### 4 — Unique Data Directories

Each node must write to a separate data directory. Sharing a data directory between nodes will cause data corruption.

```yaml
# Node 1
path.data: /tmp/es-data/node-1

# Node 2
path.data: /tmp/es-data/node-2
```

#### 5 — Discovery Configuration

Nodes must know how to find each other. For a local cluster, `discovery.seed_hosts` lists the transport addresses of other nodes.

```yaml
discovery.seed_hosts:
  - 127.0.0.1:9300
  - 127.0.0.1:9301
  - 127.0.0.1:9302
```

#### 6 — Initial Master Node Bootstrap

`cluster.initial_master_nodes` is required for the **first-time** formation of a cluster. It lists the node names (not addresses) of master-eligible nodes.

```yaml
cluster.initial_master_nodes:
  - node-1
  - node-2
  - node-3
```

> This setting must be removed or commented out after the cluster has formed. Leaving it in place can interfere with master re-election on subsequent restarts. [Inference] Exact behavior with this setting left in place varies by Elasticsearch version.

---

### Method 1 — Multiple Nodes from a Single TAR Install

A single extracted Elasticsearch archive can be used to run multiple nodes simultaneously. Each node uses the same binaries but a separate configuration directory.

#### Step 1 — Extract the Archive Once

```bash
tar -xzf elasticsearch-8.13.0-linux-x86_64.tar.gz
cd elasticsearch-8.13.0
```

#### Step 2 — Create Per-Node Configuration Directories

```bash
mkdir -p /tmp/es-config/node-1
mkdir -p /tmp/es-config/node-2
mkdir -p /tmp/es-config/node-3
```

Copy the base configuration into each:

```bash
cp -r config/* /tmp/es-config/node-1/
cp -r config/* /tmp/es-config/node-2/
cp -r config/* /tmp/es-config/node-3/
```

#### Step 3 — Write Per-Node `elasticsearch.yml`

**`/tmp/es-config/node-1/elasticsearch.yml`:**

```yaml
cluster.name: local-dev-cluster
node.name: node-1

path.data: /tmp/es-data/node-1
path.logs: /tmp/es-logs/node-1

network.host: 127.0.0.1
http.port: 9200
transport.port: 9300

discovery.seed_hosts:
  - 127.0.0.1:9300
  - 127.0.0.1:9301
  - 127.0.0.1:9302

cluster.initial_master_nodes:
  - node-1
  - node-2
  - node-3

xpack.security.enabled: false
```

**`/tmp/es-config/node-2/elasticsearch.yml`:**

```yaml
cluster.name: local-dev-cluster
node.name: node-2

path.data: /tmp/es-data/node-2
path.logs: /tmp/es-logs/node-2

network.host: 127.0.0.1
http.port: 9201
transport.port: 9301

discovery.seed_hosts:
  - 127.0.0.1:9300
  - 127.0.0.1:9301
  - 127.0.0.1:9302

cluster.initial_master_nodes:
  - node-1
  - node-2
  - node-3

xpack.security.enabled: false
```

**`/tmp/es-config/node-3/elasticsearch.yml`:**

```yaml
cluster.name: local-dev-cluster
node.name: node-3

path.data: /tmp/es-data/node-3
path.logs: /tmp/es-logs/node-3

network.host: 127.0.0.1
http.port: 9202
transport.port: 9302

discovery.seed_hosts:
  - 127.0.0.1:9300
  - 127.0.0.1:9301
  - 127.0.0.1:9302

cluster.initial_master_nodes:
  - node-1
  - node-2
  - node-3

xpack.security.enabled: false
```

#### Step 4 — Create Data and Log Directories

```bash
mkdir -p /tmp/es-data/node-{1,2,3}
mkdir -p /tmp/es-logs/node-{1,2,3}
```

#### Step 5 — Start Each Node in a Separate Terminal

```bash
# Terminal 1
ES_PATH_CONF=/tmp/es-config/node-1 ES_JAVA_OPTS="-Xms512m -Xmx512m" ./bin/elasticsearch

# Terminal 2
ES_PATH_CONF=/tmp/es-config/node-2 ES_JAVA_OPTS="-Xms512m -Xmx512m" ./bin/elasticsearch

# Terminal 3
ES_PATH_CONF=/tmp/es-config/node-3 ES_JAVA_OPTS="-Xms512m -Xmx512m" ./bin/elasticsearch
```

`ES_PATH_CONF` directs each startup to its own configuration directory while sharing the same binaries.

#### Step 6 — Verify Cluster Formation

```bash
curl http://localhost:9200/_cluster/health?pretty
```

**Expected output:**

```json
{
  "cluster_name" : "local-dev-cluster",
  "status" : "green",
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  ...
}
```

---

### Method 2 — Multiple TAR Installs (Fully Isolated)

For complete binary isolation, extract a separate copy of the archive for each node. This uses more disk space but mirrors how nodes would be managed on separate hosts.

```bash
tar -xzf elasticsearch-8.13.0-linux-x86_64.tar.gz -C /opt/es-node-1 --strip-components=1
tar -xzf elasticsearch-8.13.0-linux-x86_64.tar.gz -C /opt/es-node-2 --strip-components=1
tar -xzf elasticsearch-8.13.0-linux-x86_64.tar.gz -C /opt/es-node-3 --strip-components=1
```

Edit `config/elasticsearch.yml` within each extracted directory independently, then start each node:

```bash
# Terminal 1
/opt/es-node-1/bin/elasticsearch

# Terminal 2
/opt/es-node-2/bin/elasticsearch

# Terminal 3
/opt/es-node-3/bin/elasticsearch
```

---

### Method 3 — Docker Compose (Recommended for Local Multi-Node)

Docker Compose is the most practical approach for local multi-node clusters. Each node runs in its own container with full isolation of configuration, data, and network identity.

The following example creates a three-node cluster with security disabled.

**`docker-compose.yml`:**

```yaml
version: "3.8"

services:
  es01:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: es01
    environment:
      - node.name=es01
      - cluster.name=local-dev-cluster
      - discovery.seed_hosts=es02,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    ports:
      - "9200:9200"
    volumes:
      - esdata01:/usr/share/elasticsearch/data
    networks:
      - elastic
    healthcheck:
      test: ["CMD-SHELL", "curl -sf http://localhost:9200/_cluster/health || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 10

  es02:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: es02
    environment:
      - node.name=es02
      - cluster.name=local-dev-cluster
      - discovery.seed_hosts=es01,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    ports:
      - "9201:9200"
    volumes:
      - esdata02:/usr/share/elasticsearch/data
    networks:
      - elastic

  es03:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: es03
    environment:
      - node.name=es03
      - cluster.name=local-dev-cluster
      - discovery.seed_hosts=es01,es02
      - cluster.initial_master_nodes=es01,es02,es03
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    ports:
      - "9202:9200"
    volumes:
      - esdata03:/usr/share/elasticsearch/data
    networks:
      - elastic

volumes:
  esdata01:
    driver: local
  esdata02:
    driver: local
  esdata03:
    driver: local

networks:
  elastic:
    driver: bridge
```

**Start the cluster:**

```bash
docker compose up -d
```

**Watch cluster formation:**

```bash
docker compose logs -f
```

**Verify:**

```bash
curl http://localhost:9200/_cluster/health?pretty
curl http://localhost:9200/_cat/nodes?v
```

---

### Understanding Cluster Formation

When nodes start, they go through a sequence of steps before the cluster is operational:

#### Step 1 — Transport Layer Bind

Each node binds to its configured transport port (`9300`, `9301`, etc.) and begins listening for connections from other nodes.

#### Step 2 — Seed Host Contact

Each node attempts to contact the addresses listed in `discovery.seed_hosts`. This is how nodes find each other initially.

#### Step 3 — Master Election

Among the master-eligible nodes that have found each other, a master is elected. A quorum of `(n/2) + 1` master-eligible nodes must be reachable to elect a master.

| Number of Master-Eligible Nodes | Quorum Required |
|---|---|
| 1 | 1 |
| 2 | 2 |
| 3 | 2 |
| 5 | 3 |
| 7 | 4 |

> A two-node master-eligible cluster requires both nodes to be available to elect a master — it provides no fault tolerance for master election. Three nodes is the minimum recommended for meaningful quorum behavior.

#### Step 4 — Cluster State Publication

The elected master publishes the initial cluster state to all nodes.

#### Step 5 — Shard Allocation

The master allocates primary shards to data nodes and assigns replica shards to different nodes than their primaries.

---

### Observing the Cluster

Once the cluster is running, the following APIs are useful for observing its state.

#### Cluster Health

```bash
curl http://localhost:9200/_cluster/health?pretty
```

#### Node List

```bash
curl http://localhost:9200/_cat/nodes?v
```

**Example output:**

```
ip        heap.percent ram.percent cpu load_1m node.role master name
127.0.0.1           23          85   2    0.10 cdfhilmrstw *     node-1
127.0.0.1           18          85   1    0.10 cdfhilmrstw -     node-2
127.0.0.1           21          85   1    0.10 cdfhilmrstw -     node-3
```

The `*` in the `master` column identifies the elected master node.

#### Shard Allocation

```bash
curl http://localhost:9200/_cat/shards?v
```

#### Cluster State (Verbose)

```bash
curl http://localhost:9200/_cluster/state?pretty
```

---

### Simulating Node Failure

One of the primary reasons to run a multi-node cluster locally is to observe failure and recovery behavior.

#### Stop a Node (TAR)

```bash
# Send SIGTERM to the specific node process
kill <PID_OF_NODE_2>
```

#### Stop a Container (Docker)

```bash
docker stop es02
```

After stopping a node:

1. The cluster detects the missing node (after `discovery` timeout)
2. If the stopped node held primary shards, those primaries are promoted from replicas on surviving nodes
3. Cluster health transitions to `yellow` if replica shards are now unassigned (no remaining node to place them on)
4. Cluster health returns to `green` when the node rejoins and shards are reallocated

[Inference] Recovery timing depends on `cluster.fault_detection` settings, shard sizes, and available resources. Behavior may vary.

#### Restart the Stopped Node

```bash
# TAR — restart with same ES_PATH_CONF
ES_PATH_CONF=/tmp/es-config/node-2 ./bin/elasticsearch

# Docker
docker start es02
```

---

### Assigning Node Roles Locally

By default, each node is master-eligible, a data node, and an ingest node simultaneously. For testing role-separated topologies, roles can be assigned explicitly.

```yaml
# Dedicated master node
node.roles: [ master ]

# Dedicated data node
node.roles: [ data ]

# Coordinating only node (no roles assigned)
node.roles: []
```

**Example — role-separated local cluster:**

| Node | Roles | HTTP Port | Transport Port |
|---|---|---|---|
| node-1 | `master` | 9200 | 9300 |
| node-2 | `data` | 9201 | 9301 |
| node-3 | `data` | 9202 | 9302 |

> A cluster with only one master-eligible node has no master fault tolerance — the cluster becomes unavailable if that node stops. For local testing of master election, use at least three master-eligible nodes.

---

### Resource Considerations for Local Multi-Node

Running multiple Elasticsearch nodes on a single machine multiplies resource consumption.

| Resource | Per-Node Recommendation (Dev) | 3-Node Total |
|---|---|---|
| JVM Heap | 512 MB – 1 GB | 1.5 GB – 3 GB |
| RAM (total, including Lucene cache) | 1 – 2 GB | 3 – 6 GB |
| Disk | Depends on data volume | Multiply by node count |

Reduce heap to the minimum needed for local testing:

```bash
ES_JAVA_OPTS="-Xms256m -Xmx256m"
```

[Inference] Very small heap sizes (below 256 MB) may cause instability or GC overhead errors depending on the workload and Elasticsearch version. Behavior is not guaranteed at minimal heap sizes.

---

### Common Issues with Local Multi-Node Setups

| Symptom | Likely Cause | Resolution |
|---|---|---|
| Nodes do not join the cluster | `cluster.name` mismatch | Ensure all nodes share the same `cluster.name` |
| Master not elected | `cluster.initial_master_nodes` misconfigured or missing | Verify node names match exactly |
| `address already in use` error | Port conflict between nodes | Assign unique `http.port` and `transport.port` per node |
| Data corruption or startup errors | Shared `path.data` between nodes | Assign a unique data directory per node |
| Cluster stays `yellow` after all nodes start | Only one data node (no node for replicas) | Add more data nodes or set `number_of_replicas: 0` for dev indices |
| Nodes keep re-electing master | `cluster.initial_master_nodes` left in config after bootstrap | Remove or comment out after initial cluster formation |
| High memory usage | Heap too large for available RAM | Reduce `ES_JAVA_OPTS` heap values |
| Nodes cannot discover each other in Docker | Services on different networks | Ensure all containers share the same Docker network |

---

### Cleaning Up a Local Multi-Node Cluster

#### TAR

```bash
# Stop all node processes
kill <PID_NODE_1> <PID_NODE_2> <PID_NODE_3>

# Remove data and log directories
rm -rf /tmp/es-data /tmp/es-logs /tmp/es-config
```

#### Docker Compose

```bash
# Stop and remove containers
docker compose down

# Stop, remove containers, and delete volumes (removes all indexed data)
docker compose down -v
```

---

### Summary — Configuration Checklist for Local Multi-Node

| Setting | Requirement |
|---|---|
| `cluster.name` | Identical across all nodes |
| `node.name` | Unique per node |
| `http.port` | Unique per node |
| `transport.port` | Unique per node |
| `path.data` | Unique per node |
| `path.logs` | Unique per node (recommended) |
| `discovery.seed_hosts` | Lists transport addresses of all other nodes |
| `cluster.initial_master_nodes` | Lists names of master-eligible nodes — first boot only |
| `xpack.security.enabled` | Set to `false` for local dev (or configure TLS properly) |
| `ES_JAVA_OPTS` | Reduce heap to fit available local RAM |

---

**Conclusion**

Running multiple Elasticsearch nodes locally is straightforward once the core requirements — shared cluster name, unique node names, unique ports, unique data directories, and correct discovery configuration — are in place. Docker Compose is the most practical approach, providing isolation and repeatability with minimal configuration overhead. TAR-based multi-node setups offer more direct visibility into configuration and process management. Either approach is suitable for learning cluster behavior, testing shard allocation, and simulating failure and recovery scenarios that are impossible to observe on a single-node instance.

**Next Steps** — understanding shard allocation, replication mechanics, and cluster state management builds directly on the multi-node foundation established here.