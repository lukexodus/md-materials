## Proxy Tools for Development


### Charles Proxy

#### Installation and Setup

Charles Proxy is a cross-platform HTTP debugging proxy that captures network traffic between applications and the internet.

**Basic Configuration:**

- Download from https://www.charlesproxy.com
- Install SSL certificates for HTTPS inspection
- Configure system proxy: automatically sets to `127.0.0.1:8888`
- Trust Charles root certificate in system keychain

**SSL Certificate Installation:**

1. Help → SSL Proxying → Install Charles Root Certificate
2. Trust certificate for SSL proxying
3. Enable SSL Proxying: Proxy → SSL Proxying Settings
4. Add location: `*:443` or specific domains

#### Inspecting Fetch Requests

**View Request Details:**

- Structure view: organized by domain hierarchy
- Sequence view: chronological request order
- Request tab: headers, parameters, body
- Response tab: status, headers, content

**Key Information Visible:**

- Request method, URL, protocol
- Request/response headers
- Query parameters and form data
- Request/response body (JSON, XML, binary)
- Timing information (DNS, Connect, Request, Response)
- WebSocket frames

#### Breakpoints

Set breakpoints to pause and modify requests/responses:

**Request Breakpoints:**

```
Proxy → Breakpoint Settings → Add
- Host: api.example.com
- Port: 443
- Path: /users/*
```

When breakpoint triggers:

- Edit URL parameters
- Modify request headers
- Change request body
- Add authentication tokens
- Cancel or execute request

**Response Breakpoints:**

- Modify response status code
- Edit response headers
- Change response body
- Simulate different data structures

**Practical Example:**

```javascript
// Original fetch request
fetch('https://api.example.com/users/123')
  .then(r => r.json())
  .then(data => console.log(data));

// With Charles breakpoint:
// 1. Request pauses at breakpoint
// 2. Change URL to /users/456
// 3. Add header: X-Debug: true
// 4. Execute to continue
```

#### Throttling and Bandwidth Simulation

Simulate slow connections to test fetch behavior:

**Throttle Settings:**

```
Proxy → Throttle Settings
- Enable throttling
- Throttle preset: 3G, 4G, LTE, Custom
- Bandwidth: upload/download speeds
- Utilisation: percentage of bandwidth
- Round-trip latency
- MTU (Maximum Transmission Unit)
```

**Common Presets:**

- 3G: 780 kbps down, 330 kbps up, 100ms latency
- 4G: 9 Mbps down, 9 Mbps up, 50ms latency
- Edge: 240 kbps down, 200 kbps up, 840ms latency

**Testing Fetch Timeouts:**

```javascript
// Test with throttling enabled
const controller = new AbortController();
setTimeout(() => controller.abort(), 3000);

fetch('https://api.example.com/large-file', {
  signal: controller.signal
}).catch(err => {
  // Timeout will trigger with slow throttling
  console.log('Request timeout:', err);
});
```

#### Map Local and Map Remote

**Map Local:** Redirect network requests to local files:

```
Tools → Map Local
- Map From: https://api.example.com/config.json
- Map To: /Users/dev/mock-data/config.json
```

Use cases:

- Test with mock data without backend changes
- Develop offline with cached responses
- Test different response scenarios

**Map Remote:** Redirect requests to different endpoints:

```
Tools → Map Remote
- Map From: https://api.staging.com
- Map To: https://api.production.com
```

Use cases:

- Test production API from staging environment
- Switch between API versions
- Route to local development server

#### Rewrite Tool

Modify requests/responses automatically:

**Rewrite Rules:**

```
Tools → Rewrite
- Type: Modify Header
- Where: Request
- Match: Authorization
- Replace: Bearer new-token-here
```

**Rule Types:**

- Add/Modify/Remove header
- Add/Modify/Remove query parameter
- Modify path
- Modify host
- Modify URL
- Modify body
- Modify response status

**Example Scenarios:**

```javascript
// Rewrite Rule: Add CORS headers to any response
// Response Header: Access-Control-Allow-Origin: *

fetch('https://third-party-api.com/data')
  .then(r => r.json())
  // CORS header automatically added by Charles
  .then(data => console.log(data));
```

#### Recording and Sessions

**Session Management:**

- Record automatically on startup
- Save session: File → Save Session
- Export formats: .chls (Charles), .har (HTTP Archive)
- Import previous sessions for analysis

**Filtering:**

```
Proxy → Recording Settings
- Include: specific domains
- Exclude: analytics, ads, tracking
```

**Session Analysis:**

- Total requests/responses
- Failed requests
- Average response time
- Total data transferred
- Request distribution by domain

#### Repeat and Compose

**Repeat Tool:** Right-click request → Repeat

- Repeat once
- Repeat advanced (specify count)
- Useful for testing rate limiting
- Test load handling

**Compose Tool:** Create requests from scratch:

```
Tools → Compose
- Set method: GET, POST, PUT, DELETE
- Enter URL
- Add headers
- Add body (raw, form, multipart)
- Execute request
```

**Testing Custom Fetch Configurations:**

```javascript
// Test this fetch configuration in Charles Compose:
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer token123'
  },
  body: JSON.stringify({ key: 'value' })
});

// Use Compose to verify:
// - Correct headers sent
// - Body formatted properly
// - Authentication working
// - Response as expected
```

#### Mirror Tool

Duplicate traffic to another server:

```
Tools → Mirror
- Mirror To: https://backup-server.com
```

Use cases:

- Send production traffic to staging
- Duplicate requests for testing
- Load testing parallel servers

### Fiddler

#### Installation and Setup

Fiddler is a Windows-focused HTTP debugging proxy (Fiddler Classic) with cross-platform Fiddler Everywhere.

**Basic Configuration:**

- Download from https://www.telerik.com/fiddler
- Default proxy: `127.0.0.1:8888`
- Enable HTTPS decryption: Tools → Options → HTTPS
- Install Fiddler root certificate

**Fiddler Everywhere:**

- Modern cross-platform version (Windows, Mac, Linux)
- Cloud-based collaboration features
- Similar core functionality to Classic

#### Inspecting Traffic

**Session List:**

- Left panel: chronological list of requests
- Columns: Result, Protocol, Host, URL, Body, Caching
- Color coding: 200s (green), 300s (blue), 400s/500s (red)

**Inspectors:**

- Headers: raw headers, formatted view
- TextView: response as text
- WebForms: POST data, query strings
- JSON: formatted JSON viewer
- XML: structured XML view
- Raw: unprocessed request/response

**Request Details:**

```javascript
// Fetch request
fetch('https://api.example.com/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'John' })
});

// Fiddler shows:
// - Raw HTTP request/response
// - Timing information
// - Request/response sizes
// - Compression details
```

#### AutoResponder

Automatically respond to requests with custom responses:

**Creating Rules:**

```
AutoResponder tab → Add Rule
- Rule: EXACT:https://api.example.com/users
- Response: C:\mock-data\users.json

OR

- Rule: regex:(?inx)^https://api\.example\.com/.*
- Response: *404
```

**Response Types:**

- Local file path
- HTTP status code (404, 500, 302)
- Built-in responses (*bpafter, *delay:ms)
- Another captured session

**Latency Simulation:**

```
Rule: REGEX:api.example.com
Response: *delay:2000 *bpafter
```

**Testing Scenarios:**

```javascript
// Test error handling
fetch('https://api.example.com/data')
  .then(r => {
    if (!r.ok) throw new Error('API Error');
    return r.json();
  })
  .catch(err => console.error(err));

// AutoResponder rule: respond with 500 status
// Test if error handling works correctly
```

#### Breakpoints

**Setting Breakpoints:**

- Before requests: Rules → Automatic Breakpoints → Before Requests
- After responses: Rules → Automatic Breakpoints → After Responses
- Specific requests: Right-click session → Breakpoint

**Request Modification:** When paused at breakpoint:

- Edit raw request text
- Modify headers in Inspector
- Change request body
- Edit URL
- Click "Run to Completion" or "Break on Response"

**Response Modification:**

- Change status code
- Edit response headers
- Modify response body
- Test different content types

#### FiddlerScript

Customize Fiddler behavior with JScript:

**Common Scripts:**

```javascript
// Rules → Customize Rules (FiddlerScript editor)

// Highlight specific requests
static function OnBeforeRequest(oSession: Session) {
    if (oSession.uriContains("api.example.com")) {
        oSession["ui-color"] = "orange";
        oSession["ui-bold"] = "true";
    }
}

// Add custom header to all requests
static function OnBeforeRequest(oSession: Session) {
    oSession.oRequest["X-Custom-Header"] = "DebugMode";
}

// Log specific request data
static function OnBeforeResponse(oSession: Session) {
    if (oSession.uriContains("/api/")) {
        FiddlerApplication.Log.LogString(
            oSession.responseCode + " - " + oSession.fullUrl
        );
    }
}

// Modify response status
static function OnBeforeResponse(oSession: Session) {
    if (oSession.uriContains("/test-error")) {
        oSession.responseCode = 500;
    }
}

// Delay specific requests
static function OnBeforeRequest(oSession: Session) {
    if (oSession.uriContains("slow-endpoint")) {
        oSession["request-trickle-delay"] = "3000";
    }
}
```

**Testing Fetch with Scripts:**

```javascript
// Your fetch code
async function getData() {
    const response = await fetch('https://api.example.com/data');
    return response.json();
}

// FiddlerScript to test different scenarios:
// 1. Add authentication header automatically
// 2. Delay response to test loading states
// 3. Return mock data for specific endpoints
// 4. Log all API calls for debugging
```

#### Composer

Build and send custom requests:

**Request Builder:**

```
Composer tab
- HTTP Method: GET, POST, PUT, DELETE, PATCH
- URL: https://api.example.com/endpoint
- Request Headers:
    Content-Type: application/json
    Authorization: Bearer token
- Request Body:
    {"key": "value"}
- Execute
```

**Upload Files:**

```
- Method: POST
- Body format: multipart/form-data
- Add files: Upload File section
- Add form fields
```

**Save Requests:**

- Save as .saz file
- Import saved requests
- Share with team members

#### Filters

Focus on relevant traffic:

**Hosts Filter:**

```
Filters tab
- Show only: api.example.com, cdn.example.com
- Hide: google-analytics.com, facebook.com
```

**Request Headers Filter:**

```
- Flag requests with header: Authorization
- Delete request header: Cookie
- Set request header: X-Debug-Mode: true
```

**Response Headers Filter:**

```
- Delete response header: Set-Cookie
- Set response header: Access-Control-Allow-Origin: *
```

**Breakpoint Filters:**

```
- Break on POST requests only
- Break on requests to specific domain
- Break on responses with status 400+
```

#### Connection Simulation

**Modem Speeds:**

```
Rules → Performance → Simulate Modem Speeds
```

Options:

- No simulation
- 56K modem: 56 kbps
- ISDN: 128 kbps
- 300 baud: extremely slow

**Custom Delays:**

```javascript
// FiddlerScript
static function OnBeforeRequest(oSession: Session) {
    if (oSession.uriContains("api")) {
        oSession["request-trickle-delay"] = "1000";  // 1 second delay
        oSession["response-trickle-delay"] = "2000"; // 2 second delay
    }
}
```

#### Export and Reporting

**Export Formats:**

- HTTPArchive (.har): industry standard
- Fiddler Session Archive (.saz)
- Raw text
- CSV
- XML

**Session Statistics:**

```
Statistics tab
- Total requests
- Response codes distribution
- Content types
- Bytes sent/received
- Time charts
```

**Timeline View:**

```
Timeline tab (Fiddler Everywhere)
- Waterfall chart
- Request timing breakdown
- DNS lookup time
- Connection time
- SSL handshake time
- Time to first byte
- Download time
```

### Comparison: Charles vs Fiddler

#### Feature Comparison

**Charles Advantages:**

- Better macOS integration
- Cleaner, more intuitive UI
- Built-in bandwidth throttling presets
- Better WebSocket support
- Map Local/Remote features more polished
- Easier SSL certificate setup on macOS

**Fiddler Advantages:**

- Free (Classic version)
- More powerful scripting with FiddlerScript
- Better Windows integration
- AutoResponder more flexible
- Composer more feature-rich
- Larger user community and extensions

**Cross-Platform:**

- Charles: Windows, macOS, Linux (mature)
- Fiddler Classic: Windows only
- Fiddler Everywhere: Windows, macOS, Linux (newer)

#### Use Case Recommendations

**Choose Charles for:**

- macOS-centric development
- Teams using Apple ecosystem
- Simpler UI preference
- Built-in bandwidth profiles
- WebSocket heavy applications

**Choose Fiddler for:**

- Windows-centric development
- Complex custom scripting needs
- Budget constraints (Classic is free)
- Advanced AutoResponder scenarios
- Integration with .NET applications

### Common Workflows

#### Testing Fetch Error Handling

**Scenario: Test 404 response**

Charles:

```
1. Tools → Rewrite
2. Add rule: Modify Response Status → 404
3. Apply to specific URL pattern
4. Run fetch request
5. Verify error handling
```

Fiddler:

```
1. AutoResponder → Enable
2. Add rule: url matches → *404
3. Save rule
4. Run fetch request
5. Check error handling
```

#### Testing Timeout Behavior

**Scenario: Simulate slow network**

Charles:

```
1. Proxy → Throttle Settings
2. Enable throttling
3. Select 3G preset or custom
4. Set high latency (500ms+)
5. Test fetch timeout logic
```

Fiddler:

```
1. Rules → Performance → Simulate Modem Speeds
2. OR FiddlerScript: add delays
3. Test timeout handling
```

#### Mock API Responses

**Scenario: Develop with mock data**

Charles:

```
1. Tools → Map Local
2. Map endpoint to local JSON file
3. Update JSON as needed
4. Fetch receives mock data
5. No backend required
```

Fiddler:

```
1. AutoResponder → Enable
2. Add rule matching API endpoint
3. Point to local mock file
4. Edit file to change responses
5. Automatic reload
```

#### Debug CORS Issues

**Scenario: Test cross-origin requests**

Charles:

```
1. Tools → Rewrite
2. Add Response Header rule
3. Header: Access-Control-Allow-Origin: *
4. Apply to failing endpoint
5. Verify fetch succeeds
```

Fiddler:

```
1. Rules → Customize Rules
2. Add CORS headers in OnBeforeResponse
3. OR use Filters to add response headers
4. Test cross-origin fetch
```

#### Capture Mobile App Traffic

**Scenario: Debug fetch in mobile app**

Charles:

```
1. Get computer IP address
2. Configure mobile device proxy:
   - iOS: Settings → Wi-Fi → Proxy → Manual
   - Android: Wi-Fi → Modify Network → Proxy
3. Set proxy to computer_ip:8888
4. Install Charles certificate on device
5. Trust certificate in device settings
6. Capture mobile app traffic
```

Fiddler:

```
1. Tools → Options → Connections
2. Allow remote computers to connect
3. Configure mobile device proxy to computer_ip:8888
4. Install Fiddler certificate on mobile device
5. Capture and inspect mobile traffic
```

### Advanced Techniques

#### Request Chaining

Test dependent fetch calls:

Charles:

```
1. Capture first request response
2. Tools → Rewrite
3. Extract value from first response
4. Inject into second request header
5. Verify chain works
```

Fiddler:

```javascript
// FiddlerScript
static function OnBeforeRequest(oSession: Session) {
    if (oSession.uriContains("second-endpoint")) {
        var firstResponse = getFirstResponseValue();
        oSession.oRequest["X-Previous-Data"] = firstResponse;
    }
}
```

#### Performance Profiling

Identify slow fetch requests:

Both Tools:

1. Record full session
2. Sort by duration
3. Identify slowest requests
4. Check timing breakdown:
    - DNS resolution
    - TCP connection
    - SSL handshake
    - Time to first byte
    - Content download
5. Optimize accordingly

#### Security Testing

Test authentication and authorization:

1. Capture authenticated request
2. Save session/request
3. Compose new request with:
    - Missing auth header
    - Expired token
    - Modified token
    - Different user credentials
4. Verify server validates properly

#### Load Testing Simulation

Test multiple concurrent requests:

Charles:

```
1. Capture request
2. Right-click → Repeat Advanced
3. Set iterations: 100
4. Set concurrency: 10
5. Monitor server responses
```

Fiddler:

```
1. Capture request
2. Right-click → Clone Session
3. Use Composer to send multiple times
4. OR script automatic repeats
5. Check for rate limiting
```

---

