## Interior vs Exterior Gateway Protocols


Interior Gateway Protocols (IGPs) optimize routing within single administrative domains focusing on convergence speed and path optimization. Examples include RIP, OSPF, and EIGRP. These protocols assume cooperative environments with shared routing objectives and trust relationships.

Exterior Gateway Protocols (EGPs) manage routing between different administrative domains emphasizing policy control over optimization. BGP represents the primary EGP for internet routing, handling autonomous system interconnection with sophisticated policy mechanisms.

IGPs typically use simple metrics like hop count, bandwidth, or composite calculations for path selection. Fast convergence takes priority over policy flexibility since single organizations control entire routing domains. Authentication provides security against configuration errors rather than malicious attacks.

EGPs implement complex policy mechanisms supporting economic, political, and technical routing decisions. Route filtering, attribute manipulation, and path selection policies enable fine-grained control over traffic flow. Security considerations address potential attacks from untrusted routing peers.

**Key Points:**

- IGPs optimize routing within single administrative domains
- EGPs manage routing between different autonomous systems
- IGPs prioritize convergence speed over policy flexibility
- EGPs emphasize policy control for inter-domain routing decisions

**Related Topics:** Multiprotocol Label Switching (MPLS) traffic engineering, IPv6 routing considerations, Quality of Service (QoS) routing extensions, Software-Defined Networking (SDN) routing paradigms, routing security mechanisms including BGPsec.

---

