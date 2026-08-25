## Object Composition in JavaScript


### Understanding Object Composition

Object composition is a design approach where complex objects are built by combining simpler objects or behaviors instead of using inheritance hierarchies. In JavaScript, a language with prototypal inheritance and dynamic nature, composition provides a powerful and flexible way to structure code.

**Key Points:**

- Composition favors "has-a" relationships over "is-a" relationships
- Follows the principle "compose what an object does rather than what it is"
- Increases code reusability and flexibility
- Reduces tight coupling between components
- Aligns with the JavaScript programming paradigm

### Composition vs. Inheritance

Composition offers several advantages over classical inheritance:

- Avoids the "fragile base class problem" where changes to base classes can unexpectedly break derived classes
- Prevents deep inheritance hierarchies that are difficult to understand and maintain
- Enables runtime behavior modification by adding or removing components
- Allows for more granular code reuse without forcing hierarchical relationships
- Better represents complex relationships between objects

### Core Composition Techniques in JavaScript

#### Object Mixing

The simplest form of composition involves combining properties from multiple objects:

```javascript
const hasName = (name) => ({
  getName: () => name,
  setName: (newName) => name = newName
});

const canSpeak = () => ({
  speak: (phrase) => console.log(phrase)
});

const person = {
  ...hasName('Alice'),
  ...canSpeak()
};

person.speak(person.getName()); // Outputs: Alice
```

#### Factory Functions

Factory functions create objects with composed behaviors without using `new` or classes:

```javascript
function createPerson(name) {
  return {
    ...hasName(name),
    ...canSpeak(),
    ...canWalk()
  };
}

const alice = createPerson('Alice');
```

#### Higher-Order Functions

Functions that create or enhance objects with specific capabilities:

```javascript
const withLogging = (obj) => ({
  ...obj,
  log: (message) => console.log(`[LOG]: ${message}`)
});

const withData = (obj, data) => ({
  ...obj,
  getData: () => data,
  setData: (newData) => data = newData
});

const component = pipe(
  withLogging,
  obj => withData(obj, { count: 0 })
)({});
```

### Common Composition Design Patterns

#### Mixin Pattern

Mixins are reusable chunks of code that can be added to objects to extend their functionality:

```javascript
const FlyMixin = {
  fly() {
    console.log(`${this.name} is flying!`);
  }
};

const SwimMixin = {
  swim() {
    console.log(`${this.name} is swimming!`);
  }
};

const Duck = {
  name: 'Duck',
  quack() {
    console.log('Quack!');
  }
};

Object.assign(Duck, FlyMixin, SwimMixin);
Duck.fly(); // Duck is flying!
```

#### Decorator Pattern

Decorators add behavior to objects dynamically without affecting other objects of the same class:

```javascript
function withPersistence(component) {
  return {
    ...component,
    save() {
      localStorage.setItem(this.id, JSON.stringify(this.state));
    },
    load() {
      this.state = JSON.parse(localStorage.getItem(this.id)) || this.state;
    }
  };
}

const counterComponent = {
  id: 'counter',
  state: { count: 0 },
  increment() { this.state.count++; }
};

const persistentCounter = withPersistence(counterComponent);
persistentCounter.increment();
persistentCounter.save();
```

#### Strategy Pattern

Enables selecting an algorithm's implementation at runtime:

```javascript
const sortStrategies = {
  ascending: (a, b) => a - b,
  descending: (a, b) => b - a,
  alphabetical: (a, b) => String(a).localeCompare(String(b))
};

function createSortableCollection(items, defaultStrategy = 'ascending') {
  return {
    items,
    sort(strategy = defaultStrategy) {
      return [...items].sort(sortStrategies[strategy]);
    }
  };
}

const numbers = createSortableCollection([5, 2, 9, 1]);
console.log(numbers.sort('descending')); // [9, 5, 2, 1]
```

#### Observer Pattern

Creates a subscription model where objects (observers) are notified of changes:

```javascript
function createObservable() {
  const observers = new Set();
  
  return {
    subscribe(observer) {
      observers.add(observer);
      return () => observers.delete(observer);
    },
    notify(data) {
      observers.forEach(observer => observer(data));
    }
  };
}

const store = (() => {
  const state = { count: 0 };
  const observable = createObservable();
  
  return {
    increment() { 
      state.count++;
      observable.notify(state);
    },
    getState() { return {...state}; },
    subscribe: observable.subscribe
  };
})();

store.subscribe(state => console.log('State changed:', state));
store.increment(); // State changed: { count: 1 }
```

### Functional Composition

JavaScript's functional nature makes it excellent for function composition:

```javascript
// Function composition helper
const compose = (...fns) => x => fns.reduceRight((y, f) => f(y), x);

// Reusable functions
const addTax = rate => price => price * (1 + rate);
const formatPrice = price => `$${price.toFixed(2)}`;
const discount = amount => price => price - amount;

// Composed function
const calculateFinalPrice = compose(
  formatPrice,
  addTax(0.1),
  discount(5)
);

console.log(calculateFinalPrice(100)); // "$104.50"
```

### Module Pattern

Encapsulates functionality while exposing a controlled public API:

```javascript
const userRepository = (() => {
  // Private state
  const users = [];
  
  // Private function
  const findUserIndex = id => users.findIndex(user => user.id === id);
  
  // Public API
  return {
    add(user) {
      users.push(user);
      return user;
    },
    remove(id) {
      const index = findUserIndex(id);
      if (index !== -1) {
        users.splice(index, 1);
        return true;
      }
      return false;
    },
    get(id) {
      return users.find(user => user.id === id);
    },
    getAll() {
      return [...users];
    }
  };
})();
```

### SOLID Principles and Composition

Object composition aligns well with SOLID principles:

- **Single Responsibility Principle**: Each composed behavior has a single responsibility
- **Open/Closed Principle**: Systems can be extended with new behaviors without modification
- **Liskov Substitution Principle**: Composed objects can be replaced with their constituent parts
- **Interface Segregation Principle**: Small, focused behaviors instead of large interfaces
- **Dependency Inversion Principle**: Components depend on abstractions, not concrete implementations

### Real-World Example: Component Composition

A practical example showing UI component composition:

```javascript
// Component behaviors
const withState = (initialState) => ({
  state: {...initialState},
  setState(newState) {
    this.state = {...this.state, ...newState};
    this.render();
  }
});

const withLifecycle = () => ({
  mount() {
    console.log('Component mounted');
    this.render();
  },
  unmount() {
    console.log('Component unmounted');
  }
});

const withRendering = (renderFn, container) => ({
  render() {
    container.innerHTML = renderFn(this.state);
  }
});

// Component factory
function createComponent(initialState, renderFn, container) {
  return {
    ...withState(initialState),
    ...withLifecycle(),
    ...withRendering(renderFn, container)
  };
}

// Usage
const counterComponent = createComponent(
  { count: 0 },
  state => `<div>Count: ${state.count}</div>
           <button id="increment">Increment</button>`,
  document.getElementById('app')
);

counterComponent.mount();
document.getElementById('increment').addEventListener(
  'click', 
  () => counterComponent.setState({count: counterComponent.state.count + 1})
);
```

### Performance Considerations

When implementing object composition:

- Avoid excessive copying of large objects
- Consider using WeakMaps for private data instead of closures for better memory management
- Use Object.freeze() for immutable objects
- Implement object pooling for frequently created and discarded objects
- Be mindful of the prototype chain depth when combining it with composition

### Testing Composed Objects

Composition creates more testable code:

```javascript
// Behavior to test in isolation
const withCounter = () => ({
  count: 0,
  increment() { this.count++; },
  decrement() { this.count--; }
});

// Test
describe('withCounter', () => {
  test('should increment count', () => {
    const obj = withCounter();
    obj.increment();
    expect(obj.count).toBe(1);
  });
  
  test('should decrement count', () => {
    const obj = withCounter();
    obj.decrement();
    expect(obj.count).toBe(-1);
  });
});
```

### Best Practices for Object Composition

- Keep behaviors small and focused
- Avoid shared state between behaviors when possible
- Use meaningful names that describe what the behavior does
- Prefer immutability when operating on data
- Document the expected interface for each behavior
- Handle conflicts between composed behaviors explicitly
- Consider using TypeScript interfaces to define behavior contracts

### Advanced Composition with Proxies

ES6 Proxies allow for powerful behavior interception:

```javascript
const withValidation = (target, validators) => {
  return new Proxy(target, {
    set(obj, prop, value) {
      if (validators[prop]) {
        const valid = validators[prop](value);
        if (!valid) {
          throw new Error(`Invalid value for ${prop}`);
        }
      }
      obj[prop] = value;
      return true;
    }
  });
};

const user = withValidation(
  { name: 'John', age: 30 },
  {
    name: value => typeof value === 'string' && value.length > 0,
    age: value => typeof value === 'number' && value >= 18
  }
);

user.age = 25; // Works
try {
  user.age = 15; // Throws error
} catch (e) {
  console.error(e.message);
}
```

**Conclusion:** Object composition in JavaScript provides a flexible, powerful approach to building modular, maintainable code. By favoring composition over inheritance, developers can create systems that are easier to understand, test, and extend. The various composition patterns—mixins, decorators, factories, and functional composition—offer different tools for different scenarios, allowing developers to choose the right approach for each specific problem. As JavaScript development continues to evolve, composition remains a foundational technique for creating robust, reusable code structures.

Consider exploring related topics such as immutable data structures, functional programming paradigms, and reactive programming patterns to further enhance your object composition techniques.

---

