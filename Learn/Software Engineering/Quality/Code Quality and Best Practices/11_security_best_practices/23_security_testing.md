## Security Testing


### Shift-Left Architecture & DevSecOps Integration

Security testing must move from a final gatekeeping phase to a continuous process integrated into every stage of the Software Development Life Cycle (SDLC). The "Shift-Left" approach mandates that security controls are automated within the CI/CD pipeline, failing builds immediately upon detection of critical vulnerabilities.

- **IDE Integration:** Real-time linting (e.g., SonarLint) to catch injection flaws and secrets in plaintext before code commit.
    
- **Pre-Commit Hooks:** Enforce secret scanning (e.g., `git-secrets`, `talisman`) to prevent committing API keys or credentials to version control.
    
- **Pipeline Gates:** Define strict quality gates. A Critical or High severity finding in SAST or SCA must block deployment to staging environments.
    

### Static Application Security Testing (SAST)

SAST analyzes source code, bytecode, or binaries for security vulnerabilities without executing the application.

- **Taint Analysis:** Advanced SAST engines map the flow of data from "sources" (user input, API parameters) to "sinks" (database queries, DOM execution). This effectively detects SQL Injection, XSS, and Command Injection.
    
- **Rule Customization:** Default rulesets are insufficient. Architects must configure custom rules to recognize proprietary sanitization libraries and internal frameworks to reduce False Negatives.
    
- **Baseline Management:** To introduce SAST into legacy codebases, establish a "baseline" of existing issues. New builds should only fail on **new** vulnerabilities (the "leak period" concept) to prevent stalling development while technical debt is addressed.
    
- **Language Specifics:**
    
    - **Unmanaged Code (C/C++):** Focus on buffer overflows, use-after-free, and memory corruption.
        
    - **Managed Code (Java/C#):** Focus on deserialization vulnerabilities and injection flaws.
        

### Software Composition Analysis (SCA)

SCA addresses the risk inherent in third-party components and open-source libraries (Supply Chain Attacks).

- **Transitive Dependency Scanning:** Scanning top-level dependencies is inadequate. The scanner must resolve the full dependency tree to identify vulnerabilities deep in the graph (e.g., `npm audit`, `OWASP Dependency-Check`).
    
- **SBOM Generation:** Generate a Software Bill of Materials (SBOM) in standard formats (CycloneDX or SPDX) during the build. This provides an immutable record of all components deployed, crucial for rapid response during zero-day events (e.g., Log4Shell).
    
- **License Compliance:** While primarily legal, license conflicts (e.g., injecting GPL code into proprietary software) pose a risk to intellectual property and availability.
    
- **Reachability Analysis:** Advanced SCA tools determine if a vulnerable library function is actually invoked by the application code. This prioritizes remediation efforts by filtering out "unreachable" vulnerabilities.
    

### Dynamic Application Security Testing (DAST)

DAST interacts with the running application from the outside, simulating a malicious attacker.

- **Authenticated Scanning:** DAST scanners must be configured with valid authentication tokens (often via Selenium scripts or OIDC flows) to access deep application logic beyond the login page.
    
- **Spidering and API Definitions:**
    
    - **Web Apps:** Use aggressive crawling (spidering) to map the attack surface.
        
    - **APIs:** Import OpenAPI/Swagger definitions or GraphQL schemas to guide the scanner, ensuring parameter fuzzing covers all endpoints.
        
- **Environment Isolation:** DAST is destructive. It creates garbage data and triggers business logic. It must **never** run against production databases. Use ephemeral staging environments with sanitized data snapshots.
    

### Interactive Application Security Testing (IAST)

IAST places agents inside the running application (instrumentation) during the test phase (e.g., during functional or integration testing).

- **Hybrid Approach:** Combines the code visibility of SAST with the runtime context of DAST.
    
- **Root Cause Analysis:** Unlike DAST, which reports a vulnerability at a URL, IAST reports the exact line of code and the stack trace responsible for the flaw.
    
- **Verification:** IAST verifies if a payload actually triggers a vulnerability (e.g., did the SQL query syntax break?), significantly reducing False Positives compared to SAST.
    

### Fuzz Testing (Fuzzing)

Fuzzing involves providing invalid, unexpected, or random data as inputs to a computer program.

- **Protocol Fuzzing:** Critical for network services. Generates malformed packets to test protocol parsers for memory leaks or crashes.
    
- **Generational vs. Mutation:**
    
    - **Mutation:** Modifies existing valid inputs (bit flipping).
        
    - **Generational:** Constructs inputs from scratch based on a grammar specification.
        
- **Coverage-Guided Fuzzing:** Uses code coverage feedback (e.g., AFL++, LibFuzzer) to evolve inputs that explore new execution paths, specifically targeting edge cases in input validation logic.
    

### Infrastructure as Code (IaC) and Container Security

Security testing extends to the deployment environment configuration.

- **Static Analysis for IaC:** Scan Terraform (HCL), CloudFormation, and Kubernetes manifests for misconfigurations (e.g., open S3 buckets, root user execution, privileged containers). Tools: `Checkov`, `tfsec`.
    
- **Container Image Scanning:** Scan Docker images for OS-level vulnerabilities (CVEs) in base layers (Alpine, Debian).
    
- **Distroless Images:** Best practice involves using "distroless" images which lack shells and package managers, rendering scanners more effective and reducing the runtime attack surface.
    

### Security Regression Testing

Automate the reproduction of previously fixed security issues.

- **Regression Suites:** Every patched vulnerability (e.g., a specific XSS payload that bypassed filters) must be added to the automated test suite.
    
- **Logic Flaws:** Unit tests must explicitly assert failure cases, such as verifying that an unprivileged user receives a `403 Forbidden` when attempting to access an admin endpoint.
    

### Related Topics

- Penetration Testing Standards (PTES, OSSTMM)
    
- Threat Modeling (STRIDE, PASTA)
    
- Secret Management Architecture
    
- Runtime Application Self-Protection (RASP)
    
- Vulnerability Management Lifecycle

---

