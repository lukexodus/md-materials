## Module 6: Software Architecture for AI Systems


### Architectural Principles
- Separation of concerns
- Single responsibility at architecture level
- Loose coupling
- High cohesion
- Abstraction layers
- Encapsulation at system level
- Modularity
- Reusability
- Maintainability
- Scalability by design
- Extensibility
- Testability architecture
- Security by design
- Privacy by design
- Fault tolerance by design
- Performance by design

### System Design Fundamentals
- Requirements analysis
- Functional requirements
- Non-functional requirements
- Quality attributes
- Performance requirements
- Scalability requirements
- Availability requirements
- Reliability requirements
- Maintainability requirements
- Security requirements
- Usability requirements
- Trade-off analysis
- Constraint identification
- Architecture decision records (ADR)
- Technical debt management
- Architecture evolution

### Monolithic Architecture
- Single deployment unit
- Shared database
- Tight coupling considerations
- Modular monolith
- Vertical slicing
- Horizontal slicing
- Internal modularity
- Layered monolith
- When to use monoliths
- Migration from monolith
- Strangler fig pattern application

### Microservices Architecture
- Service boundaries
- Domain-driven service boundaries
- Service decomposition strategies
- Decompose by business capability
- Decompose by subdomain
- Service communication
- Synchronous communication
- Asynchronous communication
- Event-driven microservices
- Service mesh
- API gateway
- Service discovery
- Service registry
- Circuit breaker in microservices
- Distributed tracing
- Centralized logging
- Distributed transactions
- Saga pattern implementation
- Choreography vs orchestration
- Data consistency in microservices
- Database per service
- Shared database anti-pattern
- CQRS in microservices
- Event sourcing in microservices
- Service versioning
- Backward compatibility
- API versioning strategies
- Microservices deployment
- Container orchestration
- Kubernetes patterns

### Serverless Architecture
- Function as a Service (FaaS)
- Backend as a Service (BaaS)
- Event-driven serverless
- Stateless functions
- Cold start optimization
- Warm start strategies
- Serverless orchestration
- Step functions pattern
- Serverless data processing
- Serverless API design
- API Gateway + Lambda pattern
- Serverless security
- Serverless cost optimization
- Serverless monitoring
- Serverless limitations

### Event-Driven Architecture (EDA)
- Event producers
- Event consumers
- Event broker
- Event schema design
- Event versioning
- Event ordering
- Event replay
- Event store design
- Stream processing architecture
- Complex event processing
- Event correlation
- Event aggregation
- Event filtering
- Event transformation
- Exactly-once processing
- At-least-once processing
- At-most-once processing
- Idempotent event processing

### Data Architecture
- Data modeling
- Conceptual data model
- Logical data model
- Physical data model
- Data normalization
- Denormalization strategies
- Data warehouse architecture
- Dimensional modeling
- Star schema
- Snowflake schema
- Fact tables
- Dimension tables
- Data lake architecture
- Data lakehouse architecture
- Data mesh architecture
- Data pipeline architecture
- Lambda architecture
- Kappa architecture
- Batch processing architecture
- Stream processing architecture
- Real-time analytics architecture

### ML System Architecture
- Training pipeline architecture
- Serving pipeline architecture
- Feature pipeline architecture
- Data pipeline for ML
- Model training infrastructure
- Distributed training architecture
- Model serving infrastructure
- Batch serving architecture
- Online serving architecture
- Hybrid serving architecture
- Feature store architecture
- Online feature store
- Offline feature store
- Model registry architecture
- Experiment tracking system
- Metadata store architecture
- ML platform architecture
- AutoML system architecture
- MLOps pipeline architecture
- End-to-end ML system
- Real-time ML architecture
- Edge ML architecture
- Federated learning architecture

### AI Application Architecture
- AI-powered application layers
- Presentation layer with AI
- AI service layer
- Model serving layer
- Data layer for AI
- Conversational AI architecture
- Chatbot architecture
- Virtual assistant architecture
- Recommendation system architecture
- Collaborative filtering architecture
- Content-based filtering architecture
- Hybrid recommendation architecture
- Computer vision system architecture
- Image processing pipeline
- Video processing pipeline
- NLP system architecture
- Text processing pipeline
- Language model serving
- Multi-modal AI architecture
- Vision-language model serving
- Speech system architecture
- Speech recognition pipeline
- Text-to-speech pipeline

### Cloud Architecture
- Cloud service models (IaaS, PaaS, SaaS)
- Cloud deployment models
- Public cloud
- Private cloud
- Hybrid cloud
- Multi-cloud architecture
- Cloud-native architecture
- Twelve-factor app
- Container-based architecture
- Kubernetes architecture
- Cloud storage architecture
- Object storage patterns
- Block storage patterns
- File storage patterns
- Cloud database architecture
- Cloud networking architecture
- Virtual private cloud (VPC)
- Cloud security architecture
- Identity and access management
- Cloud cost optimization
- Resource tagging
- Auto-scaling in cloud
- Cloud monitoring architecture
- Cloud disaster recovery

### High Availability Architecture
- Redundancy strategies
- Active-active configuration
- Active-passive configuration
- Load balancing architecture
- Health checking
- Failover mechanisms
- Automatic failover
- Manual failover
- Geographic redundancy
- Multi-region deployment
- Disaster recovery planning
- Recovery time objective (RTO)
- Recovery point objective (RPO)
- Backup strategies
- Replication strategies
- Data center architecture
- Availability zones
- Region selection

### Performance Architecture
- Performance optimization strategies
- Caching architecture
- Multi-level caching
- Distributed caching
- CDN architecture
- Database optimization
- Query optimization
- Index optimization
- Connection pooling
- Asynchronous processing
- Background job processing
- Message queue architecture
- Load testing architecture
- Performance monitoring architecture
- Application performance monitoring
- Profiling strategies
- Bottleneck identification

### Security Architecture
- Defense in depth
- Security layers
- Network security
- Firewall architecture
- DMZ architecture
- Application security
- Authentication architecture
- OAuth2 architecture
- SAML architecture
- Multi-factor authentication
- Authorization architecture
- RBAC implementation
- ABAC implementation
- API security
- API gateway security
- Rate limiting architecture
- DDoS protection
- Web application firewall
- Data security
- Encryption at rest
- Encryption in transit
- Key management architecture
- Secrets management
- Certificate management
- PKI architecture
- Security monitoring
- SIEM architecture
- Intrusion detection
- Vulnerability management
- Compliance architecture
- Audit logging architecture

### Integration Architecture
- Enterprise service bus (ESB)
- Point-to-point integration
- Hub-and-spoke integration
- API-led integration
- RESTful integration
- GraphQL integration
- gRPC integration
- Message-based integration
- File-based integration
- Database integration
- ETL architecture
- ELT architecture
- Data integration patterns
- Real-time integration
- Batch integration
- Hybrid integration
- iPaaS architecture
- Integration testing architecture

### Testing Architecture
- Test automation architecture
- Unit testing infrastructure
- Integration testing infrastructure
- End-to-end testing infrastructure
- Performance testing infrastructure
- Load testing architecture
- Stress testing architecture
- Security testing architecture
- Penetration testing infrastructure
- Test data management
- Test environment management
- Continuous testing
- Test reporting architecture
- Test coverage tracking
- Mock service architecture
- Service virtualization

### Deployment Architecture
- Continuous deployment pipeline
- Build automation
- Artifact repository
- Container registry
- Deployment strategies
- Blue-green deployment architecture
- Canary deployment architecture
- Rolling deployment architecture
- Feature flag architecture
- A/B testing infrastructure
- Infrastructure as code
- Configuration management
- Immutable infrastructure
- GitOps architecture
- Deployment monitoring
- Rollback strategies

### Observability Architecture
- Logging architecture
- Centralized logging
- Log aggregation
- Log analysis infrastructure
- Metrics architecture
- Time-series database
- Metrics collection
- Metrics aggregation
- Metrics visualization
- Tracing architecture
- Distributed tracing system
- Trace collection
- Trace analysis
- Monitoring architecture
- Real-time monitoring
- Alerting architecture
- Alert routing
- Incident response architecture
- On-call system
- Dashboard architecture

