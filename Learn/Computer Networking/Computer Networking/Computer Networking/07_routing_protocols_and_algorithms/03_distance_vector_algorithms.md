## Distance Vector Algorithms


Distance vector algorithms share routing information by advertising distance metrics to known destinations with directly connected neighbors. Each router maintains distance measurements to all reachable networks and periodically broadcasts this information. Routers calculate best paths using received advertisements and update their routing tables accordingly.

The Bellman-Ford algorithm forms the mathematical foundation for distance vector protocols. Routers iteratively improve path estimates by comparing current distances with newly received advertisements. Convergence occurs when no further improvements are possible across all routers.

Split horizon prevents routing loops by prohibiting route advertisements back through the interface where routes were learned. Poison reverse enhances this by explicitly advertising unreachable destinations with infinite metrics to neighbors. Hold-down timers delay route updates after detecting failures to prevent instability.

Counting to infinity problems arise when routing loops cause metric values to increase indefinitely. Maximum metric limits bound this behavior, typically setting infinity at 16 hops. Triggered updates immediately advertise topology changes rather than waiting for periodic intervals.

**Key Points:**

- Routers share distance information with immediate neighbors only
- Bellman-Ford algorithm provides mathematical convergence foundation
- Loop prevention requires split horizon and poison reverse mechanisms
- Counting to infinity necessitates maximum metric limitations

