## Border Gateway Protocol (BGP)


BGP manages routing between autonomous systems using path vector algorithms with comprehensive policy controls. External BGP (eBGP) sessions connect different autonomous systems, while Internal BGP (iBGP) distributes external routes within AS boundaries. TCP connections provide reliable session transport.

Path attributes influence route selection through complex decision processes. LOCAL_PREF prioritizes routes within AS boundaries, AS_PATH length affects inter-AS preferences, ORIGIN indicates route source types, and NEXT_HOP specifies forwarding addresses. Communities enable additional policy mechanisms.

Route selection follows deterministic processes comparing path attributes sequentially. Highest LOCAL_PREF takes precedence, followed by shortest AS_PATH, lowest ORIGIN values, and lowest MULTI_EXIT_DISC (MED) metrics. Router ID provides final tie-breaking criteria.

Route reflection and confederation techniques address iBGP full-mesh scalability requirements. Route reflectors eliminate full-mesh connectivity by reflecting routes between clients. Confederations divide large autonomous systems into smaller sub-AS units.

**Key Points:**

- Path vector approach prevents loops while enabling policy routing
- Path attributes provide sophisticated route selection mechanisms
- eBGP and iBGP sessions serve different connectivity purposes
- Scalability solutions address full-mesh connectivity requirements

