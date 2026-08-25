## Primitive Types


Integral types in C++ are data types that represent whole numbers (integers). These types store numeric values without any fractional or decimal part.

### **Integer Types**

- **`int`**: Basic integer type, typically 4 bytes in size.
- **`short`**: Short integer type, typically 2 bytes in size.
- **`long`**: Long integer type, typically 4 or 8 bytes depending on the system.
- **`long long`**: Extended long integer type, typically 8 bytes.
- **`unsigned int`**: Unsigned version of `int`, only positive values.
- **`unsigned short`**: Unsigned version of `short`.
- **`unsigned long`**: Unsigned version of `long`.
- **`unsigned long long`**: Unsigned version of `long long`.

#### Note:

##### 1 Bit:

- **Equivalence**: 2<sup>1</sup> = 2
- **Two States**: 0 or 1

##### 1 Byte (8 bits):

- **Equivalence**: 2<sup>8</sup> = 256
- **Signed**: -128 to 127
- **Unsigned**: 0 to 255

##### 2 Bytes (16 bits):

- **Equivalence**: 2<sup>16</sup> = 65,536
- **Signed: -32,768 to 32,767
- **Unsigned**: 0 to 65,535

##### 4 Bytes (32 bits):

- **Equivalence**: 2<sup>32</sup> = 4,294,967,296
- **Signed**: -2,147,483,648 to 2,147,483,647
- **Unsigned**: 0 to 4,294,967,295

##### 8 Bytes (64 bits):

- **Equivalence**: 2<sup>64</sup> = 18,446,744,073,709,551,616
- **Signed**: -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
- **Unsigned**: 0 to 18,446,744,073,709,551,615

### Floating-Point Types

- **`float`**: Single-precision floating-point type, typically 4 bytes.
- **`double`**: Double-precision floating-point type, typically 8 bytes.
- **`long double`**: Extended-precision floating-point type, size varies (typically 8, 12, or 16 bytes).

### Character Types

- **`char`**: Single character type, typically 1 byte.
- **`signed char`**: Signed version of `char`.
- **`unsigned char`**: Unsigned version of `char`.
- **`wchar_t`**: Wide character type, typically used for Unicode characters.
- **`char16_t`**: 16-bit character type, used for UTF-16 encoding.
- **`char32_t`**: 32-bit character type, used for UTF-32 encoding.

#### **`char`**

- **Size**: 1 byte
- **Signedness**: Implementation-defined (depends on compiler & platform)
- **Range**: Could be either `signed char` or `unsigned char`, depending on the system.
- **Use Case**: Typically used for storing characters (text data).
- **Example**:
    
    ```cpp
    char c = 'A';  // Stores character 'A'
    ```
    

---

#### **`signed char`**

- **Size**: 1 byte
- **Signedness**: Always **signed**
- **Range**: `-128` to `127` (for 8-bit systems)
- **Use Case**: Used for storing small signed integer values.
- **Example**:
    
    ```cpp
    signed char c = -5;  // Allowed
    signed char d = 130; // Overflow (if 8-bit, wraps around or undefined behavior)
    ```
    

---

#### **`unsigned char`**

- **Size**: 1 byte
- **Signedness**: Always **unsigned**
- **Range**: `0` to `255` (for 8-bit systems)
- **Use Case**: Used when storing raw binary data (e.g., buffers, images).
- **Example**:
    
    ```cpp
    unsigned char c = 250; // Allowed
    unsigned char d = -1;  // Wraps around to 255
    ```
    
---

```cpp
#include <iostream>
using namespace std;

int main() {
    cout << "char is signed? " << (char(-1) < 0) << endl;
    return 0;
}
```

If it prints `1`, `char` is **signed**. If `0`, `char` is **unsigned**.

---

#### **`wchar_t` (Wide Character)**

- **Size**: **Platform-dependent** (typically **2 bytes on Windows**, **4 bytes on Linux/macOS**).
- **Encoding**: Depends on platform, but often **UTF-16 (Windows)** or **UTF-32 (Linux/macOS)**.
- **Use Case**: Used for internationalization, where characters beyond ASCII are needed.
- **Example**:
    
    ```cpp
    #include <iostream>
    using namespace std;
    
    int main() {
        wchar_t w = L'Ω'; // 'Ω' is a Greek letter
        wcout << L"Wide character: " << w << endl;
        return 0;
    }
    ```
    
    **Note:** Use `wcout` for printing `wchar_t`.

---

#### **`char16_t` (16-bit Unicode Character)**

- **Size**: Always **2 bytes** (16 bits).
- **Encoding**: **UTF-16**.
- **Use Case**: Used for handling **Unicode** text where UTF-16 encoding is required.
    
- **Example**:
    
    ```cpp
    char16_t c16 = u'好'; // Chinese character "好"
    ```
    
    Unlike `wchar_t`, `char16_t` is **always** 2 bytes, making it more portable.
    

---

#### **`char32_t` (32-bit Unicode Character)**

- **Size**: Always **4 bytes** (32 bits).
- **Encoding**: **UTF-32**.
- **Use Case**: Used for handling **full Unicode characters** (including emojis).
    
- **Example**:
    
    ```cpp
    char32_t c32 = U'🌍'; // Unicode emoji
    ```
    
    `char32_t` can store **any** Unicode character in a single code unit.
    

---

**Comparison Table**

|Type|Size|Encoding|Typical Use|
|---|---|---|---|
|`char`|1 byte|ASCII/UTF-8|Standard text|
|`wchar_t`|Platform-dependent (2 or 4 bytes)|UTF-16 (Windows), UTF-32 (Linux)|International text|
|`char16_t`|2 bytes|UTF-16|Unicode text (UTF-16)|
|`char32_t`|4 bytes|UTF-32|Unicode text (UTF-32, full-range)|

### Boolean Type:

**bool**: Boolean type representing `true` or `false`, typically 1 byte.

### **Fixed-Width Integral Types (`<cstdint>`)**

To ensure consistent sizes across different systems, C++ provides **fixed-width integer types** in `<cstdint>`:

|Type|Size (bits)|Signed Range|
|---|---|---|
|`int8_t`|8|-128 to 127|
|`uint8_t`|8|0 to 255|
|`int16_t`|16|-32,768 to 32,767|
|`uint16_t`|16|0 to 65,535|
|`int32_t`|32|-2,147,483,648 to 2,147,483,647|
|`uint32_t`|32|0 to 4,294,967,295|
|`int64_t`|64|-9,223,372,036,854,775,808 to 9,223,372,036,854,775,807|
|`uint64_t`|64|0 to 18,446,744,073,709,551,615|

These are useful for **portable** code where exact bit sizes matter.

### Enumeration Types (`enum`)

Enumerations (`enum`) are also considered integral types. The underlying type defaults to `int`, but you can specify a different integral type.

```c++
enum Color { RED = 1, GREEN = 2, BLUE = 3 };
```

With enum class, the underlying type can be explicitly set:

```c++
enum class Direction : uint8_t { UP, DOWN, LEFT, RIGHT };
```

### Auto Type Deduction:

The `auto` keyword allows the compiler to automatically deduce the type of a variable based on its initializer. It's particularly useful when dealing with complex or template-based types.

```cpp
auto x = 10;         // Deduced as int
auto y = 3.14;       // Deduced as double
auto z = "Hello";    // Deduced as const char*
```

### Sizeof Operator:

The `sizeof` operator returns the size of a variable or a type in bytes. It's useful for determining the storage requirements of variables.

```cpp
sizeof(int);         // Returns the size of an int in bytes
sizeof(double);      // Returns the size of a double in bytes
sizeof(char);        // Returns the size of a char in bytes
```

### Size Type

`size_t` is a data type in C and C++ that is used to represent sizes of objects. It's an unsigned integer type defined in the `<cstddef>` header in C and `<stddef.h>` in C++. It's commonly used to represent the size of arrays, containers, and memory blocks.

```cpp
    size_t size = 10; // Represents the size of an array or container
    size_t size_of_int = sizeof(int);
```

### Void Type

- **`void`**: Represents the absence of type, often used in functions that do not return a value.

### Null Pointer Type

`nullptr_t` is the type of the `nullptr` keyword in C++. It represents a null pointer and is used to indicate the absence of a valid pointer.

1. **Only One Value**: `nullptr_t` can only hold `nullptr`.
2. **Implicitly Convertible**: It can be assigned to any pointer type but **not** to integral types.
3. **Prevents Ambiguity**: Unlike `NULL`, which is often `0`, `nullptr` ensures type safety.

```cpp
#include <iostream>
#include <type_traits>

int main() {
    std::nullptr_t np = nullptr;  // Declaring a nullptr_t variable

    int* p1 = nullptr;      // Valid: nullptr_t converts to int*
    double* p2 = nullptr;   // Valid: nullptr_t converts to double*

    // nullptr is not an integer
    // int x = nullptr;  // ❌ Error

    std::cout << "Type of np: " << typeid(np).name() << std::endl;
    return 0;
}
```

#### **Why Use `nullptr_t` Instead of `NULL`?**

- **Type Safety**: `NULL` is often `0`, leading to ambiguity between pointers and integers. `nullptr` is explicitly a pointer type.
    
- **Overload Resolution**: Consider this example:
    
    ```cpp
    void foo(int x) { std::cout << "int version\n"; }
    void foo(int* p) { std::cout << "pointer version\n"; }
    
    int main() {
        foo(0);       // Calls `foo(int)`, which may be unintended
        foo(nullptr); // Calls `foo(int*)`, correctly selecting the pointer overload
    }
    ```
    
    `NULL` (which is `0`) could incorrectly select `foo(int)`, but `nullptr` ensures `foo(int*)` is called.
    

**Conclusion**

- Use `nullptr` instead of `NULL` for modern C++ code.
- `nullptr_t` ensures strong **type safety** and **overload resolution**.
- It is **implicitly convertible** to any pointer type but **not to integral types**.

***

