## Authentication and Authorization


### Authentication Methods

Kubernetes supports multiple authentication strategies to verify the identity of users and services accessing the cluster. The API server evaluates authentication requests through a chain of authenticators until one succeeds or all fail.

**Certificate-based Authentication** uses X.509 client certificates for mutual TLS authentication. The API server validates certificates against a configured Certificate Authority (CA). Users present client certificates containing their username in the Common Name field and groups in the Organization field. This method provides strong cryptographic identity verification and is commonly used for administrative access and automated systems.

**Token-based Authentication** encompasses several token types including static tokens, bootstrap tokens, and service account tokens. Static tokens are pre-shared secrets stored in files or passed as HTTP headers. Bootstrap tokens facilitate secure cluster initialization and node joining. Service account tokens are automatically mounted into pods and provide identity for workloads running in the cluster.

**OpenID Connect (OIDC)** integration allows Kubernetes to leverage external identity providers like Google, Azure Active Directory, or corporate SSO systems. The API server validates JWT tokens issued by configured OIDC providers, enabling centralized identity management and single sign-on capabilities. This approach supports modern authentication flows including multi-factor authentication and conditional access policies.

### Role-Based Access Control (RBAC)

RBAC provides fine-grained access control by defining what actions subjects can perform on specific resources. The authorization model follows the principle of least privilege, granting only necessary permissions to users and services.

**Authorization Flow** begins after successful authentication. The API server evaluates RBAC policies to determine if the authenticated subject has permission to perform the requested action on the specified resource. Authorization decisions consider the verb (get, create, update, delete), resource type (pods, services, deployments), and namespace scope.

**Policy Evaluation** examines all applicable roles and bindings to determine effective permissions. Multiple roles can apply to a single subject, with permissions being additive. The system denies access unless explicitly granted through RBAC policies, ensuring secure-by-default behavior.

### Roles and ClusterRoles

Roles and ClusterRoles define collections of permissions that can be assigned to subjects. They specify what actions are allowed on which resources within defined scopes.

**Roles** are namespace-scoped resources that grant permissions within a specific namespace. A Role defines rules specifying allowed verbs (actions) on resources like pods, services, or configmaps. Roles cannot grant permissions to cluster-scoped resources or resources in other namespaces.

**Example Role:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
```

**ClusterRoles** are cluster-scoped resources that can grant permissions to cluster-wide resources, resources across all namespaces, or non-resource endpoints. ClusterRoles provide broader access control capabilities and are essential for cluster administration and cross-namespace operations.

**ClusterRole Use Cases** include cluster administration, accessing cluster-scoped resources like nodes and persistent volumes, aggregating permissions across namespaces, and defining permissions for non-resource endpoints like `/healthz` or `/metrics`.

### Role Bindings and ClusterRole Bindings

Bindings associate roles with subjects (users, groups, or service accounts), granting the permissions defined in the role to those subjects.

**RoleBindings** are namespace-scoped and grant permissions defined in a Role or ClusterRole to subjects within a specific namespace. When binding a ClusterRole with a RoleBinding, the permissions are restricted to the binding's namespace.

**ClusterRoleBindings** are cluster-scoped and grant permissions defined in ClusterRoles to subjects across the entire cluster. They enable cluster-wide access and are typically used for cluster administrators and system components.

**Subject Types** supported in bindings include User accounts for human users, Group accounts for collections of users, and ServiceAccount for pod identities. Bindings can reference multiple subjects, allowing efficient permission management for teams or applications.

### Service Accounts and Their Uses

Service Accounts provide identity for processes running in pods, enabling secure communication with the Kubernetes API and other services. They represent non-human identities within the cluster.

**Automatic Service Account Creation** occurs for every namespace, with Kubernetes creating a default service account automatically. Pods use this default account unless explicitly configured otherwise. The system automatically mounts service account tokens into pods, providing API access credentials.

**Token Management** involves JWT tokens that authenticate service account identity. These tokens are automatically mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token` in pod containers. Modern Kubernetes versions support time-bound tokens with audience restrictions for enhanced security.

**Custom Service Accounts** enable fine-grained access control for different applications or workloads. Organizations create dedicated service accounts with specific permissions tailored to application needs, following the principle of least privilege.

**Key points:**

- Service accounts are namespace-scoped resources
- Each pod is associated with exactly one service account
- Service account tokens provide authentication credentials for API access
- Permissions are granted through RBAC bindings referencing service accounts
- Token auto-mounting can be disabled for security-sensitive workloads

**Pod Integration** automatically injects service account credentials into running containers. The kubelet mounts the service account token, CA certificate, and namespace information, enabling pods to authenticate with the API server and other services.

### Security Best Practices

**Principle of Least Privilege** guides all authentication and authorization decisions. Grant only the minimum permissions necessary for users and services to perform their required functions. Regularly audit and review permissions to ensure they remain appropriate.

**Token Security** requires careful management of authentication credentials. Rotate certificates and tokens regularly, use time-bound tokens when available, and avoid storing sensitive credentials in container images or configuration files.

**Network Security** complements authentication and authorization through network policies, service mesh security, and proper ingress configuration. Implement defense-in-depth strategies that secure communication channels alongside identity verification.

**Monitoring and Auditing** enables detection of unauthorized access attempts and policy violations. Enable audit logging to track authentication events, authorization decisions, and resource access patterns. Monitor for anomalous behavior and implement alerting for security incidents.

### Advanced Authentication Scenarios

**Multi-cluster Authentication** presents challenges when managing identity across multiple Kubernetes clusters. Solutions include federated identity providers, shared certificate authorities, and service mesh-based identity federation.

**Workload Identity** bridges Kubernetes service accounts with cloud provider identity systems. This enables pods to assume cloud roles and access external resources without storing long-lived credentials.

**Certificate Rotation** maintains security through automated certificate lifecycle management. Implement automated certificate renewal for cluster components and user certificates to prevent service disruptions and security vulnerabilities.

Related topics that build upon authentication and authorization include Network Policies for traffic-level security, Pod Security Standards for workload security controls, and Secrets Management for secure credential storage and distribution.

---

