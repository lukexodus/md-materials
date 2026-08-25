## Wayland Protocol Architecture


Wayland is a communication protocol specifying how a display server (compositor) communicates with its client applications, replacing the X Window System (X11) that has existed since 1984. The protocol consists of a two-layer architecture: a low-level wire protocol handling inter-process communication via Unix domain sockets, and a high-level asynchronous object-oriented protocol managing window system features.[1][2]

### Client-Server Model

The protocol follows a client-server model where graphical applications are clients requesting display of pixel buffers, and the compositor is the server controlling buffer display. Unlike X11 where the X server sits between applications and hardware as a middleman, Wayland's compositor *is* the display server, directly managing windows and communicating with clients through a lean protocol. This eliminates an entire layer of inter-process communication present in X11's architecture.[2][1]

### Protocol Implementation

The protocol is described as asynchronous and object-oriented, where compositor services are presented as objects with interfaces containing methods (requests) and events. Clients invoke requests on objects to request services, while the compositor sends events back to clients either as responses or asynchronously based on internal state changes. The reference implementation splits into `libwayland-client` for clients and `libwayland-server` for compositors.[1]

The high-level protocol layer is automatically generated from XML descriptions, allowing flexible and extensible protocol development. Compositors can define custom interfaces beyond the core protocol to extend functionality.[1]

