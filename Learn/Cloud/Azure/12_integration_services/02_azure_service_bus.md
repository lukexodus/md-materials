## Azure Service Bus


Service Bus is a fully managed enterprise message broker service that provides reliable message delivery between applications and services. It supports both queue-based and topic-based messaging patterns for decoupled communication.

**Key Points:**

- Guaranteed message delivery with at-least-once semantics
- Support for transactions and duplicate detection
- Advanced features like message sessions and dead letter queues
- Integration with Azure Active Directory for authentication
- Support for both standard and premium tiers with different performance characteristics

**Messaging Patterns:**

- **Queues**: Point-to-point communication with FIFO message delivery
- **Topics and Subscriptions**: Publish-subscribe pattern for one-to-many communication
- **Relays**: Hybrid connectivity for on-premises services

**Advanced Features:**

- Message deferral and scheduled delivery
- Auto-forwarding between queues and subscriptions
- Duplicate detection based on message properties
- Session-based message processing for stateful scenarios

**Example:** An e-commerce platform uses Service Bus queues to handle order processing, where the web application sends order messages to a queue, and multiple backend services process these messages asynchronously to update inventory, charge payments, and fulfill orders.

