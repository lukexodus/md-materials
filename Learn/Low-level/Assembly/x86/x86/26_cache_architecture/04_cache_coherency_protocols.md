## Cache Coherency Protocols


Cache coherency protocols ensure that multiple copies of data across different caches remain consistent in multi-core and multi-processor systems.

### The Cache Coherency Problem

When multiple cores each have local caches, a single memory location can have multiple copies:

```
Core 0 L1: Address 0x1000 = Value 42
Core 1 L1: Address 0x1000 = Value 42
Main Memory: Address 0x1000 = Value 42

Core 0 writes 99 to 0x1000:
Core 0 L1: Address 0x1000 = Value 99  (MODIFIED)
Core 1 L1: Address 0x1000 = Value 42  (STALE!)
Main Memory: Address 0x1000 = Value 42  (STALE!)

Problem: Core 1 reads stale data
```

**Coherency Requirements**:

1. **Write Propagation**: Writes to a location must eventually be visible to all cores
2. **Write Serialization**: Writes to the same location must be seen in the same order by all cores
3. **Read Value**: A read must return the value of the most recent write

### MESI Protocol

Modern x86 processors use variants of the MESI protocol (Modified, Exclusive, Shared, Invalid).

**MESI States**:

**Modified (M)**:

- Cache line is valid and modified (dirty)
- No other cache has a copy
- Main memory is stale
- Responsible for writing back to memory on eviction

**Exclusive (E)**:

- Cache line is valid and unmodified (clean)
- No other cache has a copy
- Matches main memory
- Can transition to Modified without notification

**Shared (S)**:

- Cache line is valid and unmodified
- Other caches may have copies
- Matches main memory
- Must notify others before modifying

**Invalid (I)**:

- Cache line is not valid
- Cannot be read from
- Default state for empty cache lines

**State Transitions**:

```
Initial State: All caches have line in Invalid state

Core 0 reads address X:
1. Cache miss, load from memory
2. Core 0 transitions I → E (exclusive, no other cache has it)

Core 1 reads same address X:
1. Snoop detects Core 0 has it in E state
2. Core 0 transitions E → S (now shared)
3. Core 1 loads into S state
4. Both cores have Shared copies

Core 0 writes to address X:
1. Core 0 must notify other caches (RFO - Request For Ownership)
2. Core 1 transitions S → I (invalidate)
3. Core 0 transitions S → M (modified, exclusive ownership)
4. Only Core 0 has valid copy

Core 1 reads address X again:
1. Snoop detects Core 0 has it in M state
2. Core 0 writes back to memory (or provides directly)
3. Core 0 transitions M → S
4. Core 1 loads into S state
```

```assembly
; Example demonstrating MESI transitions
section .data
align 64
shared_var: dd 0

; Core 0 code
core0_code:
    ; Read - transition I → E
    mov eax, [shared_var]       ; State: E (exclusive)
    
    ; Core 1 reads meanwhile...
    ; Core 0 automatically transitions E → S
    
    ; Write - must invalidate other caches
    mov dword [shared_var], 42  ; Sends invalidation
                                ; State: M (modified)
    ; Core 1's copy now in I (invalid) state
    ret

; Core 1 code (running simultaneously)
core1_code:
    ; Read while Core 0 has Exclusive
    mov ebx, [shared_var]       ; Snoop hit
                                ; Core 0: E → S
                                ; Core 1: I → S
    
    ; Read after Core 0 modified
    mov ecx, [shared_var]       ; Core 0: M → S (writeback)
                                ; Core 1: I → S
                                ; Reads latest value
    ret
```

### MESIF Protocol (Intel)

Intel extends MESI with Forward state:

**Forward (F)**:

- Like Shared but designated responder
- Reduces memory bandwidth by avoiding multiple copies responding
- One cache in F state, others in S state

```
Multiple cores read same line:
- One cache gets F state (designated forwarder)
- Others get S state
- Future reads serviced by F cache, not memory
- Reduces memory traffic
```

### MOESI Protocol (AMD)

AMD extends MESI with Owned state:

**Owned (O)**:

- Cache line is modified but shared with other caches
- Responsible for providing data to other caches
- Must eventually write back to memory
- Avoids immediate writeback when sharing modified data

```
Core 0 modifies data (M state)
Core 1 reads it:
- Core 0 transitions M → O (owned)
- Core 1 gets S state
- Core 0 provides data without writing to memory yet
- Reduces memory writes
```

### Cache Coherency Bus Operations

**Read Operations**:

**Read Hit**: Data in cache with valid state (E, S, M, O) - no bus transaction needed

**Read Miss**: Data not in cache or in Invalid state

```
1. Issue BusRd (read request) on bus
2. Other caches snoop request
3. If another cache has M/O state: provides data (intervention)
4. Otherwise: memory provides data
5. Update cache state based on snoop results
```

**Write Operations**:

**Write Hit** (Modified or Exclusive state): Can write directly

```assembly
write_hit_exclusive:
    mov dword [exclusive_data], 42  ; State E or M
    ; No bus transaction needed
    ; E → M transition (silent)
    ret
```

**Write Hit** (Shared state): Must invalidate other copies

```assembly
write_hit_shared:
    mov dword [shared_data], 42     ; State S
    ; Issues BusRdX (Read for eXclusive)
    ; All other caches invalidate their copies
    ; S → M transition
    ret
```

**Write Miss**: Must obtain exclusive ownership

```
1. Issue BusRdX (read for exclusive)
2. Other caches invalidate their copies
3. Load data and transition to M state
```

### Snooping Mechanism

Each cache monitors (snoops) the bus for operations affecting its cached data.

```
Bus Transaction         Cache State     Action
────────────────        ───────────     ──────
BusRd observed          Modified        Provide data, M → S
BusRd observed          Exclusive       E → S (silent)
BusRd observed          Shared          Remain S
BusRd observed          Invalid         No action

BusRdX observed         Modified        Provide data, M → I
BusRdX observed         Exclusive       E → I
BusRdX observed         Shared          S → I
BusRdX observed         Invalid         No action
```

```assembly
; Demonstrating snoop effects
section .data
align 64
coherent_data: dd 100

; Core 0
core0_writer:
    mov dword [coherent_data], 200  ; BusRdX issued
                                    ; Invalidates all other caches
    ret

; Core 1 (snooping)
core1_reader:
    ; Had coherent_data in S state
    ; Snoops BusRdX from Core 0
    ; Automatically transitions S → I
    
    mov eax, [coherent_data]        ; Cache miss now
                                    ; Must reload from Core 0 or memory
                                    ; Gets value 200
    ret
```

### Performance Implications

**Cache-to-Cache Transfers**: Modern systems transfer data directly between caches (cache-to-cache transfer) rather than going through memory.

```
Core 0 has modified data (M state)
Core 1 requests data:
- Core 0 provides data directly to Core 1 (intervention)
- Faster than writing to memory first
- Latency: ~40-50 cycles (vs ~200 for memory)
```

**Request For Ownership (RFO)**: When writing to a shared cache line, core must request exclusive ownership.

```assembly
; RFO storm - performance killer
section .data
align 64
shared_counter: dd 0

; Multiple cores executing:
increment_shared:
    lock inc dword [shared_counter]
    ; Each increment:
    ; 1. Issues RFO to invalidate other caches
    ; 2. All other cores must invalidate
    ; 3. Next core repeats process
    ; Constant cache-line bouncing between cores
    ret

; Better: Per-core counters, sum at end
section .data
align 64
core0_counter: dd 0
times 60 db 0               ; Padding
align 64
core1_counter: dd 0
times 60 db 0

; Each core updates own counter (no RFO)
; Combine results at end
```

**Store Buffer and Memory Ordering**:

Processors use store buffers to hide write latency:

```
Store Buffer: Holds pending writes that haven't reached cache yet
- Allows store to complete quickly
- Store forwarding: Subsequent loads can read from store buffer
- Creates memory ordering complexities
```

```assembly
; Store buffer forwarding
store_forwarding:
    mov [data], eax         ; Goes to store buffer
    mov ebx, [data]         ; Forwarded from store buffer
    ; Second load doesn't wait for cache update
    ret

; Ordering issue across cores
; Core 0:
    mov [flag], 1           ; Goes to store buffer
    mov [data], eax         ; Goes to store buffer
    
; Core 1:
.wait:
    mov ebx, [flag]         ; Might see flag=1
    test ebx, ebx
    jz .wait
    mov ecx, [data]         ; Might see old data!
    ; Reordering due to store buffers
    
; Solution: Memory barrier
core0_with_barrier:
    mov [data], eax
    mfence                  ; Memory fence - orders stores
    mov [flag], 1
    ret
```

**Cache Line Bouncing**: Frequently modified data moving between caches.

```assembly
; Lock-based synchronization causes bouncing
spin_lock_example:
    ; Lock variable bounces between cores
.acquire:
    lock bts dword [lock_var], 0    ; Atomic test-and-set
    jc .acquire                     ; Spin if locked
    
    ; Critical section - only one core at a time
    ; Lock variable in Modified state on this core
    
    lock btr dword [lock_var], 0    ; Release lock
    ; Next core must request ownership (RFO)
    ; Lock bounces to that core
    ret

; Every acquisition causes RFO, bouncing cache line between cores
; Very expensive for high-contention locks
```

**Optimizing for Cache Coherency**:

```assembly
; Poor: Test-and-set loop generates constant RFO traffic
poor_spinlock:
.spin:
    lock bts dword [lock_var], 0    ; RFO every iteration!
    jc .spin
    ret

; Better: Test-and-test-and-set reduces RFO traffic
better_spinlock:
.spin:
    test dword [lock_var], 1        ; Read only, no RFO
    jnz .spin                       ; Spin on read
    lock bts dword [lock_var], 0    ; RFO only when likely available
    jc .spin
    ret

; Reading shared data doesn't cause RFO
; Only atomic write generates bus traffic
```

**Memory Barriers and Coherency**:

x86 provides fence instructions to control memory ordering:

```assembly
; MFENCE - Full memory barrier
full_barrier:
    mov [data], eax         ; Store
    mfence                  ; All prior loads/stores complete
    mov ebx, [flag]         ; Load
    ; Guarantees store visible before load executes
    ret

; SFENCE - Store barrier
store_barrier:
    mov [data1], eax
    mov [data2], ebx
    sfence                  ; All prior stores complete
    ; Guarantees both stores complete in order
    ret

; LFENCE - Load barrier
load_barrier:
    mov eax, [data1]
    lfence                  ; All prior loads complete
    mov ebx, [data2]
    ; Guarantees first load completes before second
    ret

; LOCK prefix - Implicit full barrier
lock_instruction:
    mov [data], eax         ; Regular store
    lock add dword [counter], 1  ; Full barrier
    mov ebx, [flag]         ; Load after barrier
    ; LOCK implies MFENCE behavior
    ret
```

**Directory-Based Coherency**: Large systems use directory to track cache line locations instead of snooping.

```
Directory Entry for Address X:
- Owner: Which cache has Modified/Exclusive copy
- Sharers: Bitmap of which caches have Shared copies
- State: Current coherency state

Advantages:
- Scales better than broadcast snooping
- Reduces bus traffic
- Used in multi-socket servers
```

**Key Points**:

- Cache coherency maintains consistency across multiple caches
- MESI protocol uses four states: Modified, Exclusive, Shared, Invalid
- Intel uses MESIF (adds Forward), AMD uses MOESI (adds Owned)
- Snooping monitors bus transactions to maintain coherency
- Write to shared line requires invalidating other caches (RFO)
- Cache-to-cache transfers avoid memory access for coherency operations
- Store buffers improve performance but complicate memory ordering
- Cache line bouncing occurs with high-contention shared data
- Memory barriers enforce ordering of loads and stores
- Test-and-test-and-set pattern reduces coherency traffic
- False sharing causes coherency traffic despite no true sharing
- Coherency protocols add ~40-100 cycles to cache misses in multi-core systems

