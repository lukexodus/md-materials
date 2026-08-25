## Compose File Configuration


### Understanding Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. With a single YAML file and a few commands, you can create and start all the services defined in your configuration.

**Key Points:**

- Docker Compose simplifies multi-container application management
- Configuration is defined in YAML format (typically docker-compose.yml)
- Enables application stacks to be version-controlled
- Supports development, testing, staging, and production environments
- Provides service isolation and networking capabilities

### Services, Networks, and Volumes

The core components of Docker Compose define what runs, how components communicate, and where data persists.

#### Service Configuration

Services define the containers that should run as part of your application:

```yaml
version: '3.9'
services:
  webapp:
    image: nginx:latest
    container_name: my-webapp
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    restart: unless-stopped
```

#### Common Service Configuration Options

Services have numerous configuration options:

```yaml
services:
  api:
    image: my-api:latest
    build: ./api
    container_name: api-service
    hostname: api
    domainname: example.com
    entrypoint: ["/entrypoint.sh"]
    command: ["--config", "/etc/config.json"]
    working_dir: /app
    user: "1000:1000"
    expose:
      - "8080"
    ports:
      - "8080:8080"
      - "127.0.0.1:8081:8081" # Bind to localhost only
    restart: always # no, always, on-failure, unless-stopped
    env_file: .env
    environment:
      NODE_ENV: production
    depends_on:
      - database
    deploy:
      replicas: 3
    labels:
      com.example.description: "API service"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

#### Network Configuration

Networks enable container communication and isolation:

```yaml
services:
  webapp:
    networks:
      - frontend
  api:
    networks:
      - frontend
      - backend
  database:
    networks:
      - backend

networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  backend:
    driver: bridge
    internal: true # Not accessible from host
    driver_opts:
      com.docker.network.bridge.name: backend-network
  external-net:
    external: true
```

#### Volume Configuration

Volumes provide persistent data storage:

```yaml
services:
  database:
    image: postgres:14
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
      - /etc/localtime:/etc/localtime:ro

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      device: /path/on/host/data
      o: bind
  redis_data:
    external: true # Use pre-existing volume
```

#### Named Volumes vs. Bind Mounts

Understanding different volume types:

```yaml
services:
  webapp:
    volumes:
      # Named volume (managed by Docker)
      - data_volume:/app/data
      
      # Bind mount (direct host path)
      - ./config:/app/config
      
      # Anonymous volume
      - /app/logs
      
      # Read-only mount
      - ./assets:/app/assets:ro
      
      # tmpfs mount (memory-only)
      - type: tmpfs
        target: /app/temp
        tmpfs:
          size: 100M

volumes:
  data_volume:
```

### Environment Configuration

Managing configuration across different environments is crucial for application deployment.

#### Environment Variables

Setting environment variables in services:

```yaml
services:
  api:
    image: my-api:latest
    environment:
      # Direct value assignment
      NODE_ENV: production
      API_PORT: 3000
      
      # Value from shell environment
      DATABASE_URL: ${DATABASE_URL}
      
      # Default value if not set in shell
      LOG_LEVEL: ${LOG_LEVEL:-info}
      
      # Boolean and numeric values
      DEBUG: 'false'
      RETRY_COUNT: 5
```

#### Environment Files

Using .env files for cleaner configuration:

```yaml
services:
  webapp:
    env_file:
      - ./common.env
      - ./production.env
```

Example .env file:

```env
# common.env
APP_VERSION=1.0.0
REDIS_HOST=redis

# production.env
NODE_ENV=production
LOG_LEVEL=warn
```

#### Variable Substitution

Using variable substitution within the compose file:

```yaml
services:
  webapp:
    image: ${REGISTRY:-localhost}/webapp:${TAG:-latest}
    environment:
      DATABASE_URL: postgres://${DB_USER:-postgres}:${DB_PASSWORD}@db:5432/${DB_NAME:-app}
    volumes:
      - ${DATA_PATH:-./data}:/app/data
```

#### Environment-Specific Compose Files

Managing different environments with multiple compose files:

Base configuration (docker-compose.yml):

```yaml
services:
  webapp:
    image: webapp:latest
    ports:
      - "80:80"
```

Development overrides (docker-compose.dev.yml):

```yaml
services:
  webapp:
    build: ./src
    volumes:
      - ./src:/app
    environment:
      NODE_ENV: development
```

Production overrides (docker-compose.prod.yml):

```yaml
services:
  webapp:
    image: registry.example.com/webapp:${TAG}
    restart: always
    environment:
      NODE_ENV: production
```

Using multiple files:

```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### Dependencies and Startup Order

Managing service dependencies ensures proper application initialization.

#### Basic Dependencies

Specifying service dependencies:

```yaml
services:
  webapp:
    depends_on:
      - api
      - redis
  api:
    depends_on:
      - database
```

#### Advanced Dependency Conditions

Controlling startup based on service health in Compose v3.9+:

```yaml
services:
  webapp:
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_started
  
  database:
    image: postgres:14
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 10s
```

#### Custom Entrypoint Scripts

Using entrypoint scripts to ensure proper startup order:

```yaml
services:
  api:
    build: ./api
    entrypoint: ./wait-for-it.sh database:5432 -- ./start-api.sh
    depends_on:
      - database
```

Example wait-for-it.sh:

```bash
#!/bin/bash
# wait-for-it.sh - Wait for a service to be available before starting command
host="$1"
shift
cmd="$@"

until nc -z "$host" "${port:-5432}"; do
  echo "Waiting for $host to be available..."
  sleep 1
done

echo "$host is available, executing command"
exec $cmd
```

#### Init Systems and Supervisors

Managing multiple processes in a single container:

```yaml
services:
  app:
    build: ./app
    command: ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
    volumes:
      - ./supervisord.conf:/etc/supervisor/conf.d/supervisord.conf
```

Example supervisord.conf:

```ini
[supervisord]
nodaemon=true

[program:app]
command=node /app/server.js
autostart=true
autorestart=true
stderr_logfile=/var/log/app.err.log
stdout_logfile=/var/log/app.out.log

[program:worker]
command=node /app/worker.js
autostart=true
autorestart=true
stderr_logfile=/var/log/worker.err.log
stdout_logfile=/var/log/worker.out.log
```

### Scaling Services

Docker Compose supports scaling services for increased capacity.

#### Manual Scaling

Scaling services with docker-compose:

```bash
# Start with 3 replicas of worker service
docker-compose up --scale worker=3
```

#### Scale Configuration

Configuring service for scaling:

```yaml
services:
  worker:
    image: my-worker:latest
    deploy:
      mode: replicated
      replicas: 3
    # Use dynamic port binding with ranges
    ports:
      - "9000-9010:8080"
```

#### Load Balancing

Setting up a load balancer for scaled services:

```yaml
services:
  loadbalancer:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - webapp
  
  webapp:
    image: my-webapp:latest
    # No public ports - only exposed internally
    expose:
      - "8080"
    deploy:
      replicas: 3
```

Example nginx.conf for load balancing:

```nginx
http {
  upstream webapp {
    server webapp:8080;
  }
  
  server {
    listen 80;
    
    location / {
      proxy_pass http://webapp;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
    }
  }
}
```

#### Service Discovery

Implementing service discovery patterns:

```yaml
services:
  service-registry:
    image: consul:latest
    ports:
      - "8500:8500"
  
  api:
    image: my-api:latest
    environment:
      SERVICE_8080_NAME: api
      SERVICE_TAGS: v1,production
    depends_on:
      - service-registry
```

### Resource Constraints

Managing container resource usage ensures system stability.

#### Memory Limits

Setting memory constraints:

```yaml
services:
  webapp:
    image: my-webapp:latest
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

#### CPU Limits

Controlling CPU allocation:

```yaml
services:
  processor:
    image: data-processor:latest
    deploy:
      resources:
        limits:
          cpus: '1.5'
        reservations:
          cpus: '0.5'
```

#### Legacy Resource Syntax (Compose v2)

Using older syntax for resource constraints:

```yaml
services:
  webapp:
    image: my-webapp:latest
    mem_limit: 512m
    mem_reservation: 256m
    cpus: 1.5
    cpu_shares: 73
    cpu_quota: 50000
    cpu_period: 25000
```

#### Block I/O Constraints

Limiting disk I/O:

```yaml
services:
  database:
    image: postgres:14
    blkio_config:
      weight: 300
      device_read_bps:
        - path: /dev/sda
          rate: 20mb
      device_write_bps:
        - path: /dev/sda
          rate: 10mb
```

### Docker Compose Extensions

Modern Compose features that enhance configuration management.

#### Profiles

Using profiles to selectively run services:

```yaml
services:
  webapp:
    image: my-webapp:latest
    
  database:
    image: postgres:14
    
  monitoring:
    image: prometheus:latest
    profiles:
      - monitoring
      
  admin:
    image: adminer:latest
    profiles:
      - dev
      - admin
```

Running specific profiles:

```bash
# Run only services without profiles and the monitoring profile
docker-compose --profile monitoring up

# Run development services
docker-compose --profile dev up
```

#### Extension Fields and Anchors

Using YAML anchors and aliases for DRY configurations:

```yaml
x-common-config: &common-config
  restart: unless-stopped
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"

services:
  webapp:
    <<: *common-config
    image: my-webapp:latest
    
  api:
    <<: *common-config
    image: my-api:latest
    
  # Override specific fields from anchor
  worker:
    <<: *common-config
    image: my-worker:latest
    restart: always
```

#### Include Directive (Compose v2.20+)

Including configurations from other files:

```yaml
# docker-compose.yml
include:
  - docker-compose.db.yml
  - docker-compose.app.yml

# Additional configuration specific to this file
services:
  redis:
    image: redis:alpine
```

### Advanced Configuration

More sophisticated Compose patterns for complex applications.

#### Configs and Secrets

Managing configuration files and secrets:

```yaml
services:
  webapp:
    image: nginx:alpine
    configs:
      - source: nginx_config
        target: /etc/nginx/nginx.conf
      - source: site_config
        target: /etc/nginx/conf.d/site.conf
        uid: '103'
        gid: '103'
        mode: 0440
    secrets:
      - source: site_key
        target: /etc/ssl/private/site.key
        mode: 0400

configs:
  nginx_config:
    file: ./nginx.conf
  site_config:
    file: ./site.conf

secrets:
  site_key:
    file: ./secrets/site.key
  site_cert:
    file: ./secrets/site.crt
```

#### Development vs. Production Setup

Creating separate configurations for development and production:

```yaml
# Base configuration (docker-compose.yml)
services:
  webapp:
    image: webapp:latest
    depends_on:
      - api
  api:
    image: api:latest
    depends_on:
      - database
  database:
    image: postgres:14
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

Development-specific (docker-compose.override.yml, loaded automatically):

```yaml
services:
  webapp:
    build:
      context: ./webapp
      dockerfile: Dockerfile.dev
    volumes:
      - ./webapp:/app
      - /app/node_modules
    environment:
      NODE_ENV: development
  api:
    build:
      context: ./api
      dockerfile: Dockerfile.dev
    volumes:
      - ./api:/app
    ports:
      - "3000:3000"
    environment:
      DEBUG: "true"
  database:
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: dev_password
```

Production-specific (docker-compose.prod.yml):

```yaml
services:
  webapp:
    image: registry.example.com/webapp:${TAG:-latest}
    restart: always
    environment:
      NODE_ENV: production
    deploy:
      replicas: 3
  api:
    image: registry.example.com/api:${TAG:-latest}
    restart: always
    environment:
      NODE_ENV: production
    deploy:
      replicas: 2
  database:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    external: true
```

#### Healthchecks

Implementing robust health monitoring:

```yaml
services:
  webapp:
    image: my-webapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
  
  database:
    image: postgres:14
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
```

#### Custom Networks with IPv6

Setting up IPv6-enabled networks:

```yaml
services:
  webapp:
    networks:
      app_net:
        ipv6_address: 2001:db8:10::10

networks:
  app_net:
    driver: bridge
    enable_ipv6: true
    ipam:
      driver: default
      config:
        - subnet: 172.16.238.0/24
          gateway: 172.16.238.1
        - subnet: 2001:db8:10::/64
          gateway: 2001:db8:10::1
```

### Compose File Security

Implementing security best practices in Compose files.

#### User Namespace Remapping

Using user namespace remapping:

```yaml
services:
  webapp:
    image: my-webapp:latest
    user: "1000:1000"
    security_opt:
      - seccomp=seccomp-profile.json
```

#### Linux Capabilities

Controlling container capabilities:

```yaml
services:
  restricted:
    image: my-app:latest
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

#### Limiting System Calls

Applying seccomp profiles:

```yaml
services:
  restricted:
    image: my-app:latest
    security_opt:
      - seccomp=./seccomp-profile.json
      - no-new-privileges:true
```

#### Read-Only Filesystems

Creating immutable containers:

```yaml
services:
  webapp:
    image: nginx:alpine
    read_only: true
    tmpfs:
      - /tmp
      - /var/cache/nginx
      - /var/run
    volumes:
      - ./content:/usr/share/nginx/html:ro
```

### Troubleshooting Compose

Common troubleshooting techniques for Docker Compose.

#### Compose Logs

Viewing service logs:

```bash
# View logs for all services
docker-compose logs

# Follow logs for specific services
docker-compose logs -f webapp api

# Show last 100 lines
docker-compose logs --tail=100 database
```

#### Debugging Techniques

Troubleshooting service issues:

```bash
# Check configuration without starting services
docker-compose config

# Validate and show effective configuration
docker-compose --verbose config

# Execute command in running service
docker-compose exec database psql -U postgres

# Start an interactive shell in a new container
docker-compose run --rm database bash
```

#### Common Issues and Solutions

Diagnosing frequent problems:

1. **Service depends on another service that is not starting:**
    
    - Check logs of the dependency service
    - Verify healthcheck configuration
    - Implement wait scripts
2. **Port conflicts:**
    
    ```yaml
    services:
      webapp:
        ports:
          - "127.0.0.1:${WEB_PORT:-8080}:8080"
    ```
    
3. **Volume permission problems:**
    
    ```yaml
    services:
      app:
        user: "1000:1000"
        volumes:
          - ./data:/app/data
    ```
    
    Adjust host permissions:
    
    ```bash
    sudo chown -R 1000:1000 ./data
    ```
    
4. **Network connectivity issues:**
    
    - Use service names instead of localhost
    - Verify network configuration
    - Use tools like `docker-compose exec service ping otherservice`

I recommend exploring these additional Docker Compose topics to enhance your knowledge:

- Using Compose with Docker Swarm for orchestration
- Implementing blue-green deployments with Compose
- Integrating with CI/CD pipelines
- Compose specification for Kubernetes with Kompose
- Compose V2 with the `docker compose` command (no hyphen)

---

