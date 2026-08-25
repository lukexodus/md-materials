## Enumerations (`enum`)


Enums, short for enumerations, in C++ are user-defined data types that allow you to define sets of named constants. Enums provide a way to assign meaningful names to integral constants, making the code more readable and maintainable.

### Define an Enum:

```cpp
enum Color {
    RED,
    GREEN,
    BLUE
};
```

- In this example, `Color` is the name of the enum, and `RED`, `GREEN`, and `BLUE` are the enumerators or named constants.
- By default, the underlying type of enums is `int`, and each enumerator is assigned an integer value starting from 0.

### Assign Integer Values to Enumerators:

```cpp
enum Weekday {
    MONDAY = 1,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY,
    SUNDAY
};
```

- In this example, `MONDAY` is assigned the value 1, and subsequent enumerators are assigned increasing integer values by default (2, 3, 4, ...).

### Using Enums:

```cpp
Color paint = RED;
Weekday today = TUESDAY;

if (paint == RED) {
    std::cout << "Paint the wall red" << std::endl;
}

switch (today) {
    case MONDAY:
        std::cout << "Today is Monday" << std::endl;
        break;
    case TUESDAY:
        std::cout << "Today is Tuesday" << std::endl;
        break;
    // Handle other weekdays
    default:
        std::cout << "Unknown day" << std::endl;
}
```

- Enums can be used like any other integral type, including in conditional statements, switch statements, and variable assignments.

### Scoped Enums:

```cpp
enum class Status {
    OK,
    ERROR
};

Status systemStatus = Status::OK;

if (systemStatus == Status::OK) {
    std::cout << "System is running normally" << std::endl;
}
```

- Scoped enums introduce a new scoping mechanism, where enumerators are scoped within the enum name, preventing name clashes with other enums or variables.

### Benefits of Enums:

- **Readability**: Enums provide meaningful names for integral constants, improving code readability and maintainability.
- **Type Safety**: Enums provide type safety, preventing unintended assignments of arbitrary integer values.
- **Compiler Checking**: The compiler can catch errors related to enum usage, such as invalid enum values or type mismatches.

---
