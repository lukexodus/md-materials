## Strategy Pattern Functional Style


The strategy pattern becomes remarkably simple in functional programming by treating strategies as first-class functions rather than encapsulating them in separate classes. Instead of defining a strategy interface and multiple concrete implementations, you pass functions directly as arguments.

**Core Concept**

Replace polymorphic strategy objects with higher-order functions. The context that would normally hold a strategy object now accepts a function parameter. This eliminates the need for strategy interfaces, concrete strategy classes, and the boilerplate associated with object instantiation.

**Implementation Approach**

Define your strategies as pure functions with identical signatures. The function that uses these strategies (the context) accepts a strategy function as a parameter. You can store strategies in data structures like maps or objects for dynamic selection at runtime.

```javascript
// Strategies as simple functions
const aggressive = (health, enemy) => enemy.health < health * 0.5 ? 'attack' : 'defend';
const defensive = (health, enemy) => health > 50 ? 'defend' : 'flee';
const balanced = (health, enemy) => enemy.health < health ? 'attack' : 'defend';

// Context function that accepts strategy
const decideAction = (strategy, health, enemy) => strategy(health, enemy);

// Usage
decideAction(aggressive, 80, { health: 30 }); // 'attack'
decideAction(defensive, 80, { health: 30 }); // 'defend'
```

**Dynamic Strategy Selection**

Store strategies in a lookup structure and select them by key. This is particularly useful when strategy choice depends on runtime conditions or configuration.

```javascript
const strategies = {
  aggressive,
  defensive,
  balanced
};

const executeWithStrategy = (strategyName, health, enemy) => {
  const strategy = strategies[strategyName];
  return strategy(health, enemy);
};

// Runtime selection
const currentStrategy = userPreference; // 'aggressive', 'defensive', etc.
executeWithStrategy(currentStrategy, 75, { health: 40 });
```

**Composition of Strategies**

Strategies can be composed to create more complex behavior. Use function composition or combinators to build sophisticated strategies from simpler ones.

```javascript
const withLogging = (strategy) => (health, enemy) => {
  const result = strategy(health, enemy);
  console.log(`Strategy decided: ${result}`);
  return result;
};

const withFallback = (primaryStrategy, fallbackStrategy) => (health, enemy) => {
  try {
    return primaryStrategy(health, enemy);
  } catch (e) {
    return fallbackStrategy(health, enemy);
  }
};

// Composed strategy
const loggedAggressive = withLogging(aggressive);
const safeAggressive = withFallback(aggressive, defensive);
```

**Partial Application for Configuration**

Use partial application to pre-configure strategies with specific parameters, creating specialized variants without modifying the original functions.

```javascript
const priceCalculation = (discountFn, taxRate, basePrice) => {
  const discounted = discountFn(basePrice);
  return discounted * (1 + taxRate);
};

// Strategy functions
const noDiscount = (price) => price;
const percentDiscount = (percent) => (price) => price * (1 - percent);
const fixedDiscount = (amount) => (price) => Math.max(0, price - amount);

// Pre-configured strategies
const memberPricing = (basePrice) => priceCalculation(percentDiscount(0.15), 0.08, basePrice);
const vipPricing = (basePrice) => priceCalculation(percentDiscount(0.25), 0.08, basePrice);
```

**Advantages Over OOP Strategy**

This approach eliminates class hierarchies and boilerplate. Functions are lighter weight than objects, easier to test in isolation, and can be composed freely. Strategy selection becomes simple function passing rather than object instantiation and dependency injection. The code is more concise and the intent is clearer—you're choosing behavior, not managing objects.

---

