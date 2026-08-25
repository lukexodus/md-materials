## Binary Trees Basics


Binary trees are hierarchical data structures where each node has at most two children, referred to as left and right child.

**Structure Components:**

- Root: Top-most node
- Parent: Node with children
- Leaf: Node with no children
- Height: Maximum path length from root to leaf
- Depth: Path length from root to specific node

**Node Structure:**

- Data field
- Left child pointer
- Right child pointer

**Types:**

- Full Binary Tree: Every node has 0 or 2 children
- Complete Binary Tree: All levels filled except possibly the last, filled left to right
- Perfect Binary Tree: All internal nodes have two children, all leaves at same level
- Balanced Binary Tree: Height difference between subtrees is at most 1

**Traversal Methods:**

- Inorder: Left -> Root -> Right
- Preorder: Root -> Left -> Right
- Postorder: Left -> Right -> Root
- Level-order: Breadth-first traversal

**Basic Operations:**

- Insertion: Add new node
- Deletion: Remove node
- Search: Find specific value
- Traversal: Visit all nodes in specific order

**Time Complexity:**

- Search: O(n) worst case, O(log n) average for balanced trees
- Insertion: O(n) worst case, O(log n) average for balanced trees
- Deletion: O(n) worst case, O(log n) average for balanced trees
- Traversal: O(n)

**Space Complexity:**

- Storage: O(n) for n nodes
- Recursion: O(h) where h is tree height

**Applications:**

- Expression parsing and evaluation
- File system hierarchies
- Decision trees
- Database indexing
- Hierarchical data representation

