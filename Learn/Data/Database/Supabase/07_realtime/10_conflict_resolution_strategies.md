## Conflict Resolution Strategies


When multiple clients modify shared state simultaneously, conflicts arise. Strategies needed to maintain consistency and resolve competing updates.

**Key points:**
- Realtime itself does not provide automatic conflict resolution
- Application must implement conflict resolution logic
- Common strategies: Last Write Wins, Operational Transformation, CRDTs, Version Vectors
- Database timestamps can help determine update order
- Optimistic updates require rollback mechanisms
- Broadcast events arrive in order per sender [Inference: but may interleave between senders]

**Last Write Wins (LWW) Strategy:**

Simple approach where the most recent update overwrites previous values. Uses timestamps to determine recency.

**Example:** Last Write Wins implementation
```javascript
const documentState = {
  content: '',
  lastModified: 0,
  modifiedBy: null
}

const docChannel = supabase
  .channel('document-lww')
  .on('broadcast', { event: 'content-update' }, ({ payload }) => {
    // Only apply if update is newer than current state
    if (payload.timestamp > documentState.lastModified) {
      documentState.content = payload.content
      documentState.lastModified = payload.timestamp
      documentState.modifiedBy = payload.userId
      renderDocument(documentState.content)
    } else {
      console.log('Ignoring stale update from', payload.userId)
    }
  })
  .subscribe()

function updateDocument(newContent) {
  const timestamp = Date.now()
  
  // Optimistic update
  documentState.content = newContent
  documentState.lastModified = timestamp
  documentState.modifiedBy = currentUser.id
  
  // Broadcast to others
  docChannel.send({
    type: 'broadcast',
    event: 'content-update',
    payload: {
      content: newContent,
      timestamp: timestamp,
      userId: currentUser.id
    }
  })
}
```

**Operational Transformation (OT) Strategy:**

Transforms operations to account for concurrent changes. Commonly used in collaborative text editors.

**Example:** Simple OT for text operations
```javascript
class Operation {
  constructor(type, position, content, userId) {
    this.type = type // 'insert' or 'delete'
    this.position = position
    this.content = content
    this.userId = userId
    this.timestamp = Date.now()
  }
}

// Transform operation against another operation
function transform(op1, op2) {
  if (op1.type === 'insert' && op2.type === 'insert') {
    if (op1.position < op2.position) {
      return op2 // No change needed
    } else if (op1.position > op2.position) {
      // Adjust position to account for op2's insertion
      return new Operation(
        op2.type,
        op2.position,
        op2.content,
        op2.userId
      )
    } else {
      // Same position, use timestamp to decide order
      if (op1.timestamp < op2.timestamp) {
        return new Operation(
          op2.type,
          op2.position + op1.content.length,
          op2.content,
          op2.userId
        )
      }
    }
  }
  
  if (op1.type === 'delete' && op2.type === 'insert') {
    if (op2.position <= op1.position) {
      return new Operation(
        op2.type,
        op2.position,
        op2.content,
        op2.userId
      )
    } else if (op2.position > op1.position + op1.content.length) {
      return new Operation(
        op2.type,
        op2.position - op1.content.length,
        op2.content,
        op2.userId
      )
    }
  }
  
  // Additional transformation rules for delete/delete, etc.
  return op2
}

const editorChannel = supabase
  .channel('editor-ot')
  .on('broadcast', { event: 'operation' }, ({ payload }) => {
    const remoteOp = new Operation(
      payload.type,
      payload.position,
      payload.content,
      payload.userId
    )
    
    // Transform against pending local operations
    let transformedOp = remoteOp
    for (const localOp of pendingOperations) {
      transformedOp = transform(localOp, transformedOp)
    }
    
    // Apply transformed operation
    applyOperation(transformedOp)
  })
  .subscribe()

let pendingOperations = []

function insertText(position, text) {
  const op = new Operation('insert', position, text, currentUser.id)
  pendingOperations.push(op)
  
  applyOperation(op)
  
  editorChannel.send({
    type: 'broadcast',
    event: 'operation',
    payload: op
  })
  
  // Remove from pending after acknowledgment
  setTimeout(() => {
    pendingOperations = pendingOperations.filter(o => o !== op)
  }, 1000)
}
```

[Note: Full OT implementation is complex and requires careful handling of many edge cases. Libraries like ShareDB or Yjs provide robust OT/CRDT implementations.]

**CRDT (Conflict-free Replicated Data Types) Strategy:**

Data structures designed to merge concurrent updates without conflicts. Guaranteed eventual consistency.

**Example:** Simple CRDT counter
```javascript
class CRDTCounter {
  constructor(userId) {
    this.userId = userId
    this.counts = {} // { userId: count }
  }
  
  increment(amount = 1) {
    if (!this.counts[this.userId]) {
      this.counts[this.userId] = 0
    }
    this.counts[this.userId] += amount
    return this.getValue()
  }
  
  merge(remoteCounts) {
    for (const [userId, count] of Object.entries(remoteCounts)) {
      this.counts[userId] = Math.max(
        this.counts[userId] || 0,
        count
      )
    }
    return this.getValue()
  }
  
  getValue() {
    return Object.values(this.counts).reduce((sum, c) => sum + c, 0)
  }
}

const counter = new CRDTCounter(currentUser.id)

const counterChannel = supabase
  .channel('shared-counter')
  .on('broadcast', { event: 'counter-update' }, ({ payload }) => {
    counter.merge(payload.counts)
    updateCounterDisplay(counter.getValue())
  })
  .subscribe()

function incrementCounter() {
  const newValue = counter.increment()
  updateCounterDisplay(newValue)
  
  counterChannel.send({
    type: 'broadcast',
    event: 'counter-update',
    payload: {
      counts: counter.counts
    }
  })
}
```

**Version Vector Strategy:**

Track causality between updates using version vectors. Detects concurrent modifications.

**Example:** Version vector conflict detection
```javascript
class VersionVector {
  constructor() {
    this.vector = {} // { userId: version }
  }
  
  increment(userId) {
    this.vector[userId] = (this.vector[userId] || 0) + 1
  }
  
  merge(otherVector) {
    for (const [userId, version] of Object.entries(otherVector)) {
      this.vector[userId] = Math.max(
        this.vector[userId] || 0,
        version
      )
    }
  }
  
  compare(otherVector) {
    let hasGreater = false
    let hasLess = false
    
    const allUserIds = new Set([
      ...Object.keys(this.vector),
      ...Object.keys(otherVector.vector)
    ])
    
    for (const userId of allUserIds) {
      const thisVersion = this.vector[userId] || 0
      const otherVersion = otherVector.vector[userId] || 0
      
      if (thisVersion > otherVersion) hasGreater = true
      if (thisVersion < otherVersion) hasLess = true
    }
    
    if (!hasGreater && !hasLess) return 'equal'
    if (hasGreater && !hasLess) return 'greater'
    if (!hasGreater && hasLess) return 'less'
    return 'concurrent' // Conflict detected
  }
  
  clone() {
    const cloned = new VersionVector()
    cloned.vector = { ...this.vector }
    return cloned
  }
}

const localVersion = new VersionVector()
let documentContent = ''

const versionChannel = supabase
  .channel('versioned-document')
  .on('broadcast', { event: 'update' }, ({ payload }) => {
    const remoteVersion = new VersionVector()
    remoteVersion.vector = payload.version
    
    const comparison = localVersion.compare(remoteVersion)
    
    if (comparison === 'less') {
      // Remote is newer, apply it
      documentContent = payload.content
      localVersion.merge(payload.version)
      renderDocument(documentContent)
    } else if (comparison === 'concurrent') {
      // Conflict detected, need resolution strategy
      handleConflict(documentContent, payload.content, localVersion, remoteVersion)
    } else {
      // Local is equal or newer, ignore
      console.log('Ignoring older update')
    }
  })
  .subscribe()

function updateContent(newContent) {
  documentContent = newContent
  localVersion.increment(currentUser.id)
  
  versionChannel.send({
    type: 'broadcast',
    event: 'update',
    payload: {
      content: newContent,
      version: localVersion.vector,
      userId: currentUser.id
    }
  })
}

function handleConflict(localContent, remoteContent, localVer, remoteVer) {
  // Strategy: Show conflict UI and let user choose
  showConflictDialog({
    local: { content: localContent, version: localVer },
    remote: { content: remoteContent, version: remoteVer },
    onResolve: (chosenContent) => {
      documentContent = chosenContent
      localVersion.merge(remoteVer.vector)
      localVersion.increment(currentUser.id)
      
      versionChannel.send({
        type: 'broadcast',
        event: 'update',
        payload: {
          content: chosenContent,
          version: localVersion.vector,
          userId: currentUser.id
        }
      })
    }
  })
}
```

**Database-backed conflict resolution:**

Using database as source of truth with optimistic updates and rollback.

**Example:** Optimistic update with database verification
```javascript
let localState = { items: [] }
let pendingUpdates = new Map()

const syncChannel = supabase
  .channel('inventory-sync')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'inventory' },
    (payload) => {
      // Database change is source of truth
      if (payload.eventType === 'UPDATE') {
        const pendingId = `${payload.new.id}-${payload.new.updated_at}`
        
        if (!pendingUpdates.has(pendingId)) {
          // Not our update, remote change detected
          const item = localState.items.find(i => i.id === payload.new.id)
          if (item) {
            // Check for conflict
            if (item.version !== payload.old.version) {
              handleInventoryConflict(item, payload.new)
            } else {
              // No conflict, apply remote change
              updateLocalItem(payload.new)
            }
          }
        } else {
          // Our update was confirmed
          pendingUpdates.delete(pendingId)
        }
      }
    }
  )
  .subscribe()

async function updateItemQuantity(itemId, newQuantity) {
  const item = localState.items.find(i => i.id === itemId)
  const originalQuantity = item.quantity
  const originalVersion = item.version
  
  // Optimistic update
  item.quantity = newQuantity
  renderInventory(localState.items)
  
  try {
    // Attempt database update with version check
    const { data, error } = await supabase
      .from('inventory')
      .update({ 
        quantity: newQuantity,
        version: originalVersion + 1,
        updated_at: new Date().toISOString()
      })
      .eq('id', itemId)
      .eq('version', originalVersion) // Ensures no concurrent modification
      .select()
      .single()
    
    if (error || !data) {
      // Version mismatch or other error, rollback
      item.quantity = originalQuantity
      renderInventory(localState.items)
      
      // Fetch latest version
      const { data: latest } = await supabase
        .from('inventory')
        .select('*')
        .eq('id', itemId)
        .single()
      
      handleInventoryConflict(
        { ...item, quantity: originalQuantity },
        latest
      )
    } else {
      // Success, track pending update
      const pendingId = `${data.id}-${data.updated_at}`
      pendingUpdates.set(pendingId, { itemId, newQuantity })
      
      // Update local version
      item.version = data.version
    }
  } catch (err) {
    // Network error, rollback
    item.quantity = originalQuantity
    renderInventory(localState.items)
    showError('Update failed, please try again')
  }
}

function handleInventoryConflict(localItem, remoteItem) {
  showConflictDialog({
    message: `Item "${localItem.name}" was modified by another user`,
    local: `Your quantity: ${localItem.quantity}`,
    remote: `Their quantity: ${remoteItem.quantity}`,
    options: [
      {
        label: 'Keep yours',
        action: () => updateItemQuantity(localItem.id, localItem.quantity)
      },
      {
        label: 'Use theirs',
        action: () => updateLocalItem(remoteItem)
      },
      {
        label: 'Enter new value',
        action: () => promptForQuantity(localItem.id)
      }
    ]
  })
}
```

**Related topics:** WebSocket connection management, PostgreSQL logical replication configuration, Phoenix Channels architecture, Client-side state management patterns, Network partition handling, Eventual consistency models, Distributed systems conflict resolution

---

