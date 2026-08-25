## Layer 2 Switching Concepts


Layer 2 switching operates at the Data Link layer of the OSI model, making forwarding decisions based on MAC addresses. Switches learn MAC addresses from incoming frames, store them in the MAC address table (CAM table), and use this information to forward frames only to the appropriate destination port rather than flooding to all ports.

**Frame Forwarding Methods:**

- **Store-and-Forward**: The switch receives the entire frame, performs error checking via CRC (Cyclic Redundancy Check), then forwards it. This method provides error detection but introduces latency.
- **Cut-Through**: The switch reads only the destination MAC address (first 6 bytes after preamble) and immediately begins forwarding. This reduces latency but doesn't check for errors.
- **Fragment-Free**: A hybrid approach that reads the first 64 bytes to detect collision fragments before forwarding.

**Switching Operations:** When a frame arrives, the switch examines the source MAC address and associates it with the ingress port. It then looks up the destination MAC address in its table. If found, the frame is forwarded to that specific port (unicast). If not found, the frame is flooded to all ports except the ingress port (unknown unicast). Broadcast and multicast frames are flooded to all ports in the same VLAN.

**Switch Learning Process:** The MAC address table is dynamically built as frames traverse the switch. Each entry contains the MAC address, associated port, VLAN ID, and a timestamp. Entries age out after 300 seconds (5 minutes) of inactivity by default, though this timer is configurable.

