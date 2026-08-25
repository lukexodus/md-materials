## Content Security Policy Awareness


### CSP Directive Categories

#### Fetch Directives

Fetch directives control the locations from which specific resource types may be loaded.

**default-src** serves as the fallback for all other fetch directives. When a specific fetch directive is not defined, the browser uses default-src's value. Setting `default-src 'self'` restricts all resources to the same origin unless overridden by more specific directives.

**script-src** controls JavaScript execution sources. This includes inline scripts, external script files, event handlers, and JavaScript URLs. The directive can use nonces (`'nonce-{random}'`), hashes (`'sha256-{hash}'`), or source expressions. The `'strict-dynamic'` keyword enables a trust propagation model where scripts loaded by trusted scripts inherit that trust, simplifying CSP in modern applications.

**style-src** governs CSS loading from stylesheets, inline styles, and style attributes. Similar to script-src, it supports nonces and hashes for inline styles. The `'unsafe-inline'` keyword permits all inline styles but significantly weakens security.

**img-src** restricts image sources including `<img>`, CSS background images, and favicon sources. Data URIs can be allowed with `data:` scheme.

**connect-src** controls URLs that can be loaded using script interfaces, including XMLHttpRequest, fetch(), WebSocket, EventSource, and Navigator.sendBeacon(). This is critical for preventing data exfiltration through JavaScript.

**font-src** defines valid sources for fonts loaded via @font-face. Some browsers may require `data:` scheme for inline font data.

**object-src** restricts sources for `<object>`, `<embed>`, and `<applet>` elements. Setting this to `'none'` is recommended as these elements pose security risks.

**media-src** controls `<audio>`, `<video>`, and `<track>` element sources.

**frame-src** specifies valid sources for nested browsing contexts loaded via `<frame>` and `<iframe>`. This deprecates the older frame-ancestors directive for frame loading.

**worker-src** governs Worker, SharedWorker, and ServiceWorker script sources.

**manifest-src** restricts application manifest file sources.

#### Document Directives

**base-uri** restricts URLs that can appear in the `<base>` element. Without this directive, any URI is allowed, potentially enabling base tag injection attacks that redirect relative URLs.

**sandbox** enables a sandbox for the resource similar to the `<iframe>` sandbox attribute. It applies restrictions including preventing form submission, script execution, and popup windows. Individual restrictions can be relaxed using keywords like `allow-scripts` or `allow-forms`.

#### Navigation Directives

**form-action** restricts URLs that can be used as form submission targets. This prevents forms from submitting to attacker-controlled endpoints, mitigating data exfiltration through form manipulation.

**frame-ancestors** specifies valid parents that may embed the page using `<frame>`, `<iframe>`, `<object>`, `<embed>`, or `<applet>`. This directive addresses clickjacking by controlling where the page can be framed. Unlike X-Frame-Options, it supports multiple domains and more granular control.

**navigate-to** restricts URLs to which the document may navigate by any means. [Inference: This includes hyperlinks, form submissions, and window.location assignments, though specific browser implementations may vary.]

#### Reporting Directives

**report-uri** (deprecated) instructs the browser to send violation reports to the specified URI. The endpoint receives POST requests with JSON payloads containing violation details.

**report-to** replaces report-uri and uses the Reporting API. It references a reporting group defined in the Report-To header, enabling more flexible reporting configurations including multiple endpoints and retry logic.

### Source Expression Syntax

#### Host-Based Sources

Explicit host sources define allowed origins using scheme, hostname, and optional port patterns:

- `https://example.com` - specific origin with HTTPS
- `*.example.com` - wildcard subdomain matching
- `https://*.example.com:443` - with explicit port
- `example.com` - scheme-agnostic (matches http and https)

[Inference: Wildcard subdomains match any level of subdomains, so `*.example.com` would match both `sub.example.com` and `deep.sub.example.com`, though exact browser behavior should be verified per specification.]

#### Scheme Sources

- `https:` - allows any HTTPS origin
- `data:` - permits data URIs
- `blob:` - allows blob URLs
- `filesystem:` - permits filesystem URLs

#### Keyword Sources

Keyword sources must be wrapped in single quotes:

**'self'** matches the document's origin (protocol, domain, and port). It does not include subdomains.

**'unsafe-inline'** permits inline scripts, styles, event handlers, and style attributes. This keyword significantly weakens CSP and should be avoided. Nonces or hashes provide safer alternatives for necessary inline code.

**'unsafe-eval'** allows eval(), Function(), setTimeout() with string arguments, and setInterval() with string arguments. This creates XSS vulnerabilities and should be avoided when possible.

**'unsafe-hashes'** allows specific inline event handlers and style attributes to be enabled via hashes while keeping other inline content blocked. This provides more granular control than 'unsafe-inline'.

**'none'** blocks all sources for the directive. Useful for object-src, base-uri, and other directives where no loading is needed.

**'strict-dynamic'** enables trust propagation for scripts. Scripts loaded by trusted scripts (those matching nonces or hashes) are automatically trusted, even if they wouldn't match the source list. This simplifies CSP for applications using script loaders or module bundlers. [Inference: When 'strict-dynamic' is present, host-based allowlists and 'self' are typically ignored for backwards compatibility, though specification details govern exact behavior.]

**'report-sample'** includes the first 40 characters of the blocked inline script, style, or event handler in the violation report, aiding debugging.

#### Nonce-Based Sources

Nonces are cryptographically random tokens generated per page load:

```
'nonce-rAnd0m123'
```

The corresponding HTML includes the matching nonce:

```html
<script nonce="rAnd0m123">
  // trusted code
</script>
```

[Inference: Nonces must be unpredictable and unique per request to be secure. Reusing nonces or using predictable values defeats the protection.] The server must generate fresh nonces for each response and cannot cache pages with nonce-based CSP.

#### Hash-Based Sources

Hashes allow specific inline scripts or styles by matching their content hash:

```
'sha256-abc123...'
'sha384-def456...'
'sha512-ghi789...'
```

The hash is calculated from the exact content between the script or style tags, including whitespace. Changes to the content invalidate the hash. Hashes work well for static inline code but are impractical for dynamic content.

### CSP Deployment Modes

#### Enforcement Mode

Policies are enforced via the `Content-Security-Policy` HTTP header:

```
Content-Security-Policy: default-src 'self'; script-src 'self' https://trusted.cdn.com
```

Violations are blocked and optionally reported. This is the standard deployment mode for active protection.

#### Report-Only Mode

The `Content-Security-Policy-Report-Only` header enables monitoring without enforcement:

```
Content-Security-Policy-Report-Only: default-src 'self'; report-uri /csp-report
```

Violations are reported but not blocked. This mode is essential for testing policies before enforcement, identifying necessary exceptions, and monitoring for attacks without risking functionality breakage.

#### Meta Tag Delivery

CSP can be delivered via HTML meta tags:

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'">
```

[Inference: Meta tag delivery has limitations compared to HTTP headers - specifically, report-uri, report-to, frame-ancestors, and sandbox directives cannot be used in meta tags per specification constraints.] HTTP headers remain the preferred delivery mechanism.

### Violation Reporting

#### Report Structure

Violation reports contain:

- **document-uri**: The page where violation occurred
- **violated-directive**: The specific directive that was violated
- **effective-directive**: The directive that actually enforced the violation (considering fallbacks)
- **original-policy**: The complete CSP that was violated
- **blocked-uri**: The URI that was blocked
- **status-code**: HTTP response status of the document
- **source-file**: File containing the violation (if available)
- **line-number** and **column-number**: Location in source (if available)
- **sample**: Code sample if 'report-sample' was specified

#### Reporting API Integration

The Reporting API provides structured reporting:

```
Report-To: {"group":"csp-endpoint","max_age":86400,"endpoints":[{"url":"https://reports.example.com/csp"}]}
Content-Security-Policy: default-src 'self'; report-to csp-endpoint
```

This enables batching, retry logic, and unified reporting across multiple browser features.

### Common CSP Patterns

#### Strict CSP with Nonces

```
Content-Security-Policy: 
  default-src 'none';
  script-src 'nonce-{random}' 'strict-dynamic';
  style-src 'nonce-{random}';
  img-src 'self' https:;
  font-src 'self';
  connect-src 'self';
  base-uri 'none';
  form-action 'self';
  frame-ancestors 'none';
```

This pattern provides strong protection by requiring nonces for all inline code and using strict-dynamic for script loading.

#### Hash-Based Static Sites

```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'sha256-{hash1}' 'sha256-{hash2}';
  style-src 'self' 'sha256-{hash3}';
  object-src 'none';
  base-uri 'self';
```

Suitable for static content where inline scripts and styles don't change frequently.

#### API/Service Policy

```
Content-Security-Policy:
  default-src 'none';
  frame-ancestors 'none';
```

For APIs that only serve data and should never load resources or be framed.

### CSP Evaluation Logic

#### Directive Fallback Chain

When evaluating resource loads, browsers follow a fallback hierarchy. For example, if script-src is not defined, the browser checks default-src. If neither is defined, all sources are allowed. [Inference: The specific fallback behavior varies by resource type, with most fetch directives falling back to default-src, but directives like frame-ancestors do not have fallback behavior.]

#### Source Matching Order

[Inference: When multiple sources are specified, browsers check them in the order they appear in the policy, though the exact matching algorithm may vary by implementation.] The presence of 'none' alongside other sources effectively creates a policy that blocks everything since 'none' explicitly forbids all sources.

#### Interaction with Mixed Content

CSP interacts with mixed content blocking. [Inference: A policy that allows HTTP sources may still have those loads blocked by the browser's mixed content blocker when served over HTTPS, creating a defense-in-depth effect, though specific behavior depends on browser implementations.]

### CSP Level Progression

#### CSP Level 1

The original specification included basic fetch directives, report-uri, and sandbox. This established the foundation for resource loading controls.

#### CSP Level 2

Added nonces, hashes, 'strict-dynamic', 'unsafe-inline' with nonce/hash fallback behavior, frame-ancestors, child-src, form-action, upgrade-insecure-requests, and block-all-mixed-content.

#### CSP Level 3

Introduced 'unsafe-hashes', report-to, worker-src, manifest-src, navigate-to, and prefetch-src. [Unverified: Browser adoption varies significantly for Level 3 features, with some directives having limited support.]

### Bypass Considerations

#### JSONP Endpoints

JSONP endpoints on allowed domains can execute arbitrary JavaScript if attackers control the callback parameter. Including domains with JSONP endpoints in script-src creates bypass opportunities.

#### Angular Template Injection

Older Angular versions with CSP-unsafe template patterns can be exploited if Angular is from an allowed source. [Inference: This typically involves injecting Angular expressions into templates that get evaluated, though specific exploitation techniques depend on Angular version and configuration.]

#### Allowed CDN Compromise

If a CDN listed in script-src is compromised or contains user-uploaded content, attackers may execute arbitrary scripts. This risk applies to any third-party script source in the policy.

#### Dangling Markup Injection

[Inference: In some configurations, incomplete tags or markup injection may bypass CSP by causing the browser to reinterpret document structure, though modern browsers have implemented protections against this attack vector.]

#### Base Tag Injection

Without base-uri restrictions, attackers may inject `<base>` tags to redirect relative URLs to attacker-controlled domains, bypassing CSP's source restrictions for resources loaded via relative paths.

### CSP Testing Approaches

#### Browser Developer Tools

Modern browsers report CSP violations in the console with details about blocked resources and the violated directive. The network panel shows blocked requests with CSP indicators.

#### Automated Policy Analysis

Tools can parse CSP headers and identify:

- Missing critical directives
- Unsafe keywords like 'unsafe-inline' or 'unsafe-eval'
- Overly permissive sources like wildcard domains
- Known bypass patterns
- [Unverified: Various commercial and open-source tools claim to perform this analysis, though their accuracy and coverage varies]

#### Gradual Rollout Strategy

1. Deploy in report-only mode across all pages
2. Collect and analyze violation reports
3. Adjust policy to accommodate legitimate usage
4. Enable enforcement for subset of users
5. Monitor for breakage
6. Gradually expand enforcement
7. Continuously refine based on reports

This approach minimizes disruption while building confidence in the policy.

### Performance Implications

#### Nonce Generation Overhead

[Inference: Generating cryptographically random nonces per request adds computational overhead, though modern systems typically handle this efficiently. The impact becomes more significant at very high request rates.]

#### Cache Implications

Nonce-based CSP prevents caching of HTML pages since each response requires unique nonces. This increases server load and latency compared to cached responses. [Inference: Edge computing and CDN nonce generation can mitigate this, though implementation complexity increases.]

#### Report Volume

High-traffic sites may generate substantial violation report volumes, especially during initial deployment or policy changes. [Inference: This can impact endpoint capacity and monitoring systems, requiring rate limiting or sampling strategies for large-scale deployments.]

### Integration with Other Security Headers

#### Interaction with X-Frame-Options

When both frame-ancestors (CSP) and X-Frame-Options are present, browsers that support CSP Level 2+ ignore X-Frame-Options and use frame-ancestors. For backward compatibility, both headers should be sent with matching policies.

#### Relationship with X-Content-Type-Options

X-Content-Type-Options: nosniff prevents MIME type confusion that could bypass CSP. For example, it prevents a JPEG with embedded JavaScript from being executed if misinterpreted as script.

#### Complementing X-XSS-Protection

[Inference: While X-XSS-Protection is deprecated in modern browsers, it historically provided additional XSS protection. CSP is now the preferred mechanism, offering more comprehensive and configurable protection.]

### CSP for Single Page Applications

#### Dynamic Script Loading Challenges

SPAs using dynamic imports, code splitting, or module loaders face complexity with strict CSP. The 'strict-dynamic' keyword specifically addresses this by allowing trusted scripts to load additional scripts.

#### Framework-Specific Considerations

React, Vue, and Angular each have patterns for CSP compliance:

- React generally works well with nonces or hashes for server-rendered content
- Vue requires configuration for CSP mode to avoid unsafe-eval
- Angular deprecated unsafe-eval patterns in later versions [Unverified: Specific framework versions may have different CSP requirements and compatibility characteristics.]

#### Service Worker Integration

worker-src controls Service Worker loading. [Inference: Service Workers have privileged access to the page and network, making strict worker-src policies critical for security, though specific threat models depend on the application architecture.]

---

