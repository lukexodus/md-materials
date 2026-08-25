## Low-level Programming in Zig


Zig excels at low-level systems programming, providing direct hardware access, inline assembly integration, and fine-grained control over system resources. The language's design philosophy of "no hidden control flow" makes it particularly well-suited for embedded systems, kernel development, and performance-critical applications.

### Inline Assembly Integration

Zig provides comprehensive inline assembly support with compile-time safety checks and seamless integration with Zig code.

```zig
const std = @import("std");

fn basicInlineAssembly() u32 {
    var result: u32 = undefined;
    
    // Basic inline assembly with output constraint
    asm volatile ("mov $42, %[output]"
        : [output] "=r" (result)
        :
        : "memory"
    );
    
    return result;
}

fn assemblyWithInputs(a: u32, b: u32) u32 {
    var result: u32 = undefined;
    
    asm volatile ("addl %[input1], %[input2]\n\t"
                 "movl %[input2], %[output]"
        : [output] "=r" (result)
        : [input1] "r" (a), [input2] "r" (b)
        : "memory"
    );
    
    return result;
}

// CPUID instruction wrapper
fn cpuid(leaf: u32) struct { eax: u32, ebx: u32, ecx: u32, edx: u32 } {
    var eax: u32 = undefined;
    var ebx: u32 = undefined;
    var ecx: u32 = undefined;
    var edx: u32 = undefined;
    
    asm volatile ("cpuid"
        : [eax] "={eax}" (eax),
          [ebx] "={ebx}" (ebx),
          [ecx] "={ecx}" (ecx),
          [edx] "={edx}" (edx)
        : [leaf] "{eax}" (leaf)
        : "memory"
    );
    
    return .{ .eax = eax, .ebx = ebx, .ecx = ecx, .edx = edx };
}
```

### Architecture-Specific Assembly

```zig
// x86_64 specific operations
const x86_64 = struct {
    fn rdtsc() u64 {
        var low: u32 = undefined;
        var high: u32 = undefined;
        
        asm volatile ("rdtsc"
            : [low] "={eax}" (low), [high] "={edx}" (high)
            :
            : "memory"
        );
        
        return (@as(u64, high) << 32) | low;
    }
    
    fn pause() void {
        asm volatile ("pause" ::: "memory");
    }
    
    fn enableInterrupts() void {
        asm volatile ("sti" ::: "memory");
    }
    
    fn disableInterrupts() void {
        asm volatile ("cli" ::: "memory");
    }
    
    fn halt() void {
        asm volatile ("hlt" ::: "memory");
    }
    
    fn readCR0() u64 {
        var value: u64 = undefined;
        asm volatile ("mov %%cr0, %[value]"
            : [value] "=r" (value)
            :
            : "memory"
        );
        return value;
    }
    
    fn writeCR0(value: u64) void {
        asm volatile ("mov %[value], %%cr0"
            :
            : [value] "r" (value)
            : "memory"
        );
    }
};

// ARM specific operations
const arm64 = struct {
    fn getCurrentEL() u32 {
        var el: u32 = undefined;
        asm volatile ("mrs %[el], CurrentEL"
            : [el] "=r" (el)
            :
            : "memory"
        );
        return (el >> 2) & 0x3;
    }
    
    fn dataMemoryBarrier() void {
        asm volatile ("dmb sy" ::: "memory");
    }
    
    fn dataSync() void {
        asm volatile ("dsb sy" ::: "memory");
    }
    
    fn instructionSync() void {
        asm volatile ("isb" ::: "memory");
    }
    
    fn wfi() void {
        asm volatile ("wfi" ::: "memory");
    }
};
```

### Hardware Register Access

Direct memory-mapped I/O and hardware register manipulation with type safety.

```zig
// Memory-mapped I/O register access
fn MemoryMappedRegister(comptime T: type) type {
    return struct {
        const Self = @This();
        
        address: usize,
        
        fn init(address: usize) Self {
            return Self{ .address = address };
        }
        
        fn read(self: Self) T {
            const ptr: *volatile T = @ptrFromInt(self.address);
            return ptr.*;
        }
        
        fn write(self: Self, value: T) void {
            const ptr: *volatile T = @ptrFromInt(self.address);
            ptr.* = value;
        }
        
        fn setBits(self: Self, mask: T) void {
            self.write(self.read() | mask);
        }
        
        fn clearBits(self: Self, mask: T) void {
            self.write(self.read() & ~mask);
        }
        
        fn toggleBits(self: Self, mask: T) void {
            self.write(self.read() ^ mask);
        }
        
        fn testBits(self: Self, mask: T) bool {
            return (self.read() & mask) != 0;
        }
    };
}

// GPIO register example (ARM Cortex-M)
const GPIORegisters = struct {
    const BASE_ADDRESS = 0x40020000;
    
    const MODER = MemoryMappedRegister(u32).init(BASE_ADDRESS + 0x00);
    const OTYPER = MemoryMappedRegister(u32).init(BASE_ADDRESS + 0x04);
    const OSPEEDR = MemoryMappedRegister(u32).init(BASE_ADDRESS + 0x08);
    const PUPDR = MemoryMappedRegister(u32).init(BASE_ADDRESS + 0x0C);
    const IDR = MemoryMappedRegister(u32).init(BASE_ADDRESS + 0x10);
    const ODR = MemoryMappedRegister(u32).init(BASE_ADDRESS + 0x14);
    const BSRR = MemoryMappedRegister(u32).init(BASE_ADDRESS + 0x18);
    
    fn configurePin(pin: u5, mode: PinMode) void {
        const pin_pos = @as(u32, pin) * 2;
        const mask = @as(u32, 0x3) << pin_pos;
        
        MODER.clearBits(mask);
        MODER.setBits((@as(u32, @intFromEnum(mode)) & 0x3) << pin_pos);
    }
    
    fn setPin(pin: u5) void {
        BSRR.write(@as(u32, 1) << pin);
    }
    
    fn clearPin(pin: u5) void {
        BSRR.write(@as(u32, 1) << (pin + 16));
    }
    
    fn readPin(pin: u5) bool {
        return IDR.testBits(@as(u32, 1) << pin);
    }
};

const PinMode = enum(u2) {
    input = 0,
    output = 1,
    alternate = 2,
    analog = 3,
};
```

### Bit Field Operations

```zig
const BitField = struct {
    fn BitFieldType(comptime T: type, comptime bit_start: u6, comptime bit_count: u6) type {
        return struct {
            const Self = @This();
            const mask: T = ((1 << bit_count) - 1) << bit_start;
            
            fn get(value: T) T {
                return (value & mask) >> bit_start;
            }
            
            fn set(value: T, field_value: T) T {
                return (value & ~mask) | ((field_value << bit_start) & mask);
            }
        };
    }
};

// Example: ARM CPSR register
const CPSR = struct {
    const Mode = BitField.BitFieldType(u32, 0, 5);
    const Thumb = BitField.BitFieldType(u32, 5, 1);
    const FIQ = BitField.BitFieldType(u32, 6, 1);
    const IRQ = BitField.BitFieldType(u32, 7, 1);
    const Negative = BitField.BitFieldType(u32, 31, 1);
    const Zero = BitField.BitFieldType(u32, 30, 1);
    const Carry = BitField.BitFieldType(u32, 29, 1);
    const Overflow = BitField.BitFieldType(u32, 28, 1);
    
    fn getCPSR() u32 {
        var cpsr: u32 = undefined;
        asm volatile ("mrs %[cpsr], cpsr"
            : [cpsr] "=r" (cpsr)
            :
            : "memory"
        );
        return cpsr;
    }
    
    fn setCPSR(value: u32) void {
        asm volatile ("msr cpsr, %[value]"
            :
            : [value] "r" (value)
            : "memory"
        );
    }
};
```

### Interrupt Handling

Zig's interrupt handling provides type-safe interrupt service routines with minimal overhead.

```zig
// Generic interrupt vector table
const InterruptVector = fn() callconv(.Naked) void;

const VectorTable = struct {
    initial_stack_pointer: *const anyopaque,
    reset: InterruptVector,
    nmi: InterruptVector,
    hard_fault: InterruptVector,
    // ... additional vectors
    
    fn defaultHandler() callconv(.Naked) void {
        asm volatile (
            \\  bkpt #0
            \\  b .
        );
    }
};

// Cortex-M interrupt handlers
export const vector_table linksection(".isr_vector") = VectorTable{
    .initial_stack_pointer = @ptrFromInt(0x20010000), // End of RAM
    .reset = resetHandler,
    .nmi = VectorTable.defaultHandler,
    .hard_fault = hardFaultHandler,
};

fn resetHandler() callconv(.Naked) void {
    // Initialize system
    asm volatile (
        \\  ldr r0, =_sbss
        \\  ldr r1, =_ebss
        \\  movs r2, #0
        \\bss_loop:
        \\  cmp r0, r1
        \\  bge bss_done
        \\  str r2, [r0]
        \\  add r0, r0, #4
        \\  b bss_loop
        \\bss_done:
        \\  bl main
        \\  b .
    );
}

fn hardFaultHandler() callconv(.Naked) void {
    // Fault analysis and recovery
    asm volatile (
        \\  tst lr, #4
        \\  ite eq
        \\  mrseq r0, msp
        \\  mrsne r0, psp
        \\  bl hardFaultAnalyzer
        \\  b .
    );
}

export fn hardFaultAnalyzer(stack_frame: *const ExceptionFrame) void {
    // Analyze fault information
    _ = stack_frame;
    // Implement fault recovery or system reset
}

const ExceptionFrame = struct {
    r0: u32,
    r1: u32,
    r2: u32,
    r3: u32,
    r12: u32,
    lr: u32,
    pc: u32,
    psr: u32,
};
```

### Timer Interrupt Example

```zig
// Timer interrupt configuration
const Timer = struct {
    const BASE = 0x40000000;
    const CR1 = MemoryMappedRegister(u32).init(BASE + 0x00);
    const DIER = MemoryMappedRegister(u32).init(BASE + 0x0C);
    const SR = MemoryMappedRegister(u32).init(BASE + 0x10);
    const CNT = MemoryMappedRegister(u32).init(BASE + 0x24);
    const ARR = MemoryMappedRegister(u32).init(BASE + 0x2C);
    
    var tick_count: u32 = 0;
    
    fn init(period_ms: u32) void {
        // Configure timer for 1ms ticks
        ARR.write(period_ms * 1000 - 1); // Assuming 1MHz clock
        DIER.setBits(1); // Enable update interrupt
        CR1.setBits(1); // Enable timer
    }
    
    fn timerInterruptHandler() callconv(.C) void {
        if (SR.testBits(1)) { // Update interrupt flag
            SR.clearBits(1); // Clear flag
            tick_count += 1;
            
            // User timer callback
            onTimerTick();
        }
    }
    
    fn getTicks() u32 {
        return tick_count;
    }
};

fn onTimerTick() void {
    // User-defined timer callback
    GPIORegisters.togglePin(13); // Blink LED
}
```

### System Call Interfaces

Low-level system call wrappers for direct kernel interaction.

```zig
// Linux system call interface
const SyscallNumber = struct {
    const read = 0;
    const write = 1;
    const open = 2;
    const close = 3;
    const mmap = 9;
    const munmap = 11;
    const exit = 60;
};

fn syscall0(number: usize) usize {
    return asm volatile ("syscall"
        : [ret] "={rax}" (-> usize)
        : [number] "{rax}" (number)
        : "rcx", "r11", "memory"
    );
}

fn syscall1(number: usize, arg1: usize) usize {
    return asm volatile ("syscall"
        : [ret] "={rax}" (-> usize)
        : [number] "{rax}" (number), [arg1] "{rdi}" (arg1)
        : "rcx", "r11", "memory"
    );
}

fn syscall3(number: usize, arg1: usize, arg2: usize, arg3: usize) usize {
    return asm volatile ("syscall"
        : [ret] "={rax}" (-> usize)
        : [number] "{rax}" (number),
          [arg1] "{rdi}" (arg1),
          [arg2] "{rsi}" (arg2),
          [arg3] "{rdx}" (arg3)
        : "rcx", "r11", "memory"
    );
}

// System call wrappers
const SystemCalls = struct {
    fn write(fd: i32, buffer: []const u8) isize {
        const result = syscall3(
            SyscallNumber.write,
            @bitCast(@as(isize, fd)),
            @intFromPtr(buffer.ptr),
            buffer.len
        );
        return @bitCast(result);
    }
    
    fn read(fd: i32, buffer: []u8) isize {
        const result = syscall3(
            SyscallNumber.read,
            @bitCast(@as(isize, fd)),
            @intFromPtr(buffer.ptr),
            buffer.len
        );
        return @bitCast(result);
    }
    
    fn exit(code: i32) noreturn {
        _ = syscall1(SyscallNumber.exit, @bitCast(@as(isize, code)));
        unreachable;
    }
    
    fn mmap(
        addr: ?*anyopaque,
        length: usize,
        prot: i32,
        flags: i32,
        fd: i32,
        offset: i64
    ) ?*anyopaque {
        const result = asm volatile ("syscall"
            : [ret] "={rax}" (-> usize)
            : [number] "{rax}" (SyscallNumber.mmap),
              [arg1] "{rdi}" (@intFromPtr(addr orelse @as(*anyopaque, @ptrFromInt(0)))),
              [arg2] "{rsi}" (length),
              [arg3] "{rdx}" (@as(usize, @bitCast(@as(isize, prot)))),
              [arg4] "{r10}" (@as(usize, @bitCast(@as(isize, flags)))),
              [arg5] "{r8}" (@as(usize, @bitCast(@as(isize, fd)))),
              [arg6] "{r9}" (@as(usize, @bitCast(offset)))
            : "rcx", "r11", "memory"
        );
        
        if (result > @as(usize, @bitCast(@as(isize, -4096)))) {
            return null; // Error
        }
        return @ptrFromInt(result);
    }
};
```

### Platform-Specific Code

Conditional compilation and platform abstraction layers.

```zig
const builtin = @import("builtin");
const Target = std.Target;

// Platform detection
const Platform = struct {
    const is_x86_64 = builtin.cpu.arch == .x86_64;
    const is_aarch64 = builtin.cpu.arch == .aarch64;
    const is_arm = builtin.cpu.arch.isARM();
    const is_linux = builtin.os.tag == .linux;
    const is_windows = builtin.os.tag == .windows;
    const is_freestanding = builtin.os.tag == .freestanding;
};

// Platform-specific implementations
const PlatformImpl = switch (builtin.cpu.arch) {
    .x86_64 => struct {
        fn getStackPointer() usize {
            return asm volatile ("mov %%rsp, %[rsp]"
                : [rsp] "=r" (-> usize)
                :
                : "memory"
            );
        }
        
        fn setStackPointer(sp: usize) void {
            asm volatile ("mov %[rsp], %%rsp"
                :
                : [rsp] "r" (sp)
                : "memory"
            );
        }
        
        fn atomicAdd(ptr: *u32, value: u32) u32 {
            return asm volatile ("lock xadd %[value], %[ptr]"
                : [value] "+r" (value), [ptr] "+m" (ptr.*)
                :
                : "memory"
            );
        }
    },
    
    .aarch64 => struct {
        fn getStackPointer() usize {
            return asm volatile ("mov %[sp], sp"
                : [sp] "=r" (-> usize)
                :
                : "memory"
            );
        }
        
        fn setStackPointer(sp: usize) void {
            asm volatile ("mov sp, %[sp]"
                :
                : [sp] "r" (sp)
                : "memory"
            );
        }
        
        fn atomicAdd(ptr: *u32, value: u32) u32 {
            var old: u32 = undefined;
            var new: u32 = undefined;
            
            asm volatile (
                \\1:  ldxr %w[old], %[ptr]
                \\    add %w[new], %w[old], %w[value]
                \\    stxr w9, %w[new], %[ptr]
                \\    cbnz w9, 1b
                : [old] "=&r" (old), [new] "=&r" (new)
                : [ptr] "m" (ptr.*), [value] "r" (value)
                : "w9", "memory"
            );
            
            return old;
        }
    },
    
    else => @compileError("Unsupported architecture"),
};

// Memory barriers
const MemoryBarrier = struct {
    fn full() void {
        switch (builtin.cpu.arch) {
            .x86_64 => asm volatile ("mfence" ::: "memory"),
            .aarch64 => asm volatile ("dmb sy" ::: "memory"),
            else => @compileError("Unsupported architecture for memory barrier"),
        }
    }
    
    fn acquire() void {
        switch (builtin.cpu.arch) {
            .x86_64 => asm volatile ("" ::: "memory"), // x86 has acquire semantics
            .aarch64 => asm volatile ("dmb ld" ::: "memory"),
            else => @compileError("Unsupported architecture for acquire barrier"),
        }
    }
    
    fn release() void {
        switch (builtin.cpu.arch) {
            .x86_64 => asm volatile ("" ::: "memory"), // x86 has release semantics
            .aarch64 => asm volatile ("dmb st" ::: "memory"),
            else => @compileError("Unsupported architecture for release barrier"),
        }
    }
};
```

### Cache Operations

```zig
const CacheOps = struct {
    fn flushDataCache() void {
        switch (builtin.cpu.arch) {
            .x86_64 => {
                // x86_64 cache is mostly coherent, but we can use wbinvd in kernel mode
                asm volatile ("wbinvd" ::: "memory");
            },
            .aarch64 => {
                // Clean and invalidate all data cache
                asm volatile (
                    \\  dsb sy
                    \\  ic iallu
                    \\  dsb sy
                    \\  isb
                    ::: "memory"
                );
            },
            else => {},
        }
    }
    
    fn invalidateInstructionCache() void {
        switch (builtin.cpu.arch) {
            .x86_64 => {
                // x86_64 has coherent I-cache
                asm volatile ("" ::: "memory");
            },
            .aarch64 => {
                asm volatile (
                    \\  ic iallu
                    \\  dsb sy
                    \\  isb
                    ::: "memory"
                );
            },
            else => {},
        }
    }
    
    fn cleanDataCacheRange(start: usize, size: usize) void {
        switch (builtin.cpu.arch) {
            .x86_64 => {
                // Use clflush for specific cache lines
                const cache_line_size = 64;
                var addr = start & ~@as(usize, cache_line_size - 1);
                const end = start + size;
                
                while (addr < end) {
                    asm volatile ("clflush (%[addr])"
                        :
                        : [addr] "r" (addr)
                        : "memory"
                    );
                    addr += cache_line_size;
                }
                MemoryBarrier.full();
            },
            .aarch64 => {
                // ARM cache operations by VA
                const cache_line_size = 64; // Typical ARM cache line size
                var addr = start & ~@as(usize, cache_line_size - 1);
                const end = start + size;
                
                while (addr < end) {
                    asm volatile ("dc cvac, %[addr]"
                        :
                        : [addr] "r" (addr)
                        : "memory"
                    );
                    addr += cache_line_size;
                }
                asm volatile ("dsb sy" ::: "memory");
            },
            else => {},
        }
    }
};
```

### DMA and Memory Coherency

```zig
const DMABuffer = struct {
    ptr: [*]u8,
    len: usize,
    physical_addr: usize,
    
    fn allocate(allocator: std.mem.Allocator, size: usize) !DMABuffer {
        // Platform-specific DMA allocation
        switch (builtin.os.tag) {
            .linux => {
                // Use dma_alloc_coherent equivalent
                const PROT_READ = 1;
                const PROT_WRITE = 2;
                const MAP_SHARED = 1;
                const MAP_ANONYMOUS = 0x20;
                
                const ptr = SystemCalls.mmap(
                    null,
                    size,
                    PROT_READ | PROT_WRITE,
                    MAP_SHARED | MAP_ANONYMOUS,
                    -1,
                    0
                );
                
                if (ptr == null) return error.AllocationFailed;
                
                return DMABuffer{
                    .ptr = @ptrCast(ptr.?),
                    .len = size,
                    .physical_addr = @intFromPtr(ptr.?), // Simplified
                };
            },
            .freestanding => {
                // Direct physical memory allocation
                const memory = try allocator.alignedAlloc(u8, 4096, size);
                
                return DMABuffer{
                    .ptr = memory.ptr,
                    .len = size,
                    .physical_addr = @intFromPtr(memory.ptr),
                };
            },
            else => return error.UnsupportedPlatform,
        }
    }
    
    fn syncForDevice(self: DMABuffer) void {
        CacheOps.cleanDataCacheRange(@intFromPtr(self.ptr), self.len);
    }
    
    fn syncForCpu(self: DMABuffer) void {
        // Invalidate cache to ensure CPU sees device updates
        switch (builtin.cpu.arch) {
            .aarch64 => {
                const cache_line_size = 64;
                var addr = @intFromPtr(self.ptr) & ~@as(usize, cache_line_size - 1);
                const end = @intFromPtr(self.ptr) + self.len;
                
                while (addr < end) {
                    asm volatile ("dc ivac, %[addr]"
                        :
                        : [addr] "r" (addr)
                        : "memory"
                    );
                    addr += cache_line_size;
                }
                asm volatile ("dsb sy" ::: "memory");
            },
            else => {},
        }
    }
};
```

### Performance Monitoring

```zig
const PerfCounters = struct {
    fn readCycleCounter() u64 {
        return switch (builtin.cpu.arch) {
            .x86_64 => x86_64.rdtsc(),
            .aarch64 => blk: {
                var cycles: u64 = undefined;
                asm volatile ("mrs %[cycles], cntvct_el0"
                    : [cycles] "=r" (cycles)
                    :
                    : "memory"
                );
                break :blk cycles;
            },
            else => 0,
        };
    }
    
    fn enablePMU() void {
        switch (builtin.cpu.arch) {
            .aarch64 => {
                // Enable user access to performance counters
                asm volatile (
                    \\  mrs x0, pmuserenr_el0
                    \\  orr x0, x0, #1
                    \\  msr pmuserenr_el0, x0
                    ::: "x0", "memory"
                );
            },
            else => {},
        }
    }
};
```

**Conclusion:** Zig's low-level programming capabilities provide direct hardware access while maintaining type safety and zero-cost abstractions. The inline assembly integration, memory-mapped I/O support, and platform-specific compilation features make it excellent for systems programming, embedded development, and performance-critical applications where direct hardware control is essential.

---

