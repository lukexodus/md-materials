## Dependency Scanning


### Core Architecture and Software Composition Analysis (SCA)

Dependency scanning is the automated inspection of project dependencies (libraries, frameworks, modules) to identify known security vulnerabilities and license compliance issues. It is a subset of Software Composition Analysis (SCA) and is critical for securing the software supply chain.

#### Scanning Vectors

1. **Manifest Parsing:** Analyzes declaration files (e.g., `package.json`, `pom.xml`, `requirements.txt`). This method is fast but may miss transitive dependencies if versions are defined as ranges (e.g., `^1.2.0`).
    
2. **Lockfile Analysis:** Examines resolved dependency trees (e.g., `package-lock.json`, `yarn.lock`, `go.sum`). This provides the most accurate view of the exact versions deployed, including all transitive dependencies.
    
3. **Binary Fingerprinting:** Hashes compiled artifacts (e.g., `.dll`, `.jar`) to identify dependencies embedded within binaries. This is essential for C/C++ projects or legacy systems where source manifests are unavailable.
    

### Vulnerability Intelligence and scoring

Effective scanning relies on aggregating data from multiple advisory databases.

- **Data Sources:**
    
    - **NVD (National Vulnerability Database):** The primary aggregator of CVEs (Common Vulnerabilities and Exposures).
        
    - **OSV (Open Source Vulnerabilities):** Distributed database focused on open source ecosystems.
        
    - **Proprietary Vendor DBs:** Often include zero-day research and deeper analysis than public sources.
        
    - **Language-Specific Advisories:** GitHub Security Advisories, RustSec, PyPA.
        
- **Risk Prioritization Metrics:**
    
    - **CVSS (Common Vulnerability Scoring System):** Measures the severity of the vulnerability (Base, Temporal, and Environmental scores).
        
    - **EPSS (Exploit Prediction Scoring System):** Estimates the probability that a vulnerability will be exploited in the wild. High CVSS + Low EPSS may lower remediation priority compared to High CVSS + High EPSS.
        

### Advanced Capabilities

#### Reachability Analysis

Standard scanning generates high noise by flagging libraries that contain vulnerabilities, even if the vulnerable function is never invoked by the application code. Reachability analysis builds a call graph to determine if the vulnerable code path is actually executable.

- **Function-Level Granularity:** Determines if the specific vulnerable method is imported and called.
    
- **Control Flow Analysis:** assessing if external user input can reach the vulnerable sink.
    

#### VEX (Vulnerability Exploitability eXchange)

VEX is a machine-readable artifact that allows software vendors to communicate the status of vulnerabilities in their products. It serves as a "negative security advisory," explicitly stating that a product is _not_ affected by a specific CVE, suppressing false positives in downstream scanners.

#### Malware and Supply Chain Attack Detection

Beyond known vulnerabilities (CVEs), advanced scanners analyze behavioral signals to detect:

- **Typosquatting:** Packages mimicking popular libraries (e.g., `reqeusts` vs `requests`).
    
- **Dependency Confusion:** Attackers uploading malicious packages to public registries with names matching internal private packages.
    
- **Brandjacking:** Malicious updates to legitimate packages (compromised maintainer accounts).
    

### Integration Strategies (DevSecOps)

1. **IDE Integration:** Real-time feedback to developers during import selection.
    
2. **Pull Request/Merge Request Decorators:** Blocking merges if new dependencies introduce vulnerabilities exceeding a severity threshold (e.g., Critical/High).
    
3. **Container Registry Scanning:** Scanning Docker images at rest to detect "bit rot," where a safe image becomes vulnerable over time due to newly discovered CVEs.
    
4. **Admission Controllers:** Kubernetes admission controllers (e.g., OPA Gatekeeper) preventing the deployment of pods containing images with critical CVEs.
    

### Software Bill of Materials (SBOM)

Dependency scanning is the primary mechanism for generating and verifying SBOMs.

- **Standards:** CycloneDX and SPDX.
    
- **Utility:** Provides a comprehensive inventory of all components, enabling rapid impact analysis during zero-day events (e.g., Log4Shell).
    
- **Chain of Custody:** Signing SBOMs (e.g., via Sigstore/Cosign) ensures the inventory has not been tampered with between build and deploy.
    

### License Compliance

Scanning must also evaluate legal risk associated with open-source licenses.

- **Copyleft Detection:** identifying GPL/AGPL libraries in proprietary software which could force source code disclosure.
    
- **License Incompatibility:** Detecting conflicting licenses within the dependency tree.
    
- **Attribution Generation:** Automating the creation of legal notice files required by permissive licenses (MIT, Apache 2.0).
    

**Related Topics:**

- Software Bill of Materials (SBOM) Implementation
    
- Static Application Security Testing (SAST)
    
- Container Security and Hardening
    
- Supply Chain Security Frameworks (SLSA)

---

