## Java Fundamentals


Java serves as one of the primary languages for Android development, with extensive legacy support and comprehensive documentation. Understanding Java syntax, data types, control structures, and exception handling creates a solid foundation for Android programming.

**Key Points:**

- Variables, data types (primitive and reference types)
- Control flow statements (if/else, loops, switch)
- Methods and method overloading
- Arrays and collections framework
- Exception handling with try-catch-finally blocks
- Input/output operations and file handling
- Multithreading concepts and synchronization

**Example:**

```java
public class UserManager {
    private List<User> users = new ArrayList<>();
    
    public void addUser(User user) throws IllegalArgumentException {
        if (user == null || user.getName().isEmpty()) {
            throw new IllegalArgumentException("Invalid user data");
        }
        users.add(user);
    }
    
    public Optional<User> findUserById(int id) {
        return users.stream()
                   .filter(user -> user.getId() == id)
                   .findFirst();
    }
}
```

