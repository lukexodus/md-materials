## IPv6 Address Syntax ([2001:db8::1])


IPv6 (Internet Protocol version 6) addresses consist of 128 bits represented as eight groups of four hexadecimal digits, separated by colons. IPv6 was developed to address IPv4 address exhaustion and provides significantly more addresses.

**Basic Structure**:

```
hextet:hextet:hextet:hextet:hextet:hextet:hextet:hextet
```

Each hextet represents 16 bits (4 hexadecimal digits), ranging from 0000 to ffff.

**Full IPv6 Address Format**:

```
2001:0db8:0000:0000:0000:0000:0000:0001
```

**Hexadecimal Representation**:

- Case-insensitive: Both uppercase and lowercase are valid
- Valid characters: 0-9, a-f, A-F
- Each hextet can contain 1 to 4 hexadecimal digits

**IPv6 Address Compression Rules**:

**Leading Zero Suppression**: Leading zeros within each hextet can be omitted:

```
2001:0db8:0000:0042:0000:0000:0000:0001
Compressed: 2001:db8:0:42:0:0:0:1
```

**Zero Compression**: One sequence of consecutive zero hextets can be replaced with double colons (::):

```
2001:0db8:0000:0000:0000:0000:0000:0001
Compressed: 2001:db8::1
```

**Important Compression Constraints**:

- Double colon (::) can appear only once in an address
- Can represent one or more consecutive zero hextets
- Can appear at the beginning, middle, or end of the address

**Compression Examples**:

```
Full:       2001:0db8:0000:0000:0000:0000:0000:0001
Compressed: 2001:db8::1

Full:       2001:0db8:0000:0042:0000:8a2e:0370:7334
Compressed: 2001:db8:0:42:0:8a2e:370:7334
Better:     2001:db8:0:42::8a2e:370:7334

Full:       0000:0000:0000:0000:0000:0000:0000:0001
Compressed: ::1 (loopback address)

Full:       0000:0000:0000:0000:0000:0000:0000:0000
Compressed: :: (unspecified address)
```

**Canonical Form**: RFC 5952 defines rules for representing IPv6 addresses in a consistent, canonical format:

- Use lowercase hexadecimal digits
- Suppress leading zeros in each hextet
- Use :: to compress the longest sequence of consecutive zero hextets
- If multiple sequences of equal length exist, compress the leftmost sequence
- Do not use :: to compress a single zero hextet

**IPv6 Address Types**:

**Unicast Addresses**: Identify a single interface

- Global unicast: 2000::/3 (routable on internet)
- Link-local: fe80::/10 (used on single network segment)
- Unique local: fc00::/7 (private addresses, similar to IPv4 private ranges)

**Multicast Addresses**: ff00::/8 (deliver packets to multiple destinations)

**Anycast Addresses**: Assigned to multiple interfaces; packets delivered to nearest

**Special Addresses**:

- ::1/128: Loopback address (equivalent to 127.0.0.1)
- ::/128: Unspecified address (equivalent to 0.0.0.0)
- ::ffff:0:0/96: IPv4-mapped IPv6 addresses

**Scope Identifiers (Zone IDs)**:

Link-local addresses may include a zone identifier to specify the network interface:

```
fe80::1%eth0
fe80::1%1
```

The zone identifier follows a percent sign (%) and specifies the interface name or index.

