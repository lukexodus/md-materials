## Don't Return Null


Returning `null` shifts the burden of null-checking to the caller, violating the principle of encapsulation and leading to the ubiquitous `NullPointerException` (NPE). It creates ambiguity: does `null` mean "not found," "error," or "uninitialized"?

**Key Points**

- **Null Object Pattern:** Return a valid object that exhibits "do nothing" behavior. For example, a `NullLogger` that simply discards logs, or a `Customer.Unknown` object. This allows the caller to treat all results uniformly.
    
- **Empty Collections:** Never return `null` for a list, set, or array. Return an empty collection (e.g., `Collections.emptyList()`). This eliminates the need for callers to check `if (list != null && !list.isEmpty())`.
    
- **Optional/Maybe Types:** Use container types (like Java's `Optional<T>` or Rust's `Option<T>`) to explicitly express the possibility of absence in the API signature. This forces the caller to handle the empty case at compile time.
    
- **Fail Fast:** If a method cannot return a valid value and "absence" is not a valid state, throw an exception rather than returning `null`.
    

**Example**

_Bad Practice:_

Java

```
public List<User> getUsers() {
    if (db.isEmpty()) {
        return null; // Caller must check for null
    }
    return db.queryUsers();
}
```

_Refactored (Empty Collection):_

Java

```
public List<User> getUsers() {
    if (db.isEmpty()) {
        return Collections.emptyList(); // Caller can safe-loop immediately
    }
    return db.queryUsers();
}
```

