## **Core OOP Concepts**


#### **1. Classes**

A `class` is a blueprint for creating objects (instances) with predefined properties and methods.

**Defining a Class:**

```javascript
class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }

  greet() {
    console.log(`Hello, my name is ${this.name}`);
  }
}

let person1 = new Person("Alice", 25);
person1.greet(); // Output: Hello, my name is Alice
```

**Key Features of Classes:**

- `constructor()`: A special method used to initialize object properties.
- Methods: Functions that belong to the class (e.g., `greet()` above).

---

#### **2. Encapsulation**

Encapsulation is the bundling of data and methods into a single unit (an object). It also restricts direct access to some properties.

**Private Fields and Methods:**

```javascript
class BankAccount {
  #balance; // Private field

  constructor(balance) {
    this.#balance = balance;
  }

  getBalance() {
    return this.#balance;
  }
}

let account = new BankAccount(1000);
console.log(account.getBalance()); // Output: 1000
console.log(account.#balance); // Error: Private field
```

---

#### **3. Inheritance**

Inheritance allows a class to inherit properties and methods from another class.

**Example:**

```javascript
class Animal {
  constructor(name) {
    this.name = name;
  }

  eat() {
    console.log(`${this.name} is eating`);
  }
}

class Dog extends Animal {
  bark() {
    console.log(`${this.name} says woof!`);
  }
}

let dog = new Dog("Buddy");
dog.eat(); // Output: Buddy is eating
dog.bark(); // Output: Buddy says woof!
```

**Key Features of Inheritance:**

- `extends`: Used to inherit from another class.
- `super()`: Calls the constructor of the parent class.
    
    ```javascript
    class Cat extends Animal {
      constructor(name, color) {
        super(name); // Calls Animal's constructor
        this.color = color;
      }
    }
    ```
    

---

#### **4. Polymorphism**

Polymorphism allows a method in a child class to override a method in the parent class.

**Example:**

```javascript
class Shape {
  draw() {
    console.log("Drawing a shape");
  }
}

class Circle extends Shape {
  draw() {
    console.log("Drawing a circle");
  }
}

let shape = new Shape();
shape.draw(); // Output: Drawing a shape

let circle = new Circle();
circle.draw(); // Output: Drawing a circle
```

---

#### **5. Abstraction**

Abstraction involves hiding complex implementation details and showing only the necessary features of an object.

JavaScript does not have built-in support for abstract classes, but you can simulate abstraction using parent classes with methods meant to be overridden.

**Example:**

```javascript
class Vehicle {
  start() {
    throw new Error("start() must be implemented by a subclass");
  }
}

class Car extends Vehicle {
  start() {
    console.log("Car started");
  }
}

let car = new Car();
car.start(); // Output: Car started
```

---

