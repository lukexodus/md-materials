## Installing Elasticsearch on Linux

---

### Prerequisites

Before installing Elasticsearch, confirm the following requirements are met.

#### Java

Elasticsearch bundles its own JDK. As of **Elasticsearch 8.x**, a separate Java installation is **not required** — the bundled JDK is used by default. If a `JAVA_HOME` environment variable is set, Elasticsearch may use that instead.

[Inference] Behavior around `JAVA_HOME` detection may vary by version and distribution method. Verify the specific version's documentation if custom JVM configuration is needed.

#### System Requirements

| Requirement | Notes |
|---|---|
| OS | Linux (64-bit) |
| RAM | Minimum 2 GB available; 4 GB+ recommended for development |
| Disk | Sufficient for data volume; SSDs strongly preferred for production |
| File descriptors | Elasticsearch requires a high limit (65,535 recommended) |
| Virtual memory | `vm.max_map_count` must be at least `262144` |
| User | Should run as a non-root dedicated user |

> Elasticsearch will **refuse to start** as the `root` user by default. This is a deliberate security constraint.

---

### Installation Methods on Linux

There are four primary methods for installing Elasticsearch on Linux:

| Method | Best For |
|---|---|
| APT (Debian/Ubuntu) | Debian-based distributions |
| RPM (RHEL/CentOS/Fedora) | Red Hat-based distributions |
| TAR archive | Any Linux distribution; manual control |
| Docker | Containerized environments |

This document covers APT, RPM, and TAR. Docker installation is a separate topic.

---

### Method 1 — APT (Debian / Ubuntu)

#### Step 1 — Import the GPG Key

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
  sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
```

#### Step 2 — Add the Repository

```bash
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] \
  https://artifacts.elastic.co/packages/8.x/apt stable main" | \
  sudo tee /etc/apt/sources.list.d/elastic-8.x.list
```

#### Step 3 — Install

```bash
sudo apt-get update && sudo apt-get install elasticsearch
```

#### Step 4 — Reload and Enable the Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
```

#### Step 5 — Verify

```bash
sudo systemctl status elasticsearch
```

---

### Method 2 — RPM (RHEL / CentOS / Fedora)

#### Step 1 — Import the GPG Key

```bash
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```

#### Step 2 — Create the Repository File

```bash
sudo tee /etc/yum.repos.d/elasticsearch.repo <<EOF
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
```

#### Step 3 — Install

```bash
sudo dnf install elasticsearch
# or on older systems:
sudo yum install elasticsearch
```

#### Step 4 — Enable and Start

```bash
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
```

#### Step 5 — Verify

```bash
sudo systemctl status elasticsearch
```

---

### Method 3 — TAR Archive (Any Distribution)

This method installs Elasticsearch without a package manager, giving full control over placement and configuration.

#### Step 1 — Download the Archive

```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.0-linux-x86_64.tar.gz
```

> Replace `8.13.0` with the target version. Always verify the download URL against the [official Elastic downloads page](https://www.elastic.co/downloads/elasticsearch).

#### Step 2 — Verify the Checksum (Recommended)

```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.0-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-8.13.0-linux-x86_64.tar.gz.sha512
```

#### Step 3 — Extract

```bash
tar -xzf elasticsearch-8.13.0-linux-x86_64.tar.gz
cd elasticsearch-8.13.0/
```

#### Step 4 — Run

```bash
./bin/elasticsearch
```

The TAR installation does not integrate with `systemd` by default. Running as a foreground process is typical for development use.

---

### First-Time Startup — Security Auto-Configuration (Elasticsearch 8.x)

When Elasticsearch 8.x starts for the **first time**, it automatically:

- Enables **TLS** for HTTP and transport layers
- Generates a built-in **`elastic` superuser password**
- Outputs enrollment tokens for Kibana and additional nodes

The generated password and enrollment token are printed to the terminal **only once** at first startup. They should be copied immediately.

**Example output (truncated):**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Elasticsearch security features have been automatically configured!
...
The generated password for the elastic built-in superuser is:
  <YOUR_GENERATED_PASSWORD>

The enrollment token for Kibana instances, valid for the next 30 minutes:
  <ENROLLMENT_TOKEN>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

> If this output is missed, the password can be reset using:
> ```bash
> sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
> ```

---

### Verifying the Installation

Once running, send a request to the default HTTP port (`9200`). With security enabled (default in 8.x), HTTPS and credentials are required:

```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:<YOUR_PASSWORD> \
  https://localhost:9200
```

**Expected output:**

```json
{
  "name" : "node-1",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "abc123...",
  "version" : {
    "number" : "8.13.0",
    ...
  },
  "tagline" : "You Know, for Search"
}
```

---

### Key Configuration Files

After installation via APT or RPM, configuration files are located at:

| File | Purpose |
|---|---|
| `/etc/elasticsearch/elasticsearch.yml` | Main configuration (cluster, node, network, paths) |
| `/etc/elasticsearch/jvm.options` | JVM heap and garbage collection settings |
| `/etc/elasticsearch/log4j2.properties` | Logging configuration |

For TAR installs, these files are located under the extracted directory at `config/`.

---

### Essential `elasticsearch.yml` Settings

The following settings are commonly configured at installation time:

```yaml
# Cluster name — all nodes in a cluster must share this value
cluster.name: my-cluster

# Node name — unique per node
node.name: node-1

# Path to data directory
path.data: /var/lib/elasticsearch

# Path to log directory
path.logs: /var/log/elasticsearch

# Network host — set to 0.0.0.0 to accept external connections
# Leave as 127.0.0.1 for single-node development
network.host: 127.0.0.1

# HTTP port
http.port: 9200

# Discovery — single-node mode for development
discovery.type: single-node
```

> Setting `network.host` to anything other than `localhost` activates **bootstrap checks**, which enforce production-level system configuration. This is intentional behavior.

---

### System Configuration for Production

When `network.host` is set to a non-loopback address, Elasticsearch performs **bootstrap checks** at startup. The following system settings are commonly required:

#### File Descriptor Limit

```bash
# Add to /etc/security/limits.conf
elasticsearch  -  nofile  65535
```

#### Virtual Memory — `vm.max_map_count`

```bash
# Apply immediately (does not persist across reboots)
sudo sysctl -w vm.max_map_count=262144

# Persist across reboots
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### Disable Swap

Elasticsearch documentation strongly advises disabling swap to avoid JVM heap being swapped to disk, which severely degrades performance:

```bash
# Disable swap immediately
sudo swapoff -a

# Permanently disable — comment out swap entries in /etc/fstab
```

Alternatively, set `bootstrap.memory_lock: true` in `elasticsearch.yml` and configure the OS to allow memory locking for the `elasticsearch` user.

[Inference] The impact of swap on performance depends on workload and available RAM. Disabling swap entirely may not be appropriate in all environments. Behavior varies by system configuration.

---

### JVM Heap Configuration

Elasticsearch's JVM heap is configured in `jvm.options` or via `jvm.options.d/`:

```
-Xms4g
-Xmx4g
```

**Key rules:**

- Set `-Xms` and `-Xmx` to the **same value** to avoid heap resizing overhead
- Do not allocate more than **50% of available RAM** to the heap — the other half is needed for the Lucene file system cache
- Do not exceed **~30–31 GB** — above this threshold, the JVM may lose compressed ordinary object pointer (OOP) optimization

[Inference] The 50% rule and 30 GB ceiling are widely documented recommendations. Actual optimal heap size depends on workload characteristics and is not guaranteed to apply uniformly across all use cases.

---

### Running as a systemd Service

For APT and RPM installs, `systemd` integration is included. Common commands:

```bash
# Start
sudo systemctl start elasticsearch

# Stop
sudo systemctl stop elasticsearch

# Restart
sudo systemctl restart elasticsearch

# View logs
sudo journalctl -u elasticsearch --since "10 minutes ago"

# Enable at boot
sudo systemctl enable elasticsearch
```

---

### Checking Logs

Elasticsearch logs are written to the path specified in `path.logs`. For package installs, this is typically `/var/log/elasticsearch/`.

```bash
# Tail the main cluster log
sudo tail -f /var/log/elasticsearch/elasticsearch.log
```

Log entries include cluster state changes, shard allocation events, errors, and deprecation warnings.

---

### Disabling Security for Development (Not Recommended for Production)

To simplify local development, security features can be disabled by adding to `elasticsearch.yml`:

```yaml
xpack.security.enabled: false
```

> This disables TLS and authentication entirely. It should **never** be used in any environment accessible over a network or exposed to untrusted users.

---

### Common Installation Issues

| Symptom | Likely Cause | Resolution |
|---|---|---|
| `max virtual memory areas vm.max_map_count [65530] is too low` | `vm.max_map_count` not set | Set to `262144` via `sysctl` |
| `max file descriptors [4096] for elasticsearch process is too low` | `nofile` limit not raised | Update `/etc/security/limits.conf` |
| Service fails to start as root | Running as root user | Create a dedicated `elasticsearch` user |
| Port 9200 not responding | Service not started or bound to wrong interface | Check `network.host` and service status |
| Password not saved from first startup | Output missed at boot | Reset using `elasticsearch-reset-password` |

---

**Conclusion**

Elasticsearch can be installed on Linux via APT, RPM, or TAR archive, each suited to different distribution and operational requirements. The 8.x security defaults — automatic TLS and password generation — represent a significant change from earlier versions and require attention during first-time setup. Correct system-level configuration (file descriptors, virtual memory, heap sizing, and swap) is essential before moving any Elasticsearch node into a production role.

**Next Steps** — configuring a multi-node cluster, connecting Kibana, and understanding index lifecycle management build directly on this installation foundation.