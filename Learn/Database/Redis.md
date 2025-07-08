# Syllabus

## Course Overview

This syllabus covers Redis from fundamental concepts to advanced production deployment. Estimated duration: 8-12 weeks for complete mastery.

## Prerequisites

- Basic command line knowledge
- Understanding of databases and data structures
- Familiarity with at least one programming language (Python, JavaScript, Java, etc.)

---

## Module 1: Introduction and Fundamentals (Week 1)

### 1.1 What is Redis?

- **Learning Objectives**: Understand Redis purpose, use cases, and architecture
- **Topics**:
    - Redis overview and history
    - In-memory data structure store concept
    - Redis vs traditional databases
    - Common use cases (caching, session storage, real-time analytics)
    - Redis architecture and single-threaded model
- **Hands-on**: Install Redis locally and connect via CLI
- **Assessment**: Quiz on Redis fundamentals and use cases

### 1.2 Installation and Setup

- **Learning Objectives**: Set up Redis in different environments
- **Topics**:
    - Installing Redis on Linux, macOS, Windows
    - Redis configuration files (redis.conf)
    - Starting and stopping Redis server
    - Basic security considerations
    - Redis CLI basics
- **Hands-on**: Install Redis, modify configuration, start server
- **Assessment**: Successfully configure and start Redis server

### 1.3 Basic Commands and Data Types Overview

- **Learning Objectives**: Master basic Redis operations
- **Topics**:
    - Redis command syntax and structure
    - Basic commands: SET, GET, DEL, EXISTS, KEYS
    - Understanding Redis databases (SELECT command)
    - Data expiration concepts (TTL, EXPIRE)
- **Hands-on**: Execute basic commands via Redis CLI
- **Assessment**: Command execution exercises

---

## Module 2: Core Data Structures (Week 2-3)

### 2.1 Strings

- **Learning Objectives**: Master string operations and use cases
- **Topics**:
    - String commands: SET, GET, MSET, MGET, INCR, DECR
    - String manipulation: APPEND, SUBSTR, STRLEN
    - Atomic operations and counters
    - Use cases: caching, counters, feature flags
- **Hands-on**: Build a simple counter and caching system
- **Assessment**: String manipulation exercises

### 2.2 Lists

- **Learning Objectives**: Understand list operations and patterns
- **Topics**:
    - List commands: LPUSH, RPUSH, LPOP, RPOP, LRANGE
    - List as queue and stack
    - Blocking operations: BLPOP, BRPOP
    - Use cases: message queues, activity feeds, logs
- **Hands-on**: Implement a simple message queue
- **Assessment**: Queue implementation project

### 2.3 Sets

- **Learning Objectives**: Work with unique collections
- **Topics**:
    - Set commands: SADD, SREM, SMEMBERS, SCARD
    - Set operations: SINTER, SUNION, SDIFF
    - Use cases: tags, unique visitors, recommendations
- **Hands-on**: Build a tagging system
- **Assessment**: Set operations exercises

### 2.4 Sorted Sets (ZSets)

- **Learning Objectives**: Understand scored collections
- **Topics**:
    - Sorted set commands: ZADD, ZREM, ZRANGE, ZRANK
    - Score-based operations: ZRANGEBYSCORE, ZCOUNT
    - Use cases: leaderboards, priority queues, time-series data
- **Hands-on**: Create a leaderboard system
- **Assessment**: Leaderboard implementation

### 2.5 Hashes

- **Learning Objectives**: Work with field-value pairs
- **Topics**:
    - Hash commands: HSET, HGET, HMSET, HMGET, HGETALL
    - Use cases: user profiles, configuration storage
    - Performance considerations
- **Hands-on**: Build a user profile system
- **Assessment**: Hash manipulation exercises

---

## Module 3: Advanced Data Structures (Week 4)

### 3.1 Bitmaps

- **Learning Objectives**: Understand bit-level operations
- **Topics**:
    - Bitmap commands: SETBIT, GETBIT, BITCOUNT, BITOP
    - Use cases: user activity tracking, feature flags
    - Memory efficiency considerations
- **Hands-on**: Implement user activity tracking
- **Assessment**: Bitmap operations project

### 3.2 HyperLogLog

- **Learning Objectives**: Approximate cardinality estimation
- **Topics**:
    - HyperLogLog commands: PFADD, PFCOUNT, PFMERGE
    - Use cases: unique visitor counting, analytics
    - Accuracy vs memory trade-offs
- **Hands-on**: Build unique visitor counter
- **Assessment**: HyperLogLog implementation

### 3.3 Geospatial Data

- **Learning Objectives**: Work with location-based data
- **Topics**:
    - Geo commands: GEOADD, GEODIST, GEORADIUS, GEOSEARCH
    - Use cases: location services, proximity search
    - Performance considerations
- **Hands-on**: Create location-based service
- **Assessment**: Geospatial queries project

### 3.4 Streams

- **Learning Objectives**: Handle time-series and event data
- **Topics**:
    - Stream commands: XADD, XREAD, XRANGE, XGROUP
    - Consumer groups and message processing
    - Use cases: event logging, real-time analytics
- **Hands-on**: Build event processing system
- **Assessment**: Stream processing implementation

---

## Module 4: Scripting and Transactions (Week 5)

### 4.1 Lua Scripting

- **Learning Objectives**: Extend Redis with custom logic
- **Topics**:
    - Lua basics for Redis
    - EVAL and EVALSHA commands
    - Script caching and optimization
    - Atomic operations with scripts
    - Common scripting patterns
- **Hands-on**: Write custom Lua scripts for complex operations
- **Assessment**: Lua scripting project

### 4.2 Transactions

- **Learning Objectives**: Understand Redis transaction model
- **Topics**:
    - MULTI, EXEC, DISCARD commands
    - WATCH for optimistic locking
    - Transaction limitations and best practices
    - Comparison with traditional ACID transactions
- **Hands-on**: Implement atomic operations using transactions
- **Assessment**: Transaction implementation exercises

### 4.3 Pipeline and Batch Operations

- **Learning Objectives**: Optimize performance through batching
- **Topics**:
    - Pipelining concept and benefits
    - Implementing pipelines in different clients
    - Batch operations best practices
    - Performance comparison: pipeline vs individual commands
- **Hands-on**: Optimize bulk operations using pipelines
- **Assessment**: Performance optimization project

---

## Module 5: Client Libraries and Application Integration (Week 6)

### 5.1 Redis Clients Overview

- **Learning Objectives**: Choose appropriate client libraries
- **Topics**:
    - Client library ecosystem
    - Connection pooling and management
    - Serialization considerations
    - Error handling and retry strategies
- **Hands-on**: Compare different client libraries
- **Assessment**: Client library evaluation

### 5.2 Python Integration (redis-py)

- **Learning Objectives**: Integrate Redis with Python applications
- **Topics**:
    - redis-py installation and basic usage
    - Connection pools and threading
    - Async Redis operations
    - Django/Flask integration patterns
- **Hands-on**: Build Python web app with Redis
- **Assessment**: Python integration project

### 5.3 Node.js Integration

- **Learning Objectives**: Use Redis with Node.js applications
- **Topics**:
    - node_redis and ioredis libraries
    - Promise-based operations
    - Connection management
    - Express.js session storage
- **Hands-on**: Build Node.js API with Redis caching
- **Assessment**: Node.js integration project

### 5.4 Java Integration (Jedis/Lettuce)

- **Learning Objectives**: Integrate Redis with Java applications
- **Topics**:
    - Jedis vs Lettuce comparison
    - Spring Data Redis
    - Connection pooling with JedisPool
    - Spring Boot integration
- **Hands-on**: Build Spring Boot app with Redis
- **Assessment**: Java integration project

---

## Module 6: Performance and Optimization (Week 7)

### 6.1 Memory Management

- **Learning Objectives**: Optimize Redis memory usage
- **Topics**:
    - Memory usage analysis (MEMORY commands)
    - Data structure memory overhead
    - Expiration policies and strategies
    - Memory optimization techniques
    - Monitoring memory usage
- **Hands-on**: Analyze and optimize memory usage
- **Assessment**: Memory optimization project

### 6.2 Performance Monitoring

- **Learning Objectives**: Monitor and troubleshoot performance
- **Topics**:
    - Redis monitoring tools (redis-cli --stat, INFO command)
    - Key performance metrics
    - Slow query analysis (SLOWLOG)
    - Latency monitoring
    - Third-party monitoring solutions
- **Hands-on**: Set up monitoring dashboard
- **Assessment**: Performance monitoring setup

### 6.3 Optimization Techniques

- **Learning Objectives**: Implement performance best practices
- **Topics**:
    - Key naming conventions
    - Data structure selection for performance
    - Avoiding anti-patterns
    - Batch operations and pipelining
    - Connection pooling strategies
- **Hands-on**: Optimize existing Redis implementation
- **Assessment**: Performance optimization case study

---

## Module 7: High Availability and Scaling (Week 8)

### 7.1 Replication

- **Learning Objectives**: Implement Redis replication
- **Topics**:
    - Master-slave replication setup
    - Replication configuration
    - Handling replication lag
    - Failover procedures
    - Read scaling with replicas
- **Hands-on**: Set up master-slave replication
- **Assessment**: Replication implementation

### 7.2 Sentinel

- **Learning Objectives**: Implement automatic failover
- **Topics**:
    - Redis Sentinel architecture
    - Sentinel configuration and deployment
    - Automatic failover process
    - Client integration with Sentinel
    - Monitoring and alerting
- **Hands-on**: Deploy Redis with Sentinel
- **Assessment**: High availability setup

### 7.3 Clustering

- **Learning Objectives**: Scale Redis horizontally
- **Topics**:
    - Redis Cluster architecture
    - Cluster setup and configuration
    - Data sharding and hash slots
    - Cluster operations and maintenance
    - Client-side clustering considerations
- **Hands-on**: Set up Redis Cluster
- **Assessment**: Cluster deployment project

### 7.4 Backup and Recovery

- **Learning Objectives**: Implement data protection strategies
- **Topics**:
    - RDB snapshots vs AOF persistence
    - Backup strategies and scheduling
    - Disaster recovery procedures
    - Point-in-time recovery
    - Cross-region replication
- **Hands-on**: Implement backup and recovery procedures
- **Assessment**: Backup strategy implementation

---

## Module 8: Production Deployment (Week 9)

### 8.1 Production Configuration

- **Learning Objectives**: Configure Redis for production
- **Topics**:
    - Production-ready configuration settings
    - Security hardening
    - Resource allocation and limits
    - Logging and monitoring configuration
    - Environment-specific configurations
- **Hands-on**: Create production configuration
- **Assessment**: Production setup checklist

### 8.2 Security

- **Learning Objectives**: Secure Redis deployments
- **Topics**:
    - Authentication and authorization
    - Network security and firewalls
    - SSL/TLS encryption
    - Security best practices
    - Compliance considerations
- **Hands-on**: Implement security measures
- **Assessment**: Security audit and implementation

### 8.3 Docker and Containerization

- **Learning Objectives**: Deploy Redis in containers
- **Topics**:
    - Redis Docker images
    - Container orchestration with Kubernetes
    - Persistent storage considerations
    - Service discovery and networking
    - Helm charts for Redis
- **Hands-on**: Deploy Redis on Kubernetes
- **Assessment**: Containerized deployment

### 8.4 Cloud Deployment

- **Learning Objectives**: Deploy Redis on cloud platforms
- **Topics**:
    - AWS ElastiCache
    - Google Cloud Memorystore
    - Azure Cache for Redis
    - Cloud-specific features and limitations
    - Cost optimization strategies
- **Hands-on**: Deploy on chosen cloud platform
- **Assessment**: Cloud deployment project

---

## Module 9: Advanced Topics and Use Cases (Week 10)

### 9.1 Pub/Sub Messaging

- **Learning Objectives**: Implement real-time messaging
- **Topics**:
    - Pub/Sub commands: PUBLISH, SUBSCRIBE, PSUBSCRIBE
    - Message patterns and routing
    - Scaling pub/sub systems
    - Use cases: chat systems, notifications, real-time updates
- **Hands-on**: Build real-time chat application
- **Assessment**: Pub/Sub implementation project

### 9.2 Time-Series Data

- **Learning Objectives**: Handle time-series workloads
- **Topics**:
    - Time-series data patterns in Redis
    - RedisTimeSeries module
    - Aggregation and downsampling
    - Use cases: IoT data, metrics, monitoring
- **Hands-on**: Build time-series analytics system
- **Assessment**: Time-series implementation

### 9.3 Full-Text Search

- **Learning Objectives**: Implement search capabilities
- **Topics**:
    - RediSearch module overview
    - Indexing strategies
    - Search queries and filters
    - Performance considerations
- **Hands-on**: Build search-enabled application
- **Assessment**: Search implementation project

### 9.4 Graph Database Features

- **Learning Objectives**: Work with graph data
- **Topics**:
    - RedisGraph module
    - Graph modeling in Redis
    - Cypher queries
    - Use cases: social networks, recommendation engines
- **Hands-on**: Build graph-based recommendation system
- **Assessment**: Graph database project

---

## Module 10: Troubleshooting and Best Practices (Week 11)

### 10.1 Common Issues and Solutions

- **Learning Objectives**: Diagnose and resolve common problems
- **Topics**:
    - Memory issues and OOM errors
    - Performance degradation troubleshooting
    - Connection and timeout issues
    - Data corruption and recovery
    - Replication lag problems
- **Hands-on**: Troubleshoot simulated issues
- **Assessment**: Troubleshooting scenarios

### 10.2 Best Practices

- **Learning Objectives**: Apply Redis best practices
- **Topics**:
    - Design patterns and anti-patterns
    - Naming conventions and organization
    - Testing strategies for Redis applications
    - Documentation and maintenance
    - Code review guidelines
- **Hands-on**: Review and refactor existing code
- **Assessment**: Best practices audit

### 10.3 Migration Strategies

- **Learning Objectives**: Plan and execute Redis migrations
- **Topics**:
    - Data migration techniques
    - Version upgrade procedures
    - Zero-downtime migration strategies
    - Rollback procedures
    - Testing migration processes
- **Hands-on**: Plan and execute a migration
- **Assessment**: Migration planning exercise

---

## Module 11: Advanced Administration (Week 12)

### 11.1 Advanced Monitoring and Alerting

- **Learning Objectives**: Implement comprehensive monitoring
- **Topics**:
    - Custom metrics and dashboards
    - Alerting strategies
    - Capacity planning
    - Performance trending
    - Integration with monitoring systems
- **Hands-on**: Build comprehensive monitoring solution
- **Assessment**: Monitoring system implementation

### 11.2 Automation and DevOps

- **Learning Objectives**: Automate Redis operations
- **Topics**:
    - Infrastructure as Code (Terraform, Ansible)
    - CI/CD pipeline integration
    - Automated testing strategies
    - Configuration management
    - Deployment automation
- **Hands-on**: Create automated deployment pipeline
- **Assessment**: Automation implementation

### 11.3 Capacity Planning and Scaling

- **Learning Objectives**: Plan for growth and scaling
- **Topics**:
    - Capacity planning methodologies
    - Scaling strategies and decision points
    - Cost optimization techniques
    - Performance benchmarking
    - Future-proofing considerations
- **Hands-on**: Create capacity planning model
- **Assessment**: Scaling strategy presentation

---

## Final Project

### Capstone Project: Enterprise Redis Implementation

- **Objective**: Design and implement a complete Redis solution for a real-world scenario
- **Requirements**:
    - Multi-tier architecture with appropriate data structures
    - High availability and disaster recovery
    - Monitoring and alerting
    - Security implementation
    - Performance optimization
    - Documentation and testing
- **Deliverables**:
    - Complete implementation
    - Architecture documentation
    - Deployment guide
    - Testing strategy
    - Presentation to peers

---

## Assessment Methods

### Continuous Assessment (60%)

- Weekly quizzes and exercises
- Hands-on projects and implementations
- Code reviews and peer assessments
- Participation in discussions and forums

### Major Projects (30%)

- Module-end projects
- Integration projects
- Performance optimization case studies
- Troubleshooting scenarios

### Final Capstone (10%)

- Comprehensive enterprise implementation
- Presentation and documentation
- Peer review and feedback

---

## Resources and Tools

### Essential Tools

- Redis server (latest stable version)
- Redis CLI
- Redis Desktop Manager or RedisInsight
- Docker and Docker Compose
- Monitoring tools (Prometheus, Grafana)

### Programming Languages

- Python (redis-py)
- Node.js (node_redis, ioredis)
- Java (Jedis, Lettuce)
- Optional: Go, C#, PHP clients

### Documentation and References

- Official Redis documentation
- Redis University courses
- Redis community forums
- Stack Overflow Redis tags
- GitHub repositories and examples

### Cloud Platforms

- AWS ElastiCache
- Google Cloud Memorystore
- Azure Cache for Redis
- DigitalOcean Managed Databases

---

## Certification Path

Upon completion of this syllabus, students will be prepared for:

- Redis Certified Developer exam
- Cloud provider Redis certifications (AWS, Google Cloud, Azure)
- Industry recognition as Redis expert
- Advanced Redis consulting and architecture roles

---

## Maintenance and Updates

This syllabus will be updated regularly to reflect:

- New Redis features and versions
- Emerging best practices
- Industry trends and use cases
- Student feedback and learning outcomes
- Technology ecosystem changes

Last updated: July 2025 Version: 1.0