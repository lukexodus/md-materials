## Integrated Services (IntServ)


IntServ provides guaranteed QoS through per-flow resource reservation and admission control mechanisms.

**IntServ Architecture** The model requires applications to signal their QoS requirements to the network, which then reserves resources along the entire path for each individual flow.

_Admission Control_ determines whether sufficient resources exist to accommodate a new reservation request without violating existing guarantees.

_Packet Classifier_ identifies packets belonging to specific reserved flows based on five-tuple information (source/destination addresses, source/destination ports, protocol).

_Packet Scheduler_ implements the forwarding behavior necessary to meet reserved flow requirements.

**Service Classes** _Guaranteed Service_ provides firm bounds on end-to-end delay for conforming traffic. This service guarantees that packets will not be dropped due to queue overflow and will not exceed specified delay bounds.

_Controlled Load Service_ approximates the performance that conforming traffic would receive on an unloaded network. While not providing mathematical guarantees, it ensures a high percentage of transmitted packets are successfully delivered with minimal delay.

**Resource Reservation** Each router along the path must maintain state information for every reserved flow, including bandwidth allocation, buffer space, and scheduling parameters. This per-flow state requirement limits IntServ scalability in large networks.

