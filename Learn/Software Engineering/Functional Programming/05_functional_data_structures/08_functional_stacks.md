## Functional Stacks


Functional stacks are immutable LIFO (Last-In-First-Out) data structures that support efficient push and pop operations while preserving all previous versions. They represent one of the simplest and most efficient persistent data structures in functional programming.

### List-Based Implementation

Functional stacks are naturally implemented using immutable linked lists. Pushing adds an element to the front in O(1) time by creating a new list node pointing to the previous list. Popping removes the front element in O(1) by returning the tail. This simplicity makes stacks the canonical example of persistent data structures.

**Example:**

```haskell
-- Haskell stack using built-in list
type Stack a = [a]

push :: a -> Stack a -> Stack a
push x stack = x : stack  -- O(1) prepend

pop :: Stack a -> Maybe (a, Stack a)
pop [] = Nothing
pop (x:xs) = Just (x, xs)  -- O(1) pattern match

peek :: Stack a -> Maybe a
peek [] = Nothing
peek (x:_) = Just x

-- Usage
stack1 = push 1 []           -- [1]
stack2 = push 2 stack1       -- [2,1]
stack3 = push 3 stack2       -- [3,2,1]
Just (top, stack4) = pop stack3  -- top=3, stack4=[2,1]
```

### Structural Sharing Efficiency

Stack operations achieve maximal structural sharing. When pushing, the new stack shares all nodes with the previous stack except the newly added head. When popping, the resulting stack is literally a sublist of the original, requiring no allocation. This makes functional stacks exceptionally space-efficient.

**Example:**

```scala
// Scala immutable stack (List-based)
sealed trait Stack[+A]
case object Empty extends Stack[Nothing]
case class Node[A](head: A, tail: Stack[A]) extends Stack[A]

object Stack {
  def push[A](x: A, stack: Stack[A]): Stack[A] = Node(x, stack)
  
  def pop[A](stack: Stack[A]): Option[(A, Stack[A])] = stack match {
    case Empty => None
    case Node(h, t) => Some((h, t))
  }
}

// Structural sharing demonstration
val s1 = Node(1, Empty)
val s2 = Node(2, s1)
val s3 = Node(3, s2)
// s3, s2, and s1 all share structure
// s3 = [3,2,1], s2 = [2,1], s1 = [1]
```

### Persistent Versions

Immutability enables maintaining multiple stack versions simultaneously. Each push or pop creates a new version while preserving the old. This supports branching computations, undo mechanisms, and parallel exploration of alternatives.

**Example:**

```ocaml
(* OCaml persistent stack versions *)
type 'a stack = 'a list

let s1 = [1]
let s2 = 2 :: s1
let s3 = 3 :: s2

(* Branching from s2 *)
let branch_a = 10 :: s2  (* [10; 2; 1] *)
let branch_b = 20 :: s2  (* [20; 2; 1] *)

(* All versions coexist independently *)
(* s2 = [2; 1], branch_a and branch_b diverge from it *)
```

### Stack-Based Algorithms

Many algorithms naturally express themselves using stacks, including depth-first search, expression evaluation, backtracking, and recursive descent parsing. Functional stacks enable these algorithms while maintaining immutability.

**Example:**

```python
# Depth-first search with immutable stack (conceptual)
def dfs(graph, start):
    visited = set()
    stack = ImmutableStack().push(start)
    
    while not stack.is_empty():
        node, stack = stack.pop()
        
        if node in visited:
            continue
        
        visited.add(node)
        process(node)
        
        # Push neighbors in reverse order for correct traversal
        for neighbor in reversed(graph[node]):
            stack = stack.push(neighbor)
    
    return visited
```

### Expression Evaluation

Stack-based expression evaluation converts infix notation to postfix and evaluates using a stack. Functional stacks naturally model this process with explicit state transitions at each evaluation step.

**Example:**

```fsharp
// F# postfix calculator
let rec evaluate stack tokens =
    match tokens with
    | [] -> List.head stack
    | token :: rest ->
        match token with
        | Num n -> evaluate (n :: stack) rest
        | Add ->
            let b :: a :: remaining = stack
            evaluate ((a + b) :: remaining) rest
        | Mul ->
            let b :: a :: remaining = stack
            evaluate ((a * b) :: remaining) rest

// Evaluate "3 4 + 5 *" = (3 + 4) * 5 = 35
let result = evaluate [] [Num 3; Num 4; Add; Num 5; Mul]
```

**Output:**

```
result = 35
```

### Parenthesis Matching

Stack-based parenthesis matching validates balanced delimiters. Each opening delimiter pushes onto the stack; closing delimiters pop and verify matching types. Functional stacks make the state transitions explicit.

**Example:**

```clojure
;; Clojure parenthesis matcher
(defn balanced? [s]
  (loop [chars (seq s)
         stack '()]
    (if (empty? chars)
      (empty? stack)
      (let [c (first chars)]
        (cond
          (contains? #{\( \[ \{} c)
          (recur (rest chars) (conj stack c))
          
          (contains? #{\) \] \}} c)
          (if (and (seq stack)
                   (matching? (peek stack) c))
            (recur (rest chars) (pop stack))
            false)
          
          :else (recur (rest chars) stack))))))

;; matching? checks if open and close chars correspond
```

### Undo/Redo Mechanisms

Functional stacks naturally implement undo/redo functionality. The undo stack maintains previous states, while redo captures undone states. Each operation creates new stack versions without destroying history.

**Example:**

```scala
// Scala undo/redo system
case class Editor(content: String, undoStack: List[String], redoStack: List[String]) {
  def edit(newContent: String): Editor =
    Editor(newContent, content :: undoStack, List.empty)
  
  def undo: Option[Editor] = undoStack match {
    case Nil => None
    case prev :: rest =>
      Some(Editor(prev, rest, content :: redoStack))
  }
  
  def redo: Option[Editor] = redoStack match {
    case Nil => None
    case next :: rest =>
      Some(Editor(next, content :: undoStack, rest))
  }
}

// Usage
val e1 = Editor("hello", Nil, Nil)
val e2 = e1.edit("hello world")
val e3 = e2.edit("hello world!")
val Some(e4) = e3.undo  // Back to "hello world" 
val Some(e5) = e4.redo // Forward to "hello world!"
````

### Call Stack Simulation

Functional stacks can explicitly model call stacks for interpreters, debuggers, or continuation-based control flow. Each stack frame captures local variables, return addresses, and execution context.

**Example:**
```haskell
-- Haskell explicit call stack for interpreter
data Frame = Frame {
  returnAddr :: Int,
  localVars :: Map String Int,
  savedRegisters :: [Int]
}

type CallStack = [Frame]

pushFrame :: Frame -> CallStack -> CallStack
pushFrame = (:)

popFrame :: CallStack -> Maybe (Frame, CallStack)
popFrame [] = Nothing
popFrame (f:fs) = Just (f, fs)

-- Function call pushes frame
call :: Int -> Map String Int -> CallStack -> CallStack
call addr locals stack = pushFrame (Frame addr locals []) stack

-- Function return pops frame
returnFromCall :: CallStack -> Maybe CallStack
returnFromCall stack = fmap snd (popFrame stack)
````

### Stack Inspection

Functional stacks allow non-destructive inspection of elements at any depth through pattern matching or indexing operations. This enables algorithms that need to look ahead or examine context without consuming elements.

**Example:**

```ocaml
(* OCaml stack inspection *)
let rec nth stack n =
  match stack, n with
  | [], _ -> None
  | x::_, 0 -> Some x
  | _::xs, n -> nth xs (n-1)

let stack = [5; 4; 3; 2; 1]

let top = nth stack 0      (* Some 5 *)
let third = nth stack 2    (* Some 3 *)
(* Stack remains unchanged *)
```

### Performance Characteristics

Functional stacks provide optimal time complexity for stack operations. Push and pop are strictly O(1) with no amortization required. Space usage is linear in stack depth with maximal structural sharing across versions.

**Key Points:**

- Push: O(1) - single cons cell allocation
- Pop: O(1) - pattern match and return tail
- Peek: O(1) - examine head without modification
- Space: O(n) for depth n, with sharing across versions
- No amortized analysis needed - all operations strictly constant time

### Memory Considerations

While individual stack operations are efficient, applications maintaining many stack versions can accumulate memory. Long-lived references to old stack states prevent garbage collection of intermediate nodes. Release references to obsolete stacks when possible.

**Example:**

```javascript
// JavaScript with Immutable.js Stack
const { Stack } = require('immutable');

let current = Stack([1, 2, 3]);

// Problematic - retains all versions
const history = [];
for (let i = 0; i < 10000; i++) {
  current = current.push(i);
  history.push(current);  // Retains every stack version
}

// Better - only retain current
let current2 = Stack([1, 2, 3]);
for (let i = 0; i < 10000; i++) {
  current2 = current2.push(i);
  // Old versions eligible for GC
}
```

**Key Points:**

- Functional stacks use immutable linked lists for O(1) push/pop
- Maximal structural sharing minimizes memory overhead
- Enable persistent access to multiple stack versions
- Natural fit for DFS, expression evaluation, undo/redo
- Simplest and most efficient persistent data structure
- All operations strictly O(1) with no amortization
- Release old version references to enable garbage collection
- Choose functional stacks when immutability and persistence are required

