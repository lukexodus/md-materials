## BIOS/UEFI and Boot Sequence


---

### Legacy BIOS

The Basic Input/Output System originated with the IBM PC (1981) and remained the dominant firmware interface for three decades. It is a 16-bit real-mode program stored in a ROM chip (later flash) on the motherboard, executed by the CPU immediately after reset.

**Reset vector**: On x86, after power-on or reset, the CPU begins execution at physical address `0xFFFFFFF0` (the reset vector) in real mode. The CPU's segment registers are initialized such that `CS:IP = F000:FFF0`, which maps to the top of the 1 MB real-mode address space. The instruction at that address is typically a far jump into the main BIOS body.

**POST (Power-On Self-Test)**: The BIOS executes a sequential hardware initialization and validation routine:

1. CPU register and cache initialization
2. Chipset initialization (northbridge/southbridge configuration)
3. Memory controller initialization and DRAM training (SPD negotiation)
4. Memory test (range scan, pattern write/verify)
5. PCI bus enumeration and BAR assignment
6. Video BIOS initialization (INT 10h services)
7. Keyboard, serial, and parallel controller initialization
8. Detection of bootable devices

Errors during POST are signaled via beep codes (before video is available) or POST codes written to I/O port `0x80`, readable by a diagnostic card.

**INT 13h and boot device selection**: The BIOS provides hardware abstraction through software interrupts. INT 13h is the disk services interrupt. The BIOS iterates through the boot order (configured in CMOS/NVRAM), calling INT 13h to read the first sector (512 bytes) of each candidate device. If bytes 510–511 of that sector contain the signature `0x55 0xAA`, the sector is treated as the Master Boot Record (MBR) and control is transferred to it at address `0x7C00`.

**MBR structure** (512 bytes):

```
Offset  Size    Content
0x000   446 B   Bootstrap code (first-stage bootloader)
0x1BE   64 B    Partition table (4 × 16-byte entries)
0x1FE   2 B     Boot signature: 0x55 0xAA
```

Each partition table entry encodes: boot flag, CHS start, partition type, CHS end, LBA start, and sector count. CHS (Cylinder-Head-Sector) addressing limits disks to 8 GB (with 24-bit CHS) or 2 TB (LBA32). This is the primary capacity constraint driving the transition to GPT.

**Fundamental BIOS limitations**:

- 16-bit real mode throughout firmware execution
- 1 MB addressable space during POST (before switching to protected mode)
- MBR partition table: 4 primary partitions maximum, 2 TB disk limit
- No authenticated boot, no driver model, no network stack in firmware
- No standardized interface for add-in card firmware beyond Option ROMs

---

### UEFI Architecture

UEFI (Unified Extensible Firmware Interface) is a specification maintained by the UEFI Forum (originally developed by Intel as EFI for Itanium). It replaces the legacy BIOS with a 32/64-bit firmware environment, a modular driver model, a standardized runtime services API, and a well-defined handoff protocol to the OS.

The reference implementation is TianoCore EDK II (open source). Vendor firmwares (AMI Aptio, Phoenix SecureCore, Insyde H2O) are built atop EDK II or independently conformant to the spec.

**UEFI phases** (defined by the PI — Platform Initialization — specification):

```
SEC → PEI → DXE → BDS → TSL → RT → AL
```

Each phase is architecturally distinct in what memory and services are available.

**SEC (Security)**: Executes from CPU reset. CPU is in real mode (x86) or EL3 (ARM). No DRAM available — execution is entirely in Cache-As-RAM (CAR), where a portion of L1/L2 cache is configured as SRAM by disabling eviction. Responsibilities: CPU microcode update, establish CAR, validate and jump to PEI core. This is where measured boot begins — SEC measures the PEI core into a TPM PCR before executing it.

**PEI (Pre-EFI Initialization)**: Memory initialization. PEI modules (PEIMs) run in CAR and initialize DRAM through the Memory Reference Code (MRC) — a large, platform-specific binary blob that trains DDR timings, configures the memory controller, and validates DRAM. Once DRAM is available, the PEI core installs a Hand-Off Block (HOB) list in memory and launches the DXE core.

**DXE (Driver Execution Environment)**: The main firmware body. A full 32/64-bit protected-mode or long-mode environment with a dependency-resolved driver dispatch model. DXE drivers are PE/COFF executables stored in the firmware volume (a structured flash region). Drivers expose and consume UEFI protocols — typed GUIDs that serve as interface handles. DXE initializes: PCIe, storage controllers, NIC, USB, GOP (Graphics Output Protocol replacing legacy VGA BIOS), and all platform hardware.

**BDS (Boot Device Selection)**: After DXE, BDS loads the UEFI boot manager. It reads boot entries from NVRAM variables (`BootOrder`, `Boot####`), locates EFI System Partitions (ESP), and loads the designated boot application.

**TSL (Transient System Load)**: The OS bootloader executes as a UEFI application in this phase. It can call UEFI Boot Services and Runtime Services. When the bootloader calls `ExitBootServices()`, the firmware transfers exclusive control to the OS kernel.

**RT (Runtime)**: Post-`ExitBootServices()`. Boot Services are no longer available. Runtime Services remain callable by the OS: `GetTime`, `SetVariable`, `ResetSystem`, `UpdateCapsule` (for firmware updates). Runtime Services reside in memory regions marked `EfiRuntimeServicesCode/Data` and are mapped into the OS virtual address space after `SetVirtualAddressMap()`.

**AL (After Life)**: Error recovery, S4/S5 power transitions.

---

The two diagrams below show the UEFI phase sequence and the ESP/GPT layout.---

### GUID Partition Table (GPT) and the EFI System Partition

UEFI mandates GPT as the partition table format (though UEFI can also boot MBR disks in CSM mode). GPT addresses all MBR limitations.

**GPT layout**:

```
LBA 0       Protective MBR     (for legacy tool compatibility)
LBA 1       GPT header         (disk GUID, partition entry array location, CRC32)
LBA 2–33    Partition entries   (up to 128 entries × 128 bytes each)
...         Partition data
LBA −34..−2 Backup partition entries
LBA −1      Backup GPT header
```

GPT uses 64-bit LBA addressing — the maximum addressable disk size is 2⁶⁴ × sector size. At 512-byte sectors that is ~9.4 ZB, effectively unlimited.

**EFI System Partition (ESP)**: A FAT32 partition (type GUID `C12A7328-F81F-11D2-BA4B-00A0C93EC93B`) present on every UEFI-bootable disk. It contains UEFI boot applications in PE/COFF format. The canonical path for a bootable application is:

```
\EFI\BOOT\BOOTx64.EFI          (fallback boot path, any OS)
\EFI\Microsoft\Boot\bootmgfw.efi   (Windows Boot Manager)
\EFI\ubuntu\grubx64.efi            (GRUB for Ubuntu)
\EFI\systemd\systemd-bootx64.efi   (systemd-boot)
```

Boot entries in NVRAM (`Boot####` variables) record the device path and file path of the target `.efi` application. The boot manager loads the `.efi` binary, validates its signature (if Secure Boot is enabled), and transfers execution.---

### Secure Boot

Secure Boot is a UEFI feature (not a BIOS feature) that enforces cryptographic verification of every executable loaded during the boot process. It is specified in the UEFI specification chapter on "Secure Boot and Driver Signing."

**Key databases stored in NVRAM**:

|Variable|Content|
|---|---|
|`PK` (Platform Key)|Single RSA-2048/4096 key; owner controls all other databases|
|`KEK` (Key Exchange Key)|Keys authorized to update `db` and `dbx`|
|`db` (Signature Database)|Allowed certificates and hashes|
|`dbx` (Forbidden Signature Database)|Revoked certificates and hashes|
|`MOK` (Machine Owner Key)|Shim-managed user-enrolled keys (Linux-specific)|

**Verification chain**: The firmware verifies each loaded `.efi` binary against `db`/`dbx` before executing it. The bootloader (GRUB, systemd-boot, Windows Boot Manager) is then responsible for verifying the kernel it loads. The kernel may verify kernel modules. Each link in the chain is cryptographically bound to the previous.

**Shim**: On most Linux distributions, the first-stage loader is `shim.efi` — a small UEFI application signed by Microsoft's KEK and therefore trusted by OEM firmware out of the box. Shim then verifies GRUB using the distribution's own key (enrolled in MOK or embedded in shim). This avoids requiring every Linux distribution to be directly signed by Microsoft.

**Setup Mode vs. User Mode**: When `PK` is empty, the firmware is in Setup Mode — any key can be enrolled. Once `PK` is set, the firmware enters User Mode and all database modifications must be signed by `PK` or `KEK`. Clearing `PK` requires physical presence (typically through firmware setup UI) to prevent software-based attacks on the Secure Boot key hierarchy.

---

### OS Bootloader Phase

After UEFI loads and authenticates the `.efi` bootloader, the bootloader operates as a UEFI application with full access to Boot Services. It:

1. Locates the kernel image (typically on a separate partition, or within an initramfs stored on the ESP or root filesystem)
2. Calls `AllocatePages` to allocate memory for the kernel
3. Reads kernel command-line parameters from its configuration file or NVRAM
4. On UEFI systems: calls `GetMemoryMap` to obtain the current physical memory layout (type, base, size for each region) — this becomes the OS memory map
5. Calls `ExitBootServices(MapKey)` — the `MapKey` must match the current memory map version; if it does not (because the map changed after `GetMemoryMap`), `ExitBootServices` returns an error and the bootloader must retry
6. Transfers control to the kernel entry point

After `ExitBootServices`, the bootloader no longer exists as a concept. The kernel owns the machine. UEFI Runtime Services remain accessible via the virtual address mapping established by `SetVirtualAddressMap`.

**Linux-specific**: The Linux kernel since ~2012 implements the EFI stub — a UEFI application entry point embedded directly in the kernel image (`vmlinuz` with `CONFIG_EFI_STUB=y`). This allows the kernel to be loaded directly by the UEFI boot manager without a separate bootloader, though it limits configuration options compared to GRUB.

---

### Kernel Handoff State

At the moment the kernel receives control from the bootloader, the architectural state is precisely defined:

**x86-64 (Linux)**:

- CPU is in 64-bit long mode
- Paging is enabled with an identity map (virtual = physical) for the kernel load address
- Interrupts are disabled (`EFLAGS.IF = 0`)
- GDT is set up with minimal flat segments (code and data at base 0)
- IDT is not yet set up (any fault before `idt_setup_early_handler` is fatal)
- `rsi` register points to the `boot_params` structure (a 4 KB block at a known physical address containing: BIOS/UEFI memory map, command line pointer, initrd address/size, video mode info, ACPI RSDP pointer)
- Stack is set to a temporary location within the kernel image

**ARM64 (AArch64, Linux)**:

- CPU is in EL1 (kernel exception level)
- MMU is off; caches are off or invalidated
- `x0` points to the device tree blob (DTB) or ACPI tables
- `x1`–`x3` are zeroed (reserved for future use by the boot protocol)

The kernel's first instructions set up a minimal stack, build the page tables, enable the MMU, and jump to architecture-independent C code (`start_kernel`), at which point the boot sequence transitions to kernel initialization proper.

---

### ACPI and Firmware Tables

UEFI does not end the firmware's role at `ExitBootServices`. A set of firmware-provided data tables remains in memory and is accessed by the OS throughout its lifetime.

**ACPI (Advanced Configuration and Power Interface)**: A standardized description of system hardware in the form of bytecode tables. Key tables:

|Table|Role|
|---|---|
|RSDP|Root System Description Pointer — entry point, found via UEFI config table or legacy scan|
|XSDT|Extended System Description Table — array of pointers to all other tables|
|MADT|Multiple APIC Description Table — CPU and interrupt controller topology|
|SRAT|System Resource Affinity Table — NUMA node assignments for CPUs and memory|
|SLIT|System Locality Information Table — NUMA distance matrix|
|MCFG|PCI Express memory-mapped configuration space base addresses|
|DSDT/SSDT|Differentiated/Secondary System Description Tables — AML bytecode for device enumeration and power management|
|BGRT|Boot Graphics Resource Table — splash screen framebuffer location|

AML (ACPI Machine Language) is an interpreted bytecode executed by the OS's ACPI subsystem (Linux: `acpica` library). It implements methods like `_STA` (device present?), `_CRS` (current resource settings), `_PRT` (PCI interrupt routing), and power management transitions (`_PS0`–`_PS3`).

**Key Points**:

- Cache-As-RAM in SEC is a requirement because DRAM is not yet initialized — the CPU must execute from somewhere, and flash is too slow for runtime code; CAR repurposes cache SRAM as a small scratchpad.
- The `ExitBootServices` / `MapKey` handshake is a deliberate protocol: it detects memory map changes (e.g., from a late-arriving UEFI driver) that would invalidate the map the kernel was given.
- UEFI NVRAM variables are the authoritative boot configuration; `efibootmgr` (Linux) and `bcdedit` (Windows) both manipulate `BootOrder` and `Boot####` variables directly.
- UEFI runtime services that survive into the OS (`GetVariable`, `SetVariable`, `ResetSystem`) are called through a virtual address that the OS sets up via `SetVirtualAddressMap` — the firmware code is mapped into the kernel's virtual address space at a fixed offset.
- Secure Boot `dbx` updates are the primary mechanism for revoking compromised bootloaders; they are delivered via Windows Update and LVFS/fwupd on Linux, and take effect at the firmware level on next boot.

**Conclusion**: The BIOS/UEFI boot sequence is not a monolithic handoff but a staged pipeline: each phase establishes a more capable execution environment for the next, with explicit cryptographic checkpoints (Secure Boot, measured boot), standardized interfaces (UEFI protocols, ACPI tables), and a precisely defined hardware state at kernel entry. Understanding this pipeline is prerequisite to reasoning about firmware security, boot-time performance, and the behavior of low-level system software.

---

