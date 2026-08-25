## Standard Library (`std`)


`std` stands for the Standard Template Library (STL) in C++. It's a collection of classes and functions that are part of the C++ Standard Library. The `std` namespace encompasses the entire C++ Standard Library.

Here are some key points about `std`:

1. **Namespace**: `std` is a namespace that encapsulates all the components of the C++ Standard Library. By placing library components within the `std` namespace, it helps avoid naming conflicts with user-defined identifiers.

2. **Containers and Algorithms**: `std` provides various container classes like `std::vector`, `std::list`, `std::map`, `std::set`, etc., along with algorithms for manipulating these containers such as `std::sort`, `std::find`, `std::accumulate`, and many more.

3. **Iterators**: It offers iterator types and algorithms that work with iterators to provide a uniform interface for sequential access to elements in containers.

4. **Utilities and Functionalities**: `std` also includes utility classes like `std::pair`, `std::tuple`, `std::function`, and various other utilities like `std::move`, `std::swap`, `std::initializer_list`, etc.

5. **I/O Operations**: `std` provides facilities for input and output operations, including `std::cin`, `std::cout`, `std::cerr`, `std::ifstream`, `std::ofstream`, etc.

6. **Concurrency**: With C++11 and later standards, `std` includes components for multithreading and concurrency, such as `std::thread`, `std::mutex`, `std::atomic`, etc.

Example usage:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    // Using vector from the std namespace
    std::vector<int> vec = {3, 1, 4, 1, 5, 9, 2, 6};

    // Sorting the vector using std::sort algorithm
    std::sort(vec.begin(), vec.end());

    // Outputting the sorted vector using std::cout
    for (int elem : vec) {
        std::cout << elem << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

In summary, `std` is the namespace that contains the C++ Standard Library, providing a wide range of functionalities and utilities for C++ programmers to use in their applications.

***

### **Stream Insertion and Extraction Operators**
- **Purpose:** These operators are used with input and output streams (like `cin` and `cout`) to read from and write to the console or other streams.

#### **`<<` (Stream Insertion Operator)**
- **Usage:** Used to send (insert) data to an output stream.
- **Example:**
  ```cpp
  std::cout << "Hello, World!" << std::endl;
  ```
  - **Explanation:** This code outputs the string "Hello, World!" followed by a newline. The `<<` operator inserts the string into the `cout` stream.

#### **`>>` (Stream Extraction Operator)**
- **Usage:** Used to extract (read) data from an input stream.
- **Example:**
  ```cpp
  int number;
  std::cin >> number;
  ```
  - **Explanation:** This code reads an integer from the user input and stores it in the variable `number`. The `>>` operator extracts the data from the `cin` stream.

### **Bitwise Shift Operators**
- **Purpose:** These operators are used to shift the bits of an integer value to the left or right. They are often used in low-level programming, bit manipulation, and performance-critical code.

#### **`<<` (Left Shift Operator)**
- **Usage:** Shifts the bits of an integer to the left by a specified number of positions. Each left shift effectively multiplies the number by 2.
- **Example:**
  ```cpp
  int x = 5; // Binary: 0000 0101
  int result = x << 2; // Binary: 0001 0100 (equivalent to 20)
  ```
  - **Explanation:** This code shifts the bits of `5` two positions to the left, resulting in `20` (in binary, `0001 0100`).

#### **`>>` (Right Shift Operator)**
- **Usage:** Shifts the bits of an integer to the right by a specified number of positions. Each right shift effectively divides the number by 2.
- **Example:**
  ```cpp
  int x = 20; // Binary: 0001 0100
  int result = x >> 2; // Binary: 0000 0101 (equivalent to 5)
  ```
  - **Explanation:** This code shifts the bits of `20` two positions to the right, resulting in `5` (in binary, `0000 0101`).

***

