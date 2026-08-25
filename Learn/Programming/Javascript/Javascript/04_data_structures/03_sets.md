## Sets


A `Set` is a collection of unique values (no duplicates). It can hold any type of value (primitive or object).

#### **Creating and Using a Set**

```javascript
let mySet = new Set();
mySet.add(1);
mySet.add(2);
mySet.add(2); // Duplicate, won't be added
console.log(mySet); // Output: Set(2) { 1, 2 }
```

---

#### **Key Methods for Sets**

1. **`add(value)`**: Adds a new value to the Set.
    
    ```javascript
    mySet.add(3);
    ```
    
2. **`delete(value)`**: Removes a value from the Set.
    
    ```javascript
    mySet.delete(2); // Removes 2
    ```
    
3. **`has(value)`**: Checks if the Set contains a specific value.
    
    ```javascript
    console.log(mySet.has(1)); // true
    console.log(mySet.has(4)); // false
    ```
    
4. **`clear()`**: Removes all values from the Set.
    
    ```javascript
    mySet.clear();
    console.log(mySet); // Set(0) {}
    ```
    
5. **`size`**: Returns the number of values in the Set.
    
    ```javascript
    console.log(mySet.size); // 0 (after clear)
    ```
    

---

#### **Iterating Over a Set**

- **`forEach()`**:
    
    ```javascript
    mySet.add(1).add(2).add(3);
    mySet.forEach(value => console.log(value));
    // Output: 1, 2, 3
    ```
    
- **`for...of`**:
    
    ```javascript
    for (let value of mySet) {
      console.log(value);
    }
    ```
    

---

#### **Set Use Cases**

- Removing duplicates from an array:
    
    ```javascript
    let numbers = [1, 2, 2, 3, 3, 4];
    let uniqueNumbers = [...new Set(numbers)];
    console.log(uniqueNumbers); // [1, 2, 3, 4]
    ```
    
- Fast lookups:
    
    ```javascript
    let blacklist = new Set(["spam", "ad"]);
    console.log(blacklist.has("spam")); // true
    ```
    

---

