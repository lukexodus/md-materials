## State Machines


State machines organize complex control flow by explicitly tracking the current state and transitioning between states based on inputs or conditions. Assembly implementations use variables to store state and jump tables or comparison chains to dispatch state handlers.

**Finite State Machine Structure** defines states, transitions, and actions:

```nasm
section .data
    ; State definitions
    STATE_INIT    equ 0
    STATE_RUNNING equ 1
    STATE_PAUSED  equ 2
    STATE_STOPPED equ 3
    
    current_state: dq STATE_INIT
    
    state_table:
        dq state_init
        dq state_running
        dq state_paused
        dq state_stopped

section .text
state_machine:
    mov rax, [rel current_state]
    lea rbx, [rel state_table]
    call [rbx + rax*8]       ; Call state handler
    ret

state_init:
    ; Initialization logic
    ; Transition to running
    mov qword [rel current_state], STATE_RUNNING
    ret

state_running:
    ; Running state logic
    ; Check for pause condition
    ; Transition to paused if needed
    ret

state_paused:
    ; Paused state logic
    ; Check for resume or stop
    ret

state_stopped:
    ; Stopped state logic
    ret
```

Each state handler performs actions appropriate for that state and updates current_state to transition. The main loop calls the appropriate handler based on current_state.

**Event-Driven State Machine** responds to external inputs:

```nasm
section .data
    ; Events
    EVENT_START equ 0
    EVENT_PAUSE equ 1
    EVENT_RESUME equ 2
    EVENT_STOP equ 3
    
    current_state: dq STATE_INIT

section .text
    ; Process event in RDI
process_event:
    mov rax, [rel current_state]
    mov rbx, rdi             ; Event in RBX
    
    cmp rax, STATE_INIT
    je .handle_init
    cmp rax, STATE_RUNNING
    je .handle_running
    cmp rax, STATE_PAUSED
    je .handle_paused
    ret

.handle_init:
    cmp rbx, EVENT_START
    jne .done
    ; Transition INIT -> RUNNING
    mov qword [rel current_state], STATE_RUNNING
    ; Perform start action
    jmp .done

.handle_running:
    cmp rbx, EVENT_PAUSE
    je .transition_to_paused
    cmp rbx, EVENT_STOP
    je .transition_to_stopped
    jmp .done

.transition_to_paused:
    mov qword [rel current_state], STATE_PAUSED
    ; Perform pause action
    jmp .done

.transition_to_stopped:
    mov qword [rel current_state], STATE_STOPPED
    ; Perform stop action
    jmp .done

.done:
    ret
```

The state machine checks current state and event to determine transitions. Invalid state-event combinations are ignored or handled as errors.

**Transition Table Implementation** uses a two-dimensional array:

```nasm
section .data
    ; Transition table: [current_state][event] -> new_state
    ; -1 means invalid transition
    transition_table:
        ; Events:       START  PAUSE  RESUME STOP
        dq STATE_RUNNING, -1,    -1,    -1     ; From INIT
        dq -1,  STATE_PAUSED, -1, STATE_STOPPED ; From RUNNING
        dq -1,    -1,   STATE_RUNNING, STATE_STOPPED ; From PAUSED
        dq -1,    -1,    -1,    -1     ; From STOPPED

section .text
process_event:
    mov rax, [rel current_state]
    mov rbx, rdi             ; Event
    
    ; Calculate table index: state * 4 + event
    shl rax, 2               ; Multiply state by 4 (events per state)
    add rax, rbx
    
    lea rcx, [rel transition_table]
    mov rdx, [rcx + rax*8]   ; Get new state
    
    cmp rdx, -1
    je .invalid              ; Invalid transition
    
    mov [rel current_state], rdx
    ; Perform transition action based on new state
    ret

.invalid:
    ; Handle invalid transition
    ret
```

The transition table explicitly defines all valid transitions. Indexing by current state and event provides constant-time lookup. Invalid transitions return -1 or a special value.

**Hierarchical State Machines** nest states within superstates:

```nasm
section .data
    ; State hierarchy
    SUPER_ACTIVE  equ 0
    SUPER_INACTIVE equ 1
    
    ; Substates of ACTIVE
    SUB_RUNNING   equ 0
    SUB_PAUSED    equ 1
    
    super_state: dq SUPER_INACTIVE
    sub_state: dq SUB_RUNNING

section .text
process_event:
    mov rax, [rel super_state]
    
    cmp rax, SUPER_ACTIVE
    je .handle_active
    cmp rax, SUPER_INACTIVE
    je .handle_inactive
    ret

.handle_active:
    ; Check substates
    mov rbx, [rel sub_state]
    cmp rbx, SUB_RUNNING
    je .handle_running
    cmp rbx, SUB_PAUSED
    je .handle_paused
    ret

.handle_running:
    ; Handle running substate
    ret

.handle_paused:
    ; Handle paused substate
    ret

.handle_inactive:
    ; Handle inactive superstate
    ret
```

Superstates group related states sharing common behavior. The state machine first checks the superstate then dispatches to substates. Transitions can occur between substates or between superstates.

**Parser State Machine** processes input character by character:

```nasm
section .data
    ; Parser states for simple integer parsing
    STATE_START    equ 0
    STATE_SIGN     equ 1
    STATE_DIGITS   equ 2
    STATE_DONE     equ 3
    STATE_ERROR    equ 4
    
    parser_state: dq STATE_START
    accumulator: dq 0
    sign: dq 1

section .text
    ; Parse character in DIL (low byte of RDI)
parse_char:
    mov al, dil              ; Character to parse
    mov rbx, [rel parser_state]
    
    cmp rbx, STATE_START
    je .state_start
    cmp rbx, STATE_SIGN
    je .state_sign
    cmp rbx, STATE_DIGITS
    je .state_digits
    ret

.state_start:
    cmp al, '+'
    je .got_plus
    cmp al, '-'
    je .got_minus
    cmp al, '0'
    jl .error
    cmp al, '9'
    jg .error
    ; Got digit directly
    mov qword [rel parser_state], STATE_DIGITS
    jmp .process_digit

.got_plus:
    mov qword [rel sign], 1
    mov qword [rel parser_state], STATE_SIGN
    ret

.got_minus:
    mov qword [rel sign], -1
    mov qword [rel parser_state], STATE_SIGN
    ret

.state_sign:
.state_digits:
    cmp al, '0'
    jl .complete
    cmp al, '9'
    jg .complete
    
.process_digit:
    ; accumulator = accumulator * 10 + (char - '0')
    sub al, '0'
    movzx rax, al
    mov rbx, [rel accumulator]
    imul rbx, 10
    add rbx, rax
    mov [rel accumulator], rbx
    mov qword [rel parser_state], STATE_DIGITS
    ret

.complete:
    mov qword [rel parser_state], STATE_DONE
    ret

.error:
    mov qword [rel parser_state], STATE_ERROR
    ret
```

Each character advances the parser through states. The parser accumulates digits and handles sign characters. Invalid characters transition to error states.

**State Machine with Timeouts** tracks time in each state:

```nasm
section .data
    current_state: dq STATE_IDLE
    state_start_time: dq 0
    timeout_duration: dq 1000  ; Milliseconds

section .text
update_state_machine:
    ; Get current time in RAX
    call get_current_time
    
    mov rbx, [rel current_state]
    mov rcx, [rel state_start_time]
    sub rax, rcx             ; Time elapsed
    cmp rax, [rel timeout_duration]
    jl .no_timeout
    
    ; Timeout occurred
    cmp rbx, STATE_WAITING
    jne .no_timeout
    
    ; Transition to timeout state
    mov qword [rel current_state], STATE_TIMEOUT
    call get_current_time
    mov [rel state_start_time], rax

.no_timeout:
    ; Normal state processing
    ret
```

Time-based transitions occur when a state exceeds its duration. The state machine compares elapsed time against timeout thresholds.

**Moore Machine** determines outputs based solely on current state:

```nasm
section .data
    current_state: dq 0
    
    ; Output table: output value for each state
    output_table:
        dq 0    ; State 0 output
        dq 1    ; State 1 output
        dq 0    ; State 2 output
        dq 1    ; State 3 output

section .text
get_output:
    mov rax, [rel current_state]
    lea rbx, [rel output_table]
    mov rax, [rbx + rax*8]
    ret
```

Moore machines generate output values based on state alone, independent of input. The output table maps each state to its output value.

**Mealy Machine** determines outputs based on current state and input:

```nasm
section .text
    ; RDI contains input
get_output:
    mov rax, [rel current_state]
    mov rbx, rdi             ; Input
    
    cmp rax, STATE_0
    je .state_0_output
    cmp rax, STATE_1
    je .state_1_output
    ret

.state_0_output:
    ; Output depends on both state and input
    test rbx, 1
    jz .state_0_even
    mov rax, 1
    ret
.state_0_even:
    xor rax, rax
    ret

.state_1_output:
    ; Different output logic for state 1
    mov rax, rbx
    shl rax, 1
    ret
```

Mealy machines produce outputs that depend on both current state and input, allowing more responsive behavior than Moore machines.

**Key Points:**
- Jump tables provide constant-time multi-way branching using address arrays indexed by computed values
- Sparse jump tables use mapping tables when valid indices are non-consecutive, trading memory efficiency for flexibility
- Structured programming patterns (if-else, loops, functions) organize assembly code into readable, maintainable control flow structures
- State machines explicitly track current state and transition based on events or conditions using state variables and dispatch tables
- Transition tables define valid state changes as two-dimensional arrays indexed by current state and event
- Hierarchical state machines nest substates within superstates for complex behavior organization
- Moore machines generate outputs based only on current state while Mealy machines consider both state and input
- [Inference] Modern branch predictors may improve indirect jump performance in jump tables when access patterns are predictable, though this varies by processor microarchitecture

---

