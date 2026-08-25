## Docker Extension Development


### Understanding Docker Extensions

Docker extensions provide a way to expand Docker's functionality, particularly Docker Desktop, by integrating new features and tools into the Docker ecosystem. Extensions allow developers to build custom functionality while maintaining a consistent user experience within the Docker platform.

**Key Points**:

- Extensions enhance Docker's core functionality
- They integrate directly with Docker Desktop's interface
- Extensions can be built using web technologies or Go
- Docker provides SDKs and frameworks for extension development

### Docker Desktop Extensions

Docker Desktop extensions allow developers to add new capabilities to Docker Desktop through a plugin-based architecture. These extensions appear as new sections within the Docker Desktop dashboard.

#### Extension Architecture

Docker Desktop extensions consist of several components:

- Frontend UI built with web technologies
- Backend services (optional) running in containers
- Metadata defining the extension's properties
- Extension SDK for interacting with Docker

#### Extension Structure

A typical extension project has the following structure:

```
my-extension/
├── Dockerfile             # Builds the extension
├── docker-compose.yml     # For testing with dependent services
├── metadata.json          # Extension metadata
└── ui/                    # Frontend UI code
    ├── index.html
    ├── src/
    └── package.json
```

#### Creating a Basic Extension

To create a new Docker Desktop extension:

1. Install the Docker Extension CLI:

```bash
docker extension install docker/desktop-extension-cli
```

2. Create a new extension project:

```bash
mkdir my-extension && cd my-extension
docker extension init
```

3. Edit the `metadata.json` file:

```json
{
  "name": "my-extension",
  "description": "My custom Docker Desktop extension",
  "vendor": "My Company",
  "version": "0.1.0",
  "icon": "icon.svg",
  "ui": {
    "dashboard-tab": {
      "title": "My Extension",
      "root": "/ui",
      "src": "index.html"
    }
  }
}
```

4. Develop the UI (using React, Vue, or other frameworks):

```jsx
// src/App.jsx
import React from 'react';
import { DockerDesktopClient } from '@docker/extension-api-client';

const client = new DockerDesktopClient();

function App() {
  const handleClick = async () => {
    const result = await client.docker.cli.exec('ps', ['-a']);
    console.log(result);
  };

  return (
    <div>
      <h1>My Docker Extension</h1>
      <button onClick={handleClick}>List Containers</button>
    </div>
  );
}

export default App;
```

#### Building and Installing Extensions

To build and install your extension:

```bash
# Build the extension
docker build -t myorg/my-extension:latest .

# Install the extension
docker extension install myorg/my-extension:latest

# Update the extension during development
docker extension update myorg/my-extension:latest
```

#### Extension API

Docker Desktop extensions can interact with Docker through the Extension API:

```javascript
import { createDockerDesktopClient } from '@docker/extension-api-client';

const client = createDockerDesktopClient();

// Execute Docker CLI commands
const output = await client.docker.cli.exec('container', ['ls']);

// Interact with the Docker Engine API
const containers = await client.docker.listContainers();

// Access host functionality
const result = await client.host.openExternal('https://docker.com');
```

#### Extension VM Access

Extensions can access the Docker Desktop VM (where containers run):

```javascript
// Execute commands in the VM
const result = await client.extension.vm.cli.exec('ls', ['-la']);
```

#### Backend Services

Complex extensions may need backend services running in containers:

```json
// metadata.json
{
  "vm": {
    "composefile": "docker-compose.yaml"
  }
}
```

```yaml
# docker-compose.yaml
version: '3.9'
services:
  backend:
    image: ${DESKTOP_PLUGIN_IMAGE}
    restart: always
    ports:
      - "8080:8080"
```

#### Publishing Extensions

1. Push the extension image to a registry:

```bash
docker push myorg/my-extension:latest
```

2. Submit to Docker Hub (for public extensions):
    - Create a Docker Hub account
    - Go to Docker Hub's Extension Marketplace
    - Submit your extension for review

### Building Custom Docker Tooling

Beyond Docker Desktop extensions, developers can create custom tooling for Docker through various interfaces and SDKs.

#### Docker Engine API Integration

Custom tools can interact directly with the Docker Engine API:

```python
import docker

client = docker.from_env()

# List containers
containers = client.containers.list()

# Run a container
container = client.containers.run("alpine", "echo hello world", detach=True)

# Get container logs
logs = container.logs()
```

#### SDK Use Cases

- Container monitoring tools
- Resource optimization utilities
- CI/CD pipeline integrations
- Security scanning tools
- Custom container management interfaces

#### Authentication and Authorization

When building tools that interact with Docker, authentication is important:

```python
import docker

# Using environment variables
client = docker.from_env()

# Using explicit credentials
client = docker.DockerClient(
    base_url='tcp://remote-docker-host:2375',
    tls=docker.tls.TLSConfig(
        client_cert=('/path/to/cert.pem', '/path/to/key.pem')
    )
)
```

#### Building Context-Aware Tools

Docker context allows tools to work across different environments:

```python
import docker

# List available contexts
client = docker.from_env()
contexts = client.contexts.list()

# Switch context
client.contexts.use('my-remote-context')

# Now operations use the remote context
containers = client.containers.list()
```

#### WebAssembly Extensions

Experimental support for WebAssembly (Wasm) allows for portable extensions:

```rust
// Rust extension compiled to Wasm
#[no_mangle]
pub extern "C" fn list_containers() -> *mut c_char {
    // Implementation
}
```

### Docker CLI Plugins

Docker CLI plugins extend the functionality of the Docker command-line interface, adding new subcommands to the Docker CLI.

#### CLI Plugin Architecture

Docker CLI plugins follow a simple architecture:

- Executable files with names in the format `docker-<command>`
- Installed in one of the directories in the PATH
- Executed when users run `docker <command>`

#### Creating a Basic CLI Plugin

1. Create a script or executable named `docker-hello`:

```bash
#!/bin/bash
set -e

if [ "$1" = "--help" ]; then
  echo "Usage: docker hello [NAME]"
  echo "Say hello from a Docker CLI plugin"
  exit 0
fi

echo "Hello from Docker CLI Plugin! Args: $@"
```

2. Make it executable and move it to a directory in your PATH:

```bash
chmod +x docker-hello
sudo mv docker-hello /usr/local/bin/
```

3. Use the plugin:

```bash
docker hello world
```

#### Implementing a Go-Based CLI Plugin

For more complex plugins, Go is recommended:

```go
package main

import (
  "fmt"
  "os"
)

func main() {
  if len(os.Args) > 1 && os.Args[1] == "--help" {
    fmt.Println("Usage: docker demo [OPTIONS]")
    fmt.Println("Demo plugin for Docker CLI")
    os.Exit(0)
  }
  
  fmt.Println("Hello from the Docker CLI Demo plugin!")
}
```

Compile and install:

```bash
go build -o docker-demo
sudo mv docker-demo /usr/local/bin/
```

#### Plugin Metadata

CLI plugins can provide metadata to integrate better with Docker:

```go
package main

import (
  "encoding/json"
  "fmt"
  "os"
)

type pluginMetadata struct {
  SchemaVersion    string `json:"SchemaVersion"`
  Vendor           string `json:"Vendor"`
  Version          string `json:"Version"`
  ShortDescription string `json:"ShortDescription"`
  URL              string `json:"URL"`
}

func main() {
  if len(os.Args) > 1 && os.Args[1] == "docker-cli-plugin-metadata" {
    metadata := pluginMetadata{
      SchemaVersion:    "0.1.0",
      Vendor:           "My Organization",
      Version:          "0.1.0",
      ShortDescription: "My custom Docker CLI plugin",
      URL:              "https://github.com/myorg/docker-plugin",
    }
    json.NewEncoder(os.Stdout).Encode(metadata)
    os.Exit(0)
  }
  
  fmt.Println("Hello from my Docker CLI plugin!")
}
```

#### Interacting with Docker Engine

CLI plugins often need to interact with the Docker Engine:

```go
package main

import (
  "context"
  "fmt"
  "os"
  
  "github.com/docker/docker/api/types"
  "github.com/docker/docker/client"
)

func main() {
  if len(os.Args) > 1 && os.Args[1] == "list" {
    cli, err := client.NewClientWithOpts(client.FromEnv)
    if err != nil {
      fmt.Fprintf(os.Stderr, "Error creating Docker client: %s\n", err)
      os.Exit(1)
    }
    
    containers, err := cli.ContainerList(context.Background(), types.ContainerListOptions{})
    if err != nil {
      fmt.Fprintf(os.Stderr, "Error listing containers: %s\n", err)
      os.Exit(1)
    }
    
    fmt.Println("Running containers:")
    for _, container := range containers {
      fmt.Printf("%s - %s\n", container.ID[:12], container.Image)
    }
    os.Exit(0)
  }
  
  fmt.Println("Usage: docker myPlugin list")
}
```

#### Real-World CLI Plugin Examples

##### BuildKit Plugin

```go
package main

import (
  "context"
  "fmt"
  "os"
  "os/exec"
)

func main() {
  if len(os.Args) > 1 && os.Args[1] == "build" {
    args := []string{"buildx", "build"}
    args = append(args, os.Args[2:]...)
    
    cmd := exec.CommandContext(context.Background(), "docker", args...)
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    cmd.Stdin = os.Stdin
    
    if err := cmd.Run(); err != nil {
      os.Exit(1)
    }
    os.Exit(0)
  }
  
  fmt.Println("Usage: docker fastbuild [OPTIONS] PATH")
}
```

##### Container Stats Plugin

```go
package main

import (
  "context"
  "fmt"
  "os"
  "text/tabwriter"
  "time"
  
  "github.com/docker/docker/api/types"
  "github.com/docker/docker/client"
)

func main() {
  if len(os.Args) > 1 && os.Args[1] == "stats" {
    cli, err := client.NewClientWithOpts(client.FromEnv)
    if err != nil {
      fmt.Fprintf(os.Stderr, "Error: %s\n", err)
      os.Exit(1)
    }
    
    ctx := context.Background()
    containers, err := cli.ContainerList(ctx, types.ContainerListOptions{})
    if err != nil {
      fmt.Fprintf(os.Stderr, "Error: %s\n", err)
      os.Exit(1)
    }
    
    w := tabwriter.NewWriter(os.Stdout, 10, 1, 3, ' ', 0)
    fmt.Fprintln(w, "CONTAINER ID\tNAME\tCPU %\tMEM USAGE / LIMIT\tMEM %")
    
    for _, container := range containers {
      stats, err := cli.ContainerStats(ctx, container.ID, false)
      if err != nil {
        continue
      }
      
      var statsJSON types.StatsJSON
      decoder := json.NewDecoder(stats.Body)
      err = decoder.Decode(&statsJSON)
      stats.Body.Close()
      
      if err != nil {
        continue
      }
      
      cpuPercent := calculateCPUPercentUnix(statsJSON)
      memUsage := float64(statsJSON.MemoryStats.Usage)
      memLimit := float64(statsJSON.MemoryStats.Limit)
      memPercent := memUsage / memLimit * 100.0
      
      fmt.Fprintf(w, "%s\t%s\t%.2f%%\t%s / %s\t%.2f%%\n",
        container.ID[:12],
        container.Names[0][1:],
        cpuPercent,
        formatBytes(memUsage),
        formatBytes(memLimit),
        memPercent,
      )
    }
    w.Flush()
    os.Exit(0)
  }
  
  fmt.Println("Usage: docker extrastats")
}

func calculateCPUPercentUnix(stats types.StatsJSON) float64 {
  // CPU percentage calculation logic
  // ...
}

func formatBytes(bytes float64) string {
  // Format bytes to human-readable string
  // ...
}
```

#### Distribution and Installation

For public CLI plugins:

1. Host the compiled binaries in GitHub releases or similar
2. Create installation instructions:

```bash
# For scripts
curl -fsSL https://example.com/docker-plugin.sh -o docker-plugin
chmod +x docker-plugin
sudo mv docker-plugin /usr/local/bin/docker-plugin

# For compiled binaries
curl -fsSL https://example.com/docker-plugin-$(uname -s)-$(uname -m) -o docker-plugin
chmod +x docker-plugin
sudo mv docker-plugin /usr/local/bin/docker-plugin
```

### Advanced Extension Features

#### Debugging Extensions

Docker Desktop extensions can be debugged using browser developer tools:

1. Open Docker Desktop
2. Press Shift+Control+I (or Command+Option+I on macOS)
3. Use the Chrome DevTools to debug your extension

For CLI plugins:

```bash
# Enable verbose logging
DOCKER_DEBUG=1 docker myplugin command
```

#### Extension Settings Management

Store and retrieve user settings:

```javascript
// Save settings
await client.extension.vm.service.post('/settings', { key: 'value' });

// Retrieve settings
const settings = await client.extension.vm.service.get('/settings');
```

#### Inter-Extension Communication

Extensions can communicate via Docker Desktop's extension API:

```javascript
// Extension A publishes an event
client.extension.host.postMessage('my-custom-event', { data: 'value' });

// Extension B subscribes to the event
client.extension.host.onMessage('my-custom-event', (data) => {
  console.log('Received data:', data);
});
```

#### Advanced UI Techniques

Leveraging Docker Desktop's UI components:

```jsx
import { 
  Button, 
  Table, 
  Select, 
  TextField,
  Container,
  Drawer,
  Typography 
} from '@docker/extension-ui-components';

function MyExtensionUI() {
  return (
    <Container>
      <Typography variant="h3">My Extension</Typography>
      <Table 
        data={containers} 
        columns={[
          { key: 'id', header: 'ID' },
          { key: 'name', header: 'Name' }
        ]} 
      />
      <Button variant="contained" onClick={handleAction}>
        Perform Action
      </Button>
    </Container>
  );
}
```

#### Security Best Practices

When developing Docker extensions:

- Avoid requesting unnecessary permissions
- Use Docker's security context for isolation
- Implement proper authentication for APIs
- Follow the principle of least privilege
- Validate and sanitize all user inputs
- Use signed images for distribution

**Example**:

Secure API endpoint implementation:

```javascript
app.post('/api/action', (req, res) => {
  // Validate inputs
  const { command } = req.body;
  
  // Whitelist allowed commands
  const allowedCommands = ['status', 'list', 'info'];
  if (!allowedCommands.includes(command)) {
    return res.status(400).json({ error: 'Invalid command' });
  }
  
  // Execute with proper sanitization
  exec(`docker ${command}`, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: stderr });
    }
    res.json({ result: stdout });
  });
});
```

**Conclusion**:

Docker extension development offers powerful ways to enhance and customize the Docker ecosystem. Whether building Docker Desktop extensions with rich UIs, creating CLI plugins for specialized workflows, or developing custom tooling through the Docker API, developers can extend Docker's functionality to meet specific needs. By following the patterns and best practices outlined here, you can create robust, secure, and user-friendly extensions that integrate seamlessly with Docker's existing tools and workflows. As the Docker extension ecosystem continues to grow, these integration points provide opportunities to build innovative solutions that enhance container development and operations.

---

