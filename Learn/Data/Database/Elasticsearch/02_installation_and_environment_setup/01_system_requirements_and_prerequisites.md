## System Requirements and Prerequisites

### Scope

This section covers the hardware, software, operating system, and configuration prerequisites for deploying the Elastic Stack. Requirements are broken down per component. Where specific values are noted from Elastic's official documentation, they are presented as stated. Where estimates or recommendations extend beyond documented minimums, they are labeled accordingly.

> **Note:** Always verify current requirements against the [official Elastic support matrix](https://www.elastic.co/support/matrix) and release notes, as requirements change across versions. The values here are based on Elastic Stack 8.x unless otherwise stated.

---

### Java and the JVM

#### Elasticsearch and the Bundled JDK

Elasticsearch is written in Java and runs on the JVM. However, since **Elasticsearch 7.x**, Elastic bundles a **certified JDK** (currently based on **OpenJDK**) with each Elasticsearch release. This means:

- You do **not** need to install Java separately on the host.
- The bundled JDK is tested and certified for the specific Elasticsearch version it ships with.
- The bundled JDK is used by default unless overridden via `ES_JAVA_HOME`.

[Inference] Using the bundled JDK is strongly advisable in most deployments to avoid JVM compatibility issues — though teams with strict enterprise JVM standardization requirements may need to evaluate this carefully.

#### Logstash and Java

Logstash (written in JRuby on the JVM) also bundles a JDK starting from version **8.x**. For older versions, a separate JDK installation may be required. Check the specific Logstash version's documentation to confirm.

#### Kibana, Beats, and Elastic Agent

- **Kibana** is a **Node.js** application. It bundles its own Node.js runtime — no separate Node.js installation is required.
- **Beats** are compiled **Go** binaries — no runtime dependency required.
- **Elastic Agent** is also a Go-based binary — no runtime dependency required.

---

### Operating System Support

#### Supported Platforms (Elasticsearch 8.x)

Elastic maintains an official support matrix. As of Elastic Stack 8.x, supported operating systems include:

**Linux:**

- Red Hat Enterprise Linux (RHEL) / CentOS / Rocky Linux / AlmaLinux — 7, 8, 9
- Ubuntu — 18.04, 20.04, 22.04
- Debian — 10, 11, 12
- SUSE Linux Enterprise Server (SLES) — 12, 15
- Oracle Linux — 7, 8, 9
- Amazon Linux 2 and Amazon Linux 2023

**Windows:**

- Windows Server 2016, 2019, 2022
- Windows 10, 11 (primarily for development; production on Windows is less common)

**macOS:**

- Supported for development purposes
- Not recommended for production deployments

**Containers:**

- Official Docker images are published to **Docker Hub** and **Elastic's container registry**
- Kubernetes is supported via **Elastic Cloud on Kubernetes (ECK)**, the official Kubernetes operator

> [Unverified] Support for specific minor OS versions may change between Elastic Stack patch releases. Verify the current matrix at elastic.co/support/matrix before deployment.

#### Architecture Support

- **x86_64 (AMD64)** — fully supported across all components
- **ARM64 (aarch64)** — supported for Elasticsearch, Kibana, Beats, and Elastic Agent as of 8.x
- [Unverified] ARM64 support maturity may vary across specific integrations and plugins — verify for your specific use case.

---

### Hardware Requirements

#### Elasticsearch

Hardware requirements for Elasticsearch are highly workload-dependent. The following represent **minimum** and **recommended** baselines, not performance targets.

##### Minimum (Development / Single-Node)

|Resource|Minimum|
|---|---|
|**CPU**|2 cores|
|**RAM**|4 GB (2 GB heap + 2 GB OS file cache)|
|**Disk**|10 GB (SSD strongly preferred)|
|**Network**|1 Gbps|

##### Recommended (Production)

|Resource|Recommendation|
|---|---|
|**CPU**|8+ cores per node|
|**RAM**|64 GB per node (32 GB heap + 32 GB file cache)|
|**Disk**|SSD or NVMe; capacity based on data volume × replication factor|
|**Network**|10 Gbps between nodes|

**Key Points**

- Elasticsearch heap size should be set to **no more than 50% of available RAM**, and **no more than 32 GB** (to stay within the JVM's compressed ordinary object pointer — compressed OOP — threshold).
- The remaining RAM is used by Lucene for the OS file system cache, which is critical for search performance.
- Setting heap above 32 GB can [Inference] degrade performance due to loss of compressed OOPs, though the exact threshold may vary slightly by JVM version and platform.

##### Disk Considerations

|Factor|Guidance|
|---|---|
|**Storage type**|SSD or NVMe strongly preferred; spinning disk may be acceptable for cold/frozen tiers|
|**RAID**|RAID 0 is acceptable (Elasticsearch replication handles redundancy); RAID 5/6 not recommended due to write penalty|
|**Capacity planning**|Account for: raw data size × (1 + number of replicas) × indexing overhead (~10–15%)|
|**Disk watermarks**|Elasticsearch stops allocating shards at 85% disk usage by default (`cluster.routing.allocation.disk.watermark.low`)|

##### Node Roles and Hardware Profiles

Different node roles benefit from different hardware profiles:

|Node Role|CPU|RAM|Disk|
|---|---|---|---|
|**Master**|Low-moderate|4–16 GB|Minimal (no data)|
|**Data (hot)**|High|32–64 GB|Fast SSD/NVMe|
|**Data (warm)**|Moderate|16–32 GB|SSD or large HDD|
|**Data (cold/frozen)**|Low|8–16 GB|High-capacity HDD or object storage|
|**Coordinating only**|High|16–32 GB|Minimal|
|**Ingest**|High (CPU-bound)|16–32 GB|Minimal|
|**ML**|High (CPU or GPU)|32+ GB|Minimal|

#### Kibana

|Resource|Minimum|Recommended|
|---|---|---|
|**CPU**|2 cores|4+ cores|
|**RAM**|2 GB|4–8 GB|
|**Disk**|1 GB|Minimal (Kibana stores state in Elasticsearch)|

- Kibana is stateless; its persistent state is stored in a system index in Elasticsearch (`.kibana*`).
- Memory requirements increase with concurrent users and complex dashboard rendering. [Inference]

#### Logstash

|Resource|Minimum|Recommended|
|---|---|---|
|**CPU**|2 cores|4–8 cores|
|**RAM**|2 GB|4–8 GB|
|**Disk**|1 GB|Based on persistent queue size|
|**JVM Heap**|1 GB|4–8 GB (default is 1 GB; tunable)|

- Logstash is CPU- and memory-intensive, especially with complex filter pipelines.
- Persistent queue storage requirements depend on configured `queue.max_bytes`.

#### Beats

Individual Beats are lightweight Go binaries designed for minimal host impact:

|Beat|Typical RAM|Typical CPU|
|---|---|---|
|**Filebeat**|50–100 MB|Very low|
|**Metricbeat**|50–100 MB|Low|
|**Packetbeat**|100–200 MB|Low–moderate (packet capture)|
|**Winlogbeat**|50–100 MB|Very low|
|**Auditbeat**|50–100 MB|Low|
|**Heartbeat**|50–100 MB|Low|

> [Unverified] Exact resource consumption depends on the volume of data being processed, number of inputs configured, and enabled processors. Values above are general guidance, not guarantees.

#### Elastic Agent

Elastic Agent's footprint is similar to individual Beats but slightly higher as it manages sub-processes:

|Resource|Typical|
|---|---|
|**RAM**|200–500 MB (varies by active integrations)|
|**CPU**|Low baseline; scales with data volume|
|**Disk**|Minimal for agent binaries; plus any local buffer|

---

### Network Requirements

#### Port Reference

|Component|Default Port|Protocol|Purpose|
|---|---|---|---|
|Elasticsearch|9200|HTTP/HTTPS|REST API|
|Elasticsearch|9300|TCP|Inter-node transport (internal cluster)|
|Kibana|5601|HTTP/HTTPS|Web UI|
|Logstash|5044|TCP|Beats input (Lumberjack protocol)|
|Logstash|9600|HTTP|Logstash monitoring API|
|Fleet Server|8220|HTTPS|Agent enrollment and communication|
|Elastic Agent|Ephemeral|Outbound|Connects to Fleet Server|
|APM Server|8200|HTTP/HTTPS|APM data intake|

#### Network Topology Considerations

- Elasticsearch inter-node transport (port 9300) should be on a **private network** not exposed externally.
- REST API (port 9200) should be restricted by firewall or reverse proxy in production.
- Fleet Server must be **reachable from all Elastic Agent hosts** on port 8220.
- [Inference] In multi-datacenter or cross-region deployments, network latency between Elasticsearch nodes can affect cluster stability and replication performance — low-latency private networking is advisable.

---

### System Configuration Prerequisites

These are OS-level settings that Elasticsearch requires or strongly recommends. Elasticsearch performs bootstrap checks on startup and will **refuse to start** (in production mode) if critical settings are not met.

#### File Descriptor Limits

Elasticsearch uses a large number of file descriptors for network connections and file handles.

```bash
# /etc/security/limits.conf
elasticsearch soft nofile 65535
elasticsearch hard nofile 65535
```

Elastic recommends a minimum of **65,536** open file descriptors.

#### Virtual Memory — `vm.max_map_count`

Elasticsearch uses **memory-mapped files** (mmap) for Lucene segment files. The OS must allow sufficient memory map areas.

```bash
# Set temporarily
sysctl -w vm.max_map_count=262144

# Set permanently in /etc/sysctl.conf
vm.max_map_count=262144
```

This is one of the most common reasons Elasticsearch fails to start in containerized environments. Docker and Kubernetes deployments must set this on the **host**, not just inside the container.

#### Disable Swap

Memory swapping is highly detrimental to Elasticsearch performance and can cause JVM pauses and instability.

**Option 1 — Disable swap entirely:**

```bash
swapoff -a
# Comment out swap entries in /etc/fstab for persistence
```

**Option 2 — Reduce swappiness:**

```bash
sysctl -w vm.swappiness=1
```

**Option 3 — Enable `bootstrap.memory_lock` in Elasticsearch config:**

```yaml
# elasticsearch.yml
bootstrap.memory_lock: true
```

This instructs the JVM to lock heap memory and prevent it from being swapped. It requires the `memlock` ulimit to be set to `unlimited`:

```bash
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited
```

> [Inference] `bootstrap.memory_lock: true` combined with swappiness reduction is a commonly recommended combination for production deployments, though the appropriate approach depends on the OS and deployment environment.

#### Thread Count

Elasticsearch uses thread pools extensively. The OS must allow sufficient threads per process.

```bash
# /etc/security/limits.conf
elasticsearch soft nproc 4096
elasticsearch hard nproc 4096
```

#### TCP Retransmission Timeout (Linux)

For clusters with nodes across higher-latency links, the default TCP retransmission timeout may cause false node failures. Elastic recommends:

```bash
sysctl -w net.ipv4.tcp_retries2=5
```

> [Unverified] The appropriate value depends on network characteristics. This setting affects all TCP connections on the host, not just Elasticsearch.

#### Transparent Huge Pages (THP)

**Transparent Huge Pages** can cause memory allocation latency spikes and should be disabled for Elasticsearch hosts:

```bash
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
```

To persist across reboots, add to a system startup script or use a tuned profile.

---

### JVM Heap Configuration

#### Setting Heap Size

Heap size is configured via **JVM options**, not `elasticsearch.yml`. The recommended method in 8.x is using the `jvm.options.d` directory:

```bash
# /etc/elasticsearch/jvm.options.d/heap.options
-Xms16g
-Xmx16g
```

**Key rules:**

- Set `-Xms` and `-Xmx` to the **same value** to avoid heap resizing at runtime.
- Do not exceed **50% of available system RAM**.
- Do not exceed **32 GB** (compressed OOP threshold).
- Heap can also be set via environment variable: `ES_JAVA_OPTS="-Xms16g -Xmx16g"` (though the options file method is preferred).

#### GC Selection

Elasticsearch 8.x uses **G1GC** (Garbage First Garbage Collector) by default for most heap sizes. For very large heaps, ZGC may be considered but [Unverified] official recommendations should be verified in the current Elasticsearch documentation before changing GC settings.

---

### Docker and Kubernetes Prerequisites

#### Docker

When running Elasticsearch in Docker, the following host-level settings must still be applied:

```bash
# On the Docker host
sysctl -w vm.max_map_count=262144
```

Official Elastic Docker images are available at:

- `docker.elastic.co/elasticsearch/elasticsearch:<version>`
- `docker.elastic.co/kibana/kibana:<version>`
- `docker.elastic.co/logstash/logstash:<version>`
- `docker.elastic.co/beats/filebeat:<version>`
- `docker.elastic.co/elastic-agent/elastic-agent:<version>`

#### Kubernetes — Elastic Cloud on Kubernetes (ECK)

ECK is the official Kubernetes operator for managing the Elastic Stack.

**Prerequisites for ECK:**

|Requirement|Detail|
|---|---|
|**Kubernetes version**|1.27+ recommended (verify current ECK compatibility matrix)|
|**kubectl**|Configured with cluster-admin or appropriate RBAC permissions|
|**Storage class**|A default or specified `StorageClass` for persistent volumes|
|**vm.max_map_count**|Must be set on all Kubernetes nodes running Elasticsearch pods|
|**Resource quotas**|Namespaces hosting Elasticsearch pods must have sufficient CPU/memory quota|

**Example ECK Elasticsearch resource:**

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: production
spec:
  version: 8.13.0
  nodeSets:
    - name: default
      count: 3
      config:
        node.store.allow_mmap: true
      podTemplate:
        spec:
          initContainers:
            - name: sysctl
              securityContext:
                privileged: true
              command: ['sh', '-c', 'sysctl -w vm.max_map_count=262144']
          containers:
            - name: elasticsearch
              resources:
                requests:
                  memory: 16Gi
                  cpu: 4
                limits:
                  memory: 16Gi
```

---

### Security Prerequisites

#### TLS/SSL

In Elasticsearch 8.x, **TLS is enabled by default** for both:

- **HTTP layer** (client-to-node communication)
- **Transport layer** (inter-node communication)

For new clusters, Elasticsearch auto-generates certificates on first startup. For production, certificates should be:

- Issued by a trusted CA (internal or public)
- Generated using the `elasticsearch-certutil` tool
- Rotated before expiry

#### User Authentication

Elasticsearch 8.x ships with the **Elastic security** model enabled by default. On first startup, a superuser password for the `elastic` built-in user is generated and displayed once in the terminal output.

Built-in users include:

|User|Purpose|
|---|---|
|`elastic`|Superuser|
|`kibana_system`|Internal Kibana-to-Elasticsearch communication|
|`logstash_system`|Logstash monitoring|
|`beats_system`|Beats monitoring|
|`apm_system`|APM Server monitoring|
|`remote_monitoring_user`|Metricbeat monitoring collection|

#### Enrollment Tokens

Kibana and additional Elasticsearch nodes can be enrolled into a cluster using **enrollment tokens**, generated by the first Elasticsearch node:

```bash
# Generate Kibana enrollment token
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

# Generate node enrollment token
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node
```

Tokens are time-limited (default 30 minutes).

---

### Pre-installation Checklist

|Item|Check|
|---|---|
|OS version in Elastic support matrix|✓|
|`vm.max_map_count` set to 262144|✓|
|Swap disabled or swappiness minimized|✓|
|File descriptor limit ≥ 65535|✓|
|Thread limit configured|✓|
|Transparent Huge Pages disabled|✓|
|Heap sized correctly (≤50% RAM, ≤32 GB)|✓|
|Required ports open in firewall|✓|
|TLS certificates prepared (production)|✓|
|Sufficient disk space with growth headroom|✓|
|NTP/time synchronization configured across nodes|✓|
|Dedicated user account for Elasticsearch process|✓|

> **Note on time synchronization:** Elasticsearch nodes rely on consistent system time for cluster coordination. Significant clock skew between nodes can [Inference] cause cluster instability. NTP or equivalent time synchronization is strongly advisable on all nodes.

---

**Conclusion**

System requirements for the Elastic Stack span hardware sizing, OS-level kernel configuration, JVM tuning, network design, and security setup. Many deployment failures — particularly in containerized environments — trace back to missing kernel settings such as `vm.max_map_count` or insufficient file descriptor limits. Addressing these prerequisites before installation reduces operational friction significantly. Hardware sizing, particularly for Elasticsearch data nodes, should always be based on actual workload profiling rather than minimum specifications alone, as requirements vary considerably with data volume, query patterns, and retention policies.

===END_SYLLABOT_RESPONSE_7be29025d26b4c6c===