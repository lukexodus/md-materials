## Persistent data structures


Persistent data structures preserve previous versions when modified, creating new versions without destroying old ones. Unlike ephemeral data structures that update in-place, persistent structures maintain all historical versions efficiently through structural sharing. This enables true immutability where operations return new structures while leaving originals unchanged.

**Definition and properties:**

A persistent data structure supports queries on any version ever created. When you "modify" version `v1` to create `v2`, both versions remain accessible and valid. Operations never mutate existing structure—they construct new structure that coexists with the old.

Full persistence allows both querying and modifying any version. Partial persistence only allows querying old versions, with modifications creating new versions from the latest. Confluent persistence allows combining multiple versions, though this is less common in functional programming contexts.

**Implementation strategies:**

Path copying is the simplest persistence technique. To update a node in a tree, copy the node and all ancestors up to the root, leaving other branches untouched. A binary tree update copies O(log n) nodes while sharing the remaining O(n) nodes.

```haskell
data Tree a = Leaf | Node a (Tree a) (Tree a)

insert :: Ord a => a -> Tree a -> Tree a
insert x Leaf = Node x Leaf Leaf
insert x (Node y left right)
    | x < y     = Node y (insert x left) right  -- New node, new left, shared right
    | x > y     = Node y left (insert x right)  -- New node, shared left, new right
    | otherwise = Node y left right             -- Unchanged
```

Each insertion creates a new root and path to the insertion point, but unmodified subtrees are shared between old and new versions. Both versions remain valid tree references.

**Fat nodes and version graphs:**

Fat node techniques store multiple versions of data within nodes, tracking which version each field belongs to. Nodes expand over time, storing timestamps or version identifiers with each field value. Queries specify which version to read.

This approach trades space for time efficiency—updates are fast since they just add to existing nodes, but queries must search through version lists. It works well when few versions exist or when most recent versions are queried most frequently.

**Functional arrays and vectors:**

Arrays present challenges for persistence since updates naturally require mutation. Persistent arrays use trees where leaves contain array segments. Clojure's persistent vectors use 32-way branching tries, achieving effectively constant-time access and updates.

```
Vector structure (simplified):
Root -> [Node Node Node ...]
         |     |     |
         v     v     v
      [Leaf Leaf Leaf ...]
```

Accessing index `i` traverses log₃₂(n) levels, effectively constant for practical sizes. Updates copy the path from root to leaf, sharing all other branches. A vector with millions of elements updates by copying only 5-6 nodes.

**Lazy persistence:**

Lazy evaluation enables persistence without immediate copying. A modification returns a thunk that delays actual construction until accessed. Multiple operations on the same version share computation, and unused versions never materialize.

```haskell
-- Lazy list (stream)
data Stream a = Cons a (Stream a)

numsFrom :: Int -> Stream Int
numsFrom n = Cons n (numsFrom (n + 1))

take :: Int -> Stream a -> [a]
take 0 _ = []
take n (Cons x xs) = x : take (n - 1) xs
```

The stream `numsFrom 1` represents an infinite structure, but only requested elements are computed. Multiple consumers can share the same stream, each traversing at their own pace.

**Hash array mapped tries (HAMT):**

HAMTs provide persistent hash maps with excellent performance characteristics. Keys hash to paths through a wide-branching trie. Each node has up to 32 children selected by 5-bit chunks of the hash code.

Updates copy the path from root to modified leaf, typically 6-7 nodes for maps with millions of entries. Lookups similarly traverse 6-7 nodes. Structural sharing means updating many keys in a map copies only the affected paths, sharing everything else.

**Real-world implementations:**

Clojure's entire standard library uses persistent structures—vectors, maps, sets, and lists all maintain immutability through structural sharing. Updating large collections is practical because only changed portions are copied.

Haskell's standard lists are persistent by nature. Libraries like `Data.Map` and `Data.Set` implement persistent balanced trees. The `vector` package provides efficient persistent arrays.

Scala's immutable collections include persistent vectors, maps, and sets following Clojure's designs. OCaml's standard library provides persistent maps and sets based on balanced trees.

**Performance characteristics:**

Persistent structures typically have logarithmic overhead compared to mutable equivalents—O(log n) instead of O(1) for updates. However, constant factors are small (wide branching reduces tree depth), and practical performance is often comparable to mutable structures.

The real performance advantage comes from concurrency—persistent structures are inherently thread-safe without locking. Multiple threads safely share structure since nothing mutates. This eliminates synchronization overhead and race conditions.

