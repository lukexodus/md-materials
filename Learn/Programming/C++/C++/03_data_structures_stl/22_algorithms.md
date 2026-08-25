## **Algorithms**


C++ provides a powerful **Standard Library (`<algorithm>`)** that includes numerous algorithms designed to work seamlessly with **iterators**. These algorithms allow efficient manipulation and traversal of data structures like arrays, vectors, lists, and sets without directly handling raw loops.

---

### **Iterators and Their Role in Algorithms**

Iterators act as **generalized pointers** that allow traversal over elements of a container. They provide a **common interface** for algorithms to work across different data structures.

### **Types of Iterators**

1. **Input Iterator** → Reads data **once** (e.g., `istream_iterator`).
2. **Output Iterator** → Writes data **once** (e.g., `ostream_iterator`).
3. **Forward Iterator** → Traverses **forward only** (e.g., `std::forward_list`).
4. **Bidirectional Iterator** → Moves **forward and backward** (e.g., `std::list`).
5. **Random Access Iterator** → Supports **arithmetic operations** (e.g., `std::vector`).

---

### **Algorithms Using Iterators**

#### **Searching Algorithms**

Iterators allow search operations without manual loops.

✅ **`std::find`** → Finds the first occurrence of an element.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {10, 20, 30, 40, 50};
    auto it = find(vec.begin(), vec.end(), 30);
    
    if (it != vec.end()) cout << "Found at index: " << distance(vec.begin(), it);
    else cout << "Not found";
}
```

✅ **`std::find_if`** → Finds first element that satisfies a condition.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

bool isEven(int num) { return num % 2 == 0; }

int main() {
    vector<int> vec = {3, 7, 2, 9, 6};
    auto it = find_if(vec.begin(), vec.end(), isEven);
    
    if (it != vec.end()) cout << "First even number: " << *it;
    else cout << "No even numbers";
}
```

---

#### **Sorting Algorithms**

Sorting algorithms efficiently rearrange elements in a range using iterators.

✅ **`std::sort`** → Sorts elements using **random access iterators** (like vectors).

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {5, 2, 8, 1, 6};
    sort(vec.begin(), vec.end());  // Sort in ascending order

    for (int num : vec) cout << num << " ";
}
```

✅ **`std::stable_sort`** → Maintains **relative order** of equal elements.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

struct Student {
    string name;
    int score;
};

bool compare(Student a, Student b) {
    return a.score < b.score;
}

int main() {
    vector<Student> students = {{"Alice", 90}, {"Bob", 85}, {"Eve", 85}};
    stable_sort(students.begin(), students.end(), compare);

    for (auto s : students) cout << s.name << " " << s.score << endl;
}
```

---

#### **Counting and Modifying Algorithms**

✅ **`std::count`** → Counts occurrences of a value.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {1, 2, 2, 3, 2, 4};
    cout << "Occurrences of 2: " << count(vec.begin(), vec.end(), 2);
}
```

✅ **`std::count_if`** → Counts elements that match a condition.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

bool isOdd(int num) { return num % 2 != 0; }

int main() {
    vector<int> vec = {1, 2, 3, 4, 5};
    cout << "Odd numbers: " << count_if(vec.begin(), vec.end(), isOdd);
}
```

✅ **`std::replace`** → Replaces all occurrences of a value.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {1, 2, 3, 2, 4};
    replace(vec.begin(), vec.end(), 2, 99);

    for (int num : vec) cout << num << " ";
}
```

---

#### **Transformations and Accumulations**

✅ **`std::for_each`** → Applies a function to each element.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

void print(int num) { cout << num * num << " "; }

int main() {
    vector<int> vec = {1, 2, 3, 4};
    for_each(vec.begin(), vec.end(), print);
}
```

✅ **`std::accumulate` (from `<numeric>`)** → Computes sum/product of elements.

```cpp
#include <iostream>
#include <vector>
#include <numeric>
using namespace std;

int main() {
    vector<int> vec = {1, 2, 3, 4};
    cout << "Sum: " << accumulate(vec.begin(), vec.end(), 0);
}
```

✅ **`std::transform`** → Applies a function to each element and stores the result.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {1, 2, 3, 4};
    vector<int> squared(vec.size());

    transform(vec.begin(), vec.end(), squared.begin(), [](int x) { return x * x; });

    for (int num : squared) cout << num << " ";
}
```

---

### **Key Points**

✅ **Iterators generalize algorithms**, making them applicable to different data structures.  
✅ **Searching algorithms** like `std::find` and `std::find_if` simplify element lookup.  
✅ **Sorting algorithms** like `std::sort` and `std::stable_sort` improve efficiency.  
✅ **Counting and modification algorithms** like `std::count` and `std::replace` provide flexible manipulation.  
✅ **Transformations and accumulations** like `std::transform` and `std::accumulate` help in functional-style programming.

---

