## Infinite Data Structures


Infinite data structures represent unbounded sequences or collections that can be traversed indefinitely. Laziness makes these practical by computing only the required portions.

### Infinite Streams

Streams are lazy sequences where the tail is computed on-demand, enabling representation of infinite sequences.

**Example:**

```javascript
function repeat(value) {
  return LazyList.cons(value, () => repeat(value));
}

function cycle(list) {
  function cycleFrom(current, original) {
    if (current === null) {
      return cycleFrom(original, original);
    }
    return LazyList.cons(current.head, () => cycleFrom(current.tail, original));
  }
  return cycleFrom(list, list);
}

function iterate(fn, initial) {
  return LazyList.cons(initial, () => iterate(fn, fn(initial)));
}

const powersOfTwo = iterate(x => x * 2, 1);
console.log(take(8, powersOfTwo));

const repeatedABC = cycle(
  LazyList.cons('A', () => 
    LazyList.cons('B', () => 
      LazyList.cons('C', () => null)
    )
  )
);
console.log(take(7, repeatedABC));
```

**Output:**

```
[1, 2, 4, 8, 16, 32, 64, 128]
['A', 'B', 'C', 'A', 'B', 'C', 'A']
```

### Infinite Trees

Trees with infinite depth or breadth, useful for representing game trees, decision trees, or mathematical structures.

**Example:**

```javascript
class InfiniteTree {
  constructor(value, childrenThunk) {
    this.value = value;
    this._childrenThunk = childrenThunk;
    this._childrenCache = null;
  }
  
  get children() {
    if (this._childrenCache === null) {
      this._childrenCache = this._childrenThunk();
    }
    return this._childrenCache;
  }
}

// Infinite binary tree of natural numbers
function numberTree(n) {
  return new InfiniteTree(
    n,
    () => [numberTree(2 * n), numberTree(2 * n + 1)]
  );
}

function treeLevel(tree, depth) {
  if (depth === 0) return [tree.value];
  return tree.children.flatMap(child => treeLevel(child, depth - 1));
}

const tree = numberTree(1);
console.log(treeLevel(tree, 0));  // Root
console.log(treeLevel(tree, 1));  // Level 1
console.log(treeLevel(tree, 2));  // Level 2
console.log(treeLevel(tree, 3));  // Level 3
```

**Output:**

```
[1]
[2, 3]
[4, 5, 6, 7]
[8, 9, 10, 11, 12, 13, 14, 15]
```

### Corecursion and Productivity

Corecursion generates infinite structures by defining how to produce the next element, opposite to recursion which breaks down finite structures.

**Key Points:**

- Productive corecursion always produces at least one element
- Enables definition of infinite structures through self-reference
- Guarded by constructors to ensure termination at each step
- Must satisfy productivity conditions to avoid infinite loops

**Example:**

```javascript
// Hamming numbers: infinite stream of numbers with only 2, 3, 5 as prime factors
function merge(list1, list2) {
  if (list1 === null) return list2;
  if (list2 === null) return list1;
  
  if (list1.head < list2.head) {
    return LazyList.cons(list1.head, () => merge(list1.tail, list2));
  } else if (list1.head > list2.head) {
    return LazyList.cons(list2.head, () => merge(list1, list2.tail));
  } else {
    return LazyList.cons(list1.head, () => merge(list1.tail, list2.tail));
  }
}

function scaleList(factor, list) {
  return map(x => x * factor, list);
}

const hamming = LazyList.cons(1, () =>
  merge(
    scaleList(2, hamming),
    merge(
      scaleList(3, hamming),
      scaleList(5, hamming)
    )
  )
);

console.log(take(20, hamming));
```

**Output:**

```
[1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 25, 27, 30, 32, 36]
```

### Circular Data Structures

Self-referential infinite structures using tying-the-knot technique.

**Example:**

```javascript
// Create circular list: [1, 2, 3, 1, 2, 3, ...]
function createCircular() {
  let circularList;
  circularList = LazyList.cons(1, () =>
    LazyList.cons(2, () =>
      LazyList.cons(3, () => circularList)
    )
  );
  return circularList;
}

const circular = createCircular();
console.log(take(10, circular));
```

**Output:**

```
[1, 2, 3, 1, 2, 3, 1, 2, 3, 1]
```

