## Docker Compose Introduction


### Purpose and Benefits

Docker Compose is a tool for defining and running multi-container Docker applications. It uses YAML files to configure application services and performs the creation and startup of all the containers with a single command.

#### Core Functions

Docker Compose simplifies the management of multi-container applications by:

- Defining the entire application stack in a declarative file
- Managing container lifecycle operations across multiple services
- Creating isolated environments with custom networks and volumes
- Preserving volume data when containers are created

#### Key Benefits

**Simplified Configuration**

Docker Compose replaces long docker run commands with declarative YAML configuration:

Instead of:

```bash
docker run -d --name db -v db-data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=secret postgres:14
docker run -d --name backend --link db -p 8000:8000 -v $(pwd):/code myapp:latest
docker run -d --name frontend --link backend -p 3000:3000 myapp-frontend:latest
```

You can define:

```yaml
services:
  db:
    image: postgres:14
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: secret
  backend:
    image: myapp:latest
    ports:
      - "8000:8000"
    volumes:
      - .:/code
  frontend:
    image: myapp-frontend:latest
    ports:
      - "3000:3000"
volumes:
  db-data:
```

**Orchestration and Dependency Management**

Compose handles service dependencies, ensuring containers start in the correct order through:

- `depends_on` relationships
- Health checks for dependency readiness
- Parallel service startup for unrelated services

**Consistent Development Environments**

Compose helps maintain consistency across development, testing, and CI environments by:

- Ensuring all team members use identical service configurations
- Reducing "works on my machine" problems
- Enabling quick environment reproduction

**Efficient Development Workflow**

Compose streamlines development workflows through:

- Single command to start all services (`docker-compose up`)
- Automatic rebuilding of changed services
- Volume mounting for code changes without rebuilds
- Environment variable handling for different contexts

**Isolated Environments**

Each Compose project creates isolated environments with:

- Project-specific networks
- Named volumes for persistence
- Container namespacing to prevent conflicts

**Common Use Cases**

- Local development environments
- Automated testing in CI/CD pipelines
- Single-host deployments for small to medium applications
- Demonstrations and proof-of-concept implementations
- Microservices application development

**Key Points:**

- Docker Compose is primarily designed for development and testing
- For production multi-host deployments, Kubernetes or Docker Swarm are typically used
- Compose simplifies the transition from development to production
- Docker Compose does not replace container orchestration systems

### Docker Compose YAML Format and Versions

Docker Compose configuration is defined in YAML files (typically named `docker-compose.yml` or `compose.yaml`), which specify all the components and configurations for your application.

#### File Structure

A basic docker-compose.yml file includes these top-level elements:

```yaml
version: '3.8'  # Optional in newer Docker Compose versions

services:       # Defines the containers to be run
  service1:
    # service configuration

  service2:
    # service configuration

networks:       # Optional: Define custom networks
  network1:
    # network configuration

volumes:        # Optional: Define persistent volumes
  volume1:
    # volume configuration

configs:        # Optional: Define configuration files
  config1:
    # config configuration

secrets:        # Optional: Define sensitive data
  secret1:
    # secret configuration
```

#### Compose File Versions

Docker Compose has evolved through several specification versions:

|Version|Docker Engine|Features Added|
|---|---|---|
|1|1.9.0+|Basic functionality|
|2|1.10.0+|Named networks, volume configuration|
|2.1|1.12.0+|Variable substitution, extends, healthcheck|
|3|1.13.0+|Swarm mode support, deploy section|
|3.4|17.09.0+|Target node placement, rollback config|
|3.8|19.03.0+|GPU support, configurable scale/replicas|
|Latest Compose V2|20.10.0+|Version field is optional|

**Version Selection:**

- For modern Docker installations, use the latest version (currently 3.8)
- Specify the version based on features needed
- Since Compose V2, the version field is optional

**Example Version Evolution:**

Version 1 (Legacy):

```yaml
web:
  image: nginx
  links:
    - db
db:
  image: postgres
```

Version 3.8:

```yaml
services:
  web:
    image: nginx
    networks:
      - frontend
  db:
    image: postgres
    networks:
      - backend
networks:
  frontend:
  backend:
```

#### Environment Variable Interpolation

Docker Compose supports variable substitution in the YAML file:

```yaml
services:
  db:
    image: postgres:${POSTGRES_VERSION}
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
```

Variables can be set in:

- Environment variables on the host
- `.env` file in the same directory
- Command line arguments

**Example .env file:**

```
POSTGRES_VERSION=14
DB_PASSWORD=secretpassword
```

#### Extension Fields and Special Formats

Docker Compose supports various extension fields:

**x- Prefix for Custom Data:**

```yaml
x-common-config: &common-config
  restart: always
  logging:
    driver: json-file
    options:
      max-size: "10m"

services:
  web:
    <<: *common-config
    image: nginx
  db:
    <<: *common-config
    image: postgres
```

**YAML Anchors and Aliases:** Use `&` to create anchors and `*` to reference them, as shown above.

**Long and Short Syntax:** Many properties support both short and long syntax:

Short syntax:

```yaml
volumes:
  - ./data:/app/data
```

Long syntax:

```yaml
volumes:
  - type: bind
    source: ./data
    target: /app/data
    read_only: true
```

**Key Points:**

- Compose file format is backward compatible
- Modern Docker installations support all Compose versions
- Use the latest version for new projects
- Anchors and aliases help maintain DRY configuration

### Service Definitions

The `services` section is the core of a docker-compose.yml file, defining the containers that make up your application.

#### Basic Service Configuration

Each service requires either an `image` or `build` instruction:

```yaml
services:
  web:
    image: nginx:alpine  # Use existing image
  
  api:
    build: ./api         # Build from Dockerfile in ./api
```

#### Common Service Configuration Options

**Port Mapping:**

```yaml
services:
  web:
    ports:
      - "8080:80"        # HOST:CONTAINER
      - "443:443"
```

**Volume Mounting:**

```yaml
services:
  app:
    volumes:
      - ./src:/app/src   # Bind mount
      - data:/app/data   # Named volume
```

**Environment Variables:**

```yaml
services:
  db:
    environment:
      POSTGRES_USER: myuser
      POSTGRES_PASSWORD: secret
    # Alternative syntax
    env_file:
      - ./common.env
      - ./db.env
```

**Dependencies:**

```yaml
services:
  web:
    depends_on:
      - db
      - redis
```

**Advanced Depends On:**

```yaml
services:
  web:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
```

**Restart Policy:**

```yaml
services:
  worker:
    restart: always  # always, on-failure, unless-stopped, no
```

**Networks:**

```yaml
services:
  frontend:
    networks:
      - front-tier
      - back-tier
```

**Custom Container Name:**

```yaml
services:
  db:
    container_name: project_database
```

**Healthcheck:**

```yaml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

#### Build Configuration

For services that build from a Dockerfile:

```yaml
services:
  app:
    build:
      context: ./dir    # Build context directory
      dockerfile: Dockerfile.dev  # Alternative Dockerfile
      args:              # Build arguments
        VERSION: 1.0
      target: development  # Build stage for multi-stage builds
```

#### Resource Constraints

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

#### Complete Service Example

```yaml
services:
  webapp:
    image: myapp:latest
    build:
      context: ./app
      dockerfile: Dockerfile.prod
      args:
        ENV: production
    ports:
      - "80:8000"
    environment:
      NODE_ENV: production
      DB_HOST: db
    volumes:
      - ./app/config:/app/config
      - logs:/app/logs
    depends_on:
      db:
        condition: service_healthy
    networks:
      - frontend
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

**Key Points:**

- Compose converts YAML service definitions to docker run commands
- Services can be customized with dozens of options
- Some options like `deploy` were originally for Swarm but work in standalone Compose
- Configuration complexity grows with application needs

### Compose CLI Basics

Docker Compose provides a command-line interface for managing multi-container applications defined in a compose file.

#### Installation

Docker Compose is included with Docker Desktop. For Linux systems, it may need to be installed separately:

```bash
# Install Compose V2
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Legacy V1 installation
sudo curl -L "https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### Compose Command Structure

Docker Compose V2 uses this command structure:

```bash
docker compose [OPTIONS] COMMAND [ARGS...]
```

Legacy V1 used a hyphen:

```bash
docker-compose [OPTIONS] COMMAND [ARGS...]
```

#### Common Commands

**Starting Containers:**

```bash
# Create and start containers
docker compose up

# Detached mode (run in background)
docker compose up -d

# Build or rebuild services
docker compose up --build

# Scale specific services
docker compose up -d --scale worker=3
```

**Stopping Containers:**

```bash
# Stop containers
docker compose stop

# Stop and remove containers
docker compose down

# Remove volumes too
docker compose down -v

# Remove images too
docker compose down --rmi all
```

**Service Management:**

```bash
# View running services
docker compose ps

# View service logs
docker compose logs [service]

# Follow logs
docker compose logs -f [service]

# Execute command in service
docker compose exec web bash

# Run one-off command
docker compose run --rm web npm test
```

**Build and Push:**

```bash
# Build services
docker compose build

# Push images to registry
docker compose push
```

**Configuration Validation:**

```bash
# Validate and view the configuration
docker compose config

# Check for errors only
docker compose config --quiet
```

**File Management:**

```bash
# Specify an alternate compose file
docker compose -f docker-compose.prod.yml up -d

# Multiple compose files (overlay)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Specify project directory
docker compose -p myproject up -d
```

#### Development Workflow Example

```bash
# Start development environment
docker compose up -d

# View logs of all services
docker compose logs -f

# Run tests in app container
docker compose exec app npm test

# Check service status
docker compose ps

# Rebuild after code changes
docker compose up -d --build app

# Stop all services
docker compose down
```

#### Project Isolation

Docker Compose uses a project name to isolate environments. By default, it uses the directory name containing the compose file.

```bash
# Set custom project name
docker compose -p myapp up -d

# List containers with project name
docker compose -p myapp ps
```

#### Environment Variables

```bash
# Use variables from .env file
docker compose up -d

# Override with environment variables
DATABASE_URL=custom docker compose up -d

# Or with a different env file
docker compose --env-file .env.production up -d
```

#### Partial Commands

```bash
# Start only specific services
docker compose up -d db redis

# Build specific services
docker compose build api worker

# Scale specific services
docker compose up -d --scale worker=3 --scale api=2
```

#### Dependencies and Order

```bash
# Pull all images
docker compose pull

# Force recreation of containers
docker compose up -d --force-recreate

# Recreate only dependencies
docker compose up -d --renew-anon-volumes web
```

**Key Points:**

- Most commands accept service names to limit scope
- Project name isolates environments on the same host
- Compose respects the dependency order defined in compose file
- Compose loads environment variables from the shell or .env file

### Related Topics

- Docker Compose File Configuration: Advanced features and options
- Docker Compose for Production: Considerations for production use
- Multi-Environment Setup: Development, staging, and production configurations
- Docker Compose Override Files: Extending and customizing configurations
- Docker Compose with Continuous Integration: Setting up CI/CD pipelines

---

