## Trusted Types API


### Core Architecture

The Trusted Types API enforces type safety for DOM XSS sinks by requiring specific object types rather than raw strings. The browser rejects string assignments to dangerous sinks unless explicitly configured otherwise, creating a compile-time-like safety model at runtime.

The API defines four trusted type objects: `TrustedHTML`, `TrustedScript`, `TrustedScriptURL`, and `TrustedURL`. Each type wraps a string value and can only be created through policies that implement sanitization or validation logic. DOM sinks check the type of incoming values and only accept matching trusted types or throw `TypeError` exceptions.

### Policy Creation and Management

Policies are created through `trustedTypes.createPolicy(name, rules)` where rules is an object containing sanitizer functions. Each policy must have a unique name within the document context. The rules object can define `createHTML`, `createScript`, `createScriptURL`, and `createURL` methods that receive string input and return sanitized strings.

```javascript
const policy = trustedTypes.createPolicy('myPolicy', {
  createHTML: (input) => {
    // Sanitization logic
    return DOMPurify.sanitize(input);
  },
  createScriptURL: (input) => {
    if (input.startsWith('https://trusted-cdn.example.com/')) {
      return input;
    }
    throw new TypeError('Untrusted script source');
  }
});
```

The policy object exposes methods corresponding to defined rules: `policy.createHTML(string)`, `policy.createScript(string)`, etc. These methods return the appropriate trusted type object.

### Default Policy Behavior

A single default policy can be created using the special name `'default'`. This policy intercepts string assignments to sinks when no explicit trusted type is provided, acting as a fallback sanitizer. The default policy enables incremental adoption by allowing legacy string-based code to function while still applying sanitization.

[Inference] The default policy likely executes for every string-to-sink assignment that lacks an explicit trusted type, creating potential performance overhead in string-heavy applications.

The default policy cannot be deleted once created. Attempting to create multiple default policies throws an exception. Applications must carefully design default policy rules since they apply globally across all untyped sink assignments.

### Content Security Policy Integration

Trusted Types enforcement requires CSP directives. The `require-trusted-types-for 'script'` directive activates enforcement, causing browsers to reject string assignments to XSS sinks. Without this directive, the API remains available but non-enforcing.

The `trusted-types` directive specifies allowed policy names: `trusted-types myPolicy otherPolicy`. This creates a whitelist of policies that can be instantiated. The wildcard `trusted-types *` permits any policy name. Including `'allow-duplicates'` permits multiple policies with the same name, though this weakens security guarantees.

```
Content-Security-Policy: require-trusted-types-for 'script'; trusted-types myPolicy default
```

The `'none'` keyword (`trusted-types 'none'`) prevents all policy creation except the default policy, useful for locked-down environments where only centralized sanitization should exist.

### Protected DOM Sinks

The API protects specific DOM operations that create executable code or navigate contexts:

**HTML injection sinks:**

- `Element.innerHTML`
- `Element.outerHTML`
- `Document.write()`
- `Document.writeln()`
- `Element.insertAdjacentHTML()`
- `DOMParser.parseFromString()` (when parsing HTML)

**Script execution sinks:**

- `HTMLScriptElement.src`
- `HTMLScriptElement.text`
- `HTMLScriptElement.textContent`
- `HTMLScriptElement.innerText`
- Dynamic `import()`
- `eval()`
- `Function()` constructor
- `setTimeout()` and `setInterval()` with string arguments

**Navigation sinks:**

- `HTMLIFrameElement.src`
- `HTMLEmbedElement.src`
- `HTMLObjectElement.data`
- `HTMLObjectElement.codeBase`

**URL-based sinks:**

- `HTMLAnchorElement.href` (certain contexts)
- `HTMLAreaElement.href` (certain contexts)

[Unverified] The exact list of protected sinks may vary by browser implementation and version. Specification updates may add or reclassify sinks.

### Type Construction and Validation

Trusted type objects are immutable once created. They expose a `toString()` method that returns the underlying string value, but this value cannot be modified. Attempting to create trusted types without using policies (e.g., through object literal construction) fails.

```javascript
const html = policy.createHTML('<div>Safe content</div>');
element.innerHTML = html; // Works
element.innerHTML = html.toString(); // Throws TypeError in enforcement mode
```

The `trustedTypes.isHTML()`, `trustedTypes.isScript()`, `trustedTypes.isScriptURL()`, and `trustedTypes.isURL()` methods check whether a value is the corresponding trusted type. These enable conditional logic based on type safety.

Trusted types created by one policy are accepted by sinks regardless of which policy created them. The type system provides protection through creation control, not through policy-specific validation at consumption time.

### Policy Design Patterns

**Allowlist-based policies** validate input against known-safe patterns:

```javascript
const strictPolicy = trustedTypes.createPolicy('strict', {
  createScriptURL: (url) => {
    const allowed = ['https://cdn.example.com/', 'https://trusted.example.org/'];
    if (allowed.some(prefix => url.startsWith(prefix))) {
      return url;
    }
    throw new TypeError(`URL ${url} not in allowlist`);
  }
});
```

**Sanitization policies** transform potentially dangerous input:

```javascript
const sanitizingPolicy = trustedTypes.createPolicy('sanitizer', {
  createHTML: (dirty) => {
    const sanitizer = new Sanitizer({
      allowElements: ['div', 'span', 'p', 'b', 'i'],
      allowAttributes: {'class': ['*']}
    });
    return sanitizer.sanitize(dirty);
  }
});
```

[Inference] Policies that throw exceptions on invalid input likely provide better security than policies that silently modify or ignore unsafe content, as they prevent unexpected data flow.

**Pass-through policies** exist for trusted sources where validation already occurred:

```javascript
const trustedSourcePolicy = trustedTypes.createPolicy('trusted-source', {
  createHTML: (html) => html,
  createScript: (script) => script
});
```

Pass-through policies should only be used when input provenance is absolutely verified, as they provide no protection.

### Migration Strategies

**Report-only mode** allows detection of violations without enforcement. The CSP directive `Content-Security-Policy-Report-Only: require-trusted-types-for 'script'` logs violations to the console and sends reports to configured endpoints without blocking operations.

**Incremental policy adoption** involves:

1. Deploy report-only CSP with `trusted-types *` to identify all string-to-sink assignments
2. Create default policy that logs and passes through all strings
3. Analyze logs to identify high-risk code paths
4. Replace high-risk assignments with explicit policy usage
5. Tighten default policy to reject or sanitize specific patterns
6. Switch to enforcement mode
7. Remove default policy and restrict `trusted-types` directive

**Library wrapping** encapsulates third-party code:

```javascript
const libraryPolicy = trustedTypes.createPolicy('library-wrapper', {
  createHTML: (input) => {
    // Apply library-specific sanitization
    return thirdPartyLibrary.sanitize(input);
  }
});

// Wrap library calls
function safeLibraryRender(content) {
  const safe = libraryPolicy.createHTML(content);
  return library.render(safe);
}
```

### Performance Characteristics

[Inference] Policy invocation adds overhead to every sink assignment, with the magnitude depending on sanitization complexity. Simple allowlist checks likely incur minimal cost, while full HTML parsing and sanitization may significantly impact performance.

Trusted type object creation allocates memory for wrapper objects. Applications creating millions of trusted type instances may experience memory pressure compared to raw string usage.

[Speculation] Browser implementations might optimize trusted type checks through inline caching or type specialization in JIT compilation, but this depends on implementation details not specified in the standard.

The default policy executes on every untyped sink assignment, creating a potential performance bottleneck in string-heavy code paths. Explicit policy usage bypasses default policy overhead.

### Security Boundaries

Trusted Types protect against DOM XSS by controlling string-to-code conversions, but do not prevent:

- XSS through unprotected sinks (e.g., custom data attributes interpreted as JavaScript)
- Logic vulnerabilities in policy implementation
- Exploitation of allowed HTML elements (e.g., `<form action>`, `<meta http-equiv>`)
- Server-side XSS in initially served HTML
- Prototype pollution that modifies policy behavior
- Attacks that bypass sink protection through alternative code paths

[Unverified disclaimer] The effectiveness of Trusted Types depends on comprehensive policy implementation and correct identification of all dangerous sinks. Complete XSS prevention cannot be guaranteed as new bypass techniques may emerge.

Policies execute with full JavaScript privileges. A compromised policy (through prototype pollution, monkey-patching, or implementation bugs) undermines all protection. Policy code should be minimized, audited, and isolated from untrusted input processing where possible.

### Browser API Surface

The `trustedTypes` global object provides:

- `createPolicy(name, rules)`: Creates a new policy
- `isHTML(value)`: Returns true if value is TrustedHTML
- `isScript(value)`: Returns true if TrustedScript
- `isScriptURL(value)`: Returns true if TrustedScriptURL
- `isURL(value)`: Returns true if TrustedURL
- `emptyHTML`: Pre-created TrustedHTML representing empty string
- `emptyScript`: Pre-created TrustedScript representing empty string
- `getAttributeType(tagName, attribute, elementNs, attrNs)`: Returns expected type for attribute assignment
- `getPropertyType(tagName, property, elementNs)`: Returns expected type for property assignment

The `getAttributeType()` and `getPropertyType()` methods enable dynamic determination of required types, useful for framework authors building abstraction layers.

### Framework Integration Patterns

Frameworks can integrate Trusted Types by:

**Template compilation**: Transform templates into code that generates trusted types:

```javascript
// Template: <div>{{userContent}}</div>
// Compiled output:
const rendered = policy.createHTML(`<div>${escapeHTML(userContent)}</div>`);
```

**Type-aware rendering**: Accept both strings and trusted types, wrapping strings automatically:

```javascript
function render(content) {
  if (typeof content === 'string') {
    content = policy.createHTML(content);
  }
  if (!trustedTypes.isHTML(content)) {
    throw new TypeError('Expected HTML content');
  }
  element.innerHTML = content;
}
```

**Context-aware policies**: Create different policies for different security contexts:

```javascript
const strictPolicy = trustedTypes.createPolicy('strict', { /* restrictive rules */ });
const lenientPolicy = trustedTypes.createPolicy('lenient', { /* permissive rules */ });

// Use strict policy for user input, lenient for trusted templates
```

### Testing and Validation

CSP reporting provides violation detection:

```javascript
document.addEventListener('securitypolicyviolation', (e) => {
  if (e.violatedDirective.includes('require-trusted-types-for')) {
    console.log('Trusted Types violation:', {
      blockedURI: e.blockedURI,
      violatedDirective: e.violatedDirective,
      sample: e.sample
    });
  }
});
```

Unit tests should verify policy behavior:

```javascript
describe('HTML policy', () => {
  it('rejects script tags', () => {
    expect(() => {
      policy.createHTML('<script>alert(1)</script>');
    }).toThrow();
  });
  
  it('allows safe markup', () => {
    const html = policy.createHTML('<div>safe</div>');
    expect(trustedTypes.isHTML(html)).toBe(true);
  });
});
```

[Inference] Integration tests in browsers with Trusted Types enforcement enabled likely provide the most reliable validation, as they test actual browser behavior rather than mocked policy logic.

### Edge Cases and Limitations

**Same-document navigation**: `location.href = string` may or may not require TrustedURL depending on browser implementation and URL context.

**Worker contexts**: Trusted Types enforcement in Workers depends on the Worker's own CSP, not the parent document's CSP.

**Dynamic policy modification**: Policy methods cannot be modified after creation. Attempting to reassign `policy.createHTML` fails silently or throws in strict mode.

**JSON.stringify on trusted types**: Serializing trusted types produces objects with `toString()` methods, not the underlying strings. Deserialization requires explicit handling.

**Cross-realm trusted types**: [Unverified] Trusted types created in one realm (e.g., iframe) may not be recognized in another realm depending on browser implementation.

### Adoption Considerations

[Inference] Organizations with large legacy codebases likely face significant migration costs due to widespread string-based DOM manipulation. Automated refactoring tools would substantially reduce adoption barriers but may not exist for all frameworks.

Third-party script compatibility represents a major adoption challenge. Analytics, advertising, and widget scripts frequently use string-based DOM APIs and may break under enforcement without vendor updates.

[Speculation] Widespread Trusted Types adoption might incentivize development of standardized sanitization libraries and framework-level support, reducing per-application implementation burden.

The requirement for CSP deployment limits adoption in environments where CSP conflicts with existing architectures (e.g., applications relying on inline event handlers, inline scripts without nonces, or eval-based template engines).

---

