## Classful and Classless Addressing


IPv4 addressing evolved from a rigid classful system to a flexible classless system to address inefficient address allocation and accommodate diverse network requirements.

**Classful addressing system:** The original IPv4 addressing scheme divided addresses into five classes based on the first octet values, with predetermined network and host portions.

**Class A networks:**

- **Range**: 1.0.0.0 to 126.0.0.0
- **Default mask**: 255.0.0.0 (/8)
- **Network bits**: 8 bits
- **Host bits**: 24 bits
- **Networks available**: 126 (excluding 0 and 127)
- **Hosts per network**: 16,777,214

**Class B networks:**

- **Range**: 128.0.0.0 to 191.255.0.0
- **Default mask**: 255.255.0.0 (/16)
- **Network bits**: 16 bits
- **Host bits**: 16 bits
- **Networks available**: 16,384
- **Hosts per network**: 65,534

**Class C networks:**

- **Range**: 192.0.0.0 to 223.255.255.0
- **Default mask**: 255.255.255.0 (/24)
- **Network bits**: 24 bits
- **Host bits**: 8 bits
- **Networks available**: 2,097,152
- **Hosts per network**: 254

**Class D and E:**

- **Class D**: 224.0.0.0 to 239.255.255.255 (multicast)
- **Class E**: 240.0.0.0 to 255.255.255.255 (experimental)

**Classless Inter-Domain Routing (CIDR):** CIDR eliminated the rigid class boundaries, allowing more efficient address allocation through variable-length subnet masks. Introduced in 1993, CIDR uses prefix notation to indicate network size.

**CIDR benefits:**

- **Efficient allocation**: Assigns address blocks matching actual requirements
- **Route aggregation**: Combines multiple routes into single routing table entries
- **Reduced routing table size**: Minimizes memory and processing requirements
- **Flexible subnetting**: Enables custom subnet sizes regardless of class boundaries

**Examples** of CIDR allocations:

- /22 network: 1,024 host addresses (4 Class C equivalents)
- /20 network: 4,096 host addresses (16 Class C equivalents)
- /30 network: 4 host addresses (point-to-point links)

