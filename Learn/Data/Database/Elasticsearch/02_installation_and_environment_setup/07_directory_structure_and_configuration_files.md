Directory structure and configuration files
## Directory Structure and Configuration Files

---

### Overview

Elasticsearch's directory layout and configuration files differ depending on the installation method used. Understanding where files live, what each configuration file controls, and how settings interact is essential for managing, tuning, and troubleshooting any Elasticsearch deployment.

---

### Directory Layouts by Installation Method

#### APT / RPM Package Install

When installed via a package manager, Elasticsearch follows Linux filesystem conventions, distributing files across standard system directories.

| Directory / Path | Purpose |
|---|---|
| `/etc/elasticsearch/` | Configuration files |
| `/var/lib/elasticsearch/` | Data directory (default) |
| `/var/log/elasticsearch/` | Log files |
| `/usr/share/elasticsearch/` | Application binaries, libraries, modules, plugins |
| `/usr/share/elasticsearch/bin/` | Executable scripts (`elasticsearch`, `elasticsearch-plugin`, etc.) |
| `/usr/share/elasticsearch/lib/` | JAR libraries |
| `/usr/share/elasticsearch/modules/` | Built-in modules |
| `/usr/share/elasticsearch/plugins/` | Installed plugins |
| `/etc/default/elasticsearch` (Debian) | Environment variable overrides |
| `/etc/sysconfig/elasticsearch` (RPM) | Environment variable overrides |
| `/usr/lib/systemd/system/elasticsearch.service` | systemd service unit file |

#### TAR Archive Install

The TAR install is self-contained. All files reside within the extracted directory.

```
elasticsearch-8.13.0/
├── bin/
├── config/
│   ├── elasticsearch.yml
│   ├── jvm.options
│   ├── jvm.options.d/
│   ├── log4j2.properties
│   ├── role_mapping.yml
│   ├── roles.yml
│   ├── users
│   ├── users_roles
│   └── certs/          ← generated on first start (8.x)
├── data/
├── lib/
├── logs/
├── modules/
└── plugins/
```

#### Docker Install

Inside the official Elasticsearch Docker container:

| Path | Purpose |
|---|---|
| `/usr/share/elasticsearch/` | Application root |
| `/usr/share/elasticsearch/config/` | Configuration files |
| `/usr/share/elasticsearch/data/` | Data directory (mount a volume here) |
| `/usr/share/elasticsearch/logs/` | Log files |
| `/usr/share/elasticsearch/plugins/` | Installed plugins |
| `/usr/share/elasticsearch/bin/` | Executables |

---

### The `config/` Directory in Detail

The configuration directory contains all files that control Elasticsearch's runtime behavior.

```
/etc/elasticsearch/          (package install)
/usr/share/elasticsearch/config/   (Docker / TAR)
├── elasticsearch.yml
├── jvm.options
├── jvm.options.d/
│   └── (custom .options files)
├── log4j2.properties
├── role_mapping.yml
├── roles.yml
├── users
├── users_roles
└── certs/
    ├── http_ca.crt
    ├── http.p12
    └── transport.p12
```

---

### `elasticsearch.yml`

This is the primary configuration file. It uses **YAML** syntax and controls all major aspects of node and cluster behavior.

#### Cluster Settings

```yaml
# Name shared by all nodes in the cluster
cluster.name: production-cluster
```

All nodes with the same `cluster.name` on the same network will attempt to join each other. Nodes with different cluster names will not join.

#### Node Settings

```yaml
# Unique name for this node
node.name: node-1

# Node roles (explicit assignment)
node.roles: [ master, data, ingest ]
```

Omitting `node.roles` allows Elasticsearch to assign default roles. Explicit role assignment is recommended for production clusters.

#### Path Settings

```yaml
# One or more data directories
path.data: /var/lib/elasticsearch

# Log directory
path.logs: /var/log/elasticsearch
```

Multiple data paths are supported:

```yaml
path.data:
  - /mnt/disk1/elasticsearch
  - /mnt/disk2/elasticsearch
```

> As of Elasticsearch 8.x, multiple data paths are deprecated in favor of RAID or volume management at the OS level. [Unverified: removal timeline; verify against target version documentation.]

#### Memory Settings

```yaml
# Lock JVM heap in RAM — prevents swapping
bootstrap.memory_lock: true
```

Requires the OS to permit memory locking for the Elasticsearch process. Without the corresponding OS-level configuration, this setting will cause a bootstrap check failure.

#### Network Settings

```yaml
# Address to bind to for HTTP and transport
network.host: 192.168.1.10

# Separate HTTP and transport bind addresses (optional)
http.host: 0.0.0.0
transport.host: 192.168.1.10

# HTTP port
http.port: 9200

# Transport port (inter-node communication)
transport.port: 9300
```

> Setting `network.host` to anything other than `127.0.0.1` or `localhost` activates all **bootstrap checks**. This is intentional — it signals that the node is being prepared for a networked (potentially production) environment.

#### Discovery Settings

```yaml
# Seed hosts for initial cluster discovery
discovery.seed_hosts:
  - 192.168.1.10
  - 192.168.1.11
  - 192.168.1.12

# Initial master nodes — used only for first-time cluster bootstrap
cluster.initial_master_nodes:
  - node-1
  - node-2
  - node-3
```

> `cluster.initial_master_nodes` must be removed or commented out after the cluster has formed. Leaving it in place on subsequent restarts can interfere with master election in some versions. [Inference] Exact behavior on restart with this setting present may vary by version.

#### Single-Node Development Mode

```yaml
discovery.type: single-node
```

Disables the need for discovery configuration and bypasses quorum requirements. Suitable only for single-node development instances.

#### Security Settings (8.x defaults)

```yaml
xpack.security.enabled: true

xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12

xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
```

These settings are auto-generated on first startup in Elasticsearch 8.x. Manual modification is possible but requires corresponding certificate management.

#### Gateway Settings

```yaml
# Minimum number of master-eligible nodes that must join before
# the cluster recovers after a full restart
gateway.recover_after_nodes: 2
```

#### Index Settings (Node-Level Defaults)

```yaml
# Default number of shards for new indices
# (Only applies if not specified at index creation)
# Note: This setting was removed in 7.x — use index templates instead
```

[Inference] Node-level index defaults have been progressively removed in favor of index templates. The mechanism available depends on the version in use.

---

### `jvm.options`

Controls JVM behavior for the Elasticsearch process. Elasticsearch uses a specific loading mechanism for this file.

#### Heap Size

```
-Xms4g
-Xmx4g
```

- `-Xms` — initial heap size
- `-Xmx` — maximum heap size
- These should always be set to the **same value**

#### GC Logging (Example)

```
## GC logging
-Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m
```

#### JVM Temp Directory

```
-Djava.io.tmpdir=${ES_TMPDIR}
```

#### Important Behavioral Notes

- The `jvm.options` file is processed **line by line**
- Lines beginning with `#` are comments
- Lines beginning with a version qualifier apply only to matching JVM versions:

```
8:-Xmx4g        ← applies only to Java 8
8-:-Xmx4g       ← applies to Java 8 and later
8-9:-Xmx4g      ← applies to Java 8 and 9 only
```

#### `jvm.options.d/` Directory

Custom JVM options should be placed in separate `.options` files within `jvm.options.d/` rather than editing `jvm.options` directly. This is the recommended approach for package installs, as it survives upgrades.

**Example** — `/etc/elasticsearch/jvm.options.d/heap.options`:

```
-Xms8g
-Xmx8g
```

[Inference] Options files in `jvm.options.d/` are loaded in alphabetical order. Conflicting settings across files may produce unexpected results. Behavior may vary by version.

---

### `log4j2.properties`

Controls Elasticsearch's logging behavior via **Apache Log4j 2**.

#### Default Log Output

By default, Elasticsearch logs to:
- A **rolling file** in the logs directory
- The **console** (stdout), which is captured by systemd or Docker

#### Key Configuration Sections

```properties
# Root logger level
rootLogger.level = info

# Main cluster log file
appender.rolling.type = RollingFile
appender.rolling.name = rolling
appender.rolling.fileName = ${sys:es.logs.base_path}${sys:file.separator}${sys:es.logs.cluster_name}.log
appender.rolling.filePattern = ${sys:es.logs.base_path}${sys:file.separator}${sys:es.logs.cluster_name}-%d{yyyy-MM-dd}-%i.log.gz

# Rollover policy
appender.rolling.policies.time.type = TimeBasedTriggeringPolicy
appender.rolling.policies.time.interval = 1
appender.rolling.policies.size.type = SizeBasedTriggeringPolicy
appender.rolling.policies.size.size = 256MB
```

#### Log Levels

Valid log levels in order of verbosity:

```
TRACE → DEBUG → INFO → WARN → ERROR → FATAL
```

**Example** — raising log level for a specific component:

```properties
logger.index_search_slowlog_rolling.level = trace
```

> Increasing log verbosity (especially to `DEBUG` or `TRACE`) can generate very large log volumes and may affect performance. [Inference] Impact varies by workload.

#### Slow Log Configuration

Elasticsearch has dedicated slow logs for indexing and search operations. These are configured separately within `log4j2.properties` and through index-level settings (covered under index management topics).

---

### `role_mapping.yml`

Used with the **file-based realm** for mapping external roles (e.g., from LDAP or PKI) to Elasticsearch roles. This file is relevant only when using certain authentication realms.

```yaml
superuser:
  - "cn=admins,dc=example,dc=com"

kibana_admin:
  - "cn=analysts,dc=example,dc=com"
```

[Inference] This file is only active when the file-based role mapping realm is configured. Behavior and format may vary depending on the security realm in use.

---

### `roles.yml`

Defines custom roles for the **native file-based security realm**. Not commonly used in modern deployments, which manage roles through the Kibana UI or roles API.

```yaml
my_custom_role:
  cluster:
    - monitor
  indices:
    - names:
        - "logs-*"
      privileges:
        - read
```

---

### `users` and `users_roles`

Plain-text files used by the **file-based user authentication realm**.

- `users` — stores usernames and bcrypt-hashed passwords
- `users_roles` — maps usernames to roles

These files are managed via the `elasticsearch-users` command-line tool rather than being edited directly.

```bash
# Add a user
bin/elasticsearch-users useradd myuser -p mypassword -r viewer

# List users
bin/elasticsearch-users list
```

---

### Environment Variable Configuration Files

#### Debian-based (APT): `/etc/default/elasticsearch`

```bash
# JVM options override
ES_JAVA_OPTS="-Xms4g -Xmx4g"

# Custom config directory
ES_PATH_CONF=/etc/elasticsearch

# Set startup timeout
MAX_OPEN_FILES=65535
```

#### RPM-based: `/etc/sysconfig/elasticsearch`

Same purpose and format as `/etc/default/elasticsearch`, but located at the RPM-conventional path.

These files are sourced by the systemd service unit before starting Elasticsearch. They allow environment-level configuration without modifying the systemd unit file directly.

---

### Configuration via Environment Variables

Any `elasticsearch.yml` setting can be overridden using environment variables. The convention is:

- Uppercase the setting name
- Replace `.` with `_`
- Prefix with `ES_`

**Example:**

| `elasticsearch.yml` setting | Environment variable |
|---|---|
| `cluster.name` | `ES_CLUSTER_NAME` |
| `node.name` | `ES_NODE_NAME` |
| `network.host` | `ES_NETWORK_HOST` |

This is the standard approach when configuring Elasticsearch via Docker or Kubernetes.

[Inference] Not all settings map cleanly to environment variables — complex nested or list-type settings may require YAML file configuration. Behavior may vary by setting and version.

---

### Configuration Precedence Order

When the same setting appears in multiple places, Elasticsearch resolves it in the following order (highest precedence first):

```
1. Command-line arguments (-E flag)
2. Environment variables
3. elasticsearch.yml
4. Default values
```

**Example** — overriding cluster name at startup:

```bash
./bin/elasticsearch -E cluster.name=override-cluster
```

---

### The `bin/` Directory

The `bin/` directory contains executable scripts for managing Elasticsearch and its security configuration.

| Script | Purpose |
|---|---|
| `elasticsearch` | Start the Elasticsearch node |
| `elasticsearch-plugin` | Install, list, and remove plugins |
| `elasticsearch-keystore` | Manage the secure settings keystore |
| `elasticsearch-certutil` | Generate TLS certificates |
| `elasticsearch-users` | Manage file-realm users |
| `elasticsearch-reset-password` | Reset built-in user passwords |
| `elasticsearch-node` | Node management and unsafe operations |
| `elasticsearch-shard` | Shard-level diagnostics and recovery tools |
| `elasticsearch-sql-cli` | Interactive SQL command-line interface |

---

### The Secure Settings Keystore

Sensitive values (passwords, API keys, credentials) should not be stored in `elasticsearch.yml` in plaintext. Elasticsearch provides a **keystore** for this purpose.

```bash
# Create the keystore (if it does not exist)
bin/elasticsearch-keystore create

# Add a secure setting
bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password

# List keystore entries
bin/elasticsearch-keystore list

# Remove an entry
bin/elasticsearch-keystore remove xpack.security.transport.ssl.keystore.secure_password
```

Keystore values are read at startup and are not written to disk in plaintext. The keystore file is located at:

- APT/RPM: `/etc/elasticsearch/elasticsearch.keystore`
- TAR/Docker: `config/elasticsearch.keystore`

[Inference] Keystore values cannot be reloaded without a node restart in most cases, though some settings support hot-reload via the reload secure settings API. Behavior depends on the specific setting and version.

---

### The `modules/` and `plugins/` Directories

#### `modules/`

Built-in functionality bundled with Elasticsearch. These are not optional — they are part of the core distribution and are loaded automatically.

Examples: `x-pack-core`, `lang-painless`, `transport-netty4`, `analysis-common`

Do not modify the `modules/` directory manually.

#### `plugins/`

Optional extensions installed separately via `elasticsearch-plugin install`. Each plugin is a subdirectory containing its JAR files and a `plugin-descriptor.properties` file.

```bash
# Install a plugin
bin/elasticsearch-plugin install analysis-icu

# List installed plugins
bin/elasticsearch-plugin list

# Remove a plugin
bin/elasticsearch-plugin remove analysis-icu
```

> Plugins must be installed on **every node** in the cluster and require a **node restart** to take effect.

---

### Summary Reference

| File / Directory | Location (Package) | Purpose |
|---|---|---|
| `elasticsearch.yml` | `/etc/elasticsearch/` | Primary node and cluster configuration |
| `jvm.options` | `/etc/elasticsearch/` | JVM heap and runtime settings |
| `jvm.options.d/` | `/etc/elasticsearch/` | Custom JVM option overrides |
| `log4j2.properties` | `/etc/elasticsearch/` | Logging behavior |
| `elasticsearch.keystore` | `/etc/elasticsearch/` | Secure (encrypted) settings storage |
| `certs/` | `/etc/elasticsearch/` | TLS certificates (auto-generated in 8.x) |
| `data/` | `/var/lib/elasticsearch/` | Index data |
| `logs/` | `/var/log/elasticsearch/` | Cluster and component logs |
| `bin/` | `/usr/share/elasticsearch/bin/` | Management scripts |
| `plugins/` | `/usr/share/elasticsearch/plugins/` | Optional installed plugins |
| `modules/` | `/usr/share/elasticsearch/modules/` | Built-in core modules |

---

**Conclusion**

Elasticsearch's configuration is distributed across several files, each with a distinct scope — cluster and node behavior in `elasticsearch.yml`, JVM tuning in `jvm.options`, logging in `log4j2.properties`, and security in the keystore and certificate files. Understanding the layout for the specific installation method in use — package, TAR, or Docker — is a prerequisite for reliable configuration management, troubleshooting, and upgrade procedures.

**Next Steps** — cluster configuration, node roles, and index lifecycle management build directly on the settings and paths established here.