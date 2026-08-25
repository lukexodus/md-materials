## Null Object Pattern


The null object pattern eliminates null checks by providing a valid object with neutral behavior. In functional programming, this translates to using default values, identity functions, or algebraic data types that encode the presence or absence of values.

**Identity and Neutral Values**

Instead of checking for null, provide functions with neutral behavior:

```javascript
const noOpLogger = {
  log: () => {},
  error: () => {},
  warn: () => {}
};

const createService = (logger = noOpLogger) => ({
  process: (data) => {
    logger.log('Processing:', data);
    return transform(data);
  }
});
```

**Default Function Arguments**

Use default parameters to provide null object behavior:

```javascript
const processWithCallback = (data, onSuccess = () => {}, onError = () => {}) => {
  try {
    const result = process(data);
    onSuccess(result);
    return result;
  } catch (e) {
    onError(e);
    throw e;
  }
};
```

**Maybe/Option Type**

The Option monad is the canonical null object replacement, encoding presence or absence explicitly:

```javascript
const Some = (value) => ({
  isSome: () => true,
  isNone: () => false,
  map: (fn) => Some(fn(value)),
  flatMap: (fn) => fn(value),
  getOrElse: () => value,
  fold: (ifNone, ifSome) => ifSome(value)
});

const None = {
  isSome: () => false,
  isNone: () => true,
  map: () => None,
  flatMap: () => None,
  getOrElse: (defaultValue) => defaultValue,
  fold: (ifNone, ifSome) => ifNone()
};

const findUser = (id) => {
  const user = database.find(id);
  return user ? Some(user) : None;
};

findUser(123)
  .map(user => user.name)
  .map(name => name.toUpperCase())
  .getOrElse('UNKNOWN');
```

**Empty Collections**

Use empty arrays or objects as null objects for collections:

```javascript
const getOrders = (userId) => {
  const orders = database.orders(userId);
  return orders || []; // Always return array, never null
};

// Consumer code never needs null checks
getOrders(userId).map(order => order.total);
```

**Null Object Factory**

Create factories that return objects with the same interface but neutral behavior:

```javascript
const createUser = (data) => ({
  getName: () => data.name,
  getEmail: () => data.email,
  isValid: () => true
});

const nullUser = {
  getName: () => 'Guest',
  getEmail: () => '',
  isValid: () => false
};

const getUserOr = (id) => {
  const userData = database.find(id);
  return userData ? createUser(userData) : nullUser;
};
```

**Defaulting with Logical OR**

Use the `||` or `??` operator to provide defaults:

```javascript
const config = {
  timeout: userConfig.timeout || 5000,
  retries: userConfig.retries ?? 3,
  onError: userConfig.onError || (() => {})
};
```

**Fold Pattern**

Handle both cases explicitly without null checks:

```javascript
const result = findUser(id).fold(
  () => ({ error: 'User not found' }),
  (user) => ({ data: user })
);
```

**Key Points**

- Replace null checks with default values or neutral behaviors
- Use algebraic data types (Option/Maybe) to make absence explicit
- Ensure null objects implement the same interface as real objects
- Default parameters and logical operators provide simple null object behavior
- The fold pattern handles both presence and absence cases explicitly

