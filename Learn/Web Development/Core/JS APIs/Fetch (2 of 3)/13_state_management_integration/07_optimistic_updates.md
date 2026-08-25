## Optimistic Updates


### Basic Optimistic Update Pattern

#### Simple Implementation

```javascript
async function updateItemOptimistically(itemId, newData) {
  // Store original state
  const originalItem = getItem(itemId);
  
  // Update UI immediately
  updateUI(itemId, newData);
  
  try {
    // Send request to server
    const response = await fetch(`/api/items/${itemId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newData)
    });
    
    if (!response.ok) {
      throw new Error('Update failed');
    }
    
    // Optionally sync with server response
    const serverData = await response.json();
    updateUI(itemId, serverData);
    
  } catch (error) {
    // Rollback on failure
    updateUI(itemId, originalItem);
    showError('Update failed. Changes reverted.');
  }
}
```

#### With State Management

```javascript
class OptimisticStateManager {
  constructor() {
    this.state = {};
    this.pendingUpdates = new Map();
  }
  
  getItem(id) {
    return this.state[id];
  }
  
  async updateItem(id, updates) {
    const original = { ...this.state[id] };
    const optimistic = { ...original, ...updates };
    
    // Apply optimistic update
    this.state[id] = optimistic;
    this.notifyListeners(id);
    
    // Track pending update
    const updateId = Date.now();
    this.pendingUpdates.set(updateId, { id, original });
    
    try {
      const response = await fetch(`/api/items/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates)
      });
      
      if (!response.ok) throw new Error('Update failed');
      
      const serverData = await response.json();
      this.state[id] = serverData;
      this.notifyListeners(id);
      
    } catch (error) {
      // Rollback
      this.state[id] = original;
      this.notifyListeners(id);
      throw error;
      
    } finally {
      this.pendingUpdates.delete(updateId);
    }
  }
  
  notifyListeners(id) {
    // Trigger UI updates
  }
}
```

### Handling Multiple Concurrent Updates

#### Queue-Based Approach

```javascript
class UpdateQueue {
  constructor() {
    this.queues = new Map(); // resourceId -> array of updates
  }
  
  async enqueue(resourceId, updateFn) {
    if (!this.queues.has(resourceId)) {
      this.queues.set(resourceId, []);
    }
    
    const queue = this.queues.get(resourceId);
    
    return new Promise((resolve, reject) => {
      queue.push({ updateFn, resolve, reject });
      
      if (queue.length === 1) {
        this.processQueue(resourceId);
      }
    });
  }
  
  async processQueue(resourceId) {
    const queue = this.queues.get(resourceId);
    
    while (queue.length > 0) {
      const { updateFn, resolve, reject } = queue[0];
      
      try {
        const result = await updateFn();
        resolve(result);
      } catch (error) {
        reject(error);
      }
      
      queue.shift();
    }
    
    this.queues.delete(resourceId);
  }
}

// Usage
const updateQueue = new UpdateQueue();

async function optimisticUpdate(itemId, data) {
  return updateQueue.enqueue(itemId, async () => {
    const original = getItem(itemId);
    updateUI(itemId, data);
    
    try {
      const response = await fetch(`/api/items/${itemId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });
      
      if (!response.ok) throw new Error('Failed');
      return await response.json();
      
    } catch (error) {
      updateUI(itemId, original);
      throw error;
    }
  });
}
```

#### Conflict Resolution

```javascript
class ConflictResolver {
  async updateWithConflictResolution(itemId, localChanges) {
    const originalVersion = getItemVersion(itemId);
    const original = getItem(itemId);
    
    // Apply optimistic update
    const optimistic = { ...original, ...localChanges };
    updateUI(itemId, optimistic);
    
    try {
      const response = await fetch(`/api/items/${itemId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'If-Match': originalVersion // ETag-based versioning
        },
        body: JSON.stringify(localChanges)
      });
      
      if (response.status === 409) {
        // Conflict detected
        const serverData = await response.json();
        const resolved = await this.resolveConflict(original, localChanges, serverData);
        
        updateUI(itemId, resolved);
        
        // Retry with resolved data
        return this.updateWithConflictResolution(itemId, resolved);
      }
      
      if (!response.ok) throw new Error('Update failed');
      
      const serverData = await response.json();
      updateUI(itemId, serverData);
      return serverData;
      
    } catch (error) {
      // Rollback
      updateUI(itemId, original);
      throw error;
    }
  }
  
  async resolveConflict(original, local, server) {
    // Strategy 1: Server wins
    return server;
    
    // Strategy 2: Local wins (force update)
    // return local;
    
    // Strategy 3: Field-level merge
    // const merged = { ...server };
    // for (const [key, value] of Object.entries(local)) {
    //   if (original[key] === server[key]) {
    //     merged[key] = value;
    //   }
    // }
    // return merged;
    
    // Strategy 4: Prompt user
    // return await promptUserForResolution(original, local, server);
  }
}
```

### Optimistic Creation

#### Creating New Items

```javascript
async function optimisticCreate(newItem) {
  // Generate temporary ID
  const tempId = `temp-${Date.now()}`;
  const optimisticItem = {
    id: tempId,
    ...newItem,
    _pending: true
  };
  
  // Add to UI immediately
  addToUI(optimisticItem);
  
  try {
    const response = await fetch('/api/items', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newItem)
    });
    
    if (!response.ok) throw new Error('Creation failed');
    
    const serverItem = await response.json();
    
    // Replace temporary item with server version
    replaceInUI(tempId, serverItem);
    
    return serverItem;
    
  } catch (error) {
    // Remove optimistic item
    removeFromUI(tempId);
    showError('Failed to create item');
    throw error;
  }
}
```

#### Handling Dependent Creates

```javascript
class DependentCreateManager {
  constructor() {
    this.tempIdMap = new Map(); // temp ID -> server ID
  }
  
  async createWithDependencies(item, dependencies = []) {
    // Wait for dependencies to resolve
    const resolvedDeps = await Promise.all(
      dependencies.map(dep => this.resolveTempId(dep))
    );
    
    // Replace temp IDs in item
    const itemWithResolvedDeps = this.replaceTempIds(item, resolvedDeps);
    
    const tempId = `temp-${Date.now()}`;
    const optimisticItem = { id: tempId, ...itemWithResolvedDeps };
    
    addToUI(optimisticItem);
    
    const promise = (async () => {
      try {
        const response = await fetch('/api/items', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(itemWithResolvedDeps)
        });
        
        if (!response.ok) throw new Error('Creation failed');
        
        const serverItem = await response.json();
        this.tempIdMap.set(tempId, serverItem.id);
        
        replaceInUI(tempId, serverItem);
        return serverItem;
        
      } catch (error) {
        removeFromUI(tempId);
        throw error;
      }
    })();
    
    // Store promise for dependency resolution
    this.tempIdMap.set(tempId, promise);
    
    return promise;
  }
  
  async resolveTempId(id) {
    if (!id.startsWith('temp-')) return id;
    
    const value = this.tempIdMap.get(id);
    
    if (value instanceof Promise) {
      const resolved = await value;
      return resolved.id;
    }
    
    return value || id;
  }
  
  replaceTempIds(item, resolvedDeps) {
    // Replace temp IDs in item properties
    const result = { ...item };
    
    for (const [key, value] of Object.entries(result)) {
      if (typeof value === 'string' && value.startsWith('temp-')) {
        result[key] = this.tempIdMap.get(value) || value;
      }
    }
    
    return result;
  }
}
```

### Optimistic Deletion

#### Safe Delete with Undo

```javascript
class OptimisticDelete {
  constructor() {
    this.deletedItems = new Map();
    this.undoTimeouts = new Map();
  }
  
  async deleteItem(itemId, { undoTimeout = 5000 } = {}) {
    const item = getItem(itemId);
    
    // Mark as deleted in UI (fade out, strikethrough, etc.)
    markAsDeleted(itemId);
    
    // Store for potential undo
    this.deletedItems.set(itemId, item);
    
    // Set up undo timeout
    const timeoutId = setTimeout(() => {
      this.commitDelete(itemId);
    }, undoTimeout);
    
    this.undoTimeouts.set(itemId, timeoutId);
    
    // Show undo notification
    showUndoNotification(itemId, undoTimeout);
  }
  
  async commitDelete(itemId) {
    const item = this.deletedItems.get(itemId);
    if (!item) return;
    
    try {
      const response = await fetch(`/api/items/${itemId}`, {
        method: 'DELETE'
      });
      
      if (!response.ok) throw new Error('Delete failed');
      
      // Remove from UI permanently
      removeFromUI(itemId);
      
    } catch (error) {
      // Restore item on failure
      this.undoDelete(itemId);
      showError('Delete failed. Item restored.');
    } finally {
      this.deletedItems.delete(itemId);
      this.undoTimeouts.delete(itemId);
    }
  }
  
  undoDelete(itemId) {
    // Clear timeout
    const timeoutId = this.undoTimeouts.get(itemId);
    if (timeoutId) {
      clearTimeout(timeoutId);
      this.undoTimeouts.delete(itemId);
    }
    
    // Restore item
    const item = this.deletedItems.get(itemId);
    if (item) {
      restoreInUI(itemId, item);
      this.deletedItems.delete(itemId);
    }
  }
}
```

### Batch Optimistic Updates

#### Batching Multiple Changes

```javascript
class BatchOptimisticUpdater {
  constructor() {
    this.batch = [];
    this.batchTimer = null;
    this.flushDelay = 300;
  }
  
  scheduleUpdate(itemId, updates) {
    // Apply optimistic update immediately
    const original = getItem(itemId);
    const optimistic = { ...original, ...updates };
    updateUI(itemId, optimistic);
    
    // Add to batch
    this.batch.push({
      itemId,
      updates,
      original,
      optimistic
    });
    
    // Schedule flush
    clearTimeout(this.batchTimer);
    this.batchTimer = setTimeout(() => this.flush(), this.flushDelay);
  }
  
  async flush() {
    if (this.batch.length === 0) return;
    
    const currentBatch = [...this.batch];
    this.batch = [];
    
    try {
      const response = await fetch('/api/items/batch', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          updates: currentBatch.map(({ itemId, updates }) => ({
            id: itemId,
            data: updates
          }))
        })
      });
      
      if (!response.ok) throw new Error('Batch update failed');
      
      const results = await response.json();
      
      // Update with server data
      results.forEach(serverItem => {
        updateUI(serverItem.id, serverItem);
      });
      
    } catch (error) {
      // Rollback all changes in batch
      currentBatch.forEach(({ itemId, original }) => {
        updateUI(itemId, original);
      });
      
      showError('Batch update failed. Changes reverted.');
    }
  }
  
  async forceFlush() {
    clearTimeout(this.batchTimer);
    await this.flush();
  }
}
```

### Optimistic UI Indicators

#### Visual Feedback Patterns

```javascript
class OptimisticUIManager {
  constructor() {
    this.pendingOperations = new Map();
  }
  
  async performOptimisticUpdate(itemId, updates, operation) {
    // Track operation
    this.pendingOperations.set(itemId, {
      type: operation,
      startTime: Date.now()
    });
    
    // Update UI with pending indicator
    this.updatePendingState(itemId, true);
    
    const original = getItem(itemId);
    updateUI(itemId, { ...original, ...updates });
    
    try {
      const response = await fetch(`/api/items/${itemId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates)
      });
      
      if (!response.ok) throw new Error('Update failed');
      
      const serverData = await response.json();
      updateUI(itemId, serverData);
      
      // Success feedback
      this.showSuccessFeedback(itemId);
      
    } catch (error) {
      updateUI(itemId, original);
      this.showErrorFeedback(itemId);
      throw error;
      
    } finally {
      this.pendingOperations.delete(itemId);
      this.updatePendingState(itemId, false);
    }
  }
  
  updatePendingState(itemId, isPending) {
    const element = document.querySelector(`[data-item-id="${itemId}"]`);
    if (!element) return;
    
    if (isPending) {
      element.classList.add('optimistic-pending');
      element.setAttribute('aria-busy', 'true');
    } else {
      element.classList.remove('optimistic-pending');
      element.removeAttribute('aria-busy');
    }
  }
  
  showSuccessFeedback(itemId) {
    const element = document.querySelector(`[data-item-id="${itemId}"]`);
    if (!element) return;
    
    element.classList.add('optimistic-success');
    setTimeout(() => {
      element.classList.remove('optimistic-success');
    }, 1000);
  }
  
  showErrorFeedback(itemId) {
    const element = document.querySelector(`[data-item-id="${itemId}"]`);
    if (!element) return;
    
    element.classList.add('optimistic-error');
    setTimeout(() => {
      element.classList.remove('optimistic-error');
    }, 2000);
  }
}
```

### Offline Queue with Optimistic Updates

#### Persisting Pending Operations

```javascript
class OfflineOptimisticQueue {
  constructor() {
    this.queue = this.loadQueue();
    this.processing = false;
    
    window.addEventListener('online', () => this.processQueue());
  }
  
  loadQueue() {
    const stored = localStorage.getItem('optimistic-queue');
    return stored ? JSON.parse(stored) : [];
  }
  
  saveQueue() {
    localStorage.setItem('optimistic-queue', JSON.stringify(this.queue));
  }
  
  async enqueue(operation) {
    const queueItem = {
      id: `op-${Date.now()}`,
      operation,
      timestamp: Date.now(),
      retries: 0
    };
    
    this.queue.push(queueItem);
    this.saveQueue();
    
    // Apply optimistic update immediately
    this.applyOptimisticChange(operation);
    
    if (navigator.onLine) {
      this.processQueue();
    }
    
    return queueItem.id;
  }
  
  async processQueue() {
    if (this.processing || this.queue.length === 0) return;
    
    this.processing = true;
    
    while (this.queue.length > 0 && navigator.onLine) {
      const item = this.queue[0];
      
      try {
        await this.executeOperation(item.operation);
        this.queue.shift();
        this.saveQueue();
        
      } catch (error) {
        item.retries++;
        
        if (item.retries >= 3) {
          // Max retries reached
          this.queue.shift();
          this.rollbackOperation(item.operation);
          showError('Operation failed after retries');
        } else {
          // Retry later
          await new Promise(resolve => setTimeout(resolve, 1000 * item.retries));
        }
        
        this.saveQueue();
      }
    }
    
    this.processing = false;
  }
  
  async executeOperation(operation) {
    const { type, itemId, data } = operation;
    
    const response = await fetch(`/api/items/${itemId}`, {
      method: type === 'update' ? 'PUT' : type === 'create' ? 'POST' : 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: type !== 'delete' ? JSON.stringify(data) : undefined
    });
    
    if (!response.ok) throw new Error('Operation failed');
    
    return await response.json();
  }
  
  applyOptimisticChange(operation) {
    // Apply change to UI
    switch (operation.type) {
      case 'update':
        updateUI(operation.itemId, operation.data);
        break;
      case 'create':
        addToUI(operation.data);
        break;
      case 'delete':
        markAsDeleted(operation.itemId);
        break;
    }
  }
  
  rollbackOperation(operation) {
    // Revert optimistic change
    switch (operation.type) {
      case 'update':
        updateUI(operation.itemId, operation.original);
        break;
      case 'create':
        removeFromUI(operation.tempId);
        break;
      case 'delete':
        restoreInUI(operation.itemId, operation.original);
        break;
    }
  }
}
```

### Optimistic Reordering

#### Drag and Drop with Optimistic Updates

```javascript
class OptimisticReorder {
  async reorderItems(itemId, newPosition, list) {
    const oldPosition = list.findIndex(item => item.id === itemId);
    const oldList = [...list];
    
    // Optimistic reorder
    const newList = [...list];
    const [item] = newList.splice(oldPosition, 1);
    newList.splice(newPosition, 0, item);
    
    // Update UI immediately
    updateListUI(newList);
    
    try {
      const response = await fetch(`/api/items/${itemId}/reorder`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          position: newPosition,
          adjacentIds: {
            before: newList[newPosition - 1]?.id,
            after: newList[newPosition + 1]?.id
          }
        })
      });
      
      if (!response.ok) throw new Error('Reorder failed');
      
      // Optionally sync with server order
      const serverList = await response.json();
      updateListUI(serverList);
      
    } catch (error) {
      // Revert to old order
      updateListUI(oldList);
      showError('Reorder failed. Changes reverted.');
    }
  }
}
```

### Transaction-like Updates

#### Atomic Multi-Resource Updates

```javascript
class OptimisticTransaction {
  constructor() {
    this.activeTransactions = new Map();
  }
  
  async executeTransaction(transactionId, operations) {
    const rollbackData = [];
    
    // Apply all optimistic changes
    for (const op of operations) {
      const original = this.applyOptimisticOp(op);
      rollbackData.push({ op, original });
    }
    
    this.activeTransactions.set(transactionId, rollbackData);
    
    try {
      const response = await fetch('/api/transactions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ operations })
      });
      
      if (!response.ok) throw new Error('Transaction failed');
      
      const results = await response.json();
      
      // Update with server data
      results.forEach(result => {
        updateUI(result.id, result.data);
      });
      
    } catch (error) {
      // Rollback entire transaction
      this.rollbackTransaction(transactionId);
      showError('Transaction failed. All changes reverted.');
      throw error;
      
    } finally {
      this.activeTransactions.delete(transactionId);
    }
  }
  
  applyOptimisticOp(op) {
    const { type, resourceId, data } = op;
    const original = getItem(resourceId);
    
    switch (type) {
      case 'update':
        updateUI(resourceId, { ...original, ...data });
        break;
      case 'create':
        addToUI(data);
        break;
      case 'delete':
        markAsDeleted(resourceId);
        break;
    }
    
    return original;
  }
  
  rollbackTransaction(transactionId) {
    const rollbackData = this.activeTransactions.get(transactionId);
    if (!rollbackData) return;
    
    // Rollback in reverse order
    for (let i = rollbackData.length - 1; i >= 0; i--) {
      const { op, original } = rollbackData[i];
      
      switch (op.type) {
        case 'update':
          updateUI(op.resourceId, original);
          break;
        case 'create':
          removeFromUI(op.data.id);
          break;
        case 'delete':
          restoreInUI(op.resourceId, original);
          break;
      }
    }
  }
}
```

---

