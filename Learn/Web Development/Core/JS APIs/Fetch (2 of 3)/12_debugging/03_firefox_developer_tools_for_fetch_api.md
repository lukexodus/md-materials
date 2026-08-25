## Firefox Developer Tools for Fetch API


### Network Monitor

#### Request Inspection

The Network Monitor displays all fetch requests in a tabular format with columns for status, method, domain, file, cause, type, transferred size, and time. Click any request to open the detailed inspection panel.

The Headers tab shows complete request and response headers. Toggle between Raw and Parsed views to see headers as sent over the wire or in structured format. Click the Edit and Resend button to modify and resubmit the request with different headers, body, or parameters.

#### Request/Response Body Analysis

The Response tab displays the returned data with automatic formatting based on content type. JSON responses are syntax-highlighted and collapsible. The Preview tab renders HTML responses or displays images. For fetch requests, both tabs handle binary data, text, and structured formats.

The Request tab shows the payload sent via fetch's body option. POST, PUT, and PATCH requests display form data, JSON payloads, or raw body content. Use the params tab to view parsed query string parameters.

#### Timing Breakdown

The Timings tab provides granular performance metrics for each fetch request:

- **Blocked**: Time spent in browser queue before connection
- **DNS Resolution**: Time to resolve the domain name
- **Connecting**: TCP handshake duration
- **TLS Setup**: SSL/TLS negotiation time (for HTTPS)
- **Sending**: Time to upload request data
- **Waiting**: Server processing time (TTFB)
- **Receiving**: Time to download response body

These metrics help identify bottlenecks in network performance, particularly useful when optimizing fetch call sequences.

#### Security Analysis

The Security tab shows TLS/SSL certificate details, protocol version, cipher suite, and certificate chain. For fetch requests to HTTPS endpoints, verify certificate validity and security posture. Warning indicators appear for weak cryptography or certificate issues.

#### Filtering and Search

Filter requests by type (XHR, Fetch, WS), domain, or status code using the filter bar. The search function highlights matching requests across URL, headers, and body content. Use negative filters with `-fetch` to exclude fetch requests when debugging other network activity.

#### Request Blocking

Right-click any fetch request and select "Block URL" to prevent that specific endpoint from loading. Useful for testing error handling, offline scenarios, or removing third-party dependencies during development. Manage blocked patterns in the Network Monitor settings.

### Console Integration

#### Fetch Request Logging

The Console automatically logs fetch requests when they initiate. Each entry shows the HTTP method, URL, and returns a Promise object. Click the Promise disclosure triangle to inspect its resolved value once the fetch completes.

```javascript
// Console displays:
// Promise { <state>: "fulfilled", <value>: Response }
```

Expand the Response object to examine status, headers, body, and other properties directly in the Console.

#### Network Log Persistence

Enable "Persist Logs" to retain network activity across page navigations. Essential when debugging fetch calls that trigger redirects or occur during page transitions. The Console preserves both logged fetch requests and their responses.

#### CORS Error Details

When fetch encounters CORS issues, the Console displays detailed error messages identifying the specific header or configuration problem. Unlike the Network Monitor (which may show the request succeeded at the network level), the Console reveals JavaScript-level CORS blocking with actionable error messages.

### Debugger

#### Breakpoint on Fetch

Set breakpoints in code that calls fetch to pause execution before the request initiates. Inspect variables containing URLs, headers objects, and request options. Step through async/await or Promise chains to trace fetch behavior.

#### XHR/Fetch Breakpoints

Enable "Pause on any URL" in the Debugger's Breakpoints panel to halt execution on all fetch calls automatically. Filter by URL pattern to break only on specific endpoints. This feature intercepts requests without modifying source code.

#### Async Stack Traces

The Debugger maintains call stacks across async boundaries. When a fetch Promise rejects or throws, trace back through await points to identify the originating call site. Enable "Show Async Stack Traces" in Debugger settings for complete execution history.

#### Source Mapping

When using bundlers or transpilers, Firefox maps minified fetch calls back to original source files. Set breakpoints in TypeScript or ES6+ source code that compiles to fetch calls, and the Debugger resolves them correctly.

### Storage Inspector

#### Cache Storage Inspection

Navigate to the Storage tab and expand "Cache Storage" to view Service Worker caches populated by fetch requests. Each cache entry shows the request URL, response status, and stored data. Right-click entries to delete individual cached responses.

The Storage Inspector displays cache metadata including creation time and size. Useful for verifying fetch requests utilize caching strategies correctly, especially when implementing offline-first applications.

#### IndexedDB and Fetch

When fetch responses are stored in IndexedDB, inspect the database structure, object stores, and individual entries. The Storage Inspector provides a tree view of all databases, with expandable records showing stored response data from fetch calls.

### Performance Tools

#### Profiler Analysis

Record a performance profile while executing fetch requests to identify JavaScript execution costs. The Profiler shows time spent in fetch initialization, response parsing (JSON, text, blob methods), and promise chain resolution.

Flame charts reveal whether fetch-related code blocks the main thread. Look for long bars representing synchronous response processing that should be optimized or moved off-thread.

#### Network Waterfall

The Performance panel's network waterfall visualizes fetch request timing alongside JavaScript execution, rendering, and other browser activities. Identify whether network requests are serialized unnecessarily or if request queueing causes delays.

Color-coded bars distinguish fetch requests from other resource types. Overlapping bars indicate parallel requests, while sequential patterns suggest opportunities for request optimization or resource bundling.

#### Memory Profiling

Use the Memory tool to detect leaks from fetch-related objects. Take heap snapshots before and after fetch operations to identify retained Response objects, unread streams, or abandoned promise chains. Filter by "Response" or "ReadableStream" to isolate fetch-related allocations.

### Network Throttling

Access throttling presets (3G, 4G, WiFi) or create custom profiles in the Network Monitor settings. Test fetch behavior under constrained bandwidth and high latency to validate timeout handling, progress indicators, and retry logic.

Throttling applies to all network requests including fetch, allowing realistic testing of mobile network conditions. Combine with offline mode to simulate complete network failure and verify error handling.

### Request Context Menu

Right-click any fetch request in the Network Monitor to access:

- **Copy as cURL**: Generate command-line equivalent with headers
- **Copy as Fetch**: Create JavaScript fetch code replicating the request
- **Open in New Tab**: Execute the request in a browser tab
- **Resend**: Replay the exact request without modification
- **Block URL**: Prevent this endpoint from loading

The "Copy as Fetch" option generates code including headers, method, and body, useful for replicating requests in different contexts or sharing with team members.

### HAR Export

Export network activity as HTTP Archive (HAR) format from the Network Monitor. HAR files contain complete request/response data for all fetch calls, enabling offline analysis, performance auditing, or sharing with external tools.

Import HAR files back into Firefox to replay network sessions and compare performance across different builds or network conditions.

### Response Override

Use the "Edit and Resend" feature to modify fetch responses during development. Change response status codes, headers, or body content to test error handling without requiring server changes. Useful for simulating edge cases like rate limiting, authentication failures, or partial content delivery.

### WebSocket and Fetch API Integration

While WebSockets appear separately, the Network Monitor's unified view helps debug applications using both fetch and WebSocket connections. Filter between technologies to isolate specific communication patterns or verify fallback mechanisms from WebSocket to HTTP fetch.

### Developer Tools Settings

Configure Network Monitor behavior in Settings (F1):

- **Disable Cache**: Force fresh fetch requests on every load
- **Throttling**: Set default throttling profile
- **Enable persistent logs**: Retain requests across navigation
- **Show original size**: Display pre-compression response sizes

These settings apply globally to all tabs and persist across browser sessions.

---

