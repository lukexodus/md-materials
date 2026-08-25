## Erlang concepts


Erlang is a pure functional language built on the actor model, designed for building massively concurrent, distributed, and fault-tolerant systems. Its design philosophy centers around "let it crash" supervision trees and hot code swapping.

**Immutability and Single Assignment**

Variables in Erlang can only be assigned once. Once bound, a variable cannot be rebound within the same scope. Pattern matching against already-bound variables checks for equality rather than performing assignment. This eliminates entire classes of bugs related to state mutation and makes concurrent code naturally safe.

**Process-Based Concurrency**

Processes are Erlang's fundamental unit of concurrency—not OS threads but lightweight processes managed by the BEAM virtual machine. Each process has its own heap and garbage collector, with millions of processes running simultaneously on commodity hardware. Process creation overhead is minimal (microseconds), and each process consumes only a few kilobytes. Processes communicate exclusively through asynchronous message passing with mailboxes, ensuring complete isolation and share-nothing architecture.

**Pattern Matching and Guards**

Pattern matching is deeply integrated into function clauses, case expressions, and receive blocks. Multiple function clauses with different patterns enable elegant handling of different data shapes. Guards extend pattern matching with boolean conditions, type checks, and arithmetic comparisons. The pattern matching occurs top-to-bottom, with the first matching clause executing.

**Tail Call Optimization**

The BEAM VM guarantees tail call optimization, making recursive functions as memory-efficient as loops. Tail-recursive functions don't accumulate stack frames, enabling infinite recursion patterns for long-running server processes. Accumulator-passing style transforms naturally recursive algorithms into tail-recursive equivalents.

**OTP Framework**

OTP (Open Telecom Platform) provides battle-tested abstractions for building reliable systems. GenServer implements client-server patterns with synchronous and asynchronous calls. Supervisors monitor processes and restart them according to configurable strategies (one-for-one, one-for-all, rest-for-one). Applications package related processes and supervision trees into deployable units. The supervision tree hierarchy creates self-healing systems where failures are isolated and recovered automatically.

**Hot Code Loading**

The BEAM supports loading new code versions while the system runs. Two versions of a module can coexist, allowing gradual migration. Processes using old code continue until they make a fully-qualified function call, triggering migration to the new version. This enables zero-downtime deployments for long-running systems.

**Distribution and Location Transparency**

Processes on different nodes communicate identically to local processes. PIDs work across node boundaries with full transparency. Distribution is built into the language runtime, not bolted on. Nodes form a mesh network with full connectivity, though you can configure hidden nodes and custom topologies.

**Fault Tolerance Philosophy**

"Let it crash" means processes should fail fast rather than handling every possible error. Supervisors detect failures through process links and monitors, restarting failed processes to known good states. This approach separates error handling (supervisor responsibility) from business logic (worker responsibility). The result is cleaner code and more robust systems than defensive programming approaches.

**Binary Pattern Matching**

Erlang excels at parsing and constructing binary data through binary pattern matching syntax. You can match on specific bit sizes, byte boundaries, and data types within binary structures. This makes protocol implementation and binary format parsing remarkably concise and efficient.

**ETS and DETS**

ETS (Erlang Term Storage) provides in-memory tables with constant-time or logarithmic lookup, supporting sets, bags, and duplicate bags. DETS extends this to disk storage. These provide shared mutable state carefully controlled through table ownership and access rights, offering performance-critical escape hatches while maintaining functional principles in process logic.

