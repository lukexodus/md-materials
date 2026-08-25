## Proxies


### Fundamentals of JavaScript Proxies

JavaScript Proxies, introduced in ES6 (ES2015), provide a powerful mechanism for intercepting and customizing operations on objects. A Proxy wraps an object (called the target) and allows you to define custom behavior for fundamental operations like property access, assignment, enumeration, function invocation, and more.

**Key Points**:

- Proxies enable metaprogramming by intercepting object operations
- They consist of a target object and a handler object with trap methods
- Traps intercept specific operations on the target object
- Proxies are used for validation, logging, formatting, access control, and more

```javascript
const target = {
  message: "Hello, world!"
};

const handler = {
  get(target, prop, receiver) {
    console.log(`Property "${prop}" was accessed`);
    return target[prop];
  }
};

const proxy = new Proxy(target, handler);
console.log(proxy.message); 
// Property "message" was accessed
// Hello, world!
```

### Available Proxy Traps

Proxy handlers can define various trap methods to intercept different operations:

```javascript
const handler = {
  // Object property operations
  get(target, prop, receiver) { /* Intercept property access */ },
  set(target, prop, value, receiver) { /* Intercept property assignment */ },
  has(target, prop) { /* Intercept "in" operator */ },
  deleteProperty(target, prop) { /* Intercept "delete" operator */ },
  
  // Object metadata operations
  getOwnPropertyDescriptor(target, prop) { /* Intercept Object.getOwnPropertyDescriptor */ },
  defineProperty(target, prop, descriptor) { /* Intercept Object.defineProperty */ },
  getPrototypeOf(target) { /* Intercept Object.getPrototypeOf */ },
  setPrototypeOf(target, prototype) { /* Intercept Object.setPrototypeOf */ },
  
  // Object extensibility operations
  isExtensible(target) { /* Intercept Object.isExtensible */ },
  preventExtensions(target) { /* Intercept Object.preventExtensions */ },
  
  // Enumeration operations
  ownKeys(target) { /* Intercept Object.keys, Object.getOwnPropertyNames, etc. */ },
  
  // Function operations
  apply(target, thisArg, argumentsList) { /* Intercept function calls */ },
  construct(target, argumentsList, newTarget) { /* Intercept "new" operator */ }
};
```

### Common Use Cases

#### Property Validation

```javascript
const validator = {
  set(target, prop, value) {
    if (prop === 'age') {
      if (typeof value !== 'number') {
        throw new TypeError('Age must be a number');
      }
      if (value < 0 || value > 120) {
        throw new RangeError('Age must be between 0 and 120');
      }
    }
    
    // Default behavior
    target[prop] = value;
    return true; // Indicate success
  }
};

const person = new Proxy({}, validator);
person.age = 25; // Works fine
// person.age = -5;  // Throws RangeError
// person.age = "25"; // Throws TypeError
```

#### Data Binding and Change Detection

```javascript
function makeReactive(obj, onChange) {
  return new Proxy(obj, {
    set(target, property, value) {
      const oldValue = target[property];
      target[property] = value;
      onChange(property, oldValue, value);
      return true;
    }
  });
}

const user = makeReactive(
  { name: "John", age: 30 },
  (prop, oldVal, newVal) => {
    console.log(`Property "${prop}" changed from ${oldVal} to ${newVal}`);
  }
);

user.name = "Jane"; // Property "name" changed from John to Jane
```

#### Access Control and Private Properties

```javascript
function createSecureObject(privateData = {}) {
  return new Proxy({}, {
    get(target, prop) {
      if (prop.startsWith('_')) {
        throw new Error(`Access to private property "${prop}" denied`);
      }
      return privateData[prop];
    },
    
    set(target, prop, value) {
      if (prop.startsWith('_')) {
        throw new Error(`Modification of private property "${prop}" denied`);
      }
      privateData[prop] = value;
      return true;
    },
    
    has(target, prop) {
      return !prop.startsWith('_') && prop in privateData;
    },
    
    ownKeys(target) {
      return Object.keys(privateData).filter(key => !key.startsWith('_'));
    }
  });
}

const obj = createSecureObject({
  name: "Public",
  _secret: "Private"
});

console.log(obj.name);  // "Public"
// console.log(obj._secret);  // Error: Access to private property "_secret" denied
```

#### Logging and Debugging

```javascript
function createLoggingProxy(target, name = '') {
  return new Proxy(target, {
    get(target, prop) {
      const value = target[prop];
      console.log(`GET ${name}.${prop.toString()} -> ${value}`);
      return value;
    },
    
    set(target, prop, value) {
      console.log(`SET ${name}.${prop.toString()} = ${value}`);
      target[prop] = value;
      return true;
    }
  });
}

const user = createLoggingProxy({ name: "John", age: 30 }, 'user');
console.log(user.name);  // GET user.name -> John
user.age = 31;          // SET user.age = 31
```

### Proxy Patterns

#### Default Values for Non-Existent Properties

```javascript
const withDefaults = (target, defaults) => new Proxy(target, {
  get(target, prop) {
    return prop in target ? target[prop] : defaults[prop];
  }
});

const settings = withDefaults(
  { theme: "dark" },
  { theme: "light", fontSize: 16, showSidebar: true }
);

console.log(settings.theme);      // "dark" (from target)
console.log(settings.fontSize);   // 16 (from defaults)
```

#### Auto-Populating Objects

```javascript
const autoPopulate = (factory) => new Proxy({}, {
  get(target, prop) {
    if (!(prop in target)) {
      target[prop] = factory(prop);
    }
    return target[prop];
  }
});

// Auto-creates arrays for any property accessed
const collections = autoPopulate(() => []);

collections.users.push("John");
collections.products.push("Laptop");

console.log(collections.users);      // ["John"]
console.log(collections.products);   // ["Laptop"]
```

#### Method Chaining with Proxies

```javascript
function createChainable(methods) {
  const target = {};
  
  for (const method of methods) {
    target[method.name] = method;
  }
  
  return new Proxy(target, {
    get(target, prop) {
      if (prop in target) {
        const method = target[prop];
        return (...args) => {
          method(...args);
          return proxy; // Return the proxy for chaining
        };
      }
      return target[prop];
    }
  });
}

const query = createChainable([
  function select(fields) { console.log(`SELECT ${fields}`); },
  function from(table) { console.log(`FROM ${table}`); },
  function where(condition) { console.log(`WHERE ${condition}`); }
]);

query.select("id, name").from("users").where("age > 18");
// SELECT id, name
// FROM users
// WHERE age > 18
```

### Advanced Proxy Techniques

#### Nested Proxies and Deep Observation

```javascript
function deepObserve(obj, onChange) {
  return new Proxy(obj, {
    get(target, property) {
      // Return a new proxy if the property is an object
      const value = target[property];
      if (typeof value === 'object' && value !== null) {
        return deepObserve(value, onChange);
      }
      return value;
    },
    
    set(target, property, value) {
      const oldValue = target[property];
      if (oldValue !== value) {
        target[property] = value;
        onChange(property, oldValue, value);
      }
      return true;
    }
  });
}

const state = deepObserve(
  { user: { name: "John", profile: { age: 30 } } },
  (prop, oldVal, newVal) => {
    console.log(`Changed ${prop}: ${oldVal} -> ${newVal}`);
  }
);

state.user.profile.age = 31; // Changed age: 30 -> 31
```

#### Revocable Proxies

Revocable proxies allow you to invalidate a proxy, making it unusable.

```javascript
const target = { message: "Hello" };
const { proxy, revoke } = Proxy.revocable(target, {
  get(target, prop) {
    console.log(`Accessing ${prop}`);
    return target[prop];
  }
});

console.log(proxy.message); // Accessing message, Hello
revoke(); // Invalidate the proxy
// console.log(proxy.message); // TypeError: Cannot perform 'get' on a proxy that has been revoked
```

#### Function Proxies

```javascript
function createFunctionProxy(fn, beforeCall, afterCall) {
  return new Proxy(fn, {
    apply(target, thisArg, args) {
      beforeCall(args);
      const result = target.apply(thisArg, args);
      afterCall(result);
      return result;
    }
  });
}

const add = (a, b) => a + b;

const tracedAdd = createFunctionProxy(
  add,
  args => console.log(`Calling with args: ${args}`),
  result => console.log(`Returned result: ${result}`)
);

tracedAdd(2, 3);
// Calling with args: 2,3
// Returned result: 5
```

### Performance Considerations

**Key Points**:

- Proxies introduce overhead compared to direct object access
- The overhead is generally negligible for most applications
- Critical code paths with high-frequency property access might be affected
- Consider the tradeoff between flexibility and performance

```javascript
// Performance comparison example
const directObj = { value: 42 };
const proxiedObj = new Proxy(directObj, {
  get(target, prop) {
    return target[prop];
  }
});

// Benchmark
const iterations = 10000000;

console.time('Direct');
for (let i = 0; i < iterations; i++) {
  const x = directObj.value;
}
console.timeEnd('Direct');

console.time('Proxied');
for (let i = 0; i < iterations; i++) {
  const x = proxiedObj.value;
}
console.timeEnd('Proxied');
```

### Proxy Limitations and Edge Cases

**Key Points**:

- Proxies cannot intercept operations on primitive values
- Some built-in objects like Date have internal slots not accessible through proxies
- Equality comparisons (== and ===) compare references, not intercepted values
- The `this` value in methods might refer to the proxy instead of the target object

```javascript
// Example of equality comparison limitation
const target = {};
const proxy = new Proxy(target, {});

console.log(proxy === target); // false, they are different references

// Example of "this" value issue
const user = {
  name: "John",
  getName() {
    return this.name;
  }
};

const userProxy = new Proxy(user, {
  get(target, prop) {
    console.log(`Getting ${prop}`);
    return target[prop];
  }
});

console.log(user.getName());     // "John"
console.log(userProxy.getName()); // "John", but "this" in getName refers to the proxy
```

### Proxies in Frameworks and Libraries

Many popular JavaScript libraries and frameworks use Proxies internally:

1. **Vue.js** - Uses proxies for its reactivity system in version 3+
2. **MobX** - Uses proxies for observable objects
3. **Immer** - Creates immutable state updates with a mutable API using proxies
4. **on-change** - Watches for changes on objects and arrays

```javascript
// Simplified example of Vue 3's reactivity system
function reactive(obj) {
  return new Proxy(obj, {
    get(target, key) {
      track(target, key); // Track that this property was accessed
      return typeof target[key] === 'object' 
        ? reactive(target[key]) // Deep reactivity
        : target[key];
    },
    set(target, key, value) {
      const oldValue = target[key];
      target[key] = value;
      if (oldValue !== value) {
        trigger(target, key); // Trigger updates for components that depend on this property
      }
      return true;
    }
  });
}
```

### Cross-Browser Compatibility

**Key Points**:

- Proxies are supported in all modern browsers (Chrome, Firefox, Safari, Edge)
- No support in Internet Explorer 11 and below
- Polyfills only offer limited functionality due to the nature of proxies
- Consider feature detection when using proxies in production code

```javascript
// Feature detection for Proxy support
const supportsProxy = typeof Proxy !== 'undefined';

if (supportsProxy) {
  // Use proxies
} else {
  // Fallback behavior
}
```

### Best Practices

1. **Keep handlers simple and focused**: Each trap should have a clear purpose
2. **Use invariant checks**: Ensure that traps maintain expected behavior
3. **Consider performance impact**: Use proxies judiciously in performance-critical code
4. **Handle edge cases**: Account for property descriptors, inheritance, and object methods
5. **Remember transparent virtualization**: Proxies should generally maintain the behavior of the target object
6. **Document proxy behavior**: Make it clear when and how operations are being intercepted

### Proxy Composition

```javascript
function composeProxyHandlers(...handlers) {
  return Object.keys(Reflect).reduce((composed, trap) => {
    composed[trap] = function(target, ...args) {
      // Apply each handler's trap in sequence
      return handlers.reduce((result, handler) => {
        // Skip if this handler doesn't define this trap
        if (!handler[trap]) return result;
        
        // If the previous result was { value, done }, use the value
        const input = result && result.value !== undefined ? result.value : result;
        
        // Apply this handler's trap
        return handler[trap](target, ...args.concat(input));
      }, undefined);
    };
    return composed;
  }, {});
}

// Example usage with logging and validation
const loggingHandler = {
  get(target, prop) {
    console.log(`Getting ${prop}`);
    return Reflect.get(target, prop);
  }
};

const validationHandler = {
  set(target, prop, value) {
    if (prop === 'age' && typeof value !== 'number') {
      throw new TypeError('Age must be a number');
    }
    return Reflect.set(target, prop, value);
  }
};

const composedHandler = composeProxyHandlers(loggingHandler, validationHandler);
const person = new Proxy({}, composedHandler);

console.log(person.name); // Getting name, undefined
person.age = 30;         // Works fine
// person.age = "thirty"; // TypeError: Age must be a number
```

### Comparing Proxies with Alternatives

Proxies vs. Object.defineProperty():

```javascript
// Using Object.defineProperty
const userDef = {};
let _name = '';

Object.defineProperty(userDef, 'name', {
  get() {
    console.log('Name accessed');
    return _name;
  },
  set(value) {
    console.log(`Name changed to ${value}`);
    _name = value;
  }
});

// Using Proxy
const userProxy = new Proxy({}, {
  get(target, prop) {
    if (prop === 'name') {
      console.log('Name accessed');
    }
    return target[prop];
  },
  set(target, prop, value) {
    if (prop === 'name') {
      console.log(`Name changed to ${value}`);
    }
    target[prop] = value;
    return true;
  }
});

// Comparisons:
// 1. Object.defineProperty can only intercept pre-defined properties
// 2. Proxies can intercept all properties, even ones that don't exist yet
// 3. Proxies support more operations (has, deleteProperty, etc.)
// 4. Object.defineProperty has better browser compatibility
```

### Practical Real-World Examples

#### Form Input Validation

```javascript
function createFormValidator(validationRules) {
  const data = {};
  const errors = {};
  
  return new Proxy(data, {
    set(target, prop, value) {
      // Store the value
      target[prop] = value;
      
      // Check validation
      if (validationRules[prop]) {
        const error = validationRules[prop](value);
        if (error) {
          errors[prop] = error;
          console.log(`Validation error for ${prop}: ${error}`);
        } else {
          delete errors[prop];
        }
      }
      
      return true;
    },
    
    get(target, prop) {
      if (prop === '_errors') return errors;
      return target[prop];
    }
  });
}

const form = createFormValidator({
  email: (value) => {
    if (!value.includes('@')) return 'Invalid email';
    return null;
  },
  password: (value) => {
    if (value.length < 8) return 'Password too short';
    return null;
  }
});

form.email = 'test'; // Validation error for email: Invalid email
form.email = 'test@example.com'; // No error
console.log(form._errors); // {}
```

#### API Wrapper with Automatic Error Handling

```javascript
function createApiWrapper(baseUrl) {
  return new Proxy({}, {
    get(target, endpoint) {
      // Create methods for each endpoint dynamically
      if (!target[endpoint]) {
        target[endpoint] = async (params = {}) => {
          try {
            const response = await fetch(`${baseUrl}/${endpoint}`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(params)
            });
            
            if (!response.ok) {
              throw new Error(`API error: ${response.status}`);
            }
            
            return await response.json();
          } catch (err) {
            console.error(`Error in ${endpoint}:`, err);
            throw err;
          }
        };
      }
      
      return target[endpoint];
    }
  });
}

const api = createApiWrapper('https://api.example.com');

// Usage:
async function fetchUser() {
  try {
    // No need to define this method beforehand
    const user = await api.getUser({ id: 123 });
    console.log(user);
  } catch (err) {
    // Error already logged by the proxy
  }
}
```

---

