## Container Security Best Practices


### Introduction to Container Security

Container security encompasses the practices, tools, and strategies used to protect containerized applications and infrastructure. As containers have become the standard for application deployment, securing them across the entire lifecycle—from development to runtime—has become crucial for organizations.

**Key Points**:

- Container security is a shared responsibility between developers, operations, and security teams
- Security must be applied at every phase of the container lifecycle
- Container isolation is not as strong as VM isolation, requiring additional security measures
- Compromised containers can potentially affect host systems and other containers
- Containers introduce new attack vectors not present in traditional deployments

### Minimal Base Images

Using minimal base images reduces the attack surface by limiting the number of packages, libraries, and potential vulnerabilities in containers.

**Key Points**:

- Smaller images have fewer potential vulnerabilities
- Distroless images contain only your application and runtime dependencies
- Alpine-based images provide a good balance of size and functionality
- Multi-stage builds can separate build tools from runtime dependencies
- Official images are typically more secure and regularly maintained

**Example** of a multi-stage build with minimal base image:

```dockerfile
# Build stage
FROM golang:1.19 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Final stage with minimal base image
FROM alpine:3.17
RUN apk --no-cache add ca-certificates && \
    addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/app .
USER appuser
ENTRYPOINT ["./app"]
```

**Example** of using distroless images:

```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Final stage with distroless image
FROM gcr.io/distroless/nodejs:18
COPY --from=builder /app/dist /app
WORKDIR /app
USER nonroot
CMD ["index.js"]
```

### Non-Root Users

Running containers with non-root users significantly reduces the potential impact of container escapes and other security breaches.

**Key Points**:

- Root in a container can become root on the host system if container escapes occur
- Many applications don't require root privileges to function
- User namespaces provide additional isolation
- Create dedicated users in your Dockerfile for running applications
- Kubernetes provides SecurityContext to enforce non-root execution

**Example** in Dockerfile:

```dockerfile
FROM ubuntu:22.04

# Create a non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Set up application
WORKDIR /app
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

CMD ["./start.sh"]
```

**Example** in Kubernetes manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false
```

### Read-Only Filesystems

Implementing read-only filesystems prevents attackers from modifying the container's filesystem, writing malicious files, or changing application code.

**Key Points**:

- Immutable containers enhance security posture
- Write operations should be limited to specific volumes
- Prevents malware persistence after compromise
- Makes containers truly ephemeral
- Can identify applications that unexpectedly require write access

**Example** in Dockerfile:

```dockerfile
FROM nginx:1.23-alpine

# Configure nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY app /usr/share/nginx/html

# Create necessary directories for temp files
RUN mkdir -p /tmp/nginx && \
    chown -R nginx:nginx /tmp/nginx

# Configure to run as read-only
VOLUME ["/tmp/nginx"]

USER nginx

CMD ["nginx", "-g", "daemon off;"]
```

**Example** in Kubernetes manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readonly-app
spec:
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: cache
      mountPath: /var/cache
  volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
```

### Secrets Management

Proper secrets management prevents sensitive information from being exposed in container images, runtime environments, or logs.

**Key Points**:

- Never embed secrets in container images
- Use dedicated secrets management tools
- Encrypt secrets at rest and in transit
- Rotate secrets regularly
- Implement least privilege access to secrets
- Use dynamic secrets when possible

**Example** of bad practice (avoid this):

```dockerfile
FROM node:18-alpine

WORKDIR /app

# DO NOT DO THIS!
ENV DB_PASSWORD="super_secure_password"

COPY . .
RUN npm install

CMD ["npm", "start"]
```

**Example** with Kubernetes secrets:

```yaml
# Create the secret
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded "admin"
  password: cGFzc3dvcmQxMjM=  # base64 encoded "password123"
---
# Use the secret in a pod
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
```

**Example** with HashiCorp Vault:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vault-app
spec:
  serviceAccountName: vault-auth
  containers:
  - name: app
    image: myapp:1.0
    volumeMounts:
    - name: vault-token
      mountPath: /var/run/secrets/vault
  initContainers:
  - name: vault-agent
    image: vault:1.12.0
    command: ["/bin/sh", "-c"]
    args:
    - |
      vault agent -config=/etc/vault/config.hcl
    volumeMounts:
    - name: vault-config
      mountPath: /etc/vault
    - name: vault-token
      mountPath: /var/run/secrets/vault
  volumes:
  - name: vault-config
    configMap:
      name: vault-agent-config
  - name: vault-token
    emptyDir:
      medium: Memory
```

### Security Scanning Tools

Implementing automated security scanning throughout the development pipeline helps identify and remediate vulnerabilities early.

**Key Points**:

- Scan images for known vulnerabilities (CVEs)
- Scan for misconfigurations and best practice violations
- Integrate scanners into CI/CD pipelines
- Enforce security policies through automated gates
- Use runtime security monitoring tools

Popular tools include:

- Trivy, Clair, and Anchore for image scanning
- Docker Bench for Security for runtime configuration
- Falco for runtime monitoring
- Snyk, Aqua Security, and Prisma Cloud for comprehensive scanning

**Example** of Trivy integration in GitHub Actions:

```yaml
name: Container Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build image
      run: docker build -t myapp:${{ github.sha }} .
      
    - name: Scan image with Trivy
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: myapp:${{ github.sha }}
        format: 'table'
        exit-code: '1'
        ignore-unfixed: true
        severity: 'CRITICAL,HIGH'
```

### Limiting Capabilities and Resources

Restricting container capabilities and resources helps minimize the impact of security breaches and prevents resource exhaustion attacks.

**Key Points**:

- Linux capabilities control privileged operations
- Drop all capabilities by default, then add only required ones
- Set resource limits for CPU, memory, and storage
- Use seccomp profiles to restrict system calls
- Implement cgroup isolation
- Use AppArmor or SELinux for additional isolation

**Example** in Dockerfile:

```dockerfile
FROM ubuntu:22.04

# Create user
RUN useradd -r -u 1000 -g 1000 appuser

# Set up application
WORKDIR /app
COPY --chown=appuser:appuser . .

USER appuser

# Drop capabilities
CMD ["./myapp"]
```

**Example** in Kubernetes manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: limited-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      capabilities:
        drop: ["ALL"]
        add: ["NET_BIND_SERVICE"]
      seccompProfile:
        type: RuntimeDefault
    resources:
      limits:
        cpu: "500m"
        memory: "512Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"
```

### Container Runtime Security

Securing the container runtime environment is crucial for maintaining the overall security posture of containerized applications.

**Key Points**:

- Choose secure container runtimes (containerd, CRI-O)
- Keep runtime software updated
- Implement pod security policies or admission controllers
- Use runtime security monitoring tools
- Configure host security properly
- Enable audit logging

**Example** of Kubernetes Pod Security Policy (now deprecated but concept is important):

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
  readOnlyRootFilesystem: true
```

**Example** of Kubernetes Security Context:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-pod
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsUser: 1000
      runAsGroup: 3000
      capabilities:
        drop: ["ALL"]
```

### Image Signing and Trust

Implementing image signing and verification ensures that only authorized and unmodified container images are deployed.

**Key Points**:

- Sign images to verify their authenticity
- Implement policy enforcement for signed images
- Use content trust mechanisms
- Verify signatures before deployment
- Maintain a trusted registry of approved images

**Example** using Docker Content Trust:

```bash
# Enable content trust
export DOCKER_CONTENT_TRUST=1

# Sign and push an image
docker push mycompany/myapp:1.0

# Verify signature before pulling
docker pull mycompany/myapp:1.0
```

**Example** using Cosign:

```bash
# Generate a key pair
cosign generate-key-pair

# Sign an image
cosign sign --key cosign.key mycompany/myapp:1.0

# Verify an image
cosign verify --key cosign.pub mycompany/myapp:1.0
```

### Network Security

Implementing proper network security controls minimizes the risk of lateral movement and unauthorized access.

**Key Points**:

- Implement network policies to restrict container communications
- Use service meshes for encrypted communication
- Limit exposure of container ports
- Implement proper ingress and egress controls
- Use TLS for all external communications
- Monitor network traffic for anomalies

**Example** of Kubernetes Network Policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

### Monitoring and Logging

Comprehensive monitoring and logging help detect and respond to security incidents in containerized environments.

**Key Points**:

- Implement centralized logging
- Monitor container behavior for anomalies
- Set up alerts for suspicious activities
- Maintain audit logs for compliance
- Use runtime security monitoring tools
- Follow the principle of non-repudiation

**Example** of Falco rule for detecting suspicious behavior:

```yaml
- rule: Terminal Shell in Container
  desc: A shell was spawned in a container with an attached terminal
  condition: >
    container and
    container.image.repository != "k8s.gcr.io/pause" and
    spawned_process and
    ((proc.name = "sh" or proc.name = "bash" or proc.name = "dash") and
    proc.tty != 0)
  output: >
    Terminal shell spawned in a container (user=%user.name
    container_id=%container.id container_name=%container.name
    image=%container.image.repository:%container.image.tag
    shell=%proc.name parent=%proc.pname cmdline=%proc.cmdline)
  priority: NOTICE
  tags: [container, shell, mitre_execution]
```

### Vulnerability Management

A comprehensive vulnerability management program helps identify and remediate security issues in containers across their lifecycle.

**Key Points**:

- Implement a vulnerability management process
- Scan images regularly, not just at build time
- Prioritize vulnerabilities based on risk
- Establish clear remediation SLAs
- Maintain an inventory of all containers and their components
- Track vulnerabilities across the entire container ecosystem

**Example** of a vulnerability management workflow:

1. Scan base images before using them
2. Scan application dependencies before build
3. Scan final container images
4. Deploy with automated gates based on severity
5. Continuously monitor for new vulnerabilities
6. Automate remediation where possible
7. Maintain documentation of accepted risks

### Recommended related topics:

- Implementing DevSecOps for container security
- Compliance considerations for containerized applications
- Container security in cloud-native environments
- Zero Trust architecture for containerized applications
- Supply chain security for containers
- Threat modeling for containerized applications

---

