## Message Passing


Message passing enables concurrent systems to communicate through explicit messages rather than shared memory, maintaining isolation while coordinating behavior.

**Actor Model Implementation**

Actors process messages sequentially from a mailbox:

```javascript
const createActor = (initialState, behavior) => {
  const mailbox = [];
  let state = initialState;
  let processing = false;
  
  const processNext = async () => {
    if (processing || mailbox.length === 0) return;
    
    processing = true;
    const message = mailbox.shift();
    
    try {
      const result = await behavior(state, message);
      state = result.state;
      
      if (result.reply) {
        message.sender?.receive(result.reply);
      }
    } finally {
      processing = false;
      if (mailbox.length > 0) {
        processNext();
      }
    }
  };
  
  return {
    send: (message, sender = null) => {
      mailbox.push({ ...message, sender });
      processNext();
    },
    
    getState: () => state
  };
};

// Counter actor
const counterActor = createActor(
  { count: 0 },
  (state, message) => {
    switch (message.type) {
      case 'increment':
        return { 
          state: { count: state.count + 1 },
          reply: { type: 'count', value: state.count + 1 }
        };
      case 'get':
        return {
          state,
          reply: { type: 'count', value: state.count }
        };
      default:
        return { state };
    }
  }
);

counterActor.send({ type: 'increment' });
counterActor.send({ type: 'increment' });
```

**Channel-Based Communication**

Channels provide typed message passing between concurrent processes:

```javascript
const createChannel = () => {
  const buffer = [];
  const receivers = [];
  
  return {
    send: async (message) => {
      if (receivers.length > 0) {
        const receiver = receivers.shift();
        receiver.resolve(message);
      } else {
        buffer.push(message);
      }
    },
    
    receive: () => new Promise((resolve) => {
      if (buffer.length > 0) {
        resolve(buffer.shift());
      } else {
        receivers.push({ resolve });
      }
    }),
    
    close: () => {
      receivers.forEach(r => r.resolve(null));
      receivers.length = 0;
      buffer.length = 0;
    }
  };
};

// Producer-Consumer pattern
const producerConsumer = async () => {
  const channel = createChannel();
  
  const producer = async () => {
    for (let i = 0; i < 10; i++) {
      await channel.send({ id: i, data: `Item ${i}` });
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    channel.close();
  };
  
  const consumer = async () => {
    const results = [];
    while (true) {
      const message = await channel.receive();
      if (message === null) break;
      results.push(message);
    }
    return results;
  };
  
  const [_, consumed] = await Promise.all([
    producer(),
    consumer()
  ]);
  
  return consumed;
};
```

**Request-Reply Pattern**

Synchronous-style communication over asynchronous messages:

```javascript
const createRequestReplyActor = (handler) => {
  const pendingRequests = new Map();
  let requestId = 0;
  
  return {
    request: async (message) => {
      const id = requestId++;
      
      const promise = new Promise((resolve) => {
        pendingRequests.set(id, resolve);
      });
      
      // Simulate sending request
      setTimeout(async () => {
        const response = await handler(message);
        const resolver = pendingRequests.get(id);
        if (resolver) {
          resolver(response);
          pendingRequests.delete(id);
        }
      }, 0);
      
      return promise;
    }
  };
};

const dbActor = createRequestReplyActor(async (message) => {
  switch (message.type) {
    case 'query':
      return { data: await database.query(message.sql) };
    case 'insert':
      return { id: await database.insert(message.data) };
    default:
      return { error: 'Unknown message type' };
  }
});

const result = await dbActor.request({ 
  type: 'query', 
  sql: 'SELECT * FROM users' 
});
```

**Publish-Subscribe**

One-to-many message distribution:

```javascript
const createPubSub = () => {
  const subscribers = new Map();
  
  return {
    subscribe: (topic, handler) => {
      if (!subscribers.has(topic)) {
        subscribers.set(topic, new Set());
      }
      subscribers.get(topic).add(handler);
      
      return () => subscribers.get(topic)?.delete(handler);
    },
    
    publish: async (topic, message) => {
      const handlers = subscribers.get(topic);
      if (!handlers) return;
      
      await Promise.all(
        Array.from(handlers).map(handler => handler(message))
      );
    },
    
    topics: () => Array.from(subscribers.keys())
  };
};

const pubsub = createPubSub();

// Multiple subscribers
const unsubscribe1 = pubsub.subscribe('user.created', async (user) => {
  console.log('Sending welcome email to', user.email);
});

const unsubscribe2 = pubsub.subscribe('user.created', async (user) => {
  console.log('Creating user profile for', user.name);
});

const unsubscribe3 = pubsub.subscribe('user.created', async (user) => {
  console.log('Logging user creation event');
});

// Publish event
await pubsub.publish('user.created', { 
  id: 123, 
  name: 'Alice', 
  email: 'alice@example.com' 
});
```

**Pipeline Pattern**

Chain actors where output of one becomes input to next:

```javascript
const createPipeline = (...stages) => {
  const channels = stages.map(() => createChannel());
  
  stages.forEach((stage, index) => {
    const input = channels[index];
    const output = channels[index + 1];
    
    (async () => {
      while (true) {
        const message = await input.receive();
        if (message === null) {
          output?.close();
          break;
        }
        
        const result = await stage(message);
        if (output) {
          await output.send(result);
        }
      }
    })();
  });
  
  return {
    input: channels[0],
    output: channels[channels.length - 1]
  };
};

const pipeline = createPipeline(
  (data) => ({ ...data, step1: true }),
  (data) => ({ ...data, step2: true }),
  (data) => ({ ...data, step3: true })
);

// Send data through pipeline
await pipeline.input.send({ id: 1, value: 'test' });
const result = await pipeline.output.receive();
```

**Supervisor Pattern**

Monitor and restart failed actors:

```javascript
const createSupervisor = (createWorker, maxRestarts = 3) => {
  let worker = createWorker();
  let restarts = 0;
  
  const supervise = async (message) => {
    try {
      return await worker.send(message);
    } catch (error) {
      if (restarts < maxRestarts) {
        console.log(`Restarting worker (${++restarts}/${maxRestarts})`);
        worker = createWorker();
        return supervise(message);
      } else {
        throw new Error('Max restarts exceeded');
      }
    }
  };
  
  return {
    send: supervise,
    restart: () => {
      worker = createWorker();
      restarts = 0;
    }
  };
};

const supervisor = createSupervisor(() => 
  createActor({ count: 0 }, workerBehavior)
);
```

**Scatter-Gather**

Distribute work to multiple actors and collect results:

```javascript
const scatterGather = async (workers, message, timeout = 5000) => {
  const results = await Promise.race([
    Promise.all(
      workers.map(worker => worker.send(message))
    ),
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Timeout')), timeout)
    )
  ]);
  
  return results;
};

const workers = Array.from({ length: 5 }, (_, i) => 
  createActor({ id: i }, workerBehavior)
);

const results = await scatterGather(
  workers,
  { type: 'process', data: payload }
);
```

**Mailbox Prioritization**

Process high-priority messages first:

```javascript
const createPriorityActor = (initialState, behavior) => {
  const highPriority = [];
  const normalPriority = [];
  let state = initialState;
  let processing = false;
  
  const processNext = async () => {
    if (processing) return;
    
    const queue = highPriority.length > 0 ? highPriority : normalPriority;
    if (queue.length === 0) return;
    
    processing = true;
    const message = queue.shift();
    
    try {
      state = await behavior(state, message);
    } finally {
      processing = false;
      processNext();
    }
  };
  
  return {
    send: (message, priority = 'normal') => {
      const queue = priority === 'high' ? highPriority : normalPriority;
      queue.push(message);
      processNext();
    }
  };
};
```

**Selective Receive**

Wait for specific message types:

```javascript
const createSelectiveActor = (initialState, behavior) => {
  const mailbox = [];
  const waiters = [];
  
  return {
    send: (message) => {
      // Check if any waiter is interested in this message
      const waiterIndex = waiters.findIndex(w => w.predicate(message));
      
      if (waiterIndex >= 0) {
        const waiter = waiters.splice(waiterIndex, 1)[0];
        waiter.resolve(message);
      } else {
        mailbox.push(message);
      }
    },
    
    receive: (predicate = () => true) => new Promise((resolve) => {
      // Check existing mailbox first
      const index = mailbox.findIndex(predicate);
      
      if (index >= 0) {
        resolve(mailbox.splice(index, 1)[0]);
      } else {
        waiters.push({ predicate, resolve });
      }
    })
  };
};

const actor = createSelectiveActor({}, behavior);

// Wait for specific message type
const response = await actor.receive(msg => msg.type === 'response');
```

**Dataflow Concurrency**

Variables resolved when dependencies available:

```javascript
const createDataflow = () => {
  const values = new Map();
  const waiters = new Map();
  
  return {
    set: (key, value) => {
      values.set(key, value);
      
      const waiting = waiters.get(key);
      if (waiting) {
        waiting.forEach(resolve => resolve(value));
        waiters.delete(key);
      }
    },
    
    get: (key) => {
      if (values.has(key)) {
        return Promise.resolve(values.get(key));
      }
      
      return new Promise((resolve) => {
        if (!waiters.has(key)) {
          waiters.set(key, []);
        }
        waiters.get(key).push(resolve);
      });
    }
  };
};

const df = createDataflow();

// Concurrent computations with dependencies
const computation1 = async () => {
  const a = await df.get('a');
  const b = await df.get('b');
  df.set('c', a + b);
};

const computation2 = async () => {
  const c = await df.get('c');
  const d = await df.get('d');
  df.set('result', c * d);
};

df.set('a', 10);
df.set('b', 20);
df.set('d', 5);

await Promise.all([computation1(), computation2()]);
const result = await df.get('result');
```

