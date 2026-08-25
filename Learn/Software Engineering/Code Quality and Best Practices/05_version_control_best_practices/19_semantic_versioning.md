## Semantic Versioning


Semantic Versioning (SemVer) is a formal convention for assigning version numbers to software releases. It creates a shared contract between library authors and consumers, communicating the nature of changes and the risk of upgrading. The version number itself conveys meaning about the underlying code changes.

**Key Points**

- **Format:** The version number follows the format `MAJOR.MINOR.PATCH` (e.g., `2.14.3`).
    
- **Increment Rules:**
    
    - **MAJOR:** Incremented when you make incompatible API changes (Breaking Changes). Resets MINOR and PATCH to zero.
        
    - **MINOR:** Incremented when you add functionality in a backward-compatible manner (New Features). Resets PATCH to zero.
        
    - **PATCH:** Incremented when you make backward-compatible bug fixes.
        
- **Public API Declaration:** SemVer relies on a clearly defined public API. Changes to this API dictate the version increment. If the API is not declared, version numbers become meaningless.
    
- **Initial Development (0.y.z):** Major version zero (`0.y.z`) is for initial development. The public API should be considered unstable. Breaking changes can occur at any time without incrementing the Major version. The standard shifts to `1.0.0` once the API is stable and ready for production use.
    
- **Pre-release Identifiers:** A hyphen and a series of dot-separated identifiers can be appended to the patch version to denote a pre-release (e.g., `1.0.0-alpha`, `1.0.0-beta.1`). These indicate lower stability.
    
- **Build Metadata:** Plus signs denoted build metadata (e.g., `1.0.0+20130313144700`). This metadata is ignored when determining version precedence.
    

**Example**

Consider a library currently at version `1.5.0`.

1. **Scenario A (Refactor):** You rewrite a function for performance, but the inputs and outputs remain identical.
    
    - Action: Increment PATCH.
        
    - New Version: `1.5.1`
        
2. **Scenario B (New Feature):** You add a new method `exportToPDF()` to a class, but existing methods work as before.
    
    - Action: Increment MINOR.
        
    - New Version: `1.6.0`
        
3. **Scenario C (Breaking Change):** You rename a public method from `getUser()` to `fetchUser()` to align with a new naming convention. Code depending on `getUser()` will break.
    
    - Action: Increment MAJOR.
        
    - New Version: `2.0.0`
        

**Dependency Resolution**

SemVer enables package managers (like npm, cargo, pip) to resolve dependencies safely using range operators:

- **Tilde (`~1.2.3`):** Allows Patch-level changes only (equivalent to `>= 1.2.3 < 1.3.0`). Safe for bug fixes.
    
- **Caret (`^1.2.3`):** Allows Minor and Patch-level changes (equivalent to `>= 1.2.3 < 2.0.0`). Safe for non-breaking features.
    

**Conclusion**

Strict adherence to Semantic Versioning prevents "Dependency Hell," where a system becomes locked because upgrading one package breaks another. It shifts the focus from arbitrary marketing numbers to technical compatibility contracts.

**Next Steps**

Review your project's `git` tags. If you are preparing for a production release and are still on `0.x.x`, audit your API stability and plan your `1.0.0` release to signal maturity to your users.

---

