## Actor Model Concept


The actor model is a mathematical model of concurrent computation where "actors" are the fundamental units of computation. Each actor can receive messages, process them sequentially, create new actors, send messages to other actors, and determine how to respond to the next message. This model eliminates shared mutable state and provides natural isolation between concurrent processes.

**Core Principles**

Actors are isolated computational entities that communicate exclusively through asynchronous message passing. Each actor has:

- A mailbox (message queue) that buffers incoming messages
- State that is private and never shared
- Behavior that determines how it processes messages
- The ability to create child actors

Messages are immutable and delivered asynchronously. The actor model guarantees that messages sent from actor A to actor B arrive in the order sent, though messages from different senders may interleave.

**Basic Actor Implementation**

```javascript
const createActor = (behavior, initialState) => {
  const mailbox = [];
  let state = initialState;
  let processing = false;

  const processNext = () => {
    if (mailbox.length === 0) {
      processing = false;
      return;
    }

    const message = mailbox.shift();
    const result = behavior(state, message);
    
    if (result.newState !== undefined) {
      state = result.newState;
    }
    
    if (result.effects) {
      result.effects.forEach(effect => effect());
    }

    setImmediate(processNext);
  };

  return {
    send: (message) => {
      mailbox.push(message);
      if (!processing) {
        processing = true;
        setImmediate(processNext);
      }
    },
    ask: (message) => new Promise((resolve) => {
      mailbox.push({ ...message, replyTo: resolve });
      if (!processing) {
        processing = true;
        setImmediate(processNext);
      }
    })
  };
};
```

**Counter Actor Example**

```javascript
const counterBehavior = (state, message) => {
  switch (message.type) {
    case 'INCREMENT':
      return { newState: state + 1 };
    case 'DECREMENT':
      return { newState: state - 1 };
    case 'GET':
      return {
        newState: state,
        effects: [() => message.replyTo(state)]
      };
    default:
      return { newState: state };
  }
};

const counter = createActor(counterBehavior, 0);
counter.send({ type: 'INCREMENT' });
counter.send({ type: 'INCREMENT' });
counter.ask({ type: 'GET' }).then(count => console.log(count)); // 2
```

**Behavior Changes**

Actors can change their behavior in response to messages, implementing state machines:

```javascript
const authenticatedBehavior = (state, message) => {
  switch (message.type) {
    case 'LOGOUT':
      return {
        newState: { ...state, user: null },
        behavior: unauthenticatedBehavior
      };
    case 'GET_DATA':
      return {
        effects: [() => message.replyTo(state.privateData)]
      };
    default:
      return {};
  }
};

const unauthenticatedBehavior = (state, message) => {
  switch (message.type) {
    case 'LOGIN':
      if (validateCredentials(message.credentials)) {
        return {
          newState: { ...state, user: message.credentials.user },
          behavior: authenticatedBehavior
        };
      }
      return { effects: [() => message.replyTo({ error: 'Invalid credentials' })] };
    default:
      return { effects: [() => message.replyTo({ error: 'Not authenticated' })] };
  }
};
```

**Supervision and Fault Tolerance**

Parent actors supervise child actors and handle their failures:

```javascript
const supervisorBehavior = (state, message) => {
  switch (message.type) {
    case 'CREATE_CHILD':
      const child = createActor(message.behavior, message.initialState);
      return {
        newState: {
          ...state,
          children: [...state.children, { id: message.id, actor: child }]
        }
      };
    case 'CHILD_FAILED':
      const strategy = state.strategy || 'restart';
      if (strategy === 'restart') {
        const failedChild = state.children.find(c => c.id === message.childId);
        const newChild = createActor(failedChild.behavior, failedChild.initialState);
        return {
          newState: {
            ...state,
            children: state.children.map(c =>
              c.id === message.childId ? { ...c, actor: newChild } : c
            )
          }
        };
      }
      return { newState: state };
    default:
      return { newState: state };
  }
};
```

**Actor Hierarchies**

Organize actors in trees where parents manage children:

```javascript
const workerPoolBehavior = (state, message) => {
  switch (message.type) {
    case 'INIT':
      const workers = Array.from({ length: message.poolSize }, (_, i) =>
        createActor(workerBehavior, { id: i })
      );
      return { newState: { ...state, workers, currentIndex: 0 } };
    
    case 'WORK':
      const worker = state.workers[state.currentIndex];
      worker.send({ type: 'PROCESS', data: message.data, replyTo: message.replyTo });
      return {
        newState: {
          ...state,
          currentIndex: (state.currentIndex + 1) % state.workers.length
        }
      };
    
    default:
      return { newState: state };
  }
};
```

**Message Routing Patterns**

Implement various routing strategies:

```javascript
// Round-robin routing
const roundRobinRouter = (workers) => {
  let index = 0;
  return (message) => {
    workers[index].send(message);
    index = (index + 1) % workers.length;
  };
};

// Broadcast to all
const broadcastRouter = (workers) => (message) => {
  workers.forEach(worker => worker.send(message));
};

// Route by message content
const contentRouter = (workers, selector) => (message) => {
  const targetIndex = selector(message) % workers.length;
  workers[targetIndex].send(message);
};
```

**Back-pressure Handling**

Manage flow control when actors receive messages faster than they can process:

```javascript
const boundedActor = (behavior, initialState, maxMailboxSize) => {
  const mailbox = [];
  let state = initialState;
  let processing = false;

  return {
    send: (message) => {
      if (mailbox.length >= maxMailboxSize) {
        return { accepted: false, reason: 'mailbox full' };
      }
      mailbox.push(message);
      if (!processing) {
        processing = true;
        setImmediate(processNext);
      }
      return { accepted: true };
    }
  };
};
```

**Key Points**

- Actors process messages sequentially, eliminating race conditions within an actor
- No shared mutable state between actors; all communication via message passing
- Asynchronous message delivery enables natural parallelism
- Actor hierarchies with supervision provide fault tolerance
- Location transparency allows actors to run on different threads or machines
- Mailbox buffering decouples sender and receiver timing

