## **Syllabus of MIPS Architecture and Assembly Language**

### **Unit 1: Introduction to MIPS**

- **Overview of MIPS Architecture**
- **History and Development of MIPS**
- **Key Features of MIPS Architecture**
- **Applications of MIPS Processors**

### **Unit 2: MIPS Instruction Set**

- **Instruction Types and Formats**
- **Opcode and Function Fields**
- **Immediate and Register Addressing Modes**
- **Instruction Execution Cycle**
- **Pipelining in MIPS**

### **Unit 3: MIPS Registers**

- **General-Purpose Registers**
- **Special-Purpose Registers**
- **Register Usage in MIPS Instructions**
- **Register Transfer Language (RTL)**

### **Unit 4: MIPS Assembly Language**

- **Introduction to Assembly Language Programming**
- **Basic Syntax and Structure**
- **Writing Simple Programs**
- **Control Structures (Loops, Conditionals)**
- **Functions and Procedures**

### **Unit 5: Data Types and Operations**

- **Integer and Floating-Point Data Types**
- **Arithmetic and Logical Operations**
- **Data Movement Instructions**
- **Handling of Special Values (Zero, NaN)**

### **Unit 6: Memory Management**

- **Memory Addressing Modes**
- **Memory Access Instructions**
- **Handling of Arrays and Structures**
- **Memory-Mapped I/O**

### **Unit 7: Advanced MIPS Features**

- **Superscalar Execution**
- **Branch Prediction and Handling**
- **Exception Handling and Interrupts**
- **Performance Optimization Techniques**

### **Unit 8: Practical Projects**

- **Designing a Simple Processor Using MIPS**
- **Implementing Algorithms in MIPS Assembly**
- **Simulating MIPS Programs**
- **Performance Analysis and Optimization**

### **Textbooks:**

- **Computer Organization and Design** by David A. Patterson and John L. Hennessy
- **MIPS Assembly Language Programming** by Robert Britton
- **Digital Design and Computer Architecture** by Sarah Harris and David Harris

---

# Instruction Set

## Why is MIPS called MIPS?

MIPS stands for **Microprocessor without Interlocked Pipeline Stages**.  

**Meaning of MIPS**  
- **Microprocessor** – It is a type of processor used in computers and embedded systems.  
- **Without Interlocked Pipeline Stages** – The original MIPS design aimed to simplify processor control by avoiding interlocking mechanisms that stall the pipeline. Instead, the **compiler** was responsible for scheduling instructions efficiently to prevent data hazards.  

**Why This Name?**  
Early MIPS processors used a **RISC (Reduced Instruction Set Computing) architecture**, which focused on:  
1. **Simple Instructions** – Executed in a single clock cycle.  
2. **Pipelining** – Instructions were divided into stages (fetch, decode, execute, memory access, write-back).  
3. **No Hardware Interlocks (Initially)** – Instead of the processor detecting hazards and stalling execution, the **compiler** was responsible for inserting delay slots or rearranging instructions to maintain efficiency.  

**Did MIPS Always Lack Interlocks?**  
- **Early MIPS CPUs (like MIPS I)** had **no hardware interlocks**, relying on **compilers** to handle instruction scheduling.  
- **Later MIPS CPUs (like MIPS R4000 and beyond)** introduced **some hardware interlocks** to improve performance and simplify software development.  

**Conclusion**  
MIPS is called **Microprocessor without Interlocked Pipeline Stages** because its early design relied on the **compiler** to manage instruction scheduling instead of using hardware-based pipeline interlocks. This approach was intended to keep the processor simple and fast, aligning with RISC principles.

## Instruction Types and Formats

MIPS (Microprocessor without Interlocked Pipeline Stages) uses a streamlined and efficient instruction set designed for high performance and ease of implementation. MIPS instructions are divided into three main types: R-type (Register), I-type (Immediate), and J-type (Jump). Each type of instruction has a specific format and serves different purposes. Here's a detailed look at each type:

### **1. R-type (Register) Instructions:**

**Format:**

```plaintext
| opcode (6 bits) | rs (5 bits) | rt (5 bits) | rd (5 bits) | shamt (5 bits) | funct (6 bits) |
```

- **opcode:** Operation code (always 0 for R-type instructions)
- **rs:** Source register 1
- **rt:** Source register 2
- **rd:** Destination register
- **shamt:** Shift amount (used only for shift instructions)
- **funct:** Function code (specifies the exact operation)

**Example:**

- `ADD $t1, $t2, $t3` (Add the values in registers $t2 and $t3, store the result in $t1)
    - opcode: 0
    - rs: $t2
    - rt: $t3
    - rd: $t1
    - shamt: 0
    - funct: 32 (ADD operation)

### **2. I-type (Immediate) Instructions:**

**Format:**

`| opcode (6 bits) | rs (5 bits) | rt (5 bits) | immediate (16 bits) |`

- **opcode:** Operation code (varies for different instructions)
- **rs:** Source register
- **rt:** Destination register
- **immediate:** Immediate value (a constant value or address offset)

**Example:**

- `ADDI $t1, $t2, 10` (Add the value in register $t2 and the immediate value 10, store the result in $t1)
    - opcode: 8 (ADDI)
    - rs: $t2
    - rt: $t1
    - immediate: 10

### **3. J-type (Jump) Instructions:**

**Format:**

`| opcode (6 bits) | address (26 bits) |`

- **opcode:** Operation code (varies for different instructions)
- **address:** Target address (26-bit address, combined with the upper bits of the Program Counter to form a 32-bit address)

**Example:**

- `J 10000` (Jump to the address 10000)
    - opcode: 2 (J)
    - address: 10000

**Summary of MIPS Instruction Types:**

|Instruction Type|Format|Purpose|
|---|---|---|
|**R-type**|`opcode|rs|
|**I-type**|`opcode|rs|
|**J-type**|`opcode|address`|

MIPS architecture is designed for simplicity and efficiency, and understanding these instruction formats is key to writing and analyzing MIPS assembly language programs.

---

## Opcode and Function FIelds

In the MIPS architecture, instructions are encoded using specific fields that define the operation and the operands. The **opcode** and **function** fields are crucial components of this encoding. Here's a detailed look at each:

### **Opcode Field:**

- **Definition:** The opcode (operation code) field specifies the basic operation to be performed. It is a 6-bit field located at the beginning of the instruction format.
- **Purpose:** The opcode determines the instruction type and guides the Control Unit in decoding and executing the instruction.
- **Range:** Since the opcode field is 6 bits, it can represent 64 different values (from 0 to 63).

### **Function Field:**

- **Definition:** The function field is used in R-type (Register) instructions to specify the exact operation. It is a 6-bit field located at the end of the instruction format.
- **Purpose:** The function field works in conjunction with the opcode to provide additional specification for R-type instructions. While the opcode indicates that an instruction is an R-type, the function field specifies the exact operation (e.g., add, subtract, and, or).
- **Range:** Similar to the opcode, the function field, being 6 bits, can represent 64 different values.

### **Example of Opcode and Function Fields in R-type Instructions:**

**Format:**

`| opcode (6 bits) | rs (5 bits) | rt (5 bits) | rd (5 bits) | shamt (5 bits) | funct (6 bits) |`

**Example: ADD Instruction**

- **Opcode:** 0 (indicates an R-type instruction)
- **Function (funct):** 32 (specifies the ADD operation)

**Encoding:**

`| 000000 | rs | rt | rd | 00000 | 100000 |`

### **Example of Opcode Field in I-type and J-type Instructions:**

**Format for I-type:**

`| opcode (6 bits) | rs (5 bits) | rt (5 bits) | immediate (16 bits) |`

**Format for J-type:**

`| opcode (6 bits) | address (26 bits) |`

**Example: ADDI (Add Immediate) Instruction**

- **Opcode:** 8 (indicates the ADDI operation)

**Encoding:**

`| 001000 | rs | rt | immediate |`

**Summary of Some Common Opcodes and Function Codes:**

|Instruction|Opcode (Binary)|Function (Binary)|
|---|---|---|
|**R-type**|||
|ADD|000000|100000|
|SUB|000000|100010|
|AND|000000|100100|
|OR|000000|100101|
|SLT|000000|101010|
|**I-type**|||
|ADDI|001000|N/A|
|LW|100011|N/A|
|SW|101011|N/A|
|BEQ|000100|N/A|
|BNE|000101|N/A|
|**J-type**|||
|J|000010|N/A|
|JAL|000011|N/A|

**Key Points:**

- The **opcode** field determines the general type of the instruction (R-type, I-type, J-type) and specifies the operation for I-type and J-type instructions.
- The **function** field is specific to R-type instructions and provides additional details about the operation to be performed.

---

## Immediate and Register Addressing Modes

### **1. Immediate Addressing Mode:**

**Description:**

- **Immediate Addressing** involves specifying a constant value (immediate value) directly within the instruction. This value is used as an operand in the operation.

**Format:**

`| opcode | rs | rt | immediate |`

- **opcode:** Specifies the operation to be performed.
- **rs:** Source register containing the first operand.
- **rt:** Target register where the result will be stored.
- **immediate:** A constant value used as the second operand.

**Example:**

- **Instruction:** `ADDI $t1, $t2, 10`
    - **Explanation:** Add the value in register $t2 and the immediate value 10, then store the result in register $t1.
        
    - **Binary Encoding:**
        `opcode: 001000 (ADDI) rs: $t2 rt: $t1 immediate: 10`
        

**Use Case:**

- Immediate addressing is commonly used for operations involving constants, such as initializing variables or performing arithmetic calculations with fixed values.

### **2. Register Addressing Mode:**

**Description:**

- **Register Addressing** involves specifying operands that are located in registers. The instruction directly references the registers containing the operands.

**Format:**

`| opcode | rs | rt | rd | shamt | funct |`

- **opcode:** Specifies the operation to be performed (usually 000000 for R-type instructions).
- **rs:** First source register.
- **rt:** Second source register.
- **rd:** Destination register where the result will be stored.
- **shamt:** Shift amount (used for shift instructions, otherwise 0).
- **funct:** Function code specifying the exact operation.

**Example:**

- **Instruction:** `ADD $t1, $t2, $t3`
    - **Explanation:** Add the values in registers $t2 and $t3, then store the result in register $t1.
        
    - **Binary Encoding:**
        `opcode: 000000 (R-type) rs: $t2 rt: $t3 rd: $t1 shamt: 00000 funct: 100000 (ADD)`


**Use Case:**

- Register addressing is used for operations where both operands are in registers, providing fast access to data and efficient execution of instructions.

### **Comparison:**

|Addressing Mode|Format|Example|Use Case|
|---|---|---|---|
|**Immediate**|`opcode|rs|rt|
|**Register**|`opcode|rs|rt|

Both addressing modes provide different ways to access and manipulate data, offering flexibility in programming and efficient use of resources.

---

## **Instruction Execution Cycle**

The **Instruction Execution Cycle** refers to the process the CPU follows to execute an instruction. In MIPS, this cycle consists of the following key stages:

---

### **1. Fetch (IF - Instruction Fetch)**

- The CPU retrieves the instruction from memory.
- The **Program Counter (PC)** holds the address of the instruction to be fetched.
- The fetched instruction is stored in the **Instruction Register (IR)**.

**MIPS Execution**

```assembly
lw   $t0, 0($t1)   # Example instruction (Load Word)
```

- The instruction is fetched from memory at address **PC**.
- The PC is incremented (`PC = PC + 4`) to point to the next instruction.

---

### **2. Decode (ID - Instruction Decode & Register Fetch)**

- The instruction is analyzed to determine the type (e.g., arithmetic, memory, control).
- The control unit sets up the necessary control signals.
- If required, registers are read for operands.

**MIPS Execution**

- The instruction `lw $t0, 0($t1)` is identified as a **Load Word** operation.
- The CPU determines:
    - `$t0` is the destination register.
    - `$t1` is the base register.
    - `0` is the offset.
- The **Control Unit** activates the necessary signals for memory access.

---

### **3. Execute (EX - Execution / Address Calculation)**

- If the instruction is arithmetic (`ADD, SUB`), the ALU performs the computation.
- If it is a memory instruction (`LW, SW`), the ALU calculates the memory address.
- If it is a branch (`BEQ, BNE`), the ALU computes the target address.

**MIPS Execution**

```assembly
lw   $t0, 0($t1)
```

- The ALU computes the memory address:
    
    ```
    Memory Address = $t1 + Offset
    ```
    

---

### **4. Memory Access (MEM - Memory Read/Write, if needed)**

- If the instruction is `LW` (Load Word), the CPU reads data from memory into a register.
- If the instruction is `SW` (Store Word), the CPU writes data from a register into memory.

**MIPS Execution**

```assembly
lw   $t0, 0($t1)  # Load word from memory
```

- The CPU reads the word at the computed address and stores it in `$t0`.

---

### **5. Write Back (WB - Register Write-Back, if needed)**

- The result is stored back in a register (for arithmetic or load instructions).
- Control signals determine whether the register file is updated.

**MIPS Execution**

```assembly
lw   $t0, 0($t1)
```

- The data fetched from memory is written to register `$t0`.

---

**Summary of Execution Cycle Stages**

|Stage|Description|MIPS Example|
|---|---|---|
|**IF**|Fetch instruction from memory|Fetch `lw $t0, 0($t1)`|
|**ID**|Decode instruction & read registers|Identify as **Load Word**, read `$t1`|
|**EX**|Execute ALU operation|Compute address: `$t1 + 0`|
|**MEM**|Access memory (Read/Write)|Load data from memory|
|**WB**|Write result to register|Store data in `$t0`|

---

### **Pipeline Execution**

MIPS processors use **pipelining** to execute multiple instructions simultaneously by overlapping the execution stages.

---

## Pipelining

Pipelining is a technique used in MIPS processors to improve performance by **overlapping** the execution of multiple instructions. This allows the CPU to execute one instruction per cycle **after the pipeline is filled**.

---

### **1. The Five Stages of MIPS Pipeline**

Each instruction in MIPS goes through **five stages**, and pipelining enables **different instructions** to be in different stages simultaneously.

|**Stage**|**Description**|**Example (`lw $t0, 0($t1)`)**|
|---|---|---|
|**IF** (Instruction Fetch)|Fetch instruction from memory|Fetch `lw $t0, 0($t1)`|
|**ID** (Instruction Decode)|Decode the instruction & read registers|Identify as **Load Word**, read `$t1`|
|**EX** (Execute / ALU)|Perform ALU operation|Compute memory address `$t1 + 0`|
|**MEM** (Memory Access)|Read/write from memory|Load data from memory|
|**WB** (Write-Back)|Write result to register|Store data in `$t0`|

---

### **2. Pipelining Concept: Overlapping Execution**

Without pipelining, each instruction would finish before the next starts:

```
Cycle: 1   2   3   4   5   6   7   8   9  10
Inst 1: IF  ID  EX  MEM WB
Inst 2:         IF  ID  EX  MEM WB
Inst 3:             IF  ID  EX  MEM WB
```

With pipelining, multiple instructions execute **concurrently**:

```
Cycle: 1   2   3   4   5   6   7   8   9  10
Inst 1: IF  ID  EX  MEM WB
Inst 2:     IF  ID  EX  MEM WB
Inst 3:         IF  ID  EX  MEM WB
Inst 4:             IF  ID  EX  MEM WB
```

- Each stage takes **one cycle**.
- After **five cycles**, a new instruction completes **every cycle**.

---

### **3. Pipeline Hazards (Problems in Pipelining)**

Although pipelining improves efficiency, it introduces **hazards** that can cause incorrect execution.

#### **a. Structural Hazard**

🔴 **Problem:** Hardware conflict when multiple instructions need the same resource (e.g., memory access).  
✅ **Solution:** Use **separate** instruction and data memory (Harvard architecture) or **multi-port memory**.

#### **b. Data Hazard**

🔴 **Problem:** An instruction depends on a previous instruction’s result, but the result isn’t ready yet.  
✅ **Solution:**

1. **Forwarding (Data Forwarding)**: The result is sent directly to dependent instructions.
2. **Pipeline Stall (Interlock)**: Insert a delay (`NOP`) until the data is available.

Example (without forwarding):

```assembly
lw   $t0, 0($t1)  # Load word into $t0
add  $t2, $t0, $t3  # $t2 depends on $t0, but $t0 isn't ready yet!
```

The `add` instruction has to **wait** until `lw` finishes.

#### **c. Control Hazard**

🔴 **Problem:** Branch instructions (`beq`, `bne`, `j`) affect the PC, making it uncertain which instruction to fetch next.  
✅ **Solution:**

1. **Branch Prediction**: Predict the outcome of branches to keep the pipeline full.
2. **Branch Delay Slot**: Execute the next instruction before taking the branch.

Example:

```assembly
beq  $t0, $t1, LABEL  # If equal, jump to LABEL
add  $t2, $t3, $t4     # This executes even if we branch (Delay Slot)
```

This ensures useful work is done while waiting.

---

### **4. Performance Improvement**

- Without pipelining: **Each instruction takes 5 cycles** → **CPI (Cycles per Instruction) = 5**.
- With pipelining: **One instruction completes every cycle after the pipeline is filled** → **CPI ≈ 1**.

🔹 **Ideal Speedup** = **5×**, but real-world performance is lower due to hazards.

---

### **5. Superpipelining & Superscalar Execution**

- **Superpipelining**: More than 5 stages (e.g., 10-stage pipeline).
- **Superscalar**: Multiple instructions executed per cycle using multiple pipelines.

---

## Pseudo-instruction

#### **What is a Pseudo-Instruction?**

A **pseudo-instruction** is an assembly-level shortcut that makes coding easier. Unlike **real instructions** (which have direct machine code representations), pseudo-instructions are translated by the assembler into one or more actual MIPS instructions.

---

### **Examples of Common Pseudo-Instructions**

| **Pseudo-Instruction** | **Equivalent MIPS Instructions**                                                               | **Description**                          |
| ---------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------- |
| `move $d, $s`          | `add $d, $s, $zero`                                                                            | Copies the value of `$s` into `$d`       |
| `li $d, imm`           | `ori $d, $zero, imm` _(for small imm)_ `lui $d, upper` + `ori $d, $d, lower` _(for large imm)_ | Loads an immediate value into a register |
| `la $d, label`         | `lui $d, upper` + `ori $d, $d, lower`                                                          | Loads the address of a label             |
| `bgt $s, $t, label`    | `slt $at, $t, $s` `bne $at, $zero, label`                                                      | Branches if `$s > $t`                    |
| `blt $s, $t, label`    | `slt $at, $s, $t` `bne $at, $zero, label`                                                      | Branches if `$s < $t`                    |
| `bge $s, $t, label`    | `slt $at, $s, $t` `beq $at, $zero, label`                                                      | Branches if `$s >= $t`                   |
| `ble $s, $t, label`    | `slt $at, $t, $s` `beq $at, $zero, label`                                                      | Branches if `$s <= $t`                   |
| `push $s`              | `addi $sp, $sp, -4` `sw $s, 0($sp)`                                                            | Stores a register on the stack           |
| `pop $d`               | `lw $d, 0($sp)` `addi $sp, $sp, 4`                                                             | Restores a register from the stack       |

---

### **Example 1: Using `move` and `li`**

```assembly
      .text
      .globl main
main:
      li   $t0, 42      # Load immediate value 42 into $t0
      move $t1, $t0     # Copy $t0 into $t1
      li   $v0, 1       # Print integer syscall
      move $a0, $t1     # Set argument for printing
      syscall           # Print 42
      li   $v0, 10      # Exit
      syscall
```

**Assembler Translation**

```assembly
      ori  $t0, $zero, 42   # li $t0, 42
      add  $t1, $t0, $zero  # move $t1, $t0
```

---

### **Example 2: Using `bgt` and `blt`**

```assembly
      .text
      .globl main
main:
      li   $t0, 10
      li   $t1, 20
      bgt  $t1, $t0, greater
      li   $a0, 0        # Print 0 if false
      j    done

greater:
      li   $a0, 1        # Print 1 if true

done:
      li   $v0, 1        # Print integer syscall
      syscall
      li   $v0, 10       # Exit
      syscall
```

**Assembler Translation**

```assembly
      slt  $at, $t0, $t1
      bne  $at, $zero, greater
```

---

### **Example 3: Using `push` and `pop`**

```assembly
      .text
      .globl main
main:
      li   $t0, 5
      push $t0         # Save $t0 on the stack
      li   $t0, 10
      pop  $t1         # Restore saved value into $t1

      li   $v0, 1      # Print restored value (should print 5)
      move $a0, $t1
      syscall
      li   $v0, 10     # Exit
      syscall
```

**Assembler Translation**

```assembly
      addi $sp, $sp, -4
      sw   $t0, 0($sp)   # push $t0

      lw   $t1, 0($sp)
      addi $sp, $sp, 4   # pop $t1
```

---

### **Why Use Pseudo-Instructions?**

- They **simplify** assembly programming.
- They **reduce** the number of instructions you need to write.
- The **assembler** automatically converts them into valid MIPS instructions.

---

# Registers

MIPS (Microprocessor without Interlocked Pipeline Stages) has **32 general-purpose registers** and a few special-purpose registers. Each register has a specific convention or purpose. Here’s a breakdown:

## **General-Purpose Registers (GPRs)**

| Register      | Number | Name/Alias          | Usage                                                                |
| ------------- | ------ | ------------------- | -------------------------------------------------------------------- |
| **$zero**     | 0      | Zero Register       | Always contains 0 (read-only)                                        |
| **$at**       | 1      | Assembler Temporary | Reserved for assembler (not recommended for use)                     |
| **$v0, $v1**  | 2-3    | Return Values       | Stores function return values                                        |
| **$a0 - $a3** | 4-7    | Arguments           | Stores function arguments                                            |
| **$t0 - $t7** | 8-15   | Temporary Registers | Used for temporary calculations, not preserved across function calls |
| **$s0 - $s7** | 16-23  | Saved Registers     | Preserved across function calls (callee-saved)                       |
| **$t8, $t9**  | 24-25  | More Temporaries    | Same as $t0-$t7 but additional temporary registers                   |
| **$k0, $k1**  | 26-27  | Kernel Registers    | Reserved for OS kernel (not for general use)                         |
| **$gp**       | 28     | Global Pointer      | Points to static data                                                |
| **$sp**       | 29     | Stack Pointer       | Points to top of stack                                               |
| **$fp**       | 30     | Frame Pointer       | Optional, used for stack frames                                      |
| **$ra**       | 31     | Return Address      | Stores the return address for function calls                         |

---

### **Calling Convention**

- **Caller-saved registers:** `$t0-$t9`, `$a0-$a3`, `$v0-$v1`
- **Callee-saved registers:** `$s0-$s7`, `$sp`, `$fp`, `$ra` (must be preserved by the called function)

- `$t0-$t9`: **Caller-saved**, can be overwritten.
- `$s0-$s7`: **Callee-saved**, must be preserved.
- `$ra`: Used for function calls (`jal`).
- `$sp`: Must always point to the top of the stack.

### Caller-Saved vs. Callee-Saved Registers

In assembly programming and low-level function calls, **caller-saved** and **callee-saved** registers are conventions that determine **who is responsible for saving and restoring the values of registers** during a function call. These conventions are essential for managing the state of registers and ensuring that data is not unintentionally overwritten when functions are called.

---

#### Caller-Saved Registers

- **Definition**: Caller-saved registers (also known as **volatile** or **call-clobbered** registers) are registers that the **caller** (the function making the call) is responsible for saving and restoring if it needs their values after the function call.
- **Responsibility**: Before making a function call, the caller must save the values of these registers (if they are still needed) to memory or other registers. After the function call, the caller can restore the saved values.
- **Usage**: Caller-saved registers are typically used for temporary or intermediate values that are not needed after the function call. They are efficient for short-lived data because the callee does not need to save or restore them.
- **Example**: If a function `A` calls function `B`, and `A` is using a caller-saved register (e.g., `R1`), `A` must save the value of `R1` before calling `B` and restore it afterward if it still needs the value.

---

#### Callee-Saved Registers

- **Definition**: Callee-saved registers (also known as **non-volatile** or **call-preserved** registers) are registers that the **callee** (the function being called) is responsible for saving and restoring if it modifies them during its execution.
- **Responsibility**: The callee must save the values of these registers at the start of the function (prologue) and restore them before returning to the caller (epilogue). This ensures that the caller's values remain intact.
- **Usage**: Callee-saved registers are typically used for values that need to persist across function calls, such as loop counters or variables that are used throughout a program.
- **Example**: If a function `B` modifies a callee-saved register (e.g., `R2`), it must save the original value of `R2` at the start of the function and restore it before returning to the caller.

---

## **Special-Purpose Registers in MIPS**

MIPS has **special-purpose registers** used for handling **exceptions, program control, and system operations**. These registers are not directly accessible with standard instructions and require **privileged** instructions.

---

### **1. Program Control Registers**

|**Register**|**Name**|**Description**|
|---|---|---|
|**$pc**|Program Counter|Holds the address of the next instruction|
|**$hi**|High Register|Stores the upper 32 bits of multiplication or division results|
|**$lo**|Low Register|Stores the lower 32 bits of multiplication or division results|

🔹 **Example (Multiply and Move Result):**

```assembly
mul  $t0, $t1, $t2   # Multiply $t1 * $t2, result stored in $hi and $lo
mflo $t3             # Move lower 32 bits from $lo to $t3
mfhi $t4             # Move upper 32 bits from $hi to $t4
```

---

### **2. Exception and Interrupt Handling Registers** (COP0 - Coprocessor 0)

| **Register**  | **Name**            | **Description**                             |
| ------------- | ------------------- | ------------------------------------------- |
| **$status**   | Status Register     | Controls interrupt enabling/disabling       |
| **$cause**    | Cause Register      | Stores exception type                       |
| **$epc**      | Exception PC        | Stores return address after an exception    |
| **$badvaddr** | Bad Virtual Address | Stores the address that caused an exception |

🔹 **Exception Handling Example:**

```assembly
mfc0 $t0, $cause    # Move exception cause to $t0
mfc0 $t1, $epc      # Move exception return address to $t1
```

---

### **3. Floating-Point Registers (Coprocessor 1 - COP1)**

MIPS has **32 floating-point registers (\$f0-\$f31)**, used for floating-point arithmetic. These registers are separate from general-purpose registers.

| **Register**   | **Usage**          |
| -------------- | ------------------ |
| **\$f0-$f2**   | Return values      |
| **\$f4-$f10**  | Temporary          |
| **\$f12-$f14** | Function arguments |
| **\$f16-$f18** | Temporary          |
| **\$f20-$f30** | Saved registers    |


🔹 **Floating-Point Addition Example:**

```assembly
lwc1 $f1, 0($a0)   # Load float from memory
lwc1 $f2, 4($a0)
add.s $f3, $f1, $f2 # Floating-point addition
swc1 $f3, 8($a0)   # Store result back to memory
```

---

## **Register Usage in MIPS Instructions**

MIPS uses **register-based** instructions, meaning most operations involve registers rather than direct memory access. Below is a breakdown of how registers are used in different types of instructions.

---

### **1. Arithmetic and Logical Instructions**

These instructions operate on **general-purpose registers**.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`add`|Addition|`add $t0, $t1, $t2` → `$t0 = $t1 + $t2`|
|`sub`|Subtraction|`sub $t0, $t1, $t2` → `$t0 = $t1 - $t2`|
|`and`|Bitwise AND|`and $t0, $t1, $t2` → `$t0 = $t1 & $t2`|
|`or`|Bitwise OR|`or $t0, $t1, $t2` → `$t0 = $t1|
|`sll`|Shift Left|`sll $t0, $t1, 2` → `$t0 = $t1 << 2`|
|`srl`|Shift Right|`srl $t0, $t1, 2` → `$t0 = $t1 >> 2`|

🔹 **Registers Used:**

- `$t0, $t1, $t2`: **Temporary registers** (caller-saved).
- **Only registers are used** (no direct memory access).

---

### **2. Data Transfer Instructions**

These instructions move data between registers and memory.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`lw`|Load Word|`lw $t0, 0($s1)` → `$t0 = Memory[$s1 + 0]`|
|`sw`|Store Word|`sw $t0, 4($s1)` → `Memory[$s1 + 4] = $t0`|
|`lb`|Load Byte|`lb $t0, 0($s1)` → `$t0 = Memory[$s1 + 0] (byte)`|
|`sb`|Store Byte|`sb $t0, 4($s1)` → `Memory[$s1 + 4] = $t0 (byte)`|

🔹 **Registers Used:**

- `$t0, $s1`: **Source/destination register**.
- **Memory addresses are computed using registers** (`base + offset`).

---

### **3. Branch and Jump Instructions**

Used for **decision-making and control flow**.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`beq`|Branch if Equal|`beq $t0, $t1, label`|
|`bne`|Branch if Not Equal|`bne $t0, $t1, label`|
|`j`|Jump|`j target`|
|`jal`|Jump and Link|`jal function` (stores return address in `$ra`)|
|`jr`|Jump Register|`jr $ra` (return from function)|

🔹 **Registers Used:**

- `$t0, $t1`: **Comparison registers**.
- `$ra`: Stores **return address** in function calls.

---

### **4. Special Register Instructions**

Some operations use **special-purpose registers**.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`mfhi`|Move from HI|`mfhi $t0` (moves HI register value to $t0)|
|`mflo`|Move from LO|`mflo $t0` (moves LO register value to $t0)|
|`mtc0`|Move to COP0|`mtc0 $t0, $status` (move $t0 to status register)|

🔹 **Registers Used:**

- `$hi, $lo`: Store multiplication/division results.
- **Coprocessor registers (`$status, $cause`) require special instructions.**

---

## **Register Transfer Language (RTL)**

**Register Transfer Language (RTL)** is a way to describe **operations at the register level**. It represents how data moves between registers and memory in a CPU during execution.

---

### **1. RTL Notation**

In RTL, operations are described as **data transfers and computations** using registers, memory, and control signals.

🔹 **General RTL Format:**

```plaintext
Destination ← Source
```

- The **destination** is a register or memory location.
- The **source** is a register, memory location, or computed value.

🔹 **Example:**

```plaintext
R1 ← R2 + R3
```

This means **register R1 gets the sum of R2 and R3**.

---

### **2. RTL for MIPS Instructions**

#### **Arithmetic Instructions**

|**MIPS Instruction**|**RTL Representation**|
|---|---|
|`add $t0, $t1, $t2`|`$t0 ← $t1 + $t2`|
|`sub $t0, $t1, $t2`|`$t0 ← $t1 - $t2`|
|`and $t0, $t1, $t2`|`$t0 ← $t1 AND $t2`|
|`or $t0, $t1, $t2`|`$t0 ← $t1 OR $t2`|
|`sll $t0, $t1, 2`|`$t0 ← $t1 << 2`|
|`srl $t0, $t1, 2`|`$t0 ← $t1 >> 2`|

🔹 **Example:**

```plaintext
add $t0, $t1, $t2
$t0 ← $t1 + $t2
```

---

#### **Memory Instructions**

|**MIPS Instruction**|**RTL Representation**|
|---|---|
|`lw $t0, 4($s1)`|`$t0 ← Memory[$s1 + 4]`|
|`sw $t0, 4($s1)`|`Memory[$s1 + 4] ← $t0`|
|`lb $t0, 4($s1)`|`$t0 ← Memory[$s1 + 4] (byte)`|
|`sb $t0, 4($s1)`|`Memory[$s1 + 4] ← $t0 (byte)`|

🔹 **Example:**

```plaintext
lw $t0, 4($s1)
$t0 ← Memory[$s1 + 4]
```

---

#### **Branch and Jump Instructions**

|**MIPS Instruction**|**RTL Representation**|
|---|---|
|`beq $t0, $t1, LABEL`|`if ($t0 = $t1) then PC ← LABEL`|
|`bne $t0, $t1, LABEL`|`if ($t0 ≠ $t1) then PC ← LABEL`|
|`j LABEL`|`PC ← LABEL`|
|`jal FUNCTION`|`$ra ← PC + 4; PC ← FUNCTION`|
|`jr $ra`|`PC ← $ra`|

🔹 **Example:**

```plaintext
beq $t0, $t1, LABEL
if ($t0 = $t1) then PC ← LABEL
```

---

#### **Multiplication and Division**

|**MIPS Instruction**|**RTL Representation**|
|---|---|
|`mul $t0, $t1, $t2`|`($hi, $lo) ← $t1 × $t2`|
|`div $t0, $t1`|`$lo ← $t0 ÷ $t1, $hi ← $t0 mod $t1`|
|`mfhi $t0`|`$t0 ← $hi`|
|`mflo $t0`|`$t0 ← $lo`|

🔹 **Example:**

```plaintext
mul $t0, $t1, $t2
($hi, $lo) ← $t1 × $t2
```

---

### **3. RTL for Instruction Execution Cycle**

Each instruction in MIPS follows the **Instruction Execution Cycle**, typically consisting of these steps:

1. **Instruction Fetch**
    
    ```plaintext
    IR ← Memory[PC]   // Load instruction
    PC ← PC + 4       // Move to next instruction
    ```
    
2. **Instruction Decode**
    
    ```plaintext
    Decode IR and identify operands
    ```
    
3. **Execute (ALU Operations)**
    
    ```plaintext
    ALU_Result ← Operand1 OP Operand2
    ```
    
4. **Memory Access (if needed)**
    
    ```plaintext
    if (load) then Register ← Memory[Address]
    if (store) then Memory[Address] ← Register
    ```
    
5. **Write Back**
    
    ```plaintext
    Register ← ALU_Result
    ```

---

# Assembly Language

## **Basic Syntax and Structure**

MIPS assembly language follows a simple syntax with a structured format. It consists of **directives, labels, instructions, and comments** that define the program's execution.

---

### **1. Structure of a MIPS Program**

A typical MIPS assembly program consists of two main sections:

#### **a. Data Section (`.data`)**

- Defines **variables, arrays, and strings** used in the program.
- Uses directives like `.word`, `.byte`, and `.asciiz`.

#### **b. Text Section (`.text`)**

- Contains the **actual instructions** executed by the CPU.
- The `main` label is used as the program's entry point.

**Example:**

```assembly
.data
message: .asciiz "Hello, MIPS!\n"  # String in memory
value:   .word 10                   # Integer variable

.text
.globl main
main:
    li   $v0, 4          # Load syscall code for print string
    la   $a0, message    # Load address of string
    syscall              # Print message

    li   $v0, 10         # Exit program
    syscall
```

---

### **2. Basic Syntax Rules**

- **Instructions:** Use **opcode** followed by **operands** (e.g., `add $t0, $t1, $t2`).
- **Registers:** Use **\$** followed by a register name (e.g., `$t0, $s1, $a0`).
- **Comments:** Start with `#` (e.g., `# This is a comment`).
- **Labels:** End with `:` (e.g., `loop:`).
- **Directives:** Start with `.` (e.g., `.data, .text, .word`).

---

### **3. MIPS Instructions Format**

MIPS uses three main instruction formats:

#### **a. R-Type (Register Format)**

- Used for **arithmetic and logical operations**.
- Format: `opcode rd, rs, rt`
- Example:
    
    ```assembly
    add $t0, $t1, $t2  # $t0 = $t1 + $t2
    sub $t3, $t4, $t5  # $t3 = $t4 - $t5
    ```


#### **b. I-Type (Immediate Format)**

- Used for **memory access, branches, and arithmetic with constants**.
- Format: `opcode rt, rs, immediate`
- Example:
    
    ```assembly
    addi $t0, $t1, 5   # $t0 = $t1 + 5
    lw   $t2, 8($s1)   # Load word from memory
    ```
    

#### **c. J-Type (Jump Format)**

- Used for **jumping to different parts of the program**.
- Format: `opcode address`
- Example:
    
    ```assembly
    j   label   # Jump to label
    jal function  # Jump to function (store return address)
    ```
    

---

### **4. Common Directives**

| **Directive**    | **Description**                       |
| ---------------- | ------------------------------------- |
| `.data`          | Defines the data section (variables). |
| `.text`          | Defines the code section.             |
| `.globl main`    | Declares `main` as a global label.    |
| `.word n`        | Reserves space for an integer (`n`).  |
| `.byte n`        | Reserves space for a byte (`n`).      |
| `.asciiz "text"` | Stores a null-terminated string.      |

---

### **5. Example: Arithmetic and Loops in MIPS**

```assembly
.data
msg: .asciiz "Sum: "

.text
.globl main
main:
    li   $t0, 10       # Load first number
    li   $t1, 20       # Load second number
    add  $t2, $t0, $t1 # Add numbers and store in $t2

    li   $v0, 4        # Print string
    la   $a0, msg
    syscall

    li   $v0, 1        # Print integer
    move $a0, $t2
    syscall

    li   $v0, 10       # Exit program
    syscall
```

📌 **Explanation:**

- Loads `10` into `$t0` and `20` into `$t1`.
- Adds them and stores the result in `$t2`.
- Prints `"Sum: "` followed by the computed value.

---

## Directives

In **MIPS assembly language**, **directives** are special instructions that tell the assembler how to handle data, memory allocation, and program structure. They do not generate machine code but help define program behavior. Directives typically start with a **dot (`.`)** and are not executed at runtime.

#### **Data Section Directives**
These directives are used to define and allocate data in memory.

- **`.data`** – Marks the beginning of the data section (for variables).
- **`.text`** – Marks the beginning of the code section (for instructions).
- **`.globl <label>`** – Declares a label as global, making it accessible from other files.

#### **Data Allocation Directives**
These directives allocate memory in the `.data` section.

- **`.word <values>`** – Allocates one or more 32-bit words.
  ```assembly
  .word 10, 20, 30  # Allocates three 32-bit integers
  ```
- **`.half <values>`** – Allocates one or more 16-bit halfwords.
- **`.byte <values>`** – Allocates one or more 8-bit bytes.
- **`.space <size>`** – Reserves a block of memory (in bytes).
  ```assembly
  .space 40  # Reserves 40 bytes
  ```
- **`.asciiz "<string>"`** – Stores a null-terminated string.
  ```assembly
  .asciiz "Hello, World!"  # Stores string with a null terminator
  ```
- **`.ascii "<string>"`** – Stores a string **without** a null terminator.

#### **Text Section Directives**
- **`.text`** – Specifies the start of the program code section.
- **`.align <n>`** – Aligns data on a `2^n` boundary.
  ```assembly
  .align 2  # Aligns the next data on a multiple of 4 bytes
  ```

#### **Macro and Constant Definition Directives**
- **`.equ <name>, <value>`** – Defines a constant.
  ```assembly
  PI .equ 3.14159  # PI is now a constant
  ```
- **`.set`** – Controls assembler options (e.g., enabling/disabling certain optimizations).

**Example Usage**
```assembly
.data
message: .asciiz "Hello, MIPS!"

.text
.globl main
main:
    li $v0, 4          # Print string syscall
    la $a0, message    # Load address of message
    syscall            # Call kernel

    li $v0, 10         # Exit syscall
    syscall
```

**Summary**
MIPS directives help in organizing code, defining memory layout, and managing data. They are **processed at assembly time** and are **not actual machine instructions**.

---

## Labels

In **MIPS assembly**, **labels** are **identifiers** that mark specific locations in code or data. They serve as **references** for jump instructions, function calls, and data locations.

---

### **Label Syntax**  
- A label is a **user-defined name** followed by a colon (`:`).  
- It can be used in both the **data section** (for variables) and the **text section** (for instructions).  

**Example:**  
```assembly
myLabel:  # A label named "myLabel"
```

---

### **Labels in the `.data` Section (Variable Labels)**  
Labels can be used to name memory locations storing data.  

**Example:**  
```assembly
.data
message:  .asciiz "Hello, MIPS!"  # Label "message" refers to this string
```
- `message` is a label pointing to `"Hello, MIPS!"` in memory.
- We can reference `message` in the **text section** using `la` (load address).  

```assembly
.text
main:
    li $v0, 4          # Print string syscall
    la $a0, message    # Load address of "message" into $a0
    syscall
```

---

### **Labels in the `.text` Section (Control Flow Labels)**  
Labels are commonly used for loops, conditionals, and function definitions.

#### **Jump Labels**
Labels mark **jump destinations** for branching instructions.

**Example: Infinite Loop**
```assembly
.text
main:
    j main  # Jump to "main", causing an infinite loop
```
- `j main` makes the program jump back to `main`.

**Loop Example**
```assembly
.text
.globl main
main:
    li $t0, 5         # $t0 = 5
loop:
    beq $t0, $zero, end  # If $t0 == 0, jump to "end"
    sub $t0, $t0, 1      # $t0 -= 1
    j loop               # Jump back to "loop"
end:
    li $v0, 10        # Exit
    syscall
```
- `loop:` marks the start of the loop.
- `beq` checks if `$t0` is 0; if true, it jumps to `end:`.
- `j loop` makes the program repeat.

---

### **Labels for Function Definitions**  
In MIPS, labels are used to define function entry points.

**Example: Function Call**
```assembly
.text
.globl main

main:
    jal myFunction   # Jump to "myFunction"
    li $v0, 10       # Exit syscall
    syscall

myFunction:
    li $a0, 42
    jr $ra           # Return to caller
```
- `myFunction:` marks the function start.
- `jal myFunction` jumps to `myFunction`, storing the return address in `$ra`.
- `jr $ra` returns to the caller.

---

**Summary**

| Feature | Description |
|---------|------------|
| **Label Syntax** | `labelName:` (must end with `:`) |
| **Data Labels** | Name memory locations (e.g., `message: .asciiz "Hello"`) |
| **Jump Labels** | Mark destinations for `j`, `beq`, `bne`, etc. |
| **Loop Labels** | Used for iteration (`loop: ... j loop`) |
| **Function Labels** | Define subroutines (`myFunction: ... jr $ra`) |

Labels **improve code readability** and **make jumps/branches more manageable**.

---

### Similarities With Pointers  

#### Both Represent Memory Addresses  
- A **label** in MIPS represents a memory location (either an instruction or data).  
- A **pointer** in C is a variable that stores a memory address.  

**Example:**  
- **MIPS Label (Data Addressing)**  
  ```assembly
  .data
  message: .asciiz "Hello"  # "message" is an address in memory

  .text
  la $a0, message   # Load the address of "message" into $a0
  ```
- **C Pointer Equivalent**  
  ```c
  char message[] = "Hello";
  char *ptr = message;  // "ptr" holds the address of "message"
  ```  

#### Can Be Used to Jump to Code (Like Function Pointers)  
- A **label** in MIPS marks an instruction address.  
- A **function pointer** in C stores an address of a function.  

**Example:**  
- **MIPS Function Call Using a Label**  
  ```assembly
  jal myFunction   # Jump to function (like calling a function pointer)
  ```
- **C Function Pointer**  
  ```c
  void myFunction() { /* Code */ }
  void (*funcPtr)() = myFunction;
  funcPtr();  // Calls the function
  ```  

### Differences  With Pointers

| Feature | MIPS Labels | C Pointers |
|---------|------------|------------|
| **Type** | Fixed memory address | Variable storing an address |
| **Modification** | Cannot be changed | Can be reassigned to point elsewhere |
| **Usage** | Used for jumps (code) and data labels | Used to reference memory dynamically |
| **Dereferencing** | Implicit (loading/saving) | Explicit (`*ptr`) |

**Example Difference**  

- **MIPS Label (Fixed Address)**  
  ```assembly
  la $t0, data   # $t0 holds the address of "data"
  ```
  - The address of `data` **cannot be reassigned**.  

- **C Pointer (Dynamic Address)**  
  ```c
  int a = 10, b = 20;
  int *ptr = &a;  // ptr points to a
  ptr = &b;       // ptr now points to b
  ```
  - `ptr` can be reassigned to a different address.  

**Conclusion**  

- **Labels in MIPS are more like fixed memory addresses** (they don’t change).  
- **Pointers in C are variables that store addresses and can be reassigned dynamically.**  
- **Labels are closer to function names or array names in C, which act as fixed addresses.**


---

## **Control Structures (Loops and Conditionals)**

MIPS assembly uses **branches and jumps** to implement control structures like loops and conditionals. Since MIPS is a low-level language, there are no built-in `if`, `while`, or `for` statements like in high-level languages. Instead, these structures are implemented using **branch instructions** (`beq`, `bne`, `blt`, `bgt`, etc.) and **jump instructions** (`j`, `jal`, `jr`).

---

### **1. Conditional Statements (`if`, `if-else`)**

#### **a. `if` Statement**

**High-Level Equivalent:**

```c
if (a == b) {
    do_something();
}
```

**MIPS Implementation:**

```assembly
    lw   $t0, a       # Load a into $t0
    lw   $t1, b       # Load b into $t1
    beq  $t0, $t1, if_body  # If a == b, jump to if_body

    j end_if          # Skip if block if condition is false

if_body:
    # Code inside if block
    li   $v0, 1
    li   $a0, 100     # Print 100
    syscall 

end_if:
```

---

#### **b. `if-else` Statement**

**High-Level Equivalent:**

```c
if (a < b) {
    do_something();
} else {
    do_something_else();
}
```

**MIPS Implementation:**

```assembly
    lw   $t0, a       
    lw   $t1, b       
    blt  $t0, $t1, if_body  # If a < b, jump to if_body

    j else_body       # Else, jump to else_body

if_body:
    li   $v0, 1
    li   $a0, 200     # Print 200
    syscall
    j end_if

else_body:
    li   $v0, 1
    li   $a0, 300     # Print 300
    syscall

end_if:
```

---

### **2. Loops (`while`, `for`, `do-while`)**

#### **a. `while` Loop**

**High-Level Equivalent:**

```c
while (i < 10) {
    do_something();
    i++;
}
```

**MIPS Implementation:**

```assembly
    li   $t0, 0       # i = 0
    li   $t1, 10      # limit = 10

while_loop:
    bge  $t0, $t1, end_while  # Exit if i >= 10

    # Code inside while loop
    li   $v0, 1
    move $a0, $t0    # Print i
    syscall

    addi $t0, $t0, 1  # i++

    j while_loop      # Repeat loop

end_while:
```

---

#### **b. `for` Loop**

**High-Level Equivalent:**

```c
for (i = 0; i < 5; i++) {
    do_something();
}
```

**MIPS Implementation:**

```assembly
    li   $t0, 0       # i = 0
    li   $t1, 5       # limit = 5

for_loop:
    bge  $t0, $t1, end_for  # Exit if i >= 5

    # Code inside for loop
    li   $v0, 1
    move $a0, $t0    # Print i
    syscall

    addi $t0, $t0, 1  # i++

    j for_loop        # Repeat loop

end_for:
```

---

#### **c. `do-while` Loop**

**High-Level Equivalent:**

```c
do {
    do_something();
    i++;
} while (i < 5);
```

**MIPS Implementation:**

```assembly
    li   $t0, 0       # i = 0
    li   $t1, 5       # limit = 5

do_while:
    # Code inside loop
    li   $v0, 1
    move $a0, $t0    # Print i
    syscall

    addi $t0, $t0, 1  # i++

    blt  $t0, $t1, do_while  # Repeat if i < 5
```

---

### **3. Switch-Case in MIPS**

Since MIPS does not have a built-in `switch-case` structure, we implement it using **jump tables**.

**High-Level Equivalent:**

```c
switch (x) {
    case 1: do_something(); break;
    case 2: do_something_else(); break;
    default: default_case();
}
```

**MIPS Implementation:**

```assembly
    lw   $t0, x       # Load value of x

    beq  $t0, 1, case_1
    beq  $t0, 2, case_2
    j default_case

case_1:
    li   $v0, 1
    li   $a0, 100     # Print 100
    syscall
    j end_switch

case_2:
    li   $v0, 1
    li   $a0, 200     # Print 200
    syscall
    j end_switch

default_case:
    li   $v0, 1
    li   $a0, 300     # Print 300
    syscall

end_switch:
```

---

## **Functions and Procedures in MIPS**

In MIPS assembly, functions (also called procedures or subroutines) are implemented using the **Jump and Link (JAL)** instruction, along with the **Jump Register (JR)** instruction for returning. These allow structured and reusable code execution.

---

### **1. Calling a Function**

MIPS functions use the following conventions:

- **`$a0 - $a3`** → Arguments (input values)
- **`$v0 - $v1`** → Return values
- **`$ra` (Return Address Register)** → Stores the return address after calling a function

The **basic structure** of a function call:

```assembly
    jal function_name  # Jump to function and save return address
    # Code continues after function returns
function_name:
    # Function code here
    jr $ra            # Return to caller
```

---

### **2. Function with No Parameters and No Return Value**

This function simply prints a message.

**Example: Print "Hello, World!"**

```assembly
      .data
msg:  .asciiz "Hello, World!\n"

      .text
      .globl main
main:
      jal print_hello  # Call function
      li  $v0, 10      # Exit program
      syscall

print_hello:
      li  $v0, 4       # Print string syscall
      la  $a0, msg     # Load address of message
      syscall
      jr  $ra          # Return
```

---

### **3. Function with Parameters**

To pass arguments, we use registers `$a0 - $a3`.

**Example: Print an Integer**

```assembly
      .text
      .globl main
main:
      li   $a0, 42     # Argument: number to print
      jal  print_int   # Call function
      li   $v0, 10     # Exit program
      syscall

print_int:
      li   $v0, 1      # Print integer syscall
      syscall
      jr   $ra         # Return
```

---

### **4. Function with a Return Value**

To return a value, we use registers `$v0 - $v1`.

**Example: Return the Square of a Number**

```assembly
      .text
      .globl main
main:
      li   $a0, 5      # Argument: 5
      jal  square      # Call function
      move $a0, $v0    # Move return value to $a0 for printing
      li   $v0, 1      # Print result
      syscall
      li   $v0, 10     # Exit program
      syscall

square:
      mul  $v0, $a0, $a0  # Return a0 * a0
      jr   $ra            # Return
```

---

### **5. Recursive Function**

MIPS supports recursion, just like high-level languages.

**Example: Factorial Using Recursion**

```assembly
      .text
      .globl main
main:
      li   $a0, 5      # Compute factorial(5)
      jal  factorial   # Call function
      move $a0, $v0    # Move return value for printing
      li   $v0, 1      # Print integer
      syscall
      li   $v0, 10     # Exit
      syscall

factorial:
      blez $a0, base_case  # If n <= 0, return 1
      addi $sp, $sp, -8    # Allocate stack space
      sw   $ra, 4($sp)     # Save return address
      sw   $a0, 0($sp)     # Save argument

      addi $a0, $a0, -1    # n - 1
      jal  factorial       # Recursive call

      lw   $a0, 0($sp)     # Restore argument
      lw   $ra, 4($sp)     # Restore return address
      addi $sp, $sp, 8     # Deallocate stack space

      mul  $v0, $a0, $v0   # Multiply n * factorial(n-1)
      jr   $ra             # Return

base_case:
      li   $v0, 1          # Return 1 for factorial(0)
      jr   $ra
```

---

### **6. Function with More Than Four Parameters**

Let’s say we want to sum **five numbers**:

```assembly
      .text
      .globl main
main:
      li   $a0, 10        # First number
      li   $a1, 20        # Second number
      li   $a2, 30        # Third number
      li   $a3, 40        # Fourth number

      li   $t0, 50        # Fifth number (can’t fit in $a0-$a3)

      # Push the fifth argument onto the stack
      addi $sp, $sp, -4   # Allocate space on the stack
      sw   $t0, 0($sp)    # Store $t0 on the stack

      jal  sum_five       # Call the function

      # Clean up the stack (optional)
      addi $sp, $sp, 4

      # Print result
      move $a0, $v0
      li   $v0, 1
      syscall

      # Exit
      li   $v0, 10
      syscall

sum_five:
      # Access the fifth argument from the stack
      lw   $t0, 0($sp)    # Load the fifth argument into $t0

      # Sum all five numbers
      add  $t1, $a0, $a1  # t1 = a0 + a1
      add  $t1, $t1, $a2  # t1 = t1 + a2
      add  $t1, $t1, $a3  # t1 = t1 + a3
      add  $v0, $t1, $t0  # v0 = t1 + t0 (fifth argument)

      jr   $ra            # Return to caller
```

---

**Explanation:**

- **Stack Usage:**
    - We used the **stack** to pass the **fifth argument** (`50`).
    - **Before** calling the function, we adjusted the stack pointer (`$sp`) to allocate space and stored the fifth argument with `sw $t0, 0($sp)`.
    - **Inside the function**, we retrieved this value using `lw $t0, 0($sp)`.
- **Why Use the Stack?**
    - `$a0 - $a3` can hold only **four arguments**. For more, the stack provides extra space.
    - The stack is also useful for **saving registers** if a function needs to modify them (not shown here but common in more complex scenarios).
- **Stack Pointer ($sp):**
    - Grows **downwards** (toward lower memory addresses).
    - **Allocate** space: `addi $sp, $sp, -4`.
    - **Deallocate** space: `addi $sp, $sp, 4`.

---
### **7. Saving Registers on the Stack**

If a function modifies **saved registers** (`$s0 - $s7`) or the **return address ($ra)**, it must **store them on the stack** before making changes.

```assembly
      .text
      .globl main
main:
      li   $s0, 5       # Store 5 in $s0
      li   $s1, 10      # Store 10 in $s1
      jal  add_s0_s1    # Call function

      move $a0, $v0     # Move result for printing
      li   $v0, 1       # Print integer
      syscall

      li   $v0, 10      # Exit
      syscall

add_s0_s1:
      # Save registers and return address
      addi $sp, $sp, -12   # Allocate space (3 words: $s0, $s1, $ra)
      sw   $s0, 0($sp)     # Save $s0
      sw   $s1, 4($sp)     # Save $s1
      sw   $ra, 8($sp)     # Save return address

      # Perform the addition
      add  $v0, $s0, $s1   # v0 = s0 + s1

      # Restore registers and return address
      lw   $s0, 0($sp)     # Restore $s0
      lw   $s1, 4($sp)     # Restore $s1
      lw   $ra, 8($sp)     # Restore return address
      addi $sp, $sp, 12    # Deallocate stack space

      jr   $ra             # Return to caller
```

---

**What Changed?**

- **Stack Usage**:
    - Before modifying `$s0, $s1`, we **saved** them on the stack (`sw`).
    - We also saved the **return address** (`$ra`).
    - After computation, we **restored** the saved values before returning.
- **Why Save `$ra`?**
    - If this function calls another function, the return address might get **overwritten**, so we **back it up** on the stack.

---

#### **General Rule for Using the Stack in Functions**

1. **Allocate stack space** for saved registers (`addi $sp, $sp, -X`).
2. **Store registers** (`sw`).
3. **Do computations**.
4. **Restore registers** (`lw`).
5. **Deallocate stack space** (`addi $sp, $sp, X`).
6. **Return properly** (`jr $ra`).

---

# Data Types and Operations

## **Integer and Floating-Point Data Types**

MIPS supports both **integer** and **floating-point** data types, each with dedicated registers and instructions.

---

### **Integer Data Types**

Integers in MIPS are stored in **general-purpose registers** (`$t0 - $t9`, `$s0 - $s7`). The main integer types are:

|**Type**|**Size**|**Usage**|
|---|---|---|
|**Byte**|8-bit|`.byte`|
|**Halfword**|16-bit|`.half`|
|**Word**|32-bit|`.word` (most common)|
|**Doubleword**|64-bit|`.dword` (used in MIPS64)|

**Example: Declaring Integers**

```assembly
      .data
num1: .word 25       # 32-bit integer
num2: .half 10       # 16-bit integer
num3: .byte 5        # 8-bit integer
```

**Example: Integer Arithmetic**

```assembly
      .text
      .globl main
main:
      li   $t0, 10        # Load 10 into $t0
      li   $t1, 20        # Load 20 into $t1
      add  $t2, $t0, $t1  # t2 = t0 + t1 (30)
      li   $v0, 10        # Exit
      syscall
```

---

### **Floating-Point Data Types**

MIPS has a separate **Coprocessor 1 (FPU - Floating Point Unit)** for floating-point operations. Floating-point numbers are stored in **floating-point registers** (`$f0 - $f31`). The main floating-point types are:

|**Type**|**Size**|**Usage**|
|---|---|---|
|**Single-Precision**|32-bit|`.float`|
|**Double-Precision**|64-bit|`.double`|

**Example: Declaring Floating-Point Numbers**

```assembly
      .data
val1: .float  3.14
val2: .double 2.718
```


For floating-point arithmetic, we need to:

1. **Load values** from memory to FPU registers.
2. **Use FPU instructions** (e.g., `add.s` for single-precision, `add.d` for double).
3. **Store results** back in memory.

**Example: Floating-Point Addition**

```assembly
      .data
val1: .float  3.5
val2: .float  2.5
result: .float 0.0

      .text
      .globl main
main:
      # Load floating-point values into registers
      l.s  $f0, val1      
      l.s  $f1, val2

      # Perform addition (single-precision)
      add.s $f2, $f0, $f1  

      # Store result back in memory
      s.s  $f2, result    

      li   $v0, 10        # Exit
      syscall
```

---

### **Key Differences Between Integer and Floating-Point in MIPS**

|**Feature**|**Integer Operations**|**Floating-Point Operations**|
|---|---|---|
|**Registers**|`$t0 - $t9, $s0 - $s7`|`$f0 - $f31` (Coprocessor 1)|
|**Arithmetic**|`add, sub, mul, div`|`add.s, sub.s, mul.s, div.s` (single-precision)|
|**Storage**|`.word, .byte, .half`|`.float, .double`|
|**Usage**|Counters, addresses, whole numbers|Decimal values, scientific calculations|

---

## **Arithmetic and Logical Operations**

MIPS supports **arithmetic** (addition, subtraction, multiplication, division) and **logical** (AND, OR, XOR, shifts) operations using **register-based** instructions.

---

### **Arithmetic Operations**

| **Instruction** | **Operation**                                        | **Example**                              | **Notes**                                      |
| --------------- | ---------------------------------------------------- | ---------------------------------------- | ---------------------------------------------- |
| `add`           | Signed addition (`$d = $s + $t`)                     | `add $t0, $t1, $t2` → `$t0 = $t1 + $t2`  | Traps on overflow                              |
| `addi`          | Signed addition with immediate                       | `addi $t0, $t1, 10` → `$t0 = $t1 + 10`   | Traps on overflow                              |
| `addu`          | Unsigned addition                                    | `addu $t0, $t1, $t2` → `$t0 = $t1 + $t2` | Does not trap on overflow                      |
| `addiu`         | Unsigned addition with immediate                     | `addiu $t0, $t1, 10` → `$t0 = $t1 + 10`  | Does not trap on overflow                      |
| `sub`           | Signed subtraction (`$d = $s - $t`)                  | `sub $t0, $t1, $t2` → `$t0 = $t1 - $t2`  | Traps on overflow                              |
| `subu`          | Unsigned subtraction                                 | `subu $t0, $t1, $t2` → `$t0 = $t1 - $t2` | Does not trap on overflow                      |
| `mul`           | Signed multiplication (`$d = $s * $t`)               | `mul $t0, $t1, $t2` → `$t0 = $t1 * $t2`  | Stores result in `$t0` (alternative to `mult`) |
| `mulo`          | Signed multiplication with overflow check            | `mulo $t0, $t1, $t2`                     | Traps on overflow                              |
| `mulou`         | Unsigned multiplication with overflow check          | `mulou $t0, $t1, $t2`                    | Traps on overflow                              |
| `div`           | Signed division (`$LO = $s / $t`, `$HI = $s % $t`)   | `div $t1, $t2`                           | Quotient in `$LO`, remainder in `$HI`          |
| `divu`          | Unsigned division (`$LO = $s / $t`, `$HI = $s % $t`) | `divu $t1, $t2`                          | Quotient in `$LO`, remainder in `$HI`          |
| `rem`           | Signed remainder (`$d = $s % $t`)                    | `rem $t0, $t1, $t2` → `$t0 = $t1 % $t2`  | Alternative to `mfhi` after `div`              |
| `remu`          | Unsigned remainder (`$d = $s % $t`)                  | `remu $t0, $t1, $t2`                     | Alternative to `mfhi` after `divu`             |

**Example: Integer Arithmetic**

```assembly
      .text
      .globl main
main:
      li   $t1, 10         # Load 10 into $t1
      li   $t2, 5          # Load 5 into $t2
      add  $t0, $t1, $t2   # t0 = t1 + t2 (10 + 5 = 15)
      sub  $t3, $t1, $t2   # t3 = t1 - t2 (10 - 5 = 5)
      
      mul  $t4, $t1, $t2   # t4 = t1 * t2 (10 * 5 = 50)
      div  $t1, $t2        # t1 / t2 → LO = quotient (2), HI = remainder (0)
      mflo $t5             # Move quotient to $t5
      
      li   $v0, 10         # Exit
      syscall
```

---

### **Logical Operations**

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`and`|Bitwise AND|`and $t0, $t1, $t2`|
|`andi`|AND with immediate|`andi $t0, $t1, 0xF`|
|`or`|Bitwise OR|`or $t0, $t1, $t2`|
|`ori`|OR with immediate|`ori $t0, $t1, 0xF`|
|`xor`|Bitwise XOR|`xor $t0, $t1, $t2`|
|`xori`|XOR with immediate|`xori $t0, $t1, 0xF`|
|`nor`|Bitwise NOR (NOT-OR)|`nor $t0, $t1, $t2`|

**Example: Logical Operations**

```assembly
      .text
      .globl main
main:
      li   $t1, 0b1010     # Load 10 (binary 1010) into $t1
      li   $t2, 0b1100     # Load 12 (binary 1100) into $t2
      
      and  $t3, $t1, $t2   # t3 = 1010 AND 1100  → 1000 (8)
      or   $t4, $t1, $t2   # t4 = 1010 OR 1100   → 1110 (14)
      xor  $t5, $t1, $t2   # t5 = 1010 XOR 1100  → 0110 (6)
      nor  $t6, $t1, $t2   # t6 = ~(1010 OR 1100) → 0001 (-15)
      
      li   $v0, 10         # Exit
      syscall
```

---

### **Shift Operations**

|**Instruction**|**Operation**|**Example**|**Notes**|
|---|---|---|---|
|`sll`|Shift left logical (`$d = $t << shamt`)|`sll $t0, $t1, 2` → `$t0 = $t1 << 2`|Zero-filled, shifts left by `shamt` bits|
|`sllv`|Variable shift left logical (`$d = $t << $s`)|`sllv $t0, $t1, $t2` → `$t0 = $t1 << $t2`|Shift amount specified by register `$s`|
|`srl`|Shift right logical (`$d = $t >> shamt`)|`srl $t0, $t1, 2` → `$t0 = $t1 >> 2`|Zero-filled, shifts right by `shamt` bits|
|`srlv`|Variable shift right logical (`$d = $t >> $s`)|`srlv $t0, $t1, $t2` → `$t0 = $t1 >> $t2`|Shift amount specified by register `$s`|
|`sra`|Shift right arithmetic (`$d = $t >> shamt`)|`sra $t0, $t1, 2` → `$t0 = $t1 >> 2`|Sign-extended (preserves sign bit)|
|`srav`|Variable shift right arithmetic (`$d = $t >> $s`)|`srav $t0, $t1, $t2` → `$t0 = $t1 >> $t2`|Shift amount specified by register `$s`, sign-extended|


**Example: Bit Shifting**

```assembly
      .text
      .globl main
main:
      li   $t1, 8          # Load 8 (binary 1000)
      
      sll  $t2, $t1, 2     # Shift left by 2 → 100000 (32)
      srl  $t3, $t1, 2     # Shift right by 2 → 0010 (2)
      
      li   $v0, 10         # Exit
      syscall
```

#### Logical Shift vs Arithmetic Shift

##### **Logical Shift**

- **Definition**: A logical shift moves all bits in a binary number to the left or right, filling the vacated bit positions with zeros.
- **Left Logical Shift**:
    - Each bit is shifted to the left by one position.
    - The least significant bit (LSB) is filled with zero, and the most significant bit (MSB) is discarded.
    - For example, shifting `1010` left results in `0100`.
- **Right Logical Shift**:
    - Each bit is shifted to the right by one position.
    - The LSB is discarded, and the MSB is filled with zero.
    - For example, shifting `1010` right results in `0101`.
- **Use Cases**: Logical shifts are typically used with **unsigned integers** where the sign of the number is not a concern.

---

##### **Arithmetic Shift**

- **Definition**: An arithmetic shift also moves bits to the left or right, but it preserves the sign of the number when shifting right.
- **Left Arithmetic Shift**:
    - Functions the same as a left logical shift, moving bits to the left and filling the LSB with zero.
    - For example, shifting `1010` left results in `0100`.
- **Right Arithmetic Shift**:
    - Each bit is shifted to the right, but the MSB (which represents the sign bit in signed integers) is replicated to fill the vacated positions.
    - This means if the original number is negative (MSB is 1), the new bits filled in will also be 1, preserving the sign.
    - For example, shifting `1110` (which represents -2 in two's complement) right results in `1111`, maintaining the negative sign.
- **Use Cases**: Arithmetic shifts are used with **signed integers** where it is important to maintain the sign of the number during the shift operation.

---

## **Data Movement Instructions**

Data movement instructions in MIPS are used to transfer data **between registers and memory** or **between registers**. Since MIPS is a **load/store architecture**, arithmetic and logical operations work only on registers, requiring explicit memory access when working with variables in memory.

---

### **Load Instructions**

Load instructions transfer data from **memory** to **registers**.

|**Instruction**|**Operation**|**Example**|**Notes**|
|---|---|---|---|
|`lb`|Load byte (`$t = Mem[$s + offset]`, sign-extended)|`lb $t0, 4($t1)`|Loads a signed byte (8-bit) and sign-extends to 32-bit|
|`lbu`|Load byte unsigned (`$t = Mem[$s + offset]`, zero-extended)|`lbu $t0, 4($t1)`|Loads an unsigned byte (8-bit) and zero-extends to 32-bit|
|`lh`|Load halfword (`$t = Mem[$s + offset]`, sign-extended)|`lh $t0, 4($t1)`|Loads a signed halfword (16-bit) and sign-extends to 32-bit|
|`lhu`|Load halfword unsigned (`$t = Mem[$s + offset]`, zero-extended)|`lhu $t0, 4($t1)`|Loads an unsigned halfword (16-bit) and zero-extends to 32-bit|
|`lw`|Load word (`$t = Mem[$s + offset]`)|`lw $t0, 4($t1)`|Loads a full word (32-bit)|
|`lwl`|Load word left (`$t = Partial Mem[$s + offset]`)|`lwl $t0, 1($t1)`|Loads the most significant bytes from memory, used for unaligned access|
|`lwr`|Load word right (`$t = Partial Mem[$s + offset]`)|`lwr $t0, 1($t1)`|Loads the least significant bytes from memory, used for unaligned access|
|`ll`|Load linked (`$t = Mem[$s + offset]`)|`ll $t0, 0($t1)`|Used for atomic operations with `sc` (store conditional)|
|`lui`|Load upper immediate (`$t = imm << 16`)|`lui $t0, 0x1234`|Loads an immediate into the upper 16 bits, lower 16 bits set to 0|

**Example: Loading Data from Memory**

```assembly
      .data
array:  .word 10, 20, 30  # Define an array in memory

      .text
      .globl main
main:
      la   $t1, array     # Load address of array
      lw   $t2, 0($t1)    # Load first element (10)
      lw   $t3, 4($t1)    # Load second element (20)
      lw   $t4, 8($t1)    # Load third element (30)
      
      li   $v0, 10        # Exit
      syscall
```

---

### **Store Instructions**

Store instructions transfer data from **registers** to **memory**.

|**Instruction**|**Operation**|**Example**|**Notes**|
|---|---|---|---|
|`sb`|Store byte (`Mem[$s + offset] = $t (lower 8 bits)`)|`sb $t0, 4($t1)`|Stores the least significant byte (8-bit) of `$t0` into memory|
|`sh`|Store halfword (`Mem[$s + offset] = $t (lower 16 bits)`)|`sh $t0, 4($t1)`|Stores the least significant halfword (16-bit) of `$t0` into memory|
|`sw`|Store word (`Mem[$s + offset] = $t`)|`sw $t0, 4($t1)`|Stores a full word (32-bit) into memory|
|`swl`|Store word left (`Partial Mem[$s + offset] = $t`)|`swl $t0, 1($t1)`|Stores the most significant bytes of `$t0` into memory, used for unaligned access|
|`swr`|Store word right (`Partial Mem[$s + offset] = $t`)|`swr $t0, 1($t1)`|Stores the least significant bytes of `$t0` into memory, used for unaligned access|
|`sc`|Store conditional (`Mem[$s + offset] = $t` if link is valid)|`sc $t0, 0($t1)`|Used for atomic operations with `ll` (load linked), stores only if no other writes occurred|

**Example: Storing Data into Memory**

```assembly
      .data
array:  .space 12  # Reserve space for 3 words

      .text
      .globl main
main:
      la   $t1, array     # Load address of array
      li   $t2, 100       # Load 100
      li   $t3, 200       # Load 200
      li   $t4, 300       # Load 300
      
      sw   $t2, 0($t1)    # Store 100 at first position
      sw   $t3, 4($t1)    # Store 200 at second position
      sw   $t4, 8($t1)    # Store 300 at third position
      
      li   $v0, 10        # Exit
      syscall
```

---

### **Move Instructions**

Move instructions copy values **between registers**.

|**Instruction**|**Operation**|**Example**|**Notes**|
|---|---|---|---|
|`move`|Copy register value (`$d = $s`)|`move $t0, $t1`|Pseudo-instruction for `or $t0, $t1, $zero`|
|`mfhi`|Move from HI register (`$d = HI`)|`mfhi $t0`|Moves the value from the HI register (used in multiplication and division) to `$t0`|
|`mflo`|Move from LO register (`$d = LO`)|`mflo $t0`|Moves the value from the LO register (used in multiplication and division) to `$t0`|
|`mthi`|Move to HI register (`HI = $s`)|`mthi $t0`|Stores `$t0` into the HI register|
|`mtlo`|Move to LO register (`LO = $s`)|`mtlo $t0`|Stores `$t0` into the LO register|
|`movn`|Move if not zero (`$d = $s` if `$t ≠ 0`)|`movn $t0, $t1, $t2`|Moves `$t1` into `$t0` if `$t2` is not zero|
|`movz`|Move if zero (`$d = $s` if `$t == 0`)|`movz $t0, $t1, $t2`|Moves `$t1` into `$t0` if `$t2` is zero|

**Example: Moving Register Values**

```assembly
      .text
      .globl main
main:
      li   $t1, 42       # Load 42 into $t1
      move $t2, $t1      # Copy value to $t2
      
      li   $v0, 10       # Exit
      syscall
```

---

## **Handling of Special Values (Zero, NaN)**

MIPS handles special values such as **zero** and **NaN (Not a Number)** in both integer and floating-point computations. These values affect arithmetic operations, comparisons, and branching.

---

### **Handling Zero in MIPS**

1. **Zero Register (`$zero`)**
    
    - The **`$zero` register always holds the constant value 0**.
    - Any attempt to write to `$zero` is ignored.
    
    ```assembly
    add $t0, $zero, $t1   # $t0 = $t1 (same as move $t0, $t1)
    ```
    
2. **Checking for Zero**
    
    - **Branch if Zero (`beqz`)**
        
        ```assembly
        beq  $t0, $zero, label  # Branch if $t0 is zero
        ```
        
    - **Branch if Not Zero (`bnez`)**
        
        ```assembly
        bne  $t0, $zero, label  # Branch if $t0 is not zero
        ```
        
3. **Dividing by Zero (Exception Handling)**
    
    - Integer division by zero causes an **exception**.
    - MIPS does **not** automatically handle it, so checking is necessary.
    
    ```assembly
    beq  $t1, $zero, error    # If denominator is zero, jump to error
    div  $t0, $t1             # Safe division
    ```
    

---

### **Handling NaN (Not a Number) in MIPS Floating-Point Operations**

MIPS **follows IEEE 754 standard** for floating-point arithmetic, which includes NaN. NaN is produced in cases such as:

- **0 ÷ 0**
- **Infinity - Infinity**
- **sqrt(-1) (invalid square root)**
- **Operations involving NaN (NaN propagates)**

#### **Checking for NaN using `c.un.s` (Compare Unordered Single-Precision)**

```assembly
      .data
nan_msg: .asciiz "NaN detected!\n"

      .text
      .globl main
main:
      li.s   $f1, 0.0
      div.s  $f2, $f1, $f1   # NaN = 0.0 / 0.0

      c.un.s $f2, $f2        # Check if NaN (unordered comparison)
      bc1t   print_nan       # Branch if true (NaN detected)

      li    $v0, 10          # Exit
      syscall

print_nan:
      li    $v0, 4
      la    $a0, nan_msg
      syscall
      li    $v0, 10
      syscall
```

**Step-by-Step Breakdown**

**1. Load Zero into `$f1`**

```assembly
li.s   $f1, 0.0
```

- The instruction **`li.s`** (Load Immediate Single) loads the floating-point value `0.0` into register `$f1`.

**2. Perform an Invalid Division (0.0 / 0.0)**

```assembly
div.s  $f2, $f1, $f1   # NaN = 0.0 / 0.0
```

- **`div.s`** (Divide Single) computes `$f1 ÷ $f1`, which is `0.0 ÷ 0.0`.
- Since dividing zero by zero is mathematically undefined, **IEEE 754 floating-point standard produces NaN (Not a Number)**.
- The result is stored in `$f2`.

**3. Check if `$f2` is NaN (Unordered Comparison)**

```assembly
c.un.s $f2, $f2        # Check if NaN (unordered comparison)
```

- **`c.un.s` (Compare Unordered Single)** checks if **either operand is NaN**.
- Since `$f2` contains NaN, the result of this comparison is **true**.

**4. Branch if NaN is Detected**

```assembly
bc1t   print_nan       # Branch if true (NaN detected)
```

- **`bc1t` (Branch on Condition True for Floating-Point Unit)** jumps to `print_nan` **if the previous comparison was true**.
- Since `$f2` is NaN, the branch **will be taken**, and the program will execute the `print_nan` routine.

---

# Memory Management

## Memory Addressing Modes

MIPS uses **load/store architecture**, meaning memory access is done explicitly through **load (`lw`, `lb`, etc.)** and **store (`sw`, `sb`, etc.)** instructions. Below are the primary **addressing modes** in MIPS:

---

### **1. Register Addressing**

- The operand is in a register.
- Example:
    
    ```assembly
    add $t0, $t1, $t2  # $t0 = $t1 + $t2
    ```
    
    - Both `$t1` and `$t2` are **register operands**.

---

### **2. Immediate Addressing**

- The operand is a **constant value** embedded in the instruction.
- Example:
    
    ```assembly
    addi $t0, $zero, 10  # $t0 = 10 (Immediate value)
    ```
    
    - The constant **10** is directly used in the instruction.

---

### **3. Direct (Absolute) Addressing**

- The instruction directly specifies a memory **label** (absolute address).
- Example:
    
    ```assembly
    la   $t0, var      # Load address of 'var' into $t0
    lw   $t1, 0($t0)   # Load value from memory at 'var'
    
    .data
    var: .word 42      # Memory location labeled 'var'
    ```
    
    - `var` is a **memory label**, and `lw` loads the value stored at that location.

---

### **4. Indirect Addressing**

- The **memory address** is stored in a **register**.
- Example:
    
    ```assembly
    lw   $t0, 0($t1)   # Load word from address stored in $t1
    ```
    
    - `$t1` contains a memory address, and `lw` loads the word stored at that address.

---

### **5. Base + Offset (Displacement) Addressing**

- The memory address is calculated as: Effective Address=Base Register+Offset\text{Effective Address} = \text{Base Register} + \text{Offset}
- Example:
    
    ```assembly
    lw   $t0, 4($t1)   # Load word from address ($t1 + 4)
    ```
    
    - Useful for **arrays and structures**.

---

### **6. Indexed Addressing (Using Shifted Indexes)**

- Used for **array access**, where an index is **scaled** before adding to a base address.
- Example:
    
    ```assembly
    sll  $t2, $t1, 2   # Multiply index ($t1) by 4 (word size)
    lw   $t0, array($t2) # Load word from array[index]
    
    .data
    array: .word 10, 20, 30, 40  # Example array
    ```
    
    - `$t1` contains an **array index**.
    - `sll` (Shift Left Logical) **shifts** `$t1` **left by 2 bits**, which is equivalent to multiplying by `4`.
	- This converts an **array index** to a **byte offset**.
	- Example values:
	    - If `$t1 = 0` → `$t2 = 0 × 4 = 0` (Access `array[0]`)
	    - If `$t1 = 1` → `$t2 = 1 × 4 = 4` (Access `array[1]`)
	    - If `$t1 = 2` → `$t2 = 2 × 4 = 8` (Access `array[2]`)
	    - If `$t1 = 3` → `$t2 = 3 × 4 = 12` (Access `array[3]`)

---

### **7. PC-Relative Addressing (Used in Branching)**

- The memory address is computed relative to the **Program Counter (PC)**.
- Example:
    
    ```assembly
    beq  $t0, $t1, label  # Branch to 'label' if $t0 == $t1
    ```
    
    - The branch **offset** is added to the **PC** to compute the target address.

---

### **8. Pseudo-Direct Addressing (Used in Jump Instructions)**

- The instruction contains part of the address, and the upper bits are taken from the **PC**.
- Example:
    
    ```assembly
    j target_label   # Jump to 'target_label'
    ```
    
    - Used in **jump (`j`) and jump-and-link (`jal`)** instructions.

---

### **Summary Table**

| **Addressing Mode**              | **Description**                | **Example**           |
| -------------------------------- | ------------------------------ | --------------------- |
| **Register Addressing**          | Operand in register            | `add $t0, $t1, $t2`   |
| **Immediate Addressing**         | Operand is constant            | `addi $t0, $zero, 10` |
| **Direct (Absolute) Addressing** | Uses memory label              | `lw $t1, var`         |
| **Indirect Addressing**          | Address stored in register     | `lw $t0, 0($t1)`      |
| **Base + Offset Addressing**     | Base + displacement            | `lw $t0, 4($t1)`      |
| **Indexed Addressing**           | Uses scaled index              | `lw $t0, array($t2)`  |
| **PC-Relative Addressing**       | Relative to `PC`               | `beq $t0, $t1, label` |
| **Pseudo-Direct Addressing**     | Part of address in instruction | `j target_label`      |

---

### **Handling of Arrays and Structures in MIPS**

MIPS does not have built-in array or structure support like high-level languages (e.g., C), but we can handle them using **memory addressing and register operations**.

---

### **1. Handling Arrays**

Arrays in MIPS are stored in **contiguous memory locations**, and we access elements using **base address + index × element size**.

#### **Accessing Array Elements (Indexing)**

Each **word** (integer) in MIPS is **4 bytes**. To access an element at index $i$, we use:

Address=Base Address+(i×4)\text{Address} = \text{Base Address} + (i \times 4)

#### **Example: Accessing an Integer Array**

```assembly
      .data
array: .word 10, 20, 30, 40  # Define an array of 4 integers

      .text
      .globl main
main:
      la   $t0, array      # Load base address of array
      li   $t1, 2          # Load index (access 3rd element)
      sll  $t1, $t1, 2     # Multiply index by 4 (word size)
      add  $t1, $t0, $t1   # Compute address of array[2]
      lw   $a0, 0($t1)     # Load array[2] (30) into $a0
      li   $v0, 1          # Print the value
      syscall
      li   $v0, 10         # Exit
      syscall
```

✅ **Output:** `30`

---

### **2. Looping Through an Array**

To iterate through an array, use a **loop** and **increment the address**.

#### **Example: Summing an Array**

```assembly
      .data
array: .word 1, 2, 3, 4, 5  # Define an array of 5 integers
size:  .word 5              # Store array size

      .text
      .globl main
main:
      la   $t0, array      # Load base address
      lw   $t1, size       # Load array size
      li   $t2, 0          # Index = 0
      li   $t3, 0          # Sum = 0

loop:
      beq  $t2, $t1, end   # If index == size, exit loop
      lw   $t4, 0($t0)     # Load array[i]
      add  $t3, $t3, $t4   # Add to sum
      addi $t0, $t0, 4     # Move to next element
      addi $t2, $t2, 1     # Increment index
      j    loop            # Repeat

end:
      move $a0, $t3        # Print sum
      li   $v0, 1
      syscall
      li   $v0, 10         # Exit
      syscall
```

✅ **Output:** `15`

---

### **3. Handling Structures in MIPS**

A **structure** is a collection of different data types stored in **consecutive memory locations**.

#### **Example: Defining a Structure (Student)**

```assembly
      .data
student:
      .asciiz "John Doe"  # Name (string)
      .space 4            # Align memory
age:  .word 20           # Age
gpa:  .float 3.75        # GPA

      .text
      .globl main
main:
      la   $a0, student  # Load address of name
      li   $v0, 4        # Print string
      syscall

      lw   $a0, age      # Load age
      li   $v0, 1        # Print integer
      syscall

      l.s  $f12, gpa     # Load GPA (floating-point)
      li   $v0, 2        # Print float
      syscall

      li   $v0, 10       # Exit
      syscall
```

✅ **Output:**

```
John Doe
20
3.75
```

---

### **4. Accessing Structure Fields with Offsets**

Since structure fields are stored **sequentially**, we use **offsets**.

#### **Example: Accessing Structure Fields Dynamically**

```assembly
      .data
person:
      .asciiz "Alice"  # Name
      .space 4         # Padding
      .word 25         # Age
      .float 4.0       # GPA

      .text
      .globl main
main:
      la   $t0, person    # Load base address

      # Load and print name
      move $a0, $t0
      li   $v0, 4
      syscall

      # Load and print age (offset = 8)
      lw   $a0, 8($t0)
      li   $v0, 1
      syscall

      # Load and print GPA (offset = 12)
      l.s  $f12, 12($t0)
      li   $v0, 2
      syscall

      li   $v0, 10       # Exit
      syscall
```

✅ **Output:**

```
Alice
25
4.0
```

---

**Key Takeaways**

✅ **Arrays** use **base address + (index × element size)** for access.  
✅ **Loops** iterate through arrays using pointer arithmetic.  
✅ **Structures** are accessed using **offsets** from a base address.

---

# Instructions

## [[#Arithmetic Operations]]

## [[#Logical Operations]]

## [[#Shift Operations]]

## **Set Instructions**

MIPS provides **set instructions** to compare registers and set values based on conditions. These instructions are useful for implementing conditional logic without using branches.

---

### **`slti` (Set Less Than Immediate)**

- **Operation**: `$rd = ($rs < immediate) ? 1 : 0`
- **Usage**: Checks if a register value is less than a constant.

**Example**

```assembly
slti $t0, $s1, 10   # If $s1 < 10, set $t0 = 1; otherwise, $t0 = 0
```

---

### **`sltiu` (Set Less Than Immediate Unsigned)**

- **Operation**: `$rd = ($rs < immediate) ? 1 : 0` (treats numbers as **unsigned**)
- **Usage**: Similar to `slti`, but interprets numbers as unsigned.

**Example**

```assembly
sltiu $t0, $s1, 10  # If $s1 (unsigned) < 10, set $t0 = 1; otherwise, $t0 = 0
```

---

### **`slt` (Set Less Than)**

- **Operation**: `$rd = ($rs < $rt) ? 1 : 0`
- **Usage**: Compares two **signed** registers.

**Example**

```assembly
slt $t0, $s1, $s2   # If $s1 < $s2, set $t0 = 1; otherwise, $t0 = 0
```

---

### **`sltu` (Set Less Than Unsigned)**

- **Operation**: `$rd = ($rs < $rt) ? 1 : 0` (treats numbers as **unsigned**)
- **Usage**: Compares two **unsigned** numbers.

**Example**

```assembly
sltu $t0, $s1, $s2  # If $s1 (unsigned) < $s2 (unsigned), set $t0 = 1
```

---

### **`sgt` (Set Greater Than) [Pseudoinstruction]**

- **Operation**: `$rd = ($rs > $rt) ? 1 : 0`
- **Usage**: Checks if `$rs` is greater than `$rt`. It is **not a real instruction**, but a **pseudoinstruction** implemented as:

#### **Expansion**

```assembly
sgt $t0, $s1, $s2  # If $s1 > $s2, set $t0 = 1
```

Expands to:

```assembly
slt $t0, $s2, $s1  # Equivalent to checking if $s2 < $s1
```

Since `$s2 < $s1` is logically the same as `$s1 > $s2`, `sgt` is just an alias for `slt`.

---

### **`sgtu` (Set Greater Than Unsigned) [Pseudoinstruction]**

- **Operation**: `$rd = ($rs > $rt) ? 1 : 0` (unsigned comparison)
- **Usage**: Similar to `sgt`, but for unsigned values.

#### **Expansion**

```assembly
sgtu $t0, $s1, $s2  # If $s1 (unsigned) > $s2 (unsigned), set $t0 = 1
```

Expands to:

```assembly
sltu $t0, $s2, $s1  # Equivalent to checking if $s2 < $s1
```

---

**Example: Using Set Instructions**

**Check if a Number is Positive, Negative, or Zero**

```assembly
    li   $s1, -5       # Example number

    slti $t0, $s1, 0   # Check if negative ($t0 = 1 if $s1 < 0)
    bne  $t0, $zero, negative

    beq  $s1, $zero, zero

    j    positive

negative:
    li   $a0, 'N'
    j    print
zero:
    li   $a0, 'Z'
    j    print
positive:
    li   $a0, 'P'

print:
    li   $v0, 11  # Print character
    syscall

    li   $v0, 10  # Exit
    syscall
```

---

**Summary Table**

| **Instruction** | **Description**                                     | **Signed/Unsigned** |
| --------------- | --------------------------------------------------- | ------------------- |
| `slt`           | Set if less than (`rs < rt`)                        | Signed              |
| `sltu`          | Set if less than (`rs < rt`)                        | Unsigned            |
| `slti`          | Set if less than immediate (`rs < imm`)             | Signed              |
| `sltiu`         | Set if less than immediate (`rs < imm`)             | Unsigned            |
| `sgt`           | Set if greater than (`rs > rt`) (Pseudoinstruction) | Signed              |
| `sgtu`          | Set if greater than (`rs > rt`) (Pseudoinstruction) | Unsigned            |

## [[#Load Instructions]]

## [[#Store Instructions]]

## [[#Move Instructions]]

## **Comparison Instruction**

Comparison instructions are used to evaluate conditions and store results in registers or control program flow through branching.

---

### **1. Set on Less Than Instructions (`slt`, `sltu`, `slti`, `sltiu`)**

These instructions compare two values and store `1` if the condition is true; otherwise, they store `0`.

| **Instruction** | **Operation**                                     | **Example**                                       |
| --------------- | ------------------------------------------------- | ------------------------------------------------- |
| `slt`           | `$rd = ($rs < $rt) ? 1 : 0` (signed comparison)   | `slt $t0, $t1, $t2` → `$t0 = ($t1 < $t2) ? 1 : 0` |
| `sltu`          | `$rd = ($rs < $rt) ? 1 : 0` (unsigned comparison) | `sltu $t0, $t1, $t2`                              |
| `slti`          | `$rt = ($rs < imm) ? 1 : 0` (signed immediate)    | `slti $t0, $t1, 10`                               |
| `sltiu`         | `$rt = ($rs < imm) ? 1 : 0` (unsigned immediate)  | `sltiu $t0, $t1, 10`                              |

✅ **Example Usage:**

```assembly
    li $t1, 5
    li $t2, 10
    slt $t0, $t1, $t2  # $t0 = 1 because 5 < 10
```

---

### **2. Branching Based on Comparison**

These instructions compare values and alter program execution.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`beq`|Branch if equal|`beq $t0, $t1, label`|
|`bne`|Branch if not equal|`bne $t0, $t1, label`|
|`bgtz`|Branch if greater than zero|`bgtz $t0, label`|
|`bltz`|Branch if less than zero|`bltz $t0, label`|
|`bgez`|Branch if greater than or equal to zero|`bgez $t0, label`|
|`blez`|Branch if less than or equal to zero|`blez $t0, label`|

✅ **Example Usage:**

```assembly
    li $t1, 5
    li $t2, 5
    beq $t1, $t2, equal_label  # If $t1 == $t2, jump to "equal_label"
```

---

### **3. Pseudoinstructions (`sgt`, `sle`, `sge`)**

MIPS does not have `sgt` (set greater than) or `sle` (set less than or equal), but they can be implemented using existing instructions.

|**Pseudoinstruction**|**Equivalent MIPS Instruction**|
|---|---|
|`sgt $t0, $t1, $t2`|`slt $t0, $t2, $t1` (reverse `slt`)|
|`sle $t0, $t1, $t2`|`slt $t0, $t2, $t1` → `xori $t0, $t0, 1`|
|`sge $t0, $t1, $t2`|`slt $t0, $t1, $t2` → `xori $t0, $t0, 1`|

✅ **Example Usage:**

```assembly
    li $t1, 10
    li $t2, 5
    sgt $t0, $t1, $t2  # $t0 = 1 because 10 > 5
```

---

**Summary**

- **`slt` / `sltu` / `slti` / `sltiu`** → Set if less than
- **`beq` / `bne`** → Branch if equal or not equal
- **`bgtz` / `bltz` / `bgez` / `blez`** → Branch on greater/less than zero
- **Pseudoinstructions** (`sgt`, `sle`, `sge`) → Simulate missing conditions

---

## **Branching Instructions**

Branching instructions control the flow of execution by jumping to a different part of the program based on conditions.

---

### **1. Conditional Branch Instructions**

These instructions compare registers and branch to a specified label if the condition is met.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`beq`|Branch if equal|`beq $t0, $t1, label` → If `$t0 == $t1`, jump to `label`.|
|`bne`|Branch if not equal|`bne $t0, $t1, label` → If `$t0 ≠ $t1`, jump to `label`.|
|`bgtz`|Branch if greater than zero|`bgtz $t0, label` → If `$t0 > 0`, jump to `label`.|
|`bltz`|Branch if less than zero|`bltz $t0, label` → If `$t0 < 0`, jump to `label`.|
|`bgez`|Branch if greater than or equal to zero|`bgez $t0, label` → If `$t0 ≥ 0`, jump to `label`.|
|`blez`|Branch if less than or equal to zero|`blez $t0, label` → If `$t0 ≤ 0`, jump to `label`.|

✅ **Example: Checking if a number is positive, negative, or zero**

```assembly
    li $t0, -5        # Load value into $t0

    bltz $t0, negative   # Branch if negative
    beq  $t0, $zero, zero  # Branch if zero
    bgtz $t0, positive   # Branch if positive

negative:
    li $a0, -1
    j exit

zero:
    li $a0, 0
    j exit

positive:
    li $a0, 1

exit:
    # End of program
```

---

### **2. Unconditional Jump Instructions**

These instructions cause the program to jump to a new location regardless of conditions.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`j label`|Jump to address at `label`|`j loop` → Unconditionally jump to `loop`.|
|`jr $ra`|Jump to the address in register `$ra`|Used for function returns.|
|`jal label`|Jump and link (save return address)|Used for function calls.|

✅ **Example: Loop using an unconditional jump**

```assembly
loop:
    # Do something
    j loop  # Infinite loop
```

---

### **3. Comparison and Branching (Using `slt`)**

If more complex conditions are needed, use `slt` (`set on less than`) with `bne` or `beq`.

✅ **Example: Branch if `$t0` is greater than `$t1`**

```assembly
    slt $t2, $t1, $t0  # $t2 = 1 if $t1 < $t0
    bne $t2, $zero, greater_than_label  # Branch if $t2 == 1
```

---

### **4. Function Calls and Returns**

- **`jal label`** → Jumps to a function while saving return address in `$ra`.
- **`jr $ra`** → Jumps back to the saved return address.

✅ **Example: Calling and returning from a function**

```assembly
main:
    jal my_function  # Call function
    j exit           # End program

my_function:
    # Do something
    jr $ra           # Return to caller
```

---

**Summary**

- **Conditional Branching:** `beq`, `bne`, `bgtz`, `bltz`, `bgez`, `blez`
- **Unconditional Jumps:** `j`, `jr`, `jal`
- **Function Calls & Returns:** `jal`, `jr`

---

## **Jump Instructions**

Jump instructions in MIPS allow the program to transfer control to a specific address, either unconditionally or with linkage for function calls.

---

### **1. Unconditional Jump (`j`)**

- Directly jumps to a label without any condition.
- Used for infinite loops, skipping code, or branching to another part of the program.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`j label`|Jump to `label`|`j loop` (Go to `loop`)|

✅ **Example: Infinite loop using `j`**

```assembly
main:
    j loop  # Jump to loop

loop:
    # Some repeated task
    j loop  # Go back to loop (infinite)
```

---

### **2. Jump and Link (`jal`)**

- Used for **function calls**.
- Saves the return address (next instruction) into `$ra` (`$31`).
- Allows returning to the caller using `jr $ra`.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`jal label`|Jump to `label`, save `$ra`|`jal function` (Call function)|

✅ **Example: Calling a function**

```assembly
main:
    jal my_function  # Call function
    j exit           # Skip to exit after function returns

my_function:
    # Function logic
    jr $ra  # Return to caller

exit:
    # End of program
```

---

### **3. Jump Register (`jr`)**

- Jumps to an address stored in a register.
- Commonly used with `jal` to return from functions.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`jr $ra`|Jump to address in `$ra`|`jr $ra` (Return from function)|

✅ **Example: Function return**

```assembly
my_function:
    # Function logic
    jr $ra  # Return to caller
```

---

### **4. Jump and Link Register (`jalr`)**

- Like `jal`, but the target address is in a register instead of an immediate label.
- Saves return address in `$ra`.

|**Instruction**|**Operation**|**Example**|
|---|---|---|
|`jalr $t0`|Jump to address in `$t0` and save return address in `$ra`|`jalr $t0`|

✅ **Example: Dynamic function calls**

```assembly
    move $t0, $a0  # Load function address
    jalr $t0       # Call function in $t0
```

---

### **5. Jump and Register-Based Execution**

Sometimes, jumps are combined with register-based operations.

✅ **Example: Switching execution using a register**

```assembly
    li $t0, func1  # Load address of func1
    jalr $t0       # Call function in $t0

func1:
    # Function logic
    jr $ra  # Return to caller
```

---

**Summary of Jump Instructions**

|**Instruction**|**Purpose**|
|---|---|
|`j label`|Unconditional jump to `label`.|
|`jal label`|Jump to `label`, save return address.|
|`jr $ra`|Jump to return address in `$ra`.|
|`jalr $t0`|Jump to address in `$t0`, save return address.|

---

## **Floating-Point Instructions**

#### **Arithmetic Instructions**

|**Instruction**|**Operation**|**Example**|**Notes**|
|---|---|---|---|
|`add.s`|Single-precision floating-point addition|`add.s $f0, $f1, $f2`|`$f0 = $f1 + $f2`|
|`add.d`|Double-precision floating-point addition|`add.d $f0, $f1, $f2`|`$f0 = $f1 + $f2`|
|`sub.s`|Single-precision floating-point subtraction|`sub.s $f0, $f1, $f2`|`$f0 = $f1 - $f2`|
|`sub.d`|Double-precision floating-point subtraction|`sub.d $f0, $f1, $f2`|`$f0 = $f1 - $f2`|
|`mul.s`|Single-precision floating-point multiplication|`mul.s $f0, $f1, $f2`|`$f0 = $f1 * $f2`|
|`mul.d`|Double-precision floating-point multiplication|`mul.d $f0, $f1, $f2`|`$f0 = $f1 * $f2`|
|`div.s`|Single-precision floating-point division|`div.s $f0, $f1, $f2`|`$f0 = $f1 / $f2`|
|`div.d`|Double-precision floating-point division|`div.d $f0, $f1, $f2`|`$f0 = $f1 / $f2`|
|`neg.s`|Negate single-precision floating-point|`neg.s $f0, $f1`|`$f0 = -$f1`|
|`neg.d`|Negate double-precision floating-point|`neg.d $f0, $f1`|`$f0 = -$f1`|
|`abs.s`|Absolute value (single-precision)|`abs.s $f0, $f1`|`$f0 =|
|`abs.d`|Absolute value (double-precision)|`abs.d $f0, $f1`|`$f0 =|

#### **Comparison Instructions**

|**Instruction**|**Operation**|**Example**|**Notes**|
|---|---|---|---|
|`c.eq.s`|Compare equal (single)|`c.eq.s $f0, $f1`|Sets condition flag if `$f0 == $f1`|
|`c.eq.d`|Compare equal (double)|`c.eq.d $f0, $f1`|Same as above for double-precision|
|`c.lt.s`|Compare less than (single)|`c.lt.s $f0, $f1`|Sets flag if `$f0 < $f1`|
|`c.lt.d`|Compare less than (double)|`c.lt.d $f0, $f1`|Same as above for double-precision|
|`c.le.s`|Compare less than or equal (single)|`c.le.s $f0, $f1`|Sets flag if `$f0 ≤ $f1`|
|`c.le.d`|Compare less than or equal (double)|`c.le.d $f0, $f1`|Same as above for double-precision|

#### **Floating-Point Load and Store Instructions**

|**Instruction**|**Operation**|**Example**|**Notes**|
|---|---|---|---|
|`lwc1`|Load word (single-precision)|`lwc1 $f0, 0($t0)`|Load 32-bit float from memory|
|`ldc1`|Load double word (double-precision)|`ldc1 $f0, 0($t0)`|Load 64-bit double from memory|
|`swc1`|Store word (single-precision)|`swc1 $f0, 0($t0)`|Store 32-bit float to memory|
|`sdc1`|Store double word (double-precision)|`sdc1 $f0, 0($t0)`|Store 64-bit double to memory|

#### **Floating-Point Move Instructions**

| **Instruction** | **Operation**               | **Example**            | **Notes**           |
| --------------- | --------------------------- | ---------------------- | ------------------- |
| `mov.s`         | Move single-precision float | `mov.s $f0, $f1`       | `$f0 = $f1`         |
| `mov.d`         | Move double-precision float | `mov.d $f0, $f1`       | `$f0 = $f1`         |
| `movn.s`        | Move if not zero (single)   | `movn.s $f0, $f1, $t0` | Moves if `$t0 ≠ 0`  |
| `movn.d`        | Move if not zero (double)   | `movn.d $f0, $f1, $t0` | Moves if `$t0 ≠ 0`  |
| `movz.s`        | Move if zero (single)       | `movz.s $f0, $f1, $t0` | Moves if `$t0 == 0` |
| `movz.d`        | Move if zero (double)       | `movz.d $f0, $f1, $t0` | Moves if `$t0 == 0` |

---

