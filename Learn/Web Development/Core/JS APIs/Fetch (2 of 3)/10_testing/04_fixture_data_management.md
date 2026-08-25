## Fixture Data Management


### Loading Strategies

Fixture data can be loaded through multiple approaches depending on application architecture and testing requirements. Direct fetch calls retrieve static JSON files from the file system or test servers, while dynamic imports enable code-splitting and lazy loading of fixtures.

```javascript
// Static fetch
const userData = await fetch('/fixtures/users.json').then(r => r.json());

// Dynamic import
const { default: products } = await import('./fixtures/products.json');
```

### File Organization

Structure fixture files by domain, feature, or test scope:

```
fixtures/
├── users/
│   ├── admin.json
│   ├── regular.json
│   └── guest.json
├── products/
│   ├── catalog.json
│   └── inventory.json
└── transactions/
    ├── pending.json
    └── completed.json
```

Reference fixtures with path-based conventions:

```javascript
async function loadFixture(path) {
  const response = await fetch(`/fixtures/${path}.json`);
  return response.json();
}

const admin = await loadFixture('users/admin');
const catalog = await loadFixture('products/catalog');
```

### Fixture Factories

Generate fixture data programmatically for variation and customization:

```javascript
class FixtureFactory {
  static user(overrides = {}) {
    return {
      id: Math.random().toString(36).substr(2, 9),
      email: `user${Date.now()}@example.com`,
      name: 'Test User',
      role: 'user',
      createdAt: new Date().toISOString(),
      ...overrides
    };
  }
  
  static product(overrides = {}) {
    return {
      id: Math.random().toString(36).substr(2, 9),
      name: 'Sample Product',
      price: 99.99,
      stock: 100,
      category: 'general',
      ...overrides
    };
  }
}

// Usage
const admin = FixtureFactory.user({ role: 'admin' });
const premiumProduct = FixtureFactory.product({ price: 299.99 });
```

### Fixture Registry

Centralize fixture management with a registry pattern:

```javascript
class FixtureRegistry {
  constructor() {
    this.cache = new Map();
    this.baseUrl = '/fixtures';
  }
  
  async load(name) {
    if (this.cache.has(name)) {
      return this.cache.get(name);
    }
    
    const response = await fetch(`${this.baseUrl}/${name}.json`);
    const data = await response.json();
    this.cache.set(name, data);
    
    return data;
  }
  
  register(name, data) {
    this.cache.set(name, data);
  }
  
  clear(name) {
    if (name) {
      this.cache.delete(name);
    } else {
      this.cache.clear();
    }
  }
  
  async loadMultiple(names) {
    return Promise.all(names.map(name => this.load(name)));
  }
}

const fixtures = new FixtureRegistry();

// Load and cache
const users = await fixtures.load('users/admin');

// Register programmatic fixtures
fixtures.register('current-user', FixtureFactory.user({ role: 'admin' }));
```

### Fixture Templating

Use placeholder substitution for dynamic fixture content:

```javascript
class FixtureTemplate {
  constructor(template) {
    this.template = template;
  }
  
  render(context = {}) {
    const rendered = JSON.stringify(this.template);
    
    return JSON.parse(
      rendered.replace(/\{\{(\w+)\}\}/g, (match, key) => {
        return context[key] !== undefined ? context[key] : match;
      })
    );
  }
}

// Template fixture
const userTemplate = {
  id: '{{userId}}',
  email: '{{email}}',
  name: '{{name}}',
  createdAt: '{{timestamp}}'
};

const template = new FixtureTemplate(userTemplate);
const user = template.render({
  userId: '123',
  email: 'alice@example.com',
  name: 'Alice',
  timestamp: new Date().toISOString()
});
```

### Fixture Composition

Combine multiple fixtures to build complex test scenarios:

```javascript
class FixtureComposer {
  constructor(registry) {
    this.registry = registry;
  }
  
  async compose(spec) {
    const result = {};
    
    for (const [key, fixtureName] of Object.entries(spec)) {
      if (typeof fixtureName === 'string') {
        result[key] = await this.registry.load(fixtureName);
      } else if (Array.isArray(fixtureName)) {
        result[key] = await this.registry.loadMultiple(fixtureName);
      }
    }
    
    return result;
  }
}

const composer = new FixtureComposer(fixtures);

const scenario = await composer.compose({
  user: 'users/admin',
  products: ['products/featured', 'products/seasonal'],
  orders: 'orders/recent'
});
```

### Fixture Variants

Manage multiple versions of the same fixture:

```javascript
class FixtureVariants {
  constructor(base) {
    this.base = base;
    this.variants = new Map();
  }
  
  addVariant(name, modifications) {
    this.variants.set(name, modifications);
  }
  
  get(variantName = null) {
    if (!variantName) {
      return structuredClone(this.base);
    }
    
    const modifications = this.variants.get(variantName);
    if (!modifications) {
      throw new Error(`Variant '${variantName}' not found`);
    }
    
    return {
      ...structuredClone(this.base),
      ...modifications
    };
  }
}

const baseUser = {
  id: '1',
  email: 'user@example.com',
  role: 'user',
  verified: false
};

const userVariants = new FixtureVariants(baseUser);
userVariants.addVariant('admin', { role: 'admin' });
userVariants.addVariant('verified', { verified: true });
userVariants.addVariant('premium', { role: 'user', subscription: 'premium' });

const admin = userVariants.get('admin');
const verified = userVariants.get('verified');
```

### Fixture Relationships

Model relationships between fixtures:

```javascript
class FixtureRelations {
  constructor() {
    this.entities = new Map();
  }
  
  define(type, id, data) {
    if (!this.entities.has(type)) {
      this.entities.set(type, new Map());
    }
    this.entities.get(type).set(id, data);
  }
  
  get(type, id) {
    return this.entities.get(type)?.get(id);
  }
  
  resolve(entity) {
    if (!entity || typeof entity !== 'object') {
      return entity;
    }
    
    const resolved = Array.isArray(entity) ? [] : {};
    
    for (const [key, value] of Object.entries(entity)) {
      if (value && typeof value === 'object' && value.$ref) {
        const [type, id] = value.$ref.split('/');
        resolved[key] = this.get(type, id);
      } else if (typeof value === 'object') {
        resolved[key] = this.resolve(value);
      } else {
        resolved[key] = value;
      }
    }
    
    return resolved;
  }
}

const relations = new FixtureRelations();

relations.define('users', '1', { id: '1', name: 'Alice' });
relations.define('orders', 'order1', {
  id: 'order1',
  user: { $ref: 'users/1' },
  total: 150
});

const order = relations.resolve(relations.get('orders', 'order1'));
// order.user now contains full user object
```

### Fixture Seeding

Populate mock APIs or test databases with fixture data:

```javascript
class FixtureSeeder {
  constructor(apiClient) {
    this.api = apiClient;
  }
  
  async seed(fixtures) {
    const results = [];
    
    for (const [endpoint, data] of Object.entries(fixtures)) {
      try {
        const response = await this.api.post(endpoint, data);
        results.push({ endpoint, status: 'success', data: response });
      } catch (error) {
        results.push({ endpoint, status: 'error', error: error.message });
      }
    }
    
    return results;
  }
  
  async seedMultiple(endpoint, items) {
    return Promise.all(
      items.map(item => this.api.post(endpoint, item))
    );
  }
}

// Usage
const seeder = new FixtureSeeder(apiClient);

await seeder.seed({
  '/api/users': await fixtures.load('users/admin'),
  '/api/products': await fixtures.load('products/catalog')
});
```

### Fixture State Management

Track and restore fixture state across tests:

```javascript
class FixtureState {
  constructor() {
    this.snapshots = [];
    this.current = new Map();
  }
  
  set(key, value) {
    this.current.set(key, structuredClone(value));
  }
  
  get(key) {
    return structuredClone(this.current.get(key));
  }
  
  snapshot() {
    this.snapshots.push(new Map(this.current));
  }
  
  restore() {
    if (this.snapshots.length === 0) {
      throw new Error('No snapshot to restore');
    }
    this.current = this.snapshots.pop();
  }
  
  reset() {
    this.current.clear();
    this.snapshots = [];
  }
}

const state = new FixtureState();

// Set initial state
state.set('users', await fixtures.load('users/all'));
state.snapshot();

// Modify state
const users = state.get('users');
users.push(FixtureFactory.user());
state.set('users', users);

// Restore to snapshot
state.restore();
```

### Lazy Loading

Defer fixture loading until needed:

```javascript
class LazyFixture {
  constructor(loader) {
    this.loader = loader;
    this.loaded = false;
    this.data = null;
  }
  
  async get() {
    if (!this.loaded) {
      this.data = await this.loader();
      this.loaded = true;
    }
    return this.data;
  }
  
  invalidate() {
    this.loaded = false;
    this.data = null;
  }
}

const lazyUsers = new LazyFixture(
  () => fetch('/fixtures/users/large-dataset.json').then(r => r.json())
);

// Only loads when first accessed
const users = await lazyUsers.get();
```

### Fixture Validation

Validate fixture data against schemas:

```javascript
class FixtureValidator {
  constructor(schemas) {
    this.schemas = schemas;
  }
  
  validate(type, data) {
    const schema = this.schemas[type];
    if (!schema) {
      throw new Error(`No schema defined for type: ${type}`);
    }
    
    const errors = [];
    
    for (const [field, rules] of Object.entries(schema)) {
      if (rules.required && !(field in data)) {
        errors.push(`Missing required field: ${field}`);
      }
      
      if (field in data && rules.type) {
        const actualType = typeof data[field];
        if (actualType !== rules.type) {
          errors.push(`Invalid type for ${field}: expected ${rules.type}, got ${actualType}`);
        }
      }
    }
    
    return {
      valid: errors.length === 0,
      errors
    };
  }
}

const validator = new FixtureValidator({
  user: {
    id: { type: 'string', required: true },
    email: { type: 'string', required: true },
    role: { type: 'string', required: true }
  }
});

const result = validator.validate('user', userData);
if (!result.valid) {
  console.error('Validation errors:', result.errors);
}
```

### Fixture Middleware

Transform fixtures during loading:

```javascript
class FixtureMiddleware {
  constructor() {
    this.transforms = [];
  }
  
  use(transform) {
    this.transforms.push(transform);
  }
  
  async apply(data) {
    let result = data;
    
    for (const transform of this.transforms) {
      result = await transform(result);
    }
    
    return result;
  }
}

const middleware = new FixtureMiddleware();

// Add timestamp to all fixtures
middleware.use(data => ({
  ...data,
  _loadedAt: new Date().toISOString()
}));

// Deep freeze for immutability
middleware.use(data => Object.freeze(structuredClone(data)));

const processed = await middleware.apply(rawFixture);
```

### Fixture Overrides

Apply environment-specific or test-specific overrides:

```javascript
class FixtureOverrides {
  constructor(baseFixtures) {
    this.base = baseFixtures;
    this.overrides = new Map();
  }
  
  override(path, value) {
    this.overrides.set(path, value);
  }
  
  async resolve(name) {
    let data = await this.base.load(name);
    
    for (const [path, value] of this.overrides.entries()) {
      if (path.startsWith(name)) {
        const keys = path.split('.').slice(1);
        data = this.applyOverride(data, keys, value);
      }
    }
    
    return data;
  }
  
  applyOverride(obj, keys, value) {
    if (keys.length === 0) return value;
    
    const result = structuredClone(obj);
    let current = result;
    
    for (let i = 0; i < keys.length - 1; i++) {
      current = current[keys[i]];
    }
    
    current[keys[keys.length - 1]] = value;
    return result;
  }
}

const overrides = new FixtureOverrides(fixtures);
overrides.override('users/admin.email', 'override@example.com');

const admin = await overrides.resolve('users/admin');
// admin.email is now 'override@example.com'
```

### Fixture Sampling

Extract subsets of large fixture datasets:

```javascript
class FixtureSampler {
  static random(array, count) {
    const shuffled = [...array].sort(() => Math.random() - 0.5);
    return shuffled.slice(0, count);
  }
  
  static first(array, count) {
    return array.slice(0, count);
  }
  
  static filter(array, predicate) {
    return array.filter(predicate);
  }
  
  static paginate(array, page, pageSize) {
    const start = (page - 1) * pageSize;
    return array.slice(start, start + pageSize);
  }
}

const allUsers = await fixtures.load('users/complete');

const sample = FixtureSampler.random(allUsers, 10);
const admins = FixtureSampler.filter(allUsers, u => u.role === 'admin');
const page1 = FixtureSampler.paginate(allUsers, 1, 20);
```

### Fixture Dependencies

Manage loading order for dependent fixtures:

```javascript
class FixtureDependencies {
  constructor(loader) {
    this.loader = loader;
    this.loaded = new Map();
    this.loading = new Set();
  }
  
  async load(name, deps = []) {
    if (this.loaded.has(name)) {
      return this.loaded.get(name);
    }
    
    if (this.loading.has(name)) {
      throw new Error(`Circular dependency detected: ${name}`);
    }
    
    this.loading.add(name);
    
    // Load dependencies first
    for (const dep of deps) {
      await this.load(dep);
    }
    
    const data = await this.loader(name);
    this.loaded.set(name, data);
    this.loading.delete(name);
    
    return data;
  }
}

const deps = new FixtureDependencies(
  name => fetch(`/fixtures/${name}.json`).then(r => r.json())
);

// Load orders (depends on users and products)
const orders = await deps.load('orders', ['users', 'products']);
```

### Fixture Versioning

Manage multiple versions of fixtures for backward compatibility:

```javascript
class FixtureVersioning {
  constructor(basePath) {
    this.basePath = basePath;
  }
  
  async load(name, version = 'latest') {
    const path = version === 'latest' 
      ? `${this.basePath}/${name}.json`
      : `${this.basePath}/${name}.v${version}.json`;
    
    const response = await fetch(path);
    return response.json();
  }
  
  async loadWithFallback(name, preferredVersion) {
    try {
      return await this.load(name, preferredVersion);
    } catch {
      return await this.load(name, 'latest');
    }
  }
}

const versioned = new FixtureVersioning('/fixtures');

const v2Data = await versioned.load('users', 2);
const latestData = await versioned.load('users');
```

---

