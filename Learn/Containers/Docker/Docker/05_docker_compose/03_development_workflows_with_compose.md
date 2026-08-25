## Development Workflows with Compose


### Introduction to Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. It uses YAML files to configure application services and simplifies the process of managing complex applications with multiple interconnected containers. Compose is particularly valuable for development, testing, and staging environments, as well as CI/CD pipelines.

**Key Points**:

- Docker Compose uses a declarative YAML configuration file
- Manages the entire application lifecycle: start, stop, rebuild, scale
- Creates isolated environments for applications
- Preserves volume data when containers are recreated
- Supports variable substitution and extends configurations

### Local Development Environments

Docker Compose excels at creating consistent, reproducible development environments that mirror production setups while being optimized for development workflows.

#### Basic Compose File Structure

A basic `docker-compose.yml` file for a web application with a database might look like this:

```yaml
version: '3.8'
services:
  web:
    build: ./web
    ports:
      - "8000:8000"
    volumes:
      - ./web:/code
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/app
  
  db:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=app

volumes:
  postgres_data:
```

#### Code Hot Reloading

For development, you can mount your code as a volume to enable hot reloading:

```yaml
services:
  web:
    build: ./web
    volumes:
      - ./web:/code:delegated  # Host code directory mounted into container
    command: npm run dev  # Run in development mode with hot reloading
```

**Example** for a Node.js application with nodemon:

```yaml
services:
  api:
    build: ./api
    volumes:
      - ./api:/app:delegated
      - /app/node_modules  # Volume mounting for node_modules
    command: npm run dev  # Uses nodemon to watch for changes
    environment:
      - NODE_ENV=development
```

#### Development-Specific Overrides

Use multiple Compose files to separate development configuration from production:

Base `docker-compose.yml`:

```yaml
version: '3.8'
services:
  web:
    build: ./web
    ports:
      - "80:80"
```

Development override `docker-compose.override.yml` (automatically applied):

```yaml
version: '3.8'
services:
  web:
    build:
      context: ./web
      dockerfile: Dockerfile.dev
    ports:
      - "8000:8000"  # Different port for development
    volumes:
      - ./web:/code  # Mount source code
    environment:
      - DEBUG=True
    command: ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

Run with:

```bash
docker-compose up  # Automatically merges docker-compose.yml and docker-compose.override.yml
```

#### Multi-Environment Configuration

For explicit environment selection, create separate override files:

```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

#### Developer Tools Integration

Include development tools in your Compose configuration:

```yaml
services:
  web:
    # Main service configuration...
  
  db:
    # Database configuration...
  
  # Development tools
  adminer:
    image: adminer
    ports:
      - "8080:8080"
    depends_on:
      - db
  
  mailhog:
    image: mailhog/mailhog
    ports:
      - "8025:8025"  # Web UI
      - "1025:1025"  # SMTP server
```

#### Debugging Configuration

Set up your development environment for debugging:

```yaml
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
      - "5678:5678"  # Debug port
    volumes:
      - ./backend:/app
    command: ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "-m", "flask", "run", "--host=0.0.0.0", "--port=8000", "--no-debugger", "--no-reload"]
    environment:
      - FLASK_ENV=development
      - PYTHONUNBUFFERED=1
```

### Testing with Compose

Docker Compose provides an excellent framework for running tests in isolated environments that closely resemble production.

#### Setting Up Test Environments

Create a dedicated Compose file for testing:

```yaml
# docker-compose.test.yml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.test
    volumes:
      - .:/app
      - ./test-results:/app/test-results
    depends_on:
      - db-test
    environment:
      - NODE_ENV=test
      - DATABASE_URL=postgres://postgres:password@db-test:5432/testdb
    command: npm test
  
  db-test:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=testdb
```

Run tests with:

```bash
docker-compose -f docker-compose.test.yml up --exit-code-from app
```

The `--exit-code-from app` flag makes the command exit with the exit code of the `app` service, which is useful for CI/CD pipelines.

#### Test Isolation

For truly isolated tests, ensure test containers don't interfere with development or other test runs:

```yaml
services:
  db-test:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=testdb
    tmpfs:
      - /var/lib/postgresql/data  # Use tmpfs for speed and isolation
```

#### Parallel Test Execution

Configure Compose for running multiple test suites in parallel:

```yaml
services:
  unit-tests:
    build: .
    command: npm run test:unit
    volumes:
      - ./unit-results:/app/results
  
  integration-tests:
    build: .
    command: npm run test:integration
    volumes:
      - ./integration-results:/app/results
    depends_on:
      - db-test
```

#### Testing with Different Database Versions

Test compatibility with different database versions:

```yaml
services:
  app:
    build: .
    command: npm test
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/testdb
  
  db:
    image: postgres:${POSTGRES_VERSION:-13}  # Default to 13, but can be overridden
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=testdb
```

Run with:

```bash
POSTGRES_VERSION=12 docker-compose -f docker-compose.test.yml up
```

#### Integration Testing with Service Dependencies

Configure integration tests with dependent services:

```yaml
services:
  integration-tests:
    build:
      context: .
      dockerfile: Dockerfile.test
    volumes:
      - ./tests:/app/tests
    depends_on:
      - api
      - db
      - redis
    environment:
      - API_URL=http://api:8000
    command: npm run test:integration
  
  api:
    build: ./api
    depends_on:
      - db
      - redis
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=password
  
  redis:
    image: redis:6
```

**Example** of a test script that waits for services to be ready:

```yaml
services:
  test:
    build: .
    command: sh -c "wait-for-it.sh db:5432 -t 60 && wait-for-it.sh redis:6379 -t 60 && npm test"
    depends_on:
      - db
      - redis
```

### Extending Compose Files

Docker Compose allows for extending and overriding configurations, enabling reuse across different environments and scenarios.

#### Using Multiple Compose Files

Compose files are applied in order, with later files overriding settings from earlier ones:

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

The `docker-compose.yml` file might contain:

```yaml
version: '3.8'
services:
  web:
    image: myapp:latest
    restart: always
    depends_on:
      - db
  
  db:
    image: postgres:13
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

While `docker-compose.prod.yml` overrides specific settings:

```yaml
version: '3.8'
services:
  web:
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 3
  
  db:
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    external: true
```

#### Using the extends Field (Legacy)

In older Compose file formats (version 2), you could use the `extends` field:

```yaml
# common-services.yml
version: '2'
services:
  webapp:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/code
```

```yaml
# docker-compose.yml
version: '2'
services:
  webapp:
    extends:
      file: common-services.yml
      service: webapp
    environment:
      - DEBUG=True
```

Note: The `extends` field was removed in Compose file format version 3, in favor of using multiple Compose files.

#### Using Environment Variables

Environment variables in Compose files allow for configuration without changing the files:

```yaml
version: '3.8'
services:
  web:
    image: nginx:${NGINX_VERSION:-latest}
    ports:
      - "${HOST_PORT:-8080}:80"
    environment:
      - API_KEY=${API_KEY}
```

You can use a `.env` file to set these variables:

```
NGINX_VERSION=1.21
HOST_PORT=9090
API_KEY=your_api_key
```

#### Configuration Fragments with YAML Anchors and Aliases

Use YAML anchors and aliases to reuse configuration fragments:

```yaml
version: '3.8'
x-logging: &default-logging
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

services:
  web:
    image: nginx
    <<: *default-logging
  
  api:
    image: myapi
    <<: *default-logging
```

#### Template-Based Configuration

Combine environment substitution with templates:

```yaml
version: '3.8'
services:
  app:
    image: ${DOCKER_REGISTRY:-localhost}/${IMAGE_NAME:-myapp}:${IMAGE_TAG:-latest}
    environment:
      - NODE_ENV=${ENVIRONMENT:-development}
      - DB_HOST=${DB_HOST:-db}
      - REDIS_HOST=${REDIS_HOST:-redis}
```

### Using Compose for CI/CD

Docker Compose can be integrated into CI/CD pipelines to build, test, and deploy applications in a consistent environment.

#### Building Images in CI/CD

Build and push images in your CI pipeline:

```yaml
# Example CI script
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - docker-compose build
    - docker-compose push

test:
  stage: test
  script:
    - docker-compose -f docker-compose.test.yml up --exit-code-from tests
```

**Example** of GitHub Actions workflow with Compose:

```yaml
name: CI Pipeline

on: [push, pull_request]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build images
        run: docker-compose build
      
      - name: Run tests
        run: docker-compose -f docker-compose.test.yml up --exit-code-from tests
      
      - name: Push images (on main branch only)
        if: github.ref == 'refs/heads/main'
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker-compose push
```

#### Deploying with Compose

For simple deployments, you can use Docker Compose directly:

```yaml
# docker-compose.deploy.yml
version: '3.8'
services:
  web:
    image: ${DOCKER_REGISTRY}/myapp:${IMAGE_TAG}
    restart: always
    ports:
      - "80:80"
    environment:
      - NODE_ENV=production
```

Deployment script:

```bash
#!/bin/bash
# deploy.sh
export DOCKER_REGISTRY=myregistry.com
export IMAGE_TAG=$(git rev-parse --short HEAD)

# Pull latest images
docker-compose -f docker-compose.deploy.yml pull

# Stop and start services
docker-compose -f docker-compose.deploy.yml down
docker-compose -f docker-compose.deploy.yml up -d
```

#### Compose for Different Deployment Environments

Create environment-specific Compose files:

```yaml
# docker-compose.staging.yml
version: '3.8'
services:
  web:
    image: ${DOCKER_REGISTRY}/myapp:${IMAGE_TAG}
    environment:
      - NODE_ENV=staging
      - API_URL=https://api.staging.example.com
```

```yaml
# docker-compose.production.yml
version: '3.8'
services:
  web:
    image: ${DOCKER_REGISTRY}/myapp:${IMAGE_TAG}
    environment:
      - NODE_ENV=production
      - API_URL=https://api.example.com
    deploy:
      replicas: 3
```

#### Continuous Deployment Pipeline

Example of a deployment pipeline using Docker Compose:

1. Build and test stage:

```bash
docker-compose build
docker-compose -f docker-compose.test.yml up --exit-code-from tests
docker-compose push
```

2. Deployment stage:

```bash
# On the deployment server
export IMAGE_TAG=$(git rev-parse --short HEAD)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

#### Blue-Green Deployments with Compose

Implement blue-green deployments using Docker Compose:

```bash
#!/bin/bash
# blue-green-deploy.sh

# Determine current active deployment
if [ "$(docker ps --filter name=blue -q)" ]; then
  ACTIVE="blue"
  INACTIVE="green"
else
  ACTIVE="green"
  INACTIVE="blue"
fi

echo "Active deployment: $ACTIVE, preparing $INACTIVE"

# Deploy to inactive environment
export DEPLOYMENT=$INACTIVE
export IMAGE_TAG=$1

docker-compose -f docker-compose.deploy.yml up -d

# Health check
for i in {1..30}; do
  if curl -f http://localhost:8${INACTIVE}/health; then
    echo "$INACTIVE deployment is healthy"
    break
  fi
  echo "Waiting for $INACTIVE deployment to be healthy..."
  sleep 2
done

# Switch traffic
echo "Switching traffic to $INACTIVE deployment"
# Update load balancer or proxy configuration
nginx -s reload

# Cleanup (optional)
echo "Stopping $ACTIVE deployment"
export DEPLOYMENT=$ACTIVE
docker-compose -f docker-compose.deploy.yml down
```

#### Compose with CI/CD Variables

Leverage CI/CD platform variables with Compose:

```yaml
# docker-compose.ci.yml
version: '3.8'
services:
  app:
    build:
      context: .
      args:
        - BUILD_NUMBER=${CI_BUILD_NUMBER}
        - GIT_COMMIT=${CI_COMMIT_SHA}
    image: ${CI_REGISTRY_IMAGE}:${CI_COMMIT_REF_SLUG}
```

**Example** with GitLab CI:

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

variables:
  DOCKER_HOST: tcp://docker:2375

build:
  stage: build
  script:
    - docker-compose -f docker-compose.ci.yml build
    - docker-compose -f docker-compose.ci.yml push

test:
  stage: test
  script:
    - docker-compose -f docker-compose.ci.yml -f docker-compose.test.yml pull
    - docker-compose -f docker-compose.ci.yml -f docker-compose.test.yml up --exit-code-from tests

deploy:
  stage: deploy
  script:
    - docker-compose -f docker-compose.ci.yml -f docker-compose.prod.yml config > docker-compose.deployed.yml
    - scp docker-compose.deployed.yml user@production-server:/app/
    - ssh user@production-server "cd /app && docker-compose -f docker-compose.deployed.yml pull && docker-compose -f docker-compose.deployed.yml up -d"
  only:
    - main
```

### Advanced Compose Workflows

#### Scaling Services

Scale services for testing load balancing and high availability:

```bash
docker-compose up -d --scale worker=3
```

**Example** Compose file with scaling configuration:

```yaml
services:
  worker:
    image: myapp/worker
    deploy:
      replicas: 3
    depends_on:
      - redis
  
  redis:
    image: redis:6
```

#### Resource Limiting

Set resource limits for development to simulate production constraints:

```yaml
services:
  api:
    build: ./api
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

#### Development Profiles

Use Compose profiles to selectively start services:

```yaml
services:
  app:
    build: .
    # Always started
  
  db:
    image: postgres
    # Always started
  
  adminer:
    image: adminer
    profiles: ["dev", "debug"]
    # Only started when using the "dev" or "debug" profile
  
  selenium:
    image: selenium/standalone-chrome
    profiles: ["test"]
    # Only started when using the "test" profile
```

Run with:

```bash
docker-compose --profile dev up
```

#### Handling Secret Management

Manage secrets securely in development and CI/CD environments:

```yaml
# docker-compose.yml
services:
  app:
    image: myapp
    secrets:
      - db_password
      - api_key

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    file: ./secrets/api_key.txt
```

In CI/CD, you can create secrets files dynamically:

```bash
mkdir -p ./secrets
echo "$DB_PASSWORD" > ./secrets/db_password.txt
echo "$API_KEY" > ./secrets/api_key.txt
docker-compose up -d
```

#### Developer Onboarding Scripts

Create helper scripts for developer onboarding:

```bash
#!/bin/bash
# setup.sh

# Clone repository
git clone https://github.com/org/project.git
cd project

# Create environment file from template
cp .env.example .env

# Start development environment
docker-compose up -d

# Run database migrations
docker-compose exec app npm run migrate

echo "Development environment is ready!"
echo "Visit http://localhost:8000 to see the application"
```

### Related Topics

- Multi-stage builds for optimized Docker images
- Securing Docker Compose environments
- Integration with container orchestration platforms like Kubernetes
- Container monitoring and logging solutions
- Infrastructure as Code approaches for container deployments

----

