## Path Vector Algorithms


Path vector protocols maintain complete path information including all intermediate autonomous systems traversed to reach destinations. This approach enables sophisticated routing policies based on path attributes and prevents routing loops through path inspection.

Each route advertisement includes the full AS path, preventing routers from selecting paths containing their own AS number. Policy-based routing utilizes path attributes like AS path length, origin type, and local preference for route selection beyond simple metrics.

Route aggregation combines multiple network prefixes into single advertisements, reducing routing table sizes and update overhead. Aggregation policies balance route specificity with scalability requirements. Longest prefix matching ensures accurate forwarding despite aggregated advertisements.

Path attributes enable complex routing policies including traffic engineering, economic routing decisions, and political routing constraints. Communities provide additional policy mechanisms through route tagging. Route reflection and confederation techniques manage full-mesh scaling requirements.

**Key Points:**

- Complete path information prevents loops and enables policy routing
- AS path inspection provides loop prevention without distance limitations
- Route aggregation reduces routing table sizes and update overhead
- Path attributes support sophisticated routing policies beyond simple metrics

