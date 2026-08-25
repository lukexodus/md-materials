## Input Validation


### Architectural Strategy: Defense in Depth

Input validation must be implemented as a layered defense strategy, not a single gateway check. Security and data integrity require validation at multiple architectural boundaries.

- **Edge Validation (Gateway/WAF):** Enforce strict request size limits, header allow-lists, and protocol compliance to drop malformed traffic before it consumes application resources.
    
- **Application Boundary (Controller/DTO):** Syntactic validation occurs here. Use declarative constraints (e.g., JSR-380/Bean Validation) to verify formats, ranges, and non-nullability on Data Transfer Objects (DTOs) before any business logic is invoked.
    
- **Domain Layer:** Semantic validation resides here. This involves state-dependent checks (e.g., "account must be active to process transaction") that require context beyond the raw input payload.
    

### The "Parse, Don't Validate" Pattern

Traditional validation checks a value and then blindly passes it to the next function. The "Parse, Don't Validate" philosophy (common in functional programming and robust static typing) dictates that validation should transform data into a type that _proves_ validity.

- **Type-Driven Design:** Instead of passing a `String` email and checking it repeatedly, parse the `String` once into an `EmailAddress` value object. If the object exists, the data is guaranteed valid by its type definition.
    
- **Illegal States Unrepresentable:** Design data structures such that invalid combinations of data simply cannot be constructed. This eliminates the need for defensive checking deep within the domain logic.
    

### Whitelisting (Positive Validation)

Security-critical validation must rely exclusively on whitelisting (allowing known good input) rather than blacklisting (blocking known bad input).

- **Strict Criteria:** Define exact permissible character sets, length boundaries, and patterns. Blacklists are inherently flawed because attackers constantly discover new evasion techniques (e.g., alternative encodings, null byte injection).
    
- **Canonicalization:** Input must be canonicalized (decoded to its simplest form) _before_ validation. Failure to do so allows attackers to bypass filters using double-encoding (e.g., `%2527` for `'`) or Unicode variations.
    

### Regular Expression Denial of Service (ReDoS)

Regex is a powerful validation tool but introduces significant availability risks if mishandled.

- **Catastrophic Backtracking:** Poorly crafted regex patterns (specifically those with nested quantifiers like `(a+)+`) can cause the regex engine to take exponential time to process non-matching strings.
    
- ** mitigation:** Use atomic grouping, possessive quantifiers, or non-backtracking regex engines (e.g., RE2). Implement strict timeouts on all regex execution to prevent a single malicious payload from hanging a thread.
    

### Deserialization Security

Validating the _structure_ of serialized data (JSON, XML, YAML) is insufficient; the _instantiation_ process itself is a vector.

- **Type Enforcement:** strictly enforce polymorphic type allow-lists during deserialization to prevent "Gadget Chain" attacks where attackers instantiate dangerous classes available on the classpath.
    
- **Entity Expansion:** Disallow DTDs (Document Type Definitions) and external entity processing in XML parsers to prevent XXE (XML External Entity) attacks, which can lead to local file disclosure or SSRF.
    

### Anti-Patterns

- **Client-Side Only Validation:** Client-side checks are purely for UX. They provide zero security and can be bypassed by any user with `curl` or Postman.
    
- **Sanitization as Validation:** Attempting to "clean" malicious input (e.g., removing `<script>` tags) is error-prone. It is safer to reject invalid input entirely than to attempt to reconstruct it into a safe state.
    
- **Coupled Validation Logic:** Hardcoding validation rules inside business logic methods makes the system difficult to test and violates the Single Responsibility Principle. Move constraints to metadata or distinct validator classes.

---

