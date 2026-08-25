## Docker Compose for Local Development


Docker Compose defines and runs multi-container applications using a YAML file (`compose.yaml` or `docker-compose.yml`). It is the standard tool for orchestrating services locally.

### Example compose.yaml

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://user:password@db:5432/mydb
    volumes:
      - ./src:/app/src
    depends_on:
      db:
        condition: service_healthy
    develop:
      watch:
        - action: sync
          path: ./src
          target: /app/src

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  db-data:
```

### Common Compose Commands

```bash
docker compose up -d          # Start all services in detached mode
docker compose up --build     # Rebuild images before starting
docker compose down           # Stop and remove containers (volumes preserved)
docker compose down -v        # Stop, remove containers, and remove volumes
docker compose logs -f app    # Follow logs for a specific service
docker compose exec app sh    # Open a shell in a running service
docker compose ps             # List running services
docker compose restart app    # Restart a specific service
```

### Watch Mode (Compose Develop)

The `develop.watch` block (introduced in Compose v2.22) enables file-sync and hot-reload behavior without running a separate file-watching utility. The `sync` action copies changed files into the running container; the `rebuild` action triggers a full image rebuild.

### Service Profiles

Profiles allow optional services (e.g., a mail catcher, a monitoring stack) to be included only when explicitly requested:

```yaml
services:
  mailhog:
    image: mailhog/mailhog
    profiles: ["tools"]
```

```bash
docker compose --profile tools up
```

---

