## Installing Elasticsearch on macOS

### Overview

Elasticsearch can be installed on macOS via several methods. macOS is supported for **development purposes**; it is not recommended for production deployments. The available installation methods are:

- **Homebrew** — package manager installation
- **Archive (tar.gz)** — manual installation from the official Elastic archive
- **Docker** — containerized installation

All methods install Elasticsearch 8.x, which has **security enabled by default**, including TLS and a generated password for the `elastic` superuser.

> Always verify the current version and checksum against [https://www.elastic.co/downloads/elasticsearch](https://www.elastic.co/downloads/elasticsearch) before installing.

---

### Prerequisites

#### Hardware

|Resource|Minimum (Development)|
|---|---|
|**CPU**|2 cores (Apple Silicon and Intel both supported)|
|**RAM**|4 GB available (8 GB+ recommended)|
|**Disk**|10 GB free space|

#### Software

|Requirement|Detail|
|---|---|
|**macOS version**|macOS 12 (Monterey) or later recommended|
|**Java**|Not required — bundled JDK is included|
|**Docker**|Required only for the Docker method|
|**Homebrew**|Required only for the Homebrew method|

#### Architecture

Both **Intel (x86_64)** and **Apple Silicon (ARM64 / aarch64)** are supported. Download the correct archive for your architecture when using the tar.gz method. Homebrew and Docker handle architecture selection automatically.

---

### Method 1 — Homebrew

Homebrew is the simplest installation method for macOS development environments.

#### Step 1 — Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify installation:

```bash
brew --version
```

#### Step 2 — Tap the Elastic Homebrew Repository

Elasticsearch is not in the default Homebrew core formulae. Elastic maintains its own tap:

```bash
brew tap elastic/tap
```

#### Step 3 — Install Elasticsearch

```bash
brew install elastic/tap/elasticsearch-full
```

This installs Elasticsearch along with its bundled JDK into Homebrew's prefix (typically `/opt/homebrew` on Apple Silicon or `/usr/local` on Intel).

#### Step 4 — Start Elasticsearch

**Start as a foreground process (development):**

```bash
elasticsearch
```

**Start as a background service:**

```bash
brew services start elastic/tap/elasticsearch-full
```

**Stop the service:**

```bash
brew services stop elastic/tap/elasticsearch-full
```

**Restart the service:**

```bash
brew services restart elastic/tap/elasticsearch-full
```

#### Step 5 — Retrieve the Auto-Generated Password

On first startup with security enabled, Elasticsearch outputs the auto-generated `elastic` user password to the terminal. If running as a service, retrieve it from the startup log or reset it manually:

```bash
/opt/homebrew/bin/elasticsearch-reset-password -u elastic
```

> The path may differ on Intel Macs. Verify with `brew --prefix elastic/tap/elasticsearch-full`.

#### Homebrew Installation Paths

|Item|Path (Apple Silicon)|
|---|---|
|**Elasticsearch home**|`/opt/homebrew/opt/elasticsearch-full`|
|**Config directory**|`/opt/homebrew/etc/elasticsearch`|
|**Data directory**|`/opt/homebrew/var/lib/elasticsearch`|
|**Log directory**|`/opt/homebrew/var/log/elasticsearch`|
|**Plugins directory**|`/opt/homebrew/var/elasticsearch/plugins`|

> On Intel Macs, replace `/opt/homebrew` with `/usr/local`.

---

### Method 2 — Archive (tar.gz)

The archive method gives full control over installation location and is useful when a specific version is required.

#### Step 1 — Download the Archive

Go to [https://www.elastic.co/downloads/elasticsearch](https://www.elastic.co/downloads/elasticsearch) and select the macOS package. Alternatively, download via `curl`:

**Apple Silicon (ARM64):**

```bash
curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.0-darwin-aarch64.tar.gz
```

**Intel (x86_64):**

```bash
curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.0-darwin-x86_64.tar.gz
```

> Replace `8.13.0` with the current stable version. Always check [https://www.elastic.co/downloads/elasticsearch](https://www.elastic.co/downloads/elasticsearch) for the latest version number.

#### Step 2 — Verify the SHA-512 Checksum

Download the checksum file:

**Apple Silicon:**

```bash
curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.0-darwin-aarch64.tar.gz.sha512
```

Verify:

```bash
shasum -a 512 -c elasticsearch-8.13.0-darwin-aarch64.tar.gz.sha512
```

**Expected output:**

```
elasticsearch-8.13.0-darwin-aarch64.tar.gz: OK
```

Do not proceed if the checksum does not match.

#### Step 3 — Extract the Archive

```bash
tar -xzf elasticsearch-8.13.0-darwin-aarch64.tar.gz
cd elasticsearch-8.13.0
```

#### Step 4 — Review the Directory Structure

```
elasticsearch-8.13.0/
├── bin/                  # Executable scripts
├── config/               # Configuration files
│   ├── elasticsearch.yml
│   ├── jvm.options
│   └── log4j2.properties
├── data/                 # Default data storage location
├── jdk.app/              # Bundled JDK (macOS app bundle)
├── lib/                  # Core library JARs
├── logs/                 # Default log location
├── modules/              # Built-in modules
└── plugins/              # Installed plugins (initially empty)
```

#### Step 5 — Configure Elasticsearch (Optional for Development)

For a minimal single-node development setup, the defaults are sufficient. Optionally review `config/elasticsearch.yml`:

```yaml
# config/elasticsearch.yml

# Cluster name
cluster.name: my-dev-cluster

# Node name
node.name: node-1

# Data and log paths (optional overrides)
# path.data: /path/to/data
# path.logs: /path/to/logs

# Network binding (default: localhost)
# network.host: localhost
```

#### Step 6 — Start Elasticsearch

```bash
./bin/elasticsearch
```

On first start, Elasticsearch outputs important information to the terminal:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Elasticsearch security features have been automatically configured!
✅ Authentication is enabled and cluster connections are encrypted.

ℹ️  Password for the elastic user (reset with `bin/elasticsearch-reset-password -u elastic`):
  pAssw0rd_example

ℹ️  HTTP CA certificate SHA-256 fingerprint:
  a1b2c3d4e5...

ℹ️  Configure Kibana to use this cluster:
  Run Kibana and click the configuration link in the terminal when Kibana starts.
  Enrollment token for Kibana (valid for the next 30 minutes):
  eyJ2ZXIiOiI4LjEzLjAiLCJhZHI...

ℹ️  Configure other nodes to join this cluster:
  Copy the following enrollment token and start new Elasticsearch nodes with
  `bin/elasticsearch --enrollment-token <token>`:
  eyJ2ZXIiOiI4LjEzLjAiLCJhZHI...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

> **Save this output immediately.** The auto-generated password and enrollment tokens are shown only once. If lost, the password can be reset using `bin/elasticsearch-reset-password -u elastic`.

#### Step 7 — Run as a Background Process (Optional)

To run in the background during development:

```bash
./bin/elasticsearch -d -p pid
```

- `-d` — daemonize (run in background)
- `-p pid` — write the process ID to a file named `pid`

To stop:

```bash
pkill -F pid
```

---

### Method 3 — Docker

Docker is useful for isolated, reproducible development environments on macOS.

#### Step 1 — Install Docker Desktop

Download and install Docker Desktop for Mac from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop). Docker Desktop supports both Intel and Apple Silicon.

Verify installation:

```bash
docker --version
```

#### Step 2 — Create a Docker Network

Creating a dedicated Docker network allows Elasticsearch and Kibana containers to communicate by hostname:

```bash
docker network create elastic
```

#### Step 3 — Pull the Elasticsearch Image

```bash
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

> Replace `8.13.0` with the desired version.

#### Step 4 — Start the Elasticsearch Container

```bash
docker run --name elasticsearch \
  --net elastic \
  -p 9200:9200 \
  -p 9300:9300 \
  -e "discovery.type=single-node" \
  -e "ELASTIC_PASSWORD=changeme" \
  -e "xpack.security.enabled=true" \
  -e "xpack.security.http.ssl.enabled=false" \
  -t \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

**Environment variables explained:**

|Variable|Purpose|
|---|---|
|`discovery.type=single-node`|Disables multi-node discovery for single-node dev setup|
|`ELASTIC_PASSWORD`|Sets the `elastic` user password directly|
|`xpack.security.enabled=true`|Keeps authentication enabled|
|`xpack.security.http.ssl.enabled=false`|Disables HTTPS for easier local development (HTTP only)|

> Disabling SSL (`xpack.security.http.ssl.enabled=false`) is acceptable for local development only. Never disable SSL in production or any environment exposed beyond localhost.

#### Step 5 — Verify the Container is Running

```bash
docker ps
```

#### Step 6 — Persist Data with a Volume (Recommended)

Without a volume, data is lost when the container is removed. Use a named volume for persistence:

```bash
docker run --name elasticsearch \
  --net elastic \
  -p 9200:9200 \
  -p 9300:9300 \
  -v elasticsearch-data:/usr/share/elasticsearch/data \
  -e "discovery.type=single-node" \
  -e "ELASTIC_PASSWORD=changeme" \
  -e "xpack.security.enabled=true" \
  -e "xpack.security.http.ssl.enabled=false" \
  -t \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

#### Docker Compose Alternative

For a more maintainable local setup:

```yaml
# docker-compose.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - ELASTIC_PASSWORD=changeme
      - xpack.security.enabled=true
      - xpack.security.http.ssl.enabled=false
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    networks:
      - elastic

volumes:
  elasticsearch-data:

networks:
  elastic:
    driver: bridge
```

Start:

```bash
docker compose up -d
```

Stop:

```bash
docker compose down
```

Stop and remove volumes:

```bash
docker compose down -v
```

---

### Verifying the Installation

Once Elasticsearch is running via any method, verify it is accessible.

#### With HTTPS (Homebrew or tar.gz default)

```bash
curl --cacert /path/to/http_ca.crt \
  -u elastic:YOUR_PASSWORD \
  https://localhost:9200
```

The CA certificate is located at:

- **tar.gz:** `config/certs/http_ca.crt`
- **Homebrew:** `/opt/homebrew/etc/elasticsearch/certs/http_ca.crt`

Alternatively, skip certificate verification for local development (not recommended for any shared environment):

```bash
curl -k -u elastic:YOUR_PASSWORD https://localhost:9200
```

#### With HTTP (Docker method with SSL disabled)

```bash
curl -u elastic:changeme http://localhost:9200
```

#### Expected Response

```json
{
  "name" : "node-1",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "abc123XYZ",
  "version" : {
    "number" : "8.13.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "lucene_version" : "9.10.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

#### Check Cluster Health

```bash
curl -u elastic:YOUR_PASSWORD https://localhost:9200/_cluster/health?pretty
```

**Expected output:**

```json
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0
}
```

> A single-node cluster will report `yellow` status if indices have replica shards configured (default is 1 replica), since replicas cannot be assigned when only one node exists. This is expected behavior in a single-node development setup.

---

### Common Post-Installation Tasks

#### Reset the elastic User Password

```bash
# tar.gz / Homebrew
./bin/elasticsearch-reset-password -u elastic

# Docker
docker exec -it elasticsearch \
  /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

#### Generate a New Kibana Enrollment Token

```bash
# tar.gz / Homebrew
./bin/elasticsearch-create-enrollment-token -s kibana

# Docker
docker exec -it elasticsearch \
  /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

#### Install a Plugin

```bash
# tar.gz / Homebrew
./bin/elasticsearch-plugin install analysis-icu

# Docker (plugins must be installed at image build time or via a custom Dockerfile)
```

#### View Logs

```bash
# tar.gz — logs are in the logs/ directory
tail -f logs/elasticsearch.log

# Homebrew service logs
tail -f /opt/homebrew/var/log/elasticsearch/elasticsearch.log

# Docker
docker logs -f elasticsearch
```

---

### macOS-Specific Considerations

#### Gatekeeper and Quarantine

macOS may quarantine downloaded binaries. If Elasticsearch fails to start due to Gatekeeper restrictions:

```bash
xattr -d com.apple.quarantine elasticsearch-8.13.0-darwin-aarch64.tar.gz
```

Or after extraction:

```bash
xattr -r -d com.apple.quarantine elasticsearch-8.13.0/
```

#### Memory Limits on macOS

macOS restricts the amount of memory a process can lock. The `bootstrap.memory_lock: true` setting [Inference] may not function as expected on macOS, unlike on Linux. For development purposes this is generally not a concern.

#### File Descriptor Limits

macOS imposes per-process file descriptor limits. For development, the defaults are typically sufficient. If hitting limits:

```bash
ulimit -n 65536
```

This applies only to the current shell session. Persistent configuration requires a `launchd` plist or `/etc/launchd.conf` modification.

#### Apple Silicon (M1/M2/M3)

Elasticsearch provides native ARM64 binaries for Apple Silicon. When using the tar.gz method, ensure the `darwin-aarch64` archive is downloaded rather than `darwin-x86_64`. Homebrew and Docker Desktop handle this automatically.

---

### Choosing an Installation Method

|Factor|Homebrew|tar.gz|Docker|
|---|---|---|---|
|**Ease of setup**|Easiest|Moderate|Easy|
|**Version control**|Homebrew-managed|Manual|Image tag|
|**Service management**|`brew services`|Manual / launchd|`docker` / Compose|
|**Data isolation**|Shared Homebrew paths|Contained in directory|Volume-isolated|
|**Multiple versions**|Difficult|Easy (separate directories)|Easy (separate containers)|
|**Cleanup**|`brew uninstall`|Delete directory|`docker rm` + volume removal|
|**Closest to production**|No|Moderate|Yes (if using official image)|

---

**Conclusion**

Elasticsearch on macOS is straightforward to install via Homebrew, archive, or Docker. For most local development workflows, Homebrew provides the fastest path to a running instance, while Docker offers better isolation and closer parity with containerized production environments. Regardless of method, capturing the auto-generated credentials on first startup, verifying the installation via the REST API, and understanding the default security configuration are the critical steps before proceeding to index and query data.

===END_SYLLABOT_RESPONSE_7be29025d26b4c6c===