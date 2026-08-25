## Under the Hood


### How ES6 Classes Work in the JavaScript Engine

ES6 classes are syntactic sugar over JavaScript's prototype-based inheritance model:

1. Class declarations create a constructor function
2. Class methods are added to the constructor's prototype
3. Static methods are added directly to the constructor
4. Extends sets up the prototype chain

```javascript
class Person {
  constructor(name) {
    this.name = name;
  }
  
  greet() {
    return `Hello, I'm ${this.name}`;
  }
  
  static isHuman() {
    return true;
  }
}

// Roughly equivalent to:
function Person(name) {
  this.name = name;
}

Person.prototype.greet = function() {
  return `Hello, I'm ${this.name}`;
};

Person.isHuman = function() {
  return true;
};
```

### Class Hoisting

Unlike function declarations, class declarations are not hoisted:

```javascript
// This works
sayHello();
function sayHello() {
  console.log("Hello");
}

// This throws a ReferenceError
const p = new Person(); // ReferenceError
class Person {}
```

### ES6 Classes vs Traditional Constructors

Classes provide several advantages over traditional constructor functions:

1. More intuitive syntax for OOP developers
2. Cleaner inheritance with `extends` and `super`
3. Private fields and methods (with `#` prefix)
4. Static methods and fields without manual assignment
5. Enforced `new` operator (classes cannot be called without `new`)

