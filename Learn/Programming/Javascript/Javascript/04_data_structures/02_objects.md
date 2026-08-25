## Objects


Objects are key-value pairs that allow you to group and manage related data and functionality. They are one of the foundational building blocks of JavaScript.

---

### **Basics of Objects**

- Declaring an Object:
    
    ```javascript
    let person = {
      name: "John",
      age: 30,
      isStudent: false
    };
    ```
    
- Accessing Properties:
    
    ```javascript
    console.log(person.name); // Dot notation: "John"
    console.log(person["age"]); // Bracket notation: 30
    ```
    
- Adding/Updating Properties:
    
    ```javascript
    person.city = "New York"; // Adds 'city'
    person.age = 31;         // Updates 'age'
    ```
    
- Removing Properties:
    
    ```javascript
    delete person.isStudent; // Removes 'isStudent'
    ```
    

---

### **Object Methods**

- Adding methods to an object:
    
    ```javascript
    let person = {
      name: "John",
      greet() {
        console.log(`Hello, my name is ${this.name}`);
      }
    };
    person.greet(); // Output: Hello, my name is John
    ```
    
- Using `this`: Refers to the object it belongs to.
    
    ```javascript
    let car = {
      brand: "Toyota",
      getBrand() {
        return this.brand;
      }
    };
    console.log(car.getBrand()); // Output: "Toyota"
    ```
    

---

### **Built-in Object Methods**

1. **Object.keys(obj)**: Returns an array of an object's property names.
    
    ```javascript
    let keys = Object.keys(person); // ["name", "age", "city"]
    ```
    
2. **Object.values(obj)**: Returns an array of an object's values.
    
    ```javascript
    let values = Object.values(person); // ["John", 31, "New York"]
    ```
    
3. **Object.entries(obj)**: Returns an array of `[key, value]` pairs.
    
    ```javascript
    let entries = Object.entries(person);
    // [["name", "John"], ["age", 31], ["city", "New York"]]
    ```
    
4. **Object.assign(target, source)**: Copies properties from one or more objects to a target object.
    
    ```javascript
    let additionalInfo = { isEmployed: true };
    let updatedPerson = Object.assign({}, person, additionalInfo);
    console.log(updatedPerson); // { name: "John", age: 31, city: "New York", isEmployed: true }
    ```
    
5. **Object.freeze(obj)**: Prevents modifications to the object.
    
    ```javascript
    Object.freeze(person);
    person.age = 40; // No effect
    ```
    
6. **Object.seal(obj)**: Allows modifications to existing properties but prevents adding/removing properties.
    
    ```javascript
    Object.seal(person);
    person.age = 40; // Works
    person.city = "London"; // No effect
    ```
    

---

### **Advanced Object Concepts**

1. **Computed Property Names**: Allows dynamic creation of property keys.
    
    ```javascript
    let key = "dynamicKey";
    let obj = { [key]: "value" };
    console.log(obj); // { dynamicKey: "value" }
    ```
    
2. **Destructuring Objects**: Extract specific properties from an object.
    
    ```javascript
    let { name, age } = person;
    console.log(name); // "John"
    console.log(age);  // 31
    ```
    
3. **Spread Operator (`...`)**: Copies all properties of an object into a new object.
    
    ```javascript
    let newPerson = { ...person, country: "USA" };
    console.log(newPerson); // { name: "John", age: 31, city: "New York", country: "USA" }
    ```
    
4. **Prototype and Inheritance**: Objects can inherit properties and methods through prototypes.
    
    ```javascript
    let animal = { eats: true };
    let dog = Object.create(animal);
    console.log(dog.eats); // true
    ```
    

---

### **Common Use Cases**

- **Storing configurations**:
    
    ```javascript
    let config = {
      theme: "dark",
      language: "en-US",
      showNotifications: true
    };
    ```
    
- **Modeling entities**:
    
    ```javascript
    let book = {
      title: "JavaScript Basics",
      author: "John Doe",
      pages: 250,
      read() {
        console.log(`Reading "${this.title}" by ${this.author}`);
      }
    };
    book.read(); // Reading "JavaScript Basics" by John Doe
    ```
    

---

### **Object Methods for Comparison and Checking**

1. **Object.is(value1, value2)**: Compares two values for strict equality, including special cases like `NaN`.
    
    ```javascript
    console.log(Object.is(NaN, NaN)); // true
    ```
    
2. **hasOwnProperty(key)**: Checks if a property exists directly on the object (not inherited).
    
    ```javascript
    console.log(person.hasOwnProperty("name")); // true
    console.log(person.hasOwnProperty("toString")); // false
    ```
    
3. **Property Enumeration**: Use `for...in` to loop through enumerable properties of an object.
    
    ```javascript
    for (let key in person) {
      console.log(`${key}: ${person[key]}`);
    }
    ```
    

