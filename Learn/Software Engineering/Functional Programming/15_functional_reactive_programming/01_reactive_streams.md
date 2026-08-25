## Reactive Streams


Reactive streams provide a standard for asynchronous stream processing with non-blocking backpressure. They define a minimal set of interfaces, methods, and protocols that describe the necessary operations and entities to achieve asynchronous streams of data with backpressure.

The specification addresses the problem of handling streams of data where the producer might generate data faster than the consumer can process it. Without backpressure mechanisms, this leads to resource exhaustion, dropped data, or system instability.

**Core Components:**

The reactive streams specification defines four primary interfaces:

**Publisher** - A provider of a potentially unbounded number of sequenced elements, publishing them according to the demand received from its subscribers. The Publisher interface contains a single method: `subscribe(Subscriber)`, which allows subscribers to register themselves to receive elements.

**Subscriber** - Receives and processes elements from a Publisher. The Subscriber interface defines four methods:

- `onSubscribe(Subscription)` - Called when the subscription is established
- `onNext(T)` - Delivers the next element in the stream
- `onError(Throwable)` - Signals that the Publisher has encountered an error
- `onComplete()` - Signals successful completion with no more elements

**Subscription** - Represents a one-to-one lifecycle of a Subscriber subscribing to a Publisher. It provides two methods:

- `request(long n)` - Requests n elements from the upstream Publisher (backpressure control)
- `cancel()` - Allows the Subscriber to cancel the subscription

**Processor** - Represents a processing stage that is both a Subscriber and a Publisher, obeying the contracts of both interfaces. Processors enable stream transformation and composition.

**Backpressure Mechanics:**

The flow control mechanism operates through the `request(n)` method. When a Subscriber calls `request(n)`, it signals to the Publisher that it can handle n more elements. This creates a pull-based model within a push-based paradigm:

1. Subscriber establishes subscription and requests initial batch
2. Publisher emits up to the requested number of elements
3. Subscriber processes elements and requests more when ready
4. Publisher respects the outstanding demand, never exceeding it

**Demand Tracking:**

Publishers must track outstanding demand across all subscribers. The cumulative demand represents the maximum number of `onNext` signals that can be sent. Demand is additive - multiple `request(n)` calls accumulate unless Long.MAX_VALUE is reached, which represents unbounded demand.

**Signal Ordering:**

Reactive streams enforce strict ordering guarantees:

- `onSubscribe` must be called before any other signals
- `onNext` signals must not be interleaved for the same Subscriber
- Terminal signals (`onComplete` or `onError`) must be the final signal
- After a terminal signal, no further signals are permitted

**Error Handling:**

Errors flow downstream through `onError` signals. When an error occurs:

- The Publisher immediately terminates the subscription
- The error signal replaces the normal completion
- Subscribers must handle errors appropriately to prevent cascade failures
- Processors receiving errors should propagate them downstream after cleanup

**Thread Safety:**

The specification requires that Publishers handle Subscriber signals in a thread-safe, serialized manner. While the Publisher may execute on any thread, signals to a single Subscriber must exhibit happens-before relationships - no concurrent calls to the same Subscriber's methods.

**Implementation Considerations:**

Publishers should implement efficient queueing mechanisms for demand management. Common strategies include:

- Bounded queues with overflow handling
- Buffering strategies (drop oldest, drop newest, block)
- Request batching to reduce coordination overhead
- Prefetching to minimize latency while respecting demand

The specification intentionally remains minimal to allow diverse implementations while ensuring interoperability. Libraries like RxJava, Project Reactor, and Akka Streams all implement the reactive streams specification, enabling seamless composition across different reactive frameworks.

