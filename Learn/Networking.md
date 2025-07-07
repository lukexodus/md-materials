### MAC Address Filtering

MAC address filtering allows administrators to restrict network access to devices based on their Media Access Control (MAC) addresses. Each network interface card (NIC) has a unique MAC address, allowing devices to be identified on the network.

- **How It Works**: Administrators can configure their router to allow or deny access to devices based on their MAC addresses. This is particularly useful for securing a network against unauthorized access.
- **Use Case**: If a device is having trouble connecting to the network, and MAC address filtering is enabled, it's possible the device's MAC address is not allowed. Conversely, if a device is not supposed to access the network, its MAC address can be added to the filter list to block it.

### IP Binding

IP binding is a feature that associates a specific IP address with a MAC address on the router. This means that only the device with the specified MAC address can use the assigned IP address.

- **How It Works**: When a device connects to the network, the router checks if the device's MAC address matches the one bound to the IP address. If they match, the device is granted the IP address; otherwise, it's denied.
- **Use Case**: IP binding is useful for preventing IP spoofing, where a malicious actor tries to impersonate a legitimate device by using its IP address. By binding an IP address to a specific MAC address, administrators can ensure that only authorized devices use that IP address.

### Firewall Rules

Firewall rules define how the router handles incoming and outgoing network traffic based on IP addresses, ports, protocols, and other criteria. These rules can allow, block, or limit traffic.

- **How It Works**: Administrators set up rules to specify which traffic is permitted or denied. For example, a rule might allow incoming traffic on port 80 (HTTP) but block all incoming traffic on port 22 (SSH).
- **Use Case**: Firewalls protect networks from unauthorized access and potential attacks. Misconfigured firewall rules can inadvertently block legitimate traffic, affecting network connectivity.

### Static IP vs. DHCP

- **Static IP**: A static IP address is manually assigned to a device and does not change over time. This is useful for devices that need a constant IP address for reliable operation, such as servers or printers.
  
- **DHCP**: Dynamic Host Configuration Protocol (DHCP) automatically assigns IP addresses to devices from a pool of addresses managed by the router. Devices receive an IP address, subnet mask, default gateway, and DNS servers, which are valid for a limited period.

### DHCP Reservation Feature

A DHCP reservation ensures that a specific device always receives the same IP address from the DHCP server, even if other devices request that IP address. This is useful for devices that rely on a fixed IP address, such as VoIP phones or networked printers.

- **How It Works**: Administrators reserve an IP address for a specific MAC address in the router's DHCP settings. When the device requests an IP address, the DHCP server assigns the reserved IP address to the device's MAC address.
- **Use Case**: DHCP reservations prevent IP conflicts and ensure that critical devices always have a stable IP address, facilitating network management and reducing downtime.
