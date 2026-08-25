## Docker API and SDK


### Introduction to Docker API

The Docker Engine API is a RESTful API that provides programmatic access to Docker daemon functionality, allowing developers to automate, integrate, and extend Docker capabilities through code. This API serves as the foundation for Docker client tools and enables building custom solutions for container management.

**Key Points**:

- RESTful HTTP API exposed by the Docker daemon
- Provides full control over Docker objects (containers, images, networks, volumes)
- Enables automation and custom tooling
- Versioned for backward compatibility
- Supports both local and remote connections
- Serves as the foundation for Docker CLI and other official tools

### Docker Engine API

The Docker Engine API exposes Docker's functionality through a comprehensive set of HTTP endpoints that allow interaction with all aspects of the Docker engine.

**Key Points**:

- Access to container lifecycle management (create, start, stop, remove)
- Image operations (build, pull, push, tag)
- Network and volume management
- System information and monitoring
- Resource management and configuration
- Support for Docker Swarm operations
- Authentication and access control

#### API Basics

The Docker API follows RESTful principles, using HTTP methods for different operations and returning JSON responses.

**Example** of basic API usage with curl:

```bash
# Get Docker version information
curl --unix-socket /var/run/docker.sock http://localhost/version

# List all containers
curl --unix-socket /var/run/docker.sock http://localhost/v1.41/containers/json

# Create a new container
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"Image":"nginx:alpine","ExposedPorts":{"80/tcp":{}},"HostConfig":{"PortBindings":{"80/tcp":[{"HostPort":"8080"}]}}}' \
  http://localhost/v1.41/containers/create?name=api-nginx

# Start a container
curl -X POST --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/containers/api-nginx/start

# Inspect a container
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/containers/api-nginx/json
```

#### API Authentication

For remote API access, securing the API with TLS certificates is essential.

**Example** of accessing a secure Docker API:

```bash
# Generate certificates (as shown in previous sections)

# Access secure API with TLS certificates
curl --cert ./cert.pem --key ./key.pem --cacert ./ca.pem \
  https://docker-host:2376/v1.41/containers/json

# Using environment variables with curl
export DOCKER_CERT_PATH=~/.docker/machine/machines/default
export DOCKER_HOST=tcp://192.168.99.100:2376
export DOCKER_TLS_VERIFY=1

curl --cert $DOCKER_CERT_PATH/cert.pem \
  --key $DOCKER_CERT_PATH/key.pem \
  --cacert $DOCKER_CERT_PATH/ca.pem \
  https://${DOCKER_HOST#tcp://}/v1.41/containers/json
```

#### Container Operations

The API provides comprehensive control over container lifecycle management.

**Example** of container operations:

```bash
# Create a container
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{
    "Image": "ubuntu:20.04",
    "Cmd": ["bash", "-c", "echo hello world"],
    "HostConfig": {
      "AutoRemove": true
    }
  }' \
  http://localhost/v1.41/containers/create?name=test-container

# Start container
curl -X POST --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/containers/test-container/start

# Get container logs
curl --unix-socket /var/run/docker.sock \
  "http://localhost/v1.41/containers/test-container/logs?stdout=1&stderr=1"

# Inspect container
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/containers/test-container/json

# Execute a command in a running container
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"AttachStdin": false, "AttachStdout": true, "AttachStderr": true, "Cmd": ["ls", "-la"]}' \
  http://localhost/v1.41/containers/test-container/exec

# Stop container
curl -X POST --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/containers/test-container/stop

# Remove container
curl -X DELETE --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/containers/test-container
```

#### Image Operations

The API enables full management of Docker images.

**Example** of image operations:

```bash
# List images
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/images/json

# Pull an image
curl -X POST --unix-socket /var/run/docker.sock \
  "http://localhost/v1.41/images/create?fromImage=alpine&tag=latest"

# Build an image from a Dockerfile
# First, prepare a tar archive with the build context
tar -cf context.tar Dockerfile app/

# Then, build using the API
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/tar" \
  --data-binary '@context.tar' \
  "http://localhost/v1.41/build?t=myapp:latest"

# Push an image to a registry
curl -X POST --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/images/myapp/push?tag=latest

# Tag an image
curl -X POST --unix-socket /var/run/docker.sock \
  "http://localhost/v1.41/images/myapp:latest/tag?repo=registry.example.com/myapp&tag=v1.0"

# Delete an image
curl -X DELETE --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/images/myapp:latest
```

#### Network Operations

The API provides control over Docker's networking capabilities.

**Example** of network operations:

```bash
# List networks
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/networks

# Create a network
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "my-network",
    "Driver": "bridge",
    "IPAM": {
      "Config": [{"Subnet": "172.20.0.0/16", "Gateway": "172.20.0.1"}]
    }
  }' \
  http://localhost/v1.41/networks/create

# Inspect a network
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/networks/my-network

# Connect a container to a network
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"Container":"test-container"}' \
  http://localhost/v1.41/networks/my-network/connect

# Disconnect a container from a network
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"Container":"test-container"}' \
  http://localhost/v1.41/networks/my-network/disconnect

# Remove a network
curl -X DELETE --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/networks/my-network
```

#### Volume Operations

The API allows management of Docker volumes for persistent data storage.

**Example** of volume operations:

```bash
# List volumes
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/volumes

# Create a volume
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "data-volume",
    "Driver": "local",
    "DriverOpts": {},
    "Labels": {"app": "myapp"}
  }' \
  http://localhost/v1.41/volumes/create

# Inspect a volume
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/volumes/data-volume

# Remove a volume
curl -X DELETE --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/volumes/data-volume

# Prune unused volumes
curl -X POST --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/volumes/prune
```

#### System Operations

The API provides various system-level operations and information.

**Example** of system operations:

```bash
# Get system information
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/info

# Get disk usage information
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/system/df

# Get Docker events (streaming)
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/events

# Get container stats
curl --unix-socket /var/run/docker.sock \
  http://localhost/v1.41/containers/test-container/stats?stream=false

# Ping the Docker daemon
curl --unix-socket /var/run/docker.sock \
  http://localhost/_ping
```

### Docker SDK for Various Languages

Docker provides official SDKs and community-maintained libraries for various programming languages, simplifying Docker integration in applications without directly dealing with the HTTP API.

**Key Points**:

- Abstracts the HTTP API behind language-specific methods
- Official SDKs for Go, Python, and Java
- Community-maintained libraries for many other languages
- Simplifies error handling and data parsing
- Provides type safety and IDE integration
- Handles authentication and connection management

#### Docker SDK for Python (docker-py)

Python's Docker SDK is one of the most mature and widely used client libraries.

**Example** of basic operations with docker-py:

```python
import docker

# Connect to Docker daemon
client = docker.from_env()

# List containers
containers = client.containers.list()
print(f"Running containers: {len(containers)}")
for container in containers:
    print(f"Container: {container.name}, ID: {container.short_id}, Image: {container.image.tags}")

# Run a new container
container = client.containers.run(
    "alpine:latest",
    "echo Hello from Docker Python SDK",
    remove=True,
    detach=False
)
print(f"Container output: {container.decode('utf-8')}")

# Pull an image
image = client.images.pull("nginx:latest")
print(f"Pulled image: {image.tags}")

# Create and start a container
container = client.containers.create(
    "nginx:latest",
    name="nginx-test",
    ports={"80/tcp": 8080}
)
container.start()
print(f"Started container: {container.name}, Status: {container.status}")

# Execute a command in a running container
exec_result = container.exec_run("uname -a")
print(f"Exec result: {exec_result.output.decode('utf-8')}")

# Stop and remove the container
container.stop()
container.remove()
print("Container stopped and removed")
```

**Example** of monitoring Docker events with docker-py:

```python
import docker
import json

client = docker.from_env()

# Listen for Docker events
for event in client.events(decode=True):
    print(f"Event Type: {event['Type']}, Action: {event['Action']}")
    print(json.dumps(event, indent=2))
    
    # Filter for specific events
    if event['Type'] == 'container' and event['Action'] == 'start':
        container_id = event['Actor']['ID']
        container = client.containers.get(container_id)
        print(f"Container started: {container.name}")
```

#### Docker SDK for Go

Go's Docker SDK is the official client package used by the Docker CLI itself.

**Example** of basic operations with Go SDK:

```go
package main

import (
	"context"
	"fmt"
	"io"
	"os"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
	"github.com/docker/go-connections/nat"
)

func main() {
	ctx := context.Background()
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		panic(err)
	}

	// List containers
	containers, err := cli.ContainerList(ctx, types.ContainerListOptions{})
	if err != nil {
		panic(err)
	}

	fmt.Printf("Found %d containers\n", len(containers))
	for _, container := range containers {
		fmt.Printf("Container ID: %s, Image: %s, Status: %s\n", 
			container.ID[:10], container.Image, container.Status)
	}

	// Pull an image
	out, err := cli.ImagePull(ctx, "alpine:latest", types.ImagePullOptions{})
	if err != nil {
		panic(err)
	}
	defer out.Close()
	io.Copy(os.Stdout, out)

	// Create a container
	hostConfig := &container.HostConfig{
		PortBindings: nat.PortMap{
			"80/tcp": []nat.PortBinding{
				{
					HostIP:   "0.0.0.0",
					HostPort: "8080",
				},
			},
		},
	}

	resp, err := cli.ContainerCreate(ctx, &container.Config{
		Image: "nginx:latest",
		ExposedPorts: nat.PortSet{
			"80/tcp": struct{}{},
		},
	}, hostConfig, nil, nil, "nginx-test")
	if err != nil {
		panic(err)
	}

	// Start container
	if err := cli.ContainerStart(ctx, resp.ID, types.ContainerStartOptions{}); err != nil {
		panic(err)
	}

	fmt.Printf("Container started: %s\n", resp.ID)

	// Clean up
	fmt.Println("Stopping container...")
	if err := cli.ContainerStop(ctx, resp.ID, container.StopOptions{}); err != nil {
		panic(err)
	}

	fmt.Println("Removing container...")
	if err := cli.ContainerRemove(ctx, resp.ID, types.ContainerRemoveOptions{}); err != nil {
		panic(err)
	}
}
```

#### Docker SDK for Java

Java's Docker SDK provides comprehensive Docker functionality for Java applications.

**Example** of basic operations with Java SDK:

```java
import com.github.dockerjava.api.DockerClient;
import com.github.dockerjava.api.command.CreateContainerResponse;
import com.github.dockerjava.api.model.*;
import com.github.dockerjava.core.DockerClientBuilder;

public class DockerJavaExample {
    public static void main(String[] args) {
        // Create a Docker client
        DockerClient dockerClient = DockerClientBuilder.getInstance().build();

        // List containers
        List<Container> containers = dockerClient.listContainersCmd()
                .withShowAll(true)
                .exec();
        
        System.out.println("Found " + containers.size() + " containers");
        for (Container container : containers) {
            System.out.println("Container ID: " + container.getId().substring(0, 10) + 
                             ", Image: " + container.getImage() +
                             ", Status: " + container.getStatus());
        }

        // Pull an image
        dockerClient.pullImageCmd("nginx:latest")
                .exec(new PullImageResultCallback())
                .awaitCompletion();
        System.out.println("Image pulled: nginx:latest");

        // Create port bindings
        ExposedPort tcp80 = ExposedPort.tcp(80);
        Ports portBindings = new Ports();
        portBindings.bind(tcp80, Ports.Binding.bindPort(8080));

        // Create container
        CreateContainerResponse container = dockerClient.createContainerCmd("nginx:latest")
                .withName("nginx-test")
                .withExposedPorts(tcp80)
                .withHostConfig(new HostConfig().withPortBindings(portBindings))
                .exec();
        
        System.out.println("Container created: " + container.getId());

        // Start container
        dockerClient.startContainerCmd(container.getId()).exec();
        System.out.println("Container started");

        // Exec command in container
        ExecCreateCmdResponse execCreateCmdResponse = dockerClient.execCreateCmd(container.getId())
                .withAttachStdout(true)
                .withAttachStderr(true)
                .withCmd("uname", "-a")
                .exec();
        
        dockerClient.execStartCmd(execCreateCmdResponse.getId())
                .exec(new ExecStartResultCallback(System.out, System.err))
                .awaitCompletion();

        // Clean up
        dockerClient.stopContainerCmd(container.getId()).exec();
        System.out.println("Container stopped");
        
        dockerClient.removeContainerCmd(container.getId()).exec();
        System.out.println("Container removed");
    }
}
```

#### Docker SDK for Node.js (dockerode)

Dockerode is a popular Node.js library for Docker API.

**Example** of basic operations with dockerode:

```javascript
const Docker = require('dockerode');
const docker = new Docker();

// List containers
async function listContainers() {
  const containers = await docker.listContainers();
  console.log(`Found ${containers.length} containers`);
  
  containers.forEach(container => {
    console.log(`Container ID: ${container.Id.substring(0, 10)}, Image: ${container.Image}, Status: ${container.Status}`);
  });
}

// Run a container
async function runContainer() {
  console.log('Pulling image: alpine:latest');
  await new Promise((resolve, reject) => {
    docker.pull('alpine:latest', (err, stream) => {
      if (err) return reject(err);
      docker.modem.followProgress(stream, resolve);
    });
  });
  
  console.log('Creating container');
  const container = await docker.createContainer({
    Image: 'alpine:latest',
    Cmd: ['echo', 'Hello from Node.js Docker SDK'],
    HostConfig: {
      AutoRemove: true
    }
  });
  
  console.log('Starting container');
  await container.start();
  
  const output = await container.logs({
    follow: true,
    stdout: true,
    stderr: true
  });
  
  console.log('Container output:', output.toString());
}

// Create and manage a web server
async function createWebServer() {
  console.log('Creating nginx container');
  const container = await docker.createContainer({
    Image: 'nginx:latest',
    name: 'nginx-test',
    ExposedPorts: {
      '80/tcp': {}
    },
    HostConfig: {
      PortBindings: {
        '80/tcp': [{ HostPort: '8080' }]
      }
    }
  });
  
  console.log('Starting container');
  await container.start();
  
  console.log('Container running at http://localhost:8080');
  
  // Execute command inside container
  const exec = await container.exec({
    Cmd: ['uname', '-a'],
    AttachStdout: true,
    AttachStderr: true
  });
  
  const stream = await exec.start();
  stream.pipe(process.stdout);
  
  // Wait for 10 seconds then clean up
  setTimeout(async () => {
    console.log('Stopping container');
    await container.stop();
    
    console.log('Removing container');
    await container.remove();
    
    console.log('Container removed');
  }, 10000);
}

// Run the examples
async function runExamples() {
  try {
    await listContainers();
    await runContainer();
    await createWebServer();
  } catch (error) {
    console.error('Error:', error);
  }
}

runExamples();
```

### Building Tools with Docker API

The Docker API enables building custom tools, dashboards, and automation systems that integrate Docker functionality into larger workflows and applications.

**Key Points**:

- Enables custom management interfaces and dashboards
- Allows integration with CI/CD systems
- Enables infrastructure as code capabilities
- Facilitates custom monitoring and scaling solutions
- Enables application-specific container orchestration
- Provides integration with existing systems

#### Building a Container Management Dashboard

**Example** of a simple container management dashboard with Flask and docker-py:

```python
from flask import Flask, render_template, request, redirect, url_for
import docker
import json

app = Flask(__name__)
client = docker.from_env()

@app.route('/')
def index():
    containers = client.containers.list(all=True)
    images = client.images.list()
    
    container_data = []
    for container in containers:
        container_data.append({
            'id': container.short_id,
            'name': container.name,
            'image': container.image.tags[0] if container.image.tags else container.image.short_id,
            'status': container.status,
            'ports': container.ports
        })
    
    image_data = []
    for image in images:
        image_data.append({
            'id': image.short_id,
            'tags': image.tags,
            'created': image.attrs['Created'],
            'size': f"{image.attrs['Size'] / 1000000:.2f} MB"
        })
    
    return render_template('index.html', containers=container_data, images=image_data)

@app.route('/container/<id>/start')
def start_container(id):
    container = client.containers.get(id)
    container.start()
    return redirect(url_for('index'))

@app.route('/container/<id>/stop')
def stop_container(id):
    container = client.containers.get(id)
    container.stop()
    return redirect(url_for('index'))

@app.route('/container/<id>/remove')
def remove_container(id):
    container = client.containers.get(id)
    container.remove(force=True)
    return redirect(url_for('index'))

@app.route('/container/create', methods=['POST'])
def create_container():
    image = request.form.get('image')
    name = request.form.get('name')
    port_mapping = request.form.get('port_mapping')
    
    ports = {}
    if port_mapping:
        host_port, container_port = port_mapping.split(':')
        ports[f"{container_port}/tcp"] = int(host_port)
    
    client.containers.run(
        image,
        name=name,
        detach=True,
        ports=ports
    )
    
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
```

#### CI/CD Integration

**Example** of a simple CI/CD build service using the Docker API:

```python
import docker
import os
import git
import json
import logging
from flask import Flask, request, jsonify

app = Flask(__name__)
client = docker.from_env()
logging.basicConfig(level=logging.INFO)

@app.route('/webhook', methods=['POST'])
def webhook():
    # Parse webhook payload
    payload = request.json
    repo_url = payload['repository']['clone_url']
    repo_name = payload['repository']['name']
    branch = payload['ref'].split('/')[-1]
    commit = payload['after']
    
    logging.info(f"Received webhook for {repo_name}, branch: {branch}, commit: {commit}")
    
    # Clone repository
    repo_dir = f"/tmp/{repo_name}-{commit}"
    if os.path.exists(repo_dir):
        os.system(f"rm -rf {repo_dir}")
    
    git.Repo.clone_from(repo_url, repo_dir, branch=branch)
    logging.info(f"Cloned repository to {repo_dir}")
    
    # Check if Dockerfile exists
    if not os.path.exists(f"{repo_dir}/Dockerfile"):
        return jsonify({"status": "error", "message": "No Dockerfile found"})
    
    # Build Docker image
    tag = f"{repo_name}:{branch}-{commit[:7]}"
    logging.info(f"Building image: {tag}")
    
    try:
        image, logs = client.images.build(
            path=repo_dir,
            tag=tag,
            rm=True
        )
        
        # Push to registry if needed
        if 'DOCKER_REGISTRY' in os.environ:
            registry = os.environ['DOCKER_REGISTRY']
            registry_tag = f"{registry}/{tag}"
            image.tag(registry_tag)
            
            logging.info(f"Pushing image to registry: {registry_tag}")
            push_logs = client.images.push(registry_tag)
            
        # Deploy if needed
        if branch == 'main' or branch == 'master':
            logging.info(f"Deploying {tag}")
            try:
                # Stop existing container
                try:
                    old_container = client.containers.get(repo_name)
                    old_container.stop()
                    old_container.remove()
                    logging.info(f"Stopped and removed existing container: {repo_name}")
                except docker.errors.NotFound:
                    pass
                
                # Start new container
                container = client.containers.run(
                    tag,
                    name=repo_name,
                    detach=True,
                    restart_policy={"Name": "always"},
                    ports={80: 8080}  # Adjust as needed
                )
                logging.info(f"Deployed container: {container.short_id}")
            except Exception as e:
                logging.error(f"Deployment error: {str(e)}")
                return jsonify({"status": "error", "message": f"Deployment failed: {str(e)}"})
        
        return jsonify({
            "status": "success",
            "image": tag,
            "message": "Build and deployment successful"
        })
        
    except Exception as e:
        logging.error(f"Build error: {str(e)}")
        return jsonify({"status": "error", "message": f"Build failed: {str(e)}"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

#### Custom Resource Management

Custom resource management involves creating specialized tools to monitor, allocate, and optimize Docker resources beyond what Docker's built-in tools provide. This includes fine-grained control over CPU, memory, storage, and network resources across containers and services.

**Key Points**

- Enables granular resource allocation based on application priorities
- Helps prevent resource contention in multi-container environments
- Provides insights for capacity planning and optimization
- Allows implementation of custom policies for resource distribution
- Supports dynamic resource adjustment based on workload patterns

Custom resource management typically involves:

1. Collection of detailed resource metrics from containers
2. Analysis of resource utilization patterns
3. Implementation of allocation policies based on business requirements
4. Automation of resource adjustments based on predefined thresholds
5. Integration with monitoring and alerting systems

### Example of a Container Resource Monitoring and Management Tool

Let me complete the example code for the ContainerResourceMonitor class:

```python
import docker
import time
import psutil
import json
import logging
from datetime import datetime
import threading

logging.basicConfig(level=logging.INFO)
client = docker.from_env()

class ContainerResourceMonitor:
    def __init__(self):
        self.stats = {}
        self.running = True
        self.containers = {}
        self.autoscale_configs = {}

    def add_autoscale_config(self, container_name, max_cpu_percent=80, min_instances=1, max_instances=5):
        self.autoscale_configs[container_name] = {
            'max_cpu_percent': max_cpu_percent,
            'min_instances': min_instances,
            'max_instances': max_instances,
            'current_instances': 1  # assume 1 running initially
        }

    def monitor_container(self, container_id):
        try:
            container = client.containers.get(container_id)
            stats_stream = container.stats(stream=True, decode=True)

            for stat in stats_stream:
                if not self.running:
                    break

                # CPU Usage Calculation
                cpu_delta = stat['cpu_stats']['cpu_usage']['total_usage'] - \
                            stat['precpu_stats']['cpu_usage']['total_usage']
                system_delta = stat['cpu_stats']['system_cpu_usage'] - \
                               stat['precpu_stats']['system_cpu_usage']
                cpu_percent = 0.0
                if system_delta > 0 and cpu_delta > 0:
                    cpu_percent = (cpu_delta / system_delta) * len(stat['cpu_stats']['cpu_usage']['percpu_usage']) * 100.0

                # Memory Usage
                mem_usage = stat['memory_stats']['usage']
                mem_limit = stat['memory_stats']['limit']
                mem_percent = (mem_usage / mem_limit) * 100.0 if mem_limit else 0

                # Network I/O
                net_rx, net_tx = 0, 0
                if 'networks' in stat:
                    for iface_data in stat['networks'].values():
                        net_rx += iface_data['rx_bytes']
                        net_tx += iface_data['tx_bytes']

                # Save stats
                self.stats[container_id] = {
                    'name': container.name,
                    'cpu_percent': cpu_percent,
                    'mem_usage_mb': mem_usage / (1024 * 1024),
                    'mem_percent': mem_percent,
                    'net_rx_mb': net_rx / (1024 * 1024),
                    'net_tx_mb': net_tx / (1024 * 1024),
                    'timestamp': datetime.now().isoformat()
                }

                logging.info(f"Container {container.name}: CPU: {cpu_percent:.2f}% | Memory: {mem_percent:.2f}%")

                # Check autoscaling
                if container.name in self.autoscale_configs:
                    self.check_autoscale(container.name, cpu_percent)

                time.sleep(5)  # Delay between logs

        except Exception as e:
            logging.error(f"Error monitoring container {container_id}: {str(e)}")

    def check_autoscale(self, container_name, cpu_percent):
        config = self.autoscale_configs[container_name]
        current = config['current_instances']

        if cpu_percent > config['max_cpu_percent'] and current < config['max_instances']:
            logging.info(f"Scaling up {container_name} - CPU {cpu_percent:.2f}%")
            self.scale_service(container_name, current + 1)
            config['current_instances'] += 1

        elif cpu_percent < config['max_cpu_percent'] * 0.6 and current > config['min_instances']:
            logging.info(f"Scaling down {container_name} - CPU {cpu_percent:.2f}%")
            self.scale_service(container_name, current - 1)
            config['current_instances'] -= 1

    def scale_service(self, service_name, replicas):
        try:
            service = client.services.get(service_name)
            service.scale(replicas)
            logging.info(f"Service {service_name} scaled to {replicas} replicas")
        except docker.errors.APIError as e:
            logging.error(f"Failed to scale {service_name}: {str(e)}")

    def start_monitoring(self):
        while self.running:
            containers = client.containers.list()
            for container in containers:
                if container.id not in self.containers:
                    thread = threading.Thread(target=self.monitor_container, args=(container.id,), daemon=True)
                    thread.start()
                    self.containers[container.id] = thread
            time.sleep(10)

    def stop_monitoring(self):
        self.running = False
        for thread in self.containers.values():
            thread.join()
        logging.info("Stopped monitoring all containers.")
        
    def export_stats(self, filename=None):
        """Export current stats to JSON file or return as dictionary"""
        if filename:
            with open(filename, 'w') as f:
                json.dump(self.stats, f, indent=2)
            logging.info(f"Stats exported to {filename}")
        return self.stats
    
    def set_resource_limits(self, container_id, cpu_limit=None, memory_limit=None):
        """Update resource limits for a running container"""
        try:
            container = client.containers.get(container_id)
            update_config = {}
            
            if cpu_limit:
                update_config['cpu_quota'] = int(cpu_limit * 100000)
                update_config['cpu_period'] = 100000
                
            if memory_limit:  # memory limit in MB
                update_config['mem_limit'] = int(memory_limit * 1024 * 1024)
                
            if update_config:
                container.update(**update_config)
                logging.info(f"Updated resource limits for {container.name}: {update_config}")
                
        except docker.errors.APIError as e:
            logging.error(f"Failed to update resources for {container_id}: {str(e)}")
    
    def get_host_resources(self):
        """Get host machine resource usage"""
        return {
            'cpu_percent': psutil.cpu_percent(interval=1),
            'memory_percent': psutil.virtual_memory().percent,
            'disk_percent': psutil.disk_usage('/').percent,
            'timestamp': datetime.now().isoformat()
        }
        
    def optimize_placement(self):
        """Suggest optimal container placement based on resource usage"""
        host_resources = self.get_host_resources()
        container_resources = self.stats
        
        # Simple algorithm to identify overloaded containers
        overloaded = []
        underutilized = []
        
        for container_id, stats in container_resources.items():
            if stats['cpu_percent'] > 80 or stats['mem_percent'] > 80:
                overloaded.append((container_id, stats))
            elif stats['cpu_percent'] < 20 and stats['mem_percent'] < 20:
                underutilized.append((container_id, stats))
                
        recommendations = {
            'host_status': 'overloaded' if host_resources['cpu_percent'] > 80 else 'normal',
            'overloaded_containers': [c[1]['name'] for c in overloaded],
            'underutilized_containers': [c[1]['name'] for c in underutilized],
            'recommendations': []
        }
        
        # Generate recommendations
        if overloaded and host_resources['cpu_percent'] > 80:
            recommendations['recommendations'].append(
                "Consider migrating overloaded containers to another host"
            )
        
        if len(underutilized) > 3:
            recommendations['recommendations'].append(
                "Consider consolidating underutilized containers"
            )
            
        return recommendations


# Example usage
if __name__ == "__main__":
    monitor = ContainerResourceMonitor()
    
    # Configure autoscaling for a service
    monitor.add_autoscale_config("web-service", max_cpu_percent=70, min_instances=2, max_instances=10)
    
    # Start monitoring in background thread
    monitor_thread = threading.Thread(target=monitor.start_monitoring)
    monitor_thread.daemon = True
    monitor_thread.start()
    
    try:
        # Example resource management operations
        while True:
            # Get host stats every 30 seconds
            host_stats = monitor.get_host_resources()
            logging.info(f"Host resources: CPU {host_stats['cpu_percent']}%, Memory {host_stats['memory_percent']}%")
            
            # Check for optimization opportunities every 5 minutes
            if int(time.time()) % 300 < 10:  # Every 5 minutes approximately
                recommendations = monitor.optimize_placement()
                if recommendations['recommendations']:
                    logging.info(f"Optimization recommendations: {recommendations['recommendations']}")
            
            # Export stats every hour
            if int(time.time()) % 3600 < 10:  # Every hour approximately
                monitor.export_stats(f"container_stats_{datetime.now().strftime('%Y%m%d_%H%M')}.json")
                
            time.sleep(30)
            
    except KeyboardInterrupt:
        logging.info("Shutting down resource monitor...")
        monitor.stop_monitoring()
```

### Webhooks and Event Monitoring

Docker webhooks and event monitoring provide a mechanism for real-time notification and response to Docker events, enabling automation, auditing, and integration with external systems.

**Key Points**

- Enables real-time automation based on Docker events
- Facilitates integration with external monitoring and alerting systems
- Supports audit logging and compliance requirements
- Allows for event-driven architectures in container environments
- Provides insights into container lifecycle events

#### Event Types

Docker events can be categorized into several types:

1. Container events (create, start, stop, die, destroy)
2. Image events (pull, push, delete)
3. Volume events (create, mount, unmount)
4. Network events (create, connect, disconnect)
5. Daemon events (reload)

#### Implementing a Docker Event Monitor with Webhooks

Here's a comprehensive implementation of a Docker event monitoring system with webhook integration:

```python
import docker
import requests
import json
import logging
import threading
import time
import argparse
from datetime import datetime
from flask import Flask, request, jsonify

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("docker_events.log"),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger("DockerEventMonitor")

# Flask app for webhook receivers
app = Flask(__name__)
webhook_subscribers = []

class DockerEventMonitor:
    def __init__(self):
        self.client = docker.from_env()
        self.running = True
        self.event_filters = {}
        self.event_handlers = {
            'container': self.handle_container_event,
            'image': self.handle_image_event,
            'volume': self.handle_volume_event,
            'network': self.handle_network_event,
            'daemon': self.handle_daemon_event
        }
        self.event_history = []
        self.max_history = 1000
        
    def set_filters(self, filters=None):
        """Set filters for events to monitor"""
        self.event_filters = filters or {}
        
    def start_monitoring(self):
        """Start monitoring Docker events"""
        logger.info("Starting Docker event monitoring")
        try:
            for event in self.client.events(decode=True, filters=self.event_filters):
                if not self.running:
                    break
                    
                # Add timestamp for internal tracking
                event['received_at'] = datetime.now().isoformat()
                
                # Store in history
                self.event_history.append(event)
                if len(self.event_history) > self.max_history:
                    self.event_history.pop(0)
                
                # Process event
                self.process_event(event)
                
        except Exception as e:
            logger.error(f"Error in event monitoring: {str(e)}")
            
    def process_event(self, event):
        """Process a Docker event"""
        event_type = event.get('Type', '')
        event_action = event.get('Action', '')
        
        logger.info(f"Event: {event_type} - {event_action}")
        
        # Call specific handler based on event type
        if event_type in self.event_handlers:
            self.event_handlers[event_type](event)
        
        # Send to all webhook subscribers
        self.send_webhooks(event)
        
    def handle_container_event(self, event):
        """Handle container-specific events"""
        action = event.get('Action', '')
        attrs = event.get('Actor', {}).get('Attributes', {})
        container_name = attrs.get('name', 'unknown')
        
        if action == 'die':
            exit_code = attrs.get('exitCode', 'unknown')
            if exit_code != '0':
                logger.warning(f"Container {container_name} exited with code {exit_code}")
                # Could trigger alerts here
        
        elif action == 'start':
            logger.info(f"Container {container_name} started")
            
        elif action == 'health_status':
            health_status = attrs.get('health_status', 'unknown')
            logger.info(f"Container {container_name} health status: {health_status}")
            if health_status == 'unhealthy':
                logger.warning(f"Container {container_name} is unhealthy")
                # Could trigger remediation here
    
    def handle_image_event(self, event):
        """Handle image-specific events"""
        action = event.get('Action', '')
        attrs = event.get('Actor', {}).get('Attributes', {})
        image_name = attrs.get('name', 'unknown')
        
        if action == 'pull':
            logger.info(f"Image pulled: {image_name}")
        elif action == 'delete':
            logger.info(f"Image deleted: {image_name}")
    
    def handle_volume_event(self, event):
        """Handle volume-specific events"""
        action = event.get('Action', '')
        attrs = event.get('Actor', {}).get('Attributes', {})
        volume_name = attrs.get('name', 'unknown')
        
        logger.info(f"Volume {action}: {volume_name}")
    
    def handle_network_event(self, event):
        """Handle network-specific events"""
        action = event.get('Action', '')
        attrs = event.get('Actor', {}).get('Attributes', {})
        network_name = attrs.get('name', 'unknown')
        
        logger.info(f"Network {action}: {network_name}")
    
    def handle_daemon_event(self, event):
        """Handle daemon-specific events"""
        action = event.get('Action', '')
        logger.info(f"Daemon event: {action}")
    
    def send_webhooks(self, event):
        """Send event data to all registered webhooks"""
        for webhook in webhook_subscribers:
            try:
                response = requests.post(
                    webhook['url'],
                    json={
                        'event': event,
                        'timestamp': datetime.now().isoformat()
                    },
                    headers={
                        'Content-Type': 'application/json',
                        'X-Docker-Event': f"{event.get('Type', '')}.{event.get('Action', '')}"
                    },
                    timeout=5
                )
                
                if response.status_code >= 400:
                    logger.warning(f"Webhook delivery failed to {webhook['url']}: {response.status_code}")
            except Exception as e:
                logger.error(f"Error sending webhook to {webhook['url']}: {str(e)}")
    
    def stop_monitoring(self):
        """Stop monitoring Docker events"""
        self.running = False
        logger.info("Stopped Docker event monitoring")
    
    def get_recent_events(self, limit=100, event_type=None, action=None):
        """Get recent events with optional filtering"""
        filtered_events = self.event_history
        
        if event_type:
            filtered_events = [e for e in filtered_events if e.get('Type') == event_type]
            
        if action:
            filtered_events = [e for e in filtered_events if e.get('Action') == action]
            
        return filtered_events[-limit:]


# Flask routes for webhook management
@app.route('/webhooks', methods=['POST'])
def register_webhook():
    """Register a new webhook"""
    data = request.json
    if not data or 'url' not in data:
        return jsonify({'error': 'URL is required'}), 400
        
    webhook_subscribers.append({
        'url': data['url'],
        'description': data.get('description', ''),
        'registered_at': datetime.now().isoformat()
    })
    
    logger.info(f"Registered new webhook: {data['url']}")
    return jsonify({'status': 'success', 'message': 'Webhook registered'}), 201

@app.route('/webhooks', methods=['GET'])
def list_webhooks():
    """List all registered webhooks"""
    return jsonify({'webhooks': webhook_subscribers})

@app.route('/webhooks/<int:webhook_id>', methods=['DELETE'])
def delete_webhook(webhook_id):
    """Delete a registered webhook"""
    if webhook_id < 0 or webhook_id >= len(webhook_subscribers):
        return jsonify({'error': 'Webhook not found'}), 404
        
    deleted = webhook_subscribers.pop(webhook_id)
    logger.info(f"Deleted webhook: {deleted['url']}")
    
    return jsonify({'status': 'success', 'message': 'Webhook deleted'})

@app.route('/events', methods=['GET'])
def get_events():
    """Get recent events with optional filtering"""
    limit = int(request.args.get('limit', 100))
    event_type = request.args.get('type')
    action = request.args.get('action')
    
    events = docker_monitor.get_recent_events(limit, event_type, action)
    return jsonify({'events': events})


# Main function to run the application
def main():
    parser = argparse.ArgumentParser(description='Docker Event Monitor with Webhook Integration')
    parser.add_argument('--port', type=int, default=5000, help='Port for webhook server')
    parser.add_argument('--filter-type', help='Filter events by type (container, image, volume, etc.)')
    parser.add_argument('--filter-action', help='Filter events by action (start, stop, etc.)')
    args = parser.parse_args()
    
    # Set up event filters
    filters = {}
    if args.filter_type:
        filters['type'] = args.filter_type
    if args.filter_action:
        filters['event'] = args.filter_action
    
    # Initialize and start Docker event monitor
    global docker_monitor
    docker_monitor = DockerEventMonitor()
    docker_monitor.set_filters(filters)
    
    monitor_thread = threading.Thread(target=docker_monitor.start_monitoring)
    monitor_thread.daemon = True
    monitor_thread.start()
    
    # Start Flask server for webhooks
    logger.info(f"Starting webhook server on port {args.port}")
    app.run(host='0.0.0.0', port=args.port)


if __name__ == "__main__":
    main()
```

**Output**

When running the Docker Event Monitoring system with webhook integration, you can expect the following output in the logs:

```
2025-05-12 10:15:32 - DockerEventMonitor - INFO - Starting Docker event monitoring
2025-05-12 10:15:32 - DockerEventMonitor - INFO - Starting webhook server on port 5000
2025-05-12 10:15:35 - DockerEventMonitor - INFO - Event: container - start
2025-05-12 10:15:35 - DockerEventMonitor - INFO - Container web-app started
2025-05-12 10:16:42 - DockerEventMonitor - INFO - Event: image - pull
2025-05-12 10:16:42 - DockerEventMonitor - INFO - Image pulled: nginx:latest
2025-05-12 10:17:15 - DockerEventMonitor - INFO - Registered new webhook: http://alerting-service:8080/docker-events
2025-05-12 10:18:20 - DockerEventMonitor - WARNING - Container database health status: unhealthy
```

#### Advanced Event Monitoring Features

Beyond basic event capture and webhook delivery, a comprehensive Docker event monitoring system can include:

1. **Event correlation and pattern recognition**
    - Identifying patterns across multiple events
    - Detecting anomalous sequences of events
2. **Intelligent alerting**
    - Prioritizing alerts based on severity
    - Rate limiting for frequent events
    - Alert routing to appropriate teams
3. **Automated remediation**
    - Self-healing responses to common issues
    - Rollback capabilities for failed deployments
    - Automated scaling based on event patterns
4. **Compliance and audit capabilities**
    - Secure storage of event logs
    - Chain-of-custody tracking for sensitive operations
    - Compliance reporting based on event history
5. **Integration with external systems**
    - CI/CD pipeline integration
    - ITSM ticket creation
    - ChatOps notifications

**Conclusion**

Docker's API and SDK provide powerful capabilities for building custom tools to manage, monitor, and optimize containerized applications. By leveraging the Docker API, developers can create specialized solutions that extend Docker's native capabilities to meet specific organizational requirements. Custom resource management and comprehensive event monitoring are critical components of a mature container platform, enabling organizations to achieve better resource utilization, faster incident response, and improved operational visibility.

---

