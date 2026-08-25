## Minimal Dependencies


The philosophy of Minimal Dependencies (often aligned with "Zero Dependency" or "Lean Software Development") asserts that every external library introduced into a codebase incurs a permanent tax on performance, security, and maintenance. In high-quality software architecture, dependency addition is a calculated risk, not a default action.

### The Cost of Abstraction

External dependencies inevitably introduce abstractions that may not align perfectly with the host application's domain model.

- **Leaky Abstractions:** Relying on heavy frameworks for simple tasks often forces the application to inherit the framework's limitations and idiosyncrasies. When the abstraction leaks (e.g., an ORM fails to generate an optimized query), the developer must understand the internal complexity of the dependency to implement a workaround, negating the time saved by using the library.
    
- **Transitive Bloat:** A single direct dependency often pulls in a deep tree of transitive dependencies. This "dependency hell" increases the application's binary size and memory footprint. Tools like `npm ls` or `mvn dependency:tree` should be used during code review to visualize and reject packages with disproportionate transitive graphs.
    
- **Vendor Lock-in:** Extensive use of proprietary or highly opinionated libraries couples the business logic to specific technology stacks. This makes future refactoring or migration (e.g., switching cloud providers or database engines) exponentially more expensive.
    

### Security Implications

Every line of code in a dependency is a line of code running in your application with your application's privileges, yet it is code your team did not write and likely does not audit.

- **Surface Area Expansion:** Each dependency increases the surface area for potential Common Vulnerabilities and Exposures (CVEs). A library used for a trivial utility function (e.g., `left-pad`) exposes the application to the full risk profile of that library's maintainer and their supply chain security practices.
    
- **Typosquatting and Malicious Packages:** Reducing the number of dependencies statistically reduces the probability of falling victim to supply chain attacks where attackers publish malicious packages with names similar to popular libraries.
    
- **Auditability:** A lean dependency tree is human-auditable. It is feasible for a security team to review the source code of 5 critical libraries. It is impossible to manually review 500 micro-libraries.
    

### Implementation Strategies

Achieving minimal dependencies requires a shift from "consumption" to "ownership."

- **Standard Library Utilization:** Modern languages (Go, Rust, Python 3.x, Java 17+) have robust standard libraries. Architects must enforce a "Standard Library First" policy. For example, use Python's built-in `json` and `urllib` before reaching for `requests` or `simplejson` for basic tasks. Use Java's `java.net.http` instead of Apache HttpClient for simple REST calls.
    
- **Micro-Dependencies vs. Copy-Paste:** For trivial functionality (e.g., a single string manipulation function), it is often rigorous best practice to copy the specific function into a strictly tested internal utility module (crediting the license) rather than importing a massive utility library like `lodash` or `Guava`. This creates a "Vendored" approach where the code is owned, formatted, and linted according to internal standards.
    
- **Tree Shaking and Dead Code Elimination:** When dependencies are unavoidable, the build pipeline must employ aggressive tree shaking (e.g., Webpack, Rollup, ProGuard) to strip unused exports. However, reliance on tree shaking is a mitigation, not a solution; the initial architectural goal remains the exclusion of the library.
    

### Criteria for Acceptance

A formal process should exist for vetting new dependencies. A dependency should only be accepted if:

1. **Complexity Imbalance:** The cost of implementing the feature internally significantly outweighs the maintenance cost of the library.
    
2. **Cryptography/Security:** **Never** implement cryptography internally. Always use established, battle-tested libraries (e.g., OpenSSL, Sodium) for security primitives. This is the primary exception to the "build vs. buy" rule.
    
3. **Active Maintenance:** The library shows recent commits, active issue triage, and a sustainable governance model.
    
4. **License Compatibility:** The license (MIT, Apache 2.0, GPL) is legally compatible with the project's distribution model.
    

**Related Topics:**

- Software Supply Chain Security
    
- Static Analysis and Linting
    
- Build Optimization and Tree Shaking
    
- Vendor Risk Management
    
- Technical Debt Management

---

