## Passing Structures to Functions


Passing structures to functions in C++ allows you to manipulate and operate on structure data within functions.

### Passing by Value:

```cpp
struct Person {
    std::string name;
    int age;
    float height;
};

void printPerson(Person person) {
    std::cout << "Name: " << person.name << std::endl;
    std::cout << "Age: " << person.age << std::endl;
    std::cout << "Height: " << person.height << std::endl;
}

int main() {
    Person p = {"John", 25, 175.5};
    printPerson(p);
    return 0;
}
```

- When passed by value, the function `printPerson` receives a copy of the structure. Changes made to the structure inside the function do not affect the original structure.

### Passing by Reference:

```cpp
void modifyPerson(Person& person) {
    person.age = 30;
    person.height = 180.0;
}

int main() {
    Person p = {"John", 25, 175.5};
    modifyPerson(p);
    printPerson(p); // Print modified person
    return 0;
}
```

- Passing by reference allows the function to directly modify the original structure. Changes made to the structure inside the function are reflected in the original structure.

### Passing by Pointer:

```cpp
void updatePerson(Person* personPtr) {
    personPtr->age = 30;
    personPtr->height = 180.0;
}

int main() {
    Person p = {"John", 25, 175.5};
    updatePerson(&p);
    printPerson(p); // Print updated person
    return 0;
}
```

- Passing a pointer to the structure allows the function to modify the original structure indirectly. Arrow (`->`) operator is used to access members through the pointer.

### Benefits:
- Passing structures to functions allows for modular and organized code.
- It enables functions to operate on data encapsulated within structures.
- Different methods of passing (by value, by reference, by pointer) offer flexibility based on requirements.

### Considerations:
- Passing by value creates a copy of the structure, which may have performance implications for large structures.
- Passing by reference and pointer allows direct modification of the original structure, so caution is needed to avoid unintended side effects.

---

