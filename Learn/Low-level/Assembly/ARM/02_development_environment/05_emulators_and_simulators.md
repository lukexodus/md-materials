## Emulators and Simulators


### QEMU (Quick Emulator)

QEMU is a widely-used open-source machine emulator and virtualizer that supports full system emulation for ARM architectures. It allows developers to run ARM binaries on x86 hosts without requiring physical ARM hardware.

**System Emulation Mode**

QEMU's system emulation mode virtualizes an entire ARM machine, including CPU, memory, peripherals, and devices. This mode is useful for testing bootloaders, operating systems, and bare-metal applications. The emulator supports various ARM boards such as versatilepb, vexpress-a9, vexpress-a15, and raspi2/raspi3 for Raspberry Pi emulation.

When running in system mode, QEMU can emulate different ARM processor variants including ARM926, ARM1176, Cortex-A9, Cortex-A15, and Cortex-A53/A57. The choice of CPU model affects available instruction sets and architectural features.

**User Mode Emulation**

User mode emulation allows running ARM Linux binaries directly on x86 Linux hosts by translating ARM instructions to host architecture instructions on-the-fly. This mode is faster than system emulation and suitable for testing userspace applications. The qemu-arm binary handles translation and system call forwarding between guest ARM programs and the host kernel.

**Debugging Capabilities**

QEMU integrates with GDB through its remote debugging stub. Developers can attach GDB to a running QEMU instance using the `-s` flag (opens port 1234) or `-S` flag (starts paused, waiting for debugger). This enables breakpoints, single-stepping, register inspection, and memory examination during program execution.

**Command Line Usage**

Basic QEMU invocation requires specifying the ARM variant and binary to execute. Common flags include `-M` for machine type, `-cpu` for processor model, `-m` for memory size, `-kernel` for kernel image, and `-append` for kernel command line arguments.

### ARM Fast Models

ARM Fast Models are instruction-accurate software models of ARM processors that execute faster than cycle-accurate simulators. These commercial tools from ARM provide high simulation speed while maintaining functional accuracy, making them suitable for software development before hardware availability.

### Cycle-Accurate Simulators

Cycle-accurate simulators model the exact timing behavior of ARM processors, including pipeline stages, cache behavior, and memory access latency. While slower than functional simulators, they provide precise performance analysis and timing verification for real-time systems and performance-critical code.

