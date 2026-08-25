## Factory Pattern with Functions


Factory patterns in functional programming leverage first-class functions and closures to create object construction logic without classes or explicit constructors. The pattern emphasizes pure factory functions that return new instances based on input parameters.

**Core Implementation**

A functional factory is simply a function that returns a new data structure or object. The factory encapsulates construction logic, default values, and validation:

```javascript
const createUser = (name, email) => ({
  name,
  email,
  createdAt: new Date(),
  isActive: true
});

const createAdminUser = (name, email) => ({
  ...createUser(name, email),
  role: 'admin',
  permissions: ['read', 'write', 'delete']
});
```

**Parameterized Factories**

Functions can return factory functions, enabling dynamic factory creation based on configuration:

```javascript
const createEntityFactory = (type, defaults = {}) => 
  (data) => ({
    type,
    id: crypto.randomUUID(),
    ...defaults,
    ...data,
    timestamp: Date.now()
  });

const userFactory = createEntityFactory('user', { role: 'guest' });
const productFactory = createEntityFactory('product', { inStock: true });

const user = userFactory({ name: 'Alice' });
const product = productFactory({ name: 'Widget', price: 29.99 });
```

**Dependency Injection Through Closures**

Factories can close over dependencies, eliminating the need for dependency injection frameworks:

```javascript
const createRepository = (database, cache) => ({
  findById: (id) => {
    const cached = cache.get(id);
    if (cached) return cached;
    
    const result = database.query(`SELECT * FROM items WHERE id = ?`, [id]);
    cache.set(id, result);
    return result;
  },
  
  save: (item) => {
    cache.invalidate(item.id);
    return database.execute(`INSERT INTO items VALUES (?, ?)`, [item.id, item.data]);
  }
});

const repo = createRepository(myDatabase, myCache);
```

**Polymorphic Factories**

Different factory strategies can be selected based on input type or discriminator:

```javascript
const createLogger = (type) => {
  const factories = {
    console: () => ({
      log: (msg) => console.log(msg),
      error: (msg) => console.error(msg)
    }),
    
    file: () => ({
      log: (msg) => fs.appendFileSync('app.log', msg + '\n'),
      error: (msg) => fs.appendFileSync('error.log', msg + '\n')
    }),
    
    remote: () => ({
      log: (msg) => fetch('/api/log', { method: 'POST', body: msg }),
      error: (msg) => fetch('/api/error', { method: 'POST', body: msg })
    })
  };
  
  return factories[type]?.() ?? factories.console();
};
```

**Validation and Smart Constructors**

Factories can enforce invariants and return either valid instances or error values:

```javascript
const createEmail = (string) => {
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  
  if (!emailPattern.test(string)) {
    return { type: 'error', message: 'Invalid email format' };
  }
  
  return {
    type: 'email',
    value: string.toLowerCase(),
    domain: string.split('@')[1]
  };
};

const createAge = (value) => {
  if (typeof value !== 'number' || value < 0 || value > 150) {
    return { type: 'error', message: 'Invalid age' };
  }
  
  return { type: 'age', value };
};
```

**Builder Pattern Through Function Composition**

Multiple factory functions can be composed to build complex objects incrementally:

```javascript
const withTimestamps = (obj) => ({
  ...obj,
  createdAt: new Date(),
  updatedAt: new Date()
});

const withValidation = (obj) => ({
  ...obj,
  validate: function() {
    return Object.values(this).every(v => v != null);
  }
});

const withSerialization = (obj) => ({
  ...obj,
  toJSON: function() {
    return JSON.stringify(this);
  }
});

const createEntity = (data) => 
  withSerialization(withValidation(withTimestamps(data)));
```

**Registry Pattern**

Factories can be registered and retrieved dynamically:

```javascript
const factoryRegistry = new Map();

const registerFactory = (name, factory) => {
  factoryRegistry.set(name, factory);
};

const createFromRegistry = (name, ...args) => {
  const factory = factoryRegistry.get(name);
  if (!factory) throw new Error(`Factory ${name} not found`);
  return factory(...args);
};

registerFactory('user', createUser);
registerFactory('admin', createAdminUser);

const user = createFromRegistry('user', 'Bob', 'bob@example.com');
```

