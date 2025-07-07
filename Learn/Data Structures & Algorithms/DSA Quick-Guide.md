## Table of Contents

- [[#The Array: The Foundational Data Structure|The Array: The Foundational Data Structure (p. 2)]]
- [[#Data Structure Operations|Data Structure Operations (p. 3)]]
- [[#Time Complexity Notations|Time Complexity Notations (p. 4)]]
- [[#Big O Categories and Their Significance|Big O Categories and Their Significance (p. 6)]]
- [[#The Soul of Big O|The Soul of Big O (p. 8)]]
- [[#Deeper into the Soul of Big O|Deeper into the Soul of Big O (p. 8)]]
- [[#Measuring Speed|Measuring Speed (p. 10)]]
- [[#Reading from an Array|Reading from an Array(p. 10)]]
- [[#Searching in an Array|Searching in an Array (p. 11)]]
- [[#Insertion to an Array|Insertion to an Array (p. 13)]]
- [[#Deletion in from Array|Deletion in from Array (p. 14)]]
- [[#Ordered Array|Ordered Array (p. 16)]]
- [[#Same Algorithm, Different Scenarios|Same Algorithm, Different Scenarios (p. 17)]]
- [[#Stacks|Stacks (p. 18)]]
- [[#Abstract Data Types|Abstract Data Types (p. 19)]]
- [[#Queues|Queues (p. 20)]]
- [[#Recurse Instead of Loop|Recurse Instead of Loop (p. 22)]]
- [[#The Call Stack in Recursion|The Call Stack in Recursion (p. 24)]]
- [[#Recursive Trick: Passing Extra Parameters|Recursive Trick: Passing Extra Parameters (p. 25)]]
- [[#Two Approaches to Calculations|Two Approaches to Calculations (p. 28)]]
- [[#Top-Down Recursion|Top-Down Recursion (p. 29)]]
- [[#Binary Search|Binary Search (p. 31)]]
- [[#Binary Search vs. Linear Search|Binary Search vs. Linear Search (p. 34)]]
- [[#Understanding O(log N) Complexity|Understanding O(log N) Complexity (p. 36)]]
- [[#Trees|Trees (p. 38)]]
- [[#Binary Search Trees (BSTs)|Binary Search Trees (BSTs) (p. 39)]]
- [[#Search a BST|Search a BST (p. 42)]]
- [[#O(log N) Complexity in Binary Search Trees|O(log N) Complexity in Binary Search Trees (p. 46)]]
- [[#Insertion in a Binary Search Tree (BST)|Insertion in a Binary Search Tree (BST) (p. 47)]]
- [[#Deletion in a Binary Search Tree|Deletion in a Binary Search Tree (p. 52)]]
- [[#B-Trees|B-Trees (p. 61)]]
- [[#B-Tree Search|B-Tree Search (p. 64)]]
- [[#B-Tree Insertion|B-Tree Insertion (p. 65)]]
- [[#B-Tree Deletion|B-Tree Deletion (p. 71)]]
- [[#Hash Tables and Hash Functions|Hash Tables and Hash Functions (p. 75)]]
- [[#Hash Table Lookups|Hash Table Lookups (p. 76)]]
- [[#Dealing With Collissions|Dealing With Collissions (p. 77)]]
- [[#Making an Efficient Hash Table|Making an Efficient Hash Table (p. 78)]]
- [[#Hash Tables for Organization|Hash Tables for Organization (p. 80)]]
- [[#Linked Lists|Linked Lists (p. 81)]]
- [[#Efficiency of Linked List Operations|Efficiency of Linked List Operations (p. 87)]]
- [[#Doubly Linked Lists|Doubly Linked Lists (p. 88)]]
- [[#Queues as Doubly Linked Lists|Queues as Doubly Linked Lists (p. 89)]]
- [[#Graphs|Graphs (p. 91)]]
- [[#Graph Search|Graph Search (p. 97)]]
- [[#Depth-First Search (DFS)|Depth-First Search (DFS) (p. 99)]]
- [[#Breadth-First Search (BFS)|Breadth-First Search (BFS) (p. 107)]]
- [[#DFS vs. BFS|DFS vs. BFS (p. 118)]]
- [[#Efficiency of Graph Search|Efficiency of Graph Search (p. 119)]]
- [[#Weighted Graphs and Shortest Path Problem|Weighted Graphs and Shortest Path Problem (p. 121)]]
- [[#Dijkstra’s Algorithm|Dijkstra’s Algorithm (p. 123)]]

## The Array: The Foundational Data Structure

- **Array Definition**: An array is a list of data elements stored sequentially in memory. It's one of the most basic and foundational data structures in computer science.

- **Versatility**: Arrays can store various data types (integers, strings, objects) and are used in numerous scenarios, such as storing shopping lists.

- **Size**: The size of an array refers to the total number of elements it can hold. For instance, an array of five grocery items has a size of 5.

- **Indexing**: Indexes are used to access elements in an array. Most programming languages, including C++, use zero-based indexing, meaning the first element is at index 0, the second at index 1, and so on.

- **Example in C++**:

  ```cpp
  #include <iostream>
  
  int main() {
      std::string groceryList[] = {"apples", "bananas", "cucumbers", "dates", "elderberries"};
      int size = sizeof(groceryList) / sizeof(groceryList[0]);
  
      std::cout << "Size of the array: " << size << std::endl;
  
      // Accessing elements using their index
      std::cout << "Item at index 0: " << groceryList[0] << std::endl;
      std::cout << "Item at index 4: " << groceryList[4] << std::endl;

      return 0;
  }
  ```

- **Output**:
  ```
  Size of the array: 5
  Item at index 0: apples
  Item at index 4: elderberries
  ```

![[Pasted image 20240819195401.png]]

## Data Structure Operations

- **Read**:
  - **Definition**: Accessing a specific value at a particular index within the array.
  - **Example**: Looking up the item at index 2 in the grocery list array.

- **Search**:
  - **Definition**: Finding whether a specific value exists in the array and, if it does, determining its index.
  - **Example**: Searching for "dates" in the grocery list to find its index.

- **Insert**:
  - **Definition**: Adding a new value to the array.
  - **Example**: Adding "figs" to the grocery list array.

- **Delete**:
  - **Definition**: Removing a value from the array.
  - **Example**: Deleting "bananas" from the grocery list array.

Each of these operations has performance implications, which can vary depending on the structure and size of the array. 

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    // Initialize array as a vector for easier manipulation
    std::vector<std::string> groceryList = {"apples", "bananas", "cucumbers", "dates", "elderberries"};
    
    // Read operation: Accessing value at index 2
    std::cout << "Item at index 2: " << groceryList[2] << std::endl;

    // Search operation: Finding the index of "dates"
    auto it = std::find(groceryList.begin(), groceryList.end(), "dates");
    if (it != groceryList.end()) {
        std::cout << "\"dates\" found at index: " << std::distance(groceryList.begin(), it) << std::endl;
    } else {
        std::cout << "\"dates\" not found in the list." << std::endl;
    }

    // Insert operation: Adding "figs" to the array
    groceryList.push_back("figs");
    std::cout << "Added \"figs\" to the list. New size: " << groceryList.size() << std::endl;

    // Delete operation: Removing "bananas" from the array
    groceryList.erase(std::remove(groceryList.begin(), groceryList.end(), "bananas"), groceryList.end());
    std::cout << "Removed \"bananas\" from the list. New size: " << groceryList.size() << std::endl;

    return 0;
}
```

**Explanation**:
- **Read**: Directly accesses the element at a specified index.
- **Search**: Uses the `find` function to locate an element.
- **Insert**: Uses `push_back` to add a new element to the end of the array.
- **Delete**: Combines `erase` and `remove` to eliminate a specific element from the array.

## Time Complexity Notations

Big O notation is a mathematical representation used to describe the efficiency of algorithms, specifically focusing on their time complexity and space complexity.

![[Pasted image 20240820191144.jpg]]

- **O(1)** - **Constant Time**:
  - The runtime does not change with the size of the input. For example, accessing an element in an array by index.
  - **Analogy**: Imagine you have a bookshelf where you always know exactly where to find a specific book, no matter how many books are on the shelf. Accessing that book takes the same amount of time regardless of the total number of books.

- **O(log n)** - **Logarithmic Time**:
  - The runtime increases logarithmically as the input size increases. Binary search in a sorted array is an example.
  - **Analogy**: Think of a phone book with names listed alphabetically. To find a person’s number, you start in the middle and decide whether to search in the left half or the right half based on the alphabetical range. Each step cuts the search space in half, so finding a name takes fewer steps as the book grows larger.

- **O(n)** - **Linear Time**:
  - The runtime increases linearly with the size of the input. For example, traversing a list or array.
  - **Analogy**: Imagine you have a stack of papers with names on them and you need to find a specific name. You must check each paper one by one. The time it takes grows directly with the number of papers you need to check.

- **O(n log n)** - **Log-Linear Time**:
  - The runtime grows in proportion to $n$ times the logarithm of $n$. Many efficient sorting algorithms, like merge sort and quicksort, have this complexity.
  - **Analogy**: Suppose you’re sorting a list of names using a method where you repeatedly divide the list into smaller chunks and sort each chunk. The time it takes to sort the list grows faster than just checking each item but not as fast as squaring the number of items. Sorting takes more steps as the list grows, but not as drastically as quadratic time.

- **O(n^2)** - **Quadratic Time**:
  - The runtime increases proportionally to the square of the input size. Examples include bubble sort and insertion sort in their worst-case scenarios.
  - **Analogy**: Imagine organizing a large party where you need to shake hands with everyone. If there are 10 people, you shake hands with each of the 10 people, so you do this 10 times, which means you have to shake hands 100 times in total. As the number of guests increases, the total number of handshakes increases dramatically.

- **O(n^3)** - **Cubic Time**:
  - The runtime grows proportionally to the cube of the input size. This might be seen in algorithms involving three nested loops.
  - **Analogy**: Think of a 3D grid where you need to visit every point in the grid. If the grid has dimensions of size `n`, you will need to visit `n * n * n` points, so the time grows very quickly as the grid size increases. This is like having to check each point in a 3D space.

- **O(2^n)** - **Exponential Time**:
  - The runtime doubles with each additional input element. Examples include some brute-force algorithms for combinatorial problems.
  - **Analogy**: Consider a situation where you have to explore all possible combinations of toppings on a pizza. If you have 10 different toppings, each topping can either be on or off, leading to $2^{10}$ possible combinations. As the number of toppings increases, the number of combinations grows exponentially, making it extremely time-consuming.

- **O(n!)** - **Factorial Time**:
  - The runtime grows factorially with the input size. This is seen in algorithms that generate all permutations of a set.
  - **Analogy**: Imagine you need to arrange a set of 10 unique books on a shelf. The number of possible arrangements (permutations) is 10 factorial (10!). As the number of books increases, the number of arrangements grows factorially, leading to an astronomically large number of possibilities.

### Examples in Context

1. **O(1)**:
   - Accessing an element in an array by index.

2. **O(log n)**:
   - Binary search in a sorted array.

3. **O(n)**:
   - Iterating through all elements in an array or list.

4. **O(n log n)**:
   - Efficient sorting algorithms like merge sort or quicksort.

5. **O(n^2)**:
   - Simple sorting algorithms like bubble sort or insertion sort.

6. **O(2^n)**:
   - Solving the traveling salesman problem using brute force.

7. **O(n!)**:
   - Generating all permutations of a set.


## Big O Categories and Their Significance

#### **Understanding Big O Categories**

1. **Categories vs. Specifics**:
   - **Analogy**: Comparing buildings, such as a single-family home and a skyscraper, illustrates how the general category (house vs. skyscraper) often suffices to highlight significant differences. Similarly, Big O Notation categorizes algorithms based on their growth rates rather than exact step counts.
   - **Example**: An O(N) algorithm and an O(N²) algorithm represent fundamentally different growth patterns. Even if the O(N) algorithm has a constant factor (like 100N), it will still be more efficient than an O(N²) algorithm for large enough input sizes.

2. **Categories of Big O Notation**:
   - **O(1)**: Constant time complexity, meaning the algorithm's performance does not change with the size of the input data.
   - **O(log N)**: Logarithmic time complexity, meaning the algorithm's performance grows logarithmically with the size of the input data. Binary search is a classic example.
   - **O(N)**: Linear time complexity, where the algorithm's performance grows linearly with the input size. For example, linear search.
   - **O(N²)**: Quadratic time complexity, where performance grows quadratically with the input size. Selection Sort and Bubble Sort are examples.

#### **Significance of Categories**

1. **Long-Term Growth**:
   - **O(N) vs. O(N²)**: An O(N) algorithm will eventually outperform an O(N²) algorithm as the data size increases. The linear growth of O(N) will be much more manageable compared to the quadratic growth of O(N²).

2. **Comparison Across Categories**:
   - When comparing algorithms from different Big O categories, such as O(N) and O(N²), the difference is stark and clear. It’s sufficient to recognize the general category because the growth rates are vastly different.

3. **Within the Same Category**:
   - **Same Classification**: Algorithms within the same Big O category (e.g., O(N²)) may have different actual performance characteristics. For instance, Selection Sort may be faster than Bubble Sort even though both are O(N²) due to fewer swaps.

4. **Practical Analysis**:
   - While Big O provides a high-level understanding, detailed analysis is necessary for algorithms within the same category. Factors such as constant factors, implementation details, and specific data characteristics can impact real-world performance.

#### **Graphical Representation**

![[Pasted image 20240820191144.jpg]]

Graphs illustrating different Big O categories help visualize how their growth rates diverge as input size increases. For instance:

- **O(1)** remains constant regardless of input size.
- **O(log N)** increases slowly, reflecting logarithmic growth.
- **O(N)** shows a straight line, indicating linear growth.
- **O(N²)** curves upwards more steeply, demonstrating quadratic growth.

## The Soul of Big O

**Big O Notation** is a way to express the efficiency of an algorithm, particularly how its runtime or space requirements grow as the size of the input data increases. But understanding Big O involves more than just counting steps; it's about how an algorithm's performance scales with larger datasets. Here’s a deeper look into the concept:

#### **Key Concepts**

1. **What is Big O Notation?**
    - **Definition**: Big O Notation provides an upper bound on the growth rate of an algorithm’s time or space complexity. It describes how the running time or space requirement of an algorithm increases with the size of the input.
    - **Purpose**: It helps in comparing the efficiency of algorithms, particularly as the size of the input data increases.
2. **The Soul of Big O**
    - **Core Idea**: Big O is not just about the absolute number of steps an algorithm takes but about how the number of steps increases relative to the size of the input. This reflects the scalability and efficiency of an algorithm.

![[Pasted image 20240819202748.png]]

## Deeper into the Soul of Big O

Understanding the deeper implications of Big O Notation involves analyzing the efficiency of algorithms beyond just their asymptotic complexity. Let’s explore why the “soul of Big O” matters and how different scenarios affect the performance evaluation of algorithms.

### **Constant Time vs. Linear Time**

![[Pasted image 20240819203006.png]]

1. **Comparison of O(1) and O(N)**
   - **O(1) Algorithm**: This algorithm performs a constant number of steps regardless of the size of the input. For example, an algorithm that always takes 100 steps is O(1), because the number of steps doesn’t change with the size of the input data.
   - **O(N) Algorithm**: This algorithm’s number of steps increases linearly with the size of the input. For instance, if you have an algorithm that takes up to N steps, it will take 10 steps for 10 elements, 100 steps for 100 elements, and so on.

   **Graphical Comparison**:
   - For smaller datasets, an O(N) algorithm might take fewer steps compared to an O(1) algorithm that takes a large constant number of steps.
   - **Graph**: Initially, the O(N) line might be below the O(1) line (if the constant is large). However, as the dataset size grows, the O(N) line will eventually surpass the O(1) line. Beyond this crossing point, O(N) will always take more steps than the O(1) algorithm.

   **Key Insight**: The O(1) algorithm will always be more efficient for sufficiently large datasets because its performance does not depend on the size of the input. Even if the constant is large (e.g., one million steps), the performance remains constant relative to the input size, whereas the O(N) algorithm’s steps increase directly with the size of the input.

2. **Practical Implications**
   - **Large Datasets**: For very large datasets, an O(1) algorithm will almost always be preferable because it maintains a constant number of steps. The performance of an O(N) algorithm, on the other hand, becomes less efficient as the input size grows.
   - **Small Datasets**: For small datasets, the difference might be negligible. An O(N) algorithm could outperform an O(1) algorithm with a very high constant if the input size is small.

## Measuring Speed

- **Steps vs. Time**:
  - **Steps**: Measuring speed in terms of the number of computational steps or operations. This approach is consistent across different hardware since the number of steps remains the same regardless of the computer’s performance.
  - **Time**: Measuring speed based on actual time is unreliable because it varies with hardware and system load. 

- **Time Complexity**:
  - **Definition**: Refers to the number of steps an operation takes. It is used to analyze and compare the efficiency of algorithms regardless of the hardware they run on.
  - **Terminology**: Terms like speed, time complexity, efficiency, performance, and runtime are often used interchangeably to refer to this concept.

- **Operations on Arrays**:
  - **Read**:
    - **Steps**: Accessing an element at a specific index is typically done in constant time, i.e., $O(1)$ steps. This is because direct indexing in arrays allows immediate access to any element.
  
  - **Search**:
    - **Steps**: Finding a specific value involves checking each element until the value is found or the end of the array is reached. In the worst case, this is $O(n)$ steps, where $n$ is the number of elements in the array.

  - **Insert**:
    - **Steps**: Adding a new element involves finding a place to insert the new value and possibly shifting elements to make space. For an unsorted array, insertion might be $O(1)$ if added at the end, but $O(n)$ if the array needs to be resized or if elements need to be shifted.

  - **Delete**:
    - **Steps**: Removing an element requires locating it and then shifting subsequent elements to fill the gap. This operation is typically $O(n)$ in the worst case, as elements might need to be moved to maintain the array's structure.

These steps provide a way to evaluate and compare the efficiency of different operations and algorithms.

## Reading from an Array

- **Operation**: Reading involves accessing the value stored at a specific index within the array.

- **Efficiency**: This operation is extremely efficient, taking constant time, denoted as $O(1)$, because it requires just one step to access any element.

- **How It Works**:
  1. **Memory Addresses**: Computer memory can be thought of as a sequence of cells, each with a unique address. For example, if an array starts at memory address 1010, and each cell is of equal size, the element at index 3 is located at address 1013.
  
  2. **Direct Access**: To find the value at any index, the computer uses the starting address of the array and adds the index to this address to get the specific cell's address. This is because the cells are stored contiguously (one right after the other).

- **Analogy**:
  - **Bookcase Analogy**: Imagine you have a row of books on a shelf, where each book is placed next to the other in a straight line. If you want to find a book at a specific position, you can directly count from the start of the row to get to the exact spot. For instance, if the shelf starts at position 10, and you want the 4th book, you count to position 13. This direct counting is similar to how the computer calculates the memory address for a given index.

- **Detailed Process**:
  1. **Locate Start**: The computer knows where the array begins in memory. 
  2. **Calculate Address**: To find the value at index 3, it starts from the base address (e.g., 1010) and adds the index (3) to it, resulting in address 1013.
  3. **Retrieve Value**: The computer jumps to address 1013 and retrieves the value stored there (e.g., "dates").

![[Pasted image 20240819201304.png]]

### **Why It's Efficient**
- **One-Step Access**: Since accessing a specific memory address is a direct operation and doesn’t require searching through other elements, reading from an array is very fast and always takes the same amount of time, regardless of the array size.

This efficient access is one of the reasons arrays are fundamental in computer science, providing quick and predictable performance for retrieving data.

## Searching in an Array

- **Operation**: Searching involves looking for a specific value within an array and determining its index if it exists.

- **Difference from Reading**:
  - **Reading**: Accessing a value at a given index is instantaneous and takes constant time ($O(1)$).
  - **Searching**: Finding the index of a specific value requires examining each element until the desired value is found or the end of the array is reached. This is more time-consuming.

- **Process**:
  1. **Start at the Beginning**: The computer begins at the first index and checks the value stored there.
  2. **Sequential Checking**: If the value at the current index does not match the target value, the computer moves to the next index and repeats the process.
  3. **Stop When Found**: If the target value is found, the search stops, and the index is returned.
  4. **End of Array**: If the target value is not found by the end of the array, the search concludes that the value is not present.

- **Example**:
  For an array `["apples", "bananas", "cucumbers", "dates", "elderberries"]`, searching for "dates" involves:
  
  1. Checking index 0: "apples" (not a match).
  2. Checking index 1: "bananas" (not a match).
  3. Checking index 2: "cucumbers" (not a match).
  4. Checking index 3: "dates" (match found).

![[Pasted image 20240819201517.png]]

- **Linear Search**:
  - **Definition**: This is the simplest form of search where each element is checked sequentially until the target is found or the end is reached.
  - **Efficiency**: The time complexity is $O(n)$, where $n$ is the number of elements in the array. This means in the worst case, you may need to check every element.

- **Worst-Case Scenario**:
  - If the value is in the last position or not present at all, the computer must check all $N$ elements in the array.
  - For an array of $N$ elements, the maximum number of steps required for a linear search is $N$.

### **Analogy for Linear Search**

- **Analogy**: Imagine you are searching for a specific book on a long shelf where the books are arranged in no particular order. To find the book, you must start at one end of the shelf and check each book one by one. If the book is near the end or not on the shelf at all, you'll need to check each book until you find it or reach the end of the shelf.

### **Summary**

- **Reading** is fast and takes constant time ($O(1)$) because you can directly access any index.
- **Searching** is slower, especially for large arrays, and takes linear time ($O(n)$) because it requires examining each element until the desired one is found or the array is exhausted.

This shows why searching can be less efficient than reading and why more advanced searching techniques, like binary search (for sorted arrays), are often employed to improve performance.

## Insertion to an Array

- **Operation**: Insertion involves adding a new element to a specific position in the array. The efficiency of this operation depends on where the new element is inserted.

- **Inserting at the End**:
  - **Efficiency**: Inserting an element at the end of an array is very efficient, as it typically requires only one step.
  - **Reason**: The computer knows the current size of the array and the memory address of the last element. It can directly append the new element to the next available memory address.
  - **Example**: If an array starts at address 1010 and contains 5 elements, the next available address for a new element is 1015.

![[Pasted image 20240819201723.png]]

- **Inserting in the Middle or Beginning**:
  - **Efficiency**: Inserting an element in the middle or at the beginning of the array is less efficient. This operation requires shifting elements to make room for the new element.
  - **Steps**:
    1. **Shift Elements**: Move elements starting from the end of the insertion point to the end of the array to the right by one position.
    2. **Insert New Element**: Place the new element at the desired index.

  - **Example**: To insert "figs" at index 2 in the array `["apples", "bananas", "cucumbers", "dates", "elderberries"]`:

![[Pasted image 20240819201750.png]]

1. Move "elderberries" to index 5.
2. Move "dates" to index 4.
3. Move "cucumbers" to index 3.
4. Insert "figs" at index 2.

- **Worst-Case Scenario**:
  - **Description**: The worst-case scenario for insertion occurs when inserting an element at the beginning of the array. This requires shifting all existing elements to the right.
  - **Time Complexity**: Inserting at the beginning can take up to $N + 1$ steps for an array with $N$ elements. This includes shifting all $N$ elements and performing the insertion itself.

### **Analogies for Insertion**

- **Insertion at the End**:
  - **Analogy**: Think of adding a new book to the end of a bookshelf. If there’s already a space reserved for new books at the end, you can just place the new book there without disturbing the others.

- **Insertion in the Middle or Beginning**:
  - **Analogy**: Imagine inserting a new book into the middle of a tightly packed bookshelf. To make space, you need to move all the books from the insertion point onward one position to the right. This requires more effort compared to simply placing a book at the end.

### **Summary**

- **End Insertion**: Fast and efficient, typically $O(1)$ because it involves directly adding the element at the end of the array.
- **Middle/Beginning Insertion**: Slower and less efficient, typically $O(n)$, due to the need to shift existing elements to accommodate the new element.

## Deletion from an Array

**Deletion** is the process of removing a value from a specific index in an array. This operation can be broken down into two main parts: the actual deletion and the shifting of elements to fill the gap left by the deleted value.

#### **Steps for Deletion**

1. **Delete the Value**:
   - **Action**: Remove the value from the specified index.
   - **Example**: To delete "cucumbers" from `["apples", "bananas", "cucumbers", "dates", "elderberries"]`, the array becomes `["apples", "bananas", None, "dates", "elderberries"]`.
	   - ![[Pasted image 20240819201950.png]]
   - **Efficiency**: This step is generally $O(1)$, as it involves setting the value at the index to `None` or removing it directly.

2. **Shift Elements**:
   - **Action**: Move the elements that follow the deleted value to the left to close the gap.
   - **Steps**:
     1. **Shift "dates" to the left**: Moves to index 2.
	    ![[Pasted image 20240819202004.png]]
     2. **Shift "elderberries" to the left**: Moves to index 3.
	    ![[Pasted image 20240819202013.png]]
   - **Efficiency**: This requires iterating through and moving elements, making it $O(n)$ in the worst case.

#### **Worst-Case Scenario**

- **Description**: The worst-case scenario for deletion occurs when deleting the very first element of the array. This requires shifting all subsequent elements to the left.
- **Time Complexity**: For an array with $N$ elements:
  - **Steps**: 1 step for deletion + $(N-1)$ steps for shifting.
  - **Total**: $O(n)$

#### **Analogy for Deletion**

- **Analogy**: Imagine you have a row of numbered seats in a theater. If someone leaves from the middle of the row, you need to shift all the people who are sitting in the seats after the empty one to fill the gap. This is similar to how elements are shifted in an array after a deletion.

### **Summary**

- **Deletion Operation**: The deletion itself is quick ($O(1)$) but may require additional time to shift elements.
- **Worst-Case Complexity**: The overall time complexity for deletion is $O(n)$ due to the need to shift elements after removing an item.

By understanding how deletion works and its efficiency, you can better assess when and how to use arrays in your programming tasks. Each data structure has its own strengths and weaknesses, and choosing the right one can greatly impact your software’s performance.

## Ordered Array

An **ordered array** is a variation of a classic array where the values are always kept in sorted order. This constraint affects the efficiency of various operations, particularly insertion and searching. Here’s a breakdown of how these operations perform in an ordered array:

#### **Insertion in an Ordered Array**

1. **Description**:
   - Inserting a new value requires not only finding the correct position to maintain order but also shifting existing elements to make space.

2. **Process**:
   - **Step 1**: Compare the value to be inserted with values in the array to find the correct position.
   - **Step 2**: Shift elements to the right to create space.
   - **Step 3**: Insert the new value into its correct position.

3. **Efficiency**:
   - **Searching for Position**:
     - Finding the correct position involves comparing the new value with existing values, which takes $O(N)$ time in the worst case.
   - **Shifting Elements**:
     - After finding the position, shifting elements to make space also takes $O(N)$ time in the worst case.

   - **Total Steps**:
     - **Best Case**: Inserting at the end of the array requires $N$ comparisons (one for each existing value) and 1 step for insertion. Total: $N + 1$ steps.
     - **Worst Case**: Inserting at the beginning requires up to $N$ comparisons and $N$ shifts. Total: $2N$ steps.

   - **Average Case**:
     - Generally, insertion will take about $N$ comparisons and about half the number of shifts needed in the worst case. Therefore, it averages out to approximately $N + 1$ steps.

#### **Searching in an Ordered Array**

1. **Description**:
   - Searching for a value in an ordered array can be done efficiently using binary search.

2. **Process**:
   - **Binary Search**:
     - Binary search divides the array into halves, repeatedly narrowing down the search space based on comparisons with the middle element.

3. **Efficiency**:
   - **Binary Search**:
     - **Time Complexity**: $O(\log N)$ because each comparison reduces the search space by half.
   - This is significantly more efficient than linear search, which has $O(N)$ time complexity.

#### **Comparative Analysis**

- **Classic Array vs. Ordered Array**:
  - **Reading**: Both have $O(1)$ time complexity for accessing elements.
  - **Searching**:
    - **Classic Array**: $O(N)$ due to linear search.
    - **Ordered Array**: $O(\log N)$ due to binary search.
  - **Insertion**:
    - **Classic Array**: Best-case $O(1)$ for appending at the end; worst-case $O(N)$ for inserting at the beginning or middle.
    - **Ordered Array**: $O(N)$ for searching and shifting, regardless of position.
  - **Deletion**:
    - **Classic Array**: $O(N)$ for searching and shifting.
    - **Ordered Array**: Similar to classic arrays, with $O(N)$ for finding and $O(N)$ for shifting elements.

#### **Analogy for Insertion in an Ordered Array**

- **Analogy**: Imagine a row of numbered slots where you need to insert a new card. To keep the cards in numerical order, you first need to find the correct slot by checking each one until you find the spot where your card should go. Once you’ve found the spot, you need to move all subsequent cards one slot to the right to make room. This process ensures that the cards remain in order but requires careful placement and shifting.

## **Same Algorithm, Different Scenarios**

1. **Best-Case vs. Worst-Case Scenarios**
   - **Linear Search Example**:
     - **Best Case**: If the item being searched is in the first position, linear search takes only one step. This scenario is O(1).
     - **Worst Case**: If the item is at the last position or not present at all, it will take N steps to find or conclude absence. This scenario is O(N).

   **Explanation**:
   - **Best Case**: Linear search finds the element quickly, so it can be considered O(1) in the best-case scenario.
   - **Worst Case**: Linear search may require examining every element in the array, which is O(N).

2. **General Big O Notation**
   - **Worst-Case Focus**: Big O Notation typically refers to the worst-case scenario because it provides a guarantee on the maximum time or space an algorithm will require. This is useful for understanding the upper limit of an algorithm's performance and preparing for the worst-case scenario.
   - **Pessimistic Approach**: By focusing on the worst case, we ensure that the algorithm will not exceed the given performance bounds, which helps in making informed decisions about algorithm choice and application.

## Stacks

![[Pasted image 20240819210826.png]]

- **Basic Concept:**
  - A stack is a data structure that stores elements in a list-like manner, with specific rules for how elements can be added, removed, and accessed.

- **Key Constraints:**
  - **Insertion:** Elements can only be added to the *top* of the stack.
  - **Deletion:** Elements can only be removed from the *top* of the stack.
  - **Access:** Only the last (top) element of the stack can be read.

- **Analogy:**
  - A stack is like a stack of dishes:
    - You can only add a dish to the top of the stack.
    - You can only remove the top dish.
    - You can only see the dish on top.

- **Terminology:**
  - The *top* of the stack refers to the end where elements are added or removed.
  - The *bottom* of the stack is where the first element is placed, but it cannot be accessed unless all the elements above it are removed.

- **LIFO Processing:**
	- Stacks are perfect for scenarios where the most recent data needs to be processed first.
	- **Example Use Case:** The "undo" function in word processors:
	    - Each keystroke is pushed onto the stack.
	    - When "undo" is pressed, the most recent keystroke is popped off and removed from the document.
	    - This mechanism allows for sequential undo actions, removing the most recent changes one by one.

## Abstract Data Types

- **Abstract Data Types (ADTs):**
  - An ADT is a data structure defined by a set of operations or behaviors rather than by its implementation.
  - ADTs focus on *what* operations are performed, not *how* they are performed.

- **Stack Example:**
  - **Implementation in C++ (replacing Ruby code):**

    ```cpp
    class Stack {
    private:
        std::vector<int> data; // Using a vector to store the stack elements

    public:
        void push(int element) {
            data.push_back(element); // Adds element to the end (top) of the stack
        }

        int pop() {
            int lastElement = data.back(); // Retrieves the top element
            data.pop_back(); // Removes the top element
            return lastElement;
        }

        int read() const {
            return data.back(); // Returns the top element without removing it
        }
    };
    ```

  - **Key Points:**
    - The stack operations (`push`, `pop`, `read`) are implemented on top of a `std::vector` in C++.
    - The stack enforces a Last-In-First-Out (LIFO) access pattern, regardless of the underlying data structure.

- **ADTs vs. Built-in Data Structures:**
  - Unlike arrays, which are built into most languages and interact directly with memory, stacks are more about *how* data is accessed and manipulated.
  - The implementation of a stack could use different underlying data structures (like arrays or linked lists) without changing the stack's behavior.

- **Abstract Concept:**
  - The stack, as an ADT, doesn’t depend on the underlying data structure; it only requires that the data be managed in a LIFO manner.
  - This concept allows flexibility in how the stack is implemented, making it abstract and adaptable.

## Queues

![[Pasted image 20240819211441.png]]

- **Definition**:
    - A queue is a data structure designed to process temporary data.
    - It is an abstract data type, similar to a stack but with different processing order.
- **Analogy**:
    - Think of a queue as a line of people at a movie theater.
    - The first person in line is the first to enter the theater.
    - This is known as **FIFO** (First In, First Out).
- **Structure**:
    - Queues are usually depicted horizontally.
    - The beginning of the queue is called the **front**, and the end is called the **back**.
- **Restrictions**:
    - **Insertion**: Data can be inserted only at the end of the queue.
    - **Deletion**: Data can be deleted only from the front of the queue.
    - **Access**: Only the element at the front of the queue can be read.
- **Comparison with Stacks**:
    - **Insertion**: Both queues and stacks insert data at the end.
    - **Deletion**: Queues delete data from the front, while stacks delete from the end.
    - **Access**: Queues read from the front, while stacks read from the end.

### C++ Code Implemenation

```cpp
#include <iostream>
#define MAX 1000

class Queue {
    int front, rear;
    int arr[MAX];

public:
    Queue() {
        front = -1;
        rear = -1;
    }

    bool isFull() {
        return (rear == MAX - 1);
    }

    bool isEmpty() {
        return (front == -1 || front > rear);
    }

    void enqueue(int value) {
        if (isFull()) {
            std::cout << "Queue is full\n";
            return;
        }
        if (front == -1) front = 0;
        arr[++rear] = value;
    }

    int dequeue() {
        if (isEmpty()) {
            std::cout << "Queue is empty\n";
            return -1;
        }
        return arr[front++];
    }

    int peek() {
        if (isEmpty()) {
            std::cout << "Queue is empty\n";
            return -1;
        }
        return arr[front];
    }
};

int main() {
    Queue q;

    q.enqueue(10);
    q.enqueue(20);
    q.enqueue(30);

    std::cout << "Dequeued: " << q.dequeue() << "\n";
    std::cout << "Front element: " << q.peek() << "\n";

    return 0;
}
```

### Explanation:

- **Queue Class**: Defines the queue with methods to enqueue, dequeue, and peek.
- **Array-Based Implementation**: Uses a fixed-size array to store elements.
- **Front and Rear**: Track the front and rear positions of the queue.
- **Methods**:
    - `enqueue(int value)`: Adds an element to the end of the queue.
    - `dequeue()`: Removes and returns the front element of the queue.
    - `peek()`: Returns the front element without removing it.
    - `isFull()`: Checks if the queue is full.
    - `isEmpty()`: Checks if the queue is empty.

## Recurse Instead of Loop

- **Task**: Create a countdown function that accepts a number and displays numbers from that number down to 0.

- **Initial Loop Implementation**:
    - Uses a `for` loop to iterate from the given number down to 0.
    - Example in JavaScript:
        ```javascript
        function countdown(number) {
            for(let i = number; i >= 0; i--) {
                console.log(i);
            }
        }
        countdown(10);
        ```

- **Recursive Implementation**:
    - Uses a function that calls itself to achieve the countdown.
    - Example in JavaScript:
        ```javascript
        function countdown(number) {
            console.log(number);
            countdown(number - 1);
        }
        countdown(10);
        ```

- **Steps in Recursive Countdown**:
    1. Call `countdown(10)`, `number` starts at 10.
    2. Print `number` (10).
    3. Call `countdown(9)`.
    4. Print `number` (9).
    5. Call `countdown(8)`.
    6. Continue this process until `number` is less than 0.
- **Base Case**:
    - To prevent infinite recursion, add a base case to stop the recursion when `number` is 0.
    - Example in JavaScript:
        
        ```javascript
        function countdown(number) {
            console.log(number);
            if (number === 0) {
                return;
            } else {
                countdown(number - 1);
            }
        }
        countdown(10);
        ```

### C++ Implementation of Recursive Countdown

Here’s how you can implement the countdown function using recursion in C++:

```cpp
#include <iostream>

void countdown(int number) {
    if (number < 0) return; // Base case: stop when number is less than 0
    std::cout << number << std::endl;
    countdown(number - 1); // Recursive call with number decremented by 1
}

int main() {
    countdown(10); // Start the countdown from 10
    return 0;
}
```

#### Explanation:

- **Base Case**: The function stops calling itself when `number` is less than 0.
- **Recursive Call**: The function calls itself with `number - 1`, effectively counting down.
- **Output**: Each call to the function prints the current value of `number`.

## The Call Stack in Recursion

#### **Overview:**
The call stack is a fundamental concept in computer science, particularly when dealing with recursive functions. It operates on a Last-In-First-Out (LIFO) principle, making it ideal for managing function calls, especially in recursion where functions call themselves repeatedly.

#### **How the Call Stack Works:**
1. **Initial Call:**
   - When a function is called (e.g., `factorial(3)`), the computer needs to remember that it’s in the middle of executing this function. It pushes this function call onto the call stack.
	  ![[Pasted image 20240819212740.png]]
2. **Subsequent Recursive Calls:**
   - Before `factorial(3)` completes, it calls `factorial(2)`. To keep track of `factorial(3)`, the computer pushes `factorial(2)` onto the stack. The same process happens with `factorial(2)` calling `factorial(1)`.
	![[Pasted image 20240819212752.png]]

3. **Base Case:**
   - When `factorial(1)` is called, it reaches the base case and completes execution without making further recursive calls. 

4. **Unwinding the Stack:**
   - After `factorial(1)` finishes, the computer pops it off the stack and resumes the execution of `factorial(2)`, completing it. It then pops `factorial(2)` and completes `factorial(3)` similarly. The stack is empty when all function calls are completed, indicating that the recursion is fully resolved.
	![[Pasted image 20240819212849.png]]

#### **Stack Overflow:**
- **Infinite Recursion:** 
  - If a function continually calls itself without a base case (e.g., `blah()` calling `blah()` indefinitely), the call stack grows indefinitely. Since the stack is stored in a limited region of memory, it eventually fills up, leading to a **stack overflow**.
  - A stack overflow occurs when there’s no more memory to push new function calls onto the stack, causing the program to crash or throw an error.

#### **Bird's-Eye View of Execution Order:**
1. `factorial(3)` is called.
2. `factorial(2)` is called.
3. `factorial(1)` is called.
4. `factorial(1)` completes.
5. `factorial(2)` completes.
6. `factorial(3)` completes.

#### **Value Passing in the Call Stack:**
- As the call stack unwinds, each function returns its computed value to the previous function (its “parent”). This return of values is crucial in recursive calculations, where the final result is built up as each function call completes.

### **Key Takeaways:**
- **LIFO Structure:** The call stack operates on a last-in, first-out basis, making it perfect for managing recursive function calls.
- **Memory Limitations:** Each new function call consumes stack space. Without proper termination (base case), recursive functions can lead to stack overflow.
- **Function Unwinding:** As the call stack unwinds, values are passed back up the chain of function calls, ultimately leading to the final result.

## Recursive Trick: Passing Extra Parameters

#### **Problem: Doubling Array Elements Using Recursion**

The task here is to double each element in an array in place, without creating a new array. Recursion is chosen over a traditional loop, and a common technique is introduced: passing extra parameters to manage additional state.

#### **Challenge:**
When using recursion, maintaining a state such as an index (to track which element to process next) is tricky because recursive functions typically don’t have persistent state between calls unless you explicitly manage it.

#### **Solution: Passing an Extra Parameter**

The key technique here is passing an additional parameter (like an index) to keep track of which element of the array needs to be processed next.

### **Step-by-Step Implementation**

1. **Basic Recursive Function Call:**
   - Start by defining the function that calls itself recursively. Initially, the code just recursively calls `double_array()` without doing anything useful.
   - Example:
     ```python
     def double_array(array):
         double_array(array)
     ```

2. **Adding Functionality:**
   - Modify the function to actually double the first element of the array. 
   - Example:
     ```python
     def double_array(array):
         array[0] *= 2
         double_array(array)
     ```

3. **Handling the Index:**
   - To double each element, you need to track which element you’re currently processing. This requires passing an index parameter to the function.
   - Example:
     ```python
     def double_array(array, index):
         array[index] *= 2
         double_array(array, index + 1)
     ```

4. **Base Case to Prevent Errors:**
   - Add a base case to stop the recursion when the index exceeds the array length. Without a base case, the function will try to access an out-of-bounds element, causing an error.
   - Example:
     ```python
     def double_array(array, index):
         if index >= len(array):
             return
         array[index] *= 2
         double_array(array, index + 1)
     ```

5. **Using Default Parameters for a Cleaner API:**
   - To simplify the function call, you can set a default value for the `index` parameter, so the user doesn’t need to specify it initially. This makes the function call cleaner and hides the implementation detail of managing the index.
   - Example:
     ```python
     def double_array(array, index=0):
         if index >= len(array):
             return
         array[index] *= 2
         double_array(array, index + 1)
     ```

### **Final Implementation:**
Here’s the final, polished function:
```python
def double_array(array, index=0):
    # Base case: when the index goes past the end of the array
    if index >= len(array):
        return
    array[index] *= 2
    double_array(array, index + 1)
```

### **Usage:**
You can now use this function as follows:
```python
array = [1, 2, 3, 4]
double_array(array)
print(array)
```
- **Output:** `[2, 4, 6, 8]`

### C++ Code Implementation

```cpp
#include <iostream>
#include <vector>

void doubleArray(std::vector<int>& array, int index = 0) {
    // Base case: if the index goes past the end of the array, stop the recursion
    if (index >= array.size()) {
        return;
    }

    // Double the current element
    array[index] *= 2;

    // Recursive call to process the next element
    doubleArray(array, index + 1);
}

int main() {
    // Create an array (vector in C++)
    std::vector<int> array = {1, 2, 3, 4, 5};

    // Call the function to double each element in the array
    doubleArray(array);

    // Print the modified array to verify the result
    for (int num : array) {
        std::cout << num << " ";
    }

    return 0;
}
```

## Two Approaches to Calculations

### **1. Bottom-Up Approach:**

- **Concept:** 
  - You start from the smallest possible subproblem and build up to the solution.
  - In the factorial example, you calculate the factorial of `1`, then `2`, and so on, until you reach the desired number `n`.

- **Non-Recursive Example in C++:**
  - This is typically done using a loop.

```cpp
int factorial(int n) {
    int product = 1;
    for (int i = 1; i <= n; ++i) {
        product *= i;
    }
    return product;
}
```

- **Recursive Example in C++ (Bottom-Up):**
  - Although recursion is not particularly beneficial for a bottom-up approach, you can still implement it.

```cpp
int factorial(int n, int i = 1, int product = 1) {
    if (i > n) return product;
    return factorial(n, i + 1, product * i);
}
```
  - Here, the function starts with `i = 1` and a `product` of `1`. It keeps multiplying `product` by `i` until `i` exceeds `n`.

### **2. Top-Down Approach:**

- **Concept:**
  - You start from the problem in its entirety and break it down into smaller subproblems.
  - In the factorial example, you start with `n` and consider the factorial of `n` as `n * factorial(n-1)`.

- **Recursive Example in C++ (Top-Down):**
  - This approach is more natural and commonly used with recursion.

```cpp
int factorial(int n) {
    if (n == 1) return 1;  // Base case
    return n * factorial(n - 1);  // Recursive call
}
```
  - The function continues to call itself with `n-1` until it reaches the base case `n == 1`, at which point it returns `1`.

### **Key Differences:**

- **Bottom-Up:**
  - Uses an iterative approach (often a loop) to build up the solution.
  - Can be done with or without recursion, but recursion may not add much value here.

- **Top-Down:**
  - Relies heavily on recursion, breaking down the problem into smaller subproblems until reaching a base case.
  - It's more natural for problems where you want to consider the problem in its entirety and break it down recursively.

### **When to Use Which:**

- **Bottom-Up:**
  - Ideal when the problem is naturally iterative or when recursion is unnecessary.
  - Easier to implement and understand for simple problems.

- **Top-Down:**
  - Useful when the problem can be broken down recursively.
  - More elegant for complex problems involving multiple levels of depth or where subproblems naturally lead to the solution.

## Top-Down Recursion

1. **Imagine the Function is Already Implemented:** 
   - When writing a recursive function, pretend the function you're writing has already been implemented by someone else. This allows you to focus on the overall problem-solving strategy without getting bogged down by the implementation details.

2. **Identify the Subproblem:** 
   - Break down the problem into a smaller version of itself. For example, in summing an array, the subproblem is to sum all elements except the first one.

3. **Use the Function on the Subproblem:** 
   - Apply the function recursively to the subproblem and combine its result with the first element of the array to get the solution for the full problem.

4. **Base Case:** 
   - Ensure to define a base case that will stop the recursion, typically when the problem is reduced to its simplest form.

### **Example: Summing an Array in C++**

```cpp
#include <iostream>
#include <vector>

int sum(const std::vector<int>& array, int start) {
    // Base case: If we've reached the last element, return it.
    if (start == array.size() - 1) {
        return array[start];
    }
    
    // Recursive case: Add the current element to the sum of the rest.
    return array[start] + sum(array, start + 1);
}

int main() {
    std::vector<int> array = {1, 2, 3, 4, 5};
    int result = sum(array, 0);
    std::cout << "Sum of the array is: " << result << std::endl;
    return 0;
}
```

### **Explanation:**

- **Base Case:** 
  - The base case is `if (start == array.size() - 1)`, where we return the last element of the array. This ensures that when the function reaches the last element, it stops making further recursive calls.

- **Recursive Case:** 
  - The function `sum(array, start + 1)` is called on the subproblem, which is the array excluding the current element at `start`. We then add `array[start]` to the result of this recursive call.

### **How It Works:**
- If the array is `[1, 2, 3, 4, 5]`, the function will:
  1. Return `1 + sum([2, 3, 4, 5])`
  2. Return `2 + sum([3, 4, 5])`
  3. Return `3 + sum([4, 5])`
  4. Return `4 + sum([5])`
  5. Finally, return `5` when it reaches the base case.

- The results are then combined as the recursion unwinds, ultimately summing the entire array.

### **Advantages:**
- This top-down approach makes it easier to think about the problem because you focus on breaking down the problem and rely on the recursive function to handle the details of the subproblem.

## Binary Search

Binary search is a highly efficient algorithm used to find an item in a sorted array by repeatedly dividing the search interval in half. It’s akin to the guessing game where you eliminate half the possible answers with each guess.

#### **How Binary Search Works**

1. **Initial Setup**:
   - Start with the entire array.
   - Define two pointers: `low` (start of the array) and `high` (end of the array).

2. **Iterative Search**:
   - Calculate the midpoint of the array segment.
   - Compare the target value with the value at the midpoint:
     - If the target equals the midpoint value, you’ve found the target.
     - If the target is less than the midpoint value, adjust the `high` pointer to search the left half.
     - If the target is greater, adjust the `low` pointer to search the right half.
   - Repeat until the `low` pointer exceeds the `high` pointer or the target is found.

3. **Efficiency**:
   - **Time Complexity**: $O(\log N)$, where $N$ is the number of elements in the array. This logarithmic time complexity makes binary search much faster than linear search, especially for large arrays.
   - **Space Complexity**: $O(1)$ for the iterative approach, as it requires only a few additional variables.

![[Pasted image 20240819202513.png]]

#### **Example**

Suppose you have an ordered array `[1, 3, 4, 7, 9, 11]` and want to find the value `7`. Here’s a step-by-step breakdown:

1. **Initial State**:
   - Array: `[1, 3, 4, 7, 9, 11]`
   - `low` = 0, `high` = 5

2. **First Iteration**:
   - `midpoint` = (0 + 5) / 2 = 2
   - Value at index 2 is `4`
   - Since `7 > 4`, update `low` to `midpoint + 1` = 3

3. **Second Iteration**:
   - `low` = 3, `high` = 5
   - `midpoint` = (3 + 5) / 2 = 4
   - Value at index 4 is `9`
   - Since `7 < 9`, update `high` to `midpoint - 1` = 3

4. **Third Iteration**:
   - `low` = 3, `high` = 3
   - `midpoint` = (3 + 3) / 2 = 3
   - Value at index 3 is `7`
   - Found the target!

#### **Code Implementation**

```cpp
#include <iostream>
#include <vector>

int binarySearch(const std::vector<int>& array, int searchValue) {
    int low = 0;
    int high = array.size() - 1;

    while (low <= high) {
        int midpoint = low + (high - low) / 2;
        int valueAtMidpoint = array[midpoint];

        if (searchValue == valueAtMidpoint) {
            return midpoint;  // Target found
        } else if (searchValue < valueAtMidpoint) {
            high = midpoint - 1;  // Search in the left half
        } else {
            low = midpoint + 1;   // Search in the right half
        }
    }

    return -1;  // Target not found
}

int main() {
    std::vector<int> sortedArray = {1, 3, 4, 7, 9, 11};
    int target = 7;

    int result = binarySearch(sortedArray, target);

    if (result != -1) {
        std::cout << "Value " << target << " found at index " << result << ".\n";
    } else {
        std::cout << "Value " << target << " not found.\n";
    }

    return 0;
}
```

#### **Explanation**

1. **Function `binarySearch`**:
   - Takes a `std::vector<int>` (which represents the sorted array) and an integer `searchValue`.
   - Initializes `low` and `high` pointers to represent the range of indices to search within.
   - Uses a `while` loop to repeatedly narrow down the search range:
     - Computes the `midpoint` index.
     - Compares the value at `midpoint` with `searchValue`:
       - If they match, returns the `midpoint` index.
       - If `searchValue` is less than the midpoint value, narrows the search to the left half.
       - If `searchValue` is greater, narrows the search to the right half.
   - Returns `-1` if the `searchValue` is not found.

2. **`main` Function**:
   - Defines a `std::vector<int>` with sorted values.
   - Calls `binarySearch` with the target value.
   - Prints the result to the console.

[Binary Search Video Tutorial](https://www.youtube.com/watch?v=fDKIpRe8GW4&list=PL9xmBV_5YoZMIAJn8M6At9CjZ0Wu0B31d&pp=iAQB)

## Binary Search vs. Linear Search

#### **Linear Search**
- **Description**: Linear search checks each element in the array sequentially until it finds the target value or exhausts the array.
- **Steps**:
  - Start from the beginning of the array.
  - Compare each element with the target value.
  - Continue until you find the target or reach the end of the array.
- **Time Complexity**: O(N), where N is the number of elements in the array.
  - **Worst-case scenario**: If the target value is at the end or not in the array, it will take N steps.
  - **Best-case scenario**: If the target is at the first position, it will take 1 step.

#### **Binary Search**
- **Description**: Binary search works on sorted arrays by repeatedly dividing the search interval in half.
- **Steps**:
  - Start with the middle element of the array.
  - Compare the middle element with the target value.
  - If the target value is less, search the left half; if greater, search the right half.
  - Repeat until the target is found or the search interval is empty.
- **Time Complexity**: O(log N), where N is the number of elements in the array.
  - **Worst-case scenario**: In a binary search on an array of size N, it will take at most log₂(N) + 1 steps. This is due to the halving of the search space with each step.
  - **Best-case scenario**: If the target is at the middle, it will take 1 step.

#### **Comparing Performance**

- **For a small array (e.g., 3 elements)**:
  - **Linear Search**: Up to 3 steps.
  - **Binary Search**: Up to 2 steps.

- **For a medium-sized array (e.g., 100 elements)**:
  - **Linear Search**: Up to 100 steps.
  - **Binary Search**: Up to 7 steps.

- **For a large array (e.g., 10,000 elements)**:
  - **Linear Search**: Up to 10,000 steps.
  - **Binary Search**: Up to 14 steps.

- **For an even larger array (e.g., 1,000,000 elements)**:
  - **Linear Search**: Up to 1,000,000 steps.
  - **Binary Search**: Up to 20 steps.

#### **Visualizing Performance**

- **Linear Search**: As the number of elements increases, the number of steps increases linearly. This creates a diagonal line in a graph, where the slope represents a proportional increase in steps with the increase in data size.

- **Binary Search**: As the number of elements increases, the number of steps increases logarithmically. This creates a much flatter curve on the graph, showing a much slower increase in steps compared to linear search.

![[Pasted image 20240819202706.png]]

#### **Trade-offs**

- **Insertion and Deletion**: Ordered arrays have slower insertion and deletion compared to unsorted arrays due to the need to maintain order. Binary search is only efficient for searching in sorted data.

- **Use Case Analysis**: 
  - **If your application frequently inserts and deletes elements**, a standard array (or other data structure) might be more appropriate.
  - **If your application frequently searches through a large dataset**, an ordered array with binary search could be more efficient despite the slower insertion time.

## Understanding O(log N) Complexity

**Binary Search** and algorithms like it fall into the category of O(log N) complexity. Let’s explore why this is the case and how it compares to other complexities.

#### **What is O(log N)?**

1. **Definition**:
   - **O(log N)**: This notation represents algorithms where the number of steps increases logarithmically as the size of the input data (N) increases. In simpler terms, the number of steps grows proportionally to the logarithm of the input size.
   - **Logarithms**: Logarithms are the inverse of exponentiation. For example, $\log_2 8 = 3$ because $2^3 = 8$. Logarithms tell us how many times we need to multiply a base number (like 2) to reach a certain value.

2. **Understanding Logarithms**:
   - To understand O(log N) in practical terms, consider how many times you need to divide the data size by 2 until you reach 1. For instance:
     - For $N = 8$, $\log_2 8 = 3$ (You divide 8 by 2 three times: 8 → 4 → 2 → 1).
     - For $N = 64$, $\log_2 64 = 6$ (You divide 64 by 2 six times to get 1).

![[Pasted image 20240819203149.png]]

#### **Why Binary Search is O(log N)**

- **Binary Search Mechanism**:
  - **Process**: In binary search, you start with the entire sorted array and repeatedly divide the search space in half.
  - **Steps**: Each step halves the number of elements to search through. This halving continues until you either find the target value or narrow down the search space to zero.

- **Example**:
  - For an array of size 8, you might need 3 steps: 8 → 4 → 2 → 1.
  - For an array of size 1024, you would need about 10 steps: $\log_2 1024 = 10$.

#### **Comparison with Other Complexities**

1. **O(1) - Constant Time**:
   - **Definition**: Takes a constant number of steps, regardless of input size.
   - **Efficiency**: Best for scenarios where operations don’t depend on the size of the data.

2. **O(N) - Linear Time**:
   - **Definition**: Takes as many steps as there are data elements.
   - **Efficiency**: Each additional data element adds one more step.

3. **O(log N) - Logarithmic Time**:
   - **Definition**: Takes fewer steps as the data size increases, increasing only logarithmically.
   - **Efficiency**: Much more efficient than O(N) for large datasets. For example, in an array with 1,024 elements, binary search (O(log N)) takes 10 steps, while a linear search (O(N)) would take up to 1,024 steps.

#### **Graphical Representation**

**Graph Comparison**:
- **O(1)**: A horizontal line indicating constant steps.
- **O(log N)**: A curve that rises slowly, increasing gradually as N grows.
- **O(N)**: A straight diagonal line indicating a direct, proportional relationship between steps and data size.

**Example Table**:

| N Elements | O(N) | O(log N) |
|------------|------|----------|
| 8          | 8    | 3        |
| 16         | 16   | 4        |
| 32         | 32   | 5        |
| 64         | 64   | 6        |
| 128        | 128  | 7        |
| 256        | 256  | 8        |
| 512        | 512  | 9        |
| 1024       | 1024 | 10       |

## Trees

- **Tree Structure:**
  - **Node-Based Data Structure:** Like linked lists, trees consist of nodes. However, each node in a tree can have links (branches) to multiple other nodes.
  - **Visualization:** A tree is often depicted with the root at the top and branches growing downward.

- **Tree Terminology:**
  - **Root:** The topmost node in a tree. It is the ancestor of all other nodes. In the given example, "j" is the root.
  - **Parent and Child:** 
    - **Parent:** A node that has branches to other nodes (children).
    - **Child:** A node that is connected by a branch from another node (parent). For instance, "j" is the parent of "m" and "b," while "m" and "b" are children of "j."
  - **Descendants and Ancestors:**
    - **Descendants:** All nodes that stem from a particular node.
    - **Ancestors:** All nodes that a particular node stems from. For example, "j" is the ancestor of all other nodes in the tree.
  - **Levels:** The rows within a tree, where each row represents a different level. The root is at level 1, its children are at level 2, and so on.

- **Tree Balance:**
  - **Balanced Tree:** A tree is balanced if the subtrees of every node contain the same number of nodes. In the example, the tree is perfectly balanced because each node's subtrees have an equal number of nodes.
  - **Imbalanced Tree:** If one subtree has more nodes than the other, the tree is imbalanced. An imbalance can affect the performance of operations like search, insertion, and deletion.

### Visual Examples

**Balanced Tree:**
![[Pasted image 20240819222526.png]]

**Imbalanced Tree:**
![[Pasted image 20240819222537.png]]

This concept of balance is crucial for many tree operations, particularly in structures like **Binary Search Trees (BSTs)** where balanced trees ensure efficient performance.

## Binary Search Trees (BSTs)

- **Binary Tree:**
  - A **binary tree** is a tree where each node has zero, one, or two children.

- **Binary Search Tree (BST):**
  - A **binary search tree** is a special type of binary tree that follows two key rules:
    1. Each node can have at most one "left" child and one "right" child.
    2. The "left" child and its descendants must have values less than the node's value, while the "right" child and its descendants must have values greater than the node's value.

### Characteristics of a BST:
- **Left Child:** Contains values less than the parent node.
- **Right Child:** Contains values greater than the parent node.
- **Structure Example:**

![[Pasted image 20240819222612.png]]

  - In this example:
    - The root is 50.
    - The left subtree of 50 contains values less than 50 (25, 10, 33, ...).
    - The right subtree of 50 contains values greater than 50 (75, 56, 52, 95, ...).
    - This pattern holds true for each node in the tree.

### Invalid BST Example:
- A binary tree that does not follow the BST rules:
  ```
         50
        /  \
       25   40
      / 
     30 
  ```
  - This is a binary tree because each node has at most two children.
  - However, it is not a valid BST because the right child of the root (40) is less than the root (50), violating the BST property.

### C++ Implementation of a BST Node and Simple Tree

```cpp
#include <iostream>

class TreeNode {
public:
    int value;
    TreeNode* leftChild;
    TreeNode* rightChild;

    TreeNode(int val) : value(val), leftChild(nullptr), rightChild(nullptr) {}
};

// Function to insert a new node into the BST
TreeNode* insert(TreeNode* root, int value) {
    if (root == nullptr) {
        return new TreeNode(value);
    }

    if (value < root->value) {
        root->leftChild = insert(root->leftChild, value);
    } else if (value > root->value) {
        root->rightChild = insert(root->rightChild, value);
    }

    return root;
}

// Function to search for a value in the BST
bool search(TreeNode* root, int value) {
    if (root == nullptr) {
        return false;
    }

    if (root->value == value) {
        return true;
    }

    if (value < root->value) {
        return search(root->leftChild, value);
    } else {
        return search(root->rightChild, value);
    }
}

int main() {
    TreeNode* root = nullptr;

    // Inserting nodes into the BST
    root = insert(root, 50);
    insert(root, 25);
    insert(root, 75);
    insert(root, 10);
    insert(root, 30);
    insert(root, 60);
    insert(root, 85);

    // Searching for a value
    int target = 30;
    if (search(root, target)) {
        std::cout << target << " found in the tree." << std::endl;
    } else {
        std::cout << target << " not found in the tree." << std::endl;
    }

    return 0;
}
```

### Explanation of the Code:
- **TreeNode Class:**
  - Represents a node in the BST with an integer value and pointers to left and right children.

- **Insert Function:**
  - Recursively inserts a new value into the tree, maintaining the BST properties.

- **Search Function:**
  - Recursively searches for a value in the tree, returning `true` if found and `false` otherwise.

This C++ implementation allows efficient insertion and search operations in a BST, with time complexity of $O(\log N)$ on average for balanced trees.

## Search a BST

### Steps for Searching in a Binary Search Tree (BST)

1. **Start at the Root:** 
   - Begin the search at the root node, which is initially the "current node."

![[Pasted image 20240819222911.png]]
(Say we want to search for the 61.)

2. **Inspect the Current Node:** 
   - Check the value of the current node.

3. **Check for Match:**
   - If the value matches the one you're searching for, the search is complete.

4. **Move to the Left Subtree (if applicable):** 
   - If the value you're searching for is less than the current node's value, move to the left child node and designate it as the new current node.

![[Pasted image 20240819222922.png]]

5. **Move to the Right Subtree (if applicable):**
   - If the value you're searching for is greater than the current node's value, move to the right child node and designate it as the new current node.\

![[Pasted image 20240819223008.png]]

6. **Repeat the Process:**
   - Continue the process by repeating steps 2-5 until either:
     - The value is found.
     - You reach a leaf node (a node without children), indicating that the value is not in the tree.

![[Pasted image 20240819223016.png]]

### Efficiency of the Search
- **Time Complexity:** 
  - The efficiency of searching in a BST is generally $O(\log N)$ for a balanced tree, where $N$ is the number of nodes. This is because each step of the search halves the number of potential nodes to explore by moving either left or right.
  
- **Caveat for Imbalance:**
  - The $O(\log N)$ complexity assumes the tree is balanced. In an imbalanced tree (where nodes are skewed to one side), the worst-case time complexity could degrade to $O(N)$, making the search equivalent to a linear search in a linked list.

### C++ Implementation

```cpp
#include <iostream>

class TreeNode {
public:
    int value;
    TreeNode* leftChild;
    TreeNode* rightChild;

    TreeNode(int val) : value(val), leftChild(nullptr), rightChild(nullptr) {}
};

class BST {
public:
    TreeNode* root;

    BST() : root(nullptr) {}

    // Function to insert a new node into the BST
    void insert(int value) {
        root = insertRec(root, value);
    }

    // Function to search for a value in the BST
    bool search(int value) {
        return searchRec(root, value);
    }

private:
    // Helper function for inserting a new node
    TreeNode* insertRec(TreeNode* node, int value) {
        if (node == nullptr) {
            return new TreeNode(value);
        }

        if (value < node->value) {
            node->leftChild = insertRec(node->leftChild, value);
        } else if (value > node->value) {
            node->rightChild = insertRec(node->rightChild, value);
        }

        return node;
    }

    // Helper function for searching a value
    bool searchRec(TreeNode* node, int value) {
        if (node == nullptr) {
            return false;
        }

        if (node->value == value) {
            return true;
        } else if (value < node->value) {
            return searchRec(node->leftChild, value);
        } else {
            return searchRec(node->rightChild, value);
        }
    }
};

int main() {
    BST tree;

    // Inserting nodes into the BST
    tree.insert(50);
    tree.insert(25);
    tree.insert(75);
    tree.insert(10);
    tree.insert(30);
    tree.insert(60);
    tree.insert(85);

    // Searching for a value in the BST
    int target = 30;
    if (tree.search(target)) {
        std::cout << target << " found in the tree." << std::endl;
    } else {
        std::cout << target << " not found in the tree." << std::endl;
    }

    return 0;
}
```

### Explanation:

1. **TreeNode Class:**
   - Represents each node in the BST with an integer value, and pointers to left and right child nodes.

2. **BST Class:**
   - Contains a `root` pointer to the root node of the tree.
   - Implements the `insert` function to add values to the tree.
   - Implements the `search` function to find a value in the tree.

3. **Insertion:**
   - The `insertRec` function recursively finds the correct spot in the tree for a new value while maintaining the BST properties.

4. **Search:**
   - The `searchRec` function recursively checks nodes to find the target value. It follows the logic:
     - If the value matches the current node, return true.
     - If the value is less, search the left subtree.
     - If the value is greater, search the right subtree.
     - If a leaf node is reached without finding the value, return false.

5. **Main Function:**
   - Demonstrates inserting nodes into the BST and searching for a specific value.

## O(log N) Complexity in Binary Search Trees

The $O(\log N)$ complexity in binary search trees (BSTs) is a fundamental property that explains why searching in a balanced BST is so efficient. This concept is deeply tied to the structure of the tree itself, particularly the number of levels (or rows) that the tree has.

#### Logarithmic Levels in a Balanced Binary Tree

A binary tree is a hierarchical structure where each node has at most two children. In a balanced binary tree, the nodes are evenly distributed across all levels, which means the tree is as compact as possible given the number of nodes.

- **Doubling Nodes with Each Level:** In a complete binary tree, every level of the tree doubles the number of nodes from the previous level (except possibly the last level, which might not be fully filled). This means if level 1 has 1 node, level 2 has 2 nodes, level 3 has 4 nodes, and so on. This doubling pattern follows an exponential growth, which is the inverse of the logarithmic relationship.

- **Logarithmic Growth of Levels:** Because the number of nodes doubles with each level, the number of levels required to hold $N$ nodes in a balanced binary tree grows logarithmically with $N$. Specifically, the number of levels $L$ in a perfectly balanced binary tree with $N$ nodes can be approximated by $L = \log_2(N)$.

    - For example, if a binary tree has $31$ nodes, you would calculate the levels as:
      $L = \log_2(31) \approx 5$
      This means a balanced binary tree with 31 nodes has about 5 levels.

#### O(log N) Search Complexity

- **Search Process:** When searching for a value in a BST, you start at the root and at each step, you decide to move to either the left or right child depending on the value you're searching for relative to the current node. Each step effectively eliminates half of the tree from consideration, which is similar to how binary search works in a sorted array.

- **Connection to Tree Levels:** Since each step in the search process corresponds to moving down one level in the tree, the maximum number of steps required to find a value (or determine it's not in the tree) is equal to the number of levels in the tree. Hence, the search operation in a balanced BST has a time complexity of $O(\log N)$.

#### Comparison to Binary Search in an Array

- **Binary Search in an Array:** Similarly, binary search in a sorted array also operates in $O(\log N)$ time because each comparison eliminates half of the remaining elements. 

- **Advantage of BSTs:** The key advantage of BSTs over arrays is in insertion and deletion operations. Inserting or deleting a value in a sorted array typically requires $O(N)$ time because elements may need to be shifted. In contrast, inserting or deleting in a BST can be done in $O(\log N)$ time, making BSTs more efficient for dynamic datasets where elements are frequently added or removed.

### Summary
- A balanced binary tree with $N$ nodes has approximately $\log_2(N)$ levels.
- Searching in a BST takes $O(\log N)$ steps because each step eliminates half of the remaining tree, similar to binary search in an array.
- While both searching in a BST and binary search in an ordered array have $O(\log N)$ time complexity, BSTs provide more efficient insertion and deletion operations.

## Insertion in a Binary Search Tree (BST)

1. **Start at the Root:**
   - Begin the insertion process by comparing the value you want to insert with the root node.
	![[Pasted image 20240820093354.png]]

2. **Compare and Traverse:**
   - If the value is less than the current node's value, move to the left child.
   - If the value is greater than the current node's value, move to the right child.
	   - Since 45 is less than 50, we drill down to the left child:
		![[Pasted image 20240820093424.png]]
     	  - Since 45 is greater than 25, we must inspect the right child:
		![[Pasted image 20240820093515.png]]
	   - Since 45 is greater than 33, we check the 33’s right child:
		![[Pasted image 20240820093609.png]]

3. **Repeat Until Leaf Node:**
   - Continue comparing and moving left or right until you reach a node that has no appropriate child (i.e., a leaf node).

4. **Insert the New Node:**
   - Once you reach a leaf node, insert the new value as either a left or right child, depending on whether it is less or greater than the leaf node's value.
	![[Pasted image 20240820093645.png]]

### Efficiency of Insertion:
- **Time Complexity:** 
  - The insertion process in a balanced BST involves first searching for the correct position, which takes $O(\log N)$ time, followed by inserting the node in $O(1)$ time.
  - Thus, the overall time complexity for insertion is $O(\log N)$.

### Why BSTs are Efficient for Insertion:
- **Comparison with Ordered Arrays:**
  - Ordered arrays take $O(\log N)$ for search but $O(N)$ for insertion because elements may need to be shifted to accommodate the new element.
  - In contrast, BSTs handle both search and insertion in $O(\log N)$ time, making them highly efficient, especially when frequent insertions are expected.

### C++ Implementation

```cpp
#include <iostream>

class TreeNode {
public:
    int value;
    TreeNode* leftChild;
    TreeNode* rightChild;

    TreeNode(int val) : value(val), leftChild(nullptr), rightChild(nullptr) {}
};

class BST {
public:
    TreeNode* root;

    BST() : root(nullptr) {}

    // Function to insert a new value into the BST
    void insert(int value) {
        root = insertRec(root, value);
    }

    // Function to perform an in-order traversal of the BST (for display purposes)
    void inOrderTraversal(TreeNode* node) {
        if (node == nullptr) return;
        inOrderTraversal(node->leftChild);
        std::cout << node->value << " ";
        inOrderTraversal(node->rightChild);
    }

    // Function to start in-order traversal from the root
    void display() {
        inOrderTraversal(root);
        std::cout << std::endl;
    }

private:
    // Helper function for inserting a new node into the BST
    TreeNode* insertRec(TreeNode* node, int value) {
        // If the current node is null, create a new node with the value
        if (node == nullptr) {
            return new TreeNode(value);
        }

        // Recursively insert in the left subtree if the value is less than the current node's value
        if (value < node->value) {
            node->leftChild = insertRec(node->leftChild, value);
        }
        // Recursively insert in the right subtree if the value is greater than the current node's value
        else if (value > node->value) {
            node->rightChild = insertRec(node->rightChild, value);
        }

        // Return the (unchanged) node pointer
        return node;
    }
};

int main() {
    BST tree;

    // Inserting nodes into the BST
    tree.insert(50);
    tree.insert(25);
    tree.insert(75);
    tree.insert(10);
    tree.insert(33);
    tree.insert(40);
    tree.insert(45);

    // Display the BST using in-order traversal
    tree.display();

    return 0;
}
```

### Explanation:

1. **TreeNode Class:**
   - Represents each node in the BST with an integer value and pointers to its left and right children.

2. **BST Class:**
   - Contains a `root` pointer to the root node of the tree.
   - Implements the `insert` function to add values to the tree.
   - Includes an `inOrderTraversal` function to traverse and print the tree's elements in order, which helps verify the structure of the BST.

3. **Insertion Logic:**
   - The `insertRec` function is a recursive helper function that determines where the new value should be placed within the tree:
     - If the current node is `nullptr`, a new `TreeNode` is created with the value.
     - If the value is less than the current node's value, the function recurses into the left subtree.
     - If the value is greater, it recurses into the right subtree.

4. **Main Function:**
   - Demonstrates inserting nodes into the BST and displaying the tree using in-order traversal, which should print the values in ascending order if the tree is correctly structured.

### Impact of Insertion Order on Binary Search Trees:

- **Balanced vs. Imbalanced Trees:**
  - **Balanced Tree:** A tree is considered balanced when the depth of the left and right subtrees of any node differ by at most one. In such a tree, search operations take $O(\log N)$ time.
  - **Imbalanced Tree:** When a tree is imbalanced, it can become linear, resembling a linked list. In this scenario, the time complexity for search operations degrades to $O(N)$.

- **Effect of Insertion Order:**
  - **Sorted Data Insertion (Worst-Case):**
    - Inserting data in a sequential order (e.g., 1, 2, 3, 4, 5) leads to a completely imbalanced tree. This results in a tree that is essentially a straight line, causing search operations to become inefficient ($O(N)$).
		![[Pasted image 20240820093840.png]]
  - **Random Order Insertion (Typical-Case):**
    - Inserting data in a random order (e.g., 3, 2, 4, 1, 5) typically results in a more balanced tree. This ensures that search operations remain efficient, usually around $O(\log N)$.
	    ![[Pasted image 20240820093847.png]]

- **Recommendation for Converting Ordered Arrays to BST:**
  - Before converting an ordered array into a binary search tree, it is advisable to randomize the data to prevent the tree from becoming imbalanced and to maintain efficient search performance.

## Deletion in a Binary Search Tree

Deletion in a binary search tree (BST) involves removing a node and then adjusting the tree to maintain the BST properties. The process depends on the number of children the node to be deleted has:

#### 1. **Case 1: Node with No Children (Leaf Node)**
   - **Process:**
     - Simply delete the node.
   - **Example:**
     - If you delete a node like `4` that has no children, you can remove it directly.
     ![[Pasted image 20240820094039.png]]
     ![[Pasted image 20240820094044.png]]

#### 2. **Case 2: Node with One Child**
   - **Process:**
     - Delete the node and replace it with its child.
   - **Example:**
     - If you delete a node like `10` that has only one child (`11`), you remove the `10` and connect `11` to the parent of `10`.
     ![[Pasted image 20240820094057.png]]
     ![[Pasted image 20240820094109.png]]

### Deleting a Node with Two Children

When deleting a node with two children in a binary search tree (BST), the process involves replacing the node with its **successor**. The successor is the node with the smallest value that is greater than the node being deleted.

#### 1. **Find the Successor:**
   - The successor is the node with the smallest value in the right subtree of the node to be deleted.
   - In the given example, if you want to delete `56`, the right subtree of `56` contains `61`. Since `61` is the smallest value in that subtree, it is the successor.
	![[Pasted image 20240820094225.png]]

#### 2. **Replace the Node:**
   - Replace the node to be deleted (`56`) with the successor node (`61`).
   - This involves copying the value of the successor into the node being deleted, and then deleting the successor node.

#### 3. **Handle the Successor's Subtree:**
   - If the successor node (`61`) has a right child, connect this child to the parent of the successor.
   - In this case, after replacing `56` with `61`, the original position of `61` is left empty, so you can simply remove it, as it had no children.
	   ![[Pasted image 20240820094319.png]]

By replacing the node with its successor, you maintain the BST property that all nodes in the left subtree are smaller and all nodes in the right subtree are larger. This ensures the tree remains valid after the deletion.

### Finding the Successor Node

When deleting a node with two children in a Binary Search Tree (BST), you need to find the successor node to maintain the tree's structure.

#### 1. **Start with the Right Child:**
   - Begin by visiting the right child of the node you want to delete. This is the first step to finding the successor.

#### 2. **Traverse Left Subtree:**
   - From the right child, continue moving left, descending through the left children until you reach a node that has no left child. This node is the successor.
   - The reason this works is that the smallest value greater than the node you're deleting will always be the leftmost node in the right subtree.

#### 3. **Replace the Deleted Node with the Successor:**
   - Once the successor node is found, you replace the value of the node you're deleting with the value of the successor.
   - If the successor has a right child, you need to connect this right child to the parent of the successor, maintaining the BST property.

#### Example:
Let's say you want to delete the root node `50`. The steps would be:

1. Visit the right child of `50`, which is `75`.
	![[Pasted image 20240820094443.png]]
2. From `75`, move left to `61`.
3. Continue left to `52`, which has no left child. Thus, `52` is the successor.
	![[Pasted image 20240820094506.png]]
4. Replace `50` with `52`, making `52` the new root of the tree.
	![[Pasted image 20240820094521.png]]

By following this algorithm, you ensure that the BST remains correctly ordered after the deletion.

### Handling a Successor Node with a Right Child

When the successor node in a Binary Search Tree (BST) has a right child, the deletion process requires some additional steps to maintain the tree structure.

#### 1. **Identify the Successor Node:**
   - As before, find the successor node by going to the right child of the node to be deleted and then traversing left until no more left children exist.

#### 2. **Plug the Successor Node into the Deleted Node's Position:**
   - Replace the node you're deleting with the successor node. However, if the successor node has a right child, this child will be left without a parent after the replacement.

#### 3. **Reattach the Successor's Right Child:**
   - To address the dangling right child of the successor:
     1. **Find the former parent of the successor node.** This is the node that initially linked to the successor (its parent before the deletion).
     2. **Reattach the right child of the successor as the left child of this former parent.**
   - This step ensures that the BST properties are preserved by maintaining the correct ordering of the nodes.

#### Example:
Consider you want to delete the root node `50` from a BST, where `52` is the successor and has a right child `55`.

1. **Find the Successor:**  
   - Start at the right child of `50` (which is `75`), move left to `61`, and then left again to `52`, which is the successor.
	![[Pasted image 20240820094623.png]]

2. **Plug the Successor into the Root:**  
   - Replace `50` with `52`, making `52` the new root. This leaves `55` without a parent.
	![[Pasted image 20240820094653.png]]

3. **Reattach `55`:**
   - Since `61` was the parent of `52`, make `55` the left child of `61`.
	![[Pasted image 20240820094704.png]]

By following these steps, the tree remains correctly structured, preserving the BST properties even after the deletion of a node with two children.

### Complete Deletion Algorithm for a Binary Search Tree (BST)

1. **Deleting a Node with No Children (Leaf Node):**
   - If the node to be deleted has no children, simply remove it from the tree.

2. **Deleting a Node with One Child:**
   - If the node to be deleted has only one child:
     - Remove the node.
     - Replace it with its child, effectively bypassing the deleted node.

3. **Deleting a Node with Two Children:**
   - When the node to be deleted has two children:
     1. **Find the Successor Node:**
        - The successor node is the node with the smallest value greater than the node to be deleted. 
        - To find the successor:
          - Go to the right child of the node to be deleted.
          - Then keep moving left until no more left children exist.
     2. **Replace the Deleted Node with the Successor Node:**
        - Swap the contents (value) of the node to be deleted with the successor node.
        - Remove the successor node from its original position. 
     3. **Handle the Successor’s Right Child (if it exists):**
        - If the successor node has a right child:
          - Attach this child to the left of the successor’s former parent, ensuring the BST structure remains intact.

### C++ Implementation

```cpp
#include <iostream>

struct TreeNode {
    int value;
    TreeNode* left;
    TreeNode* right;

    TreeNode(int val) : value(val), left(nullptr), right(nullptr) {}
};

// Helper function to find the minimum value node in a given subtree
TreeNode* findMin(TreeNode* node) {
    while (node && node->left != nullptr) {
        node = node->left;
    }
    return node;
}

// Function to delete a node from the BST
TreeNode* deleteNode(TreeNode* root, int key) {
    // Base case: if the tree is empty
    if (root == nullptr) {
        return nullptr;
    }

    // Recur down the tree
    if (key < root->value) {
        root->left = deleteNode(root->left, key);
    } else if (key > root->value) {
        root->right = deleteNode(root->right, key);
    } else {
        // Node to be deleted found

        // Case 1: Node has no children
        if (root->left == nullptr && root->right == nullptr) {
            delete root;
            return nullptr;
        }

        // Case 2: Node has only one child
        if (root->left == nullptr) {
            TreeNode* temp = root->right;
            delete root;
            return temp;
        } else if (root->right == nullptr) {
            TreeNode* temp = root->left;
            delete root;
            return temp;
        }

        // Case 3: Node has two children
        TreeNode* temp = findMin(root->right); // Find the smallest value in the right subtree
        root->value = temp->value; // Replace value of node to be deleted with the smallest value
        root->right = deleteNode(root->right, temp->value); // Delete the successor node
    }
    return root;
}

// Helper function to print the tree (inorder traversal)
void printInOrder(TreeNode* node) {
    if (node == nullptr) {
        return;
    }
    printInOrder(node->left);
    std::cout << node->value << " ";
    printInOrder(node->right);
}

int main() {
    // Example usage
    TreeNode* root = new TreeNode(50);
    root->left = new TreeNode(30);
    root->right = new TreeNode(70);
    root->left->left = new TreeNode(20);
    root->left->right = new TreeNode(40);
    root->right->left = new TreeNode(60);
    root->right->right = new TreeNode(80);

    std::cout << "Original tree (inorder): ";
    printInOrder(root);
    std::cout << std::endl;

    int keyToDelete = 70;
    root = deleteNode(root, keyToDelete);

    std::cout << "Tree after deleting " << keyToDelete << " (inorder): ";
    printInOrder(root);
    std::cout << std::endl;

    // Clean up remaining nodes (not shown here for brevity)

    return 0;
}
```

### Explanation:

1. **`findMin(TreeNode* node)`**: Finds the minimum value node in a subtree, used to locate the successor node.

2. **`deleteNode(TreeNode* root, int key)`**: Deletes the node with the given `key` and handles all cases:
   - **No children**: Simply delete the node.
   - **One child**: Replace the node with its child.
   - **Two children**: Replace the node with its successor node and then delete the successor.

3. **`printInOrder(TreeNode* node)`**: A utility function for displaying the BST in inorder (ascending) to verify the tree structure.

This code demonstrates how to perform deletions while maintaining the BST properties.

## B-Trees

![[Pasted image 20240821134923.png]]

A B-tree is a self-balancing tree data structure that maintains sorted data and allows searches, sequential access, insertions, and deletions in logarithmic time. B-trees are particularly well-suited for systems that read and write large blocks of data, such as databases and file systems. They are designed to work efficiently on disk-based storage systems where minimizing disk accesses is crucial.

### Key Features of B-Trees:
1. **Balanced Structure**: B-trees remain balanced by ensuring that all leaf nodes are at the same level, which means the tree has a uniform depth. This balance ensures that operations like searching, inserting, and deleting elements have consistent performance.

2. **Multiple Keys per Node**: Unlike binary search trees, where each node contains a single key and two child pointers, a B-tree node can contain multiple keys and child pointers. The number of keys in a node can vary but is kept within a certain range to maintain balance. This feature makes B-trees shallow and wide, reducing the number of disk accesses required to reach a particular key.

3. **Key Ordering**:
- Within a node, the keys are ordered in a non-decreasing manner: $k_1 \leq k_2 \leq \dots \leq k_n$.
- For a node with children, the keys define the ranges for the values in the subtrees:
    - All keys in the leftmost child are less than the first key.
		![[Pasted image 20240821135957.png]]
    - All keys in the rightmost child are greater than the last key.
	    ![[Pasted image 20240821140016.png]]
    - For any key $k_i$, all keys in the $i$-th child are greater than $k_{i-1}$ and less than $k_i$.
	    ![[Pasted image 20240821140030.png]]

4. **Order of the Tree**: The order of a B-tree is a measure of its branching factor (i.e., the maximum number of children a node can have). A B-tree of order $t$ means that:
   - Each node can have at most $t$ children.
   - Each node (except the root) must have at least $\lceil t/2 \rceil$ children.
   - Each internal node (non-leaf and non-root) contains at least $\lceil t/2 \rceil - 1$ keys and at most $t - 1$ keys.

![[Pasted image 20240821135111.png]]

4. **Height of the Tree**: Because B-trees are balanced, the height of the tree is kept low even with a large number of elements. This low height ensures that any operation (like search, insertion, or deletion) will require only a few steps, minimizing the number of disk accesses.

5. **Efficient Disk Access**: B-trees are optimized for systems that use secondary storage (like disks) by minimizing the number of disk reads and writes. Since nodes are designed to store multiple keys, fewer nodes are needed to cover the same number of elements compared to binary search trees. This feature reduces the number of disk accesses, making B-trees suitable for database indexing and file systems.

6. **Leaf Nodes**: All leaf nodes are at the same depth in the tree, which is why B-trees are balanced. Leaf nodes do not have any children and store the actual data or pointers to the data.

### Operations on B-Trees:
1. **Search**: Searching for a key in a B-tree is similar to binary search but within nodes. It involves navigating through the tree by comparing the target key with the keys stored in each node.

2. **Insertion**: Inserting a new key into a B-tree requires finding the correct leaf node where the key should be placed. If the node is full, the node is split, and the middle key is promoted to the parent node. This process may propagate up to the root, potentially increasing the tree's height.

3. **Deletion**: Deleting a key from a B-tree involves several steps. If the key is in a leaf node, it's simply removed. If it's in an internal node, the tree is restructured to maintain balance. Deletion can involve merging nodes or redistributing keys among sibling nodes.

### Example of B-Tree:
A B-tree of order 3 (each node can have at most 2 keys and 3 children) might look like this:

```
         [13 26]
       /    |     \
[7 10]  [15 20]  [30 40 50]
```

In this example:
- The root has 2 keys (13, 26) and 3 children.
- Each child node also has a certain number of keys within the allowed range.

### Applications of B-Trees:
- **Databases**: B-trees are commonly used in databases for indexing, as they allow quick search, insert, and delete operations on large datasets.
- **File Systems**: B-trees are used in file systems (e.g., NTFS, HFS+) to manage files and directories, ensuring efficient access and modification of file metadata.
- **Memory Management**: Some operating systems use B-trees for managing virtual memory and ensuring fast access to memory pages.

[B-Trees Video Tutorial](https://www.youtube.com/watch?v=FgWbADOG44s&list=PL9xmBV_5YoZNFPPv98DjTdD9X6UI9KMHz&pp=iAQB)


## B-Tree Search

1. **Start at the Root**:
   - Begin the search at the root node of the B-tree.

2. **Compare with Keys in the Node**:
   - Compare the search key $k$ with the keys in the current node.
   - If $k$ matches any key in the current node, the search is successful, and you can return the found key (or the associated data).

3. **Determine the Child Subtree**:
   - If $k$ does not match any key in the current node:
     - Identify the appropriate child pointer to follow. 
     - If $k$ is less than the smallest key in the node, follow the leftmost child pointer.
     - If $k$ is greater than the largest key in the node, follow the rightmost child pointer.
     - Otherwise, find the interval in which $k$ falls and follow the corresponding child pointer.

4. **Move to the Child Node**:
   - Move to the child node pointed to by the appropriate child pointer from the previous step.

5. **Repeat the Process**:
   - Repeat steps 2-4 for the child node.
   - Continue this process until you either find the key or reach a leaf node.

6. **Check the Leaf Node**:
   - If the search key $k$ is not found in any of the internal nodes and you reach a leaf node, check the leaf node for the key.
   - If $k$ is present in the leaf node, the search is successful.
   - If $k$ is not found in the leaf node, the search is unsuccessful, and the key does not exist in the B-tree.

### Example

Consider a B-tree with the following structure:

```
       [10, 20]
       /  |   \
    [5] [15] [25, 30]
```

- **Search for 15**:
  1. Start at the root: [10, 20].
  2. 15 is greater than 10 but less than 20. Move to the middle child: [15].
  3. 15 matches the key in this node. Search successful.

- **Search for 17**:
  1. Start at the root: [10, 20].
  2. 17 is greater than 10 but less than 20. Move to the middle child: [15].
  3. 17 is greater than 15. Move to the right child of [15], which is a leaf node (if one exists).
  4. If the leaf node exists and contains no 17, search unsuccessful.


## B-Tree Insertion

Insertion in a B-tree is more complex than in simpler tree structures like binary search trees because it involves maintaining the B-tree properties: balanced structure, the correct number of keys per node, and ordered keys.

### Steps for Inserting a Key into a B-Tree:

1. **Start at the Root**:
   - The insertion process always begins at the root node of the B-tree.
   - The goal is to find the appropriate leaf node where the new key should be inserted.

2. **Traverse the Tree**:
   - Traverse down the tree from the root to find the correct position for the new key.
   - At each node, determine the correct child pointer to follow by comparing the new key with the keys in the current node.
   - Continue this process until you reach a leaf node.

3. **Insert the Key in the Leaf Node**:
   - Once you’ve reached the correct leaf node, insert the key into its proper position within the node’s existing keys, ensuring that the keys remain in sorted order.

4. **Check for Overflow**:
   - After inserting the key, check if the node now contains more than the maximum allowed number of keys ($2t-1$ keys, where $t$ is the minimum degree of the tree).
   - If the node does **not** exceed this limit, the insertion is complete.

5. **Handle Node Splitting**:
   - If the node **does** overflow (has $2t$ keys), a **split** operation is needed.
   - Split the node into two separate nodes:
     - The median key (middle key) of the node is moved up to the parent node.
     - The keys to the left of the median form a new left child, and the keys to the right form a new right child.
   - If the split node was the root, the median key becomes the new root, and the tree height increases by one level.

![[Pasted image 20240821140540.png]]

6. **Recursive Splitting (if necessary)**:
   - If the parent node also overflows after receiving the median key, repeat the splitting process at the parent level.
   - This recursive splitting may continue up the tree until no node overflows or until the root is split, creating a new root.

### Example

![[BTreeInsert.png]]

### **Initial Configuration (a)**
- **Insert 9, 0, 8**: 
  - Start by inserting 9, followed by 0 and 8. 
  - The tree starts filling the root node with keys: `[0, 8, 9]`.

![[Pasted image 20240821141638.png]]

### **Step (b) - Insert 1**
- **Before Insertion**:
  - The root node has the keys `[0, 8, 9]`.
  - Since this node is full (a B-tree of order 3 can hold at most 2 keys before splitting), the node must be split.

- **Splitting Process**:
  - The median key `8` is moved up to a new root.
  - The keys `0` and `9` are split into two separate child nodes: `[0]` and `[9]`.
  
- **Insertion**:
  - The key `1` is inserted into the left child node, resulting in the node `[0, 1]`.

![[Pasted image 20240821141650.png]]

### **Step (c) - Insert 7**

- **Insertion**:
  - Since 7 is less than 8, it should go into the left subtree.
  - The left child `[0, 1]` is not full, so 7 is inserted in the correct position.
  - Resulting nodes: `[0, 1, 7]`.

![[Pasted image 20240821141701.png]]

### **Step (d) - Insert 2**

- **Insertion**:
  - The key `2` should be inserted in the left child `[0, 1, 7]`.
  - However, this node is full. Thus, it needs to be split.
  - The median key `1` is moved up to the root.
  - The node `[0, 1, 7]` is split into `[0]` and `[7]`.
  - The resulting tree has a root `1, 8`, with children `[0]`, `[2, 7]`, and `[9]`.

![[Pasted image 20240821141715.png]]

### **Step (e) - Insert 6**

- **Insertion**:
  - The key `6` should be inserted into the middle child `[2, 7]`.
  - This node is not full, so `6` is inserted in its correct position.
  - Resulting node becomes `[2, 6, 7]`.

![[Pasted image 20240821141809.png]]

### **Step (f) - Insert 3**

- **Insertion**:
  - The key `3` should go into the middle child `[2, 6, 7]`.
  - However, this node is full, so it needs to be split.
  - The median key `6` is moved up to the root.
  - The node `[2, 6, 7]` is split into `[2]` and `[7]`.
  - Resulting tree: Root `1, 6, 8`, with children `[0]`, `[2, 3]`, `[7]`, and `[9]`.

![[Pasted image 20240821141845.png]]

### **Step (h) - Insert 5**

#### Step 1: Insert `5` into Node `[2, 3]`

- Before insertion: The node `[2, 3]` has two keys and is not full.
- After insertion: The node now contains `[2, 3, 5]`. This node is still within its capacity (it can hold up to `2T-1 = 5` keys for `T = 3`).

So far, no splitting is needed, and the tree should remain at the same level.

#### Step 2: Consider Additional Insertions and Splitting

If the insertion of `5` somehow causes an overflow higher up (perhaps in a later step or after the insertion of other keys that are not shown in the diagram), the tree may need restructuring.

#### Revised Process: Handling Subsequent Insertions

1. **Insertion of `4` (Example Before `5`)**:
    - Before splitting: You have the tree rooted at `[1, 6, 8]` with the middle node `[2, 3]` already full.
    - Splitting happens after inserting `4`, where `3` gets moved up, creating a new node that effectively changes the level count.
2. **Recursive Splitting**:
    - As each new median is promoted, if the root overflows, it splits, increasing the tree's height by one.

#### Step 3: Understand Level Increase

- If the parent node `[1, 6, 8]` becomes full after receiving a key from a lower-level split, the root node will have to split, promoting a median key to a new root.
- The new root causes the overall height of the tree to increase.

#### Final Structure After `5`

After `5` is inserted and potentially more keys (like `4` in the next step) lead to further promotions, the tree might restructure itself by increasing the overall height:

- **Node `[6]` as New Root**: The tree restructures such that `6` becomes the new root, splitting into two subtrees `[1, 3]` and `[8]`.
- **Promotion of Median Keys**: If this leads to further node split promotions, that would naturally increase the tree's height from level 2 to level 3.

![[Pasted image 20240821142000.png]]

### **Step (h) - Insert 4**

- **Insertion**:
  - The key `4` should go into the child `[2, 3, 5]`.
  - This node is full, so it needs to be split.
  - The median key `3` is moved up to the root.
  - The node `[2, 3, 5]` is split into `[2]` and `[5]`.

![[Pasted image 20240821142552.png]]

This sequence ensures that the B-tree remains balanced after each insertion, maintaining its efficiency for search, insertion, and deletion operations.

## B-Tree Deletion

Deleting a key from a B-tree is more complex than insertion, as it involves several cases.

#### 1. **Locate the Key**
   - Start by finding the key that you want to delete.

#### 2. **Delete the Key from a Leaf Node**
   - If the key is in a **leaf node** and the node contains more than the minimum number of keys (i.e., more than $\lceil m/2 \rceil - 1$ keys, where $m$ is the order of the B-tree), simply remove the key from the leaf.
   - If the key is in a **leaf node** and the node contains the minimum number of keys, you will need to **rebalance** the tree after deletion. This could involve **merging** with a sibling node or **borrowing** a key from an adjacent sibling.

#### 3. **Delete the Key from an Internal Node**
   - If the key is in an **internal node**, the deletion process is more involved:
     1. **Find the predecessor** (the largest key in the left subtree) or the **successor** (the smallest key in the right subtree) of the key.
     2. Replace the key with its predecessor or successor.
     3. Recursively delete the predecessor or successor from the leaf node where it resides.

#### 4. **Rebalancing the Tree**
   - After deleting the key, check if the node is **underflowed** (has fewer than the minimum number of keys).
   - If underflow occurs, you need to **rebalance** the tree:
     1. **Borrow from a sibling**: If a sibling has more than the minimum number of keys, move a key from the parent down into the underflowed node and move a key from the sibling up into the parent.
     2. **Merge with a sibling**: If both siblings have the minimum number of keys, merge the underflowed node with a sibling and pull a key down from the parent.

#### 5. **Adjust the Root (if necessary)**
   - If the root node becomes empty as a result of deletion, make the first child of the root the new root of the tree.

### Example:
#### Example 1: Deleting From an Internal Node

Suppose you have a B-tree of order 3 (each node can have at most 2 keys):

```
       [10, 20]
       /   |   \
   [5]   [15]   [25, 30]
```

   - **Delete key 20.**
   - 20 is in an internal node. The successor is 25.
   - Replace 20 with 25 and delete 25 from its leaf.
   - The tree rebalances if necessary.

#### Example 2: **Deleting From a Leaf Node**

```
       [10, 20]
       /   |   \
   [5]   [15]   [25, 30]
```

   - **Delete key 15.**
   - 15 is in a leaf node with only one key. Since it's a leaf node and doesn't require rebalancing, simply remove it.

#### Example 3: **Deleting From an Internal Node**

Suppose you have a B-tree of order 4 (each node can have at most 3 keys):

```
           [20,   40,   60]
          /     |    \    \
     [10]   [30] [50, 55] [70, 80, 90]
```

- **Delete key 60.**
- **Key 60** is in the root node.
- Replace `60` with its predecessor `55` from the leaf node.
- Now delete `55` from the leaf node.

- After deleting `55`, the B-tree looks like:

```
           [20,  40,   55]
           /    |   \    \
      [10]   [30] [50] [70, 80, 90]
```

- The root still has sufficient keys, so no further action is needed.

#### Example 3: Rebalancing by Borrowing from a Sibling

Suppose you have a B-tree of order 4 (each node can have at most 3 keys):

```
           [20, 50]
          /    |    \
      [10]   [30, 40] [60, 70, 80]
```
##### Step 1: Delete the Key `10`
After deleting `10`, the tree looks like this:

```
           [20, 50]
          /    |    \
       []  [30, 40] [60, 70, 80]
```

The leftmost child node is now empty, which causes an **underflow**.

##### Step 2: Rebalance by Borrowing from a Sibling
First, check if the left sibling of the empty node (`[30, 40]`) or the right sibling (`[60, 70, 80]`) has more than the minimum number of keys (which is 1 for an order-4 tree).

- The left sibling `[30, 40]` has 2 keys, which is more than the minimum.

**Borrowing Process**:
- Move `20` (the parent key) down into the empty node.
- Move `30` (the left sibling key) up to replace `20` in the parent node.

##### After Borrowing:
```
           [30, 50]
          /    |    \
       [20] [40] [60, 70, 80]
```

The tree is now balanced after borrowing from the left sibling.

#### Example 4: Rebalancing by Merging with a Sibling

```
           [30, 50]
          /    |    \
       [20] [40] [60, 70, 80]
```
##### Step 1: Delete the Key `30`
After deleting `30`, the tree looks like this:

```
           [50]
          /    \
       [20, 40] [60, 70, 80]
```

Now the left child has 2 keys, which is fine since it's not underflowed. But let's assume we delete `40` as well:

##### Step 2: Delete the Key `40`
After deleting `40`, the tree looks like this:

```
           [50]
          /    \
       [20] [60, 70, 80]
```

Now, the left child `[20]` has only 1 key, which is the minimum number of keys allowed in an order-4 tree. However, it is important to maintain balance in the tree. 

If the sibling on the right `[60, 70, 80]` had only the minimum number of keys, we would have to **merge** the nodes instead of borrowing.

##### Merging Process:
- Merge the left node `[20]` with the parent key `50` and the right sibling `[60, 70, 80]`.
- After merging, the tree looks like this:

```
           [60, 70, 80]
          /
       [20, 50]
```

Now the tree is balanced again.

## Hash Tables and Hash Functions

**Hash Tables** are a powerful data structure commonly used in programming for fast data retrieval. They are also known as hashes, hash maps, dictionaries, or associative arrays, depending on the programming language.

#### **Hash Tables Overview**

- **Structure**: A hash table is essentially a collection of key-value pairs. For example, in Ruby, you might define a menu using a hash table as follows:

  ```ruby
  menu = { "french fries" => 0.75, "hamburger" => 2.5, "hot dog" => 1.5, "soda" => 0.6 }
  ```

  Here, `"french fries"` is the key, and `0.75` is the value associated with that key.

- **Lookup Efficiency**: Looking up a value associated with a key in a hash table is typically done in constant time, i.e., $O(1)$ on average. This efficiency is achieved through the use of **hash functions**.

#### **Hashing and Hash Functions**

Hash functions are essential for the operation of hash tables. They convert keys into indices of an internal array where the corresponding values are stored.

##### **Example of Hash Functions**

1. **Simple Character-to-Number Hash Function**:
   - **Mapping**: `A = 1`, `B = 2`, `C = 3`, `D = 4`, etc.
   - **Example**:
     - **BAD** → `2, 1, 4`
     - **Product of Digits**: `2 * 1 * 4 = 8`
     - So, BAD maps to `8`.

2. **Sum of Digits Hash Function**:
   - **Mapping**: Same character-to-number mapping.
   - **Example**:
     - **BAD** → `2, 1, 4`
     - **Sum of Digits**: `2 + 1 + 4 = 7`
     - So, BAD maps to `7`.

##### **Criteria for a Valid Hash Function**

A valid hash function must:

1. **Consistency**: Always produce the same hash value for the same input. For instance, with our multiplication hash function, **BAD** will always hash to `8`.

2. **Deterministic**: The function should not use random elements or current time. For instance, using random numbers or the current time would result in inconsistent hash values.

#### **Handling Collisions**

Hash functions might produce the same hash value for different keys. This is known as a **collision**. For example, both **BAD** and **DAB** might hash to `8` with our multiplication hash function. Handling collisions effectively is a crucial aspect of designing hash tables. Common strategies include:

- **Chaining**: Storing collided elements in a list at each index.
- **Open Addressing**: Finding another open slot in the array according to a probing sequence.

### Summary

- **Hash Tables** provide efficient key-value storage and retrieval.
- **Hash Functions** convert keys into indices where values are stored.
- **Consistency and Determinism** are essential for a good hash function.
- **Collisions** can occur and must be handled to maintain efficiency.

## Hash Table Lookups

- **Hash Table Basics:**
  - A hash table is a data structure that uses keys to find associated values quickly.
  - Each key is processed using a hash function, which converts the key into an index number.
  - The value associated with a key is stored at the index computed by the hash function.

- **Hash Table Lookup Process:**
  - To look up a value, the key is hashed to produce an index.
  - The value is then retrieved from the cell at the calculated index.
  - This lookup process typically has a time complexity of $O(1)$, meaning it takes a constant amount of time.

- **Efficiency of Hash Tables:**
  - Hash tables provide faster lookups compared to arrays, where searching for an item can take $O(N)$ time in an unordered array or $O(\log N)$ in an ordered array.
  - By using keys (e.g., menu items) directly in hash tables, lookups become much more efficient.

- **One-Directional Lookups:**
  - Hash tables are efficient only when you know the key; the key determines the location of the value.
  - If you only know the value and need to find the key, you would have to search through the entire table, resulting in $O(N)$ time complexity.
  - This one-directional nature means you can't easily find keys based on values.

- **Key-Value Storage:**
  - In some programming languages, keys are stored next to their corresponding values within the hash table.
  - This helps resolve issues like collisions, where multiple keys might hash to the same index.

- **Uniqueness of Keys:**
  - Each key in a hash table must be unique; if a key is inserted again, its associated value is overwritten.
  - However, multiple keys can map to the same value.

- **Practical Example:**
  - In a restaurant menu, using the item name as the key in a hash table allows for fast price lookups, whereas using an array would require searching through all items.

## Dealing With Collissions

### **Collisions in Hash Tables:**
- **What is a Collision?**
  - A collision occurs when two different keys hash to the same index in the hash table.
  - In the example, both "bad" and "dab" hash to index 8, leading to a collision when trying to store the value associated with "dab".
```python
thesaurus["dab"] = "pat"
```

![[Pasted image 20240819205831.png]]

![[Pasted image 20240819205845.png]]

### **Handling Collisions:**
- **Separate Chaining:**
  - One common way to handle collisions is through separate chaining.
  - Instead of storing a single value in a cell, the hash table stores a reference to an array (or linked list) when a collision occurs.
  - This array will hold subarrays (or nodes in the case of a linked list) where each subarray contains the key and its associated value.

![[Pasted image 20240819205924.png]]

### **Lookup Process with Separate Chaining:**
- **Steps in Lookup:**
  - The computer hashes the key to determine the index.
  - It then checks the cell at that index. If the cell contains an array of subarrays (due to a collision), a linear search is conducted within that array.
  - The computer searches through the array, comparing the key at index 0 of each subarray until it finds the correct key. It then returns the corresponding value from index 1 of that subarray.

- **Impact on Performance:**
  - While separate chaining allows the hash table to handle collisions, it can degrade performance.
  - In the worst-case scenario, if many keys collide and are stored in the same cell, the lookup process could degrade to $O(N)$ time complexity, which is no better than searching in a regular array.

### **Importance of Minimizing Collisions:**
- **Designing Efficient Hash Tables:**
  - To maintain the typical $O(1)$ lookup time, it's crucial to minimize the number of collisions.
  - This can be achieved by using a good hash function that distributes keys evenly across the hash table, and by ensuring the table is large enough relative to the number of entries.
  - Most programming languages implement hash tables with these optimizations in place to handle collisions efficiently.

## Making an Efficient Hash Table

### **Factors Affecting Hash Table Efficiency:**
1. **Amount of Data:**
   - The more data you store in a hash table, the higher the potential for collisions if the table isn’t large enough.

2. **Number of Cells:**
   - The number of cells in the hash table should be sufficient to store data with minimal collisions. If the table has too few cells relative to the data, collisions become more frequent, reducing efficiency.

3. **Hash Function:**
   - The hash function determines how keys are converted into indices (cell locations) in the table.
   - A good hash function distributes keys uniformly across all available cells, minimizing collisions.

### **Importance of a Good Hash Function:**
- **Example of a Poor Hash Function:**
  - A hash function that always returns a number between 1 and 9, even if the table has more cells, results in underutilization. Only cells 1 to 9 will be used, leading to a high concentration of data (and thus collisions) in these cells.
	![[Pasted image 20240819210137.png]]
  
- **Desired Hash Function Behavior:**
  - A well-designed hash function spreads data evenly across all cells, using the entire table efficiently and reducing the chances of collisions.

### **Balancing Act:**
- **Collision Avoidance vs. Memory Usage:**
  - While avoiding collisions is crucial, it must be balanced against memory usage. For example, using a hash table with 1,000 cells for only 5 pieces of data avoids collisions but wastes memory.
  
- **Load Factor:**
  - The load factor is a ratio that represents the balance between the number of data elements and the number of cells in the table.
  - A commonly accepted load factor is 0.7, meaning for every 7 pieces of data, there should be 10 cells.
  - As more data is added, the table may need to be resized, and the hash function might be adjusted to maintain an even distribution.

### **Dynamic Resizing and Load Factor:**
- **Resizing the Hash Table:**
  - When the load factor becomes too high (too many elements relative to the number of cells), the hash table is resized to accommodate more data and reduce collisions.
  - This resizing process often involves rehashing the existing data to spread it more evenly across the new, larger table.

### **Optimizing for Efficiency:**
- **Programming Language Implementations:**
  - Most modern programming languages handle the details of hash table sizing, hash function selection, and resizing automatically, ensuring optimal performance.
  - This allows developers to focus on using hash tables without worrying too much about the underlying mechanics.

### **Key Takeaways:**
- Efficient hash tables balance the number of cells, the amount of data, and the effectiveness of the hash function to ensure $O(1)$ lookup times.
- The load factor provides a guideline for maintaining this balance, preventing excessive collisions while avoiding unnecessary memory usage.
- Understanding these principles helps in appreciating how hash tables achieve fast lookups and why certain design choices are made in their implementation.

## Hash Tables for Organization

1. **Natural Fit for Paired Data:**
   - **Paired Data Examples:** 
     - Hash tables are ideal for data that naturally exists in pairs, such as:
       - **Fast-food menu:** Food item paired with its price.
       - **Thesaurus:** Word paired with its synonym.
     - In Python, hash tables are called **dictionaries** because they function like a dictionary, with words (keys) and definitions (values).
   
2. **Tallies and Inventory:**
   - **Tallies:** 
     - Example: Tracking votes in an election, where each candidate's name is paired with their vote count.
     - Example: An inventory system, where each item's name is paired with the quantity in stock.
   
3. **Simplifying Conditional Logic:**
   - **Conditional Logic Example:**
     - Instead of using multiple `if-else` statements to map HTTP status codes to their meanings, a hash table can be used for direct lookups.
   - **C++ Example:**
     ```cpp
     #include <unordered_map>
     #include <string>

     std::string status_code_meaning(int number) {
         static const std::unordered_map<int, std::string> STATUS_CODES = {
             {200, "OK"}, {301, "Moved Permanently"}, {401, "Unauthorized"},
             {404, "Not Found"}, {500, "Internal Server Error"}
         };
         return STATUS_CODES[number];
     }
     ```

4. **Representing Objects with Attributes:**
   - **Attributes as Paired Data:**
     - Example: Representing a dog with attributes like name, breed, age, and gender, where each attribute is a key-value pair.
   - **C++ Example:**
     - An individual dog:
     ```cpp
     std::unordered_map<std::string, std::string> dog = {
         {"Name", "Fido"}, {"Breed", "Pug"}, {"Age", "3"}, {"Gender", "Male"}
     };
     ```
     - A list of dogs:
     ```cpp
     std::vector<std::unordered_map<std::string, std::string>> dogs = {
         {{"Name", "Fido"}, {"Breed", "Pug"}, {"Age", "3"}, {"Gender", "Male"}},
         {{"Name", "Lady"}, {"Breed", "Poodle"}, {"Age", "6"}, {"Gender", "Female"}},
         {{"Name", "Spot"}, {"Breed", "Dalmatian"}, {"Age", "2"}, {"Gender", "Male"}}
     };
     ```

5. **Key Takeaway:**
   - Hash tables are extremely useful for organizing paired data, simplifying lookups, and representing objects with multiple attributes efficiently.
## Linked Lists

A **linked list** is a fundamental data structure used to store a collection of elements in a linear order. Unlike arrays, linked lists do not require a contiguous block of memory for storing their elements. Instead, each element (referred to as a **node**) contains two parts:

1. **Data**: The actual value stored in the node.
2. **Link**: A pointer or reference to the next node in the sequence.

![[Pasted image 20240819220540.png]]

#### Structure of a Linked List Node

Each node in a linked list typically looks like this:

- **Data**: The value or data you want to store (e.g., an integer, string, or any object).
- **Next**: A pointer to the next node in the list. If a node is the last one, this pointer is set to `null` (or `nullptr` in C++), indicating the end of the list.

### Key Features of Linked Lists

1. **Dynamic Size**: Unlike arrays, linked lists can grow or shrink in size as needed. You don't need to allocate memory upfront.

2. **Memory Efficiency**: Since nodes are scattered in memory, linked lists don't require large contiguous blocks of memory, which can be a limitation for arrays.

3. **Insertion and Deletion**: Linked lists allow for efficient insertion and deletion of elements, especially at the beginning or middle of the list. This is because you only need to adjust a few pointers, unlike arrays where you might have to shift elements.

4. **Sequential Access**: Accessing elements in a linked list is sequential. To access an element at position `n`, you must start at the head and follow the links until you reach the `n`th node. This is slower compared to arrays where direct access to any element by index is possible.

### Advantages and Disadvantages of Linked Lists

**Advantages**:
- **Flexible Size**: Can easily grow or shrink in size.
- **Efficient Insertions/Deletions**: Particularly at the start or middle.

**Disadvantages**:
- **No Random Access**: Accessing elements requires traversing the list.
- **Extra Memory**: Requires additional memory for storing pointers.

Linked lists are particularly useful in scenarios where dynamic data structures are needed, and where frequent insertions and deletions occur. They are a fundamental concept in computer science and provide the foundation for more complex data structures like stacks, queues, and more.

### Reading

Reading a value from a linked list involves traversing the list from the head (first node) until the desired node is reached. Since we must follow the links from one node to the next, reading a specific element from a linked list has a time complexity of $O(N)$, where $N$ is the number of nodes in the list.

### Searching

Searching for a specific value in a linked list also requires traversing the list. The time complexity of this operation is also $O(N)$ since each node must be inspected until the desired value is found or the list ends.

### Insertion

Linked lists offer efficient insertion at the beginning, with a time complexity of $O(1)$. However, inserting at any other position, especially at the end, requires traversal, making the worst-case insertion $O(N)$.

Here’s how insertion works in different scenarios:

1. **Insertion at the Beginning**: This is the fastest case. We simply create a new node, set its `next` pointer to the current head, and update the head to this new node.
    
2. **Insertion in the Middle or End**: For this, we need to traverse the list to find the correct position, which can take $O(N)$ in the worst case.

### Deletion

Deletion in linked lists is generally more efficient than in arrays, especially for removing nodes from the beginning of the list.

1. **Deletion at the Beginning**: This is the most efficient case. We simply adjust the head pointer to skip over the first node, which takes $O(1)$ time.
    
2. **Deletion at the End**: The actual removal of the last node is simple, but finding the second-to-last node requires traversal, resulting in $O(N)$ time.
    
3. **Deletion in the Middle**: This involves finding the node to be deleted and adjusting pointers, which typically takes $O(N)$ time.

### C++ Code Implementation

```cpp
#include <iostream>

struct Node {
    int data;
    Node* next;
};

class LinkedList {
private:
    Node* head;

public:
    LinkedList() : head(nullptr) {}

    // Function to add a node at the end of the list
    void append(int new_data) {
        Node* new_node = new Node();
        new_node->data = new_data;
        new_node->next = nullptr;

        if (head == nullptr) {
            head = new_node;
            return;
        }

        Node* last = head;
        while (last->next != nullptr) {
            last = last->next;
        }
        last->next = new_node;
    }

    // Function to read the value at a given position
    int read(int position) {
        if (head == nullptr) {
            std::cerr << "List is empty!" << std::endl;
            return -1;
        }

        Node* current = head;
        int index = 0;

        while (current != nullptr) {
            if (index == position) {
                return current->data;
            }
            current = current->next;
            index++;
        }

        std::cerr << "Position out of range!" << std::endl;
        return -1;  // Return an invalid value if the position is out of range
    }

    // Function to search for a value in the list
    int search(int value) {
        Node* current = head;
        int index = 0;

        while (current != nullptr) {
            if (current->data == value) {
                return index;  // Return the index if the value is found
            }
            current = current->next;
            index++;
        }

        std::cerr << "Value not found in the list!" << std::endl;
        return -1;  // Return -1 if the value is not found
    }

    // Insert at the beginning
    void insertAtBeginning(int new_data) {
        Node* new_node = new Node();
        new_node->data = new_data;
        new_node->next = head;
        head = new_node;
    }

    // Insert at the end
    void insertAtEnd(int new_data) {
        Node* new_node = new Node();
        new_node->data = new_data;
        new_node->next = nullptr;

        if (head == nullptr) {
            head = new_node;
            return;
        }

        Node* last = head;
        while (last->next != nullptr) {
            last = last->next;
        }
        last->next = new_node;
    }

    // Insert after a specific node (position-based)
    void insertAtPosition(int position, int new_data) {
        if (position == 0) {
            insertAtBeginning(new_data);
            return;
        }

        Node* new_node = new Node();
        new_node->data = new_data;

        Node* current = head;
        for (int i = 0; i < position - 1 && current != nullptr; i++) {
            current = current->next;
        }

        if (current == nullptr) {
            std::cerr << "Position out of range!" << std::endl;
            delete new_node;
            return;
        }

        new_node->next = current->next;
        current->next = new_node;
    }

    // Print the list
    void printList() {
        Node* current = head;
        while (current != nullptr) {
            std::cout << current->data << " -> ";
            current = current->next;
        }
        std::cout << "null" << std::endl;
    }

    // Delete at the beginning
    void deleteAtBeginning() {
        if (head == nullptr) {
            std::cout << "List is empty." << std::endl;
            return;
        }
        Node* temp = head;
        head = head->next;
        delete temp;
    }

    // Delete at the end
    void deleteAtEnd() {
        if (head == nullptr) {
            std::cout << "List is empty." << std::endl;
            return;
        }
        if (head->next == nullptr) {
            delete head;
            head = nullptr;
            return;
        }
        Node* current = head;
        while (current->next->next != nullptr) {
            current = current->next;
        }
        delete current->next;
        current->next = nullptr;
    }

    // Delete a specific value
    void deleteByValue(int value) {
        if (head == nullptr) {
            std::cout << "List is empty." << std::endl;
            return;
        }
        if (head->data == value) {
            deleteAtBeginning();
            return;
        }
        Node* current = head;
        while (current->next != nullptr && current->next->data != value) {
            current = current->next;
        }
        if (current->next == nullptr) {
            std::cout << "Value not found in the list." << std::endl;
            return;
        }
        Node* temp = current->next;
        current->next = current->next->next;
        delete temp;
    }

    // Destructor to clean up memory
    ~LinkedList() {
        Node* current = head;
        Node* next;
        while (current != nullptr) {
            next = current->next;
            delete current;
            current = next;
        }
    }
};

int main() {
    LinkedList list;

    list.insertAtBeginning(10);
    list.append(20);
    list.insertAtEnd(30);
    list.append(40);

    std::cout << "Value at position 2: " << list.read(2) << std::endl;  // Output: Value at position 2: 30

	int index = list.search(30); // Search for the value 30
	if (index != -1) {
		std::cout << "Value 30 found at position: " << index << std::endl; 
		// Output: Value 30 found at position: 2
	}

	list.insertAtPosition(1, 15); // Insert 15 after the first element

	list.deleteAtBeginning();
    std::cout << "After deleting the first node: ";
    list.printList();

    list.deleteAtEnd();
    std::cout << "After deleting the last node: ";
    list.printList();

    list.deleteByValue(20);
    std::cout << "After deleting the node with value 20: ";
    list.printList();

    return 0;
}
```

## Efficiency of Linked List Operations

- **Reading:**
  - **Array:** $O(1)$ (constant time) because you can directly access any element by its index.
  - **Linked List:** $O(N)$ (linear time) because you have to traverse from the head node to reach a particular element.

- **Search:**
  - Both **Array** and **Linked List:** $O(N)$, as you need to check each element until you find the target.

- **Insertion:**
  - **Array:** $O(N)$ (at a specific position due to shifting) but $O(1)$ at the end.
  - **Linked List:** $O(N)$ (at a specific position due to traversal) but $O(1)$ at the beginning.

- **Deletion:**
  - **Array:** $O(N)$ (at a specific position due to shifting) but $O(1)$ at the end.
  - **Linked List:** $O(N)$ (at a specific position due to traversal) but $O(1)$ at the beginning.

### Why Use Linked Lists?
- Despite similar time complexities to arrays for many operations, linked lists offer $O(1)$ insertion and deletion when done at the beginning of the list. This is especially useful in scenarios where the node to be inserted or deleted is already known due to previous operations.

## Doubly Linked Lists

![[Pasted image 20240819222228.png]]

- **Structure:** Each node has two links—one to the next node and one to the previous node. The list also keeps track of both the first and last nodes.
- **Efficiency:**
  - Accessing the first or last node is $O(1)$.
  - Inserting or deleting at either end of the list is $O(1)$, unlike singly linked lists where only operations at the beginning are $O(1)$.

### C++ Implementation

```cpp
class Node {
public:
    int data;
    Node* next;
    Node* prev;

    Node(int data) : data(data), next(nullptr), prev(nullptr) {}
};

class DoublyLinkedList {
public:
    Node* head;
    Node* tail;

    DoublyLinkedList() : head(nullptr), tail(nullptr) {}

    void append(int data) {
        Node* newNode = new Node(data);
        if (tail == nullptr) {
            head = tail = newNode;
        } else {
            tail->next = newNode;
            newNode->prev = tail;
            tail = newNode;
        }
    }

    // Other operations like deletion, traversal can be implemented similarly
};
```

This example initializes a doubly linked list and allows for appending elements to the end in $O(1)$ time.

## Queues as Doubly Linked Lists

- **Queues Overview:**  
  A queue is a data structure that follows the First-In-First-Out (FIFO) principle. Items are inserted at the end (enqueue) and removed from the front (dequeue).

- **Array Implementation:**  
  Using an array for a queue can be inefficient:
  - **Insertion (enqueue):** $O(1)$ (at the end of the array).
  - **Deletion (dequeue):** $O(N)$ (from the front, as it requires shifting elements).

- **Doubly Linked List Implementation:**  
  Using a doubly linked list for a queue is more efficient:
  - **Insertion (enqueue):** $O(1)$ (at the end, by directly linking the new node).
  - **Deletion (dequeue):** $O(1)$ (from the front, by directly unlinking the node).

### C++ Implementation of a Queue Using a Doubly Linked List

```cpp
#include <iostream>

class Node {
public:
    int data;
    Node* next;
    Node* prev;

    Node(int data) : data(data), next(nullptr), prev(nullptr) {}
};

class Queue {
private:
    Node* front;
    Node* rear;

public:
    Queue() : front(nullptr), rear(nullptr) {}

    // Enqueue: Insert at the end (rear)
    void enqueue(int data) {
        Node* newNode = new Node(data);
        if (rear == nullptr) {
            front = rear = newNode;
        } else {
            rear->next = newNode;
            newNode->prev = rear;
            rear = newNode;
        }
    }

    // Dequeue: Remove from the front
    int dequeue() {
        if (front == nullptr) {
            std::cerr << "Queue is empty!" << std::endl;
            return -1;
        }
        int data = front->data;
        Node* temp = front;
        front = front->next;
        if (front != nullptr) {
            front->prev = nullptr;
        } else {
            rear = nullptr; // Queue is now empty
        }
        delete temp;
        return data;
    }

    // Check if the queue is empty
    bool isEmpty() {
        return front == nullptr;
    }

    // Peek the front element
    int peek() {
        if (front == nullptr) {
            std::cerr << "Queue is empty!" << std::endl;
            return -1;
        }
        return front->data;
    }
};

int main() {
    Queue q;
    q.enqueue(10);
    q.enqueue(20);
    q.enqueue(30);

    std::cout << "Dequeued: " << q.dequeue() << std::endl; // 10
    std::cout << "Front element: " << q.peek() << std::endl; // 20
    std::cout << "Dequeued: " << q.dequeue() << std::endl; // 20
    std::cout << "Dequeued: " << q.dequeue() << std::endl; // 30
    std::cout << "Dequeued: " << q.dequeue() << std::endl; // Queue is empty!

    return 0;
}
```

### Explanation of the Code:
- **Node Class:** Represents each element (node) in the doubly linked list, with `data`, `next`, and `prev` pointers.
- **Queue Class:** Manages the queue operations:
  - `enqueue(int data)`: Adds a node to the end of the queue.
  - `dequeue()`: Removes a node from the front of the queue.
  - `isEmpty()`: Checks if the queue is empty.
  - `peek()`: Returns the front element without removing it.

This implementation allows efficient queue operations with $O(1)$ time complexity for both enqueue and dequeue.


## Graphs

Graphs are versatile data structures that excel at representing relationships between different pieces of data. Unlike linear structures like arrays or hierarchical structures like trees, graphs allow for more complex connections, making them ideal for modeling networks, such as social networks, transportation systems, or web page links.

#### Visualizing Graphs

![[Pasted image 20240820193738.png]]

Imagine a social network where each person is represented as a node (or vertex) and each friendship is represented as a line (or edge) connecting two nodes. For example, if Alice is friends with Bob, Diana, and Fred, there would be edges connecting Alice's node to each of their nodes.

#### Graphs vs. Trees

Graphs and trees are related but distinct structures:

- **Trees are a subset of graphs**: All trees are graphs, but not all graphs are trees.
- **Cycles**: Trees cannot have cycles, meaning there are no circular paths where you can start at one node and return to the same node by following edges. In contrast, graphs can have cycles. For example, if Alice is friends with Diana, Diana is friends with Bob, and Bob is friends with Alice, they form a cycle.
- **Connectivity**: Trees are fully connected, meaning there's a path from any node to any other node. In graphs, however, some nodes might not be connected to others. For example, in a social network, a new user might have no friends yet, and therefore their node would be isolated.

#### Graph Terminology

Graphs come with specific terminology:

- **Vertex (plural: vertices)**: This is what we usually call a node in other data structures.
- **Edge**: The line connecting two vertices.
- **Adjacent vertices**: Two vertices connected by an edge are adjacent, or neighbors.
- **Connected graph**: A graph where there is some path between every pair of vertices. 

### Example: Social Network as a Graph

In a social network graph:

- **Vertices**: Represent users (e.g., Alice, Bob).
- **Edges**: Represent friendships (e.g., an edge between Alice and Bob indicates they are friends).
- **Cycles**: If Alice, Bob, and Diana are friends in a circular manner, they form a cycle.
- **Disconnected vertices**: A new user with no friends yet would have a vertex with no edges.
	![[Pasted image 20240820193729.png]]

Understanding graphs and their properties allows for efficient modeling of complex relationships, making them a fundamental tool in computer science and real-world applications.


### Bare-Bones Graph Implementation in C++

Let's use hash tables using `std::unordered_map` and `std::vector`.

#### C++ Implementation

We'll start by implementing an undirected graph (like the social network example) where relationships are mutual, and then proceed to a directed graph where relationships may be one-way (like a following system).

#### 1. Undirected Graph

![[Pasted image 20240820193738.png]]

```cpp
#include <iostream>
#include <unordered_map>
#include <vector>
#include <string>

int main() {
    // Define the graph using an unordered_map, where each person has a list of friends
    std::unordered_map<std::string, std::vector<std::string>> friends = {
        {"Alice", {"Bob", "Diana", "Fred"}},
        {"Bob", {"Alice", "Cynthia", "Diana"}},
        {"Cynthia", {"Bob"}},
        {"Diana", {"Alice", "Bob", "Fred"}},
        {"Elise", {"Fred"}},
        {"Fred", {"Alice", "Diana", "Elise"}}
    };

    // Example: Look up Alice's friends
    std::string person = "Alice";
    std::cout << person << "'s friends: ";
    for (const auto& friend_name : friends[person]) {
        std::cout << friend_name << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

#### Explanation:
- `std::unordered_map<std::string, std::vector<std::string>>`: This data structure maps each person (a `std::string`) to a list of their friends (a `std::vector<std::string>`).
- Looking up a person's friends is done in $O(1)$ time by accessing the map.

#### 2. Directed Graph

![[Pasted image 20240820194952.png]]

In a directed graph, relationships are not mutual. This means if Alice follows Bob, it doesn't necessarily mean Bob follows Alice back.

```cpp
#include <iostream>
#include <unordered_map>
#include <vector>
#include <string>

int main() {
    // Define the directed graph using an unordered_map, where each person has a list of people they follow
    std::unordered_map<std::string, std::vector<std::string>> followees = {
        {"Alice", {"Bob", "Cynthia"}},
        {"Bob", {"Cynthia"}},
        {"Cynthia", {"Bob"}}
    };

    // Example: Look up who Alice follows
    std::string person = "Alice";
    std::cout << person << " follows: ";
    for (const auto& followee_name : followees[person]) {
        std::cout << followee_name << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

#### Explanation:
- Similar to the undirected graph, but now the list associated with each person represents the people they follow.
- This setup can be used to model one-way relationships common in social networks like Twitter.

### Object-Oriented Graph Implementation

In graph theory, a graph is a collection of vertices (or nodes) and edges (connections between the nodes). An object-oriented approach to graph implementation provides a clear, modular way to represent and manipulate graphs in a programming context.

#### **Vertex Class Overview**

The `Vertex` class represents a node in the graph, with two primary attributes:
- **`value`**: This stores the data contained in the vertex (e.g., a person's name in a social network).
- **`adjacent_vertices`**: This is a list (or array) of other vertices that are directly connected to this vertex.

The class also provides methods to manage the graph:
- **Constructor (`initialize`)**: Initializes a vertex with a specific value and an empty list of adjacent vertices.
- **`add_adjacent_vertex(vertex)`**: Adds a new connection (edge) from this vertex to another vertex.

#### **Directed vs. Undirected Graphs**

- **Directed Graph**: If we add an edge from Vertex A to Vertex B, it does not imply a reverse connection from B to A. For example, in a social network, this could represent a "follows" relationship.
- **Undirected Graph**: If an edge is added from Vertex A to Vertex B, we also automatically add an edge from B to A. This could represent a mutual friendship in a social network.

#### **Implementation Example in C++**

![[Pasted image 20240820195549.png]]

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

class Vertex {
public:
    std::string value;
    std::vector<Vertex*> adjacentVertices;

    Vertex(const std::string& val) : value(val) {}

    void addAdjacentVertex(Vertex* vertex) {
        if (std::find(adjacentVertices.begin(), adjacentVertices.end(), vertex) != adjacentVertices.end()) {
            return; // Vertex already in the adjacency list
        }
        adjacentVertices.push_back(vertex);
        vertex->addAdjacentVertex(this); // For undirected graph, add the reverse connection
    }
};

int main() {
    Vertex alice("alice");
    Vertex bob("bob");
    Vertex cynthia("cynthia");

    alice.addAdjacentVertex(&bob);
    alice.addAdjacentVertex(&cynthia);
    bob.addAdjacentVertex(&cynthia);

    // Display connections for Alice
    std::cout << alice.value << " is connected to: ";
    for (Vertex* v : alice.adjacentVertices) {
        std::cout << v->value << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

**Explanation**:
- **Vertex Class**: Represents each node with a value and a list of adjacent nodes.
- **`addAdjacentVertex` Method**: Adds a vertex to the adjacency list if it’s not already there. For undirected graphs, it also adds the reverse connection.

#### **Graph Connectivity**
- **Connected Graph**: All vertices are reachable from any other vertex.
- **Disconnected Graph**: Not all vertices are reachable from others, so a separate data structure (like an array) might be needed to keep track of all vertices.

#### **Adjacency List vs. Adjacency Matrix**
- **Adjacency List**: Each vertex stores a list of its adjacent vertices. This is memory-efficient and ideal when the graph is sparse (few edges).
- **Adjacency Matrix**: A 2D array where each cell `[i][j]` represents an edge between vertices `i` and `j`. This is faster for lookups but uses more memory, especially in dense graphs.

## Graph Search

Graph search is a fundamental operation in graph theory, where the objective is to explore a graph to find specific vertices or determine connections between them. 

### 1. **Basic Concept of Graph Search**
In its simplest form, graph search involves finding a specific vertex in a graph, akin to searching for an item in a list or a key-value pair in a hash table. However, in graphs, searching typically involves finding a path from one vertex to another, starting from a given vertex.

### 2. **Paths in Graphs**
- **Path**: A path in a graph is a sequence of edges that connects a series of vertices. For example, if you have a graph representing a social network, a path might show how one person is connected to another through mutual friends.
- **Multiple Paths**: It's possible to have more than one path between two vertices. For example, if you're trying to find a way from "Alice" to "Irena" in a graph:
	![[Pasted image 20240820202815.png]]
	- A shorter path might be: `Alice -> Derek -> Gina -> Irena`
	- A longer path could be: `Alice -> Elaine -> Derek -> Gina -> Irena`

The concept of paths is crucial because it allows us to explore different ways of navigating through a graph.

### 3. **Use Cases for Graph Search**
- **Finding a Specific Vertex**: Given a starting vertex, the goal is to locate another specific vertex in the graph. This is particularly useful in connected graphs, where all vertices are somehow connected.
- **Checking Connectivity**: You might want to verify whether two vertices are connected, which involves determining if there is any path between them.
- **Graph Traversal**: Even when not searching for a specific vertex, graph search can be used to traverse the entire graph. This traversal can be useful for performing operations on all vertices, like marking them as visited or computing certain properties.

### 4. **Types of Graph Search**
There are different strategies for searching a graph, each with its own strengths and weaknesses, typically focusing on how the search explores the paths:
- **Breadth-First Search (BFS)**: Explores all neighbors at the present depth before moving on to nodes at the next depth level.
- **Depth-First Search (DFS)**: Explores as far as possible along one branch before backtracking.

### 5. **Applications**
Graph search has a wide range of applications, such as:
- **Social Networks**: Finding connections between people or suggesting friends.
- **Network Routing**: Determining the best path for data to travel across a network.
- **Solving Puzzles**: Like mazes, where the goal is to find a path from the start to the finish.

## Depth-First Search (DFS)

Depth-First Search (DFS) is a graph traversal algorithm that explores as far as possible along each branch before backtracking. This approach is similar to algorithms used for traversing binary trees and filesystems.

### Key Concepts:

1. **Traversal vs. Search**:
   - **Traversal**: DFS can be used to visit every vertex in a graph.
   - **Search**: It can also be employed to find a particular vertex within the graph.

2. **Cycle Handling**:
   - Unlike trees, graphs can have cycles, which can cause the algorithm to loop infinitely if not managed correctly.
	   - Example of an infinite cycle:
		![[Pasted image 20240820203033.png]]
   - **Tracking Visited Vertices**: To prevent infinite cycles, DFS keeps track of the vertices it has already visited. This is often done using a hash table (or set), where each visited vertex is stored.

3. **DFS Algorithm Steps**:
   1. **Start at a Vertex**: Begin at any vertex in the graph.
   2. **Mark as Visited**: Add this vertex to a hash table to mark it as visited.
   3. **Explore Adjacent Vertices**: Iterate over the current vertex's adjacent vertices.
   4. **Check for Visited Vertices**: If an adjacent vertex is already in the hash table, skip it.
   5. **Recursive Exploration**: If an adjacent vertex has not been visited, recursively perform DFS on that vertex.

- **Applications**: DFS is useful in scenarios like pathfinding, solving puzzles (e.g., mazes), and detecting cycles in a graph.
- **Comparison with BFS**: DFS is often compared with Breadth-First Search (BFS), which explores all neighbors at the current depth before moving deeper. DFS is generally better for problems requiring exploration of deep paths, while BFS is preferable for finding the shortest path in unweighted graphs.
### Walk-Through

#### **Step-by-Step Process:**
1. **Start at Alice:** 
   - Alice is marked as visited and added to the call stack. 
   - Explore Alice's neighbors: Bob, Candy, Derek, and Elaine.

![[Pasted image 20240820203232.png]]
![[Pasted image 20240820203317.png]]

2. **Visit Bob:**
   - Recursively perform DFS on Bob.
   - Mark Bob as visited and add him to the call stack.
   - Bob’s neighbors: Alice (already visited) and Fred.

![[Pasted image 20240820203330.png]]

3. **Visit Fred:**
   - Recursively perform DFS on Fred.
   - Mark Fred as visited and add him to the call stack.
   - Fred’s neighbors: Bob (already visited) and Helen.

![[Pasted image 20240820203342.png]]

![[Pasted image 20240820203352.png]]

4. **Visit Helen:**
   - Recursively perform DFS on Helen.
   - Mark Helen as visited and add her to the call stack.
   - Helen’s neighbors: Fred (already visited) and Candy.

![[Pasted image 20240820203402.png]]

![[Pasted image 20240820203407.png]]

5. **Visit Candy:**
   - Recursively perform DFS on Candy.
   - Mark Candy as visited and add her to the call stack.
   - Candy’s neighbors: Alice (already visited) and Helen (already visited).
   - No more neighbors to visit, so begin unwinding the call stack.

![[Pasted image 20240820203415.png]]

6. **Backtrack:**
   - Pop Helen, Fred, and Bob off the call stack as they have no unvisited neighbors left.

![[Pasted image 20240820203616.png]]

7. **Continue from Alice:**
   - Continue the loop for Alice’s neighbors: Candy (already visited).
   - Next, visit Derek.

8. **Visit Derek:**
   - Recursively perform DFS on Derek.
   - Mark Derek as visited and add him to the call stack.
   - Derek’s neighbors: Alice (already visited), Elaine, and Gina.

![[Pasted image 20240820203549.png]]

![[Pasted image 20240820203631.png]]

9. **Visit Elaine:**
   - Recursively perform DFS on Elaine.
   - Mark Elaine as visited and add her to the call stack.
   - Elaine’s neighbors: Alice (already visited) and Derek (already visited).
   - Backtrack from Elaine.

![[Pasted image 20240820203639.png]]

10. **Visit Gina:**
    - Recursively perform DFS on Gina.
    - Mark Gina as visited and add her to the call stack.
    - Gina’s neighbors: Derek (already visited) and Irena.

![[Pasted image 20240820203829.png]]

![[Pasted image 20240820203837.png]]

11. **Visit Irena:**
    - Recursively perform DFS on Irena.
    - Mark Irena as visited and add her to the call stack.
    - Irena’s only neighbor, Gina, is already visited.
    - Unwind the call stack completely.

![[Pasted image 20240820203844.png]]

**Completion:**
Once the call stack is fully unwound, DFS is complete, having visited all connected vertices from the starting point (Alice).

### C++ Implementation

#### **DFS Traversal in C++**
```cpp
#include <iostream>
#include <unordered_map>
#include <vector>
#include <string>

using namespace std;

class Vertex {
public:
    string value;
    vector<Vertex*> adjacent_vertices;

    Vertex(string v) : value(v) {}

    void add_adjacent_vertex(Vertex* vertex) {
        adjacent_vertices.push_back(vertex);
    }
};

void dfs_traverse(Vertex* vertex, unordered_map<string, bool>& visited_vertices) {
    // Mark vertex as visited:
    visited_vertices[vertex->value] = true;

    // Print the vertex's value:
    cout << vertex->value << endl;

    // Iterate through the current vertex's adjacent vertices:
    for (Vertex* adjacent_vertex : vertex->adjacent_vertices) {
        // Ignore an adjacent vertex if it's already visited:
        if (visited_vertices[adjacent_vertex->value]) {
            continue;
        }
        // Recursively call this method on the adjacent vertex:
        dfs_traverse(adjacent_vertex, visited_vertices);
    }
}
```

#### **DFS Search in C++**
```cpp
Vertex* dfs(Vertex* vertex, const string& search_value, unordered_map<string, bool>& visited_vertices) {
    // Return the vertex if it matches the search value:
    if (vertex->value == search_value) {
        return vertex;
    }
    
    visited_vertices[vertex->value] = true;
    
    for (Vertex* adjacent_vertex : vertex->adjacent_vertices) {
        if (visited_vertices[adjacent_vertex->value]) {
            continue;
        }
        
        // Return the vertex if it's the one we're searching for:
        if (adjacent_vertex->value == search_value) {
            return adjacent_vertex;
        }
        
        // Recursively search for the vertex:
        Vertex* found_vertex = dfs(adjacent_vertex, search_value, visited_vertices);
        
        // Return the found vertex:
        if (found_vertex) {
            return found_vertex;
        }
    }
    
    // Return nullptr if the vertex isn't found:
    return nullptr;
}
```

### **Explanation**
- **`dfs_traverse`** function performs a depth-first traversal of the graph starting from a given vertex. It marks each visited vertex and recursively visits adjacent vertices.
- **`dfs`** function searches for a specific vertex value in the graph. It returns the vertex if found or `nullptr` if the vertex is not present in the graph.

Both implementations ensure that each vertex is visited only once by keeping track of visited vertices using a hash table (or `unordered_map` in C++).

## Breadth-First Search (BFS)

**Breadth-First Search (BFS)** is a graph traversal algorithm that explores vertices in layers, visiting all neighbors at the present depth level before moving on to vertices at the next depth level. Unlike Depth-First Search (DFS), which uses recursion and a stack, BFS uses a queue to keep track of vertices to visit next.

Here's a summary of how BFS works:

1. **Start at a Vertex**:
   - Choose an initial vertex to start the search. This vertex will be the starting point.

2. **Initialize Data Structures**:
   - **Visited Hash Table**: Mark the starting vertex as visited by adding it to a hash table (or a similar data structure) to keep track of visited vertices.
   - **Queue**: Initialize a queue and enqueue the starting vertex. The queue will help manage the order in which vertices are explored.

3. **Processing Loop**:
   - **Dequeue**: While the queue is not empty, dequeue the first vertex. This vertex is considered the "current vertex."
   - **Visit Neighbors**: Iterate over all adjacent vertices of the current vertex.
     - If an adjacent vertex has not been visited yet, mark it as visited by adding it to the hash table, and enqueue it.

4. **Repeat**:
   - Continue the loop until the queue is empty. This ensures that all reachable vertices are visited.

### BFS Algorithm in Steps

1. **Initialization**:
   - Set the starting vertex as visited.
   - Enqueue the starting vertex.

2. **Loop Until Queue is Empty**:
   - Dequeue a vertex from the queue and process it.
   - For each neighbor of the dequeued vertex:
     - If the neighbor has not been visited:
       - Mark it as visited.
       - Enqueue the neighbor.

3. **Termination**:
   - The loop ends when the queue is empty, meaning all reachable vertices have been visited.

### Key Differences from DFS

- **Data Structure**: BFS uses a queue (FIFO) while DFS uses a stack (LIFO) or recursion.
- **Traversal Order**: BFS explores vertices layer by layer, while DFS explores as far as possible along each branch before backtracking.

BFS is particularly useful for finding the shortest path in an unweighted graph because it explores all nodes at the present "depth" before moving on to nodes at the next level.

### Walk-Through

Here’s a step-by-step explanation of how the Breadth-First Search (BFS) algorithm works, using Alice as the starting vertex:

1. **Initialization**:
   - **Starting Vertex**: Alice
   - **Mark Alice as Visited** and add her to the queue.

![[Pasted image 20240820204310.png]]

2. **Processing Loop**:

   - **Current Vertex**: Alice (dequeue Alice from the queue)
     - **Adjacent Vertices**:
       - **Bob**: Mark as visited, add to the queue.
	    ![[Pasted image 20240820204352.png]]
       - **Candy**: Mark as visited, add to the queue.
	    ![[Pasted image 20240820204400.png]]
       - **Derek**: Mark as visited, add to the queue.
		![[Pasted image 20240820204407.png]]
       - **Elaine**: Mark as visited, add to the queue.
	    ![[Pasted image 20240820204414.png]]

   - **Current Vertex**: Bob (dequeue Bob from the queue)
     - **Adjacent Vertices**:
       - **Alice**: Already visited, ignore.
       - **Fred**: Mark as visited, add to the queue.
    
![[Pasted image 20240820204426.png]]
![[Pasted image 20240820204521.png]]

   - **Current Vertex**: Candy (dequeue Candy from the queue)
     - **Adjacent Vertices**:
       - **Alice**: Already visited, ignore.
       - **Helen**: Mark as visited, add to the queue.

![[Pasted image 20240820204538.png]]
![[Pasted image 20240820204552.png]]

   - **Current Vertex**: Derek (dequeue Derek from the queue)
     - **Adjacent Vertices**:
       - **Alice**: Already visited, ignore.
       - **Elaine**: Already visited, ignore.
       - **Gina**: Mark as visited, add to the queue.

![[Pasted image 20240820204600.png]]
![[Pasted image 20240820204613.png]]

   - **Current Vertex**: Elaine (dequeue Elaine from the queue)
     - **Adjacent Vertices**:
       - **Alice**: Already visited, ignore.
       - **Derek**: Already visited, ignore.

![[Pasted image 20240820204626.png]]

   - **Current Vertex**: Fred (dequeue Fred from the queue)
     - **Adjacent Vertices**:
       - **Bob**: Already visited, ignore.
       - **Helen**: Already visited, ignore.

![[Pasted image 20240820204635.png]]

   - **Current Vertex**: Helen (dequeue Helen from the queue)
     - **Adjacent Vertices**:
       - **Fred**: Already visited, ignore.
       - **Candy**: Already visited, ignore.

![[Pasted image 20240820204646.png]]

   - **Current Vertex**: Gina (dequeue Gina from the queue)
     - **Adjacent Vertices**:
       - **Derek**: Already visited, ignore.
       - **Irena**: Mark as visited, add to the queue.

![[Pasted image 20240820204653.png]]
![[Pasted image 20240820204717.png]]

   - **Current Vertex**: Irena (dequeue Irena from the queue)
     - **Adjacent Vertices**:
       - **Gina**: Already visited, ignore.

![[Pasted image 20240820204723.png]]

3. **Completion**:
   - The queue is now empty, indicating that all reachable vertices have been visited.

### C++ Implementation

```cpp
#include <iostream>
#include <queue>
#include <unordered_map>
#include <vector>

class Vertex {
public:
    int value;
    std::vector<Vertex*> adjacent_vertices;

    Vertex(int val) : value(val) {}
};

void bfs_traverse(Vertex* starting_vertex) {
    std::queue<Vertex*> queue;
    std::unordered_map<int, bool> visited_vertices;

    // Mark the starting vertex as visited and enqueue it
    visited_vertices[starting_vertex->value] = true;
    queue.push(starting_vertex);

    // While the queue is not empty
    while (!queue.empty()) {
        // Remove the first vertex from the queue and make it the current vertex
        Vertex* current_vertex = queue.front();
        queue.pop();

        // Print the current vertex's value
        std::cout << current_vertex->value << std::endl;

        // Iterate over the current vertex's adjacent vertices
        for (Vertex* adjacent_vertex : current_vertex->adjacent_vertices) {
            // If we have not yet visited the adjacent vertex
            if (visited_vertices.find(adjacent_vertex->value) == visited_vertices.end()) {
                // Mark the adjacent vertex as visited and add it to the queue
                visited_vertices[adjacent_vertex->value] = true;
                queue.push(adjacent_vertex);
            }
        }
    }
}
```

### Explanation

1. **Queue Initialization**:
   - Use `std::queue<Vertex*>` to manage the vertices to be processed.

2. **Visited Vertices Tracking**:
   - `std::unordered_map<int, bool>` keeps track of visited vertices.

3. **Traversal**:
   - Start by marking the `starting_vertex` as visited and enqueue it.
   - While the queue is not empty:
     - Dequeue the front vertex.
     - Print its value.
     - Iterate through its adjacent vertices:
       - If an adjacent vertex has not been visited, mark it as visited and enqueue it.

## DFS vs. BFS

**1. Search Strategy:**

- **Depth-First Search (DFS)**:
  - Explores as far as possible along each branch before backtracking.
  - Follows a path from the starting vertex to a leaf (or dead end) before trying another path.
  - Uses a stack (either explicitly or through recursion).

- **Breadth-First Search (BFS)**:
  - Explores all vertices at the present depth level before moving on to vertices at the next depth level.
  - Uses a queue to manage the vertices to be explored.

**2. Use Cases and Advantages:**

- **Finding Direct Connections**:
  - **BFS** is preferable for finding all immediate neighbors or direct connections (e.g., Alice’s friends) efficiently. BFS will find all vertices at the current level before moving to the next, making it ideal for scenarios where proximity is important.

- **Finding Specific Nodes in a Large Tree**:
  - **DFS** can be more effective for finding a specific node in a large or deep graph, like searching for Ruth in a family tree. DFS explores one branch deeply before moving to another, which can be faster if the desired node is far from the root.

**3. Time Complexity**:
  - Both DFS and BFS have a time complexity of $O(V + E)$, where $V$ is the number of vertices and $E$ is the number of edges, because each vertex and edge is processed once.

**4. Space Complexity**:
  - **DFS**:
    - **Recursive DFS**: Space complexity can be $O(h)$ where $h$ is the maximum depth of recursion (in practice, can be higher if the graph is deep).
    - **Iterative DFS with Stack**: Space complexity is $O(V)$ in the worst case.
  
  - **BFS**:
    - Uses a queue, so the space complexity is $O(V)$ in the worst case as all vertices at a given level might be stored in the queue.

**5. Traversal Order**:
  - **DFS**: Can be implemented using pre-order, in-order, or post-order traversal depending on when vertices are processed relative to their children.
  - **BFS**: Processes vertices level by level, ensuring that all vertices at distance $d$ from the start are processed before those at distance $d+1$.

**6. Cycles and Connectivity**:
  - **DFS**: Can easily get stuck in cycles if not properly managed with a visited set.
  - **BFS**: Generally easier to manage and avoids cycles naturally when using a queue.

### Summary

- **Use BFS** when:
  - You need to find all nodes at a specific level.
  - You want to find the shortest path in an unweighted graph.
  - You are interested in the nearest neighbors or connections.

- **Use DFS** when:
  - You need to explore deep paths or solutions in large graphs.
  - You are interested in topological sorting or solving problems where moving far away from the start quickly is beneficial.

## Efficiency of Graph Search

To understand the efficiency of graph search algorithms like Depth-First Search (DFS) and Breadth-First Search (BFS), we need to consider both the number of vertices and the number of edges in the graph.

#### **Time Complexity of Graph Search Algorithms**

1. **Number of Vertices (V):**
   - This is the count of nodes or points in the graph.

2. **Number of Edges (E):**
   - This is the count of connections or links between the vertices.

In both DFS and BFS, each vertex is visited once. During each visit, the algorithm checks all adjacent vertices (i.e., the edges connected to that vertex). 

**Time Complexity Analysis:**

- **Vertices:** Each vertex is processed exactly once. Therefore, the time complexity contribution from the vertices alone is $O(V)$.

- **Edges:** For each vertex, the algorithm checks each adjacent edge. In the worst case, every edge is checked exactly twice (once from each end), contributing $O(E)$ to the time complexity.

Combining these two factors, the overall time complexity of both DFS and BFS is:

$$
O(V + E)
$$

Where:
- $V$ is the number of vertices.
- $E$ is the number of edges.

**Examples:**

1. **Dense Graph (e.g., Complete Graph):**
   - In a complete graph with $V$ vertices, every vertex is connected to every other vertex, resulting in $E = \frac{V(V-1)}{2}$ edges.
   - For a dense graph, the number of edges grows quadratically with the number of vertices. Hence, $E$ is on the order of $V^2$.
   - Thus, the time complexity would be $O(V + V^2) = O(V^2)$.

2. **Sparse Graph (e.g., Tree):**
   - In a tree, which is a type of graph with $V$ vertices and $V-1$ edges, the number of edges is linear with respect to the number of vertices.
   - Therefore, for a sparse graph, the time complexity would be $O(V + (V-1)) = O(V)$.

**Space Complexity:**

The space complexity of DFS and BFS is determined by:

1. **Visited Set:** Both algorithms need to keep track of visited vertices, which requires $O(V)$ space.

2. **Data Structures:**
   - **DFS:** Uses a stack (or recursion) which may need to store up to $O(V)$ vertices in the worst case.
   - **BFS:** Uses a queue to store vertices, which also requires $O(V)$ space in the worst case.

Overall, the space complexity for both algorithms is:

$$
O(V)
$$

**Summary:**

- **Time Complexity:** $O(V + E)$
- **Space Complexity:** $O(V)$

The actual performance of DFS and BFS will vary depending on the specific structure of the graph and whether it is dense or sparse.

## Weighted Graphs and Shortest Path Problem

#### **Weighted Graphs**

A **weighted graph** is a graph where each edge has a weight associated with it. The weight often represents cost, distance, or some other measure of "value" between the vertices connected by that edge.

![[Pasted image 20240820205217.png]]

**Example of Weighted Graphs:**
- **Distance:** The distance between cities, such as the miles between Chicago and New York City.
- **Cost:** The cost of flights or other transactions.

**Directional Weighted Graphs:**
- These graphs not only have weights but also indicate the direction of travel. For instance, a flight from Dallas to Toronto might cost $138, while the reverse flight costs $216.

![[Pasted image 20240820205224.png]]

#### **Code Representation for Weighted Graphs**

To represent weighted graphs in code, you can use a hash table to store the weights associated with each edge.

```cpp
#include <unordered_map>
#include <vector>
#include <string>

class WeightedGraphVertex {
public:
    std::string value;
    std::unordered_map<WeightedGraphVertex*, int> adjacent_vertices;

    WeightedGraphVertex(const std::string& val) : value(val) {}

    void add_adjacent_vertex(WeightedGraphVertex* vertex, int weight) {
        adjacent_vertices[vertex] = weight;
    }
};
```

**Explanation:**
- `adjacent_vertices` is an unordered map where the key is a pointer to the adjacent vertex and the value is the weight of the edge.
- The `add_adjacent_vertex` method allows adding an edge with a specific weight to the vertex.

#### **Shortest Path Problem**

The **shortest path problem** involves finding the most efficient path between two vertices in a weighted graph. Efficiency is determined by the sum of the weights along the path. The problem can be applied to various scenarios, such as:

- Finding the cheapest flight route between cities.
- Determining the shortest distance in a map.

**Popular Algorithms for Solving the Shortest Path Problem:**

1. **Dijkstra's Algorithm:**
   - Used for finding the shortest path from a starting vertex to all other vertices in a graph with non-negative weights.
   - Efficient with a time complexity of $O((V + E) \log V)$ when implemented with a priority queue.

2. **Bellman-Ford Algorithm:**
   - Suitable for graphs with negative weights but no negative-weight cycles.
   - Has a time complexity of $O(V \cdot E)$.

3. **Floyd-Warshall Algorithm:**
   - Computes shortest paths between all pairs of vertices.
   - Time complexity is $O(V^3)$, making it suitable for smaller graphs.

## Dijkstra’s Algorithm 

Dijkstra’s algorithm is a classic method for finding the shortest path in a graph with non-negative weights.

#### **Data Structures**

1. **Cheapest Prices Table (`cheapest_prices_table`)**
   - This table stores the minimum cost to reach each vertex from the starting vertex. Initially, only the starting vertex has a cost of `0`, while all other vertices have an infinite cost (indicating they are not yet reachable).

   **Example:**
   ```cpp
   std::unordered_map<std::string, int> cheapest_prices_table = {
       {"Atlanta", 0}, 
       {"Boston", INT_MAX}, 
       {"Chicago", INT_MAX}, 
       {"Denver", INT_MAX}, 
       {"El Paso", INT_MAX}
   };
   ```

2. **Cheapest Previous Stopover City Table (`cheapest_previous_stopover_city_table`)**
   - This table tracks the last city visited before reaching each city with the minimum cost. It helps in reconstructing the shortest path once the algorithm completes.

   **Example:**
   ```cpp
   std::unordered_map<std::string, std::string> cheapest_previous_stopover_city_table = {
       {"Boston", ""}, 
       {"Chicago", ""}, 
       {"Denver", ""}, 
       {"El Paso", ""}
   };
   ```

#### **Dijkstra’s Algorithm Steps**

1. **Initialization:**
   - Set the starting city as the current city.
   - Initialize `cheapest_prices_table` with the cost to reach the starting city as `0` and all other cities as `INT_MAX` (infinity).

2. **Visit the Current City:**
   - Check all adjacent cities of the current city and calculate the cost to reach each adjacent city via the current city.
   - If the calculated cost is less than the current value in `cheapest_prices_table`, update both `cheapest_prices_table` and `cheapest_previous_stopover_city_table`.

3. **Update the Cheapest Prices Table:**
   - For each adjacent city, if the new cost is cheaper, update the table and also record the current city as the previous stopover city.

4. **Select the Next City:**
   - Choose the unvisited city with the smallest cost from `cheapest_prices_table` as the new current city.

5. **Repeat Until All Cities Are Visited:**
   - Continue visiting cities and updating tables until every city has been visited.

6. **Path Reconstruction:**
   - Once the algorithm completes, use `cheapest_previous_stopover_city_table` to reconstruct the path from the starting city to the destination city.

#### **Dijkstra’s Algorithm Example in C++**

Here’s a simple implementation of Dijkstra’s algorithm:

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <unordered_map>
#include <climits>
#include <string>

class Graph {
public:
    std::unordered_map<std::string, std::vector<std::pair<std::string, int>>> adj;

    void add_edge(const std::string& u, const std::string& v, int weight) {
        adj[u].emplace_back(v, weight);
        adj[v].emplace_back(u, weight); // For undirected graph
    }

    void dijkstra(const std::string& start) {
        std::unordered_map<std::string, int> cheapest_prices_table;
        std::unordered_map<std::string, std::string> cheapest_previous_stopover_city_table;

        // Initialize tables
        for (const auto& pair : adj) {
            cheapest_prices_table[pair.first] = INT_MAX;
            cheapest_previous_stopover_city_table[pair.first] = "";
        }
        cheapest_prices_table[start] = 0;

        using pii = std::pair<int, std::string>; // (cost, city)
        std::priority_queue<pii, std::vector<pii>, std::greater<>> pq;
        pq.emplace(0, start);

        while (!pq.empty()) {
            int current_cost = pq.top().first;
            std::string current_city = pq.top().second;
            pq.pop();

            if (current_cost > cheapest_prices_table[current_city]) continue;

            for (const auto& edge : adj[current_city]) {
                const std::string& adjacent_city = edge.first;
                int weight = edge.second;
                int new_cost = current_cost + weight;

                if (new_cost < cheapest_prices_table[adjacent_city]) {
                    cheapest_prices_table[adjacent_city] = new_cost;
                    cheapest_previous_stopover_city_table[adjacent_city] = current_city;
                    pq.emplace(new_cost, adjacent_city);
                }
            }
        }

        // Output the results
        for (const auto& pair : cheapest_prices_table) {
            std::cout << "Cheapest price from " << start << " to " << pair.first << " is $" << pair.second << "\n";
        }
    }
};

int main() {
    Graph g;
    g.add_edge("Atlanta", "Boston", 100);
    g.add_edge("Atlanta", "Chicago", 200);
    g.add_edge("Atlanta", "Denver", 160);
    g.add_edge("Chicago", "El Paso", 80);
    g.add_edge("Denver", "El Paso", 120);

    g.dijkstra("Atlanta");

    return 0;
}
```

**Explanation:**
- **Graph Construction:** `add_edge` method creates bidirectional edges with weights.
- **Dijkstra’s Algorithm:** Uses a priority queue to efficiently find the shortest paths.
- **Output:** Displays the shortest path costs from the starting city to all other cities.

### Step-by-Step Walk-Through

#### Initial Setup
- **Starting City:** Atlanta

#### Cheapest Prices Table
| From Atlanta To | Boston | Chicago | Denver | El Paso |
|-----------------|--------|---------|--------|---------|
| $0              | $∞     | $∞      | $∞     | $∞      |

#### Previous Stopover Table
| Cheapest Previous Stopover City from Atlanta: | Boston | Chicago | Denver | El Paso |
| --------------------------------------------- | ------ | ------- | ------ | ------- |
|                                               | -      | -       | -      | -       |

#### **Step 1: Visit Atlanta**
- **Current City:** Atlanta
- **Inspect Adjacent Cities:** Boston, Denver

![[Pasted image 20240820210120.png]]

#### **Step 2: Update Prices from Atlanta to Boston and Denver**

- **Price to Boston:** $100 (New entry in `cheapest_prices_table`)

#### Updated Cheapest Prices Table
| From Atlanta To | Boston | Chicago | Denver | El Paso |
|-----------------|--------|---------|--------|---------|
| $0              | $100   | $∞      | $∞     | $∞      |

#### Updated Previous Stopover Table
| Cheapest Previous Stopover City from Atlanta: | Boston  | Chicago | Denver | El Paso |
| --------------------------------------------- | ------- | ------- | ------ | ------- |
|                                               | Atlanta | -       | -      | -       |

- **Price to Denver:** $160 (New entry in `cheapest_prices_table`)

#### Updated Cheapest Prices Table
| From Atlanta To | Boston | Chicago | Denver | El Paso |
|-----------------|--------|---------|--------|---------|
| $0              | $100   | $∞      | $160   | $∞      |

#### Updated Previous Stopover Table
| Cheapest Previous Stopover City from Atlanta: | Boston  | Chicago | Denver  | El Paso |
| --------------------------------------------- | ------- | ------- | ------- | ------- |
|                                               | Atlanta | -       | Atlanta | -       |

#### **Step 3: Choose the Next City to Visit**
- **Unvisited Cities:** Boston, Denver
- **Visit Boston** (cheapest price from Atlanta)

![[Pasted image 20240820210223.png]]

#### **Step 4: Inspect Boston’s Adjacent Cities**
- **Adjacent Cities:** Chicago, Denver

#### **Step 5: Update Prices via Boston**

- **Price from Atlanta to Chicago via Boston:** $100 (Atlanta to Boston) + $120 (Boston to Chicago) = $220

#### Updated Cheapest Prices Table
| From Atlanta To | Boston | Chicago | Denver | El Paso |
| --------------- | ------ | ------- | ------ | ------- |
| $0              | $100   | *$220*  | $160   | $∞      |

#### Updated Previous Stopover Table
| Cheapest Previous Stopover City from Atlanta: | Boston  | Chicago  | Denver  | El Paso |
| --------------------------------------------- | ------- | -------- | ------- | ------- |
|                                               | Atlanta | *Boston* | Atlanta | -       |

- **Price from Atlanta to Denver via Boston:** $100 (Atlanta to Boston) + $180 (Boston to Denver) = $280
  - **Current Price to Denver ($160) is cheaper than $280**; no update needed for Denver.

#### **Step 6: Choose the Next City to Visit**
- **Unvisited Cities:** Chicago, Denver
- **Visit Denver** (cheapest price from Atlanta)

![[Pasted image 20240820210520.png]]

#### **Step 7: Inspect Denver’s Adjacent Cities**
- **Adjacent Cities:** Chicago, El Paso

#### **Step 8: Update Prices via Denver**

- **Price from Atlanta to Chicago via Denver:** $160 (Atlanta to Denver) + $40 (Denver to Chicago) = $200

#### Updated Cheapest Prices Table
| From Atlanta To | Boston | Chicago | Denver | El Paso |
|-----------------|--------|---------|--------|---------|
| $0              | $100   | $200   | $160   | $∞      |

#### Updated Previous Stopover Table
| Cheapest Previous Stopover City from Atlanta: | Boston | Chicago | Denver  | El Paso |
| --------------------------------------------- | ------ | ------- | ------- | ------- |
|                                               | Boston | Denver  | Atlanta | -       |

- **Price from Atlanta to El Paso via Denver:** $160 (Atlanta to Denver) + $140 (Denver to El Paso) = $300

#### Updated Cheapest Prices Table
| From Atlanta To | Boston | Chicago | Denver | El Paso |
|-----------------|--------|---------|--------|---------|
| $0              | $100   | $200   | $160   | $300   |

#### Updated Previous Stopover Table
| Cheapest Previous Stopover City from Atlanta: | Boston | Chicago | Denver  | El Paso |
| --------------------------------------------- | ------ | ------- | ------- | ------- |
|                                               | Boston | Denver  | Atlanta | Denver  |

#### **Step 9: Choose the Next City to Visit**
- **Unvisited Cities:** Chicago, El Paso
- **Visit Chicago** (cheapest price from Atlanta)

![[Pasted image 20240820210608.png]]

#### **Step 10: Inspect Chicago’s Adjacent Cities**
- **Adjacent Cities:** El Paso

#### **Step 11: Update Prices via Chicago**

- **Price from Atlanta to El Paso via Chicago:** $200 (Atlanta to Chicago) + $80 (Chicago to El Paso) = $280

#### Updated Cheapest Prices Table
| From Atlanta To | Boston | Chicago | Denver | El Paso |
|-----------------|--------|---------|--------|---------|
| $0              | $100   | $200   | $160   | $280   |

#### Updated Previous Stopover Table
| Cheapest Previous Stopover City from Atlanta: | Boston   | Chicago | Denver  | El Paso |
| --------------------------------------------- | -------- | ------- | ------- | ------- |
|                                               | Atalanta | Denver  | Atlanta | Chicago |

#### **Step 12: Choose the Next City to Visit**
- **Unvisited Cities:** El Paso
- **Visit El Paso**

![[Pasted image 20240820210706.png]]

#### **Step 13: Inspect El Paso’s Adjacent Cities**
- **Adjacent Cities:** Boston
  - **No updates required** since revisiting Boston yields a more expensive route than previously known.

### Given Data

#### Cheapest Prices Table
| From Atlanta To | Boston | Chicago | Denver | El Paso |
|-----------------|--------|---------|--------|---------|
| $0              | $100   | $200   | $160   | $280   |

#### Cheapest Previous Stopover Table
| Cheapest Previous Stopover City from Atlanta: | Boston   | Chicago | Denver  | El Paso |
| --------------------------------------------- | -------- | ------- | ------- | ------- |
|                                               | Atalanta | Denver  | Atlanta | Chicago |

### Finding the Shortest Path

1. **Start with the Destination: El Paso**

   - **Previous Stopover City for El Paso:** Chicago
   - Path so far: `Chicago -> El Paso`

2. **Trace Back to Chicago**

   - **Previous Stopover City for Chicago:** Denver
   - Update path: `Denver -> Chicago -> El Paso`

3. **Trace Back to Denver**

   - **Previous Stopover City for Denver:** Atlanta
   - Update path: `Atlanta -> Denver -> Chicago -> El Paso`

4. **Starting City**

   - **Atlanta** is our starting city, so the final path is:
     - `Atlanta -> Denver -> Chicago -> El Paso`

### Final Path and Price

- **Shortest Path:** `Atlanta -> Denver -> Chicago -> El Paso`
- **Cheapest Price:** $280
