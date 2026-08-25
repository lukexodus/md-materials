## Containerization


### Docker Containers for MongoDB

Docker provides a standardized way to package and deploy MongoDB instances with consistent environments across development, testing, and production scenarios.

**Basic MongoDB container setup:**

```dockerfile
# Dockerfile for custom MongoDB image
FROM mongo:7.0

# Set environment variables
ENV MONGO_INITDB_ROOT_USERNAME=admin
ENV MONGO_INITDB_ROOT_PASSWORD=password123
ENV MONGO_INITDB_DATABASE=myapp

# Copy initialization scripts
COPY ./init-scripts/ /docker-entrypoint-initdb.d/

# Copy custom configuration
COPY mongod.conf /etc/mongod.conf

# Create data directory with proper permissions
RUN mkdir -p /data/db /data/logs && \
    chown -R mongodb:mongodb /data

# Expose MongoDB port
EXPOSE 27017

# Use custom configuration
CMD ["mongod", "--config", "/etc/mongod.conf"]
```

**Running MongoDB container with docker run:**

```bash
# Basic MongoDB container
docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password123 \
  -v mongodb_data:/data/db \
  -v mongodb_logs:/data/logs \
  mongo:7.0

# MongoDB with custom configuration
docker run -d \
  --name mongodb-custom \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password123 \
  -v $(pwd)/mongod.conf:/etc/mongod.conf:ro \
  -v $(pwd)/init-scripts:/docker-entrypoint-initdb.d:ro \
  -v mongodb_data:/data/db \
  -v mongodb_logs:/data/logs \
  mongo:7.0 mongod --config /etc/mongod.conf

# MongoDB replica set member
docker run -d \
  --name mongodb-replica-1 \
  --network mongodb-network \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password123 \
  -v mongodb_replica1_data:/data/db \
  mongo:7.0 mongod --replSet rs0 --bind_ip_all
```

**Custom MongoDB configuration file:**

```yaml
# mongod.conf
storage:
  dbPath: /data/db
  journal:
    enabled: true
  wiredTiger:
    engineConfig:
      cacheSizeGB: 2

systemLog:
  destination: file
  logAppend: true
  path: /data/logs/mongod.log
  logRotate: rename

net:
  port: 27017
  bindIp: 0.0.0.0

processManagement:
  timeZoneInfo: /usr/share/zoneinfo

security:
  authorization: enabled

replication:
  replSetName: rs0

operationProfiling:
  slowOpThresholdMs: 100
  mode: slowOp
```

**Database initialization script:**

```javascript
// init-scripts/01-create-users.js
db = db.getSiblingDB('myapp');

db.createUser({
  user: 'appuser',
  pwd: 'apppassword',
  roles: [
    {
      role: 'readWrite',
      db: 'myapp'
    }
  ]
});

// Create collections with validation
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['username', 'email'],
      properties: {
        username: {
          bsonType: 'string',
          description: 'must be a string and is required'
        },
        email: {
          bsonType: 'string',
          pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          description: 'must be a valid email address'
        }
      }
    }
  }
});

// Create indexes
db.users.createIndex({ username: 1 }, { unique: true });
db.users.createIndex({ email: 1 }, { unique: true });

print('Database initialization completed');
```

**MongoDB container with security hardening:**

```dockerfile
FROM mongo:7.0

# Create non-root user for MongoDB
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb

# Set up directory structure
RUN mkdir -p /data/db /data/logs /data/configdb && \
    chown -R mongodb:mongodb /data

# Copy security configuration
COPY --chown=mongodb:mongodb mongod-secure.conf /etc/mongod.conf
COPY --chown=mongodb:mongodb keyfile /data/keyfile
RUN chmod 600 /data/keyfile

# Switch to non-root user
USER mongodb

EXPOSE 27017

CMD ["mongod", "--config", "/etc/mongod.conf"]
```

### Docker Compose for Development

Docker Compose simplifies multi-container MongoDB deployments, including replica sets, sharding clusters, and application stacks.

**Basic MongoDB with application stack:**

```yaml
# docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:7.0
    container_name: mongodb
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password123
      MONGO_INITDB_DATABASE: myapp
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - mongodb_logs:/data/logs
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
      - ./mongod.conf:/etc/mongod.conf:ro
    networks:
      - app-network
    command: mongod --config /etc/mongod.conf

  app:
    build: .
    container_name: myapp
    restart: unless-stopped
    environment:
      - MONGODB_URI=mongodb://admin:password123@mongodb:27017/myapp?authSource=admin
    ports:
      - "3000:3000"
    depends_on:
      - mongodb
    networks:
      - app-network
    volumes:
      - ./app:/usr/src/app
      - /usr/src/app/node_modules

  mongo-express:
    image: mongo-express:latest
    container_name: mongo-express
    restart: unless-stopped
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: admin
      ME_CONFIG_MONGODB_ADMINPASSWORD: password123
      ME_CONFIG_MONGODB_URL: mongodb://admin:password123@mongodb:27017/
      ME_CONFIG_BASICAUTH_USERNAME: admin
      ME_CONFIG_BASICAUTH_PASSWORD: admin123
    ports:
      - "8081:8081"
    depends_on:
      - mongodb
    networks:
      - app-network

volumes:
  mongodb_data:
    driver: local
  mongodb_logs:
    driver: local

networks:
  app-network:
    driver: bridge
```

**MongoDB replica set with Docker Compose:**

```yaml
# docker-compose.replica.yml
version: '3.8'

services:
  mongodb-primary:
    image: mongo:7.0
    container_name: mongodb-primary
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password123
    ports:
      - "27017:27017"
    volumes:
      - mongodb_primary_data:/data/db
      - mongodb_primary_logs:/data/logs
      - ./replica-keyfile:/data/keyfile:ro
    networks:
      - mongodb-replica
    command: >
      mongod --replSet rs0 
             --keyFile /data/keyfile 
             --bind_ip_all 
             --port 27017
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 3

  mongodb-secondary1:
    image: mongo:7.0
    container_name: mongodb-secondary1
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password123
    ports:
      - "27018:27017"
    volumes:
      - mongodb_secondary1_data:/data/db
      - mongodb_secondary1_logs:/data/logs
      - ./replica-keyfile:/data/keyfile:ro
    networks:
      - mongodb-replica
    command: >
      mongod --replSet rs0 
             --keyFile /data/keyfile 
             --bind_ip_all 
             --port 27017
    depends_on:
      - mongodb-primary

  mongodb-secondary2:
    image: mongo:7.0
    container_name: mongodb-secondary2
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password123
    ports:
      - "27019:27017"
    volumes:
      - mongodb_secondary2_data:/data/db
      - mongodb_secondary2_logs:/data/logs
      - ./replica-keyfile:/data/keyfile:ro
    networks:
      - mongodb-replica
    command: >
      mongod --replSet rs0 
             --keyFile /data/keyfile 
             --bind_ip_all 
             --port 27017
    depends_on:
      - mongodb-primary

  mongodb-arbiter:
    image: mongo:7.0
    container_name: mongodb-arbiter
    restart: unless-stopped
    ports:
      - "27020:27017"
    volumes:
      - ./replica-keyfile:/data/keyfile:ro
    networks:
      - mongodb-replica
    command: >
      mongod --replSet rs0 
             --keyFile /data/keyfile 
             --bind_ip_all 
             --port 27017
             --nojournal
             --smallfiles
    depends_on:
      - mongodb-primary

  replica-setup:
    image: mongo:7.0
    container_name: replica-setup
    networks:
      - mongodb-replica
    depends_on:
      - mongodb-primary
      - mongodb-secondary1
      - mongodb-secondary2
      - mongodb-arbiter
    volumes:
      - ./setup-replica.js:/setup-replica.js:ro
    command: >
      bash -c "
        sleep 30 &&
        mongosh --host mongodb-primary:27017 -u admin -p password123 --authenticationDatabase admin /setup-replica.js
      "

volumes:
  mongodb_primary_data:
  mongodb_primary_logs:
  mongodb_secondary1_data:
  mongodb_secondary1_logs:
  mongodb_secondary2_data:
  mongodb_secondary2_logs:

networks:
  mongodb-replica:
    driver: bridge
```

**Replica set initialization script:**

```javascript
// setup-replica.js
rs.initiate({
  _id: "rs0",
  members: [
    {
      _id: 0,
      host: "mongodb-primary:27017",
      priority: 2
    },
    {
      _id: 1,
      host: "mongodb-secondary1:27017",
      priority: 1
    },
    {
      _id: 2,
      host: "mongodb-secondary2:27017",
      priority: 1
    },
    {
      _id: 3,
      host: "mongodb-arbiter:27017",
      arbiterOnly: true
    }
  ]
});

// Wait for replica set to be ready
sleep(5000);

// Check replica set status
rs.status();

print("Replica set initialization completed");
```

**Sharded cluster with Docker Compose:**

```yaml
# docker-compose.sharded.yml
version: '3.8'

services:
  # Config servers
  configsvr1:
    image: mongo:7.0
    container_name: configsvr1
    restart: unless-stopped
    ports:
      - "27019:27017"
    volumes:
      - configsvr1_data:/data/db
      - ./shard-keyfile:/data/keyfile:ro
    networks:
      - mongodb-sharded
    command: mongod --configsvr --replSet configReplSet --keyFile /data/keyfile --bind_ip_all

  configsvr2:
    image: mongo:7.0
    container_name: configsvr2
    restart: unless-stopped
    ports:
      - "27020:27017"
    volumes:
      - configsvr2_data:/data/db
      - ./shard-keyfile:/data/keyfile:ro
    networks:
      - mongodb-sharded
    command: mongod --configsvr --replSet configReplSet --keyFile /data/keyfile --bind_ip_all

  configsvr3:
    image: mongo:7.0
    container_name: configsvr3
    restart: unless-stopped
    ports:
      - "27021:27017"
    volumes:
      - configsvr3_data:/data/db
      - ./shard-keyfile:/data/keyfile:ro
    networks:
      - mongodb-sharded
    command: mongod --configsvr --replSet configReplSet --keyFile /data/keyfile --bind_ip_all

  # Shard 1
  shard1svr1:
    image: mongo:7.0
    container_name: shard1svr1
    restart: unless-stopped
    ports:
      - "27022:27017"
    volumes:
      - shard1svr1_data:/data/db
      - ./shard-keyfile:/data/keyfile:ro
    networks:
      - mongodb-sharded
    command: mongod --shardsvr --replSet shard1ReplSet --keyFile /data/keyfile --bind_ip_all

  shard1svr2:
    image: mongo:7.0
    container_name: shard1svr2
    restart: unless-stopped
    ports:
      - "27023:27017"
    volumes:
      - shard1svr2_data:/data/db
      - ./shard-keyfile:/data/keyfile:ro
    networks:
      - mongodb-sharded
    command: mongod --shardsvr --replSet shard1ReplSet --keyFile /data/keyfile --bind_ip_all

  # Shard 2
  shard2svr1:
    image: mongo:7.0
    container_name: shard2svr1
    restart: unless-stopped
    ports:
      - "27024:27017"
    volumes:
      - shard2svr1_data:/data/db
      - ./shard-keyfile:/data/keyfile:ro
    networks:
      - mongodb-sharded
    command: mongod --shardsvr --replSet shard2ReplSet --keyFile /data/keyfile --bind_ip_all

  shard2svr2:
    image: mongo:7.0
    container_name: shard2svr2
    restart: unless-stopped
    ports:
      - "27025:27017"
    volumes:
      - shard2svr2_data:/data/db
      - ./shard-keyfile:/data/keyfile:ro
    networks:
      - mongodb-sharded
    command: mongod --shardsvr --replSet shard2ReplSet --keyFile /data/keyfile --bind_ip_all

  # Mongos routers
  mongos1:
    image: mongo:7.0
    container_name: mongos1
    restart: unless-stopped
    ports:
      - "27017:27017"
    networks:
      - mongodb-sharded
    command: mongos --configdb configReplSet/configsvr1:27017,configsvr2:27017,configsvr3:27017 --keyFile /data/keyfile --bind_ip_all
    volumes:
      - ./shard-keyfile:/data/keyfile:ro
    depends_on:
      - configsvr1
      - configsvr2
      - configsvr3

  mongos2:
    image: mongo:7.0
    container_name: mongos2
    restart: unless-stopped
    ports:
      - "27018:27017"
    networks:
      - mongodb-sharded
    command: mongos --configdb configReplSet/configsvr1:27017,configsvr2:27017,configsvr3:27017 --keyFile /data/keyfile --bind_ip_all
    volumes:
      - ./shard-keyfile:/data/keyfile:ro
    depends_on:
      - configsvr1
      - configsvr2
      - configsvr3

volumes:
  configsvr1_data:
  configsvr2_data:
  configsvr3_data:
  shard1svr1_data:
  shard1svr2_data:
  shard2svr1_data:
  shard2svr2_data:

networks:
  mongodb-sharded:
    driver: bridge
```

### Kubernetes StatefulSets

Kubernetes StatefulSets provide ordered deployment, persistent storage, and stable network identities essential for MongoDB clusters.

**MongoDB StatefulSet configuration:**

```yaml
# mongodb-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
  namespace: database
spec:
  serviceName: mongodb-headless
  replicas: 3
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      serviceAccountName: mongodb
      securityContext:
        fsGroup: 999
        runAsUser: 999
        runAsNonRoot: true
      containers:
      - name: mongodb
        image: mongo:7.0
        ports:
        - containerPort: 27017
          name: mongodb
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: username
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: password
        - name: MONGODB_REPLICA_SET_NAME
          value: "rs0"
        command:
        - mongod
        - --replSet
        - rs0
        - --bind_ip_all
        - --keyFile
        - /data/keyfile/keyfile
        - --auth
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
        - name: mongodb-config
          mountPath: /data/configdb
        - name: mongodb-keyfile
          mountPath: /data/keyfile
          readOnly: true
        - name: mongodb-logs
          mountPath: /data/logs
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "4Gi"
            cpu: "2"
        livenessProbe:
          exec:
            command:
            - mongosh
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - mongosh
            - --eval
            - "db.runCommand('ismaster').ismaster"
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: mongodb-keyfile
        secret:
          secretName: mongodb-keyfile
          defaultMode: 0600
      - name: mongodb-logs
        emptyDir: {}
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 50Gi
  - metadata:
      name: mongodb-config
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 1Gi
```

**MongoDB services and networking:**

```yaml
# mongodb-services.yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-headless
  namespace: database
spec:
  clusterIP: None
  selector:
    app: mongodb
  ports:
  - port: 27017
    targetPort: 27017
    name: mongodb

---
apiVersion: v1
kind: Service
metadata:
  name: mongodb-primary
  namespace: database
spec:
  selector:
    app: mongodb
    role: primary
  ports:
  - port: 27017
    targetPort: 27017
    name: mongodb
  type: ClusterIP

---
apiVersion: v1
kind: Service
metadata:
  name: mongodb-secondary
  namespace: database
spec:
  selector:
    app: mongodb
    role: secondary
  ports:
  - port: 27017
    targetPort: 27017
    name: mongodb
  type: ClusterIP

---
apiVersion: v1
kind: Service
metadata:
  name: mongodb-external
  namespace: database
spec:
  selector:
    app: mongodb
  ports:
  - port: 27017
    targetPort: 27017
    name: mongodb
  type: LoadBalancer
```

**MongoDB initialization Job:**

```yaml
# mongodb-init-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mongodb-replica-init
  namespace: database
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: replica-init
        image: mongo:7.0
        command:
        - /bin/bash
        - -c
        - |
          sleep 60
          mongosh --host mongodb-0.mongodb-headless.database.svc.cluster.local:27017 \
                  -u $MONGO_INITDB_ROOT_USERNAME \
                  -p $MONGO_INITDB_ROOT_PASSWORD \
                  --authenticationDatabase admin \
                  --eval "
                    rs.initiate({
                      _id: 'rs0',
                      members: [
                        {
                          _id: 0,
                          host: 'mongodb-0.mongodb-headless.database.svc.cluster.local:27017',
                          priority: 2
                        },
                        {
                          _id: 1,
                          host: 'mongodb-1.mongodb-headless.database.svc.cluster.local:27017',
                          priority: 1
                        },
                        {
                          _id: 2,
                          host: 'mongodb-2.mongodb-headless.database.svc.cluster.local:27017',
                          priority: 1
                        }
                      ]
                    });
                    
                    // Wait for replica set to be ready
                    while (rs.status().ok !== 1) {
                      sleep(1000);
                    }
                    
                    // Create application database and user
                    db = db.getSiblingDB('myapp');
                    db.createUser({
                      user: 'appuser',
                      pwd: 'apppassword',
                      roles: [{ role: 'readWrite', db: 'myapp' }]
                    });
                    
                    print('Replica set initialization completed');
                  "
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: username
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: password
```

**MongoDB secrets and ConfigMaps:**

```yaml
# mongodb-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-secret
  namespace: database
type: Opaque
data:
  username: YWRtaW4=  # admin (base64 encoded)
  password: cGFzc3dvcmQxMjM=  # password123 (base64 encoded)

---
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-keyfile
  namespace: database
type: Opaque
data:
  keyfile: |
    # Base64 encoded keyfile content
    # Generate with: openssl rand -base64 756 | tr -d '\n'

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: mongodb-config
  namespace: database
data:
  mongod.conf: |
    storage:
      dbPath: /data/db
      journal:
        enabled: true
      wiredTiger:
        engineConfig:
          cacheSizeGB: 2
    
    systemLog:
      destination: file
      logAppend: true
      path: /data/logs/mongod.log
    
    net:
      port: 27017
      bindIp: 0.0.0.0
    
    replication:
      replSetName: rs0
    
    security:
      authorization: enabled
      keyFile: /data/keyfile/keyfile
```

**MongoDB monitoring with Prometheus:**

```yaml
# mongodb-exporter.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb-exporter
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb-exporter
  template:
    metadata:
      labels:
        app: mongodb-exporter
    spec:
      containers:
      - name: mongodb-exporter
        image: percona/mongodb_exporter:0.37
        ports:
        - containerPort: 9216
          name: metrics
        env:
        - name: MONGODB_URI
          value: "mongodb://mongodb-exporter:password@mongodb-headless:27017/admin?ssl=false"
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"

---
apiVersion: v1
kind: Service
metadata:
  name: mongodb-exporter
  namespace: database
  labels:
    app: mongodb-exporter
spec:
  ports:
  - port: 9216
    targetPort: 9216
    name: metrics
  selector:
    app: mongodb-exporter
```

### Persistent Storage in Containers

Persistent storage ensures data durability and enables stateful MongoDB deployments across container restarts and migrations.

**Docker volume management:**

```bash
# Create named volumes
docker volume create mongodb_data
docker volume create mongodb_logs
docker volume create mongodb_config

# Inspect volume details
docker volume inspect mongodb_data

# List all volumes
docker volume ls

# Remove unused volumes
docker volume prune

# Backup volume data
docker run --rm -v mongodb_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/mongodb_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .

# Restore volume data
docker run --rm -v mongodb_data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/mongodb_backup_20240125_143000.tar.gz -C /data
```

**Bind mounts for development:**

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  mongodb:
    image: mongo:7.0
    container_name: mongodb-dev
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password123
    volumes:
      # Bind mounts for development
      - ./data/db:/data/db
      - ./data/logs:/data/logs
      - ./config/mongod.conf:/etc/mongod.conf:ro
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
    command: mongod --config /etc/mongod.conf
```

**Kubernetes storage classes:**

```yaml
# storage-class.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  fsType: ext4
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Retain

---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: mongodb-storage
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  zones: us-central1-a,us-central1-b,us-central1-c
  replication-type: regional-pd
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Retain
```

**Persistent Volume Claims:**

```yaml
# mongodb-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-data-pvc
  namespace: database
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 100Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-logs-pvc
  namespace: database
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 10Gi
```

**Volume backup and restore strategies:**

```yaml
# backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mongodb-backup
  namespace: database
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: mongodb-backup
            image: mongo:7.0
            command:
            - /bin/bash
            - -c
            - |
              DATE=$(date +%Y%m%d_%H%M%S)
              mongodump --host mongodb-primary:27017 \
                       --username $MONGO_USERNAME \
                       --password $MONGO_PASSWORD \
                       --authenticationDatabase admin \
                       --gzip \
                       --out /backup/mongodb_backup_$DATE
              
              # Upload to cloud storage (AWS S3 example)
              aws s3 sync /backup/mongodb_backup_$DATE \
                         s3://my-mongodb-backups/mongodb_backup_$DATE/
              
              # Cleanup old local backups (keep last 7 days)
              find /backup -type d -name "mongodb_backup_*" -mtime +7 -exec rm -rf {} \;
            env:
            - name: MONGO_USERNAME
              valueFrom:
                secretKeyRef:
                  name: mongodb-secret
                  key: username
            - name: MONGO_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mongodb-secret
                  key: password
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: aws-credentials
                  key: access-key-id
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: aws-credentials
                  key: secret-access-key
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: mongodb-backup-pvc
```

**Storage optimization and monitoring:**

```yaml
# storage-monitoring.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: storage-monitoring-script
  namespace: database
data:
  monitor.sh: |
    #!/bin/bash
    
    # Monitor disk usage
    while true; do
      USAGE=$(df -h /data/db | awk 'NR==2{print $5}' | sed 's/%//')
      AVAILABLE=$(df -h /data/db | awk 'NR==2{print $4}')
      
      echo "$(date): Disk usage: ${USAGE}%, Available: ${AVAILABLE}"
      
      # Alert if usage exceeds 80%
      if [ $USAGE -gt 80 ]; then
        echo "WARNING: Disk usage is ${USAGE}%" | \
        curl -X POST -H 'Content-type: application/json' \
             --data "{\"text\":\"MongoDB storage alert: ${USAGE}% disk usage\"}" \
             $SLACK_WEBHOOK_URL
      fi
      
      # Monitor MongoDB collection sizes
      mongosh --host localhost:27017 \
              --username $MONGO_USERNAME \
              --password $MONGO_PASSWORD \
              --authenticationDatabase admin \
              --eval "
                db.adminCommand('listCollections').cursor.firstBatch.forEach(
                  function(collection) {
                    var stats = db.getCollection(collection.name).stats();
                    print('Collection: ' + collection.name + 
                          ', Size: ' + (stats.size / 1024 / 1024).toFixed(2) + ' MB' +
                          ', Documents: ' + stats.count);
                  }
                );
              "
      
      sleep 300  # Check every 5 minutes
    done

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: storage-monitor
  namespace: database
spec:
  selector:
    matchLabels:
      app: storage-monitor
  template:
    metadata:
      labels:
        app: storage-monitor
    spec:
      containers:
      - name: monitor
        image: mongo:7.0
        command: ["/bin/bash", "/scripts/monitor.sh"]
        env:
        - name: MONGO_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: username
        - name: MONGO_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: password
        - name: SLACK_WEBHOOK_URL
          valueFrom:
            secretKeyRef:
              name: monitoring-secrets
              key: slack-webhook
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
          readOnly: true
        - name: monitoring-scripts
          mountPath: /scripts
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      volumes:
      - name: mongodb-data
        hostPath:
          path: /var/lib/mongodb
      - name: monitoring-scripts
        configMap:
          name: storage-monitoring-script
          defaultMode: 0755
```

**Volume expansion and migration:**

```yaml
# volume-expansion.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-data-expanded
  namespace: database
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 200Gi  # Expanded from 100Gi

---
# Migration Job
apiVersion: batch/v1
kind: Job
metadata:
  name: mongodb-data-migration
  namespace: database
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: data-migration
        image: alpine:latest
        command:
        - /bin/sh
        - -c
        - |
          echo "Starting data migration..."
          
          # Stop MongoDB gracefully
          kubectl scale statefulset mongodb --replicas=0 -n database
          
          # Wait for pods to terminate
          kubectl wait --for=delete pod -l app=mongodb -n database --timeout=300s
          
          # Copy data from old volume to new volume
          cp -av /old-data/* /new-data/
          
          # Verify data integrity
          if [ $? -eq 0 ]; then
            echo "Data migration completed successfully"
            
            # Update StatefulSet to use new PVC
            kubectl patch statefulset mongodb -n database -p '
            {
              "spec": {
                "volumeClaimTemplates": [
                  {
                    "metadata": {
                      "name": "mongodb-data"
                    },
                    "spec": {
                      "accessModes": ["ReadWriteOnce"],
                      "storageClassName": "fast-ssd",
                      "resources": {
                        "requests": {
                          "storage": "200Gi"
                        }
                      }
                    }
                  }
                ]
              }
            }'
            
            # Scale up MongoDB
            kubectl scale statefulset mongodb --replicas=3 -n database
          else
            echo "Data migration failed"
            exit 1
          fi
        volumeMounts:
        - name: old-data
          mountPath: /old-data
          readOnly: true
        - name: new-data
          mountPath: /new-data
      volumes:
      - name: old-data
        persistentVolumeClaim:
          claimName: mongodb-data-pvc
      - name: new-data
        persistentVolumeClaim:
          claimName: mongodb-data-expanded
      serviceAccountName: mongodb-operator
```

**Container storage best practices:**

```dockerfile
# Optimized MongoDB Dockerfile
FROM mongo:7.0

# Create optimized directory structure
RUN mkdir -p /data/db /data/logs /data/configdb /data/backup && \
    chown -R mongodb:mongodb /data

# Install monitoring and backup tools
RUN apt-get update && apt-get install -y \
    curl \
    awscli \
    prometheus-node-exporter \
    && rm -rf /var/lib/apt/lists/*

# Copy optimized MongoDB configuration
COPY mongod-container.conf /etc/mongod.conf

# Create backup script
COPY backup-script.sh /usr/local/bin/backup-mongodb
RUN chmod +x /usr/local/bin/backup-mongodb

# Set up log rotation
COPY mongodb-logrotate /etc/logrotate.d/mongodb

# Health check script
COPY healthcheck.sh /usr/local/bin/healthcheck
RUN chmod +x /usr/local/bin/healthcheck

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD /usr/local/bin/healthcheck

# Expose ports
EXPOSE 27017 9100

# Use non-root user
USER mongodb

# Start with custom entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["mongod", "--config", "/etc/mongod.conf"]
```

**Backup and disaster recovery automation:**

```bash
#!/bin/bash
# backup-script.sh

set -e

BACKUP_DIR="/data/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_$DATE"
RETENTION_DAYS=7

echo "Starting MongoDB backup: $BACKUP_NAME"

# Create backup directory
mkdir -p "$BACKUP_DIR/$BACKUP_NAME"

# Perform backup
mongodump \
  --host localhost:27017 \
  --username "$MONGO_USERNAME" \
  --password "$MONGO_PASSWORD" \
  --authenticationDatabase admin \
  --gzip \
  --out "$BACKUP_DIR/$BACKUP_NAME"

# Compress backup
tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" -C "$BACKUP_DIR" "$BACKUP_NAME"
rm -rf "$BACKUP_DIR/$BACKUP_NAME"

# Upload to cloud storage
if [ ! -z "$AWS_S3_BUCKET" ]; then
  aws s3 cp "$BACKUP_DIR/$BACKUP_NAME.tar.gz" \
           "s3://$AWS_S3_BUCKET/mongodb-backups/$BACKUP_NAME.tar.gz"
  echo "Backup uploaded to S3"
fi

# Cleanup old backups
find "$BACKUP_DIR" -name "mongodb_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Log backup completion
echo "Backup completed: $BACKUP_NAME"

# Send notification
if [ ! -z "$SLACK_WEBHOOK_URL" ]; then
  curl -X POST -H 'Content-type: application/json' \
       --data "{\"text\":\"MongoDB backup completed: $BACKUP_NAME\"}" \
       "$SLACK_WEBHOOK_URL"
fi
```

**Performance tuning for containerized MongoDB:**

```yaml
# mongodb-performance-tuning.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mongodb-performance-config
  namespace: database
data:
  mongod.conf: |
    # Storage Engine Configuration
    storage:
      dbPath: /data/db
      journal:
        enabled: true
      wiredTiger:
        engineConfig:
          # Use 60% of available memory for cache
          cacheSizeGB: 2.4
          # Optimize for SSD storage
          directoryForIndexes: true
        collectionConfig:
          blockCompressor: snappy
        indexConfig:
          prefixCompression: true
    
    # Network Configuration
    net:
      port: 27017
      bindIp: 0.0.0.0
      maxIncomingConnections: 1000
      # Enable compression
      compression:
        compressors: snappy,zstd
    
    # Operation Profiling
    operationProfiling:
      slowOpThresholdMs: 100
      mode: slowOp
    
    # Replication
    replication:
      replSetName: rs0
      # Optimize oplog size (5% of disk space)
      oplogSizeMB: 2560
    
    # Security
    security:
      authorization: enabled
      keyFile: /data/keyfile/keyfile
    
    # Process Management
    processManagement:
      timeZoneInfo: /usr/share/zoneinfo
    
    # System Log
    systemLog:
      destination: file
      logAppend: true
      path: /data/logs/mongod.log
      logRotate: rename
      # Reduce verbosity in production
      verbosity: 0

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb-optimized
  namespace: database
spec:
  serviceName: mongodb-headless
  replicas: 3
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      affinity:
        # Ensure pods are distributed across nodes
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - mongodb
            topologyKey: kubernetes.io/hostname
      containers:
      - name: mongodb
        image: mongo:7.0
        ports:
        - containerPort: 27017
        # Resource limits optimized for performance
        resources:
          requests:
            memory: "4Gi"
            cpu: "1"
          limits:
            memory: "8Gi"
            cpu: "4"
        # Security context
        securityContext:
          runAsUser: 999
          runAsGroup: 999
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false
        # Volume mounts
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
        - name: mongodb-config
          mountPath: /etc/mongod.conf
          subPath: mongod.conf
        - name: mongodb-keyfile
          mountPath: /data/keyfile
        # Startup probe for large datasets
        startupProbe:
          exec:
            command:
            - mongosh
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 30
        # Liveness probe
        livenessProbe:
          exec:
            command:
            - mongosh
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 30
          periodSeconds: 10
        # Readiness probe
        readinessProbe:
          exec:
            command:
            - mongosh
            - --eval
            - "db.runCommand('ismaster').ismaster"
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: mongodb-config
        configMap:
          name: mongodb-performance-config
      - name: mongodb-keyfile
        secret:
          secretName: mongodb-keyfile
          defaultMode: 0600
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 100Gi
```

**Key points:**

- Docker containers provide consistent MongoDB environments across development and production
- Docker Compose simplifies multi-container deployments including replica sets and sharded clusters
- Kubernetes StatefulSets ensure ordered deployment and persistent storage for MongoDB clusters
- Persistent storage strategies must account for data durability, backup, and disaster recovery requirements
- [Inference] Performance optimization requires careful resource allocation and storage configuration
- Container security involves non-root users, read-only filesystems where possible, and proper secret management
- Monitoring and alerting are essential for containerized MongoDB deployments to track resource usage and performance metrics

---

