# Syllabus

## Module 1: Foundation Concepts

- Event streaming fundamentals
- Publish-subscribe messaging patterns
- Kafka architecture overview
- Core components (brokers, topics, partitions, producers, consumers)
- Use cases and business applications
- Kafka ecosystem overview

## Module 2: Kafka Core Components

- Brokers and cluster architecture
- Topics and partitions
- Messages and records
- Offsets and ordering guarantees
- Replication and fault tolerance
- Leaders and followers
- In-Sync Replicas (ISR)

## Module 3: Installation and Setup

- System requirements
- Single-node installation
- Multi-node cluster setup
- Configuration files and parameters
- Starting and stopping Kafka services
- Basic cluster verification
- Docker-based deployments

## Module 4: Producers

- Producer API basics
- Message serialization
- Partitioning strategies
- Producer configurations
- Acknowledgment settings (acks)
- Retries and error handling
- Idempotent producers
- Transactional producers
- Performance tuning

## Module 5: Consumers

- Consumer API basics
- Consumer groups
- Message deserialization
- Offset management
- Partition assignment strategies
- Consumer configurations
- Rebalancing protocols
- Consumer lag monitoring
- Manual offset management

## Module 6: Kafka Streams

- Stream processing concepts
- Kafka Streams API
- Stream topologies
- Stateless transformations
- Stateful operations
- Windowing operations
- Joins (stream-stream, stream-table, table-table)
- State stores
- Exactly-once processing semantics

## Module 7: Schema Management

- Schema evolution challenges
- Confluent Schema Registry
- Avro serialization
- JSON Schema support
- Protobuf support
- Schema compatibility modes
- Schema versioning strategies
- Client-side schema validation

## Module 8: Kafka Connect

- Connect framework overview
- Source connectors
- Sink connectors
- Connector configurations
- Transforms and converters
- Distributed vs standalone mode
- Custom connector development
- Popular connector ecosystem

## Module 9: Administration and Operations

- Cluster management
- Topic administration
- Partition management
- Replica management
- Broker maintenance
- Rolling updates
- Configuration management
- Log cleanup policies

## Module 10: Monitoring and Observability

- Key performance metrics
- JMX metrics collection
- Kafka Manager and other UI tools
- Consumer lag monitoring
- Broker health monitoring
- Application-level monitoring
- Alerting strategies
- Log analysis

## Module 11: Security

- Authentication mechanisms (SASL, SSL)
- Authorization and ACLs
- Encryption in transit
- Encryption at rest
- Security best practices
- Network security
- Certificate management
- Audit logging

## Module 12: Performance Optimization

- Producer performance tuning
- Consumer performance tuning
- Broker performance tuning
- Network optimization
- Disk I/O optimization
- Memory management
- Batch size optimization
- Compression strategies

## Module 13: Deployment Patterns

- On-premises deployments
- Cloud deployments (AWS, GCP, Azure)
- Kubernetes deployments
- Helm charts and operators
- Multi-datacenter deployments
- Disaster recovery setups
- Blue-green deployments

## Module 14: Data Patterns and Architectures

- Event sourcing
- CQRS (Command Query Responsibility Segregation)
- Change data capture (CDC)
- Data pipelines
- Lambda architecture
- Kappa architecture
- Microservices integration
- Real-time analytics

## Module 15: Advanced Topics

- Exactly-once semantics
- Transactional messaging
- Custom partitioners
- Custom serializers/deserializers
- Kafka Streams DSL vs Processor API
- State store customization
- Cross-cluster replication
- Kafka REST Proxy

## Module 16: Testing Strategies

- Unit testing producers and consumers
- Integration testing
- Kafka Streams testing
- Test containers
- Embedded Kafka for testing
- Schema Registry testing
- End-to-end testing
- Performance testing

## Module 17: Migration and Upgrades

- Version compatibility
- Rolling upgrades
- Data migration strategies
- Client library upgrades
- Protocol version management
- Backward compatibility considerations
- Migration from other messaging systems

## Module 18: Troubleshooting

- Common issues and solutions
- Log analysis techniques
- Network troubleshooting
- Performance bottleneck identification
- Consumer group debugging
- Rebalancing issues
- Data loss prevention
- Recovery procedures

## Module 19: Ecosystem Integration

- Apache Spark integration
- Elasticsearch integration
- Database connectors
- Cloud service integrations
- Monitoring tool integrations
- CI/CD pipeline integration
- Container orchestration
- Service mesh integration

## Module 20: Enterprise Considerations

- Governance and compliance
- Multi-tenancy patterns
- Cost optimization
- Capacity planning
- SLA management
- Change management processes
- Documentation standards
- Team training strategies