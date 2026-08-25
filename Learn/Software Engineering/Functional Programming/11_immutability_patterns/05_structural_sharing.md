## Structural sharing


Structural sharing reuses unchanged portions of data structures across versions, making immutability efficient. When creating a modified version, only the changed path from root to modified element is copied—all other structure is shared between versions. This achieves O(log n) space and time overhead instead of O(n) full copying.

**Mechanism in trees:**

Consider a binary tree with 1 million nodes. Updating one leaf requires copying approximately 20 nodes (the path from root to leaf in a balanced tree), while sharing the remaining 999,980 nodes. Both old and new tree versions share 99.998% of their structure.

```haskell
-- Original tree
original = Node 5
    (Node 3 (Node 1 ...) (Node 4 ...))
    (Node 8 (Node 6 ...) (Node 9 ...))

-- Updated tree (changing Node 1 to Node 2)
updated = Node 5                           -- New node (copied)
    (Node 3 (Node 2 ...) (Node 4 ...))    -- New left subtree (copied)
    (Node 8 (Node 6 ...) (Node 9 ...))    -- Shared right subtree (original pointer)
```

The updated version reuses the entire right subtree. If multiple threads or functions hold references to `original`, they're unaffected by the update creating `updated`. Both versions coexist safely.

**Sharing in list operations:**

Lists achieve maximal sharing because prepending creates a new head that points to the existing tail. The tail is completely shared—no copying occurs.

```haskell
original = [1, 2, 3, 4, 5]
extended = 0 : original  -- Only allocates one new cons cell
```

The `extended` list shares all five nodes from `original`. This makes prepending O(1) time and space. Operations like `take`, `drop`, and `tail` similarly create new list heads while sharing tails.

However, appending to a list requires copying the entire first list to point its last element to the second list. This asymmetry explains why functional code prefers prepending and processes lists left-to-right.

**Map and set sharing:**

Persistent hash maps share structure at hash bucket granularity. When updating a key, only the path through the trie to that key's bucket is copied. All other buckets remain shared.

```scala
val map1 = Map("a" -> 1, "b" -> 2, "c" -> 3, /* ...1000s more entries */)
val map2 = map1.updated("a", 10)  // Only copies path to "a", shares rest
```

If `map1` has 10,000 entries organized in a 6-level trie, updating one entry copies approximately 6 nodes (one per level) and shares the rest. The space overhead is logarithmic in map size, not linear.

**String sharing:**

Strings in functional languages often use structural sharing for substrings. Taking a substring doesn't copy characters—it creates a new string object pointing into the original's character buffer with different offset and length.

```haskell
-- Conceptual representation
original = "The quick brown fox jumps"
substring = take 9 (drop 4 original)  -- "quick bro"
-- substring shares original's character array
```

This makes substring operations O(1) instead of O(n). However, it also means small substrings can keep large original strings alive in memory, requiring care in long-running programs.

**Sharing in record updates:**

Updating record fields creates new records that share unchanged fields. Languages with immutable records optimize this with shallow copying.

```ocaml
type person = { name: string; age: int; address: string }

let original = { name = "Alice"; age = 30; address = "123 Main" }
let updated = { original with age = 31 }
(* updated shares the name and address strings with original *)
```

Only the record structure itself is copied (typically a small fixed overhead). Field values that are themselves structures (strings, lists, nested records) are shared through pointer copying, not deep copying.

**Memory management implications:**

Structural sharing requires garbage collection to reclaim unused versions. When a version is no longer referenced, the GC identifies which nodes are exclusively owned by that version and reclaims them. Shared nodes remain alive as long as any version references them.

Reference counting struggles with structural sharing because cycles become common. Tracing garbage collectors (mark-and-sweep, generational) handle sharing naturally by identifying all reachable nodes regardless of reference structure.

**Limits of sharing:**

Structural sharing works well for tree-like structures but poorly for arrays. Array updates require copying at least the modified element's container. Persistent vectors partially solve this with tree-based array implementations, but some overhead remains compared to mutable arrays.

Operations that modify many scattered elements lose sharing efficiency. Updating 1000 random elements in a tree requires copying 1000 paths, potentially duplicating significant portions of the tree. Batch operations that collect updates before applying them can mitigate this.

**Sharing visibility and debugging:**

From a logical perspective, structural sharing is invisible—programs behave as if data is copied. From a performance perspective, sharing is crucial for efficiency. Debugging tools may struggle to visualize sharing since multiple variables point to the same memory.

```haskell
-- Logically these appear independent
list1 = [1, 2, 3]
list2 = 0 : list1
list3 = -1 : list1

-- Actually list1's structure is shared by list2 and list3
-- But logically, modifying list2 doesn't affect list3 (because nothing is modified)
```

This separation of logical and physical representation is fundamental to abstraction in functional programming.

