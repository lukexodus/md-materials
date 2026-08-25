## Driver Interfaces


### Linux Device Drivers

**Character Device Interface**:

Userspace assembly interacts with character devices through file operations:

```asm
; Open device file
mov rax, 2          ; sys_open
mov rdi, device_path  ; e.g., "/dev/mydevice"
mov rsi, O_RDWR
syscall
mov [dev_fd], rax

; ioctl for device control
mov rax, 16         ; sys_ioctl
mov rdi, [dev_fd]
mov rsi, IOCTL_CMD  ; device-specific command
mov rdx, arg        ; pointer to argument structure
syscall

; Memory map device registers
mov rax, 9          ; sys_mmap
mov rdi, 0
mov rsi, size
mov rdx, PROT_READ | PROT_WRITE
mov r10, MAP_SHARED
mov r8, [dev_fd]
mov r9, 0           ; offset
syscall
```

**Key Points:**

- ioctl commands are device-specific
- ioctl number encoding includes direction, size, type, and command number
- Memory-mapped I/O allows direct hardware access from userspace

**Block Device Interface**:

```asm
; Block devices use similar file operations
mov rax, 2          ; sys_open
mov rdi, block_dev  ; e.g., "/dev/sda"
mov rsi, O_RDONLY | O_DIRECT
syscall

; Read directly from block device
mov rax, 0          ; sys_read
mov rdi, [block_fd]
mov rsi, buffer
mov rdx, block_size
syscall
```

The `O_DIRECT` flag bypasses page cache for direct hardware access.

**Network Device Interface**:

Assembly can create raw sockets for low-level network access:

```asm
; socket(domain, type, protocol)
mov rax, 41         ; sys_socket
mov rdi, AF_PACKET  ; raw packet interface
mov rsi, SOCK_RAW
mov rdx, htons(ETH_P_ALL)
syscall

; Bind to specific interface
mov rax, 49         ; sys_bind
mov rdi, [sock_fd]
mov rsi, sockaddr   ; sockaddr_ll structure
mov rdx, sockaddr_len
syscall

; Send raw packet
mov rax, 44         ; sys_sendto
mov rdi, [sock_fd]
mov rsi, packet
mov rdx, packet_len
mov r10, 0          ; flags
mov r8, dest_addr
mov r9, addr_len
syscall
```

**Key Points:**

- Requires `CAP_NET_RAW` capability or root privileges
- Direct access to link layer
- Can construct custom Ethernet frames

**DMA (Direct Memory Access)**:

For high-performance I/O, drivers may expose DMA buffers:

```asm
; Allocate DMA-capable memory (via driver ioctl)
mov rax, 16         ; sys_ioctl
mov rdi, [dev_fd]
mov rsi, IOCTL_ALLOC_DMA
mov rdx, dma_request
syscall

; Get physical address for DMA
; Returned in dma_request structure

; Trigger DMA operation
mov rax, 16
mov rdi, [dev_fd]
mov rsi, IOCTL_START_DMA
mov rdx, dma_params
syscall
```

**Key Points:**

- DMA buffers must be physically contiguous
- Requires cache coherency management
- Hardware directly accesses memory without CPU intervention

### Hardware Port Access

**I/O Ports (Legacy x86)**:

Direct port access from userspace (requires privileges):

```asm
; ioperm(from, num, turn_on)
mov rax, 173        ; sys_ioperm
mov rdi, 0x3f8      ; COM1 base port
mov rsi, 8          ; number of ports
mov rdx, 1          ; enable access
syscall

; Now can use in/out instructions
mov dx, 0x3f8
in al, dx           ; Read from COM1 data register

mov al, 'A'
out dx, al          ; Write to COM1
```

**Key Points:**

- Limited to first 1024 ports with ioperm
- `iopl` system call grants full port access (more dangerous)
- Modern systems typically use memory-mapped I/O instead

**Memory-Mapped I/O (MMIO)**:

```asm
; Open /dev/mem (requires root)
mov rax, 2
mov rdi, mem_device  ; "/dev/mem"
mov rsi, O_RDWR | O_SYNC
syscall

; Map hardware registers
mov rax, 9
mov rdi, 0
mov rsi, size
mov rdx, PROT_READ | PROT_WRITE
mov r10, MAP_SHARED
mov r8, [mem_fd]
mov r9, phys_addr   ; physical address of hardware
syscall
mov [mmio_base], rax

; Access hardware registers
mov rdi, [mmio_base]
mov eax, [rdi]      ; Read 32-bit register
mov dword [rdi+4], 0x1  ; Write to register
```

**Key Points:**

- Requires knowledge of hardware physical addresses
- Cache behavior important (use `O_SYNC` or cache control)
- Alignment requirements depend on hardware

### Interrupt Handling

**Userspace Interrupt Notification**:

Linux UIO (Userspace I/O) framework:

```asm
; Open UIO device
mov rax, 2
mov rdi, uio_dev    ; "/dev/uio0"
mov rsi, O_RDWR
syscall
mov [uio_fd], rax

; Wait for interrupt
mov rax, 0          ; sys_read
mov rdi, [uio_fd]
mov rsi, int_count  ; buffer for interrupt count
mov rdx, 4
syscall             ; Blocks until interrupt occurs

; Acknowledge interrupt (re-enable)
mov rax, 1          ; sys_write
mov rdi, [uio_fd]
mov rsi, ack_value  ; value to write (usually 1)
mov rdx, 4
syscall
```

**VFIO (Virtual Function I/O)**:

For direct device assignment to userspace (used in virtualization):

```asm
; Open VFIO container
mov rax, 2
mov rdi, vfio_cont  ; "/dev/vfio/vfio"
mov rsi, O_RDWR
syscall

; Attach group to container
mov rax, 16         ; sys_ioctl
mov rdi, [cont_fd]
mov rsi, VFIO_SET_IOMMU
mov rdx, VFIO_TYPE1_IOMMU
syscall

; Map DMA
mov rax, 16
mov rdi, [cont_fd]
mov rsi, VFIO_IOMMU_MAP_DMA
mov rdx, dma_map    ; struct vfio_iommu_type1_dma_map
syscall
```

**Key Points:**

- Provides IOMMU protection for DMA
- Allows safe userspace device drivers
- Used by DPDK and other high-performance frameworks

### Windows Driver Interface (x86 Assembly Context)

**Device I/O Control**:

```asm
; DeviceIoControl equivalent using NtDeviceIoControlFile
extern NtDeviceIoControlFile

; Setup parameters (Windows x64 calling convention)
mov rcx, device_handle
mov rdx, event_handle
mov r8, apc_routine
mov r9, apc_context
; Additional parameters on stack:
; IoStatusBlock, IoControlCode, InputBuffer, InputBufferLength,
; OutputBuffer, OutputBufferLength

sub rsp, 48h        ; Shadow space + parameters
; Load additional parameters onto stack
call NtDeviceIoControlFile
add rsp, 48h
```

**Kernel-Mode Driver Access**:

Kernel-mode assembly in Windows drivers uses different structures:

```asm
; Driver entry point signature
DriverEntry:
    ; RCX = DriverObject
    ; RDX = RegistryPath
    
    ; Register dispatch routines
    ; [RCX + DRIVER_OBJECT.MajorFunction + IRP_MJ_CREATE*8], handler
    
    ret
```

**[Inference]** Specific implementation details of Windows kernel-mode assembly depend on the driver framework (WDM, WDF) being used.

### BSD Driver Interface

BSD device drivers follow a different model:

```asm
; Open device (similar to Linux)
mov rax, 5          ; BSD sys_open number (varies)
mov rdi, device
mov rsi, O_RDWR
syscall

; ioctl (similar but different command encoding)
mov rax, 54         ; BSD sys_ioctl number
mov rdi, [fd]
mov rsi, ioctl_cmd  ; BSD-style encoding
mov rdx, arg
syscall
```

**Key Points:**

- ioctl command encoding differs from Linux
- Device naming conventions differ (/dev/da0 vs /dev/sda)
- Different kernel interfaces for driver development

### DMA Buffer Management

Allocating coherent DMA buffers:

```asm
; Using driver-specific ioctl
struc dma_alloc_req
    .size:      resq 1      ; Size to allocate
    .virt_addr: resq 1      ; Returned virtual address
    .phys_addr: resq 1      ; Returned physical address
    .flags:     resq 1      ; Allocation flags
endstruc

mov rax, 16             ; sys_ioctl
mov rdi, [dev_fd]
mov rsi, IOCTL_ALLOC_DMA
lea rdx, [dma_req]
syscall

; Use returned addresses
mov rdi, [dma_req + dma_alloc_req.virt_addr]
; Write data to buffer
mov rsi, data
mov rcx, size
rep movsb

; Trigger DMA with physical address
mov rdi, [dma_req + dma_alloc_req.phys_addr]
; Pass to hardware via MMIO register write
```

**Key Points:**

- Virtual and physical addresses differ due to MMU
- Cache coherency critical for DMA correctness
- May require explicit cache flush/invalidate operations
- Alignment requirements depend on hardware

**Important subtopics**: UEFI system call interfaces for bootloaders and firmware, real-time operating system (RTOS) interfaces with deterministic behavior, hypervisor interfaces (hypercalls) for virtualized environments, coprocessor interfaces (GPU, FPGA) for offload computation.

---

