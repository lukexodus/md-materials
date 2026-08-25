## Arrays


### Declaring, Accessing, and Iterating

**Declaring an Array**  
Arrays in JavaScript can be created using the `[]` literal or the `Array` constructor.

Examples:

```javascript
let fruits = ["apple", "banana", "cherry"]; // Array literal
let numbers = new Array(1, 2, 3, 4, 5);    // Using Array constructor
```

---

**Accessing Array Elements**  
Array elements are accessed using **zero-based indexing**. The first element is at index `0`, the second at `1`, and so on.

Example:

```javascript
let fruits = ["apple", "banana", "cherry"];
console.log(fruits[0]); // Output: apple
console.log(fruits[2]); // Output: cherry
```

You can also modify elements by assigning values to a specific index:

```javascript
fruits[1] = "mango";
console.log(fruits); // Output: ["apple", "mango", "cherry"]
```

---

**Iterating Through Arrays**  
You can iterate through arrays using loops or array methods:

1. **Using `for` loop**:
    
    ```javascript
    for (let i = 0; i < fruits.length; i++) {
        console.log(fruits[i]);
    }
    ```
    
2. **Using `for...of` loop**:
    
    ```javascript
    for (let fruit of fruits) {
        console.log(fruit);
    }
    ```
    
3. **Using `forEach` method**:
    
    ```javascript
    fruits.forEach(fruit => console.log(fruit));
    ```
    

---

### Array Methods

JavaScript provides many built-in methods to manipulate arrays. Below is an overview of the most common ones:

**1. Adding or Removing Elements**

- `push(element)`: Adds an element to the end of the array.
    
    ```javascript
    fruits.push("orange"); // ["apple", "mango", "cherry", "orange"]
    ```
    
- `pop()`: Removes the last element of the array.
    
    ```javascript
    fruits.pop(); // ["apple", "mango", "cherry"]
    ```
    
- `unshift(element)`: Adds an element to the beginning of the array.
    
    ```javascript
    fruits.unshift("strawberry"); // ["strawberry", "apple", "mango", "cherry"]
    ```
    
- `shift()`: Removes the first element of the array.
    
    ```javascript
    fruits.shift(); // ["apple", "mango", "cherry"]
    ```
    

**2. Finding and Searching**

- `indexOf(element)`: Returns the first index of the element, or `-1` if not found.
    
    ```javascript
    fruits.indexOf("mango"); // Output: 1
    ```
    
- `includes(element)`: Returns `true` if the element exists, otherwise `false`.
    
    ```javascript
    fruits.includes("cherry"); // Output: true
    ```
    

**3. Transforming Arrays**

- `map(callback)`: Creates a new array by applying a function to each element.
    
    ```javascript
    let numbers = [1, 2, 3];
    let squares = numbers.map(num => num * num); // [1, 4, 9]
    ```
    
- `filter(callback)`: Creates a new array with elements that pass the given condition.
    
    ```javascript
    let evenNumbers = numbers.filter(num => num % 2 === 0); // [2]
    ```
    
- `reduce(callback, initialValue)`: Reduces the array to a single value.
    
    ```javascript
    let sum = numbers.reduce((acc, num) => acc + num, 0); // 6
    ```
    

**4. Sorting and Reversing**

- `sort()`: Sorts the elements of the array alphabetically (by default).
    
    ```javascript
    let fruits = ["banana", "apple", "cherry"];
    fruits.sort(); // ["apple", "banana", "cherry"]
    ```
    
    For numerical sorting, you need a compare function:
    
    ```javascript
    let numbers = [10, 3, 2, 15];
    numbers.sort((a, b) => a - b); // [2, 3, 10, 15]
    ```
    
- `reverse()`: Reverses the order of elements.
    
    ```javascript
    fruits.reverse(); // ["cherry", "banana", "apple"]
    ```
    

**5. Slicing and Splicing**

- `slice(start, end)`: Returns a shallow copy of a portion of the array.
    
    ```javascript
    let sliced = fruits.slice(1, 3); // ["banana", "cherry"]
    ```
    
- `splice(start, deleteCount, ...items)`: Removes and/or adds elements to the array.
    
    ```javascript
    fruits.splice(1, 1, "mango", "orange"); // ["apple", "mango", "orange", "cherry"]
    ```
    

**6. Joining and Splitting**

- `join(separator)`: Combines all elements into a string.
    
    ```javascript
    fruits.join(", "); // "apple, mango, orange, cherry"
    ```
    
- `split(separator)`: Converts a string into an array.
    
    ```javascript
    let sentence = "Hello World";
    let words = sentence.split(" "); // ["Hello", "World"]
    ```
    

**7. Finding Elements**

- `find(callback)`: Returns the first element that satisfies the given condition or `undefined` if none match.
    
    ```javascript
    let numbers = [10, 20, 30, 40];
    let result = numbers.find(num => num > 25); // 30
    ```
    
- `findIndex(callback)`: Returns the index of the first element that satisfies the condition or `-1` if none match.
    
    ```javascript
    let index = numbers.findIndex(num => num > 25); // 2
    ```
    

---

**8. Checking Conditions**

- `every(callback)`: Returns `true` if **all elements** satisfy the given condition.
    
    ```javascript
    let allPositive = numbers.every(num => num > 0); // true
    ```
    
- `some(callback)`: Returns `true` if **at least one element** satisfies the condition.
    
    ```javascript
    let hasLargeNumber = numbers.some(num => num > 35); // true
    ```
    

---

**9. Flattening Arrays**

- `flat(depth = 1)`: Flattens a nested array up to the specified depth.
    
    ```javascript
    let nested = [1, [2, 3], [4, [5, 6]]];
    let flatArray = nested.flat(2); // [1, 2, 3, 4, 5, 6]
    ```
    
- `flatMap(callback)`: Maps each element to a new array and flattens the result (depth of 1).
    
    ```javascript
    let words = ["hello", "world"];
    let letters = words.flatMap(word => word.split("")); // ["h", "e", "l", "l", "o", "w", "o", "r", "l", "d"]
    ```
    

---

**10. Copying and Filling**

- `copyWithin(target, start, end)`: Copies part of the array to another location within the same array, without changing its length.
    
    ```javascript
    let arr = [1, 2, 3, 4, 5];
    arr.copyWithin(0, 3); // [4, 5, 3, 4, 5]
    ```
    
- `fill(value, start, end)`: Fills part of the array with a static value.
    
    ```javascript
    let filledArray = [1, 2, 3, 4];
    filledArray.fill(0, 1, 3); // [1, 0, 0, 4]
    ```
    

---

**11. Creating Arrays**

- `Array.from()`: Creates a new array from an iterable or array-like object.
    
    ```javascript
    let str = "hello";
    let chars = Array.from(str); // ["h", "e", "l", "l", "o"]
    ```
    
- `Array.of()`: Creates a new array with the provided arguments.
    
    ```javascript
    let numbers = Array.of(1, 2, 3); // [1, 2, 3]
    ```
    

---

**12. Working with Keys and Values**

- `keys()`: Returns an iterator of the array's keys (indices).
    
    ```javascript
    let arr = ["a", "b", "c"];
    let keys = arr.keys();
    console.log([...keys]); // [0, 1, 2]
    ```
    
- `values()`: Returns an iterator of the array's values.
    
    ```javascript
    let values = arr.values();
    console.log([...values]); // ["a", "b", "c"]
    ```
    
- `entries()`: Returns an iterator of the array's key-value pairs.
    
    ```javascript
    let entries = arr.entries();
    for (let [index, value] of entries) {
      console.log(index, value); // Output: 0 "a", 1 "b", 2 "c"
    }
    ```
    

---

**13. Checking the Array**

- `isArray(value)`: Checks if the given value is an array.
    
    ```javascript
    let check = Array.isArray([1, 2, 3]); // true
    let checkString = Array.isArray("not an array"); // false
    ```
    

**14. Generating Array Buffers**

- `ArrayBuffer`: Used to represent a generic, fixed-length raw binary data buffer. While not a traditional array method, it allows working with binary data.
    
    ```javascript
    let buffer = new ArrayBuffer(16); // Creates a buffer of 16 bytes
    console.log(buffer.byteLength); // Output: 16
    ```
    

---

**15. Iterating with `reduceRight`**

- `reduceRight(callback, initialValue)`: Similar to `reduce`, but processes the array elements from right to left.
    
    ```javascript
    let numbers = [1, 2, 3, 4];
    let product = numbers.reduceRight((acc, num) => acc * num, 1); // Output: 24
    ```
    

---

**16. Working with Typed Arrays**  
Although not traditional arrays, JavaScript includes typed arrays like `Int8Array`, `Uint8Array`, and `Float32Array`. They are used for performance-critical tasks such as graphics and audio processing.

Example:

```javascript
let typedArray = new Uint8Array([10, 20, 30]);
console.log(typedArray[1]); // Output: 20
```

---

**17. Sorting with Locale**

- `toLocaleString()`: Converts array elements into a localized string based on the current locale.
    
    ```javascript
    let prices = [123456.78, 87654.32];
    console.log(prices.toLocaleString("en-US", { style: "currency", currency: "USD" })); 
    // Output: $123,456.78,$87,654.32
    ```
    

---

**18. Creating Sparse Arrays**  
You can create arrays with undefined or "empty slots" using the `Array` constructor.

Example:

```javascript
let sparseArray = new Array(5); // Creates an array with 5 empty slots
console.log(sparseArray); // [empty × 5]
```

---

**19. Method Chaining for Transformations**  
While not an exclusive method, arrays allow chaining methods for complex transformations. Example:

```javascript
let result = [1, 2, 3, 4]
  .map(x => x * 2)
  .filter(x => x > 4)
  .reduce((sum, x) => sum + x, 0);
console.log(result); // Output: 14
```

---

**20. Nested Array Manipulation with `Array.prototype.every` and `Array.prototype.some`**  
These methods are also effective for nested arrays:

```javascript
let matrix = [[1, 2], [3, 4], [5, 6]];
let allEven = matrix.every(arr => arr.every(num => num % 2 === 0)); // false
let containsEven = matrix.some(arr => arr.some(num => num % 2 === 0)); // true
```

---

**21. Converting Iterables to Arrays**

- `Array.from()` can convert non-array iterables like NodeLists and Set objects into arrays.
    
    ```javascript
    let set = new Set([1, 2, 3]);
    let arrayFromSet = Array.from(set); // [1, 2, 3]
    ```
    

---

**Rarely Used Properties or Methods**

**22. Length Property Manipulation** You can modify the `.length` property to truncate or expand an array:

```javascript
let arr = [1, 2, 3, 4];
arr.length = 2; // Truncates the array
console.log(arr); // [1, 2]
arr.length = 5; // Expands the array with empty slots
console.log(arr); // [1, 2, empty × 3]
```

---

**23. Experimental Features** As JavaScript evolves, experimental array features may be added (e.g., `Array.prototype.group` and `Array.prototype.groupToMap` in some environments). These group elements based on a callback:

```javascript
let items = [1.2, 1.5, 2.3, 2.8];
let grouped = items.group(num => Math.floor(num)); 
// Output (browser-dependent): {1: [1.2, 1.5], 2: [2.3, 2.8]}
```

---

