## Kubernetes Security Model


Kubernetes security operates on a multi-layered defense approach, protecting workloads through authentication, authorization, admission control, and runtime security mechanisms. The platform's security model assumes a hostile environment where threats can emerge from compromised containers, malicious users, or network attacks.

### Security Principles and Threat Model

The Kubernetes security model is built on several fundamental principles that guide its defensive architecture. Defense in depth forms the cornerstone, implementing multiple security layers to ensure that if one layer fails, others continue to protect the system. The principle of least privilege ensures that users, service accounts, and processes receive only the minimum permissions necessary for their intended function.

The threat model encompasses various attack vectors that Kubernetes deployments must defend against. Container breakout attacks occur when malicious code escapes container boundaries to access the host system. Privilege escalation threats involve attackers gaining higher-level permissions than initially granted. Supply chain attacks target container images and dependencies, while network-based attacks exploit inter-pod communication or external traffic flows.

Kubernetes addresses these threats through its layered security architecture. The API server serves as the central security gateway, authenticating and authorizing all requests. Network policies control traffic flow between pods and external resources. Pod security standards prevent dangerous container configurations, while resource quotas limit potential damage from resource exhaustion attacks.

**Key points:**

- Multi-layered defense protects against diverse threat vectors
- Least privilege principle minimizes attack surface
- API server centralization enables consistent security enforcement
- Network segmentation isolates workloads and limits lateral movement

### Pod Security Standards

Pod Security Standards (PSS) replace the deprecated Pod Security Policies, providing a simplified approach to enforcing security policies across Kubernetes clusters. These standards define three policy levels: Privileged, Baseline, and Restricted, each with increasingly strict security requirements.

The Privileged level imposes no restrictions and allows all possible pod configurations. This level is suitable for system workloads and privileged applications that require full access to host resources. The Baseline level prevents known privilege escalations while maintaining broad compatibility with common container patterns. It restricts dangerous capabilities like privileged containers, host network access, and volume types that could compromise the host system.

The Restricted level enforces current pod hardening best practices and significantly limits pod capabilities. This level prevents privilege escalation, requires containers to run as non-root users, and restricts volume types to safe options. It also enforces seccomp profiles and prohibits dangerous capabilities.

Pod Security Standards operate through three modes: enforce, audit, and warn. Enforce mode blocks pod creation if policies are violated. Audit mode logs policy violations without blocking pods. Warn mode displays warnings to users about policy violations while allowing pod creation.

**Example:**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### Security Contexts and Capabilities

Security contexts define privilege and access control settings for pods and containers, controlling how processes run within containers and their access to system resources. These contexts operate at both pod and container levels, with container-level settings overriding pod-level configurations.

User and group settings control process ownership within containers. The runAsUser field specifies the user ID for container processes, while runAsGroup sets the primary group ID. The runAsNonRoot field prevents containers from running as root, enhancing security by limiting potential damage from container breakouts.

Filesystem permissions are managed through fsGroup settings, which control ownership of mounted volumes. The fsGroupChangePolicy determines how volume ownership changes are applied, with options for OnRootMismatch or Always policies.

Linux capabilities provide fine-grained control over privileged operations. Capabilities can be added or dropped at the container level, allowing precise control over what privileged operations containers can perform. Common capabilities include NET_ADMIN for network administration, SYS_TIME for time modification, and CHOWN for file ownership changes.

Security Enhanced Linux (SELinux) contexts provide mandatory access control through seLinuxOptions. These contexts define security labels that determine what resources processes can access, adding an additional layer of protection beyond traditional user-based permissions.

**Example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    runAsNonRoot: true
    fsGroup: 2000
  containers:
  - name: app
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
      readOnlyRootFilesystem: true
```

### Container Image Security Best Practices

Container image security begins with base image selection and extends through the entire image lifecycle. Using minimal base images reduces attack surface by eliminating unnecessary packages and potential vulnerabilities. Official images from trusted registries provide better security maintenance than unofficial alternatives.

Image vulnerability scanning should be integrated into CI/CD pipelines to identify known security issues before deployment. Tools like Trivy, Clair, or commercial solutions can automatically scan images for CVEs and misconfigurations. Regular scanning of running containers ensures that newly discovered vulnerabilities are promptly addressed.

Image signing and verification ensure image integrity and authenticity. Digital signatures prove that images haven't been tampered with during storage or transmission. Tools like Cosign or Notary provide cryptographic verification of image provenance and integrity.

Multi-stage builds enhance security by separating build dependencies from runtime images. Build tools, source code, and intermediate artifacts remain in build stages, while only necessary runtime components are included in final images. This approach significantly reduces the attack surface of deployed containers.

User management within containers prevents privilege escalation attacks. Images should create non-root users for application processes, avoiding the default root user that provides unnecessary privileges. Package managers and temporary files should be cleaned up during image builds to prevent information disclosure.

Runtime security scanning monitors running containers for suspicious activity, file system changes, and network connections. Tools like Falco provide runtime threat detection by monitoring system calls and generating alerts for anomalous behavior.

**Key points:**

- Minimal base images reduce attack surface and vulnerability exposure
- Automated vulnerability scanning prevents deployment of compromised images
- Image signing ensures integrity and authenticity throughout the supply chain
- Multi-stage builds separate build-time and runtime dependencies
- Non-root users limit potential damage from container compromise
- Runtime monitoring detects threats during container execution

**Next steps:**

- Implement admission controllers like OPA Gatekeeper for policy enforcement
- Configure network policies for micro-segmentation
- Set up RBAC for fine-grained access control
- Implement secrets management with external secret stores
- Enable audit logging for security monitoring and compliance

---

