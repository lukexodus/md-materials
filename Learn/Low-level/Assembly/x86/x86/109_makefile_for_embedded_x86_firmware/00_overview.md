## Overview

AS = nasm
LD = ld
OBJCOPY = objcopy

ASFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T linker.ld

SOURCES = boot.asm main.asm drivers.asm
OBJECTS = $(SOURCES:.asm=.o)

all: firmware.bin

firmware.elf: $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary $< $@

%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $

clean:
	rm -f $(OBJECTS) firmware.elf firmware.bin

flash: firmware.bin
	flashrom -p internal -w firmware.bin

.PHONY: all clean flash
```

### Cross-Platform Considerations

```asm
; Conditional assembly for different targets
%ifdef TARGET_ATOM
    ; Intel Atom specific optimizations
    %define CACHE_LINE 64
    %define USE_SSE3
%elifdef TARGET_GEODE
    ; AMD Geode specific
    %define CACHE_LINE 32
    %undef USE_SSE3
%else
    ; Generic x86
    %define CACHE_LINE 64
%endif

; Use definitions
align_cache_line:
    align CACHE_LINE
cached_data:
    times 1024 db 0
```

### Testing and Debugging

```asm
; UART debugging output
debug_print:
    push eax
    push edx
    
    mov dx, 0x3F8       ; COM1
.loop:
    lodsb
    or al, al
    jz .done
    
    ; Wait for transmit ready
.wait:
    mov dx, 0x3FD
    in al, dx
    test al, 0x20
    jz .wait
    
    ; Send byte
    mov dx, 0x3F8
    mov al, [si-1]
    out dx, al
    jmp .loop
    
.done:
    pop edx
    pop eax
    ret

; Assert macro for debugging
%macro ASSERT 1
    test %1
    jnz %%ok
    push debug_assert_msg
    call debug_print
    hlt
%%ok:
%endmacro

debug_assert_msg: db "ASSERTION FAILED", 13, 10, 0
```

### Memory Layout Management

```asm
; Define memory regions
%define FLASH_BASE   0xFFFE0000
%define RAM_BASE     0x00100000
%define MMIO_BASE    0xFEC00000

; Section placement
section .text.boot
global _start
_start:
    jmp firmware_entry

section .text
firmware_entry:
    ; Copy .data from ROM to RAM
    mov esi, _data_load
    mov edi, _data_start
    mov ecx, _data_end
    sub ecx, _data_start
    rep movsb
    
    ; Zero .bss
    mov edi, _bss_start
    mov ecx, _bss_end
    sub ecx, _bss_start
    xor eax, eax
    rep stosb
    
    ; Call main
    call main
    hlt

section .data
global config_data
config_data:
    dd 0x12345678

section .bss
global buffer
buffer:
    resb 4096
```

**Key Points:**

- Power management requires coordination between CPU C-states, peripheral control, and interrupt optimization for minimal power consumption
- Firmware development involves managing boot sequences, hardware initialization, and creating ISRs without OS support
- Cross-compilation requires careful toolchain configuration, custom linker scripts, and memory layout management for specific target hardware
- [Inference] MSR programming and MWAIT/MONITOR provide better power efficiency than simple HLT loops in modern x86 embedded systems
- Flash memory operations require specific unlock sequences and polling mechanisms that vary by manufacturer
- Multi-stage bootloaders enable complex firmware in space-constrained boot sectors

**Important related topics:** Real-time operating systems (RTOS) integration with x86 assembly, SPI/I2C bus protocols at assembly level, DMA controller programming for embedded peripherals, x86 instruction timing analysis for embedded applications, secure boot implementation in x86 firmware.

---

# Virtualization Extensions

Hardware virtualization extensions are CPU features that enable efficient execution of virtual machines by providing direct hardware support for virtualization. Before these extensions, virtualization relied on software techniques like binary translation and parapirtualization, which introduced significant performance overhead.

## VT-x (Intel Virtualization Technology)

Intel VT-x is Intel's hardware virtualization technology that introduces new processor execution modes and instructions specifically designed for virtualization. It enables a hypervisor to run multiple operating systems simultaneously with minimal performance degradation.

### Architecture Components

VT-x introduces two fundamental operation modes: VMX root operation (for the hypervisor) and VMX non-root operation (for guest virtual machines). The hypervisor runs in VMX root mode with full hardware privileges, while guest operating systems run in VMX non-root mode with restricted access to certain hardware features.

The technology adds new privilege levels beyond the traditional ring 0-3 protection model. VMX root operation can access all processor features, while VMX non-root operation experiences controlled exits to the hypervisor when attempting privileged operations.

### VMX Instructions

VT-x introduces several new instructions for managing virtual machine lifecycle:

**VMXON** enables VMX operation mode and must be executed before any other VMX instructions. It requires a 4KB-aligned VMXON region in memory and can only be executed in ring 0 with CR4.VMXE set to 1.

**VMXOFF** disables VMX operation and returns the processor to normal operation mode. All VMX-specific state is cleared, and the processor can no longer execute VMX instructions until VMXON is executed again.

**VMLAUNCH** launches a new virtual machine using the current VMCS. It transitions the processor from VMX root operation to VMX non-root operation, loading guest state from the VMCS. This instruction can only be used once per VMCS; subsequent entries must use VMRESUME.

**VMRESUME** resumes a previously launched virtual machine. It performs the same state transition as VMLAUNCH but is used for VMs that have already been launched and have subsequently exited.

**VMREAD** and **VMWRITE** access fields within the current VMCS. VMREAD reads a field value into a general-purpose register, while VMWRITE writes a value from a register into a VMCS field. These instructions use field encoding values to specify which VMCS component to access.

**VMPTRLD** loads a pointer to a VMCS structure, making it the current VMCS for subsequent VMX operations. The pointer must reference a 4KB-aligned memory region.

**VMPTRST** stores the current VMCS pointer to a specified memory location.

**VMCLEAR** initializes or clears a VMCS structure and ensures any cached data is written back to memory. This instruction must be executed before a VMCS can be used on a different logical processor.

**VMCALL** allows guest software to explicitly call into the hypervisor. This provides a mechanism for paravirtualized operations where the guest cooperates with the hypervisor.

### VM Entry and Exit

VM entry occurs when the processor transitions from VMX root operation to VMX non-root operation, loading guest state and beginning or resuming guest execution. During entry, the processor performs consistency checks on the VMCS, loads guest state (registers, control registers, segment descriptors), and optionally injects events like interrupts or exceptions.

VM exit occurs when guest execution encounters a condition configured to trigger an exit. The processor saves guest state to the VMCS, loads host state, and transfers control to the hypervisor's exit handler. Exit reasons include execution of privileged instructions, hardware interrupts, exceptions, access to controlled I/O ports or memory regions, and explicit VMCALL instructions.

### Extended Page Tables (EPT)

EPT provides hardware-assisted memory virtualization by introducing a second level of address translation. Guest virtual addresses are first translated to guest physical addresses using the guest's page tables, then EPT translates guest physical addresses to host physical addresses.

This eliminates the need for shadow page tables, which required the hypervisor to maintain synchronized copies of guest page tables. EPT significantly reduces VM exits related to memory management and improves performance for memory-intensive workloads.

EPT uses a page table structure similar to standard x86-64 paging with four levels (PML4, PDPT, PD, PT). Each EPT entry contains a host physical address, access permissions (read, write, execute), and memory type information.

### VPID (Virtual Processor Identifier)

VPID adds a tag to TLB entries to distinguish translations belonging to different virtual machines. Without VPID, the TLB must be flushed on every VM entry and exit, causing performance degradation.

With VPID enabled, each VM is assigned a unique 16-bit identifier. TLB entries are tagged with this identifier, allowing the processor to cache translations for multiple VMs simultaneously. This significantly reduces the overhead of VM transitions.

## AMD-V (AMD Virtualization)

AMD-V is AMD's hardware virtualization technology, providing similar functionality to Intel VT-x but with different architectural approaches and terminology. AMD was first to market with hardware virtualization extensions in 2006.

### Architecture Components

AMD-V introduces two execution modes: host mode (for the hypervisor) and guest mode (for virtual machines). The hypervisor runs in host mode with full control over hardware, while guests run in guest mode with intercepted access to sensitive resources.

Unlike Intel's VMCS, AMD-V uses a Virtual Machine Control Block (VMCB) to store guest and control state. The VMCB is a 4KB memory structure containing guest processor state, control bits for intercepts, and nested paging tables.

### SVM Instructions

AMD-V instructions are part of Secure Virtual Machine (SVM) extensions:

**VMRUN** is the primary instruction for entering guest mode. It loads guest state from the VMCB and begins or resumes guest execution. Unlike Intel's separate VMLAUNCH/VMRESUME, AMD uses a single instruction for both initial launch and resume operations.

**VMLOAD** loads a subset of guest state from the VMCB into processor registers. This includes segment registers, system descriptor tables (GDTR, IDTR), and other control state.

**VMSAVE** saves the same subset of processor state to the VMCB. These instructions allow efficient state management during VM transitions.

**STGI** and **CLGI** set and clear the Global Interrupt Flag, which controls whether physical interrupts can cause VM exits. This provides fine-grained control over interrupt handling in virtualized environments.

**SKINIT** is a secure initialization instruction that establishes a secure environment before launching virtual machines. It's part of AMD's Secure Startup technology.

**INVLPGA** invalidates TLB entries based on guest virtual address and ASID (Address Space Identifier), providing targeted TLB management for virtualized environments.

### Nested Paging (NPT/RVI)

AMD's Nested Paging, also called Rapid Virtualization Indexing (RVI), provides hardware-assisted memory virtualization equivalent to Intel's EPT. Guest virtual addresses are translated through guest page tables to guest physical addresses, then through nested page tables to system physical addresses.

NPT uses the same page table format as standard AMD64 paging. The hypervisor controls the nested page tables while guests maintain their own page tables independently. This eliminates the need for shadow paging and reduces memory management overhead.

NPT tables support multiple page sizes (4KB, 2MB, 1GB) and include protection attributes for read, write, and execute permissions. Memory type information can be specified to control caching behavior for different memory regions.

### ASID (Address Space Identifier)

ASID is AMD's equivalent to Intel's VPID, providing TLB tagging to distinguish translations for different VMs. Each VMCB includes an ASID field (1-255, with 0 reserved for host mode).

TLB entries are tagged with ASIDs, allowing the processor to maintain cached translations for multiple address spaces simultaneously. This avoids TLB flushes during VM transitions and improves performance.

## VMCS (Virtual Machine Control Structure)

The VMCS is the central data structure for Intel VT-x virtualization. It contains all the state and control information necessary to manage a virtual machine's execution.

### Structure and Organization

The VMCS is a 4KB memory region with a specific format defined by the processor. It must be aligned on a 4KB boundary and begins with a 32-bit revision identifier that matches the processor's VMX capabilities.

The structure is divided into six major areas: guest-state area, host-state area, VM-execution control fields, VM-exit control fields, VM-entry control fields, and VM-exit information fields.

VMCS fields are accessed using encoding values rather than direct memory addresses. Each field has a unique encoding that specifies its width (16-bit, 32-bit, 64-bit, natural width) and type (control, guest-state, host-state, exit information).

### Guest-State Area

The guest-state area stores the complete processor state for the virtual machine. This includes all general-purpose registers (RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15), instruction pointer (RIP), and flags register (RFLAGS).

Control registers (CR0, CR3, CR4) define the guest's execution environment, including paging mode, protected mode settings, and feature enables. DR7 stores debug control information.

Segment registers (CS, DS, ES, FS, GS, SS) and their associated descriptor cache information (base, limit, access rights) are stored to fully describe the guest's segmentation state.

System table registers (GDTR, IDTR, LDTR, TR) point to the guest's descriptor tables and task state. These are essential for interrupt handling and task management within the guest.

Model-specific registers (MSRs) that affect guest execution are stored, including SYSENTER registers, PAT (Page Attribute Table), EFER (Extended Feature Enable Register), and others depending on processor capabilities.

### Host-State Area

The host-state area contains the processor state that will be loaded during VM exits. This defines the execution environment for the hypervisor's exit handler.

It includes control registers (CR0, CR3, CR4) to establish the host's execution mode, instruction pointer (RIP) pointing to the exit handler entry point, and RSP providing the host stack pointer.

Segment selectors for CS, SS, DS, ES, FS, GS establish the host's segmentation environment. Base addresses for FS and GS support thread-local storage in the hypervisor.

System table registers (GDTR, IDTR, TR) point to the host's interrupt descriptor table and task state. Host MSRs including SYSENTER registers, PAT, and EFER are loaded to establish the host's execution environment.

### VM-Execution Control Fields

VM-execution controls determine which guest operations trigger VM exits and configure processor behavior in VMX non-root operation.

**Pin-based execution controls** manage external interrupt behavior. Settings control whether external interrupts, NMIs, and virtual NMIs cause VM exits. The "activate VMX-preemption timer" bit enables a countdown timer that generates exits.

**Primary processor-based execution controls** govern a wide range of intercepts. These include unconditional exits for HLT, INVLPG, MWAIT, RDPMC, RDTSC, and control register accesses. Interrupt-window exiting allows the hypervisor to inject interrupts when the guest is ready. I/O bitmap controls determine whether I/O instructions cause exits based on port number.

**Secondary processor-based execution controls** enable advanced features. "Enable EPT" activates Extended Page Tables for hardware memory virtualization. "Enable VPID" enables Virtual Processor Identifiers for TLB optimization. "Virtualize APIC accesses" and "Virtualize x2APIC mode" optimize interrupt handling. "Enable INVPCID" allows controlled invalidation of process-context identifiers.

**Exception bitmap** is a 32-bit field where each bit corresponds to an x86 exception vector (0-31). Setting a bit causes that exception to trigger a VM exit rather than being delivered directly to the guest.

**I/O bitmaps** are two 4KB regions (for ports 0-7FFFh and 8000h-FFFFh) where each bit represents an I/O port. A set bit causes I/O instructions accessing that port to cause VM exits.

**MSR bitmaps** are 4KB regions containing four 1024-bit fields controlling exits for RDMSR and WRMSR instructions. Separate bitmaps exist for low MSRs (0-1FFFh) and high MSRs (C0000000h-C0001FFFh).

**EPT pointer (EPTP)** specifies the base address of the EPT page tables and configures memory type and page-walk length. This field is only valid when EPT is enabled.

**VPID** is a 16-bit virtual processor identifier used to tag TLB and paging-structure cache entries. Value 0 is reserved; valid VPIDs range from 1-65535.

**VM-function controls** enable specific operations that guests can perform without VM exits, such as EPTP switching for fast address space changes.

### VM-Exit Control Fields

VM-exit controls govern the processor's behavior during VM exits and what information is saved.

**Exit controls** include options to save/load debug registers, acknowledge interrupts on exit, save PAT and EFER, load PAT and EFER, save/load preemption timer value, and clear BNDCFGS (bounds configuration for Intel MPX).

**MSR-store and MSR-load addresses** point to lists of MSRs that should be saved from guest state or loaded into host state during exits. Each list can contain up to 512 entries specifying MSR numbers and values.

**Exit reason** field (16 bits) indicates why the VM exit occurred. Basic exit reasons include exception or NMI, external interrupt, triple fault, INIT signal, SIPI, task switch, instruction execution (HLT, INVD, INVLPG, etc.), CR access, I/O instruction, RDMSR/WRMSR, EPT violation, and many others.

### VM-Entry Control Fields

VM-entry controls configure the processor's behavior during VM entries and event injection.

**Entry controls** include options to load debug registers, enter IA-32e mode (64-bit), enter SMM (System Management Mode), deactivate dual-monitor treatment, load PAT, load EFER, load BNDCFGS, and conceal VM entries from Intel PT (Processor Trace).

**Event injection** mechanism allows the hypervisor to inject interrupts, exceptions, or software interrupts into the guest during VM entry. Fields include interrupt/exception vector, type (external interrupt, NMI, hardware exception, software interrupt), error code validity, and error code value.

**MSR-load address** points to a list of MSRs to load into guest state during entry, enabling efficient restoration of guest MSR values.

**Instruction length** must be provided for software interrupts, privileged software exceptions, and software exceptions. This ensures correct RIP adjustment after event delivery.

### VM-Exit Information Fields

These read-only fields provide information about why a VM exit occurred and the guest state at exit time.

**Exit reason** contains a 16-bit basic reason code and additional flags. Bit 31 indicates VM-entry failure. Bits 27-16 provide enclave mode information. Bits 15-0 contain the basic exit reason.

**Exit qualification** provides additional detail specific to the exit reason. For CR accesses, it identifies which register and operation. For EPT violations, it indicates the guest physical address and access type. For I/O instructions, it specifies port number, size, and direction.

**Guest-linear address** contains the linear address that caused certain exits, such as EPT violations or page faults.

**Guest-physical address** contains the guest physical address for EPT violations or failed guest address translations.

**VM-instruction error** indicates why a VMX instruction failed when executed in VMX root operation.

**IDT-vectoring information** describes an event that was being delivered when the exit occurred. This enables proper event re-injection after the hypervisor handles the exit.

**Instruction information** provides decoded information about instructions that caused exits, reducing the need for software instruction decoding.

**Instruction length** specifies the length of the instruction that caused the exit, enabling correct RIP advancement.

## VMX Operations

VMX operations encompass the complete lifecycle of virtual machine management using Intel VT-x technology.

### Enabling VMX Operation

Before using VMX instructions, the system must verify processor support and enable the feature. CPUID leaf 1 ECX bit 5 indicates VMX support.

The IA32_FEATURE_CONTROL MSR (address 3Ah) must be configured. Bit 0 (lock bit) must be set to prevent further changes. Bit 2 (enable VMX outside SMX operation) must be set for standard VMX use. These settings typically require BIOS configuration or are set during early boot.

CR4.VMXE (bit 13) must be set to 1 to enable VMX instructions. Attempting VMX instructions without this bit set generates #UD (undefined opcode) exceptions.

The IA32_VMX_BASIC MSR provides essential information: VMCS revision identifier (bits 30-0), VMCS region size (bits 44-32), memory type for VMCS regions (bit 50), and whether the processor supports various VMX features.

Capability MSRs (IA32_VMX_PINBASED_CTLS, IA32_VMX_PROCBASED_CTLS, IA32_VMX_EXIT_CTLS, IA32_VMX_ENTRY_CTLS) report which control bits are allowed or required. Bits 0-31 indicate allowed 0-settings; bits 32-63 indicate allowed 1-settings.

### Initializing VMX Operation

After enabling prerequisites, execute VMXON with a pointer to a VMXON region. This region must be 4KB-aligned, and its first 32 bits must contain the VMCS revision identifier from IA32_VMX_BASIC.

The VMXON instruction places the logical processor in VMX root operation. From this point, the processor can execute VMX management instructions and launch virtual machines.

Allocate and initialize a VMCS for each virtual machine. The VMCS must be 4KB-aligned and begin with the revision identifier. Clear the VMCS using VMCLEAR to initialize it and ensure it's not active on any logical processor.

Load the VMCS using VMPTRLD to make it current for the logical processor. All subsequent VMREAD and VMWRITE operations affect this VMCS.

### Configuring the VMCS

Configure execution controls based on virtualization requirements. Set exception bitmap bits for exceptions the hypervisor needs to intercept. Configure I/O and MSR bitmaps to control access to specific ports and MSRs.

Enable EPT if hardware memory virtualization is desired. Set the EPTP field to point to EPT page tables. Assign a unique VPID to optimize TLB performance.

Initialize guest-state area with the starting state for the virtual machine. This includes setting CS:RIP to the guest entry point, configuring segment descriptors, setting control register values (CR0, CR3, CR4), and initializing system table registers (GDTR, IDTR).

Configure host-state area with hypervisor state for VM exits. Set host RIP to the exit handler entry point, RSP to a valid stack, and configure segment selectors and control registers for host execution mode.

Set VM-entry controls and VM-exit controls based on required features. Configure MSR load/store lists if MSRs need special handling during transitions.

### Launching and Resuming VMs

Use VMLAUNCH to start a new virtual machine. The processor performs extensive consistency checks on the VMCS. If checks pass, the processor saves host state, loads guest state from the VMCS, and begins guest execution in VMX non-root operation.

If VMLAUNCH fails, the instruction sets RFLAGS appropriately and stores an error code in the VM-instruction error field. Common failures include invalid control settings or inconsistent guest state.

After successful launch, the VMCS enters the "launched" state. Subsequent re-entries after VM exits must use VMRESUME instead of VMLAUNCH.

VMRESUME operates similarly to VMLAUNCH but is used for VMs that have already been launched. It reloads guest state and resumes execution at the saved guest RIP.

### Handling VM Exits

When a VM exit occurs, the processor automatically saves guest state to the VMCS, loads host state, and transfers control to the host RIP specified in the VMCS.

The exit handler examines the exit reason field to determine what caused the exit. Based on the exit reason, it reads additional information from exit qualification, guest-linear address, guest-physical address, or instruction information fields.

[Inference] Common handling patterns include:

For instruction intercepts: The hypervisor emulates the instruction's effect, potentially updating guest state via VMWRITE, then advances guest RIP appropriately before resuming.

For EPT violations: The hypervisor checks whether the access should be permitted, updates EPT page tables if needed, or forwards the fault to the guest as a page fault exception.

For I/O instructions: The hypervisor emulates the I/O operation by communicating with virtual devices, then advances guest RIP.

For interrupt exits: The hypervisor handles the physical interrupt, then determines whether to inject a virtual interrupt into the guest.

After handling the exit, the hypervisor either resumes the guest using VMRESUME or performs other management tasks like scheduling different VMs.

### Event Injection

The hypervisor can inject interrupts, exceptions, or other events into the guest during VM entry using the VM-entry interrupt-information field.

Set the valid bit (bit 31) to enable injection. Specify the interrupt/exception vector (bits 7-0), type (bits 10-8: external interrupt, NMI, hardware exception, software interrupt), and error code validity (bit 11).

For exceptions that push error codes, set the error-code valid bit and provide the error code in the VM-entry exception error-code field.

For software interrupts and exceptions, provide the instruction length in the VM-entry instruction-length field to ensure correct RIP adjustment.

The processor delivers the event to the guest after completing VM entry. Event injection enables the hypervisor to virtualize interrupts from physical devices, inject timer interrupts, or forward exceptions that occurred during instruction emulation.

### Nested Virtualization

[Inference] Modern processors support nested virtualization, allowing a guest hypervisor to use VMX instructions. The hardware provides multiple levels of VMX operation, with the L0 hypervisor managing L1 guest hypervisors, which in turn manage L2 guests.

VMCS shadowing optimizes nested virtualization by allowing some VMREAD and VMWRITE operations in L1 to access shadow VMCS structures without exiting to L0. This reduces the overhead of nested virtualization.

VMCS link pointer field enables switching between VMCS structures efficiently, supporting nested hypervisor operations.

### Disabling VMX Operation

Before exiting VMX operation, ensure no VMCS is current by executing VMCLEAR for any active VMCS. This ensures all cached state is written to memory.

Execute VMXOFF to leave VMX operation. This disables VMX mode and returns the processor to normal operation. After VMXOFF, VMX instructions generate #UD exceptions until VMXON is executed again.

**Key Points:**

- Hardware virtualization extensions eliminate most software virtualization overhead by providing direct hardware support for running multiple operating systems
- Intel VT-x and AMD-V provide similar functionality but use different architectural approaches, instructions, and data structures
- VMCS stores complete virtual machine state and control information, using field encodings rather than direct memory access
- EPT/NPT provide two-level address translation, eliminating shadow page tables and reducing memory management overhead
- VPID/ASID tag TLB entries to avoid flushes during VM transitions, significantly improving performance
- VM exits transfer control to the hypervisor when guests attempt privileged operations or when configured conditions occur
- Event injection allows hypervisors to deliver interrupts and exceptions to guests during VM entry

---

## Hardware Virtualization Architecture

### VMX Operation Modes

Intel VT-x introduces VMX (Virtual Machine Extensions) operation with two distinct modes:

**VMX root operation** - The hypervisor executes in this privileged mode with full control over hardware and VMX instructions. This mode has unrestricted access to all processor features.

**VMX non-root operation** - Guest operating systems execute in this restricted mode. Certain operations automatically trigger VM exits to transfer control back to the hypervisor, regardless of the guest's privilege level.

The processor maintains this dual-mode structure through the VMCS (Virtual Machine Control Structure), a memory region that defines the execution environment and behavior for each virtual machine.

### VMCS (Virtual Machine Control Structure)

The VMCS is a 4KB-aligned data structure stored in memory that contains:

**Guest-state area** - Saves processor state when VM exits occur (registers, control registers, segment registers, MSRs, instruction pointers)

**Host-state area** - Defines processor state to load during VM exits (where the hypervisor resumes execution)

**VM-execution control fields** - Specify which operations trigger VM exits and how the processor behaves in VMX non-root operation

**VM-exit control fields** - Configure what happens during VM exit transitions

**VM-entry control fields** - Configure what happens during VM entry transitions

**VM-exit information fields** - Provide details about why a VM exit occurred (exit reason, qualification, interruption information)

Each logical processor can have only one current VMCS, referenced by a 64-bit physical address. The processor caches VMCS data internally for performance.

### VMX Instructions

**VMXON** - Enables VMX operation by placing the processor into VMX root mode. Requires a 4KB-aligned VMXON region in memory.

```nasm
; Enable VMX operation
mov rax, vmxon_region_phys
vmxon [rax]
jc vmx_error          ; CF=1 indicates failure
jz vmx_error          ; ZF=1 indicates failure
```

**VMXOFF** - Disables VMX operation and returns to normal x86 operation.

```nasm
vmxoff
```

**VMPTRLD** - Loads a VMCS pointer, making it the current VMCS for the logical processor.

```nasm
mov rax, vmcs_phys_addr
vmptrld [rax]
```

**VMPTRST** - Stores the current VMCS pointer to memory.

```nasm
vmptrst [rax]
```

**VMCLEAR** - Initializes a VMCS and ensures cached data is written back to memory. Marks the VMCS as non-current.

```nasm
mov rax, vmcs_phys_addr
vmclear [rax]
```

**VMREAD** - Reads a field from the current VMCS.

```nasm
mov rax, 0x6C14h      ; Guest RIP field encoding
vmread rbx, rax        ; Read guest RIP into RBX
```

**VMWRITE** - Writes a field to the current VMCS.

```nasm
mov rax, 0x6C14h      ; Guest RIP field encoding
mov rbx, guest_entry_point
vmwrite rax, rbx       ; Write guest entry point
```

**VMLAUNCH** - Launches a virtual machine (VM entry) for a VMCS being used for the first time.

```nasm
vmlaunch
jc vmlaunch_failure
jz vmlaunch_failure
; This code only executes if VMLAUNCH fails
```

**VMRESUME** - Resumes a virtual machine (VM entry) for a VMCS that has been launched previously.

```nasm
vmresume
jc vmresume_failure
jz vmresume_failure
```

**VMCALL** - Allows guest software to make explicit calls to the hypervisor (hypercalls).

```nasm
; Guest code making a hypercall
mov rax, HYPERCALL_NUMBER
mov rbx, parameter1
vmcall                 ; Triggers VM exit to hypervisor
```

**INVEPT** - Invalidates EPT-derived translations in TLB and paging-structure caches.

```nasm
mov rax, ept_pointer
mov rbx, 2            ; Single-context invalidation
invept rbx, [rsp]     ; Descriptor in memory
```

**INVVPID** - Invalidates VPID-tagged TLB entries for virtual processor identifiers.

```nasm
mov rax, vpid_value
mov rbx, 1            ; Individual-address invalidation
invvpid rbx, [rsp]    ; Descriptor in memory
```

## VM Entry and Exit

### VM Entry Process

VM entry is the transition from VMX root operation (hypervisor) to VMX non-root operation (guest). It occurs when the hypervisor executes VMLAUNCH or VMRESUME.

**VM Entry Sequence:**

1. **Checks on hypervisor state** - Verifies the processor is in VMX root operation and the current VMCS is valid
2. **Checks on VMCS controls** - Validates VM-execution, VM-exit, and VM-entry control fields
3. **Checks on host state** - Ensures host-state area contains valid values for VM exit
4. **Checks on guest state** - Verifies guest-state area contains valid architectural state
5. **Checks on VMCS linkage** - Validates VMCS link pointer if VM entry is to a nested guest
6. **Loading guest state** - Loads processor state from VMCS guest-state area (CR3, IDTR, GDTR, segment registers, RIP, RFLAGS)
7. **Loading MSRs** - Loads MSRs specified in VM-entry MSR-load area
8. **Event injection** - Delivers interrupts/exceptions if configured in VM-entry interruption-information field
9. **Begin guest execution** - Transfers control to guest at loaded RIP

**Example: Basic VM Entry Setup**

```nasm
; Configure VM-entry controls
mov rax, VM_ENTRY_CONTROLS
mov rbx, 0x93FF        ; IA-32e mode guest, load EFER
vmwrite rax, rbx

; Set guest RIP (entry point)
mov rax, GUEST_RIP
mov rbx, guest_start_address
vmwrite rax, rbx

; Set guest RSP
mov rax, GUEST_RSP
mov rbx, guest_stack_top
vmwrite rax, rbx

; Set guest RFLAGS (bit 1 must be 1)
mov rax, GUEST_RFLAGS
mov rbx, 0x2
vmwrite rax, rbx

; Set guest CR0
mov rax, GUEST_CR0
mov rbx, 0x80050033    ; PG=1, PE=1, NE=1, ET=1, MP=1
vmwrite rax, rbx

; Set guest CR3
mov rax, GUEST_CR3
mov rbx, guest_page_table_phys
vmwrite rax, rbx

; Set guest CR4
mov rax, GUEST_CR4
mov rbx, 0x2020        ; PAE=1, VMXE=1
vmwrite rax, rbx

; Set guest CS
mov rax, GUEST_CS_SELECTOR
mov rbx, 0x10
vmwrite rax, rbx

mov rax, GUEST_CS_BASE
xor rbx, rbx
vmwrite rax, rbx

mov rax, GUEST_CS_LIMIT
mov rbx, 0xFFFFFFFF
vmwrite rax, rbx

mov rax, GUEST_CS_ACCESS_RIGHTS
mov rbx, 0xA09B        ; P=1, DPL=0, S=1, Type=code, L=1
vmwrite rax, rbx

; Launch VM
vmlaunch
; Control only returns here on failure
```

### VM Exit Process

VM exit is the transition from VMX non-root operation (guest) to VMX root operation (hypervisor). It occurs when the guest executes an operation configured to trigger an exit.

**VM Exit Sequence:**

1. **Record exit information** - Saves exit reason, exit qualification, and other diagnostic information
2. **Save guest state** - Stores current processor state to VMCS guest-state area
3. **Save MSRs** - Stores MSRs specified in VM-exit MSR-store area
4. **Load host state** - Loads processor state from VMCS host-state area
5. **Load MSRs** - Loads MSRs specified in VM-exit MSR-load area
6. **Transfer control** - Begins execution at host RIP specified in VMCS

The processor automatically disables interrupts during VM exit (RFLAGS.IF = 0) to give the hypervisor time to save state and prepare for handling.

**Example: VM Exit Handler Setup**

```nasm
; Set host state for VM exits
mov rax, HOST_CR0
mov rbx, cr0
vmwrite rax, rbx

mov rax, HOST_CR3
mov rbx, hypervisor_page_table
vmwrite rax, rbx

mov rax, HOST_CR4
mov rbx, cr4
vmwrite rax, rbx

mov rax, HOST_RSP
lea rbx, [hypervisor_stack_top]
vmwrite rax, rbx

mov rax, HOST_RIP
lea rbx, [vm_exit_handler]
vmwrite rax, rbx

; Set host segment selectors
mov rax, HOST_CS_SELECTOR
mov bx, cs
vmwrite rax, rbx

mov rax, HOST_SS_SELECTOR
mov bx, ss
vmwrite rax, rbx

mov rax, HOST_DS_SELECTOR
mov bx, ds
vmwrite rax, rbx

mov rax, HOST_ES_SELECTOR
mov bx, es
vmwrite rax, rbx

mov rax, HOST_FS_SELECTOR
mov bx, fs
vmwrite rax, rbx

mov rax, HOST_GS_SELECTOR
mov bx, gs
vmwrite rax, rbx

; VM Exit handler entry point
vm_exit_handler:
    ; Save scratch registers
    push rax
    push rbx
    push rcx
    push rdx
    
    ; Read exit reason
    mov rax, VM_EXIT_REASON
    vmread rbx, rax
    
    ; Dispatch based on exit reason
    cmp rbx, EXIT_REASON_CPUID
    je handle_cpuid
    
    cmp rbx, EXIT_REASON_HLT
    je handle_hlt
    
    cmp rbx, EXIT_REASON_IO_INSTRUCTION
    je handle_io
    
    cmp rbx, EXIT_REASON_VMCALL
    je handle_hypercall
    
    cmp rbx, EXIT_REASON_EPT_VIOLATION
    je handle_ept_violation
    
    jmp unknown_exit
```

### VM Exit Reasons

**Unconditional exits** - Always cause VM exits regardless of control settings:

- CPUID execution
- GETSEC execution
- INVD execution
- XSETBV execution
- VMCALL execution
- VMCLEAR, VMLAUNCH, VMPTRLD, VMPTRST, VMREAD, VMRESUME, VMWRITE, VMXOFF, VMXON execution

**Conditional exits** - Controlled by VM-execution control fields:

- External interrupts (if "external-interrupt exiting" = 1)
- NMI (if "NMI exiting" = 1)
- INIT signals
- SIPI (Start-up IPI)
- Task switches (if configured)
- HLT execution (if "HLT exiting" = 1)
- IN, OUT, INS, OUTS (if "use I/O bitmaps" = 1 and port accessed is set)
- RDMSR, WRMSR (if MSR bitmap indicates)
- MOV to/from CR0-CR8 (if "CR0/CR3/CR4 guest/host mask" bits set)
- MOV DR (if "MOV-DR exiting" = 1)
- RDTSC, RDTSCP (if "RDTSC exiting" = 1)
- PAUSE (if "PAUSE exiting" = 1)
- MONITOR, MWAIT (if configured)
- EPT violations (page faults in guest physical memory)
- APIC access (if "virtualize APIC accesses" = 1 and access to APIC page)

**Example: Configuring VM Exit Controls**

```nasm
; Configure which events cause VM exits
mov rax, CPU_BASED_VM_EXEC_CONTROL
mov rbx, 0x84006172    ; Typical controls
; Bits set: HLT exiting, INVLPG exiting, MWAIT exiting
;           RDPMC exiting, RDTSC exiting, CR8-load/store exiting
;           MOV-DR exiting, use I/O bitmaps, use MSR bitmaps
;           activate secondary controls
vmwrite rax, rbx

; Configure secondary execution controls
mov rax, SECONDARY_VM_EXEC_CONTROL
mov rbx, 0x0000001E    ; Enable EPT, VPID, RDTSCP, INVPCID
vmwrite rax, rbx

; Set up I/O bitmap addresses (4KB each for ports 0-FFFF)
mov rax, IO_BITMAP_A
lea rbx, [io_bitmap_a]
vmwrite rax, rbx

mov rax, IO_BITMAP_B
lea rbx, [io_bitmap_b]
vmwrite rax, rbx

; Set up MSR bitmaps (4KB, controls RDMSR/WRMSR exits)
mov rax, MSR_BITMAP
lea rbx, [msr_bitmap]
vmwrite rax, rbx
```

### Exit Qualification

The exit qualification field provides additional information about certain VM exits. Its format depends on the exit reason.

**Example: Handling I/O Instruction Exits**

```nasm
handle_io:
    ; Read exit qualification for I/O instruction
    mov rax, EXIT_QUALIFICATION
    vmread rbx, rax
    
    ; Parse exit qualification
    ; Bits 0-2: Size of access (0=1-byte, 1=2-byte, 3=4-byte)
    ; Bit 3: Direction (0=OUT, 1=IN)
    ; Bit 4: String instruction (0=no, 1=yes)
    ; Bit 5: REP prefix (0=no, 1=yes)
    ; Bit 6: Operand encoding (0=DX, 1=immediate)
    ; Bits 16-31: Port number
    
    mov rcx, rbx
    shr rcx, 16
    and rcx, 0xFFFF       ; RCX = port number
    
    test rbx, 8           ; Check direction bit
    jnz io_input
    
io_output:
    ; Handle OUT instruction
    ; Read guest RAX value
    mov rax, GUEST_RAX
    vmread rdx, rax       ; RDX = value written
    
    ; Emulate I/O operation
    call emulate_port_write
    
    ; Advance guest RIP past instruction
    call advance_guest_rip
    
    ; Resume guest
    jmp resume_guest
    
io_input:
    ; Handle IN instruction
    call emulate_port_read  ; Returns value in RAX
    
    ; Write result to guest RAX
    mov rbx, GUEST_RAX
    vmwrite rbx, rax
    
    call advance_guest_rip
    jmp resume_guest

advance_guest_rip:
    ; Read current guest RIP
    mov rax, GUEST_RIP
    vmread rbx, rax
    
    ; Read instruction length
    mov rax, VM_EXIT_INSTRUCTION_LEN
    vmread rcx, rax
    
    ; Advance RIP
    add rbx, rcx
    mov rax, GUEST_RIP
    vmwrite rax, rbx
    ret

resume_guest:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    vmresume
    ; Only reaches here on error
    jmp vmresume_failed
```

## EPT (Extended Page Tables)

Extended Page Tables provide hardware-assisted Second Level Address Translation (SLAT), allowing the processor to translate guest virtual addresses to host physical addresses in two stages without hypervisor intervention.

### Two-Level Address Translation

**Traditional virtualization** requires the hypervisor to maintain shadow page tables that directly map guest virtual addresses to host physical addresses. Every guest page table modification requires a VM exit to update shadows.

**EPT virtualization** introduces a two-stage translation:

1. **Guest paging** - Guest virtual address (GVA) → Guest physical address (GPA) using guest page tables (CR3)
2. **EPT paging** - Guest physical address (GPA) → Host physical address (HPA) using EPT page tables (EPTP)

This eliminates shadow page table maintenance and reduces VM exits. The processor hardware walks both page table structures automatically.

### EPT Page Table Structure

EPT uses a 4-level or 5-level page table hierarchy similar to regular x86-64 paging but with different entry formats:

**EPT PML5E/PML4E** (512 entries, 8 bytes each)

- Bits 0-2: Read, Write, Execute permissions
- Bit 7: Page size (0=next level, 1=huge page)
- Bit 8: Accessed flag
- Bits 12-51: Physical address of next level table
- Bits 52-62: Reserved
- Bit 63: Suppress #VE (virtualization exception)

**EPT PDPTE** (512 entries, 8 bytes each)

- Same format as PML4E
- If bit 7=1, maps 1GB page directly

**EPT PDE** (512 entries, 8 bytes each)

- Same format as PML4E
- If bit 7=1, maps 2MB page directly

**EPT PTE** (512 entries, 8 bytes each)

- Bits 0-2: Read, Write, Execute permissions
- Bits 3-5: EPT memory type (0=UC, 1=WC, 4=WT, 5=WP, 6=WB)
- Bit 6: Ignore PAT memory type
- Bit 8: Accessed flag
- Bit 9: Dirty flag
- Bits 12-51: Physical address of 4KB page
- Bit 63: Suppress #VE

**Key Points:**

- EPT permissions (R/W/X) are independent of guest page permissions
- Final effective permissions are the intersection of guest and EPT permissions
- EPT supports 4KB, 2MB, and 1GB page sizes
- Memory type can be specified per-page for fine-grained control
- The processor caches EPT translations in specialized TLB structures

### EPTP (EPT Pointer)

The EPT Pointer is a 64-bit value stored in the VMCS that references the EPT PML4/PML5 table:

- Bits 0-2: EPT paging-structure memory type (0=UC, 6=WB)
- Bits 3-5: EPT page-walk length minus 1 (3=4-level, 4=5-level)
- Bit 6: Enable accessed and dirty flags
- Bits 12-51: Physical address of EPT PML4/PML5 table (4KB aligned)
- Other bits reserved

**Example: Setting up EPTP**

```nasm
; Create EPTP value
mov rax, ept_pml4_phys  ; Physical address of EPT PML4
or rax, 0x1E            ; Memory type=WB (6<<0), Walk length=4 (3<<3)
                         ; Enable A/D flags (1<<6)

; Write EPTP to VMCS
mov rbx, EPT_POINTER
vmwrite rbx, rax
```

### Building EPT Page Tables

**Example: Identity Mapping with EPT**

```nasm
; Allocate and zero EPT structures
ept_pml4:
    times 512 dq 0

ept_pdpt:
    times 512 dq 0

ept_pd:
    times 512 dq 0

ept_pt:
    times 512 dq 0

; Initialize EPT PML4 entry 0
setup_ept:
    ; PML4[0] -> PDPT
    mov rax, ept_pdpt
    or rax, 0x07          ; R=1, W=1, X=1
    mov [ept_pml4], rax
    
    ; PDPT[0] -> PD
    mov rax, ept_pd
    or rax, 0x07
    mov [ept_pdpt], rax
    
    ; PD[0] -> PT
    mov rax, ept_pt
    or rax, 0x07
    mov [ept_pd], rax
    
    ; Map first 2MB identity (512 x 4KB pages)
    xor rcx, rcx
    mov rdx, ept_pt
.map_pages:
    mov rax, rcx
    shl rax, 12           ; Page number * 4096
    or rax, 0x07          ; R=1, W=1, X=1
    or rax, (6 << 3)      ; Memory type = WB
    mov [rdx + rcx*8], rax
    inc rcx
    cmp rcx, 512
    jl .map_pages
    
    ret
```

**Example: Mapping with 2MB Pages**

```nasm
setup_ept_2mb:
    ; PML4[0] -> PDPT
    mov rax, ept_pdpt
    or rax, 0x07
    mov [ept_pml4], rax
    
    ; PDPT[0] -> PD
    mov rax, ept_pd
    or rax, 0x07
    mov [ept_pdpt], rax
    
    ; Map first 1GB using 2MB pages (512 entries)
    xor rcx, rcx
    mov rdx, ept_pd
.map_2mb_pages:
    mov rax, rcx
    shl rax, 21           ; Page number * 2MB
    or rax, 0x87          ; R=1, W=1, X=1, PS=1 (bit 7)
    or rax, (6 << 3)      ; Memory type = WB
    mov [rdx + rcx*8], rax
    inc rcx
    cmp rcx, 512
    jl .map_2mb_pages
    
    ret
```

### EPT Violations

An EPT violation is a VM exit that occurs when the guest accesses a guest physical address that:

- Has no valid EPT mapping
- Violates EPT permissions (read, write, or execute)
- Accesses memory with misconfigured EPT entries

**Example: Handling EPT Violations**

```nasm
handle_ept_violation:
    ; Read guest physical address that caused violation
    mov rax, GUEST_PHYSICAL_ADDRESS
    vmread rbx, rax       ; RBX = faulting GPA
    
    ; Read exit qualification
    mov rax, EXIT_QUALIFICATION
    vmread rcx, rax
    
    ; Parse qualification bits:
    ; Bit 0: Data read violation
    ; Bit 1: Data write violation
    ; Bit 2: Instruction fetch violation
    ; Bit 3: Readable (EPT entry was readable)
    ; Bit 4: Writable (EPT entry was writable)
    ; Bit 5: Executable (EPT entry was executable)
    ; Bit 7: GVA validity (1=GVA is valid)
    ; Bit 8: Caused by paging structure access
    
    test rcx, 2           ; Check if write violation
    jnz ept_write_violation
    
    test rcx, 1           ; Check if read violation
    jnz ept_read_violation
    
    test rcx, 4           ; Check if execute violation
    jnz ept_execute_violation
    
ept_write_violation:
    ; Handle write to protected page
    ; Could be copy-on-write, MMIO, or permissions error
    
    ; Check if this is MMIO region
    call is_mmio_address
    test rax, rax
    jnz handle_mmio_write
    
    ; Check if copy-on-write page
    call is_cow_page
    test rax, rax
    jnz handle_cow
    
    ; Permission error - inject page fault to guest
    jmp inject_page_fault
    
handle_mmio_write:
    ; Read instruction to determine access size
    call decode_guest_instruction
    
    ; Read guest register value being written
    call get_guest_register_value
    
    ; Emulate MMIO write
    call emulate_mmio_write
    
    ; Advance guest RIP
    call advance_guest_rip
    
    ; Resume guest
    jmp resume_guest
    
handle_cow:
    ; Allocate new physical page
    call allocate_page    ; Returns HPA in RAX
    
    ; Copy original page contents
    mov rdi, rax
    mov rsi, [cow_original_page]
    mov rcx, 4096/8
    rep movsq
    
    ; Update EPT entry with new page and write permission
    call update_ept_mapping
    
    ; Invalidate EPT TLB entries
    call invalidate_ept_tlb
    
    ; Resume guest to retry instruction
    jmp resume_guest
```

### EPT Memory Types

EPT allows specifying memory types for fine-grained control over caching:

- **UC (Uncacheable, 0)** - No caching, used for MMIO regions
- **WC (Write Combining, 1)** - Weak ordering, used for frame buffers
- **WT (Write Through, 4)** - Writes go to memory immediately
- **WP (Write Protected, 5)** - Reads can be cached, writes go to memory
- **WB (Write Back, 6)** - Full caching, best performance for normal memory

The effective memory type is determined by combining the EPT memory type with the guest's PAT (Page Attribute Table) settings according to processor-specific rules.

### EPT TLB Management

The processor caches EPT translations in specialized TLB structures. After modifying EPT page tables, these caches must be invalidated using the INVEPT instruction.

**INVEPT Types:**

- Type 1 (Single-context) - Invalidates all EPT-derived entries for a specific EPTP
- Type 2 (All-context) - Invalidates all EPT-derived entries for all EPTPs

**Example: Invalidating EPT TLB**

```nasm
invalidate_ept_tlb:
    ; Build INVEPT descriptor in memory
    ; [rsp] = EPTP value (8 bytes)
    ; [rsp+8] = Reserved, must be zero (8 bytes)
    
    sub rsp, 16
    
    ; Read current EPTP from VMCS
    mov rax, EPT_POINTER
    vmread rbx, rax
    mov [rsp], rbx
    
    xor rax, rax
    mov [rsp+8], rax      ; Zero reserved field
    
    ; Perform single-context invalidation
    mov rax, 1            ; Type = single-context
    mov rbx, rsp          ; RBX = descriptor address
    invept rax, [rbx]
    
    add rsp, 16
    ret
```

## Hypervisor Fundamentals

### Type 1 vs Type 2 Hypervisors

**Type 1 (Bare-metal) Hypervisors** run directly on hardware:

- Examples: VMware ESXi, Xen, Microsoft Hyper-V (standalone)
- Boot directly as the host operating system
- Have direct control over hardware resources
- Provide better performance and isolation
- Require comprehensive device drivers

**Type 2 (Hosted) Hypervisors** run on top of a host OS:

- Examples: VMware Workstation, VirtualBox, KVM (partially)
- Rely on host OS for device drivers and resource management
- Easier to install and use
- Slightly higher overhead due to host OS layer

### Hypervisor Architecture Layers

**Hardware Virtualization Layer** - VMX/SVM instructions and EPT/NPT hardware support provide the foundation.

**VMM (Virtual Machine Monitor)** - Core hypervisor component that:

- Manages VMCS structures for each virtual CPU
- Handles VM entries and exits
- Implements EPT page tables for memory virtualization
- Provides virtual device emulation or passthrough
- Schedules virtual CPUs on physical CPUs

**Guest OS Layer** - Unmodified operating systems running in VMX non-root mode, unaware they're virtualized (full virtualization).

### Resource Virtualization

**CPU Virtualization:**

- Each guest vCPU maps to a VMCS structure
- Hypervisor schedules vCPUs on physical CPUs
- Maintains guest register state in VMCS
- Handles privileged instruction emulation

**Memory Virtualization:**

- EPT provides guest physical to host physical translation
- Hypervisor manages host physical memory allocation
- Implements memory overcommitment with ballooning or paging
- Handles MMIO region mapping for devices

**I/O Virtualization:**

- Full emulation - Hypervisor traps I/O and emulates devices (slow but compatible)
- Paravirtualization - Guest uses special drivers (virtio) for better performance
- Direct device assignment - Hardware IOMMU allows passing physical devices to guests
- SR-IOV - Single physical device appears as multiple virtual devices

### Interrupt and Exception Handling

**External Interrupts:**

When "external-interrupt exiting" is enabled, physical interrupts cause VM exits. The hypervisor must:

```nasm
handle_external_interrupt:
    ; Read interrupt vector
    mov rax, VM_EXIT_INTR_INFO
    vmread rbx, rax
    and rbx, 0xFF         ; Extract vector
    
    ; Check if interrupt belongs to hypervisor or guest
    call classify_interrupt
    
    ; If hypervisor interrupt, handle it
    cmp rax, HYPERVISOR_INTERRUPT
    je handle_hypervisor_interrupt
    
    ; Otherwise inject into guest
    ; Set VM-entry interruption-information field
    mov rax, VM_ENTRY_INTR_INFO_FIELD
    mov rbx, [interrupt_info]
    or rbx, 0x80000000    ; Valid bit
    vmwrite rax, rbx
    
    jmp resume_guest
```

**Virtual APIC:**

The processor can virtualize local APIC operations to reduce VM exits:

```nasm
; Enable virtual APIC support
mov rax, SECONDARY_VM_EXEC_CONTROL
vmread rbx, rax
or rbx, (1 << 0)      ; Virtualize APIC accesses
or rbx, (1 << 4)      ; Virtual-interrupt delivery
or rbx, (1 << 7)      ; Virtualize x2APIC mode
vmwrite rax, rbx

; Set virtual-APIC page address (4KB aligned)
mov rax, VIRTUAL_APIC_PAGE_ADDR
lea rbx, [virtual_apic_page]
vmwrite rax, rbx

; Configure posted-interrupt processing
mov rax, POSTED_INTR_NOTIF_VECTOR
mov rbx, POSTED_INTERRUPT_VECTOR
vmwrite rax, rbx

mov rax, POSTED_INTR_DESC_ADDR
lea rbx, [posted_interrupt_descriptor]
vmwrite rax, rbx
```

**NMI Handling:**

Non-maskable interrupts require special handling:

```nasm
handle_nmi:
    ; Read NMI information
    mov rax, VM_EXIT_INTR_INFO
    vmread rbx, rax
    
    ; Check if real NMI or injected
    test rbx, 0x80000000
    jz not_valid_nmi
    
    ; Handle physical NMI for hypervisor
    call hypervisor_nmi_handler
    
    ; Optionally inject NMI to guest
    mov rax, VM_ENTRY_INTR_INFO_FIELD
    mov rbx, 0x80000202    ; Valid=1, Type=NMI(2), Vector=2
    vmwrite rax, rbx
    
    jmp resume_guest

not_valid_nmi:
    ; Spurious NMI, resume guest
    jmp resume_guest
```

**Exception Injection:**

The hypervisor can inject exceptions into the guest:

```nasm
inject_page_fault:
    ; Set exception information
    mov rax, VM_ENTRY_INTR_INFO_FIELD
    mov rbx, 0x80000B0E    ; Valid=1, Type=HW exception(3), Vector=14(#PF)
                           ; Error code valid=1
    vmwrite rax, rbx
    
    ; Set error code
    mov rax, VM_ENTRY_EXCEPTION_ERROR_CODE
    mov rbx, [page_fault_error_code]  ; P, W/R, U/S bits
    vmwrite rax, rbx
    
    ; Set CR2 (faulting address)
    mov rax, GUEST_CR2
    mov rbx, [faulting_address]
    vmwrite rax, rbx
    
    ; Guest will handle #PF through its IDT
    jmp resume_guest
```

### Virtual Processor Identifiers (VPID)

VPID tags TLB entries with a 16-bit virtual processor ID to avoid flushing the entire TLB on every VM entry/exit.

**Enabling VPID:**

```nasm
setup_vpid:
    ; Enable VPID in secondary execution controls
    mov rax, SECONDARY_VM_EXEC_CONTROL
    vmread rbx, rax
    or rbx, (1 << 5)      ; Enable VPID
    vmwrite rax, rbx
    
    ; Assign unique VPID to this vCPU (0 is reserved)
    mov rax, VIRTUAL_PROCESSOR_ID
    mov rbx, [vcpu_id]
    add rbx, 1            ; VPIDs start at 1
    vmwrite rax, rbx
    
    ret
```

**Invalidating VPID-tagged TLB entries:**

```nasm
flush_vpid_tlb:
    ; Build INVVPID descriptor
    ; [rsp] = VPID (16 bits)
    ; [rsp+2] = Reserved (48 bits)
    ; [rsp+8] = Linear address (64 bits)
    
    sub rsp, 16
    
    mov ax, [target_vpid]
    mov [rsp], ax
    xor rax, rax
    mov [rsp+2], rax
    mov rax, [linear_address]
    mov [rsp+8], rax
    
    ; Type 0 = individual address
    ; Type 1 = single context (all addresses for VPID)
    ; Type 2 = all contexts
    ; Type 3 = single context, retain globals
    
    mov rax, 1            ; Single-context invalidation
    lea rbx, [rsp]
    invvpid rax, [rbx]
    
    add rsp, 16
    ret
```

### MSR Virtualization

The hypervisor can selectively intercept RDMSR and WRMSR instructions using MSR bitmaps.

**MSR Bitmap Structure:**

The MSR bitmap is a 4KB page with four 1KB regions:

- Bytes 0-1023: RDMSR bitmap for MSRs 0x00000000-0x00001FFF
- Bytes 1024-2047: RDMSR bitmap for MSRs 0xC0000000-0xC0001FFF
- Bytes 2048-3071: WRMSR bitmap for MSRs 0x00000000-0x00001FFF
- Bytes 3072-4095: WRMSR bitmap for MSRs 0xC0000000-0xC0001FFF

Each bit represents one MSR. If the bit is 1, the corresponding RDMSR or WRMSR causes a VM exit.

**Example: Setting up MSR Bitmap**

```nasm
setup_msr_bitmap:
    ; Allocate 4KB MSR bitmap, zero-initialized
    ; (0 = no exit, 1 = exit)
    mov rdi, msr_bitmap
    xor rax, rax
    mov rcx, 512          ; 4096 / 8
    rep stosq
    
    ; Intercept EFER (MSR 0xC0000080)
    ; EFER is in range C0000000-C0001FFF
    mov rax, 0xC0000080
    sub rax, 0xC0000000   ; Offset within range
    mov rbx, rax
    shr rbx, 3            ; Byte offset
    and rax, 7            ; Bit offset
    
    ; Set RDMSR bit for EFER
    add rbx, 0            ; Offset for RDMSR low range (0 bytes)
    bts qword [msr_bitmap + rbx], rax
    
    ; Set WRMSR bit for EFER
    add rbx, 2048         ; Offset for WRMSR low range
    bts qword [msr_bitmap + rbx], rax
    
    ; Intercept IA32_STAR (MSR 0xC0000081)
    mov rax, 0xC0000081
    sub rax, 0xC0000000
    mov rbx, rax
    shr rbx, 3
    and rax, 7
    bts qword [msr_bitmap + rbx], rax
    add rbx, 2048
    bts qword [msr_bitmap + rbx], rax
    
    ; Set MSR bitmap address in VMCS
    mov rax, MSR_BITMAP
    lea rbx, [msr_bitmap]
    vmwrite rax, rbx
    
    ; Enable MSR bitmap use
    mov rax, CPU_BASED_VM_EXEC_CONTROL
    vmread rbx, rax
    or rbx, (1 << 28)     ; Use MSR bitmaps
    vmwrite rax, rbx
    
    ret
```

**Handling MSR Access Exits:**

```nasm
handle_rdmsr:
    ; Read guest RCX (MSR index)
    mov rax, GUEST_RCX
    vmread rbx, rax
    
    ; Dispatch based on MSR
    cmp rbx, 0xC0000080   ; EFER
    je rdmsr_efer
    
    cmp rbx, 0x10         ; IA32_TSC
    je rdmsr_tsc
    
    ; Default: read from physical MSR
    mov rcx, rbx
    rdmsr
    jmp rdmsr_complete

rdmsr_efer:
    ; Return virtualized EFER value
    mov rax, [guest_efer_low]
    mov rdx, [guest_efer_high]
    jmp rdmsr_complete

rdmsr_tsc:
    ; Return offset TSC value for guest migration
    rdtsc
    add rax, [tsc_offset_low]
    adc rdx, [tsc_offset_high]
    jmp rdmsr_complete

rdmsr_complete:
    ; Write result to guest RAX:RDX
    mov rbx, GUEST_RAX
    vmwrite rbx, rax
    
    mov rbx, GUEST_RDX
    vmwrite rbx, rdx
    
    ; Advance RIP
    call advance_guest_rip
    jmp resume_guest

handle_wrmsr:
    ; Read guest RCX (MSR index)
    mov rax, GUEST_RCX
    vmread rbx, rax
    
    ; Read guest RAX:RDX (value to write)
    mov rax, GUEST_RAX
    vmread rsi, rax
    
    mov rax, GUEST_RDX
    vmread rdi, rax
    
    ; Dispatch based on MSR
    cmp rbx, 0xC0000080   ; EFER
    je wrmsr_efer
    
    cmp rbx, 0x1B         ; IA32_APIC_BASE
    je wrmsr_apic_base
    
    ; Default: write to physical MSR (dangerous!)
    mov rcx, rbx
    mov rax, rsi
    mov rdx, rdi
    wrmsr
    jmp wrmsr_complete

wrmsr_efer:
    ; Validate EFER value
    ; Bits that must remain 0
    mov rax, rsi
    mov rdx, rdi
    test rax, 0xFFFFF2FE  ; Check reserved bits
    jnz inject_gp_fault
    
    ; Store virtualized EFER
    mov [guest_efer_low], rax
    mov [guest_efer_high], rdx
    
    ; Sync certain bits to VMCS
    mov rbx, GUEST_IA32_EFER
    shl rdx, 32
    or rdx, rax
    vmwrite rbx, rdx
    
    jmp wrmsr_complete

wrmsr_apic_base:
    ; Update virtual APIC base address
    shl rdi, 32
    or rdi, rsi
    mov [virtual_apic_base], rdi
    
    ; Update VMCS
    mov rax, VIRTUAL_APIC_PAGE_ADDR
    and rdi, 0xFFFFF000   ; Mask to page boundary
    vmwrite rax, rdi
    
    jmp wrmsr_complete

wrmsr_complete:
    call advance_guest_rip
    jmp resume_guest

inject_gp_fault:
    ; Inject #GP(0) to guest
    mov rax, VM_ENTRY_INTR_INFO_FIELD
    mov rbx, 0x8000030D   ; Valid=1, Type=HW exception, Vector=13(#GP)
    vmwrite rax, rbx
    
    mov rax, VM_ENTRY_EXCEPTION_ERROR_CODE
    xor rbx, rbx
    vmwrite rax, rbx
    
    jmp resume_guest
```

### Device Emulation

**MMIO (Memory-Mapped I/O) Emulation:**

Device registers accessed through memory addresses cause EPT violations, allowing the hypervisor to emulate hardware:

```nasm
emulate_mmio_access:
    ; RBX = Guest physical address
    ; RCX = Exit qualification
    
    ; Determine device and register
    call lookup_mmio_device
    test rax, rax
    jz mmio_not_found
    
    ; RAX now contains device handler pointer
    mov r12, rax
    
    ; Decode the instruction to get operand info
    call decode_memory_access
    ; Returns: R13 = access size, R14 = register number
    
    ; Check if read or write
    test rcx, 2
    jnz mmio_write
    
mmio_read:
    ; Call device read handler
    mov rdi, r12          ; Device context
    mov rsi, rbx          ; Address
    mov rdx, r13          ; Size
    call [r12 + DEVICE_READ_OFFSET]
    
    ; RAX contains read value
    ; Write to guest register
    mov rbx, GUEST_RAX
    add rbx, r14
    vmwrite rbx, rax
    
    call advance_guest_rip
    jmp resume_guest

mmio_write:
    ; Get value from guest register
    mov rax, GUEST_RAX
    add rax, r14
    vmread rsi, rax
    
    ; Call device write handler
    mov rdi, r12          ; Device context
    ; RSI already contains value
    mov rdx, rbx          ; Address
    mov rcx, r13          ; Size
    call [r12 + DEVICE_WRITE_OFFSET]
    
    call advance_guest_rip
    jmp resume_guest

mmio_not_found:
    ; Access to unmapped MMIO - inject machine check
    mov rax, VM_ENTRY_INTR_INFO_FIELD
    mov rbx, 0x80000312   ; Valid=1, Type=HW exception, Vector=18(#MC)
    vmwrite rax, rbx
    jmp resume_guest
```

**I/O Port Emulation:**

```nasm
emulate_port_write:
    ; RCX = port number
    ; RDX = value written
    ; R15 = access size
    
    ; Check common ports
    cmp rcx, 0x3F8        ; COM1 data port
    je emulate_serial_write
    
    cmp rcx, 0x70         ; CMOS address
    je emulate_cmos_address
    
    cmp rcx, 0x71         ; CMOS data
    je emulate_cmos_data
    
    cmp rcx, 0xCF8        ; PCI config address
    je emulate_pci_config_addr
    
    cmp rcx, 0xCFC        ; PCI config data
    je emulate_pci_config_data
    
    ; Ignore unknown ports
    ret

emulate_serial_write:
    ; Simple UART emulation - output character
    mov rdi, rdx
    and rdi, 0xFF
    call console_putchar
    ret

emulate_cmos_address:
    ; Store CMOS register selection
    mov [cmos_register], dl
    ret

emulate_cmos_data:
    ; Write to selected CMOS register
    movzx rax, byte [cmos_register]
    and rax, 0x7F         ; Mask NMI bit
    
    cmp rax, 0x0A         ; RTC status register A
    je write_rtc_status_a
    
    ; Store in virtual CMOS
    lea rbx, [virtual_cmos]
    mov [rbx + rax], dl
    ret

write_rtc_status_a:
    ; Handle RTC periodic interrupt rate
    lea rbx, [virtual_cmos]
    mov [rbx + 0x0A], dl
    
    ; Update virtual timer if needed
    call update_virtual_rtc_timer
    ret

emulate_port_read:
    ; RCX = port number
    ; Returns: RAX = value read
    
    cmp rcx, 0x3FD        ; COM1 line status
    je read_serial_status
    
    cmp rcx, 0x71         ; CMOS data
    je read_cmos_data
    
    ; Return 0xFF for unhandled ports
    mov rax, 0xFF
    ret

read_serial_status:
    ; Return TX ready, no errors
    mov rax, 0x60
    ret

read_cmos_data:
    ; Read from selected CMOS register
    movzx rax, byte [cmos_register]
    and rax, 0x7F
    
    cmp rax, 0x0C         ; RTC status register C
    je read_rtc_status_c
    
    lea rbx, [virtual_cmos]
    movzx rax, byte [rbx + rax]
    ret

read_rtc_status_c:
    ; Clear interrupt flags on read
    lea rbx, [virtual_cmos]
    movzx rax, byte [rbx + 0x0C]
    mov byte [rbx + 0x0C], 0
    ret
```

### Hypercalls

Hypercalls allow guest software to explicitly request hypervisor services:

```nasm
handle_hypercall:
    ; Read hypercall number from guest RAX
    mov rax, GUEST_RAX
    vmread rbx, rax
    
    ; Read parameters from guest registers
    mov rax, GUEST_RBX
    vmread r12, rax       ; Parameter 1
    
    mov rax, GUEST_RCX
    vmread r13, rax       ; Parameter 2
    
    mov rax, GUEST_RDX
    vmread r14, rax       ; Parameter 3
    
    ; Dispatch hypercall
    cmp rbx, HYPERCALL_CONSOLE_WRITE
    je hcall_console_write
    
    cmp rbx, HYPERCALL_GET_TIME
    je hcall_get_time
    
    cmp rbx, HYPERCALL_YIELD_CPU
    je hcall_yield
    
    cmp rbx, HYPERCALL_MAP_SHARED_MEMORY
    je hcall_map_shared
    
    ; Unknown hypercall
    mov rax, GUEST_RAX
    mov rbx, -1           ; Error code
    vmwrite rax, rbx
    jmp hypercall_complete

hcall_console_write:
    ; R12 = guest physical address of buffer
    ; R13 = length
    
    ; Translate GPA to HPA
    mov rdi, r12
    call gpa_to_hpa
    test rax, rax
    jz hypercall_error
    
    ; Write to console
    mov rdi, rax          ; Buffer HPA
    mov rsi, r13          ; Length
    call console_write_buffer
    
    ; Return bytes written
    mov rbx, GUEST_RAX
    vmwrite rbx, rax
    jmp hypercall_complete

hcall_get_time:
    ; Return host time in nanoseconds
    rdtsc
    shl rdx, 32
    or rax, rdx
    
    ; Convert to nanoseconds (assuming 2GHz TSC)
    mov rbx, 500
    mul rbx
    
    ; Return in RAX:RDX
    mov rbx, GUEST_RAX
    vmwrite rbx, rax
    
    mov rbx, GUEST_RDX
    vmwrite rbx, rdx
    jmp hypercall_complete

hcall_yield:
    ; Guest voluntarily yields CPU
    ; Schedule next vCPU
    call schedule_next_vcpu
    jmp hypercall_complete

hcall_map_shared:
    ; R12 = guest physical address
    ; R13 = size
    ; R14 = flags
    
    ; Allocate host physical memory
    mov rdi, r13
    call allocate_host_pages
    test rax, rax
    jz hypercall_error
    
    ; Create EPT mapping
    mov rdi, r12          ; GPA
    mov rsi, rax          ; HPA
    mov rdx, r13          ; Size
    mov rcx, r14          ; Flags (permissions)
    call create_ept_mapping
    test rax, rax
    jz hypercall_error
    
    ; Return success
    mov rax, GUEST_RAX
    xor rbx, rbx
    vmwrite rax, rbx
    jmp hypercall_complete

hypercall_error:
    mov rax, GUEST_RAX
    mov rbx, -1
    vmwrite rax, rbx
    jmp hypercall_complete

hypercall_complete:
    call advance_guest_rip
    jmp resume_guest
```

### Virtual CPU Scheduling

The hypervisor must multiplex multiple vCPUs onto physical CPUs:

```nasm
; Simple round-robin scheduler
schedule_next_vcpu:
    ; Save current vCPU state (automatically in VMCS)
    
    ; Get current vCPU index
    mov rax, [current_vcpu_index]
    
    ; Find next runnable vCPU
    mov rcx, [num_vcpus]
.find_next:
    inc rax
    cmp rax, rcx
    jl .check_runnable
    xor rax, rax          ; Wrap around
    
.check_runnable:
    ; Check if vCPU is runnable
    mov rbx, rax
    imul rbx, VCPU_STRUCT_SIZE
    lea rdi, [vcpu_array + rbx]
    
    cmp byte [rdi + VCPU_STATE], VCPU_STATE_RUNNABLE
    jne .find_next
    
    ; Found runnable vCPU
    mov [current_vcpu_index], rax
    
    ; Load new VMCS
    mov rbx, [rdi + VCPU_VMCS_PHYS]
    vmptrld [rbx]
    
    ; Update virtual timer if configured
    call setup_preemption_timer
    
    ret

setup_preemption_timer:
    ; Use VMX-preemption timer for time-slicing
    mov rax, VM_EXEC_CONTROL_PIN_BASED
    vmread rbx, rax
    or rbx, (1 << 6)      ; Activate VMX-preemption timer
    vmwrite rax, rbx
    
    ; Set timer value (in TSC ticks * multiplier)
    mov rax, VMX_PREEMPTION_TIMER_VALUE
    mov rbx, [time_slice_ticks]
    vmwrite rax, rbx
    
    ret

handle_preemption_timer:
    ; Timer expired - schedule next vCPU
    call schedule_next_vcpu
    
    ; Resume new vCPU
    jmp resume_guest
```

### Nested Virtualization

Nested virtualization allows running a hypervisor inside a virtual machine, requiring the L0 hypervisor (host) to emulate VMX operations for the L1 hypervisor (guest).

**Handling Nested VMLAUNCH:**

```nasm
handle_nested_vmlaunch:
    ; L1 hypervisor executed VMLAUNCH
    ; We're in L0, need to emulate for L1
    
    ; Get L1's VMCS pointer
    mov rax, GUEST_RAX
    vmread rbx, rax
    
    ; Translate L1 GPA to L0 HPA
    mov rdi, rbx
    call gpa_to_hpa
    test rax, rax
    jz nested_vm_fail
    
    ; Read L1's VMCS (shadow VMCS)
    mov rsi, rax
    
    ; Merge L1 and L0 controls
    ; L2 guest needs restrictions from both L0 and L1
    call merge_vmcs_controls
    
    ; Set up L0 VMCS for L2 execution
    call setup_nested_vmcs
    
    ; Advance L1's RIP past VMLAUNCH
    call advance_guest_rip
    
    ; Enter L2 guest
    vmresume
    jc nested_vm_error
    jz nested_vm_error
    
nested_vm_fail:
    ; Inject VM instruction error to L1
    mov rax, GUEST_RFLAGS
    vmread rbx, rax
    or rbx, 0x41          ; CF=1, ZF=1
    vmwrite rax, rbx
    
    call advance_guest_rip
    jmp resume_guest

merge_vmcs_controls:
    ; Combine L0 and L1 VM-execution controls
    ; Result must satisfy both hypervisors' requirements
    
    ; Read L1's CPU-based controls
    mov rsi, [shadow_vmcs]
    mov eax, [rsi + CPU_BASED_VM_EXEC_CONTROL_OFFSET]
    
    ; Read L0's required controls
    mov ebx, [l0_cpu_controls]
    
    ; Merge: (L1_controls | L0_must1) & ~L0_must0
    or eax, [l0_cpu_controls_must1]
    not dword [l0_cpu_controls_must0]
    and eax, [l0_cpu_controls_must0]
    
    ; Write to current VMCS
    mov rbx, CPU_BASED_VM_EXEC_CONTROL
    vmwrite rbx, rax
    
    ; Repeat for other control fields...
    ret
```

### Performance Optimization

**Reducing VM Exits:**

```nasm
; Use APIC virtualization to handle guest APIC access in hardware
setup_apic_virtualization:
    ; Enable APIC access virtualization
    mov rax, SECONDARY_VM_EXEC_CONTROL
    vmread rbx, rax
    or rbx, (1 << 0)      ; Virtualize APIC accesses
    or rbx, (1 << 4)      ; Virtual-interrupt delivery
    or rbx, (1 << 7)      ; Virtualize x2APIC mode
    or rbx, (1 << 8)      ; APIC-register virtualization
    vmwrite rax, rbx
    
    ; Set virtual-APIC page
    mov rax, VIRTUAL_APIC_PAGE_ADDR
    mov rbx, [vapic_page_phys]
    vmwrite rax, rbx
    
    ; Most APIC reads/writes handled by hardware
    ret

; Use unrestricted guest to avoid real-mode emulation
enable_unrestricted_guest:
    ; Requires EPT
    mov rax, SECONDARY_VM_EXEC_CONTROL
    vmread rbx, rax
    test rbx, (1 << 1)    ; Check EPT enabled
    jz .no_unrestricted
    
    ; Enable unrestricted guest
    or rbx, (1 << 7)
    vmwrite rax, rbx
    
    ; Now guest can execute in real mode without exits
.no_unrestricted:
    ret
```

**Large Page EPT Mappings:**

Using 2MB or 1GB pages in EPT reduces TLB pressure and page walk overhead:

```nasm
setup_large_page_ept:
    ; Map guest memory using 2MB pages where possible
    mov rcx, [guest_memory_size]
    shr rcx, 21           ; Divide by 2MB
    
    xor r12, r12          ; Current GPA
    xor r13, r13          ; PD entry index
    
.map_loop:
    ; Allocate 2MB host physical page
    mov rdi, 0x200000
    call allocate_aligned_pages
    test rax, rax
    jz .fallback_4kb
    
    ; Create PD entry with large page bit
    mov rbx, rax
    or rbx, 0x87          ; R=1, W=1, X=1, PS=1 (large page)
    or rbx, (6 << 3)      ; WB memory type
    
    ; Write to EPT PD
    lea rdi, [ept_pd]
    mov [rdi + r13*8], rbx
    
    ; Next entry
    add r12, 0x200000
    inc r13
    loop .map_loop
    
    ret

.fallback_4kb:
    ; Fall back to 4KB pages if 2MB allocation fails
    ; (Implementation omitted for brevity)
    ret
```

**Key Points:**

- VMX hardware extensions eliminate the need for binary translation and shadow paging used in software virtualization
- The VMCS structure maintains complete guest and host processor state, enabling efficient context switching
- EPT provides two-level address translation (GVA→GPA→HPA) entirely in hardware, dramatically reducing memory virtualization overhead
- VM exits transfer control from guest to hypervisor for events like I/O, privileged instructions, and EPT violations
- VPID tags TLB entries to avoid flushing on VM transitions, improving performance significantly
- Device emulation through MMIO and I/O port interception allows presenting virtual hardware to guests
- Hypercalls provide a direct guest-to-hypervisor communication channel for paravirtualized services
- Nested virtualization requires the outer hypervisor to emulate VMX operations for inner hypervisors
- Performance optimization focuses on reducing VM exits through hardware virtualization features and efficient memory mapping

**Related topics:** IOMMU/VT-d (device assignment and DMA remapping), SR-IOV (hardware virtualization for I/O devices), Memory overcommitment techniques (ballooning, page sharing, compression), Live migration mechanisms, Virtual machine introspection (VMI) for security monitoring

---

# Hardware-Specific Features

x86 processors expose specialized hardware features through dedicated instructions and registers that provide CPU identification, performance monitoring, timing, and cryptographic randomness. These features are essential for system programming, optimization, and security.

## CPUID Instruction

The CPUID instruction provides detailed information about the processor's capabilities, features, vendor, and characteristics. It uses EAX as the function input and returns data across EAX, EBX, ECX, and EDX registers.

### Basic CPUID Usage

```asm
; Query maximum supported CPUID function
get_max_cpuid:
    push ebx
    xor eax, eax        ; Function 0
    cpuid               ; Returns max function in EAX
    ; EBX:EDX:ECX contains vendor string
    pop ebx
    ret

; Check specific CPU feature
check_sse_support:
    push ebx
    mov eax, 1          ; Processor info and features
    cpuid
    test edx, (1 << 25) ; SSE bit in EDX
    setnz al            ; AL = 1 if SSE supported
    pop ebx
    ret
```

### Vendor Identification

```asm
; Get CPU vendor string (12 characters)
get_cpu_vendor:
    push ebp
    mov ebp, esp
    push ebx
    push edi
    
    mov edi, [ebp + 8]  ; Buffer pointer (12 bytes minimum)
    
    xor eax, eax
    cpuid
    
    ; EBX:EDX:ECX contains vendor string
    mov [edi], ebx
    mov [edi + 4], edx
    mov [edi + 8], ecx
    
    pop edi
    pop ebx
    pop ebp
    ret

; Example usage and vendor detection
detect_vendor:
    sub esp, 16
    lea eax, [esp]
    push eax
    call get_cpu_vendor
    add esp, 4
    
    ; Check for "GenuineIntel"
    mov eax, [esp]
    cmp eax, 0x756E6547  ; "Genu"
    jne .not_intel
    mov eax, [esp + 4]
    cmp eax, 0x49656E69  ; "ineI"
    jne .not_intel
    mov eax, [esp + 8]
    cmp eax, 0x6C65746E  ; "ntel"
    jne .not_intel
    
    mov eax, 1          ; Intel detected
    jmp .done
    
.not_intel:
    ; Check for "AuthenticAMD"
    mov eax, [esp]
    cmp eax, 0x68747541  ; "Auth"
    jne .unknown
    mov eax, [esp + 4]
    cmp eax, 0x69746E65  ; "enti"
    jne .unknown
    mov eax, [esp + 8]
    cmp eax, 0x444D4163  ; "cAMD"
    jne .unknown
    
    mov eax, 2          ; AMD detected
    jmp .done
    
.unknown:
    xor eax, eax        ; Unknown vendor
    
.done:
    add esp, 16
    ret
```

### Feature Detection

```asm
; Comprehensive feature detection
detect_cpu_features:
    push ebx
    push esi
    push edi
    
    mov edi, [esp + 16] ; Feature flags structure pointer
    
    ; Get basic features (function 1)
    mov eax, 1
    cpuid
    mov [edi], edx      ; Store EDX features
    mov [edi + 4], ecx  ; Store ECX features
    
    ; Store processor signature
    mov [edi + 8], eax
    
    ; Get extended features (function 7, sub-leaf 0)
    mov eax, 7
    xor ecx, ecx
    cpuid
    mov [edi + 12], ebx ; Extended features
    mov [edi + 16], ecx ; Extended features 2
    
    pop edi
    pop esi
    pop ebx
    ret

; Check specific feature flags
check_feature_sse2:
    mov eax, 1
    cpuid
    test edx, (1 << 26)
    setnz al
    ret

check_feature_avx:
    mov eax, 1
    cpuid
    test ecx, (1 << 28)
    setnz al
    ret

check_feature_avx2:
    mov eax, 7
    xor ecx, ecx
    cpuid
    test ebx, (1 << 5)
    setnz al
    ret

check_feature_aes:
    mov eax, 1
    cpuid
    test ecx, (1 << 25)
    setnz al
    ret
```

### Cache Topology Information

```asm
; Get cache information (Intel-specific)
get_cache_info:
    push ebx
    push esi
    push edi
    mov edi, [esp + 16] ; Buffer for cache info
    
    mov eax, 4          ; Cache parameters leaf
    xor ecx, ecx        ; Start with cache level 0
    
.loop:
    cpuid
    
    ; Check if valid cache level
    mov esi, eax
    and esi, 0x1F
    jz .done            ; Cache type = 0 means no more caches
    
    ; Store cache information
    mov [edi], eax      ; Cache type and level
    mov [edi + 4], ebx  ; Line size, partitions, associativity
    mov [edi + 8], ecx  ; Number of sets
    mov [edi + 12], edx ; Flags
    
    add edi, 16
    inc ecx             ; Next cache level
    mov eax, 4
    jmp .loop
    
.done:
    pop edi
    pop esi
    pop ebx
    ret

; Decode cache size from CPUID results
calculate_cache_size:
    ; Input: EAX = cache descriptor from CPUID.04H
    ;        EBX = line size info
    ;        ECX = number of sets
    push ebx
    push edx
    
    ; Ways = ((EBX >> 22) & 0x3FF) + 1
    mov eax, ebx
    shr eax, 22
    and eax, 0x3FF
    inc eax
    mov edx, eax        ; Save ways
    
    ; Partitions = ((EBX >> 12) & 0x3FF) + 1
    mov eax, ebx
    shr eax, 12
    and eax, 0x3FF
    inc eax
    imul edx, eax       ; ways * partitions
    
    ; Line size = (EBX & 0xFFF) + 1
    mov eax, ebx
    and eax, 0xFFF
    inc eax
    imul edx, eax       ; * line_size
    
    ; Sets = ECX + 1
    mov eax, ecx
    inc eax
    imul eax, edx       ; Total size in bytes
    
    pop edx
    pop ebx
    ret
```

### Processor Signature and Stepping

```asm
; Get processor family, model, and stepping
get_processor_signature:
    push ebx
    
    mov eax, 1
    cpuid
    
    ; EAX contains signature
    ; Bits 3-0: Stepping
    ; Bits 7-4: Model
    ; Bits 11-8: Family
    ; Bits 13-12: Processor Type
    ; Bits 19-16: Extended Model
    ; Bits 27-20: Extended Family
    
    mov ebx, eax
    
    ; Extract stepping
    and al, 0x0F
    mov [processor_stepping], al
    
    ; Extract base model
    mov eax, ebx
    shr eax, 4
    and al, 0x0F
    mov [processor_model], al
    
    ; Extract base family
    mov eax, ebx
    shr eax, 8
    and al, 0x0F
    mov [processor_family], al
    
    ; If family = 0x0F, add extended family
    cmp al, 0x0F
    jne .check_model
    mov eax, ebx
    shr eax, 20
    and al, 0xFF
    add [processor_family], al
    
.check_model:
    ; If family = 0x06 or 0x0F, add extended model
    mov al, [processor_family]
    cmp al, 0x06
    je .add_extended_model
    cmp al, 0x0F
    jne .done
    
.add_extended_model:
    mov eax, ebx
    shr eax, 16
    and al, 0x0F
    shl al, 4
    add [processor_model], al
    
.done:
    pop ebx
    ret

processor_stepping: db 0
processor_model: db 0
processor_family: db 0
```

### Extended CPUID Functions

```asm
; Get maximum extended CPUID function
get_max_extended_cpuid:
    push ebx
    mov eax, 0x80000000
    cpuid
    ; EAX contains max extended function
    pop ebx
    ret

; Get processor brand string (48 bytes)
get_brand_string:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov edi, [ebp + 8]  ; Buffer pointer (48 bytes)
    
    ; Function 0x80000002 - First 16 bytes
    mov eax, 0x80000002
    cpuid
    mov [edi], eax
    mov [edi + 4], ebx
    mov [edi + 8], ecx
    mov [edi + 12], edx
    
    ; Function 0x80000003 - Next 16 bytes
    mov eax, 0x80000003
    cpuid
    mov [edi + 16], eax
    mov [edi + 20], ebx
    mov [edi + 24], ecx
    mov [edi + 28], edx
    
    ; Function 0x80000004 - Last 16 bytes
    mov eax, 0x80000004
    cpuid
    mov [edi + 32], eax
    mov [edi + 36], ebx
    mov [edi + 40], ecx
    mov [edi + 44], edx
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Get physical and virtual address sizes
get_address_sizes:
    push ebx
    
    mov eax, 0x80000008
    cpuid
    
    ; AL = physical address bits
    ; AH = virtual address bits
    mov [physical_addr_bits], al
    mov [virtual_addr_bits], ah
    
    pop ebx
    ret

physical_addr_bits: db 0
virtual_addr_bits: db 0
```

## Model-Specific Registers (MSRs)

MSRs provide access to processor-specific features, performance counters, and configuration options. They require privilege level 0 (kernel mode) to access.

### Reading and Writing MSRs

```asm
; Read MSR (requires CPL 0)
; Input: ECX = MSR address
; Output: EDX:EAX = MSR value
read_msr_generic:
    rdmsr               ; Read MSR[ECX] into EDX:EAX
    ret

; Write MSR (requires CPL 0)
; Input: ECX = MSR address
;        EDX:EAX = value to write
write_msr_generic:
    wrmsr               ; Write EDX:EAX to MSR[ECX]
    ret

; Safe MSR read with error checking
safe_read_msr:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    
    mov ecx, [ebp + 8]  ; MSR address
    
    ; Check if MSR is supported
    ; [Inference] This would require checking CPUID or catching exceptions
    
    rdmsr
    
    ; Return value in EDX:EAX
    pop ecx
    pop ebx
    pop ebp
    ret
```

### Performance Monitoring MSRs

```asm
; Intel performance counters (IA32_PMCx)
%define IA32_PMC0           0x000000C1
%define IA32_PMC1           0x000000C2
%define IA32_PERFEVTSEL0    0x00000186
%define IA32_PERFEVTSEL1    0x00000187

; Setup performance counter to count instructions retired
setup_instruction_counter:
    push ebx
    push ecx
    push edx
    
    ; Disable counter first
    mov ecx, IA32_PERFEVTSEL0
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Reset counter
    mov ecx, IA32_PMC0
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Configure counter
    ; Event 0xC0 (instructions retired)
    ; UMASK 0x00
    ; USR=1 (count user mode)
    ; OS=1 (count OS mode)
    ; EN=1 (enable)
    mov ecx, IA32_PERFEVTSEL0
    mov eax, 0x004300C0 ; EN | USR | OS | Event
    xor edx, edx
    wrmsr
    
    pop edx
    pop ecx
    pop ebx
    ret

; Read instruction counter
read_instruction_counter:
    push ecx
    mov ecx, IA32_PMC0
    rdmsr               ; Returns count in EDX:EAX
    pop ecx
    ret

; Count cache misses
setup_cache_miss_counter:
    push ebx
    push ecx
    push edx
    
    mov ecx, IA32_PERFEVTSEL1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    mov ecx, IA32_PMC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Event 0x24 (L2 cache miss)
    ; Exact event codes vary by processor
    mov ecx, IA32_PERFEVTSEL1
    mov eax, 0x00430024
    xor edx, edx
    wrmsr
    
    pop edx
    pop ecx
    pop ebx
    ret
```

### Power Management MSRs

```asm
; Common power management MSRs
%define IA32_PERF_STATUS    0x00000198
%define IA32_PERF_CTL       0x00000199
%define IA32_THERM_STATUS   0x0000019C
%define IA32_MISC_ENABLE    0x000001A0
%define IA32_ENERGY_PERF_BIAS 0x000001B0

; Read current P-state
read_pstate:
    push ecx
    mov ecx, IA32_PERF_STATUS
    rdmsr
    shr eax, 8
    and eax, 0xFF       ; Current P-state in AL
    pop ecx
    ret

; Request P-state change
set_pstate:
    push ebp
    mov ebp, esp
    push ecx
    push edx
    
    mov eax, [ebp + 8]  ; Desired P-state
    and eax, 0xFF
    shl eax, 8
    
    mov ecx, IA32_PERF_CTL
    xor edx, edx
    wrmsr
    
    pop edx
    pop ecx
    pop ebp
    ret

; Read thermal status
read_thermal_status:
    push ecx
    mov ecx, IA32_THERM_STATUS
    rdmsr
    ; Bit 31: Thermal status
    ; Bit 30: Thermal status log
    ; Bits 22-16: Digital readout (temperature)
    pop ecx
    ret

; Enable turbo boost (Intel)
enable_turbo:
    push ecx
    push edx
    
    mov ecx, IA32_MISC_ENABLE
    rdmsr
    and eax, ~(1 << 38) ; Clear IDA disable bit
    wrmsr
    
    pop edx
    pop ecx
    ret

; Set energy performance bias
set_energy_bias:
    push ebp
    mov ebp, esp
    push ecx
    push edx
    
    ; 0 = performance, 15 = energy efficiency
    mov eax, [ebp + 8]
    and eax, 0x0F
    
    mov ecx, IA32_ENERGY_PERF_BIAS
    xor edx, edx
    wrmsr
    
    pop edx
    pop ecx
    pop ebp
    ret
```

### Memory Type Range Registers (MTRRs)

```asm
; MTRR MSR addresses
%define IA32_MTRRCAP        0x000000FE
%define IA32_MTRR_DEF_TYPE  0x000002FF
%define IA32_MTRR_PHYSBASE0 0x00000200
%define IA32_MTRR_PHYSMASK0 0x00000201

; Memory types
%define MTRR_TYPE_UC        0x00  ; Uncacheable
%define MTRR_TYPE_WC        0x01  ; Write Combining
%define MTRR_TYPE_WT        0x04  ; Write Through
%define MTRR_TYPE_WP        0x05  ; Write Protected
%define MTRR_TYPE_WB        0x06  ; Write Back

; Get MTRR capabilities
get_mtrr_cap:
    push ecx
    mov ecx, IA32_MTRRCAP
    rdmsr
    ; AL = number of variable MTRRs
    ; Bit 8 = WC supported
    ; Bit 10 = Fixed range MTRRs supported
    pop ecx
    ret

; Setup MTRR for memory region
setup_mtrr:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    
    ; Parameters: base address, size, type, MTRR index
    mov eax, [ebp + 8]  ; Base address (must be aligned)
    mov ebx, [ebp + 12] ; Size in bytes
    mov dl, [ebp + 16]  ; Memory type
    mov dh, [ebp + 20]  ; MTRR register index
    
    ; Disable MTRRs during modification
    mov ecx, IA32_MTRR_DEF_TYPE
    push eax
    push edx
    rdmsr
    and eax, ~(1 << 11) ; Clear enable bit
    wrmsr
    pop edx
    pop eax
    
    ; Calculate base register address
    movzx ecx, dh
    shl ecx, 1
    add ecx, IA32_MTRR_PHYSBASE0
    
    ; Set base and type
    or eax, edx         ; Combine base with type
    xor edx, edx
    wrmsr
    
    ; Set mask
    inc ecx
    mov eax, ebx
    neg eax             ; Create mask from size
    or eax, (1 << 11)   ; Set valid bit
    xor edx, edx
    wrmsr
    
    ; Re-enable MTRRs
    mov ecx, IA32_MTRR_DEF_TYPE
    rdmsr
    or eax, (1 << 11)
    wrmsr
    
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret
```

### Feature Control MSRs

```asm
; IA32_FEATURE_CONTROL MSR
%define IA32_FEATURE_CONTROL 0x0000003A

; Enable VMX (Virtualization)
enable_vmx:
    push ecx
    push edx
    
    mov ecx, IA32_FEATURE_CONTROL
    rdmsr
    
    ; Check if locked
    test eax, 1
    jnz .already_locked
    
    ; Enable VMX and lock
    or eax, 0x05        ; Bit 0: Lock, Bit 2: Enable VMX
    wrmsr
    
.already_locked:
    pop edx
    pop ecx
    ret

; IA32_EFER (Extended Feature Enable Register)
%define IA32_EFER           0xC0000080

; Enable long mode (64-bit)
enable_long_mode:
    push ecx
    push edx
    
    mov ecx, IA32_EFER
    rdmsr
    or eax, (1 << 8)    ; Set LME bit
    wrmsr
    
    pop edx
    pop ecx
    ret

; Enable NX (No-Execute) bit
enable_nx:
    push ecx
    push edx
    
    mov ecx, IA32_EFER
    rdmsr
    or eax, (1 << 11)   ; Set NXE bit
    wrmsr
    
    pop edx
    pop ecx
    ret
```

## Time Stamp Counter (TSC)

The TSC is a 64-bit counter that increments at a constant rate, providing high-resolution timing for performance measurement and profiling.

### Basic TSC Operations

```asm
; Read TSC (available to user mode)
read_tsc:
    rdtsc               ; Returns count in EDX:EAX
    ret

; Read TSC with serialization (more accurate timing)
read_tsc_serialized:
    push ebx
    push ecx
    
    cpuid               ; Serializing instruction
    rdtsc               ; Read TSC
    
    pop ecx
    pop ebx
    ret

; More precise serialization with RDTSCP (if available)
read_tsc_ordered:
    rdtscp              ; Read TSC + processor ID in ECX
    ret                 ; Returns TSC in EDX:EAX

; Check if RDTSCP is available
check_rdtscp_support:
    push ebx
    push ecx
    
    mov eax, 0x80000001
    cpuid
    test edx, (1 << 27) ; RDTSCP bit
    setnz al
    
    pop ecx
    pop ebx
    ret
```

### High-Precision Timing

```asm
; Measure code execution time
measure_execution_time:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    ; Serialize and read start time
    xor eax, eax
    cpuid
    rdtsc
    mov esi, eax        ; Save low 32 bits
    mov edi, edx        ; Save high 32 bits
    
    ; Execute code to measure
    call dword [ebp + 8] ; Function pointer parameter
    
    ; Serialize and read end time
    push eax            ; Save return value
    push edx
    xor eax, eax
    cpuid
    rdtsc
    pop edx
    
    ; Calculate elapsed cycles
    sub eax, esi        ; Subtract start low
    sbb edx, edi        ; Subtract start high with borrow
    
    pop edx             ; Restore original return value
    ; Elapsed cycles now in EDX:EAX
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret

; Benchmark with multiple iterations
benchmark_function:
    push ebp
    mov ebp, esp
    sub esp, 16
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Function pointer
    mov edi, [ebp + 12] ; Number of iterations
    
    xor eax, eax
    mov [ebp - 8], eax  ; Clear min cycles
    mov [ebp - 4], eax
    
.loop:
    ; Warm-up iteration
    call esi
    
    ; Measure this iteration
    xor eax, eax
    cpuid
    rdtsc
    mov [ebp - 16], eax
    mov [ebp - 12], edx
    
    call esi
    
    xor eax, eax
    cpuid
    rdtsc
    
    sub eax, [ebp - 16]
    sbb edx, [ebp - 12]
    
    ; Update minimum if this is smaller
    cmp edx, [ebp - 4]
    ja .next
    jb .update_min
    cmp eax, [ebp - 8]
    jae .next
    
.update_min:
    mov [ebp - 8], eax
    mov [ebp - 4], edx
    
.next:
    dec edi
    jnz .loop
    
    ; Return minimum cycles in EDX:EAX
    mov eax, [ebp - 8]
    mov edx, [ebp - 4]
    
    pop edi
    pop esi
    pop ebx
    add esp, 16
    pop ebp
    ret
```

### TSC Frequency Calibration

```asm
; Calibrate TSC frequency using PIT
calibrate_tsc_frequency:
    push ebx
    push ecx
    push esi
    push edi
    
    ; Program PIT channel 2 for one-shot
    mov al, 0xB0        ; Channel 2, one-shot
    out 0x43, al
    
    ; Set count for ~10ms (11932 at 1.193182 MHz)
    mov al, 0x9C
    out 0x42, al
    mov al, 0x2E
    out 0x42, al
    
    ; Start PIT
    in al, 0x61
    or al, 1
    out 0x61, al
    
    ; Read TSC start
    rdtsc
    mov esi, eax
    mov edi, edx
    
    ; Wait for PIT to complete
.wait:
    in al, 0x61
    test al, 0x20
    jz .wait
    
    ; Read TSC end
    rdtsc
    
    ; Calculate elapsed cycles
    sub eax, esi
    sbb edx, edi
    
    ; Scale to cycles per second
    ; [Inference] Multiply by 100 for ~10ms measurement
    mov ecx, 100
    mul ecx             ; EDX:EAX = cycles in 10ms * 100
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret                 ; Returns approximate TSC frequency in Hz

; Calculate nanoseconds from TSC cycles
tsc_to_nanoseconds:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    
    ; Input: EDX:EAX = TSC cycles
    ;        [ebp+8] = TSC frequency in Hz
    
    ; Multiply by 1000000000 and divide by frequency
    mov ebx, [ebp + 8]  ; Frequency
    
    ; Use 64-bit arithmetic
    mov ecx, 1000000000
    mul ecx             ; EDX:EAX = cycles * 1e9
    
    div ebx             ; EAX = nanoseconds
    
    pop ecx
    pop ebx
    pop ebp
    ret
```

### TSC-Based Delays

```asm
; Delay for specified number of TSC cycles
tsc_delay_cycles:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    ; Get target cycles from parameter
    mov esi, [ebp + 8]  ; Low 32 bits
    mov edi, [ebp + 12] ; High 32 bits
    
    ; Read start time
    rdtsc
    add esi, eax        ; Calculate end time
    adc edi, edx
    
.wait:
    rdtsc
    cmp edx, edi
    jb .wait
    ja .done
    cmp eax, esi
    jb .wait
    
.done:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret

; Delay for microseconds (requires TSC frequency)
tsc_delay_us:
    push ebp
    mov ebp, esp
    push ebx
    push edx
    
    mov eax, [ebp + 8]  ; Microseconds
    mov ebx, [tsc_freq_mhz] ; TSC frequency in MHz
    mul ebx             ; EAX = cycles needed
    
    push 0              ; High 32 bits
    push eax            ; Low 32 bits
    call tsc_delay_cycles
    add esp, 8
    
    pop edx
    pop ebx
    pop ebp
    ret

tsc_freq_mhz: dd 2400  ; Example: 2.4 GHz
```

### TSC Invariance and Synchronization

```asm
; Check if TSC is invariant (constant rate)
check_tsc_invariant:
    push ebx
    push ecx
    
    mov eax, 0x80000007
    cpuid
    test edx, (1 << 8)  ; Invariant TSC bit
    setnz al
    
    pop ecx
    pop ebx
    ret

; Check TSC deadline timer support (for precise interrupts)
check_tsc_deadline:
    push ebx
    push ecx
    
    mov eax, 1
    cpuid
    test ecx, (1 << 24) ; TSC-Deadline bit
    setnz al
    
    pop ecx
    pop ebx
    ret

; Setup TSC deadline timer
setup_tsc_deadline:
    push ebp
    mov ebp, esp
    push ecx
    push edx
    
    ; Set deadline in IA32_TSC_DEADLINE MSR (0x6E0)
    mov ecx, 0x6E0
    mov eax, [ebp + 8]  ; Low 32 bits of deadline
    mov edx, [ebp + 12] ; High 32 bits of deadline
    wrmsr
    
    pop edx
    pop ecx
    pop ebp
    ret
```

## RDRAND and RDSEED

RDRAND and RDSEED provide hardware-based random number generation for cryptographic and security applications. [Inference] RDSEED provides higher-quality randomness directly from the entropy source, while RDRAND uses a DRBG (Deterministic Random Bit Generator).

### RDRAND Usage

```asm
; Check RDRAND support
check_rdrand_support:
    push ebx
    push ecx
    
    mov eax, 1
    cpuid
    test ecx, (1 << 30) ; RDRAND bit
    setnz al
    
    pop ecx
    pop ebx
    ret

; Generate 32-bit random number
rdrand32:
    rdrand eax
    jnc rdrand32        ; Retry if CF=0 (underflow)
    ret

; Generate 64-bit random number (32-bit mode)
rdrand64:
    push ebx
    
.retry:
    rdrand eax
    jnc .retry
    mov ebx, eax
    
    rdrand eax
    jnc .retry
    mov edx, eax
    mov eax, ebx
    
    pop ebx
    ret

; Generate random number with retry limit
rdrand32_with_limit:
    push ebp
    mov ebp, esp
    push ecx
    
    mov ecx, [ebp + 8]  ; Maximum retry count
    
.retry:
    rdrand eax
    jc .success
    loop .retry
    
    ; Failed to get random number
    xor eax, eax
    stc                 ; Set carry to indicate error
    jmp .done
    
.success:
    clc                 ; Clear carry to indicate success
    
.done:
    pop ecx
    pop ebp
    ret

; Fill buffer with random data
rdrand_fill_buffer:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edi
    
    mov edi, [ebp + 8]  ; Buffer pointer
    mov ecx, [ebp + 12] ; Size in bytes
    
.loop:
    cmp ecx, 4
    jb .handle_remainder
    
    ; Generate 32-bit random value
    rdrand eax
    jnc .loop           ; Retry on failure
    
    mov [edi], eax
    add edi, 4
    sub ecx, 4
    jmp .loop
    
.handle_remainder:
    test ecx, ecx
    jz .done
    
    ; Generate final random value
    rdrand eax
    jnc .handle_remainder
    
    ; Copy remaining bytes
.copy_bytes:
    mov [edi], al
    shr eax, 8
    inc edi
    dec ecx
    jnz .copy_bytes
    
.done:
    pop edi
    pop ecx
    pop ebx
    pop ebp
    ret
```

### RDSEED Usage

```asm
; Check RDSEED support
check_rdseed_support:
    push ebx
    push ecx
    
    mov eax, 7
    xor ecx, ecx
    cpuid
    test ebx, (1 << 18) ; RDSEED bit
    setnz al
    
    pop ecx
    pop ebx
    ret

; Generate seed value (higher quality randomness)
rdseed32:
    rdseed eax
    jnc rdseed32        ; Retry if CF=0
    ret

; Generate seed with retry limit and backoff
rdseed32_robust:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    
    mov ecx, 10         ; Initial retry count
    
.retry:
    rdseed eax
    jc .success
    
    ; Exponential backoff
    push ecx
    mov ecx, 10
.pause_loop:
    pause
    loop .pause_loop
    pop ecx
    
    dec ecx
    jnz .retry
    
    ; If RDSEED fails, fall back to RDRAND
    mov ecx, 10
.fallback:
    rdrand eax
    jc .success
    loop .fallback
    
    ; Complete failure
    xor eax, eax
    stc
    jmp .done
    
.success:
    clc
    
.done:
    pop ecx
    pop ebx
    pop ebp
    ret

; Generate 64-bit seed (32-bit mode)
rdseed64:
    push ebx
    push ecx
    
    mov ecx, 10
.retry_low:
    rdseed eax
    jc .got_low
    pause
    loop .retry_low
    jmp .error
    
.got_low:
    mov ebx, eax
    mov ecx, 10
    
.retry_high:
    rdseed eax
    jc .got_high
    pause
    loop .retry_high
    jmp .error
    
.got_high:
    mov edx, eax
    mov eax, ebx
    clc
    jmp .done
    
.error:
    xor eax, eax
    xor edx, edx
    stc
    
.done:
    pop ecx
    pop ebx
    ret
```

### Seeding a PRNG

```asm
; Seed a simple PRNG state with hardware randomness
seed_prng:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edi
    
    mov edi, [ebp + 8]  ; PRNG state structure pointer
    
    ; Try RDSEED first for higher quality
    call check_rdseed_support
    test al, al
    jz .use_rdrand
    
    ; Use RDSEED
    rdseed eax
    jnc .use_rdrand     ; Fallback if failed
    mov [edi], eax
    
    rdseed eax
    jnc .use_rdrand
    mov [edi + 4], eax
    
    rdseed eax
    jnc .use_rdrand
    mov [edi + 8], eax
    
    rdseed eax
    jnc .use_rdrand
    mov [edi + 12], eax
    
    jmp .done
    
.use_rdrand:
    ; Use RDRAND as fallback
    rdrand eax
    mov [edi], eax
    
    rdrand eax
    mov [edi + 4], eax
    
    rdrand eax
    mov [edi + 8], eax
    
    rdrand eax
    mov [edi + 12], eax
    
.done:
    pop edi
    pop ecx
    pop ebx
    pop ebp
    ret
```

### Cryptographic Key Generation

```asm
; Generate AES-128 key (16 bytes)
generate_aes128_key:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edi
    
    mov edi, [ebp + 8]  ; Buffer for key (16 bytes)
    
    ; Use RDSEED for key material if available
    call check_rdseed_support
    test al, al
    jz .use_rdrand
    
    ; Generate key with RDSEED
    mov ecx, 4          ; 4 * 32 bits = 128 bits
.rdseed_loop:
    push ecx
    mov ecx, 10
.retry:
    rdseed eax
    jc .got_value
    pause
    loop .retry
    
    ; Fallback to RDRAND on failure
    pop ecx
    jmp .use_rdrand
    
.got_value:
    pop ecx
    stosd               ; Store EAX and increment EDI
    loop .rdseed_loop
    jmp .done
    
.use_rdrand:
    mov ecx, 4
.rdrand_loop:
    rdrand eax
    stosd
    loop .rdrand_loop
    
.done:
    pop edi
    pop ecx
    pop ebx
    pop ebp
    ret

; Generate random IV (Initialization Vector)
generate_random_iv:
    push ebp
    mov ebp, esp
    push ecx
    push edi
    
    mov edi, [ebp + 8]  ; Buffer pointer
    mov ecx, [ebp + 12] ; Size in bytes
    
    ; Convert to dword count
    add ecx, 3
    shr ecx, 2
    
.loop:
    rdrand eax
    stosd
    loop .loop
    
    pop edi
    pop ecx
    pop ebp
    ret
```

### Secure Random Number Generation with Mixing

```asm
; Generate random number with entropy mixing
generate_mixed_random:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    
    ; Combine multiple entropy sources
    
    ; 1. RDSEED (if available)
    call check_rdseed_support
    test al, al
    jz .skip_rdseed
    
    rdseed eax
    jnc .skip_rdseed
    mov ebx, eax
    jmp .add_rdrand
    
.skip_rdseed:
    xor ebx, ebx
    
.add_rdrand:
    ; 2. RDRAND
    rdrand eax
    xor ebx, eax
    
    ; 3. TSC for additional entropy
    rdtsc
    xor ebx, eax
    rol ebx, 7
    xor ebx, edx
    
    ; 4. Mix with processor ID from RDTSCP
    call check_rdtscp_support
    test al, al
    jz .no_rdtscp
    
    rdtscp
    xor ebx, ecx
    
.no_rdtscp:
    ; Return mixed random value
    mov eax, ebx
    
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret
```

### Random Number Quality Testing

```asm
; Test RDRAND availability and basic functionality
test_rdrand_quality:
    push ebp
    mov ebp, esp
    sub esp, 16
    push ebx
    push ecx
    push esi
    push edi
    
    ; Check support
    call check_rdrand_support
    test al, al
    jz .not_supported
    
    ; Generate multiple values and check for duplicates
    mov ecx, 1000       ; Generate 1000 values
    xor esi, esi        ; Duplicate count
    
.test_loop:
    rdrand eax
    jnc .test_loop      ; Retry on underflow
    
    mov [ebp - 4], eax
    
    rdrand eax
    jnc .test_loop
    
    ; Simple duplicate check
    cmp eax, [ebp - 4]
    jne .no_duplicate
    inc esi
    
.no_duplicate:
    loop .test_loop
    
    ; Calculate quality metric
    ; [Inference] Fewer duplicates indicates better randomness
    mov eax, esi
    mov ebx, 1000
    xor edx, edx
    div ebx             ; Duplicate percentage
    
    ; Return quality score (0 = perfect, higher = worse)
    jmp .done
    
.not_supported:
    mov eax, -1
    
.done:
    pop edi
    pop esi
    pop ecx
    pop ebx
    add esp, 16
    pop ebp
    ret
```

### Secure Memory Wiping with Random Data

```asm
; Overwrite memory with random data before freeing
secure_wipe_memory:
    push ebp
    mov ebp, esp
    push ecx
    push edi
    
    mov edi, [ebp + 8]  ; Memory address
    mov ecx, [ebp + 12] ; Size in bytes
    
    ; First pass: random data
.random_pass:
    cmp ecx, 4
    jb .handle_remainder
    
    rdrand eax
    stosd
    sub ecx, 4
    jmp .random_pass
    
.handle_remainder:
    test ecx, ecx
    jz .zero_pass
    
    rdrand eax
.copy_remainder:
    stosb
    shr eax, 8
    loop .copy_remainder
    
    ; Second pass: zero everything
.zero_pass:
    mov edi, [ebp + 8]
    mov ecx, [ebp + 12]
    xor eax, eax
    rep stosb
    
    pop edi
    pop ecx
    pop ebp
    ret
```

### Performance Monitoring for Random Generation

```asm
; Measure RDRAND throughput
benchmark_rdrand:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    mov ecx, [ebp + 8]  ; Number of iterations
    
    ; Read start TSC
    rdtsc
    mov esi, eax
    mov edi, edx
    
    ; Generate random numbers
.loop:
    rdrand eax
    loop .loop
    
    ; Read end TSC
    rdtsc
    
    ; Calculate elapsed cycles
    sub eax, esi
    sbb edx, edi
    
    ; Return cycles in EDX:EAX
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret

; Compare RDRAND vs RDSEED performance
compare_random_performance:
    push ebp
    mov ebp, esp
    sub esp, 16
    push ebx
    push ecx
    
    ; Benchmark RDRAND
    push 10000
    call benchmark_rdrand
    add esp, 4
    mov [ebp - 8], eax  ; Store RDRAND cycles
    mov [ebp - 4], edx
    
    ; Benchmark RDSEED
    call check_rdseed_support
    test al, al
    jz .no_rdseed
    
    rdtsc
    mov ebx, eax
    mov ecx, edx
    
    push ecx
    mov ecx, 10000
.rdseed_loop:
    rdseed eax
    loop .rdseed_loop
    pop ecx
    
    push edx
    rdtsc
    sub eax, ebx
    sbb edx, ecx
    mov [ebp - 16], eax
    mov [ebp - 12], edx
    pop edx
    
    ; Compare results
    mov eax, [ebp - 8]
    mov edx, [ebp - 16]
    ; Return comparison in registers
    jmp .done
    
.no_rdseed:
    mov dword [ebp - 16], -1
    mov dword [ebp - 12], -1
    
.done:
    pop ecx
    pop ebx
    add esp, 16
    pop ebp
    ret
```

### Integration with Operating System RNG

```asm
; Seed OS random pool with hardware RNG
contribute_to_os_entropy:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    
    mov ecx, [ebp + 8]  ; Number of 32-bit values to contribute
    mov esi, [ebp + 12] ; Callback function for OS entropy pool
    
.loop:
    ; Try RDSEED first
    call check_rdseed_support
    test al, al
    jz .use_rdrand
    
    rdseed eax
    jc .contribute
    
.use_rdrand:
    rdrand eax
    
.contribute:
    ; Call OS callback with random value
    push ecx
    push eax
    call esi
    add esp, 4
    pop ecx
    
    loop .loop
    
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret
```

### Error Handling and Diagnostics

```asm
; Comprehensive hardware RNG diagnostics
diagnose_hardware_rng:
    push ebp
    mov ebp, esp
    sub esp, 32
    push ebx
    push ecx
    push esi
    
    mov esi, [ebp + 8]  ; Diagnostics result structure
    
    ; Clear result structure
    mov ecx, 8
    mov edi, esi
    xor eax, eax
    rep stosd
    
    ; Check RDRAND support
    call check_rdrand_support
    mov [esi], al
    
    ; Check RDSEED support
    call check_rdseed_support
    mov [esi + 1], al
    
    ; Test RDRAND success rate
    xor ebx, ebx        ; Success count
    mov ecx, 100
.test_rdrand:
    rdrand eax
    jnc .rdrand_fail
    inc ebx
.rdrand_fail:
    loop .test_rdrand
    mov [esi + 4], ebx  ; Success rate
    
    ; Test RDSEED success rate if available
    cmp byte [esi + 1], 0
    je .skip_rdseed_test
    
    xor ebx, ebx
    mov ecx, 100
.test_rdseed:
    rdseed eax
    jnc .rdseed_fail
    inc ebx
.rdseed_fail:
    loop .test_rdseed
    mov [esi + 8], ebx
    
.skip_rdseed_test:
    ; Measure average latency
    push 1000
    call benchmark_rdrand
    add esp, 4
    mov [esi + 12], eax ; Average cycles per call
    mov [esi + 16], edx
    
    pop esi
    pop ecx
    pop ebx
    add esp, 32
    pop ebp
    ret
```

### Monte Carlo Simulation Example

```asm
; Estimate PI using Monte Carlo with hardware RNG
monte_carlo_pi:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    mov ecx, [ebp + 8]  ; Number of samples
    xor esi, esi        ; Count inside circle
    
.sample_loop:
    ; Generate random X coordinate
    rdrand eax
    ; Normalize to [0,1] range (simplified: use high bits)
    shr eax, 1          ; Ensure positive
    mov ebx, eax
    
    ; Generate random Y coordinate
    rdrand eax
    shr eax, 1
    mov edi, eax
    
    ; Check if point is inside unit circle
    ; x^2 + y^2 < 1
    ; Using integer approximation
    push ecx
    push edx
    
    mov eax, ebx
    mul ebx             ; x^2
    mov ebx, eax
    mov ecx, edx
    
    mov eax, edi
    mul edi             ; y^2
    add eax, ebx
    adc edx, ecx        ; x^2 + y^2
    
    ; Compare with r^2 (using 2^31 as radius for integer math)
    mov ebx, 0x40000000
    cmp edx, 0
    ja .outside
    cmp eax, ebx
    jae .outside
    
    inc esi             ; Point inside circle
    
.outside:
    pop edx
    pop ecx
    loop .sample_loop
    
    ; Estimate PI = 4 * (inside / total)
    mov eax, esi
    shl eax, 2          ; Multiply by 4
    mov ebx, [ebp + 8]  ; Total samples
    xor edx, edx
    div ebx             ; Approximate PI
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret
```

**Key Points:**

- CPUID provides comprehensive CPU feature detection across multiple function leaves, returning vendor identification, processor capabilities, cache topology, and architectural features
- MSRs expose low-level processor controls for performance monitoring, power management, and feature configuration, but require kernel-mode privileges (CPL 0)
- TSC offers high-resolution cycle-accurate timing essential for performance profiling, with invariant TSC providing constant-rate counting independent of frequency scaling
- RDRAND generates cryptographically secure random numbers through a hardware DRBG, while RDSEED provides direct access to the entropy source with higher quality but lower availability
- [Inference] Proper serialization with CPUID or fences around RDTSC measurements prevents out-of-order execution from corrupting timing results
- [Inference] Combining multiple entropy sources (RDSEED, RDRAND, TSC) provides defense-in-depth for security-critical random number generation
- Performance counter MSRs enable precise measurement of cache misses, branch mispredictions, and instruction retirement for microarchitectural optimization

**Important related topics:** Hardware transactional memory (TSX) programming, x86 virtualization extensions (VMX/SVM) initialization, Advanced Vector Extensions (AVX) capability detection and usage, Cache allocation technology (CAT) and memory bandwidth allocation through MSRs, Processor trace (Intel PT) configuration for execution tracing.

---

## Hardware Transactional Memory

Hardware Transactional Memory (HTM) allows atomic execution of code regions without explicit locks, using hardware support to detect and handle conflicts. Intel's implementation is called TSX (Transactional Synchronization Extensions), which includes two interfaces: Hardware Lock Elision (HLE) and Restricted Transactional Memory (RTM).

### Intel TSX Architecture

TSX provides optimistic concurrency control where threads speculatively execute critical sections, and the processor tracks memory operations. If conflicting accesses are detected, transactions abort and can be retried or fall back to traditional locking.

**Transaction Properties:**

The processor maintains transactional state through:

**Read-set tracking** - Records all memory locations read during the transaction. The cache coherency protocol monitors these addresses for modifications by other cores.

**Write-set buffering** - Stores speculative writes in cache without making them globally visible. Writes remain local until commit.

**Conflict detection** - Hardware detects when another core accesses transactional memory, triggering an abort if necessary.

**Atomicity guarantee** - Either all transactional operations complete and become visible atomically, or none do.

### RTM (Restricted Transactional Memory)

RTM provides explicit instructions to begin, commit, and abort transactions with full programmatic control.

**XBEGIN** - Starts a transactional region. Takes a relative offset to a fallback handler executed on abort.

```nasm
; Transaction with fallback path
    mov rax, -1           ; Initialize fallback indicator
    
transaction_start:
    xbegin transaction_abort
    
    ; Transaction successful - RAX = 0
    ; Now in transactional execution
    
    ; Critical section - speculative execution
    mov rbx, [shared_counter]
    inc rbx
    mov [shared_counter], rbx
    
    mov rcx, [shared_data]
    add rcx, 100
    mov [shared_data], rcx
    
    ; Commit transaction
    xend
    
    ; Transaction committed successfully
    jmp transaction_complete
    
transaction_abort:
    ; RAX contains abort status code
    ; Bit 0: Set if abort was explicit (XABORT)
    ; Bit 1: Set if transaction may succeed on retry
    ; Bit 2: Set if conflict with another transaction
    ; Bit 3: Set if buffer overflow
    ; Bit 4: Set if debug breakpoint triggered
    ; Bit 5: Set if abort in nested transaction
    ; Bits 24-31: Argument to XABORT instruction
    
    ; Check if retry makes sense
    test eax, (1 << 1)    ; Retry bit
    jz use_fallback_lock
    
    ; Check retry count
    dec dword [retry_count]
    jnz transaction_start
    
use_fallback_lock:
    ; Fall back to traditional locking
    mov rdi, lock_mutex
    call acquire_mutex
    
    ; Protected critical section
    mov rbx, [shared_counter]
    inc rbx
    mov [shared_counter], rbx
    
    mov rcx, [shared_data]
    add rcx, 100
    mov [shared_data], rcx
    
    mov rdi, lock_mutex
    call release_mutex
    
transaction_complete:
    ; Continue execution
```

**XEND** - Commits the current transaction. All speculative writes become globally visible atomically.

```nasm
transactional_update:
    xbegin .abort_handler
    
    ; Perform multiple updates atomically
    mov rax, [account_a_balance]
    sub rax, 1000
    mov [account_a_balance], rax
    
    mov rbx, [account_b_balance]
    add rbx, 1000
    mov [account_b_balance], rbx
    
    ; Both updates commit together
    xend
    ret
    
.abort_handler:
    ; Transaction failed, return error
    mov rax, -1
    ret
```

**XABORT** - Explicitly aborts the current transaction with an 8-bit immediate argument.

```nasm
transactional_insert:
    xbegin .abort_handler
    
    ; Check precondition
    mov rax, [list_size]
    cmp rax, MAX_SIZE
    jge .list_full
    
    ; Insert operation
    mov rbx, [list_head]
    mov [new_node + NODE_NEXT], rbx
    lea rcx, [new_node]
    mov [list_head], rcx
    inc rax
    mov [list_size], rax
    
    xend
    ret
    
.list_full:
    ; Abort with application-specific code
    xabort 0x01           ; Code 0x01 = list full
    
.abort_handler:
    ; Check abort reason
    shr eax, 24           ; Extract XABORT argument
    cmp al, 0x01
    je .handle_full
    
    ; Other abort reason
    mov rax, -1
    ret
    
.handle_full:
    mov rax, -2           ; List full error code
    ret
```

**XTEST** - Tests if code is executing inside a transaction. Sets ZF=1 if in transaction, ZF=0 otherwise.

```nasm
check_transactional_context:
    xtest
    jz not_in_transaction
    
    ; Currently inside transaction
    mov rax, 1
    ret
    
not_in_transaction:
    mov rax, 0
    ret

; Conditional behavior based on context
adaptive_function:
    xtest
    jz .use_locks
    
    ; In transaction - avoid operations that cause aborts
    ; Don't call system calls, don't use locks
    jmp .transactional_path
    
.use_locks:
    ; Not in transaction - can use any operations
    jmp .traditional_path
```

### Transaction Abort Conditions

Transactions abort when the processor cannot guarantee atomicity:

**Capacity aborts** - Transaction's read-set or write-set exceeds cache capacity (typically L1 data cache size, ~32KB). Each memory access adds to the tracked set.

```nasm
; This will likely abort due to capacity limits
large_transaction:
    xbegin .abort
    
    ; Accessing too much memory
    xor rcx, rcx
.loop:
    mov rax, [large_array + rcx*8]
    add rax, 1
    mov [large_array + rcx*8], rax
    inc rcx
    cmp rcx, 10000        ; 80KB of data
    jl .loop
    
    xend                  ; Likely to abort before reaching here
    
.abort:
    ; Handle capacity abort
    ; Must use non-transactional approach
```

**Conflict aborts** - Another logical processor reads from or writes to a memory location in the transaction's write-set, or writes to a location in the read-set.

```nasm
; Thread 1
thread1_transaction:
    xbegin .abort
    
    mov rax, [shared_variable]  ; Read-set includes shared_variable
    add rax, 10
    mov [shared_variable], rax  ; Write-set includes shared_variable
    
    xend
    
.abort:
    ; May have conflicted with thread 2

; Thread 2 (concurrent execution)
thread2_transaction:
    xbegin .abort
    
    mov rbx, [shared_variable]  ; Conflicts with thread 1's write
    add rbx, 20
    mov [shared_variable], rbx
    
    xend
    
.abort:
    ; One transaction will abort due to conflict
```

**Explicit aborts** - XABORT instruction called, or operations incompatible with transactional execution occur.

**Internal aborts** - Events like interrupts, exceptions, or privileged instruction execution.

**Operations that cause aborts:**

- System calls (SYSCALL, SYSENTER)
- I/O operations (IN, OUT, INS, OUTS)
- Non-temporal stores (MOVNT instructions)
- CPUID execution
- PAUSE instruction
- Unaligned cross-cache-line accesses
- Hardware interrupts and exceptions
- Context switches
- Accessing more than 4GB of memory

### HLE (Hardware Lock Elision)

HLE adds XACQUIRE and XRELEASE prefixes to existing lock operations, allowing backward compatibility with non-TSX processors while enabling lock elision on TSX-capable hardware.

**XACQUIRE Prefix (0xF2)** - Prefixes instructions that acquire a lock. On TSX processors, attempts to elide the lock.

**XRELEASE Prefix (0xF3)** - Prefixes instructions that release a lock. On TSX processors, commits the elided transaction.

```nasm
; Traditional spinlock
acquire_lock:
    mov rax, 1
.spin:
    xchg [lock_var], rax
    test rax, rax
    jnz .spin
    ret

release_lock:
    mov qword [lock_var], 0
    ret

; HLE-enabled spinlock (backward compatible)
acquire_lock_hle:
    mov rax, 1
.spin:
    ; XACQUIRE prefix on XCHG
    db 0xF2               ; XACQUIRE prefix
    xchg [lock_var], rax
    test rax, rax
    jnz .spin
    ; Lock acquired or transaction started
    ret

release_lock_hle:
    ; XRELEASE prefix on MOV
    db 0xF3               ; XRELEASE prefix
    mov qword [lock_var], 0
    ; Lock released or transaction committed
    ret

; Usage remains identical
increment_shared:
    call acquire_lock_hle
    
    mov rax, [shared_counter]
    inc rax
    mov [shared_counter], rax
    
    call release_lock_hle
    ret
```

**HLE Semantics:**

On TSX-capable processors:

1. XACQUIRE starts a transaction instead of actually acquiring the lock
2. The lock variable is added to the read-set but not written
3. If transaction succeeds, XRELEASE commits without touching the lock
4. If transaction aborts, the processor retries with actual lock acquisition

On non-TSX processors, the prefixes are ignored and normal lock operations execute.

### Nested Transactions

[Inference] Intel TSX supports limited nesting where inner transactions are subsumed into the outer transaction. There is no independent commit of inner transactions.

```nasm
outer_transaction:
    xbegin .outer_abort
    
    ; Outer transaction operations
    mov rax, [data1]
    add rax, 10
    mov [data1], rax
    
    ; Call function that uses transaction
    call inner_function
    
    ; More outer operations
    mov rbx, [data2]
    add rbx, 20
    mov [data2], rbx
    
    xend                  ; Commits everything atomically
    ret
    
.outer_abort:
    ; Outer transaction aborted
    ret

inner_function:
    xbegin .inner_abort
    
    ; Inner transaction - merged into outer
    mov rcx, [data3]
    add rcx, 5
    mov [data3], rcx
    
    xend                  ; Does not actually commit
    ret
    
.inner_abort:
    ; Inner abort causes outer transaction to abort
    ; Control transfers to outer abort handler
```

### Detecting TSX Support

```nasm
check_tsx_support:
    ; Check CPUID for TSX availability
    mov eax, 7
    xor ecx, ecx
    cpuid
    
    ; EBX bit 4 = HLE support
    ; EBX bit 11 = RTM support
    
    test ebx, (1 << 11)   ; Check RTM
    jz no_rtm
    
    ; RTM is supported
    mov rax, 1
    ret
    
no_rtm:
    xor rax, rax
    ret

; Check if RTM is enabled (not disabled by BIOS/OS)
check_rtm_enabled:
    xbegin .test_abort
    xend
    mov rax, 1            ; RTM works
    ret
    
.test_abort:
    xor rax, rax          ; RTM not functional
    ret
```

### Best Practices for HTM

**Transaction Size Management:**

```nasm
; Keep transactions small and focused
good_transaction:
    xbegin .abort
    
    ; Limited memory access
    mov rax, [counter]
    inc rax
    mov [counter], rax
    
    xend
    ret
    
.abort:
    ; Fallback
    jmp locked_version

; Avoid large transactions
bad_transaction:
    xbegin .abort
    
    ; Too much memory access
    mov rcx, 1000
.loop:
    mov rax, [large_array + rcx*8]
    add rax, 1
    mov [large_array + rcx*8], rax
    loop .loop
    
    xend
    ret
    
.abort:
    ; Frequent aborts expected
```

**Retry Logic with Backoff:**

```nasm
transactional_operation_with_retry:
    mov r15d, MAX_RETRIES
    
.retry_loop:
    xbegin .abort_handler
    
    ; Transaction body
    call perform_operation
    
    xend
    ret                   ; Success
    
.abort_handler:
    ; Check if retry is reasonable
    test eax, (1 << 1)
    jz .use_fallback
    
    ; Exponential backoff before retry
    dec r15d
    jz .use_fallback
    
    ; Calculate backoff delay
    mov ecx, MAX_RETRIES
    sub ecx, r15d
    mov edx, 1
    shl edx, cl           ; 2^(attempts)
    
.pause_loop:
    pause
    dec edx
    jnz .pause_loop
    
    jmp .retry_loop
    
.use_fallback:
    call locked_operation
    ret
```

**Avoiding Abort-Prone Operations:**

```nasm
; Bad: System call inside transaction
bad_transactional_log:
    xbegin .abort
    
    mov rax, [counter]
    inc rax
    mov [counter], rax
    
    ; This will always abort
    mov rax, 1            ; SYS_write
    syscall
    
    xend
    
.abort:
    ; Always reaches here

; Good: Defer I/O operations
good_transactional_log:
    xbegin .abort
    
    mov rax, [counter]
    inc rax
    mov [counter], rax
    
    ; Record that logging needed
    mov byte [need_log], 1
    
    xend
    
    ; Log after transaction
    cmp byte [need_log], 1
    jne .done
    
    mov rax, 1
    syscall
    
.done:
    ret
    
.abort:
    ; Fallback
```

## Intel SGX Basics

Intel Software Guard Extensions (SGX) provides hardware-enforced confidentiality and integrity for application code and data through isolated execution environments called enclaves.

### SGX Architecture

**Enclaves** are protected memory regions that are isolated from the OS, hypervisor, BIOS, and SMM. Only code running inside the enclave can access enclave memory.

**Processor Reserved Memory (PRM)** - A contiguous range of physical memory reserved during boot that the CPU protects from non-enclave access, including DMA.

**Enclave Page Cache (EPC)** - A subset of PRM (typically 128MB or less in SGX1) that stores encrypted enclave pages. Each 4KB page is encrypted with a processor-generated key.

**Memory Encryption Engine (MEE)** - Hardware that encrypts/decrypts EPC pages transparently using AES with integrity checking. Keys are derived from processor fuses and never leave the CPU package.

### Enclave Life Cycle

**ECREATE** - Creates an enclave by initializing the SECS (SGX Enclave Control Structure) in EPC.

```nasm
create_enclave:
    ; Allocate EPC page for SECS
    mov rdi, 4096
    call allocate_epc_page
    mov r12, rax          ; R12 = SECS linear address
    
    ; Fill PAGEINFO structure
    lea rbx, [pageinfo]
    mov qword [rbx + PAGEINFO.LINADDR], 0
    mov qword [rbx + PAGEINFO.SRCPGE], rsi  ; Source page with SECS data
    lea rcx, [secs_data]
    mov qword [rbx + PAGEINFO.SECINFO], rcx
    mov qword [rbx + PAGEINFO.SECS], 0
    
    ; Execute ECREATE
    lea rax, [pageinfo]
    mov rcx, r12          ; RCX = target SECS EPC address
    
    encls                 ; ECREATE leaf (EAX=0)
    
    test rax, rax
    jnz .error
    
    ; SECS created successfully
    mov rax, r12
    ret
    
.error:
    ; Error code in RAX
    xor rax, rax
    ret
```

**EADD** - Adds a page to the enclave by copying from non-EPC memory to EPC and associating it with the SECS.

```nasm
add_enclave_page:
    ; Parameters:
    ; R12 = SECS address
    ; R13 = Linear address in enclave
    ; R14 = Source page content
    ; R15 = Page type and permissions
    
    ; Allocate EPC page
    mov rdi, 4096
    call allocate_epc_page
    mov rbx, rax          ; EPC page address
    
    ; Build PAGEINFO
    lea rdi, [pageinfo]
    mov [rdi + PAGEINFO.LINADDR], r13
    mov [rdi + PAGEINFO.SRCPGE], r14
    lea rcx, [secinfo]
    mov [rdi + PAGEINFO.SECINFO], rcx
    mov [rdi + PAGEINFO.SECS], r12
    
    ; Set page type (PT_REG, PT_TCS, PT_TRIM, etc.)
    lea rcx, [secinfo]
    mov [rcx + SECINFO.FLAGS], r15
    
    ; Execute EADD
    mov eax, 1            ; EADD leaf
    lea rax, [pageinfo]
    mov rcx, rbx          ; Destination EPC address
    
    encls
    
    test rax, rax
    jnz .error
    
    ret
    
.error:
    ; Handle error
    ret
```

**EINIT** - Initializes the enclave by verifying its measurement and signature. After EINIT succeeds, the enclave can be entered.

```nasm
initialize_enclave:
    ; R12 = SECS address
    ; R13 = SIGSTRUCT address (signature structure)
    ; R14 = EINITTOKEN address
    
    mov eax, 2            ; EINIT leaf
    mov rbx, r13          ; SIGSTRUCT
    mov rcx, r12          ; SECS
    mov rdx, r14          ; EINITTOKEN
    
    encls
    
    test rax, rax
    jnz .init_failed
    
    ; Enclave initialized and sealed
    ret
    
.init_failed:
    ; Check error code
    ; SGX_INVALID_SIG, SGX_INVALID_ATTRIBUTE, etc.
    ret
```

**EENTER** - Enters the enclave at a Thread Control Structure (TCS). Saves untrusted state and switches to enclave mode.

```nasm
enter_enclave:
    ; R12 = TCS linear address
    ; R13 = AEP (Asynchronous Exit Pointer) for interrupts
    
    ; Prepare registers for enclave entry
    ; RBX = TCS address
    ; RCX = AEP address
    
    mov rbx, r12
    lea rcx, [aep_handler]
    
    ; Execute EENTER (leaf 2 of ENCLU)
    mov eax, 2            ; EENTER leaf
    enclu
    
    ; Control transfers to enclave entry point
    ; Does not return here unless enclave exits

; Asynchronous Exit Pointer - handles interrupts during enclave execution
aep_handler:
    ; Processor vectored here on interrupt/exception in enclave
    ; RBX = reason code
    ; RCX = enclave exit address
    
    ; Handle interrupt then resume
    call handle_interrupt
    
    ; Resume enclave (ERESUME)
    mov eax, 3            ; ERESUME leaf
    enclu
```

**EEXIT** - Exits the enclave back to the calling application.

```nasm
; Inside enclave code
exit_enclave:
    ; Prepare return values
    mov rdi, [result_value]
    
    ; Specify where to return (must be in ELRANGE)
    lea rbx, [return_address]
    
    ; Execute EEXIT
    mov eax, 4            ; EEXIT leaf
    enclu
    
    ; Control transfers back to untrusted code
```

**EREMOVE** - Removes a page from the enclave and returns it to the free EPC pool.

```nasm
remove_enclave_page:
    ; R12 = EPC page linear address
    
    mov eax, 3            ; EREMOVE leaf
    mov rcx, r12
    
    encls
    
    test rax, rax
    jnz .error
    
    ret
    
.error:
    ; Page still in use or invalid
    ret
```

### Enclave Entry and Exit

**Thread Control Structure (TCS):**

Each enclave thread requires a TCS page that stores:

- Entry point address (OENTRY)
- Stack segment register values
- Frame pointers
- Thread state flags

```nasm
; TCS structure layout (simplified)
struc TCS
    .state:         resq 1    ; Thread state (0=available)
    .flags:         resq 1    ; Thread flags
    .ossa:          resq 1    ; Offset of State Save Area
    .cssa:          resd 1    ; Current SSA frame index
    .nssa:          resd 1    ; Number of SSA frames
    .oentry:        resq 1    ; Entry point offset
    .ofsbasgx:      resq 1    ; FS base address
    .ogsbasgx:      resq 1    ; GS base address
    .fslimit:       resd 1    ; FS segment limit
    .gslimit:       resd 1    ; GS segment limit
endstruc
```

**State Save Area (SSA):**

When an asynchronous exit occurs (interrupt, exception), the processor saves enclave state to the SSA for later resumption.

```nasm
; SSA frame structure
struc SSA_GPRSGX
    .rax:       resq 1
    .rcx:       resq 1
    .rdx:       resq 1
    .rbx:       resq 1
    .rsp:       resq 1
    .rbp:       resq 1
    .rsi:       resq 1
    .rdi:       resq 1
    .r8:        resq 1
    .r9:        resq 1
    .r10:       resq 1
    .r11:       resq 1
    .r12:       resq 1
    .r13:       resq 1
    .r14:       resq 1
    .r15:       resq 1
    .rflags:    resq 1
    .rip:       resq 1
    .ursp:      resq 1  ; Untrusted RSP
    .urbp:      resq 1  ; Untrusted RBP
    .exitinfo:  resd 1  ; Exit reason
    .reserved:  resd 1
    .fsbase:    resq 1
    .gsbase:    resq 1
endstruc
```

**OCALL (Out Call):**

Enclave calls untrusted function:

```nasm
; Inside enclave
perform_ocall:
    ; Save enclave state
    push rbp
    mov rbp, rsp
    
    ; Prepare parameters in untrusted memory
    mov rdi, [param1]
    mov rsi, [param2]
    
    ; Exit to specified untrusted function
    lea rbx, [untrusted_function_address]
    mov eax, 4            ; EEXIT
    enclu
    
    ; Returns here after untrusted function completes
    pop rbp
    ret

; Untrusted code
untrusted_function_address:
    ; Process parameters
    ; ...
    
    ; Re-enter enclave at continuation point
    mov rbx, [tcs_address]
    lea rcx, [aep]
    mov eax, 2            ; EENTER
    enclu
```

**ECALL (Enclave Call):**

Application calls into enclave:

```nasm
; Untrusted application
call_enclave_function:
    ; Prepare parameters
    mov r12, [enclave_function_id]
    mov r13, [parameter_buffer]
    
    ; Enter enclave at TCS
    mov rbx, [tcs_address]
    lea rcx, [aep_handler]
    mov eax, 2            ; EENTER
    enclu
    
    ; Returns here after enclave processes request
    ret

; Inside enclave entry point
enclave_entry:
    ; Dispatch to requested function
    cmp r12, FUNC_ID_PROCESS_DATA
    je process_data_function
    
    cmp r12, FUNC_ID_GENERATE_KEY
    je generate_key_function
    
    ; Invalid function ID
    mov rax, -1
    jmp exit_to_app
    
process_data_function:
    ; Access parameter buffer (must validate!)
    call validate_untrusted_pointer
    test rax, rax
    jz .invalid_params
    
    ; Process data securely
    ; ...
    
    xor rax, rax          ; Success
    jmp exit_to_app
    
.invalid_params:
    mov rax, -2
    jmp exit_to_app

exit_to_app:
    ; Exit enclave
    lea rbx, [return_point]
    mov eax, 4            ; EEXIT
    enclu
```

### Memory Access Patterns

**Enclave Page Types:**

- **PT_REG** (0x00) - Regular enclave page for code/data
- **PT_TCS** (0x01) - Thread Control Structure
- **PT_TRIM** (0x02) - Page being removed from enclave
- **PT_SS_FIRST** (0x03) - First page of SSA frame
- **PT_SS_REST** (0x04) - Additional SSA frame pages
- **PT_SECS** (0x00) - SGX Enclave Control Structure

**Page Permissions:**

```nasm
; SECINFO structure defines page permissions
struc SECINFO
    .flags:     resq 1    ; Permissions: R, W, X
    .reserved:  resb 56
endstruc

; Permission bits
SECINFO_R = (1 << 0)      ; Readable
SECINFO_W = (1 << 1)      ; Writable
SECINFO_X = (1 << 2)      ; Executable
SECINFO_PENDING = (1 << 3)
SECINFO_MODIFIED = (1 << 4)
SECINFO_PR = (1 << 5)     ; Pending removal

; Add executable code page
add_code_page:
    lea rcx, [secinfo]
    mov qword [rcx + SECINFO.flags], (SECINFO_R | SECINFO_X)
    ; ... call EADD
    
; Add data page
add_data_page:
    lea rcx, [secinfo]
    mov qword [rcx + SECINFO.flags], (SECINFO_R | SECINFO_W)
    ; ... call EADD
```

### Attestation and Sealing

**Local Attestation (EREPORT):**

Creates a cryptographic report proving enclave identity to another enclave on the same platform.

```nasm
; Inside enclave
create_report:
    ; R12 = target enclave MRENCLAVE
    ; R13 = user data (64 bytes)
    ; R14 = output report buffer (512 bytes)
    
    ; Build TARGETINFO structure
    lea rbx, [targetinfo]
    mov rdi, r12
    mov rsi, rbx
    mov rcx, 64
    rep movsb
    
    ; Build REPORTDATA
    lea rbx, [reportdata]
    mov rdi, r13
    mov rsi, rbx
    mov rcx, 64
    rep movsb
    
    ; Generate report
    mov eax, 0            ; EREPORT leaf (ENCLU)
    lea rbx, [targetinfo]
    lea rcx, [reportdata]
    mov rdx, r14          ; Output buffer
    
    enclu
    
    ; Report created in RDX buffer
    ret
```

**Remote Attestation:**

[Inference] Involves creating a quote from the report using the Quoting Enclave, which signs it with a platform-specific key. The quote is sent to a remote verifier (Intel Attestation Service or DCAP) for verification.

```nasm
; Simplified quote generation flow
generate_quote:
    ; First, create report targeting Quoting Enclave
    lea rdi, [QE_target_info]
    lea rsi, [report_data]
    lea rdx, [report_buffer]
    call create_report
    
    ; Exit enclave and call Quoting Enclave via AESM service
    ; (This happens in untrusted code)
    
    ; Quote includes:
    ; - Enclave measurement (MRENCLAVE)
    ; - Signer measurement (MRSIGNER)
    ; - Attributes
    ; - Report data
    ; - Platform signature
    
    ret
```

**Sealing (Data Encryption for Storage):**

Encrypt data for persistent storage using processor-derived keys.

```nasm
; Inside enclave
seal_data:
    ; R12 = data pointer
    ; R13 = data size
    ; R14 = output sealed blob pointer
    
    ; Derive sealing key using EGETKEY
    lea rbx, [keyrequest]
    mov qword [rbx + KEYREQUEST.KEYNAME], 1  ; Seal key
    mov qword [rbx + KEYREQUEST.KEYPOLICY], 0  ; MRENCLAVE-based
    
    mov eax, 1            ; EGETKEY leaf
    mov rcx, rbx
    lea rdx, [derived_key]
    
    enclu
    
    ; Use derived key to encrypt data (AES-GCM)
    lea rdi, [derived_key]
    mov rsi, r12
    mov rdx, r13
    lea rcx, [encrypted_output]
    call aes_gcm_encrypt
    
    ; Copy to output with metadata
    lea rsi, [encrypted_output]
    mov rdi, r14
    call copy_sealed_blob
    
    ; Securely erase key
    lea rdi, [derived_key]
    xor rax, rax
    mov rcx, 16
    rep stosq
    
    ret
```

**Unsealing:**

```nasm
unseal_data:
    ; R12 = sealed blob pointer
    ; R13 = output data pointer
    
    ; Re-derive same key
    lea rbx, [keyrequest]
    mov qword [rbx + KEYREQUEST.KEYNAME], 1
    mov qword [rbx + KEYREQUEST.KEYPOLICY], 0
    
    mov eax, 1            ; EGETKEY
    mov rcx, rbx
    lea rdx, [derived_key]
    
    enclu
    
    ; Decrypt sealed data
    lea rdi, [derived_key]
    mov rsi, r12
    lea rdx, [decrypted_output]
    call aes_gcm_decrypt
    
    ; Verify authentication tag
    test rax, rax
    jz .decrypt_failed
    
    ; Copy decrypted data to output
    lea rsi, [decrypted_output]
    mov rdi, r13
    mov rcx, [data_length]
    rep movsb
    
    ; Securely erase key and temp buffers
    lea rdi, [derived_key]
    xor rax, rax
    mov rcx, 16
    rep stosq
    
    lea rdi, [decrypted_output]
    mov rcx, [data_length]
    shr rcx, 3
    rep stosq
    
    xor rax, rax          ; Success
    ret
    
.decrypt_failed:
    ; Tampering detected or wrong key
    mov rax, -1
    ret
```

### SGX Measurement and Identity

**MRENCLAVE** - 256-bit hash that uniquely identifies the enclave code and initial data. Computed by hashing all pages added during enclave build (EADD operations).

**MRSIGNER** - 256-bit hash of the public key used to sign the enclave. Identifies the enclave author rather than specific enclave version.

**Enclave Signature Structure (SIGSTRUCT):**

```nasm
struc SIGSTRUCT
    .header:        resb 16     ; "06000000E10000000000010000000000"
    .vendor:        resd 1      ; Intel = 0x00008086
    .date:          resd 1      ; Build date (YYYYMMDD)
    .header2:       resb 16     ; "01010000600000006000000001000000"
    .swdefined:     resd 1      ; Software-defined value
    .reserved1:     resb 84
    .modulus:       resb 384    ; RSA-3072 public key modulus
    .exponent:      resd 1      ; RSA public exponent
    .signature:     resb 384    ; RSA-3072 signature over enclave measurement
    .miscselect:    resd 1      ; Extended features
    .miscmask:      resd 1      ; Mask for miscselect
    .reserved2:     resb 20
    .attributes:    resb 16     ; Enclave attributes (debug, mode64bit, etc.)
    .attributemask: resb 16     ; Mask for attributes
    .enclavehash:   resb 32     ; MRENCLAVE value
    .reserved3:     resb 32
    .isvprodid:     resw 1      ; Product ID
    .isvsvn:        resw 1      ; Security version number
    .reserved4:     resb 12
    .q1:            resb 384    ; RSA signature Q1 value
    .q2:            resb 384    ; RSA signature Q2 value
endstruc
```

**Computing MRENCLAVE:**

```nasm
; MRENCLAVE is computed as:
; SHA256(ECREATE || EADD(page0) || EADD(page1) || ... || EEXTEND)

compute_mrenclave:
    ; Initialize SHA256 context
    lea rdi, [sha256_ctx]
    call sha256_init
    
    ; Hash ECREATE operation
    lea rsi, [ecreate_record]
    mov rdx, 64
    call sha256_update
    
    ; Hash each EADD operation
    mov r12, [page_count]
    xor r13, r13          ; Page index
    
.hash_pages:
    ; Build EADD record: 
    ; - Operation code (EADD)
    ; - Offset in enclave
    ; - Page content (4KB)
    ; - Security attributes
    
    lea rsi, [eadd_records + r13 * EADD_RECORD_SIZE]
    mov rdx, EADD_RECORD_SIZE
    call sha256_update
    
    inc r13
    cmp r13, r12
    jl .hash_pages
    
    ; Finalize hash
    lea rdi, [mrenclave_output]
    call sha256_final
    
    ret
```

### SGX Versions and Capabilities

**SGX1** - Initial version with basic enclave functionality:

- Static enclave size (set at creation)
- No dynamic memory allocation
- No enclave-to-enclave memory sharing

**SGX2** - Enhanced version with dynamic features:

**EAUG** - Dynamically adds pages to initialized enclave:

```nasm
augment_enclave_page:
    ; R12 = SECS address
    ; R13 = linear address for new page
    
    ; Allocate EPC page
    call allocate_epc_page
    mov rbx, rax
    
    ; Build PAGEINFO
    lea rdi, [pageinfo]
    mov [rdi + PAGEINFO.LINADDR], r13
    mov qword [rdi + PAGEINFO.SRCPGE], 0  ; No initial content
    lea rcx, [secinfo]
    mov [rdi + PAGEINFO.SECINFO], rcx
    mov [rdi + PAGEINFO.SECS], r12
    
    ; Set page as pending
    mov qword [secinfo + SECINFO.flags], (SECINFO_R | SECINFO_W | SECINFO_PENDING)
    
    ; Execute EAUG
    mov eax, 13           ; EAUG leaf
    lea rax, [pageinfo]
    mov rcx, rbx
    
    encls
    
    ret
```

**EMODT** - Modifies page type (e.g., REG to TRIM for removal):

```nasm
modify_page_type:
    ; R12 = page linear address
    ; R13 = new page type and permissions
    
    lea rbx, [secinfo]
    mov [rbx + SECINFO.flags], r13
    
    mov eax, 14           ; EMODT leaf
    mov rbx, [secinfo]
    mov rcx, r12
    
    encls
    
    ret
```

**EACCEPT** - Inside enclave, accepts dynamically added pages:

```nasm
; Inside enclave
accept_new_page:
    ; R12 = linear address of EAUG'd page
    
    lea rbx, [secinfo]
    mov qword [rbx + SECINFO.flags], (SECINFO_R | SECINFO_W)
    
    mov eax, 5            ; EACCEPT leaf (ENCLU)
    mov rbx, [secinfo]
    mov rcx, r12
    
    enclu
    
    test rax, rax
    jnz .accept_failed
    
    ; Page now usable
    ret
    
.accept_failed:
    ; Page not in pending state or invalid
    ret
```

**EACCEPTCOPY** - Accepts and copies content to augmented page:

```nasm
accept_and_copy_page:
    ; R12 = destination linear address
    ; R13 = source page content
    
    lea rbx, [secinfo]
    mov qword [rbx + SECINFO.flags], (SECINFO_R | SECINFO_W)
    
    mov eax, 7            ; EACCEPTCOPY leaf
    mov rbx, [secinfo]
    mov rcx, r12
    mov rdx, r13          ; Source address
    
    enclu
    
    ret
```

### SGX Security Considerations

**Side-Channel Attacks:**

SGX enclaves are vulnerable to various side-channel attacks despite memory encryption:

```nasm
; Vulnerable pattern - secret-dependent memory access
vulnerable_lookup:
    ; R12 = secret index
    ; This leaks information through cache timing
    lea rax, [lookup_table]
    mov rbx, [rax + r12*8]
    ret

; Mitigated pattern - constant-time access
constant_time_lookup:
    ; R12 = secret index
    ; R13 = table size
    
    xor rax, rax          ; Result accumulator
    xor rcx, rcx          ; Current index
    
.scan_loop:
    ; Access every entry regardless of index
    lea rbx, [lookup_table]
    mov rdx, [rbx + rcx*8]
    
    ; Conditionally select without branching
    xor rbx, rbx
    cmp rcx, r12
    cmove rax, rdx        ; Constant-time conditional move
    
    inc rcx
    cmp rcx, r13
    jl .scan_loop
    
    ret
```

**Page Fault Side-Channels:**

Untrusted OS can induce page faults to learn enclave memory access patterns:

```nasm
; Vulnerable - sequential access reveals progress
vulnerable_search:
    mov rcx, [array_size]
    xor rdx, rdx
    
.search_loop:
    mov rax, [array + rdx*8]  ; Each access potentially faultable
    cmp rax, [search_value]
    je .found
    
    inc rdx
    cmp rdx, rcx
    jl .search_loop
    
.found:
    ret

; Mitigated - preload all pages
mitigated_search:
    ; First, touch all pages to bring them in
    mov rcx, [array_size]
    xor rdx, rdx
    
.preload:
    mov rax, [array + rdx*8]
    add rdx, 512          ; Touch one per page (4KB/8bytes)
    cmp rdx, rcx
    jl .preload
    
    ; Now perform actual search
    ; (Page faults won't leak position)
    xor rdx, rdx
.search_loop:
    mov rax, [array + rdx*8]
    cmp rax, [search_value]
    je .found
    
    inc rdx
    cmp rdx, rcx
    jl .search_loop
    
.found:
    ret
```

**Untrusted Input Validation:**

All data from untrusted memory must be validated:

```nasm
; Inside enclave
process_untrusted_buffer:
    ; R12 = pointer to untrusted buffer
    ; R13 = claimed size
    
    ; Check pointer is outside enclave
    call is_outside_enclave
    test rax, rax
    jz .invalid_pointer
    
    ; Check size is reasonable
    cmp r13, MAX_BUFFER_SIZE
    jg .invalid_size
    
    ; Check for integer overflow
    mov rax, r12
    add rax, r13
    jc .overflow
    
    ; Check entire range is outside enclave
    mov rdi, r12
    mov rsi, r13
    call verify_range_outside
    test rax, rax
    jz .invalid_range
    
    ; Safe to access - copy to enclave memory
    lea rdi, [enclave_buffer]
    mov rsi, r12
    mov rcx, r13
    rep movsb
    
    ; Process copied data
    lea rdi, [enclave_buffer]
    mov rsi, r13
    call process_data
    
    ret
    
.invalid_pointer:
.invalid_size:
.overflow:
.invalid_range:
    mov rax, -1
    ret

is_outside_enclave:
    ; R12 = address to check
    mov rax, r12
    
    ; Get enclave base and size from SECS
    mov rbx, [enclave_base]
    mov rcx, [enclave_size]
    
    ; Check if address is outside [base, base+size)
    cmp rax, rbx
    jl .outside           ; Below base
    
    mov rdx, rbx
    add rdx, rcx
    cmp rax, rdx
    jge .outside          ; Above base+size
    
    xor rax, rax          ; Inside enclave - invalid
    ret
    
.outside:
    mov rax, 1            ; Outside enclave - valid
    ret
```

**TOCTTOU (Time-of-Check-Time-of-Use) Vulnerabilities:**

```nasm
; Vulnerable - untrusted data can change between checks
vulnerable_process:
    ; R12 = pointer to untrusted structure
    
    ; Check size field
    mov rax, [r12 + STRUCT.size]
    cmp rax, MAX_SIZE
    jg .invalid
    
    ; Allocate buffer based on size
    mov rdi, rax
    call allocate_buffer
    
    ; Copy data - but size could have changed!
    mov rcx, [r12 + STRUCT.size]  ; Re-read (could be different!)
    mov rsi, [r12 + STRUCT.data]
    mov rdi, rax
    rep movsb             ; Potential buffer overflow
    
    ret
    
.invalid:
    ret

; Secure - copy data once before processing
secure_process:
    ; R12 = pointer to untrusted structure
    
    ; Copy structure to enclave memory atomically
    lea rdi, [temp_struct]
    mov rsi, r12
    mov rcx, STRUCT_SIZE
    rep movsb
    
    ; Now validate copied data
    mov rax, [temp_struct + STRUCT.size]
    cmp rax, MAX_SIZE
    jg .invalid
    
    ; Safe to use - data can't change
    mov rdi, rax
    call allocate_buffer
    
    mov rcx, [temp_struct + STRUCT.size]  ; Same value as before
    lea rsi, [temp_struct + STRUCT.data]
    mov rdi, rax
    rep movsb
    
    ret
    
.invalid:
    ret
```

## AMD SME/SEV Basics

AMD Secure Memory Encryption (SME) and Secure Encrypted Virtualization (SEV) provide transparent memory encryption to protect against physical memory attacks and isolate virtual machine memory.

### SME (Secure Memory Encryption)

SME encrypts system memory using a single processor-generated AES-128 key that never leaves the CPU die. The encryption is transparent to software.

**C-bit (Encryption bit)** - A physical address bit (typically bit 47 or 51 depending on processor) that indicates whether a page should be encrypted.

```nasm
; Page table entry with C-bit set
; Assume C-bit is physical address bit 47

setup_encrypted_page:
    ; Normal physical address
    mov rax, 0x0000000012345000  ; Physical address
    
    ; Set C-bit to enable encryption
    bts rax, 47               ; Set bit 47
    
    ; Now RAX = 0x0000800012345000
    ; This page will be encrypted in memory
    
    ; Set as PTE entry
    or rax, 0x03              ; Present, Writable
    mov [page_table + rcx*8], rax
    
    ret

setup_unencrypted_page:
    ; Physical address without C-bit
    mov rax, 0x0000000012346000
    
    ; Don't set C-bit - page remains unencrypted
    ; Useful for DMA buffers, shared memory
    
    or rax, 0x03
    mov [page_table + rcx*8], rax
    
    ret
```

**Enabling SME:**

SME is controlled by the SYS_CFG MSR (0xC0010010):

```nasm
enable_sme:
    ; Check if SME is supported
    mov eax, 0x8000001F
    cpuid
    
    test eax, (1 << 0)        ; Check SME support bit
    jz .no_sme
    
    ; EBX bits 5:0 contain C-bit position
    mov ecx, ebx
    and ecx, 0x3F
    mov [c_bit_position], ecx
    
    ; ECX bits 5:0 contain physical address reduction
    shr ecx, 8
    and ecx, 0x3F
    mov [phys_addr_reduction], ecx
    
    ; Enable SME in SYS_CFG MSR
    mov ecx, 0xC0010010       ; SYS_CFG MSR
    rdmsr
    or eax, (1 << 23)         ; Set SMEE (SME Enable)
    wrmsr
    
    ; SME now active for pages with C-bit set
    ret
    
.no_sme:
    ; SME not supported on this processor
    ret
```

**Memory Encryption Key:**

The encryption key is generated by the processor using a hardware random number generator during boot:

```nasm
; The key is not directly accessible to software
; It persists until:
; - System reset
; - Power off
; - Explicit key change (WBINVD after disabling SME)

check_sme_status:
    mov ecx, 0xC0010010       ; SYS_CFG MSR
    rdmsr
    
    test eax, (1 << 23)       ; Check SMEE bit
    jnz .sme_enabled
    
    ; SME disabled
    xor rax, rax
    ret
    
.sme_enabled:
    mov rax, 1
    ret
```

**SME Use Cases:**

```nasm
; Protect sensitive data structures
allocate_encrypted_memory:
    ; Allocate physical pages
    mov rdi, num_pages
    call allocate_physical_pages
    mov r12, rax              ; R12 = physical address
    
    ; Create page table mapping with C-bit
    mov rax, r12
    mov rcx, [c_bit_position]
    bts rax, rcx              ; Set C-bit
    
    or rax, 0x03              ; Present, Writable
    mov rbx, [page_table_entry]
    mov [rbx], rax
    
    ; Flush TLB
    invlpg [virtual_address]
    
    ; Memory accessed through this mapping is encrypted
    ret

; Create unencrypted DMA buffer
allocate_dma_buffer:
    ; DMA devices can't decrypt, need plain memory
    call allocate_physical_pages
    mov r12, rax
    
    ; Map WITHOUT C-bit
    mov rax, r12
    ; Don't set C-bit
    or rax, 0x03
    mov rbx, [dma_page_table_entry]
    mov [rbx], rax
    
    invlpg [dma_virtual_address]
    
    ; This memory is accessible to DMA devices
    ret
```

### SEV (Secure Encrypted Virtualization)

SEV extends SME to virtualize the C-bit, giving each VM a unique memory encryption key. VMs are protected from:

- Hypervisor memory access
- Other VMs
- Physical memory attacks

**SEV Architecture:**

Each VM is assigned an ASID (Address Space Identifier) that selects a unique encryption key. The processor manages up to 509 encryption keys (ASIDs 1-509, ASID 0 is for hypervisor).

**Enabling SEV:**

```nasm
; Hypervisor enables SEV for a VM

enable_vm_sev:
    ; Check SEV support
    mov eax, 0x8000001F
    cpuid
    
    test eax, (1 << 1)        ; SEV supported?
    jz .no_sev
    
    ; EDX contains max ASID count
    mov [max_asid], edx
    
    ; Enable SEV in VM_HSAVE_PA MSR
    mov ecx, 0xC0010117       ; VM_HSAVE_PA
    rdmsr
    ; Configure VM save area
    
    ; For each VM, set VMCB SEV_CONTROL field
    ; ASID in VMCB determines which key
    
    ret
    
.no_sev:
    ret
```

**VMCB SEV Control:**

```nasm
; VMCB (Virtual Machine Control Block) SEV fields

struc VMCB_SEV
    .sev_features:  resd 1    ; Offset 0x90
    ; Bit 0: SEV enabled
    ; Bit 1: SEV-ES enabled
    ; Bit 2: SEV-SNP enabled
    ; Bits 31:3: Reserved
    
    .reserved:      resb 12
    
    .guest_asid:    resd 1    ; Offset 0x58 in VMCB
    ; ASID 1-509 for SEV guests
    ; ASID 0 for hypervisor
endstruc

setup_sev_vm:
    ; R12 = VMCB physical address
    
    ; Allocate ASID for this VM
    call allocate_asid
    mov r13d, eax             ; R13 = ASID
    
    ; Set ASID in VMCB
    mov rbx, r12
    mov [rbx + VMCB.guest_asid], r13d
    
    ; Enable SEV
    mov eax, [rbx + VMCB_SEV.sev_features]
    or eax, 1                 ; SEV enable bit
    mov [rbx + VMCB_SEV.sev_features], eax
    
    ; Generate new key for this ASID
    ; (Done automatically by processor on first use)
    
    ret
```

**SEV Commands (Platform Security Processor):**

SEV management is done through the AMD Platform Security Processor (PSP) using a command interface:

```nasm
; SEV command structure
struc SEV_CMD
    .command:       resd 1    ; Command ID
    .subcmd:        resd 1    ; Subcommand
    .paddr:         resq 1    ; Physical address of command buffer
endstruc

; SEV command IDs
SEV_CMD_INIT = 0x001
SEV_CMD_PLATFORM_STATUS = 0x002
SEV_CMD_LAUNCH_START = 0x030
SEV_CMD_LAUNCH_UPDATE_DATA = 0x031
SEV_CMD_LAUNCH_FINISH = 0x033
SEV_CMD_GUEST_STATUS = 0x034
SEV_CMD_SEND_START = 0x040
SEV_CMD_RECEIVE_START = 0x050

; Submit SEV command to PSP
submit_sev_command:
    ; R12 = command structure pointer
    
    ; Write command to SEV command register
    mov rax, [sev_cmd_reg_base]
    mov rbx, r12
    mov [rax], rbx
    
    ; Ring doorbell
    mov rax, [sev_doorbell_reg]
    mov dword [rax], 1
    
    ; Poll for completion
.wait_completion:
    mov rax, [sev_status_reg]
    mov ebx, [rax]
    test ebx, 1               ; Check busy bit
    jnz .wait_completion
    
    ; Check error code
    shr ebx, 16
    and ebx, 0xFFFF
    
    ret                       ; Error code in EBX
```

**SEV VM Launch Flow:**

```nasm
launch_sev_vm:
    ; Phase 1: LAUNCH_START
    ; Creates new key for VM, generates measurement
    
    lea rbx, [launch_start_params]
    mov dword [rbx + 0], 0    ; Policy (debug, migration settings)
    mov qword [rbx + 4], 0    ; Guest handle (output)
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_LAUNCH_START
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    test ebx, ebx
    jnz .error
    
    ; Save guest handle
    mov rax, [rbx + 4]
    mov [guest_handle], rax
    
    ; Phase 2: LAUNCH_UPDATE_DATA
    ; Encrypt guest pages and extend measurement
    
    mov rcx, [num_guest_pages]
    xor r13, r13              ; Page index
    
.update_pages:
    lea rbx, [launch_update_params]
    mov rax, [guest_handle]
    mov [rbx + 0], rax        ; Guest handle
    mov rax, [guest_pages + r13*8]
    mov [rbx + 8], rax        ; Page physical address
    mov dword [rbx + 16], 4096 ; Length
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_LAUNCH_UPDATE_DATA
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    test ebx, ebx
    jnz .error
    
    inc r13
    cmp r13, [num_guest_pages]
    jl .update_pages
    
    ; Phase 3: LAUNCH_FINISH
    ; Finalizes measurement and activates VM
    
    lea rbx, [launch_finish_params]
    mov rax, [guest_handle]
    mov [rbx + 0], rax
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_LAUNCH_FINISH
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    test ebx, ebx
    jnz .error
    
    ; VM can now be started
    xor rax, rax
    ret
    
.error:
    ; Error code in EBX
    mov rax, rbx
    neg rax
    ret
```

### SEV-ES (Encrypted State)

SEV-ES extends SEV by also encrypting VM register state, preventing hypervisor from inspecting or modifying guest registers.

**VMSA (Virtual Machine Saving Area):**

Guest register state is encrypted and stored in VMSA:

```nasm
; VMSA structure (simplified)
struc VMSA
    .es:            resw 1
    .cs:            resw 1
    .ss:            resw 1
    .ds:            resw 1
    ; ... all segment registers
    
    .rax:           resq 1
    .rcx:           resq 1
    .rdx:           resq 1
    ; ... all general purpose registers
    
    .rip:           resq 1
    .rflags:        resq 1
    
    ; Control registers
    .cr0:           resq 1
    .cr3:           resq 1
    .cr4:           resq 1
    
    ; ... complete processor state
endstruc

setup_sev_es_vm:
    ; Allocate encrypted VMSA page
    call allocate_page
    mov r12, rax              ; Physical address
    
    ; Mark page as VMSA using SEV command
    lea rbx, [vmsa_create_params]
    mov [rbx + 0], r12        ; VMSA physical address
    mov rax, [guest_handle]
    mov [rbx + 8], rax        ; Guest handle
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_LAUNCH_UPDATE_VMSA
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    
    ; Initialize guest state in VMSA
    ; (Hypervisor can write during setup, encrypted after launch)
    
    ret
```

**GHCB (Guest-Hypervisor Communication Block):**

Since hypervisor can't see registers, explicit communication channel needed:

```nasm
; GHCB structure
struc GHCB
    .reserved1:     resb 0xC00
    
    ; Guest-visible registers for communication
    .rax:           resq 1
    .rbx:           resq 1
    .rcx:           resq 1
    .rdx:           resq 1
    
    ; Exit information
    .exitcode:      resq 1
    .exitinfo1:     resq 1
    .exitinfo2:     resq 1
    
    ; Protocol version
    .version:       resd 1
    
    ; Validation bitmap
    .valid_bitmap:  resq 1
    
    ; ... more fields
endstruc

; Guest requests hypervisor service via GHCB
sev_es_hypercall:
    ; R12 = hypercall number
    ; R13 = parameter 1
    ; R14 = parameter 2
    
    ; Write to GHCB
    mov rbx, [ghcb_page]
    mov [rbx + GHCB.rax], r12
    mov [rbx + GHCB.rcx], r13
    mov [rbx + GHCB.rdx], r14
    
    ; Set valid bits
    mov qword [rbx + GHCB.valid_bitmap], 0x7  ; RAX, RCX, RDX valid
    
    ; Execute VMGEXIT to exit to hypervisor
    rep vmmcall               ; SEV-ES VMGEXIT instruction
    
    ; Read result from GHCB
    mov rax, [rbx + GHCB.rax]
    
    ret
```

### SEV-SNP (Secure Nested Paging)

SEV-SNP adds integrity protection and prevents replay attacks on guest memory through Reverse Map Table (RMP).

**RMP (Reverse Map Table):**

Hardware-enforced table that tracks ownership and state of every physical page:

```nasm
; RMP Entry (16 bytes per 4KB page)
struc RMP_ENTRY
    .assigned:      resb 1    ; 1 if assigned to guest
    .asid:          resw 1    ; Owner ASID
    .vmsa:          resb 1    ; 1 if page is VMSA
    .validated:     resb 1    ; 1 if guest validated page
    .gpa:           resq 1    ; Guest physical address
    .reserved:      resb 5
endstruc

; RMP is maintained by processor hardware
; Hypervisor cannot bypass RMP checks

; Page state transitions tracked automatically:
; 1. Hypervisor assigns page to guest -> RMP.assigned=1, RMP.asid=guest_asid
; 2. Guest validates page -> RMP.validated=1
; 3. Guest access allowed only if RMP.asid matches current ASID
; 4. Hypervisor cannot modify validated pages
```

**PVALIDATE Instruction:**

Guest explicitly validates pages:

```nasm
; Inside SEV-SNP guest
validate_guest_page:
    ; R12 = virtual address of page to validate
    ; R13 = page size (0=4KB, 1=2MB)
    
    mov rax, r12
    mov rcx, r13
    
    ; PVALIDATE instruction
    ; RAX = virtual address
    ; RCX = page size
    ; After execution:
    ; CF=0 if successful
    ; RMP entry marked as validated
    
    pvalidate
    jc .validation_failed
    
    ; Page is now validated and protected
    ret
    
.validation_failed:
    ; Page could not be validated
    ; (Wrong size, not assigned to this guest, etc.)
    ret
```

**RMPUPDATE Instruction:**

Hypervisor updates RMP entries:

```nasm
; Hypervisor assigns page to guest
assign_page_to_sev_snp_guest:
    ; R12 = physical address
    ; R13 = guest ASID
    ; R14 = guest physical address
    
    ; Build RMP update structure
    lea rbx, [rmp_update_params]
    mov qword [rbx + 0], r12        ; Physical address
    mov word [rbx + 8], r13         ; ASID
    mov qword [rbx + 10], r14       ; Guest physical address
    mov byte [rbx + 18], 1          ; Mark as assigned
    mov byte [rbx + 19], 0          ; Not VMSA
    
    ; Execute RMPUPDATE
    ; RCX = physical address
    ; RDX = parameter structure
    
    mov rcx, r12
    lea rdx, [rmp_update_params]
    
    rmpupdate
    jc .update_failed
    
    ; RMP entry updated successfully
    ; Page now owned by guest
    ret
    
.update_failed:
    ; Could not update RMP
    ; (Page already assigned, invalid params, etc.)
    mov rax, -1
    ret
```

**RMPADJUST Instruction:**

Guest requests permission changes on its own pages:

```nasm
; Inside SEV-SNP guest
adjust_page_permissions:
    ; R12 = virtual address
    ; R13 = new permissions (R/W/X bits)
    
    mov rax, r12
    mov rcx, r13
    
    ; RMPADJUST instruction
    ; Updates RMP entry for guest-owned page
    rmpadjust
    jc .adjust_failed
    
    ; Permissions updated
    ret
    
.adjust_failed:
    ; Permission adjustment failed
    ret
```

**SEV-SNP Attestation:**

SEV-SNP provides cryptographic attestation reports that prove VM configuration:

```nasm
; Inside SEV-SNP guest
request_attestation_report:
    ; R12 = 64-byte user data
    ; R13 = output report buffer (4KB)
    
    ; Use GHCB to request report from PSP
    mov rbx, [ghcb_page]
    
    ; Set up GHCB for attestation request
    mov qword [rbx + GHCB.rax], 0x80000000  ; SNP_GUEST_REQUEST
    mov [rbx + GHCB.rcx], r12                ; User data pointer
    mov [rbx + GHCB.rdx], r13                ; Report buffer
    
    mov qword [rbx + GHCB.valid_bitmap], 0x7
    
    ; Request report from PSP
    rep vmmcall
    
    ; Report structure contains:
    ; - Launch measurement
    ; - Current TCB version
    ; - Platform certificate chain
    ; - Signature over report
    
    ; Check if successful
    mov rax, [rbx + GHCB.rax]
    test rax, rax
    jnz .report_failed
    
    ; Attestation report available in buffer
    ret
    
.report_failed:
    ; Report generation failed
    ret
```

**SEV-SNP Report Structure:**

```nasm
struc SEV_SNP_REPORT
    .version:           resd 1      ; Report version
    .guest_svn:         resd 1      ; Guest security version
    .policy:            resq 1      ; Guest policy
    
    .family_id:         resb 16     ; Family ID
    .image_id:          resb 16     ; Image ID
    
    .vmpl:              resd 1      ; VM Privilege Level
    .signature_algo:    resd 1      ; Signature algorithm
    
    .current_tcb:       resq 1      ; Current TCB version
    .platform_info:     resq 1      ; Platform information
    
    .author_key_en:     resd 1      ; Author key enabled
    .reserved1:         resd 1
    
    .report_data:       resb 64     ; User-provided data
    
    .measurement:       resb 48     ; Launch measurement
    .host_data:         resb 32     ; Hypervisor-provided data
    .id_key_digest:     resb 48     ; ID key digest
    .author_key_digest: resb 48     ; Author key digest
    
    .report_id:         resb 32     ; Report ID
    .report_id_ma:      resb 32     ; Report ID (migration agent)
    
    .reported_tcb:      resq 1      ; Reported TCB version
    .reserved2:         resb 24
    
    .chip_id:           resb 64     ; Chip identifier
    
    .reserved3:         resb 192
    
    .signature:         resb 512    ; ECDSA P-384 signature
endstruc
```

### Migration and Key Management

**SEV Key Derivation:**

Each VM's encryption key is derived from:

- Platform root key (fused into processor)
- Guest ASID
- Additional entropy

```nasm
; Keys are managed by processor, not directly accessible
; Key hierarchy:
; - Root key (hardware fused, never visible)
;   - Per-ASID derived keys (generated on-demand)
;     - Per-page encryption keys (derived from ASID key + address)

; Conceptual key derivation (hardware internal):
derive_page_key:
    ; Inputs (internal to processor):
    ; - ASID key
    ; - Physical address
    ; - Page size
    
    ; Output: AES-128 key for this specific page
    ; Uses AES-based key derivation
    
    ; This ensures:
    ; 1. Each VM has unique keys
    ; 2. Each page has unique key (diffusion)
    ; 3. Keys never leave CPU package
    
    ret
```

**Live Migration with SEV:**

```nasm
; Source platform prepares VM for migration
migrate_sev_vm_source:
    ; Phase 1: SEND_START
    ; Negotiates with destination, exports key material
    
    lea rbx, [send_start_params]
    mov rax, [guest_handle]
    mov [rbx + 0], rax                    ; Guest handle
    lea rcx, [dest_cert]
    mov [rbx + 8], rcx                    ; Destination certificate
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_SEND_START
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    test ebx, ebx
    jnz .error
    
    ; Session established
    mov rax, [rbx + 16]
    mov [session_handle], rax
    
    ; Phase 2: Encrypt and send VM pages
    mov rcx, [num_pages]
    xor r13, r13
    
.send_pages:
    ; SEND_UPDATE_DATA encrypts page for transport
    lea rbx, [send_update_params]
    mov rax, [session_handle]
    mov [rbx + 0], rax
    mov rax, [page_list + r13*8]
    mov [rbx + 8], rax                    ; Page to send
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_SEND_UPDATE_DATA
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    test ebx, ebx
    jnz .error
    
    ; Send encrypted page to destination
    mov rdi, [dest_connection]
    lea rsi, [encrypted_page_buffer]
    mov rdx, 4096
    call network_send
    
    inc r13
    cmp r13, [num_pages]
    jl .send_pages
    
    ; Phase 3: SEND_FINISH
    lea rbx, [send_finish_params]
    mov rax, [session_handle]
    mov [rbx + 0], rax
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_SEND_FINISH
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    
    ret
    
.error:
    ; Migration failed
    ret

; Destination platform receives migrated VM
migrate_sev_vm_dest:
    ; Phase 1: RECEIVE_START
    ; Establishes session with source
    
    lea rbx, [receive_start_params]
    lea rcx, [source_session_data]
    mov [rbx + 0], rcx
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_RECEIVE_START
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    test ebx, ebx
    jnz .error
    
    mov rax, [rbx + 8]
    mov [session_handle], rax
    
    ; Phase 2: Receive and decrypt pages
.receive_pages:
    ; Receive encrypted page from source
    mov rdi, [source_connection]
    lea rsi, [encrypted_page_buffer]
    mov rdx, 4096
    call network_receive
    
    ; RECEIVE_UPDATE_DATA decrypts page
    lea rbx, [receive_update_params]
    mov rax, [session_handle]
    mov [rbx + 0], rax
    lea rcx, [encrypted_page_buffer]
    mov [rbx + 8], rcx
    mov rax, [dest_page_addr]
    mov [rbx + 16], rax
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_RECEIVE_UPDATE_DATA
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    test ebx, ebx
    jnz .error
    
    ; Continue receiving pages...
    cmp byte [all_pages_received], 1
    jne .receive_pages
    
    ; Phase 3: RECEIVE_FINISH
    ; Finalizes migration, VM can now run on destination
    
    lea rbx, [receive_finish_params]
    mov rax, [session_handle]
    mov [rbx + 0], rax
    
    lea rcx, [sev_cmd]
    mov dword [rcx + SEV_CMD.command], SEV_CMD_RECEIVE_FINISH
    mov qword [rcx + SEV_CMD.paddr], rbx
    
    mov r12, rcx
    call submit_sev_command
    
    ret
    
.error:
    ; Migration failed
    ret
```

### Performance Considerations

**SME/SEV Performance Impact:**

Memory encryption adds latency to memory operations:

```nasm
; Encryption/decryption happens at memory controller
; Impact:
; - 1-5% performance overhead for SME
; - 2-10% overhead for SEV (varies by workload)
; - Higher overhead for memory-intensive applications

; Optimization: Batch memory operations
optimized_memory_copy:
    ; Use large transfers to amortize encryption overhead
    mov rcx, [size]
    shr rcx, 6                ; Divide by 64 bytes
    
.copy_loop:
    ; Copy 64 bytes at a time (cache line)
    movdqa xmm0, [rsi]
    movdqa xmm1, [rsi + 16]
    movdqa xmm2, [rsi + 32]
    movdqa xmm3, [rsi + 48]
    
    movdqa [rdi], xmm0
    movdqa [rdi + 16], xmm1
    movdqa [rdi + 32], xmm2
    movdqa [rdi + 48], xmm3
    
    add rsi, 64
    add rdi, 64
    loop .copy_loop
    
    ret
```

**Cache Behavior:**

Encrypted data is stored in cache in encrypted form:

```nasm
; Cache contains encrypted data
; Decryption happens on cache fill
; Encryption happens on cache writeback

; This prevents:
; - Cache side-channel attacks between VMs
; - Physical probing of cache

; But means:
; - Cache pollution across context switches minimized
; - Different ASIDs can't share cache lines
```

### Platform Security Processor (PSP)

The PSP is an ARM TrustZone-based secure processor that manages SEV operations:

```nasm
; PSP responsibilities:
; - Generate and manage encryption keys
; - Perform cryptographic operations
; - Enforce security policies
; - Maintain platform state
; - Handle attestation requests

; PSP Communication:
; x86 CPU -> PSP mailbox registers -> PSP firmware

write_psp_mailbox:
    ; R12 = command buffer physical address
    ; R13 = command ID
    
    ; Wait for PSP ready
    mov rax, [psp_status_reg]
.wait_ready:
    mov ebx, [rax]
    test ebx, 0x80000000      ; Check ready bit
    jz .wait_ready
    
    ; Write command buffer address
    mov rax, [psp_cmd_buf_reg]
    mov [rax], r12
    
    ; Write command ID and trigger
    mov rax, [psp_cmd_reg]
    mov [rax], r13d
    
    ; PSP processes command asynchronously
    ret

read_psp_response:
    ; Poll for completion
    mov rax, [psp_status_reg]
.wait_complete:
    mov ebx, [rax]
    test ebx, 0x40000000      ; Check complete bit
    jz .wait_complete
    
    ; Check error code
    and ebx, 0xFFFF
    
    ; Read response data from command buffer
    mov rax, [psp_cmd_buf_reg]
    mov rsi, [rax]
    
    ret                       ; Error code in EBX
```

### Comparison: SGX vs SEV

**Trust Model:**

```nasm
; SGX: Trust CPU only
; - Enclave protected from OS, hypervisor, hardware (except CPU)
; - Small TCB (Trusted Computing Base)
; - Application-level isolation

; SEV: Trust CPU and hypervisor owner
; - VM protected from physical attacks and other VMs
; - Larger TCB (includes hypervisor)
; - VM-level isolation

; Use cases:
; SGX: Sensitive computation in untrusted environment
;      (cloud processing of encrypted data)

; SEV: Confidential VMs
;      (multi-tenant cloud isolation)
```

**Memory Protection:**

```nasm
; SGX:
; - EPC limited size (128MB typical)
; - Page-level encryption with integrity
; - Explicit enclave boundaries
; - Swapping requires re-encryption

; SEV:
; - Entire VM memory encrypted
; - No size limit (full RAM)
; - Transparent to guest OS
; - Migration supported with re-keying
```

**Performance Characteristics:**

```nasm
; SGX:
; - Enclave entry/exit overhead (EENTER/EEXIT)
; - Limited EPC causes paging overhead
; - Good for small working sets
; - Vulnerable to side channels (cache timing, page faults)

; SEV:
; - Minimal overhead (~2-5%)
; - No special paging overhead
; - Scales to large workloads
; - Protected from cross-VM side channels
```

### Detecting Hardware Features

**Comprehensive Feature Detection:**

```nasm
detect_security_features:
    ; Initialize feature flags
    xor r15, r15
    
    ; Check for HTM (TSX)
    mov eax, 7
    xor ecx, ecx
    cpuid
    
    test ebx, (1 << 4)        ; HLE
    jz .no_hle
    or r15, FEATURE_HLE
    
.no_hle:
    test ebx, (1 << 11)       ; RTM
    jz .no_rtm
    or r15, FEATURE_RTM
    
.no_rtm:
    ; Check for SGX
    mov eax, 7
    xor ecx, ecx
    cpuid
    
    test ebx, (1 << 2)        ; SGX
    jz .no_sgx
    or r15, FEATURE_SGX
    
    ; Check SGX capabilities
    mov eax, 0x12
    xor ecx, ecx
    cpuid
    
    ; EAX bit 0 = SGX1 support
    ; EAX bit 1 = SGX2 support
    test eax, 1
    jz .no_sgx
    or r15, FEATURE_SGX1
    
    test eax, 2
    jz .no_sgx2
    or r15, FEATURE_SGX2
    
.no_sgx2:
.no_sgx:
    ; Check for AMD SME/SEV
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x8000001F       ; Check max extended function
    jl .no_sme
    
    mov eax, 0x8000001F
    cpuid
    
    test eax, (1 << 0)        ; SME
    jz .no_sme
    or r15, FEATURE_SME
    
    ; Extract C-bit position
    mov ecx, ebx
    and ecx, 0x3F
    mov [c_bit_pos], ecx
    
    test eax, (1 << 1)        ; SEV
    jz .no_sev
    or r15, FEATURE_SEV
    
    test eax, (1 << 3)        ; SEV-ES
    jz .no_sev_es
    or r15, FEATURE_SEV_ES
    
.no_sev_es:
    test eax, (1 << 4)        ; SEV-SNP
    jz .no_sev_snp
    or r15, FEATURE_SEV_SNP
    
.no_sev_snp:
.no_sev:
.no_sme:
    ; Return feature bitmap in R15
    mov rax, r15
    ret

; Feature bit definitions
FEATURE_HLE       = (1 << 0)
FEATURE_RTM       = (1 << 1)
FEATURE_SGX       = (1 << 2)
FEATURE_SGX1      = (1 << 3)
FEATURE_SGX2      = (1 << 4)
FEATURE_SME       = (1 << 5)
FEATURE_SEV       = (1 << 6)
FEATURE_SEV_ES    = (1 << 7)
FEATURE_SEV_SNP   = (1 << 8)
```

**Key Points:**

- Hardware Transactional Memory (TSX) provides lock-free synchronization through speculative execution with automatic conflict detection and rollback
- Transactions abort on capacity limits, conflicts, or incompatible operations; fallback paths with traditional locking are essential
- Intel SGX creates isolated execution environments (enclaves) with hardware-enforced memory encryption and integrity protection
- SGX attestation proves enclave identity cryptographically; sealing enables secure persistent storage
- AMD SME encrypts system memory transparently using a per-page C-bit to control encryption
- SEV extends SME to give each VM a unique encryption key, isolating VM memory from hypervisor and other VMs
- SEV-ES encrypts VM register state; SEV-SNP adds integrity protection via hardware-maintained Reverse Map Table
- SGX provides stronger isolation (protects from OS/hypervisor) but with limited enclave size; SEV provides VM-level isolation with minimal overhead
- All three technologies address different threat models: TSX for concurrent programming, SGX for application-level secrets, SEV for VM isolation

**Related topics:** Intel TDX (Trust Domain Extensions - next generation VM isolation), MKTME (Multi-Key Total Memory Encryption), Hardware Side-Channel Mitigations (IBRS, STIBP), Memory Tagging Extensions (MTE), Cache Allocation Technology (CAT) for isolation

---

# Code Generation

Code generation transforms high-level intermediate representations into executable x86 machine code through systematic instruction selection, register allocation, and optimization. This process forms the backend of compilers and requires deep understanding of x86 architecture constraints and performance characteristics.

## Compiler Backend Concepts

The compiler backend converts intermediate representation (IR) to target machine code through multiple phases: instruction selection, register allocation, instruction scheduling, and code emission.

### Intermediate Representation (IR)

```asm
; Example: Three-address code IR representation
; IR: t1 = a + b
;     t2 = t1 * c
;     d = t2 - 5

; Data structures for IR (pseudo-assembly representation)
struc IRInstruction
    .opcode:    resd 1  ; ADD, MUL, SUB, etc.
    .dest:      resd 1  ; Destination operand
    .src1:      resd 1  ; Source operand 1
    .src2:      resd 1  ; Source operand 2
    .type:      resd 1  ; Data type
endstruc

; IR operations enumeration
%define IR_ADD      1
%define IR_SUB      2
%define IR_MUL      3
%define IR_DIV      4
%define IR_LOAD     5
%define IR_STORE    6
%define IR_MOV      7
%define IR_CMP      8
%define IR_JUMP     9
%define IR_CALL     10

; Virtual register representation
struc VirtualReg
    .id:        resd 1  ; Unique identifier
    .type:      resd 1  ; INT32, INT64, FLOAT, etc.
    .live_start: resd 1 ; First instruction using this register
    .live_end:  resd 1  ; Last instruction using this register
    .physical:  resd 1  ; Assigned physical register (-1 if spilled)
    .spill_slot: resd 1 ; Stack offset if spilled
endstruc
```

### Basic Block Structure

```asm
; Basic block: sequence of instructions with single entry/exit
struc BasicBlock
    .id:            resd 1  ; Block identifier
    .instructions:  resd 1  ; Pointer to instruction array
    .inst_count:    resd 1  ; Number of instructions
    .predecessors:  resd 1  ; Pointer to predecessor list
    .successors:    resd 1  ; Pointer to successor list
    .live_in:       resd 1  ; Live-in register set
    .live_out:      resd 1  ; Live-out register set
endstruc

; Build basic blocks from IR
build_basic_blocks:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; IR instruction array
    mov ecx, [ebp + 12] ; Instruction count
    mov edi, [ebp + 16] ; Output basic block array
    
    xor ebx, ebx        ; Current block index
    mov [current_block_start], esi
    
.scan_instructions:
    ; Check if instruction is a leader (starts new block)
    ; Leaders: first instruction, jump targets, after jumps
    
    mov eax, [esi + IRInstruction.opcode]
    
    ; Check for branch instruction
    cmp eax, IR_JUMP
    je .end_block
    cmp eax, IR_CALL
    je .potential_end_block
    
    add esi, IRInstruction_size
    loop .scan_instructions
    jmp .finish_last_block
    
.end_block:
    ; Finalize current block
    call finalize_block
    inc ebx
    add esi, IRInstruction_size
    mov [current_block_start], esi
    loop .scan_instructions
    
.potential_end_block:
    ; Call doesn't always end block
    add esi, IRInstruction_size
    loop .scan_instructions
    
.finish_last_block:
    call finalize_block
    
    mov eax, ebx        ; Return number of blocks
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

current_block_start: dd 0
```

### Control Flow Graph (CFG)

```asm
; Build CFG by connecting basic blocks
build_cfg:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Basic block array
    mov ecx, [ebp + 12] ; Number of blocks
    
.process_blocks:
    push ecx
    
    ; Get last instruction of current block
    mov eax, [esi + BasicBlock.instructions]
    mov edx, [esi + BasicBlock.inst_count]
    dec edx
    imul edx, IRInstruction_size
    add eax, edx
    
    ; Check instruction type
    mov ebx, [eax + IRInstruction.opcode]
    
    cmp ebx, IR_JUMP
    je .handle_jump
    
    ; Fall-through to next block
    mov edi, esi
    add edi, BasicBlock_size
    call add_successor
    jmp .next_block
    
.handle_jump:
    ; Add target block as successor
    mov edi, [eax + IRInstruction.dest]
    call add_successor
    
.next_block:
    add esi, BasicBlock_size
    pop ecx
    loop .process_blocks
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Add successor/predecessor edge
add_successor:
    push eax
    push ecx
    
    ; Add EDI to ESI's successor list
    mov eax, [esi + BasicBlock.successors]
    ; [Inference] Append to linked list or array
    
    ; Add ESI to EDI's predecessor list
    mov eax, [edi + BasicBlock.predecessors]
    
    pop ecx
    pop eax
    ret
```

### Liveness Analysis

```asm
; Compute live ranges for virtual registers
compute_liveness:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Basic block array
    mov ecx, [ebp + 12] ; Number of blocks
    
    ; Initialize live sets
    call initialize_live_sets
    
    ; Iterate until fixed point
.iterate:
    mov byte [changed_flag], 0
    mov ecx, [ebp + 12]
    mov esi, [ebp + 8]
    
.process_block:
    push ecx
    push esi
    
    ; Compute live-out from successors
    call compute_live_out
    
    ; Compute live-in from live-out
    call compute_live_in
    
    pop esi
    add esi, BasicBlock_size
    pop ecx
    loop .process_block
    
    ; Check if any sets changed
    cmp byte [changed_flag], 0
    jne .iterate
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

changed_flag: db 0

; Compute live-out = union of successors' live-in
compute_live_out:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edi
    
    mov edi, [esi + BasicBlock.live_out]
    mov ebx, [esi + BasicBlock.successors]
    
    ; For each successor
.loop_successors:
    ; Check if successor exists
    cmp dword [ebx], 0
    je .done
    
    mov eax, [ebx]      ; Get successor block
    mov ecx, [eax + BasicBlock.live_in]
    
    ; Union with current live-out
    call set_union
    
    add ebx, 4
    jmp .loop_successors
    
.done:
    pop edi
    pop ecx
    pop ebx
    pop ebp
    ret

; Compute live-in = use ∪ (live-out - def)
compute_live_in:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    ; Get instruction use and def sets
    call compute_use_def_sets
    
    ; live_in_new = use ∪ (live_out - def)
    mov esi, [esp + 20]             ; Original ESI (block pointer)
    mov edi, [esi + BasicBlock.live_in]
    mov eax, [esi + BasicBlock.live_out]
    mov ebx, [def_set]
    
    ; Subtract def from live_out
    call set_difference
    
    ; Union with use set
    mov ebx, [use_set]
    call set_union
    
    ; Check if changed
    ; [Inference] Compare old and new live-in sets
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret

use_set: dd 0
def_set: dd 0

; Compute use and def sets for a basic block
compute_use_def_sets:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    
    ; Allocate sets
    call allocate_register_set
    mov [use_set], eax
    call allocate_register_set
    mov [def_set], eax
    
    mov esi, [esp + 20]             ; Block pointer
    mov ecx, [esi + BasicBlock.inst_count]
    mov esi, [esi + BasicBlock.instructions]
    
.scan_instructions:
    ; Get instruction operands
    mov eax, [esi + IRInstruction.src1]
    cmp eax, -1
    je .check_src2
    
    ; If src1 not in def set, add to use set
    push ecx
    mov ebx, [def_set]
    call set_contains
    test al, al
    jnz .check_src2
    
    mov ebx, [use_set]
    mov eax, [esi + IRInstruction.src1]
    call set_add
    pop ecx
    
.check_src2:
    mov eax, [esi + IRInstruction.src2]
    cmp eax, -1
    je .check_dest
    
    push ecx
    mov ebx, [def_set]
    call set_contains
    test al, al
    jnz .check_dest
    
    mov ebx, [use_set]
    mov eax, [esi + IRInstruction.src2]
    call set_add
    pop ecx
    
.check_dest:
    ; Add destination to def set
    mov eax, [esi + IRInstruction.dest]
    cmp eax, -1
    je .next_instruction
    
    push ecx
    mov ebx, [def_set]
    call set_add
    pop ecx
    
.next_instruction:
    add esi, IRInstruction_size
    loop .scan_instructions
    
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret
```

## Instruction Selection

Instruction selection maps IR operations to target machine instructions, considering addressing modes, instruction costs, and architectural constraints.

### Tree Pattern Matching

```asm
; Instruction patterns for x86
struc InstPattern
    .ir_opcode:     resd 1  ; IR operation
    .operand_types: resd 2  ; Source operand constraints
    .x86_template:  resd 1  ; Pointer to x86 instruction template
    .cost:          resd 1  ; Cost metric (cycles, code size, etc.)
endstruc

; Pattern table
instruction_patterns:
    ; ADD patterns
    istruc InstPattern
        at InstPattern.ir_opcode,     dd IR_ADD
        at InstPattern.operand_types, dd OP_REG, OP_REG
        at InstPattern.x86_template,  dd template_add_reg_reg
        at InstPattern.cost,          dd 1
    iend
    
    istruc InstPattern
        at InstPattern.ir_opcode,     dd IR_ADD
        at InstPattern.operand_types, dd OP_REG, OP_IMM
        at InstPattern.x86_template,  dd template_add_reg_imm
        at InstPattern.cost,          dd 1
    iend
    
    istruc InstPattern
        at InstPattern.ir_opcode,     dd IR_ADD
        at InstPattern.operand_types, dd OP_REG, OP_MEM
        at InstPattern.x86_template,  dd template_add_reg_mem
        at InstPattern.cost,          dd 3
    iend
    
    ; MUL patterns
    istruc InstPattern
        at InstPattern.ir_opcode,     dd IR_MUL
        at InstPattern.operand_types, dd OP_REG, OP_REG
        at InstPattern.x86_template,  dd template_imul_reg_reg
        at InstPattern.cost,          dd 3
    iend
    
    ; More patterns...
    dd 0  ; Sentinel

%define OP_REG  1
%define OP_IMM  2
%define OP_MEM  3

; Select best instruction pattern
select_instruction:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; IR instruction pointer
    
    ; Get IR opcode
    mov eax, [esi + IRInstruction.opcode]
    
    ; Search pattern table
    mov edi, instruction_patterns
    mov ebx, -1         ; Best pattern index
    mov edx, 9999       ; Best cost
    
.search_patterns:
    cmp dword [edi + InstPattern.ir_opcode], 0
    je .done
    
    ; Check if opcode matches
    cmp eax, [edi + InstPattern.ir_opcode]
    jne .next_pattern
    
    ; Check operand types
    call check_operand_match
    test al, al
    jz .next_pattern
    
    ; Check if cost is better
    mov ecx, [edi + InstPattern.cost]
    cmp ecx, edx
    jae .next_pattern
    
    ; Update best pattern
    mov edx, ecx
    mov ebx, edi
    
.next_pattern:
    add edi, InstPattern_size
    jmp .search_patterns
    
.done:
    mov eax, ebx        ; Return best pattern
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Check if operands match pattern constraints
check_operand_match:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    ; ESI = IR instruction, EDI = pattern
    
    ; Check src1 type
    mov eax, [esi + IRInstruction.src1]
    call get_operand_type
    mov ebx, eax
    
    cmp ebx, [edi + InstPattern.operand_types]
    jne .no_match
    
    ; Check src2 type
    mov eax, [esi + IRInstruction.src2]
    call get_operand_type
    mov ebx, eax
    
    cmp ebx, [edi + InstPattern.operand_types + 4]
    jne .no_match
    
    mov al, 1           ; Match
    jmp .done
    
.no_match:
    xor al, al
    
.done:
    pop esi
    pop ebx
    pop ebp
    ret

; Determine operand type (register, immediate, memory)
get_operand_type:
    push ebx
    
    ; Check if immediate (constant)
    cmp eax, 0x10000000
    jb .is_immediate
    
    ; Check if memory reference
    ; [Inference] Memory operands have special encoding
    
    ; Default to register
    mov al, OP_REG
    jmp .done
    
.is_immediate:
    mov al, OP_IMM
    
.done:
    pop ebx
    ret
```

### DAG-Based Instruction Selection

```asm
; Expression tree node
struc ExprNode
    .opcode:    resd 1  ; Operation
    .left:      resd 1  ; Left child pointer
    .right:     resd 1  ; Right child pointer
    .value:     resd 1  ; Constant value (for leaves)
    .reg:       resd 1  ; Assigned register
    .cost:      resd 1  ; Cost to compute
endstruc

; Bottom-up tree matching with dynamic programming
select_dag_instructions:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Expression tree root
    
    ; Compute costs bottom-up
    call compute_tree_costs
    
    ; Generate code top-down
    call emit_tree_code
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Compute minimum cost for subtree
compute_tree_costs:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov esi, [ebp + 8]  ; Tree node
    
    ; Check if leaf node
    cmp dword [esi + ExprNode.left], 0
    je .leaf_node
    
    ; Recursively compute children costs
    push dword [esi + ExprNode.left]
    call compute_tree_costs
    add esp, 4
    
    push dword [esi + ExprNode.right]
    call compute_tree_costs
    add esp, 4
    
    ; Compute this node's cost
    mov eax, [esi + ExprNode.opcode]
    
    ; Example: ADD costs
    cmp eax, IR_ADD
    je .compute_add_cost
    
    ; Example: MUL costs
    cmp eax, IR_MUL
    je .compute_mul_cost
    
    jmp .done
    
.compute_add_cost:
    ; Cost = left_cost + right_cost + 1
    mov ebx, [esi + ExprNode.left]
    mov eax, [ebx + ExprNode.cost]
    mov ebx, [esi + ExprNode.right]
    add eax, [ebx + ExprNode.cost]
    inc eax
    mov [esi + ExprNode.cost], eax
    jmp .done
    
.compute_mul_cost:
    ; Cost = left_cost + right_cost + 3
    mov ebx, [esi + ExprNode.left]
    mov eax, [ebx + ExprNode.cost]
    mov ebx, [esi + ExprNode.right]
    add eax, [ebx + ExprNode.cost]
    add eax, 3
    mov [esi + ExprNode.cost], eax
    jmp .done
    
.leaf_node:
    ; Leaf has cost 0 (already in register or immediate)
    mov dword [esi + ExprNode.cost], 0
    
.done:
    pop esi
    pop ebx
    pop ebp
    ret

; Emit code for expression tree
emit_tree_code:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Tree node
    
    ; Check if leaf
    cmp dword [esi + ExprNode.left], 0
    je .emit_leaf
    
    ; Emit left subtree
    push dword [esi + ExprNode.left]
    call emit_tree_code
    add esp, 4
    mov ebx, eax        ; Left result register
    
    ; Emit right subtree
    push dword [esi + ExprNode.right]
    call emit_tree_code
    add esp, 4
    mov ecx, eax        ; Right result register
    
    ; Emit operation
    mov eax, [esi + ExprNode.opcode]
    
    cmp eax, IR_ADD
    je .emit_add
    cmp eax, IR_MUL
    je .emit_mul
    
    jmp .done
    
.emit_add:
    ; Generate: add ebx, ecx
    call allocate_register
    mov edi, eax
    
    ; Emit x86 instruction
    push ecx            ; Source
    push ebx            ; Destination
    push edi            ; Result register
    call emit_add_instruction
    add esp, 12
    
    mov eax, edi
    jmp .done
    
.emit_mul:
    call allocate_register
    mov edi, eax
    
    push ecx
    push ebx
    push edi
    call emit_imul_instruction
    add esp, 12
    
    mov eax, edi
    jmp .done
    
.emit_leaf:
    ; Load constant or return register
    mov eax, [esi + ExprNode.reg]
    
.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

### Complex Addressing Mode Selection

```asm
; Select optimal x86 addressing mode for memory access
; x86 supports: [base + index*scale + disp]
select_addressing_mode:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Address expression tree
    
    ; Initialize addressing components
    xor eax, eax
    mov [addr_base], eax
    mov [addr_index], eax
    mov [addr_scale], eax
    mov [addr_disp], eax
    
    ; Pattern match for array access: base + index * scale + offset
    mov eax, [esi + ExprNode.opcode]
    cmp eax, IR_ADD
    jne .simple_address
    
    ; Check for scaled index
    mov ebx, [esi + ExprNode.right]
    mov eax, [ebx + ExprNode.opcode]
    cmp eax, IR_MUL
    je .has_scaled_index
    
    ; Simple base + offset
    mov eax, [esi + ExprNode.left]
    mov [addr_base], eax
    mov eax, [esi + ExprNode.right]
    mov [addr_disp], eax
    jmp .emit_address
    
.has_scaled_index:
    ; Extract scale (must be 1, 2, 4, or 8)
    mov ecx, [ebx + ExprNode.right]
    mov eax, [ecx + ExprNode.value]
    
    ; Validate scale
    cmp eax, 1
    je .scale_valid
    cmp eax, 2
    je .scale_valid
    cmp eax, 4
    je .scale_valid
    cmp eax, 8
    je .scale_valid
    
    ; Invalid scale, fall back to simple address
    jmp .simple_address
    
.scale_valid:
    mov [addr_scale], eax
    
    ; Extract index register
    mov ecx, [ebx + ExprNode.left]
    mov [addr_index], ecx
    
    ; Extract base
    mov eax, [esi + ExprNode.left]
    mov [addr_base], eax
    
    jmp .emit_address
    
.simple_address:
    ; Just use base register
    mov eax, esi
    mov [addr_base], eax
    
.emit_address:
    ; Construct addressing mode
    ; Returns encoded addressing mode in EAX
    call encode_addressing_mode
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

addr_base:  dd 0
addr_index: dd 0
addr_scale: dd 0
addr_disp:  dd 0

; Encode x86 addressing mode
encode_addressing_mode:
    push ebx
    push ecx
    push edx
    
    ; Build ModR/M and SIB bytes
    xor eax, eax
    
    ; Check if SIB needed
    cmp dword [addr_index], 0
    je .no_sib
    
    ; Need SIB byte
    or al, 0x04         ; ModR/M indicates SIB
    
    ; Build SIB: [scale:2][index:3][base:3]
    mov ebx, [addr_scale]
    ; Convert scale to encoding (1=00, 2=01, 4=10, 8=11)
    bsr ecx, ebx
    shl ecx, 6
    or al, cl
    
    ; Add index register
    mov ebx, [addr_index]
    and ebx, 0x07
    shl ebx, 3
    or al, bl
    
    ; Add base register
    mov ebx, [addr_base]
    and ebx, 0x07
    or al, bl
    
    jmp .check_displacement
    
.no_sib:
    ; Simple base register
    mov ebx, [addr_base]
    and ebx, 0x07
    or al, bl
    
.check_displacement:
    ; Check displacement size
    mov ebx, [addr_disp]
    test ebx, ebx
    jz .no_disp
    
    ; Check if disp8 or disp32
    cmp ebx, -128
    jl .disp32
    cmp ebx, 127
    jg .disp32
    
    ; disp8
    or al, 0x40
    jmp .done
    
.disp32:
    or al, 0x80
    jmp .done
    
.no_disp:
    ; No displacement, mod = 00
    
.done:
    pop edx
    pop ecx
    pop ebx
    ret
```

### Instruction Template Instantiation

```asm
; X86 instruction templates
template_add_reg_reg:
    db 0x01             ; ADD r/m32, r32
    db 0xC0             ; ModR/M base (to be modified)
    db 0xFF             ; Sentinel

template_add_reg_imm:
    db 0x81             ; ADD r/m32, imm32
    db 0xC0             ; ModR/M base
    dd 0xFFFFFFFF       ; Immediate value placeholder
    db 0xFF

template_imul_reg_reg:
    db 0x0F, 0xAF       ; IMUL r32, r/m32
    db 0xC0
    db 0xFF

; Instantiate template with actual registers
instantiate_template:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Template pointer
    mov edi, [ebp + 12] ; Output buffer
    mov eax, [ebp + 16] ; Destination register
    mov ebx, [ebp + 20] ; Source register
    mov ecx, [ebp + 24] ; Immediate value (if applicable)
    
.copy_template:
    lodsb
    cmp al, 0xFF        ; Sentinel
    je .done
    
    ; Check if ModR/M byte
    cmp byte [esi - 2], 0x01
    je .modrm_byte
    cmp byte [esi - 2], 0x81
    je .modrm_byte
    cmp byte [esi - 3], 0xAF
    je .modrm_byte
    
    ; Check if immediate placeholder
    cmp al, 0xFF
    jne .regular_byte
    cmp byte [esi], 0xFF
    jne .regular_byte
    
    ; Replace immediate
    mov [edi], ecx
    add esi, 3
    add edi, 4
    jmp .copy_template
    
.modrm_byte:
    ; Construct ModR/M from registers
    ; Format: [mod:2][reg:3][r/m:3]
    mov dl, 0xC0        ; mod = 11 (register-register)
    
    ; Add reg field (destination)
    mov dh, al
    and dh, 0x07
    shl dh, 3
    or dl, dh
    
    ; Add r/m field (source)
    mov dh, bl
    and dh, 0x07
    or dl, dh
    
    mov al, dl
    
.regular_byte:
    stosb
    jmp .copy_template
    
.done:
    mov eax, edi
    sub eax, [ebp + 12] ; Return bytes written
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

## Register Allocation Algorithms

Register allocation assigns virtual registers to physical machine registers or spills them to memory, minimizing memory traffic and register pressure.

### Linear Scan Register Allocation

```asm
; Linear scan allocation - fast, greedy algorithm
; Suitable for JIT compilers
linear_scan_allocate:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Virtual register array
    mov ecx, [ebp + 12] ; Number of virtual registers
    
    ; Sort virtual registers by start point
    push ecx
    push esi
    call sort_by_start_point
    add esp, 8
    
    ; Initialize active list and free register pool
    call init_free_registers
    mov [active_list], 0
    
.allocate_loop:
    ; Get next virtual register
    mov ebx, esi
    
    ; Expire old intervals
    push ebx
    call expire_old_intervals
    add esp, 4
    
    ; Try to allocate physical register
    call allocate_physical_register
    test eax, eax
    jnz .allocated
    
    ; No free register, must spill
    call spill_at_interval
    
.allocated:
    ; Add to active list
    push ebx
    call add_to_active_list
    add esp, 4
    
    add esi, VirtualReg_size
    loop .allocate_loop
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

active_list: dd 0

; Initialize pool of available physical registers
init_free_registers:
    push eax
    push ecx
    push edi
    
    mov edi, free_register_pool
    
    ; x86 general purpose registers available for allocation
    ; EAX, EBX, ECX, EDX, ESI, EDI (skip ESP, EBP)
    mov eax, REG_EAX
    stosd
    mov eax, REG_EBX
    stosd
    mov eax, REG_ECX
    stosd
    mov eax, REG_EDX
    stosd
    mov eax, REG_ESI
    stosd
    mov eax, REG_EDI
    stosd
    
    mov dword [free_reg_count], 6
    
    pop edi
    pop ecx
    pop eax
    ret

free_register_pool: times 8 dd 0
free_reg_count: dd 0

%define REG_EAX 0
%define REG_ECX 1
%define REG_EDX 2
%define REG_EBX 3
%define REG_ESP 4
%define REG_EBP 5
%define REG_ESI 6
%define REG_EDI 7

; Expire intervals that are no longer live
expire_old_intervals:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    mov ebx, [ebp + 8]  ; Current interval
    mov esi, [active_list]
    
.check_active:
    test esi, esi
    jz .done
    
    ; Check if active interval ends before current starts
    mov eax, [esi + VirtualReg.live_end]
    cmp eax, [ebx + VirtualReg.live_start]
    jge .next_active
    
    ; This interval is expired, free its register
    mov eax, [esi + VirtualReg.physical]
    call free_physical_register
    
    ; Remove from active list
    mov edi, [esi]      ; Next pointer (linked list)
    ; [Inference] Update list pointers to remove node
    
.next_active:
    mov esi, [esi]      ; Next node
    jmp .check_active
    
.done:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret

; Free a physical register back to the pool
free_physical_register:
    push ebx
    push ecx
    push edi
    
    ; Add register back to free pool
    mov ecx, [free_reg_count]
    mov edi, free_register_pool
    mov [edi + ecx*4], eax
    inc dword [free_reg_count]
    
    pop edi
    pop ecx
    pop ebx
    ret

; Allocate a physical register from free pool
allocate_physical_register:
    push ebx
    
    ; Check if any registers available
    mov eax, [free_reg_count]
    test eax, eax
    jz .no_register
    
    ; Take register from pool
    dec eax
    mov [free_reg_count], eax
    mov ebx, free_register_pool
    mov eax, [ebx + eax*4]
    
    ; Assign to virtual register (EBX = VirtualReg*)
    mov ebx, [esp + 8]  ; Get VirtualReg from caller's stack
    mov [ebx + VirtualReg.physical], eax
    
    jmp .done
    
.no_register:
    xor eax, eax
    
.done:
    pop ebx
    ret

; Spill interval - choose register to spill to memory
spill_at_interval:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov ebx, [ebp + 8]  ; Current interval
    
    ; Find active interval with furthest end point
    mov esi, [active_list]
    xor edi, edi        ; Best spill candidate
    xor edx, edx        ; Furthest end point
    
.find_spill_candidate:
    test esi, esi
    jz .spill_current
    
    mov eax, [esi + VirtualReg.live_end]
    cmp eax, edx
    jle .next_candidate
    
    ; This is a better candidate
    mov edx, eax
    mov edi, esi
    
.next_candidate:
    mov esi, [esi]
    jmp .find_spill_candidate
    
.spill_current:
    ; Check if current interval ends before furthest active
    mov eax, [ebx + VirtualReg.live_end]
    cmp eax, edx
    jge .spill_active
    
    ; Spill current interval
    call allocate_spill_slot
    mov [ebx + VirtualReg.spill_slot], eax
    mov dword [ebx + VirtualReg.physical], -1
    jmp .done
    
.spill_active:
    ; Spill the active interval
    mov eax, [edi + VirtualReg.physical]
    mov [ebx + VirtualReg.physical], eax
    
    call allocate_spill_slot
    mov [edi + VirtualReg.spill_slot], eax
    mov dword [edi + VirtualReg.physical], -1
    
    ; Remove spilled interval from active list
    ; Add current interval to active list
    
.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Allocate stack slot for spilled register
allocate_spill_slot:
    push ebx
    
    mov eax, [next_spill_offset]
    add eax, 4
    mov [next_spill_offset], eax
    
    pop ebx
    ret

next_spill_offset: dd 0

; Sort virtual registers by start point (bubble sort for simplicity)
sort_by_start_point:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Array base
    mov ecx, [ebp + 12] ; Count
    
    dec ecx
    
.outer_loop:
    push ecx
    mov edi, esi
    
.inner_loop:
    mov eax, [edi + VirtualReg.live_start]
    mov ebx, [edi + VirtualReg_size + VirtualReg.live_start]
    
    cmp eax, ebx
    jle .no_swap
    
    ; Swap elements
    push ecx
    mov ecx, VirtualReg_size / 4
    
.swap_dwords:
    mov eax, [edi]
    mov ebx, [edi + VirtualReg_size]
    mov [edi + VirtualReg_size], eax
    mov [edi], ebx
    add edi, 4
    loop .swap_dwords
    
    pop ecx
    sub edi, VirtualReg_size
    
.no_swap:
    add edi, VirtualReg_size
    loop .inner_loop
    
    pop ecx
    loop .outer_loop
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret
```

### Graph Coloring Register Allocation

```asm
; Graph coloring - optimal but more expensive algorithm
; Used in optimizing compilers

struc InterferenceNode
    .vreg:          resd 1  ; Virtual register ID
    .neighbors:     resd 1  ; Adjacency list pointer
    .neighbor_count: resd 1 ; Degree
    .color:         resd 1  ; Assigned color (register)
    .removed:       resd 1  ; Removed from graph flag
endstruc

; Build interference graph
build_interference_graph:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Virtual register array
    mov ecx, [ebp + 12] ; Count
    
    ; Allocate graph nodes
    imul eax, ecx, InterferenceNode_size
    call malloc
    mov [interference_graph], eax
    mov edi, eax
    
    ; Initialize nodes
.init_nodes:
    mov eax, [esi + VirtualReg.id]
    mov [edi + InterferenceNode.vreg], eax
    mov dword [edi + InterferenceNode.neighbors], 0
    mov dword [edi + InterferenceNode.neighbor_count], 0
    mov dword [edi + InterferenceNode.color], -1
    mov dword [edi + InterferenceNode.removed], 0
    
    add esi, VirtualReg_size
    add edi, InterferenceNode_size
    loop .init_nodes
    
    ; Build edges between interfering registers
    mov esi, [ebp + 8]
    mov ecx, [ebp + 12]
    
.outer_loop:
    push ecx
    push esi
    
    mov ebx, esi
    add ebx, VirtualReg_size
    mov ecx, [ebp + 12]
    sub ecx, 1
    
.inner_loop:
    ; Check if intervals overlap
    push ecx
    push ebx
    push esi
    call intervals_interfere
    add esp, 8
    pop ecx
    
    test al, al
    jz .no_interference
    
    ; Add edge
    push ebx
    push esi
    call add_interference_edge
    add esp, 8
    
.no_interference:
    add ebx, VirtualReg_size
    loop .inner_loop
    
    pop esi
    add esi, VirtualReg_size
    pop ecx
    loop .outer_loop
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

interference_graph: dd 0

; Check if two live ranges interfere
intervals_interfere:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]  ; First interval
    mov ebx, [ebp + 12] ; Second interval
    
    ; Check overlap: [s1, e1] and [s2, e2] interfere if
    ; s1 <= e2 && s2 <= e1
    
    mov ecx, [eax + VirtualReg.live_start]
    mov edx, [ebx + VirtualReg.live_end]
    cmp ecx, edx
    jg .no_interference
    
    mov ecx, [ebx + VirtualReg.live_start]
    mov edx, [eax + VirtualReg.live_end]
    cmp ecx, edx
    jg .no_interference
    
    mov al, 1
    jmp .done
    
.no_interference:
    xor al, al
    
.done:
    pop ebx
    pop ebp
    ret

; Add edge to interference graph
add_interference_edge:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Get graph nodes for both registers
    mov esi, [ebp + 8]  ; VirtualReg 1
    mov edi, [ebp + 12] ; VirtualReg 2
    
    call find_graph_node
    mov ebx, eax        ; Node 1
    
    mov esi, edi
    call find_graph_node
    mov ecx, eax        ; Node 2
    
    ; Add to adjacency lists
    ; [Inference] Allocate and link neighbor nodes
    
    inc dword [ebx + InterferenceNode.neighbor_count]
    inc dword [ecx + InterferenceNode.neighbor_count]
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Find graph node for virtual register
find_graph_node:
    push ebx
    push ecx
    
    mov eax, [interference_graph]
    mov ebx, [esi + VirtualReg.id]
    
.search:
    cmp [eax + InterferenceNode.vreg], ebx
    je .found
    add eax, InterferenceNode_size
    jmp .search
    
.found:
    pop ecx
    pop ebx
    ret

; Kempe's algorithm: color graph using simplicial elimination
color_interference_graph:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [interference_graph]
    mov ecx, [ebp + 8]  ; Number of nodes
    
    ; Stack for node ordering
    call allocate_stack
    mov [coloring_stack], eax
    
.simplify:
    ; Find node with degree < k (k = number of colors/registers)
    mov edi, esi
    mov ebx, ecx
    
.find_low_degree:
    cmp dword [edi + InterferenceNode.removed], 1
    je .skip_node
    
    mov eax, [edi + InterferenceNode.neighbor_count]
    cmp eax, 6          ; 6 available x86 registers
    jl .found_low_degree
    
.skip_node:
    add edi, InterferenceNode_size
    dec ebx
    jnz .find_low_degree
    
    ; No low-degree node found, potential spill
    ; Select node with highest degree to spill
    call select_spill_node
    test eax, eax
    jz .start_coloring
    mov edi, eax
    
.found_low_degree:
    ; Push node to stack and remove from graph
    mov eax, [coloring_stack]
    push edi
    call push_stack
    
    mov dword [edi + InterferenceNode.removed], 1
    
    ; Update neighbor counts
    call update_neighbor_counts
    
    dec ecx
    jnz .simplify
    
.start_coloring:
    ; Pop nodes and assign colors
.color_loop:
    mov eax, [coloring_stack]
    call pop_stack
    test eax, eax
    jz .done
    
    mov edi, eax
    
    ; Find available color
    call find_available_color
    mov [edi + InterferenceNode.color], eax
    
    jmp .color_loop
    
.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

coloring_stack: dd 0

; Find available color not used by neighbors
find_available_color:
    push ebp
    mov ebp, esp
    sub esp, 32         ; Bitset for used colors
    push ebx
    push ecx
    push esi
    
    ; Clear used colors bitset
    lea edi, [ebp - 32]
    xor eax, eax
    mov ecx, 8
    rep stosd
    
    ; Mark colors used by neighbors
    mov esi, [edi + InterferenceNode.neighbors]
    
.check_neighbors:
    test esi, esi
    jz .find_free_color
    
    mov eax, [esi]      ; Neighbor node
    mov ebx, [eax + InterferenceNode.color]
    
    ; Check if neighbor has color
    cmp ebx, -1
    je .next_neighbor
    
    ; Mark color as used
    lea edi, [ebp - 32]
    mov ecx, ebx
    shr ecx, 5          ; Divide by 32
    and ebx, 31         ; Modulo 32
    bts dword [edi + ecx*4], ebx
    
.next_neighbor:
    mov esi, [esi + 4]  ; Next neighbor in list
    jmp .check_neighbors
    
.find_free_color:
    ; Find first unset bit
    lea esi, [ebp - 32]
    xor ecx, ecx        ; Color counter
    
.scan_colors:
    mov eax, [esi]
    not eax
    bsf eax, eax
    jz .next_dword
    
    ; Found free color
    add eax, ecx
    jmp .color_found
    
.next_dword:
    add esi, 4
    add ecx, 32
    cmp ecx, 256        ; Maximum colors
    jl .scan_colors
    
    ; No color available, must spill
    mov eax, -1
    
.color_found:
    pop esi
    pop ecx
    pop ebx
    add esp, 32
    pop ebp
    ret

; Select node to spill (heuristic: highest degree / spill cost)
select_spill_node:
    push ebx
    push ecx
    push esi
    
    mov esi, [interference_graph]
    xor ebx, ebx        ; Best candidate
    xor edx, edx        ; Best score
    
.scan_nodes:
    cmp dword [esi + InterferenceNode.removed], 1
    je .next_node
    
    ; Calculate spill metric
    mov eax, [esi + InterferenceNode.neighbor_count]
    ; [Inference] Higher degree = better spill candidate
    
    cmp eax, edx
    jle .next_node
    
    mov edx, eax
    mov ebx, esi
    
.next_node:
    add esi, InterferenceNode_size
    loop .scan_nodes
    
    mov eax, ebx
    
    pop esi
    pop ecx
    pop ebx
    ret
```

### SSA-Based Register Allocation

```asm
; Register allocation for SSA form
; Exploits SSA properties for more efficient allocation

struc SSAValue
    .id:            resd 1
    .def_point:     resd 1  ; Instruction that defines this value
    .use_points:    resd 1  ; List of uses
    .physical_reg:  resd 1  ; Assigned register
    .phi_related:   resd 1  ; Part of phi web
endstruc

; Allocate registers for SSA form
ssa_register_allocation:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; SSA value array
    mov ecx, [ebp + 12] ; Count
    
    ; Phase 1: Coalesce phi-related values
    call coalesce_phi_webs
    
    ; Phase 2: Build interference graph (simpler in SSA)
    call build_ssa_interference_graph
    
    ; Phase 3: Color graph
    call color_interference_graph
    
    ; Phase 4: Insert copies for phi functions
    call insert_phi_copies
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Coalesce values related by phi functions
coalesce_phi_webs:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Build union-find structure for phi webs
    call init_union_find
    
    ; Process each phi function
    mov esi, [ebp + 8]
    mov ecx, [ebp + 12]
    
.process_phis:
    ; Check if this is a phi function
    mov eax, [esi + SSAValue.def_point]
    ; [Inference] Check instruction type
    
    ; Union phi destination with all sources
    ; This creates equivalence classes of values that
    ; should share the same register
    
    add esi, SSAValue_size
    loop .process_phis
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; SSA interference is simpler: values interfere only if
; one is live at the definition point of the other
build_ssa_interference_graph:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]
    mov ecx, [ebp + 12]
    
.check_definitions:
    ; For each SSA value definition
    mov ebx, [esi + SSAValue.def_point]
    
    ; Check which values are live at this point
    push ecx
    push esi
    call get_live_at_point
    mov edi, eax        ; Live set
    
    ; Add interference edges
.add_edges:
    ; [Inference] Iterate through live set and add edges
    
    pop esi
    pop ecx
    add esi, SSAValue_size
    loop .check_definitions
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Insert copy instructions for phi functions after allocation
insert_phi_copies:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; For each phi function, insert copies at the end
    ; of predecessor blocks if the source and destination
    ; have different physical registers
    
    mov esi, [ebp + 8]
    mov ecx, [ebp + 12]
    
.process_phis:
    mov eax, [esi + SSAValue.def_point]
    ; [Inference] Check if phi function
    
    ; Get phi operands and their registers
    mov ebx, [esi + SSAValue.physical_reg]
    
    ; For each predecessor
.check_operands:
    ; If operand register != destination register
    ; Insert MOV in predecessor block
    
    add esi, SSAValue_size
    loop .process_phis
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

### Spill Code Generation

```asm
; Generate spill and reload instructions
generate_spill_code:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Instruction sequence
    mov ecx, [ebp + 12] ; Instruction count
    mov edi, [ebp + 16] ; Virtual register info
    
.process_instructions:
    push ecx
    
    ; Check if instruction uses spilled registers
    mov eax, [esi + IRInstruction.src1]
    call is_spilled
    test al, al
    jz .check_src2
    
    ; Insert reload before instruction
    push esi
    call insert_reload
    pop esi
    
.check_src2:
    mov eax, [esi + IRInstruction.src2]
    call is_spilled
    test al, al
    jz .check_dest
    
    push esi
    call insert_reload
    pop esi
    
.check_dest:
    mov eax, [esi + IRInstruction.dest]
    call is_spilled
    test al, al
    jz .next_instruction
    
    ; Insert spill after instruction
    push esi
    call insert_spill
    pop esi
    
.next_instruction:
    add esi, IRInstruction_size
    pop ecx
    loop .process_instructions
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Check if virtual register is spilled
is_spilled:
    push ebx
    
    ; Look up register in allocation table
    mov ebx, [ebp + 16] ; VirtualReg array
    
.search:
    cmp [ebx + VirtualReg.id], eax
    je .found
    add ebx, VirtualReg_size
    jmp .search
    
.found:
    cmp dword [ebx + VirtualReg.physical], -1
    sete al
    
    pop ebx
    ret

; Insert reload: MOV reg, [ebp + offset]
insert_reload:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Insertion point
    mov eax, [esi + IRInstruction.src1] ; Spilled register
    
    ; Find spill slot
    call find_spill_slot
    mov ebx, eax
    
    ; Allocate temporary physical register
    call allocate_temp_register
    mov ecx, eax
    
    ; Emit: MOV temp_reg, [ebp + spill_offset]
    mov byte [code_buffer], 0x8B    ; MOV r32, r/m32
    mov al, 0x45                     ; ModR/M: [ebp + disp8]
    or al, cl
    shl al, 3
    mov [code_buffer + 1], al
    mov [code_buffer + 2], bl       ; Displacement
    
    ; Update instruction to use temp register
    mov [esi + IRInstruction.src1], ecx
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Insert spill: MOV [ebp + offset], reg
insert_spill:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]
    mov eax, [esi + IRInstruction.dest]
    
    call find_spill_slot
    mov ebx, eax
    
    ; Get physical register that temporarily holds value
    mov ecx, [esi + IRInstruction.dest]
    
    ; Emit: MOV [ebp + spill_offset], reg
    mov byte [code_buffer], 0x89    ; MOV r/m32, r32
    mov al, 0x45
    or al, cl
    shl al, 3
    mov [code_buffer + 1], al
    mov [code_buffer + 2], bl
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

code_buffer: times 256 db 0
```

### Register Allocation Quality Metrics

```asm
; Measure register allocation quality
measure_allocation_quality:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Allocated program
    
    xor ebx, ebx        ; Spill count
    xor ecx, ecx        ; Move count
    xor edx, edx        ; Instruction count
    
.count_operations:
    ; Check for spills/reloads
    mov al, [esi]
    cmp al, 0x8B        ; MOV from memory
    je .potential_reload
    cmp al, 0x89        ; MOV to memory
    je .potential_spill
    
    ; Check for register-register moves
    cmp al, 0x89
    je .check_reg_move
    cmp al, 0x8B
    je .check_reg_move
    
    jmp .next_instruction
    
.potential_reload:
    ; Check if memory operand is stack slot
    inc ebx
    jmp .next_instruction
    
.potential_spill:
    inc ebx
    jmp .next_instruction
    
.check_reg_move:
    mov al, [esi + 1]
    and al, 0xC0
    cmp al, 0xC0        ; Register-register mode
    jne .next_instruction
    inc ecx
    
.next_instruction:
    inc edx
    ; [Inference] Advance to next instruction
    ; Actual implementation would parse instruction length
    
    cmp byte [esi], 0xC3 ; RET instruction (end)
    je .done
    inc esi
    jmp .count_operations
    
.done:
    ; Calculate metrics
    ; Spill ratio = spills / instructions
    mov eax, ebx
    imul eax, 100
    xor edx, edx
    div dword [ebp + 12] ; Total instructions
    mov [spill_ratio], eax
    
    ; Move ratio = moves / instructions
    mov eax, ecx
    imul eax, 100
    xor edx, edx
    div dword [ebp + 12]
    mov [move_ratio], eax
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

spill_ratio: dd 0
move_ratio: dd 0
```

**Key Points:**

- Compiler backends transform IR through instruction selection (pattern matching), register allocation (mapping virtual to physical registers), and code emission phases
- Linear scan allocation provides O(n) complexity suitable for JIT compilers, using a greedy approach that processes live ranges in order of start points
- Graph coloring produces optimal allocations by modeling register interference as a graph coloring problem, using Kempe's algorithm with simplicial elimination
- SSA form simplifies register allocation by reducing interference complexity, as SSA values have single definitions and non-overlapping live ranges by construction
- [Inference] Spill code insertion requires careful placement of loads before uses and stores after definitions to minimize performance impact
- [Inference] Register coalescing eliminates unnecessary move instructions by assigning the same physical register to related virtual registers when possible
- Instruction selection must consider x86 addressing modes, two-address constraints, and instruction costs to generate efficient code

**Important related topics:** Instruction scheduling and software pipelining for superscalar processors, Rematerialization to avoid spills by recomputing cheap values, Global code motion and loop-invariant code motion optimizations, Peephole optimization for local code improvements, Profile-guided optimization for hot path register allocation.

## Peephole Optimization

Peephole optimization examines small, localized sequences of instructions (the "peephole") and replaces them with more efficient equivalents. This technique operates on generated assembly code or machine code, improving it through pattern matching and local transformations.

### Fundamental Concepts

The peephole is a sliding window that examines a fixed number of consecutive instructions, typically 2-5 instructions. The optimizer searches for recognizable patterns and applies transformations that preserve semantic equivalence while improving code quality.

Peephole optimization operates independently of program structure or control flow, making it simple to implement and fast to execute. It typically runs as a post-pass after initial code generation, cleaning up inefficiencies introduced by naive code generation or exposed by earlier optimization passes.

The optimization is local in scope, meaning it cannot perform transformations requiring global program analysis. However, this locality makes it safe to apply repeatedly and allows it to catch optimization opportunities created by other transformations.

### Common Optimization Patterns

**Redundant Load/Store Elimination**

Consecutive stores to the same memory location where the first store's value is never read can be eliminated.

**Example:**

```asm
; Before optimization
mov [rbx], eax
mov [rbx], ecx          ; First store is dead

; After optimization
mov [rbx], ecx          ; First store removed
```

Loading a value immediately after storing it can be replaced with register reuse.

**Example:**

```asm
; Before optimization
mov [rbp-8], rax
mov rbx, [rbp-8]        ; Redundant load

; After optimization
mov [rbp-8], rax
mov rbx, rax            ; Use source register directly
```

**Algebraic Simplifications**

Identity operations that have no effect can be removed.

**Example:**

```asm
; Before optimization
add rax, 0              ; Identity operation
sub rbx, 0              ; Identity operation
imul rcx, 1             ; Identity operation
or rdx, 0               ; Identity operation
xor rsi, 0              ; Identity operation

; After optimization
; All instructions removed
```

Adding or subtracting the same register results in predictable values.

**Example:**

```asm
; Before optimization
sub rax, rax            ; Always produces 0

; After optimization
xor rax, rax            ; Shorter encoding, breaks dependency chain
```

**Example:**

```asm
; Before optimization
xor rax, rax
add rax, 5

; After optimization
mov rax, 5              ; Direct constant load
```

Multiplication and division by powers of two can use shift operations.

**Example:**

```asm
; Before optimization
imul rax, 8             ; Multiply by power of 2
idiv rcx, 4             ; Divide by power of 2 (if unsigned)

; After optimization
shl rax, 3              ; Faster shift operation
shr rcx, 2              ; Faster shift operation
```

Strength reduction replaces expensive operations with cheaper equivalents.

**Example:**

```asm
; Before optimization
imul rax, 3

; After optimization
lea rax, [rax + rax*2]  ; LEA is faster than IMUL

; Before optimization
imul rax, 5

; After optimization
lea rax, [rax + rax*4]
```

**Instruction Combination**

Multiple operations can sometimes merge into single instructions.

**Example:**

```asm
; Before optimization
mov rax, rbx
add rax, rcx

; After optimization
lea rax, [rbx + rcx]    ; Single instruction
```

**Example:**

```asm
; Before optimization
mov rax, [rbx]
add rax, 8

; After optimization
mov rax, [rbx + 8]      ; Fold offset into load
```

**Example:**

```asm
; Before optimization
shl rax, 2
add rax, rbx

; After optimization
lea rax, [rbx + rax*4]  ; Combine scale and add
```

**Constant Folding**

Operations on compile-time constants can be pre-computed.

**Example:**

```asm
; Before optimization
mov rax, 10
add rax, 20
imul rax, 3

; After optimization
mov rax, 90             ; (10 + 20) * 3 computed at compile time
```

**Dead Code Elimination**

Instructions whose results are never used can be removed.

**Example:**

```asm
; Before optimization
mov rax, 5              ; Value computed
mov rax, 10             ; But immediately overwritten

; After optimization
mov rax, 10             ; First instruction removed
```

**Example:**

```asm
; Before optimization
add rax, rbx            ; Result stored in RAX
mov rcx, 0              ; RAX value never used

; After optimization
mov rcx, 0              ; ADD removed
```

**Branch Optimization**

Unconditional jumps to the next instruction can be eliminated.

**Example:**

```asm
; Before optimization
jmp next_label
next_label:
    mov rax, 5

; After optimization
next_label:
    mov rax, 5          ; Jump removed
```

Jumps to jumps can be short-circuited.

**Example:**

```asm
; Before optimization
je label1
; ...
label1:
    jmp label2

; After optimization
je label2               ; Jump directly to final target
; ...
label1:
    jmp label2
```

Conditional branches with constant conditions can be resolved.

**Example:**

```asm
; Before optimization
cmp rax, rax            ; Always equal
je taken_branch

; After optimization
jmp taken_branch        ; Unconditional jump
```

**Register-Register Move Optimization**

Moving a register to itself is a no-op.

**Example:**

```asm
; Before optimization
mov rax, rax            ; No-op

; After optimization
; Instruction removed
```

Redundant moves in sequences can be eliminated.

**Example:**

```asm
; Before optimization
mov rax, rbx
mov rcx, rax
mov rdx, rcx

; After optimization
mov rax, rbx
mov rcx, rbx            ; Direct from source
mov rdx, rbx            ; Direct from source
```

**Flag Usage Optimization**

Redundant flag-setting instructions can be eliminated when flags are overwritten before use.

**Example:**

```asm
; Before optimization
cmp rax, rbx            ; Sets flags
add rcx, rdx            ; Overwrites flags
cmp rax, rbx            ; Redundant comparison
je target

; After optimization
add rcx, rdx
cmp rax, rbx            ; First comparison removed
je target
```

Test instructions can sometimes be eliminated when previous instructions set equivalent flags.

**Example:**

```asm
; Before optimization
sub rax, rbx            ; Sets zero flag if equal
test rax, rax           ; Redundant test
jz equal

; After optimization
sub rax, rbx
jz equal                ; TEST removed
```

**Extension and Truncation Optimization**

Sign or zero extension followed by truncation can be simplified.

**Example:**

```asm
; Before optimization
movsx rax, eax          ; Sign extend 32 to 64
mov ebx, eax            ; Truncate back to 32

; After optimization
mov ebx, eax            ; MOVSX removed
```

Multiple extensions can be collapsed.

**Example:**

```asm
; Before optimization
movzx eax, al           ; Zero extend 8 to 32
movzx rax, eax          ; Zero extend 32 to 64

; After optimization
movzx rax, al           ; Direct 8 to 64 extension
```

### Implementation Strategy

A typical peephole optimizer maintains a sliding window over the instruction sequence and applies pattern matching rules iteratively.

**Example implementation structure:**

```asm
; Pseudo-code structure
peephole_optimize:
    .window_size = 4
    .changed = true
    
    while .changed:
        .changed = false
        for each instruction sequence of length .window_size:
            for each optimization pattern:
                if pattern matches sequence:
                    apply transformation
                    .changed = true
                    break
```

The optimizer must track instruction properties including:

- Instructions that read or write registers
- Instructions that read or write memory
- Instructions that set or use CPU flags
- Instruction side effects (exceptions, serialization)
- Control flow changes (branches, calls, returns)

**Example pattern matching for redundant load elimination:**

```asm
; Pattern: MOV [mem], reg followed by MOV reg2, [mem]
; Condition: Same memory operand, no intervening writes
; Transform: Keep first MOV, replace second with MOV reg2, reg

; Detection logic (conceptual)
if instruction[i] is (MOV [mem], reg1):
    if instruction[i+1] is (MOV reg2, [mem]):
        if same_memory_operand(instruction[i], instruction[i+1]):
            if not register_modified_between(reg1, i, i+1):
                if not memory_modified_between(mem, i, i+1):
                    ; Apply optimization
                    replace instruction[i+1] with (MOV reg2, reg1)
```

### Liveness Analysis Integration

Effective peephole optimization benefits from basic liveness information indicating whether register values are used after specific program points.

**Example with liveness:**

```asm
; Before optimization - RAX is dead after this point
mov rax, [rbx]
add rax, 10
mov rcx, 0              ; RAX never used again

; After optimization
mov rcx, 0              ; Previous RAX operations removed (dead code)
```

[Inference] Simple liveness can be computed locally within the peephole window by scanning forward for register uses before register redefinitions or function calls that clobber registers.

### Ordering and Iteration

Multiple optimization patterns may be applicable simultaneously, requiring careful ordering. Some optimizations enable others, necessitating iterative application until a fixed point is reached.

**Example cascade:**

```asm
; Initial code
mov rax, 0
add rax, 5
imul rax, 2

; After iteration 1 (constant folding pass 1)
mov rax, 5              ; 0 + 5 folded
imul rax, 2

; After iteration 2 (constant folding pass 2)
mov rax, 10             ; 5 * 2 folded
```

[Inference] Most optimizers limit iterations to prevent excessive compile time, typically running 2-5 passes or until no changes occur.

### Safety Considerations

Peephole optimizations must preserve program semantics. Critical safety checks include:

- Memory aliasing: Transformations involving memory must account for potential aliases
- Flag dependencies: Flag-producing instructions cannot be removed if flags are used
- Side effects: Instructions with side effects (exceptions, I/O) require special handling
- Register liveness: Dead code elimination requires accurate liveness information
- Calling conventions: Register values must be preserved across calls if required
- Atomic operations: Optimizations cannot break atomicity guarantees

**Example unsafe transformation:**

```asm
; UNSAFE optimization
; Before
mov [rbx], rax
mov rcx, [rbx]          ; May not be same location if [rbx] is volatile

; After (INCORRECT if [rbx] is volatile)
mov [rbx], rax
mov rcx, rax            ; Misses potential concurrent modification
```

### Architecture-Specific Patterns

Different processor architectures enable different optimization patterns based on instruction set characteristics.

**x86-64 specific optimizations:**

Using 32-bit operations to implicitly zero-extend to 64 bits:

```asm
; Before optimization
movzx rax, eax          ; Explicitly zero extend

; After optimization
mov eax, eax            ; 32-bit MOV implicitly zero extends, but still suboptimal

; Better optimization
; Remove if eax already contains desired value
```

Exploiting LEA for complex addressing:

```asm
; Before optimization
mov rax, rbx
shl rax, 2
add rax, rcx
add rax, 8

; After optimization
lea rax, [rcx + rbx*4 + 8]  ; Single instruction
```

Using shorter instruction encodings:

```asm
; Before optimization
mov rax, 0              ; 7 bytes with REX.W

; After optimization
xor eax, eax            ; 2 bytes, zeroes entire RAX
```

### Performance Impact Measurement

[Inference] Peephole optimization typically improves performance by 5-15% through code size reduction, better instruction selection, and elimination of redundant operations. Benefits vary based on initial code quality and optimization aggressiveness.

Code size reduction ranges from 10-25% in typical cases, benefiting instruction cache performance and reducing memory bandwidth requirements.

## Assembly Code Templates

Assembly code templates define patterns for translating high-level operations into assembly instruction sequences. Templates provide a systematic approach to code generation, enabling consistent and correct translation from intermediate representations to machine code.

### Template Structure

Each template specifies:

- Input conditions or patterns to match
- Output instruction sequence to generate
- Register allocation requirements
- Constraint specifications
- Cost or priority metrics

**Example template structure:**

```
Template: INTEGER_ADD
Pattern: (ADD dest, src1, src2)
Constraints:
    - dest: register
    - src1: register
    - src2: register or immediate
Output:
    if src1 == dest:
        ADD dest, src2
    else if src2 == dest:
        ADD dest, src1
    else:
        MOV dest, src1
        ADD dest, src2
Cost: 1 instruction (if src1==dest), 2 instructions (otherwise)
```

### Basic Arithmetic Templates

**Integer addition:**

```asm
; Template: ADD reg, reg
; Cost: 1 cycle latency, 0.25 cycles throughput
add rax, rbx

; Template: ADD reg, imm32
; Cost: 1 cycle latency, 0.25 cycles throughput
add rax, 42

; Template: ADD reg, [mem]
; Cost: ~5-6 cycles latency (L1 cache hit)
add rax, [rcx]

; Template: LEA for ADD with offset
; Cost: 1 cycle latency, 0.5 cycles throughput
; Advantage: No flags modified
lea rax, [rbx + 10]
```

**Integer multiplication:**

```asm
; Template: IMUL reg, reg
; Cost: 3 cycles latency, 1 cycle throughput
imul rax, rbx

; Template: IMUL by power of 2
; Cost: 1 cycle latency, 0.5 cycles throughput
shl rax, 3              ; Multiply by 8

; Template: IMUL by small constant using LEA
; Cost: 1-2 cycles
lea rax, [rax + rax*2]  ; Multiply by 3
lea rax, [rax + rax*4]  ; Multiply by 5
lea rax, [rax*8 + rax]  ; Multiply by 9

; Template: IMUL by constant requiring decomposition
; Example: multiply by 10 = (2 * 5)
lea rax, [rax + rax*4]  ; Multiply by 5
shl rax, 1              ; Multiply by 2
```

**Integer division:**

```asm
; Template: IDIV signed division
; Cost: ~20-30 cycles latency
; Requires: Dividend in RDX:RAX, divisor in register/memory
; Returns: Quotient in RAX, remainder in RDX
mov rax, dividend
cqo                     ; Sign extend RAX into RDX
idiv divisor

; Template: DIV by power of 2 (unsigned)
; Cost: 1 cycle
shr rax, 3              ; Divide by 8

; Template: DIV by power of 2 (signed with rounding toward zero)
; Cost: 3-4 cycles
mov rbx, rax
sar rbx, 63             ; Arithmetic shift gets sign bit
shr rbx, 61             ; Shift to create bias (64 - 3 = 61)
add rax, rbx            ; Add bias
sar rax, 3              ; Arithmetic shift right
```

### Memory Access Templates

**Load operations:**

```asm
; Template: Simple load
mov rax, [rbx]

; Template: Load with offset
mov rax, [rbx + 16]

; Template: Load with scaled index
mov rax, [rbx + rcx*8]

; Template: Load with complex addressing
mov rax, [rbx + rcx*4 + 32]

; Template: Zero-extending load
movzx rax, byte [rbx]   ; 8-bit
movzx rax, word [rbx]   ; 16-bit
mov eax, [rbx]          ; 32-bit (implicit zero extension)

; Template: Sign-extending load
movsx rax, byte [rbx]   ; 8-bit
movsx rax, word [rbx]   ; 16-bit
movsxd rax, dword [rbx] ; 32-bit
```

**Store operations:**

```asm
; Template: Simple store
mov [rbx], rax

; Template: Store with addressing modes
mov [rbx + rcx*8 + 16], rax

; Template: Store immediate
mov qword [rbx], 42

; Template: Partial register store
mov byte [rbx], al
mov word [rbx], ax
mov dword [rbx], eax
```

### Control Flow Templates

**Conditional branches:**

```asm
; Template: If-then using compare and branch
; Pattern: if (a < b) { ... }
cmp rax, rbx
jl then_block
; else block
jmp end_if
then_block:
; then block
end_if:

; Template: If-then-else
; Pattern: if (a == b) { ... } else { ... }
cmp rax, rbx
je then_block
; else block
jmp end_if
then_block:
; then block
end_if:

; Template: Logical AND short-circuit
; Pattern: if (a && b) { ... }
test rax, rax
jz end_if               ; Short circuit if first false
test rbx, rbx
jz end_if               ; Short circuit if second false
; then block
end_if:

; Template: Logical OR short-circuit
; Pattern: if (a || b) { ... }
test rax, rax
jnz then_block          ; Short circuit if first true
test rbx, rbx
jz end_if
then_block:
; then block
end_if:
```

**Loop templates:**

```asm
; Template: For loop (counting up)
; Pattern: for (i = 0; i < n; i++) { ... }
xor ecx, ecx            ; i = 0
loop_start:
cmp rcx, n
jge loop_end
; loop body
inc rcx
jmp loop_start
loop_end:

; Template: For loop (counting down, more efficient)
; Pattern: for (i = n-1; i >= 0; i--) { ... }
mov rcx, n
loop_start:
dec rcx
js loop_end             ; Jump if sign flag set (< 0)
; loop body
jmp loop_start
loop_end:

; Template: While loop
; Pattern: while (condition) { ... }
loop_start:
; evaluate condition
test rax, rax
jz loop_end
; loop body
jmp loop_start
loop_end:

; Template: Do-while loop
; Pattern: do { ... } while (condition)
loop_start:
; loop body
; evaluate condition
test rax, rax
jnz loop_start
```

**Function call templates:**

```asm
; Template: Function call (System V AMD64 ABI)
; Arguments in: RDI, RSI, RDX, RCX, R8, R9, stack
; Caller-saved: RAX, RCX, RDX, RSI, RDI, R8-R11
; Callee-saved: RBX, RBP, R12-R15
; Return value: RAX (integer), XMM0 (float)

mov rdi, arg1
mov rsi, arg2
mov rdx, arg3
call function
; Result in RAX

; Template: Function prologue (with frame pointer)
push rbp
mov rbp, rsp
sub rsp, local_size     ; Allocate local variables

; Template: Function epilogue
mov rsp, rbp            ; Deallocate locals
pop rbp
ret

; Template: Leaf function (no calls, minimal state)
; No frame pointer needed
sub rsp, local_size
; function body
add rsp, local_size
ret
```

### Type Conversion Templates

**Integer conversions:**

```asm
; Template: Sign extension
movsx rax, eax          ; 32 to 64 bit
movsx eax, al           ; 8 to 32 bit
movsx rax, ax           ; 16 to 64 bit

; Template: Zero extension
movzx eax, al           ; 8 to 32 bit
movzx rax, ax           ; 16 to 64 bit
mov eax, eax            ; 32 to 64 bit (implicit)

; Template: Truncation (high bits discarded)
; No instruction needed - just use smaller register
mov al, cl              ; Use low 8 bits
mov ax, cx              ; Use low 16 bits
mov eax, ecx            ; Use low 32 bits
```

**Floating-point conversions:**

```asm
; Template: Integer to float
cvtsi2ss xmm0, eax      ; int32 to float
cvtsi2sd xmm0, rax      ; int64 to double

; Template: Float to integer (truncate)
cvttss2si eax, xmm0     ; float to int32
cvttsd2si rax, xmm0     ; double to int64

; Template: Float to float
cvtss2sd xmm0, xmm0     ; float to double
cvtsd2ss xmm0, xmm0     ; double to float (potential precision loss)
```

### Aggregate Data Templates

**Structure field access:**

```asm
; Template: Load struct field
; Pattern: struct->field where field at offset N
mov rax, [rbx + N]      ; RBX points to struct base

; Template: Store struct field
mov [rbx + N], rax

; Template: Nested struct access
; Pattern: struct->nested.field
mov rbx, [rax + offset_nested]  ; Load nested struct pointer
mov rcx, [rbx + offset_field]   ; Load field from nested struct
```

**Array access templates:**

```asm
; Template: Array element access (fixed index)
; Pattern: array[5] where elements are 8 bytes
mov rax, [rbx + 5*8]

; Template: Array element access (variable index)
; Pattern: array[i] where elements are 8 bytes
mov rax, [rbx + rcx*8]

; Template: Multi-dimensional array access
; Pattern: array[i][j] where array is [M][N] with 8-byte elements
; Index calculation: (i * N + j) * 8
imul rax, rcx, N        ; i * N
add rax, rdx            ; i * N + j
mov rax, [rbx + rax*8]  ; Load element

; Alternative using LEA
lea rax, [rdx + rcx*N]  ; i * N + j (if N is 1, 2, 4, or 8)
mov rax, [rbx + rax*8]
```

### Boolean and Bitwise Templates

**Boolean operations:**

```asm
; Template: Logical NOT
; Pattern: !a
test rax, rax
setz al                 ; AL = 1 if zero, 0 otherwise
movzx rax, al

; Template: Logical AND
; Pattern: a && b (non-short-circuit)
test rax, rax
setnz al
test rbx, rbx
setnz bl
and al, bl
movzx rax, al

; Template: Comparison to boolean
; Pattern: (a < b)
cmp rax, rbx
setl al                 ; AL = 1 if less, 0 otherwise
movzx rax, al
```

**Bitwise operations:**

```asm
; Template: Bitwise AND
and rax, rbx

; Template: Bitwise OR
or rax, rbx

; Template: Bitwise XOR
xor rax, rbx

; Template: Bitwise NOT
not rax

; Template: Left shift
shl rax, cl             ; Shift count in CL
shl rax, 5              ; Immediate shift count

; Template: Right shift (logical)
shr rax, cl

; Template: Right shift (arithmetic, preserves sign)
sar rax, cl

; Template: Bit test
bt rax, 5               ; Test bit 5, result in CF
setc al                 ; Extract to register

; Template: Bit set
bts rax, 5              ; Set bit 5

; Template: Bit clear
btr rax, 5              ; Clear bit 5

; Template: Bit toggle
btc rax, 5              ; Toggle bit 5
```

### Template Selection

When multiple templates match a pattern, selection depends on:

**Cost metrics** including instruction count, latency, throughput, and resource usage (execution ports, register pressure).

**Context factors** such as surrounding code, available registers, and memory hierarchy effects.

**Target microarchitecture** characteristics where instruction performance varies across processor generations.

**Example selection logic:**

```
Pattern: Multiply by 3
Templates:
    1. IMUL rax, 3          (Cost: 3 cycle latency, 1 cycle throughput)
    2. LEA rax, [rax+rax*2] (Cost: 1 cycle latency, 0.5 cycle throughput)

Selection: Choose template 2 (LEA) for better performance
```

### Instruction Scheduling Within Templates

[Inference] Templates can incorporate instruction scheduling to improve execution on out-of-order processors by interleaving independent operations and placing dependent instructions appropriately.

**Example:**

```asm
; Template: Multiple independent operations (poor scheduling)
mov rax, [rbx]
add rax, 10             ; Depends on previous MOV
mov rcx, [rdx]
add rcx, 20             ; Depends on previous MOV

; Template: Same operations (better scheduling)
mov rax, [rbx]
mov rcx, [rdx]          ; Independent, can execute in parallel
add rax, 10
add rcx, 20
```

### Template Instantiation

Template instantiation involves replacing abstract operands with concrete registers, memory locations, or constants based on current register allocation and code generation context.

**Example instantiation:**

```
Abstract template:
    MOV <dest>, <src1>
    ADD <dest>, <src2>

Instantiation 1:
    MOV RAX, RBX
    ADD RAX, RCX

Instantiation 2:
    MOV R8, [RSI]
    ADD R8, 42
```

## JIT Compilation Basics

Just-In-Time (JIT) compilation translates high-level code or bytecode into machine code at runtime, enabling dynamic optimization based on actual execution behavior while maintaining portability.

### JIT Compilation Architecture

A JIT compiler consists of several key components:

**Frontend** parses or interprets input code (bytecode, intermediate representation, or source code) and builds an internal representation.

**Optimizer** applies transformations to improve code quality, potentially using runtime profiling data to guide decisions.

**Backend** generates native machine code for the target processor architecture.

**Code cache** stores generated machine code for reuse and manages memory for executable code.

**Runtime system** handles execution transitions between interpreted and compiled code, manages profiling, and triggers recompilation.

### Execution Models

**Interpretation** executes bytecode directly without generating machine code. This provides fast startup but slow execution.

**Method-at-a-time JIT** compiles complete functions or methods when first invoked. This balances compilation overhead with execution speed.

**Trace-based JIT** records frequently executed paths through code and compiles these hot traces. This enables aggressive optimization of common cases.

**Tiered compilation** uses multiple optimization levels, starting with fast simple compilation and recompiling hot code with aggressive optimization.

### Basic JIT Implementation Structure

**Example conceptual structure:**

```asm
; JIT compiler main components (pseudo-code)

jit_compile_function:
    ; Input: function bytecode/IR
    ; Output: executable machine code pointer
    
    1. Allocate executable memory:
        code_buffer = allocate_executable_memory(estimated_size)
    
    2. Initialize code generation:
        code_gen = init_code_generator(code_buffer)
    
    3. Generate function prologue:
        emit_function_prologue(code_gen)
    
    4. For each bytecode instruction/IR node:
        template = select_template(instruction)
        emit_template(code_gen, template, instruction.operands)
    
    5. Generate function epilogue:
        emit_function_epilogue(code_gen)
    
    6. Finalize code:
        finalize_code(code_gen)
        flush_instruction_cache(code_buffer)
    
    7. Return executable function pointer:
        return code_buffer
```

### Memory Management for JIT Code

JIT-compiled code requires executable memory allocated with appropriate permissions. On modern systems, this requires special handling due to security features.

**Memory allocation:**

```c
// Platform-specific executable memory allocation
#ifdef _WIN32
    void* code = VirtualAlloc(NULL, size, 
                             MEM_COMMIT | MEM_RESERVE,
                             PAGE_EXECUTE_READWRITE);
#else // Linux/Unix
    void* code = mmap(NULL, size,
                     PROT_READ | PROT_WRITE | PROT_EXEC,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
#endif
```

[Inference] Modern security practices recommend W^X (write XOR execute) where memory is either writable or executable, never both simultaneously. JIT compilers should allocate memory as writable, generate code, then change permissions to executable.

**W^X implementation:**

```c
// Allocate as writable
void* code = mmap(NULL, size, PROT_READ | PROT_WRITE,
                 MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

// Generate code (write to code buffer)
generate_machine_code(code, ...);

// Change to executable
mprotect(code, size, PROT_READ | PROT_EXEC);
```

### Code Emission

Code emission involves writing machine code bytes to the executable buffer. This requires encoding x86-64 instructions with proper operands, addressing modes, and prefixes.

**Example simple code emitter:**

```c
typedef struct {
    uint8_t* buffer;        // Current write position
    uint8_t* buffer_start;  // Buffer start
    size_t buffer_size;     // Total buffer size
} CodeEmitter;

// Emit single byte
void emit_byte(CodeEmitter* e, uint8_t byte) {
    assert(e->buffer < e->buffer_start + e->buffer_size);
    *e->buffer++ = byte;
}

// Emit 32-bit value (little-endian)
void emit_int32(CodeEmitter* e, int32_t value) {
    emit_byte(e, value & 0xFF);
    emit_byte(e, (value >> 8) & 0xFF);
    emit_byte(e, (value >> 16) & 0xFF);
    emit_byte(e, (value >> 24) & 0xFF);
}

// Emit MOV reg, imm64
void emit_mov_reg_imm64(CodeEmitter* e, int reg, uint64_t imm) {
    // REX.W prefix for 64-bit operand
    emit_byte(e, 0x48 | ((reg >> 3) & 1));  // REX.W with optional REX.B
    // MOV opcode (0xB8 + register)
    emit_byte(e, 0xB8 | (reg & 7));
    // 64-bit immediate
    emit_int32(e, imm & 0xFFFFFFFF);
    emit_int32(e, imm >> 32);
}

// Emit ADD reg, reg
void emit_add_reg_reg(CodeEmitter* e, int dest, int src) {
    // REX prefix if needed
    uint8_t rex = 0x48;  // REX.W
    if (dest >= 8) rex |= 0x04;  // REX.R
    if (src >= 8) rex |= 0x01;   // REX.B
    emit_byte(e, rex);
    
    // ADD opcode (0x01 = ADD r/m64, r64)
    emit_byte(e, 0x01);
    
    // ModR/M byte: 11 (register direct) | dest | src
    emit_byte(e, 0xC0 | ((src & 7) << 3) | (dest & 7));
}

// Emit RET
void emit_ret(CodeEmitter* e) {
    emit_byte(e, 0xC3);
}
```

## REX Prefix Encoding

The REX prefix enables 64-bit operands and access to extended registers (R8-R15). Understanding REX encoding is essential for JIT compilation on x86-64.

REX prefix format: 0100WRXB

- W (bit 3): 1 = 64-bit operand size
- R (bit 2): Extension of ModR/M reg field
- X (bit 1): Extension of SIB index field
- B (bit 0): Extension of ModR/M r/m field, SIB base field, or opcode reg field

**Example REX calculation:**

```c
uint8_t calculate_rex(bool is_64bit, int reg, int rm, int index) {
    uint8_t rex = 0x40;  // Base REX prefix
    
    if (is_64bit)
        rex |= 0x08;     // REX.W
    if (reg >= 8)
        rex |= 0x04;     // REX.R
    if (index >= 8)
        rex |= 0x02;     // REX.X
    if (rm >= 8)
        rex |= 0x01;     // REX.B
    
    return rex;
}
```

## ModR/M and SIB Byte Encoding

ModR/M byte specifies addressing modes and operands: format is MMRRRSSS

- MM (bits 6-7): Addressing mode (00=indirect, 01=disp8, 10=disp32, 11=register)
- RRR (bits 3-5): Register operand
- SSS (bits 0-2): R/M operand (register or memory)

SIB byte specifies scaled index addressing: format is SSIIIBBB

- SS (bits 6-7): Scale factor (00=1, 01=2, 10=4, 11=8)
- III (bits 3-5): Index register
- BBB (bits 0-2): Base register

**Example ModR/M encoding:**

```c
uint8_t encode_modrm(int mod, int reg, int rm) {
    return ((mod & 3) << 6) | ((reg & 7) << 3) | (rm & 7);
}

uint8_t encode_sib(int scale, int index, int base) {
    int scale_bits = 0;
    switch(scale) {
        case 1: scale_bits = 0; break;
        case 2: scale_bits = 1; break;
        case 4: scale_bits = 2; break;
        case 8: scale_bits = 3; break;
    }
    return (scale_bits << 6) | ((index & 7) << 3) | (base & 7);
}
```

## Complete Example: Simple JIT Function

**Example: JIT compile function that adds two integers**

```c
#include <sys/mman.h>
#include <string.h>
#include <stdint.h>

typedef int64_t (*jit_func_t)(int64_t, int64_t);

jit_func_t jit_compile_add() {
    // Allocate executable memory
    size_t code_size = 4096;
    uint8_t* code = mmap(NULL, code_size,
                         PROT_READ | PROT_WRITE,
                         MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    
    uint8_t* ptr = code;
    
    // Function prologue (minimal for leaf function)
    // Arguments already in RDI (arg1) and RSI (arg2) per System V ABI
    
    // MOV RAX, RDI (move first argument to return register)
    *ptr++ = 0x48;  // REX.W
    *ptr++ = 0x89;  // MOV r/m64, r64
    *ptr++ = 0xF8;  // ModR/M: RDI -> RAX
    
    // ADD RAX, RSI (add second argument)
    *ptr++ = 0x48;  // REX.W
    *ptr++ = 0x01;  // ADD r/m64, r64
    *ptr++ = 0xF0;  // ModR/M: RSI -> RAX
    
    // RET
    *ptr++ = 0xC3;
    
    // Make memory executable
    mprotect(code, code_size, PROT_READ | PROT_EXEC);
    
    // Flush instruction cache (x86 handles this automatically)
    
    return (jit_func_t)code;
}

// Usage:
// jit_func_t add_func = jit_compile_add();
// int64_t result = add_func(10, 20);  // Returns 30
```

## Register Allocation in JIT

JIT compilers must allocate machine registers to virtual registers or variables. Simple JIT compilers use basic allocation strategies while advanced JITs use sophisticated graph-coloring algorithms.

**Linear scan register allocation** (simple but effective):

```c
// Conceptual linear scan algorithm
typedef struct {
    int virtual_reg;
    int start_pos;
    int end_pos;
    int physical_reg;  // -1 if spilled
} LiveInterval;

void linear_scan_allocate(LiveInterval* intervals, int count) {
    int available_regs[] = {RAX, RCX, RDX, RBX, RSI, RDI, R8, R9, R10, R11};
    int num_regs = 10;
    int active[num_regs];
    int active_count = 0;
    
    // Sort intervals by start position
    sort_intervals_by_start(intervals, count);
    
    for (int i = 0; i < count; i++) {
        LiveInterval* current = &intervals[i];
        
        // Expire old intervals
        for (int j = 0; j < active_count; j++) {
            if (intervals[active[j]].end_pos < current->start_pos) {
                // Free the register
                // Remove from active list
            }
        }
        
        // Try to allocate register
        if (active_count < num_regs) {
            current->physical_reg = available_regs[active_count];
            active[active_count++] = i;
        } else {
            // Spill to stack
            current->physical_reg = -1;
        }
    }
}
```

**Simple fixed register allocation:**

```c
// For very simple JIT: use fixed registers for common operations
#define REG_RESULT   RAX
#define REG_TEMP1    RCX
#define REG_TEMP2    RDX
#define REG_ARG1     RDI
#define REG_ARG2     RSI
#define REG_ARG3     RDX
```

## Stack Frame Management

JIT-compiled functions need stack frames for local variables and spilled registers.

**Example stack frame generation:**

```c
void emit_function_prologue(CodeEmitter* e, int local_size) {
    // Push RBP
    emit_byte(e, 0x55);
    
    // MOV RBP, RSP
    emit_byte(e, 0x48);  // REX.W
    emit_byte(e, 0x89);  // MOV r/m64, r64
    emit_byte(e, 0xE5);  // ModR/M: RSP -> RBP
    
    // SUB RSP, local_size (allocate locals)
    if (local_size > 0) {
        emit_byte(e, 0x48);  // REX.W
        emit_byte(e, 0x81);  // SUB r/m64, imm32
        emit_byte(e, 0xEC);  // ModR/M: RSP
        emit_int32(e, local_size);
    }
}

void emit_function_epilogue(CodeEmitter* e) {
    // MOV RSP, RBP (deallocate locals)
    emit_byte(e, 0x48);  // REX.W
    emit_byte(e, 0x89);  // MOV r/m64, r64
    emit_byte(e, 0xEC);  // ModR/M: RBP -> RSP
    
    // POP RBP
    emit_byte(e, 0x5D);
    
    // RET
    emit_byte(e, 0xC3);
}
```

## Control Flow in JIT

Generating branches and loops requires handling forward and backward jumps with proper offset calculation.

**Example branch emission:**

```c
typedef struct {
    uint8_t* location;  // Where to patch the offset
    int target_label;   // Which label this jumps to
} PendingJump;

typedef struct {
    uint8_t* location;  // Code location of label
    int label_id;
} Label;

void emit_jump(CodeEmitter* e, int label_id, PendingJump* pending) {
    // JMP rel32
    emit_byte(e, 0xE9);
    
    // Save location for later patching
    pending->location = e->buffer;
    pending->target_label = label_id;
    
    // Emit placeholder offset
    emit_int32(e, 0);
}

void emit_conditional_jump(CodeEmitter* e, int condition, int label_id, PendingJump* pending) {
    // Jcc rel32 (0x0F 0x80+condition)
    emit_byte(e, 0x0F);
    emit_byte(e, 0x80 + condition);  // JE=0x84, JNE=0x85, JL=0x8C, etc.
    
    pending->location = e->buffer;
    pending->target_label = label_id;
    emit_int32(e, 0);
}

void patch_jumps(PendingJump* jumps, int jump_count, Label* labels, int label_count) {
    for (int i = 0; i < jump_count; i++) {
        // Find target label
        Label* target = NULL;
        for (int j = 0; j < label_count; j++) {
            if (labels[j].label_id == jumps[i].target_label) {
                target = &labels[j];
                break;
            }
        }
        
        // Calculate relative offset
        // Offset is from END of jump instruction to target
        int32_t offset = target->location - (jumps[i].location + 4);
        
        // Patch the offset
        *(int32_t*)jumps[i].location = offset;
    }
}
```

**Example: JIT compile if-then-else:**

```c
void jit_compile_if_then_else(CodeEmitter* e, 
                              Bytecode* condition,
                              Bytecode* then_block,
                              Bytecode* else_block) {
    PendingJump jumps[2];
    Label labels[2];
    int jump_idx = 0, label_idx = 0;
    
    // Generate condition code
    emit_bytecode(e, condition);
    // Assume result in RAX
    
    // TEST RAX, RAX
    emit_byte(e, 0x48);  // REX.W
    emit_byte(e, 0x85);  // TEST r/m64, r64
    emit_byte(e, 0xC0);  // ModR/M: RAX, RAX
    
    // JE else_label (jump if zero/false)
    emit_conditional_jump(e, 0x04, 0, &jumps[jump_idx++]);  // JE = 0x84, condition = 4
    
    // Then block
    emit_bytecode(e, then_block);
    
    // JMP end_label
    emit_jump(e, 1, &jumps[jump_idx++]);
    
    // else_label:
    labels[label_idx].label_id = 0;
    labels[label_idx++].location = e->buffer;
    
    // Else block
    emit_bytecode(e, else_block);
    
    // end_label:
    labels[label_idx].label_id = 1;
    labels[label_idx++].location = e->buffer;
    
    // Patch all jumps
    patch_jumps(jumps, jump_idx, labels, label_idx);
}
```

## Optimization in JIT

JIT compilers can apply various optimizations, balancing compilation time with code quality.

**Constant folding during emission:**

```c
void emit_add(CodeEmitter* e, Value* dest, Value* src1, Value* src2) {
    if (src1->type == VALUE_CONSTANT && src2->type == VALUE_CONSTANT) {
        // Fold constants at compile time
        int64_t result = src1->constant + src2->constant;
        emit_mov_reg_imm64(e, dest->reg, result);
    } else if (src2->type == VALUE_CONSTANT) {
        // ADD reg, imm32
        emit_mov_reg_reg(e, dest->reg, src1->reg);
        emit_add_reg_imm32(e, dest->reg, src2->constant);
    } else {
        // ADD reg, reg
        emit_mov_reg_reg(e, dest->reg, src1->reg);
        emit_add_reg_reg(e, dest->reg, src2->reg);
    }
}
```

**Dead code elimination:**

```c
// During code generation, track which values are used
typedef struct {
    bool used;
    int last_use_position;
} ValueInfo;

void emit_with_dce(CodeEmitter* e, Bytecode* code, ValueInfo* info) {
    for (int i = 0; i < code->instruction_count; i++) {
        Instruction* inst = &code->instructions[i];
        
        // Skip instructions whose results are never used
        if (!info[inst->dest].used) {
            continue;
        }
        
        emit_instruction(e, inst);
    }
}
```

**Inline caching for method calls:**

```c
// Optimize virtual method calls by caching the last target
typedef struct {
    void* last_class;
    void* last_target;
    uint8_t* call_site;
} InlineCache;

void emit_virtual_call_with_ic(CodeEmitter* e, int method_index, InlineCache* ic) {
    // Check if receiver class matches cached class
    // MOV RAX, [RDI]  ; Load class pointer from object
    emit_mov_reg_mem(e, RAX, RDI, 0);
    
    // CMP RAX, cached_class
    emit_cmp_reg_imm64(e, RAX, (uint64_t)ic->last_class);
    
    PendingJump slow_path;
    // JNE slow_path
    emit_conditional_jump(e, 0x05, 0, &slow_path);  // JNE = 0x85, condition = 5
    
    // Fast path: call cached target
    emit_call_absolute(e, (uint64_t)ic->last_target);
    
    PendingJump end;
    emit_jump(e, 1, &end);
    
    // Slow path: lookup and update cache
    Label slow_label = {0, e->buffer};
    // Call runtime to lookup method and update cache
    emit_call_absolute(e, (uint64_t)&runtime_virtual_lookup);
    
    Label end_label = {1, e->buffer};
    
    patch_jumps(&slow_path, 1, &slow_label, 1);
    patch_jumps(&end, 1, &end_label, 1);
}
```

## Profiling and Tiered Compilation

Advanced JIT systems use profiling to guide optimization decisions.

**Example tiered compilation structure:**

```c
typedef enum {
    TIER_INTERPRETER,
    TIER_BASELINE_JIT,
    TIER_OPTIMIZING_JIT
} CompilationTier;

typedef struct {
    uint64_t call_count;
    uint64_t execution_time;
    CompilationTier current_tier;
    void* compiled_code[3];  // One for each tier
} FunctionProfile;

void* execute_function(Function* func, FunctionProfile* profile) {
    profile->call_count++;
    
    // Tier up based on hotness
    if (profile->call_count > 1000 && profile->current_tier == TIER_INTERPRETER) {
        // Compile with baseline JIT
        profile->compiled_code[TIER_BASELINE_JIT] = baseline_jit_compile(func);
        profile->current_tier = TIER_BASELINE_JIT;
    }
    
    if (profile->call_count > 10000 && profile->current_tier == TIER_BASELINE_JIT) {
        // Recompile with optimizing JIT
        profile->compiled_code[TIER_OPTIMIZING_JIT] = optimizing_jit_compile(func, profile);
        profile->current_tier = TIER_OPTIMIZING_JIT;
    }
    
    // Execute at current tier
    if (profile->current_tier == TIER_INTERPRETER) {
        return interpret(func);
    } else {
        return ((jit_func_t)profile->compiled_code[profile->current_tier])();
    }
}
```

## Deoptimization and On-Stack Replacement

Advanced JITs may need to deoptimize from compiled code back to interpreted code when assumptions are violated.

[Inference] Deoptimization typically involves:

- Saving the current program state
- Reconstructing interpreter state from optimized state
- Transferring control back to interpreter
- Optionally recompiling with different assumptions

**Example deoptimization guard:**

```c
void emit_type_guard(CodeEmitter* e, int reg, void* expected_type) {
    // Load object type
    // MOV RAX, [reg]  ; Assume type pointer at offset 0
    emit_mov_reg_mem(e, RAX, reg, 0);
    
    // CMP RAX, expected_type
    emit_cmp_reg_imm64(e, RAX, (uint64_t)expected_type);
    
    // JNE deoptimize
    PendingJump deopt_jump;
    emit_conditional_jump(e, 0x05, 0, &deopt_jump);
    
    // Continue with optimized code...
    
    // Deoptimization stub
    Label deopt_label = {0, e->buffer};
    
    // Save state and call deoptimization runtime
    emit_call_absolute(e, (uint64_t)&deoptimize_runtime);
    
    patch_jumps(&deopt_jump, 1, &deopt_label, 1);
}
```

## Garbage Collection Integration

JIT compilers in garbage-collected languages must coordinate with the GC.

[Inference] Key integration points include:

- Emitting GC safe points where collection can occur
- Generating stack maps describing live object references
- Emitting write barriers for generational GC
- Handling object allocation in generated code

**Example GC safe point:**

```c
void emit_gc_safepoint(CodeEmitter* e) {
    // Check if GC is requested
    // CMP [gc_requested_flag], 0
    emit_cmp_mem_imm(e, (uint64_t)&gc_requested_flag, 0);
    
    // JE continue
    PendingJump continue_jump;
    emit_conditional_jump(e, 0x04, 0, &continue_jump);
    
    // Call GC safepoint handler
    emit_call_absolute(e, (uint64_t)&gc_safepoint_handler);
    
    Label continue_label = {0, e->buffer};
    patch_jumps(&continue_jump, 1, &continue_label, 1);
}
```

## Performance Considerations

[Inference] JIT compilation involves several performance trade-offs:

**Compilation overhead:** Time spent generating code subtracts from execution time. Baseline JITs minimize this with simple code generation, while optimizing JITs invest more time for better code quality.

**Code quality vs compilation time:** More aggressive optimization produces faster code but takes longer to compile. Tiered compilation balances this by using fast compilation for cold code and aggressive optimization for hot code.

**Memory usage:** Generated code consumes memory. Code cache management, deduplication, and selective compilation help control memory footprint.

**Startup time:** Cold startup is slower with JIT than ahead-of-time compilation. Techniques like profile-guided optimization, cached compiled code, and interpreter fallback mitigate this.

## Platform-Specific Considerations

JIT compilation must handle platform differences including calling conventions, register availability, instruction set variations, and operating system interfaces.

**Calling convention handling:**

```c
typedef struct {
    int int_arg_regs[6];
    int float_arg_regs[8];
    int num_int_args;
    int num_float_args;
} CallingConvention;

void init_calling_convention(CallingConvention* cc, Platform platform) {
    if (platform == PLATFORM_LINUX || platform == PLATFORM_MACOS) {
        // System V AMD64 ABI
        cc->int_arg_regs[0] = RDI;
        cc->int_arg_regs[1] = RSI;
        cc->int_arg_regs[2] = RDX;
        cc->int_arg_regs[3] = RCX;
        cc->int_arg_regs[4] = R8;
        cc->int_arg_regs[5] = R9;
    } else if (platform == PLATFORM_WINDOWS) {
        // Microsoft x64 calling convention
        cc->int_arg_regs[0] = RCX;
        cc->int_arg_regs[1] = RDX;
        cc->int_arg_regs[2] = R8;
        cc->int_arg_regs[3] = R9;
    }
}
```

## Debugging JIT-Compiled Code

Debugging JIT code requires special support since code doesn't exist at load time.

[Inference] Techniques include:

- Generating debug symbols dynamically
- Registering code regions with debuggers via platform APIs
- Maintaining source-to-machine-code mappings
- Disassembly of generated code for inspection

**Example GDB JIT interface:**

```c
// GDB JIT interface for registering code
typedef struct {
    uint32_t version;
    uint32_t action_flag;
    void* relevant_entry;
    void* first_entry;
} JITDescriptor;

extern JITDescriptor __jit_debug_descriptor;

void register_jit_code_with_gdb(void* code_addr, size_t code_size) {
    // Create JIT entry
    JITEntry* entry = malloc(sizeof(JITEntry));
    entry->symfile_addr = create_elf_image(code_addr, code_size);
    entry->symfile_size = get_elf_size();
    
    // Add to GDB's list
    __jit_debug_descriptor.relevant_entry = entry;
    __jit_debug_descriptor.action_flag = JIT_REGISTER;
    
    // Trigger GDB's JIT handler
    __jit_debug_register_code();
}
```

**Key Points:**

- Peephole optimization applies local pattern-matching transformations to improve generated code quality with minimal compilation overhead
- Assembly code templates provide systematic translation from high-level operations to instruction sequences with consideration for cost and constraints
- JIT compilation generates machine code at runtime enabling dynamic optimization and maintaining portability across platforms
- Register allocation in JIT must balance simplicity for fast compilation with quality for good performance
- Control flow in JIT requires careful management of forward and backward jumps with proper offset calculation and patching
- Tiered compilation balances fast startup with eventual high performance by using multiple optimization levels
- Memory management for executable code requires platform-specific allocation and proper handling of security features like W^X
- Template selection should consider instruction latency, throughput, code size, and microarchitectural characteristics
- Inline caching and profiling-guided optimization enable JIT compilers to adapt to actual runtime behavior
- JIT systems must integrate with runtime services including garbage collection, exception handling, and debugging infrastructure

---

# Special-Purpose Instructions

Special-purpose instruction sets extend x86 capabilities with hardware-accelerated operations for specific computational tasks. These extensions provide significant performance improvements over software implementations through parallel execution, reduced instruction count, and dedicated silicon logic.

## Bit Manipulation Instructions

### BMI1 (Bit Manipulation Instruction Set 1)

BMI1 introduces efficient bit field extraction, manipulation, and population counting operations.

**ANDN - Logical AND NOT**

Computes the bitwise AND of the first source with the inverted second source.

```nasm
; ANDN dest, src1, src2
; dest = src1 AND (NOT src2)

; Clear specific bits efficiently
mov eax, 0xFF00FF00
mov ebx, 0x0F0F0F0F
andn ecx, eax, ebx      ; ECX = 0xF000F000
                        ; Equivalent to: NOT EBX, AND with EAX

; Traditional approach requires more instructions
mov ecx, ebx
not ecx
and ecx, eax

; Bit mask filtering
mov eax, [data_word]
mov ebx, [mask_bits]
andn ecx, eax, ebx      ; Clear masked bits from data

; Permission checking
mov eax, [requested_permissions]
mov ebx, [denied_permissions]
andn ecx, eax, ebx      ; Remove denied permissions
cmp ecx, eax
jne .permission_denied
```

**BEXTR - Bit Field Extract**

Extracts a contiguous bit field from a source operand.

```nasm
; BEXTR dest, src, control
; control[7:0] = start bit position
; control[15:8] = length in bits

; Extract bits 4-11 (8 bits starting at position 4)
mov eax, 0x12345678
mov ebx, 0x0804        ; Length=8, Start=4
bextr ecx, eax, ebx    ; ECX = 0x00000067

; Unpack packed data structure
; Struct: [unused:16][field3:8][field2:4][field1:4]
mov eax, [packed_data]

mov ebx, 0x0400        ; Extract field1 (4 bits at position 0)
bextr ecx, eax, ebx
mov [field1], cl

mov ebx, 0x0404        ; Extract field2 (4 bits at position 4)
bextr ecx, eax, ebx
mov [field2], cl

mov ebx, 0x0808        ; Extract field3 (8 bits at position 8)
bextr ecx, eax, ebx
mov [field3], cl

; Protocol packet parsing
; Packet header: [version:4][type:4][length:8][flags:8][reserved:8]
mov eax, [packet_header]

mov ebx, 0x0400        ; Extract version
bextr ecx, eax, ebx
mov [packet_version], cl

mov ebx, 0x0404        ; Extract type
bextr ecx, eax, ebx
mov [packet_type], cl

mov ebx, 0x0808        ; Extract length
bextr ecx, eax, ebx
mov [packet_length], cx

mov ebx, 0x0810        ; Extract flags
bextr ecx, eax, ebx
mov [packet_flags], cl
```

**BLSI - Extract Lowest Set Bit**

Isolates the lowest set bit in the source operand.

```nasm
; BLSI dest, src
; dest = src AND (-src)

; Find rightmost set bit
mov eax, 0b11010100
blsi ebx, eax           ; EBX = 0b00000100 (bit 2)

; Priority encoder implementation
find_lowest_priority_task:
    mov eax, [task_ready_bitmap]
    blsi ebx, eax       ; Isolate lowest bit
    jz .no_tasks
    
    ; Convert bit position to task ID
    bsf ecx, ebx        ; ECX = bit position
    mov eax, ecx
    ret
    
.no_tasks:
    mov eax, -1
    ret

; Event flag processing
process_events:
    mov eax, [event_flags]
    
.event_loop:
    blsi ebx, eax       ; Get next event
    jz .done            ; No more events
    
    bsf ecx, ebx        ; Get event number
    
    ; Process event
    push eax
    push ecx
    call handle_event
    pop ecx
    pop eax
    
    ; Clear processed event
    xor eax, ebx        ; Remove this bit
    jmp .event_loop
    
.done:
    ret

; Fast modulo for power-of-2
; x % n = x & (n-1) only if n is power of 2
is_power_of_two:        ; EAX = number
    blsi ebx, eax
    cmp ebx, eax        ; Power of 2 has only one bit set
    sete al
    movzx eax, al
    ret
```

**BLSMSK - Create Mask to Lowest Set Bit**

Creates a mask from the least significant bit up to and including the lowest set bit.

```nasm
; BLSMSK dest, src
; dest = src XOR (src - 1)

; Generate mask for all bits below lowest set bit (inclusive)
mov eax, 0b11010100
blsmsk ebx, eax         ; EBX = 0b00000111

; Round up to next power of 2 preparation
round_up_to_power_of_2: ; EAX = input
    dec eax
    blsmsk eax, eax
    inc eax
    ret

; Extract contiguous block of low bits
mov eax, [bit_flags]
blsmsk ebx, eax         ; Get mask of continuous low bits
and ebx, eax            ; Extract those bits

; Memory alignment checking
check_alignment:        ; EAX = address, EBX = alignment
    dec ebx
    blsmsk ecx, ebx     ; Create alignment mask
    test eax, ecx       ; Check if address has any bits in mask
    jnz .not_aligned
    
    ; Address is aligned
    clc
    ret
    
.not_aligned:
    stc
    ret
```

**BLSR - Reset Lowest Set Bit**

Clears the lowest set bit in the source operand.

```nasm
; BLSR dest, src
; dest = src AND (src - 1)

; Clear rightmost set bit
mov eax, 0b11010100
blsr ebx, eax           ; EBX = 0b11010000

; Count set bits (population count alternative)
popcount_manual:        ; EAX = value
    xor ecx, ecx        ; Counter
    
.count_loop:
    test eax, eax
    jz .done
    
    blsr eax, eax       ; Clear lowest bit
    inc ecx
    jmp .count_loop
    
.done:
    mov eax, ecx
    ret

; Process all set bits in bitmap
process_all_bits:       ; EAX = bitmap
    
.process_loop:
    test eax, eax
    jz .done
    
    ; Find position of current bit
    bsf ebx, eax
    
    ; Process this bit
    push eax
    mov eax, ebx
    call process_bit_handler
    pop eax
    
    ; Remove this bit and continue
    blsr eax, eax
    jmp .process_loop
    
.done:
    ret

; Fast check if only one bit is set
has_single_bit_set:     ; EAX = value
    blsr ebx, eax
    test ebx, ebx       ; If result is zero, only one bit was set
    setz al
    movzx eax, al
    ret

; Efficient sparse array iteration
iterate_sparse_array:
    mov eax, [sparse_bitmap]
    xor esi, esi        ; Index counter
    
.iterate:
    test eax, eax
    jz .done
    
    bsf ebx, eax        ; Find next set bit
    
    ; Calculate actual index
    add esi, ebx
    
    ; Process element at index ESI
    push eax
    push esi
    mov eax, esi
    call process_element
    pop esi
    pop eax
    
    ; Remove processed bit and adjust index
    blsr eax, eax
    inc esi
    
    jmp .iterate
    
.done:
    ret
```

**TZCNT - Count Trailing Zeros**

Counts the number of trailing zero bits.

```nasm
; TZCNT dest, src
; dest = count of trailing zeros (or operand size if src=0)

; Find position of lowest set bit
mov eax, 0b11010100
tzcnt ebx, eax          ; EBX = 2

; Array index calculation for bit operations
find_array_index:       ; EAX = bit mask (single bit set)
    tzcnt eax, eax      ; Convert to index
    ret

; Fast division by power of 2 detection
mov eax, [divisor]
blsi ebx, eax           ; Isolate lowest bit
cmp ebx, eax            ; Check if power of 2
jne .not_power_of_2

tzcnt ecx, eax          ; Get shift amount
mov eax, [dividend]
shr eax, cl             ; Fast division
jmp .done

.not_power_of_2:
; Use normal division

.done:

; Efficient mod/div for sparse values
sparse_lookup:          ; EAX = sparse array, EBX = bit position
    tzcnt ecx, ebx      ; Position of set bit
    
    ; Calculate offset in sparse array
    mov edx, ebx
    blsr edx, edx       ; Clear this bit
    popcnt edx, edx     ; Count remaining bits below this one
    
    ; Access sparse element
    mov eax, [eax + edx*4]
    ret
```

### BMI2 (Bit Manipulation Instruction Set 2)

BMI2 provides advanced parallel bit field operations and efficient extraction/deposition.

**BZHI - Zero High Bits**

Clears all bits above a specified position.

```nasm
; BZHI dest, src, index
; dest = src with bits above index cleared

; Create mask of N bits
create_n_bit_mask:      ; ECX = number of bits
    mov eax, 0xFFFFFFFF
    bzhi eax, eax, ecx
    ret                 ; EAX = mask with N low bits set

; Limit value to maximum
clamp_value:            ; EAX = value, ECX = bit width
    bzhi eax, eax, ecx
    ret

; Extract lower N bits efficiently
mov eax, 0x12345678
mov ecx, 16
bzhi ebx, eax, ecx      ; EBX = 0x00005678

; Implement circular buffer index wrapping
circular_buffer_index:  ; EAX = index, ECX = buffer size bits
    bzhi eax, eax, ecx
    ret

; Fast modulo for any value (when divisor is power of 2)
fast_modulo_pow2:       ; EAX = dividend, CL = log2(divisor)
    bzhi eax, eax, ecx
    ret
```

**PEXT - Parallel Bits Extract**

Extracts bits from source according to mask, compacting them.

```nasm
; PEXT dest, src, mask
; Extracts bits where mask=1, packs them into dest

; Extract specific fields from packed data
; Example: Extract bits at positions 1,3,5,7 (odd bits)
mov eax, 0b10101010
mov ebx, 0b10101010    ; Mask for odd positions
pext ecx, eax, ebx     ; ECX = 0b1111 (all odd bits packed)

; Color channel extraction from RGB565
; RGB565 format: [R:5][G:6][B:5]
extract_rgb_channels:   ; AX = RGB565 value
    movzx eax, ax
    
    ; Extract red (bits 11-15)
    mov ebx, 0xF800
    pext ecx, eax, ebx
    mov [red_channel], cl
    
    ; Extract green (bits 5-10)
    mov ebx, 0x07E0
    pext ecx, eax, ebx
    mov [green_channel], cl
    
    ; Extract blue (bits 0-4)
    mov ebx, 0x001F
    pext ecx, eax, ebx
    mov [blue_channel], cl
    
    ret

; Network packet field extraction
; IPv4 header: extract all flag bits scattered throughout header
mov eax, [ipv4_header]
mov ebx, 0x0000E000    ; Flags at bits 13-15
pext ecx, eax, ebx     ; ECX contains just the flags

; Chess board representation - extract diagonal
; 8x8 board, extract main diagonal (bits 0,9,18,27,36,45,54,63)
mov rax, [chess_board]
mov rbx, 0x8040201008040201
pext rcx, rax, rbx     ; RCX contains main diagonal pieces

; Efficient bit gathering for compression
compress_sparse_bits:   ; RAX = data, RBX = mask of valid bits
    pext rax, rax, rbx
    popcnt rcx, rbx     ; Count of bits extracted
    ; RAX now contains compacted data
    ret

; Gray code to binary conversion (certain patterns)
gray_to_binary:         ; EAX = gray code
    mov ebx, eax
    shr ebx, 1
    
.convert_loop:
    xor eax, ebx
    shr ebx, 1
    jnz .convert_loop
    
    ret

; Extract alternate bits (useful for Morton codes)
extract_morton_x:       ; RAX = Morton code
    mov rbx, 0x5555555555555555  ; Mask for X coordinates
    pext rax, rax, rbx
    ret

extract_morton_y:       ; RAX = Morton code
    mov rbx, 0xAAAAAAAAAAAAAAAA  ; Mask for Y coordinates
    pext rax, rax, rbx
    ret
```

**PDEP - Parallel Bits Deposit**

Deposits bits into positions specified by mask (inverse of PEXT).

```nasm
; PDEP dest, src, mask
; Deposits bits from src into positions where mask=1

; Scatter bits to specific positions
mov eax, 0b1111        ; 4 bits to deposit
mov ebx, 0b10101010    ; Deposit to odd positions
pdep ecx, eax, ebx     ; ECX = 0b10101010

; Color channel insertion into RGB565
pack_rgb_to_565:        ; CL = red, CH = green, DL = blue
    ; Red channel (5 bits to positions 11-15)
    movzx eax, cl
    mov ebx, 0xF800
    pdep esi, eax, ebx
    
    ; Green channel (6 bits to positions 5-10)
    movzx eax, ch
    mov ebx, 0x07E0
    pdep edi, eax, ebx
    or esi, edi
    
    ; Blue channel (5 bits to positions 0-4)
    movzx eax, dl
    mov ebx, 0x001F
    pdep edi, eax, ebx
    or esi, edi
    
    mov ax, si          ; Return RGB565 in AX
    ret

; Build network packet header
create_ipv4_flags:      ; AL = flags (3 bits)
    movzx eax, al
    mov ebx, 0x0000E000
    pdep eax, eax, ebx  ; Deposit flags to bits 13-15
    ret

; Morton code encoding (interleave X and Y coordinates)
encode_morton_2d:       ; EAX = X, EBX = Y
    push rbx
    
    ; Spread X bits to even positions
    mov ecx, eax
    mov rdx, 0x5555555555555555
    pdep rax, rcx, rdx
    
    ; Spread Y bits to odd positions
    mov rcx, rbx
    mov rdx, 0xAAAAAAAAAAAAAAAA
    pdep rbx, rcx, rdx
    
    ; Combine
    or rax, rbx
    
    pop rbx
    ret

; Expand compressed data back to original positions
decompress_sparse_bits: ; RAX = compressed data, RBX = original mask
    pdep rax, rax, rbx
    ret

; Bit field insertion
insert_bit_field:       ; EAX = existing value, EBX = new field, ECX = mask
    ; Clear old field
    mov edx, ecx
    not edx
    and eax, edx
    
    ; Insert new field
    pdep edx, ebx, ecx
    or eax, edx
    
    ret

; GPIO port manipulation - set specific pins
set_gpio_pins:          ; AL = pin values, BL = pin mask
    in al, dx           ; Read current port value
    
    ; Clear masked pins
    mov cl, bl
    not cl
    and al, cl
    
    ; Set new values
    mov cl, al
    pdep al, bl, bl     ; Deposit values to masked positions
    or al, cl
    
    out dx, al
    ret
```

**MULX - Unsigned Multiply**

Performs unsigned multiplication without affecting flags.

```nasm
; MULX high_dest, low_dest, src
; RDX * src -> high_dest:low_dest (flags unaffected)

; 64-bit × 64-bit = 128-bit multiplication
mov rdx, 0x123456789ABCDEF0
mov rax, 0xFEDCBA9876543210
mulx rbx, rcx, rax      ; RBX:RCX = RDX * RAX
                        ; RBX = high 64 bits
                        ; RCX = low 64 bits

; Large number multiplication (multi-precision)
multiply_128bit:        ; RDX:RAX = multiplicand, RCX = multiplier
    push rbx
    push r8
    push r9
    
    ; Low × Low
    mulx r8, r9, rcx    ; R8:R9 = RDX * RCX (low part)
    
    ; High × High
    mov r10, rax
    mulx r11, r12, rcx  ; R11:R12 = RAX * RCX (high part)
    
    ; Add middle products
    add r8, r12
    adc r11, 0
    
    ; Result in R11:R8:R9
    mov rax, r9         ; Low 64 bits
    mov rdx, r8         ; Middle 64 bits
    mov rbx, r11        ; High 64 bits
    
    pop r9
    pop r8
    pop rbx
    ret

; Scaled index calculation without clobbering flags
array_access_scaled:    ; RDX = multiplier, RCX = index
    ; Calculate RCX * RDX without affecting flags
    mov r8, rdx
    mulx rax, rbx, rcx  ; RBX = low result
    
    ; Use RBX as offset
    mov rax, [array_base + rbx]
    
    ; Flags from previous operations are preserved
    ret

; Fixed-point multiplication
fixed_point_mul:        ; RDX = a (16.16), RCX = b (16.16)
    mulx rbx, rax, rcx  ; 64.64 result
    
    ; Extract 16.16 result (shift right 16 bits from 64.64)
    shrd rax, rbx, 16
    
    ret

; Percentage calculation without overflow
calc_percentage:        ; RDX = value, RCX = total
    mov rax, 100
    mulx rbx, rax, rax  ; Multiply by 100
    
    ; Divide by total
    div rcx             ; RAX = percentage
    
    ret
```

**RORX/SHLX/SHRX/SARX - Rotation and Shifts**

Non-destructive rotation and shift operations.

```nasm
; RORX dest, src, count - Rotate right without modifying source
mov eax, 0x12345678
rorx ebx, eax, 8        ; EBX = 0x78123456, EAX unchanged

; SHLX dest, src, count - Shift left with variable count
mov eax, 0x00000001
mov ecx, 5
shlx ebx, eax, ecx      ; EBX = 0x00000020, EAX unchanged

; SHRX dest, src, count - Logical shift right
mov eax, 0x80000000
mov ecx, 4
shrx ebx, eax, ecx      ; EBX = 0x08000000

; SARX dest, src, count - Arithmetic shift right
mov eax, 0x80000000
mov ecx, 4
sarx ebx, eax, ecx      ; EBX = 0xF8000000 (sign extended)

; Circular buffer operations
circular_buf_write:     ; EAX = data, EBX = index, ECX = buf_size_log2
    mov esi, [buffer_base]
    
    ; Wrap index using rotation
    mov edx, 32
    sub edx, ecx
    rorx edi, ebx, edx  ; Rotate to get wrapped index
    bzhi edi, edi, ecx  ; Mask to buffer size
    
    mov [esi + edi*4], eax
    ret

; Barrel shifter implementation
variable_shift_array:   ; ESI = array, ECX = count, EDX = shift amount
    
.shift_loop:
    mov eax, [esi]
    shlx ebx, eax, edx  ; Variable shift without destroying EAX
    mov [esi + result_offset], ebx
    
    add esi, 4
    loop .shift_loop
    
    ret

; Cryptographic operations - key mixing
key_schedule_round:     ; RAX = key, CL = round number
    rorx rbx, rax, 8    ; Rotate copy
    rorx rcx, rax, 16
    rorx rdx, rax, 24
    
    xor rax, rbx
    xor rax, rcx
    xor rax, rdx
    
    ret

; Bit reversal for FFT
bit_reverse_32:         ; EAX = input
    rorx ebx, eax, 16   ; Swap halfwords
    
    mov ecx, ebx
    shlx edx, ebx, 8
    shrx ebx, ecx, 8
    and edx, 0xFF00FF00
    and ebx, 0x00FF00FF
    or ebx, edx         ; Swap bytes in halfwords
    
    ; Further bit swapping...
    mov eax, ebx
    ret
```

## CRC32 Instruction

Hardware-accelerated CRC32 calculation using the Castagnoli polynomial (CRC32C).

**CRC32 - Accumulate CRC32**

```nasm
; CRC32 reg32, reg/mem8/16/32
; Accumulates CRC32C of source into destination

; Single byte CRC32
mov eax, 0xFFFFFFFF     ; Initial CRC value
mov bl, 'A'
crc32 eax, bl           ; Accumulate byte
not eax                 ; Final CRC = NOT(accumulated)

; Calculate CRC32 of buffer
calc_crc32:             ; ESI = buffer, ECX = length
    push ebx
    
    mov eax, 0xFFFFFFFF ; Initialize CRC
    
    ; Process 8 bytes at a time when possible
    mov ebx, ecx
    shr ebx, 3
    jz .process_remaining
    
.process_qwords:
    crc32 rax, qword [esi]
    add esi, 8
    dec ebx
    jnz .process_qwords
    
.process_remaining:
    and ecx, 7
    jz .done
    
    ; Process 4 bytes
    cmp ecx, 4
    jb .process_words
    
    crc32 eax, dword [esi]
    add esi, 4
    sub ecx, 4
    
.process_words:
    cmp ecx, 2
    jb .process_bytes
    
    crc32 eax, word [esi]
    add esi, 2
    sub ecx, 2
    
.process_bytes:
    test ecx, ecx
    jz .done
    
    crc32 eax, byte [esi]
    inc esi
    dec ecx
    jnz .process_bytes
    
.done:
    not eax             ; Finalize CRC
    pop ebx
    ret

; Network packet CRC verification
verify_packet_crc:      ; ESI = packet, ECX = length (including CRC)
    push ebx
    push edi
    
    sub ecx, 4          ; Length without CRC
    mov edi, ecx
    add edi, esi        ; Point to CRC field
    
    call calc_crc32     ; Calculate CRC of data
    
    cmp eax, [edi]      ; Compare with stored CRC
    pop edi
    pop ebx
    sete al
    movzx eax, al
    ret

; Incremental CRC calculation
crc32_init:
    mov dword [crc_state], 0xFFFFFFFF
    ret

crc32_update:           ; ESI = data, ECX = length
    push eax
    push ecx
    
    mov eax, [crc_state]
    
.update_loop:
    crc32 eax, byte [esi]
    inc esi
    loop .update_loop
    
    mov [crc_state], eax
    
    pop ecx
    pop eax
    ret

crc32_final:
    mov eax, [crc_state]
    not eax
    ret

; File integrity checking
check_file_integrity:   ; ESI = file data, ECX = file size
    call calc_crc32
    
    cmp eax, [expected_crc]
    jne .integrity_failed
    
    ; File is valid
    clc
    ret
    
.integrity_failed:
    stc
    ret

; Storage block verification
verify_storage_block:   ; EBX = block number
    push esi
    push ecx
    
    ; Calculate block address
    mov esi, ebx
    shl esi, BLOCK_SIZE_LOG2
    add esi, [storage_base]
    
    ; Read stored CRC
    mov edi, [esi + BLOCK_SIZE - 4]
    
    ; Calculate CRC of block data
    mov ecx, BLOCK_SIZE - 4
    call calc_crc32
    
    cmp eax, edi
    pop ecx
    pop esi
    sete al
    movzx eax, al
    ret

; DMA buffer validation
validate_dma_transfer:  ; ESI = source, EDI = destination, ECX = length
    push eax
    push ebx
    push esi
    push ecx
    
    ; Calculate source CRC
    call calc_crc32
    mov ebx, eax
    
    ; Calculate destination CRC
    pop ecx
    pop esi
    push ecx
    mov esi, edi
    call calc_crc32
    
    ; Compare CRCs
    cmp eax, ebx
    pop ecx
    pop esi
    pop ebx
    pop eax
    sete al
    movzx eax, al
    ret
```

## AES-NI Instructions

Hardware-accelerated AES encryption/decryption operations.

**AESENC/AESENCLAST - AES Encryption Round**

```nasm
; AESENC xmm1, xmm2/m128 - Perform one AES encryption round
; AESENCLAST xmm1, xmm2/m128 - Perform last AES encryption round

; AES-128 encryption single block
aes128_encrypt_block:   ; XMM0 = plaintext, ESI = key schedule
    ; Load key schedule rounds
    movdqa xmm1, [esi]      ; Round 0 key
    pxor xmm0, xmm1         ; Initial AddRoundKey
    
    ; Rounds 1-9
    movdqa xmm1, [esi + 16]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [esi + 32]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [esi + 48]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [esi + 64]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [esi + 80]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [esi + 96]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [esi + 112]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [esi + 128]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [esi + 144]
    aesenc xmm0, xmm1
    
    ; Round 10 (last round)
    movdqa xmm1, [esi + 160]
    aesenclast xmm0, xmm1
    
    ; XMM0 contains ciphertext
    ret
```

**AESDEC/AESDECLAST - AES Decryption Round**

```nasm
; AESDEC xmm1, xmm2/m128 - Perform one AES decryption round
; AESDECLAST xmm1, xmm2/m128 - Perform last AES decryption round

; AES-128 decryption single block
aes128_decrypt_block:   ; XMM0 = ciphertext, ESI = key schedule
    ; Load key schedule rounds (in reverse order)
    movdqa xmm1, [esi + 160]    ; Round 10 key
    pxor xmm0, xmm1             ; Initial AddRoundKey
    
    ; Rounds 9-1
    movdqa xmm1, [esi + 144]
    aesdec xmm0, xmm1
    
    movdqa xmm1, [esi + 128]
    aesdec xmm0, xmm1
    
    movdqa xmm1, [esi + 112]
    aesdec xmm0, xmm1
    
    movdqa xmm1, [esi + 96]
    aesdec xmm0, xmm1
    
    movdqa xmm1, [esi + 80]
    aesdec xmm0, xmm1
    
    movdqa xmm1, [esi + 64]
    aesdec xmm0, xmm1
    
    movdqa xmm1, [esi + 48]
    aesdec xmm0, xmm1
    
    movdqa xmm1, [esi + 32]
    aesdec xmm0, xmm1
    movdqa xmm1, [esi + 16] 
    aesdec xmm0, xmm1

	; Round 0 (last round)
	movdqa xmm1, [esi]
	aesdeclast xmm0, xmm1
	
	; XMM0 contains plaintext
	ret
````

**AESIMC - AES Inverse Mix Columns**

```nasm
; AESIMC xmm1, xmm2/m128
; Performs inverse MixColumns transformation (for decryption key schedule)

; Convert encryption key schedule to decryption key schedule
convert_key_schedule:   ; ESI = encryption keys, EDI = decryption keys
    ; Copy round 0 and round 10 keys unchanged
    movdqa xmm0, [esi]
    movdqa [edi], xmm0
    
    movdqa xmm0, [esi + 160]
    movdqa [edi + 160], xmm0
    
    ; Apply InvMixColumns to middle rounds
    mov ecx, 9
    mov eax, 16
    
.convert_loop:
    movdqa xmm0, [esi + eax]
    aesimc xmm1, xmm0
    movdqa [edi + eax], xmm1
    
    add eax, 16
    loop .convert_loop
    
    ret
````

**AESKEYGENASSIST - AES Key Generation Assist**

```nasm
; AESKEYGENASSIST xmm1, xmm2/m128, imm8
; Assists in generating AES round keys

; AES-128 key expansion
aes128_key_expansion:   ; XMM0 = original key, ESI = key schedule output
    ; Store original key as round 0
    movdqa [esi], xmm0
    
    ; Round 1
    aeskeygenassist xmm1, xmm0, 0x01
    call key_expansion_128_step
    movdqa [esi + 16], xmm0
    
    ; Round 2
    aeskeygenassist xmm1, xmm0, 0x02
    call key_expansion_128_step
    movdqa [esi + 32], xmm0
    
    ; Round 3
    aeskeygenassist xmm1, xmm0, 0x04
    call key_expansion_128_step
    movdqa [esi + 48], xmm0
    
    ; Round 4
    aeskeygenassist xmm1, xmm0, 0x08
    call key_expansion_128_step
    movdqa [esi + 64], xmm0
    
    ; Round 5
    aeskeygenassist xmm1, xmm0, 0x10
    call key_expansion_128_step
    movdqa [esi + 80], xmm0
    
    ; Round 6
    aeskeygenassist xmm1, xmm0, 0x20
    call key_expansion_128_step
    movdqa [esi + 96], xmm0
    
    ; Round 7
    aeskeygenassist xmm1, xmm0, 0x40
    call key_expansion_128_step
    movdqa [esi + 112], xmm0
    
    ; Round 8
    aeskeygenassist xmm1, xmm0, 0x80
    call key_expansion_128_step
    movdqa [esi + 128], xmm0
    
    ; Round 9
    aeskeygenassist xmm1, xmm0, 0x1B
    call key_expansion_128_step
    movdqa [esi + 144], xmm0
    
    ; Round 10
    aeskeygenassist xmm1, xmm0, 0x36
    call key_expansion_128_step
    movdqa [esi + 160], xmm0
    
    ret

key_expansion_128_step:
    pshufd xmm1, xmm1, 0xFF     ; Broadcast high dword
    
    ; Shift and XOR cascade
    movdqa xmm2, xmm0
    pslldq xmm2, 4
    pxor xmm0, xmm2
    
    pslldq xmm2, 4
    pxor xmm0, xmm2
    
    pslldq xmm2, 4
    pxor xmm0, xmm2
    
    pxor xmm0, xmm1
    ret

; AES-256 key expansion
aes256_key_expansion:   ; XMM0 = key low, XMM1 = key high, ESI = key schedule
    ; Store original keys
    movdqa [esi], xmm0
    movdqa [esi + 16], xmm1
    
    ; Generate 14 round keys (AES-256 has 15 rounds including round 0)
    mov edi, 2
    
.expand_loop:
    ; Odd round
    aeskeygenassist xmm2, xmm1, 0x01
    call key_expansion_256_step_a
    movdqa [esi + edi*16], xmm0
    inc edi
    
    cmp edi, 14
    jge .done
    
    ; Even round
    aeskeygenassist xmm2, xmm0, 0x00
    call key_expansion_256_step_b
    movdqa [esi + edi*16], xmm1
    inc edi
    
    cmp edi, 14
    jl .expand_loop
    
.done:
    ret

key_expansion_256_step_a:
    pshufd xmm2, xmm2, 0xFF
    
    movdqa xmm3, xmm0
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pslldq xmm3, 4
    pxor xmm0, xmm3
    pxor xmm0, xmm2
    ret

key_expansion_256_step_b:
    pshufd xmm2, xmm2, 0xAA
    
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    ret
```

### AES Block Cipher Modes

**ECB Mode (Electronic Codebook)**

```nasm
; AES-128 ECB encryption
aes_ecb_encrypt:        ; ESI = plaintext, EDI = ciphertext, ECX = blocks, EBX = key schedule
    
.encrypt_loop:
    movdqu xmm0, [esi]      ; Load plaintext block
    
    push esi
    mov esi, ebx
    call aes128_encrypt_block
    pop esi
    
    movdqu [edi], xmm0      ; Store ciphertext block
    
    add esi, 16
    add edi, 16
    loop .encrypt_loop
    
    ret

; AES-128 ECB decryption
aes_ecb_decrypt:        ; ESI = ciphertext, EDI = plaintext, ECX = blocks, EBX = key schedule
    
.decrypt_loop:
    movdqu xmm0, [esi]
    
    push esi
    mov esi, ebx
    call aes128_decrypt_block
    pop esi
    
    movdqu [edi], xmm0
    
    add esi, 16
    add edi, 16
    loop .decrypt_loop
    
    ret
```

**CBC Mode (Cipher Block Chaining)**

```nasm
; AES-128 CBC encryption
aes_cbc_encrypt:        ; ESI = plaintext, EDI = ciphertext, ECX = blocks
                        ; EBX = key schedule, XMM7 = IV
    
.encrypt_loop:
    movdqu xmm0, [esi]      ; Load plaintext block
    pxor xmm0, xmm7         ; XOR with previous ciphertext (or IV)
    
    push esi
    mov esi, ebx
    call aes128_encrypt_block
    pop esi
    
    movdqa xmm7, xmm0       ; Save ciphertext for next block
    movdqu [edi], xmm0      ; Store ciphertext
    
    add esi, 16
    add edi, 16
    loop .encrypt_loop
    
    ret

; AES-128 CBC decryption
aes_cbc_decrypt:        ; ESI = ciphertext, EDI = plaintext, ECX = blocks
                        ; EBX = key schedule, XMM7 = IV
    
.decrypt_loop:
    movdqu xmm0, [esi]      ; Load ciphertext block
    movdqa xmm6, xmm0       ; Save for next iteration
    
    push esi
    mov esi, ebx
    call aes128_decrypt_block
    pop esi
    
    pxor xmm0, xmm7         ; XOR with previous ciphertext (or IV)
    movdqu [edi], xmm0
    
    movdqa xmm7, xmm6       ; Update IV for next block
    
    add esi, 16
    add edi, 16
    loop .decrypt_loop
    
    ret
```

**CTR Mode (Counter)**

```nasm
; AES-128 CTR mode (encryption and decryption are identical)
aes_ctr_process:        ; ESI = input, EDI = output, ECX = blocks
                        ; EBX = key schedule, XMM7 = counter/nonce
    
.process_loop:
    movdqa xmm0, xmm7       ; Copy counter
    
    ; Encrypt counter
    push esi
    mov esi, ebx
    call aes128_encrypt_block
    pop esi
    
    ; XOR with plaintext/ciphertext
    movdqu xmm1, [esi]
    pxor xmm0, xmm1
    movdqu [edi], xmm0
    
    ; Increment counter (big-endian)
    movdqa xmm0, xmm7
    pxor xmm1, xmm1
    pcmpeqd xmm1, xmm1      ; All 1s
    psrldq xmm1, 12         ; Keep only lowest dword as 1
    
    ; Reverse bytes for big-endian increment
    pshufb xmm0, [byte_reverse_mask]
    paddq xmm0, xmm1        ; Increment as 64-bit
    pshufb xmm0, [byte_reverse_mask]
    movdqa xmm7, xmm0
    
    add esi, 16
    add edi, 16
    loop .process_loop
    
    ret

byte_reverse_mask:
    db 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
```

**GCM Mode (Galois/Counter Mode) - Authenticated Encryption**

```nasm
; GCM multiplication in GF(2^128)
gcm_multiply:           ; XMM0 = X, XMM1 = H (hash key)
    pclmulqdq xmm2, xmm0, xmm1, 0x00    ; Low × Low
    pclmulqdq xmm3, xmm0, xmm1, 0x11    ; High × High
    pclmulqdq xmm4, xmm0, xmm1, 0x01    ; Low × High
    pclmulqdq xmm5, xmm0, xmm1, 0x10    ; High × Low
    
    ; Combine middle terms
    pxor xmm4, xmm5
    
    ; Shift and combine
    movdqa xmm5, xmm4
    pslldq xmm4, 8
    psrldq xmm5, 8
    pxor xmm2, xmm4         ; Low result
    pxor xmm3, xmm5         ; High result
    
    ; Reduction in GF(2^128) with polynomial x^128 + x^7 + x^2 + x + 1
    movdqa xmm4, xmm2
    movdqa xmm5, xmm2
    movdqa xmm6, xmm2
    
    pslld xmm4, 31
    pslld xmm5, 30
    pslld xmm6, 25
    
    pxor xmm4, xmm5
    pxor xmm4, xmm6
    
    movdqa xmm5, xmm4
    psrldq xmm5, 4
    pslldq xmm4, 12
    pxor xmm2, xmm4
    
    movdqa xmm4, xmm2
    movdqa xmm6, xmm2
    
    psrld xmm2, 1
    psrld xmm4, 2
    psrld xmm6, 7
    
    pxor xmm2, xmm4
    pxor xmm2, xmm6
    pxor xmm2, xmm5
    pxor xmm0, xmm2
    pxor xmm0, xmm3
    
    ret

; AES-GCM encryption with authentication
aes_gcm_encrypt:        ; ESI = plaintext, EDI = ciphertext, ECX = blocks
                        ; EBX = key schedule, XMM7 = counter, XMM6 = GHASH state
    push r12
    push r13
    
    mov r12, [hash_key]     ; H = E(K, 0^128)
    
.encrypt_loop:
    ; Increment counter
    movdqa xmm0, xmm7
    call increment_counter
    movdqa xmm7, xmm0
    
    ; Encrypt counter
    push esi
    mov esi, ebx
    call aes128_encrypt_block
    pop esi
    
    ; XOR with plaintext
    movdqu xmm1, [esi]
    pxor xmm0, xmm1
    movdqu [edi], xmm0
    
    ; Update GHASH
    pxor xmm6, xmm0         ; XOR ciphertext into state
    movdqa xmm1, [r12]      ; Load H
    movdqa xmm0, xmm6
    call gcm_multiply
    movdqa xmm6, xmm0
    
    add esi, 16
    add edi, 16
    loop .encrypt_loop
    
    pop r13
    pop r12
    ret

increment_counter:
    ; Increment 32-bit counter (rightmost 4 bytes)
    pextrd eax, xmm0, 3     ; Extract counter
    bswap eax               ; Convert to big-endian
    inc eax
    bswap eax               ; Convert back
    pinsrd xmm0, eax, 3     ; Insert back
    ret
```

### Optimized AES Implementations

**Parallel Block Processing**

```nasm
; Process 4 blocks in parallel for better throughput
aes_ctr_encrypt_4x:     ; ESI = plaintext, EDI = ciphertext, ECX = blocks (multiple of 4)
                        ; EBX = key schedule, XMM7 = initial counter
    push r12
    
    shr ecx, 2              ; Process 4 blocks at a time
    
.process_4_blocks:
    ; Prepare 4 counter values
    movdqa xmm0, xmm7
    call increment_counter
    movdqa xmm8, xmm0
    
    call increment_counter
    movdqa xmm9, xmm0
    
    call increment_counter
    movdqa xmm10, xmm0
    
    call increment_counter
    movdqa xmm11, xmm0
    movdqa xmm7, xmm0       ; Update counter for next iteration
    
    ; Load round keys
    movdqa xmm12, [ebx]
    movdqa xmm13, [ebx + 16]
    movdqa xmm14, [ebx + 32]
    movdqa xmm15, [ebx + 48]
    
    ; Initial round
    pxor xmm8, xmm12
    pxor xmm9, xmm12
    pxor xmm10, xmm12
    pxor xmm11, xmm12
    
    ; Round 1
    aesenc xmm8, xmm13
    aesenc xmm9, xmm13
    aesenc xmm10, xmm13
    aesenc xmm11, xmm13
    
    ; Round 2
    aesenc xmm8, xmm14
    aesenc xmm9, xmm14
    aesenc xmm10, xmm14
    aesenc xmm11, xmm14
    
    ; Rounds 3-9 (similar pattern)
    mov r12, 3
    
.round_loop:
    movdqa xmm12, [ebx + r12*16]
    aesenc xmm8, xmm12
    aesenc xmm9, xmm12
    aesenc xmm10, xmm12
    aesenc xmm11, xmm12
    
    inc r12
    cmp r12, 10
    jl .round_loop
    
    ; Last round
    movdqa xmm12, [ebx + 160]
    aesenclast xmm8, xmm12
    aesenclast xmm9, xmm12
    aesenclast xmm10, xmm12
    aesenclast xmm11, xmm12
    
    ; XOR with plaintext and store
    movdqu xmm0, [esi]
    pxor xmm8, xmm0
    movdqu [edi], xmm8
    
    movdqu xmm0, [esi + 16]
    pxor xmm9, xmm0
    movdqu [edi + 16], xmm9
    
    movdqu xmm0, [esi + 32]
    pxor xmm10, xmm0
    movdqu [edi + 32], xmm10
    
    movdqu xmm0, [esi + 48]
    pxor xmm11, xmm0
    movdqu [edi + 48], xmm11
    
    add esi, 64
    add edi, 64
    dec ecx
    jnz .process_4_blocks
    
    pop r12
    ret
```

**AES with PCLMULQDQ for Authentication**

```nasm
; Combined encryption + authentication using AES and PCLMULQDQ
aes_encrypt_and_auth:   ; ESI = data, EDI = output, ECX = length
                        ; EBX = AES key, R8 = auth key
    push r12
    push r13
    push r14
    
    ; Initialize authentication state
    pxor xmm15, xmm15       ; Auth accumulator
    
    ; Process full blocks
    mov r12, rcx
    shr r12, 4              ; Number of full blocks
    
.process_block:
    ; Load and encrypt
    movdqu xmm0, [esi]
    
    push esi
    mov esi, ebx
    call aes128_encrypt_block
    pop esi
    
    movdqu [edi], xmm0
    
    ; Update authentication
    pxor xmm15, xmm0        ; XOR ciphertext into auth state
    
    ; Polynomial multiplication for authentication
    movdqa xmm1, [r8]       ; Load auth key
    pclmulqdq xmm2, xmm15, xmm1, 0x00
    pclmulqdq xmm3, xmm15, xmm1, 0x11
    
    ; Reduction (simplified)
    pxor xmm15, xmm2
    pxor xmm15, xmm3
    
    add esi, 16
    add edi, 16
    dec r12
    jnz .process_block
    
    ; XMM15 contains authentication tag
    movdqu [auth_tag], xmm15
    
    pop r14
    pop r13
    pop r12
    ret
```

### Performance Optimization Techniques

**Cache-Conscious Implementation**

```nasm
; Process data in cache-friendly chunks
aes_bulk_encrypt_optimized:
    ; Process in 64KB chunks to fit in L1/L2 cache
    mov r12, rcx
    
.chunk_loop:
    mov r13, 4096           ; 64KB / 16 bytes per block
    cmp r12, r13
    cmovb r13, r12          ; Use remaining blocks if less than chunk
    
    ; Process this chunk
    mov rcx, r13
    call aes_ctr_encrypt_4x
    
    sub r12, r13
    jnz .chunk_loop
    
    ret
```

**Software Pipelining**

```nasm
; Interleave independent operations to hide latency
aes_pipelined_encrypt:
    ; Prepare multiple blocks to keep pipeline full
    movdqu xmm0, [esi]
    movdqu xmm4, [esi + 16]
    movdqu xmm8, [esi + 32]
    
    ; Round 0 for all blocks
    movdqa xmm12, [ebx]
    pxor xmm0, xmm12
    pxor xmm4, xmm12
    pxor xmm8, xmm12
    
    ; Round 1 for all blocks
    movdqa xmm13, [ebx + 16]
    aesenc xmm0, xmm13
    aesenc xmm4, xmm13
    aesenc xmm8, xmm13
    
    ; Continue pattern for remaining rounds...
    
    ret
```

**Key Points:**

- BMI1/BMI2 instructions provide efficient bit manipulation for packing/unpacking data structures, protocol parsing, and algorithmic operations
- PEXT and PDEP enable parallel bit extraction and deposition, crucial for data compression and Morton codes
- CRC32 instruction accelerates checksumming for data integrity verification in storage and networking
- AES-NI instructions provide hardware-accelerated encryption 10-20x faster than software implementations
- Parallel block processing and pipelining maximize throughput for bulk encryption operations
- Combined AES and authentication (GCM mode) provides both confidentiality and integrity in single pass
- Special-purpose instructions exploit dedicated silicon logic for operations that would require many general instructions

**Example:** Complete secure communication implementation using special instructions

```nasm
; Secure packet transmission combining CRC32 and AES-GCM
send_secure_packet:     ; ESI = data, ECX = length
    push rbx
    push r12
    push r13
    
    ; Calculate CRC32 of plaintext
    call calc_crc32
    mov [packet_crc], eax
    
    ; Prepare GCM encryption
    mov ebx, [aes_key_schedule]
    movdqu xmm7, [gcm_iv]
    pxor xmm6, xmm6         ; GHASH state
    
    ; Encrypt data
    mov edi, [output_buffer]
    call aes_gcm_encrypt
    
    ; Append authentication tag
    movdqu [edi], xmm6
    
    ; Transmit encrypted packet
    mov esi, [output_buffer]
    add ecx, 16             ; Include auth tag
    call transmit_data
    
    pop r13
    pop r12
    pop rbx
    ret

receive_secure_packet:  ; ESI = encrypted data, ECX = length
    push rbx
    push r12
    
    ; Extract authentication tag
    sub ecx, 16
    lea edi, [esi + ecx]
    movdqu xmm14, [edi]     ; Expected tag
    
    ; Decrypt and verify
    mov edi, [decrypt_buffer]
    mov ebx, [aes_key_schedule]
    movdqu xmm7, [gcm_iv]
    pxor xmm6, xmm6
    
    call aes_gcm_decrypt    ; XMM6 contains computed tag
    
    ; Verify authentication tag
    pcmpeqb xmm6, xmm14
    pmovmskb eax, xmm6
    cmp eax, 0xFFFF
    jne .auth_failed
    
    ; Verify CRC32 of decrypted data
    mov esi, [decrypt_buffer]
    call calc_crc32
    cmp eax, [packet_crc]
    jne .integrity_failed
    
    ; Packet is authentic and intact
    clc
    jmp .done
    
.auth_failed:
.integrity_failed:
    stc
    
.done:
    pop r12
    pop rbx
    ret
```

**Important related topics:**

- **AVX2/AVX-512 extensions** - Wider vector operations for parallel AES processing
- **SHA extensions** - Hardware-accelerated SHA-1 and SHA-256
- **RDRAND/RDSEED** - Hardware random number generation for cryptographic keys
- **Intel SGX instructions** - Secure enclave creation and management
- **VAES instructions** - Vector AES operations on 256/512-bit registers

---

## SHA Extensions

Intel SHA extensions (introduced with Intel processors from 2013 onwards) provide hardware-accelerated SHA-1 and SHA-256 hashing through dedicated instructions that significantly outperform software implementations.

### SHA Extension Detection

```asm
; Check for SHA extension support
check_sha_support:
    push ebx
    push ecx
    
    ; Query extended features (leaf 7, sub-leaf 0)
    mov eax, 7
    xor ecx, ecx
    cpuid
    
    ; Check SHA bit (bit 29 in EBX)
    test ebx, (1 << 29)
    setnz al
    
    pop ecx
    pop ebx
    ret

; Comprehensive feature check
check_crypto_features:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    
    mov edi, [ebp + 8]  ; Feature flags output
    
    ; Check SHA extensions
    mov eax, 7
    xor ecx, ecx
    cpuid
    
    test ebx, (1 << 29)
    setnz byte [edi]    ; SHA support
    
    ; Check AES-NI
    mov eax, 1
    cpuid
    test ecx, (1 << 25)
    setnz byte [edi + 1]
    
    ; Check AVX for SHA256 optimization
    test ecx, (1 << 28)
    setnz byte [edi + 2]
    
    pop ecx
    pop ebx
    pop ebp
    ret
```

### SHA-1 Implementation

```asm
; SHA-1 state structure (20 bytes = 5 dwords)
struc SHA1_CTX
    .h0:    resd 1
    .h1:    resd 1
    .h2:    resd 1
    .h3:    resd 1
    .h4:    resd 1
endstruc

; Initialize SHA-1 context
sha1_init:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp + 8]  ; SHA1_CTX pointer
    
    ; Initialize hash values (SHA-1 constants)
    mov dword [edi + SHA1_CTX.h0], 0x67452301
    mov dword [edi + SHA1_CTX.h1], 0xEFCDAB89
    mov dword [edi + SHA1_CTX.h2], 0x98BADCFE
    mov dword [edi + SHA1_CTX.h3], 0x10325476
    mov dword [edi + SHA1_CTX.h4], 0xC3D2E1F0
    
    pop edi
    pop ebp
    ret

; Process one SHA-1 block (64 bytes) using SHA extensions
sha1_process_block:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Message block pointer (64 bytes)
    mov edi, [ebp + 12] ; SHA1_CTX pointer
    
    ; Load current hash state into XMM registers
    ; ABCD state in xmm0, E in xmm1
    movdqu xmm0, [edi + SHA1_CTX.h0]
    movd xmm1, [edi + SHA1_CTX.h4]
    
    ; Save initial state
    movdqa xmm7, xmm0
    movdqa xmm6, xmm1
    
    ; Load message schedule (16 dwords)
    movdqu xmm2, [esi]
    movdqu xmm3, [esi + 16]
    movdqu xmm4, [esi + 32]
    movdqu xmm5, [esi + 48]
    
    ; Byte swap message words (SHA expects big-endian)
    pshufb xmm2, [sha1_shuf_mask]
    pshufb xmm3, [sha1_shuf_mask]
    pshufb xmm4, [sha1_shuf_mask]
    pshufb xmm5, [sha1_shuf_mask]
    
    ; Rounds 0-3 (using SHA1RNDS4 with immediate 0)
    movdqa xmm8, xmm2
    paddd xmm8, [sha1_k0]   ; Add round constant
    sha1rnds4 xmm0, xmm1, 0
    sha1msg1 xmm2, xmm3
    
    ; Rounds 4-7
    movdqa xmm8, xmm3
    paddd xmm8, [sha1_k0]
    sha1rnds4 xmm0, xmm1, 0
    sha1msg1 xmm3, xmm4
    pxor xmm2, xmm4
    
    ; Rounds 8-11
    movdqa xmm8, xmm4
    paddd xmm8, [sha1_k0]
    sha1rnds4 xmm0, xmm1, 0
    sha1msg1 xmm4, xmm5
    pxor xmm3, xmm5
    sha1msg2 xmm2, xmm5
    
    ; Rounds 12-15
    movdqa xmm8, xmm5
    paddd xmm8, [sha1_k0]
    sha1rnds4 xmm0, xmm1, 0
    sha1msg1 xmm5, xmm2
    pxor xmm4, xmm2
    sha1msg2 xmm3, xmm2
    
    ; Rounds 16-19
    movdqa xmm8, xmm2
    paddd xmm8, [sha1_k0]
    sha1rnds4 xmm0, xmm1, 0
    sha1msg1 xmm2, xmm3
    pxor xmm5, xmm3
    sha1msg2 xmm4, xmm3
    
    ; Rounds 20-23 (function F1, constant K1)
    movdqa xmm8, xmm3
    paddd xmm8, [sha1_k1]
    sha1rnds4 xmm0, xmm1, 1
    sha1msg1 xmm3, xmm4
    pxor xmm2, xmm4
    sha1msg2 xmm5, xmm4
    
    ; Continue for remaining rounds...
    ; Rounds 24-39 use function F1
    ; Rounds 40-59 use function F2
    ; Rounds 60-79 use function F3
    
    ; Rounds 40-43 (function F2, constant K2)
    movdqa xmm8, xmm2
    paddd xmm8, [sha1_k2]
    sha1rnds4 xmm0, xmm1, 2
    sha1msg1 xmm2, xmm3
    pxor xmm5, xmm3
    sha1msg2 xmm4, xmm3
    
    ; Rounds 60-63 (function F3, constant K3)
    movdqa xmm8, xmm4
    paddd xmm8, [sha1_k3]
    sha1rnds4 xmm0, xmm1, 3
    sha1msg1 xmm4, xmm5
    pxor xmm3, xmm5
    sha1msg2 xmm2, xmm5
    
    ; Final rounds 76-79
    movdqa xmm8, xmm5
    paddd xmm8, [sha1_k3]
    sha1rnds4 xmm0, xmm1, 3
    
    ; Add initial state
    paddd xmm0, xmm7
    paddd xmm1, xmm6
    
    ; Store updated hash
    movdqu [edi + SHA1_CTX.h0], xmm0
    movd [edi + SHA1_CTX.h4], xmm1
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; SHA-1 constants and masks
align 16
sha1_k0: times 4 dd 0x5A827999  ; Rounds 0-19
sha1_k1: times 4 dd 0x6ED9EBA1  ; Rounds 20-39
sha1_k2: times 4 dd 0x8F1BBCDC  ; Rounds 40-59
sha1_k3: times 4 dd 0xCA62C1D6  ; Rounds 60-79

sha1_shuf_mask:
    db 3, 2, 1, 0, 7, 6, 5, 4, 11, 10, 9, 8, 15, 14, 13, 12
```

### SHA-256 Implementation

```asm
; SHA-256 state structure (32 bytes = 8 dwords)
struc SHA256_CTX
    .h0:    resd 1
    .h1:    resd 1
    .h2:    resd 1
    .h3:    resd 1
    .h4:    resd 1
    .h5:    resd 1
    .h6:    resd 1
    .h7:    resd 1
endstruc

; Initialize SHA-256 context
sha256_init:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp + 8]
    
    ; Initialize hash values (first 32 bits of fractional parts
    ; of square roots of first 8 primes)
    mov dword [edi + SHA256_CTX.h0], 0x6A09E667
    mov dword [edi + SHA256_CTX.h1], 0xBB67AE85
    mov dword [edi + SHA256_CTX.h2], 0x3C6EF372
    mov dword [edi + SHA256_CTX.h3], 0xA54FF53A
    mov dword [edi + SHA256_CTX.h4], 0x510E527F
    mov dword [edi + SHA256_CTX.h5], 0x9B05688C
    mov dword [edi + SHA256_CTX.h6], 0x1F83D9AB
    mov dword [edi + SHA256_CTX.h7], 0x5BE0CD19
    
    pop edi
    pop ebp
    ret

; Process SHA-256 block using SHA extensions
sha256_process_block:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]  ; Message block (64 bytes)
    mov edi, [ebp + 12] ; SHA256_CTX pointer
    
    ; Load state
    ; ABEF in xmm0, CDGH in xmm1
    movdqu xmm0, [edi + SHA256_CTX.h0]
    movdqu xmm1, [edi + SHA256_CTX.h4]
    
    ; Shuffle state: {FEBA} and {HGDC}
    pshufd xmm0, xmm0, 0xB1  ; CDAB -> BADC
    pshufd xmm1, xmm1, 0x1B  ; EFGH -> HGFE
    movdqa xmm2, xmm0
    palignr xmm0, xmm1, 8    ; Get ABEF
    pblendw xmm2, xmm1, 0xF0 ; Get CDGH
    movdqa xmm1, xmm2
    
    ; Save initial state
    movdqa xmm7, xmm0
    movdqa xmm6, xmm1
    
    ; Load and prepare message schedule
    movdqu xmm2, [esi]
    movdqu xmm3, [esi + 16]
    movdqu xmm4, [esi + 32]
    movdqu xmm5, [esi + 48]
    
    ; Byte swap
    pshufb xmm2, [sha256_shuf_mask]
    pshufb xmm3, [sha256_shuf_mask]
    pshufb xmm4, [sha256_shuf_mask]
    pshufb xmm5, [sha256_shuf_mask]
    
    ; Round 0
    movdqa xmm8, xmm2
    paddd xmm8, [sha256_k]
    sha256rnds2 xmm0, xmm1
    pshufd xmm8, xmm8, 0x0E
    sha256rnds2 xmm1, xmm0
    sha256msg1 xmm2, xmm3
    
    ; Round 1
    movdqa xmm8, xmm3
    paddd xmm8, [sha256_k + 16]
    sha256rnds2 xmm0, xmm1
    pshufd xmm8, xmm8, 0x0E
    sha256rnds2 xmm1, xmm0
    sha256msg1 xmm3, xmm4
    
    ; Round 2
    movdqa xmm8, xmm4
    paddd xmm8, [sha256_k + 32]
    sha256rnds2 xmm0, xmm1
    pshufd xmm8, xmm8, 0x0E
    sha256rnds2 xmm1, xmm0
    sha256msg1 xmm4, xmm5
    
    ; Round 3
    movdqa xmm8, xmm5
    paddd xmm8, [sha256_k + 48]
    sha256rnds2 xmm0, xmm1
    movdqa xmm9, xmm5
    palignr xmm9, xmm4, 4
    paddd xmm2, xmm9
    sha256msg2 xmm2, xmm5
    pshufd xmm8, xmm8, 0x0E
    sha256rnds2 xmm1, xmm0
    sha256msg1 xmm5, xmm2
    
    ; Rounds 4-11 (similar pattern)
    ; Each round processes 4 message words
    
    mov ecx, 12         ; Remaining rounds
    lea ebx, [sha256_k + 64]
    
.round_loop:
    ; Compute message schedule
    movdqa xmm8, xmm2
    paddd xmm8, [ebx]
    sha256rnds2 xmm0, xmm1
    
    movdqa xmm9, xmm2
    palignr xmm9, xmm5, 4
    paddd xmm3, xmm9
    sha256msg2 xmm3, xmm2
    
    pshufd xmm8, xmm8, 0x0E
    sha256rnds2 xmm1, xmm0
    sha256msg1 xmm2, xmm3
    
    ; Rotate message registers
    movdqa xmm9, xmm2
    movdqa xmm2, xmm3
    movdqa xmm3, xmm4
    movdqa xmm4, xmm5
    movdqa xmm5, xmm9
    
    add ebx, 16
    dec ecx
    jnz .round_loop
    
    ; Add initial state
    paddd xmm0, xmm7
    paddd xmm1, xmm6
    
    ; Shuffle back and store
    pshufd xmm0, xmm0, 0x1B
    pshufd xmm1, xmm1, 0xB1
    movdqa xmm2, xmm0
    pblendw xmm0, xmm1, 0xF0
    palignr xmm1, xmm2, 8
    
    movdqu [edi + SHA256_CTX.h0], xmm0
    movdqu [edi + SHA256_CTX.h4], xmm1
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

align 16
sha256_shuf_mask:
    db 3, 2, 1, 0, 7, 6, 5, 4, 11, 10, 9, 8, 15, 14, 13, 12

; SHA-256 K constants (first 32 bits of fractional parts
; of cube roots of first 64 primes)
align 16
sha256_k:
    dd 0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5
    dd 0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5
    dd 0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3
    dd 0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174
    dd 0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC
    dd 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA
    dd 0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7
    dd 0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967
    dd 0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13
    dd 0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85
    dd 0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3
    dd 0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070
    dd 0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5
    dd 0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3
    dd 0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208
    dd 0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2
```

### Complete Hash Function with Padding

```asm
; Compute SHA-256 hash of arbitrary-length message
sha256_hash:
    push ebp
    mov ebp, esp
    sub esp, 80          ; Space for context + temp buffer
    push ebx
    push esi
    push edi
    
    lea eax, [ebp - 32]
    push eax
    call sha256_init
    add esp, 4
    
    mov esi, [ebp + 8]   ; Message pointer
    mov ecx, [ebp + 12]  ; Message length in bytes
    mov ebx, ecx         ; Save original length
    
.process_blocks:
    cmp ecx, 64
    jb .final_block
    
    ; Process full block
    lea eax, [ebp - 32]
    push eax
    push esi
    call sha256_process_block
    add esp, 8
    
    add esi, 64
    sub ecx, 64
    jmp .process_blocks
    
.final_block:
    ; Prepare final block with padding
    lea edi, [ebp - 80]  ; Temp buffer
    
    ; Copy remaining message
    push ecx
    push esi
    push edi
    call memcpy
    add esp, 12
    
    ; Add padding bit
    add edi, ecx
    mov byte [edi], 0x80
    inc edi
    
    ; Calculate padding size
    mov eax, ecx
    inc eax              ; Include padding bit
    mov edx, 64
    sub edx, eax
    
    ; Check if we need two blocks
    cmp edx, 8           ; Need 8 bytes for length
    jae .single_final_block
    
    ; Zero padding to end of block
    push edx
    xor eax, eax
    mov ecx, edx
    rep stosb
    pop edx
    
    ; Process first final block
    lea eax, [ebp - 32]
    push eax
    lea eax, [ebp - 80]
    push eax
    call sha256_process_block
    add esp, 8
    
    ; Prepare second block with length
    lea edi, [ebp - 80]
    xor eax, eax
    mov ecx, 14          ; 56 bytes of zeros
    rep stosd
    
    jmp .append_length
    
.single_final_block:
    ; Zero padding
    sub edx, 8
    xor eax, eax
    mov ecx, edx
    rep stosb
    
.append_length:
    ; Append message length in bits (big-endian)
    mov eax, ebx
    shl eax, 3           ; Convert bytes to bits
    bswap eax
    stosd
    xor eax, eax
    stosd
    
    ; Process final block
    lea eax, [ebp - 32]
    push eax
    lea eax, [ebp - 80]
    push eax
    call sha256_process_block
    add esp, 8
    
    ; Copy hash to output (big-endian)
    mov edi, [ebp + 16]  ; Output buffer (32 bytes)
    lea esi, [ebp - 32]
    mov ecx, 8
    
.copy_hash:
    mov eax, [esi]
    bswap eax
    stosd
    add esi, 4
    loop .copy_hash
    
    pop edi
    pop esi
    pop ebx
    add esp, 80
    pop ebp
    ret
```

### Performance-Optimized SHA-256

```asm
; Multi-block SHA-256 processing for throughput
sha256_process_multiple_blocks:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]   ; Message blocks array
    mov ecx, [ebp + 12]  ; Number of blocks
    mov edi, [ebp + 16]  ; SHA256_CTX pointer
    
.block_loop:
    push ecx
    
    ; Process block
    push edi
    push esi
    call sha256_process_block
    add esp, 8
    
    add esi, 64
    pop ecx
    loop .block_loop
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; HMAC-SHA256 implementation
hmac_sha256:
    push ebp
    mov ebp, esp
    sub esp, 160         ; Space for contexts and pads
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]   ; Key
    mov ecx, [ebp + 12]  ; Key length
    mov ebx, [ebp + 16]  ; Message
    mov edx, [ebp + 20]  ; Message length
    
    ; Prepare key pad
    lea edi, [ebp - 64]  ; ipad
    
    cmp ecx, 64
    jbe .key_short
    
    ; Hash long key
    push edi
    push ecx
    push esi
    call sha256_hash
    add esp, 12
    mov ecx, 32
    
.key_short:
    ; Copy key
    push ecx
    push esi
    push edi
    call memcpy
    add esp, 12
    
    ; Pad with zeros
    add edi, ecx
    mov ecx, 64
    sub ecx, [ebp + 12]
    xor eax, eax
    rep stosb
    
    ; XOR with ipad constant (0x36)
    lea esi, [ebp - 64]
    mov ecx, 16
.xor_ipad:
    mov eax, [esi]
    xor eax, 0x36363636
    mov [esi], eax
    add esi, 4
    loop .xor_ipad
    
    ; Hash (ipad || message)
    lea edi, [ebp - 128]  ; Inner hash context
    push edi
    call sha256_init
    add esp, 4
    
    push edi
    lea eax, [ebp - 64]
    push eax
    call sha256_process_block
    add esp, 8
    
    ; Process message blocks
    ; [Inference] Process full blocks then final with padding
    
    ; Prepare opad
    lea edi, [ebp - 64]
    lea esi, [ebp - 64]
    mov ecx, 16
.xor_opad:
    mov eax, [esi]
    xor eax, 0x36363636   ; Undo ipad
    xor eax, 0x5C5C5C5C   ; Apply opad
    stosd
    add esi, 4
    loop .xor_opad
    
    ; Hash (opad || inner_hash)
    ; [Inference] Similar process to inner hash
    
    pop edi
    pop esi
    pop ebx
    add esp, 160
    pop ebp
    ret
```

## Random Number Generation

Beyond RDRAND and RDSEED covered earlier, x86 provides additional instructions and techniques for random number generation in various contexts.

### Entropy Mixing Techniques

```asm
; Mix multiple entropy sources for enhanced randomness
generate_entropy_pool:
    push ebp
    mov ebp, esp
    sub esp, 32
    push ebx
    push esi
    push edi
    
    mov edi, [ebp + 8]   ; Output buffer
    mov ecx, [ebp + 12]  ; Size in dwords
    
.generate_loop:
    ; Source 1: RDSEED
    call check_rdseed_support
    test al, al
    jz .use_rdrand_1
    
    rdseed eax
    jc .got_seed
    
.use_rdrand_1:
    rdrand eax
    
.got_seed:
    mov ebx, eax
    
    ; Source 2: TSC
    rdtsc
    xor ebx, eax
    rol ebx, 13
    xor ebx, edx
    
    ; Source 3: RDRAND again
    rdrand eax
    xor ebx, eax
    
    ; Source 4: System state (stack pointer, instruction pointer)
    mov eax, esp
    xor ebx, eax
    
    call get_eip
    xor ebx, eax
    
    ; Source 5: Performance counter jitter
    mov ecx, 0xC1        ; IA32_PMC0
    rdmsr
    xor ebx, eax
    
    ; Mix using avalanche function
    mov eax, ebx
    call avalanche_hash
    
    stosd
    mov ecx, [ebp + 12]
    loop .generate_loop
    
    pop edi
    pop esi
    pop ebx
    add esp, 32
    pop ebp
    ret

get_eip:
    mov eax, [esp]
    ret

; Avalanche hash for mixing
avalanche_hash:
    ; Bob Jenkins' 32-bit integer hash
    mov ebx, eax
    
    sub eax, ebx
    xor eax, (ebx >> 15)
    add eax, (ebx << 3)
    
    xor eax, (eax >> 12)
    add eax, (eax << 2)
    xor eax, (eax >> 4)
    
    imul eax, 2057
    xor eax, (eax >> 16)
    
    ret
```

### Cryptographically Secure PRNG

```asm
; ChaCha20-based CSPRNG
struc ChaCha20State
    .state:     resd 16  ; 64 bytes
    .position:  resd 1   ; Current position in keystream
    .rounds:    resd 1   ; Number of rounds (usually 20)
endstruc

; Initialize ChaCha20 state
chacha20_init:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov edi, [ebp + 8]   ; ChaCha20State pointer
    mov esi, [ebp + 12]  ; 32-byte key
    mov ebx, [ebp + 16]  ; 12-byte nonce
    
    ; Set constants "expand 32-byte k"
    mov dword [edi + ChaCha20State.state], 0x61707865
    mov dword [edi + ChaCha20State.state + 4], 0x3320646E
    mov dword [edi + ChaCha20State.state + 8], 0x79622D32
    mov dword [edi + ChaCha20State.state + 12], 0x6B206574
    
    ; Copy key (8 words)
    mov ecx, 8
    lea edi, [edi + ChaCha20State.state + 16]
    rep movsd
    
    ; Set counter
    mov dword [edi], 0
    add edi, 4
    
    ; Copy nonce (3 words)
    mov esi, ebx
    mov ecx, 3
    rep movsd
    
    ; Set parameters
    mov edi, [ebp + 8]
    mov dword [edi + ChaCha20State.position], 64
    mov dword [edi + ChaCha20State.rounds], 20
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; ChaCha20 quarter round macro
%macro CHACHA_QUARTERROUND 4
    ; Args: %1=a, %2=b, %3=c, %4=d
    add %1, %2
    xor %4, %1
    rol %4, 16
    
    add %3, %4
    xor %2, %3
    rol %2, 12
    
    add %1, %2
    xor %4, %1
    rol %4, 8
    
    add %3, %4
    xor %2, %3
    rol %2, 7
%endmacro

; ChaCha20 block function
chacha20_block:
    push ebp
    mov ebp, esp
    sub esp, 64          ; Working state
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]   ; ChaCha20State pointer
    lea edi, [ebp - 64]  ; Working buffer
    
    ; Copy state to working buffer
    push esi
    mov ecx, 16
    lea esi, [esi + ChaCha20State.state]
    rep movsd
    pop esi
    
    ; Perform rounds
    mov ecx, [esi + ChaCha20State.rounds]
    shr ecx, 1           ; Double rounds
    
.round_loop:
    push ecx
    
    ; Column rounds
    mov eax, [ebp - 64]      ; state[0]
    mov ebx, [ebp - 60]      ; state[1]
    mov ecx, [ebp - 56]      ; state[2]
    mov edx, [ebp - 52]      ; state[3]
    CHACHA_QUARTERROUND eax, ebx, ecx, edx
    mov [ebp - 64], eax
    mov [ebp - 60], ebx
    mov [ebp - 56], ecx
    mov [ebp - 52], edx
    
    mov eax, [ebp - 48]      ; state[4]
    mov ebx, [ebp - 44]      ; state[5]
    mov ecx, [ebp - 40]      ; state[6]
    mov edx, [ebp - 36]      ; state[7]
    CHACHA_QUARTERROUND eax, ebx, ecx, edx
    mov [ebp - 48], eax
    mov [ebp - 44], ebx
    mov [ebp - 40], ecx
    mov [ebp - 36], edx
    
    mov eax, [ebp - 32]      ; state[8]
    mov ebx, [ebp - 28]      ; state[9]
    mov ecx, [ebp - 24]      ; state[10]
    mov edx, [ebp - 20]      ; state[11]
    CHACHA_QUARTERROUND eax, ebx, ecx, edx
    mov [ebp - 32], eax
    mov [ebp - 28], ebx
    mov [ebp - 24], ecx
    mov [ebp - 20], edx
    
    mov eax, [ebp - 16]      ; state[12]
    mov ebx, [ebp - 12]      ; state[13]
    mov ecx, [ebp - 8]       ; state[14]
    mov edx, [ebp - 4]       ; state[15]
    CHACHA_QUARTERROUND eax, ebx, ecx, edx
    mov [ebp - 16], eax
    mov [ebp - 12], ebx
    mov [ebp - 8], ecx
    mov [ebp - 4], edx
    
    ; Diagonal rounds
    mov eax, [ebp - 64]      ; state[0]
    mov ebx, [ebp - 44]      ; state[5]
    mov ecx, [ebp - 24]      ; state[10]
    mov edx, [ebp - 4]       ; state[15]
    CHACHA_QUARTERROUND eax, ebx, ecx, edx
    mov [ebp - 64], eax
    mov [ebp - 44], ebx
    mov [ebp - 24], ecx
    mov [ebp - 4], edx
    
    mov eax, [ebp - 60]      ; state[1]
    mov ebx, [ebp - 40]      ; state[6]
    mov ecx, [ebp - 20]      ; state[11]
    mov edx, [ebp - 52]      ; state[3]
    CHACHA_QUARTERROUND eax, ebx, ecx, edx
    mov [ebp - 60], eax
    mov [ebp - 40], ebx
    mov [ebp - 20], ecx
    mov [ebp - 52], edx
    
    mov eax, [ebp - 56]      ; state[2]
    mov ebx, [ebp - 36]      ; state[7]
    mov ecx, [ebp - 16]      ; state[12]
    mov edx, [ebp - 48]      ; state[4]
    CHACHA_QUARTERROUND eax, ebx, ecx, edx
    mov [ebp - 56], eax
    mov [ebp - 36], ebx
    mov [ebp - 16], ecx
    mov [ebp - 48], edx
    
    mov eax, [ebp - 48]      ; state[3]
    mov ebx, [ebp - 32]      ; state[8]
    mov ecx, [ebp - 12]      ; state[13]
    mov edx, [ebp - 44]      ; state[6]
    CHACHA_QUARTERROUND eax, ebx, ecx, edx
    mov [ebp - 48], eax
    mov [ebp - 32], ebx
    mov [ebp - 12], ecx
    mov [ebp - 44], edx
    
    pop ecx
    dec ecx
    jnz .round_loop
    
    ; Add original state
    mov esi, [ebp + 8]
    lea edi, [ebp - 64]
    lea esi, [esi + ChaCha20State.state]
    mov ecx, 16
    
.add_state:
    mov eax, [edi]
    add eax, [esi]
    mov [edi], eax
    add edi, 4
    add esi, 4
    loop .add_state
    
    ; Copy result to output
    mov edi, [ebp + 12]  ; Output buffer
    lea esi, [ebp - 64]
    mov ecx, 16
    rep movsd
    
    ; Increment counter
    mov esi, [ebp + 8]
    inc dword [esi + ChaCha20State.state + 48]
    
    pop edi
    pop esi
    pop ebx
    add esp, 64
    pop ebp
    ret

; Generate random bytes using ChaCha20
chacha20_random_bytes:
    push ebp
    mov ebp, esp
    sub esp, 64
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]   ; ChaCha20State pointer
    mov edi, [ebp + 12]  ; Output buffer
    mov ecx, [ebp + 16]  ; Number of bytes
    
.generate_loop:
    test ecx, ecx
    jz .done
    
    ; Check if we need new keystream block
    cmp dword [esi + ChaCha20State.position], 64
    jb .have_keystream
    
    ; Generate new keystream block
    lea eax, [ebp - 64]
    push eax
    push esi
    call chacha20_block
    add esp, 8
    
    mov dword [esi + ChaCha20State.position], 0
    
.have_keystream:
    ; Copy bytes from keystream
    mov ebx, [esi + ChaCha20State.position]
    lea eax, [ebp - 64]
    mov al, [eax + ebx]
    stosb
    
    inc dword [esi + ChaCha20State.position]
    dec ecx
    jmp .generate_loop
    
.done:
    pop edi
    pop esi
    pop ebx
    add esp, 64
    pop ebp
    ret
```

### Timing Attack Resistant Random Delay

```asm
; Generate random delay resistant to timing analysis
secure_random_delay:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    
    ; Generate random delay count
    rdrand eax
    and eax, 0xFFFF      ; Limit maximum delay
    mov ecx, eax
    
    ; Add base delay
    add ecx, 1000
    
.delay_loop:
    ; Use unpredictable operations
    rdtsc
    xor eax, edx
    
    ; Cache line flush for timing resistance
    ; [Inference] Prevents timing attacks based on cache state
    clflush [delay_dummy]
    
    pause
    pause
    loop .delay_loop
    
    pop ecx
    pop ebx
    pop ebp
    ret

align 64
delay_dummy: dd 0
```

## Conditional Move (CMOV)

CMOV instructions enable branchless conditional execution, eliminating branch misprediction penalties and preventing timing side-channels in security-critical code.

### Basic CMOV Operations

```asm
; Check CMOV support
check_cmov_support:
    push ebx
    push ecx
    
    mov eax, 1
    cpuid
    test edx, (1 << 15)  ; CMOV bit
    setnz al
    
    pop ecx
    pop ebx
    ret

; Conditional move based on comparison
; result = (a > b) ? x : y
conditional_select_gt:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]   ; a
    mov ebx, [ebp + 12]  ; b
    mov ecx, [ebp + 16]  ; x (value if true)
    mov edx, [ebp + 20]  ; y (value if false)
    
    ; Start with false value
    mov eax, edx
    
    ; Compare and conditionally move
    mov ebx, [ebp + 8]
    cmp ebx, [ebp + 12]
    cmovg eax, ecx       ; Move x to eax if a > b
    
    pop ebp
    ret

; All CMOV variants
cmov_examples:
    push ebp
    mov ebp, esp
    
    mov eax, [value_a]
    mov ebx, [value_b]
    
    ; Conditional moves based on flags
    cmp eax, ebx
    
    cmove ecx, edx       ; Move if equal (ZF=1)
    cmovne ecx, edx      ; Move if not equal (ZF=0)
    
    cmovl ecx, edx       ; Move if less (SF≠OF)
    cmovle ecx, edx      ; Move if less or equal (ZF=1 or SF≠OF)
    cmovg ecx, edx       ; Move if greater (ZF=0 and SF=OF)
    cmovge ecx, edx      ; Move if greater or equal (SF=OF)
    
    cmova ecx, edx       ; Move if above (CF=0 and ZF=0) [unsigned]
    cmovae ecx, edx      ; Move if above or equal (CF=0) [unsigned]
    cmovb ecx, edx       ; Move if below (CF=1) [unsigned]
    cmovbe ecx, edx      ; Move if below or equal (CF=1 or ZF=1) [unsigned]
    
    cmovs ecx, edx       ; Move if sign (SF=1)
    cmovns ecx, edx      ; Move if not sign (SF=0)
    
    cmovo ecx, edx       ; Move if overflow (OF=1)
    cmovno ecx, edx      ; Move if not overflow (OF=0)
    
    cmovp ecx, edx       ; Move if parity (PF=1)
    cmovnp ecx, edx      ; Move if not parity (PF=0)
    
    pop ebp
    ret

value_a: dd 10
value_b: dd 20
```

### Constant-Time Comparison

```asm
; Constant-time equality check (timing-attack resistant)
constant_time_equals:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]   ; Buffer 1
    mov edi, [ebp + 12]  ; Buffer 2
    mov ecx, [ebp + 16]  ; Length
    
    xor eax, eax         ; Result accumulator
    
.compare_loop:
    mov bl, [esi]
    xor bl, [edi]        ; XOR difference
    or al, bl            ; Accumulate differences
    
    inc esi
    inc edi
    dec ecx
    
    ; Use constant-time loop continuation
    xor ebx, ebx
    test ecx, ecx
    cmovnz ebx, ecx      ; ebx = (ecx != 0) ? ecx : 0
    test ebx, ebx
    jnz .compare_loop
    
    ; Convert to boolean (0 or 1)
    test al, al
    setz al              ; al = (result == 0) ? 1 : 0
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Constant-time conditional copy
constant_time_conditional_copy:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov edi, [ebp + 8]   ; Destination
    mov esi, [ebp + 12]  ; Source
    mov ecx, [ebp + 16]  ; Length
    mov edx, [ebp + 20]  ; Condition (0 or 1)
    
    ; Create mask: 0x00000000 if condition=0, 0xFFFFFFFF if condition=1
    xor eax, eax
    test edx, edx
    cmovnz eax, [all_ones]
    
.copy_loop:
    mov ebx, [esi]       ; Load source
    mov edx, [edi]       ; Load current dest
    
    ; result = (src & mask) | (dest & ~mask)
    and ebx, eax
    not eax
    and edx, eax
    not eax
    or ebx, edx
    
    mov [edi], ebx
    
    add esi, 4
    add edi, 4
    sub ecx, 4
    jnz .copy_loop
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

all_ones: dd 0xFFFFFFFF
```

### Branchless Min/Max

```asm
; Branchless minimum
branchless_min:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]   ; a
    mov ebx, [ebp + 12]  ; b
    
    cmp eax, ebx
    cmovg eax, ebx       ; If a > b, use b
    
    pop ebp
    ret

; Branchless maximum
branchless_max:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]   ; a
    mov ebx, [ebp + 12]  ; b
    
    cmp eax, ebx
    cmovl eax, ebx       ; If a < b, use b
    
    pop ebp
    ret

; Branchless clamp (limit value to range)
branchless_clamp:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]   ; value
    mov ebx, [ebp + 12]  ; min
    mov ecx, [ebp + 16]  ; max
    
    ; result = max(min, min(value, max))
    cmp eax, ecx
    cmovg eax, ecx       ; Clamp to max
    
    cmp eax, ebx
    cmovl eax, ebx       ; Clamp to min
    
    pop ebx
    pop ebp
    ret

; Branchless absolute value
branchless_abs:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]   ; value
    mov ebx, eax
    sar ebx, 31          ; Sign bit mask (all 1s if negative)
    
    xor eax, ebx         ; Flip bits if negative
    sub eax, ebx         ; Add 1 if negative
    
    pop ebp
    ret
```

### Cryptographic Applications

```asm
; Constant-time array lookup (prevents cache timing attacks)
constant_time_lookup:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp + 8]   ; Array
    mov ecx, [ebp + 12]  ; Array length
    mov edx, [ebp + 16]  ; Target index
    
    xor eax, eax         ; Result accumulator
    xor edi, edi         ; Current index
    
.lookup_loop:
    mov ebx, [esi + edi*4]  ; Load element
    
    ; Check if current index matches target
    cmp edi, edx
    cmove eax, ebx       ; Accumulate if match
    
    inc edi
    cmp edi, ecx
    jb .lookup_loop
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Constant-time bit extraction
constant_time_bit_extract:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]   ; Value
    mov ecx, [ebp + 12]  ; Bit position
    
    ; Extract bit without branching
    shr eax, cl
    and eax, 1
    
    pop ebp
    ret

; Select from two values based on bit
constant_time_select_bit:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]   ; Value if bit=1
    mov ebx, [ebp + 12]  ; Value if bit=0
    mov ecx, [ebp + 16]  ; Selector bit
    
    ; Create mask from bit
    neg ecx              ; 0 -> 0, 1 -> 0xFFFFFFFF
    
    ; result = (val1 & mask) | (val0 & ~mask)
    mov edx, eax
    and edx, ecx
    not ecx
    and ebx, ecx
    or eax, edx
    or eax, ebx
    
    pop ebp
    ret
```

### Side-Channel Resistant Operations

```asm
; Constant-time modular reduction
constant_time_mod:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]   ; dividend
    mov ebx, [ebp + 12]  ; divisor
    
    ; Perform multiple conditional subtractions
    xor ecx, ecx         ; Iteration counter
    
.reduce_loop:
    ; Calculate difference
    mov edx, eax
    sub edx, ebx
    
    ; Conditionally select
    cmp eax, ebx
    cmovae eax, edx      ; Use difference if dividend >= divisor
    
    inc ecx
    cmp ecx, 32          ; Sufficient iterations for 32-bit
    jb .reduce_loop
    
    pop ebx
    pop ebp
    ret

; Constant-time swap (pointer swap without branching)
constant_time_swap_pointers:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]   ; Pointer to ptr1
    mov ebx, [ebp + 12]  ; Pointer to ptr2
    mov ecx, [ebp + 16]  ; Condition (0 or 1)
    
    mov esi, [eax]       ; Load ptr1
    mov edi, [ebx]       ; Load ptr2
    
    ; Create mask
    neg ecx              ; 0 -> 0, 1 -> 0xFFFFFFFF
    
    ; XOR both with XOR of values if condition
    mov edx, esi
    xor edx, edi
    and edx, ecx
    
    xor esi, edx
    xor edi, edx
    
    ; Store back
    mov [eax], esi
    mov [ebx], edi
    
    pop ebx
    pop ebp
    ret

; Constant-time memcmp
constant_time_memcmp:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp + 8]   ; Buffer 1
    mov edi, [ebp + 12]  ; Buffer 2
    mov ecx, [ebp + 16]  ; Length
    
    xor eax, eax         ; Difference accumulator
    xor edx, edx
    
.compare_loop:
    ; Always load and compare
    movzx ebx, byte [esi]
    movzx edx, byte [edi]
    
    xor ebx, edx         ; Calculate difference
    or eax, ebx          ; Accumulate any differences
    
    inc esi
    inc edi
    
    ; Constant-time loop continuation
    dec ecx
    jnz .compare_loop
    
    ; Return 0 if equal, non-zero if different
    pop edi
    pop esi
    pop ebp
    ret
```

### Performance-Critical Selection

```asm
; Fast selection for array indexing
fast_select_index:
    push ebp
    mov ebp, esp
    
    ; Select index based on multiple conditions
    mov eax, [ebp + 8]   ; condition1
    mov ebx, [ebp + 12]  ; condition2
    mov ecx, [ebp + 16]  ; condition3
    
    xor edx, edx         ; Result index
    
    ; Build index from conditions
    test eax, eax
    cmovnz edx, [index_1]
    
    test ebx, ebx
    cmovnz edx, [index_2]
    
    test ecx, ecx
    cmovnz edx, [index_3]
    
    mov eax, edx
    
    pop ebp
    ret

index_1: dd 10
index_2: dd 20
index_3: dd 30

; Branchless state machine transition
state_machine_transition:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]   ; Current state
    mov ebx, [ebp + 12]  ; Input event
    
    ; Lookup table approach with CMOV
    lea esi, [transition_table]
    
    ; Calculate offset: (state * num_events + event) * 4
    imul eax, 16         ; Assume 16 possible events
    add eax, ebx
    shl eax, 2
    
    mov eax, [esi + eax] ; Load new state
    
    ; Validate state (ensure within range)
    xor ecx, ecx
    cmp eax, MAX_STATES
    cmovae eax, ecx      ; Reset to 0 if invalid
    
    pop ebx
    pop ebp
    ret

%define MAX_STATES 8
transition_table:
    times 128 dd 0       ; State transition table
```

### Comparison with Branching Code

```asm
; Traditional branching min (subject to branch misprediction)
branching_min:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    
    cmp eax, ebx
    jle .use_a
    mov eax, ebx
.use_a:
    pop ebp
    ret
    ; Cost: ~1 cycle if predicted, ~15-20 cycles if mispredicted

; CMOV version (no branch)
cmov_min:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    
    cmp eax, ebx
    cmovg eax, ebx
    
    pop ebp
    ret
    ; Cost: ~2-3 cycles always, no misprediction penalty

; Benchmark comparison
benchmark_cmov_vs_branch:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov ecx, 1000000     ; Iterations
    
    ; Time branching version
    rdtsc
    mov esi, eax
    mov edi, edx
    
.branch_loop:
    push 20
    push 10
    call branching_min
    add esp, 8
    loop .branch_loop
    
    rdtsc
    sub eax, esi
    sbb edx, edi
    mov [branch_cycles], eax
    
    ; Time CMOV version
    mov ecx, 1000000
    rdtsc
    mov esi, eax
    mov edi, edx
    
.cmov_loop:
    push 20
    push 10
    call cmov_min
    add esp, 8
    loop .cmov_loop
    
    rdtsc
    sub eax, esi
    sbb edx, edi
    mov [cmov_cycles], eax
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

branch_cycles: dd 0
cmov_cycles: dd 0
```

**Key Points:**

- SHA extensions provide hardware acceleration for SHA-1 and SHA-256 through dedicated instructions (SHA1RNDS4, SHA1MSG1, SHA256RNDS2, SHA256MSG1, SHA256MSG2) that process multiple rounds per instruction
- RDRAND and RDSEED generate cryptographically secure random numbers, with RDSEED providing higher-quality entropy directly from the hardware source while RDRAND uses a DRBG for higher throughput
- CMOV instructions enable constant-time conditional operations essential for preventing timing side-channel attacks in cryptographic code by eliminating data-dependent branches
- [Inference] SHA extensions achieve 3-5x performance improvement over software implementations by processing multiple rounds in parallel and eliminating loop overhead
- [Inference] Constant-time implementations using CMOV prevent cache timing attacks and speculative execution vulnerabilities by ensuring execution time is independent of secret data
- [Inference] CMOV is beneficial when branch misprediction cost exceeds CMOV latency (~2-3 cycles), typically for unpredictable conditions or security-critical code
- Mixing multiple entropy sources (RDSEED, RDRAND, TSC, performance counters) provides defense-in-depth for random number generation in security applications

**Important related topics:** AES-NI instructions for hardware-accelerated encryption, PCLMULQDQ for carry-less multiplication in cryptography, AVX-512 vector SHA-512 implementations, Intel SGX integration with hardware RNG, Spectre/Meltdown mitigations using speculation barriers, Constant-time modular arithmetic for RSA and ECC implementations.

---

# Advanced Topics

## Speculative Execution

Speculative execution is a performance optimization technique where the processor executes instructions before it knows whether they are actually needed. The CPU predicts which path a program will take and begins executing instructions along that path before the branch condition is resolved.

### How Speculative Execution Works

When the processor encounters a conditional branch, it doesn't wait for the condition to be evaluated. Instead, it predicts the outcome and speculatively executes instructions along the predicted path. If the prediction is correct, the results are committed to architectural state and performance improves significantly. If the prediction is wrong, the processor discards all speculatively executed work and restarts from the correct path.

The process involves several stages. First, the branch predictor makes a prediction based on historical branch behavior. The processor then fetches and executes instructions from the predicted path while the actual branch condition is being computed. During speculative execution, results are held in temporary buffers rather than being immediately committed to registers or memory. When the branch resolves, if the prediction was correct, results are committed; otherwise, the speculative state is rolled back.

### Reorder Buffer and Speculation

The Reorder Buffer (ROB) is central to managing speculative execution. It stores the results of speculatively executed instructions in program order. Instructions enter the ROB after they are decoded and leave (retire) in program order once they complete without exceptions and all previous instructions have retired. This maintains the illusion of sequential execution while allowing out-of-order execution internally.

### Security Implications

Speculative execution has become a major security concern due to vulnerabilities like Spectre and Meltdown. These attacks exploit the side effects of speculative execution, particularly how speculation can leave traces in cache state that reveal secret information.

**Spectre** exploits branch misprediction to trick the processor into speculatively executing code that accesses unauthorized memory. Even though the speculative execution is eventually rolled back, the data brought into cache during speculation can be detected through timing attacks.

**Meltdown** exploits out-of-order execution to read kernel memory from user space. The processor speculatively executes a memory access that would normally cause an exception, and before the exception is handled, the data affects cache state in detectable ways.

Mitigations for these vulnerabilities include: retpoline (return trampoline) to prevent indirect branch speculation, IBRS (Indirect Branch Restricted Speculation) hardware controls, STIBP (Single Thread Indirect Branch Predictors) to isolate branch prediction between threads, and KPTI (Kernel Page Table Isolation) to separate kernel and user page tables.

## Branch Prediction Internals

Branch prediction is critical for maintaining high performance in modern processors. Without it, the pipeline would stall at every branch waiting for the condition to resolve. Modern x86 processors achieve prediction accuracies exceeding 95% for typical workloads.

### Types of Branch Predictors

**Static Prediction** uses simple heuristics without historical information. Backward branches (typical in loops) are predicted as taken, forward branches are predicted as not taken. This is rarely used in modern processors except as a fallback.

**Dynamic Prediction** uses runtime history to predict branches. This includes several sophisticated mechanisms:

**Bimodal Predictor (Two-Level Adaptive)** uses a table indexed by branch address, with each entry containing a 2-bit saturating counter. The counter states represent strongly not taken (00), weakly not taken (01), weakly taken (10), and strongly taken (11). The counter increments on taken branches and decrements on not-taken branches, providing hysteresis that prevents a single atypical branch from changing the prediction.

**Global History Predictor** maintains a shift register of recent branch outcomes (taken/not taken pattern). This global history is combined with the branch address to index into a prediction table. This captures correlations between different branches, such as when one branch's outcome influences another.

**gshare Predictor** XORs the global history with the branch address before indexing the prediction table. This provides better distribution and avoids aliasing problems while still capturing global correlation patterns.

**Tournament Predictors** combine multiple prediction mechanisms using a meta-predictor that learns which predictor is more accurate for each branch. Intel processors use variations of this approach, maintaining both local and global predictors and selecting between them.

**TAGE Predictor (TAgged GEometric)** is used in modern processors like AMD Zen architectures. It uses multiple prediction tables with different history lengths (geometric progression) and tags to identify branches. Longer history tables capture complex patterns while shorter ones provide quick adaptation.

### Branch Target Buffer (BTB)

The BTB is a cache that stores the target addresses of recently executed branches. It is indexed by the branch instruction address and contains:

- The target address of the branch
- Branch type information (conditional, unconditional, call, return)
- Prediction metadata

When a branch instruction is fetched, the BTB is consulted immediately to provide the predicted target address before the instruction is even decoded. This allows the processor to begin fetching from the predicted target without pipeline stalls.

The BTB has limited capacity (thousands of entries in modern processors) and uses replacement policies similar to cache memory. Critical branches can be evicted, causing BTB misses that result in prediction bubbles in the pipeline.

### Return Stack Buffer (RSB)

The RSB is a specialized predictor for function return instructions. It operates as a small hardware stack (typically 16-32 entries) that pushes return addresses when CALL instructions execute and pops them when RET instructions execute.

Returns are challenging for general branch predictors because the same RET instruction returns to different locations depending on the call site. The RSB solves this by maintaining the actual call stack structure, achieving near-perfect prediction for typical function call patterns.

RSB underflow occurs when returns exceed pushes (due to limited capacity or non-standard code patterns). Modern processors fall back to BTB prediction when RSB underflows, though with reduced accuracy.

### Loop Stream Detector

Some processors include dedicated hardware to detect small loops. Once a loop is detected and its iteration count is predictable, the processor can stream instructions directly without continuous branch prediction or instruction fetch, significantly improving efficiency for tight loops.

## Instruction Fusion

Instruction fusion is an optimization where multiple x86 instructions are combined into a single micro-operation during decode, reducing pressure on execution resources and improving throughput.

### Macro-Fusion

Macro-fusion combines two adjacent instructions into a single μop that occupies one slot in the reorder buffer and execution pipeline. This occurs during the decode stage.

**Common Macro-Fusion Patterns:**

**CMP/TEST followed by conditional jump:**

```nasm
cmp rax, rbx
je  target
```

These fuse into a single compare-and-branch μop. This is the most common fusion pattern and is supported across all modern x86 processors. The fusion works with various comparison instructions (CMP, TEST, ADD, SUB, AND, INC, DEC) followed by conditional jumps.

**Requirements for macro-fusion:**

- Instructions must be adjacent in the instruction stream
- The first instruction must set flags that the second instruction consumes
- The branch must be a conditional jump (not unconditional)
- Instructions must be properly aligned in some architectures

**Benefits:**

- Reduced front-end bandwidth consumption (fused pair counts as one instruction)
- Reduced pressure on the reorder buffer
- Improved branch prediction efficiency
- Lower latency for the combined operation

**Intel Architecture Evolution:**

Early Intel Core processors (Core 2) supported limited macro-fusion. Sandy Bridge and later architectures expanded support to include more instruction combinations and relaxed alignment requirements. Modern processors can fuse in both 64-bit and 32-bit modes.

**AMD Architecture:**

AMD Zen architectures support macro-fusion with some differences from Intel. Certain combinations that fuse on Intel may not fuse on AMD and vice versa, requiring architecture-specific optimization for maximum performance.

### Micro-Fusion

Micro-fusion combines the two micro-operations that typically result from a memory operation (address generation + memory access) into a single μop at the decode stage.

**Example:**

```nasm
add rax, [rbx + rcx*4 + 8]
```

Without micro-fusion, this would generate:

- One μop to calculate the address: rbx + rcx*4 + 8
- One μop to load the value from memory
- One μop to add the loaded value to rax

With micro-fusion, the address calculation and load are combined into a single load μop, so only two μops are dispatched:

- One fused load μop (address + load)
- One ALU μop for the addition

**Micro-fusion limitations:**

**[Inference]** Not all addressing modes can be micro-fused. Complex addressing modes or certain instruction combinations may prevent fusion. Indexed addressing with scale factors of 2, 4, or 8 generally fuse well, but this varies by architecture.

Stores typically cannot fully micro-fuse because they require separate handling of store data and store address in the memory subsystem. Some architectures maintain stores as two μops throughout execution.

**Benefits:**

- Reduced execution bandwidth
- More efficient use of execution ports
- Improved instruction-level parallelism
- Lower latency for memory operations

### Stack Operation Fusion

[Inference] Some processors can fuse stack-relative operations like PUSH/POP with their corresponding memory operations, though this varies significantly by microarchitecture and may not apply to all implementations.

## Micro-Operation (μop) Concepts

The x86 instruction set presents a complex CISC interface to programmers, but modern processors implement it using a RISC-like core that executes simpler micro-operations.

### CISC to RISC Translation

When x86 instructions are decoded, they are translated into one or more μops. Simple instructions like `add rax, rbx` decode to a single μop. Complex instructions may decode to many μops.

**Single-μop instructions:**

- Register-to-register ALU operations: ADD, SUB, XOR, OR, AND
- Simple moves: MOV between registers
- Shifts and rotates with immediate counts
- Simple comparisons and tests

**Multi-μop instructions:**

- Memory operations (typically 2-3 μops: address calculation, load/store, operation)
- String instructions (REP MOVS, REP STOS): many μops or microcode
- Complex instructions (CPUID, XSAVE): microcode sequences

**Example breakdown:**

```nasm
add [rax + rbx*4], rcx
```

Generates approximately:

1. Calculate address: rax + rbx*4
2. Load value from memory at that address
3. Add rcx to the loaded value
4. Store result back to memory

This is 3-4 μops depending on microarchitecture and fusion capabilities.

### Microcode ROM

Some very complex instructions cannot be efficiently represented as a small number of μops. These instructions are implemented using microcode sequences stored in a ROM on the processor.

**Microcode-heavy instructions:**

- CPUID (processor identification)
- String operations with REP prefix
- XSAVE/XRSTOR (extended state save/restore)
- Some floating-point transcendental functions
- Privilege level changes and system management operations

When a microcoded instruction is encountered, the decode logic transfers control to the microcode sequencer, which emits a sequence of μops from the microcode ROM. This process is slower than direct decode but allows implementation of complex semantics without dedicated hardware.

**Microcode updates** can be loaded by the operating system at boot time to fix processor bugs or security vulnerabilities. These updates reside in CPU cache and override the ROM microcode when necessary.

### μop Cache (Decoded Stream Buffer - DSB)

To avoid repeatedly decoding the same instructions, modern processors cache decoded μops in a structure called the μop cache or DSB.

**Structure and Operation:**

The μop cache stores decoded μops indexed by instruction pointer. When the processor needs to fetch instructions, it first checks the μop cache. If the decoded form is present (a hit), it bypasses the instruction decode logic entirely and feeds μops directly to the execution pipeline.

**Intel μop Cache:**

- Typically holds 1500-2500 μops (varies by microarchitecture)
- Organized in sets of 32-byte aligned instruction chunks
- Each set contains up to 6 μops per entry
- 8-way associative structure

**Benefits:**

- Eliminates decode latency for cached code
- Higher effective instruction throughput (up to 5-6 μops per cycle from cache vs. 4-5 from decoders)
- Power savings by leaving complex decode logic inactive
- Compensates for x86 variable-length instruction complexity

**Cache misses** occur when executing new code or when hot code exceeds cache capacity. The processor falls back to conventional instruction fetch and decode, causing temporary throughput reduction.

### Out-of-Order Execution and μops

After decode, μops enter the out-of-order execution engine. The processor maintains the illusion of sequential execution while executing μops in an order determined by data dependencies and resource availability.

**Reservation Station** holds μops waiting for their source operands to become available. When all sources are ready, the μop becomes eligible for execution and is dispatched to an appropriate execution unit.

**Register Renaming** eliminates false dependencies (WAW and WAR hazards) by mapping architectural registers (RAX, RBX, etc.) to a larger pool of physical registers. This allows μops that write to the same architectural register to execute in parallel as long as they write to different physical registers.

**Execution Ports** are the pathways to different execution units. Modern Intel processors have 8-10 execution ports, each capable of executing certain types of μops:

- Port 0: ALU, integer multiply, divide, branch
- Port 1: ALU, integer multiply, FP operations
- Port 2: Load address generation
- Port 3: Load address generation
- Port 4: Store data
- Port 5: ALU, vector operations
- Port 6: ALU, branch
- Port 7: Store address generation

[Inference] Port assignments vary significantly between microarchitectures (Skylake, Ice Lake, Zen, etc.), and optimal performance requires understanding which operations can execute on which ports for the target processor.

**Scheduler** tracks μop dependencies and dispatches ready μops to available execution ports. It can dispatch multiple μops per cycle (4-6 on modern processors) as long as port availability and dependencies allow.

### μop Retirement

Even though μops execute out-of-order, they must retire (commit their results to architectural state) in program order to maintain correct semantics. The Reorder Buffer enforces this ordering.

When a μop completes execution, its result is marked as ready but not immediately visible to the architectural state. Only when the μop reaches the head of the ROB and all previous μops have retired does it commit. This ensures that exceptions, interrupts, and mispredicted branches are handled correctly without exposing speculative state.

**Retirement bandwidth** limits how many μops can retire per cycle (typically 3-4 on Intel, 4-6 on AMD Zen). This can become a bottleneck for code with many simple instructions that execute quickly but must retire in order.

**Key Points:**

- Speculative execution allows processors to execute instructions before knowing if they're needed, with predictions exceeding 95% accuracy but introducing security vulnerabilities like Spectre and Meltdown
- Branch prediction uses sophisticated multi-level mechanisms including bimodal predictors, global history, tournament predictors, and specialized structures like BTB and RSB
- Instruction fusion (macro-fusion and micro-fusion) combines multiple operations into single μops, reducing pipeline pressure and improving throughput
- Modern x86 processors translate CISC instructions into RISC-like μops, using decode caching (DSB), register renaming, and out-of-order execution while maintaining in-order retirement
- Understanding μop generation, port assignment, and execution constraints is essential for writing high-performance x86 code, though specifics vary significantly between processor generations

---

## Instruction Decoding

Instruction decoding is the process by which the processor translates variable-length x86-64 instruction bytes into internal micro-operations (μops) that the execution units can process. This is one of the most complex aspects of x86-64 processor design due to the variable-length, variable-format instruction encoding inherited from the architecture's long evolution.

### x86-64 Instruction Format

x86-64 instructions consist of multiple optional components in a specific order, making instruction length variable from 1 to 15 bytes.

**Instruction format structure:**

```
[Prefixes] [REX] [Opcode] [ModR/M] [SIB] [Displacement] [Immediate]

Prefixes (0-4 bytes):
    - Legacy prefixes (66h, F2h, F3h, etc.)
    - Address size override (67h)
    - Segment override (26h, 2Eh, 36h, 3Eh, 64h, 65h)
    - Lock prefix (F0h)
    - REP/REPNE prefixes (F2h, F3h)

REX prefix (0-1 byte):
    - Format: 0100WRXB (40h-4Fh)
    - Only in 64-bit mode
    - Must immediately precede opcode

Opcode (1-3 bytes):
    - Primary opcode byte
    - Optional escape bytes (0Fh, 0F38h, 0F3Ah)
    - VEX/EVEX prefixes for AVX instructions

ModR/M byte (0-1 byte):
    - Format: MMRRRSSS
    - Specifies addressing mode and operands

SIB byte (0-1 byte):
    - Format: SSIIIBBB
    - Specifies scaled index addressing

Displacement (0, 1, 2, 4, or 8 bytes):
    - Memory operand offset

Immediate (0, 1, 2, 4, or 8 bytes):
    - Constant operand value
```

**Example instruction breakdown:**

```asm
; Instruction: ADD QWORD PTR [RBX + RCX*4 + 0x100], 42
; Bytes: 48 83 84 8B 00 01 00 00 2A

48          ; REX.W prefix (64-bit operand)
83          ; ADD r/m, imm8 opcode
84          ; ModR/M: mod=10 (disp32), reg=000, r/m=100 (SIB follows)
8B          ; SIB: scale=10 (4x), index=001 (RCX), base=011 (RBX)
00 01 00 00 ; Displacement: 0x100 (little-endian)
2A          ; Immediate: 42
```

### Instruction Length Calculation

[Inference] The decoder must determine instruction length before it can proceed to decode the next instruction. This requires parsing the instruction format sequentially:

1. Scan and count legacy prefix bytes (up to 4)
2. Check for REX prefix (40h-4Fh range)
3. Identify opcode length (1-3 bytes based on escape sequences)
4. Determine if ModR/M byte is present (opcode-dependent)
5. Determine if SIB byte is present (ModR/M-dependent)
6. Calculate displacement length (ModR/M-dependent: 0, 1, 4, or 8 bytes)
7. Calculate immediate length (opcode-dependent: 0, 1, 2, 4, or 8 bytes)

**Example length calculation algorithm:**

```c
int decode_instruction_length(uint8_t* instr) {
    int pos = 0;
    bool has_rex = false;
    
    // Skip legacy prefixes
    while (is_legacy_prefix(instr[pos]) && pos < 4) {
        pos++;
    }
    
    // Check for REX prefix
    if ((instr[pos] & 0xF0) == 0x40) {
        has_rex = true;
        pos++;
    }
    
    // Check for VEX/EVEX (multi-byte prefix)
    if (instr[pos] == 0xC4 || instr[pos] == 0xC5) {
        return decode_vex_instruction_length(instr);
    }
    if (instr[pos] == 0x62) {
        return decode_evex_instruction_length(instr);
    }
    
    // Parse opcode
    int opcode_bytes = 1;
    if (instr[pos] == 0x0F) {
        opcode_bytes = 2;
        if (instr[pos+1] == 0x38 || instr[pos+1] == 0x3A) {
            opcode_bytes = 3;
        }
    }
    
    uint8_t opcode = instr[pos + opcode_bytes - 1];
    pos += opcode_bytes;
    
    // Check if ModR/M byte is required
    if (requires_modrm(opcode)) {
        uint8_t modrm = instr[pos++];
        int mod = (modrm >> 6) & 3;
        int rm = modrm & 7;
        
        // Check for SIB byte
        if (mod != 3 && rm == 4) {
            pos++;  // SIB byte
        }
        
        // Determine displacement size
        if (mod == 1) {
            pos += 1;  // disp8
        } else if (mod == 2 || (mod == 0 && rm == 5)) {
            pos += 4;  // disp32
        }
    }
    
    // Add immediate size
    pos += get_immediate_size(opcode);
    
    return pos;
}
```

### Decode Pipeline Stages

Modern processors use multi-stage pipelines for instruction decoding to achieve high throughput despite the complexity of x86-64 instruction format.

**Typical decode pipeline stages:**

**Instruction Fetch (IF):** Fetches 16-32 bytes of instruction stream from L1 instruction cache per cycle. The fetch unit must predict where to fetch from, handling branches and maintaining multiple fetch streams for speculative execution.

**Pre-decode (PD):** Identifies instruction boundaries within the fetched byte stream. This stage marks the start and end of each instruction, enabling parallel decode of multiple instructions. Pre-decode information is often cached alongside instruction bytes.

**Instruction Queue (IQ):** Buffers complete instructions between fetch and decode stages, smoothing out variations in fetch and decode rates.

**Decode (ID):** Translates x86-64 instructions into internal micro-operations. Simple instructions decode into 1-4 μops, while complex instructions may require microcode ROM assistance.

**Example decode bandwidth (modern processors):**

```
Intel processors (since Sandy Bridge):
    - 4-5 instructions decoded per cycle
    - Simple path: 1-4 μops per instruction (4 decoders)
    - Complex path: >4 μops per instruction (microcode ROM)

AMD processors (Zen architecture):
    - 4 instructions decoded per cycle
    - Op cache bypasses decode for hot code
    - Microcode for complex instructions
```

### Micro-Operations (μops)

The x86-64 instruction set is translated into simpler RISC-like micro-operations that the execution engine can process efficiently.

**Common μop patterns:**

```asm
; Simple instruction: 1 μop
ADD RAX, RBX
    → μop: ADD RAX, RBX

; Memory load + ALU: 2 μops
ADD RAX, [RBX]
    → μop1: LOAD temp, [RBX]
    → μop2: ADD RAX, temp

; Memory store: 2 μops (address generation + store data)
MOV [RAX], RBX
    → μop1: STA (store address) RAX
    → μop2: STD (store data) RBX

; Complex instruction: Multiple μops
PUSH RAX
    → μop1: SUB RSP, 8
    → μop2: STORE [RSP], RAX

; Read-modify-write memory: 4 μops
ADD [RAX], RBX
    → μop1: LOAD temp, [RAX]
    → μop2: ADD temp, RBX
    → μop3: STA (store address) RAX
    → μop4: STD (store data) temp
```

[Inference] The μop count affects instruction throughput since the processor can issue and execute a limited number of μops per cycle. Instructions with fewer μops generally have higher throughput.

### Instruction Fusion

Modern processors can fuse certain instruction pairs into single μops to improve throughput and reduce pressure on execution resources.

**Macro-fusion:** Combines compare/test instruction with a following conditional branch into a single μop.

```asm
; Without fusion: 2 μops
CMP RAX, RBX
JE target

; With macro-fusion: 1 fused μop
CMP-and-branch-if-equal RAX, RBX, target

; Common fusible patterns:
CMP/TEST + Jcc
ADD/SUB/AND/OR + Jcc (with flag result)
INC/DEC + Jcc
```

**Micro-fusion:** Combines memory operand address calculation with the memory operation itself.

```asm
; Without fusion: 2 μops
ADD RAX, [RBX + RCX*8 + 0x100]
    → Calculate address
    → Load and add

; With micro-fusion: 1 μop
ADD RAX, [RBX + RCX*8 + 0x100]
    → Fused address-generation-and-load-and-add
```

**Conditions for fusion:**

```
Macro-fusion requirements:
    - Specific compare/test + conditional branch sequences
    - Instructions must be adjacent in instruction stream
    - No prefix bytes that prevent fusion
    - Branch target must be predictable

Micro-fusion requirements:
    - Simple addressing modes (specific to microarchitecture)
    - Memory operand meets alignment requirements
    - No bank conflicts or other microarchitectural restrictions
```

### Decoder Complexity

The x86-64 instruction set's variable-length encoding creates several challenges for high-performance decoding.

**Instruction boundary detection:** Variable length means the start of instruction N+1 depends on the length of instruction N, creating sequential dependencies. Pre-decode stages and length prediction help parallelize this process.

**Multiple instruction formats:** The same opcode byte can mean different things depending on prefixes, requiring complex decoder logic. Modern processors use multiple parallel decoders, each optimized for common instruction patterns.

**Prefix handling:** Up to 4 legacy prefixes plus REX can precede an instruction, and some prefixes change instruction meaning while others are ignored. The decoder must track prefix state across multiple bytes.

### Decode Cache and μop Cache

To avoid repeatedly decoding the same instructions, modern processors cache decoded μops.

**Decoded Stream Buffer (DSB) / μop Cache:**

```
Organization:
    - Stores μops for frequently executed code
    - Indexed by instruction pointer
    - Tagged with code alignment and branch targets
    - Capacity: 1500-6000 μops (varies by processor)

Benefits:
    - Bypasses instruction fetch and decode stages
    - Higher sustained μop delivery rate (6-8 μops/cycle vs 4-5)
    - Reduced power consumption
    - Better performance for small loops and hot code

Operation:
    - On μop cache hit: Deliver μops directly to rename stage
    - On μop cache miss: Fall back to legacy decode pipeline
    - Cache built on-demand as code executes
```

**Example μop cache behavior:**

```asm
; Small loop - likely to fit in μop cache
.loop:
    mov rax, [rsi]
    add rax, [rdi]
    mov [rdx], rax
    add rsi, 8
    add rdi, 8
    add rdx, 8
    dec rcx
    jnz .loop

; After first iteration, entire loop may execute from μop cache
; Achieving higher throughput than decode pipeline alone
```

### Length-Changing Prefixes (LCP)

Certain prefix combinations create Length-Changing Prefix (LCP) stalls where the pre-decoder cannot accurately predict instruction length, forcing slower sequential decode.

**LCP-causing scenarios:**

```asm
; 66h prefix changing operand size
66 48 89 C3         ; XCHG BX, BX (66h + REX.W creates LCP)

; Redundant prefixes
F3 F2 A4            ; Multiple REP prefixes

; Misaligned 16-byte boundaries with specific patterns
; (microarchitecture-dependent)
```

[Inference] LCP stalls typically cost 2-3 extra cycles for decode. Compilers and assemblers should avoid generating instructions with LCP-causing prefix combinations.

### Microcode ROM

Complex instructions that cannot be efficiently expressed as a small number of μops use microcode sequences stored in on-chip ROM.

**Microcode-requiring instructions:**

```asm
; String operations
REP MOVSB/MOVSW/MOVSD/MOVSQ
REP STOSB/STOSW/STOSD/STOSQ

; Privilege-level changes
IRET
SYSENTER/SYSEXIT
SYSCALL/SYSRET

; Complex arithmetic
IDIV (division)
IMUL with three operands and memory source

; System management
CPUID (with some leaf values)
WRMSR
XSAVE/XRSTOR with large state

; Legacy string operations
CMPS, SCAS, LODS with REP prefix

; Floating-point transcendentals (x87)
FSIN, FCOS, FSINCOS
```

**Microcode characteristics:**

```
Invocation:
    - Triggered by specific opcode patterns
    - Decoder signals microcode sequencer
    - Microcode ROM address calculated from opcode

Execution:
    - Microcode sequencer issues μops from ROM
    - Typically 10-100+ μops for complex operations
    - Executed sequentially (not out-of-order within microcode)

Performance impact:
    - Much slower than simple instruction decode (10-100+ cycles)
    - Blocks decode pipeline while active
    - May flush or stall various pipeline stages

Optimization:
    - Avoid microcode instructions in hot paths when possible
    - Use equivalent sequences of simple instructions if faster
    - Modern processors optimize common microcode sequences
```

### Decoding AVX/AVX-512 Instructions

AVX instructions use VEX (Vector Extensions) or EVEX (Enhanced VEX) prefixes that replace legacy prefixes and REX, providing a more efficient encoding.

**VEX prefix format (2 or 3 bytes):**

```
2-byte VEX (C5h):
    Byte 0: C5h
    Byte 1: R vvvv L pp
        R: REX.R inverted
        vvvv: Additional operand register (inverted)
        L: Vector length (0=128-bit, 1=256-bit)
        pp: Implied prefix (0=none, 1=66h, 2=F3h, 3=F2h)

3-byte VEX (C4h):
    Byte 0: C4h
    Byte 1: R X B m-mmmm
        RXB: REX.R, REX.X, REX.B (inverted)
        m-mmmm: Opcode map select
    Byte 2: W vvvv L pp
        W: REX.W (operand size)
        vvvv: Additional operand (inverted)
        L: Vector length
        pp: Implied prefix
```

**EVEX prefix format (4 bytes):**

```
Byte 0: 62h
Byte 1: R X B R' 0 0 m m
Byte 2: W v v v v 1 p p
Byte 3: z L' L b V' a a a

Extended features:
    - Up to 32 registers (K0-K7 mask, ZMM0-ZMM31 vector)
    - Embedded rounding control
    - Suppress all exceptions (SAE)
    - Broadcasting (replicating scalar across vector)
    - Masking (predicated operations)
```

**VEX/EVEX decoding advantages:**

```
Efficiency:
    - No legacy prefix scanning required
    - Instruction length more predictable
    - Compact encoding of additional operands

Performance:
    - Faster decode than legacy prefix scheme
    - Better decode throughput for vectorized code
    - Reduced instruction cache footprint
```

### Branch Target Buffer and Decode

The Branch Target Buffer (BTB) predicts branch targets before instructions are fully decoded, enabling speculative fetch and decode of the correct path.

**BTB-decoder interaction:**

```
1. Fetch stage consults BTB with instruction pointer
2. BTB predicts: taken/not-taken, target address
3. Fetch continues from predicted path
4. Pre-decode identifies actual branch instruction
5. Decode confirms or corrects BTB prediction
6. On misprediction: flush pipeline, restart from correct target
```

[Inference] The BTB must predict before decode completes because decode latency (2-4 cycles) would create pipeline bubbles. Early prediction enables continuous fetch and decode of the predicted path.

## Out-of-Order Execution

Out-of-order (OoO) execution allows the processor to execute instructions in a different sequence than the program order, exploiting instruction-level parallelism (ILP) to improve performance by keeping execution units busy and hiding memory latency.

### Fundamental Concepts

**Program order:** The sequence in which instructions appear in the compiled code represents the intended execution order that preserves correct program semantics.

**Data dependencies:** An instruction depends on another if it consumes a value produced by the earlier instruction. These dependencies constrain reordering.

```asm
; True dependency (Read After Write - RAW)
ADD RAX, RBX        ; Produces RAX
SUB RCX, RAX        ; Consumes RAX - must wait

; Anti-dependency (Write After Read - WAR)
ADD RDX, RAX        ; Consumes RAX
MOV RAX, 10         ; Produces RAX - could execute earlier with renaming

; Output dependency (Write After Write - WAW)
MOV RAX, 5          ; Produces RAX
MOV RAX, 10         ; Produces RAX - second write must appear after first
```

**Out-of-order execution principle:** Instructions execute as soon as their operands are available and execution resources are free, regardless of program order, while maintaining the illusion of sequential execution through careful management of dependencies and state updates.

### OoO Execution Pipeline Stages

Modern out-of-order processors use a complex pipeline with distinct phases for instruction processing.

**Frontend (In-order):**

```
Fetch → Decode → Rename → Allocate → Dispatch
```

**Backend (Out-of-order):**

```
Schedule → Execute → Writeback
```

**Retirement (In-order):**

```
Commit → Complete
```

### Register Renaming

Register renaming eliminates false dependencies (WAR and WAW) by mapping architectural registers (RAX, RBX, etc.) to a larger pool of physical registers, allowing instructions to execute in parallel despite apparent register conflicts.

**Architectural vs physical registers:**

```
Architectural registers (visible to programmer):
    - x86-64: 16 general-purpose (RAX-R15)
    - 16 vector registers (XMM0-XMM15 / YMM0-YMM15 / ZMM0-ZMM31)
    - Flags register (RFLAGS)

Physical registers (internal to processor):
    - Modern processors: 150-300+ physical registers
    - Dynamically allocated to architectural registers
    - Allows multiple versions of same architectural register
```

**Register renaming example:**

```asm
; Original code with false dependencies
MOV RAX, [RSI]      ; RAX = physical reg P10
ADD RAX, 5          ; P10 = P10 + 5 (depends on previous)
MOV RBX, RAX        ; RBX = P10

MOV RAX, [RDI]      ; RAX = physical reg P20 (WAW false dependency removed)
SUB RAX, 3          ; P20 = P20 - 3 (depends on its own load)
MOV RCX, RAX        ; RCX = P20

; After renaming, two instruction streams are independent
; Can execute in parallel despite using same architectural register RAX
```

**Rename table structure:**

```c
typedef struct {
    int physical_reg;       // Current physical register mapping
    bool ready;             // Is value available?
    uint64_t value;         // Actual value (if ready)
} RegisterMapping;

typedef struct {
    RegisterMapping arch_regs[16];  // RAX-R15 mappings
    int free_physical_regs[256];    // Pool of available physical registers
    int free_list_head;
} RenameTable;
```

**Rename process:**

```
For each instruction:
1. Read operands:
    - Look up source architectural registers in rename table
    - Get physical register numbers and ready status
    
2. Allocate destination:
    - Allocate new physical register from free pool
    - Update rename table: architectural dest → new physical reg
    - Save old physical register mapping for later freeing
    
3. Issue instruction:
    - Instruction now references physical registers
    - Can execute when all source physical registers ready
```

**Example rename operation:**

```asm
; Instruction: ADD RAX, RBX
; Before: RAX→P15, RBX→P20
; After:  RAX→P50, RBX→P20

Rename process:
1. Read sources: P15 (old RAX), P20 (RBX)
2. Allocate destination: P50 (new RAX)
3. Issue: ADD P50, P15, P20
4. Free P15 when all instructions using it complete
```

### Reorder Buffer (ROB)

The Reorder Buffer tracks all in-flight instructions in program order, enabling precise exceptions and in-order retirement despite out-of-order execution.

**ROB structure:**

```c
typedef struct {
    uint64_t instruction_pointer;
    uint8_t opcode;
    int arch_dest_reg;          // Architectural destination register
    int old_physical_reg;       // Previous mapping (for rollback)
    int new_physical_reg;       // New physical register assigned
    bool completed;             // Has execution finished?
    bool exception;             // Did instruction raise exception?
    uint64_t exception_info;    // Exception details
    uint64_t result;            // Execution result value
} ROBEntry;

typedef struct {
    ROBEntry entries[256];      // Circular buffer
    int head;                   // Oldest instruction (retirement point)
    int tail;                   // Newest instruction (allocation point)
    int count;                  // Number of in-flight instructions
} ReorderBuffer;
```

**ROB operations:**

**Allocation:** When instruction is renamed and dispatched, allocate ROB entry at tail. Store instruction information and register mappings.

**Completion:** When instruction finishes execution, mark ROB entry as completed and store result. Entry remains in ROB but is ready to retire.

**Retirement (commit):** In-order from ROB head, commit completed instructions to architectural state. Update architectural registers, memory, and free old physical registers.

**Exception handling:** If instruction at ROB head has exception, flush all younger instructions (later in program order), restore architectural state, and handle exception.

**Example ROB timeline:**

```
Cycle 1: Allocate instruction at tail (entry 10)
Cycle 2: Instruction dispatched to execution unit
Cycle 5: Instruction completes execution (mark entry 10 complete)
Cycle 8: ROB head reaches entry 10, instruction retires
```

### Reservation Stations and Issue Queues

Reservation stations hold instructions waiting for operands to become available, then issue them to execution units when ready.

**Reservation station structure:**

```c
typedef struct {
    uint8_t opcode;
    int dest_physical_reg;
    
    // Source operand 1
    bool src1_ready;
    int src1_physical_reg;
    uint64_t src1_value;
    
    // Source operand 2
    bool src2_ready;
    int src2_physical_reg;
    uint64_t src2_value;
    
    int rob_entry;              // Associated ROB entry
    bool issued;                // Has issued to execution unit?
} ReservationStation;
```

**Dispatch and wake-up process:**

```
Dispatch (after rename):
1. Allocate reservation station
2. For each source operand:
    - If physical register ready: copy value
    - If not ready: record physical register number to monitor
3. Place in issue queue for appropriate execution port

Wake-up (when results broadcast):
1. Execution unit broadcasts: "Physical reg P50 = value"
2. All reservation stations check:
    - If waiting for P50 as source, mark ready and capture value
3. Instructions with all sources ready become eligible for issue

Issue (select and execute):
1. Scheduler selects ready instruction(s) from queue
2. Selected instruction(s) issue to available execution unit(s)
3. Execution unit processes instruction
4. Result broadcasts on completion, waking dependent instructions
```

**Example wakeup cascade:**

```asm
; Initial state: All instructions in reservation stations

ADD P10, P5, P6         ; Ready (P5, P6 available)
MUL P11, P10, P7        ; Not ready (waiting for P10)
SUB P12, P11, P8        ; Not ready (waiting for P11)

Cycle 1: ADD issues and executes
Cycle 4: ADD completes, broadcasts P10=value
         MUL wakes up (now ready)
Cycle 5: MUL issues and executes
Cycle 8: MUL completes, broadcasts P11=value
         SUB wakes up (now ready)
Cycle 9: SUB issues and executes
```

### Execution Units and Ports

Modern processors have multiple execution units connected to issue ports, enabling parallel execution of different instruction types.

**Example port configuration (Intel Skylake-based):**

```
Port 0: Integer ALU, Vector ALU, Vector Multiply, Branch
Port 1: Integer ALU, Vector ALU, Vector Multiply, Bit manipulation
Port 2: Load AGU (Address Generation Unit)
Port 3: Load AGU
Port 4: Store Data
Port 5: Integer ALU, Vector ALU, Vector Shuffle, Branch
Port 6: Integer ALU, Branch
Port 7: Store AGU

Bandwidth:
    - 4 μops issued per cycle (to 4 different ports)
    - Execution width: Up to 8 operations completing per cycle
    - Memory: 2 loads + 1 store per cycle
```

**Port assignment examples:**

```asm
; These can execute in parallel (different ports)
ADD RAX, RBX            ; Port 0, 1, 5, or 6
MOV RCX, [RDI]          ; Port 2 or 3 (load)
IMUL RDX, RSI           ; Port 1
LEA R8, [R9 + R10]      ; Port 1 or 5

; Port contention example
ADD RAX, RBX            ; Port 0, 1, 5, or 6
ADD RCX, RDX            ; Port 0, 1, 5, or 6
ADD RSI, RDI            ; Port 0, 1, 5, or 6
ADD R8, R9              ; Port 0, 1, 5, or 6
IMUL R10, R11           ; Port 1 only - may wait for port availability
```

### Memory Ordering and Load/Store Execution

Memory operations require special handling in out-of-order execution to maintain correct memory ordering semantics while maximizing performance.

**Load/Store Queue structure:**

```c
typedef struct {
    uint64_t virtual_address;
    uint64_t physical_address;
    bool address_valid;
    uint64_t data;
    bool data_valid;
    int size;                   // 1, 2, 4, or 8 bytes
    int rob_entry;
    bool completed;
} LoadStoreQueueEntry;

typedef struct {
    LoadStoreQueueEntry load_queue[64];
    LoadStoreQueueEntry store_queue[64];
    int load_head, load_tail;
    int store_head, store_tail;
} MemoryOrderBuffer;
```

**Load execution:**

```
1. Calculate address (may execute speculatively)
2. Check store queue for forwarding:
    - If older store to same address exists: forward data
    - If older store address unknown: stall (memory ordering)
3. If no forwarding: issue load to cache/memory
4. Receive data and complete
5. Broadcast result to wake dependent instructions
```

**Store execution:**

```
1. Calculate address (can execute early)
2. Hold data in store queue until retirement
3. At retirement:
    - Commit store to L1 data cache
    - Remove from store queue
    - Make visible to other cores via cache coherence
```

**Memory ordering example:**

```asm
; Program order matters for correctness
MOV [RBX], RAX          ; Store to address in RBX
MOV RCX, [RBX]          ; Load from same address

; Execution:
Store: Calculate address, hold in store queue
Load:  Calculate address, check store queue
       Find matching older store → forward data
       Complete without cache access
```

**Memory disambiguation:**

[Inference] The processor must predict whether a load will alias with an older store (access the same memory location). Incorrect predictions cause pipeline flushes and performance loss.

```
Conservative approach:
    - Stall loads until all older store addresses known
    - Safe but slow

Aggressive approach:
    - Allow loads to execute speculatively
    - Check for violations when store addresses calculated
    - Flush and replay on violations
```

### Speculative Execution

Out-of-order processors execute instructions before knowing whether they should execute (speculatively), then either commit results if speculation was correct or discard results if wrong.

**Branch prediction and speculation:**

```asm
; Branch prediction example
CMP RAX, RBX
JE target               ; Branch predictor guesses taken/not-taken

; Speculative path (predicted taken)
target:
    MOV RCX, [RDI]     ; Execute speculatively
    ADD RCX, 10         ; Execute speculatively
    MOV RDX, RCX        ; Execute speculatively

; On prediction confirmation:
    - Retire speculative instructions normally
    
; On misprediction:
    - Flush all speculative instructions from pipeline
    - Restore architectural state to branch point
    - Restart fetch from correct path
```

**Memory speculation:**

```asm
; Load speculation example
MOV RAX, [RSI]          ; Load executes speculatively
ADD RAX, 5              ; Dependent instruction executes
MOV [RDI], RAX          ; Store executes

; Later, if older store to [RSI] completes:
    - Check if load address matched
    - If mismatch: load was correct, continue
    - If match: load got wrong data, flush and replay
```

### Speculative Execution Vulnerabilities

[Inference] Speculative execution can create security vulnerabilities when speculative instructions access data they shouldn't, leaving traces in cache that can be observed through timing side channels.

**Spectre vulnerabilities:** Exploit branch prediction to cause speculative execution of code that leaks secrets through cache side channels.

**Meltdown vulnerability:** Exploits speculative execution of loads that should cause permission faults, leaking kernel data before permission check completes.

**Mitigation techniques:**

```asm
; Serializing instructions prevent speculation
LFENCE                  ; Load fence - blocks speculative loads

; Bounds checking with serialization
CMP RAX, ARRAY_SIZE
JAE out_of_bounds
LFENCE                  ; Prevent speculative access
MOV RBX, [ARRAY + RAX*8]

; Indirect branch barriers
JMP RCX                 ; Indirect branch
; Modern processors: Require retraining of branch predictors
```

### Pipeline Depth and Latency

Out-of-order execution pipelines are deep (15-25+ stages) to achieve high clock frequencies, but this creates long pipeline latencies.

**Typical pipeline stages:**

```
Stages 1-4:   Fetch (instruction cache access, branch prediction)
Stages 5-8:   Decode (instruction decode, μop generation)
Stages 9-12:  Rename/Allocate (register renaming, ROB allocation)
Stages 13-14: Schedule/Dispatch (reservation stations, issue queues)
Stages 15-18: Execute (execution units, multiple cycles for complex ops)
Stages 19-20: Writeback (result broadcast, wakeup dependents)
Stages 21-23: Retire (commit architectural state, free resources)
```

**Pipeline latency consequences:**

```
Branch misprediction penalty:
    - Must flush entire pipeline from misprediction point
    - 15-20 cycle penalty on typical modern processor
    - Can stall execution until correct path fills pipeline

Memory latency hiding:
    - L1 cache hit: ~4-5 cycles
    - L2 cache hit: ~12-15 cycles
    - L3 cache hit: ~40-60 cycles
    - DRAM access: ~200-300 cycles
    - Out-of-order execution can hide latency by executing other work
```

**Example latency hiding:**

```asm
; Memory latencies hidden by executing independent work
MOV RAX, [RSI]          ; L3 cache miss - 50 cycle latency
MOV RBX, [RDI]          ; L3 cache miss - 50 cycle latency

; While loads pending, execute independent work
MOV RCX, 100
.loop:
    ADD RDX, RCX        ; Independent computation
    DEC RCX
    JNZ .loop

; By the time loop completes, loads may have finished
ADD RAX, RBX            ; Dependent on both loads
```

### Performance Monitoring and Analysis

Modern processors provide performance counters to observe out-of-order execution behavior.

**Key performance metrics:**

```
Instructions Per Cycle (IPC):
    - Measures instruction-level parallelism exploitation
    - Ideal: 4-6 IPC on modern processors
    - Actual: Often 1-3 IPC depending on code characteristics

μops Per Cycle:
    - Internal execution rate
    - Backend can execute 4-8 μops/cycle on modern designs
    - Frontend often limits to 4-5 μops/cycle decode

Backend stalls:
    - Execution port contention
    - Memory access latency
    - Data dependencies creating dependency chains

Frontend stalls:
    - Instruction cache misses
    - Branch mispredictions
    - Decode bandwidth limitations
```

**Example performance counter usage:**

```c
// Intel: Use RDPMC or performance monitoring MSRs
// Measuring IPC

uint64_t start_cycles, end_cycles;
uint64_t start_instrs, end_instrs;

// Configure performance counters
write_msr(IA32_PERFEVTSEL0, 0x003C); // CPU_CLK_UNHALTED.THREAD
write_msr(IA32_PERFEVTSEL1, 0x00C0); // INST_RETIRED.ANY

// Start measurement
start_cycles = read_pmc(0);
start_instrs = read_pmc(1);

// Code under test
workload();

// End measurement
end_cycles = read_pmc(0);
end_instrs = read_pmc(1);

// Calculate IPC
double ipc = (double)(end_instrs - start_instrs) / 
             (double)(end_cycles - start_cycles);
```

### Dependency Chains and Critical Paths

The longest dependency chain in code determines minimum execution time regardless of available parallelism.

**Critical path example:**

```asm
; Long dependency chain (critical path)
MOV RAX, [RSI]          ; Load: 5 cycles
ADD RAX, RBX            ; ADD: 1 cycle (depends on load)
IMUL RAX, RCX           ; MUL: 3 cycles (depends on add)
ADD RAX, RDX            ; ADD: 1 cycle (depends on mul)
MOV [RDI], RAX          ; Store: (depends on add)

; Total critical path: 5 + 1 + 3 + 1 = 10 cycles minimum
; No amount of out-of-order execution can reduce this

; Broken dependency chain (more parallelism)
MOV RAX, [RSI]          ; Load: 5 cycles - independent
MOV RBX, [RDI]          ; Load: 5 cycles - independent
MOV RCX, [RDX]          ; Load: 5 cycles - independent

ADD RAX, RBX            ; ADD: 1 cycle (depends on two loads)
ADD RAX, RCX            ; ADD: 1 cycle (depends on previous add)

; Critical path: 5 + 1 + 1 = 7 cycles
; Three loads can execute in parallel
```

**Reducing dependency chains:**

```asm
; Sequential dependency chain
XOR EAX, EAX
ADD EAX, 1
ADD EAX, 2
ADD EAX, 3
ADD EAX, 4
; Chain length: 4 cycles

; Parallel reduction (tree-based)
MOV EAX, 1
MOV EBX, 2
MOV ECX, 3
MOV EDX, 4
ADD EAX, EBX            ; Parallel with next ADD
ADD ECX, EDX
ADD EAX, ECX
; Chain length: 2 cycles (with more parallelism)
```

### Write Combining and Store Buffers

Store buffers hold pending stores and can combine multiple stores to adjacent addresses, improving memory bandwidth utilization.

**Store buffer structure:**

```c
typedef struct {
    uint64_t address;
    uint8_t data[64];           // Cache line size
    uint64_t valid_bytes;       // Bitmask of valid bytes
    bool committed;             // Store retired from ROB?
} StoreBufferEntry;

// Store buffer: 10-40 entries typical
StoreBufferEntry store_buffer[40];
```

**Write combining:**

```asm
; Sequential stores to adjacent addresses
MOV BYTE [RBX], AL          ; Store to address X
MOV BYTE [RBX+1], CL        ; Store to address X+1
MOV BYTE [RBX+2], DL        ; Store to address X+2
MOV BYTE [RBX+3], BL        ; Store to address X+3

; Store buffer combines into single cache line write
; Instead of 4 separate memory transactions:
;   Single cache line write with partial data
; Improves memory bandwidth efficiency
```

**Write combining buffers (WC memory type):**

```
WC buffers for memory-mapped I/O:
    - Specialized buffers for write-combining memory
    - Combine multiple writes before committing to bus
    - Used for framebuffers, PCIe BARs, etc.
    - Can dramatically improve write performance (10-100x)
```

### Superscalar Execution Width

Superscalar width determines how many instructions can execute simultaneously.

**Execution width examples:**

```
Modern Intel (Skylake-based):
    - Decode: 4 instructions/cycle
    - Rename: 4 instructions/cycle
    - Issue: 4 μops/cycle
    - Execute: 8 μops/cycle (various ports)
    - Retire: 4 instructions/cycle

Modern AMD (Zen 3):
    - Decode: 4 instructions/cycle
    - Rename: 6 instructions/cycle
    - Issue: 6 μops/cycle
    - Execute: 10 μops/cycle (various ports)
    - Retire: 8 μops/cycle

Older designs:
    - Pentium Pro (1995): 3-wide
    - Pentium 4 (2000): Effectively 1-3 wide
    - Core 2 (2006): 4-wide
```

**Achieving maximum width:**

```asm
; Example achieving 4-wide execution
ADD RAX, RBX            ; Port 0,1,5,6 - independent
SUB RCX, RDX            ; Port 0,1,5,6 - independent
XOR RSI, RDI            ; Port 0,1,5,6 - independent
AND R8, R9              ; Port 0,1,5,6 - independent

; All four can issue and execute in same cycle
; Each uses different execution port
; No dependencies between instructions
```

## Simultaneous Multithreading (SMT)

Simultaneous Multithreading, commonly known as Hyper-Threading on Intel processors, allows a single physical processor core to execute instructions from multiple software threads concurrently, sharing most execution resources while maintaining separate architectural state.

### SMT Fundamental Concepts

**Hardware thread (logical processor):** Each SMT thread appears as a separate processor to software, with its own architectural state (registers, program counter, etc.) but sharing most execution resources with sibling threads.

**Resource sharing model:**

```
Replicated per thread (separate):
    - Architectural registers (RAX-R15, RIP, RFLAGS)
    - ROB entries (partitioned)
    - Load/store queue entries (partitioned)
    - Rename table
    - Return stack buffer (branch prediction)

Shared between threads:
    - Execution units (ALU, FPU, vector units)
    - Caches (L1, L2, L3)
    - TLB entries (tagged with thread ID)
    - Branch predictor structures
    - Decode and fetch bandwidth
    - Memory ports
```

**SMT motivation:**

```
Single thread limitations:
    - Memory latency creates idle cycles
    - Branch mispredictions create bubbles
    - Limited instruction-level parallelism
    - Execution units often underutilized (30-50% typical)

SMT benefits:
    - Fill idle cycles with instructions from other thread
    - Better execution unit utilization
    - Hide memory latency of one thread with work from another
    - Improved throughput (not single-thread latency)
```

### SMT Architecture Implementation

**Thread selection and scheduling:**

The processor must decide which thread(s) to fetch from and which thread's instructions to issue each cycle.

**Fetch policy:**

```
Round-robin:
    - Alternate fetching between threads each cycle
    - Simple but may not maximize throughput

ICOUNT:
    - Fetch from thread with fewer instructions in pipeline
    - Balances instruction queue depths

Priority-based:
    - Assign priorities to threads
    - Favor higher-priority thread
    - OS can influence via hints
```

**Issue policy:**

```
Oldest-first:
    - Issue oldest ready instruction regardless of thread
    - Maximizes instruction throughput

Per-thread quotas:
    - Limit how many resources each thread can use
    - Prevents one thread from monopolizing resources

Dynamic priority:
    - Adjust based on execution characteristics
    - Favor thread making progress vs. stalled thread
```

**Resource partitioning:**

```c
// Example resource allocation
typedef struct {
    int thread_id;
    
    // Partitioned resources
    int rob_entries_allocated;
    int rob_entries_max;           // e.g., 96 out of 192 total
    
    int load_queue_entries;
    int load_queue_max;            // e.g., 32 out of 64 total
    
    int store_queue_entries;
    int store_queue_max;           // e.g., 20 out of 40 total
    
    // Shared resources (statistical sharing)
    int execution_port_usage[8];   // Usage counters per port
    
} ThreadContext;
```

### Performance Characteristics

**Throughput improvement:**

```
Ideal SMT speedup: 2.0x (with 2 threads)
Actual SMT speedup: 1.2-1.3x typical

Speedup depends on:
    - Resource contention
    - Cache behavior
    - Memory bandwidth
    - Workload characteristics
```

**Single-thread performance impact:**

```
Resource sharing effects:
    - Cache pollution from sibling thread
    - Execution port contention
    - Memory bandwidth sharing
    - ROB entry competition

Typical impact:
    - 0-20% single-thread performance reduction
    - Varies greatly by workload
    - Some workloads unaffected
    - Others significantly impacted
```

**Example workload interactions:**

```asm
; Thread 0: Memory-intensive (frequent cache misses)
.loop0:
    MOV RAX, [RSI]      ; Often misses in cache
    ADD RAX, 10
    MOV [RDI], RAX
    ADD RSI, 64         ; Iterate over large array
    ADD RDI, 64
    DEC RCX
    JNZ .loop0

; Thread 1: Compute-intensive (in-cache)
.loop1:
    MOV RAX, [RBX]      ; Cache hits
    IMUL RAX, RAX
    ADD RAX, RDX
    MOV [RBX], RAX
    ADD RBX, 8          ; Small working set
    DEC R8
    JNZ .loop1

; SMT benefit:
; - While Thread 0 waits on memory, Thread 1 uses execution units
; - Good complementary behavior
; - Total throughput > either thread alone
```

### Cache and TLB Sharing

Caches and TLBs are shared between SMT threads, creating both opportunities and challenges.

**TLB sharing:**

```
TLB entries tagged with thread ID:
    - Each entry records which thread it belongs to
    - TLB lookup checks address and thread ID
    - Effective capacity split between threads
    
Example TLB pressure:
    Thread 0: Working set = 4MB (needs ~512 TLB entries)
    Thread 1: Working set = 4MB (needs ~512 TLB entries)
    Total TLB: 1024 entries
    
    Result:
    - Each thread gets ~512 entries statistically
    - Higher TLB miss rate than single thread
    - Page table walks consume memory bandwidth
```

**Cache sharing:**

```
L1 cache sharing:
    - Shared between threads on same core
    - No partitioning - statistical sharing
    - One thread can evict other thread's data
    - Cache thrashing possible
    
L2/L3 cache sharing:
    - Shared across all cores and threads
    - Larger capacity helps mitigate interference
    - Cache coherence traffic increases with more threads
```

**Example cache interference:**

```asm
; Thread 0 working set: 32KB
; Thread 1 working set: 32KB
; L1 cache size: 32KB

; Both threads access different data
; Frequent cache evictions
; Each thread experiences higher miss rate
; Effective cache size per thread: ~16KB

; Performance impact:
; - Increased memory traffic
; - Higher memory latency
; - Reduced effective cache capacity
```

### Memory Bandwidth Sharing

Memory bandwidth is a critical shared resource in SMT systems.

**Bandwidth contention:**

```
Single thread memory bandwidth: 20 GB/s (example)
Two threads ideal: 40 GB/s
Two threads actual: 25-30 GB/s

Reasons for sub-linear scaling:
    - Memory controller scheduling overhead
    - Bank conflicts
    - Row buffer conflicts
    - Cache coherence traffic
    - Shared memory bus arbitration
```

**Load/store queue contention:**

```c
// Queue capacity split between threads
Total load queue: 64 entries
Thread 0 allocation: 32 entries
Thread 1 allocation: 32 entries

// When thread has many in-flight memory operations:
if (thread0_loads >= 32) {
    // Stall thread 0 dispatch (queue full)
    thread0_stalled = true;
}

// Reduces effective memory-level parallelism per thread
// But allows both threads to make progress
```

### Branch Prediction with SMT

Branch predictors must handle predictions for multiple threads simultaneously.

**Branch predictor organization:**

```
Thread-shared structures:
    - Branch Target Buffer (BTB): Tagged with thread ID
    - Pattern history tables: Separate per thread
    - Return address stack: Separate per thread (critical)

Capacity partitioning:
    - Each thread gets subset of BTB entries
    - Reduced effective predictor size per thread
    - May increase misprediction rate
```

**Return stack contention:**

```asm
; Thread 0 makes function call
CALL function_a
    ; Return address pushed to thread 0's return stack
    ; ...
    RET             ; Predicts return from thread 0's stack

; Thread 1 makes function call  
CALL function_b
    ; Return address pushed to thread 1's return stack
    ; Separate from thread 0
    ; ...
    RET             ; Predicts return from thread 1's stack

; Separate return stacks prevent interference
; Critical for prediction accuracy
```

### SMT and Power Consumption

SMT increases processor utilization, which typically increases power consumption and temperature.

**Power characteristics:**

```
Single thread power: 50W (example)
Two threads SMT: 65-75W (not 100W)

Reasons for sub-linear power increase:
    - Execution units already powered
    - Cache already active
    - Additional power mainly from:
        * Increased switching activity
        * Higher utilization of existing units
        * More memory traffic
```

**Thermal implications:**

```
Higher sustained power:
    - May trigger thermal throttling sooner
    - Reduces clock frequency
    - Can negate SMT performance benefit
    
Thermal management:
    - Dynamic frequency scaling per core
    - May disable SMT under thermal pressure
    - OS can move threads to cooler cores
```

### Operating System SMT Awareness

Operating systems must understand SMT topology to schedule threads effectively.

**Topology detection:**

```c
// CPUID can reveal SMT topology
typedef struct {
    int physical_core_id;
    int logical_processor_id;
    int threads_per_core;
    bool is_smt_enabled;
} CPUTopology;

void detect_smt_topology(CPUTopology* topology) {
    uint32_t eax, ebx, ecx, edx;
    
    // CPUID leaf 0Bh: Extended Topology Enumeration
    eax = 0x0B;
    ecx = 0;  // Level 0: SMT
    cpuid(&eax, &ebx, &ecx, &edx);
    
    topology->threads_per_core = ebx & 0xFFFF;
    // Additional processing to determine core IDs...
}
```

**Scheduling policies:**

```
Prefer filling cores before using SMT:
    - Schedule threads on separate physical cores first
    - Use SMT threads only when cores exhausted
    - Maximizes per-thread performance
    - Good for CPU-bound workloads

Prefer using SMT threads together:
    - Schedule related threads on same core
    - Better cache locality
    - Reduced inter-core communication latency
    - Good for cooperative workloads

Balance based on workload:
    - Memory-bound: Use SMT aggressively
    - CPU-bound: Prefer separate cores
    - OS can adjust based on performance counters
```

**Example Linux scheduler:**

```c
// Simplified scheduling decision
void schedule_thread(Thread* thread) {
    CPU* target_cpu;
    
    if (workload_is_memory_bound(thread)) {
        // Memory-bound: SMT helps hide latency
        target_cpu = find_cpu_with_spare_smt_slot();
    } else {
        // CPU-bound: Prefer separate core
        target_cpu = find_idle_physical_core();
        if (target_cpu == NULL) {
            // No idle cores, use SMT
            target_cpu = find_least_loaded_cpu();
        }
    }
    
    migrate_thread(thread, target_cpu);
}
```

### SMT Security Concerns

SMT introduces security vulnerabilities due to shared resources between threads that may be running different security contexts.

**Side-channel attacks:**

```
Cache timing attacks:
    - Thread A can observe cache state changes from Thread B
    - Thread B's access patterns leak information
    - Thread A times cache accesses to infer Thread B's behavior
    
Execution port contention:
    - Thread A can measure execution time variations
    - Variations indicate Thread B's instruction mix
    - May leak cryptographic key bits

TLB timing:
    - Similar to cache timing but for TLB entries
    - Can leak address space layout information
```

**Mitigations:**

```
Disable SMT:
    - Eliminates shared resource side channels
    - Costs 20-30% throughput
    - Used in high-security environments

Core scheduling:
    - Only allow threads from same security context on SMT pairs
    - Schedule trusted threads together
    - Prevents cross-security-domain leakage
    
Hardware mitigations:
    - Partition critical resources
    - Clear shared state on context switch
    - Reduce timing precision
```

**Example SMT disable:**

```bash
