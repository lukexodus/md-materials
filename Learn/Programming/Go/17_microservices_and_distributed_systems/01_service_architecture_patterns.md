## Service Architecture Patterns


**Decomposition Patterns** Service decomposition forms the foundation of microservices design. The Database-per-Service pattern ensures each microservice maintains its own database, preventing tight coupling through shared data stores. Domain-Driven Design (DDD) provides strategic guidance for service boundaries, where each service represents a bounded context within the business domain.

The Strangler Fig pattern enables gradual migration from monolithic systems by incrementally replacing functionality with microservices. Services can be decomposed by business capability, organizing around what the business does rather than technical layers. Alternatively, decomposition by subdomain aligns services with specific areas of the business domain.

**Communication Patterns** Synchronous communication typically uses HTTP/REST or gRPC for request-response interactions. The API Gateway pattern provides a single entry point for clients, handling cross-cutting concerns like authentication, rate limiting, and request routing. Backend for Frontend (BFF) creates specialized API gateways tailored for specific client types.

Asynchronous communication leverages messaging patterns for loose coupling. The Publish-Subscribe pattern enables event-driven architectures where services react to domain events. The Saga pattern manages distributed transactions across multiple services through choreography or orchestration approaches.

**Data Management Patterns** The Command Query Responsibility Segregation (CQRS) pattern separates read and write models, optimizing each for their specific use cases. Event Sourcing stores the state of entities as a sequence of events rather than current state snapshots. The Outbox pattern ensures reliable publishing of domain events alongside database transactions.

