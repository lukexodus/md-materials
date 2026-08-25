## Structures (`struct`)


Structures in C++ are user-defined data types that allow you to group different variables together under a single name. They are used to represent records containing various types of data.

### Declaring a Structure:

```cpp
struct Person {
    std::string name;
    int age;
    float height;
};
```

- `struct` keyword is used to define a structure.
- `Person` is the structure tag or name.
- Inside the structure, you can declare variables of different data types.

### Creating Structure Variables:

```cpp
Person person1; // Declaration of a structure variable
```

### Accessing Structure Members:

```cpp
person1.name = "John";
person1.age = 25;
person1.height = 175.5;
```

- You can access structure members using the dot `.` operator.

### Initializing Structure Variables:

```cpp
Person person2 = {"Alice", 30, 160.0}; // Initializing structure variable during declaration
```

### Nested Structures:

```cpp
struct Address {
    std::string city;
    std::string country;
};

struct Person {
    std::string name;
    int age;
    Address address; // Nested structure
};

Person person;
person.name = "John Doe";
person.age = 30;
person.address.city = "Anytown";
person.address.country = "USA";
```

- Structures can contain other structures as members, allowing for complex data structures.

### Benefits of Structures:

- **Organization**: Group related data together for better organization and readability.
- **Abstraction**: Represent real-world entities or concepts in code.
- **Passing Data**: Pass structures to functions to encapsulate related data.

### Considerations:

- **Memory Allocation**: Each structure variable occupies memory based on the size of its members.
- **Access Control**: By default, structure members are public, but you can use access specifiers to control access.

***

