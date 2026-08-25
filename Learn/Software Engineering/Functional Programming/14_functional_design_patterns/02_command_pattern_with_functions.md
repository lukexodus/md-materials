## Command Pattern with Functions


The command pattern in functional style replaces command objects with functions, often enhanced with closures to capture necessary state. Commands become pure data structures paired with executor functions, or simply thunks (parameterless functions) that encapsulate both the action and its parameters.

**Basic Command as Function**

The simplest form treats commands as functions that can be stored, passed around, and executed later. Each command is a closure that captures the parameters needed for execution.

```javascript
// Command creators return executable functions
const createMoveCommand = (entity, x, y) => () => {
  entity.position = { x, y };
};

const createAttackCommand = (attacker, target) => () => {
  target.health -= attacker.damage;
};

// Store and execute later
const commands = [
  createMoveCommand(player, 10, 20),
  createAttackCommand(player, enemy),
  createMoveCommand(player, 15, 25)
];

commands.forEach(cmd => cmd());
```

**Commands as Data**

Represent commands as plain data structures (objects or arrays) that separate the command description from its execution. This enables serialization, persistence, and network transmission.

```javascript
// Commands as data
const moveCommand = { type: 'MOVE', entityId: 'player1', x: 10, y: 20 };
const attackCommand = { type: 'ATTACK', attackerId: 'player1', targetId: 'enemy1' };

// Executor interprets command data
const executeCommand = (command, gameState) => {
  switch (command.type) {
    case 'MOVE':
      return {
        ...gameState,
        entities: {
          ...gameState.entities,
          [command.entityId]: {
            ...gameState.entities[command.entityId],
            position: { x: command.x, y: command.y }
          }
        }
      };
    case 'ATTACK':
      const attacker = gameState.entities[command.attackerId];
      const target = gameState.entities[command.targetId];
      return {
        ...gameState,
        entities: {
          ...gameState.entities,
          [command.targetId]: {
            ...target,
            health: target.health - attacker.damage
          }
        }
      };
    default:
      return gameState;
  }
};
```

**Undo/Redo Implementation**

Implement undo functionality by storing both commands and their inverse operations. Each command can include an undo function or the data needed to reverse its effects.

```javascript
const createUndoableCommand = (execute, undo) => ({
  execute,
  undo
});

const createMoveCommand = (entity, newX, newY) => {
  const oldX = entity.position.x;
  const oldY = entity.position.y;
  
  return createUndoableCommand(
    () => { entity.position = { x: newX, y: newY }; },
    () => { entity.position = { x: oldX, y: oldY }; }
  );
};

// Command history manager
const commandHistory = {
  past: [],
  future: [],
  
  execute(command) {
    command.execute();
    this.past.push(command);
    this.future = []; // Clear redo stack
  },
  
  undo() {
    if (this.past.length === 0) return;
    const command = this.past.pop();
    command.undo();
    this.future.push(command);
  },
  
  redo() {
    if (this.future.length === 0) return;
    const command = this.future.pop();
    command.execute();
    this.past.push(command);
  }
};
```

**Command Queue and Batching**

Commands can be queued for batch execution, scheduled for delayed execution, or grouped into macro commands that execute multiple operations atomically.

```javascript
const createCommandQueue = () => {
  const queue = [];
  
  return {
    enqueue(command) {
      queue.push(command);
    },
    
    executeAll() {
      const results = [];
      while (queue.length > 0) {
        const command = queue.shift();
        results.push(command());
      }
      return results;
    },
    
    executeBatch(batchSize) {
      const batch = queue.splice(0, batchSize);
      return batch.map(cmd => cmd());
    }
  };
};

// Macro command - composite of multiple commands
const createMacroCommand = (...commands) => () => {
  return commands.map(cmd => cmd());
};

const moveAndAttack = createMacroCommand(
  createMoveCommand(player, 10, 10),
  createAttackCommand(player, enemy)
);
```

**Async Command Handling**

Commands can return promises for asynchronous operations, enabling complex workflows with sequential or parallel execution patterns.

```javascript
const createAsyncCommand = (asyncFn) => async () => {
  return await asyncFn();
};

const saveGameCommand = createAsyncCommand(async () => {
  const data = serializeGameState();
  await fetch('/api/save', { method: 'POST', body: data });
  return { success: true };
});

const loadGameCommand = createAsyncCommand(async () => {
  const response = await fetch('/api/load');
  const data = await response.json();
  return deserializeGameState(data);
});

// Sequential execution
const executeSequentially = async (commands) => {
  const results = [];
  for (const command of commands) {
    results.push(await command());
  }
  return results;
};

// Parallel execution
const executeParallel = async (commands) => {
  return await Promise.all(commands.map(cmd => cmd()));
};
```

**Transaction-like Commands**

Implement transactional semantics where commands can be validated before execution and rolled back on failure.

```javascript
const createTransaction = (commands) => {
  const executedCommands = [];
  
  return {
    async execute() {
      try {
        for (const command of commands) {
          await command.execute();
          executedCommands.push(command);
        }
        return { success: true };
      } catch (error) {
        // Rollback in reverse order
        for (const command of executedCommands.reverse()) {
          await command.undo();
        }
        return { success: false, error };
      }
    }
  };
};
```

**Command Middleware**

Apply middleware pattern to commands for cross-cutting concerns like logging, validation, or authorization.

```javascript
const withLogging = (command) => () => {
  console.log('Executing command');
  const result = command();
  console.log('Command completed', result);
  return result;
};

const withValidation = (command, validator) => () => {
  if (!validator()) {
    throw new Error('Validation failed');
  }
  return command();
};

const withRetry = (command, maxAttempts = 3) => async () => {
  for (let i = 0; i < maxAttempts; i++) {
    try {
      return await command();
    } catch (error) {
      if (i === maxAttempts - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
};

// Compose middleware
const enhancedCommand = withLogging(
  withValidation(
    withRetry(saveGameCommand),
    () => gameState.isValid
  )
);
```

---

