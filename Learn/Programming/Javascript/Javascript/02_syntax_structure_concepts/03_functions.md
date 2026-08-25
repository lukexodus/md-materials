## **Functions**


Functions allow you to encapsulate code that can be reused.

1. **Function Declaration**:
    
    ```javascript
    function greet(name) {
      return `Hello, ${name}`;
    }
    console.log(greet("Alice")); // Hello, Alice
    ```
    
2. **Function Expression**:
    
    ```javascript
    const greet = function(name) {
      return `Hi, ${name}`;
    };
    console.log(greet("Bob")); // Hi, Bob
    ```
    
3. **Arrow Functions**: A concise syntax introduced in ES6.
    
    ```javascript
    const add = (a, b) => a + b;
    console.log(add(3, 4)); // 7
    ```
    
4. **Parameters and Default Values**:
    
    ```javascript
    function greet(name = "Guest") {
      return `Hello, ${name}`;
    }
    console.log(greet()); // Hello, Guest
    ```


---

### **Arrow Functions**

Arrow functions (`=>`) are a concise way to write functions, introduced in ES6. They have some distinct features:

#### **1. Shorter Syntax**

- Avoid the `function` keyword, making code more concise.
- Example:
    
    ```javascript
    const add = (a, b) => a + b;
    console.log(add(3, 4)); // 7
    ```

---

#### **2. Implicit Return**

- If the function body contains a single expression, it is automatically returned.
- Example:
    
    ```javascript
    const square = x => x * x;
    console.log(square(5)); // 25
    ```

---

#### **3. `this` Binding**

- Arrow functions do **not have their own `this` context**. Instead, they inherit `this` from the surrounding scope (lexical scoping).
- Useful for avoiding issues with `this` in callbacks.
- Example:
    
    ```javascript
    function Person(name) {
      this.name = name;
      setTimeout(() => {
        console.log(this.name); // Correctly refers to the Person object
      }, 1000);
    }
    const john = new Person("John");
    ```
    
- **Contrast with regular functions**:
    
    ```javascript
    function Person(name) {
      this.name = name;
      setTimeout(function () {
        console.log(this.name); // `this` refers to the global object or `undefined` in strict mode
      }, 1000);
    }
    ```

---

#### **4. Cannot Be Used as Constructors**

- Arrow functions do not have a `prototype` property, so they cannot be used with the `new` keyword to create objects.
- Example:
    ```javascript
    const MyClass = () => {};
    // new MyClass(); // Error: MyClass is not a constructor
    ```

---

#### **5. No `arguments` Object**

- Arrow functions do not have their own `arguments` object. Use rest parameters (`...args`) instead.
- Example:
    
    ```javascript
    const sum = (...args) => args.reduce((total, num) => total + num, 0);
    console.log(sum(1, 2, 3, 4)); // 10
    ```

---

**Summary**

|Feature|Arrow Functions|Regular Functions|
|---|---|---|
|**`this` binding**|Lexical (inherits from the outer scope)|Dynamic (depends on how it's called)|
|**Constructor**|Cannot be used as constructors|Can be used as constructors|
|**Syntax**|Concise|Verbose|
|**Implicit Return**|Supported|Not supported|
|**`arguments` object**|Not available (use rest parameters)|Available|

---

### Normal Funtions vs Anonymous Functions vs Arrow Functions

#### Normal Functions (Function Declarations)

##### Syntax:

```javascript
function greet(name) {
  return `Hello, ${name}`;
}
```

##### Characteristics:

- **Named** function: has a name (`greet`).
- **Hoisted**: Can be called before its declaration due to hoisting.
- Has its own `this`, `arguments`, `super`, and `new.target` bindings.
- Can be used as constructors with `new`.
    

**Example:**

```javascript
console.log(greet("John")); // "Hello, John"
```

---

#### Anonymous Functions (Function Expressions)

##### Syntax:

```javascript
const greet = function(name) {
  return `Hello, ${name}`;
};
```

##### Characteristics:

- **No name** (anonymous), but can be assigned to a variable.
- **Not hoisted**: Cannot be called before the definition.
- Has its own `this`, `arguments`, etc., if defined with `function`.
- Can be used as constructors.
    

#**Example:**

```javascript
console.log(greet("Jane")); // "Hello, Jane"
```

> You can give function expressions names (called _named function expressions_) to help debugging:

```javascript
const greet = function greetFunction(name) { return `Hi ${name}` };
```

---

#### Arrow Functions

##### Syntax:

```javascript
const greet = (name) => `Hello, ${name}`;
```

##### Characteristics:

- **Always anonymous**, assigned to variables.
- **Lexical `this` binding**: Inherits `this` from its surrounding context.
- Does **not** bind `arguments`, `super`, or `new.target`.
- **Cannot** be used as constructors.
- More concise syntax, especially for one-liners.

#**Example:**

```javascript
console.log(greet("Jake")); // "Hello, Jake"
```

---

#### Summary Table

|Feature|Normal Function|Anonymous Function|Arrow Function|
|---|---|---|---|
|Named|✅ Yes|❌ (usually)|❌|
|Hoisted|✅ Yes|❌ No|❌ No|
|`this` binding|Own|Own|**Lexical** (from outer scope)|
|`arguments` object|✅ Yes|✅ Yes|❌ No|
|Can be used as constructor|✅ Yes|✅ Yes|❌ No|
|Short syntax|❌ No|❌ No|✅ Yes|
|Common use cases|General-purpose|Callbacks, one-off|Callbacks, concise logic|

---

### Using Functions as Constructors

**Overview**

In JavaScript, **constructor functions** are functions designed to create and initialize objects. When used with the `new` keyword, they produce **instances** of objects, where each instance inherits properties and methods defined in the constructor.

This approach predates ES6 classes and is the traditional way of doing object-oriented programming in JavaScript.

---

#### Syntax

```javascript
function Person(name, age) {
  this.name = name;
  this.age = age;
  this.sayHello = function() {
    return `Hi, I'm ${this.name}`;
  };
}

const john = new Person("John", 30);
```

The `new` keyword does the following:

1. Creates a new empty object: `{}`
2. Sets the constructor’s prototype as the new object's prototype
3. Binds `this` inside the constructor to the new object
4. Returns the new object unless the constructor returns another object explicitly
    

---

**Key points**

- Constructor functions start with an **uppercase** letter by convention (e.g., `Person`, `Car`).
- Must be called with the `new` keyword to behave as a constructor.
- When not used with `new`, `this` refers to the global object (or `undefined` in strict mode), leading to bugs.
- You can define shared methods on the constructor's `.prototype` to save memory.
    

---

#### Adding methods using `.prototype`

Defining methods inside the constructor creates duplicates for every instance. Use the prototype instead:

```javascript
function Person(name, age) {
  this.name = name;
  this.age = age;
}

Person.prototype.sayHello = function() {
  return `Hi, I'm ${this.name}`;
};

const jane = new Person("Jane", 25);
```

Now, `sayHello` is shared across all `Person` instances.

---

#### Built-in constructors

JavaScript has built-in constructor functions like:

- `Object`
- `Array`
- `Function`
- `Date`
- `RegExp`

But it’s better to use literals (`[]`, `{}`, `/regex/`) when possible for clarity and performance.

---

#### Detecting constructor usage

Inside a function, you can detect if it's being called as a constructor (with `new`) using `new.target`:

```javascript
function Example() {
  if (!new.target) {
    throw new Error("Must use 'new' to call this function");
  }
  this.value = 42;
}
```

---

#### Constructor vs Class

ES6 introduced `class` syntax, which is syntactic sugar over constructor functions:

```javascript
class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }

  sayHello() {
    return `Hi, I'm ${this.name}`;
  }
}
```

Under the hood, this behaves similarly to the constructor/prototype pattern.

---

**Example**

```javascript
function Car(make, model) {
  this.make = make;
  this.model = model;
}

Car.prototype.describe = function() {
  return `This car is a ${this.make} ${this.model}`;
};

const car1 = new Car("Toyota", "Corolla");
const car2 = new Car("Honda", "Civic");

console.log(car1.describe()); // "This car is a Toyota Corolla"
console.log(car2.describe()); // "This car is a Honda Civic"
```

---

**Output**

```
This car is a Toyota Corolla
This car is a Honda Civic
```

---

**Conclusion**

- Constructor functions are a legacy but foundational mechanism for object creation in JavaScript.
- Always use `new` to avoid unintended side effects.
- Use the prototype for method sharing to improve memory efficiency.
- Prefer ES6 `class` for clarity, but understand constructors to maintain and interpret legacy codebases effectively.
    

---

For related topics, study:

- ES6 Classes and Inheritance
- `Object.create()` for prototypal inheritance
- Factory functions vs constructor functions

---

### `super` in Functions

**Overview**

In JavaScript, the `super` keyword is used to call methods from a **parent class** or **object**. It is primarily valid inside:

- **Classes that extend other classes**
- **Object methods using the `[[HomeObject]]` internal slot** (e.g., within object literals or class fields)

`super` is **not** valid in regular function declarations or traditional constructor functions that are not part of class inheritance.

---

**Key Points**

- `super` refers to the **prototype** of the parent class or object.
- Inside a **constructor**, `super(...)` must be called **before** using `this`.
- In methods, `super.method()` calls a method from the **parent prototype**.
- It only works properly in **class-based** or **method context**, not standalone functions.

---

#### **Example 1: Using `super` in a class constructor**

```javascript
class Animal {
  constructor(name) {
    this.name = name;
  }

  speak() {
    return `${this.name} makes a noise.`;
  }
}

class Dog extends Animal {
  constructor(name, breed) {
    super(name); // Calls Animal constructor
    this.breed = breed;
  }

  speak() {
    return `${super.speak()} Bark!`; // Calls Animal's speak
  }
}

const dog = new Dog("Rex", "Labrador");
console.log(dog.speak()); 
```

**Output**
```
Rex makes a noise. Bark!
```

---

#### **Example 2: Using `super` in object literals**

This works only in object methods (not arrow functions or function expressions) and requires the object to have a proper prototype chain:

```javascript
const parent = {
  greet() {
    return "Hello from parent";
  }
};

const child = {
  __proto__: parent,
  greet() {
    return `${super.greet()} and child`;
  }
};

console.log(child.greet());
```

**Output**
```
Hello from parent and child
```

---

#### **super in regular functions**

`super` cannot be used in a regular (non-class) function. It throws a syntax error:

```javascript
function bad() {
  super.greet(); // ❌ SyntaxError: 'super' keyword unexpected
}
```

---

**Conclusion**

- `super` enables access to parent class/object methods and constructors in hierarchical object models.
- Only valid inside **class constructors or methods**, and **object methods** with correct prototype chain.
- Not usable in plain functions or arrow functions lacking class/method context.

---

**Related concepts to study:**
- ES6 `class` and `extends`
- Method binding and `[[HomeObject]]`
- Difference between class methods and arrow functions in class context

---

### `arguments` Object in Function

**Overview**
The `arguments` object is an **array-like** object available within **non-arrow** functions. It contains all the arguments passed to the function, regardless of how many parameters are declared.

It is useful when:
- The number of arguments is not fixed
- You want to access arguments dynamically

---

**Key Points**

- Available only in **regular functions**, **not in arrow functions**
- It’s **array-like** (has `length` and index access), but **not a real array** (no array methods like `.map()`, `.filter()`)
- Automatically available inside function bodies
- Deprecated for **strict parameter handling**; **rest parameters (`...args`)** are preferred in modern JavaScript
- In **non-strict mode**, `arguments[i]` and named parameters are **linked**—changing one updates the other

---

#### **Example: Basic Usage**

```javascript
function showArguments() {
  for (let i = 0; i < arguments.length; i++) {
    console.log(arguments[i]);
  }
}

showArguments("apple", "banana", 123);
```

**Output**
```
apple
banana
123
```

---

#### **Limitations**

- Cannot use `arguments` in arrow functions:
```javascript
const arrow = () => {
  console.log(arguments); // ❌ ReferenceError
};
```

- Cannot use array methods directly:
```javascript
function test() {
  arguments.map(x => x * 2); // ❌ TypeError
}
```

---

#### **Modern Alternative: Rest Parameters**

```javascript
function show(...args) {
  args.forEach(arg => console.log(arg));
}

show("a", "b", "c");
```

Rest parameters:
- Are real arrays
- More readable and flexible
- Work in both regular and arrow functions

---

#### **Example: Arguments in Strict Mode**

```javascript
"use strict";
function modify(a) {
  arguments[0] = 99;
  return a;
}

console.log(modify(10)); // 10 in strict mode; 99 in sloppy mode
```

In strict mode, `arguments` and parameters are **not linked**.

---

**Conclusion**

- `arguments` is a legacy feature useful in some older codebases
- Prefer `...args` (rest parameters) for clarity, flexibility, and modern support
- Avoid using `arguments` in modern development unless maintaining old code

---

**Related topics to study:**
- Rest parameters (`...args`)
- Spread syntax (`...`)
- Arrow functions vs regular functions
- ES5 vs ES6+ function features

---

