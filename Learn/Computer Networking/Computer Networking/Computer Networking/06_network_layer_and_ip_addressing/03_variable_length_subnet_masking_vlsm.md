## Variable Length Subnet Masking (VLSM)


VLSM extends basic subnetting by allowing different subnet sizes within the same network, optimizing address utilization by matching subnet size to actual requirements.

**VLSM principles:**

- **Hierarchical addressing**: Creates subnet hierarchies within major networks
- **Address conservation**: Allocates only required addresses to each subnet
- **Design flexibility**: Accommodates varying subnet requirements
- **Route summarization**: Enables efficient routing table entries

**VLSM design process:**

1. **Identify requirements**: Determine host count for each subnet
2. **Sort by size**: Arrange subnets from largest to smallest
3. **Allocate addresses**: Assign subnets starting with largest requirements
4. **Avoid overlap**: Ensure subnet ranges don't conflict
5. **Document scheme**: Maintain clear addressing documentation

**Example** of VLSM implementation for 192.168.100.0/24:

- **Subnet A**: 100 hosts required → /25 (126 usable hosts) → 192.168.100.0/25
- **Subnet B**: 50 hosts required → /26 (62 usable hosts) → 192.168.100.128/26
- **Subnet C**: 25 hosts required → /27 (30 usable hosts) → 192.168.100.192/27
- **Point-to-point links**: 2 hosts required → /30 (2 usable hosts) → 192.168.100.224/30

**VLSM advantages:**

- **Address efficiency**: Minimizes wasted addresses
- **Scalability**: Supports network growth and changes
- **Cost effectiveness**: Reduces need for additional address blocks
- **Route optimization**: Enables hierarchical routing structures

**VLSM considerations:**

- **Routing protocol support**: Requires classless routing protocols (OSPF, EIGRP, RIPv2, BGP)
- **Planning complexity**: Requires careful address allocation planning
- **Documentation**: Needs comprehensive addressing documentation
- **Growth planning**: Must consider future expansion requirements

