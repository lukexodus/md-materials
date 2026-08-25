## Garbage Collection Algorithms


Garbage collection automatically identifies and reclaims memory that programs can no longer access. Different algorithms employ various strategies to balance collection efficiency, pause times, and memory overhead.

### Reference Counting

Reference counting maintains a count of references to each object, deallocating objects immediately when their reference count reaches zero. This approach provides prompt memory reclamation and predictable behavior but cannot handle cyclic references without additional mechanisms.

Reference counting implementation requires:

- Counter maintenance on every reference assignment
- Immediate deallocation when counts reach zero
- Cycle detection mechanisms for cyclic data structures
- Efficient counter update operations

**Example** reference counting challenges:

```
// Cyclic reference problem
class Node {
    Node next;
}

Node a = new Node();
Node b = new Node();
a.next = b;
b.next = a;
// Neither object can be collected despite being unreachable
```

### Mark and Sweep Collection

Mark and sweep collection operates in two phases: marking all reachable objects starting from program roots, then sweeping through memory to reclaim unmarked objects. This approach handles cyclic references naturally but requires stopping program execution during collection.

The marking phase traverses all reachable objects from root references (global variables, stack variables, registers), setting mark bits to indicate reachability. The sweep phase examines all allocated objects, deallocating unmarked objects and clearing mark bits for the next collection cycle.

Mark and sweep provides complete garbage collection but suffers from potentially long pause times proportional to heap size. Fragmentation can also become problematic as objects are deallocated non-contiguously.

### Copying Collection

Copying collection divides memory into two equal semi-spaces, allocating objects in one space while keeping the other empty. During collection, reachable objects are copied from the active space to the inactive space, then the roles of the spaces are swapped.

Copying collection provides automatic defragmentation and fast allocation through simple pointer bumping. Collection time is proportional to the amount of live data rather than total heap size. However, it requires twice as much memory and has higher overhead for programs with many long-lived objects.

### Generational Collection

Generational collection exploits the observation that most objects die young by dividing the heap into generations based on object age. Younger generations are collected more frequently than older generations, focusing collection effort where it's most beneficial.

Typical generational systems use:

- Nursery (generation 0) for newly allocated objects
- Intermediate generations for objects that survive several collections
- Old generation for long-lived objects

Intergenerational references are tracked using write barriers or card marking to ensure collection correctness when younger generations reference older objects.

**Key points** for generational collection:

- Exploits temporal locality of object lifetimes
- Reduces collection frequency for long-lived objects
- Requires tracking intergenerational references
- Achieves good performance for typical allocation patterns

### Incremental and Concurrent Collection

Incremental collection interleaves small collection steps with program execution to reduce pause times. The collector performs limited work during each incremental step, spreading collection overhead across program execution.

Concurrent collection allows programs to continue executing while garbage collection proceeds in parallel. This approach requires sophisticated synchronization to handle objects being modified during collection.

Tricolor marking algorithms support incremental and concurrent collection by categorizing objects as:

- White: not yet examined or determined to be garbage
- Gray: examined but whose references haven't been processed
- Black: examined along with all referenced objects

Write barriers maintain tricolor invariants when programs modify references during concurrent collection.

### Real-Time Garbage Collection

Real-time garbage collection provides bounded pause times suitable for systems with strict timing requirements. These collectors guarantee that individual collection steps complete within specified time bounds.

Real-time collectors typically use incremental techniques with work-based scheduling, performing collection work proportional to allocation activity. Some systems use time-based scheduling with preemptible collection operations.

[Inference] Real-time collection generally involves trade-offs between pause time guarantees and overall collection efficiency compared to batch collectors.

