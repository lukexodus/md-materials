## Passing Arrays to Functions


You can pass arrays to functions using different methods depending on whether you're working with raw arrays or vectors. Here's how you can pass arrays to functions:

### Passing Raw Arrays:

#### Method 1: Pass by Pointer

```cpp
void printArray(int* arr, int size) {
    for (int i = 0; i < size; ++i) {
        std::cout << arr[i] << " ";
    }
    std::cout << std::endl;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5};
    int size = sizeof(arr) / sizeof(arr[0]);
    printArray(arr, size);
    return 0;
}
```

#### Method 2: Pass by Reference

```cpp
void printArray(int (&arr)[5]) { // Size must be specified
    for (int i = 0; i < 5; ++i) {
        std::cout << arr[i] << " ";
    }
    std::cout << std::endl;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5};
    printArray(arr);
    return 0;
}
```

### Passing Vectors:

#### Method 1: Pass by Reference

```cpp
void printVector(const std::vector<int>& vec) {
    for (int num : vec) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> vec = {1, 2, 3, 4, 5};
    printVector(vec);
    return 0;
}
```

#### Method 2: Pass by Value (Copy)

```cpp
void modifyVector(std::vector<int> vec) {
    vec.push_back(6);
    for (int num : vec) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> vec = {1, 2, 3, 4, 5};
    modifyVector(vec);
    return 0;
}
```

### Considerations:

- When passing arrays, it's common to pass the size of the array as a separate parameter.
- When passing vectors by reference, use `const` to ensure that the function does not modify the vector.
- Passing by reference is generally more efficient than passing by value, especially for large containers.

---

