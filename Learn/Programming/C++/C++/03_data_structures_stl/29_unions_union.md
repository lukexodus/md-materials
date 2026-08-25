## Unions (`union`)


Unions in C++ allow you to define a data structure that can hold elements of different types in the same memory location. Unlike structures, where each member has its own memory space, all members of a union share the same memory location.

### Define a Union:

```cpp
union Data {
    int intValue;
    float floatValue;
    char stringValue[10];
};
```

- In this example, `Data` can hold either an integer, a floating-point number, or a string of characters, but not all simultaneously.
- All members of the union share the same memory location, and the size of the union is determined by the size of its largest member (`stringValue` in this case).

### Accessing Union Members:

```cpp
Data data;
data.intValue = 10; // Assign an integer value
std::cout << data.intValue << std::endl; // Access the integer value

data.floatValue = 3.14f; // Assign a floating-point value
std::cout << data.floatValue << std::endl; // Access the floating-point value

strcpy(data.stringValue, "Hello"); // Assign a string value
std::cout << data.stringValue << std::endl; // Access the string value
```

- When you assign a value to one member of the union, the contents of the other members become undefined. Only the last assigned member should be accessed.

### Use Cases for Unions:

1. **Memory Efficiency**: Unions can save memory by allowing different interpretations of the same memory location.
2. **Type Conversion**: Unions can be used for type conversion when the same memory needs to be interpreted in different ways.
3. **Interpretation of Binary Data**: Unions are useful when dealing with low-level binary data where the same memory needs to be interpreted differently based on context.

### Considerations:

- **Union Size**: The size of a union is determined by the size of its largest member.
- **Undefined Behavior**: Accessing non-active members of a union (those not most recently assigned) can lead to undefined behavior.
- **Type Safety**: Unions can lead to type safety issues if not used carefully, especially when interpreting data in different ways.

***

