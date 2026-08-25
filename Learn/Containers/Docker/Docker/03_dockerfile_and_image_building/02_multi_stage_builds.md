## Multi-stage Builds


### Understanding Multi-stage Builds

Multi-stage builds in Docker allow you to create more efficient, smaller images by separating the build environment from the runtime environment. This feature was introduced in Docker 17.05 and has become a cornerstone of modern containerization practices.

**Key Points**
- Multi-stage builds use multiple FROM statements in a single Dockerfile
- Each FROM instruction begins a new build stage
- You can selectively copy artifacts from one stage to another
- Only the final stage results in an image
- Intermediate build stages are discarded, reducing final image size

### How Multi-stage Builds Work

A multi-stage build Dockerfile contains multiple FROM instructions. Each new FROM statement starts a new build stage with a clean state. You can copy files from previous stages using the `COPY --from=` syntax.

```dockerfile
# Stage 1: Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm install --production
CMD ["node", "dist/index.js"]
```

In this example, the first stage uses a full Node.js image to build the application, while the second stage uses a lightweight Alpine-based image and copies only the necessary files from the build stage.

### Reducing Image Size with Multi-stage Builds

One of the primary benefits of multi-stage builds is dramatically reduced image size.

**Key Points**
- Build tools and dependencies aren't included in the final image
- Only the artifacts needed for runtime are copied
- Smaller images mean faster deployments and reduced attack surface
- Reduced layers can improve performance

### Before and After Comparison

Traditional approach (single stage):
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["node", "dist/index.js"]
# Final image size: ~1.5 GB
```

Multi-stage approach:
```dockerfile
FROM node:18 AS builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm install --production
CMD ["node", "dist/index.js"]
# Final image size: ~300 MB
```

### Build Arguments

Build arguments provide flexibility in multi-stage builds by allowing parameters to be passed at build time.

**Key Points**
- Defined with ARG instruction
- Can be set during build with `--build-arg`
- Available only during build time (not at runtime)
- Can be used in any stage
- Each stage can have its own ARGs

**Example**
```dockerfile
# Define argument
ARG NODE_VERSION=18

# Use argument in FROM statement
FROM node:${NODE_VERSION} AS builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Use the same argument in another stage
FROM node:${NODE_VERSION}-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/index.js"]
```

To build with a specific Node version:
```bash
docker build --build-arg NODE_VERSION=16 -t myapp:latest .
```

### Advanced ARG Techniques

Build arguments can be used for conditional logic within your Dockerfile:

```dockerfile
ARG ENV=production

FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN if [ "$ENV" = "production" ]; then \
      npm run build:prod; \
    else \
      npm run build:dev; \
    fi

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

ARGs can also be redefined between stages:

```dockerfile
ARG VERSION=latest
FROM ubuntu:${VERSION} AS base

# Redefine with a different default
ARG VERSION=alpine
FROM nginx:${VERSION} AS final
```

### Creating Efficient Development and Production Images

Multi-stage builds can help create separate development and production images from a single Dockerfile.

**Key Points**
- Target specific stages with `--target` flag
- Share common base layers between dev and prod
- Different optimizations can be applied to each environment
- Keep development tooling in dev images, strip them from prod

**Example**
```dockerfile
# Base stage with common dependencies
FROM node:18 AS base
WORKDIR /app
COPY package*.json ./
RUN npm install

# Development stage with dev tools
FROM base AS development
ENV NODE_ENV=development
RUN npm install --only=development
COPY . .
CMD ["npm", "run", "dev"]

# Build stage
FROM base AS build
COPY . .
RUN npm run build

# Production stage - minimal final image
FROM node:18-alpine AS production
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY package*.json ./
RUN npm install --production
CMD ["node", "dist/index.js"]
```

Build for development:
```bash
docker build --target development -t myapp:dev .
```

Build for production:
```bash
docker build --target production -t myapp:prod .
```

### Named Stages

Named stages make Dockerfiles more readable and maintainable:

```dockerfile
FROM node:18 AS builder
# Builder configuration

FROM python:3.11 AS validator
# Validation configuration

FROM node:18-alpine AS final
COPY --from=builder /app/dist ./dist
COPY --from=validator /app/reports ./reports
```

### Optimizing Build Context

The build context is all the files sent to the Docker daemon during a build. Optimizing it speeds up builds and improves efficiency.

**Key Points**
- Use .dockerignore to exclude unnecessary files
- Organize files to minimize context changes
- Start with commands least likely to change
- Group related commands to reduce layers

### .dockerignore Best Practices

Create a comprehensive .dockerignore file to exclude files not needed for the build:

```
# Version control
.git
.gitignore

# Development artifacts
node_modules
npm-debug.log
yarn-debug.log
yarn-error.log

# Build artifacts
dist
build
*.o
*.obj

# Testing and documentation
test
__tests__
docs
*.md

# Environment and editor
.env
.env.*
.vscode
.idea
*.swp
*.swo

# OS specific
.DS_Store
Thumbs.db
```

### Layer Optimization in Multi-stage Builds

Order matters in Dockerfiles. Place instructions that change less frequently earlier in the file:

```dockerfile
FROM node:18 AS builder
WORKDIR /app

# Files that change less frequently
COPY package*.json ./
RUN npm install

# Files that change more frequently
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm install --production
CMD ["node", "dist/index.js"]
```

### Build Caching

Multi-stage builds work efficiently with Docker's build cache:

**Key Points**
- Each instruction creates a layer that can be cached
- Cache is invalidated when a file in COPY changes
- Using specific paths in COPY preserves cache when unrelated files change
- Split COPY instructions to optimize caching

**Example**
```dockerfile
FROM node:18 AS builder
WORKDIR /app

# Will only invalidate cache if package files change
COPY package.json package-lock.json ./
RUN npm install

# Will only invalidate cache if source files change
COPY src/ ./src/
RUN npm run build
```

### Multi-architecture Support

Multi-stage builds work well with multi-architecture builds:

```dockerfile
FROM --platform=$BUILDPLATFORM node:18 AS builder
ARG TARGETPLATFORM
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM --platform=$TARGETPLATFORM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/index.js"]
```

### Real-world Examples

#### Go Application

```dockerfile
FROM golang:1.20 AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/app .
CMD ["./app"]
```

#### Java Spring Boot Application

```dockerfile
FROM maven:3.8-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### React Frontend with Nginx

```dockerfile
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Advanced Multi-stage Techniques

#### Parallel Builds

Multiple independent stages can be created for components that don't depend on each other:

```dockerfile
FROM golang:1.20 AS backend-builder
WORKDIR /backend
COPY backend/ .
RUN go build -o server .

FROM node:18 AS frontend-builder
WORKDIR /frontend
COPY frontend/ .
RUN npm install && npm run build

FROM alpine:latest
COPY --from=backend-builder /backend/server /app/server
COPY --from=frontend-builder /frontend/build /app/public
CMD ["/app/server"]
```

#### Debugging Multi-stage Builds

Debug intermediate stages by building with a specific target:

```bash
docker build --target builder -t debug-image .
docker run -it debug-image sh
```

### Best Practices for Multi-stage Builds

**Key Points**
- Name your stages for better readability
- Keep your final stage minimal
- Combine RUN instructions to reduce layers
- Use specific COPY commands rather than COPY . .
- Leverage build cache by ordering instructions intelligently
- Use .dockerignore to exclude unnecessary files
- Set appropriate permissions in the final image
- Consider security scanning of the final image

### Common Pitfalls

- Forgetting to copy runtime dependencies from build stages
- Not considering user permissions between stages
- Unnecessary files being copied between stages
- Hardcoding secrets or credentials in intermediate stages
- Not leveraging build cache effectively
- Overly complex Dockerfiles with too many stages

### Integrating with CI/CD

Multi-stage builds integrate well with CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
build:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    - name: Build development image
      run: docker build --target development -t myapp:dev .
    - name: Run tests
      run: docker run myapp:dev npm test
    - name: Build production image
      run: docker build --target production -t myapp:prod .
    - name: Push production image
      run: docker push myapp:prod
```

### Related Topics

- Docker BuildKit for advanced build capabilities
- Docker image security scanning
- Docker Compose for multi-container applications
- Container orchestration with Kubernetes
- Image layer optimization techniques

---

