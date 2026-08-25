## Internet Control Message Protocol (ICMP)


ICMP provides error reporting and diagnostic functionality for IP networks. Error messages indicate unreachable destinations, time exceeded conditions, and parameter problems. Diagnostic messages support network troubleshooting through echo requests and replies.

Destination unreachable messages specify various conditions: network unreachable, host unreachable, protocol unreachable, and port unreachable. Time exceeded messages occur when TTL values reach zero or fragment reassembly timers expire.

Ping utilities utilize ICMP echo requests to test connectivity and measure round-trip times. Traceroute tools leverage TTL manipulation and ICMP time exceeded messages to discover network paths.

Path MTU discovery uses ICMP fragmentation needed messages to determine maximum packet sizes for efficient transmission without fragmentation.

**Key Points:**

- Error reporting enables network problem diagnosis
- Echo request/reply supports connectivity testing
- TTL manipulation reveals network topology
- Path MTU discovery optimizes packet sizing

