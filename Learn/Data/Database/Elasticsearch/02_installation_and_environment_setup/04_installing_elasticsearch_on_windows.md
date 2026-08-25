## Installing Elasticsearch on Windows

### Overview

Elasticsearch can be installed on Windows via two primary methods:

- **ZIP archive** — manual installation, full control over placement and configuration
- **Docker Desktop for Windows** — containerized installation using Docker with WSL 2 backend

> Windows is supported for **development purposes**. Elastic does not recommend Windows for production Elasticsearch deployments. For production on Windows-based infrastructure, Docker with Linux containers is closer to a supported production configuration than a native Windows installation.

> Always verify the current version and package integrity against [https://www.elastic.co/downloads/elasticsearch](https://www.elastic.co/downloads/elasticsearch) before installing.

---

### Prerequisites

#### Hardware

|Resource|Minimum (Development)|
|---|---|
|**CPU**|2 cores|
|**RAM**|4 GB available (8 GB+ recommended)|
|**Disk**|10 GB free space (SSD preferred)|

#### Software

|Requirement|Detail|
|---|---|
|**Windows version**|Windows 10 (64-bit) or Windows 11; Windows Server 2016, 2019, 2022|
|**Architecture**|x86_64 only for native Windows installation|
|**Java**|Not required — bundled JDK included|
|**PowerShell**|Version 5.1 or later (included with Windows 10+)|
|**Docker Desktop**|Required only for the Docker method|
|**WSL 2**|Required for Docker Desktop (Windows 10 version 2004+ / build 19041+)|

#### User Privileges

- **ZIP method** — Administrator privileges are required for installing and managing the Windows service.
- **Docker method** — User must be a member of the `docker-users` group after Docker Desktop installation.

---

### Method 1 — ZIP Archive

#### Step 1 — Download the ZIP Archive

Navigate to [https://www.elastic.co/downloads/elasticsearch](https://www.elastic.co/downloads/elasticsearch) and download the **Windows** ZIP package.

Or download via PowerShell:

```powershell
Invoke-WebRequest -Uri "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.0-windows-x86_64.zip" `
  -OutFile "elasticsearch-8.13.0-windows-x86_64.zip"
```

> Replace `8.13.0` with the current stable version. Verify the latest version at the Elastic downloads page.

#### Step 2 — Verify the SHA-512 Checksum

Download the checksum file:

```powershell
Invoke-WebRequest -Uri "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.0-windows-x86_64.zip.sha512" `
  -OutFile "elasticsearch-8.13.0-windows-x86_64.zip.sha512"
```

Compute and compare the hash:

```powershell
$expected = (Get-Content "elasticsearch-8.13.0-windows-x86_64.zip.sha512").Split(" ")[0].ToUpper()
$actual = (Get-FileHash "elasticsearch-8.13.0-windows-x86_64.zip" -Algorithm SHA512).Hash
if ($expected -eq $actual) { "Checksum OK" } else { "CHECKSUM MISMATCH — do not proceed" }
```

Do not proceed if the checksum does not match.

#### Step 3 — Extract the ZIP

Using PowerShell:

```powershell
Expand-Archive -Path "elasticsearch-8.13.0-windows-x86_64.zip" `
  -DestinationPath "C:\elasticsearch"
```

Or extract manually via Windows Explorer (right-click → Extract All).

The extracted directory structure:

```
C:\elasticsearch\elasticsearch-8.13.0\
├── bin\                  # Executable scripts (.bat and PowerShell)
├── config\               # Configuration files
│   ├── elasticsearch.yml
│   ├── jvm.options
│   └── log4j2.properties
├── data\                 # Default data storage
├── jdk\                  # Bundled JDK
├── lib\                  # Core library JARs
├── logs\                 # Default log location
├── modules\              # Built-in modules
└── plugins\              # Installed plugins (initially empty)
```

#### Step 4 — Configure Elasticsearch (Optional for Development)

Open `config\elasticsearch.yml` in a text editor. For a minimal single-node development setup, defaults are sufficient. Optionally set:

```yaml
# config\elasticsearch.yml

cluster.name: my-dev-cluster
node.name: node-1

# Explicit path configuration (recommended on Windows to avoid path ambiguity)
path.data: C:\elasticsearch\data
path.logs: C:\elasticsearch\logs
```

> Avoid paths with spaces when possible. If spaces are unavoidable, ensure paths are correctly quoted in any scripts referencing them.

#### Step 5 — Configure JVM Heap (Optional)

For development, the default heap settings are typically adequate. To customize, create a file in `config\jvm.options.d\`:

```
# config\jvm.options.d\heap.options
-Xms2g
-Xmx2g
```

Keep `-Xms` and `-Xmx` equal. Do not exceed 50% of available RAM or 32 GB.

#### Step 6 — Start Elasticsearch

Open **PowerShell as Administrator** and navigate to the Elasticsearch directory:

```powershell
cd C:\elasticsearch\elasticsearch-8.13.0
.\bin\elasticsearch.bat
```

On first startup, Elasticsearch outputs security configuration information:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Elasticsearch security features have been automatically configured!
✅ Authentication is enabled and cluster connections are encrypted.

ℹ️  Password for the elastic user:
  pAssw0rd_example

ℹ️  HTTP CA certificate SHA-256 fingerprint:
  a1b2c3d4e5...

ℹ️  Enrollment token for Kibana (valid for 30 minutes):
  eyJ2ZXIiOiI4LjEzLjAiLCJhZHI...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

> **Save this output immediately.** The password and enrollment tokens are shown only once. If the password is lost, reset it using `bin\elasticsearch-reset-password.bat -u elastic`.

#### Step 7 — Install as a Windows Service (Optional)

Running Elasticsearch as a Windows service allows it to start automatically with Windows and run in the background.

**Install the service:**

```powershell
.\bin\elasticsearch-service.bat install
```

**Manage the service:**

```powershell
# Start
.\bin\elasticsearch-service.bat start

# Stop
.\bin\elasticsearch-service.bat stop

# Restart
.\bin\elasticsearch-service.bat manager
```

The `manager` command opens the **Elasticsearch Service Manager** GUI, which provides controls for:

- Starting and stopping the service
- Setting startup type (Automatic, Manual, Disabled)
- Configuring JVM heap size
- Viewing log paths

**Alternatively, manage via Windows Services panel:**

```powershell
# Start via sc
sc.exe start elasticsearch-service-x64

# Stop via sc
sc.exe stop elasticsearch-service-x64
```

Or via the Services snap-in: `services.msc` → find `Elasticsearch` → right-click to manage.

**Remove the service:**

```powershell
.\bin\elasticsearch-service.bat remove
```

#### Step 8 — Configure Windows Firewall (If Needed)

If accessing Elasticsearch from other machines on the network (not typical for development), allow port 9200 through Windows Firewall:

```powershell
New-NetFirewallRule -DisplayName "Elasticsearch HTTP" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 9200 `
  -Action Allow
```

> For local development only, no firewall changes are needed since Elasticsearch binds to `localhost` by default.

---

### Method 2 — Docker Desktop for Windows

Docker Desktop on Windows runs Linux containers via a **WSL 2** (Windows Subsystem for Linux 2) backend, which means the Elasticsearch container runs in a Linux environment. This is the closer-to-production option on Windows.

#### Step 1 — Enable WSL 2

WSL 2 is required for Docker Desktop on Windows 10/11.

**Check if WSL is installed:**

```powershell
wsl --status
```

**Install or update WSL:**

```powershell
wsl --install
```

**Set WSL 2 as default:**

```powershell
wsl --set-default-version 2
```

Restart the machine if prompted.

#### Step 2 — Install Docker Desktop

Download Docker Desktop from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop).

During installation:

- Ensure **Use WSL 2 instead of Hyper-V** is selected (recommended default).
- After installation, Docker Desktop starts automatically.

Verify installation:

```powershell
docker --version
docker compose version
```

#### Step 3 — Set vm.max_map_count in WSL 2

Elasticsearch requires `vm.max_map_count=262144`. In a WSL 2 environment, this must be set inside the WSL 2 Linux kernel, not in Windows itself.

**Option A — Set temporarily (lost on WSL restart):**

```bash
# Run inside WSL 2 terminal
wsl -u root sysctl -w vm.max_map_count=262144
```

**Option B — Set persistently via `.wslconfig`:**

Create or edit `C:\Users\<YourUsername>\.wslconfig`:

```ini
[wsl2]
kernelCommandLine = sysctl.vm.max_map_count=262144
```

Restart WSL:

```powershell
wsl --shutdown
```

Then restart Docker Desktop.

> This is one of the most common issues when running Elasticsearch in Docker on Windows. Elasticsearch [Inference] may fail to start or behave unexpectedly if `vm.max_map_count` is not set correctly — though exact behavior may vary by version.

#### Step 4 — Create a Docker Network

Open PowerShell or Windows Terminal:

```powershell
docker network create elastic
```

#### Step 5 — Pull the Elasticsearch Image

```powershell
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

#### Step 6 — Start the Elasticsearch Container

```powershell
docker run --name elasticsearch `
  --net elastic `
  -p 9200:9200 `
  -p 9300:9300 `
  -e "discovery.type=single-node" `
  -e "ELASTIC_PASSWORD=changeme" `
  -e "xpack.security.enabled=true" `
  -e "xpack.security.http.ssl.enabled=false" `
  -t `
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

> The backtick (`` ` ``) is the PowerShell line continuation character. Use `^` if running in Command Prompt.

> Disabling SSL (`xpack.security.http.ssl.enabled=false`) is acceptable for local development only. Do not disable SSL in any shared or exposed environment.

#### Step 7 — Persist Data with a Named Volume

```powershell
docker run --name elasticsearch `
  --net elastic `
  -p 9200:9200 `
  -p 9300:9300 `
  -v elasticsearch-data:/usr/share/elasticsearch/data `
  -e "discovery.type=single-node" `
  -e "ELASTIC_PASSWORD=changeme" `
  -e "xpack.security.enabled=true" `
  -e "xpack.security.http.ssl.enabled=false" `
  -t `
  docker.elastic.co/elasticsearch/elasticsearch:8.13.0
```

#### Docker Compose on Windows

Create `docker-compose.yml` in a working directory:

```yaml
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

**Start:**

```powershell
docker compose up -d
```

**Stop:**

```powershell
docker compose down
```

**Stop and remove volumes:**

```powershell
docker compose down -v
```

---

### Verifying the Installation

#### With HTTPS (ZIP method default)

In PowerShell:

```powershell
# Using curl (available in PowerShell 7+ and Windows 10+)
curl.exe -k -u elastic:YOUR_PASSWORD https://localhost:9200
```

Or using `Invoke-WebRequest`:

```powershell
$cred = Get-Credential  # Enter 'elastic' as username
Invoke-WebRequest -Uri "https://localhost:9200" `
  -Credential $cred `
  -SkipCertificateCheck
```

> `-SkipCertificateCheck` is the PowerShell equivalent of `curl -k`. Use only for local development.

#### With HTTP (Docker method with SSL disabled)

```powershell
curl.exe -u elastic:changeme http://localhost:9200
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
    "build_type" : "zip",
    "lucene_version" : "9.10.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

#### Check Cluster Health

```powershell
curl.exe -u elastic:YOUR_PASSWORD https://localhost:9200/_cluster/health?pretty
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
  "unassigned_shards" : 0
}
```

> A single-node cluster reports `yellow` status when indices have replica shards configured (the default). This is expected behavior on a single-node development setup.

---

### Common Post-Installation Tasks

#### Reset the elastic User Password

```powershell
# ZIP installation
.\bin\elasticsearch-reset-password.bat -u elastic

# Docker
docker exec -it elasticsearch `
  /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

#### Generate a Kibana Enrollment Token

```powershell
# ZIP installation
.\bin\elasticsearch-create-enrollment-token.bat -s kibana

# Docker
docker exec -it elasticsearch `
  /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

#### Install a Plugin

```powershell
# ZIP installation
.\bin\elasticsearch-plugin.bat install analysis-icu

# Docker — plugins should be added at image build time via a custom Dockerfile
```

#### View Logs

```powershell
# ZIP installation — logs in the configured logs directory
Get-Content "C:\elasticsearch\elasticsearch-8.13.0\logs\elasticsearch.log" -Wait

# Docker
docker logs -f elasticsearch
```

---

### Windows-Specific Considerations

#### Antivirus Software

Windows antivirus tools (including Windows Defender) may scan Elasticsearch's data and log files, which can significantly degrade performance. [Inference] Adding exclusions for the Elasticsearch data, logs, and binary directories is advisable in development environments — though the performance impact depends on the antivirus product and workload.

**Recommended exclusions (Windows Defender example):**

```powershell
Add-MpPreference -ExclusionPath "C:\elasticsearch"
```

> Apply exclusions cautiously and in accordance with your organization's security policies.

#### Path Length Limitations

Windows has a default maximum path length of 260 characters (`MAX_PATH`). Deep directory structures within the Elasticsearch data directory may [Inference] trigger path length errors on older Windows versions or configurations.

Enable long path support (Windows 10 version 1607+):

```powershell
# Via PowerShell (requires Administrator)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
  -Name "LongPathsEnabled" -Value 1
```

Or via Group Policy: `Computer Configuration > Administrative Templates > System > Filesystem > Enable Win32 long paths`.

#### Line Endings

Configuration files edited on Windows may introduce CRLF (`\r\n`) line endings. Elasticsearch configuration parsers [Inference] handle this in most cases, but using an editor that saves files with LF (`\n`) line endings (such as VS Code with the appropriate setting) reduces the risk of parsing issues.

#### Windows Defender Firewall

By default, Elasticsearch binds to `localhost` (127.0.0.1) and is not accessible from the network. No firewall changes are required for local development. If binding to a network interface is needed, update `elasticsearch.yml`:

```yaml
network.host: 0.0.0.0
```

And add a corresponding firewall rule as shown in Step 8 of the ZIP method.

#### Service Account Considerations

When running Elasticsearch as a Windows service, it runs under the **Local System** account by default. For environments with stricter access control requirements, [Inference] configuring a dedicated service account with minimum necessary permissions may be preferable — though this requires additional configuration of file system permissions on the data and log directories.

#### PowerShell Execution Policy

Running `.bat` scripts from PowerShell may require adjusting the execution policy if scripts are blocked:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> Understand the security implications before changing execution policy. `RemoteSigned` allows locally created scripts to run and requires downloaded scripts to be signed.

---

### Choosing an Installation Method on Windows

|Factor|ZIP Archive|Docker Desktop|
|---|---|---|
|**Ease of setup**|Moderate|Moderate (WSL 2 setup required)|
|**Service management**|Windows Service|Docker / Compose|
|**Data persistence**|Native filesystem|Docker named volume|
|**Isolation**|None|Strong (Linux container)|
|**Closer to production**|No|Yes (Linux environment)|
|**Multiple versions**|Easy (separate directories)|Easy (separate containers/images)|
|**vm.max_map_count requirement**|Not applicable (Windows kernel)|Required (WSL 2 kernel setting)|
|**Antivirus impact**|Yes|Reduced (data inside WSL 2)|
|**Cleanup**|Delete directory + service removal|`docker rm` + volume removal|

---

**Conclusion**

Installing Elasticsearch on Windows is straightforward via the ZIP archive or Docker Desktop. The ZIP method suits developers who prefer a direct, native installation with Windows Service integration. Docker Desktop with WSL 2 provides a Linux-native environment that more closely resembles production container deployments and avoids several Windows-specific concerns such as antivirus interference and path length limitations. Regardless of method, capturing the auto-generated credentials on first startup, verifying connectivity via the REST API, and setting `vm.max_map_count` correctly in the WSL 2 environment (for Docker) are the critical steps before proceeding.

===END_SYLLABOT_RESPONSE_7be29025d26b4c6c===