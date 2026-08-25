## Traffic Shaping and Policing


Traffic conditioning mechanisms control the rate at which traffic enters or exits a network to ensure compliance with service level agreements and prevent congestion.

**Traffic Shaping** Smooths traffic bursts by buffering excess packets and releasing them at a controlled rate. Shaping typically uses a token bucket algorithm where tokens are added to a bucket at a configured rate, and packets can only be transmitted when sufficient tokens are available.

_Generic Traffic Shaping (GTS)_ can be applied per-interface or per-access list, allowing granular control over different traffic types.

_Frame Relay Traffic Shaping (FRTS)_ specifically addresses Frame Relay networks by adapting to Backward Explicit Congestion Notification (BECN) signals and Forward Explicit Congestion Notification (FECN) indications.

**Traffic Policing** Enforces traffic contracts by monitoring traffic rates and taking action on non-conforming traffic. Unlike shaping, policing does not buffer excess traffic but instead drops or remarks it.

_Single-Rate Policing_ uses one token bucket to measure traffic against a single rate limit.

_Dual-Rate Policing_ employs two token buckets (Committed Information Rate and Peak Information Rate) to provide more granular control with conforming, exceeding, and violating traffic categories.

**Token Bucket Algorithm** The fundamental mechanism underlying both shaping and policing operations. Tokens represent permission to transmit a certain amount of data and are added to the bucket at the configured rate. When traffic arrives, tokens are removed from the bucket. If insufficient tokens exist, the traffic is either buffered (shaping) or subjected to policing actions.

