## Advanced Class Patterns


### Mixins

Mixins allow for composition over inheritance by adding methods to a class from multiple sources.

```javascript
// Mixin that adds event handling capabilities
const EventMixin = {
  on(eventName, handler) {
    if (!this._eventHandlers) this._eventHandlers = {};
    if (!this._eventHandlers[eventName]) this._eventHandlers[eventName] = [];
    this._eventHandlers[eventName].push(handler);
  },
  
  off(eventName, handler) {
    if (!this._eventHandlers || !this._eventHandlers[eventName]) return;
    this._eventHandlers[eventName] = this._eventHandlers[eventName]
      .filter(h => h !== handler);
  },
  
  trigger(eventName, ...args) {
    if (!this._eventHandlers || !this._eventHandlers[eventName]) return;
    this._eventHandlers[eventName].forEach(handler => handler.apply(this, args));
  }
};

// Applying the mixin to a class
class User {
  constructor(name) {
    this.name = name;
  }
}

// Add the mixin methods to User.prototype
Object.assign(User.prototype, EventMixin);

const user = new User("John");

// Now user can use event methods
user.on("login", () => console.log(`${user.name} logged in`));
user.trigger("login"); // Outputs: "John logged in"
```

### Factory Pattern with Classes

The factory pattern creates objects without exposing instantiation logic.

```javascript
class Vehicle {
  constructor(options) {
    this.type = options.type;
    this.wheels = options.wheels;
    this.engine = options.engine;
  }
  
  getDescription() {
    return `This is a ${this.type} with ${this.wheels} wheels and a ${this.engine} engine.`;
  }
}

// Factory for creating different types of vehicles
class VehicleFactory {
  static createCar() {
    return new Vehicle({
      type: "car",
      wheels: 4,
      engine: "gasoline"
    });
  }
  
  static createMotorcycle() {
    return new Vehicle({
      type: "motorcycle",
      wheels: 2,
      engine: "gasoline"
    });
  }
  
  static createElectricCar() {
    return new Vehicle({
      type: "car",
      wheels: 4,
      engine: "electric"
    });
  }
}

const car = VehicleFactory.createCar();
console.log(car.getDescription()); // "This is a car with 4 wheels and a gasoline engine."
```

### Class Composition

Composition is an alternative to inheritance where classes delegate to components rather than inheriting.

```javascript
class Engine {
  start() {
    return "Engine started";
  }
  
  stop() {
    return "Engine stopped";
  }
}

class Wheels {
  rotate() {
    return "Wheels rotating";
  }
  
  brake() {
    return "Wheels stopped";
  }
}

class Car {
  constructor() {
    this.engine = new Engine();
    this.wheels = new Wheels();
  }
  
  start() {
    return this.engine.start();
  }
  
  drive() {
    return this.wheels.rotate();
  }
  
  stop() {
    const engineStatus = this.engine.stop();
    const wheelsStatus = this.wheels.brake();
    return `${engineStatus}, ${wheelsStatus}`;
  }
}

const car = new Car();
console.log(car.start()); // "Engine started"
console.log(car.drive()); // "Wheels rotating"
console.log(car.stop()); // "Engine stopped, Wheels stopped"
```

