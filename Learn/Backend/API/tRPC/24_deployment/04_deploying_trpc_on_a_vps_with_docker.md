## Deploying tRPC on a VPS with Docker

A VPS deployment gives full control over the execution environment — no platform-imposed timeouts, no cold starts, no serverless constraints. Docker standardizes the runtime across development, staging, and production, and Docker Compose orchestrates multi-container setups (app, database, reverse proxy, monitoring) on a single host.

---

### Architecture Overview

A typical single-VPS tRPC deployment:

```mermaid
flowchart TD
    Client -->|HTTPS :443| Caddy
    Caddy -->|HTTP :3000| tRPC["tRPC App Container"]
    tRPC --> Postgres["PostgreSQL Container"]
    tRPC --> Redis["Redis Container"]
    Caddy -->|/metrics scrape| Prometheus["Prometheus Container"]
    Prometheus --> Grafana["Grafana Container"]
    tRPC -->|traces| Jaeger["Jaeger Container"]
```

Caddy acts as the reverse proxy, handles TLS termination automatically via Let's Encrypt, and forwards traffic to the tRPC application container over the internal Docker network.

---

### Project Structure

```
project/
├── src/
│   ├── server.ts
│   ├── trpc/
│   │   ├── router.ts
│   │   └── context.ts
│   └── lib/
│       └── db.ts
├── docker/
│   ├── Caddyfile
│   └── prometheus.yml
├── Dockerfile
├── docker-compose.yml
├── docker-compose.prod.yml
├── .dockerignore
├── package.json
└── tsconfig.json
```

---

### Application Server

```ts
// src/server.ts
import express from 'express';
import http from 'http';
import { createExpressMiddleware } from '@trpc/server/adapters/express';
import { applyWSSHandler } from '@trpc/server/adapters/ws';
import { WebSocketServer } from 'ws';
import cors from 'cors';
import { appRouter } from './trpc/router';
import { createContext } from './trpc/context';
import { db } from './lib/db';

const app = express();

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') ?? [],
  credentials: true,
}));

app.use(express.json({ limit: '10mb' }));

app.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

app.use('/trpc', createExpressMiddleware({
  router: appRouter,
  createContext,
  onError({ error, path }) {
    if (error.code === 'INTERNAL_SERVER_ERROR') {
      console.error(JSON.stringify({
        level: 'error',
        msg: 'Internal tRPC error',
        path,
        error: error.message,
        stack: error.stack,
      }));
    }
  },
}));

const server = http.createServer(app);

const wss = new WebSocketServer({ server });
const wssHandler = applyWSSHandler({
  wss,
  router: appRouter,
  createContext,
});

const PORT = parseInt(process.env.PORT ?? '3000', 10);

server.listen(PORT, '0.0.0.0', () => {
  console.log(JSON.stringify({
    level: 'info',
    msg: `tRPC server listening`,
    port: PORT,
    pid: process.pid,
  }));
});

async function shutdown(signal: string) {
  console.log(JSON.stringify({ level: 'info', msg: `Received ${signal}` }));

  wssHandler.broadcastReconnectNotification();

  server.close(async () => {
    await db.$disconnect();
    process.exit(0);
  });

  setTimeout(() => {
    console.error(JSON.stringify({ level: 'error', msg: 'Forced shutdown' }));
    process.exit(1);
  }, 15_000);
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
```

---

### Dockerfile

```dockerfile
# Dockerfile
FROM node:20-alpine AS base
WORKDIR /app
RUN apk add --no-cache tini

# ── Dependency layer ──────────────────────────────────────────────────────────
FROM base AS deps
COPY package*.json ./
RUN npm ci

# ── Build layer ───────────────────────────────────────────────────────────────
FROM base AS build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build       # tsc → dist/
RUN npm run db:generate # prisma generate (if using Prisma)

# ── Production deps only ──────────────────────────────────────────────────────
FROM base AS prod-deps
COPY package*.json ./
RUN npm ci --omit=dev

# ── Final image ───────────────────────────────────────────────────────────────
FROM base AS runner
ENV NODE_ENV=production

# Non-root user for reduced attack surface
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=prod-deps --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/node_modules/.prisma ./node_modules/.prisma
COPY --chown=appuser:appgroup package.json ./

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/server.js"]
```

**Key Points:**
- Multi-stage build keeps the final image free of TypeScript compiler, source files, and dev dependencies
- Non-root user (`appuser`) reduces the blast radius of a container compromise
- `tini` as PID 1 correctly forwards signals and reaps zombie processes — without it, `SIGTERM` may not reach the Node.js process
- `HEALTHCHECK` lets Docker and Compose know when the container is genuinely ready versus just running

---

### `.dockerignore`

```
node_modules
dist
.env*
.git
*.md
docker/
coverage/
.nyc_output/
*.log
```

Excluding `node_modules` and `dist` prevents stale local artifacts from entering the build context and keeps build context transfer fast.

---

### Docker Compose — Development

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      target: build          # use build stage for hot reload
    command: npx ts-node-dev --respawn --transpile-only src/server.ts
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: development
      PORT: 3000
      DATABASE_URL: postgresql://trpc:trpc@postgres:5432/trpcdb
      REDIS_URL: redis://redis:6379
    volumes:
      - .:/app                # mount source for hot reload
      - /app/node_modules     # exclude host node_modules
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: trpc
      POSTGRES_PASSWORD: trpc
      POSTGRES_DB: trpcdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U trpc -d trpcdb"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

**Key Points:**
- `condition: service_healthy` delays app startup until the database passes its healthcheck — prevents connection errors on first boot
- Volume mounting source code with `- .:/app` enables hot reload without rebuilding the image
- The anonymous volume `/app/node_modules` shadows the host's `node_modules` inside the container, preventing platform-incompatible binaries from leaking in

---

### Docker Compose — Production

Production uses the `runner` stage (final image), environment variables from a secrets file, and adds the reverse proxy and observability stack:

```yaml
# docker-compose.prod.yml
services:
  app:
    build:
      context: .
      target: runner
    restart: unless-stopped
    environment:
      NODE_ENV: production
      PORT: 3000
      DATABASE_URL: ${DATABASE_URL}
      REDIS_URL: ${REDIS_URL}
      SENTRY_DSN: ${SENTRY_DSN}
      ALLOWED_ORIGINS: ${ALLOWED_ORIGINS}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - internal
      - proxy
    logging:
      driver: json-file
      options:
        max-size: "50m"
        max-file: "5"

  caddy:
    image: caddy:2-alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"    # HTTP/3
    volumes:
      - ./docker/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - proxy
    logging:
      driver: json-file
      options:
        max-size: "20m"
        max-file: "3"

  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - internal
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - internal
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  prometheus:
    image: prom/prometheus:latest
    restart: unless-stopped
    volumes:
      - ./docker/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - internal
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=30d'

  grafana:
    image: grafana/grafana:latest
    restart: unless-stopped
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
      GF_SERVER_ROOT_URL: https://${DOMAIN}/grafana
      GF_SERVER_SERVE_FROM_SUB_PATH: "true"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - internal
      - proxy
    depends_on:
      - prometheus

networks:
  internal:
    driver: bridge
    internal: true     # no external internet access from this network
  proxy:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
  caddy_data:
  caddy_config:
  prometheus_data:
  grafana_data:
```

**Key Points:**
- `internal: true` on the `internal` network means database and cache containers cannot make outbound internet connections — they can only communicate with other containers on that network
- The `app` container is on both networks: `internal` (to reach postgres/redis) and `proxy` (to be reachable by Caddy)
- `restart: unless-stopped` restarts containers after crashes or host reboots, but respects explicit `docker compose stop` calls
- Log rotation via `json-file` driver options prevents unbounded log growth on the host

---

### Caddy Configuration

Caddy handles TLS certificate issuance and renewal via Let's Encrypt automatically:

```
# docker/Caddyfile
{
  email admin@example.com
  admin off
}

api.example.com {
  # Reverse proxy tRPC app
  reverse_proxy /trpc/* app:3000

  # WebSocket upgrade support — Caddy handles this automatically
  # for connections with Upgrade: websocket header

  # Expose Grafana at /grafana subpath
  reverse_proxy /grafana* grafana:3000

  # Protect metrics endpoint from public access
  handle /metrics {
    respond 404
  }

  # Security headers
  header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"
    Referrer-Policy "strict-origin-when-cross-origin"
    -Server
  }

  # Access logging
  log {
    output file /var/log/caddy/access.log {
      roll_size 50mb
      roll_keep 5
    }
    format json
  }
}
```

Caddy automatically:
- Obtains a TLS certificate from Let's Encrypt on first request
- Renews certificates before expiry
- Redirects HTTP to HTTPS
- Handles HTTP/2 and HTTP/3

> [Inference] Let's Encrypt rate limits certificate issuance to 5 certificates per registered domain per week. During initial setup, use Caddy's staging environment (`acme_ca https://acme-staging-v02.api.letsencrypt.org/directory`) to avoid hitting limits while testing. Behavior depends on Let's Encrypt's current rate limit policy.

---

### Prometheus Configuration

```yaml
# docker/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'trpc-app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'

  - job_name: 'caddy'
    static_configs:
      - targets: ['caddy:2019']   # Caddy admin API exposes metrics
    metrics_path: '/metrics'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

Add `node-exporter` and `postgres-exporter` to the Compose file for host and database metrics:

```yaml
# Addition to docker-compose.prod.yml
  node-exporter:
    image: prom/node-exporter:latest
    restart: unless-stopped
    pid: host
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
    networks:
      - internal

  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    restart: unless-stopped
    environment:
      DATA_SOURCE_NAME: "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable"
    networks:
      - internal
```

---

### Environment Variables

Use a `.env.prod` file on the VPS (never committed to the repository):

```bash
# .env.prod — on VPS only, chmod 600
DATABASE_URL=postgresql://trpc:strongpassword@postgres:5432/trpcdb
POSTGRES_USER=trpc
POSTGRES_PASSWORD=strongpassword
POSTGRES_DB=trpcdb
REDIS_URL=redis://:redispassword@redis:6379
REDIS_PASSWORD=redispassword
SENTRY_DSN=https://xxx@sentry.io/yyy
ALLOWED_ORIGINS=https://app.example.com
GRAFANA_PASSWORD=grafanapassword
DOMAIN=api.example.com
```

Load it when running Compose:

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml up -d
```

---

### Database Migrations

Run migrations as a separate step before starting the app, not as part of the app startup:

```bash
# On deploy — runs migration container then exits
docker compose --env-file .env.prod -f docker-compose.prod.yml \
  run --rm app node dist/scripts/migrate.js
```

```ts
// src/scripts/migrate.ts
import { execSync } from 'child_process';

console.log('Running database migrations...');

try {
  execSync('npx prisma migrate deploy', {
    stdio: 'inherit',
    env: { ...process.env },
  });
  console.log('Migrations complete');
  process.exit(0);
} catch (error) {
  console.error('Migration failed:', error);
  process.exit(1);
}
```

Running migrations separately from app startup prevents the race condition where multiple app replicas each attempt to run migrations concurrently.

---

### Zero-Downtime Deploys

Docker Compose on a single VPS does not provide zero-downtime rolling updates natively. Approaches:

**Option 1 — Blue/green with Caddy upstream switching:**

Run two app containers (`app-blue`, `app-green`). Update Caddy's upstream to point to the new container after health checks pass, then stop the old one. Requires scripting and is complex to maintain.

**Option 2 — Restart with a brief gap (acceptable for most deployments):**

```bash
# Pull new image, recreate app container only
docker compose --env-file .env.prod -f docker-compose.prod.yml \
  up -d --no-deps --build app
```

`--no-deps` restarts only the `app` service without touching postgres/redis. The old container stops and the new one starts — clients experience a brief disconnection window (typically 2–10 seconds).

`broadcastReconnectNotification()` in the graceful shutdown handler signals WebSocket clients to reconnect automatically.

**Option 3 — Use a container orchestrator:**

For genuine zero-downtime rolling updates, Kubernetes or Docker Swarm provides the infrastructure. These are outside the scope of a single-VPS deployment.

---

### Deployment Script

```bash
#!/bin/bash
# deploy.sh — run on VPS or triggered via SSH from CI

set -euo pipefail

COMPOSE="docker compose --env-file .env.prod -f docker-compose.prod.yml"

echo "Pulling latest images..."
git pull origin main

echo "Building app image..."
$COMPOSE build app

echo "Running migrations..."
$COMPOSE run --rm app node dist/scripts/migrate.js

echo "Restarting app..."
$COMPOSE up -d --no-deps app

echo "Waiting for health check..."
sleep 10
$COMPOSE ps app

echo "Cleaning up old images..."
docker image prune -f

echo "Deploy complete."
```

---

### CI/CD via GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to VPS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - run: npm ci
      - run: npm test
      - run: npm run build

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd /opt/trpc-app
            bash deploy.sh
```

The `appleboy/ssh-action` connects to the VPS via SSH and runs the deploy script. Store the private SSH key in GitHub Secrets; place only the public key in `~/.ssh/authorized_keys` on the VPS.

> [Inference] Storing the SSH private key in GitHub Secrets grants GitHub Actions full SSH access to the VPS. Restrict this by using a dedicated deploy user with limited permissions, or by using a push-to-deploy webhook approach where the VPS pulls from the registry rather than GitHub Actions pushing to the VPS.

---

### VPS Security Baseline

Before deploying:

```bash
# Firewall — allow only SSH, HTTP, HTTPS
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 443/udp   # HTTP/3
ufw enable

# Disable root login and password auth in /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes

# Keep Docker daemon socket private
# Never mount /var/run/docker.sock into untrusted containers
```

Expose only ports 80, 443, and 22 (SSH) on the host. All inter-container communication on the `internal` network is invisible to the host firewall.

---

### Backup Strategy

```bash
# backup.sh — run via cron daily
#!/bin/bash
set -euo pipefail

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/opt/backups

mkdir -p $BACKUP_DIR

# PostgreSQL dump
docker exec trpc-app-postgres-1 \
  pg_dump -U trpc trpcdb | \
  gzip > $BACKUP_DIR/postgres_$DATE.sql.gz

# Retain 30 days of backups
find $BACKUP_DIR -name "postgres_*.sql.gz" -mtime +30 -delete

# Sync to object storage (rclone configured separately)
rclone sync $BACKUP_DIR remote:trpc-backups/
```

Add to crontab:

```bash
0 2 * * * /opt/trpc-app/backup.sh >> /var/log/backup.log 2>&1
```

---

### Common Issues

| Symptom | Likely Cause |
|---|---|
| Container exits immediately | Crash before binding to port — check `docker compose logs app` |
| `connection refused` from app to postgres | App started before postgres was healthy — add `depends_on` with `condition: service_healthy` |
| TLS certificate not issued | Port 80/443 not reachable from internet, or Let's Encrypt rate limit hit |
| WebSocket connections drop on deploy | Expected — `broadcastReconnectNotification` signals clients to reconnect |
| Disk full | Log rotation not configured, or postgres data volume growing unbounded — add log limits and monitor disk |
| `permission denied` on volume mount | Non-root user in container lacks write permission on mounted host path — fix ownership with `chown` |
| Old images accumulating | Add `docker image prune -f` to deploy script |

---

### Summary

| Concern | Approach |
|---|---|
| Containerization | Multi-stage Dockerfile with non-root user and `tini` |
| Development | `docker-compose.yml` with source mount and hot reload |
| Production | `docker-compose.prod.yml` with env file and restart policies |
| Reverse proxy / TLS | Caddy with automatic Let's Encrypt |
| Network isolation | `internal: true` network for databases; `proxy` network for Caddy |
| Secrets | `.env.prod` on VPS, `chmod 600`, never committed |
| Migrations | Separate `run --rm` container before app restart |
| Zero-downtime | `--no-deps --build app` + graceful shutdown with reconnect signal |
| Observability | Prometheus + Grafana + node-exporter + postgres-exporter |
| Backups | `pg_dump` via cron + rclone to object storage |
| CI/CD | GitHub Actions → SSH → deploy script on VPS |

**Next Steps:**
- Add Watchtower or a similar tool to automatically pull updated base images (postgres, redis, caddy) on a schedule, keeping dependencies patched without manual intervention
- Configure Caddy's `log` directive to ship access logs to a centralized log platform (Loki, Logtail) for correlation with application logs from the tRPC container
- Evaluate Docker Swarm as a step up from single-node Compose if the workload outgrows one VPS — Swarm adds rolling deploys and multi-node scheduling with minimal additional operational complexity