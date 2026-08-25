## Secrets Management


### Secret Lifecycle Architecture

Secrets management extends beyond static storage; it encompasses the entire lifecycle: generation, distribution, usage, rotation, and revocation. A robust architecture treats secrets as ephemeral, strictly scoped, and auditable entities, decoupling credentials from source code and configuration files.

### Storage and Version Control Hygiene

Hardcoding Preclusion: Absolute prohibition of credentials in source code. This includes comments, test files, and default configuration values.

Git Hooks and Scanning:

- **Pre-commit:** Implement local hooks (e.g., Talisman, git-secrets) to block commits containing high-entropy strings or regex matches for known key formats (AWS AKIA, private keys).
    
- **Server-side:** Integrate CI/CD pipeline scanners (e.g., Gitleaks, TruffleHog) to detect secrets in commit history.
    
- **Remediation:** If a secret enters the VCS history, it is considered compromised. Immediate rotation is required; history rewriting (BFG Repo-Cleaner) is a cleanup task, not a security fix.
    

Encrypted Configuration (GitOps):

For scenarios requiring Git-based configuration storage, use tools like Mozilla SOPS (Secrets OPerationS). SOPS encrypts values in YAML/JSON files via KMS/PGP while keeping keys plaintext for diffability. This allows encrypted secrets to reside safely in version control, decrypted only at runtime or deployment.

### Runtime Injection and Container Security

The Environment Variable Anti-Pattern:

While 12-Factor App methodology suggests environment variables, they pose security risks in containerized environments:

- **Visibility:** `docker inspect` and process listing (`ps eww`) reveal environment variables to any user with sufficient privileges on the host or orchestration platform.
    
- **Leakage:** Application crash dumps and debug logs often inadvertently dump the entire environment block.
    

**Preferred Injection Methods:**

1. **Filesystem Mounts (Volume Projection):** Mount secrets as ephemeral files (e.g., `/run/secrets/db_pass`) into a RAM-backed file system (`tmpfs`). The application reads the file into memory and closes the handle. This avoids exposure via process inspection.
    
2. **Sidecar Injection (Vault Agent):** In Kubernetes, a sidecar container authenticates with the secret provider (e.g., HashiCorp Vault), fetches the secret, and renders it to a shared memory volume. The application remains agnostic to the secret source.
    
3. **Orchestrator Native Secrets:** Ensure Kubernetes Secrets are configured with Encryption at Rest (via KMS provider) within etcd. Default base64 encoding provides no confidentiality.
    

### Memory Management and Handling

Managed languages (Java, C#, Python) present challenges due to string immutability and garbage collection (GC).

- **String Immutability:** Storing a password in a `String` object makes it immutable. It lingers in the heap until GC runs, potentially surviving multiple generations. It cannot be explicitly overwritten.
    
- **Mutable Structures:** Use primitive arrays (e.g., `char[]`, `byte[]`) or `SecureString` equivalents where available.
    
- **Explicit Clearing:** Immediately overwrite the array with zeros (memset) after the cryptographic operation is complete.
    
- **Swap and Core Dumps:**
    
    - Disable swap on sensitive production nodes to prevent secrets from being paged to disk.
        
    - Set `ulimit -c 0` to prevent core dumps, which contain process memory snapshots, from being written to disk during crashes.
        

### Dynamic Secrets and Identity Federation

Static, long-lived credentials (API keys, database passwords) are the primary vector for persistence.

- **Dynamic Secrets:** Utilize engines like Vault to generate Just-In-Time (JIT) credentials. For example, when an app connects to a database, Vault creates a temporary SQL user with a short Time-To-Live (TTL). Once the TTL expires, the credential is automatically revoked and deleted.
    
- **Workload Identity Federation:** Replace static service account keys in CI/CD (e.g., GitHub Actions, GitLab CI) with OIDC (OpenID Connect). The pipeline exchanges a signed JWT token for a short-lived cloud provider access token, eliminating the need to store long-term cloud credentials in the CI system.
    

Related topics: Identity and Access Management (IAM), Public Key Infrastructure (PKI), Encryption at Rest, Secure Software Supply Chain.

---

