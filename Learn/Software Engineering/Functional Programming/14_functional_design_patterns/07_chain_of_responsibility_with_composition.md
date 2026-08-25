## Chain of Responsibility with Composition


The chain of responsibility pattern processes a request through a series of handlers, where each handler decides whether to process the request or pass it to the next handler. In functional programming, this is implemented through function composition rather than class hierarchies.

**Core Concept**

Instead of objects linked through references, handlers are functions that either return a result or delegate to the next function in the chain. The chain itself is a composed function built from individual handler functions.

**Implementation Approaches**

The simplest form uses function composition where each handler receives both the request and the next handler as parameters:

```javascript
const handler = (request, next) => {
  if (canHandle(request)) {
    return process(request);
  }
  return next(request);
};
```

A more sophisticated approach uses monadic patterns where handlers return `Option` or `Either` types, allowing the chain to short-circuit on the first successful handler:

```javascript
const tryHandler = (handler) => (request) => {
  const result = handler(request);
  return result !== null ? Some(result) : None;
};

const chain = (...handlers) => (request) => {
  for (const handler of handlers) {
    const result = tryHandler(handler)(request);
    if (result.isSome()) return result;
  }
  return None;
};
```

**Partial Application Strategy**

Handlers can be partially applied functions that capture configuration while remaining composable:

```javascript
const authHandler = (minRole) => (request) => {
  if (request.user.role >= minRole) {
    return { ...request, authorized: true };
  }
  return null;
};

const validationHandler = (schema) => (request) => {
  if (validate(schema, request.data)) {
    return { ...request, validated: true };
  }
  return null;
};

const pipeline = chain(
  authHandler('admin'),
  validationHandler(userSchema),
  processRequest
);
```

**Reducer-Based Chains**

When all handlers should process the request in sequence (transformation chain rather than delegation chain), use `reduce`:

```javascript
const transformChain = (...handlers) => (request) =>
  handlers.reduce(
    (acc, handler) => acc !== null ? handler(acc) : null,
    request
  );
```

**Async Chain Handling**

For asynchronous handlers, compose promises or use async/await with proper error handling:

```javascript
const asyncChain = (...handlers) => async (request) => {
  for (const handler of handlers) {
    const result = await handler(request);
    if (result !== null) return result;
  }
  return null;
};
```

**Middleware Pattern**

The chain can support middleware-style handlers that wrap subsequent handlers:

```javascript
const middleware = (handler) => (next) => (request) => {
  const modified = handler(request);
  return modified ? next(modified) : null;
};

const compose = (...middlewares) => (finalHandler) =>
  middlewares.reduceRight(
    (next, middleware) => middleware(next),
    finalHandler
  );
```

**Key Points**

- Each handler is a pure function that returns a result or signals delegation
- The chain itself is a higher-order function that coordinates handler execution
- Short-circuiting occurs naturally through conditional logic or monadic types
- Configuration is captured through closures or partial application
- No mutable state or object references required

