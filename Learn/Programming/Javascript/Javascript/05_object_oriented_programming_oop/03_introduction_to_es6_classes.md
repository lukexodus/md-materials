## Introduction to ES6 Classes


ES6 (ECMAScript 2015) introduced the `class` syntax to JavaScript, providing a cleaner, more intuitive way to create objects and implement inheritance. Classes in JavaScript are primarily syntactic sugar over JavaScript's existing prototype-based inheritance, but they offer a more familiar syntax for developers coming from class-based languages.

**Key Points**

- ES6 classes are not introducing a new object-oriented inheritance model
- They encapsulate JavaScript's prototype-based inheritance in a cleaner syntax
- Classes are special functions under the hood
- Classes are not hoisted (unlike function declarations)

### Class Syntax Basics

```javascript
class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }
  
  greet() {
    return `Hello, my name is ${this.name} and I am ${this.age} years old`;
  }
}

const john = new Person("John", 30);
console.log(john.greet()); // "Hello, my name is John and I am 30 years old"
```

### Class Declarations vs Class Expressions

Just like functions, classes can be defined using declarations or expressions:

```javascript
// Class declaration
class Rectangle {
  constructor(width, height) {
    this.width = width;
    this.height = height;
  }
}

// Class expression (unnamed)
const Circle = class {
  constructor(radius) {
    this.radius = radius;
  }
};

// Class expression (named)
const Square = class Square {
  constructor(side) {
    this.side = side;
  }
};
```

### Constructor Method

The `constructor` method is a special method for creating and initializing objects created with the class. A class can only have one constructor.

```javascript
class Car {
  constructor(make, model, year) {
    this.make = make;
    this.model = model;
    this.year = year;
    this.isRunning = false;
  }
}
```

If you don't explicitly define a constructor, JavaScript adds an empty constructor automatically.

### Class Methods

#### Instance Methods

Instance methods are available on instances of a class and operate on instance data.

```javascript
class Car {
  constructor(make, model) {
    this.make = make;
    this.model = model;
    this.speed = 0;
  }
  
  accelerate(increment) {
    this.speed += increment;
    return this.speed;
  }
  
  brake(decrement) {
    this.speed = Math.max(0, this.speed - decrement);
    return this.speed;
  }
}

const myCar = new Car("Toyota", "Corolla");
myCar.accelerate(30); // 30
myCar.brake(10);      // 20
```

#### Static Methods

Static methods are called on the class itself, not on instances of the class. They cannot access instance data directly.

```javascript
class MathUtils {
  static add(a, b) {
    return a + b;
  }
  
  static multiply(a, b) {
    return a * b;
  }
}

console.log(MathUtils.add(5, 3));      // 8
console.log(MathUtils.multiply(4, 2)); // 8
```

#### Getter and Setter Methods

Classes can use getter and setter methods to control access to class properties.

```javascript
class Temperature {
  constructor(celsius) {
    this._celsius = celsius;
  }
  
  get celsius() {
    return this._celsius;
  }
  
  set celsius(value) {
    if (value < -273.15) {
      throw new Error("Temperature below absolute zero is not possible");
    }
    this._celsius = value;
  }
  
  get fahrenheit() {
    return this._celsius * 9/5 + 32;
  }
  
  set fahrenheit(value) {
    this.celsius = (value - 32) * 5/9;
  }
}

const temp = new Temperature(25);
console.log(temp.celsius);    // 25
console.log(temp.fahrenheit); // 77
temp.fahrenheit = 68;
console.log(temp.celsius);    // 20
```

### Class Fields

ES2022 added support for class fields, allowing you to declare properties directly in the class without using the constructor.

```javascript
class Product {
  // Public fields
  name;
  price;
  
  // Field with initial value
  category = "General";
  
  // Private field (denoted with #)
  #inventoryCount = 0;
  
  constructor(name, price, initialCount) {
    this.name = name;
    this.price = price;
    this.#inventoryCount = initialCount;
  }
  
  getInventoryValue() {
    return this.price * this.#inventoryCount;
  }
  
  #restock(count) {
    this.#inventoryCount += count;
  }
  
  addStock(count) {
    if (count > 0) {
      this.#restock(count);
      return true;
    }
    return false;
  }
}
```

### Private Class Features

Classes support private fields, methods, and accessors, indicated by the `#` prefix.

```javascript
class BankAccount {
  // Private fields
  #balance = 0;
  #transactions = [];
  
  constructor(initialBalance) {
    if (initialBalance > 0) {
      this.#balance = initialBalance;
      this.#addTransaction("initial deposit", initialBalance);
    }
  }
  
  // Private method
  #addTransaction(type, amount) {
    this.#transactions.push({
      type,
      amount,
      date: new Date()
    });
  }
  
  // Public methods that use private features
  deposit(amount) {
    if (amount <= 0) throw new Error("Deposit amount must be positive");
    
    this.#balance += amount;
    this.#addTransaction("deposit", amount);
    return this.#balance;
  }
  
  withdraw(amount) {
    if (amount <= 0) throw new Error("Withdrawal amount must be positive");
    if (amount > this.#balance) throw new Error("Insufficient funds");
    
    this.#balance -= amount;
    this.#addTransaction("withdrawal", amount);
    return this.#balance;
  }
  
  get balance() {
    return this.#balance;
  }
  
  get transactionCount() {
    return this.#transactions.length;
  }
}
```

