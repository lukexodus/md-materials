Docker and Docker Compose setup
## Docker and Docker Compose Setup

---

### Overview

Running Elasticsearch in Docker is common for local development, testing, and containerized production deployments. Elastic publishes official Docker images for Elasticsearch, and Docker Compose is the standard tool for orchestrating multi-container setups that include Elasticsearch alongside Kibana or other components of the Elastic Stack.

---

### Prerequisites

| Requirement | Notes |
|---|---|
| Docker Engine | 20.10.10 or later recommended |
| Docker Compose | V2 (`docker compose`) preferred over legacy V1 (`docker-compose`) |
| RAM | At least 4 GB allocated to Docker Desktop (macOS/Windows); on Linux, host RAM is used directly |
| `vm.max_map_count` | Must be `262144` on Linux hosts (same requirement as bare-metal installs) |

#### Setting `vm.max_map_count` on Linux

```bash
sudo sysctl -w vm.max_map_count=262144
```

To persist across reboots:

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

> On **macOS** and **Windows** with Docker Desktop, this setting applies inside the Linux VM that Docker Desktop runs — it does not need to be set on the host OS directly. [Inference] Behavior may vary by Docker Desktop version.

---

### Official Elasticsearch Docker Image

Elastic publishes images to two registries:

| Registry | Image |
|---|---|
| Elastic Registry | `docker.elastic.co/elasticsearch/elasticsearch:<version>` |
| Docker Hub | `elasticsearch:<version>` |

The Elastic registry image is the canonical source and is preferred.

**Example** — pulling the image:

```bash
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

> Replace `8.13.0` with the target version. Always pin to an explicit version tag in any persistent setup — avoid using `latest`.

---

### Single-Node Container — Development Setup

The simplest way to run Elasticsearch locally is a single container with security disabled for ease of use during development.

```bash
docker run -d \
  --name elasticsearch \
  -p 9200:9200 \
  -p 9300:9300 \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

| Flag | Purpose |
|---|---|
| `-d` | Run in detached (background) mode |
| `-p 9200:9200` | HTTP API port |
| `-p 9300:9300` | Transport port (inter-node communication) |
| `discovery.type=single-node` | Disables multi-node discovery |
| `xpack.security.enabled=false` | Disables TLS and authentication |
| `ES_JAVA_OPTS` | Sets JVM heap size |

**Verify:**

```bash
curl http://localhost:9200
```

> Security is disabled in this example for development convenience only. It should **never** be used in a network-accessible or production environment.

---

### Single-Node Container — With Security Enabled

To run a single-node container with security enabled (closer to production behavior):

```bash
docker run -d \
  --name elasticsearch \
  -p 9200:9200 \
  -e "discovery.type=single-node" \
  -e "ELASTIC_PASSWORD=changeme" \
  -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

**Verify with credentials:**

```bash
curl -u elastic:changeme --cacert <path-to-http_ca.crt> https://localhost:9200
```

The CA certificate can be copied from the running container:

```bash
docker cp elasticsearch:/usr/share/elasticsearch/config/certs/http_ca.crt .
```

---

### Persisting Data with Volumes

By default, data inside a Docker container is lost when the container is removed. Use a named volume or bind mount to persist Elasticsearch data.

#### Named Volume

```bash
docker run -d \
  --name elasticsearch \
  -p 9200:9200 \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  -v esdata:/usr/share/elasticsearch/data \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

Docker manages the volume at a system path. Inspect it with:

```bash
docker volume inspect esdata
```

#### Bind Mount

```bash
docker run -d \
  --name elasticsearch \
  -p 9200:9200 \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  -v /path/on/host:/usr/share/elasticsearch/data \
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

> The host directory must be writable by UID `1000`, which is the user Elasticsearch runs as inside the container.

```bash
sudo chown -R 1000:1000 /path/on/host
```

---

### Docker Compose — Elasticsearch Only

For repeatable setups, Docker Compose is preferable to long `docker run` commands.

**`docker-compose.yml`:**

```yaml
version: "3.8"

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - esdata:/usr/share/elasticsearch/data

volumes:
  esdata:
    driver: local
```

**Start:**

```bash
docker compose up -d
```

**Stop:**

```bash
docker compose down
```

**Stop and remove volumes:**

```bash
docker compose down -v
```

---

### Docker Compose — Elasticsearch and Kibana

A common local stack pairs Elasticsearch with Kibana. The following setup disables security for simplicity.

**`docker-compose.yml`:**

```yaml
version: "3.8"

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ports:
      - "9200:9200"
    volumes:
      - esdata:/usr/share/elasticsearch/data
    networks:
      - elastic

  kibana:
    image: docker.elastic.co/kibana/kibana:8.13.0
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    networks:
      - elastic

volumes:
  esdata:
    driver: local

networks:
  elastic:
    driver: bridge
```

**Key points:**

- Kibana connects to Elasticsearch using the **service name** (`elasticsearch`) as the hostname — Docker's internal DNS resolves this within the shared network
- `depends_on` instructs Docker Compose to start Elasticsearch before Kibana, but does **not** wait for Elasticsearch to be ready — a health check is needed for strict ordering
- Both services share the `elastic` network

**Access:**

| Service | URL |
|---|---|
| Elasticsearch | `http://localhost:9200` |
| Kibana | `http://localhost:5601` |

---

### Docker Compose — With Health Checks

`depends_on` alone does not prevent Kibana from attempting to connect before Elasticsearch is fully ready. A health check addresses this:

```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ports:
      - "9200:9200"
    volumes:
      - esdata:/usr/share/elasticsearch/data
    networks:
      - elastic
    healthcheck:
      test: ["CMD-SHELL", "curl -sf http://localhost:9200/_cluster/health || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 10

  kibana:
    image: docker.elastic.co/kibana/kibana:8.13.0
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
    depends_on:
      elasticsearch:
        condition: service_healthy
    networks:
      - elastic

volumes:
  esdata:
    driver: local

networks:
  elastic:
    driver: bridge
```

The `condition: service_healthy` directive instructs Compose to wait until the health check passes before starting Kibana.

[Inference] Health check timing values (`interval`, `timeout`, `retries`) may need adjustment based on host performance and available resources. The values above are illustrative. Behavior is not guaranteed to be identical across all environments.

---

### Multi-Node Cluster with Docker Compose

The following example sets up a three-node Elasticsearch cluster with security disabled, suitable for testing distributed behavior locally.

```yaml
version: "3.8"

services:
  es01:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: es01
    environment:
      - node.name=es01
      - cluster.name=es-docker-cluster
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

  es02:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: es02
    environment:
      - node.name=es02
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    volumes:
      - esdata02:/usr/share/elasticsearch/data
    networks:
      - elastic

  es03:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    container_name: es03
    environment:
      - node.name=es03
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01,es02
      - cluster.initial_master_nodes=es01,es02,es03
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
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

**Key settings explained:**

| Setting | Purpose |
|---|---|
| `node.name` | Unique identifier for each node |
| `cluster.name` | Must match across all nodes in the cluster |
| `discovery.seed_hosts` | Other nodes to contact during discovery |
| `cluster.initial_master_nodes` | Bootstraps master election on first cluster formation only |

> `cluster.initial_master_nodes` should be set **only for initial cluster bootstrap**. It should be removed from the configuration after the cluster is formed to avoid issues on restart. [Inference] Leaving this setting in place after initial bootstrap may cause problems in some versions; behavior varies.

---

### Passing Custom Configuration Files

Rather than using environment variables, a custom `elasticsearch.yml` can be bind-mounted into the container:

```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.13.0
    volumes:
      - ./config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      - esdata:/usr/share/elasticsearch/data
```

The mounted file replaces the default configuration. All required settings must be present in the custom file — it is not merged with the default.

---

### Environment Variable Precedence

Elasticsearch configuration can be set via:

1. `elasticsearch.yml` (file)
2. Environment variables passed to the container

Environment variables take precedence over `elasticsearch.yml` values. Setting the same key in both places will result in the environment variable winning.

[Inference] This precedence behavior is documented by Elastic but may have edge cases depending on the version and configuration key. Behavior is not guaranteed across all settings.

---

### Useful Docker Commands

```bash
# View running containers
docker ps

# View Elasticsearch logs
docker logs elasticsearch

# Follow logs in real time
docker logs -f elasticsearch

# Open a shell inside the container
docker exec -it elasticsearch bash

# Check cluster health from inside the container
docker exec -it elasticsearch curl http://localhost:9200/_cluster/health

# Stop a container
docker stop elasticsearch

# Remove a container
docker rm elasticsearch

# Remove volume
docker volume rm esdata
```

---

### Common Issues and Resolutions

| Symptom | Likely Cause | Resolution |
|---|---|---|
| Container exits immediately | `vm.max_map_count` too low | Set to `262144` on Linux host |
| `max virtual memory areas` error in logs | Same as above | Same resolution |
| Kibana cannot connect to Elasticsearch | Wrong `ELASTICSEARCH_HOSTS` value or network mismatch | Confirm both services share the same Docker network and use the service name as hostname |
| Data lost after `docker compose down` | No volume defined | Add a named volume for `/usr/share/elasticsearch/data` |
| Port 9200 already in use | Another process or container using the port | Change the host-side port mapping (e.g., `9201:9200`) |
| OOM (out of memory) container kill | Heap too large for available Docker memory | Reduce `ES_JAVA_OPTS` heap or increase Docker memory allocation |
| `bootstrap checks failed` | `network.host` set to non-loopback in a single-node container without `discovery.type=single-node` | Add `discovery.type=single-node` or correct network settings |

---

### Production Considerations for Docker

Docker is widely used for Elasticsearch in production but requires additional attention:

- **Do not run Elasticsearch as root inside the container** — the official image handles this correctly by default
- **Use named volumes or external storage** — container-local storage is ephemeral
- **Set explicit resource limits** — use Docker's `--memory` and `--cpus` flags or Compose `deploy.resources` to prevent a single container from consuming all host resources
- **Pin image versions** — never use `latest` in any persistent or production deployment
- **Separate data and configuration volumes** — allows configuration updates without touching data
- **Monitor container health** — integrate with your existing monitoring stack

[Inference] Production Docker deployments for Elasticsearch at scale are often managed via Kubernetes or Elastic Cloud on Kubernetes (ECK). Docker Compose is generally considered more suitable for development and small-scale deployments. Suitability depends on operational requirements.

---

**Conclusion**

Docker and Docker Compose provide a fast, reproducible way to run Elasticsearch locally and in containerized environments. Single-node setups with security disabled serve well for development. Multi-node Compose configurations allow local testing of distributed cluster behavior. For production Docker deployments, persistent volumes, health checks, resource limits, and pinned image versions are essential considerations.

**Next Steps** — understanding Elasticsearch's cluster architecture and node roles builds naturally on the multi-node patterns introduced here.