## Installation and Setup


### Installing MongoDB Community Server

#### System Requirements

MongoDB Community Server supports Windows, macOS, and Linux distributions. The minimum requirements include 64-bit architecture and sufficient disk space for data storage. Windows requires Windows 10/Windows Server 2016 or later, while macOS needs macOS 10.14 or later.

#### Windows Installation

Download the MongoDB Community Server MSI installer from the official MongoDB website. Run the installer with administrator privileges and select "Complete" installation type. The installer creates a Windows service that starts MongoDB automatically. The default installation directory is `C:\Program Files\MongoDB\Server\[version]\`.

During installation, you can optionally install MongoDB Compass and configure MongoDB as a Windows service. The service runs under the default user account and starts automatically with the system.

#### macOS Installation

Install MongoDB using Homebrew package manager:

```bash
brew tap mongodb/brew
brew install mongodb-community
```

Alternative installation methods include downloading the TGZ archive and extracting it manually. After installation, start MongoDB using:

```bash
brew services start mongodb/brew/mongodb-community
```

#### Linux Installation

Add the MongoDB repository to your package manager. For Ubuntu/Debian:

```bash
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
```

Start MongoDB service:

```bash
sudo systemctl start mongod
sudo systemctl enable mongod
```

#### Docker Installation

Run MongoDB in a Docker container:

```bash
docker run --name mongodb -d -p 27017:27017 mongo:latest
```

For persistent data storage:

```bash
docker run --name mongodb -d -p 27017:27017 -v mongodb_data:/data/db mongo:latest
```

### MongoDB Compass (GUI Tool)

#### Installation Process

MongoDB Compass can be installed separately or bundled with MongoDB Community Server. Download the appropriate installer for your operating system from the MongoDB website. The installation process is straightforward with a standard installer wizard.

#### Initial Setup and Connection

Launch Compass and configure the connection to your MongoDB instance. The default connection string for local installations is `mongodb://localhost:27017`. Compass automatically detects local MongoDB instances and provides a connection interface.

#### Key Features and Interface

Compass provides a visual interface for database operations including:

- Schema visualization and analysis
- Query builder with drag-and-drop functionality
- Index management and performance monitoring
- Document editing with validation
- Aggregation pipeline builder
- Real-time performance metrics

#### Database Exploration

Navigate databases and collections through the tree view interface. Compass displays collection statistics, document counts, and storage size information. The schema tab reveals field types, frequency distributions, and data patterns within collections.

#### Query Building

Use the query bar to filter documents with MongoDB query syntax. Compass provides query history, allowing you to save and reuse frequently executed queries. The visual query builder helps construct complex queries without writing code.

### MongoDB Shell (mongosh)

#### Installation and Setup

MongoDB Shell (mongosh) replaces the legacy mongo shell and provides enhanced functionality. Install mongosh separately or as part of MongoDB Community Server installation. Verify installation by running `mongosh --version` in your terminal.

#### Connecting to MongoDB

Connect to local MongoDB instance:

```bash
mongosh
```

Connect to remote instance:

```bash
mongosh "mongodb://hostname:port/database"
```

With authentication:

```bash
mongosh "mongodb://username:password@hostname:port/database"
```

#### Basic Shell Operations

Navigate databases and collections using shell commands:

```javascript
// Show databases
show dbs

// Switch to database
use myDatabase

// Show collections
show collections

// Insert document
db.users.insertOne({name: "John", age: 30})

// Find documents
db.users.find({age: {$gte: 25}})
```

#### Advanced Shell Features

Mongosh supports JavaScript syntax and provides built-in helpers for database operations. Use tab completion for command suggestions and access help documentation with `help` command. The shell maintains command history and supports multi-line editing.

#### Scripting and Automation

Create JavaScript files for batch operations and execute them using:

```bash
mongosh --file script.js
```

Shell scripts can automate administrative tasks, data migrations, and repetitive operations across multiple databases or collections.

### Setting up MongoDB Atlas (Cloud)

#### Account Creation and Setup

Create a MongoDB Atlas account at atlas.mongodb.com using email registration or social login options. Atlas provides a free tier with 512MB storage suitable for development and learning purposes.

#### Cluster Creation Process

Navigate to the Atlas dashboard and create a new cluster. Select the cloud provider (AWS, Google Cloud, or Azure) and region closest to your application. Choose cluster tier based on performance and storage requirements.

**Key points:**

- Free tier (M0) includes 512MB storage and shared CPU
- Dedicated clusters (M10+) provide reserved resources
- Multi-region clusters offer high availability

#### Network Security Configuration

Configure IP access list to restrict database connections. Add your current IP address for immediate access or configure IP ranges for production environments. Atlas blocks all connections by default for security.

Create database users with specific permissions:

```javascript
// In Atlas UI, create user with read/write permissions
Username: appUser
Password: [secure-password]
Roles: readWrite@myDatabase
```

#### Connection String Setup

Atlas provides connection strings for different drivers and tools. The standard connection string format includes:

```
mongodb+srv://username:password@cluster.mongodb.net/database?retryWrites=true&w=majority
```

**Example connection methods:**

- Application drivers (Node.js, Python, Java)
- MongoDB Compass GUI connection
- MongoDB Shell (mongosh) command line

#### Data Import and Migration

Use Atlas Data Explorer for manual document creation and editing. Import data from JSON, CSV files, or migrate from existing MongoDB instances using mongoimport tool or Atlas Live Migration service.

#### Monitoring and Alerts

Atlas provides real-time monitoring dashboards showing:

- Database operations per second
- Memory and CPU utilization
- Network traffic and connection counts
- Query performance metrics

Configure alerts for threshold breaches, connection limits, and storage capacity warnings.

### Basic Configuration and Security

#### MongoDB Configuration File

MongoDB uses configuration files (mongod.conf) to define server behavior. The configuration file uses YAML format and controls database path, network settings, and security options.

**Example basic configuration:**

```yaml
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 127.0.0.1

security:
  authorization: enabled
```

#### Authentication Setup

Enable authentication in MongoDB by modifying the configuration file or using command-line options. Create an administrative user before enabling authentication:

```javascript
use admin
db.createUser({
  user: "admin",
  pwd: "securePassword",
  roles: ["userAdminAnyDatabase", "dbAdminAnyDatabase"]
})
```

Start MongoDB with authentication enabled:

```bash
mongod --auth --config /etc/mongod.conf
```

#### User Management and Roles

MongoDB implements role-based access control (RBAC) with built-in roles and custom role creation capabilities. Common built-in roles include:

- `read`: Read data from specific databases
- `readWrite`: Read and write data to specific databases
- `dbAdmin`: Database administration tasks
- `userAdmin`: User and role management
- `clusterAdmin`: Cluster administration

Create database-specific users:

```javascript
use myDatabase
db.createUser({
  user: "appUser",
  pwd: "userPassword",
  roles: [{role: "readWrite", db: "myDatabase"}]
})
```

#### Network Security Configuration

Configure MongoDB to bind to specific IP addresses and restrict network access. Modify the `bindIp` setting in the configuration file to limit connections:

```yaml
net:
  port: 27017
  bindIp: 127.0.0.1,192.168.1.100
```

Use firewall rules to control port 27017 access at the operating system level. For production deployments, implement VPN or private network connectivity.

#### SSL/TLS Encryption

Enable SSL/TLS encryption for client-server communication by configuring certificates in the MongoDB configuration:

```yaml
net:
  ssl:
    mode: requireSSL
    PEMKeyFile: /path/to/server.pem
    CAFile: /path/to/ca.pem
```

[Inference] SSL/TLS configuration requires proper certificate management and may impact connection performance slightly due to encryption overhead.

#### Backup and Recovery Planning

Implement regular backup strategies using mongodump for logical backups or filesystem snapshots for physical backups. Atlas provides automated backup with point-in-time recovery capabilities.

**Example backup command:**

```bash
mongodump --host localhost:27017 --db myDatabase --out /backup/directory
```

**Key points:**

- Test backup restoration procedures regularly
- Store backups in secure, off-site locations
- Document recovery procedures and contact information
- Monitor backup completion and failure notifications

#### Logging and Monitoring Setup

Configure MongoDB logging levels and destinations in the configuration file. Enable profiling for slow operations and monitor database performance metrics:

```yaml
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
  verbosity: 1

operationProfiling:
  slowOpThresholdMs: 100
  mode: slowOp
```

Implement monitoring solutions using MongoDB Monitoring Service (MMS), third-party tools, or custom scripts to track database health and performance indicators.

---

