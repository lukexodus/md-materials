## Queuing Mechanisms


Queuing algorithms determine how packets are stored, prioritized, and forwarded when network congestion occurs.

**First-In-First-Out (FIFO)** The simplest queuing method where packets are processed in arrival order. While easy to implement, FIFO provides no differentiation between traffic types and can lead to head-of-line blocking.

**Priority Queuing (PQ)** Implements multiple queues with strict priority levels. Higher priority queues are always serviced before lower priority ones. While providing excellent delay characteristics for high-priority traffic, PQ can starve lower-priority traffic during congestion.

**Weighted Fair Queuing (WFQ)** Allocates bandwidth fairly among active flows by maintaining separate queues for each flow and serving them in a round-robin fashion weighted by packet size. WFQ automatically provides more bandwidth to flows with larger packets while ensuring fairness.

**Class-Based Weighted Fair Queuing (CBWFQ)** Extends WFQ by allowing manual configuration of traffic classes and bandwidth allocation. Administrators can define classes based on various criteria and assign minimum bandwidth guarantees to each class.

**Low Latency Queuing (LLQ)** Combines CBWFQ with a strict priority queue for delay-sensitive traffic. The priority queue is policed to prevent starvation of other queues, while remaining queues use CBWFQ scheduling.

**Weighted Round Robin (WRR)** Services queues in a round-robin fashion with different weights assigned to each queue. The weight determines how many packets or bytes are dequeued from each queue during each service cycle.

