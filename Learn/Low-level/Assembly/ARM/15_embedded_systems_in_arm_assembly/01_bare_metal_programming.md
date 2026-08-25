## Bare-metal Programming


Bare-metal programming refers to writing code that runs directly on hardware without an operating system. The programmer has complete control over all resources but must manually manage everything the OS would typically handle.

**Core Responsibilities:**

**Hardware Initialization** The processor starts in an undefined state. Code must configure clock sources, enable peripheral clocks, set up memory controllers (DRAM timing, chip selects), and initialize GPIO pin modes. On Cortex-M processors, the System Control Block (SCB) registers control core behavior including vector table location and priority grouping.

**Memory Management** Without virtual memory, physical addresses are used directly. Memory regions are defined with specific purposes: code in flash/ROM, data in SRAM, peripheral registers at fixed addresses. Memory Protection Units (MPU) on Cortex-M3/M4/M7 can enforce access restrictions even without an MMU.

**Direct Hardware Access** Peripherals are controlled through memory-mapped registers. Writing to specific addresses controls UART transmission, SPI clock rates, ADC sampling, timer configurations. Each register bit has hardware-defined meaning documented in the chip reference manual.

**Interrupt Handling** Interrupts must be manually enabled in the NVIC (Nested Vectored Interrupt Controller). Priority levels, interrupt service routine addresses, and enable flags require explicit configuration. Context saving (register preservation) is partially automatic on Cortex-M but manual on Cortex-A/R.

**Example** - Basic GPIO toggle on ARM Cortex-M:

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ Memory-mapped register addresses
.equ RCC_AHB1ENR,  0x40023830
.equ GPIOA_MODER,  0x40020000
.equ GPIOA_ODR,    0x40020014

.global main
.type main, %function

main:
    @ Enable GPIOA clock
    LDR r0, =RCC_AHB1ENR
    LDR r1, [r0]
    ORR r1, r1, #0x01        @ Set bit 0
    STR r1, [r0]
    
    @ Configure PA5 as output
    LDR r0, =GPIOA_MODER
    LDR r1, [r0]
    BIC r1, r1, #(0x3 << 10) @ Clear bits 10-11
    ORR r1, r1, #(0x1 << 10) @ Set as output
    STR r1, [r0]
    
loop:
    @ Toggle PA5
    LDR r0, =GPIOA_ODR
    LDR r1, [r0]
    EOR r1, r1, #(1 << 5)    @ XOR bit 5
    STR r1, [r0]
    
    @ Simple delay
    LDR r2, =500000
delay_loop:
    SUBS r2, r2, #1
    BNE delay_loop
    
    B loop
```

