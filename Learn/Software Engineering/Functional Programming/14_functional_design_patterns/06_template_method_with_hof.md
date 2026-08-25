## Template Method with HOF


The template method pattern defines the skeleton of an algorithm in a higher-order function, allowing specific steps to be customized through function parameters. This pattern separates invariant algorithm structure from variant implementation details.

**Basic Template Method**

A higher-order function defines the algorithm structure, accepting functions for customizable steps:

```javascript
const processData = (data, {
  validate,
  transform,
  save,
  onError = (e) => console.error(e)
}) => {
  try {
    if (!validate(data)) {
      throw new Error('Validation failed');
    }
    
    const transformed = transform(data);
    return save(transformed);
  } catch (error) {
    return onError(error);
  }
};

// Different implementations
const processUser = (userData) => processData(userData, {
  validate: (u) => u.email && u.name,
  transform: (u) => ({ ...u, email: u.email.toLowerCase() }),
  save: (u) => database.users.insert(u)
});

const processOrder = (orderData) => processData(orderData, {
  validate: (o) => o.items.length > 0 && o.total > 0,
  transform: (o) => ({ ...o, status: 'pending', date: Date.now() }),
  save: (o) => database.orders.insert(o)
});
```

**Data Pipeline Template**

Defines a multi-stage data processing pipeline:

```javascript
const createPipeline = (...stages) => (input) => 
  stages.reduce((data, stage) => stage(data), input);

const dataProcessingTemplate = ({ 
  extract, 
  validate, 
  transform, 
  enrich, 
  load 
}) => createPipeline(
  extract,
  validate,
  transform,
  enrich,
  load
);

// Concrete implementation
const etlProcess = dataProcessingTemplate({
  extract: (source) => fetch(source).then(r => r.json()),
  validate: (data) => data.filter(item => item.valid),
  transform: (data) => data.map(item => ({ ...item, processed: true })),
  enrich: (data) => data.map(item => ({ ...item, timestamp: Date.now() })),
  load: (data) => database.bulkInsert(data)
});
```

**Request-Response Template**

Template for handling HTTP-like request-response cycles:

```javascript
const requestTemplate = ({
  parseRequest,
  authenticate,
  authorize,
  execute,
  formatResponse,
  handleError
}) => async (request) => {
  try {
    const parsed = parseRequest(request);
    const user = await authenticate(parsed);
    
    if (!authorize(user, parsed)) {
      return formatResponse({ error: 'Forbidden', status: 403 });
    }
    
    const result = await execute(parsed, user);
    return formatResponse({ data: result, status: 200 });
  } catch (error) {
    return handleError(error);
  }
};

const apiEndpoint = requestTemplate({
  parseRequest: (req) => JSON.parse(req.body),
  authenticate: async (req) => getUserFromToken(req.headers.token),
  authorize: (user, req) => user.permissions.includes(req.action),
  execute: async (req, user) => performAction(req.action, user),
  formatResponse: (res) => ({ ...res, timestamp: Date.now() }),
  handleError: (err) => ({ error: err.message, status: 500 })
});
```

**Hook-Based Template**

Provides hooks at various stages of execution:

```javascript
const createTemplateWithHooks = (algorithm) => ({
  beforeEach = () => {},
  afterEach = () => {},
  onSuccess = (result) => result,
  onFailure = (error) => { throw error; }
} = {}) => async (...args) => {
  beforeEach(args);
  
  try {
    const result = await algorithm(...args);
    afterEach(result);
    return onSuccess(result);
  } catch (error) {
    afterEach(error);
    return onFailure(error);
  }
};

const processTransaction = createTemplateWithHooks(
  async (transaction) => {
    // Core transaction logic
    return await database.commit(transaction);
  }
)({
  beforeEach: (args) => console.log('Starting transaction:', args),
  afterEach: (result) => console.log('Transaction completed'),
  onSuccess: (result) => ({ success: true, data: result }),
  onFailure: (error) => ({ success: false, error: error.message })
});
```

**Strategy Pattern Through Template Method**

Combines template method with strategy selection:

```javascript
const sortingTemplate = (strategy) => (array, comparator) => {
  const strategies = {
    quick: (arr, cmp) => quickSort(arr, cmp),
    merge: (arr, cmp) => mergeSort(arr, cmp),
    bubble: (arr, cmp) => bubbleSort(arr, cmp)
  };
  
  const sortFn = strategies[strategy] ?? strategies.quick;
  
  // Template steps
  const validated = validateArray(array);
  const sorted = sortFn(validated, comparator);
  return postProcess(sorted);
};

const quickSorter = sortingTemplate('quick');
const mergeSorter = sortingTemplate('merge');
```

**Resource Management Template**

Ensures proper resource acquisition and cleanup:

```javascript
const withResource = (acquire, release) => async (operation) => {
  let resource;
  
  try {
    resource = await acquire();
    return await operation(resource);
  } finally {
    if (resource) {
      await release(resource);
    }
  }
};

// Database connection example
const withDatabaseConnection = withResource(
  () => database.connect(),
  (conn) => conn.close()
);

const queryUsers = withDatabaseConnection(
  (db) => db.query('SELECT * FROM users')
);

// File handling example
const withFileHandle = withResource(
  (path) => fs.promises.open(path, 'r'),
  (handle) => handle.close()
);

const readFile = (path) => withFileHandle(
  async (handle) => handle.readFile('utf-8')
)(path);
```

**State Machine Template**

Defines state transitions as a template:

```javascript
const stateMachineTemplate = (initialState, transitions) => {
  let currentState = initialState;
  
  return {
    dispatch: (action) => {
      const transition = transitions[currentState]?.[action];
      
      if (!transition) {
        throw new Error(`Invalid transition: ${currentState} -> ${action}`);
      }
      
      const { nextState, effect } = transition;
      
      if (effect) effect(currentState, nextState);
      
      currentState = nextState;
      return currentState;
    },
    
    getState: () => currentState
  };
};

const orderMachine = stateMachineTemplate('pending', {
  pending: {
    confirm: { 
      nextState: 'confirmed', 
      effect: (from, to) => sendEmail('Order confirmed') 
    },
    cancel: { 
      nextState: 'cancelled', 
      effect: (from, to) => refundPayment() 
    }
  },
  confirmed: {
    ship: { 
      nextState: 'shipped', 
      effect: (from, to) => updateTracking() 
    },
    cancel: { 
      nextState: 'cancelled', 
      effect: (from, to) => refundPayment() 
    }
  },
  shipped: {
    deliver: { 
      nextState: 'delivered', 
      effect: (from, to) => closeOrder() 
    }
  }
});
```

**Iteration Template**

Abstracts iteration patterns over collections:

```javascript
const iterationTemplate = ({
  initialize,
  shouldContinue,
  getNext,
  process,
  finalize
}) => (collection) => {
  let state = initialize(collection);
  const results = [];
  
  while (shouldContinue(state)) {
    const item = getNext(state);
    const result = process(item);
    results.push(result);
  }
  
  return finalize(results);
};

// Forward iteration
const forwardMap = iterationTemplate({
  initialize: (arr) => ({ arr, index: 0 }),
  shouldContinue: (state) => state.index < state.arr.length,
  getNext: (state) => state.arr[state.index++],
  process: (item) => item * 2,
  finalize: (results) => results
});

// Reverse iteration
const reverseMap = iterationTemplate({
  initialize: (arr) => ({ arr, index: arr.length - 1 }),
  shouldContinue: (state) => state.index >= 0,
  getNext: (state) => state.arr[state.index--],
  process: (item) => item * 2,
  finalize: (results) => results
});
```

**Async Operation Template**

Template for handling asynchronous operations consistently:

```javascript
const asyncOperationTemplate = ({
  prepare,
  execute,
  validate,
  retry = 1,
  timeout = 5000
}) => async (input) => {
  const prepared = await prepare(input);
  
  for (let attempt = 1; attempt <= retry; attempt++) {
    try {
      const result = await Promise.race([
        execute(prepared),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Timeout')), timeout)
        )
      ]);
      
      if (validate(result)) {
        return result;
      }
      
      if (attempt === retry) {
        throw new Error('Validation failed after all retries');
      }
    } catch (error) {
      if (attempt === retry) throw error;
    }
  }
};

const apiCall = asyncOperationTemplate({
  prepare: (endpoint) => ({ url: endpoint, headers: getAuthHeaders() }),
  execute: (config) => fetch(config.url, config),
  validate: (response) => response.ok,
  retry: 3,
  timeout: 3000
});
```

