## Amazon SNS (Simple Notification Service)


Amazon SNS is a fully managed pub/sub messaging service that enables message filtering, fanout, and delivery to multiple subscriber types. SNS supports application-to-application communication through topics and application-to-person communication through SMS, email, and push notifications.

### Topics and Subscription Models

SNS topics serve as communication channels for sending messages to multiple subscribers simultaneously. Publishers send messages to topics without knowledge of specific subscribers, enabling loose coupling between application components. Topics support various subscription types including HTTP/HTTPS endpoints, email, SMS, SQS queues, Lambda functions, and mobile push notifications.

Standard topics provide high throughput, at-least-once delivery, and best-effort ordering. These topics support unlimited throughput and are suitable for most pub/sub scenarios where occasional duplicate messages are acceptable.

FIFO topics maintain strict message ordering and provide exactly-once delivery to FIFO SQS queue subscribers. FIFO topics support up to 300 transactions per second without batching or 3,000 transactions per second with batching. These topics ensure message ordering preservation throughout the delivery chain.

### Message Filtering and Routing

Message filtering enables subscribers to receive only messages matching specific criteria, reducing unnecessary message processing and improving application efficiency. Filter policies use JSON syntax to define matching criteria based on message attributes.

Filter policies support various operators including exact matching, numeric ranges, prefix matching, and existence checks. Complex filtering logic can combine multiple conditions using logical operators, enabling sophisticated message routing scenarios.

Attribute-based filtering occurs at the SNS service level, reducing bandwidth costs and processing overhead by delivering only relevant messages to subscribers. This capability is particularly valuable for microservices architectures where different services require different subsets of events.

### Delivery Protocols and Reliability

SNS supports multiple delivery protocols optimized for different use cases. HTTP/HTTPS endpoints enable integration with web applications and API gateways. SQS integration provides reliable message delivery with built-in retry mechanisms and dead letter queue support.

Lambda integration enables serverless message processing with automatic scaling and error handling. Email and SMS protocols support human notification scenarios with customizable message formatting and delivery preferences.

Mobile push notifications support iOS, Android, Windows, and Amazon Fire platforms through platform-specific push notification services. SNS handles platform differences and provides unified APIs for multi-platform mobile application development.

Delivery retry policies automatically handle temporary failures with exponential backoff strategies. Delivery status logging provides visibility into successful and failed deliveries, enabling monitoring and troubleshooting of message delivery issues.

### Message Security and Access Control

SNS topic policies control publisher and subscriber access using AWS Identity and Access Management integration. Fine-grained permissions enable secure multi-tenant scenarios where different applications can publish and subscribe to shared topics with appropriate authorization.

Message encryption protects sensitive data during transit and at rest. Server-side encryption uses AWS KMS keys to encrypt message bodies and attributes. Client-side encryption enables applications to encrypt messages before publishing for end-to-end security.

Cross-region message delivery enables global application architectures with centralized event publishing and distributed processing. Regional topic replication supports disaster recovery scenarios and improves message delivery performance for global audiences.

