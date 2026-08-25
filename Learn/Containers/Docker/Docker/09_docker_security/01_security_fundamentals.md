## Security Fundamentals


### Docker Security Model

The Docker security model consists of multiple layers of isolation and protection mechanisms designed to secure container deployments while maintaining performance and usability.

**Key Points:**

- Docker leverages Linux kernel security features
- Default configuration provides reasonable security
- Security is multi-layered and defense-in-depth
- Host system security remains crucial
- Docker daemon runs with elevated privileges
- Security model focuses on isolation and reduced attack surface

Docker's security architecture includes:

1. **Linux namespaces**: Provide process isolation
    
    - PID: Process isolation
    - NET: Network interfaces
    - IPC: Inter-process communication
    - MNT: Filesystem/mount points
    - UTS: Hostname and domain name
    - USER: User and group IDs
2. **Control Groups (cgroups)**: Limit resource utilization
    
    - Prevent denial-of-service attacks
    - Constrain CPU, memory, disk I/O, network bandwidth
3. **Union filesystem**: Layer-based approach
    
    - Read-only base layers
    - Single writable container layer
    - Immutable infrastructure pattern
4. **Security profiles**: Configure fine-grained privileges
    
    - AppArmor profiles
    - Seccomp filters
    - Linux capabilities

**Example:** How Docker layers security controls:

```
Container Application
├── Container Runtime (e.g., runc)
│   ├── Seccomp Filters (system call restrictions)
│   ├── Capabilities (fine-grained privileges)
│   ├── AppArmor/SELinux (mandatory access control)
│   └── User Namespace (UID/GID mapping)
├── Linux Namespaces (resource isolation)
├── Control Groups (resource limits)
└── Host Kernel
```

### Container Isolation

Container isolation is fundamental to Docker security, creating boundaries between containers and between containers and the host system.

**Key Points:**

- Containers share the host kernel but are isolated from each other
- Isolation is not as strong as virtual machines
- Multiple isolation mechanisms work together
- Different aspects of container runtime are isolated differently
- Container breakout is a primary security concern
- Isolation must be balanced with performance and usability

Isolation mechanisms include:

1. **Process Isolation**:
    
    - Each container has its own PID namespace
    - Processes in one container can't see or signal processes in others
    - Container processes appear as regular processes on the host
2. **Network Isolation**:
    
    - Containers get their own network stack
    - Virtual Ethernet pairs connect containers to host
    - Bridge networks isolate container-to-container traffic
    - Port mappings control external access
3. **Filesystem Isolation**:
    
    - Each container has its own mount namespace
    - Container root filesystem is isolated
    - Volumes can be shared selectively
    - Read-only mounts prevent modifications
4. **IPC Isolation**:
    
    - Separate IPC namespaces prevent shared memory access
    - System V IPC and POSIX message queues are isolated
    - Optional shared IPC for specific cases

**Example:** Testing container isolation:

```bash
# In container 1
docker run --name c1 -d ubuntu sleep infinity
docker exec c1 sh -c "echo container1 > /tmp/test.txt"

# In container 2
docker run --name c2 -d ubuntu sleep infinity
docker exec c2 cat /tmp/test.txt  # File doesn't exist

# On host, container processes are visible
ps aux | grep "sleep infinity"  # Shows container processes
```

### Kernel Security Features

Docker relies heavily on Linux kernel security features to provide container isolation and enforce security boundaries.

**Key Points:**

- Kernel security features predate containers
- Docker leverages these features rather than implementing its own
- Most features can be configured to different security levels
- Features can be layered for defense-in-depth
- Some features require specific kernel versions
- Understanding these features helps improve container security

Key Linux kernel security features used by Docker:

1. **Capabilities**: Fine-grained privileges instead of root/non-root binary distinction
    
    - Docker drops most capabilities by default
    - Specific capabilities can be added as needed
    - Examples: CAP_NET_ADMIN, CAP_SYS_ADMIN, CAP_NET_BIND_SERVICE
2. **Seccomp**: System call filtering
    
    - Restricts which system calls a process can make
    - Docker uses a default seccomp profile
    - Custom profiles can further restrict access
    - Blocks potentially dangerous syscalls
3. **AppArmor/SELinux**: Mandatory Access Control (MAC)
    
    - Restricts programs to defined resources
    - Docker uses default profiles when available
    - Can be customized for specific container workloads
    - Limits damage from compromised applications
4. **User Namespaces**: Map UIDs between host and container
    
    - Container root can map to unprivileged host user
    - Limits impact of container breakout
    - Not enabled by default in all Docker installations

**Example:** Running a container with reduced capabilities:

```bash
# Drop all capabilities and add back only what's needed
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE nginx

# Check capabilities inside container
docker exec container-name capsh --print
```

Seccomp profile example:

```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64"],
  "syscalls": [
    {
      "names": [
        "accept", "access", "arch_prctl", "brk",
        "capget", "capset", "chdir", "chmod",
        "close", "connect", "dup2", "execve",
        "exit_group", "fcntl", "fstat", "getdents64",
        "getpid", "gettid", "getuid", "ioctl",
        "mmap", "mprotect", "munmap", "nanosleep",
        "open", "poll", "read", "rt_sigaction",
        "rt_sigprocmask", "select", "set_tid_address",
        "setgid", "setgroups", "setuid", "stat",
        "socket", "write"
      ],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

### Common Vulnerabilities

Container environments face various security challenges that must be understood and mitigated to ensure secure deployments.

**Key Points:**

- Container security encompasses images, runtime, orchestration, and infrastructure
- Many vulnerabilities stem from misconfigurations rather than software flaws
- Supply chain security is increasingly important
- Container-specific attack vectors require specific mitigations
- Regular security assessments are essential
- Defense-in-depth approach is recommended

Common vulnerabilities in container environments:

1. **Vulnerable Container Images**:
    
    - Outdated base images with known CVEs
    - Malicious packages in public images
    - Hardcoded secrets in images
    - Excessive packages increasing attack surface
2. **Privilege Escalation**:
    
    - Running containers as root
    - Mounting sensitive host directories
    - Excessive capabilities
    - Privileged containers
3. **Container Breakout**:
    
    - Kernel vulnerabilities
    - Misconfigured security contexts
    - Volume mounts to sensitive paths
    - Privileged operations
4. **Supply Chain Attacks**:
    
    - Compromised base images
    - Dependency confusion attacks
    - Typosquatting in package repositories
    - Backdoored dependencies
5. **Orchestration Security Issues**:
    
    - Weak API server authentication
    - Insecure defaults in orchestrators
    - Excessive RBAC permissions
    - Exposed dashboards and APIs

**Example:** Container escape through mounted socket:

```bash
# Mounting Docker socket gives container control over Docker engine
docker run -v /var/run/docker.sock:/var/run/docker.sock ubuntu

# From inside container, attacker can now control Docker
docker exec -it container-name bash
apt update && apt install -y docker.io
docker ps  # Can see all containers
docker run --privileged -v /:/host alpine chroot /host  # Complete host access
```

### Docker Security Best Practices

Implementing security best practices significantly reduces the risk of container-related security incidents.

**Key Points:**

- Security should be integrated throughout the container lifecycle
- Defense-in-depth approach with multiple security controls
- Principle of least privilege for all components
- Regular security assessments and updates
- Automated security checks in CI/CD pipeline
- Runtime security monitoring

Best practices include:

1. **Image Security**:
    
    - Use minimal base images (Alpine, distroless)
    - Implement multi-stage builds
    - Scan images for vulnerabilities
    - Sign and verify images
    - Remove unnecessary tools and packages
    - Never embed secrets in images
2. **Runtime Security**:
    
    - Run containers as non-root users
    - Use read-only filesystems where possible
    - Implement strict resource limits
    - Apply custom seccomp and AppArmor profiles
    - Limit container capabilities
    - Set `--no-new-privileges` flag
3. **Host Security**:
    
    - Keep host system updated
    - Secure Docker daemon configuration
    - Use dedicated container hosts
    - Enable user namespaces
    - Implement host-based firewalls
    - Use container-specific OS distributions
4. **Network Security**:
    
    - Implement network segmentation
    - Use encrypted communications
    - Restrict container communication
    - Implement network policies
    - Follow zero-trust networking principles

**Example:** Secure Dockerfile:

```dockerfile
# Multi-stage build to reduce attack surface
FROM node:16-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Minimal runtime image
FROM node:16-alpine
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
USER appuser
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

Secure container run command:

```bash
docker run \
  --name secure-app \
  --read-only \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --security-opt no-new-privileges \
  --security-opt apparmor=docker-default \
  --security-opt seccomp=/path/to/seccomp.json \
  --cpus 0.5 \
  --memory 512m \
  --pids-limit 100 \
  --user 1000:1000 \
  -p 8080:3000 \
  secure-app-image
```

### Container Runtime Protection

Runtime protection provides active monitoring and enforcement of security policies while containers are running.

**Key Points:**

- Runtime security catches issues that static analysis might miss
- Behavior-based detection complements vulnerability scanning
- Real-time monitoring enables quick response to threats
- Different enforcement modes from monitoring to blocking
- Multiple layers of runtime protection can be implemented
- Container-specific tools provide specialized protection

Runtime protection approaches:

1. **System Call Monitoring**:
    
    - Seccomp filters block unauthorized syscalls
    - Behavioral analysis detects unusual syscall patterns
    - Audit logs capture container activity
2. **File Integrity Monitoring**:
    
    - Detect unexpected file changes
    - Prevent writes to sensitive directories
    - Alert on suspicious file operations
3. **Network Activity Monitoring**:
    
    - Detect unusual network connections
    - Enforce network segmentation policies
    - Monitor for data exfiltration attempts
4. **Process Activity Monitoring**:
    
    - Detect unexpected process execution
    - Monitor for privilege escalation
    - Alert on unusual process behavior

**Example:** Tools for runtime protection:

```
- Falco: Open-source container runtime security
- Aqua Security: Commercial container security platform
- Sysdig Secure: Container security monitoring
- Tetragon: eBPF-based security observability and runtime enforcement
- NeuVector: Container firewall and runtime security
```

Sample Falco rule to detect privilege escalation:

```yaml
- rule: Terminal Shell in Container
  desc: A shell was spawned in a container with an attached terminal
  condition: >
    container.id != host and
    proc.name = bash and
    evt.type = execve and
    evt.dir=< and
    proc.tty != 0
  output: >
    Terminal shell in container (user=%user.name container_id=%container.id
    container_name=%container.name shell=%proc.name parent=%proc.pname)
  priority: WARNING
```

### Image Scanning and Vulnerability Management

Scanning container images for vulnerabilities is a critical component of container security to identify and remediate security issues before deployment.

**Key Points:**

- Images can contain vulnerabilities in OS packages or application dependencies
- Scanning should be integrated into CI/CD pipelines
- Regular rescanning of deployed images is necessary
- Policy-based scanning can enforce security standards
- Different scanners have different coverage and detection capabilities
- Context-based vulnerability prioritization is essential

Vulnerability management process:

1. **Static Image Analysis**:
    
    - OS package vulnerability scanning
    - Application dependency scanning
    - Sensitive content detection (secrets, keys)
    - Configuration and best practice checks
2. **Policy Enforcement**:
    
    - Fail builds for critical vulnerabilities
    - Enforce base image standards
    - Require security metadata (labels, signatures)
    - Block non-compliant images from deployment
3. **Continuous Monitoring**:
    
    - Rescan images as new vulnerabilities are discovered
    - Track vulnerability status across environments
    - Automate remediation where possible
    - Generate compliance reports

**Example:** Image scanning output:

```
Image: myapp:1.0
│
├── CVE-2021-1234 (CRITICAL)
│   ├── Package: openssl 1.1.1c-1
│   ├── Fixed in: openssl 1.1.1d-1
│   └── Description: Buffer overflow vulnerability in TLS handshake
│
├── CVE-2021-5678 (HIGH)
│   ├── Package: nodejs 12.18.3
│   ├── Fixed in: nodejs 12.22.1
│   └── Description: HTTP Request Smuggling vulnerability
│
└── 14 MEDIUM, 23 LOW vulnerabilities
```

Integration in CI/CD pipeline:

```yaml
# GitHub Actions example with Trivy scanner
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
      - uses: actions/checkout@v2
      
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Scan image for vulnerabilities
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:${{ github.sha }}'
          format: 'table'
          exit-code: '1'
          ignore-unfixed: true
          severity: 'CRITICAL,HIGH'
```

### Secure Orchestration

When using orchestration systems like Kubernetes, additional security considerations and controls must be implemented.

**Key Points:**

- Orchestration adds new security layers and challenges
- Security must be applied at pod, node, and cluster levels
- RBAC controls access to orchestration API
- Network policies control pod-to-pod communication
- Secrets management requires special attention
- Default configurations are often not secure enough

Security controls for orchestrated environments:

1. **Authentication and Authorization**:
    
    - Role-Based Access Control (RBAC)
    - Service accounts with minimal permissions
    - External identity provider integration
    - API server authentication
2. **Pod Security**:
    
    - Pod Security Standards (Restricted, Baseline, Privileged)
    - Security Contexts for containers
    - Admission controllers to enforce policies
    - Runtime Class for container isolation
3. **Network Security**:
    
    - Network Policies for micro-segmentation
    - Service Mesh for encrypted communication
    - Ingress/Egress controls
    - DNS policies
4. **Secrets Management**:
    
    - Encryption at rest for secrets
    - External secrets providers
    - Just-in-time secrets access
    - Secret rotation

**Example:** Kubernetes Pod Security Context:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: secure-container
    image: nginx:1.19.1
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: true
```

Kubernetes Network Policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: database
    ports:
    - protocol: TCP
      port: 5432
```

### Security Compliance and Auditing

Container environments must often meet compliance requirements and provide auditability for security controls and operations.

**Key Points:**

- Containers introduce new compliance challenges
- Container-specific compliance standards are emerging
- Audit logs are essential for security investigations
- Compliance automation tools help maintain standards
- Regular security assessments are required
- Documentation of security controls is important

Compliance considerations:

1. **Regulatory Compliance**:
    
    - PCI DSS for payment processing
    - HIPAA for healthcare data
    - GDPR for European personal data
    - SOC 2 for service organizations
    - Industry-specific regulations
2. **Security Standards**:
    
    - CIS Docker Benchmark
    - CIS Kubernetes Benchmark
    - NIST container guidelines
    - ISO 27001 controls applied to containers
3. **Audit Capabilities**:
    
    - Container runtime logs
    - Host system logs
    - Orchestration API audit logs
    - Network flow logs
    - Image build and deployment logs

**Example:** Docker Bench Security script output:

```
# Docker Bench for Security v1.3.6

[INFO] 1 - Host Configuration
[WARN] 1.1 - Ensure a separate partition for containers has been created
[PASS] 1.2 - Ensure the container host has been Hardened
[PASS] 1.3 - Ensure Docker is up to date
[INFO] 1.4 - Ensure only trusted users are allowed to control Docker daemon
[INFO]      * docker:x:999:user1,user2

[INFO] 2 - Docker daemon configuration
[PASS] 2.1 - Ensure network traffic is restricted between containers on the default bridge
[WARN] 2.2 - Ensure the logging level is set to 'info'
[PASS] 2.3 - Ensure Docker is allowed to make changes to iptables
[PASS] 2.4 - Ensure insecure registries are not used
[PASS] 2.5 - Ensure aufs storage driver is not used
[INFO] 2.6 - Ensure TLS authentication for Docker daemon is configured
```

CIS Kubernetes Benchmark checks:

```
1. Control Plane Components
   1.1 Master Node Configuration Files
   1.2 API Server
   1.3 Controller Manager
   1.4 Scheduler
   1.5 etcd
   1.6 General Security Primitives

2. Worker Nodes
   2.1 Kubelet
   2.2 Configuration Files

3. Policies
   3.1 Authentication and Authorization
   3.2 Pod Security Policies
   3.3 Network Policies and CNI
   3.4 Secrets Management
   3.5 Extensible Admission Control
```

### Related Topics

- Container security in CI/CD pipelines
- Kubernetes security operators
- Zero-trust security model for containers
- Service mesh security features
- Container forensics and incident response
- Container security maturity models
- Shift-left security for container applications
- Automated vulnerability remediation

---

