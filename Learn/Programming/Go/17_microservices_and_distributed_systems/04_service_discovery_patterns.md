## Service Discovery Patterns


**Client-Side Discovery** Client-side discovery requires services to query a service registry directly to obtain the network locations of available service instances. This pattern provides clients with full control over load balancing decisions and reduces the number of network hops. However, it couples clients to the service registry and requires implementing discovery logic in multiple programming languages.

Popular implementations include Netflix Eureka and Consul. The pattern works well in environments where clients can cache service locations and implement sophisticated load balancing algorithms. Circuit breaker patterns often complement client-side discovery to handle service failures gracefully.

**Server-Side Discovery** Server-side discovery abstracts the service registry from clients through a load balancer or API gateway. Clients make requests to a well-known endpoint, and the load balancer queries the service registry to route requests to available instances. This pattern simplifies client implementation and centralizes routing logic.

AWS Application Load Balancer and NGINX Plus exemplify server-side discovery implementations. The pattern reduces client complexity but introduces an additional network hop and potential single point of failure. High availability load balancer configurations mitigate these concerns.

**Service Registry Implementations** Distributed service registries maintain service location information across multiple nodes for fault tolerance. Health checking mechanisms ensure only healthy service instances receive traffic. Service registries support both self-registration, where services register themselves, and third-party registration through deployment tools.

Time-to-live (TTL) mechanisms remove stale service registrations automatically. Service metadata enables routing decisions based on service versions, data center locations, or other attributes. Registry replication ensures consistency across multiple registry nodes.

