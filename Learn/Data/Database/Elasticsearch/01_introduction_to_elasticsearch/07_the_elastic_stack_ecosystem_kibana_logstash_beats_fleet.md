## The Elastic Stack Ecosystem

### Overview

The Elastic Stack is a collection of open-source and commercial tools built around Elasticsearch. Each component addresses a specific layer of the data pipeline — from collection and ingestion, through storage and search, to visualization and management. Together they form an end-to-end observability, search, and analytics platform.

The four primary components are:

- **Kibana** — Visualization, dashboards, and platform UI
- **Logstash** — Heavy-duty data ingestion and transformation
- **Beats** — Lightweight data shippers
- **Fleet** — Centralized agent management

---

### Kibana

#### What Kibana Is

Kibana is the **visualization and user interface layer** of the Elastic Stack. It connects directly to Elasticsearch and provides a browser-based interface for exploring data, building dashboards, managing the Elastic Stack, and accessing Elastic's platform features.

Originally released in **2013**, Kibana has grown from a simple log visualization tool into a full platform UI that exposes nearly every Elastic Stack capability through a graphical interface.

#### Core Capabilities

##### Discover

The **Discover** tab provides ad-hoc data exploration. Users can:

- Query Elasticsearch indices using **KQL (Kibana Query Language)** or **Lucene syntax**
- View raw documents and field values
- Filter data by time range and field values
- View field statistics and distributions

**Example KQL query:**

```
status: "error" and response_time > 500
```

##### Dashboards

Kibana dashboards are collections of **panels** — visualizations, saved searches, and controls — arranged on a canvas. Dashboards are interactive: clicking a data point applies filters across all panels.

Dashboard panels can include:

- Bar, line, and area charts
- Pie and donut charts
- Data tables
- Metric tiles
- Maps
- Markdown text panels
- Custom Vega visualizations

##### Lens

**Lens** is Kibana's drag-and-drop visualization editor. It allows users to build charts without writing queries by dragging fields onto axes and selecting aggregation types. Lens suggests appropriate visualization types based on the data being explored.

##### Maps

The **Maps** application in Kibana supports geospatial data visualization, including:

- Point maps from `geo_point` fields
- Shape layers from `geo_shape` fields
- Heatmaps and cluster maps
- Integration with Elastic Maps Service (basemap tiles)

##### Canvas

**Canvas** is a presentation-and-reporting tool within Kibana that allows pixel-level layout control. It is used for building live, data-driven reports and slides rather than interactive dashboards.

##### Alerting and Rules

Kibana provides a **Rules and Connectors** framework for defining threshold-based or anomaly-based alerts. Alert actions can be routed to:

- Email
- Slack
- PagerDuty
- Webhook
- Jira
- ServiceNow

##### Machine Learning UI

Kibana exposes Elastic's **machine learning** features through a dedicated UI:

- **Anomaly detection** jobs — identify unusual patterns in time-series data
- **Data frame analytics** — classification, regression, and outlier detection
- **Trained model management** — deploy and manage NLP and vector models (including ELSER)

##### Stack Management

The **Stack Management** section in Kibana provides administrative interfaces for:

- Index management and lifecycle policies (ILM)
- Snapshot and restore
- User and role management (when security is enabled)
- Ingest pipeline management
- Data views (index patterns)
- Saved objects (dashboards, visualizations, searches)

##### Dev Tools

The **Dev Tools** section includes:

- **Console** — An in-browser REST client for sending requests to Elasticsearch with autocomplete support
- **Search Profiler** — Visualizes how a query is executed across shards
- **Grok Debugger** — Tests Grok patterns used in Logstash and ingest pipelines

#### Kibana Query Language (KQL)

KQL is a simplified query language designed for filtering in Kibana's UI. It is not the same as the Elasticsearch Query DSL.

|KQL Example|Meaning|
|---|---|
|`status: 200`|Exact match on field|
|`message: "connection refused"`|Phrase match|
|`bytes > 1000`|Range filter|
|`status: 200 and method: GET`|Boolean AND|
|`tags: (error or warning)`|OR across values|
|`host.name: *`|Field exists|

#### ES|QL in Kibana

As of Elasticsearch 8.x, Kibana includes an **ES|QL** query interface — a pipe-based query language for exploratory data analysis directly within Kibana's Discover and dashboards.

```esql
FROM logs-*
| WHERE status == "error"
| STATS count = COUNT(*) BY service.name
| SORT count DESC
| LIMIT 10
```

---

### Logstash

#### What Logstash Is

Logstash is a **server-side data processing pipeline** that ingests data from multiple sources, transforms it, and sends it to one or more destinations (commonly Elasticsearch). It was the original "L" in the ELK Stack, created in **2009** by Jordan Sissel.

Logstash is written in **JRuby** running on the JVM, which makes it powerful but more resource-intensive than alternatives like Beats or Elastic Agent.

#### Pipeline Architecture

A Logstash pipeline has three stages:

```
[Input] → [Filter] → [Output]
```

Each stage is defined in a pipeline configuration file (`.conf`).

**Example pipeline:**

```ruby
input {
  beats {
    port => 5044
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
  date {
    match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
  }
  geoip {
    source => "clientip"
  }
}

output {
  elasticsearch {
    hosts => ["https://localhost:9200"]
    index => "apache-logs-%{+YYYY.MM.dd}"
  }
}
```

#### Input Plugins

Logstash supports a wide range of input sources via plugins:

|Plugin|Source|
|---|---|
|`beats`|Receives data from Beats agents|
|`file`|Reads from log files|
|`kafka`|Consumes from Apache Kafka topics|
|`jdbc`|Reads from relational databases via JDBC|
|`http`|Receives HTTP POST payloads|
|`syslog`|Listens for syslog messages|
|`tcp` / `udp`|Raw socket data|
|`s3`|Reads objects from AWS S3|
|`rabbitmq`|Consumes from RabbitMQ queues|

#### Filter Plugins

Filter plugins transform and enrich data mid-pipeline:

|Plugin|Purpose|
|---|---|
|`grok`|Pattern-based parsing of unstructured text|
|`mutate`|Field manipulation (rename, remove, convert, replace)|
|`date`|Parse date strings into `@timestamp`|
|`geoip`|Enrich IP addresses with geographic data|
|`dns`|Resolve hostnames|
|`json`|Parse JSON strings into structured fields|
|`csv`|Parse CSV-formatted data|
|`dissect`|Faster, simpler alternative to grok for structured patterns|
|`ruby`|Arbitrary Ruby code for custom transformations|
|`aggregate`|Combine events across multiple log lines|
|`translate`|Map field values using a dictionary|

#### Output Plugins

|Plugin|Destination|
|---|---|
|`elasticsearch`|Index data into Elasticsearch|
|`file`|Write to a local file|
|`kafka`|Publish to Kafka|
|`s3`|Write to AWS S3|
|`http`|Send to an HTTP endpoint|
|`stdout`|Print to console (debugging)|
|`email`|Send email alerts|

#### Persistent Queues

By default, Logstash processes events in memory. **Persistent queues** allow Logstash to store in-flight events on disk, providing resilience against pipeline crashes or downstream unavailability.

```yaml
# logstash.yml
queue.type: persisted
queue.max_bytes: 1gb
```

#### Dead Letter Queues

Events that cannot be processed (e.g., due to mapping conflicts in Elasticsearch) can be routed to a **Dead Letter Queue (DLQ)** for later inspection and reprocessing, rather than being silently dropped.

#### Multiple Pipelines

Logstash supports running **multiple independent pipelines** within a single instance, defined in `pipelines.yml`:

```yaml
- pipeline.id: apache
  path.config: "/etc/logstash/conf.d/apache.conf"
- pipeline.id: syslog
  path.config: "/etc/logstash/conf.d/syslog.conf"
```

#### When to Use Logstash

Logstash is appropriate when:

- Data requires **complex, multi-stage transformation** before indexing.
- Sources include **databases, Kafka, S3**, or other non-file inputs.
- **Custom business logic** in transformation is required.
- **Dead letter queue handling** or **persistent queues** are needed for reliability.

For simpler data shipping, Beats or Elastic Agent are typically preferred due to lower resource consumption.

---

### Beats

#### What Beats Are

Beats are **lightweight, single-purpose data shippers** written in **Go**. They run on edge hosts (servers, containers, endpoints) and ship data either directly to Elasticsearch or through Logstash for further processing.

Compared to Logstash, Beats are:

- Significantly lighter on CPU and memory
- Limited in transformation capability
- Easier to deploy at scale across many hosts

#### The Beats Family

##### Filebeat

**Filebeat** ships log files and other text-based data streams. It is the most widely deployed Beat.

Key features:

- **Harvesters** — one per monitored file, tracking read position
- **Inputs** — define which files or streams to monitor
- **Modules** — pre-built configurations for common log formats (Nginx, Apache, MySQL, AWS, etc.)
- **Multiline support** — combines multi-line log entries (e.g., Java stack traces) into single events

**Example Filebeat input configuration:**

```yaml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/nginx/access.log
    fields:
      service: nginx
      environment: production
```

**Example using a module:**

```yaml
filebeat.modules:
  - module: nginx
    access:
      enabled: true
      var.paths: ["/var/log/nginx/access.log"]
    error:
      enabled: true
```

##### Metricbeat

**Metricbeat** collects system and service metrics at configurable intervals.

- **System metrics** — CPU, memory, disk I/O, network, process statistics
- **Service metrics** — via modules for Nginx, MySQL, Redis, Kafka, Kubernetes, Docker, and many others

**Example:**

```yaml
metricbeat.modules:
  - module: system
    metricsets:
      - cpu
      - memory
      - network
      - diskio
    period: 10s
  - module: docker
    metricsets:
      - container
      - cpu
      - memory
    period: 10s
    hosts: ["unix:///var/run/docker.sock"]
```

##### Packetbeat

**Packetbeat** is a network packet analyzer. It captures network traffic and decodes application-layer protocols to provide visibility into network communications without modifying application code.

Supported protocols include HTTP, DNS, MySQL, PostgreSQL, Redis, MongoDB, Thrift, and others.

##### Winlogbeat

**Winlogbeat** ships **Windows Event Log** data. It is specific to Windows hosts and collects events from channels such as:

- Application
- System
- Security
- Windows PowerShell
- Microsoft-Windows-Sysmon/Operational

##### Auditbeat

**Auditbeat** collects audit data from the Linux kernel's **audit framework** and monitors file integrity.

- **Auditd module** — streams events from the Linux audit daemon
- **File Integrity Module (FIM)** — monitors file and directory changes for security compliance

##### Heartbeat

**Heartbeat** performs **uptime and availability monitoring** by probing endpoints at configured intervals.

- Supports **ICMP** (ping), **TCP**, and **HTTP** monitors
- Reports latency, response codes, and TLS certificate details
- Integrates with Kibana's **Uptime** and **Synthetics** apps

**Example:**

```yaml
heartbeat.monitors:
  - type: http
    id: my-api
    name: "Production API"
    urls: ["https://api.example.com/health"]
    schedule: "@every 30s"
    check.response.status: [200]
```

##### Custom Beats

Elastic provides a **libbeat** framework (in Go) for building custom Beats for proprietary data sources not covered by existing Beats.

#### Beats Processors

Beats support lightweight **processors** for in-agent data transformation before shipping — reducing the need for Logstash in simpler pipelines:

```yaml
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
  - drop_fields:
      fields: ["agent.ephemeral_id"]
  - rename:
      fields:
        - from: "source.address"
          to: "client.ip"
```

#### Beats Output Options

|Output|Use Case|
|---|---|
|`elasticsearch`|Direct indexing|
|`logstash`|Route through Logstash for enrichment|
|`kafka`|Buffer via Kafka|
|`redis`|Buffer via Redis|
|`file`|Write locally (debugging)|
|`console`|Print to stdout (debugging)|

---

### Elastic Agent and Fleet

#### What Elastic Agent Is

**Elastic Agent** is a **unified, single agent** that replaces the need to deploy and manage multiple individual Beats on a host. Introduced in **Elastic Stack 7.x** and reaching greater maturity in **8.x**, it consolidates data collection under a single process.

A single Elastic Agent installation can collect:

- Logs (replacing Filebeat)
- Metrics (replacing Metricbeat)
- Security events (replacing Auditbeat and Winlogbeat)
- Network data (replacing Packetbeat)
- Uptime data (replacing Heartbeat)

Under the hood, Elastic Agent runs the appropriate Beats as sub-processes, but this is abstracted from the operator.

#### What Fleet Is

**Fleet** is the **centralized management layer** for Elastic Agents, accessible through Kibana. It allows operators to:

- Enroll agents remotely
- Deploy and update **integrations** (data collection policies) across agent groups
- Monitor agent health and status
- Upgrade agents remotely
- Manage agent policies without touching individual hosts

#### Fleet Architecture

```
[Elastic Agents on hosts]
        ↓ ↑ (policy, enrollment, status)
  [Fleet Server]
        ↓ ↑
  [Elasticsearch + Kibana]
```

**Fleet Server** is a special Elastic Agent instance that acts as the communication hub between Fleet (in Kibana) and the deployed agents.

#### Agent Policies

An **Agent Policy** defines what an Elastic Agent should collect. It contains one or more **integrations**.

- Policies are created and managed in Kibana Fleet UI.
- Changes to a policy are pushed to all enrolled agents assigned to that policy.
- Agents poll Fleet Server for policy updates at a configurable interval.

#### Integrations

**Integrations** are pre-packaged configurations for collecting data from specific sources. They include:

- Input configurations
- Ingest pipelines
- Index templates
- Kibana dashboards
- ML jobs (where applicable)

**Example integrations:**

|Integration|Data Source|
|---|---|
|System|OS-level logs and metrics|
|Nginx|Nginx access and error logs|
|AWS|CloudTrail, S3, EC2 metrics, VPC Flow Logs|
|Kubernetes|Pod, node, and container metrics|
|Endpoint Security|Elastic Defend (EDR)|
|Windows|Event logs, security events|
|MySQL|Slow query logs, performance metrics|
|Custom Logs|Generic log file ingestion|

#### Elastic Defend

**Elastic Defend** is the **Endpoint Detection and Response (EDR)** integration delivered via Elastic Agent. It provides:

- Malware prevention (using ML models)
- Ransomware protection
- Process, network, and file event collection for threat hunting
- Integration with Elastic Security (SIEM) in Kibana

Elastic Defend is only available through Elastic Agent, not standalone Beats.

#### Enrollment Methods

|Method|Use Case|
|---|---|
|**Fleet-managed**|Centrally managed via Fleet Server and Kibana|
|**Standalone**|Agent runs independently with a local `elastic-agent.yml` config; no Fleet Server required|

Standalone mode is useful in air-gapped environments or where central management is not required. [Inference] Fleet-managed mode is generally recommended for production deployments with many agents, as it reduces per-host configuration management — though this depends on operational constraints.

---

### Data Flow: End to End

A typical Elastic Stack data flow looks like this:

```
[Data Sources]
  (servers, containers, endpoints, databases, cloud services)
        ↓
[Collection Layer]
  Elastic Agent / Beats (Filebeat, Metricbeat, etc.)
        ↓
[Optional Processing Layer]
  Logstash (complex transformation, enrichment)
  — OR —
  Elasticsearch Ingest Pipelines (lightweight transformation)
        ↓
[Storage and Search]
  Elasticsearch
        ↓
[Visualization and Management]
  Kibana (Dashboards, Alerts, Fleet, ML, Security, Dev Tools)
```

---

### Component Selection Guide

|Requirement|Recommended Component|
|---|---|
|Ship logs from files on a host|Elastic Agent (with System or Custom Logs integration) or Filebeat|
|Collect OS and service metrics|Elastic Agent (with System/service integrations) or Metricbeat|
|Complex data transformation|Logstash|
|Lightweight transformation at agent level|Beats processors or Elastic Agent processors|
|Centralized agent management|Fleet + Elastic Agent|
|Air-gapped or standalone deployment|Standalone Elastic Agent or direct Beats|
|Endpoint security (EDR)|Elastic Agent with Elastic Defend|
|Uptime monitoring|Heartbeat or Elastic Agent with Synthetics integration|
|Windows event logs|Winlogbeat or Elastic Agent with Windows integration|

---

**Conclusion**

The Elastic Stack ecosystem is designed as a layered, composable platform. Kibana provides the interface and platform UI; Logstash handles heavyweight transformation; Beats handle lightweight, purpose-specific data shipping; and Elastic Agent with Fleet unifies agent management across environments. Understanding which component addresses which layer of the pipeline — and when to use each — is foundational to designing effective Elastic Stack deployments.

===END_SYLLABOT_RESPONSE_7be29025d26b4c6c===