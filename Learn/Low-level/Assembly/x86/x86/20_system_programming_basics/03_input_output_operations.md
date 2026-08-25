## Input/Output Operations


x86 architecture provides multiple mechanisms for performing input/output operations: port-mapped I/O, memory-mapped I/O, and DMA (Direct Memory Access). Each method has distinct characteristics and use cases.

### Port-Mapped I/O

Port-mapped I/O uses a separate I/O address space distinct from memory addresses, accessed through dedicated I/O instructions.

#### I/O Address Space

x86 processors support a 16-bit I/O port address space (ports 0x0000-0xFFFF, 65536 ports). Ports can be accessed as bytes, words (16-bit), or doublewords (32-bit).

**Common port assignments**:

```
0x0020-0x0021: Master PIC (Programmable Interrupt Controller)
0x0040-0x0043: PIT (Programmable Interval Timer)
0x0060, 0x0064: PS/2 Keyboard Controller
0x0070-0x0071: CMOS/RTC (Real-Time Clock)
0x00A0-0x00A1: Slave PIC
0x00F0-0x00FF: Math Coprocessor
0x01F0-0x01F7: Primary IDE Controller
0x0170-0x0177: Secondary IDE Controller
0x03F8-0x03FF: COM1 Serial Port
0x02F8-0x02FF: COM2 Serial Port
0x0378-0x037F: LPT1 Parallel Port
0x03D4-0x03D5: VGA CRT Controller
```

#### IN Instruction

The IN instruction reads data from I/O ports:

```nasm
; Read byte from port
in al, 0x60         ; Read from port 0x60 (keyboard data)
; AL contains byte read from port

; Read word from port
in ax, 0x3D4        ; Read 16 bits from port 0x3D4

; Read doubleword from port
in eax, 0x0CF8      ; Read 32 bits from port 0x0CF8 (PCI config address)

; Variable port addressing (port number in DX)
mov dx, 0x1F0       ; IDE data port
in ax, dx           ; Read word from IDE
```

**IN instruction variants**:

- `IN AL, imm8`: Read byte from immediate port (0-255)
- `IN AX, imm8`: Read word from immediate port
- `IN EAX, imm8`: Read doubleword from immediate port
- `IN AL, DX`: Read byte from port specified in DX
- `IN AX, DX`: Read word from port in DX
- `IN EAX, DX`: Read doubleword from port in DX

[Inference] The immediate form (imm8) provides compact encoding for frequently-accessed low ports, while the DX register form enables access to all 65536 ports at the cost of one additional register operand.

#### OUT Instruction

The OUT instruction writes data to I/O ports:

```nasm
; Write byte to port
mov al, 0x20
out 0x20, al        ; Write to port 0x20 (PIC EOI)

; Write word to port
mov ax, 0x1234
out 0x3D4, ax       ; Write to port 0x3D4

; Write doubleword to port
mov eax, 0x80000000
out 0x0CF8, eax     ; Write to PCI configuration address port

; Variable port addressing
mov dx, 0x1F0       ; IDE data port
mov ax, [data]
out dx, ax          ; Write word to IDE
```

**OUT instruction variants**:

- `OUT imm8, AL`: Write byte to immediate port
- `OUT imm8, AX`: Write word to immediate port
- `OUT imm8, EAX`: Write doubleword to immediate port
- `OUT DX, AL`: Write byte to port in DX
- `OUT DX, AX`: Write word to port in DX
- `OUT DX, EAX`: Write doubleword to port in DX

#### String I/O Instructions

INS and OUTS instructions perform block I/O operations with automatic pointer increment:

```nasm
; Input string of bytes from port to memory
mov dx, 0x1F0       ; IDE data port
mov rdi, buffer     ; Destination buffer
mov rcx, 256        ; Count (256 words = 512 bytes)
rep insw            ; Read CX words from DX to [RDI], increment RDI
```

**String I/O variants**:

- `INSB`: Input byte from DX to [RDI], adjust RDI
- `INSW`: Input word from DX to [RDI], adjust RDI
- `INSD`: Input doubleword from DX to [RDI], adjust RDI
- `OUTSB`: Output byte from [RSI] to DX, adjust RSI
- `OUTSW`: Output word from [RSI] to DX, adjust RSI
- `OUTSD`: Output doubleword from [RSI] to DX, adjust RSI

With REP prefix, these instructions repeat CX times, providing efficient block transfer:

```nasm
; Transfer 512 bytes from IDE drive
mov dx, 0x1F0       ; IDE data port
lea rdi, [sector_buffer]
mov ecx, 256        ; 256 words
cld                 ; Direction flag: increment
rep insw            ; Transfer entire sector

; Write 512 bytes to IDE drive
mov dx, 0x1F0
lea rsi, [sector_buffer]
mov ecx, 256
rep outsw
```

[Inference] String I/O instructions reduce code size and provide microcode-optimized block transfers, though modern systems often use memory-mapped I/O and DMA for bulk transfers instead of programmed I/O.

#### I/O Port Access Control

I/O port access from user mode requires either IOPL=3 or permission bits set in the I/O permission bitmap:

```nasm
; Kernel code enabling specific port access for user mode
; Set I/O bitmap bit to 0 for allowed port
mov rdi, [current_task_tss]
add rdi, io_bitmap_offset
mov ax, port_number
shr ax, 3           ; Divide by 8 (byte index)
mov cl, port_number
and cl, 7           ; Modulo 8 (bit index)
btr [rdi + rax], cx ; Clear bit to allow access
```

[Inference] Most modern operating systems deny direct I/O port access from user mode, requiring applications to use kernel drivers or system calls for hardware interaction. This centralized control prevents applications from interfering with each other's devices and maintains system stability.

### Memory-Mapped I/O (MMIO)

Memory-mapped I/O maps device registers into the processor's physical address space, allowing devices to be accessed using normal memory instructions instead of specialized I/O instructions.

#### MMIO Characteristics

Device registers appear as memory locations at specific physical addresses:

```
Typical MMIO regions:
0x000A0000-0x000BFFFF: VGA framebuffer (128 KB)
0x000C0000-0x000FFFFF: Option ROMs, BIOS
0xFEC00000-0xFECFFFFF: I/O APIC
0xFEE00000-0xFEEFFFFF: Local APIC
0xFED00000-0xFED003FF: HPET (High Precision Event Timer)
(Device-specific): PCIe configuration space, device BARs
```

#### MMIO Access Methods

Accessing memory-mapped devices uses standard MOV instructions:

```nasm
; Reading from memory-mapped device register
mov rax, [mmio_base + DEVICE_STATUS_REG]
test rax, STATUS_READY_BIT
jz device_not_ready

; Writing to memory-mapped device register
mov qword [mmio_base + DEVICE_COMMAND_REG], COMMAND_START

; Accessing framebuffer
mov rdi, framebuffer_base
mov eax, pixel_color
mov [rdi + offset], eax    ; Write pixel
```

#### Cache Considerations

Memory-mapped I/O regions must be configured as uncacheable to prevent stale data and ensure write ordering. The Memory Type Range Registers (MTRRs) or page table attributes control caching behavior:

**Page table flags for MMIO**:

- Page Cache Disable (PCD bit)
- Page Write-Through (PWT bit)
- Page Attribute Table (PAT) for fine-grained control

```nasm
; Mapping MMIO region with uncacheable attribute (kernel code)
; Page table entry setup
mov rax, physical_address
or rax, PAGE_PRESENT | PAGE_WRITE | PAGE_PCD | PAGE_PWT
mov [page_table_entry], rax
```

[Inference] Proper cache configuration for MMIO is critical. Cached access to device registers can cause reads to return stale values and writes to be reordered or delayed, leading to device malfunction or system instability.

### Memory-Mapped I/O vs. Port-Mapped I/O

| **Aspect**                    | **Port-Mapped I/O**          | **Memory-Mapped I/O**             |
| ----------------------------- | ---------------------------- | --------------------------------- |
| **Address space**             | Separate 16-bit (64K ports)  | Physical memory address space     |
| **Access instructions**       | IN, OUT, INS, OUTS           | MOV, and all memory instructions  |
| **Access from user mode**     | Requires IOPL or I/O bitmap  | Requires appropriate page mapping |
| **Cache behavior**            | Always uncached              | Requires explicit cache control   |
| **Performance**               | Fixed cycle count per access | May benefit from burst transfers  |
| **Compatibility**             | x86-specific                 | Universal across architectures    |
| **Address space consumption** | No memory address space used | Consumes physical address space   |

[Inference] Port-mapped I/O provides simple, uncached access with explicit privilege control but is limited to x86 architecture. Memory-mapped I/O offers flexibility, wider device address spaces, and compatibility with non-x86 architectures but requires careful cache management and page table configuration.

### Direct Memory Access (DMA)

DMA enables devices to transfer data directly to/from system memory without continuous CPU involvement, dramatically improving throughput for bulk data transfers.

#### DMA Architecture

**Traditional ISA DMA Controller (8237A)**:

- 8 DMA channels (channels 0-7)
- Channels 0-3: 8-bit transfers, 64KB limit
- Channels 4-7: 16-bit transfers (cascade of channels 0-3)
- Maximum transfer size: 64KB per channel
- Address limit: 24-bit (16MB)

**Modern Bus Mastering DMA**:

- Devices act as bus masters
- Access full physical address space
- Support scatter-gather operations
- No channel limitations

#### ISA DMA Programming

Programming the legacy DMA controller involves multiple port writes:

```nasm
; Setting up DMA channel 2 for transfer
; Transfer from memory to device (e.g., floppy disk write)

; Disable DMA channel
mov al, 0x06        ; Mask channel 2 (0x04 | channel_number)
out 0x0A, al        ; Write to single channel mask register

; Clear byte pointer flip-flop
xor al, al
out 0x0C, al        ; Write to flip-flop reset register

; Set transfer mode
mov al, 0x5A        ; Channel 2, read, single mode (01011010b)
out 0x0B, al        ; Mode register

; Set address (low then high byte)
mov ax, dma_address
out 0x04, al        ; Address low byte (channel 2 address port)
mov al, ah
out 0x04, al        ; Address high byte

; Set page register (bits 16-23 of address)
mov al, [dma_address + 2]
out 0x81, al        ; Page register for channel 2

; Set count (length - 1, low then high byte)
mov ax, transfer_length
dec ax              ; Count is length - 1
out 0x05, al        ; Count low byte (channel 2 count port)
mov al, ah
out 0x05, al        ; Count high byte

; Enable DMA channel
mov al, 0x02        ; Unmask channel 2
out 0x0A, al        ; Write to single channel mask register

; Device now performs DMA transfer
```

**DMA Controller Ports**:

```
Master DMA Controller (channels 0-3):
0x00-0x01: Channel 0 address/count
0x02-0x03: Channel 1 address/count
0x04-0x05: Channel 2 address/count
0x06-0x07: Channel 3 address/count
0x08:      Status register
0x0A:      Single channel mask
0x0B:      Mode register
0x0C:      Clear byte pointer flip-flop
0x0D:      Master clear

Page Registers (bits 16-23 of address):
0x87: Channel 0 page
0x83: Channel 1 page
0x81: Channel 2 page
0x82: Channel 3 page
```

[Inference] ISA DMA programming is complex and error-prone due to the split address registers and flip-flop mechanism. Modern systems rarely use ISA DMA, preferring bus mastering DMA that devices control directly.

#### Bus Mastering DMA

Modern devices implement bus mastering, allowing them to initiate memory transfers independently:

**Device-initiated DMA process**:

1. Device driver sets up transfer parameters in device registers (base address, length, direction)
2. Device driver commands device to begin transfer
3. Device requests bus ownership from chipset
4. Device performs memory transactions as bus master
5. Device signals completion via interrupt

```nasm
; Programming a bus mastering device (conceptual example)
mov rdi, [device_mmio_base]

; Set DMA buffer address
mov rax, [buffer_physical_addr]
mov [rdi + DMA_ADDR_LOW], eax
shr rax, 32
mov [rdi + DMA_ADDR_HIGH], eax

; Set transfer length
mov eax, [transfer_length]
mov [rdi + DMA_LENGTH], eax

; Set direction and start transfer
mov dword [rdi + DMA_CONTROL], DMA_START | DMA_READ
; Device now performs DMA, CPU continues other work

; Later: interrupt handler processes completion
dma_interrupt_handler:
    mov rdi, [device_mmio_base]
    mov eax, [rdi + DMA_STATUS]
    test eax, DMA_COMPLETE
    jz not_complete
    ; Process completed transfer
```

#### Scatter-Gather DMA

Advanced DMA controllers support scatter-gather lists, enabling transfers to/from non-contiguous memory regions:

```nasm
; Scatter-gather descriptor structure
struc sg_descriptor
    .addr:      resq 1      ; Physical address
    .length:    resd 1      ; Transfer length
    .flags:     resd 1      ; Control flags
endstruc

; Setting up scatter-gather DMA
section .data
align 16
sg_list:
    dq buffer1_phys, 4096, SG_VALID
    dq buffer2_phys, 8192, SG_VALID
    dq buffer3_phys, 4096, SG_VALID | SG_LAST

section .text
    ; Program device with scatter-gather list address
    mov rdi, [device_mmio_base]
    mov rax, sg_list_phys
    mov [rdi + SG_LIST_ADDR], rax
    mov dword [rdi + SG_CONTROL], SG_START
```

[Inference] Scatter-gather DMA eliminates the need to copy data into contiguous buffers before transfer, improving performance for operations on fragmented memory regions such as network packet processing or disk I/O with scattered file pages.

#### DMA Coherency and Memory Barriers

DMA operations interact with CPU caches and memory ordering, requiring explicit coherency management:

**Cache coherency issues**:

- CPU writes to DMA buffer may remain in cache
- Device DMA reads may access stale memory
- Device DMA writes may not be visible to CPU immediately

**Solutions**:

**Cache flushing before DMA write (memory → device)**:

```nasm
; Flush cache lines containing DMA buffer (x86-64)
mov rsi, buffer_start
mov rcx, buffer_length
add rcx, 63
shr rcx, 6          ; Divide by cache line size (64 bytes)

flush_loop:
    clflush [rsi]   ; Flush cache line
    add rsi, 64
    loop flush_loop

mfence              ; Memory fence to ensure completion
; Now safe to initiate DMA transfer
```

**Cache invalidation after DMA read (device → memory)**:

```nasm
; Invalidate cache lines that may contain stale data
; On x86, typically accomplished by avoiding reading buffer until after
; DMA completion, allowing natural cache miss to load fresh data

; Alternative: Use WBINVD (privileged, kernel only, very expensive)
wbinvd              ; Write-back and invalidate all caches
```

**Memory barriers**:

```nasm
; MFENCE: Serialize all memory operations
mfence              ; All prior loads/stores complete before subsequent ops

; SFENCE: Serialize store operations
sfence              ; All prior stores complete before subsequent stores

; LFENCE: Serialize load operations
lfence              ; All prior loads complete before subsequent loads
```

[Inference] Proper DMA coherency management is critical for data integrity. Failure to flush caches before DMA writes or invalidate caches after DMA reads can result in data corruption that is difficult to diagnose, as the corruption may be intermittent and depend on cache state timing.

### I/O APIC and MSI/MSI-X

Modern interrupt delivery mechanisms for I/O devices have evolved beyond the legacy PIC (Programmable Interrupt Controller).

#### I/O APIC

The I/O APIC (Advanced Programmable Interrupt Controller) handles interrupt routing from devices to processors:

**I/O APIC characteristics**:

- Memory-mapped registers at 0xFEC00000
- Up to 24 interrupt pins (implementation-dependent)
- Supports multiple delivery modes (fixed, lowest priority, SMI, NMI)
- Per-interrupt programmable destination, vector, trigger mode

```nasm
; I/O APIC register access
IOAPIC_BASE     equ 0xFEC00000
IOREGSEL        equ 0x00        ; Register select offset
IOWIN           equ 0x10        ; Data window offset

; Reading I/O APIC register
ioapic_read:
    ; Input: EAX = register number
    ; Output: EAX = register value
    mov [IOAPIC_BASE + IOREGSEL], eax
    mov eax, [IOAPIC_BASE + IOWIN]
    ret

; Writing I/O APIC register
ioapic_write:
    ; Input: EAX = register number, EDX = value
    mov [IOAPIC_BASE + IOREGSEL], eax
    mov [IOAPIC_BASE + IOWIN], edx
    ret

; Programming redirection entry for IRQ
program_ioapic_irq:
    ; Set low 32 bits of redirection entry
    mov eax, 0x10       ; IOREDTBL0 (IRQ 0 redirection)
    mov edx, VECTOR_NUM | DELIVERY_FIXED | DEST_PHYSICAL
    call ioapic_write
    
    ; Set high 32 bits (destination APIC ID)
    mov eax, 0x11       ; IOREDTBL0 high
    mov edx, APIC_ID << 24
    call ioapic_write
```

#### MSI/MSI-X (Message Signaled Interrupts)

MSI allows devices to signal interrupts by writing to memory locations rather than asserting interrupt lines:

**MSI advantages**:

- No shared interrupt lines (each device has unique vector)
- Higher interrupt counts available
- Better performance (memory write vs. interrupt line arbitration)
- Support for multiple interrupts per device (MSI-X)

**MSI operation**:

1. Device writes interrupt vector to specific memory address
2. Chipset converts memory write to interrupt message
3. Processor local APIC receives interrupt
4. CPU executes interrupt handler

```nasm
; MSI configuration (via PCI configuration space)
; Typically done by kernel driver, not application code

; MSI Capability Structure (in PCI config space)
struc msi_cap
    .cap_id:        resb 1      ; Capability ID (0x05 for MSI)
    .next_ptr:      resb 1      ; Next capability pointer
    .msg_ctrl:      resw 1      ; Message control
    .msg_addr_lo:   resd 1      ; Message address low
    .msg_addr_hi:   resd 1      ; Message address high (64-bit)
    .msg_data:      resw 1      ; Message data (interrupt vector)
endstruc

; Programming MSI
setup_msi:
    ; Set message address (target local APIC)
    mov dword [device_config + msi_cap.msg_addr_lo], 0xFEE00000
    mov dword [device_config + msi_cap.msg_addr_hi], 0
    
    ; Set message data (interrupt vector)
    mov word [device_config + msi_cap.msg_data], DEVICE_VECTOR
    
    ; Enable MSI
    mov ax, [device_config + msi_cap.msg_ctrl]
    or ax, MSI_ENABLE
    mov [device_config + msi_cap.msg_ctrl], ax
    ret
```

[Inference] MSI/MSI-X represents a significant improvement over line-based interrupts, eliminating interrupt sharing issues and enabling devices to efficiently signal multiple interrupt conditions. Modern device drivers should prefer MSI/MSI-X when available.

### Programmed I/O (PIO) vs DMA

|**Aspect**|**Programmed I/O**|**DMA**|
|---|---|---|
|**CPU involvement**|CPU performs every transfer|CPU only sets up transfer|
|**Throughput**|Limited by CPU speed|Limited by bus/device speed|
|**CPU efficiency**|CPU busy during transfer|CPU free for other work|
|**Latency**|Low (immediate start)|Higher (setup overhead)|
|**Complexity**|Simple implementation|Complex setup and management|
|**Suitable for**|Small transfers, low-speed devices|Bulk transfers, high-speed devices|

[Inference] PIO is appropriate for small control operations and status checking, while DMA is essential for bulk data transfers where CPU efficiency matters. Modern systems use PIO for device configuration and DMA for actual data movement.

### I/O Port Examples

#### Serial Port (UART) Communication

```nasm
; 16550 UART register offsets
UART_BASE       equ 0x3F8       ; COM1 base address
UART_DATA       equ 0           ; Data register (DLAB=0)
UART_IER        equ 1           ; Interrupt Enable Register
UART_IIR        equ 2           ; Interrupt ID Register
UART_LCR        equ 3           ; Line Control Register
UART_MCR        equ 4           ; Modem Control Register
UART_LSR        equ 5           ; Line Status Register
UART_MSR        equ 6           ; Modem Status Register

; Initialize serial port
init_serial:
    mov dx, UART_BASE + UART_IER
    xor al, al
    out dx, al          ; Disable interrupts
    
    mov dx, UART_BASE + UART_LCR
    mov al, 0x80        ; Enable DLAB
    out dx, al
    
    mov dx, UART_BASE + 0   ; Divisor low byte
    mov al, 0x03        ; 38400 baud (115200 / 3)
    out dx, al
    
    mov dx, UART_BASE + 1   ; Divisor high byte
    xor al, al
    out dx, al
    
    mov dx, UART_BASE + UART_LCR
    mov al, 0x03        ; 8 bits, no parity, 1 stop bit
    out dx, al
    
    mov dx, UART_BASE + UART_MCR
    mov al, 0x03        ; DTR, RTS
    out dx, al
    ret

; Write byte to serial port
serial_write:
    ; Input: AL = byte to write
    mov ah, al          ; Save byte
    mov dx, UART_BASE + UART_LSR
.wait:
    in al, dx
    test al, 0x20       ; Transmitter empty?
    jz .wait
    
    mov al, ah
    mov dx, UART_BASE + UART_DATA
    out dx, al
    ret

; Read byte from serial port
serial_read:
    ; Output: AL = byte read
    mov dx, UART_BASE + UART_LSR
.wait:
    in al, dx
    test al, 0x01       ; Data ready?
    jz .wait
    
    mov dx, UART_BASE + UART_DATA
    in al, dx
    ret
```

#### PCI Configuration Space Access

```nasm
; PCI Configuration Address Port (0x0CF8)
PCI_CONFIG_ADDR equ 0x0CF8
PCI_CONFIG_DATA equ 0x0CFC

; Read PCI configuration space
; Input: BH = bus, BL = device, CL = function, AL = register offset
; Output: EAX = configuration data
pci_config_read:
    push eax
    movzx eax, bh       ; Bus number
    shl eax, 16
    movzx edx, bl       ; Device number
    shl edx, 11
    or eax, edx
    movzx edx, cl       ; Function number
    shl edx, 8
    or eax, edx
    pop edx
    and dl, 0xFC        ; Align register to dword
    or eax, edx
    or eax, 0x80000000  ; Enable bit
    
    mov dx, PCI_CONFIG_ADDR
    out dx, eax
    
    mov dx, PCI_CONFIG_DATA
    in eax, dx
    ret

; Write PCI configuration space
; Input: BH = bus, BL = device, CL = function, AL = register, EDX = value
pci_config_write:
    push eax
    movzx eax, bh
    shl eax, 16
    movzx esi, bl
    shl esi, 11
    or eax, esi
    movzx esi, cl
    shl esi, 8
    or eax, esi
    pop esi
    and sil, 0xFC
    or eax, esi
    or eax, 0x80000000
    
    push edx
    mov dx, PCI_CONFIG_ADDR
    out dx, eax
    pop eax
    
    mov dx, PCI_CONFIG_DATA
    out dx, eax
    ret
```

#### Keyboard Controller (PS/2)

```nasm
; PS/2 Keyboard controller ports
KBD_DATA_PORT   equ 0x60        ; Data port
KBD_CMD_PORT    equ 0x64        ; Command/Status port

; Read scancode from keyboard
read_scancode:
    mov dx, KBD_CMD_PORT
.wait:
    in al, dx
    test al, 1          ; Output buffer full?
    jz .wait
    
    mov dx, KBD_DATA_PORT
    in al, dx           ; Read scancode
    ret

; Write command to keyboard controller
kbd_write_cmd:
    ; Input: AL = command byte
    mov ah, al
    mov dx, KBD_CMD_PORT
.wait:
    in al, dx
    test al, 2          ; Input buffer full?
    jnz .wait
    
    mov al, ah
    out dx, al
    ret

; Reboot via keyboard controller
reboot_system:
    mov al, 0xFE        ; System reset command
    call kbd_write_cmd
.hang:
    hlt
    jmp .hang
```

### I/O Optimization Techniques

#### I/O Batching

[Inference] Batching multiple I/O operations reduces overhead by amortizing setup costs:

```nasm
; Inefficient: Multiple small I/O operations
write_inefficient:
    mov ecx, 1000
.loop:
    mov al, [buffer + rcx]
    call serial_write       ; Function call overhead per byte
    loop .loop

; Efficient: Batch operation
write_efficient:
    mov rsi, buffer
    mov ecx, 1000
    mov dx, UART_BASE + UART_LSR
.loop:
    in al, dx
    test al, 0x20
    jz .loop
    
    lodsb                   ; Load byte, increment RSI
    mov dx, UART_BASE + UART_DATA
    out dx, al
    mov dx, UART_BASE + UART_LSR
    loop .loop
```

#### Polling vs Interrupts

**Polling**: CPU continuously checks device status

```nasm
; Polling loop
poll_device:
    mov dx, DEVICE_STATUS_PORT
.loop:
    in al, dx
    test al, DATA_READY
    jz .loop
    
    ; Data ready, process it
    mov dx, DEVICE_DATA_PORT
    in al, dx
    ; ... process data ...
    jmp .loop
```

[Inference] Polling is efficient for devices with predictable, frequent events but wastes CPU cycles when events are infrequent.

**Interrupts**: Device signals CPU when ready

```nasm
; Interrupt-driven I/O
device_interrupt_handler:
    push rax
    push rdx
    
    mov dx, DEVICE_STATUS_PORT
    in al, dx
    test al, DATA_READY
    jz .done
    
    mov dx, DEVICE_DATA_PORT
    in al, dx
    ; ... process data ...
    
    ; Send EOI to interrupt controller
    mov al, 0x20
    out 0x20, al
    
.done:
    pop rdx
    pop rax
    iretq
```

[Inference] Interrupt-driven I/O is more efficient for infrequent events, allowing the CPU to perform other work while waiting. However, interrupt overhead makes polling preferable for very high-frequency operations.

**Hybrid approach**: Polling with timeout, falling back to interrupts

```nasm
; Poll briefly, then enable interrupts
smart_io_wait:
    mov ecx, 1000       ; Poll iterations
.poll:
    mov dx, DEVICE_STATUS_PORT
    in al, dx
    test al, DATA_READY
    jnz .ready
    pause               ; Hint to CPU (reduces power in spin)
    loop .poll
    
    ; Timeout: enable interrupts and sleep
    call enable_device_interrupt
    hlt                 ; Wait for interrupt
    
.ready:
    ; Process data
    ret
```

**Key Points:**

- x86 architecture implements four privilege levels (rings 0-3), with modern systems typically using only ring 0 (kernel) and ring 3 (user mode)
- Current Privilege Level (CPL) is hardware-enforced through the CS segment register, preventing unauthorized privilege escalation
- [Inference] Privileged instructions executing at CPL=3 generate general protection faults, ensuring only kernel code can manipulate system-critical hardware state
- INT 80h provides traditional system call mechanism with complete state preservation but [Unverified] incurs approximately 100-300 cycle overhead
- SYSENTER/SYSEXIT (32-bit) and SYSCALL/SYSRET (64-bit) provide fast system call mechanisms with [Unverified] approximately 30-70 cycle overhead through MSR-based configuration
- [Inference] System call evolution reflects the trade-off between automatic state management and performance, with modern mechanisms requiring kernel management of minimal preserved state
- Port-mapped I/O uses dedicated IN/OUT instructions with separate 16-bit address space, while memory-mapped I/O uses standard memory instructions with device registers mapped into physical address space
- DMA enables devices to transfer bulk data without continuous CPU involvement, dramatically improving throughput for high-bandwidth operations
- [Inference] Proper DMA coherency management through cache flushing and memory barriers is critical to prevent data corruption from cache/memory inconsistency
- [Inference] MSI/MSI-X represents modern interrupt delivery mechanism superior to line-based interrupts, eliminating sharing issues and enabling per-device interrupt vectors


---

