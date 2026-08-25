## Common Standard Libraries


In C++, several standard libraries are commonly used across different types of applications. These libraries provide essential functionalities that are fundamental to C++ programming. Here are some of the most commonly used default libraries:

### 1. **\<iostream\>**
- **Purpose:** Provides facilities for input and output (I/O) operations.
- **Common Uses:** 
  - `std::cout` for console output.
  - `std::cin` for console input.
  - `std::cerr` for error output.

### 2. **\<vector\>**
- **Purpose:** Defines the `std::vector` container, a dynamic array that can resize itself automatically.
- **Common Uses:** 
  - Managing a dynamic array of elements.
  - Accessing elements using indexing.
  - Adding and removing elements.

### 3. **\<string\>**
- **Purpose:** Provides support for handling strings through the `std::string` class.
- **Common Uses:** 
  - Manipulating sequences of characters.
  - String concatenation, comparison, and searching.
  - Converting between strings and other data types.

### 4. **\<algorithm\>**
- **Purpose:** Provides a collection of functions for performing various operations on data structures, such as sorting, searching, and modifying sequences.
- **Common Uses:** 
  - `std::sort` for sorting elements.
  - `std::find` for searching elements.
  - `std::copy`, `std::transform`, and others for modifying data.

### 5. **\<map> and <unordered_map>**
- **Purpose:** Define associative containers that store key-value pairs. `std::map` is ordered, while `std::unordered_map` is not.
- **Common Uses:** 
  - Storing and retrieving elements based on keys.
  - Implementing lookup tables, dictionaries, and associative arrays.

### 6. **\<set> and <unordered_set>**
- **Purpose:** Define containers that store unique elements. `std::set` is ordered, while `std::unordered_set` is not.
- **Common Uses:** 
  - Storing unique elements.
  - Efficiently checking if an element exists.

### 7. **\<deque>**
- **Purpose:** Defines `std::deque`, a double-ended queue that allows insertion and deletion of elements from both ends.
- **Common Uses:** 
  - Implementing queues or stacks.
  - Managing sequences where elements are frequently added or removed from both ends.

### 8. **\<list>**
- **Purpose:** Provides a doubly-linked list implementation through `std::list`.
- **Common Uses:** 
  - Managing sequences of elements with frequent insertions and deletions.
  - When random access is not needed.

### 9. **\<cmath>**
- **Purpose:** Provides mathematical functions.
- **Common Uses:** 
  - Trigonometric functions like `std::sin`, `std::cos`.
  - Power and exponentiation functions like `std::pow`, `std::exp`.
  - Basic operations like `std::sqrt` and `std::abs`.

### 10. **\<thread>**
- **Purpose:** Provides support for multithreading in C++.
- **Common Uses:** 
  - Creating and managing threads (`std::thread`).
  - Synchronizing access to shared resources (`std::mutex`, `std::lock_guard`).

### 11. **\<functional>**
- **Purpose:** Provides utilities for function objects, lambdas, and other callable objects.
- **Common Uses:** 
  - Using `std::function` to store and pass around functions.
  - Creating bind expressions with `std::bind`.

### 12. **\<chrono>**
- **Purpose:** Provides utilities for dealing with time.
- **Common Uses:** 
  - Measuring time intervals (`std::chrono::duration`).
  - Getting the current time (`std::chrono::system_clock`).

### 13. **\<memory>**
- **Purpose:** Provides facilities for dynamic memory management.
- **Common Uses:** 
  - Using smart pointers like `std::unique_ptr` and `std::shared_ptr` to manage dynamic memory safely.

### 14. **\<tuple>**
- **Purpose:** Allows grouping of multiple values of different types into a single object.
- **Common Uses:** 
  - Returning multiple values from a function.
  - Grouping related data without creating a custom structure.

### 15. **\<utility>**
- **Purpose:** Contains utility functions like `std::pair` and `std::move`.
- **Common Uses:** 
  - Returning two related values with `std::pair`.
  - Efficiently transferring resources with `std::move`.

### 16. **\<array>**
- **Purpose:** Provides a fixed-size array container through `std::array`.
- **Common Uses:**
  - Creating arrays with a fixed size known at compile-time.
  - Offers the benefits of an array with additional functionality like bounds checking.

### 17. **\<stack>**
- **Purpose:** Provides a stack container adapter.
- **Common Uses:**
  - Implementing a LIFO (Last In, First Out) data structure.
  - Managing a sequence where the last added element is the first to be removed.

### 18. **\<queue>**
- **Purpose:** Provides a queue container adapter.
- **Common Uses:**
  - Implementing a FIFO (First In, First Out) data structure.
  - Managing tasks or elements where the first added element is the first to be processed.

### 19. **\<bitset>**
- **Purpose:** Provides a container to manage a fixed-size sequence of bits.
- **Common Uses:**
  - Manipulating individual bits efficiently.
  - Performing operations like bitwise AND, OR, and XOR on sequences of bits.

### 20. **\<fstream>**
- **Purpose:** Provides facilities for file input and output operations.
- **Common Uses:**
  - Reading from and writing to files (`std::ifstream`, `std::ofstream`, `std::fstream`).
  - Handling text and binary files.

### 21. **\<iomanip>**
- **Purpose:** Provides facilities to control the formatting of input and output.
- **Common Uses:**
  - Setting precision for floating-point output (`std::setprecision`).
  - Formatting output with width and alignment (`std::setw`, `std::left`, `std::right`).

### 22. **\<locale>**
- **Purpose:** Provides support for localization, allowing programs to adapt to different cultural conventions.
- **Common Uses:**
  - Handling region-specific formatting of numbers, dates, and times.
  - Managing locale-specific input and output.

### 23. **\<random>**
- **Purpose:** Provides facilities to generate random numbers and perform random operations.
- **Common Uses:**
  - Generating random integers, floats, and other types (`std::mt19937`, `std::uniform_int_distribution`).
  - Creating random number generators with various distributions.

### 24. **\<type_traits>**
- **Purpose:** Provides templates that allow you to query and manipulate type information at compile-time.
- **Common Uses:**
  - Checking if a type is integral or floating-point (`std::is_integral`, `std::is_floating_point`).
  - Enabling or disabling template functions based on type traits (`std::enable_if`).

### 25. **\<numeric>**
- **Purpose:** Provides algorithms for performing numerical operations on sequences.
- **Common Uses:**
  - Accumulating values (`std::accumulate`).
  - Computing inner products (`std::inner_product`).
  - Performing partial sums (`std::partial_sum`).

### 26. **\<regex>**
- **Purpose:** Provides support for regular expressions.
- **Common Uses:**
  - Pattern matching within strings (`std::regex`, `std::regex_search`, `std::regex_match`).
  - Finding and replacing text in strings using regular expressions.

### 27. **\<cassert>**
- **Purpose:** Provides support for diagnostic output via the `assert` macro.
- **Common Uses:**
  - Performing runtime checks during debugging (`assert`).
  - Ensuring that conditions expected by the program are true during execution.

### 28. **\<cctype>**
- **Purpose:** Provides functions for character classification and conversion.
- **Common Uses:**
  - Checking if a character is a digit, letter, or whitespace (`std::isdigit`, `std::isalpha`).
  - Converting characters to upper or lower case (`std::toupper`, `std::tolower`).

### 29. **\<ctime>**
- **Purpose:** Provides functions for dealing with calendar time.
- **Common Uses:**
  - Getting the current time (`std::time`).
  - Converting time to and from string representations (`std::strftime`, `std::strptime`).

### 30. **\<exception>**
- **Purpose:** Provides support for exception handling.
- **Common Uses:**
  - Defining custom exception classes (`std::exception`).
  - Catching and handling exceptions in a consistent manner.

***

