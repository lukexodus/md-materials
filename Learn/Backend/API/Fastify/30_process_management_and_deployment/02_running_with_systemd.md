## Running with systemd

### Overview

systemd is the init system and service manager on most modern Linux distributions. It supervises processes, handles startup ordering, restarts failed services, manages logs via journald, and integrates with the OS boot sequence. For Fastify applications deployed on bare-metal or VMs without a container orchestrator, a systemd unit file is the minimal, dependency-free alternative to PM2 — one file, no additional runtime, full OS-level integration.

---

### When to Use systemd Over PM2

| Concern | systemd | PM2 |
|---|---|---|
| External dependencies | None — ships with OS | Requires Node.js global install |
| Multi-core scaling | Requires app-level `cluster` | Built-in `-i max` |
| Log management | journald — built-in, structured | Separate log files + `pm2-logrotate` |
| Restart policy | Declarative in unit file | `autorestart`, `max_restarts` |
| Zero-downtime reload | Manual (socket activation or rolling) | `pm2 reload` |
| Startup on boot | Native | `pm2 startup` + `pm2 save` |
| CPU/memory limits | `cgroups` via `CPUQuota`, `MemoryMax` | `max_memory_restart` (RSS only) |
| Security hardening | Extensive namespace/capability options | None |

---

### Basic Unit File Structure

Unit files live in `/etc/systemd/system/` for system-wide services or `~/.config/systemd/user/` for user-level services.

```ini
# /etc/systemd/system/fastify-app.service

[Unit]
Description=Fastify Application
Documentation=https://fastify.dev
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=nodeuser
Group=nodeuser
WorkingDirectory=/srv/fastify-app
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable fastify-app
sudo systemctl start fastify-app
sudo systemctl status fastify-app
```

---

### Service Types

The `Type=` directive controls how systemd determines when a service has finished starting.

| Type | Behavior | When to Use |
|---|---|---|
| `simple` | Process starts immediately; PID 1 is the main process | Most Node.js apps |
| `exec` | Like `simple`, but waits until `execve()` completes | Preferred over `simple` for Node.js >= systemd 240 |
| `notify` | Process sends `sd_notify(READY=1)` when ready | Use with `systemd-notify` for readiness signaling |
| `forking` | Main process forks; parent exits | PM2 daemon mode — avoid for Fastify |
| `oneshot` | Process runs and exits; systemd waits for it | Scripts, migrations |

For Fastify, `Type=notify` with explicit readiness signaling is the most correct approach for applications with async initialization.

---

### Production Unit File

```ini
# /etc/systemd/system/fastify-app.service

[Unit]
Description=Fastify Production Application
Documentation=https://fastify.dev
After=network.target network-online.target postgresql.service redis.service
Wants=network-online.target
BindsTo=postgresql.service

[Service]
Type=notify
NotifyAccess=main

User=nodeuser
Group=nodeuser
WorkingDirectory=/srv/fastify-app

# Environment
Environment=NODE_ENV=production
Environment=PORT=3000
Environment=HOST=0.0.0.0
EnvironmentFile=/etc/fastify-app/env

# Process
ExecStart=/usr/bin/node \
  --max-old-space-size=512 \
  server.js
ExecReload=/bin/kill -HUP $MAINPID

# Restart policy
Restart=on-failure
RestartSec=5s
StartLimitIntervalSec=60s
StartLimitBurst=3

# Timeouts
TimeoutStartSec=30s
TimeoutStopSec=30s

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=fastify-app

# Resource limits
LimitNOFILE=65535
LimitNPROC=4096
MemoryMax=600M
CPUQuota=200%

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/srv/fastify-app/logs /srv/fastify-app/tmp
CapabilityBoundingSet=

[Install]
WantedBy=multi-user.target
```

---

### `Type=notify` — Readiness Signaling

With `Type=notify`, systemd waits for the process to signal `READY=1` before considering the service started. Dependent services do not start until this signal is received.

#### Using `sd-notify` from Node.js

```bash
npm install sd-notify
```

```js
// server.js
import Fastify from 'fastify'
import sdNotify from 'sd-notify'

const fastify = Fastify({ logger: true })

// Register plugins, decorators, routes
await fastify.register(import('./plugins/db.js'))
await fastify.register(import('./plugins/redis.js'))
await fastify.register(import('./routes/api.js'))

await fastify.listen({
  port: process.env.PORT ?? 3000,
  host: process.env.HOST ?? '0.0.0.0',
})

// Signal systemd: service is ready to accept connections
sdNotify.ready()

fastify.log.info('Server ready')
```

#### Watchdog Support

systemd can restart a service that stops responding, via the watchdog mechanism.

```ini
[Service]
WatchdogSec=30s
```

```js
import sdNotify from 'sd-notify'

// Send watchdog keepalive at half the WatchdogSec interval
const watchdogInterval = sdNotify.watchdogInterval()

if (watchdogInterval > 0) {
  const pingInterval = Math.floor(watchdogInterval / 2)
  setInterval(() => {
    sdNotify.watchdog()
  }, pingInterval).unref()
}
```

> **Key Point:** The watchdog only detects that the process is alive enough to run the `setInterval` callback. [Inference] For a more meaningful health signal, drive the watchdog ping from a lightweight internal health check (e.g., a DB ping or event loop lag measurement) rather than a bare timer. If the check fails, do not send the watchdog signal — systemd will restart the service. Behavior depends on `WatchdogSec` value and system load.

---

### Graceful Shutdown with systemd

systemd sends `SIGTERM` on `systemctl stop` or `systemctl restart`. After `TimeoutStopSec`, it sends `SIGKILL`.

```js
// server.js
import Fastify from 'fastify'
import sdNotify from 'sd-notify'

const fastify = Fastify({ logger: true })

fastify.get('/', async () => ({ ok: true }))

const shutdown = async (signal) => {
  fastify.log.info({ signal }, 'Shutdown signal received')

  // Signal systemd: stopping
  sdNotify.stopping()

  try {
    await fastify.close()
    fastify.log.info('Graceful shutdown complete')
    process.exit(0)
  } catch (err) {
    fastify.log.error(err, 'Error during shutdown')
    process.exit(1)
  }
}

process.on('SIGTERM', () => shutdown('SIGTERM'))
process.on('SIGINT', () => shutdown('SIGINT'))

await fastify.listen({
  port: process.env.PORT ?? 3000,
  host: '0.0.0.0',
})

sdNotify.ready()
```

> **Key Point:** `sdNotify.stopping()` sends `STOPPING=1` to systemd, which updates the service state in `systemctl status` and may be used by dependent services to begin their own shutdown sequence. It is not required but improves observability.

---

### Environment Variables

#### Inline in Unit File

```ini
[Service]
Environment=NODE_ENV=production
Environment=PORT=3000
Environment=LOG_LEVEL=info
```

#### External Environment File

```ini
[Service]
EnvironmentFile=/etc/fastify-app/env
```

```bash
# /etc/fastify-app/env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgres://user:pass@localhost/appdb
REDIS_URL=redis://localhost:6379
LOG_LEVEL=info
```

Secure the file:

```bash
sudo chown root:nodeuser /etc/fastify-app/env
sudo chmod 640 /etc/fastify-app/env
```

> **Key Point:** `EnvironmentFile` contents are not encrypted at rest. For secrets, consider `systemd-creds` (systemd >= 250), HashiCorp Vault, or AWS Secrets Manager with a pre-start script that writes the env file from a secrets API.

#### `systemd-creds` (systemd >= 250)

```ini
[Service]
LoadCredential=db-password:/etc/credentials/db-password
```

```js
// Access in Node.js
const credDir = process.env.CREDENTIALS_DIRECTORY
const dbPassword = fs.readFileSync(path.join(credDir, 'db-password'), 'utf8').trim()
```

---

### Logging with journald

All output to `stdout` and `stderr` is captured by journald automatically when `StandardOutput=journal`.

```bash
# Tail live logs
journalctl -u fastify-app -f

# Last 100 lines
journalctl -u fastify-app -n 100

# Since last boot
journalctl -u fastify-app -b

# Time range
journalctl -u fastify-app --since "2024-01-15 10:00" --until "2024-01-15 11:00"

# JSON output (for log shipping)
journalctl -u fastify-app -o json

# Filter by priority (err, warning, info, debug)
journalctl -u fastify-app -p err

# Follow with metadata
journalctl -u fastify-app -f -o short-iso
```

#### Structured Logs — Pino + journald

Fastify's default logger (Pino) outputs JSON. journald captures it as the `MESSAGE` field. To make structured fields queryable in journald, use `pino-systemd` or forward to a log aggregator.

```bash
npm install pino-systemd
```

```bash
# Pipe Pino output through pino-systemd transport
ExecStart=/usr/bin/node server.js | /usr/local/bin/pino-systemd
```

Or use Pino's transport option:

```js
const fastify = Fastify({
  logger: {
    transport: {
      target: 'pino-systemd',
    },
  },
})
```

> [Inference] `pino-systemd` maps Pino log levels to journald priority levels and exposes Pino fields as journald structured fields, making them filterable with `journalctl FIELD=value`. Verify current `pino-systemd` API and compatibility with your Pino version before use.

---

### Restart Policy

```ini
[Service]
Restart=on-failure       # restart only on non-zero exit or signal
RestartSec=5s            # wait 5s before restarting
StartLimitIntervalSec=60s  # sliding window for burst counting
StartLimitBurst=3          # max 3 restarts within the window before giving up
```

`Restart=` values:

| Value | Behavior |
|---|---|
| `no` | Never restart |
| `on-failure` | Restart on non-zero exit code or killed by signal |
| `on-abnormal` | Restart on signal, watchdog timeout, or core dump |
| `always` | Restart unconditionally |
| `on-success` | Restart only on clean exit (exit code 0) |

> **Key Point:** `Restart=on-failure` is correct for Fastify production services. `Restart=always` will restart even intentional `process.exit(0)` calls — which can cause restart loops during deliberate shutdown sequences if the signal handling is not perfect.

After exceeding `StartLimitBurst`:

```bash
# Manually reset the failure counter to allow restart attempts again
sudo systemctl reset-failed fastify-app
sudo systemctl start fastify-app
```

---

### Resource Control via cgroups

systemd places each service in a cgroup, enabling hard resource limits enforced by the kernel.

```ini
[Service]
# Memory
MemoryMax=600M          # hard limit — OOM kill if exceeded
MemoryHigh=500M         # soft limit — throttle before OOM

# CPU
CPUQuota=200%           # 200% = 2 full cores
CPUWeight=100           # relative scheduling weight (default 100)

# File descriptors
LimitNOFILE=65535       # max open file descriptors (increase for high-concurrency)

# Processes
LimitNPROC=4096         # max child processes/threads
```

> **Key Point:** `LimitNOFILE` is critical for high-concurrency Fastify applications. Each TCP connection consumes a file descriptor. The default system limit (often 1024) causes `EMFILE: too many open files` errors under load. Set it to at least `65535` in production.

Check current limits for a running service:

```bash
cat /proc/$(systemctl show -p MainPID --value fastify-app)/limits
```

---

### Security Hardening Directives

systemd provides namespacing and capability restrictions that reduce the blast radius of a compromised Node.js process.

```ini
[Service]
# Prevent privilege escalation
NoNewPrivileges=true

# Private /tmp — process gets its own isolated /tmp
PrivateTmp=true

# Make /usr, /boot, /etc read-only
ProtectSystem=strict

# Block access to /home, /root
ProtectHome=true

# Allow writes only to specific paths
ReadWritePaths=/srv/fastify-app/logs /srv/fastify-app/uploads

# Remove all Linux capabilities
CapabilityBoundingSet=

# Restrict syscalls to a safe subset
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM

# Prevent writing to kernel variables
ProtectKernelTunables=true
ProtectKernelModules=true

# Private network namespace (remove if app needs network)
# PrivateNetwork=true

# Restrict address families
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
```

> [Inference] `SystemCallFilter=@system-service` restricts the process to a predefined set of syscalls appropriate for network services. Node.js uses a broad set of syscalls — if the app crashes silently after adding this directive, check `journalctl` for `EPERM` errors and identify which syscalls need adding to the allowlist. Behavior depends on Node.js version and native modules in use.

---

### Socket Activation

systemd can pre-open the listening socket and pass it to the process, enabling zero-downtime restarts — the socket stays bound during process restart, so incoming connections queue rather than fail.

```ini
# /etc/systemd/system/fastify-app.socket

[Unit]
Description=Fastify App Socket

[Socket]
ListenStream=3000
SocketMode=0660
Accept=false

[Install]
WantedBy=sockets.target
```

```ini
# /etc/systemd/system/fastify-app.service

[Unit]
Description=Fastify App
Requires=fastify-app.socket
After=fastify-app.socket

[Service]
Type=notify
ExecStart=/usr/bin/node server.js
NonBlocking=true
```

```js
// server.js — receive socket from systemd
import Fastify from 'fastify'
import sdNotify from 'sd-notify'

const fastify = Fastify({ logger: true })

fastify.get('/', async () => ({ ok: true }))

// systemd passes the socket as file descriptor 3
const SD_LISTEN_FDS_START = 3

await fastify.listen({
  fd: SD_LISTEN_FDS_START,
})

sdNotify.ready()
```

Enable the socket unit, not the service unit directly:

```bash
sudo systemctl enable fastify-app.socket
sudo systemctl start fastify-app.socket
# Service starts automatically when first connection arrives
```

> [Inference] Socket activation is the closest systemd equivalent to PM2's zero-downtime `reload`. During a restart, connections queue on the socket and are accepted by the new process once it signals ready. Actual behavior under high concurrency depends on the OS socket backlog (`ListenStream` backlog tuning) and startup time. Test under realistic load before relying on this in production.

---

### Multiple Instances with `@` Units (Template Units)

A template unit file runs multiple instances of the same service on different ports or configurations.

```ini
# /etc/systemd/system/fastify-app@.service

[Unit]
Description=Fastify App instance %i
After=network.target

[Service]
Type=notify
User=nodeuser
WorkingDirectory=/srv/fastify-app
Environment=PORT=%i
EnvironmentFile=/etc/fastify-app/env
ExecStart=/usr/bin/node server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Start instances on ports 3000, 3001, 3002:

```bash
sudo systemctl enable fastify-app@3000
sudo systemctl enable fastify-app@3001
sudo systemctl enable fastify-app@3002
sudo systemctl start fastify-app@3000 fastify-app@3001 fastify-app@3002
```

> [Inference] Template units are a systemd-native alternative to PM2 cluster mode when the app itself does not use `cluster`. Each instance is a fully supervised independent process. A reverse proxy (NGINX, Caddy) load-balances across the ports. This approach gives per-instance resource limits and independent restart policies.

---

### Diagram — systemd Service Lifecycle

```mermaid
stateDiagram-v2
    [*] --> inactive
    inactive --> activating : systemctl start
    activating --> active : READY=1 (Type=notify)\nor process running (Type=simple)
    activating --> failed : timeout / non-zero exit
    active --> deactivating : systemctl stop / SIGTERM
    deactivating --> inactive : process exits cleanly
    active --> failed : crash / watchdog timeout
    failed --> activating : Restart=on-failure\n(within StartLimitBurst)
    failed --> failed : StartLimitBurst exceeded
    failed --> activating : systemctl reset-failed + start
```

---

### Quick Reference — Common Commands

```bash
# Unit management
sudo systemctl daemon-reload          # reload unit files after edit
sudo systemctl enable fastify-app     # start on boot
sudo systemctl disable fastify-app    # remove from boot
sudo systemctl start fastify-app
sudo systemctl stop fastify-app
sudo systemctl restart fastify-app
sudo systemctl reload fastify-app     # send SIGHUP (ExecReload)
sudo systemctl status fastify-app

# Failure recovery
sudo systemctl reset-failed fastify-app

# Logs
journalctl -u fastify-app -f
journalctl -u fastify-app -b -p err   # errors since last boot

# Inspect
systemctl cat fastify-app             # view effective unit file
systemctl show fastify-app            # all properties
systemd-analyze verify fastify-app.service  # validate unit file syntax
```

---

**Related Topics**

- NGINX reverse proxy in front of systemd-managed Fastify — upstream keepalive tuning
- `systemd-creds` for encrypted credential injection
- `pino-systemd` structured log transport and journald field queries
- Socket activation for zero-downtime restarts without PM2
- `systemd-analyze blame` and `systemd-analyze critical-chain` for boot time profiling
- cgroup v2 memory and CPU accounting for per-service resource visibility
- Deploying multiple Fastify instances with template units and HAProxy
- Comparing systemd, PM2, and Docker supervision for single-VM Fastify deployments