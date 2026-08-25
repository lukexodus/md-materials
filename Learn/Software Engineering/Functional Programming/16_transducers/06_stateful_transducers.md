## Stateful Transducers


Stateful transducers maintain internal state across reduction steps, enabling transformations that depend on previous inputs or accumulated context. Unlike stateless transducers that treat each element independently, stateful variants track information in mutable references (typically volatiles) closed over by the reducing function.

**State management pattern:**

```clojure
(defn partition-all [n]
  (fn [rf]
    (let [buffer (volatile! [])]
      (fn
        ([] (rf))
        ([result]
         (let [final-buffer @buffer]
           (vreset! buffer [])
           (if (seq final-buffer)
             (rf (rf result final-buffer))
             (rf result))))
        ([result input]
         (let [new-buffer (conj @buffer input)]
           (if (= n (count new-buffer))
             (do
               (vreset! buffer [])
               (rf result new-buffer))
             (do
               (vreset! buffer new-buffer)
               result))))))))
```

The volatile provides mutable storage with minimal overhead compared to atoms. State persists across invocations of the step function (arity-2) but remains encapsulated within the transducer's closure, preventing external interference.

**Completion function criticality:**

The arity-1 completion function is essential for stateful transducers. It handles any remaining state when the input sequence exhausts. For `partition-all`, this means emitting the final incomplete partition. Forgetting to flush state in completion leads to silent data loss.

```clojure
(transduce (partition-all 3) conj [] [1 2 3 4 5])
;; => [[1 2 3] [4 5]]
;; The [4 5] only appears because completion flushed the buffer
```

**Common stateful patterns:**

- **Windowing**: `partition-all`, `partition-by` maintain buffers of elements
- **Deduplication**: `dedupe` remembers the previous element to detect duplicates
- **Indexed transformations**: `map-indexed` tracks the current index
- **Throttling**: Rate-limiting transducers track timing information
- **Accumulation**: Running totals or statistics across elements

**Composition considerations:**

Multiple stateful transducers compose cleanly—each maintains its own independent state. However, order matters significantly. A `take` before `partition-all` affects how many partitions form, while reversing the order changes which elements survive.

Stateful transducers are not thread-safe when the same transducer instance processes multiple sequences concurrently. Each call to `transduce`, `into`, or `sequence` must receive a fresh transducer (created by calling the transducer-returning function) to ensure isolated state.

