Environment variables and JVM options
## Environment Variables and JVM Options

---

### Overview

Elasticsearch's runtime behavior is controlled through a combination of configuration files, environment variables, and JVM options. Understanding how these layers interact — and which takes precedence — is essential for consistent, predictable deployments across development, staging, and production environments.

---

### Environment Variables — Purpose and Scope

Environment variables in Elasticsearch serve two distinct purposes:

1. **Configuration overrides** — substituting or supplementing values in `elasticsearch.yml`
2. **Process-level control** — controlling the startup environment of the Elasticsearch JVM process itself

---

### Core Process Environment Variables

These variables are read by the Elasticsearch startup scripts before the JVM launches.

#### `ES_PATH_CONF`

Specifies the directory Elasticsearch reads its configuration files from.

```bash
export ES_PATH_CONF=/etc/elasticsearch
```

- If not set, Elasticsearch uses its default config directory based on installation method
- Overriding this allows multiple Elasticsearch instances on the same host to use separate configurations
- All configuration files (`elasticsearch.yml`, `jvm.options`, `log4j2.properties`) must be present in the specified directory

#### `ES_JAVA_HOME`

Specifies a custom JDK to use instead of the bundled JDK.

```bash
export ES_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

- If not set, Elasticsearch uses the JDK bundled with the distribution (recommended)
- If `JAVA_HOME` is set in the environment, Elasticsearch may fall back to it — behavior depends on version

[Inference] Using a custom JDK may introduce compatibility issues. The bundled JDK is tested against the specific Elasticsearch version. Using external JDKs is not guaranteed to produce identical behavior.

#### `ES_JAVA_OPTS`

Passes additional JVM flags to the Elasticsearch process. This is the primary mechanism for JVM tuning when not using `jvm.options` files directly — particularly relevant in Docker and Kubernetes environments.

```bash
export ES_JAVA_OPTS="-Xms4g -Xmx4g"
```

- Values set here are **appended** to options already defined in `jvm.options`
- Conflicts between `ES_JAVA_OPTS` and `jvm.options` entries may produce unpredictable results depending on the JVM flag involved

[Inference] JVM flag conflict behavior depends on the specific flags and the JVM implementation. Some flags are last-value-wins; others produce warnings or errors. Behavior is not guaranteed.

#### `ES_TMPDIR`

Sets the temporary directory used by the JVM and Elasticsearch internals.

```bash
export ES_TMPDIR=/tmp/elasticsearch
```

- Defaults to the system temp directory if not set
- Some Linux distributions mount `/tmp` with `noexec`, which can prevent Elasticsearch from running — setting `ES_TMPDIR` to a path without `noexec` resolves this

#### `ES_HEAP_SIZE` (Deprecated)

Previously used to set heap size. **Removed in Elasticsearch 6.x.** Use `ES_JAVA_OPTS` or `jvm.options` instead.

> Any documentation or script referencing `ES_HEAP_SIZE` is outdated.

#### `ES_GC_LOG_FILE` (Deprecated)

Previously configured GC log output path. Replaced by JVM argument-based GC logging configuration in modern versions.

---

### Setting Environment Variables by Install Method

#### APT (Debian/Ubuntu) — `/etc/default/elasticsearch`

```bash
# JVM options
ES_JAVA_OPTS="-Xms4g -Xmx4g"

# Custom config path
ES_PATH_CONF=/etc/elasticsearch

# Maximum open file descriptors
MAX_OPEN_FILES=65535

# Maximum locked memory (for bootstrap.memory_lock)
MAX_LOCKED_MEMORY=unlimited
```

This file is sourced by the systemd service unit at startup. It is the correct place to set persistent environment variables for package-based installs on Debian systems.

#### RPM (RHEL/CentOS/Fedora) — `/etc/sysconfig/elasticsearch`

```bash
ES_JAVA_OPTS="-Xms4g -Xmx4g"
ES_PATH_CONF=/etc/elasticsearch
MAX_OPEN_FILES=65535
MAX_LOCKED_MEMORY=unlimited
```

Same purpose as `/etc/default/elasticsearch` but located at the RPM-conventional path.

#### TAR Archive

Set environment variables in the shell before running the startup script, or in the shell's profile:

```bash
export ES_JAVA_OPTS="-Xms4g -Xmx4g"
export ES_PATH_CONF=/path/to/config
./bin/elasticsearch
```

#### Docker

Pass environment variables via `-e` flags or `environment:` in Docker Compose:

```bash
docker run -e "ES_JAVA_OPTS=-Xms2g -Xmx2g" \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

```yaml
# docker-compose.yml
services:
  elasticsearch:
    environment:
      - ES_JAVA_OPTS=-Xms2g -Xmx2g
      - discovery.type=single-node
```

---

### Overriding `elasticsearch.yml` Settings via Environment Variables

Any setting from `elasticsearch.yml` can be passed as an environment variable. The conversion rules are:

- Prefix with `ES_`
- Uppercase the entire key
- Replace `.` (dots) with `_` (underscores)

**Examples:**

| `elasticsearch.yml` | Environment Variable |
|---|---|
| `cluster.name` | `ES_CLUSTER_NAME` |
| `node.name` | `ES_NODE_NAME` |
| `network.host` | `ES_NETWORK_HOST` |
| `http.port` | `ES_HTTP_PORT` |
| `discovery.type` | `ES_DISCOVERY_TYPE` |
| `xpack.security.enabled` | `ES_XPACK_SECURITY_ENABLED` |

**Example — Docker Compose using only environment variables (no mounted `elasticsearch.yml`):**

```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    environment:
      - ES_CLUSTER_NAME=my-cluster
      - ES_NODE_NAME=node-1
      - ES_DISCOVERY_TYPE=single-node
      - ES_XPACK_SECURITY_ENABLED=false
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
```

[Inference] Not all `elasticsearch.yml` settings reliably map to environment variables — particularly list-type settings and complex nested structures. For these, mounting a configuration file is more reliable. Behavior may vary by version.

---

### Configuration Precedence (Full Order)

When the same setting is defined in multiple places, Elasticsearch resolves conflicts in this order (highest to lowest precedence):

```
1. Command-line arguments    (-E flag at startup)
2. Environment variables
3. elasticsearch.yml
4. Built-in defaults
```

**Example — command-line override:**

```bash
./bin/elasticsearch -E cluster.name=override-name -E node.name=override-node
```

This takes precedence over both environment variables and `elasticsearch.yml` values for those keys.

---

### JVM Options — Purpose and Scope

JVM options control the behavior of the Java Virtual Machine process that runs Elasticsearch. They affect:

- Memory allocation and garbage collection
- Performance tuning
- Diagnostic and logging behavior
- Security and runtime assertions

---

### How Elasticsearch Loads JVM Options

Elasticsearch does **not** use a single monolithic JVM options string. Instead, it processes options from:

1. `jvm.options` — the base file
2. `jvm.options.d/*.options` — all `.options` files in this directory, loaded in alphabetical order
3. `ES_JAVA_OPTS` — appended last

Options from `jvm.options.d/` override or extend options in `jvm.options` depending on the specific JVM flag semantics.

> For package installs, custom JVM options should always be placed in `jvm.options.d/` — not in `jvm.options` itself. This prevents custom settings from being overwritten during package upgrades.

---

### `jvm.options` File Syntax

```
# This is a comment

# Plain JVM flag (applies to all JVM versions)
-Xms4g

# Version-qualified flag
8:-Xmx4g          ← applies only to Java 8
8-:-Xmx4g         ← applies to Java 8 and later
8-17:-Xmx4g       ← applies to Java 8 through 17 inclusive
```

Lines that do not start with `-` or a version qualifier are ignored (treated as comments if starting with `#`, otherwise may produce a warning).

---

### Heap Size Configuration

Heap sizing is the most critical JVM configuration for Elasticsearch.

#### Setting Heap Size

```
-Xms4g
-Xmx4g
```

Or equivalently in bytes:

```
-Xms4294967296
-Xmx4294967296
```

#### Rules for Heap Sizing

**Rule 1 — `Xms` and `Xmx` must be equal**

Setting them to different values causes the JVM to resize the heap at runtime, introducing garbage collection pauses.

**Rule 2 — Do not exceed 50% of available RAM**

The remaining RAM is needed by the OS and Lucene's file system cache. Lucene performs better when it has access to substantial off-heap memory.

```
Host RAM: 32 GB
Maximum heap: 16 GB (50% rule)
```

**Rule 3 — Do not exceed ~30–31 GB**

The JVM uses **Compressed Ordinary Object Pointers (CompressedOops)** when the heap is below a threshold (approximately 32 GB, but the exact value varies by JVM implementation and platform). Above this threshold, object pointer size doubles, which can actually reduce effective memory efficiency.

```
# Safe upper boundary — verify with your specific JVM
-Xms30g
-Xmx30g
```

To verify whether CompressedOops is active:

```bash
java -Xmx30g -XX:+PrintFlagsFinal -version 2>&1 | grep UseCompressedOops
```

[Inference] The exact CompressedOops threshold varies by JVM build, OS, and platform. The ~30–31 GB figure is a widely cited guideline, not a guaranteed value. Always verify with the specific JVM in use.

**Rule 4 — Never allocate 100% of host RAM**

Leaving headroom for the OS, Lucene page cache, and other processes is essential. On a 64 GB host, setting heap to 60+ GB risks OS-level memory pressure.

#### Heap Size in Docker

In Docker environments, set heap size via `ES_JAVA_OPTS`:

```yaml
environment:
  - ES_JAVA_OPTS=-Xms2g -Xmx2g
```

Alternatively, Elasticsearch 8.x supports automatic heap sizing based on container memory limits when `ES_JAVA_OPTS` is not set. [Inference] Automatic heap sizing behavior depends on the specific version and container memory configuration. Verify against target version documentation before relying on this in production.

---

### Garbage Collection Configuration

Elasticsearch defaults to the **G1GC** (Garbage First Garbage Collector) for heap management on JDK 14 and later. Earlier versions may default differently.

#### Default G1GC Settings (from `jvm.options`)

```
## GC configuration
8-13:-XX:+UseConcMarkSweepGC
8-13:-XX:CMSInitiatingOccupancyFraction=75
8-13:-XX:+UseCMSInitiatingOccupancyOnly

## G1GC (JDK 14+)
14-:-XX:+UseG1GC
14-:-XX:G1ReservePercent=25
14-:-XX:InitiatingHeapOccupancyPercent=30
```

[Inference] Default GC settings are version-specific and may change between Elasticsearch releases. Always consult the `jvm.options` shipped with the specific version rather than assuming defaults.

#### GC Logging

GC logging is enabled by default in modern Elasticsearch versions:

```
## JDK 9+ GC logging
9-:-Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m
```

| Parameter | Meaning |
|---|---|
| `gc*` | All GC events |
| `gc+age=trace` | Object age information |
| `safepoint` | Safepoint events |
| `filecount=32` | Retain up to 32 log files |
| `filesize=64m` | Rotate at 64 MB per file |

GC logs are valuable for diagnosing memory pressure, long pauses, and heap exhaustion. They should be retained and monitored in production.

---

### JVM Temporary Directory

```
-Djava.io.tmpdir=${ES_TMPDIR}
```

This references the `ES_TMPDIR` environment variable. If `ES_TMPDIR` is not set, this resolves to the system temp directory.

---

### DNS Caching

By default, the JVM caches DNS lookups indefinitely for security reasons. Elasticsearch overrides this to support dynamic environments:

```
-Des.networkaddress.cache.ttl=60
-Des.networkaddress.cache.negative.ttl=10
```

| Setting | Default Override | Meaning |
|---|---|---|
| `networkaddress.cache.ttl` | 60 seconds | How long to cache successful DNS lookups |
| `networkaddress.cache.negative.ttl` | 10 seconds | How long to cache failed DNS lookups |

[Inference] These settings affect Elasticsearch's behavior in environments where service addresses change (e.g., Kubernetes). Tuning may be needed in specific networking configurations. Behavior is not guaranteed across all environments.

---

### Heap Dump Configuration

Elasticsearch configures the JVM to produce a heap dump when an `OutOfMemoryError` occurs:

```
-XX:+HeapDumpOnOutOfMemoryError
```

The dump is written to the Elasticsearch data directory by default. The path can be overridden:

```
-XX:HeapDumpPath=/path/to/heap/dumps
```

> Heap dumps can be very large (equal to the heap size). Ensure the target directory has sufficient disk space.

---

### Error Handling and JVM Exit on OOM

```
-XX:+ExitOnOutOfMemoryError
```

This causes the JVM to exit immediately on an `OutOfMemoryError` rather than continuing in a potentially inconsistent state. Elasticsearch includes this by default in modern versions.

[Inference] Whether to use `ExitOnOutOfMemoryError` or `HeapDumpOnOutOfMemoryError` (or both) depends on operational requirements. Both can be active simultaneously. Behavior on OOM may vary.

---

### Performance-Relevant JVM Flags

#### Disable JVM Performance Optimizations that Can Cause Issues

```
-XX:-OmitStackTraceInFastThrow
```

Prevents the JVM from omitting stack traces in frequently thrown exceptions — important for diagnosing issues in production.

#### Class Data Sharing (JDK 10+)

```
10-:-XX:+UseContainerSupport
```

Enables container-aware resource detection. Relevant when running inside Docker or other container runtimes.

[Inference] Container support behavior and its interaction with Elasticsearch's own resource detection may vary by JVM and container runtime version.

---

### Custom JVM Options — Recommended Approach

#### Step 1 — Create a file in `jvm.options.d/`

```bash
# For package installs
sudo nano /etc/elasticsearch/jvm.options.d/custom-heap.options
```

#### Step 2 — Add options

```
# Custom heap size
-Xms8g
-Xmx8g

# Custom heap dump path
-XX:HeapDumpPath=/var/lib/elasticsearch/heapdumps
```

#### Step 3 — Restart Elasticsearch

```bash
sudo systemctl restart elasticsearch
```

---

### Verifying Active JVM Settings

To inspect what JVM flags are actually active for a running Elasticsearch process:

```bash
# Get the Elasticsearch PID
ps aux | grep elasticsearch

# Print JVM flags for the running process
jcmd <PID> VM.flags
```

Alternatively, Elasticsearch exposes JVM information via the nodes info API:

```http
GET /_nodes/jvm
```

**Example response (truncated):**

```json
{
  "nodes": {
    "node-id": {
      "jvm": {
        "version": "17.0.10",
        "vm_name": "OpenJDK 64-Bit Server VM",
        "mem": {
          "heap_init_in_bytes": 4294967296,
          "heap_max_in_bytes": 4294967296
        },
        "gc_collectors": ["G1 Young Generation", "G1 Old Generation"]
      }
    }
  }
}
```

---

### Common Mistakes and How to Avoid Them

| Mistake | Consequence | Correct Approach |
|---|---|---|
| Setting `Xms` ≠ `Xmx` | Heap resizing pauses during GC | Always set both to the same value |
| Allocating >50% RAM to heap | Lucene cache starvation, OS memory pressure | Cap at 50% of host RAM |
| Exceeding ~31 GB heap | Loss of CompressedOops, reduced efficiency | Stay below the threshold; verify with the specific JVM |
| Editing `jvm.options` directly on package install | Settings overwritten on upgrade | Use `jvm.options.d/` instead |
| Using `ES_HEAP_SIZE` | Variable is ignored (removed in 6.x) | Use `ES_JAVA_OPTS` or `jvm.options` |
| Setting `ES_JAVA_OPTS` and `jvm.options` for same flag | Flag conflict, unpredictable behavior | Use one mechanism per flag |
| No heap dump path configured with limited disk on data path | Heap dump fills data disk on OOM | Set `HeapDumpPath` to a separate volume |

---

### Quick Reference — Key Environment Variables

| Variable | Purpose | Example |
|---|---|---|
| `ES_PATH_CONF` | Config directory path | `/etc/elasticsearch` |
| `ES_JAVA_OPTS` | Additional JVM flags | `-Xms4g -Xmx4g` |
| `ES_JAVA_HOME` | Custom JDK path | `/usr/lib/jvm/java-17` |
| `ES_TMPDIR` | JVM temp directory | `/tmp/elasticsearch` |

### Quick Reference — Key JVM Options

| Option | Purpose |
|---|---|
| `-Xms` / `-Xmx` | Initial and maximum heap size |
| `-XX:+UseG1GC` | Enable G1 garbage collector |
| `-XX:+HeapDumpOnOutOfMemoryError` | Write heap dump on OOM |
| `-XX:HeapDumpPath` | Destination for heap dumps |
| `-XX:+ExitOnOutOfMemoryError` | Exit JVM on OOM |
| `-XX:-OmitStackTraceInFastThrow` | Preserve stack traces |
| `-Xlog:gc*` | Enable GC logging |

---

**Conclusion**

Environment variables and JVM options are the primary mechanisms for configuring Elasticsearch's process-level behavior outside of `elasticsearch.yml`. Heap sizing is the most operationally significant JVM configuration — governed by the equal `Xms`/`Xmx` rule, the 50% RAM ceiling, and the CompressedOops threshold. For package installs, `jvm.options.d/` is the correct location for custom JVM settings. For containerized deployments, `ES_JAVA_OPTS` is the standard approach. Understanding the precedence order across all configuration layers prevents unexpected overrides and simplifies troubleshooting.

**Next Steps** — cluster configuration, shard allocation settings, and index lifecycle management build on the runtime foundation established here.