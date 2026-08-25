## Custom Scheme Definition


Organizations and applications can define custom URI schemes to enable specialized functionality, protocol handlers, and deep linking. The process involves technical specification, optional registration, and implementation considerations.

### When to Define Custom Schemes

Custom schemes are appropriate for:

**Application-Specific Protocols**: When existing schemes don't adequately represent your protocol's semantics:

```
myapp://action/resource
spotify://track/1234567890
```

**Deep Linking**: Enabling direct navigation to specific application states:

```
shopping://product/12345
news://article/breaking-story
```

**Protocol Integration**: Creating bridges between different systems:

```
git://repository/path
magnet:?xt=urn:btih:...
```

**Internal Corporate Systems**: Organization-specific resource identification:

```
corpnet://department/document
intranet://wiki/page
```

**Avoid Custom Schemes When**:

- Existing schemes suffice (http/https for web resources)
- Deep linking can use URL parameters (https://example.com/app?action=open)
- Universal schemes (data:, javascript:) meet your needs
- Custom scheme would confuse users or conflict with established patterns

### Technical Specification Requirements

A well-defined custom scheme requires documentation of:

**Scheme Name**: Must follow RFC 3986 rules:

- Start with a letter
- Contain only letters, digits, plus (`+`), period (`.`), or hyphen (`-`)
- Should be short, descriptive, and unlikely to conflict
- Case-insensitive but conventionally lowercase

**Valid Examples**:

```
myapp
example-app
app.example
git+ssh
```

**Invalid Examples**:

```
123app      // Cannot start with digit
my_app      // Underscore not allowed
my-app!     // Special character not allowed
```

**Syntax Definition**: Specify the structure after the scheme:

```
scheme:scheme-specific-part[?query][#fragment]
```

Document:

- Whether to use hierarchical (`://`) or non-hierarchical (`:`) format
- Authority component requirements (host, port, userinfo)
- Path structure and allowed characters
- Query parameter format and semantics
- Fragment identifier meaning
- Encoding requirements for special characters

**Example Specification**:

```
shopapp://action/resource?param=value

Components:
- scheme: "shopapp" (case-insensitive)
- action: One of {view, add, purchase} (case-sensitive)
- resource: Resource ID (alphanumeric, percent-encoded if special chars)
- param: Optional query parameters (standard URL query format)

Examples:
shopapp://view/product-123
shopapp://add/item-456?quantity=2
shopapp://purchase/cart?checkout=true
```

**Semantics**: Define what the URI represents:

- What resource or action does it identify?
- What should happen when a client processes it?
- What operations are supported?
- What states or contexts are valid?

**Security Considerations**: Address potential vulnerabilities:

- Parameter injection risks
- Authentication requirements
- Authorization checks
- Resource access boundaries
- Cross-origin implications
- User consent for sensitive actions

**Error Handling**: Specify behavior for malformed URIs:

- Missing required components
- Invalid characters
- Out-of-range values
- Unknown actions or resources

**Versioning**: Plan for future evolution:

- Version number in scheme name (`myapp-v2://`) or path (`myapp://v2/`)
- Backward compatibility strategy
- Migration path for old URIs

### IANA Registration Process

Formal registration with IANA provides:

- Official recognition and documentation
- Prevention of naming conflicts
- Public specification availability
- Standards-track status

**Registration Types**:

**Permanent Schemes**: For widely-used, stable protocols

- Requires IETF RFC or equivalent specification
- Expert review and IESG approval
- Long-term commitment to maintenance
- Examples: http, ftp, mailto

**Provisional Schemes**: For experimental or limited-scope use

- Lighter documentation requirements
- First-come, first-served registration
- Can be promoted to permanent later
- Suitable for application-specific schemes

**Historical Schemes**: Previously registered but now obsolete

- Maintained for reference
- Should not be used for new implementations

**Registration Steps**:

1. **Prepare Specification Document**:
    
    - Scheme name and syntax
    - Semantics and use cases
    - Encoding and character set
    - Security considerations
    - Contact information
2. **Submit to IANA**:
    
    - Email registration request to iana@iana.org
    - Include completed registration template
    - Reference specification document (if available)
3. **Expert Review**:
    
    - Designated expert reviews submission
    - Checks for conflicts with existing schemes
    - Evaluates specification quality
    - May request modifications
4. **Publication**:
    
    - Approved schemes added to IANA registry
    - Publicly accessible at https://www.iana.org/assignments/uri-schemes/
    - Specification linked from registry entry

**Registration Template**:

```
Scheme name: example
Status: Provisional
Applications/protocols: Example application protocol
Contact: admin@example.com
Change controller: Example Organization
References: https://example.com/spec/example-uri-scheme.html
```

### Implementation Approaches

**Operating System Registration**:

Different platforms provide mechanisms to register custom scheme handlers:

**Windows**: Registry entries associate schemes with applications

```
HKEY_CLASSES_ROOT\myapp
    (Default) = "URL:MyApp Protocol"
    URL Protocol = ""
    
HKEY_CLASSES_ROOT\myapp\shell\open\command
    (Default) = "C:\Path\To\App.exe" "%1"
```

**macOS**: Info.plist configuration in application bundle

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.example.myapp</string>
    </dict>
</array>
```

**Linux**: Desktop entry files specify scheme handlers

```
[Desktop Entry]
Name=MyApp
Exec=myapp %u
MimeType=x-scheme-handler/myapp;
```

**Web Browsers**:

Browsers handle custom schemes through protocol handler APIs:

**Navigator.registerProtocolHandler** (limited support):

```javascript
navigator.registerProtocolHandler(
    'web+myapp',  // Must start with 'web+' for security
    'https://example.com/handle?url=%s',
    'My App Handler'
);
```

Restrictions:

- Scheme must start with `web+` or be an approved scheme (mailto, etc.)
- Handler must be HTTPS URL on same origin
- User must explicitly approve registration

**Android**:

Intent filters in AndroidManifest.xml:

```xml
<activity android:name=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" />
    </intent-filter>
</activity>
```

Handle in activity:

```java
Intent intent = getIntent();
Uri data = intent.getData();
if (data != null) {
    String scheme = data.getScheme();
    String path = data.getPath();
    // Process custom URI
}
```

**iOS**:

URL Schemes in Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

Handle in AppDelegate:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme == "myapp" {
        // Handle custom URL
        return true
    }
    return false
}
```

### Security Considerations for Custom Schemes

**Injection Attacks**: Custom scheme handlers must validate and sanitize URI components:

```javascript
// Vulnerable code
let uri = "myapp://action/" + userInput;
window.location = uri;

// Safer approach
function createSafeURI(action, resource) {
    const safeAction = encodeURIComponent(action);
    const safeResource = encodeURIComponent(resource);
    return `myapp://${safeAction}/${safeResource}`;
}
```

**Privilege Escalation**: Handlers should verify user authorization before performing sensitive actions:

```javascript
// Check if action requires authentication
if (requiresAuth(action) && !isAuthenticated()) {
    promptLogin();
    return;
}

// Verify user has permission for resource
if (!hasPermission(user, resource, action)) {
    showError("Access denied");
    return;
}
```

**Phishing and Social Engineering**: Custom schemes can be abused to trick users:

```
mybank://transfer?to=attacker&amount=1000
```

[Inference: Applications should display confirmation dialogs for sensitive actions triggered by URIs, especially when the URI originates from external sources like web pages or emails.]

**Cross-Site Request Forgery (CSRF)**: URIs triggered from web pages can perform actions without user consent:

**Mitigation Strategies**:

- Require user confirmation for state-changing actions
- Implement one-time tokens in URIs for sensitive operations
- Check referrer or origin of URI invocation
- Rate-limit action execution

**URL Spoofing**: Schemes with similar names can confuse users:

```
myapp://...      // Legitimate
rnyapp://...     // Visual similarity attack (rn vs m)
my-app://...     // Slight variation
```

**Protection**:

- Choose distinctive scheme names
- Register variations proactively
- Educate users about official scheme names

### Best Practices for Custom Schemes

**Naming Conventions**:

- Use organization/app name prefix to avoid conflicts: `spotify://`, `slack://`
- Keep names short but descriptive
- Avoid generic terms that might conflict
- Consider future expansion in naming

**Structure Design**:

- Follow established patterns (hierarchical for resources)
- Make URIs human-readable when possible
- Support both minimal and detailed forms
- Allow optional parameters for extensibility

**Example Well-Designed Scheme**:

```
appname://module/action/resource?param=value

Examples:
appname://editor/open/document-123
appname://settings/preferences/display?theme=dark
appname://share/content/post-456?platform=twitter
```

**Backward Compatibility**:

- Version critical changes
- Maintain support for old URI formats during transition
- Provide migration tools or automatic conversion
- Document deprecation timeline clearly

**Documentation**:

- Publish complete specification
- Provide usage examples for common scenarios
- Document error codes and handling
- Include security considerations
- Maintain changelog for specification updates

**Testing**:

- Test across target platforms and OS versions
- Verify proper handling of malformed URIs
- Check security against injection attacks
- Validate encoding/decoding edge cases
- Test integration with different URI sources (web, email, QR codes)

**User Experience**:

- Provide clear feedback when URI is processed
- Show error messages for invalid URIs
- Allow users to review actions before execution
- Support fallback behavior for unregistered handlers

**Privacy**:

- Minimize sensitive data in URIs (they may be logged)
- Use tokens or references instead of explicit user data
- Consider URI visibility in browser history and logs
- Implement expiration for time-sensitive URIs

### Alternative Approaches to Custom Schemes

Before defining custom schemes, consider alternatives:

**Universal Links (iOS) / App Links (Android)**:

- Use standard HTTPS URLs that open apps when installed
- Provide web fallback when app is not installed
- Better for SEO and universal sharing
- More secure (requires domain verification)

**Example**:

```
https://example.com/product/123
// Opens app if installed, otherwise loads web page
```

**URL Parameters with Standard Schemes**:

```
https://example.com/app?action=open&resource=document-123
```

**Deep Linking Services**:

- Branch.io, Firebase Dynamic Links, AppsFlyer
- Provide cross-platform deep linking
- Include analytics and attribution
- Handle deferred deep linking (install then open)

**Key Points**: Custom URI schemes enable powerful application integration and deep linking capabilities but require careful design, security consideration, and proper implementation across platforms. For web-to-app scenarios, modern alternatives like Universal Links often provide better user experience and security. Registration with IANA provides official recognition but is optional for private or application-specific schemes.

