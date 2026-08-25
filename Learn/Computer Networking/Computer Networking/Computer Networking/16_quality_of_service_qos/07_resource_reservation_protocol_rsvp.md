## Resource Reservation Protocol (RSVP)


RSVP enables applications and routers to communicate QoS requirements and establish resource reservations across IP networks.

**RSVP Operation** The protocol uses a receiver-initiated reservation model where data receivers request specific QoS levels for traffic flows.

_Path Messages_ are sent by traffic senders toward receivers, carrying traffic specifications and following the same route as data packets. These messages install path state in intermediate routers.

_Reservation Messages_ travel from receivers back toward senders, requesting resource reservations based on the traffic specifications received in Path messages.

_Soft State_ maintenance requires periodic refresh of both path and reservation state. If refresh messages are not received within timeout periods, the associated state is automatically deleted.

**RSVP Messages** _Path Messages_ contain sender traffic specifications (TSpec) describing the traffic characteristics that will be generated.

_Resv Messages_ include flow specifications (FlowSpec) defining the QoS requirements and filter specifications (FilterSpec) identifying the traffic flows to be reserved.

_PathErr and ResvErr Messages_ report errors in path setup or reservation establishment.

_PathTear and ResvTear Messages_ explicitly delete path or reservation state.

**RSVP-TE Extensions** Traffic Engineering extensions enable RSVP to establish MPLS Label Switched Paths (LSPs) with specific bandwidth and path requirements. RSVP-TE supports explicit routing, bandwidth reservation, and fast reroute capabilities for MPLS networks.

