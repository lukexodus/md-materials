## IP Addresses as Hosts


IP addresses can serve directly as host components in URIs, providing numeric addressing that bypasses domain name resolution. Both IPv4 and IPv6 address formats are supported with distinct syntax rules.

**IPv4 Address Format:**

IPv4 addresses appear in dotted-decimal notation consisting of four decimal octets separated by periods. Each octet represents 8 bits and ranges from 0 to 255. Valid examples include `192.168.1.1`, `10.0.0.1`, `172.16.254.1`, and `8.8.8.8`.

**IPv4 URI Examples:**

```
http://192.168.1.1/admin
https://10.0.0.50:8443/api
ftp://172.16.0.100/files
```

**IPv4 Syntax Constraints:**

The IPv4 address must contain exactly four octets. Each octet must be a decimal number without leading zeros (with the exception of the single digit `0`). Octet values exceeding 255 create invalid addresses. Spaces or other characters within the address are not permitted.

**IPv6 Address Format:**

IPv6 addresses use hexadecimal notation with eight 16-bit groups separated by colons. The address `2001:0db8:85a3:0000:0000:8a2e:0370:7334` demonstrates the full format. Zero compression allows consecutive zero groups to be replaced with `::`, appearing once per address: `2001:0db8:85a3::8a2e:0370:7334`.

**IPv6 URI Syntax:**

IPv6 addresses in URIs must be enclosed in square brackets to distinguish address colons from the port separator colon. Without brackets, parsers cannot determine where the address ends and the port begins.

**IPv6 URI Examples:**

```
http://[2001:db8::1]/page
https://[fe80::1%eth0]:8080/api
http://[::1]/localhost
ftp://[2001:db8:85a3::8a2e:370:7334]/
```

**Zone Identifier:**

IPv6 link-local addresses may include a zone identifier specifying the network interface. The zone ID follows a percent sign: `fe80::1%eth0`. In URIs, the percent sign must be percent-encoded as `%25`: `http://[fe80::1%25eth0]/`.

**IPv6 Zero Compression:**

The `::` notation replaces one or more consecutive groups of zeros. It may appear only once in an address. The loopback address `0000:0000:0000:0000:0000:0000:0000:0001` compresses to `::1`. The address `2001:db8:0:0:0:0:2:1` can be written as `2001:db8::2:1`.

**IPv4-Mapped IPv6 Addresses:**

IPv6 can represent IPv4 addresses using a hybrid notation. The format `::ffff:192.168.1.1` maps the IPv4 address into IPv6 space. In URIs: `http://[::ffff:192.168.1.1]/`.

**Leading Zero Omission:**

Within IPv6 groups, leading zeros may be omitted. The group `0db8` can be written as `db8`. The group `0000` can be written as `0` or omitted entirely through zero compression.

**Port Specification:**

Port numbers follow the closing bracket in IPv6 URIs. The syntax `[address]:port` maintains unambiguous parsing. Example: `http://[2001:db8::1]:8080/` specifies port 8080.

**Address Validation:**

[Inference] Applications parsing URIs with IP address hosts must validate address format correctness. Invalid formats should be rejected rather than misinterpreted. Validation includes verifying octet ranges for IPv4, hexadecimal group validity for IPv6, proper bracket usage for IPv6, and port number validity when present.

**Localhost Addresses:**

The IPv4 address `127.0.0.1` and IPv6 address `::1` designate the local host. URIs using these addresses reference services on the same machine: `http://127.0.0.1:3000/` and `http://[::1]:3000/`.

**Private Address Ranges:**

IPv4 defines private address ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) for internal networks. IPv6 defines unique local addresses (fc00::/7) for similar purposes. URIs containing private addresses typically function only within the relevant network context.

