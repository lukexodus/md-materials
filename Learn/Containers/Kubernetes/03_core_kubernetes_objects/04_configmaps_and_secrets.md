## ConfigMaps and Secrets


### Externalizing Configuration with ConfigMaps

ConfigMaps provide a way to store non-confidential configuration data in key-value pairs, allowing you to decouple configuration from application code and container images.

#### Creating ConfigMaps

**From Literal Values:**

```bash
# Create ConfigMap with literal values
kubectl create configmap app-config \
  --from-literal=database_host=postgres.example.com \
  --from-literal=database_port=5432 \
  --from-literal=debug_mode=true

# Create ConfigMap with multiple key-value pairs
kubectl create configmap web-config \
  --from-literal=server_name=web-server \
  --from-literal=port=8080 \
  --from-literal=log_level=info
```

**From Files:**

```bash
# Create ConfigMap from single file
kubectl create configmap app-properties --from-file=app.properties

# Create ConfigMap from multiple files
kubectl create configmap config-files \
  --from-file=app.properties \
  --from-file=logging.conf \
  --from-file=database.yaml

# Create ConfigMap from directory
kubectl create configmap app-configs --from-file=config-directory/
```

**From Environment File:**

```bash
# Create from .env file
kubectl create configmap env-config --from-env-file=.env
```

#### Declarative ConfigMap Creation

**Basic ConfigMap YAML:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  database_host: "postgres.example.com"
  database_port: "5432"
  debug_mode: "true"
  app.properties: |
    server.port=8080
    server.name=my-app
    logging.level=INFO
  config.yaml: |
    database:
      host: postgres.example.com
      port: 5432
      name: myapp
    features:
      feature_a: true
      feature_b: false
```

**ConfigMap with Binary Data:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: binary-config
binaryData:
  my-binary-file: <base64-encoded-binary-data>
data:
  text-config: "regular text data"
```

#### ConfigMap Management Commands

```bash
# List ConfigMaps
kubectl get configmaps

# Describe ConfigMap
kubectl describe configmap app-config

# View ConfigMap data
kubectl get configmap app-config -o yaml

# Edit ConfigMap
kubectl edit configmap app-config

# Delete ConfigMap
kubectl delete configmap app-config
```

### Managing Sensitive Data with Secrets

Secrets store sensitive information such as passwords, OAuth tokens, SSH keys, and TLS certificates, providing better security than storing sensitive data in ConfigMaps or container images.

#### Secret Types

**Generic Secrets:**

```bash
# Create generic secret from literals
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=super-secret-password

# Create secret from files
kubectl create secret generic api-secret \
  --from-file=api-key.txt \
  --from-file=client-cert.pem
```

**Docker Registry Secrets:**

```bash
# Create Docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com
```

**TLS Secrets:**

```bash
# Create TLS secret
kubectl create secret tls tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/cert.key
```

**SSH Key Secrets:**

```bash
# Create SSH key secret
kubectl create secret generic ssh-key-secret \
  --from-file=ssh-privatekey=/path/to/ssh/key \
  --from-file=ssh-publickey=/path/to/ssh/key.pub
```

#### Declarative Secret Creation

**Basic Secret YAML:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded 'admin'
  password: c3VwZXItc2VjcmV0LXBhc3N3b3Jk  # base64 encoded 'super-secret-password'
```

**Using stringData for Easier Management:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  database_url: "postgresql://user:pass@localhost:5432/mydb"
  api_key: "abc123def456"
  config.json: |
    {
      "database": {
        "host": "postgres.example.com",
        "credentials": {
          "username": "admin",
          "password": "secret"
        }
      }
    }
```

**Docker Registry Secret:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

**TLS Secret:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-certificate>
  tls.key: <base64-encoded-private-key>
```

#### Secret Management Commands

```bash
# List secrets
kubectl get secrets

# Describe secret (doesn't show data)
kubectl describe secret db-secret

# View secret data (base64 encoded)
kubectl get secret db-secret -o yaml

# Decode secret data
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 --decode

# Edit secret
kubectl edit secret db-secret

# Delete secret
kubectl delete secret db-secret
```

### Mounting Configs and Secrets in Pods

ConfigMaps and Secrets can be consumed by pods through environment variables, volume mounts, or command-line arguments.

#### Volume Mounts

**ConfigMap Volume Mount:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
      readOnly: true
    - name: app-properties
      mountPath: /app/config/app.properties
      subPath: app.properties
      readOnly: true
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: app-properties
    configMap:
      name: app-config
      items:
      - key: app.properties
        path: app.properties
```

**Secret Volume Mount:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app-pod
spec:
  containers:
  - name: app-container
    image: myapp:latest
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
    - name: tls-certs
      mountPath: /etc/ssl/certs
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-secret
      defaultMode: 0400
  - name: tls-certs
    secret:
      secretName: tls-secret
      items:
      - key: tls.crt
        path: server.crt
      - key: tls.key
        path: server.key
        mode: 0400
```

**Advanced Volume Mount Options:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: advanced-config-pod
spec:
  containers:
  - name: app-container
    image: myapp:latest
    volumeMounts:
    - name: config-volume
      mountPath: /app/config
      readOnly: true
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      defaultMode: 0644
      optional: false
      items:
      - key: app.properties
        path: application.properties
        mode: 0644
      - key: config.yaml
        path: config/app.yaml
```

#### File Permissions and Ownership

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: permission-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: app-container
    image: myapp:latest
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-secret
      defaultMode: 0400
```

### Environment Variables vs Volume Mounts

#### Environment Variables

**ConfigMap as Environment Variables:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-var-pod
spec:
  containers:
  - name: app-container
    image: myapp:latest
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_host
    - name: DATABASE_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_port
    envFrom:
    - configMapRef:
        name: app-config
        prefix: APP_
```

**Secret as Environment Variables:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: app-container
    image: myapp:latest
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
    envFrom:
    - secretRef:
        name: db-secret
```

**Mixed Configuration:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mixed-config-pod
spec:
  containers:
  - name: app-container
    image: myapp:latest
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_host
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
    - name: STATIC_CONFIG
      value: "hardcoded-value"
    volumeMounts:
    - name: config-files
      mountPath: /app/config
    - name: secret-files
      mountPath: /app/secrets
  volumes:
  - name: config-files
    configMap:
      name: app-config
  - name: secret-files
    secret:
      secretName: db-secret
```

#### Comparison: Environment Variables vs Volume Mounts

**Environment Variables:**

_Advantages:_

- Simple to use and understand
- Directly accessible in application code
- No file system dependencies
- Suitable for simple key-value configurations

_Disadvantages:_

- Visible in process lists and container inspection
- Limited to string values
- Not suitable for large configuration files
- Cannot be updated without pod restart

**Volume Mounts:**

_Advantages:_

- Support for complex file structures
- Better security (file permissions)
- Can handle binary data
- Suitable for large configuration files
- Can be updated dynamically (with some limitations)

_Disadvantages:_

- More complex setup
- Requires file system operations
- May need application logic to read files

#### Best Practices for Configuration Management

**Security Considerations:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-config-pod
spec:
  containers:
  - name: app-container
    image: myapp:latest
    env:
    - name: NON_SENSITIVE_CONFIG
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log_level
    volumeMounts:
    - name: sensitive-config
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: sensitive-config
    secret:
      secretName: db-secret
      defaultMode: 0400
```

**Configuration Hot Reloading:**

```yaml
apiVersion: v1
kind: Deployment
metadata:
  name: configurable-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: configurable-app
  template:
    metadata:
      labels:
        app: configurable-app
      annotations:
        config/checksum: "{{ include (print $.Template.BasePath '/configmap.yaml') . | sha256sum }}"
    spec:
      containers:
      - name: app-container
        image: myapp:latest
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
        - name: secret-volume
          mountPath: /app/secrets
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: secret-volume
        secret:
          secretName: app-secret
```

#### Deployment Strategies with Configuration

**Rolling Updates with Configuration Changes:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app-container
        image: myapp:latest
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secret
```

**Init Containers for Configuration Validation:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: validated-config-pod
spec:
  initContainers:
  - name: config-validator
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Validating configuration..."
      if [ -f /etc/config/app.properties ]; then
        echo "Configuration file found"
      else
        echo "Configuration file missing"
        exit 1
      fi
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  containers:
  - name: app-container
    image: myapp:latest
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: secret-volume
      mountPath: /etc/secrets
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: secret-volume
    secret:
      secretName: app-secret
```

### Advanced Configuration Patterns

#### Immutable ConfigMaps and Secrets

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: immutable-config
immutable: true
data:
  app.properties: |
    server.port=8080
    server.name=production-app
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: immutable-secret
type: Opaque
immutable: true
data:
  password: c3VwZXItc2VjcmV0LXBhc3N3b3Jk
```

#### Configuration Layering

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: layered-config-pod
spec:
  containers:
  - name: app-container
    image: myapp:latest
    env:
    - name: ENVIRONMENT
      value: "production"
    envFrom:
    - configMapRef:
        name: base-config
    - configMapRef:
        name: environment-config
    - secretRef:
        name: environment-secrets
    volumeMounts:
    - name: base-config
      mountPath: /app/config/base
    - name: env-config
      mountPath: /app/config/environment
  volumes:
  - name: base-config
    configMap:
      name: base-config
  - name: env-config
    configMap:
      name: environment-config
```

**Key points:** ConfigMaps and Secrets provide essential configuration management capabilities in Kubernetes. ConfigMaps handle non-sensitive configuration data, while Secrets manage sensitive information with additional security measures. Both can be consumed through environment variables or volume mounts, each with distinct advantages. Volume mounts offer better security and flexibility for complex configurations, while environment variables provide simplicity for basic key-value pairs. Proper configuration management enables application portability, security, and maintainability across different environments.

**Next steps:** Explore advanced topics like configuration validation with admission controllers, automated secret rotation, external secret management integration (HashiCorp Vault, AWS Secrets Manager), and configuration templating with tools like Helm or Kustomize.

---

