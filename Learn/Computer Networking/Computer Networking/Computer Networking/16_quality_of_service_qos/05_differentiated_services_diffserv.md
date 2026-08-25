## Differentiated Services (DiffServ)


DiffServ provides a scalable approach to QoS by classifying and managing network traffic through standardized per-hop behaviors.

**DiffServ Architecture** The model defines two key components: traffic classification and marking at network edges, and differentiated forwarding treatment at each network node based on the DSCP marking.

_Trust Boundary_ represents the point where DSCP markings are trusted. Traffic entering the DiffServ domain at untrusted interfaces may be classified and marked based on local policies.

_Service Level Agreements (SLAs)_ define the traffic conditioning and performance expectations between DiffServ domains.

**Per-Hop Behaviors (PHB)** Standardized forwarding treatments that routers apply to packets based on their DSCP markings.

_Default PHB_ provides best-effort forwarding for unmarked traffic (DSCP 0).

_Expedited Forwarding (EF)_ PHB ensures low-latency, low-jitter service suitable for voice traffic. EF traffic receives priority treatment but must be rate-limited to prevent starvation of other traffic classes.

_Assured Forwarding (AF)_ PHB defines four classes (AF1-AF4) with three drop precedence levels each. Within each class, higher drop precedence packets are discarded first during congestion.

_Class Selector (CS)_ PHB maintains backward compatibility with IP Precedence by using the three most significant bits of the DSCP field.

**Traffic Conditioning** Edge routers perform traffic conditioning functions including classification, marking, metering, shaping, and policing to ensure traffic conforms to SLA requirements before entering the DiffServ core.

