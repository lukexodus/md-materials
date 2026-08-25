## Host Subcomponent


The host identifies the network location where the resource resides. It can take several forms: registered domain names, IPv4 addresses, IPv6 addresses (enclosed in brackets), or registered names that are not domain names.

The host subcomponent is case-insensitive and should be normalized to lowercase for comparison. It is the most critical part of the authority component as it determines where connection attempts are directed.

### Host Types and Validation

Different host types require different validation approaches. Domain names must conform to DNS rules and may include internationalized characters through Punycode encoding. IP addresses must match specific format requirements for their version. Some schemes allow opaque hosts that don't fit standard categories.

The WHATWG URL Standard categorizes hosts more specifically: domain (DNS domain names), IPv4 address (dotted decimal notation), IPv6 address (hexadecimal with colons), opaque host (scheme-dependent format), and empty host (allowed in some contexts like file: URLs).

