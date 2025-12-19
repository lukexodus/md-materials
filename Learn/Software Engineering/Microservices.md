# Syllabus

## Module 1: Foundations
- Monolithic vs. microservices architecture
- Service-oriented architecture (SOA)
- Domain-driven design (DDD) fundamentals
- Bounded contexts
- Ubiquitous language
- Conway's Law
- Single Responsibility Principle
- Separation of concerns
- Coupling and cohesion
- Trade-offs and when not to use microservices

## Module 2: Service Design
- Service boundaries identification
- Service granularity
- API design principles
- RESTful API design
- GraphQL
- gRPC and Protocol Buffers
- Versioning strategies
- Backward and forward compatibility
- Contract-first development
- API specifications (OpenAPI, AsyncAPI)

## Module 3: Communication Patterns
- Synchronous communication
- Asynchronous communication
- Message queues
- Publish-subscribe pattern
- Event-driven architecture
- Request-response pattern
- Saga pattern
- Choreography vs. orchestration
- Event sourcing
- CQRS (Command Query Responsibility Segregation)

## Module 4: Data Management
- Database per service pattern
- Shared database anti-pattern
- Data consistency challenges
- Eventual consistency
- Two-phase commit (2PC)
- Distributed transactions
- Saga pattern for transactions
- Data replication strategies
- Polyglot persistence
- CAP theorem
- BASE vs. ACID

## Module 5: Service Discovery
- Service registry
- Client-side discovery
- Server-side discovery
- DNS-based service discovery
- Consul
- Eureka
- etcd
- ZooKeeper
- Health checks
- Service mesh service discovery

## Module 6: API Gateway
- API Gateway pattern
- Reverse proxy
- Routing and load balancing
- Request aggregation
- Protocol translation
- Authentication and authorization at gateway
- Rate limiting and throttling
- Circuit breaker at gateway
- API composition
- Backend for Frontend (BFF) pattern

## Module 7: Load Balancing
- Load balancing algorithms
- Client-side load balancing
- Server-side load balancing
- Layer 4 vs. Layer 7 load balancing
- Health-based routing
- Weighted routing
- Geographic routing
- Sticky sessions
- Connection pooling

## Module 8: Resilience and Fault Tolerance
- Circuit breaker pattern
- Bulkhead pattern
- Retry pattern
- Timeout pattern
- Fallback mechanisms
- Rate limiting
- Backpressure
- Chaos engineering
- Fault injection testing
- Graceful degradation
- Self-healing systems

## Module 9: Security
- Authentication mechanisms
- Authorization models
- OAuth 2.0 and OpenID Connect
- JWT (JSON Web Tokens)
- API keys and secrets management
- Service-to-service authentication
- mTLS (mutual TLS)
- Role-Based Access Control (RBAC)
- Attribute-Based Access Control (ABAC)
- Security at the edge
- Secrets management tools (Vault, AWS Secrets Manager)
- Encryption in transit and at rest
- API security best practices
- OWASP Top 10 for APIs

## Module 10: Service Mesh
- Service mesh architecture
- Control plane vs. data plane
- Sidecar proxy pattern
- Istio
- Linkerd
- Consul Connect
- Traffic management
- Security policies
- Observability features
- Service mesh interface (SMI)

## Module 11: Containerization
- Container fundamentals
- Docker basics
- Container images
- Dockerfile best practices
- Multi-stage builds
- Container registries
- Image security scanning
- Container networking
- Volume management
- Resource limits

## Module 12: Container Orchestration
- Kubernetes architecture
- Pods, deployments, and services
- ReplicaSets and StatefulSets
- ConfigMaps and Secrets
- Persistent volumes
- Namespaces
- Ingress controllers
- Network policies
- Resource quotas
- Helm charts
- Operators pattern
- Custom Resource Definitions (CRDs)

## Module 13: CI/CD for Microservices
- Continuous Integration principles
- Continuous Delivery vs. Continuous Deployment
- Build pipelines
- Automated testing strategies
- Integration testing
- Contract testing
- Blue-green deployments
- Canary deployments
- Rolling updates
- Feature flags
- GitOps
- Infrastructure as Code (IaC)
- Pipeline tools (Jenkins, GitLab CI, GitHub Actions)

## Module 14: Monitoring and Observability
- Metrics collection
- Prometheus
- Grafana
- Time-series databases
- Key performance indicators (KPIs)
- Service Level Indicators (SLIs)
- Service Level Objectives (SLOs)
- Service Level Agreements (SLAs)
- Health checks and readiness probes
- Custom metrics

## Module 15: Logging
- Centralized logging
- Structured logging
- Log aggregation
- ELK stack (Elasticsearch, Logstash, Kibana)
- Fluentd
- Log correlation
- Request tracing through logs
- Log retention policies
- Security and compliance in logging

## Module 16: Distributed Tracing
- Distributed tracing concepts
- Trace context propagation
- Spans and traces
- Jaeger
- Zipkin
- OpenTelemetry
- Trace sampling strategies
- Performance analysis
- Dependency mapping

## Module 17: Testing Strategies
- Unit testing
- Integration testing
- Component testing
- Contract testing (Pact)
- End-to-end testing
- Consumer-driven contracts
- Testing pyramid for microservices
- Test doubles and mocking
- Performance testing
- Load testing
- Chaos testing
- Testing in production

## Module 18: DevOps Practices
- DevOps culture
- Infrastructure as Code
- Terraform
- Ansible
- Configuration management
- Immutable infrastructure
- Environment parity
- Automated provisioning
- Self-service platforms
- Platform engineering

## Module 19: Cloud-Native Development
- Cloud-native principles
- 12-factor app methodology
- Stateless services
- Horizontal scaling
- Cloud provider services (AWS, Azure, GCP)
- Managed services vs. self-hosted
- Serverless microservices
- Function as a Service (FaaS)
- Cloud-native databases
- Multi-cloud strategies

## Module 20: Message Brokers and Event Streaming
- Apache Kafka
- RabbitMQ
- Amazon SQS/SNS
- Azure Service Bus
- Google Pub/Sub
- NATS
- Message durability
- Message ordering
- Dead letter queues
- Event streaming patterns
- Stream processing

## Module 21: Performance Optimization
- Caching strategies
- Content Delivery Networks (CDNs)
- Database query optimization
- Connection pooling
- Asynchronous processing
- Batch processing
- Compression techniques
- API response optimization
- Resource utilization
- Profiling and benchmarking

## Module 22: Scalability
- Horizontal vs. vertical scaling
- Auto-scaling strategies
- Stateless design
- Sharding and partitioning
- Read replicas
- Write scalability
- Scaling databases
- Queue-based load leveling
- Rate limiting for scalability
- Cost optimization

## Module 23: Documentation
- API documentation
- Architecture decision records (ADRs)
- Service catalogs
- Runbooks
- Diagrams and visual documentation
- Developer portals
- Documentation as code
- Swagger/OpenAPI
- Maintaining documentation currency

## Module 24: Organizational Patterns
- Team topology
- Conway's Law implications
- Cross-functional teams
- DevOps team structures
- Platform teams
- Enabling teams
- Stream-aligned teams
- Ownership models
- Communication patterns
- Organizational scalability

## Module 25: Migration Strategies
- Strangler fig pattern
- Incremental migration
- Anti-corruption layer
- Branch by abstraction
- Feature toggles for migration
- Data migration strategies
- Testing during migration
- Rollback strategies
- Migration planning
- Risk management

## Module 26: Cost Management
- Resource optimization
- Cost monitoring
- Cloud cost analysis
- Reserved vs. on-demand instances
- Spot instances
- Right-sizing services
- Idle resource identification
- Cost allocation and chargeback
- FinOps practices

## Module 27: Compliance and Governance
- Regulatory requirements
- Data privacy (GDPR, CCPA)
- Audit logging
- Compliance automation
- Policy as code
- Service governance
- API governance
- Data sovereignty
- Compliance monitoring

## Module 28: Advanced Patterns
- Backend for Frontend (BFF)
- Sidecar pattern
- Ambassador pattern
- Adapter pattern
- Anti-corruption layer
- Competing consumers
- Priority queue
- Throttling
- Valet Key pattern
- Gatekeeper pattern
- Materialized view pattern

## Module 29: Real-World Case Studies
- Netflix architecture
- Amazon microservices journey
- Uber's microservices evolution
- Spotify's squad model
- Airbnb's service architecture
- Industry-specific patterns
- Lessons learned
- Anti-patterns and failures
- Success factors

## Module 30: Emerging Trends
- WebAssembly in microservices
- Edge computing
- Service mesh evolution
- eBPF and observability
- Platform engineering
- Internal developer platforms
- AI/ML in microservices
- GraphQL federation
- Serverless containers
- Micro frontends