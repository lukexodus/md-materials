## Docker Compose


Docker Compose is a tool for defining and running multi-container applications using a YAML file (`docker-compose.yml` or `compose.yaml`).

### Basic compose.yaml Structure

```yaml
version: "3.9"

services:
  web:
    build: .
    ports:
      - "8080:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgres://user:pass@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./logs:/app/logs
    networks:
      - appnet

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - appnet

volumes:
  pgdata:

networks:
  appnet:
```

### Common Compose Commands

```bash
# Start all services in detached mode (build images if needed)
docker compose up -d --build

# Stop all services
docker compose down

# Stop and remove volumes (destructive)
docker compose down -v

# View logs for all services
docker compose logs -f

# View logs for a specific service
docker compose logs -f web

# Scale a service
docker compose up -d --scale web=3

# Run a one-off command in a service
docker compose run --rm web bash

# Execute a command in a running service
docker compose exec db psql -U user mydb

# View running services
docker compose ps

# Pull updated images without starting
docker compose pull

# Build images without starting
docker compose build
```

### Environment Variables in Compose

Compose automatically reads a `.env` file in the same directory:

```env
POSTGRES_PASSWORD=secretpassword
APP_VERSION=2.1.0
```

Reference them in `compose.yaml`:

```yaml
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

### Overrides and Multiple Compose Files

Compose merges multiple files, which is useful for environment-specific configuration:

```bash
# Development (default + override)
docker compose -f compose.yaml -f compose.dev.yaml up

# Production
docker compose -f compose.yaml -f compose.prod.yaml up
```

---

