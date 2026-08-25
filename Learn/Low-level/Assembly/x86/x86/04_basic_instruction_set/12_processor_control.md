## Processor Control


HLT (Halt) stops instruction execution and places the processor in a halt state until an interrupt occurs. Only privileged code (ring 0) can execute HLT. Operating systems use HLT to put idle processors into low-power states.

When a processor executes HLT, it stops fetching and executing instructions until interrupted by an external interrupt, NMI, SMI, or reset. This significantly reduces power consumption compared to busy-waiting.

CLI (Clear Interrupt Flag) and STI (Set Interrupt Flag) disable and enable maskable interrupts. `CLI` clears IF in RFLAGS, preventing maskable hardware interrupts from being recognized. `STI` sets IF, enabling interrupts. These instructions are privileged in protected mode and long mode (require ring 0).

Critical sections in kernel code often disable interrupts:

```
CLI                    ; Disable interrupts
; Critical section code
STI                    ; Re-enable interrupts
```

However, disabling interrupts for extended periods degrades system responsiveness. Modern operating systems prefer spinlocks and other synchronization primitives that don't require disabling interrupts globally.

CLD (Clear Direction Flag) and STD (Set Direction Flag) control string instruction direction. `CLD` clears DF, making string instructions increment index registers (forward direction). `STD` sets DF, making string instructions decrement index registers (backward direction).

String instructions (MOVS, CMPS, SCAS, LODS, STOS) adjust RSI and/or RDI based on DF. Most code operates with DF=0 (cleared), and many calling conventions require functions to preserve DF=0. Functions that modify DF should restore it before returning.

