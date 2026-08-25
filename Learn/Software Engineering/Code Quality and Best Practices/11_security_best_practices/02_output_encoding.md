## Output Encoding


### Security Criticality and XSS Prevention

Output encoding is the primary defensive mechanism against Cross-Site Scripting (XSS) and various injection attacks. It ensures that the interpreter (browser, database, parser) treats user-supplied data as content rather than executable code or structural markup. In a secure architecture, output encoding is not an optional feature but a mandatory, pervasive layer in the presentation tier.

Failure to implement rigorous output encoding compromises the Confidentiality and Integrity of the application, allowing attackers to hijack sessions, exfiltrate data, or deface interfaces.

### Context-Sensitive Encoding

A common architectural failure is applying a generic encoding strategy universally. Encoding must be context-sensitive, meaning the encoding method changes based on where the data is placed within the document structure.

#### 1. HTML Body Context

When inserting untrusted data between tags (`<div>...</div>`), characters that are significant in HTML must be converted to their corresponding HTML entities.

- **Critical Characters:** `<` `>` `&` `"` `'` `/`
    
- **Transformation:** `<` $\rightarrow$ `&lt;`
    

#### 2. HTML Attribute Context

Data inserted into attributes (e.g., `<input value="...">`) requires more aggressive encoding. Using HTML entity encoding is insufficient if the attribute is not quoted, or if the attacker can break out of the attribute context.

- **Standard:** All non-alphanumeric characters with ASCII values less than 256 should be encoded using the `&#xHH;` format (e.g., `&#x3B;`) to prevent attribute breakout.
    

#### 3. JavaScript Context

Inserting data dynamically into `<script>` blocks is the most dangerous context. HTML entity encoding is **ineffective** here because the JavaScript parser executes before the HTML decoder in many scenarios.

- **Requirement:** Unicode escapes (`\uXXXX`) or Hex escapes (`\xHH`).
    
- **Anti-Pattern:** Using backslashes alone to escape quotes, which can be bypassed if the attacker injects the backslash character itself.
    

#### 4. URL Context

When embedding data into URL parameters, standard URL encoding (percent-encoding) is required.

- **Scope:** Only parameter values should be encoded. Encoding the entire URL breaks the structural separators (`?`, `&`, `=`).
    

### The "Input Validation vs. Output Encoding" Distinction

A rigorous codebase distinguishes between input validation (data integrity) and output encoding (presentation security).

- **Input Validation:** Occurs at the entry point. Rejects data that does not conform to expected types, lengths, or formats.
    
- **Output Encoding:** Occurs at the exit point (Just-In-Time). Transforms data safely for the specific consumer.
    

**Architectural Rule:** Never encode data before storing it in the database ("Encoding at Ingress"). This leads to:

1. **Data Corruption:** The database contains `&lt;name&gt;` instead of `<name>`.
    
2. **Double Encoding:** Subsequent retrievals re-encode the entities (e.g., `&amp;lt;`), rendering garbage to the user.
    
3. **Loss of Agnostic Utility:** The data becomes tied to HTML and cannot be easily consumed by non-web clients (e.g., mobile apps, PDF generators).
    

### Framework-Specific Controls and Escape Hatches

Modern frontend frameworks (React, Angular, Vue) provide automatic context-sensitive encoding by default. However, code quality reviews must scrutinize the usage of "escape hatches" that bypass these protections.

- **React:** `dangerouslySetInnerHTML`. Usage implies the developer has manually verified the sanitization of the input.
    
- **Angular:** `innerHTML` binding. Must be used in conjunction with `DomSanitizer`.
    
- **Vue:** `v-html` directive.
    

**Policy:** The use of these directives should be flagged by static analysis tools (SAST) and permitted only with an explicit suppression comment and a documented security review.

### Sanitization vs. Encoding

While encoding renders code inert, **sanitization** removes unsafe characters while preserving safe HTML structure (e.g., allowing `<b>` but removing `<script>`).

- **Use Case:** Rich text editors or CMS inputs where users must author HTML.
    
- **Library Standard:** Never attempt to write a sanitizer using Regular Expressions. It is mathematically impossible to parse nested HTML structures safely with Regex. Use established libraries like DOMPurify (Client-side) or OWASP Java HTML Sanitizer (Server-side).

---

