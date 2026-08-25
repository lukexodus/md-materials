## Recursive ADTs


Recursive algebraic data types contain references to themselves in their definition, enabling representation of unbounded hierarchical structures like trees, lists, and expression grammars. This self-reference allows finite type definitions to describe infinite data spaces.

**Self-Referential Structure**

The type appears in its own variant definitions, creating potentially infinite nesting:

```python
from dataclasses import dataclass
from typing import Union

@dataclass
class Cons:
    head: int
    tail: 'List'

@dataclass
class Nil:
    pass

List = Union[Cons, Nil]

# Construct: [1, 2, 3]
my_list = Cons(1, Cons(2, Cons(3, Nil())))
```

**Binary Tree Structures**

Trees are canonical recursive ADTs with branching structure:

```python
@dataclass
class Leaf:
    value: int

@dataclass
class Branch:
    left: 'Tree'
    right: 'Tree'

Tree = Union[Leaf, Branch]

# Construct tree:
#       /\
#      /  \
#     3   /\
#        /  \
#       5    7
tree = Branch(
    Leaf(3),
    Branch(Leaf(5), Leaf(7))
)
```

**Recursive Processing via Pattern Matching**

Process recursive ADTs through recursive functions mirroring the type structure:

```python
def sum_list(lst: List) -> int:
    match lst:
        case Nil():
            return 0
        case Cons(head=x, tail=xs):
            return x + sum_list(xs)

def tree_sum(tree: Tree) -> int:
    match tree:
        case Leaf(value=x):
            return x
        case Branch(left=l, right=r):
            return tree_sum(l) + tree_sum(r)

def tree_height(tree: Tree) -> int:
    match tree:
        case Leaf(_):
            return 1
        case Branch(left=l, right=r):
            return 1 + max(tree_height(l), tree_height(r))
```

**Multi-Way Recursion**

Recursive ADTs can have multiple self-references, creating complex traversal patterns:

```python
@dataclass
class Empty:
    pass

@dataclass
class Node:
    value: int
    children: list['NTree']

NTree = Union[Empty, Node]

def n_tree_sum(tree: NTree) -> int:
    match tree:
        case Empty():
            return 0
        case Node(value=x, children=cs):
            return x + sum(n_tree_sum(child) for child in cs)
```

**Expression Trees**

Represent computational structures like mathematical expressions:

```python
@dataclass
class Num:
    value: float

@dataclass
class Add:
    left: 'Expr'
    right: 'Expr'

@dataclass
class Mul:
    left: 'Expr'
    right: 'Expr'

@dataclass
class Neg:
    expr: 'Expr'

Expr = Union[Num, Add, Mul, Neg]

# Represents: -(3 + (5 * 2))
expr = Neg(
    Add(
        Num(3),
        Mul(Num(5), Num(2))
    )
)

def eval_expr(expr: Expr) -> float:
    match expr:
        case Num(value=x):
            return x
        case Add(left=l, right=r):
            return eval_expr(l) + eval_expr(r)
        case Mul(left=l, right=r):
            return eval_expr(l) * eval_expr(r)
        case Neg(expr=e):
            return -eval_expr(e)
```

**Tail Recursion Optimization Pattern**

Transform recursive ADT traversals into accumulator-passing style for stack safety:

```python
def sum_list_tail(lst: List, acc: int = 0) -> int:
    match lst:
        case Nil():
            return acc
        case Cons(head=x, tail=xs):
            return sum_list_tail(xs, acc + x)

def reverse_list(lst: List, acc: List = Nil()) -> List:
    match lst:
        case Nil():
            return acc
        case Cons(head=x, tail=xs):
            return reverse_list(xs, Cons(x, acc))
```

[Inference] Python doesn't perform automatic tail call optimization, so deeply recursive ADT operations may still cause stack overflow despite tail-recursive form.

**Mutual Recursion**

Multiple ADTs can reference each other, creating mutually recursive type systems:

```python
@dataclass
class IntLeaf:
    value: int

@dataclass
class FloatLeaf:
    value: float

@dataclass
class IntBranch:
    left: 'IntTree'
    right: 'FloatTree'

@dataclass
class FloatBranch:
    left: 'FloatTree'
    right: 'IntTree'

IntTree = Union[IntLeaf, IntBranch]
FloatTree = Union[FloatLeaf, FloatBranch]

def process_int_tree(tree: IntTree) -> float:
    match tree:
        case IntLeaf(value=x):
            return float(x)
        case IntBranch(left=l, right=r):
            return process_int_tree(l) + process_float_tree(r)

def process_float_tree(tree: FloatTree) -> float:
    match tree:
        case FloatLeaf(value=x):
            return x
        case FloatBranch(left=l, right=r):
            return process_float_tree(l) + process_int_tree(r)
```

**Infinite Structures via Laziness**

In languages supporting lazy evaluation, recursive ADTs can represent infinite structures:

```python
# Conceptual (requires lazy evaluation)
# infinite_ones = Cons(1, lambda: infinite_ones)
# 
# Python approximation using generators:
def infinite_ones():
    yield 1
    yield from infinite_ones()
```

**Folding Recursive Structures**

Catamorphisms (folds) abstract recursive traversal patterns:

```python
from typing import TypeVar, Callable

A = TypeVar('A')
B = TypeVar('B')

def fold_list(lst: List, 
              nil_case: B, 
              cons_case: Callable[[int, B], B]) -> B:
    match lst:
        case Nil():
            return nil_case
        case Cons(head=x, tail=xs):
            return cons_case(x, fold_list(xs, nil_case, cons_case))

# Usage
sum_list = lambda lst: fold_list(lst, 0, lambda x, acc: x + acc)
length = lambda lst: fold_list(lst, 0, lambda x, acc: 1 + acc)
reverse = lambda lst: fold_list(lst, Nil(), lambda x, acc: append(acc, x))
```

**Zipper Pattern for Navigation**

Zippers enable efficient navigation and modification of recursive structures:

```python
@dataclass
class TreeContext:
    direction: str  # 'left' or 'right'
    sibling: Tree
    parent: 'TreeZipper | None'

TreeZipper = tuple[Tree, TreeContext | None]

def go_left(zipper: TreeZipper) -> TreeZipper | None:
    tree, context = zipper
    match tree:
        case Branch(left=l, right=r):
            new_context = TreeContext('left', r, context)
            return (l, new_context)
        case _:
            return None

def go_up(zipper: TreeZipper) -> TreeZipper | None:
    tree, context = zipper
    if context is None:
        return None
    match context.direction:
        case 'left':
            parent = Branch(tree, context.sibling)
        case 'right':
            parent = Branch(context.sibling, tree)
    return (parent, context.parent)
```

