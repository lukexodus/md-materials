## Closure Use Cases


Closures provide powerful patterns for managing state, creating abstractions, and implementing various programming techniques.

### Data Privacy and Encapsulation

Closures enable private variables that cannot be accessed directly from outside, implementing information hiding.

**Example:**

```javascript
function createBankAccount(initialBalance) {
  let balance = initialBalance;  // Private variable
  
  return {
    deposit(amount) {
      balance += amount;
      return balance;
    },
    withdraw(amount) {
      if (amount <= balance) {
        balance -= amount;
        return balance;
      }
      throw new Error('Insufficient funds');
    },
    getBalance() {
      return balance;
    }
  };
}

const account = createBankAccount(100);
console.log(account.deposit(50));    // 150
console.log(account.withdraw(30));   // 120
console.log(account.balance);        // undefined (private)
```

**Output:**

```
150
120
undefined
```

### Partial Application and Currying

Closures capture arguments to create specialized functions from general ones.

**Example:**

```javascript
function multiply(a) {
  return function(b) {
    return a * b;
  };
}

const double = multiply(2);
const triple = multiply(3);

console.log(double(5));  // 10
console.log(triple(5));  // 15
```

**Output:**

```
10
15
```

### Callback Functions with Context

Closures preserve context when passing functions as callbacks.

**Example:**

```javascript
function createTimer(name) {
  let seconds = 0;
  
  return function() {
    seconds++;
    console.log(`${name}: ${seconds} seconds`);
  };
}

const timer1 = createTimer('Timer A');
const timer2 = createTimer('Timer B');

setInterval(timer1, 1000);
setInterval(timer2, 1000);
```

Each timer maintains its own `name` and `seconds` via closure.

### Memoization

Closures cache function results for performance optimization.

**Example:**

```javascript
function memoize(fn) {
  const cache = {};  // Captured by returned function
  
  return function(...args) {
    const key = JSON.stringify(args);
    
    if (key in cache) {
      return cache[key];
    }
    
    const result = fn(...args);
    cache[key] = result;
    return result;
  };
}

const slowFibonacci = (n) => {
  if (n <= 1) return n;
  return slowFibonacci(n - 1) + slowFibonacci(n - 2);
};

const fastFibonacci = memoize(slowFibonacci);
console.log(fastFibonacci(10));  // Computed
console.log(fastFibonacci(10));  // Retrieved from cache
```

### Iterator Generators

Closures maintain iteration state across multiple calls.

**Example:**

```javascript
function createIterator(array) {
  let index = 0;
  
  return {
    next() {
      if (index < array.length) {
        return { value: array[index++], done: false };
      }
      return { done: true };
    },
    hasNext() {
      return index < array.length;
    }
  };
}

const iter = createIterator([1, 2, 3]);
console.log(iter.next());  // { value: 1, done: false }
console.log(iter.next());  // { value: 2, done: false }
```

### Event Handlers

Closures capture state for event-driven programming.

**Example:**

```javascript
function setupButtons() {
  const buttons = ['Button 1', 'Button 2', 'Button 3'];
  
  buttons.forEach((label, index) => {
    // Closure captures both label and index
    document.getElementById(`btn${index}`).onclick = function() {
      console.log(`${label} clicked at index ${index}`);
    };
  });
}
```

### Module Pattern

Closures create modules with public and private members.

**Example:**

```javascript
const calculator = (function() {
  let memory = 0;  // Private
  
  return {
    add(x) { memory += x; return this; },
    subtract(x) { memory -= x; return this; },
    multiply(x) { memory *= x; return this; },
    getResult() { return memory; },
    clear() { memory = 0; return this; }
  };
})();

calculator.add(10).multiply(2).subtract(5);
console.log(calculator.getResult());  // 15
```

**Output:**

```
15
```

**Key Points:**

- Closures enable state management without global variables
- Provide encapsulation and data hiding mechanisms
- Enable functional programming patterns like partial application
- Critical for asynchronous programming and callbacks
- Support lazy evaluation and deferred computation
- Form the basis of module systems and namespacing

---

