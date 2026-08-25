## Reflect API


### Introduction to Reflect

The Reflect API, introduced in ECMAScript 2015 (ES6), provides methods for interceptable JavaScript operations. It is a built-in object that provides methods for JavaScript operations that were previously scattered across various Object methods or implemented as operators. Reflect is not a constructor - you can't use it with the `new` operator or invoke it as a function.

The Reflect API was designed alongside the Proxy API, offering a set of methods that are the same as the handler methods of Proxy objects. This symmetry provides a reliable set of operations for meta-programming in JavaScript.

### Purpose and Benefits

The Reflect API serves several key purposes:

### Grouping of Meta-Programming Operations

Reflect consolidates all meta-programming operations into a single namespace, making JavaScript more organized and predictable.

**Example:**

```javascript
// Before Reflect
Object.defineProperty(obj, 'prop', { value: 42 });

// With Reflect
Reflect.defineProperty(obj, 'prop', { value: 42 });
```

### Reliable Function Application

The `Reflect.apply` method provides a reliable way to call functions with a specified `this` context and arguments.

**Example:**

```javascript
function greet(greeting) {
  return `${greeting}, ${this.name}!`;
}

const user = { name: 'Alice' };

// Using Reflect.apply
const result = Reflect.apply(greet, user, ['Hello']);
console.log(result); // "Hello, Alice!"
```

### Default Operation Behavior

Reflect methods often provide the default behavior for corresponding operations, making it easier to implement certain parts of proxies.

**Example:**

```javascript
const handler = {
  get(target, prop, receiver) {
    console.log(`Getting property "${prop}"`);
    // Forward to the default implementation
    return Reflect.get(target, prop, receiver);
  }
};

const proxy = new Proxy({x: 1, y: 2}, handler);
console.log(proxy.x);
// Output:
// Getting property "x"
// 1
```

### More Meaningful Return Values

Reflect methods return more useful values compared to their Object counterparts.

**Example:**

```javascript
// Object.defineProperty returns the object
const obj = {};
const result1 = Object.defineProperty(obj, 'x', {value: 10});
console.log(result1 === obj); // true

// Reflect.defineProperty returns a boolean indicating success
const result2 = Reflect.defineProperty(obj, 'y', {value: 20});
console.log(result2); // true

// Useful for checking if an operation succeeded
try {
  // This will fail since property is non-configurable
  Object.defineProperty(obj, 'x', {value: 30});
} catch (e) {
  console.log("Operation failed with error:", e);
}

// Using Reflect, we can check directly
if (!Reflect.defineProperty(obj, 'x', {value: 30})) {
  console.log("Operation failed without throwing");
}
```

### Avoiding Exceptions in Common Operations

Reflect methods often replace operations that would throw exceptions with methods that return booleans.

**Example:**

```javascript
// Using delete operator
const obj = { x: 1, y: 2 };
try {
  delete Object.freeze(obj).x; // Will throw in strict mode
  console.log("Deleted property");
} catch (e) {
  console.log("Failed to delete property");
}

// Using Reflect.deleteProperty
const frozen = Object.freeze({ x: 1, y: 2 });
if (Reflect.deleteProperty(frozen, 'x')) {
  console.log("Deleted property");
} else {
  console.log("Failed to delete property");
}
```

### Reflect API Methods

The Reflect API provides 13 static methods that correspond to various fundamental operations in JavaScript.

### Reflect.apply()

Calls a target function with arguments as specified.

**Syntax:**

```javascript
Reflect.apply(target, thisArgument, argumentsList)
```

**Example:**

```javascript
function sum(...numbers) {
  return numbers.reduce((total, num) => total + num, 0);
}

const numbers = [1, 2, 3, 4, 5];
const total = Reflect.apply(sum, null, numbers);
console.log(total); // 15

// Equivalent to:
const total2 = sum.apply(null, numbers);
// or with ES6:
const total3 = sum(...numbers);
```

### Reflect.construct()

Acts like the `new` operator, but as a function. Invokes a constructor with a list of arguments.

**Syntax:**

```javascript
Reflect.construct(target, argumentsList[, newTarget])
```

**Example:**

```javascript
class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }
}

const args = ['Alice', 30];
const alice = Reflect.construct(Person, args);
console.log(alice instanceof Person); // true
console.log(alice.name); // "Alice"
console.log(alice.age); // 30

// Equivalent to:
const bob = new Person('Bob', 25);
```

**Advanced Example with newTarget:**

```javascript
class Person {
  constructor(name) {
    this.name = name;
  }
}

class Employee extends Person {
  constructor(name, title) {
    super(name);
    this.title = title;
  }
}

// Creates an Employee instance but with Person's constructor logic
const john = Reflect.construct(Person, ['John'], Employee);
console.log(john instanceof Person); // true
console.log(john instanceof Employee); // true
console.log(john.name); // "John"
console.log(Object.getPrototypeOf(john) === Employee.prototype); // true
```

### Reflect.defineProperty()

Similar to `Object.defineProperty()`, defines a new property on an object, but returns a boolean.

**Syntax:**

```javascript
Reflect.defineProperty(target, propertyKey, attributes)
```

**Example:**

```javascript
const obj = {};
const success = Reflect.defineProperty(obj, 'name', {
  value: 'John',
  writable: false,
  enumerable: true,
  configurable: true
});

console.log(success); // true
console.log(obj.name); // "John"

// Try to redefine a non-writable property
const failed = Reflect.defineProperty(obj, 'name', {
  value: 'Jane'
});

console.log(failed); // false - operation failed
console.log(obj.name); // Still "John"
```

### Reflect.deleteProperty()

Works like the `delete` operator, but as a function. Returns a boolean indicating success.

**Syntax:**

```javascript
Reflect.deleteProperty(target, propertyKey)
```

**Example:**

```javascript
const obj = { x: 1, y: 2 };
console.log(Reflect.deleteProperty(obj, 'x')); // true
console.log(obj); // { y: 2 }

// Try to delete a non-configurable property
const secured = {};
Object.defineProperty(secured, 'z', { value: 3, configurable: false });
console.log(Reflect.deleteProperty(secured, 'z')); // false
console.log(secured); // { z: 3 }
```

### Reflect.get()

Returns the value of a property on an object.

**Syntax:**

```javascript
Reflect.get(target, propertyKey[, receiver])
```

**Example:**

```javascript
const obj = { x: 1, y: 2 };
console.log(Reflect.get(obj, 'x')); // 1

// With a getter and receiver
const person = {
  _name: 'Alice',
  get name() {
    return this._name;
  }
};

const employee = {
  _name: 'Bob'
};

// Get the name property of person but with employee as this
console.log(Reflect.get(person, 'name', employee)); // "Bob"
```

### Reflect.getOwnPropertyDescriptor()

Similar to `Object.getOwnPropertyDescriptor()`, returns a property descriptor of a property.

**Syntax:**

```javascript
Reflect.getOwnPropertyDescriptor(target, propertyKey)
```

**Example:**

```javascript
const obj = {};
Object.defineProperty(obj, 'hidden', {
  value: 'secret',
  enumerable: false
});

const descriptor = Reflect.getOwnPropertyDescriptor(obj, 'hidden');
console.log(descriptor);
// Output:
// {
//   value: "secret",
//   writable: false,
//   enumerable: false,
//   configurable: false
// }
```

### Reflect.getPrototypeOf()

Similar to `Object.getPrototypeOf()`, returns the prototype of the specified object.

**Syntax:**

```javascript
Reflect.getPrototypeOf(target)
```

**Example:**

```javascript
class Animal {}
class Dog extends Animal {}

const dog = new Dog();
console.log(Reflect.getPrototypeOf(dog) === Dog.prototype); // true
console.log(Reflect.getPrototypeOf(Dog.prototype) === Animal.prototype); // true
```

### Reflect.has()

Works like the `in` operator as a function. Returns a boolean indicating if the property exists on the object or its prototype chain.

**Syntax:**

```javascript
Reflect.has(target, propertyKey)
```

**Example:**

```javascript
const obj = { x: 0 };
Object.defineProperty(obj, 'y', { value: 'hidden', enumerable: false });

console.log(Reflect.has(obj, 'x')); // true
console.log(Reflect.has(obj, 'y')); // true - works with non-enumerable props
console.log(Reflect.has(obj, 'toString')); // true - inherited from Object.prototype
console.log(Reflect.has(obj, 'nonExistent')); // false
```

### Reflect.isExtensible()

Similar to `Object.isExtensible()`, determines if an object is extensible (can have properties added).

**Syntax:**

```javascript
Reflect.isExtensible(target)
```

**Example:**

```javascript
const obj = { x: 1 };
console.log(Reflect.isExtensible(obj)); // true

Object.freeze(obj);
console.log(Reflect.isExtensible(obj)); // false

const sealed = Object.seal({});
console.log(Reflect.isExtensible(sealed)); // false
```

### Reflect.ownKeys()

Returns an array of all property keys (including Symbols) owned by the target object.

**Syntax:**

```javascript
Reflect.ownKeys(target)
```

**Example:**

```javascript
const obj = {
  a: 1,
  b: 2
};

// Add a non-enumerable property
Object.defineProperty(obj, 'hidden', { value: 3, enumerable: false });

// Add a Symbol property
const symbolKey = Symbol('sym');
obj[symbolKey] = 4;

console.log(Reflect.ownKeys(obj));
// Output: ["a", "b", "hidden", Symbol(sym)]

// Compare with Object.keys() which only returns enumerable string keys
console.log(Object.keys(obj)); // ["a", "b"]
```

### Reflect.preventExtensions()

Similar to `Object.preventExtensions()`, prevents adding new properties to an object.

**Syntax:**

```javascript
Reflect.preventExtensions(target)
```

**Example:**

```javascript
const obj = { x: 1 };
console.log(Reflect.preventExtensions(obj)); // true
obj.y = 2; // This will fail silently or throw in strict mode
console.log(obj); // { x: 1 }
console.log(Reflect.isExtensible(obj)); // false
```

### Reflect.set()

Sets a property on an object, returning a boolean indicating if the operation succeeded.

**Syntax:**

```javascript
Reflect.set(target, propertyKey, value[, receiver])
```

**Example:**

```javascript
const obj = { x: 1 };
console.log(Reflect.set(obj, 'y', 2)); // true
console.log(obj); // { x: 1, y: 2 }

// With setters and receiver
const data = {
  _value: 0,
  set value(v) {
    this._value = v;
  }
};

const wrapper = {
  _value: 0
};

Reflect.set(data, 'value', 10, wrapper);
console.log(data._value); // 0
console.log(wrapper._value); // 10
```

### Reflect.setPrototypeOf()

Sets the prototype of an object, returning a boolean indicating success.

**Syntax:**

```javascript
Reflect.setPrototypeOf(target, prototype)
```

**Example:**

```javascript
const obj = {};
const prototype = { inherited: true };

console.log(Reflect.setPrototypeOf(obj, prototype)); // true
console.log(obj.inherited); // true

// Cannot change prototype of non-extensible objects
const frozen = Object.freeze({});
console.log(Reflect.setPrototypeOf(frozen, prototype)); // false
```

### Reflect API with Proxy

One of the primary use cases for the Reflect API is to complement the Proxy API. When implementing proxy handlers, Reflect methods provide an elegant way to forward operations to their default behavior.

**Example:**

```javascript
const target = {
  name: 'target',
  greeting() {
    return `Hello, I'm ${this.name}`;
  }
};

const handler = {
  get(obj, prop, receiver) {
    console.log(`Getting "${prop}" property`);
    return Reflect.get(obj, prop, receiver);
  },
  set(obj, prop, value, receiver) {
    console.log(`Setting "${prop}" property to "${value}"`);
    return Reflect.set(obj, prop, value, receiver);
  },
  apply(target, thisArg, args) {
    console.log(`Calling function with arguments: ${args}`);
    return Reflect.apply(target, thisArg, args);
  }
};

const proxy = new Proxy(target, handler);

// Demonstrating get trap
console.log(proxy.name);
// Output:
// Getting "name" property
// target

// Demonstrating set trap
proxy.name = 'proxy';
// Output:
// Setting "name" property to "proxy"

// Demonstrating apply trap
console.log(proxy.greeting());
// Output:
// Getting "greeting" property
// Calling function with arguments:
// Hello, I'm proxy
```

### Advanced Use Cases

### Implementing Value Validation

**Example:**

```javascript
function createValidator(obj, validations) {
  return new Proxy(obj, {
    set(target, prop, value, receiver) {
      if (validations[prop]) {
        const isValid = validations[prop](value);
        if (!isValid) {
          console.error(`Invalid value for ${prop}: ${value}`);
          return false;
        }
      }
      return Reflect.set(target, prop, value, receiver);
    }
  });
}

const user = createValidator(
  { name: "John", age: 30 },
  {
    name: value => typeof value === 'string' && value.length > 0,
    age: value => typeof value === 'number' && value >= 18
  }
);

user.name = ""; // Error: Invalid value for name: 
console.log(user.name); // Still "John"

user.age = 15; // Error: Invalid value for age: 15
console.log(user.age); // Still 30

user.name = "Alice"; // Valid
console.log(user.name); // "Alice"
```

### Implementing Private Properties

**Example:**

```javascript
function createPrivateStore() {
  const privateStore = new WeakMap();
  
  return {
    get(obj, key) {
      let privateObj = privateStore.get(obj);
      return privateObj ? privateObj[key] : undefined;
    },
    set(obj, key, value) {
      let privateObj = privateStore.get(obj);
      if (!privateObj) {
        privateObj = {};
        privateStore.set(obj, privateObj);
      }
      privateObj[key] = value;
      return true;
    }
  };
}

function createPerson(name, age) {
  const private = createPrivateStore();
  
  return new Proxy({}, {
    get(target, prop, receiver) {
      if (prop === 'name' || prop === 'introduction') {
        // Public properties/methods
        if (prop === 'name') {
          return private.get(target, 'name');
        }
        if (prop === 'introduction') {
          return `I'm ${private.get(target, 'name')}, ${private.get(target, 'age')} years old`;
        }
      }
      return undefined; // Property not accessible
    },
    set(target, prop, value, receiver) {
      if (prop === 'name' && typeof value === 'string') {
        return private.set(target, 'name', value);
      }
      return false; // Property not settable
    }
  });
}

const person = createPerson("John", 30);
console.log(person.name); // "John"
console.log(person.introduction); // "I'm John, 30 years old"
console.log(person.age); // undefined (private)

person.name = "Alice";
console.log(person.introduction); // "I'm Alice, 30 years old"
```

### Method Decorating and Logging

**Example:**

```javascript
function logMethodCalls(obj) {
  const handler = {
    get(target, prop, receiver) {
      const value = Reflect.get(target, prop, receiver);
      
      if (typeof value === 'function') {
        return function(...args) {
          console.log(`Calling ${prop} with args:`, args);
          const start = Date.now();
          
          try {
            const result = Reflect.apply(value, target, args);
            const end = Date.now();
            console.log(`${prop} returned:`, result, `(took ${end - start}ms)`);
            return result;
          } catch (error) {
            console.error(`${prop} threw error:`, error);
            throw error;
          }
        };
      }
      
      return value;
    }
  };
  
  return new Proxy(obj, handler);
}

const calculator = logMethodCalls({
  add(a, b) {
    return a + b;
  },
  divide(a, b) {
    if (b === 0) throw new Error("Division by zero");
    return a / b;
  }
});

calculator.add(5, 3);
// Output:
// Calling add with args: [5, 3]
// add returned: 8 (took 0ms)

try {
  calculator.divide(10, 0);
} catch (e) {
  // Expected to throw
}
// Output:
// Calling divide with args: [10, 0]
// divide threw error: Error: Division by zero
```

### Reactive Programming Primitives

**Example:**

```javascript
function createObservable(target) {
  const handlers = new Map();
  
  function notify(prop, oldValue, newValue) {
    if (handlers.has(prop)) {
      handlers.get(prop).forEach(handler => {
        handler(oldValue, newValue);
      });
    }
  }
  
  return {
    data: new Proxy(target, {
      set(obj, prop, value, receiver) {
        const oldValue = Reflect.get(obj, prop);
        const result = Reflect.set(obj, prop, value, receiver);
        if (result && oldValue !== value) {
          notify(prop, oldValue, value);
        }
        return result;
      }
    }),
    
    observe(prop, handler) {
      if (!handlers.has(prop)) {
        handlers.set(prop, new Set());
      }
      handlers.get(prop).add(handler);
      
      return () => {
        // Return unsubscribe function
        if (handlers.has(prop)) {
          handlers.get(prop).delete(handler);
        }
      };
    }
  };
}

const observable = createObservable({ count: 0, name: 'Unknown' });

const unsubscribe = observable.observe('count', (oldValue, newValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`);
});

observable.data.count += 1;
// Output: Count changed from 0 to 1

observable.data.count += 5;
// Output: Count changed from 1 to 6

observable.data.name = 'John'; // No handler for 'name'

unsubscribe(); // Remove the observer
observable.data.count = 10; // No output
```

### Performance Considerations

When using the Reflect API, be aware of these performance considerations:

1. **Reflect vs Direct Operations**: Reflect methods generally have similar performance to their direct operation counterparts, but there might be minor overhead in some engines.
    
2. **Multiple Reflect Calls**: Using multiple Reflect methods in sequence is slightly less efficient than direct operations.
    
3. **Proxy with Reflect**: Proxies with handlers that use Reflect methods introduce some overhead compared to direct object operations.
    

**Example:**

```javascript
const obj = { x: 1 };

// Performance test
function directAccess() {
  let sum = 0;
  for (let i = 0; i < 1000000; i++) {
    sum += obj.x;
  }
  return sum;
}

function reflectAccess() {
  let sum = 0;
  for (let i = 0; i < 1000000; i++) {
    sum += Reflect.get(obj, 'x');
  }
  return sum;
}

// The reflectAccess function will typically be slightly slower
// than directAccess, but the difference is often negligible
// for most applications.
```

### When to Use Reflect API

The Reflect API is particularly useful in these scenarios:

1. **When implementing Proxy handlers**: Reflect methods provide a clean way to forward operations to their default behavior.
    
2. **For meta-programming**: When you need to manipulate objects in a way that mimics built-in operations.
    
3. **For better error handling**: When you prefer boolean returns over thrown exceptions.
    
4. **For dynamic property access**: When property names are determined at runtime.
    
5. **For more consistent JavaScript**: When you want predictable function-based alternatives to operators.
    

### Browser Compatibility

The Reflect API is well-supported in modern browsers:

- Chrome 49+ (March 2016)
- Firefox 42+ (November 2015)
- Safari 10+ (September 2016)
- Edge 12+ (July 2015)

For older browsers, polyfills are available, though they can't perfectly replicate all features, especially those tied to internal language operations.

### Reflect API vs Object Methods

Many Reflect methods correspond to similar Object methods, but with key differences:

|Operation|Object Method|Reflect Method|Key Difference|
|---|---|---|---|
|Property definition|`Object.defineProperty()`|`Reflect.defineProperty()`|Returns object vs boolean|
|Property deletion|`delete` operator|`Reflect.deleteProperty()`|Throws in strict mode vs returns boolean|
|Prototype access|`Object.getPrototypeOf()`|`Reflect.getPrototypeOf()`|Converts non-objects vs throws TypeError|
|Property descriptor|`Object.getOwnPropertyDescriptor()`|`Reflect.getOwnPropertyDescriptor()`|Converts non-objects vs throws TypeError|
|Key enumeration|`Object.keys()`|`Reflect.ownKeys()`|Only string keys vs all keys including symbols|

### Common Patterns and Best Practices

#### Forward Method in Proxy Handlers

**Pattern:**

```javascript
{
  get(target, prop, receiver) {
    // Custom logic
    return Reflect.get(target, prop, receiver);
  }
}
```

#### Property Existence Check

**Pattern:**

```javascript
if (Reflect.has(obj, 'property')) {
  // Property exists in obj or its prototype chain
}
```

#### Safe Property Access and Modification

**Pattern:**

```javascript
// Safe property access
const value = Reflect.get(obj, dynamicKey);

// Safe property setting
if (!Reflect.set(obj, dynamicKey, newValue)) {
  console.warn(`Could not set ${dynamicKey}`);
}
```

#### Method Borrowing with Apply

**Pattern:**

```javascript
const arrayLike = { 0: 'a', 1: 'b', 2: 'c', length: 3 };
const actualArray = Reflect.apply(Array.prototype.slice, arrayLike, []);
```

### Summary and Key Takeaways

The Reflect API provides a powerful set of methods for JavaScript meta-programming. Its key benefits include:

1. **Consolidation**: Gathering meta-programming operations into a single namespace
2. **Better Returns**: Providing meaningful return values (typically booleans) instead of throwing exceptions
3. **Proxy Integration**: Supporting the Proxy API with corresponding methods
4. **Consistency**: Offering functional alternatives to operators and scattered methods

By understanding and using the Reflect API, developers can write more robust and maintainable code for complex JavaScript applications, especially those that involve deep object manipulation, meta-programming, or custom behavioral control.

---

