## Network Topologies


### Bus Topology

All devices connect to a single central cable (backbone). Data travels along the backbone until it reaches the intended recipient.

**Advantages:**

- Cost-effective for small networks
- Easy to implement and extend
- Requires less cable than other topologies

**Disadvantages:**

- Single point of failure (backbone)
- Performance degrades with more devices
- Difficult to troubleshoot
- Limited cable length

### Star Topology

All devices connect to a central hub or switch. All communication passes through the central device.

**Advantages:**

- Easy to install and manage
- Failure of one device doesn't affect others
- Easy to detect faults
- Good performance

**Disadvantages:**

- Central device is single point of failure
- Requires more cable than bus topology
- Limited by central device capabilities

### Ring Topology

Devices connect in a circular fashion, with each device connected to exactly two others, forming a ring.

**Advantages:**

- Equal access for all devices
- No collisions (in token ring)
- Predictable performance

**Disadvantages:**

- Single device failure can break entire network
- Difficult to troubleshoot
- Adding/removing devices requires network disruption

### Mesh Topology

Every device connects directly to every other device in the network.

**Full Mesh:**

- Every device connects to every other device
- Provides maximum redundancy and fault tolerance
- Expensive and complex to implement

**Partial Mesh:**

- Some devices connect to multiple others
- Balance between redundancy and cost
- More practical for larger networks

**Advantages:**

- High redundancy and fault tolerance
- Multiple paths for data transmission
- No single point of failure

**Disadvantages:**

- Expensive to implement
- Complex configuration and management
- Requires many connections (n(n-1)/2 for full mesh)

### Hybrid Topology

Combines two or more different topologies to meet specific network requirements.

**Example:** Star-bus hybrid where multiple star networks connect via a bus backbone.

**Advantages:**

- Flexible design
- Can optimize for specific needs
- Scalable

**Disadvantages:**

- Complex design and management
- Expensive to implement
- Difficult to troubleshoot

