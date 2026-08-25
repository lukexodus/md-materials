## IPv4 Addressing and Subnetting


IPv4 (Internet Protocol version 4) uses 32-bit addresses to uniquely identify devices on networks. These addresses are typically expressed in dotted decimal notation, dividing the 32 bits into four 8-bit octets separated by periods.

**IPv4 address structure:**

- **32-bit binary address**: Provides approximately 4.3 billion unique addresses
- **Dotted decimal notation**: Four octets ranging from 0 to 255 (e.g., 192.168.1.1)
- **Network and host portions**: Address divided into network identifier and host identifier
- **Subnet mask**: Determines boundary between network and host portions

**Subnetting fundamentals:** Subnetting divides a single network into multiple smaller subnetworks, improving network organization, security, and efficiency. The subnet mask uses binary 1s to represent the network portion and binary 0s for the host portion.

**Subnet mask formats:**

- **Decimal notation**: 255.255.255.0 (24-bit network mask)
- **CIDR notation**: /24 (indicating 24 network bits)
- **Binary representation**: 11111111.11111111.11111111.00000000

**Subnetting calculations:**

- **Number of subnets**: 2^n (where n = borrowed host bits)
- **Hosts per subnet**: 2^h - 2 (where h = remaining host bits, minus 2 for network and broadcast addresses)
- **Subnet increment**: 256 - subnet mask value in relevant octet

**Example** of subnetting 192.168.1.0/24 into 4 subnets:

- Original network: 192.168.1.0/24 (256 host addresses)
- Borrow 2 host bits: Creates /26 subnets (64 host addresses each)
- Resulting subnets: 192.168.1.0/26, 192.168.1.64/26, 192.168.1.128/26, 192.168.1.192/26

**Special IPv4 addresses:**

- **Network address**: First address in subnet (host bits all 0)
- **Broadcast address**: Last address in subnet (host bits all 1)
- **Loopback**: 127.0.0.0/8 for local testing
- **Private addresses**: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
- **Automatic Private IP Addressing (APIPA)**: 169.254.0.0/16

