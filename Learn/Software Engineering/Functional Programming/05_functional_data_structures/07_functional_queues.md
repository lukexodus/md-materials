## Functional Queues


Functional queues are immutable FIFO (First-In-First-Out) data structures that support efficient enqueue and dequeue operations while preserving previous versions. Unlike mutable queues, operations return new queue instances with structural sharing, enabling persistent access to queue states.

### Naive Implementation Limitations

A straightforward immutable queue using a single list faces performance problems. Enqueueing at the end requires O(n) traversal to reach the tail. While dequeueing from the front is O(1), the asymmetry makes the structure impractical for real-world use.

**Example:**

```haskell
-- Inefficient single-list queue
type NaiveQueue a = [a]

enqueue :: a -> NaiveQueue a -> NaiveQueue a
enqueue x queue = queue ++ [x]  -- O(n) - traverses entire list

dequeue :: NaiveQueue a -> Maybe (a, NaiveQueue a)
dequeue [] = Nothing
dequeue (x:xs) = Just (x, xs)  -- O(1) - simple pattern match
```

### Two-List Implementation

Efficient functional queues use two lists: a front list for dequeuing and a rear list for enqueuing. Elements enqueue onto the rear in O(1) time. When the front empties during dequeue, the rear list is reversed and becomes the new front, amortizing the reversal cost across operations.

**Example:**

```scala
// Scala functional queue implementation
case class Queue[A](front: List[A], rear: List[A]) {
  def enqueue(x: A): Queue[A] = 
    Queue(front, x :: rear)
  
  def dequeue: Option[(A, Queue[A])] = front match {
    case Nil => rear.reverse match {
      case Nil => None
      case h :: t => Some((h, Queue(t, Nil)))
    }
    case h :: t => Some((h, Queue(t, rear)))
  }
  
  def isEmpty: Boolean = front.isEmpty && rear.isEmpty
}

// Usage
val q1 = Queue(List.empty[Int], List.empty[Int])
val q2 = q1.enqueue(1).enqueue(2).enqueue(3)
val Some((first, q3)) = q2.dequeue  // first = 1
```

**Output:**

```
first = 1
q3 = Queue(List(2, 3), List())
```

### Amortized Analysis

The two-list queue achieves amortized O(1) performance for both enqueue and dequeue. While reversing the rear list is O(n), each element is reversed at most once across all operations. The cost distributes across subsequent operations, resulting in constant amortized time.

**Key Points:**

- Enqueue: Always O(1) - prepend to rear list
- Dequeue: Amortized O(1) - occasional O(n) reversal amortized over many operations
- The reversal happens only when front empties
- Each element participates in exactly one reversal
- Total cost for n operations is O(n), yielding O(1) amortized per operation

### Banker's Queue Optimization

Banker's queue improves on the two-list approach by maintaining size invariants. It ensures the front list is always at least as long as the rear, triggering incremental rebalancing before the front empties completely. This provides better worst-case guarantees while maintaining amortized efficiency.

**Example:**

```ocaml
(* OCaml banker's queue *)
type 'a queue = {
  front: 'a list;
  rear: 'a list;
  front_size: int;
  rear_size: int;
}

let check q =
  if q.rear_size <= q.front_size then q
  else {
    front = q.front @ List.rev q.rear;
    rear = [];
    front_size = q.front_size + q.rear_size;
    rear_size = 0;
  }

let enqueue x q =
  check { q with rear = x :: q.rear; rear_size = q.rear_size + 1 }

let dequeue q = match q.front with
  | [] -> None
  | h :: t -> Some (h, check { q with front = t; front_size = q.front_size - 1 })
```

### Real-Time Queue

Real-time queues provide O(1) worst-case bounds using lazy evaluation and incremental rotation. Rather than reversing the entire rear list at once, rotation proceeds incrementally across operations. This eliminates amortization, guaranteeing constant time for individual operations.

The implementation uses streams (lazy lists) and maintains a rotation schedule that completes the reversal over multiple operations. Each operation performs a small, constant amount of rotation work.

**Example:**

```haskell
-- Haskell real-time queue with lazy evaluation
data Queue a = Queue [a] [a] [a]  -- front, rear, rotation schedule

enqueue :: a -> Queue a -> Queue a
enqueue x (Queue f r s) = check (Queue f (x:r) s)

dequeue :: Queue a -> Maybe (a, Queue a)
dequeue (Queue [] _ _) = Nothing
dequeue (Queue (x:f) r s) = Just (x, check (Queue f r s))

check :: Queue a -> Queue a
check (Queue f r []) = let f' = rotate f r [] in Queue f' [] f'
check (Queue f r (_:s)) = Queue f r s

rotate :: [a] -> [a] -> [a] -> [a]
rotate [] (y:_) acc = y : acc
rotate (x:xs) (y:ys) acc = x : rotate xs ys (y:acc)
```

### Persistent Access Benefits

Immutable queues enable access to multiple queue versions simultaneously. This supports scenarios like backtracking, undo functionality, and speculative execution where different execution paths maintain separate queue states.

**Example:**

```clojure
;; Clojure PersistentQueue
(def q1 (conj clojure.lang.PersistentQueue/EMPTY 1 2 3))
(def q2 (pop q1))
(def q3 (conj q2 4))

;; All versions coexist
(peek q1)  ; => 1
(peek q2)  ; => 2  
(peek q3)  ; => 2

;; Branching queue states
(def branch-a (conj q2 10))
(def branch-b (conj q2 20))
;; Independent evolution from same ancestor
```

### Pattern Matching and Deconstruction

Functional languages support pattern matching on queue structure, enabling elegant recursive algorithms that process queues element by element while maintaining immutability.

**Example:**

```fsharp
// F# queue pattern matching
let rec processQueue queue =
    match Queue.tryDequeue queue with
    | None -> printfn "Queue empty"
    | Some(item, remaining) ->
        printfn "Processing: %A" item
        processQueue remaining

// Usage
let q = Queue.empty |> Queue.enqueue 1 |> Queue.enqueue 2
processQueue q
```

**Output:**

```
Processing: 1
Processing: 2
Queue empty
```

### Concatenation Operations

Some functional queue implementations support efficient concatenation of two queues. While naive concatenation is O(n), clever implementations using finger trees or other structures can achieve better asymptotic bounds.

**Example:**

```haskell
-- Efficient queue concatenation using finger trees
import Data.Sequence as Seq

q1 = Seq.fromList [1, 2, 3]
q2 = Seq.fromList [4, 5, 6]

combined = q1 >< q2  -- O(log(min(n,m))) concatenation
-- Seq.fromList [1,2,3,4,5,6]

-- Dequeue operations remain efficient
case Seq.viewl combined of
    x :< rest -> -- x = 1, rest = [2,3,4,5,6]
```

### Use Cases

Functional queues excel in scenarios requiring persistent state, concurrent access, or algorithmic backtracking. Common applications include breadth-first search, scheduling systems, message passing, and any domain where queue history matters.

**Example:**

```python
# Breadth-first search with immutable queue (conceptual)
def bfs(graph, start):
    visited = set()
    queue = ImmutableQueue().enqueue(start)
    
    while not queue.is_empty():
        node, queue = queue.dequeue()
        
        if node in visited:
            continue
            
        visited.add(node)
        process(node)
        
        for neighbor in graph[node]:
            queue = queue.enqueue(neighbor)
    
    return visited
```

### Performance Trade-offs

Functional queues sacrifice some raw performance compared to mutable array-based queues but provide persistent access and thread safety. The two-list implementation offers the best balance of simplicity and performance for most applications.

**Key Points:**

- Functional queues provide immutable FIFO with persistent versions
- Two-list implementation achieves O(1) amortized enqueue/dequeue
- Banker's queue improves worst-case behavior with size invariants
- Real-time queues provide O(1) worst-case via lazy evaluation
- Enable multiple concurrent queue versions safely
- Support pattern matching and functional decomposition
- Choose based on persistence needs versus raw performance requirements

