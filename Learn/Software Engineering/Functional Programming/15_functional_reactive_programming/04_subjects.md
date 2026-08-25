## Subjects


Subjects are a special type of Observable that act as both an observer and an observable simultaneously. They serve as a bridge or proxy, allowing values to be multicasted to multiple observers. Unlike regular observables which are unicast (each subscribed observer owns an independent execution), subjects are multicast (multiple observers share the same execution).

**Core Characteristics:**

Subjects maintain an internal list of observers and broadcast values to all subscribed observers when `next()` is called. They can be used to convert cold observables into hot observables, and they provide imperative methods (`next()`, `error()`, `complete()`) for pushing values into the stream.

**Types of Subjects:**

**Subject** - The basic subject broadcasts values to all current subscribers but doesn't retain any state. New subscribers only receive values emitted after their subscription.

**BehaviorSubject** - Stores the latest emitted value and immediately sends it to new subscribers. Requires an initial value upon creation. Useful for representing "current state" that new observers need immediately.

**ReplaySubject** - Buffers a specified number of values (or all values within a time window) and replays them to new subscribers. The buffer size and time window can be configured. Essential when late subscribers need historical context.

**AsyncSubject** - Only emits the last value when the sequence completes. If the sequence never completes, subscribers receive nothing. Useful for representing the final result of an async operation.

**Usage Patterns:**

Subjects are commonly used for event buses, shared state management, and converting imperative code to reactive streams. They allow external code to push values into a reactive pipeline. However, subjects should be used judiciously as they introduce imperative control flow into otherwise declarative reactive code, potentially making the data flow harder to trace.

**Example:**

```javascript
const subject = new Subject();

subject.subscribe(x => console.log('Observer A:', x));
subject.next(1); // Observer A: 1

subject.subscribe(x => console.log('Observer B:', x));
subject.next(2); // Observer A: 2, Observer B: 2

const behaviorSubject = new BehaviorSubject(0);
behaviorSubject.subscribe(x => console.log('Initial:', x)); // Initial: 0
behaviorSubject.next(1); // Initial: 1
```

