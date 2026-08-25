## Hot vs Cold Observables


The distinction between hot and cold observables defines when and how observable sequences produce values relative to their subscribers, fundamentally affecting resource management, data sharing, and subscription behavior.

**Cold Observables:**

Cold observables create a new independent execution for each subscriber. The data producer is created inside the observable and is passive—it only starts producing values when subscribed to. Each subscription receives its own isolated stream of values from the beginning.

**Characteristics:**

- Unicast: each subscriber gets independent execution
- Lazy: execution starts only upon subscription
- Reproducible: each subscriber receives the same sequence
- Examples: HTTP requests, timers created with `interval()`, range sequences, observables created with `of()`, `from()`, or `create()`

Cold observables are analogous to functions—calling them multiple times produces independent executions. When you subscribe to a cold observable wrapping an HTTP request, each subscription triggers a separate HTTP request.

**Hot Observables:**

Hot observables share a single execution among all subscribers. The data producer exists outside the observable and is active regardless of subscriptions. Subscribers receive only the values emitted after their subscription, missing earlier emissions.

**Characteristics:**

- Multicast: all subscribers share the same execution
- Eager: may produce values before any subscriptions exist
- Live: subscribers receive values from the point of subscription onward
- Examples: mouse events, WebSocket connections, subjects, observables wrapped with `share()` or `publish()`

Hot observables are analogous to event emitters—multiple listeners receive the same events. When you subscribe to a hot observable of mouse movements, you only receive movements that occur after subscription.

**Converting Cold to Hot:**

The `share()` operator converts cold observables to hot by multicasting to multiple subscribers. The `publish()` operator provides more control, returning a ConnectableObservable that begins execution only when `connect()` is called.

**Example:**

```javascript
// Cold - each subscription triggers a new HTTP request
const cold$ = http.get('/api/data');
cold$.subscribe(data => console.log('Sub 1:', data));
cold$.subscribe(data => console.log('Sub 2:', data)); // Second request

// Hot - single HTTP request shared among subscribers
const hot$ = http.get('/api/data').pipe(share());
hot$.subscribe(data => console.log('Sub 1:', data));
hot$.subscribe(data => console.log('Sub 2:', data)); // No second request
```

**[Inference]** The temperature analogy suggests that cold observables must be "warmed up" (subscribed to) before producing values, while hot observables are already "warm" (producing values). However, this is conceptual reasoning about naming conventions rather than confirmed etymology.

**Practical Implications:**

Choosing between hot and cold affects performance, resource usage, and data consistency. Cold observables ensure each subscriber gets complete data but may duplicate expensive operations. Hot observables optimize resource usage but may cause late subscribers to miss data. Selecting the appropriate temperature requires analyzing whether shared execution or independent execution better serves the use case.

