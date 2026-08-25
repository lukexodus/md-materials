## **Maps**


A `Map` is a collection of key-value pairs where keys can be of any type (e.g., objects, functions, or primitives).

#### **Creating and Using a Map**

```javascript
let myMap = new Map();
myMap.set("name", "Alice");
myMap.set("age", 25);
console.log(myMap); // Map(2) { "name" => "Alice", "age" => 25 }
```

---

#### **Key Methods for Maps**

1. **`set(key, value)`**: Adds or updates a key-value pair.
    
    ```javascript
    myMap.set("country", "USA");
    ```
    
2. **`get(key)`**: Retrieves the value associated with a key.
    
    ```javascript
    console.log(myMap.get("name")); // "Alice"
    ```
    
3. **`has(key)`**: Checks if a key exists in the Map.
    
    ```javascript
    console.log(myMap.has("age")); // true
    ```
    
4. **`delete(key)`**: Removes a key-value pair.
    
    ```javascript
    myMap.delete("age");
    ```
    
5. **`clear()`**: Removes all key-value pairs.
    
    ```javascript
    myMap.clear();
    ```
    
6. **`size`**: Returns the number of key-value pairs.
    
    ```javascript
    console.log(myMap.size); // 0 (after clear)
    ```
    

---

#### **Iterating Over a Map**

- **Key-Value Pairs**:
    
    ```javascript
    myMap.set("name", "Alice").set("age", 25);
    for (let [key, value] of myMap) {
      console.log(`${key}: ${value}`);
    }
    ```
    
- **Keys Only**:
    
    ```javascript
    for (let key of myMap.keys()) {
      console.log(key);
    }
    ```
    
- **Values Only**:
    
    ```javascript
    for (let value of myMap.values()) {
      console.log(value);
    }
    ```
    

---

#### **Map vs Object**

- **Objects**: Best for structures where keys are known and typically strings.
- **Maps**: Better for dynamic collections, with keys of any type and improved performance for frequent additions/deletions.

---

### **WeakSet and WeakMap**

These are similar to `Set` and `Map` but allow only objects as keys and do not prevent garbage collection. They are useful for memory-sensitive tasks.

#### **Key Differences**

- **WeakSet**:
    
    - Only stores objects.
    - Does not have `size`, `keys`, or `values`.
    - Items are weakly referenced, so they can be garbage collected.
    
    ```javascript
    let weakSet = new WeakSet();
    let obj = { key: "value" };
    weakSet.add(obj);
    ```
    
- **WeakMap**:
    
    - Keys must be objects.
    - Does not have iteration methods or `size`.
    - Keys can be garbage collected when no references exist.
    
    ```javascript
    let weakMap = new WeakMap();
    let keyObj = {};
    weakMap.set(keyObj, "value");
    ```
    

---

### **Key Use Cases**

1. **Tracking unique items (Set)**: Use `Set` for fast, unique collections like managing tags or categories.
    
2. **Key-value storage (Map)**: Use `Map` for dynamic data like configurations, metadata, or caching.
    
3. **Memory-sensitive caching (WeakMap)**: Use `WeakMap` to associate metadata with objects without preventing their garbage collection.
    


