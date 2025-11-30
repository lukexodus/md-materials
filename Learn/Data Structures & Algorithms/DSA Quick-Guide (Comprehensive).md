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

## Space Complexity Notations

Space complexity measures the amount of memory an algorithm uses as a function of the input size.

- **O(1)** - **Constant Space**:
  - The amount of memory required does not change with the size of the input. For example, using a fixed number of variables.

- **O(n)** - **Linear Space**:
  - The memory usage grows linearly with the size of the input. For example, storing an array of size $n$.

- **O(n^2)** - **Quadratic Space**:
  - Memory usage grows proportionally to the square of the input size. This could occur in algorithms that use a 2D array to store data.


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

## Reading

### **Reading from an Array**

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

## Searching

### **Searching an Array**

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

## Insertion

### **Insertion in an Array**

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

## **Deletion in an Array**

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

## Sets: How a Single Rule Can Affect Efficiency

### **Sets: Efficiency Analysis**

**Sets** are data structures that store unique elements, meaning no duplicates are allowed. This uniqueness constraint affects the efficiency of various operations, particularly insertion. Let’s break down the efficiency of operations on an array-based set compared to a regular array.

#### **Operations in an Array-Based Set**

1. **Reading**:
   - **Description**: Accessing the value at a specific index.
   - **Efficiency**: Just like in an array, reading from a set takes $O(1)$ time. The computer can jump directly to the index and retrieve the value.

2. **Searching**:
   - **Description**: Determining if a particular value exists within the set.
   - **Efficiency**: Searching in a set is similar to searching in an array. The computer may need to inspect up to $N$ elements, making the time complexity $O(n)$ in the worst case.

3. **Deletion**:
   - **Description**: Removing a value from a specific index and shifting elements to close the gap.
   - **Efficiency**: Deletion from a set requires up to $N$ steps, just like in an array. This includes the time to remove the value and shift subsequent elements.

4. **Insertion**:
   - **Description**: Adding a new value to the set.
   - **Efficiency**:
     - **Best-Case Scenario**: Inserting at the end of the set involves checking if the value already exists (which takes $O(n)$ time) and then adding it, resulting in $O(n+1)$ steps. The $+1$ accounts for the insertion step itself.
     - **Worst-Case Scenario**: Inserting at the beginning involves searching through all $N$ elements to ensure no duplicates, shifting all $N$ elements, and then inserting the new value. This totals $2N + 1$ steps.

#### **Comparative Analysis**

- **Array vs. Set**:
  - **Reading**: Both operations are $O(1)$.
  - **Searching**: Both operations are $O(n)$.
  - **Deletion**: Both operations are $O(n)$.
  - **Insertion**:
    - **Array**: Insertion at the end takes $O(1)$, but insertion at the beginning or middle takes $O(n)$.
    - **Set**: Insertion always requires $O(n)$ time due to the need to check for duplicates, making it slower compared to inserting at the end of an array.

#### **Analogy for Insertion in a Set**

- **Analogy**: Imagine a row of lockers where each locker has a unique number. If you want to put a new item in one of these lockers, you first need to check if the locker is empty and not occupied by another item. If it is, you can proceed to put your item in. If not, you have to find another locker. This checking process takes time. Inserting at the end is easier but still requires you to ensure the locker isn’t already occupied.

### **Summary**

- **Sets** are great for ensuring unique data, but their insertion operation is generally less efficient compared to arrays due to the need for duplicate checks.
- **Arrays** are more efficient for insertion when you don’t need to enforce uniqueness but can’t prevent duplicate data.
- Choosing the right data structure depends on your application needs. If you need to avoid duplicates and can handle slightly slower insertions, sets are useful. If you need faster insertion and don’t need to enforce uniqueness, arrays might be better.

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
## Bubble Sort Algorithm

**Bubble Sort** is a straightforward sorting algorithm with a simple concept: repeatedly stepping through the list, comparing adjacent elements, and swapping them if they are in the wrong order. The process is repeated until the list is sorted. 

#### **Steps of Bubble Sort**

1. **Initial Setup**:
   - Start by comparing the first two elements of the array.
	![[Pasted image 20240819203356.png]]

2. **Compare and Swap**:
   - If the first element is greater than the second element, swap them. This step places the larger value at the end of the array.
	![[Pasted image 20240819203401.png]]

3. **Move Pointers**:
   - Move the pointers one position to the right and repeat the comparison and swap process for the next pair of elements.
	![[Pasted image 20240819203406.png]]

4. **Complete Pass**:
   - Continue this process until you reach the end of the array. At the end of the first pass, the largest element will have “bubbled up” to the end of the array.

5. **Repeat**:
   - Reset the pointers to the beginning of the array and repeat the process. Each subsequent pass will ensure the next largest element finds its correct position, reducing the range of unsorted elements by one each time.

6. **Termination**:
   - The algorithm terminates when a complete pass through the array is made without any swaps, indicating that the array is sorted.

#### **Code Example in C++**

Here’s a simple implementation of Bubble Sort in C++:

```cpp
#include <iostream>
using namespace std;

void bubbleSort(int arr[], int n) {
    bool swapped;
    for (int i = 0; i < n-1; i++) {
        swapped = false;
        for (int j = 0; j < n-i-1; j++) {
            if (arr[j] > arr[j+1]) {
                swap(arr[j], arr[j+1]);
                swapped = true;
            }
        }
        // If no two elements were swapped in the inner loop, then break
        if (!swapped)
            break;
    }
}

int main() {
    int arr[] = {64, 34, 25, 12, 22, 11, 90};
    int n = sizeof(arr)/sizeof(arr[0]);
    bubbleSort(arr, n);
    cout << "Sorted array: \n";
    for (int i = 0; i < n; i++)
        cout << arr[i] << " ";
    cout << endl;
    return 0;
}
```

**Output**:
```
Sorted array: 
11 12 22 25 34 64 90 
```

#### **Time Complexity**

- **Worst-Case**: O(N²), where N is the number of elements in the array. This occurs when the array is in reverse order.
- **Best-Case**: O(N) when the array is already sorted, thanks to the early termination condition.
- **Average-Case**: O(N²) due to the nested loops.

![[Pasted image 20240819203440.png]]

Bubble Sort is generally not used for large datasets due to its inefficiency compared to more advanced algorithms like Quick Sort or Merge Sort. However, its simplicity makes it a useful educational tool for understanding basic sorting concepts.

## Selection Sort Algorithm

**Selection Sort** is another classic sorting algorithm. It operates by repeatedly selecting the smallest (or largest) element from the unsorted portion of the array and swapping it with the first unsorted element.

#### **Steps of Selection Sort**

1. **Find the Minimum**:
   - Start from the first element of the array and scan through the remaining unsorted elements to find the smallest value. Keep track of the index of this minimum value.
	![[Pasted image 20240819203604.png]]

2. **Swap**:
   - Swap the found minimum value with the first unsorted element. After the swap, the first element is now sorted, and we can consider the next element in the array.
	![[Pasted image 20240819203612.png]]

3. **Repeat**:
   - Move the starting point of the unsorted portion one position to the right and repeat the process until the entire array is sorted.

#### **Example**

![[Pasted image 20240819203736.png]]

#### **Code Example in C++**

Here’s a simple implementation of Selection Sort in C++:

```cpp
#include <iostream>
using namespace std;

void selectionSort(int arr[], int n) {
    for (int i = 0; i < n-1; i++) {
        // Find the minimum element in the unsorted array
        int minIndex = i;
        for (int j = i+1; j < n; j++) {
            if (arr[j] < arr[minIndex]) {
                minIndex = j;
            }
        }
        // Swap the found minimum element with the first element
        if (minIndex != i) {
            swap(arr[i], arr[minIndex]);
        }
    }
}

int main() {
    int arr[] = {64, 25, 12, 22, 11};
    int n = sizeof(arr)/sizeof(arr[0]);
    selectionSort(arr, n);
    cout << "Sorted array: \n";
    for (int i = 0; i < n; i++)
        cout << arr[i] << " ";
    cout << endl;
    return 0;
}
```

**Output**:
```
Sorted array: 
11 12 22 25 64 
```

#### **Time Complexity**

- **Worst-Case**: O(N²), where N is the number of elements in the array. This occurs because of the nested loops used to find the minimum value.
- **Best-Case**: O(N²) as well, even if the array is already sorted. This is because the algorithm still needs to perform all comparisons.
- **Average-Case**: O(N²), due to the same reason as the worst-case scenario.

#### **Comparison with Bubble Sort**

Both Selection Sort and Bubble Sort have a time complexity of O(N²), but they differ in their approach:

- **Selection Sort**: Always performs N-1 comparisons per pass and performs fewer swaps. It may be better for scenarios where swaps are more costly than comparisons.
- **Bubble Sort**: Continuously swaps adjacent elements and may terminate early if the array becomes sorted before completing all passes.

Selection Sort is often used in educational contexts to illustrate sorting principles and is sometimes used in practice when memory writes are expensive, as it minimizes the number of swaps.

## Efficiency and Big O Notation for Sorting Algorithms

The discussion of **Selection Sort** and **Bubble Sort** highlights important aspects of algorithm efficiency and the role of Big O Notation.

#### **Comparison of Selection Sort and Bubble Sort**

Both Selection Sort and Bubble Sort are quadratic algorithms, meaning their time complexity is O(N²). This notation captures the growth rate of the algorithm’s steps relative to the size of the input data but does not account for constant factors or lower-order terms.

#### **Analysis of Steps**

- **Selection Sort**:
  - **Comparisons**: The number of comparisons is \((N - 1) + (N - 2) + \ldots + 1\), which sums up to \(\frac{N(N-1)}{2}\). This is O(N²) in Big O Notation.
  - **Swaps**: There are at most \(N - 1\) swaps, one for each pass through the array. In practice, Selection Sort performs fewer swaps compared to Bubble Sort.

- **Bubble Sort**:
  - **Comparisons**: Bubble Sort also makes \(\frac{N(N-1)}{2}\) comparisons in the worst case, which is O(N²).
  - **Swaps**: Bubble Sort can make up to \(\frac{N(N-1)}{2}\) swaps in the worst case, which is significantly more than Selection Sort.

#### **Table of Steps**

Here’s a clearer side-by-side comparison based on your data:

| N Elements | Max # of Steps in Bubble Sort | Max # of Steps in Selection Sort |
|------------|-------------------------------|---------------------------------|
| 5          | 20                            | 14 (10 comparisons + 4 swaps)   |
| 10         | 90                            | 54 (45 comparisons + 9 swaps)   |
| 20         | 380                           | 199 (180 comparisons + 19 swaps)|
| 40         | 1560                          | 819 (780 comparisons + 39 swaps)|
| 80         | 6320                          | 3239 (3160 comparisons + 79 swaps)|

This table confirms that Selection Sort is generally more efficient than Bubble Sort because it performs fewer swaps.

#### **Ignoring Constants in Big O Notation**

Big O Notation simplifies the description of an algorithm’s efficiency by focusing on its growth rate rather than exact counts of steps. Here’s why:

1. **Focus on Growth Rate**: Big O Notation is concerned with how the time complexity grows with input size \(N\). Constants and lower-order terms are less significant for large \(N\).
  
2. **Dropping Constants**: Big O Notation ignores multiplicative constants. For instance:
   - An algorithm with \(N/2\) steps is described as O(N).
   - An algorithm with \(2N\) steps is also described as O(N).

3. **Real-World Implications**: While two algorithms might have the same Big O complexity, the actual performance can differ based on constants and lower-order terms. For example, Selection Sort might be faster than Bubble Sort in practice due to fewer swaps, even though both have O(N²) complexity.

#### **Why It Matters**

- **Scalability**: Big O Notation helps in understanding how an algorithm will scale with increasing input sizes. It provides a high-level understanding of efficiency and performance.
  
- **Practical Considerations**: In real-world scenarios, you should consider both Big O complexity and practical factors like constant factors, cache performance, and implementation details to choose the most suitable algorithm.

## Big O Categories and Their Significance

![[Pasted image 20240819204016.png]]

The discussion on Big O categories underscores the importance of understanding how different types of algorithms scale with input size. Here’s a detailed breakdown of the key points:

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

Graphs illustrating different Big O categories help visualize how their growth rates diverge as input size increases. For instance:

- **O(1)** remains constant regardless of input size.
- **O(log N)** increases slowly, reflecting logarithmic growth.
- **O(N)** shows a straight line, indicating linear growth.
- **O(N²)** curves upwards more steeply, demonstrating quadratic growth.

## Insertion Sort

**Insertion Sort** is another classic sorting algorithm, and it's known for its simplicity and efficiency in certain scenarios. Here’s a detailed look at how Insertion Sort works and its efficiency:

#### **Steps of Insertion Sort**

1. **Initial Pass-Through**:
   - **Remove the Value**: Start with the value at index 1 (the second cell) and store it in a temporary variable.
   - **Create a Gap**: This removal creates a gap at index 1.
	![[Pasted image 20240819204131.png]]

2. **Shifting Phase**:
   - **Compare and Shift**: Compare the temporarily removed value with each value to the left of the gap. 
	![[Pasted image 20240819204156.png]]
   - **Shift Larger Values**: If a value to the left is greater than the temporarily removed value, shift it one position to the right.
	![[Pasted image 20240819204204.png]]
   - **Stop Shifting**: Continue shifting until you find a value smaller than the temporarily removed value or you reach the start of the array.


3. **Insert the Value**:
   - **Place the Value**: Insert the temporarily removed value into the correct position within the shifted portion of the array.
	![[Pasted image 20240819204216.png]]

4. **Repeat**:
   - **Continue**: Repeat the process for each subsequent index until you have traversed the entire array. Each pass-through inserts one element into its correct position, thus sorting the array incrementally.

#### **Efficiency of Insertion Sort**

1. **Best-Case Scenario**:
   - **Sorted Array**: If the array is already sorted, Insertion Sort performs very efficiently. It only requires a linear number of comparisons and no swaps.
   - **Complexity**: In this best-case scenario, the time complexity is \(O(N)\).

2. **Worst-Case Scenario**:
   - **Reverse-Sorted Array**: In the worst case, where the array is sorted in reverse, Insertion Sort performs the maximum number of comparisons and shifts.
   - **Complexity**: The time complexity in this scenario is \(O(N^2)\).

3. **Average-Case Scenario**:
   - **Random Array**: On average, for a randomly ordered array, Insertion Sort will require a quadratic number of comparisons and shifts.
   - **Complexity**: The average-case time complexity is \(O(N^2)\).

#### **Comparison with Bubble Sort and Selection Sort**

- **Best Case Efficiency**: Unlike Bubble Sort and Selection Sort, Insertion Sort can perform significantly better in its best case (sorted array). While both Bubble Sort and Selection Sort always have a worst-case time complexity of \(O(N^2)\), Insertion Sort can be \(O(N)\) in the best case.
  
- **Average Performance**: In practical scenarios where the array is partially sorted, Insertion Sort can be more efficient compared to Bubble Sort and Selection Sort due to its ability to take advantage of existing order.

- **Number of Comparisons and Swaps**: Insertion Sort performs fewer swaps compared to Bubble Sort because it only swaps elements when necessary to place the element in the correct position.

#### **Example**

![[Pasted image 20240819204328.png]]

#### **Visualizing Complexity**

| **N Elements** | **Best Case (O(N))** | **Worst Case (O(N²))** |
| -------------- | -------------------- | ---------------------- |
| 5              | 5                    | 15                     |
| 10             | 10                   | 55                     |
| 20             | 20                   | 190                    |
| 40             | 40                   | 780                    |
|                |                      |                        |

Insertion Sort is highly efficient for small datasets or arrays that are already partially sorted, making it a useful algorithm in specific situations despite its average and worst-case time complexities.

#### **Code Example in C++**

```cpp
#include <iostream>
#include <vector>

void insertionSort(std::vector<int>& arr) {
    int n = arr.size();
    for (int i = 1; i < n; ++i) {
        int key = arr[i];
        int j = i - 1;

        // Move elements of arr[0..i-1], that are greater than key, to one position ahead of their current position
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            --j;
        }
        arr[j + 1] = key;
    }
}

void printArray(const std::vector<int>& arr) {
    for (int num : arr) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> arr = {12, 11, 13, 5, 6};
    
    std::cout << "Original array: ";
    printArray(arr);
    
    insertionSort(arr);
    
    std::cout << "Sorted array: ";
    printArray(arr);
    
    return 0;
}
```

#### Explanation

1. **Function `insertionSort`**:
   - **Input**: A vector of integers (`std::vector<int>& arr`).
   - **Process**:
     - Starts from the second element (index 1) and compares it to the elements before it.
     - Moves elements that are greater than the current element (`key`) one position to the right.
     - Inserts the `key` into its correct position.
   - **Complexity**:
     - Best Case: $O(N)$ (when the array is already sorted).
     - Worst Case: $O(N^2)$ (when the array is sorted in reverse).

2. **Function `printArray`**:
   - **Input**: A constant reference to a vector of integers.
   - **Output**: Prints the elements of the vector to the console.

3. **`main` Function**:
   - Initializes an array.
   - Prints the original array.
   - Calls `insertionSort` to sort the array.
   - Prints the sorted array.

#### Example Output
For the input array `{12, 11, 13, 5, 6}`, the output will be:

```
Original array: 12 11 13 5 6 
Sorted array: 5 6 11 12 13 
```

This implementation of Insertion Sort is straightforward and efficiently handles small to moderately sized arrays, especially when the data is nearly sorted.

## Average Case: Selection Sort vs. Insertion Sort

![[Pasted image 20240819204612.png]]

#### **Selection Sort**

1. **Best Case**: 
   - **Complexity**: $O(N^2)$
   - **Description**: Selection Sort always performs $N-1$ comparisons in the first pass, $N-2$ in the second, and so on, regardless of the initial order of the array.
   - **Steps**: For an array of size $N$, the total number of comparisons is $\frac{N(N-1)}{2}$. Swaps are always $\frac{N-1}{2}$ in the worst case, but there's no optimization to stop early.

2. **Average Case**: 
   - **Complexity**: $O(N^2)$
   - **Description**: The average case performance is also $O(N^2)$ because the number of comparisons remains constant. The array's initial order doesn’t affect the number of comparisons.

3. **Worst Case**: 
   - **Complexity**: $O(N^2)$
   - **Description**: In the worst case, Selection Sort performs the same number of comparisons and swaps as in the best case.

#### **Insertion Sort**

1. **Best Case**: 
   - **Complexity**: $O(N)$
   - **Description**: When the array is already sorted, Insertion Sort performs only $N-1$ comparisons and no shifts. This is the most efficient scenario for Insertion Sort.

2. **Average Case**: 
   - **Complexity**: $O(N^2)$
   - **Description**: On average, each element is compared to half of the previously sorted elements. This results in approximately $\frac{N(N-1)}{4}$ comparisons and shifts.

3. **Worst Case**: 
   - **Complexity**: $O(N^2)$
   - **Description**: In the worst case, when the array is sorted in reverse order, Insertion Sort performs $N(N-1)/2$ comparisons and shifts.

#### **Comparison Table**

| Algorithm          | Best Case | Average Case | Worst Case |     |
| ------------------ | --------- | ------------ | ---------- | --- |
| **Selection Sort** | $O(N^2)$  | $O(N^2)$     | $O(N^2)$   |     |
| **Insertion Sort** | $O(N)$    | $O(N^2)$     | $O(N^2)$   |     |

![[Pasted image 20240819204630.png]]

#### **Choosing Between the Two**

- **Selection Sort** is predictable and straightforward, with consistent performance regardless of the initial order of the data. It performs the same number of comparisons in all scenarios.
- **Insertion Sort** can be more efficient if the data is already or nearly sorted. It performs fewer operations in the best case but can degrade to $O(N^2)$ in the worst case.

In practice:

- **For mostly sorted data**: Insertion Sort is often faster due to its better average-case and best-case performance.
- **For data with unknown initial order**: Both sorts will have similar performance, but Insertion Sort might be preferred for small to medium-sized arrays due to its adaptability.
- **For large arrays**: Consider more advanced algorithms like Merge Sort or Quick Sort, which have better average-case performance.

### Conclusion

The choice between Selection Sort and Insertion Sort depends on the characteristics of your data and the specific use case. For arrays that are frequently partially sorted, Insertion Sort might be preferable, while for cases where data order is unknown or if consistency is key, Selection Sort's predictable performance can be advantageous.

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

## **Abstract Data Types**

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

## **Top-Down Recursion:**

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

## Partitioning

### **Quicksort Overview**
Quicksort is a divide-and-conquer algorithm that sorts an array by partitioning it into two subarrays—elements less than a chosen pivot and elements greater than the pivot—then recursively sorting the subarrays.

### **Partitioning Process**
The core of Quicksort is its partitioning step, which rearranges elements in the array such that:
- All elements less than the pivot are to the left of it.
- All elements greater than the pivot are to the right.

### **Step-by-Step Partitioning Example**

Let's walk through the partitioning process step-by-step using the array `[0, 5, 2, 1, 6, 3]` with the pivot being `3`, the left pointer starting at `0`, and the right pointer starting at `6`.

### Initial Array:
![[Pasted image 20240819215451.png]]

- Pivot: `3`
- Left Pointer: `0` (initially points to the value `0`)
- Right Pointer: `6` (initially points to the value `6`)

### Step 1: Compare Left Pointer to Pivot
- Left Pointer is at `0` (value `0`), which is less than the pivot `3`.
- **Action**: Move the left pointer to the next position.

![[Pasted image 20240819215505.png]]

### Step 2: Move Left Pointer
- Left Pointer is now at `5`, which is greater than the pivot `3`.
- **Action**: Stop the left pointer and activate the right pointer.

### Step 3: Compare Right Pointer to Pivot
- Right Pointer is at `6`, which is greater than the pivot `3`.
- **Action**: Move the right pointer to the previous position.

### Step 4: Move Right Pointer
- Right Pointer is now at `1`, which is less than the pivot `3`.
- **Action**: Stop the right pointer.

![[Pasted image 20240819215540.png]]

### Step 5: Swap Left and Right Pointers
- Left Pointer is at `5`, and Right Pointer is at `1`.
- **Action**: Swap the values `5` and `1`.

![[Pasted image 20240819215620.png]]

### Step 6: Move Left Pointer
- Left Pointer moves to `2`, which is less than the pivot `3`.
- **Action**: Move the left pointer to the next position.

![[Pasted image 20240819215633.png]]

### Step 7: Move Left Pointer Again
- Left Pointer now moves to `5`, which is greater than the pivot `3`.
- Since the left pointer has reached the right pointer, we stop.

![[Pasted image 20240819215644.png]]

### Step 8: Swap Pivot with Left Pointer Value
- Swap the value `5` (where the left pointer is) with the pivot `3`.

![[Pasted image 20240819215703.png]]
### **C++ Implementation**

```cpp
#include <iostream>
#include <vector>

int partition(std::vector<int>& arr, int low, int high) {
    int pivot = arr[high];  // Pivot element is the last element
    int i = low - 1;        // Index of smaller element

    for (int j = low; j < high; j++) {
        // If the current element is smaller than the pivot
        if (arr[j] < pivot) {
            i++;  // Increment index of smaller element
            std::swap(arr[i], arr[j]);
        }
    }
    std::swap(arr[i + 1], arr[high]);  // Place pivot in the correct position
    return i + 1;
}

void quicksort(std::vector<int>& arr, int low, int high) {
    if (low < high) {
        // pi is the partitioning index, arr[pi] is now in the right place
        int pi = partition(arr, low, high);

        // Recursively sort elements before partition and after partition
        quicksort(arr, low, pi - 1);
        quicksort(arr, pi + 1, high);
    }
}

int main() {
    std::vector<int> arr = {10, 7, 8, 9, 1, 5};
    int n = arr.size();
    quicksort(arr, 0, n - 1);
    
    std::cout << "Sorted array: ";
    for (int x : arr) {
        std::cout << x << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

### **Explanation:**
- **`partition` Function:** 
  - Chooses the pivot and rearranges the array such that elements smaller than the pivot are on the left and elements larger are on the right.
  - It returns the index of the pivot after rearranging.

- **`quicksort` Function:** 
  - Recursively applies the `partition` function to sort the subarrays before and after the pivot.

### **Output:**
When you run the above code, it will output the sorted array:

```
Sorted array: 1 5 7 8 9 10
```

## Quicksort Algorithm

Quicksort is a widely used and efficient sorting algorithm based on the divide-and-conquer approach. The algorithm can be broken down into the following steps:

### 1. Partitioning
- **Choose a Pivot**: Select an element from the array to serve as the pivot. There are various strategies to select the pivot, such as choosing the first element, the last element, or the median.
- **Rearrange Elements**: Reorder the array such that all elements less than the pivot come before it, and all elements greater than the pivot come after it. The pivot element is now in its correct final position in the sorted array.

### 2. Recursion
- **Divide and Conquer**: Treat the subarrays on either side of the pivot as independent arrays and recursively apply the quicksort algorithm to these subarrays.
  - The left subarray contains elements less than the pivot.
  - The right subarray contains elements greater than the pivot.
- **Recursive Process**: Continue partitioning and sorting smaller and smaller subarrays until you reach subarrays that contain zero or one element. These subarrays are already sorted by definition.

### 3. Base Case
- **Stop Recursion**: When a subarray contains zero or one element, it is inherently sorted, and no further partitioning or recursion is necessary.

### Example
Let's say we have the following array: `[3, 6, 8, 10, 1, 2, 1]`

1. **Initial Array**: `[3, 6, 8, 10, 1, 2, 1]`
   - Choose a pivot (e.g., 1).
   - Partition around the pivot: `[1, 1, 2, 3, 6, 8, 10]`

2. **Recursively Apply Quicksort**:
   - Left subarray: `[1, 1]` (already sorted)
   - Right subarray: `[3, 6, 8, 10]`
   - Choose a pivot for the right subarray (e.g., 6), partition it into `[3, 6, 8, 10]`.

3. **Base Case**:
   - Left subarray: `[3]` (sorted)
   - Right subarray: `[8, 10]` (sorted)

4. **Final Sorted Array**: `[1, 1, 2, 3, 6, 8, 10]`

Quicksort has an average-case time complexity of $O(n \log n)$, making it efficient for large datasets. However, in the worst case (when the smallest or largest element is always chosen as the pivot), the time complexity can degrade to $O(n^2)$. This is why pivot selection strategies, like choosing a random pivot or using the "median of three," are often employed to mitigate the risk of worst-case performance.

## Big O Notation for Quicksort

Quicksort is a highly efficient sorting algorithm, and its efficiency is generally expressed in terms of Big O notation as $O(N \log N)$. This notation describes how the time required to sort an array grows as the size of the array ($N$) increases.

### Why $O(N \log N)$?

Let's break down why Quicksort has an average-case time complexity of $O(N \log N)$:

#### 1. **Partitioning**: 
- Each time you partition the array, you're dividing it into two subarrays around a pivot.
- In the average case, the pivot tends to end up near the middle, so each partitioning step roughly halves the array.
- Partitioning the entire array (which is $N$ elements) takes $O(N)$ time.

#### 2. **Logarithmic Depth**:
- If you keep dividing the array into halves, the number of times you can do this before reaching subarrays of size 1 is $\log N$. 
- This is because $\log N$ represents the number of times you can halve a number before it reaches 1.

#### 3. **Total Work Done**:
- At each level of recursion (i.e., each halving step), you perform a partition operation on all subarrays that together make up the original array.
- Since the partitioning takes $O(N)$ time and there are $\log N$ levels of recursion, the total work done is $N$ multiplied by $\log N$, giving us $O(N \log N)$.

### Summary:
- **Best Case**: When the pivot always splits the array into two nearly equal halves, the time complexity is $O(N \log N)$.
- **Average Case**: In typical scenarios where the pivot is near the middle most of the time, the time complexity is also $O(N \log N)$.
- **Worst Case**: If the pivot is always the smallest or largest element (leading to highly unbalanced partitions), the time complexity can degrade to $O(N^2)$.

### Visualization:

Here's a simplified illustration:

- **Original Array**: $N = 8$
- **First Partition**: Two subarrays of size 4 → $\log N = 3$ (3 halvings)
- **Second Partition**: Two subarrays of size 2 each
- **Third Partition**: Two subarrays of size 1 each

At each level, you're working with $N$ elements, and there are $\log N$ levels of partitioning.

### Approximation vs. Reality

While $O(N \log N)$ is a good approximation, there are nuances:

1. **Initial Partition**: The first partition of the original array also takes $O(N)$ time.
2. **Imperfect Splits**: In practice, the pivot doesn't always split the array perfectly in half, but this doesn't drastically change the overall time complexity.

This is why Quicksort is generally categorized as $O(N \log N)$ for average and best-case scenarios.

## Quickselect Algorithm Overview

Quickselect is an efficient algorithm used to find the $k$th smallest (or largest) element in an unsorted array. Unlike sorting the entire array, which takes $O(N \log N)$ time, Quickselect focuses on finding just the $k$th smallest element and does so in $O(N)$ average time.

### How Quickselect Works

Quickselect is closely related to Quicksort and uses partitioning to narrow down the search for the desired element:

1. **Partition the Array**: Just like in Quicksort, select a pivot and partition the array such that elements less than the pivot are on one side, and elements greater than the pivot are on the other side. The pivot ends up in its correct position in the sorted array.

2. **Determine the Position of the Pivot**:
   - If the pivot's position is exactly $k-1$, then the pivot is the $k$th smallest element, and you are done.
   - If the pivot's position is greater than $k-1$, the $k$th smallest element must be in the left subarray (elements less than the pivot).
   - If the pivot's position is less than $k-1$, the $k$th smallest element must be in the right subarray (elements greater than the pivot).

3. **Recursively Apply Quickselect**: Focus on the relevant subarray (either left or right) and apply Quickselect again. This process continues until the pivot's position matches $k-1$.

### Example

Let's say you want to find the 2nd smallest element in the array `[7, 10, 4, 3, 20, 15]`.

1. **Initial Array**: `[7, 10, 4, 3, 20, 15]`
   - Choose a pivot (e.g., `15`).
   - Partition around `15`: `[7, 10, 4, 3, 15, 20]`.
   - The pivot `15` ends up in position 4.

2. **Check Pivot Position**:
   - We want the 2nd smallest element, so we need to look in the left subarray `[7, 10, 4, 3]`.

3. **Reapply Quickselect**:
   - Choose a new pivot (e.g., `4`).
   - Partition around `4`: `[3, 4, 7, 10]`.
   - The pivot `4` is now in position 1.

4. **Result**:
   - Since position 1 matches $k-1 = 1$, `4` is the 2nd smallest element.

### Efficiency of Quickselect

The efficiency of Quickselect is $O(N)$ on average. Here's why:

- **First Partition**: The initial partitioning step takes $O(N)$ time.
- **Subsequent Partitions**: Each subsequent partition is performed on a smaller subarray. For an array of $N$ elements, the work done is approximately:

$$N + \frac{N}{2} + \frac{N}{4} + \frac{N}{8} + \ldots + 1$$

This series sums to about $2N$, leading to an overall time complexity of $O(N)$.

### Summary

- **Average Case Time Complexity**: $O(N)$.
- **Worst Case Time Complexity**: $O(N^2)$ (if the pivot selection is consistently poor, such as always picking the smallest or largest element).
- **Best Case Time Complexity**: $O(N)$ (if the pivot consistently divides the array into equal halves).

Quickselect is particularly useful when you need to find a specific order statistic (like the median) without fully sorting the array, making it more efficient than sorting-based methods for such tasks.

### C++ Code Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>  // For std::swap

int partition(std::vector<int>& arr, int left, int right) {
    int pivot = arr[right];
    int i = left - 1;

    for (int j = left; j < right; ++j) {
        if (arr[j] <= pivot) {
            ++i;
            std::swap(arr[i], arr[j]);
        }
    }
    std::swap(arr[i + 1], arr[right]);
    return i + 1;
}

int quickselect(std::vector<int>& arr, int left, int right, int k) {
    if (left == right) {
        return arr[left];
    }

    int pivotIndex = partition(arr, left, right);

    if (pivotIndex == k) {
        return arr[pivotIndex];
    } else if (pivotIndex > k) {
        return quickselect(arr, left, pivotIndex - 1, k);
    } else {
        return quickselect(arr, pivotIndex + 1, right, k);
    }
}

int main() {
    std::vector<int> arr = {7, 10, 4, 3, 20, 15};
    int k = 2;  // Find the 2nd smallest element

    int result = quickselect(arr, 0, arr.size() - 1, k - 1);  // k - 1 because of zero-based index
    std::cout << "The " << k << "th smallest element is " << result << std::endl;

    return 0;
}
```

### How It Works:

1. **Partition Function**:
   - The `partition` function is similar to the one used in Quicksort. It chooses the last element as the pivot, partitions the array around it, and returns the pivot's final position.

2. **Quickselect Function**:
   - This function recursively selects the part of the array to search in based on the pivot's position relative to the desired $k$th smallest element.
   - It keeps partitioning until it finds the pivot in the $k$th position.

3. **Main Function**:
   - In the `main` function, the array and the desired order statistic (e.g., 2nd smallest element) are defined.
   - The `quickselect` function is called, and the result is printed.

### Output:

```
The 2nd smallest element is 4
```

This implementation is efficient and works well for finding the $k$th smallest element in an unsorted array.

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

## Insertion in a Binary Search Tree (BST):

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

## Deletion in a Binary Search Tree:

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

## Priority Queues

A **priority queue** is a specialized type of queue in which each element is assigned a priority, and elements with higher priorities are served before those with lower priorities, regardless of the order in which they were added. This makes priority queues essential for scenarios like task scheduling, where tasks must be executed based on their urgency or importance.

#### Key Characteristics of a Priority Queue:
- **Access and Deletion**: Just like a classic queue, elements are removed from the front.
- **Insertion**: Unlike a classic queue, where elements are added to the end, in a priority queue, elements are inserted in a way that maintains a specific order, usually based on their priority.

#### Example: Hospital Triage System
Imagine a hospital emergency room where patients are treated based on the severity of their condition:
- Patients are assigned a priority from 1 to 10, with 10 being the most critical.
	![[Pasted image 20240820095048.png]]
- When a patient arrives, they are placed in the queue according to their severity.
	![[Pasted image 20240820095056.png]]
- The patient with the highest priority is always treated first, regardless of when they arrived.

For example:
- **Patient C** with a priority of 10 is at the front of the queue.
- If **Patient E** arrives with a priority of 3, they are placed in the queue after all patients with higher priorities but before those with lower ones.

#### Implementing a Priority Queue Using an Ordered Array:
One way to implement a priority queue is by using an ordered array:
- **Insertion**: When a new element is added, it is inserted in such a way that the array remains sorted by priority. This takes $O(N)$ time because we might need to shift elements to make room for the new one.
- **Deletion**: The highest-priority element is always at the end of the array, so deletion is $O(1)$, which is very efficient.

However, while deletion in this approach is optimal, the insertion operation can be costly due to the need to maintain order.

#### Efficiency Considerations:
- **Deletions**: $O(1)$ because the highest-priority element is at the end of the array, so no shifting is required.
- **Insertions**: $O(N)$ because we may need to inspect and shift elements to maintain the correct order, especially in large arrays.

#### The Need for Heaps:
Because of the inefficiency in insertions using an ordered array, computer scientists developed another data structure called the **heap** to implement priority queues more efficiently. A heap allows both insertion and deletion to be performed in $O(\log N)$ time, making it a better foundation for priority queues, especially when dealing with a large number of elements.

In summary, while an array-based priority queue is simple to implement, its $O(N)$ insertion time can become a bottleneck. This is why heaps are often used as the underlying data structure for priority queues, providing a more balanced and efficient solution.

## Binary Heaps

A **binary heap** is a specialized tree-based data structure that satisfies two key properties: the **heap condition** and the **completeness** of the tree. Heaps are primarily used to implement priority queues, and they come in two main types: **max-heaps** and **min-heaps**. We'll focus on **max-heaps** in this explanation, but the concepts apply similarly to min-heaps with a simple reversal of the heap condition.

#### Key Properties of a Binary Heap:

1. **Heap Condition**:
   - In a **max-heap**, each node's value is greater than or equal to the values of its children. This means the largest value is always at the root of the tree.
   - In a **min-heap**, each node's value is less than or equal to the values of its children, so the smallest value is at the root.

2. **Completeness**:
   - The binary tree must be **complete**, meaning all levels of the tree are fully filled except possibly the last level, which is filled from left to right.

#### Example of a Max-Heap:

![[Pasted image 20240820095225.png]]

- **Heap Condition**: Every parent node is greater than its children. This satisfies the max-heap condition.

#### Example of a Non-Heap:

![[Pasted image 20240820095243.png]]

- Here, **92** is greater than its parent node **88**, violating the max-heap condition.

#### Difference from a Binary Search Tree (BST):

- In a **BST**, the left child is always less than the parent, and the right child is greater. The values in a BST are arranged to facilitate fast searches.
- In contrast, a **heap** does not have this left-right ordering. Instead, it focuses on maintaining the heap condition where no descendant is greater (in a max-heap) or smaller (in a min-heap) than its parent.

#### Why Use Heaps?

Heaps are primarily used in scenarios where you need quick access to the largest (or smallest) element. This makes them ideal for implementing priority queues, where you often need to repeatedly access and remove the highest-priority element (the largest in a max-heap).

In summary, a **binary heap** is a complete binary tree that maintains a strict order between parent and child nodes, ensuring the root always holds the maximum or minimum value, depending on the type of heap. This structure is particularly efficient for operations like finding the maximum or minimum element, which can be done in constant time $O(1)$, with insertions and deletions typically taking $O(\log N)$.

## Complete Trees

#### What is a Complete Tree?

A **complete tree** is a binary tree in which every level is fully filled except possibly the last level. If the last level is not fully filled, the nodes must be filled from left to right, with no gaps in between.

#### Examples of Complete Trees

1. **Fully Filled Tree**:
	![[Pasted image 20240820095426.png]]
   - **Explanation**: All levels are fully filled. This is a complete tree because there are no missing nodes at any level.

2. **Incomplete Tree (Not Complete)**:
	![[Pasted image 20240820095440.png]]
   - **Explanation**: The third level has a missing node on the left side, making it incomplete. A complete tree would not have gaps like this within a level.

3. **Complete Tree with Gaps on the Bottom Row**:
	![[Pasted image 20240820095514.png]]
   - **Explanation**: This tree is considered complete because the only gaps are on the bottom row, and they are to the right. There are no nodes to the right of these gaps, which satisfies the complete tree condition.

#### The Importance of Completeness in Heaps

In the context of heaps, the **completeness** of the tree is essential because it ensures that the heap can be efficiently represented using an array. In a complete tree, if you traverse the tree level by level from left to right, the nodes can be stored sequentially in an array. This property is what allows heaps to perform insertions, deletions, and access operations efficiently.

- **Example of a Valid Heap**:
	![[Pasted image 20240820095531.png]]
   - **Explanation**: This tree is complete and satisfies the heap condition (in this case, it's a max-heap). All nodes on the last level are as far left as possible, and no nodes are to the right of any gaps.

In summary, a **complete tree** is one where all levels are fully populated except possibly the last, and if the last level has missing nodes, they must be on the far right. This structure is critical for heaps because it ensures the heap can maintain its properties while enabling efficient operations.

## Properties of Heaps

Heaps are fascinating data structures that are particularly useful in scenarios where we need to repeatedly access the highest (or lowest) priority element, such as in priority queues

#### 1. **Weak Ordering**

- **Definition**: Heaps are considered to be *weakly ordered* as compared to structures like binary search trees. This means that while the heap condition ensures that each node is greater than (or smaller than, in the case of min-heaps) its descendants, there isn't enough ordering information to efficiently search for a specific value.
  
  - **Example**: If you need to find the value 3 in a max-heap where the root is 100, you know that 3 must be somewhere among the descendants of 100, but you don't know exactly where. In a binary search tree, you could immediately narrow down the search to either the left or right subtree based on the value, but in a heap, you might need to search through many nodes to find the value.

#### 2. **Root Node Property**

- **Definition**: In a max-heap, the **root node** (the top node of the heap) will always have the greatest value among all nodes in the heap. Conversely, in a min-heap, the root will always have the smallest value.

  - **Example**: In a max-heap with the root node valued at 100, no other node in the heap will have a value greater than 100. This property is what makes heaps particularly suitable for implementing priority queues, where you need to efficiently access the highest-priority element.

#### 3. **Efficiency of Primary Operations**

- **Insertion and Deletion**: Heaps are designed to efficiently support two primary operations:
  
  - **Insertion**: When you insert a new element into a heap, it is initially placed at the end (as the new last node). Then, it is "bubbled up" or "heapified" to maintain the heap property.
  
  - **Deletion**: Typically, the element that is deleted is the root (since it represents the highest or lowest priority). After deletion, the last node is moved to the root, and then it is "bubbled down" or "heapified" to maintain the heap property.

  - **Optional "Read" Operation**: This operation simply returns the value of the root node, providing a quick way to access the highest priority element in a priority queue without altering the heap.

#### 4. **The Last Node**

- **Definition**: The last node in a heap is the rightmost node at the bottom level of the tree. Understanding the position of the last node is crucial when performing insertions or deletions because these operations often involve swapping with or placing the last node.
  
  - **Example**: In the following max-heap:
	![[Pasted image 20240820095731.png]]
    The last node is the node with value 3.

## Heap Insertion Process

The process of inserting a new value into a heap involves maintaining the heap's properties—specifically, the heap condition and the completeness of the tree.

#### **Step 1: Insert the New Node**

- **Create a New Node**: First, create a node containing the new value. This node is then inserted at the next available rightmost spot in the bottom level of the tree. This ensures that the tree remains complete.
  
  - **Example**: If you were to insert the value `40` into a heap, the first available spot is as the right child of the node containing `8`.
	![[Pasted image 20240820095802.png]]
	- Note that doing the following would have been incorrect:
	![[Pasted image 20240820095832.png]]

#### **Step 2: Compare with Parent Node**

- **Heap Condition Check**: After placing the new node, compare its value with that of its parent node.
  
  - **Example**: The parent node of `40` is `8`. Since `40 > 8`, this violates the max-heap condition (where parents must be greater than or equal to their children).

#### **Step 3: Swap Nodes if Necessary**

- **Swap Values**: If the new node's value is greater than its parent's, swap the two nodes to maintain the heap property.
  
  - **Example**: Swap `40` with `8`, making `40` the new parent and `8` the child.
	![[Pasted image 20240820095841.png]]
  

#### **Step 4: Repeat the Process**

- **Move Up the Heap**: Continue comparing the new node with its new parent after each swap. Repeat the swap process until the node is in a position where its parent is greater than or equal to its value, maintaining the heap condition.

	![[Pasted image 20240820095928.png]]

  - **Example**: Compare `40` (now in the position of `25`). Since `40 > 25`, swap them. Finally, compare `40` with `100`, but since `100 > 40`, the process stops.

This process is known as **"trickling up"** the node through the heap.

### Efficiency of Insertion

- **Complexity**: The insertion operation in a heap has a time complexity of $O(\log N)$. This is because the maximum number of levels the new value might have to move up through is proportional to the height of the tree, which is $\log(N)$ for a complete binary tree.

### The Problem of the Last Node

While the insertion algorithm works well, it raises the question of how to find the correct spot for the new last node in an efficient manner:

#### **Finding the Last Node**

- **The Challenge**: To insert a new node, we need to find the rightmost spot in the bottom level of the heap. For a computer, which cannot visually inspect the tree, this is non-trivial. The computer only knows the structure of the heap via the root node and can only follow links to child nodes.

- **Example of the Challenge**: In one heap, the next spot might be the right child of a node on the right side of the tree. In another, it might be on the left. The specific structure of the heap determines where the last node's spot will be, but without inspecting every node, it's difficult to pinpoint this position efficiently.
	![[Pasted image 20240820100105.png]]

## Heap Deletion Process

Deleting a value from a heap involves removing the root node, which holds the maximum value in a max-heap (or the minimum value in a min-heap). The process ensures that the heap properties are maintained after the deletion. Here’s how it works:

#### **Step 1: Replace the Root Node**

- **Move the Last Node**: Start by moving the last node in the heap (the rightmost node in the bottom level) into the root's position. This effectively removes the original root node.
  
  - **Example**: If the root node is `100` and the last node is `3`, you move `3` to the root position.
	![[Pasted image 20240820100259.png]]
	![[Pasted image 20240820100309.png]]

#### **Step 2: Trickle Down the New Root Node**

- **Restore the Heap Condition**: After replacing the root with the last node, the heap condition is likely violated (since the new root might be smaller than its children). The next step is to trickle the new root node down the heap until the heap condition is restored.
	![[Pasted image 20240820100502.png]]
  
  - **Compare Children**: At each step, compare the trickle node (the new root) with its two children.
  - **Swap with Larger Child**: If the trickle node is smaller than the larger of its two children, swap it with that child.

- **Repeat**: Continue trickling the node down until it reaches a position where it is greater than or equal to both its children or becomes a leaf node.

  - **Example**: 
    - Start with `3` as the new root. Compare it with its children `88` and `25`.
    - Since `88` is larger, swap `3` with `88`.
	    ![[Pasted image 20240820100331.png]]
    - Now, compare `3` with its new children `87` and `16`. Swap `3` with `87`.
		![[Pasted image 20240820100344.png]]
    - Finally, compare `3` with its children `86` and `50`. Swap `3` with `86`.
	    ![[Pasted image 20240820100353.png]]
    - At this point, `3` has no children, so the trickling down stops.

### Why Swap with the Larger Child?

Swapping with the larger of the two children is crucial because it prevents the heap condition from being violated immediately. If you were to swap with the smaller child, the larger child could end up being greater than its new parent, breaking the heap condition.

#### **Example of Incorrect Swap**

- If `3` (as the root) were swapped with `25` (the smaller child), `88` (the larger child) would end up as a descendant of `25`, violating the heap condition since `88` is greater than `25`.

### Efficiency of Deletion

- **Complexity**: The deletion operation in a heap has a time complexity of $O(\log N)$ because the trickling down process might require moving the node down through all levels of the heap, and the height of the heap is $\log(N)$.

### Summary

Heap deletion involves removing the root node by replacing it with the last node and then restoring the heap condition by trickling the new root down the tree. The key to maintaining the heap property is always to swap the trickle node with the larger of its two children until it reaches its correct position.

## Heaps vs. Ordered Arrays in Priority Queues

When implementing a priority queue, choosing the right data structure is crucial for performance. Heaps and ordered arrays are both options, but they differ significantly in their efficiency for insertion and deletion operations.

#### **Comparison Table**

| Operation | Ordered Array | Heap        |
| --------- | ------------- | ----------- |
| Insertion | $O(N)$        | $O(\log N)$ |
| Deletion  | $O(1)$        | $O(\log N)$ |
|           |               |             |

#### **Analysis**

- **Ordered Arrays**:
  - **Insertion**: Inserting into an ordered array requires finding the correct position to maintain order, which takes $O(N)$ time because it may require shifting elements to make space.
  - **Deletion**: Deleting the highest-priority item (typically at the end of the array) is $O(1)$, as it involves simply removing the last element.

- **Heaps**:
  - **Insertion**: In a heap, inserting a new element requires placing it in the correct position, which involves "trickling up" to maintain the heap property. This operation takes $O(\log N)$ time.
  - **Deletion**: Deleting the root (highest-priority element) in a heap involves replacing it with the last element and "trickling down" to restore the heap property. This also takes $O(\log N)$ time.

#### **Why Heaps Are Preferred**

- **Balanced Performance**: Although an ordered array offers $O(1)$ deletion, it has $O(N)$ insertion, which can be prohibitively slow, especially as the size of the array grows. In contrast, a heap provides consistently fast performance for both insertion and deletion with $O(\log N)$ for each operation.

- **Consistency**: Priority queues typically require frequent insertions and deletions. If either operation is slow, it could bottleneck the entire system. Heaps ensure that both operations are handled efficiently, making them the preferred choice for implementing priority queues.

#### **Real-World Example**

Consider an emergency room where patients are treated based on the severity of their condition (priority). If the system uses an ordered array, each new patient (insertion) might cause delays due to the need to reorder the list. However, if a heap is used, both admitting a new patient and treating the most critical one can be done quickly, ensuring smooth and efficient operation.

### Summary

Heaps are generally the better choice for priority queues because they offer a good balance of efficiency for both insertion and deletion, ensuring that the system remains consistently fast, even as the number of elements increases.

## The Problem of the Last Node: Why It Matters and How to Solve It

The "Problem of the Last Node" is a critical issue when working with heaps, particularly for insertion and deletion operations. This problem boils down to the challenge of efficiently locating the last node of the heap, which is crucial for maintaining the heap's balance and ensuring that operations remain efficient.

#### **Why Is the Last Node So Important?**

1. **Maintaining Completeness**:  
   Heaps must be complete binary trees, meaning all levels of the tree are fully filled, except possibly for the last level, which is filled from left to right. Completeness is key to ensuring the heap remains balanced.

2. **Ensuring Balance**:  
   A balanced heap guarantees that the height of the tree (and thus the time complexity of operations) remains $O(\log N)$. If we insert or delete nodes incorrectly, the heap can become imbalanced, leading to degraded performance, potentially as bad as $O(N)$.

#### **The Role of the Last Node in Operations**

- **Insertion**:  
  When inserting a new node, it must be added to the next available position in the bottom level to keep the heap complete. This position is determined by finding the last node and placing the new node as its rightmost sibling or as its child.

- **Deletion**:  
  During deletion, the last node is moved to the root to replace the deleted node. This approach ensures that the heap remains complete after the deletion process.

#### **Why Not Use Other Nodes?**

If we were to choose a node other than the last node for insertion or deletion, the heap could become imbalanced. For example:

- **Inserting Elsewhere**:  
  If a new node were inserted at a position other than the next available spot, the tree might end up skewed to one side, violating the heap's completeness and leading to inefficient operations.

- **Replacing the Root with a Different Node**:  
  If, during deletion, we replaced the root with a node other than the last node, the resulting tree could have empty spots in the middle levels, again leading to imbalance.

#### **The Search for the Last Node**

Given the importance of the last node, we need an efficient way to find it without traversing the entire heap. This is where the structure of the heap gives us an advantage.

#### **The Twist: Using Array Representation of Heaps**

Heaps are often represented as arrays due to their completeness property. In an array:

- The root is at index 1 (or 0, depending on indexing).
- For any node at index $i$:
  - The left child is at index $2i$
  - The right child is at index $2i + 1$
  - The parent is at index $\left\lfloor \frac{i}{2} \right\rfloor$

![[Pasted image 20240820101000.png]]

**Finding the Last Node**:  
- The last node in a heap can be found at the last index of the array representing the heap. If the array has $N$ elements, the last node is at index $N$ (or $N-1$ if 0-indexed).

**Inserting and Deleting with Array Heaps**:  
- **Insertion**: Add the new node at the end of the array, then "trickle up" to maintain the heap property.
- **Deletion**: Replace the root with the last element in the array, then "trickle down" to restore the heap property.

This approach ensures that insertion and deletion both occur in $O(\log N)$ time, as the operations involve moving up or down the tree's height, not traversing the entire structure.

## Traversing an Array-Based Heap

In a heap implemented using an array, traversing between nodes is not as straightforward as following pointers in a linked structure. Instead, we use mathematical formulas to determine the parent and child relationships based on the node's index in the array.

#### Formulas for Traversal

1. **Left Child**: For a node at index `i`, the left child is located at index $(2 \times i) + 1$.
2. **Right Child**: For a node at index `i`, the right child is located at index $(2 \times i) + 2$.
3. **Parent**: For a node at index `i`, the parent is located at index $\frac{(i - 1)}{2}$ (using integer division).

These formulas allow you to navigate the heap structure within an array, treating the array as if it were a tree.

## C++ Implementation of Max Heap

```cpp
#include <iostream>
#include <vector>
#include <stdexcept>

class MaxHeap {
private:
    std::vector<int> data;

    int leftChildIndex(int index) const {
        return (index * 2) + 1;
    }

    int rightChildIndex(int index) const {
        return (index * 2) + 2;
    }

    int parentIndex(int index) const {
        return (index - 1) / 2;
    }

    void heapifyUp(int index) {
        if (index == 0) return;  // The root node has no parent

        int parentIdx = parentIndex(index);
        if (data[index] > data[parentIdx]) {
            std::swap(data[index], data[parentIdx]);
            heapifyUp(parentIdx);
        }
    }

    void heapifyDown(int index) {
        int leftChildIdx = leftChildIndex(index);
        int rightChildIdx = rightChildIndex(index);
        int largest = index;

        if (leftChildIdx < data.size() && data[leftChildIdx] > data[largest]) {
            largest = leftChildIdx;
        }
        if (rightChildIdx < data.size() && data[rightChildIdx] > data[largest]) {
            largest = rightChildIdx;
        }
        if (largest != index) {
            std::swap(data[index], data[largest]);
            heapifyDown(largest);
        }
    }

public:
    MaxHeap() {}

    void insert(int value) {
        data.push_back(value);
        heapifyUp(data.size() - 1);
    }

    void deleteRoot() {
        if (data.empty()) {
            throw std::out_of_range("Heap is empty. Cannot delete root.");
        }

        data[0] = data.back();  // Move the last element to the root
        data.pop_back();        // Remove the last element
        heapifyDown(0);         // Restore the heap property
    }

    int extractMax() {
        if (data.empty()) {
            throw std::out_of_range("Heap is empty. Cannot extract maximum.");
        }

        int maxValue = data[0];
        deleteRoot();
        return maxValue;
    }

    void printHeap() const {
        for (int i : data) {
            std::cout << i << " ";
        }
        std::cout << std::endl;
    }

    bool isEmpty() const {
        return data.empty();
    }
};

int main() {
    MaxHeap heap;

    heap.insert(10);
    heap.insert(5);
    heap.insert(20);
    heap.insert(15);
    heap.insert(30);
    heap.insert(25);

    std::cout << "Heap after insertions: ";
    heap.printHeap();

    std::cout << "Extracted max: " << heap.extractMax() << std::endl;
    std::cout << "Heap after extracting max: ";
    heap.printHeap();

    heap.deleteRoot();
    std::cout << "Heap after deleting root: ";
    heap.printHeap();

    return 0;
}
```

#### Explanation of Code

1. **Heap Insertion (`insert`)**:
   - When inserting a new value, the value is first added to the end of the array.
   - The `heapifyUp` function is then called to restore the heap property by comparing the new value with its parent and swapping them if necessary. This process continues until the heap property is restored.

2. **Heap Deletion (`deleteRoot`)**:
   - To delete the root (which is the maximum value in a max heap), the last element of the heap is moved to the root.
   - The `heapifyDown` function is called to restore the heap property by comparing the new root with its children and swapping it with the larger child if necessary. This process continues down the heap until the heap property is restored.

3. **Extract Max (`extractMax`)**:
   - This function removes and returns the maximum element from the heap. It first retrieves the maximum value (the root), then deletes the root using the `deleteRoot` function, and finally returns the maximum value.

4. **Utility Functions**:
   - `leftChildIndex`, `rightChildIndex`, and `parentIndex` are helper functions to calculate the indices of the left child, right child, and parent nodes, respectively.

5. **Heap Printing (`printHeap`)**:
   - This function prints out the current state of the heap in a linear array form.

#### Output Example

Running the above code will produce an output similar to the following:

```
Heap after insertions: 30 15 25 5 10 20 
Extracted max: 30
Heap after extracting max: 25 15 20 5 10 
Heap after deleting root: 20 15 10 5 
```

#### Key Takeaways

- The `insert` and `deleteRoot` functions ensure that the heap maintains its max-heap property after each operation.
- The heap operations are efficient, with `insert` and `deleteRoot` both having a time complexity of $O(\log N)$, where $N$ is the number of elements in the heap.


## Tries

A **Trie** (pronounced "try") is a special type of tree used to store a dynamic set or associative array where the keys are usually strings. It is particularly well-suited for tasks involving strings, such as autocomplete, spell-checking, and prefix matching. The name "trie" comes from the word "retrieval."

![[Pasted image 20240820192554.png]]

### Structure of a Trie
- **Nodes**: Each node in a Trie represents a single character of a string.
- **Children**: Each node can have multiple children, each representing the next character in the sequence.
- **Root Node**: The Trie has a root node, which is typically empty or associated with a special character. All words in the Trie are represented by paths originating from the root.
- **End of Word**: A special marker or flag (e.g., `*`, `isEndOfWord`, `null`, etc.) is used in nodes to indicate that the path from the root to this node corresponds to a complete word.

### How a Trie Works

1. **Insertion**:
   - Starting from the root, for each character in the word, check if a child node for that character exists.
   - If it doesn't exist, create a new node for that character.
   - Move to the child node and repeat for the next character.
   - After inserting all characters, mark the last node as the end of a word.

2. **Search**:
   - Start from the root and follow the nodes corresponding to each character in the word.
   - If at any point a character's node doesn't exist, the word is not in the Trie.
   - If all characters are found and the last node is marked as the end of a word, the word exists in the Trie.

3. **Prefix Matching**:
   - Similar to searching for a word, but you only need to check if the sequence of nodes for the prefix exists. You don't need to check for the end of a word.

### Example
Imagine inserting the words “ace,” “act,” “bad,” “bake,” “bat,” “batter,” “cab,” “cat,” “catnap,” and “catnip”:

![[Pasted image 20240820192529.png]]

## Trie Search

Searching in a Trie for a prefix or a complete word follows a straightforward process.
#### Algorithm Steps

1. **Initialize**: Start by setting a `currentNode` to the root of the Trie.
2. **Iterate Over Characters**: For each character in the search string:
    - Check if `currentNode` has a child corresponding to the current character.
    - If it doesn't, the string (as a word or prefix) is not in the Trie, and you return `false`.
    - If it does, move `currentNode` to this child node.
	    - **Example**: Searching for the word "cat".
			![[Pasted image 20240820192756.png]]
			![[Pasted image 20240820192813.png]]
			![[Pasted image 20240820193030.png]]
3. **End of String**: If you've checked every character in the string, it means the string exists in the Trie as a prefix. If you were looking for a complete word, you would additionally check if the last node is marked as an `isEndOfWord` (`*` in the example).
	![[Pasted image 20240820193040.png]]

### Efficiency of Trie Search

Trie search is known for its efficiency, especially when dealing with text-based operations like autocompletion, dictionary lookups, and prefix searches.

1. **Character-by-Character Search**:
   - In a trie, the search operation focuses on each character of the search string individually.
   - For each character, the algorithm checks if there's a corresponding child node in the current node's hash table.
   - Hash table lookups are extremely efficient, typically taking $O(1)$ time, meaning that checking for the presence of a character as a child node is very fast.

2. **Big O Notation**:
   - The time complexity of a trie search is expressed as $O(K)$, where $K$ is the number of characters in the search string.
   - Unlike $O(N)$, where $N$ would refer to the total number of nodes in the trie, $O(K)$ focuses only on the length of the input string, not the size of the entire data structure.
   - This makes trie search independent of the size of the trie itself. Whether the trie contains thousands of words or just a few, searching for a word with $K$ characters will take $K$ steps.

3. **Comparison with Binary Search**:
   - Binary search has a time complexity of $O(\log N)$, where $N$ is the number of elements in a sorted array.
   - While $O(\log N)$ is efficient, trie search can be faster in cases where the search string is relatively short. For example, searching for the word "cat" in a trie takes just three steps ($O(3)$), whereas binary search would take more steps depending on the size of the dataset.

4. **Scalability**:
   - Trie search efficiency doesn't degrade as the trie grows. The number of nodes or words in the trie doesn't impact the search speed for a specific string.
   - The only factor influencing the speed is the length of the search string itself. This property makes trie search extremely scalable and reliable for large datasets.

## Trie Insertion

Inserting a word into a trie follows a process similar to searching for a word, but with additional steps to create new nodes if necessary.

#### Steps for Inserting a Word into a Trie

1. **Initialize `currentNode`**:
   - Start by setting a variable `currentNode` to the root node of the trie.
   - This `currentNode` will traverse the trie as we go through each character of the word we're inserting.

2. **Iterate Over Each Character**:
   - For each character in the word, perform the following steps:

3. **Check for the Character's Child Node**:
   - Look at the `currentNode`'s children to see if there is already a node corresponding to the current character.
   
4. **If the Child Node Exists**:
   - If the `currentNode` has a child node for the current character, update `currentNode` to point to that child node.
   - Move on to the next character in the word.

5. **If the Child Node Doesn't Exist**:
   - If the `currentNode` does not have a child node for the current character:
     - Create a new node for this character.
     - Add this new node as a child of the `currentNode`.
     - Update `currentNode` to this new node.
   - Continue to the next character in the word.

6. **Mark the End of the Word**:
   - After processing all characters of the word, add a special node (often represented by a `*`) to the current node to signify the end of the word.
   - This `*` node indicates that a complete word ends at this point in the trie.

#### Example: Inserting the Word "can"

Let’s walk through the process of inserting the word "can" into a trie:

1. **Setup**:
   - Start with `currentNode` at the root of the trie.
   - Point to the first character of "can", which is "c".

![[Pasted image 20240820193454.png]]

2. **Step 1: Insert "c"**:
   - The root node has a child node for "c", so update `currentNode` to this "c" node.
   - Move to the next character, "a".

![[Pasted image 20240820193503.png]]

3. **Step 2: Insert "a"**:
   - The "c" node has a child node for "a", so update `currentNode` to this "a" node.
   - Move to the next character, "n".

![[Pasted image 20240820193514.png]]

4. **Step 3: Insert "n"**:
   - The "a" node does not have a child node for "n".
   - Create a new node for "n" and attach it as a child of the "a" node.
   - Update `currentNode` to this new "n" node.

![[Pasted image 20240820193522.png]]

5. **Step 4: Mark the End**:
   - Since we’ve reached the end of the word, add a `*` node as a child of the "n" node to mark the end of the word "can".

![[Pasted image 20240820193532.png]]

## Trie C++ Implementation

To implement a Trie in C++, we will use a `TrieNode` class to represent each node in the Trie and a `Trie` class to manage the overall structure.

```cpp
#include <iostream>
#include <unordered_map>
#include <string>

class TrieNode {
public:
    std::unordered_map<char, TrieNode*> children;
    bool isEndOfWord;

    TrieNode() : isEndOfWord(false) {}
};

class Trie {
private:
    TrieNode* root;

public:
    Trie() {
        root = new TrieNode();
    }

    // Insert a word into the Trie
    void insert(const std::string &word) {
        TrieNode* currentNode = root;
        for (char ch : word) {
            if (currentNode->children.find(ch) == currentNode->children.end()) {
                currentNode->children[ch] = new TrieNode();
            }
            currentNode = currentNode->children[ch];
        }
        currentNode->isEndOfWord = true;
    }

    // Search for a word in the Trie
    bool search(const std::string &word) const {
        TrieNode* currentNode = root;
        for (char ch : word) {
            if (currentNode->children.find(ch) == currentNode->children.end()) {
                return false;
            }
            currentNode = currentNode->children[ch];
        }
        return currentNode->isEndOfWord;
    }

    // Check if any word in the Trie starts with the given prefix
    bool startsWith(const std::string &prefix) const {
        TrieNode* currentNode = root;
        for (char ch : prefix) {
            if (currentNode->children.find(ch) == currentNode->children.end()) {
                return false;
            }
            currentNode = currentNode->children[ch];
        }
        return true;
    }
};

int main() {
    Trie trie;

    trie.insert("apple");
    std::cout << trie.search("apple") << std::endl;   // Output: 1 (true)
    std::cout << trie.search("app") << std::endl;     // Output: 0 (false)
    std::cout << trie.startsWith("app") << std::endl; // Output: 1 (true)

    trie.insert("app");
    std::cout << trie.search("app") << std::endl;     // Output: 1 (true)

    return 0;
}
```

#### Explanation of Code

1. **TrieNode Class**:
    - Each `TrieNode` contains an unordered map (`children`) that maps a character to the corresponding child `TrieNode`.
    - The `isEndOfWord` boolean flag indicates whether a node represents the end of a word.

2. **Trie Class**:
    - The `Trie` class contains a `root` node, which is the starting point of all operations.
    - **Insert Method**: Adds a word to the Trie by iterating through each character in the word. If a character does not exist in the current node's children, a new `TrieNode` is created. After inserting all characters, the last node is marked as the end of a word.
    - **Search Method**: Checks if a word exists in the Trie by iterating through each character. If all characters are found in sequence and the last node is marked as the end of a word, the function returns true.
    - **StartsWith Method**: Checks if any word in the Trie starts with a given prefix by iterating through the prefix characters. If all characters are found, it returns true.

#### Key Takeaways

- **Trie Operations**: The insert and search operations are efficient, typically $O(M)$, where $M$ is the length of the word being inserted or searched.
- **Use Cases**: Tries are particularly useful for autocomplete features, prefix matching, and searching for all keys with a common prefix.

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

## DFS vs. BFS:

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
