## Stack Architecture and Organization


The x86 stack grows downward in memory, meaning that as items are added to the stack, the stack pointer moves toward lower memory addresses. This downward growth is a convention established in early x86 processors and maintained for compatibility.

### Stack Pointer Register

The stack pointer register tracks the current top of the stack:

**RSP (64-bit mode)**: 64-bit stack pointer register  
**ESP (32-bit mode)**: 32-bit stack pointer register  
**SP (16-bit mode)**: 16-bit stack pointer register

RSP points to the most recently pushed item on the stack. When the stack is empty (or at its initial state), RSP points to the highest allocated stack address.

### Stack Segment

In protected mode with a flat memory model, the stack segment (SS) has a base of zero and limit of 4GB, making it effectively part of the flat address space. The SS register is typically set during operating system initialization and rarely modified by application code.

In 64-bit long mode, segmentation is largely disabled, and SS is effectively ignored for most operations, though it still exists for compatibility.

### Stack Memory Layout

A typical stack layout for a process:

```
High Memory (0x7FFFFFFFFFFF on Linux x86-64)
┌─────────────────────────┐
│   Command-line args     │
│   Environment variables │
├─────────────────────────┤
│   Initial stack frame   │
├─────────────────────────┤
│        Stack            │
│          ↓              │  Stack grows downward
│      (grows down)       │
│                         │
│      Available          │
│        space            │
│                         │
├─────────────────────────┤ ← RSP (current stack pointer)
│    Used stack space     │
└─────────────────────────┘
Low Memory
```

Operating systems allocate a default stack size (typically 1-8 MB on modern systems), though this can be configured.

