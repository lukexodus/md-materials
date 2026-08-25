## FLAGS Register


The FLAGS register (EFLAGS in 32-bit, RFLAGS in 64-bit) contains status flags that conditional jumps test. Understanding these flags is essential for control flow.

**Status Flags:**

**CF (Carry Flag, bit 0):** Set when an unsigned arithmetic operation generates a carry out of or borrow into the most significant bit.

```asm
mov al, 255
add al, 1           ; AL = 0, CF = 1 (carry out)

mov al, 0
sub al, 1           ; AL = 255, CF = 1 (borrow)
```

**PF (Parity Flag, bit 2):** Set if the least significant byte of the result has an even number of 1 bits.

```asm
mov al, 3           ; Binary: 00000011 (two 1 bits)
add al, 0           ; PF = 1 (even parity)

mov al, 7           ; Binary: 00000111 (three 1 bits)
add al, 0           ; PF = 0 (odd parity)
```

**AF (Auxiliary Carry Flag, bit 4):** Set when an operation causes a carry from bit 3 to bit 4. Used for Binary Coded Decimal (BCD) arithmetic.

```asm
mov al, 0x0F
add al, 1           ; AL = 0x10, AF = 1
```

**ZF (Zero Flag, bit 6):** Set if the result of an operation is zero.

```asm
mov eax, 5
sub eax, 5          ; EAX = 0, ZF = 1

mov eax, 10
sub eax, 5          ; EAX = 5, ZF = 0
```

**SF (Sign Flag, bit 7):** Set equal to the most significant bit of the result (0 = positive, 1 = negative in two's complement).

```asm
mov eax, -1         ; EAX = 0xFFFFFFFF
add eax, 0          ; SF = 1 (negative)

mov eax, 1
add eax, 0          ; SF = 0 (positive)
```

**OF (Overflow Flag, bit 11):** Set when a signed arithmetic operation produces a result too large or too small for the destination.

```asm
mov al, 127         ; Maximum positive value for signed byte
add al, 1           ; AL = -128 (0x80), OF = 1 (overflow)

mov al, -128        ; Minimum negative value for signed byte
sub al, 1           ; AL = 127, OF = 1 (overflow)
```

**DF (Direction Flag, bit 10):** Controls the direction of string operations (0 = increment, 1 = decrement).

```asm
cld                 ; Clear DF (auto-increment)
std                 ; Set DF (auto-decrement)
```

**IF (Interrupt Flag, bit 9):** Controls whether interrupts are enabled (1) or disabled (0).

```asm
cli                 ; Clear IF (disable interrupts)
sti                 ; Set IF (enable interrupts)
```

