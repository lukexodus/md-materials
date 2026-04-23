# pgAdmin 4 Comprehensive Guide

## What It Is

pgAdmin 4 is the official open-source administration and development platform for PostgreSQL. It provides a web-based GUI for managing databases, writing and executing queries, inspecting schema objects, monitoring server activity, and administering users and roles.

It runs as a web application served either by a local Python/Flask process (desktop mode) or as a standalone web server (server mode). The interface is identical in both cases.

---

## Installation

### Desktop mode (local machine)

**Ubuntu / Debian:**

```bash
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | \
  sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] \
  https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
  > /etc/apt/sources.list.d/pgadmin4.list'

sudo apt update
sudo apt install pgadmin4-desktop
```

**macOS:** Download the `.dmg` from [pgadmin.org](https://www.pgadmin.org/download/).

**Windows:** Download the `.exe` installer from [pgadmin.org](https://www.pgadmin.org/download/).

### Server mode (web server)

```bash
sudo apt install pgadmin4-web
sudo /usr/pgadmin4/bin/setup-web.sh
```

The setup script prompts for an admin email and password, configures Apache, and starts the service.

### Docker

```bash
docker run -d \
  -p 5050:80 \
  -e PGADMIN_DEFAULT_EMAIL=admin@example.com \
  -e PGADMIN_DEFAULT_PASSWORD=secret \
  --name pgadmin \
  dpage/pgadmin4
```

Access at `http://localhost:5050`.

Persist data across container restarts:

```bash
docker run -d \
  -p 5050:80 \
  -e PGADMIN_DEFAULT_EMAIL=admin@example.com \
  -e PGADMIN_DEFAULT_PASSWORD=secret \
  -v pgadmin_data:/var/lib/pgadmin \
  --name pgadmin \
  dpage/pgadmin4
```

---

## First Launch

On first launch, pgAdmin prompts you to set a master password. This password encrypts saved server passwords in pgAdmin's local storage. It is separate from any PostgreSQL user password.

If you forget the master password, saved server credentials are lost and must be re-entered, but the PostgreSQL server itself is unaffected.

---

## Connecting to a Server

### Adding a server

1. In the left panel (Browser), right-click **Servers** → **Register** → **Server**.
2. Fill in the **General** tab:
    - **Name** — display name in the browser tree (arbitrary).
3. Fill in the **Connection** tab:
    - **Host** — hostname or IP of the PostgreSQL server.
    - **Port** — default `5432`.
    - **Maintenance database** — typically `postgres`.
    - **Username** — PostgreSQL role to connect as.
    - **Password** — optionally saved (encrypted with master password).
4. Click **Save**.

### SSH tunnel

If the PostgreSQL server is not directly reachable, use the **SSH Tunnel** tab:

- **Tunnel host** — SSH server hostname.
- **Tunnel port** — default `22`.
- **Username** — SSH user.
- **Authentication** — password or identity file.

pgAdmin establishes the SSH tunnel before connecting to PostgreSQL.

### Connection parameters

The **Advanced** tab exposes additional connection parameters:

- **DB restriction** — comma-separated list of databases to show (hides others).
- **Password file** — path to a `.pgpass` file.
- **Connection timeout**.
- **SSL mode** — `disable`, `allow`, `prefer`, `require`, `verify-ca`, `verify-full`.
- **SSL certificate / key / root certificate** — paths to PEM files.

---

## Browser Panel

The left panel is a tree showing all registered servers and their objects.

```
Servers
└── my-server
    ├── Databases
    │   └── mydb
    │       ├── Schemas
    │       │   └── public
    │       │       ├── Tables
    │       │       ├── Views
    │       │       ├── Materialized Views
    │       │       ├── Functions
    │       │       ├── Procedures
    │       │       ├── Sequences
    │       │       ├── Types
    │       │       ├── Triggers
    │       │       └── Indexes
    │       ├── Extensions
    │       ├── Event Triggers
    │       └── Publications
    ├── Login/Group Roles
    └── Tablespaces
```

Clicking any object shows its **Properties**, **SQL**, **Statistics**, and **Dependencies** in the right panel tabs.

---

## Query Tool

Open with: **Tools → Query Tool**, or right-click a database → **Query Tool**.

### Interface

- **SQL editor** — top pane. Syntax highlighting, autocompletion, bracket matching.
- **Data output** — bottom pane. Displays results in a grid.
- **Messages** — shows notices, errors, row counts.
- **Explain** — graphical query plan (see below).

### Running queries

|Action|Shortcut|
|---|---|
|Execute|`F5`|
|Execute selection only|`F6`|
|Explain|`F7`|
|Explain Analyze|`Shift+F7`|
|Save file|`Ctrl+S`|
|Open file|`Ctrl+O`|
|Format SQL|`Ctrl+Shift+K`|

### Autocompletion

Press `Ctrl+Space` to trigger autocomplete. pgAdmin introspects the connected database and suggests table names, column names, functions, and keywords.

### Query history

The Query Tool maintains a history of executed statements accessible via **View → Query History**. History is per-connection, per-session.

### Saving queries

Queries can be saved as `.sql` files via **File → Save** within the Query Tool. These are plain text files.

---

## Explain and Explain Analyze

Right-click any query → **Explain** or **Explain Analyze**, or use the toolbar buttons.

pgAdmin renders the query plan as an interactive node graph. Each node shows:

- Node type (Seq Scan, Index Scan, Hash Join, etc.)
- Estimated cost
- Actual rows and execution time (Analyze only)
- Loops

Nodes are color-coded by relative cost. Hovering a node shows full details. This is equivalent to running:

```sql
EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS) SELECT ...;
```

and rendering the JSON plan graphically.

---

## Table Data Viewer and Editor

Right-click a table → **View/Edit Data**:

- **All Rows**
- **First 100 Rows**
- **Last 100 Rows**
- **Filtered Rows** — opens a filter panel

The data grid supports:

- Inline cell editing (click a cell to edit).
- Adding rows (click the `+` row at the bottom).
- Deleting rows (select row → delete key or toolbar button).
- Copy/paste rows.
- Exporting the current result to CSV.

Changes are not committed until you click the **Save Data Changes** button (floppy disk icon). pgAdmin issues individual `INSERT`, `UPDATE`, or `DELETE` statements per change.

The editor requires the table to have a primary key. Without one, pgAdmin opens it read-only.

---

## Schema and Object Management

### Creating objects via GUI

Right-click any node in the browser tree to create child objects:

- Right-click **Tables** → **Create** → **Table**
- Right-click **Schemas** → **Create** → **Schema**
- Right-click a table → **Create** → **Column** / **Index** / **Constraint**

Each dialog has tabs for properties and generates the DDL SQL, which you can preview before executing.

### Viewing generated SQL

Every object dialog has a **SQL** tab showing the exact `CREATE` statement pgAdmin will execute. You can copy this for version control or auditing.

### ERD (Entity Relationship Diagram)

**Tools → ERD Tool** opens a canvas. You can:

- Auto-generate an ERD from an existing database (loads tables and foreign keys).
- Design new tables visually and generate DDL from them.
- Export the diagram as an image or SQL file.

---

## Backup and Restore

pgAdmin wraps `pg_dump` and `pg_restore`.

### Backup a database

Right-click a database → **Backup**.

|Option|Description|
|---|---|
|Format|`Custom` (recommended), `Plain`, `Tar`, `Directory`|
|Encoding|Character encoding of the dump|
|Number of jobs|Parallel dump jobs (Directory format only)|
|Filename|Output path|

Custom format produces a compressed binary file restorable with `pg_restore`. Plain format produces a `.sql` text file.

### Restore a database

Right-click a database → **Restore**.

- Select the backup file.
- Choose restore options (clean before restore, single transaction, etc.).

### Backup a single table

Right-click a table → **Backup**. Produces a dump of that table only.

---

## Import / Export Data

Right-click a table → **Import/Export Data**.

- **Import** — loads a CSV or text file into the table.
- **Export** — writes table data to a CSV or text file.

Options:

- Delimiter, quote character, escape character.
- Header row (column names in first row).
- NULL string representation.
- Encoding.
- Column selection (import/export a subset of columns).

This wraps PostgreSQL's `COPY` command.

---

## Server Activity and Monitoring

### Dashboard

Click a server or database node → **Dashboard** tab.

Shows live charts for:

- Server sessions (active, idle, idle in transaction, waiting).
- Transactions per second.
- Tuples in/out per second.
- Block I/O.

Charts refresh at a configurable interval.

### Active sessions

**Dashboard → Sessions** table shows all current connections with:

- PID
- Database
- User
- Application name
- Client address
- State
- Wait event
- Query (truncated)
- Query start time

Right-click any row → **Terminate** or **Cancel** to kill or cancel the backend process. This calls `pg_terminate_backend()` or `pg_cancel_backend()`.

### Locks

**Dashboard → Locks** shows currently held and awaited locks with relation, mode, granted status, and the PID holding each lock.

### Configuration

**Dashboard → Configuration** displays all `pg_settings` values with source (default, config file, session, etc.).

---

## Role and User Management

Right-click **Login/Group Roles** → **Create** → **Login/Group Role**.

Tabs:

- **General** — name, comments.
- **Definition** — password, account expiry.
- **Privileges** — superuser, create role, create DB, login, inherit, replication, bypass RLS.
- **Membership** — roles this role belongs to.
- **Parameters** — per-role `SET` parameters (e.g., `search_path`).
- **Security** — security labels.

Equivalent SQL is shown in the **SQL** tab.

---

## pgAgent (Job Scheduling)

pgAgent is a PostgreSQL job scheduling daemon, separate from pgAdmin but manageable through it.

### Installing pgAgent

```bash
sudo apt install pgagent
```

Run it as a service pointed at your PostgreSQL instance. Once running, a **pgAgent Jobs** node appears in the browser tree.

### Creating a job

Right-click **pgAgent Jobs** → **Create** → **pgAgent Job**.

- **Steps** — SQL or batch script steps, each with their own connection string and on-error behavior.
- **Schedules** — cron-like schedule with year, month, day, hour, minute fields and exception dates.

Job history and step logs are visible in the **Statistics** tab of each job.

---

## Preferences

**File → Preferences** (desktop) or **User → Preferences** (web).

Key settings:

### Query Tool

- **Auto-commit** — whether statements outside explicit transactions auto-commit. Default `on`.
- **Auto-rollback** — rollback on error. Default `off`.
- **Max rows** — maximum rows fetched in results grid.
- **Explain options** — default flags for Explain (Analyze, Buffers, Timing, etc.).

### Keyboard shortcuts

All Query Tool shortcuts are remappable under **Keyboard Shortcuts**.

### Display

- **Row limit** for View/Edit Data.
- **Column header height**.
- **Theme** — light or dark.

### Browser

- **Confirm before closing Query Tool tab** — prevents accidental tab closure.
- **Show system objects** — toggles visibility of system schemas and tables.

---

## Server Mode Configuration

When running in server mode, pgAdmin is configured via `config_local.py`, located in the pgAdmin installation directory.

```python
# config_local.py

SERVER_MODE = True
DEFAULT_SERVER = '0.0.0.0'
DEFAULT_SERVER_PORT = 5050

SESSION_DB_PATH = '/var/lib/pgadmin/sessions'
STORAGE_DIR = '/var/lib/pgadmin/storage'

# Increase session lifetime (seconds)
SESSION_EXPIRATION_TIME = 3600

# CSRF
WTF_CSRF_ENABLED = True

# Logging
LOG_FILE = '/var/log/pgadmin/pgadmin4.log'
LOG_LEVEL = logging.WARNING
```

Never edit `config.py` directly — it is overwritten on upgrade. Always use `config_local.py`.

### Reverse proxy setup (nginx)

```nginx
server {
    listen 443 ssl;
    server_name pgadmin.example.com;

    location /pgadmin4/ {
        proxy_pass http://127.0.0.1:5050/pgadmin4/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Set `SCRIPT_NAME = '/pgadmin4'` in `config_local.py` to match the path prefix.

---

## Security Considerations

### Master password

The master password encrypts server credentials stored in pgAdmin's local SQLite database. Without it, credentials are stored in plaintext. Always set one.

### Network exposure

In server mode, pgAdmin exposes a web interface. Restrict access:

- Place behind a reverse proxy with TLS.
- Use firewall rules to limit source IPs.
- Enable HTTP Basic Auth at the nginx level for an additional layer.

### Minimal PostgreSQL privileges

The PostgreSQL role used to connect in pgAdmin should have only the privileges it needs. Do not connect as a superuser for routine work.

### pgAdmin's own database

pgAdmin stores its configuration (saved servers, user accounts, job definitions) in a local SQLite file at:

- **Linux:** `~/.local/share/pgadmin/pgadmin4.db`
- **macOS:** `~/Library/Application Support/pgadmin/pgadmin4.db`
- **Docker:** `/var/lib/pgadmin/pgadmin4.db`

Back this file up if you have many saved servers and jobs configured.

---

## Useful Built-in Tools

|Tool|Location|Purpose|
|---|---|---|
|Query Tool|Tools menu|SQL editor and executor|
|ERD Tool|Tools menu|Visual schema design|
|Schema Diff|Tools menu|Compares two schemas and generates migration DDL|
|Backup / Restore|Right-click database|Wraps pg_dump / pg_restore|
|Import / Export|Right-click table|Wraps COPY|
|Maintenance|Right-click database/table|VACUUM, ANALYZE, REINDEX, CLUSTER|
|psql Tool|Tools menu|Embedded terminal running psql|

### psql Tool

**Tools → psql Tool** opens a terminal emulator running `psql` connected to the selected database. Full psql metacommands (`\d`, `\dt`, `\x`, etc.) work here. Useful when the GUI is insufficient.

---

## Keyboard Shortcuts (Query Tool)

|Shortcut|Action|
|---|---|
|`F5`|Execute|
|`F6`|Execute selection|
|`F7`|Explain|
|`Shift+F7`|Explain Analyze|
|`Ctrl+Space`|Autocomplete|
|`Ctrl+/`|Toggle comment|
|`Ctrl+Shift+K`|Format SQL|
|`Ctrl+Z`|Undo|
|`Ctrl+Y`|Redo|
|`Ctrl+F`|Find|
|`Ctrl+H`|Find and replace|
|`Ctrl+L`|Go to line|
|`Alt+Shift+↑/↓`|Move line up/down|