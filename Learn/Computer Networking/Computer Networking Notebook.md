# Transport Layer Segmentation vs Internet Layer Fragmentation

## Transport Layer Segmentation

**What it is:**
Segmentation occurs at Layer 4 (Transport Layer) where protocols like TCP divide application data into smaller chunks called segments before transmission.

**Key characteristics:**
- Performed by TCP (not UDP - UDP doesn't segment)
- Application data is divided into maximum segment size (MSS) units
- MSS is typically negotiated during TCP connection establishment
- Default MSS is often 1460 bytes (to fit within standard 1500-byte Ethernet MTU)
- Segments are reassembled by the receiving transport layer
- Each segment gets its own TCP header with sequence numbers for ordering and reliability

**Purpose:**
- Efficient transmission within network constraints
- Flow control and congestion control
- Reliable, ordered delivery

## Internet Layer Fragmentation

**What it is:**
Fragmentation occurs at Layer 3 (Internet Layer/Network Layer) where IP divides packets that are too large for the underlying network's Maximum Transmission Unit (MTU).

**Key characteristics:**
- Performed by IP (IPv4 or IPv6)
- Happens when a packet exceeds the MTU of a network link
- Each fragment gets its own IP header
- IPv4: can fragment at any router along the path
- IPv6: fragmentation only at source (routers send "Packet Too Big" ICMP messages instead)
- Fragments are reassembled only at the final destination
- Uses fragment offset, identification field, and flags in IP header

**Purpose:**
- Allow packets to traverse networks with smaller MTUs
- Accommodate varying link-layer technologies

## Key Differences

| Aspect | Segmentation | Fragmentation |
|--------|--------------|---------------|
| **Layer** | Transport (Layer 4) | Internet/Network (Layer 3) |
| **Protocol** | TCP | IP (IPv4/IPv6) |
| **When it occurs** | Before transmission | When packet exceeds MTU |
| **Reassembly location** | Destination transport layer | Destination IP layer |
| **Control** | Sender controls size proactively | Reactive to network constraints |
| **Efficiency** | Generally preferred | Less efficient, avoided when possible |
| **Ordering** | TCP sequence numbers | IP fragment offset |

## Why Segmentation is Preferred

Modern networks typically rely on transport layer segmentation (via Path MTU Discovery) rather than IP fragmentation because:
- Fragmentation at routers adds processing overhead
- Lost fragments require retransmission of entire packet
- Fragments can be blocked by firewalls
- TCP's proactive approach is more efficient than IP's reactive approach