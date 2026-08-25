## Inheritance in ES6 Classes


### Extending Classes with `extends`

The `extends` keyword creates a class that is a child of another class.

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
  speak() {
    return `${this.name} barks.`;
  }
}

const dog = new Dog("Rex");
console.log(dog.speak()); // "Rex barks."
```

### Using `super` Keyword

The `super` keyword is used to call corresponding methods of the parent class.

#### In Constructors

When used in a constructor, `super()` calls the parent class's constructor.

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
    super(name); // Call the parent constructor with name
    this.breed = breed;
  }
  
  speak() {
    return `${this.name} (a ${this.breed}) barks.`;
  }
  
  description() {
    return `${this.name} is a ${this.breed}.`;
  }
}

const dog = new Dog("Rex", "German Shepherd");
console.log(dog.speak());      // "Rex (a German Shepherd) barks."
console.log(dog.description()); // "Rex is a German Shepherd."
```

#### In Methods

The `super` keyword can also be used to call a parent's method.

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
  speak() {
    return `${super.speak()} But specifically, ${this.name} barks.`;
  }
}

const dog = new Dog("Rex");
console.log(dog.speak()); // "Rex makes a noise. But specifically, Rex barks."
```

### Inheritance Chain

Classes can form inheritance chains of arbitrary length.

```javascript
class Animal {
  constructor(name) {
    this.name = name;
  }
  
  eat() {
    return `${this.name} eats.`;
  }
}

class Dog extends Animal {
  constructor(name, breed) {
    super(name);
    this.breed = breed;
  }
  
  bark() {
    return `${this.name} barks.`;
  }
}

class ServiceDog extends Dog {
  constructor(name, breed, task) {
    super(name, breed);
    this.task = task;
  }
  
  performTask() {
    return `${this.name} performs ${this.task}.`;
  }
}

const serviceDog = new ServiceDog("Buddy", "Labrador", "guiding");
console.log(serviceDog.eat());        // "Buddy eats."
console.log(serviceDog.bark());       // "Buddy barks."
console.log(serviceDog.performTask()); // "Buddy performs guiding."
```

### Abstract Classes

JavaScript doesn't have built-in support for abstract classes, but you can simulate them:

```javascript
class AbstractShape {
  constructor() {
    if (new.target === AbstractShape) {
      throw new Error("Cannot instantiate abstract class");
    }
  }
  
  area() {
    throw new Error("Method 'area()' must be implemented");
  }
  
  perimeter() {
    throw new Error("Method 'perimeter()' must be implemented");
  }
}

class Circle extends AbstractShape {
  constructor(radius) {
    super();
    this.radius = radius;
  }
  
  area() {
    return Math.PI * this.radius * this.radius;
  }
  
  perimeter() {
    return 2 * Math.PI * this.radius;
  }
}

// This works
const circle = new Circle(5);
console.log(circle.area()); // ~78.54

// This throws an error
// const shape = new AbstractShape(); // Error: Cannot instantiate abstract class
```

