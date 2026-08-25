## Chrome DevTools Features for Fetch API


### Network Panel Core Features

#### Request Filtering and Inspection

The Network panel provides dedicated filtering for fetch/XHR requests through the resource type buttons in the filter bar. Multiple type filters can be selected simultaneously by holding Control (Windows/Linux) or Command (Mac) while clicking. The panel displays all network activity in the Network Log, with each row representing a resource request.

Request details are accessible by clicking any entry in the Network Log. The interface provides multiple tabs for examining different aspects of each request:

- **Headers tab**: Displays HTTP request/response headers, general information including status codes with human-readable descriptions, and the complete header chain
- **Preview tab**: Renders basic HTML or displays formatted JSON responses, particularly useful when APIs return errors in HTML format
- **Response tab**: Shows raw response content with a Format button for minified content readability
- **Initiator tab**: Presents a tree visualization of the request initiator chain, showing what triggered the request and what resources it initiated
- **Timing tab**: Breaks down network activity timing for the resource, showing phases like DNS lookup, connection establishment, waiting time, and content download

#### Request Information Columns

The Network Log displays comprehensive information across multiple columns (customizable via right-click on header):

- **Name**: Resource filename or identifier
- **Status**: HTTP status code (200, 404, etc.) or error states like CORS failures and blocked requests
- **Type**: MIME type of the requested resource
- **Initiator**: Object or process that initiated the request (Parser, Redirect, Script, Other)
- **Size**: Combined size of response headers and body, with uncompressed size when using big request rows
- **Time**: Total duration from request start to final byte receipt
- **Waterfall**: Visual breakdown of request activity phases
- **Priority**: Both initial (bottom value) and final (top value) fetch priority when using big request rows
- **Protocol**: HTTP protocol version used (h2, h3, http/1.1)
- **Domain**: Request domain
- **Path**: Request path
- **Method**: HTTP method used
- **Remote Address**: Server IP address
- **Connection ID**: Identifies which server connection was used

#### Advanced Filtering

The filter bar supports multiple filtering methods:

**Property-based filters** use syntax like `domain:`, `status-code:`, `method:`, `mime-type:`, `has-response-header:`, `set-cookie-value:`, and `url:`. DevTools provides autocomplete suggestions populated from encountered values.

**Regular expression filters** enable complex pattern matching. For example, `/css|woff2/` shows both CSS and font files.

**Time-range filtering** involves dragging left or right on the Overview timeline to display only requests active during the selected timeframe.

**Extension URL filtering** can be enabled through the "Hide extension URLs" option in the More filters dropdown, preventing requests to `chrome-extension://` URLs from cluttering the view.

#### Search Capabilities

The Network panel includes full-text search across all request response bodies. Accessing search involves clicking the magnifying glass icon to the left of "Preserve log." Search supports regular expressions and provides a list of matches across all captured requests.

The "Copy" submenu accessible via right-click on any request provides search-related options to find all instances of specific headers, cookies, or response content patterns.

### Request Replication and Export

#### Copy Request Options

Right-clicking any request in the Network Log and hovering over "Copy" provides multiple options for replicating requests:

**Copy as fetch**: Generates browser-compatible fetch API code including all headers, referrer policy, body, method, mode, and credentials. The generated code can be executed directly in the DevTools Console.

**Copy as fetch (Node.js)**: Similar to standard fetch but includes the cookie header, essential for Node.js environments where cookies aren't automatically managed.

**Copy as cURL**: Generates a cURL command that can be executed in terminal environments, useful for sharing requests with backend developers or testing outside the browser.

**Copy as PowerShell**: Creates PowerShell-compatible request code for Windows environments.

**Copy URL**: Copies the request URL to clipboard.

**Copy response**: Copies the complete response body to clipboard.

**Copy stack trace**: Copies the request's stack trace to clipboard, showing the call chain that led to the request.

#### Batch Export Options

The "Copy" submenu also provides bulk operations for exporting multiple requests:

**Copy all as fetch (Node.js)**: Generates a chain of Node.js fetch calls for all filtered requests.

**Copy all as cURL**: Creates a chain of cURL commands for all filtered requests.

**Copy all as PowerShell**: Generates PowerShell commands for all filtered requests.

**Copy all URLs**: Copies URLs of all filtered requests to clipboard.

#### HAR File Export and Import

The Network panel supports exporting network activity as HAR (HTTP Archive) files, a JSON-based format used by HTTP session tools:

**Export options**:
- Click the Export HAR button in the action bar
- Right-click any request and select "Copy > Save all as HAR (sanitized)" or "Save all as HAR (with sensitive data)"
- Sanitized exports exclude Cookie, Set-Cookie, and Authorization headers by default

**Import capabilities**:
- Drag-and-drop HAR files directly into the Requests table
- Click the Import HAR button in the action bar
- The Network panel reads and displays initiators for imported requests

HAR files contain complete request/response data including headers, timing information, content, and the full waterfall breakdown. They're valuable for sharing debugging information with team members or support personnel who can then analyze the captured data in their own DevTools instance.

### Request Overriding and Mocking

#### Local Overrides System

Chrome DevTools (since version 117) enables overriding both web content and HTTP response headers for fetch/XHR requests without requiring access to backend servers. This functionality requires setting up a local folder where DevTools stores override files.

**Setup process**:
1. Navigate to Network panel
2. Right-click a request
3. Select "Override content" or "Override headers"
4. Select a folder to store override files when prompted
5. Grant DevTools access permissions

Once configured, DevTools saves modified files and serves them instead of the actual network responses on subsequent page loads. The system works by intercepting requests and checking if an override exists before fetching from the network.

#### Content Overriding

After selecting "Override content" for a fetch/XHR request, DevTools automatically:
- Opens the Sources > Overrides > Editor panel
- Creates a local file with the current response content
- Enables the override system if it was disabled

Developers can then edit the response content directly in the Sources panel. Changes are saved with Ctrl+S (Windows/Linux) or Cmd+S (Mac), and subsequent requests to the same URL receive the modified content.

Overridden resources are indicated with a purple icon in the Network panel. Hovering over this icon displays what's been overridden. The Response tab also shows a purple dot icon with a tooltip for requests with overridden content.

#### Response Header Overriding

Response header overrides work similarly but focus on modifying HTTP headers without changing response content. This is valuable for testing scenarios like:
- Changing Cache-Control headers to simulate different caching policies
- Adjusting Access-Control-Allow-Origin for CORS testing
- Modifying Content-Security-Policy headers for security testing
- Testing different Content-Type or Content-Encoding values

Headers can be edited by:
1. Opening the Headers tab for a request
2. Hovering over a response header value
3. Clicking the Edit button that appears
4. Modifying the value and saving

#### Override Management

The Sources > Overrides panel provides centralized management:
- Lists all override files in a tree structure
- Allows enabling/disabling overrides via checkbox
- Provides "Clear" button to delete all overrides
- Supports deleting individual override files or folders via right-click

The Changes drawer tab tracks all modifications made to web content in one location, showing exactly what changed between the original and overridden versions.

### Network Throttling

#### Global Throttling Profiles

The Network panel includes throttling capabilities to simulate degraded network conditions. The Throttling dropdown (set to "No throttling" by default) provides preset profiles:

- **Slow 3G**: 400 Kbps download, 400 Kbps upload, 2000ms minimum latency
- **Fast 3G**: 1.6 Mbps download, 750 Kbps upload, 562.5ms minimum latency
- **Slow 4G**: 4 Mbps download, 3 Mbps upload, 165ms minimum latency
- **Fast 4G**: 9 Mbps download, 9 Mbps upload, 85ms minimum latency
- **Offline**: Completely blocks network connectivity

Custom profiles can be created by:
1. Selecting "Custom" from the throttling dropdown
2. Configuring download/upload throughput (bytes/sec)
3. Setting latency (milliseconds)
4. Optionally specifying packet loss percentage for WebSocket connections

When throttling is enabled, a warning triangle appears on the Network panel tab with a tooltip indicating network modification is active.

#### Throttling Characteristics

[Inference] DevTools throttling uses request-level implementation rather than connection-level simulation. This means:
- The initial connection establishes at normal speed
- Response times are artificially delayed to simulate slower connections
- The minimum response time (TTFB) is extended to compensate for the fast initial connection
- Subsequent requests on the same connection are slowed proportionally

This approach differs from actual slow networks but provides reasonable approximation for testing purposes. For accurate testing, the connection cache should be cleared between loads.

#### Individual Request Throttling

Chrome 144 introduced Individual Request Throttling through the Request conditions drawer. This feature allows applying specific network conditions to individual requests rather than globally throttling all traffic.

**Usage**:
1. Right-click any request in the Network panel
2. Select "Throttle request" or "Block request"
3. Choose to apply to the exact URL or entire domain
4. Select a throttling profile (standard presets or custom)
5. DevTools automatically opens Request conditions drawer and applies the constraint

**Visual indicators**:
- Throttled requests display in yellow/gold with a clock icon in the Time column
- Hovering over the clock icon shows the applied network condition
- The Timings sub-panel displays throttling details
- A warning icon appears on the Network panel tab when requests are being modified

**Request conditions management**:
- URL patterns support wildcards (*) for matching dynamic resources
- Multiple patterns can be created
- When a request matches multiple patterns, the first rule is applied
- Individual rules can be enabled/disabled without deletion

#### WebSocket Throttling

Network throttling extends to WebSocket connections (since Chrome 99). Testing involves:
1. Establishing a WebSocket connection with throttling disabled
2. Sending a message and noting the timing
3. Creating a slow custom throttling profile (e.g., 10 kbit/s)
4. Applying throttling and sending another message
5. Comparing message round-trip times in the Messages tab under the WS filter

#### Network Conditions Drawer

The Network conditions drawer provides an alternative interface for throttling accessible from other DevTools panels. Opening it involves clicking the network conditions icon or running "Show Network Conditions" from the Command Menu.

Beyond throttling, this drawer enables:
- User-Agent string customization affecting both the User-Agent HTTP header and `navigator.userAgent` value
- Network connectivity simulation
- Testing with predefined browser User-Agent strings

### Request Blocking

#### Block Request Functionality

DevTools provides request blocking to test application behavior when specific resources are unavailable. The feature is accessible through:

**Command Menu method**:
1. Press Control+Shift+P or Command+Shift+P (Mac)
2. Type "block"
3. Select "Show Request Blocking"
4. Click "Add Pattern"
5. Enter URL pattern (supports wildcards)

**Network panel method**:
1. Right-click any request
2. Select "Block request URL" or "Block request domain"
3. DevTools opens Request conditions drawer with the block rule created

Blocked requests appear in red in the Network Log with status "(blocked:devtools)" in the Status column. This helps identify which resources failed due to blocking rather than actual network issues.

Request blocking patterns support wildcards for flexible matching:
- `*.js` blocks all JavaScript files
- `*/analytics/*` blocks paths containing "analytics"
- `https://example.com/*` blocks all requests to a domain

### Timing and Performance Analysis

#### Waterfall Visualization

The Waterfall column provides visual breakdown of network request phases, color-coded by activity type:

**Connection phases** (visible on first request to a domain):
- DNS Lookup (resolving IP address)
- Initial connection (TCP handshakes, SSL negotiation)
- Proxy negotiation (if applicable)

**Request/response phases**:
- Queueing (waiting for available connection)
- Stalled (delayed after connection start)
- Request sent
- Waiting (TTFB - Time To First Byte)
- Content Download

**Service Worker phases**:
- ServiceWorker Preparation (starting up worker)
- Request to ServiceWorker (sending request to worker)

Hovering over the waterfall bar displays detailed timing breakdown with millisecond precision for each phase. The total time is displayed in the Time column.

#### Priority Tracking

The Priority column (visible with Big request rows enabled) displays both initial and final fetch priority. This helps identify when browser changes request priority during loading:

- Initial Priority (bottom value): The priority assigned when the request was initiated
- Final Priority (top value): The priority when the request completed

[Inference] Priority changes can occur based on factors like resource type discovery, viewport visibility, and browser heuristics. Monitoring priority changes helps optimize resource loading order and identify opportunities for using the Fetch Priority API's `fetchpriority` attribute.

#### Performance Integration

The Performance panel's Network track shows network requests alongside other performance metrics. This provides context about how network activity relates to:
- JavaScript execution
- Rendering and painting
- User interactions
- Core Web Vitals

Network requests in the Performance track display the same priority information as the Network panel, enabling correlation between fetch priority and overall page performance.

### EventStream and Server-Sent Events

#### EventStream Tab

The Network panel includes an EventStream tab for debugging Server-Sent Events (SSE) and streams from Fetch API and EventSource API. This tab appears when viewing requests that stream events.

**Features**:
- Displays events in real-time as they arrive
- Shows event type and data for each event
- Includes filtering capability via regular expression filter bar
- Provides "Clear" button to reset captured events
- Updates live during active connections

**Limitations** [Unverified]:
- The EventStream tab only populates when using native EventSource API
- Polyfills or custom fetch-based SSE implementations may not populate the tab
- Third-party Chrome extensions like "SSE Viewer" can provide additional EventStream debugging for fetch-based implementations

#### Server-Sent Events Debugging

When debugging SSE connections:

1. Record network requests while events are streaming
2. Locate the SSE request in the Network Log (typically shows `text/event-stream` content type)
3. Click the request to open details
4. Select the EventStream tab to view messages

The Headers tab displays the SSE-specific headers:
- `Content-Type: text/event-stream`
- Connection headers indicating persistent connection
- Cache-Control headers (typically set to no-cache for SSE)

The Timing tab shows the persistent connection duration, which remains open as long as the SSE connection is active.

### WebSocket Debugging

#### WebSocket Request Inspection

WebSocket connections appear in the Network Log with type "WS (WebSocket)". The WS filter button enables showing only WebSocket traffic.

**Connection details**:
- Status column shows 101 (Switching Protocols) for successful WebSocket upgrades
- Headers tab displays the WebSocket handshake including Upgrade and Connection headers
- The Sec-WebSocket-* headers show protocol negotiation details

#### Messages Tab

The Messages tab (available for WebSocket requests) displays bidirectional communication:
- Shows each message with timestamp
- Indicates message direction (sent/received)
- Displays message payload (text or binary)
- Color-codes messages for visual distinction
- Provides length information for each message

Messages can be filtered using the filter bar within the Messages tab, supporting regular expressions for complex filtering needs.

### Initiator Chain Visualization

#### Request Initiator Information

The Initiator column and tab provide critical information about what caused each request:

**Initiator types**:
- **Parser**: Chrome's HTML parser encountered a resource reference
- **Redirect**: HTTP redirect initiated the request
- **Script**: JavaScript function triggered the request
- **Preload**: Resource hint (preload, prefetch) initiated the request
- **Other**: User action like clicking a link or entering URL

For script-initiated requests (including fetch calls), clicking the initiator link opens the Sources panel at the exact line of code that made the request. Hovering displays the full call stack leading to the request.

#### Initiator Chain Tree

The Initiator tab presents a nested tree view showing:
- Resources above the inspected request that initiated it (green highlight)
- Resources below the inspected request that it initiated (red highlight)
- The inspected resource in bold

This visualization helps understand request dependencies and loading sequences, crucial for optimizing resource loading and identifying unnecessary cascading requests.

#### Shift+Hover Visualization

Holding Shift while hovering over any request in the Network Log highlights:
- The request's initiator in green
- Requests it initiated in red

This provides quick visual understanding of request relationships without opening the Initiator tab.

### Chrome DevTools Protocol Access

#### Programmatic Network Access

The Chrome DevTools Protocol (CDP) provides programmatic access to network data through the Fetch and Network domains:

**chrome.devtools.network API** (for extensions):
- `getHAR()`: Returns complete HAR log of all network requests
- `onRequestFinished`: Event fired when requests complete with HAR entry data
- `onNavigated`: Event fired on page navigation

**CDP Fetch domain** enables:
- Request interception and modification
- Response body retrieval
- Authentication handling
- Request patterns for selective interception

**CDP Network domain** provides:
- `Network.enable`: Start capturing network events
- `Network.setBlockedURLs`: Block specific URLs
- `Network.replayXHR`: Replay XMLHttpRequest with identical parameters
- `Network.emulateNetworkConditions`: Programmatic throttling
- `Network.searchInResponseBody`: Search response content

#### Protocol Monitor

The Protocol monitor (Settings > Experiments > Protocol Monitor) displays all CDP requests and responses made by DevTools. This helps developers:
- Understand how DevTools uses CDP internally
- Debug CDP-based tools and extensions
- Learn CDP command syntax and parameters

The Protocol monitor includes a command editor (Chrome 117+) that:
- Suggests CDP commands as you type
- Displays parameter documentation and types
- Provides structured form for editing parameters
- Supports sending commands via button or Ctrl/Cmd+Enter

### Network Log Persistence

#### Preserve Log Setting

The "Preserve log" checkbox prevents clearing the Network Log during page navigations. When enabled:
- Requests from previous pages remain visible
- New requests are appended rather than replacing existing entries
- Navigation boundaries are indicated in the log

This is essential for debugging:
- Form submissions that redirect
- Multi-step authentication flows
- POST-redirect-GET patterns
- Cross-page resource loading issues

#### Recording Control

The Network panel includes a record button (red circle) that controls whether network activity is captured. When recording is paused:
- No new requests appear in the Network Log
- Existing requests remain visible
- The button turns gray to indicate inactive state

Recording automatically starts when DevTools opens and typically remains enabled. Manual control is useful for:
- Reducing clutter when only specific requests matter
- Preserving a specific set of requests for comparison
- Managing performance impact of logging large numbers of requests

### Status Code and Error Handling

#### Enhanced Status Display

The Status column and Headers > General section display HTTP status codes with human-readable descriptions. For example:
- `200 OK`
- `404 Not Found`
- `500 Internal Server Error`
- `301 Moved Permanently`

Hovering over status codes in the Network Log displays the same descriptive text, improving comprehension without opening request details.

#### Error State Indicators

Beyond standard HTTP status codes, the Network panel indicates various error states:

**(blocked:origin)**: CORS policy blocked the request. The Console displays specific CORS error messages with the Access-Control-* headers involved.

**(blocked:devtools)**: Request blocked by DevTools request blocking or Request conditions.

**(blocked:client)**: Browser blocked the request (e.g., Content Security Policy violation, mixed content, etc.).

**(failed)**: Network failure occurred (connection refused, DNS failure, etc.).

**Provisional headers warning**: The Headers tab may show "Provisional headers are shown..." indicating:
- Request served from cache without network access (headers may be incomplete)
- Invalid network resource attempted
- Request hasn't been sent yet

#### CORS Debugging

For CORS errors, the Console provides detailed information including:
- The specific CORS policy violation
- Expected vs. actual Access-Control-* headers
- Origin that was rejected
- Credentials mode that caused the issue

The Network panel's Headers tab displays both the request's Origin header and the response's Access-Control-* headers, enabling verification of proper CORS configuration.

### Response Content Analysis

#### Content Type Handling

The Response tab handles different content types appropriately:

**JSON responses**: DevTools detects JSON including subtypes (application/ld+json, application/hal+json) and provides:
- Syntax highlighting
- Collapsible tree structure for objects/arrays
- Pretty-print formatting button

**HTML responses**: Shows source code with syntax highlighting and provides format button for minified content.

**Binary responses**: Displays hex dump or indicates binary content that cannot be rendered as text.

**Images**: The Preview tab renders images at actual size with dimensions displayed.

**Fonts**: Preview tab shows font name and basic specimen.

#### Content Size Information

The Size column displays two values (in big request rows mode):
- **Top value**: Transferred size including compression and headers
- **Bottom value**: Uncompressed content size

This distinction helps identify:
- Compression effectiveness (comparing compressed vs. uncompressed size)
- Header overhead (difference between transferred and content size)
- Cache behavior (displays "from cache" instead of size for cached resources)

The Network panel footer displays total transferred size and total resource count, updating as requests complete.

### Advanced Features

#### Connection Information

The Connection ID column identifies which TCP/HTTP connection was used for each request. This information helps:
- Verify connection reuse (same ID across multiple requests)
- Identify connection limits being reached (max 6 connections per domain for HTTP/1.1)
- Optimize for HTTP/2 multiplexing (h2 protocol allows unlimited concurrent requests per connection)

#### Screenshots Timeline

The Screenshots feature captures how the page appears at different loading stages:

**Enabling screenshots**:
1. Click Network Settings (gear icon)
2. Enable Screenshots checkbox
3. Reload the page

**Using screenshots**:
- Click any screenshot thumbnail to see network state at that moment
- A yellow line appears in the waterfall showing the screenshot timing
- Helps correlate visual rendering with specific network requests
- Useful for identifying render-blocking resources

#### Frame Grouping

When pages use iframes extensively, the "Group by frame" setting organizes requests by their originating frame. Enabling this option:
1. Open Network Settings
2. Check "Group by frame"
3. Requests are organized under frame headers in the Network Log

This organization clarifies which frame generated each request, valuable for debugging complex applications using multiple iframes.

#### Request Replay

The Network domain's `replayXHR` CDP method enables replaying XHR requests with identical parameters (method, URL, body, headers, credentials). This is valuable for:
- Testing server response variations
- Debugging intermittent issues
- Verifying fixes without page reload

[Unverified] The Network panel UI doesn't expose replay functionality directly, but extensions or CDP-based tools can implement this feature using the protocol.

### Performance Considerations

#### Big Request Rows

The "Big request rows" setting (Network Settings > Big request rows) increases row height to display additional information:
- Both transferred and uncompressed sizes in Size column
- Both initial and final priorities in Priority column
- More whitespace for improved readability

This setting improves information density at the cost of requiring more scrolling for long request lists.

#### Overview Timeline

The Overview timeline at the top of the Network panel provides visual summary of:
- Request loading sequence over time
- DOMContentLoaded event (blue vertical line)
- Load event (red vertical line)
- Request density and timing patterns

This visualization helps identify:
- Periods of network congestion
- Gaps where no requests are active
- Front-loaded vs. spread-out loading patterns

The Overview can be hidden via Network Settings > Show overview checkbox to reclaim vertical space.

#### Resource Timing API

[Inference] The Network panel's timing information is based on the Resource Timing API (window.performance.getEntriesByType('resource')). This means:
- Timing accuracy matches the API's precision (millisecond resolution)
- Same data is accessible programmatically via JavaScript
- Performance marks and measures integrate with network timing

Developers can access programmatic timing data that correlates with DevTools display, enabling automated performance monitoring that matches DevTools measurements.

---

