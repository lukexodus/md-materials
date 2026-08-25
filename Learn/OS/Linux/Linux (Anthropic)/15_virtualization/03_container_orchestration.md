## Container Orchestration


### Docker Compose

Docker Compose orchestrates multi-container applications through declarative YAML configuration files, enabling developers to define, manage, and scale complex application stacks as cohesive units.

#### Compose File Structure and Syntax

Docker Compose files follow a hierarchical structure defining services, networks, and volumes:

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build:
      context: ./web
      dockerfile: Dockerfile
      args:
        - BUILD_ENV=production
    ports:
      - "80:8000"
      - "443:8443"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - REDIS_URL=redis://cache:6379
    depends_on:
      - db
      - cache
    volumes:
      - ./web/static:/app/static:ro
      - app_logs:/var/log/app
    networks:
      - frontend
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - backend
    restart: always
    command: postgres -c shared_preload_libraries=pg_stat_statements

  cache:
    image: redis:6-alpine
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - backend
    restart: always

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  app_logs:
    driver: local

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

#### Environment Configuration Management

Environment-specific configurations enable deployment across different stages:

```yaml
# docker-compose.override.yml (development)
version: '3.8'

services:
  web:
    build:
      target: development
    volumes:
      - ./web:/app:delegated
    environment:
      - DEBUG=true
      - LOG_LEVEL=debug
    ports:
      - "8000:8000"
    command: python manage.py runserver 0.0.0.0:8000

  db:
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: myapp_dev
```

```yaml
# docker-compose.prod.yml (production)
version: '3.8'

services:
  web:
    build:
      target: production
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/ssl:ro
    depends_on:
      - web
    networks:
      - frontend
```

#### Build Configuration and Multi-Stage Dockerfiles

Optimized build processes reduce image sizes and improve deployment efficiency:

```dockerfile
# web/Dockerfile
FROM node:16-alpine AS frontend-builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY src/ ./src/
RUN npm run build

FROM python:3.9-slim AS base
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

FROM base AS dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM base AS development
COPY --from=dependencies /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt
COPY . .
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

FROM base AS production
COPY --from=dependencies /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=frontend-builder /app/dist ./static/
COPY . .
RUN python manage.py collectstatic --noinput
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "myapp.wsgi:application"]
```

#### Service Dependencies and Startup Ordering

Docker Compose provides dependency management through `depends_on` and health checks:

```yaml
services:
  web:
    depends_on:
      db:
        condition: service_healthy
      migrations:
        condition: service_completed_successfully
    healthcheck:
      test: ["CMD", "python", "manage.py", "check", "--database", "default"]
      interval: 30s
      timeout: 10s
      retries: 5

  migrations:
    build: ./web
    command: python manage.py migrate
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./web:/app
    networks:
      - backend

  db:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Multi-Container Applications

Complex applications require orchestration of multiple specialized containers working together to provide comprehensive functionality.

#### Microservices Architecture Implementation

Microservices decomposition requires careful service boundary definition and inter-service communication strategies:

```yaml
# microservices-stack.yml
version: '3.8'

services:
  # API Gateway
  api-gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/gateway.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - user-service
      - order-service
      - product-service
    networks:
      - frontend
      - backend

  # User Management Service
  user-service:
    build: ./services/user
    environment:
      - DATABASE_URL=postgresql://user:pass@user-db:5432/users
      - JWT_SECRET=${JWT_SECRET}
      - REDIS_URL=redis://cache:6379
    depends_on:
      - user-db
      - cache
    networks:
      - backend
    deploy:
      replicas: 2

  user-db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - user_data:/var/lib/postgresql/data
    networks:
      - backend

  # Order Management Service
  order-service:
    build: ./services/order
    environment:
      - DATABASE_URL=postgresql://order:pass@order-db:5432/orders
      - MESSAGE_QUEUE_URL=amqp://rabbitmq:5672
      - USER_SERVICE_URL=http://user-service:8000
    depends_on:
      - order-db
      - rabbitmq
    networks:
      - backend

  order-db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: orders
      POSTGRES_USER: order
      POSTGRES_PASSWORD: pass
    volumes:
      - order_data:/var/lib/postgresql/data
    networks:
      - backend

  # Product Catalog Service
  product-service:
    build: ./services/product
    environment:
      - MONGODB_URL=mongodb://product-db:27017/products
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    depends_on:
      - product-db
      - elasticsearch
    networks:
      - backend

  product-db:
    image: mongo:4.4
    volumes:
      - product_data:/data/db
    networks:
      - backend

  # Search Service
  elasticsearch:
    image: elasticsearch:7.10.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    networks:
      - backend

  # Message Queue
  rabbitmq:
    image: rabbitmq:3-management
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD}
    ports:
      - "15672:15672"  # Management interface
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - backend

  # Shared Cache
  cache:
    image: redis:6-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - cache_data:/data
    networks:
      - backend

volumes:
  user_data:
  order_data:
  product_data:
  es_data:
  rabbitmq_data:
  cache_data:

networks:
  frontend:
  backend:
    internal: true
```

#### Service Communication Patterns

Inter-service communication requires consideration of synchronous and asynchronous patterns:

**Synchronous HTTP communication:**

```python
# services/order/app.py
import requests
import os

USER_SERVICE_URL = os.getenv('USER_SERVICE_URL')

def validate_user(user_id):
    try:
        response = requests.get(
            f"{USER_SERVICE_URL}/users/{user_id}",
            timeout=5,
            headers={'Authorization': f'Bearer {get_service_token()}'}
        )
        return response.status_code == 200
    except requests.RequestException:
        return False  # Fail closed for security
```

**Asynchronous message queue communication:**

```python
# services/order/events.py
import pika
import json
import os

def publish_order_created(order_data):
    connection = pika.BlockingConnection(
        pika.URLParameters(os.getenv('MESSAGE_QUEUE_URL'))
    )
    channel = connection.channel()
    
    channel.exchange_declare(exchange='orders', exchange_type='topic')
    
    channel.basic_publish(
        exchange='orders',
        routing_key='order.created',
        body=json.dumps(order_data),
        properties=pika.BasicProperties(
            delivery_mode=2,  # Make message persistent
            content_type='application/json'
        )
    )
    connection.close()
```

#### Load Balancer Configuration

Load balancing distributes traffic across service instances:

```nginx
# nginx/gateway.conf
upstream user_service {
    least_conn;
    server user-service:8000 max_fails=3 fail_timeout=30s;
    server user-service:8000 max_fails=3 fail_timeout=30s;
}

upstream order_service {
    ip_hash;  # Session affinity
    server order-service:8000 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    
    location /api/users/ {
        proxy_pass http://user_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    location /api/orders/ {
        proxy_pass http://order_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### Service Scaling

Container scaling adapts resource allocation to meet demand fluctuations through horizontal and vertical scaling strategies.

#### Docker Compose Scaling Commands

Docker Compose provides basic scaling capabilities for development and testing:

```bash
# Scale specific services
docker-compose up --scale web=3 --scale worker=5

# Scale with resource constraints
docker-compose --compatibility up --scale web=3

# Check scaling status
docker-compose ps
```

**Scaling configuration in compose file:**

```yaml
services:
  web:
    build: ./web
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
```

#### Auto-scaling Implementation

Auto-scaling requires external monitoring and orchestration [Inference - Docker Compose lacks built-in auto-scaling]:

```bash
#!/bin/bash
# auto-scale.sh - Basic auto-scaling script
SERVICE_NAME="web"
MIN_REPLICAS=2
MAX_REPLICAS=10
CPU_THRESHOLD=70

while true; do
    # Get current replica count
    CURRENT_REPLICAS=$(docker-compose ps -q $SERVICE_NAME | wc -l)
    
    # Get average CPU usage
    CPU_USAGE=$(docker stats --no-stream --format "table {{.CPUPerc}}" | grep -v CPU | sed 's/%//' | awk '{sum+=$1} END {print sum/NR}')
    
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        if [ $CURRENT_REPLICAS -lt $MAX_REPLICAS ]; then
            NEW_REPLICAS=$((CURRENT_REPLICAS + 1))
            echo "Scaling up to $NEW_REPLICAS replicas (CPU: ${CPU_USAGE}%)"
            docker-compose up --scale $SERVICE_NAME=$NEW_REPLICAS -d
        fi
    elif (( $(echo "$CPU_USAGE < 30" | bc -l) )); then
        if [ $CURRENT_REPLICAS -gt $MIN_REPLICAS ]; then
            NEW_REPLICAS=$((CURRENT_REPLICAS - 1))
            echo "Scaling down to $NEW_REPLICAS replicas (CPU: ${CPU_USAGE}%)"
            docker-compose up --scale $SERVICE_NAME=$NEW_REPLICAS -d
        fi
    fi
    
    sleep 60
done
```

#### Load Testing and Capacity Planning

Performance testing validates scaling effectiveness:

```yaml
# load-test.yml
version: '3.8'

services:
  load-test:
    image: loadimpact/k6:latest
    volumes:
      - ./tests:/scripts
    command: run /scripts/load-test.js
    environment:
      - TARGET_URL=http://web:8000
    networks:
      - frontend
    depends_on:
      - web

  web:
    build: ./web
    deploy:
      replicas: 1
    networks:
      - frontend
```

```javascript
// tests/load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 10 },   // Ramp up
    { duration: '5m', target: 10 },   // Sustained load
    { duration: '2m', target: 50 },   // Spike test
    { duration: '5m', target: 50 },   // Sustained spike
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% under 500ms
    http_req_failed: ['rate<0.1'],     // Error rate under 10%
  },
};

export default function() {
  let response = http.get(`${__ENV.TARGET_URL}/api/health`);
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

### Container Monitoring

Comprehensive monitoring provides visibility into container performance, resource utilization, and application health.

#### Prometheus and Grafana Integration

Prometheus collects metrics while Grafana provides visualization and alerting:

```yaml
# monitoring-stack.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/rules:/etc/prometheus/rules:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
    networks:
      - monitoring

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
```

**Prometheus configuration:**

```yaml
# prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'application'
    static_configs:
      - targets: ['web:8000', 'api:8001']
    metrics_path: '/metrics'
    scrape_interval: 5s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

#### Application Performance Monitoring

APM integration provides deep application insights:

```python
# web/monitoring.py
from prometheus_client import Counter, Histogram, Gauge, generate_latest
import time
import psutil

# Custom metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency')
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Active database connections')
MEMORY_USAGE = Gauge('memory_usage_bytes', 'Memory usage in bytes')

def track_metrics(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            REQUEST_COUNT.labels(method='GET', endpoint='/api/data').inc()
            return result
        finally:
            REQUEST_LATENCY.observe(time.time() - start_time)
            MEMORY_USAGE.set(psutil.virtual_memory().used)
    return wrapper

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain; charset=utf-8'}
```

#### Log Aggregation and Analysis

Centralized logging enables comprehensive troubleshooting:

```yaml
# logging-stack.yml
services:
  elasticsearch:
    image: elasticsearch:7.10.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    networks:
      - logging

  logstash:
    image: logstash:7.10.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline:ro
      - ./logstash/config:/usr/share/logstash/config:ro
    ports:
      - "5044:5044"
    environment:
      LS_JAVA_OPTS: "-Xmx256m -Xms256m"
    networks:
      - logging
    depends_on:
      - elasticsearch

  kibana:
    image: kibana:7.10.0
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    networks:
      - logging
    depends_on:
      - elasticsearch

  filebeat:
    image: elastic/filebeat:7.10.0
    user: root
    volumes:
      - ./filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - logging
    depends_on:
      - logstash
```

#### Health Check Implementation

Comprehensive health checks ensure service reliability:

```python
# web/health.py
from flask import Flask, jsonify
import psycopg2
import redis
import requests

app = Flask(__name__)

@app.route('/health')
def health_check():
    checks = {
        'database': check_database(),
        'cache': check_cache(),
        'external_api': check_external_service(),
        'disk_space': check_disk_space(),
    }
    
    overall_status = 'healthy' if all(checks.values()) else 'unhealthy'
    status_code = 200 if overall_status == 'healthy' else 503
    
    return jsonify({
        'status': overall_status,
        'checks': checks,
        'timestamp': time.time()
    }), status_code

def check_database():
    try:
        conn = psycopg2.connect(os.getenv('DATABASE_URL'))
        cursor = conn.cursor()
        cursor.execute('SELECT 1')
        conn.close()
        return True
    except Exception:
        return False

def check_cache():
    try:
        r = redis.from_url(os.getenv('REDIS_URL'))
        r.ping()
        return True
    except Exception:
        return False
```

**Key points:**

- Docker Compose enables multi-container application orchestration through declarative configuration
- Service scaling requires consideration of resource constraints and load distribution strategies
- Comprehensive monitoring combines infrastructure metrics, application performance data, and centralized logging
- Health checks and automated recovery mechanisms improve system reliability

**Conclusion:** Container orchestration with Docker Compose provides foundation for complex application management, though production environments typically require more advanced orchestration platforms like Kubernetes for enterprise-scale deployments [Inference based on Docker Compose limitations in production environments].

---

