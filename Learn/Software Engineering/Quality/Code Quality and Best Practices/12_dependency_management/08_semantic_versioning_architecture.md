## Semantic Versioning Architecture


### Core Specification Standard (SemVer 2.0.0)

Semantic Versioning is not an arbitrary numbering scheme; it is a formal compatibility contract between a producer and a consumer. It requires the strict declaration of a Public API. Without a defined public API (documented endpoints, interfaces, or headers), SemVer is void.

- **Format:** `MAJOR.MINOR.PATCH` (e.g., `2.14.3`).
    
- **Increment Logic:**
    
    - **MAJOR:** Incompatible API changes. Clients _will_ break without code modification.
        
    - **MINOR:** Backward-compatible functionality additions. Clients _can_ upgrade safely but may not utilize new features yet.
        
    - **PATCH:** Backward-compatible bug fixes. Internal logic changes only; no interface modifications.
        
- **Immutability:** Once a version is released (tagged), it must **never** be modified. Any change, even a single byte, demands a new version number.
    

### Pre-release and Metadata Identifiers

Advanced implementation utilizes extensions to the standard triplet for lifecycle management.

- **Pre-release:**
    
    - **Syntax:** Appended with a hyphen (e.g., `1.0.0-alpha.1`, `1.0.0-rc.3`).
        
    - **Precedence:** A pre-release version has **lower** precedence than the associated normal version (`1.0.0-alpha < 1.0.0`).
        
    - **Sorting:** Identifiers are compared from left to right. Numeric identifiers sort numerically; alphanumeric identifiers sort lexically (ASCII).
        
- **Build Metadata:**
    
    - **Syntax:** Appended with a plus sign (e.g., `1.0.0+001`, `1.0.0-beta+exp.sha.5114f85`).
        
    - **Ignored in Precedence:** Build metadata is **strictly informational**. Version `1.2.3+build1` is semantically equal to `1.2.3+build2`. Dependency resolvers treat them as identical.
        

### The "Zero-Major" Development Phase

The `0.y.z` range implies initial development and carries specific stability exemptions.

- **Volatility:** The public API is considered unstable. Breaking changes can occur at any time (e.g., dropping a `0.1.0` feature in `0.1.1` is permitted).
    
- **Transition to 1.0.0:** Production-ready software must transition to `1.0.0` immediately upon defining a stable public API. Remaining in `0.y.z` indefinitely while serving production traffic creates ambiguity regarding breaking change policies.
    

### Dependency Resolution Operators

Package managers (npm, Cargo, Maven) interpret SemVer using range operators that dictate automated upgrade behavior.

- **Caret (`^`):** Allows updates that do not change the left-most non-zero digit.
    
    - `^1.2.3` := `>=1.2.3 <2.0.0` (Safe for Major version 1).
        
    - `^0.2.3` := `>=0.2.3 <0.3.0` (Locks Minor version if Major is 0).
        
- **Tilde (`~`):** Allows updates to the Patch version only if the Minor version is specified.
    
    - `~1.2.3` := `>=1.2.3 <1.3.0`.
        
- **Lockfiles:** Range operators introduce non-determinism. A lockfile (`package-lock.json`, `Cargo.lock`) is mandatory to freeze the exact tree for reproducible builds.
    

**Related Topics:**

- CI/CD Version Bump Automation
    
- Conventional Commits Specification
    
- Monorepo Versioning Strategies (Lerna/Nx)

---

