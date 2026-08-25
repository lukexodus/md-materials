## Module 5: Software Design Patterns


### Creational Patterns
- Singleton pattern
- Thread-safe singleton
- Lazy initialization
- Factory method pattern
- Abstract factory pattern
- Factory variations
- Builder pattern
- Fluent builder
- Telescoping constructor problem
- Prototype pattern
- Shallow vs deep cloning
- Object pool pattern
- Lazy initialization pattern
- Multiton pattern
- Dependency injection pattern

### Structural Patterns
- Adapter pattern
- Object adapter vs class adapter
- Bridge pattern
- Composite pattern
- Tree structures
- Leaf and composite nodes
- Decorator pattern
- Function decorators
- Class decorators
- Decorator stacking
- Facade pattern
- Simplified interfaces
- Flyweight pattern
- Intrinsic vs extrinsic state
- Proxy pattern
- Virtual proxy
- Protection proxy
- Remote proxy
- Smart proxy

### Behavioral Patterns
- Chain of responsibility
- Command pattern
- Command queue
- Undo/redo with command
- Iterator pattern
- Iterator protocol
- Mediator pattern
- Memento pattern
- State preservation
- Observer pattern
- Publisher-subscriber
- Event systems
- State pattern
- State machines
- Strategy pattern
- Algorithm families
- Template method pattern
- Hook methods
- Visitor pattern
- Double dispatch
- Interpreter pattern

### Concurrency Patterns
- Active object pattern
- Monitor pattern
- Thread pool pattern
- Producer-consumer pattern
- Reader-writer pattern
- Scheduler pattern
- Thread-specific storage
- Balking pattern
- Guarded suspension
- Double-checked locking
- Immutable object pattern
- Future and promise pattern
- Barrier pattern
- Latch pattern

### Architectural Patterns
- Model-View-Controller (MVC)
- Model-View-Presenter (MVP)
- Model-View-ViewModel (MVVM)
- Layered architecture
- Presentation layer
- Business logic layer
- Data access layer
- Hexagonal architecture (Ports and Adapters)
- Clean architecture
- Onion architecture
- Microkernel architecture
- Event-driven architecture
- Pipe and filter
- Broker pattern
- Peer-to-peer pattern
- Blackboard pattern

### Domain-Driven Design Patterns
- Entity pattern
- Value object pattern
- Aggregate pattern
- Repository pattern
- Factory in DDD
- Domain service pattern
- Application service pattern
- Domain events
- Event sourcing
- CQRS (Command Query Responsibility Segregation)
- Specification pattern
- Unit of work pattern

### Data Access Patterns
- Data mapper pattern
- Active record pattern
- Repository pattern
- DAO (Data Access Object)
- Unit of work
- Identity map
- Lazy loading
- Eager loading
- Query object pattern
- ORM patterns

### Integration Patterns
- Gateway pattern
- Mapper pattern
- Adapter for external systems
- Anti-corruption layer
- Service stub
- Message queue integration
- Event-driven integration
- API gateway pattern
- Backends for frontends (BFF)

### Microservices Patterns
- Service decomposition
- Database per service
- Saga pattern
- API composition
- CQRS in microservices
- Event sourcing in microservices
- Service registry
- Service discovery
- Circuit breaker pattern
- Bulkhead pattern
- Sidecar pattern
- Ambassador pattern
- Adapter pattern for microservices
- Strangler fig pattern

### Cloud-Native Patterns
- Twelve-factor app principles
- Configuration externalization
- Service discovery
- Load balancing patterns
- Health check pattern
- Retry pattern
- Timeout pattern
- Fallback pattern
- Cache-aside pattern
- Throttling pattern
- Rate limiting pattern
- Token bucket algorithm
- Leaky bucket algorithm

### API Design Patterns
- RESTful API patterns
- Resource-oriented design
- HATEOAS
- Versioning strategies
- Pagination patterns
- Filtering and searching
- Bulk operations
- Batch processing
- Idempotency patterns
- Webhook patterns
- GraphQL patterns
- RPC patterns

### Error Handling Patterns
- Exception handling strategies
- Error codes vs exceptions
- Retry pattern
- Circuit breaker
- Fallback pattern
- Timeout handling
- Bulkhead isolation
- Failover pattern
- Let it crash philosophy
- Supervision trees concept

### Testing Patterns
- Test doubles (stubs, mocks, fakes)
- Test fixture patterns
- Object mother pattern
- Test data builder
- Parameterized tests
- Test pyramid
- Given-When-Then pattern
- Arrange-Act-Assert
- Mock object pattern
- Spy pattern
- Fake object pattern
- Test-specific subclass

### Refactoring Patterns
- Extract method
- Extract class
- Move method
- Inline method
- Replace conditional with polymorphism
- Introduce parameter object
- Preserve whole object
- Replace magic number with constant
- Encapsulate field
- Replace type code with class
- Replace conditional with state/strategy
- Introduce null object

### Anti-Patterns
- God object
- Spaghetti code
- Lava flow
- Golden hammer
- Cargo cult programming
- Copy-paste programming
- Hard-coding
- Magic numbers
- Shotgun surgery
- Sequential coupling
- Blob pattern
- Poltergeist classes
- Boat anchor
- Dead code
- Speculative generality
- Inappropriate intimacy

### ML/AI-Specific Patterns
- Pipeline pattern for ML
- Feature store pattern
- Model registry pattern
- Model serving patterns
- Batch inference pattern
- Online inference pattern
- A/B testing pattern
- Shadow deployment
- Canary deployment
- Champion-challenger pattern
- Ensemble pattern
- Cascade pattern for models
- Feedback loop pattern
- Feature extraction pipeline
- Data versioning pattern
- Experiment tracking pattern
- Hyperparameter tuning pattern
- Model monitoring pattern
- Drift detection pattern
- Retraining pipeline pattern

### Distributed System Patterns
- Leader election
- Consensus patterns
- Two-phase commit
- Three-phase commit
- Gossip protocol
- Vector clocks
- Distributed cache
- Sharding patterns
- Replication patterns
- Master-slave replication
- Multi-master replication
- Peer-to-peer replication
- Quorum-based replication
- Consistent hashing
- Distributed locking
- Distributed transactions
- Eventual consistency patterns
- Conflict resolution strategies
- Last-write-wins
- Version vectors
- CRDTs (Conflict-free Replicated Data Types)
- Split-brain prevention
- Distributed rate limiting
- Distributed tracing patterns

### Event-Driven Patterns
- Event sourcing
- Event store
- Event replay
- Snapshot pattern
- CQRS implementation
- Event bus
- Message broker patterns
- Publish-subscribe topology
- Point-to-point topology
- Request-reply pattern
- Event notification
- Event-carried state transfer
- Domain events
- Integration events
- Event versioning
- Event upcasting

### Messaging Patterns
- Message queue pattern
- Dead letter queue
- Poison message handling
- Message deduplication
- Idempotent consumer
- Competing consumers
- Message dispatcher
- Selective consumer
- Durable subscriber
- Message expiration
- Priority queue
- Message routing
- Content-based routing
- Message transformation
- Message aggregation
- Message splitting
- Scatter-gather pattern
- Routing slip
- Process manager
- Message sequencing

### Caching Patterns
- Cache-aside (lazy loading)
- Read-through cache
- Write-through cache
- Write-behind (write-back) cache
- Refresh-ahead
- Distributed caching
- Cache invalidation strategies
- TTL (Time To Live)
- Cache warming
- Cache stampede prevention
- Two-tier caching
- Near-cache pattern
- Edge caching
- CDN patterns
- Local cache + remote cache

### Security Patterns
- Authentication patterns
- Authorization patterns
- Role-based access control (RBAC)
- Attribute-based access control (ABAC)
- Token-based authentication
- JWT pattern
- OAuth2 patterns
- OpenID Connect patterns
- API key pattern
- Credential storage patterns
- Password hashing
- Salt and pepper
- Rate limiting for security
- CORS patterns
- CSRF protection
- XSS prevention
- SQL injection prevention
- Input validation patterns
- Output encoding
- Secure session management
- Encryption patterns
- Key management patterns

### Resource Management Patterns
- Object pool
- Connection pooling
- Thread pooling
- Resource acquisition is initialization (RAII)
- Dispose pattern
- Using statement pattern
- Context manager protocol
- Lazy initialization
- Eager initialization
- Double-checked locking
- Initialization-on-demand holder
- Static initialization

### Performance Patterns
- Lazy loading
- Eager loading
- Prefetching
- Batching pattern
- Bulk operations
- Pagination
- Streaming data pattern
- Chunking
- Compression patterns
- Denormalization
- Materialized views
- Index optimization patterns
- Query optimization patterns
- Database connection pooling
- N+1 query problem solution
- Data locality patterns
- Memory pooling

### Scalability Patterns
- Horizontal scaling patterns
- Vertical scaling patterns
- Load balancing
- Round-robin
- Least connections
- IP hash
- Weighted load balancing
- Auto-scaling patterns
- Scale-out database patterns
- Database sharding
- Partitioning strategies
- Hash-based partitioning
- Range-based partitioning
- List-based partitioning
- Composite partitioning
- Read replicas
- Master-slave architecture
- Multi-master architecture
- Database federation

### Resilience Patterns
- Retry pattern
- Exponential backoff
- Jitter in retry
- Circuit breaker pattern
- Half-open state
- Bulkhead pattern
- Timeout pattern
- Fallback pattern
- Graceful degradation
- Rate limiting
- Throttling
- Load shedding
- Backpressure handling
- Chaos engineering patterns
- Health check pattern
- Heartbeat pattern
- Self-healing patterns
- Automatic failover
- Manual failover
- Blue-green deployment
- Canary releases
- Rolling deployment

### Observability Patterns
- Logging patterns
- Structured logging
- Correlation ID
- Log aggregation
- Metrics collection patterns
- Counter metrics
- Gauge metrics
- Histogram metrics
- Summary metrics
- Distributed tracing
- Trace context propagation
- Span creation patterns
- Monitoring patterns
- Health check endpoint
- Readiness probe
- Liveness probe
- Alerting patterns
- Dashboard patterns
- Audit logging
- Application Performance Monitoring (APM)

### Configuration Patterns
- Configuration externalization
- Environment-specific configuration
- Configuration hierarchy
- Default configuration
- Configuration override
- Configuration injection
- Feature flags
- A/B testing configuration
- Remote configuration
- Configuration refresh
- Secrets management
- Vault pattern
- Configuration validation
- Type-safe configuration
- Configuration versioning

### ML/AI Pipeline Patterns
- ETL pipeline pattern
- ELT pipeline pattern
- Data ingestion patterns
- Batch ingestion
- Stream ingestion
- Micro-batch ingestion
- Data validation patterns
- Schema validation
- Statistical validation
- Data quality checks
- Feature engineering pipeline
- Feature transformation
- Feature encoding patterns
- One-hot encoding
- Label encoding
- Target encoding
- Feature scaling patterns
- Standardization
- Normalization
- Feature selection patterns
- Filter methods
- Wrapper methods
- Embedded methods
- Feature store architecture
- Online feature serving
- Offline feature serving
- Feature versioning

### Model Training Patterns
- Training pipeline pattern
- Hyperparameter tuning pattern
- Grid search pattern
- Random search pattern
- Bayesian optimization pattern
- Cross-validation patterns
- K-fold cross-validation
- Stratified cross-validation
- Time series cross-validation
- Early stopping pattern
- Checkpoint pattern
- Model snapshot
- Incremental training
- Transfer learning pattern
- Fine-tuning pattern
- Multi-task learning pattern
- Curriculum learning pattern
- Active learning pattern
- Federated learning pattern
- Distributed training patterns
- Data parallelism
- Model parallelism
- Pipeline parallelism

### Model Serving Patterns
- Batch prediction pattern
- Online prediction pattern
- Real-time inference
- Near-real-time inference
- Streaming inference
- Model deployment patterns
- Containerized deployment
- Serverless deployment
- Edge deployment
- Model versioning pattern
- Shadow mode deployment
- Canary deployment for models
- Blue-green deployment for models
- A/B testing pattern
- Multi-armed bandit
- Model ensemble serving
- Model cascade pattern
- Model fallback pattern
- Caching predictions
- Batch prediction optimization

### Model Monitoring Patterns
- Model performance monitoring
- Prediction logging
- Feature logging
- Drift detection pattern
- Data drift monitoring
- Concept drift monitoring
- Model decay detection
- Feedback loop pattern
- Human-in-the-loop pattern
- Model explainability pattern
- Model interpretability
- Feature importance tracking
- Prediction confidence monitoring
- Anomaly detection in predictions
- Model comparison pattern
- Champion-challenger pattern
- Shadow scoring
- Model rollback pattern
- Automated retraining trigger
- Performance threshold alerting

### MLOps Patterns
- Continuous training (CT)
- Continuous integration for ML
- Continuous deployment for ML
- Model registry pattern
- Experiment tracking pattern
- Metadata management
- Artifact versioning
- Reproducibility pattern
- Environment isolation
- Dependency management
- Pipeline orchestration
- Workflow DAG pattern
- Task dependency management
- Model governance pattern
- Model approval workflow
- Model lineage tracking
- Feature lineage tracking
- Data lineage tracking
- Compliance patterns
- Audit trail pattern
- Model card pattern
- Datasheet pattern

### Data Management Patterns for ML
- Data versioning pattern
- Data lake pattern
- Data warehouse pattern
- Data lakehouse pattern
- Data catalog pattern
- Metadata repository
- Schema evolution pattern
- Slowly changing dimensions
- Type 1 SCD
- Type 2 SCD
- Type 3 SCD
- Data partitioning patterns
- Time-based partitioning
- Entity-based partitioning
- Data archiving pattern
- Data retention policy
- GDPR compliance patterns
- Right to be forgotten
- Data anonymization
- Data pseudonymization
- Synthetic data generation

### Neural Network Architecture Patterns
- Encoder-decoder pattern
- Attention mechanism pattern
- Self-attention pattern
- Multi-head attention
- Cross-attention pattern
- Residual connection pattern
- Skip connection pattern
- Dense connection pattern
- Bottleneck layer pattern
- Squeeze-and-excitation pattern
- Grouped convolution
- Depthwise separable convolution
- Inverted residual pattern
- Neural architecture search patterns
- Weight sharing pattern
- Parameter efficient fine-tuning
- Adapter layers
- LoRA pattern
- Prefix tuning pattern
- Prompt tuning pattern

### Advanced ML Patterns
- Meta-learning pattern
- Few-shot learning pattern
- Zero-shot learning pattern
- Self-supervised learning pattern
- Contrastive learning pattern
- Siamese network pattern
- Triplet loss pattern
- Knowledge distillation pattern
- Teacher-student pattern
- Model compression patterns
- Pruning pattern
- Quantization pattern
- Neural architecture pruning
- Mixed precision training
- Gradient accumulation pattern
- Gradient checkpointing pattern
- Memory-efficient attention
- Flash attention pattern

