## CI/CD with Docker


### Understanding CI/CD with Docker

Continuous Integration and Continuous Deployment (CI/CD) with Docker combines the power of containerization with automated software delivery practices. This integration enables consistent build environments, reproducible deployments, and efficient testing workflows.

**Key Points**:

- Docker provides consistent environments across development, testing, and production
- Containers isolate dependencies, reducing "it works on my machine" problems
- Docker images serve as immutable artifacts throughout the deployment pipeline
- Container orchestration enables seamless deployment and scaling

### Integrating Docker in CI/CD Pipelines

Docker can be integrated at various stages of a CI/CD pipeline to create a streamlined workflow from code commit to production deployment.

#### CI/CD Pipeline Architecture with Docker

A typical Docker-based CI/CD pipeline includes these stages:

1. **Source Code Management**: Developers push code to a version control system
2. **Build**: The CI server builds Docker images from the source code
3. **Test**: Tests run against containerized applications
4. **Publish**: Approved images are pushed to a container registry
5. **Deploy**: Images are pulled and deployed to target environments

#### Containerizing Your Application

The foundation of a Docker-based CI/CD pipeline is a well-designed Dockerfile:

```dockerfile
# Build stage
FROM node:16-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:16-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm ci --only=production
USER node
CMD ["node", "dist/index.js"]
```

#### Multi-Stage Builds for Efficient CI/CD

Multi-stage builds are particularly useful in CI/CD pipelines:

- Separate build and runtime environments
- Include only necessary production dependencies
- Reduce image size for faster transfers
- Improve security by minimizing attack surface

#### Container Registries in CI/CD

Container registries serve as the central hub for storing and distributing Docker images:

```bash
# Tag the image with registry information
docker tag myapp:latest registry.example.com/myapp:${CI_COMMIT_SHA}

# Push to the registry
docker push registry.example.com/myapp:${CI_COMMIT_SHA}
```

Popular registry options include:

- Docker Hub
- GitHub Container Registry
- AWS Elastic Container Registry (ECR)
- Google Container Registry (GCR)
- Azure Container Registry (ACR)
- Harbor (self-hosted option)

#### Docker Compose for Multi-Container Testing

Docker Compose simplifies testing multi-container applications in CI/CD:

```yaml
# docker-compose.test.yml
version: '3.8'
services:
  app:
    build: .
    environment:
      - NODE_ENV=test
      - DB_HOST=db
    depends_on:
      - db
  
  db:
    image: postgres:14-alpine
    environment:
      - POSTGRES_USER=test
      - POSTGRES_PASSWORD=test
      - POSTGRES_DB=testdb
  
  test:
    build:
      context: .
      dockerfile: Dockerfile.test
    volumes:
      - ./reports:/app/reports
    depends_on:
      - app
      - db
```

### Jenkins with Docker

Jenkins is a popular CI/CD server that integrates well with Docker for building and testing applications.

#### Setting Up Jenkins with Docker

There are two main approaches to using Jenkins with Docker:

1. **Docker-in-Docker**: Running Docker commands inside a Jenkins container
2. **Docker outside of Docker**: Mounting the host's Docker socket

```dockerfile
# Dockerfile for Jenkins with Docker support
FROM jenkins/jenkins:lts
USER root
RUN apt-get update && \
    apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get -y install docker-ce docker-ce-cli containerd.io
USER jenkins
```

#### Jenkins Pipeline for Docker

Jenkins Pipeline allows defining CI/CD workflows as code:

```groovy
pipeline {
    agent {
        docker {
            image 'docker:dind'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'myapp'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t $DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG .'
            }
        }
        
        stage('Test') {
            steps {
                sh 'docker-compose -f docker-compose.test.yml up --exit-code-from test'
            }
        }
        
        stage('Publish') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([string(credentialsId: 'docker-registry-token', variable: 'DOCKER_TOKEN')]) {
                    sh 'echo $DOCKER_TOKEN | docker login $DOCKER_REGISTRY -u user --password-stdin'
                    sh 'docker push $DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG'
                    sh 'docker tag $DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG $DOCKER_REGISTRY/$IMAGE_NAME:latest'
                    sh 'docker push $DOCKER_REGISTRY/$IMAGE_NAME:latest'
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'curl -X POST $DEPLOYMENT_WEBHOOK_URL'
            }
        }
    }
    
    post {
        always {
            sh 'docker-compose -f docker-compose.test.yml down -v'
            sh 'docker logout $DOCKER_REGISTRY'
        }
    }
}
```

#### Jenkins Agents with Docker

Jenkins can use Docker to provide dynamic agent environments:

```groovy
pipeline {
    agent none
    
    stages {
        stage('Build Backend') {
            agent {
                docker {
                    image 'golang:1.17'
                }
            }
            steps {
                sh 'go build -o myapp'
                stash includes: 'myapp', name: 'app-binary'
            }
        }
        
        stage('Build Frontend') {
            agent {
                docker {
                    image 'node:16'
                }
            }
            steps {
                sh 'npm install'
                sh 'npm run build'
                stash includes: 'dist/**/*', name: 'frontend-assets'
            }
        }
        
        stage('Package') {
            agent {
                docker {
                    image 'docker:20.10'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                unstash 'app-binary'
                unstash 'frontend-assets'
                sh 'docker build -t myapp:${BUILD_NUMBER} .'
            }
        }
    }
}
```

### GitHub Actions with Docker

GitHub Actions provides CI/CD capabilities directly within GitHub repositories with strong Docker integration.

#### Basic GitHub Actions Workflow with Docker

```yaml
# .github/workflows/docker-build.yml
name: Docker Build and Push

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to DockerHub
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v3
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: |
            user/app:latest
            user/app:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

#### GitHub Actions with Docker Compose

For multi-container applications:

```yaml
# .github/workflows/test-and-deploy.yml
name: Test and Deploy

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run tests with Docker Compose
        run: |
          docker-compose -f docker-compose.test.yml up --exit-code-from test
          docker-compose -f docker-compose.test.yml down -v
  
  deploy:
    if: github.event_name != 'pull_request'
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v3
        with:
          context: .
          push: true
          tags: user/app:latest,user/app:${{ github.sha }}
      
      - name: Deploy to Production
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SSH_HOST }}
          username: ${{ secrets.SSH_USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/myapp
            docker-compose pull
            docker-compose up -d
```

#### GitHub Actions Matrix Testing with Docker

Testing across multiple versions or configurations:

```yaml
name: Matrix Testing

on:
  push:
    branches: [ "main" ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14, 16, 18]
        database: [mysql, postgres]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Test with Node ${{ matrix.node-version }} and ${{ matrix.database }}
        run: |
          docker-compose -f docker-compose.${{ matrix.database }}.yml \
            -f docker-compose.node${{ matrix.node-version }}.yml \
            up --exit-code-from test
```

#### GitHub Actions for Docker Image Security Scanning

```yaml
name: Security Scan

on:
  push:
    branches: [ "main" ]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
```

### GitLab CI with Docker

GitLab CI/CD provides comprehensive pipeline capabilities with built-in Docker support.

#### Basic GitLab CI Configuration with Docker

```yaml
# .gitlab-ci.yml
image: docker:20.10

services:
  - docker:20.10-dind

variables:
  DOCKER_TLS_CERTDIR: "/certs"
  DOCKER_HOST: tcp://docker:2376
  DOCKER_TLS_VERIFY: 1
  DOCKER_CERT_PATH: "$DOCKER_TLS_CERTDIR/client"

stages:
  - build
  - test
  - deploy

before_script:
  - docker info

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

test:
  stage: test
  script:
    - docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker-compose -f docker-compose.test.yml up --exit-code-from test

deploy:
  stage: deploy
  script:
    - docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - main
```

#### GitLab CI with Kaniko for Secure Building

Kaniko allows building Docker images in environments that can't mount the Docker socket:

```yaml
build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: [""]
  script:
    - mkdir -p /kaniko/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > /kaniko/.docker/config.json
    - /kaniko/executor --context $CI_PROJECT_DIR --dockerfile $CI_PROJECT_DIR/Dockerfile --destination $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

#### GitLab Auto DevOps with Docker

GitLab Auto DevOps provides out-of-the-box CI/CD for Docker applications:

```yaml
# Enable Auto DevOps with customizations
include:
  - template: Auto-DevOps.gitlab-ci.yml

variables:
  AUTO_DEVOPS_BUILD_IMAGE_EXTRA_ARGS: "--build-arg NODE_ENV=production"
  AUTO_DEVOPS_DEPLOY_STRATEGY: "rolling"
  POSTGRES_ENABLED: "false"
  HELM_UPGRADE_EXTRA_ARGS: "--set replicaCount=3"
```

#### GitLab CI for Docker Swarm Deployment

```yaml
deploy:
  stage: deploy
  image: docker:20.10
  before_script:
    - apk add --no-cache openssh-client
    - mkdir -p ~/.ssh
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' > ~/.ssh/id_rsa
    - chmod 600 ~/.ssh/id_rsa
    - ssh-keyscan -H $DEPLOYMENT_SERVER >> ~/.ssh/known_hosts
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker context create remote --docker "host=ssh://$DEPLOYMENT_USER@$DEPLOYMENT_SERVER"
    - docker --context remote stack deploy --with-registry-auth -c docker-compose.prod.yml myapp
  only:
    - main
```

### Automated Testing with Docker

Docker provides consistent environments for running various types of tests in CI/CD pipelines.

#### Unit Testing with Docker

Running unit tests in isolated containers:

```dockerfile
# Dockerfile.test
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
CMD ["npm", "test"]
```

```yaml
# docker-compose.test.yml for unit tests
version: '3.8'
services:
  test:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - NODE_ENV=test
    volumes:
      - ./coverage:/app/coverage
```

#### Integration Testing with Docker Compose

Testing interactions between services:

```yaml
version: '3.8'
services:
  app:
    build: .
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/testdb
    depends_on:
      - db
  
  db:
    image: postgres:14
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=testdb
    volumes:
      - ./init-test-db.sql:/docker-entrypoint-initdb.d/init.sql
  
  test:
    build:
      context: .
      dockerfile: Dockerfile.integration
    environment:
      - APP_URL=http://app:3000
    depends_on:
      - app
      - db
    command: ["./wait-for-it.sh", "app:3000", "--", "npm", "run", "test:integration"]
```

#### End-to-End Testing with Selenium and Docker

```yaml
version: '3.8'
services:
  app:
    build: .
    environment:
      - NODE_ENV=test
  
  chrome:
    image: selenium/standalone-chrome:latest
    volumes:
      - /dev/shm:/dev/shm
  
  e2e:
    build:
      context: .
      dockerfile: Dockerfile.e2e
    environment:
      - SELENIUM_HOST=chrome
      - APP_HOST=app
    volumes:
      - ./test-results:/app/test-results
    depends_on:
      - app
      - chrome
```

#### Performance Testing with Docker

```yaml
version: '3.8'
services:
  app:
    build: .
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
  
  loadtest:
    image: artillery/artillery
    volumes:
      - ./performance:/scripts
    command: ["run", "/scripts/load-test.yml"]
    depends_on:
      - app
```

#### Test Result Collection

Collecting test results from containers:

```yaml
test:
  image: myapp-test
  volumes:
    - ./test-results:/app/test-results
  environment:
    - JEST_JUNIT_OUTPUT_DIR=/app/test-results
    - JEST_JUNIT_OUTPUT_NAME=results.xml
  command: ["npm", "test", "--", "--reporters=default", "--reporters=jest-junit"]
```

CI/CD configuration to collect results:

```yaml
# GitLab CI example
test:
  stage: test
  script:
    - docker-compose -f docker-compose.test.yml up --exit-code-from test
    - docker cp $(docker-compose -f docker-compose.test.yml ps -q test):/app/test-results ./test-results
  artifacts:
    reports:
      junit: test-results/results.xml
```

```yaml
# GitHub Actions example
- name: Run tests
  run: docker-compose -f docker-compose.test.yml up --exit-code-from test

- name: Copy test results
  if: always()
  run: |
    container_id=$(docker-compose -f docker-compose.test.yml ps -q test)
    docker cp $container_id:/app/test-results ./test-results

- name: Publish Test Report
  uses: mikepenz/action-junit-report@v3
  if: always()
  with:
    report_paths: 'test-results/*.xml'
```

### Build and Deployment Strategies

Effective Docker CI/CD requires thoughtful build and deployment strategies to optimize performance, security, and reliability.

#### Image Tagging Strategies

Effective tagging ensures traceability and facilitates deployments:

- **Git Commit SHA**: `myapp:8a7d3e2`
- **Semantic Versioning**: `myapp:1.2.3`
- **Branch/Feature Tags**: `myapp:feature-auth`
- **Environment Tags**: `myapp:staging`
- **Build Metadata**: `myapp:1.2.3-build.45`

Example implementation:

```bash
# In CI/CD Pipeline
VERSION=$(cat VERSION)
BUILD_NUMBER=${CI_PIPELINE_ID}
GIT_SHA=${CI_COMMIT_SHA:0:8}

docker build -t myapp:${VERSION} .
docker tag myapp:${VERSION} myapp:${VERSION}-build.${BUILD_NUMBER}
docker tag myapp:${VERSION} myapp:${GIT_SHA}
```

#### Layer Caching for Faster Builds

Optimizing Dockerfiles for effective caching:

```dockerfile
# Inefficient - changes to code invalidate dependency cache
FROM node:16-alpine
WORKDIR /app
COPY . .
RUN npm ci
CMD ["npm", "start"]

# Efficient - dependency layers cached separately from code
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
CMD ["npm", "start"]
```

Leveraging CI/CD caching:

```yaml
# GitHub Actions
- name: Build and push
  uses: docker/build-push-action@v3
  with:
    context: .
    push: true
    tags: myapp:latest
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

```yaml
# GitLab CI
build:
  script:
    - docker buildx build --cache-from type=registry,ref=$CI_REGISTRY_IMAGE:cache --cache-to type=registry,ref=$CI_REGISTRY_IMAGE:cache,mode=max -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
```

#### Blue-Green Deployments with Docker

Blue-green deployment minimizes downtime by running two identical environments:

```yaml
# docker-compose.blue.yml
version: '3.8'
services:
  app:
    image: myapp:${VERSION}
    environment:
      - ENVIRONMENT=production
    networks:
      - frontend
      - backend
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app-blue.rule=Host(`app.example.com`)"
      - "traefik.http.routers.app-blue.entrypoints=web"

networks:
  frontend:
    external: true
  backend:
    external: true
```

Deployment script:

```bash
#!/bin/bash
# Deploy new version (green)
docker-compose -f docker-compose.green.yml up -d

# Wait for green to be ready
./health-check.sh app.green.internal

# Switch traffic to green
docker-compose -f docker-compose.green.yml exec traefik traefik cli service update rule@docker 'Host(`app.example.com`)'

# Remove old version (blue) after grace period
sleep 60
docker-compose -f docker-compose.blue.yml down
```

#### Rolling Updates with Docker Swarm

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  app:
    image: myapp:${VERSION}
    deploy:
      replicas: 6
      update_config:
        parallelism: 2
        delay: 10s
        order: start-first
        failure_action: rollback
      rollback_config:
        parallelism: 2
        delay: 0s
      restart_policy:
        condition: on-failure
        max_attempts: 3
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
```

Deployment command:

```bash
export VERSION=1.2.3
docker stack deploy -c docker-compose.prod.yml --with-registry-auth myapp
```

#### Canary Deployments with Docker and Kubernetes

Gradual rollout with traffic splitting:

```yaml
# Kubernetes manifest with Istio for canary deployment
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp.example.com
  http:
  - route:
    - destination:
        host: myapp-stable
        subset: v1
      weight: 90
    - destination:
        host: myapp-canary
        subset: v2
      weight: 10
```

#### Infrastructure as Code for Docker Deployments

Using Terraform to manage Docker infrastructure:

```hcl
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "app" {
  name = "myregistry.com/myapp:${var.version}"
}

resource "docker_container" "app" {
  name  = "myapp"
  image = docker_image.app.image_id
  
  ports {
    internal = 3000
    external = 80
  }
  
  env = [
    "DATABASE_URL=${var.database_url}",
    "NODE_ENV=production"
  ]
  
  volumes {
    container_path = "/app/data"
    host_path      = "/mnt/data"
  }
  
  restart = "always"
}

resource "null_resource" "health_check" {
  depends_on = [docker_container.app]
  
  provisioner "local-exec" {
    command = "curl -f http://localhost/health || exit 1"
  }
}
```

#### Managing Secrets in Docker CI/CD

Secure management of secrets in pipelines:

```yaml
# GitHub Actions
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Create Docker config with secrets
        run: |
          mkdir -p $HOME/.docker
          echo '${{ secrets.DOCKER_CONFIG }}' > $HOME/.docker/config.json
          chmod 600 $HOME/.docker/config.json
      
      - name: Generate .env file
        run: |
          echo "DB_PASSWORD=${{ secrets.DB_PASSWORD }}" > .env
          echo "API_KEY=${{ secrets.API_KEY }}" >> .env
      
      - name: Deploy
        run: docker-compose --env-file .env up -d
```

```yaml
# GitLab CI
deploy:
  stage: deploy
  image: docker:20.10
  variables:
    DOCKER_CONFIG: /tmp/.docker/
  before_script:
    - mkdir -p $DOCKER_CONFIG
    - echo "$DOCKER_AUTH_CONFIG" > $DOCKER_CONFIG/config.json
  script:
    - echo "DB_PASSWORD=$DB_PASSWORD" > .env
    - echo "API_KEY=$API_KEY" >> .env
    - docker-compose --env-file .env up -d
  environment:
    name: production
```

#### Observability in CI/CD

Adding monitoring and logging:

```yaml
# docker-compose.prod.yml with monitoring
version: '3.8'
services:
  app:
    image: myapp:${VERSION}
    environment:
      - NODE_ENV=production
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=3000"
      - "prometheus.path=/metrics"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
  
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
  
  grafana:
    image: grafana/grafana:latest
    volumes:
      - grafana-data:/var/lib/grafana
    ports:
      - "3000:3000"
    depends_on:
      - prometheus

volumes:
  grafana-data:
```

#### Database Migrations in CI/CD

Handling database schema changes in pipelines:

```yaml
# docker-compose.migration.yml
version: '3.8'
services:
  db-migration:
    image: myapp-migration:${VERSION}
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/mydb
    depends_on:
      - db
```

CI/CD implementation:

```bash
# In deployment script
# Run migrations before updating application
docker-compose -f docker-compose.migration.yml up --exit-code-from db-migration

# If migrations successful, deploy new version
if [ $? -eq 0 ]; then
  docker-compose -f docker-compose.prod.yml up -d
else
  echo "Migration failed!"
  exit 1
fi
```

**Conclusion**:

Integrating Docker into CI/CD pipelines provides powerful capabilities for building, testing, and deploying applications with consistency and reliability. The containerized approach ensures that applications run the same way in development, testing, and production environments, reducing the "it works on my machine" problem. By leveraging Docker with modern CI/CD tools like Jenkins, GitHub Actions, and GitLab CI, teams can automate their software delivery process, implement advanced deployment strategies, and maintain high quality through comprehensive testing. As containerization becomes increasingly central to modern software development, mastering Docker-based CI/CD workflows becomes essential for efficient and reliable software delivery.
