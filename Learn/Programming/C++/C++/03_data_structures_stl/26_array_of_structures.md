## Array of Structures


Arrays of structures in C++ allow you to store multiple instances of a structure type in a contiguous block of memory. This is particularly useful when you need to work with collections of related data.

### Declaring a Structure:

```cpp
struct Person {
    std::string name;
    int age;
    float height;
};
```

### Declaring an Array of Structures:

```cpp
const int MAX_PERSONS = 100;
Person people[MAX_PERSONS]; // Array of structures
```

- This declares an array named `people` that can hold up to `MAX_PERSONS` instances of the `Person` structure.

### Initializing Array of Structures:

```cpp
Person people[MAX_PERSONS] = {
    {"John", 25, 175.5},
    {"Alice", 30, 160.0},
    // Add more instances as needed
};
```

### Accessing Elements in Array of Structures:

```cpp
people[0].name = "Bob";
people[0].age = 35;
people[0].height = 180.0;
```

- Access individual elements of the array using array indexing and set their values as needed.

### Iterating Through Array of Structures:

```cpp
for (int i = 0; i < MAX_PERSONS; ++i) {
    std::cout << "Person " << i + 1 << std::endl;
    std::cout << "Name: " << people[i].name << std::endl;
    std::cout << "Age: " << people[i].age << std::endl;
    std::cout << "Height: " << people[i].height << std::endl;
    std::cout << std::endl;
}
```

- Use a loop to iterate through the array and access each structure element.

### Dynamic Allocation of Array of Structures:

```cpp
Person* people = new Person[MAX_PERSONS];
```

- Dynamic allocation allows you to allocate memory for the array at runtime. Don't forget to deallocate memory using `delete[]` when done.

***

