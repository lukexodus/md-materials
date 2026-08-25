## Securing Docker Environment


### Introduction to Docker Security

Docker containers provide process isolation through Linux namespaces and control groups, but they don't offer the same level of isolation as virtual machines. A comprehensive security approach for Docker environments involves securing the host, the daemon, container configurations, images, and the surrounding ecosystem.

**Key Points**:
- Container security is multi-layered, spanning from the host to application code
- Docker's security model relies on Linux kernel security features
- Default configurations are not always secure and need hardening
- Docker containers share the host kernel, creating potential security implications
- Security must be implemented across the entire container ecosystem

### Docker Daemon Security

The Docker daemon (dockerd) runs with root privileges and manages containers, networks, and volumes. Securing the daemon is critical as it represents a high-value target for attackers.

**Key Points**:
- The daemon runs with root privileges by default
- Restrict access to the Docker socket
- Use TLS for remote API connections
- Configure proper logging and auditing
- Implement runtime protection
- Limit daemon capabilities when possible

#### Restrict Socket Access

The Docker daemon socket (typically `/var/run/docker.sock`) provides full control over Docker. Restrict access to authorized users only.

**Example** of securing the Docker socket:
```bash
# Create a docker group and add users to it
sudo groupadd docker
sudo usermod -aG docker $USER

# Set proper permissions on the socket
sudo chmod 660 /var/run/docker.sock
sudo chown root:docker /var/run/docker.sock

# Restart Docker
sudo systemctl restart docker
```

#### Enable TLS for Remote Access

When accessing Docker remotely, enable TLS to encrypt communications and authenticate clients.

**Example** of configuring TLS:
```bash
# Create CA, server and client certificates
mkdir -p ~/.docker/certs
cd ~/.docker/certs

# Generate CA key and certificate
openssl genrsa -aes256 -out ca-key.pem 4096
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem

# Generate server key and certificate
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr
echo subjectAltName = DNS:$HOST,IP:10.10.10.20,IP:127.0.0.1 >> extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf

# Generate client key and certificate
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
echo extendedKeyUsage = clientAuth > extfile-client.cnf
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile-client.cnf

# Set permissions
chmod 0400 ca-key.pem key.pem server-key.pem
chmod 0444 ca.pem server-cert.pem cert.pem
```

#### Configure Docker Daemon

Use a configuration file (`/etc/docker/daemon.json`) to secure the daemon.

**Example** of secure daemon configuration:
```json
{
  "icc": false,
  "log-driver": "journald",
  "iptables": true,
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true,
  "storage-driver": "overlay2",
  "selinux-enabled": true,
  "seccomp-profile": "/etc/docker/seccomp-profile.json",
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  },
  "tlsverify": true,
  "tlscacert": "/etc/docker/certs/ca.pem",
  "tlscert": "/etc/docker/certs/server-cert.pem",
  "tlskey": "/etc/docker/certs/server-key.pem"
}
```

#### Docker Daemon Systemd Configuration

When using systemd, create a drop-in file to add security-related options.

**Example** of systemd configuration:
```bash
# Create a drop-in file
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo nano /etc/systemd/system/docker.service.d/override.conf

# Add security options
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --userns-remap="default" --seccomp-profile=/etc/docker/seccomp-profile.json

# Reload systemd and restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### User Namespaces

User namespaces allow mapping of host users to container users, providing an additional security layer by isolating user privileges inside containers from the host system.

**Key Points**:
- Map container's root user to an unprivileged user on the host
- Reduce the risk of container breakout attacks
- Configure per-container or global user namespace remapping
- Some features may not work with user namespaces enabled
- Requires proper configuration of subordinate UID/GID ranges

#### Enable User Namespaces

**Example** of enabling user namespaces:
```bash
# Create subordinate UID/GID ranges
sudo nano /etc/subuid
# Add: docker:100000:65536

sudo nano /etc/subgid
# Add: docker:100000:65536

# Configure Docker daemon to use user namespaces
sudo nano /etc/docker/daemon.json
```

Add the following to `daemon.json`:
```json
{
  "userns-remap": "docker"
}
```

Restart Docker:
```bash
sudo systemctl restart docker
```

#### Per-Container User Namespace Remapping

**Example** of running a container with user namespace remapping:
```bash
# Run container with specific user namespace
docker run --user 1000:1000 --userns=host nginx:alpine

# Verify user ID mapping
docker exec container_name id
```

#### Testing User Namespace Configuration

**Example** of verifying user namespace setup:
```bash
# Run a container and check user ID
docker run -it --rm alpine id
# Output should show UID 0 (root) in container

# Check mapped UID on host
ps aux | grep docker-containerd-shim
# Should show non-root UID for the container process
```

### Docker Bench Security

Docker Bench Security is an automated script that checks for dozens of common best practices around deploying Docker containers in production, based on CIS Docker Benchmark recommendations.

**Key Points**:
- Provides comprehensive security checks for Docker environments
- Based on CIS Docker Benchmark standards
- Evaluates host configuration, Docker daemon, and containers
- Identifies misconfigured containers
- Helps achieve compliance with security standards

#### Running Docker Bench Security

**Example** of running Docker Bench Security:
```bash
# Clone the repository
git clone https://github.com/docker/docker-bench-security.git

# Run the script
cd docker-bench-security
sudo ./docker-bench-security.sh

# Run specific checks
sudo ./docker-bench-security.sh -c container_images
```

#### Automating Docker Bench Security Checks

**Example** of automating checks with a cron job:
```bash
# Create a script to run checks and send report
cat > /usr/local/bin/docker-security-check.sh << 'EOF'
#!/bin/bash
cd /path/to/docker-bench-security
./docker-bench-security.sh -l /var/log/docker-bench-security.log
if [ $? -ne 0 ]; then
  mail -s "Docker Security Check Failed" admin@example.com < /var/log/docker-bench-security.log
fi
EOF

# Make it executable
chmod +x /usr/local/bin/docker-security-check.sh

# Add to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/docker-security-check.sh") | crontab -
```

#### Addressing Docker Bench Security Findings

Common issues found by Docker Bench Security and how to fix them:

```bash
# Set proper permissions on Docker socket
sudo chmod 660 /var/run/docker.sock

# Add audit rules for Docker files and directories
sudo auditctl -w /usr/bin/docker -p rwxa
sudo auditctl -w /var/lib/docker -p rwxa
sudo auditctl -w /etc/docker -p rwxa

# Enable content trust
echo 'export DOCKER_CONTENT_TRUST=1' >> ~/.bashrc

# Ensure Docker daemon directory is owned by root
sudo chown -R root:root /var/lib/docker
```

### Registry Security

Docker registries store and distribute container images. Securing registries is essential to prevent unauthorized access and compromised images.

**Key Points**:
- Use private registries for sensitive images
- Implement HTTPS for registry communications
- Enforce strong authentication mechanisms
- Configure proper access controls
- Regularly scan images in the registry
- Implement rate limiting to prevent abuse

#### Secure Registry Setup

**Example** of setting up a secure private registry:
```bash
# Create certificates for the registry
mkdir -p certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt

# Run a secure registry
docker run -d \
  --restart=always \
  --name registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 5000:5000 \
  registry:2
```

#### Registry Authentication

**Example** of adding basic authentication:
```bash
# Create password file
mkdir auth
docker run --entrypoint htpasswd httpd:2 -Bbn username password > auth/htpasswd

# Start registry with authentication
docker run -d \
  --restart=always \
  --name registry \
  -v "$(pwd)"/auth:/auth \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 5000:5000 \
  registry:2
```

#### Client-Side Registry Security

**Example** of securely interacting with a registry:
```bash
# Login to the registry
docker login my-registry.example.com:5000

# Pull and push images securely
docker pull my-registry.example.com:5000/my-image:tag
docker push my-registry.example.com:5000/my-image:tag

# Verify registry is secure
curl -v https://my-registry.example.com:5000/v2/
```

#### Registry Hardening

**Example** of implementing registry security controls:
```bash
# Run with resource limits
docker run -d \
  --restart=always \
  --name registry \
  --cpus="1.0" \
  --memory="2g" \
  -v "$(pwd)"/certs:/certs \
  -v "$(pwd)"/auth:/auth \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -p 5000:5000 \
  registry:2

# Configure registry to reject unsigned images
# Add to registry configuration
{
  "storage": {
    "filesystem": {
      "rootdirectory": "/var/lib/registry"
    }
  },
  "auth": {
    "token": {
      "realm": "https://auth.example.com/token",
      "service": "container_registry",
      "issuer": "auth_service"
    }
  }
}
```

### Image Signing and Content Trust

Docker Content Trust allows you to verify the authenticity, integrity, and publisher of container images using digital signatures.

**Key Points**:
- Sign images to prove their authenticity
- Verify signatures before deploying images
- Use Notary for managing signing keys
- Content Trust helps prevent tampering and MITM attacks
- Enforce Content Trust at the organization level
- Rotate signing keys regularly

#### Enabling Docker Content Trust

**Example** of enabling Content Trust:
```bash
# Enable Docker Content Trust globally
export DOCKER_CONTENT_TRUST=1

# Sign an image during push
docker push mycompany/myapp:1.0

# Verify image before pulling
docker pull mycompany/myapp:1.0

# Disable Content Trust for specific commands
DOCKER_CONTENT_TRUST=0 docker pull mycompany/myapp:untrusted
```

#### Managing Signing Keys

**Example** of managing Content Trust keys:
```bash
# List trust data
docker trust key load key.pem --name user@example.com

# Add a signer
docker trust signer add --key cert.pem user@example.com mycompany/myapp

# Sign an existing image
docker trust sign mycompany/myapp:1.0

# Revoke a signature
docker trust revoke mycompany/myapp:1.0

# Rotate keys
docker trust key rotate mycompany/myapp
```

#### Advanced Content Trust Configuration

**Example** of a comprehensive Content Trust setup:
```bash
# Generate a root key
docker trust key generate root

# Initialize repository trust
docker trust init --root-key root.key

# Install Notary client
curl -L https://github.com/theupdateframework/notary/releases/download/v0.6.1/notary-Linux-amd64 -o notary
chmod +x notary

# Configure Notary
mkdir -p ~/.notary
cat > ~/.notary/config.json << EOF
{
  "trust_dir": "~/.notary",
  "remote_server": {
    "url": "https://notary.docker.io"
  }
}
EOF

# List trusted images
docker trust inspect --pretty mycompany/myapp:1.0
```

#### Content Trust with CI/CD

**Example** of integrating Content Trust in a CI/CD pipeline:
```yaml
# Example in GitHub Actions
name: Build and Sign
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
      
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
        
    - name: Import signing key
      run: |
        echo "${{ secrets.DOCKER_CONTENT_TRUST_PRIVATE_KEY }}" > key.pem
        echo "${{ secrets.DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE }}" > passphrase.txt
        mkdir -p ~/.docker/trust/private
        docker trust key load key.pem --name ${{ secrets.DOCKER_CONTENT_TRUST_NAME }}
        
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: mycompany/myapp:${{ github.sha }}
      env:
        DOCKER_CONTENT_TRUST: 1
        DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE: ${{ secrets.DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE }}
```

### Operating System Security for Docker Hosts

Securing the host operating system is a critical component of Docker security, as containers share the host kernel and can potentially escape their isolation.

**Key Points**:
- Keep the host OS updated and patched
- Implement proper firewall rules
- Use SELinux or AppArmor for additional isolation
- Implement CIS benchmarks for OS hardening
- Minimize installed packages on the host
- Configure proper audit logging

#### Host OS Hardening

**Example** of basic host hardening:
```bash
# Update the system
sudo apt update && sudo apt upgrade -y

# Remove unnecessary packages
sudo apt autoremove -y

# Set up automatic security updates
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades

# Configure firewall
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 2376/tcp  # Docker TLS port
sudo ufw enable

# Set secure permissions
sudo chmod 700 /root
sudo chmod 700 /home/*
```

#### SELinux Configuration for Docker

**Example** of enabling SELinux for Docker (CentOS/RHEL):
```bash
# Install SELinux utilities
sudo yum install -y policycoreutils-python selinux-policy-targeted

# Enable SELinux
sudo setenforce 1
sudo sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config

# Configure Docker to use SELinux
sudo mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "selinux-enabled": true,
  "icc": false,
  "log-driver": "journald"
}
EOF

# Restart Docker
sudo systemctl restart docker
```

#### AppArmor Profiles for Docker

**Example** of using AppArmor with Docker (Ubuntu/Debian):
```bash
# Install AppArmor utilities
sudo apt install -y apparmor-utils

# Check if AppArmor is running
sudo aa-status

# Create a custom AppArmor profile for Docker
sudo nano /etc/apparmor.d/docker-custom

# Load the profile
sudo apparmor_parser -r -W /etc/apparmor.d/docker-custom

# Run a container with the custom profile
docker run --security-opt apparmor=docker-custom nginx:alpine
```

#### Audit Logging

**Example** of setting up Docker audit logging:
```bash
# Install audit system
sudo apt install -y auditd

# Configure Docker-related audit rules
cat > /etc/audit/rules.d/docker.rules << EOF
-w /usr/bin/docker -p wa -k docker_bin
-w /var/lib/docker -p wa -k docker_lib
-w /etc/docker -p wa -k docker_etc
-w /lib/systemd/system/docker.service -p wa -k docker_service
-w /lib/systemd/system/docker.socket -p wa -k docker_socket
-w /etc/default/docker -p wa -k docker_default
-w /etc/docker/daemon.json -p wa -k docker_daemon_config
EOF

# Restart the audit service
sudo service auditd restart

# Test audit logging
sudo ausearch -k docker_bin
```

### Docker Network Security

Securing Docker networks prevents unauthorized container communications and helps isolate containers from each other and from the host network.

**Key Points**:
- Use custom bridge networks instead of the default bridge
- Implement network segmentation with multiple networks
- Avoid exposing container ports to the host when unnecessary
- Use network policies to control traffic between containers
- Configure proper firewall rules for Docker networks
- Disable inter-container communication when not needed

#### Secure Network Configuration

**Example** of secure network setup:
```bash
# Create custom bridge networks for different application tiers
docker network create --driver bridge frontend
docker network create --driver bridge backend
docker network create --driver bridge database

# Run containers on specific networks
docker run -d --name webserver --network frontend nginx:alpine
docker run -d --name appserver --network backend app:latest
docker run -d --name db --network database postgres:13

# Connect containers to multiple networks as needed
docker network connect backend webserver

# Inspect network configuration
docker network inspect frontend
```

#### Disabling Inter-Container Communication

**Example** of disabling ICC in Docker daemon:
```bash
# Update daemon configuration
sudo nano /etc/docker/daemon.json

# Add ICC disable flag
{
  "icc": false,
  "iptables": true
}

# Restart Docker
sudo systemctl restart docker
```

#### Network Policy with Docker Swarm

**Example** of network encryption in Docker Swarm:
```bash
# Initialize Docker Swarm
docker swarm init

# Create an encrypted overlay network
docker network create --driver overlay --opt encrypted=true secure-network

# Deploy services with the encrypted network
docker service create --name webapp --network secure-network --replicas 3 nginx:alpine
```

#### Exposing Services Securely

**Example** of secure port exposure:
```bash
# Avoid publishing to all interfaces
docker run -d -p 127.0.0.1:8080:80 nginx:alpine

# Use specific IP bindings
docker run -d -p 192.168.1.10:8080:80 nginx:alpine

# Use TLS for exposed services
docker run -d -p 443:443 -v /path/to/certs:/certs nginx:alpine
```

### Docker Secrets Management

Docker provides a native secrets management system for securely distributing sensitive information to containers.

**Key Points**:
- Store sensitive data as Docker secrets
- Mount secrets as in-memory filesystems
- Rotate secrets regularly
- Limit access to secrets based on least privilege
- Encrypt secrets at rest
- Avoid storing secrets in environment variables

#### Creating and Using Docker Secrets

**Example** of using Docker secrets:
```bash
# Create a secret (in Swarm mode)
echo "my_database_password" | docker secret create db_password -

# Create a secret from a file
docker secret create ssl_cert /path/to/cert.pem

# List existing secrets
docker secret ls

# Use secrets in a service
docker service create \
  --name db \
  --secret db_password \
  --secret source=ssl_cert,target=/etc/ssl/cert.pem \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/db_password \
  postgres:13
```

#### Inspecting and Accessing Secrets

**Example** of accessing secrets inside containers:
```bash
# Secrets are mounted at /run/secrets/<secret_name>
docker exec -it db_container cat /run/secrets/db_password

# Check secret mounts
docker exec -it db_container mount | grep secrets
```

#### Secrets Rotation

**Example** of rotating secrets in Docker Swarm:
```bash
# Create a new version of the secret
echo "new_password" | docker secret create db_password_v2 -

# Update the service to use the new secret
docker service update \
  --secret-rm db_password \
  --secret-add source=db_password_v2,target=db_password \
  db

# Remove the old secret
docker secret rm db_password
```

### Docker Compliance and Audit

Implementing compliance controls and audit mechanisms for Docker environments helps meet regulatory requirements and detect security issues.

**Key Points**:
- Implement logging for container activities
- Configure audit trails for Docker daemon operations
- Establish a compliance baseline using CIS benchmarks
- Regularly audit Docker configurations
- Monitor for unauthorized changes to Docker configuration
- Create reports for compliance evidence

#### Docker Audit Logging

**Example** of comprehensive Docker logging:
```bash
# Configure Docker daemon logging
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "labels": "production_status,geo",
    "env": "os,customer"
  },
  "debug": true,
  "experimental": false
}
EOF

# Restart Docker
sudo systemctl restart docker

# View logs
sudo journalctl -u docker.service

# Container-specific logs
docker logs --details container_name
```

#### Compliance Scanning

**Example** of compliance scanning:
```bash
# Run Docker Bench Security for CIS compliance
./docker-bench-security.sh

# Run Trivy for vulnerability scanning
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy:0.22.0 image nginx:alpine

# Generate reports
./docker-bench-security.sh -l docker-bench-report.txt
```

#### Container Runtime Monitoring

**Example** of runtime monitoring with Falco:
```bash
# Install Falco
curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
apt-get update -y
apt-get install -y falco

# Configure Falco for Docker monitoring
cat > /etc/falco/falco_rules.local.yaml << EOF
- rule: Terminal Shell in Container
  desc: A shell was spawned in a container
  condition: container.id != "" and proc.name = bash
  output: "Shell spawned in container (user=%user.name container_id=%container.id container_name=%container.name image=%container.image)"
  priority: WARNING
EOF

# Start Falco
systemctl start falco

# Check alerts
tail -f /var/log/falco_alerts.log
```

### Recommended related topics:

- Docker in Kubernetes environments
- Multi-stage builds for secure container images
- Rootless Docker configurations
- DevSecOps pipelines for Docker security
- Container security in CI/CD pipelines
- Zero Trust architecture with Docker

---

