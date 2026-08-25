## Composition vs Inheritance


Composition and inheritance represent fundamentally different approaches to code reuse and relationship modeling. While inheritance establishes "is-a" relationships through class hierarchies, composition builds functionality through "has-a" relationships by combining smaller, focused units.

**Key Points:**

- Inheritance creates tight coupling through parent-child relationships
- Composition favors loose coupling and flexibility
- Functional programming strongly prefers composition over inheritance
- Composition enables runtime behavior changes; inheritance is compile-time fixed
- The phrase "favor composition over inheritance" comes from the Gang of Four design patterns

Inheritance problems manifest in several ways: the fragile base class problem (changes to parent break children), the gorilla-banana problem (wanting a banana but getting the entire gorilla and jungle), and deep hierarchies that become rigid and hard to modify.

**Example of inheritance brittleness:**

```javascript
class Animal {
  constructor(name) {
    this.name = name;
  }
  
  move() {
    return `${this.name} moves`;
  }
}

class Bird extends Animal {
  fly() {
    return `${this.name} flies`;
  }
}

class Penguin extends Bird {
  // Problem: Penguins inherit fly() but can't fly
  // Must override or throw error
  fly() {
    throw new Error("Penguins can't fly");
  }
}
```

This demonstrates the Liskov Substitution Principle violation—a Penguin cannot substitute for a Bird in all contexts.

**Example of composition approach:**

```javascript
const canMove = (state) => ({
  move: () => `${state.name} moves`
});

const canFly = (state) => ({
  fly: () => `${state.name} flies`
});

const canSwim = (state) => ({
  swim: () => `${state.name} swims`
});

const createBird = (name) => {
  const state = { name };
  return {
    ...canMove(state),
    ...canFly(state)
  };
};

const createPenguin = (name) => {
  const state = { name };
  return {
    ...canMove(state),
    ...canSwim(state)
    // No fly capability—only compose what's needed
  };
};
```

Each capability is a self-contained function that adds behavior. Objects compose exactly the capabilities they need without inheriting unwanted baggage.

**Functional composition patterns:**

Function composition (not object composition):

```javascript
const compose = (...fns) => (x) => 
  fns.reduceRight((acc, fn) => fn(acc), x);

const addTax = (rate) => (price) => price * (1 + rate);
const addShipping = (cost) => (price) => price + cost;
const formatCurrency = (price) => `$${price.toFixed(2)}`;

const calculateTotal = compose(
  formatCurrency,
  addShipping(5),
  addTax(0.08)
);

calculateTotal(100); // "$113.00"
```

Higher-order functions for behavior composition:

```javascript
const withLogging = (fn) => (...args) => {
  console.log(`Calling ${fn.name} with`, args);
  const result = fn(...args);
  console.log(`Result:`, result);
  return result;
};

const withRetry = (fn, maxAttempts = 3) => async (...args) => {
  for (let i = 0; i < maxAttempts; i++) {
    try {
      return await fn(...args);
    } catch (error) {
      if (i === maxAttempts - 1) throw error;
    }
  }
};

const fetchUser = async (id) => { /* ... */ };
const robustFetchUser = withRetry(withLogging(fetchUser));
```

**Key Points on choosing composition:**

- Prefer composition when relationships are dynamic or may change
- Use composition to avoid deep inheritance hierarchies
- Inheritance may still be appropriate for true taxonomic relationships with stable hierarchies
- Composition enables better testing through isolated, pure functions
- Functional composition eliminates state mutation concerns inherent in class hierarchies

The functional paradigm naturally gravitates toward composition because functions are first-class citizens that can be combined, passed, and returned freely, making composition the natural default rather than a conscious choice against inheritance.

