## Table of Contents: Embedded Devices

### Foundations of Embedded Systems

- What defines an embedded system
- Embedded vs general-purpose computing
- Classes of embedded systems by scale
- Real-time vs non-real-time systems
- Hard, firm, and soft real-time constraints
- Embedded system design metrics
- Power, cost, and performance tradeoffs
- Embedded system lifecycle and development flow
- Industry domains and application areas

### Digital Logic and Computer Architecture

- Number systems and binary arithmetic
- Boolean algebra and logic gates
- Combinational logic circuits
- Sequential logic and flip-flops
- Finite state machines
- Registers and counters
- Memory hierarchy fundamentals
- CPU architecture basics
- Instruction set architectures overview
- Von Neumann vs Harvard architecture
- Pipelining and instruction execution
- Endianness and data representation

### Electronics Fundamentals for Embedded Engineers

- Voltage, current, resistance, and power
- Ohm's law and Kirchhoff's laws
- Analog circuit basics
- Diodes, transistors, and switching elements
- Operational amplifiers
- Passive components: resistors, capacitors, inductors
- Signal types: analog vs digital
- Voltage levels and logic families
- Noise, grounding, and signal integrity
- Reading datasheets and schematics
- Multimeter and oscilloscope usage
- Breadboarding and prototyping practices

### Microcontroller Architecture

- Microcontroller vs microprocessor vs SoC
- Core architectures: ARM Cortex-M family
- Core architectures: AVR, PIC, RISC-V
- CPU registers and instruction pipeline
- Memory map and address space
- Flash, SRAM, and EEPROM on-chip
- Clock sources and oscillators
- Clock trees and prescalers
- Reset types and reset circuitry
- Power domains and low-power modes
- Bootloaders and boot sequence
- Vendor selection criteria and ecosystem comparison

### Digital I/O and Peripheral Basics

- GPIO configuration and modes
- Input debouncing techniques
- Output drive strength and current limits
- Pull-up and pull-down resistors
- Interrupt-driven I/O concepts
- Interrupt controllers and vector tables
- Interrupt priority and nesting
- Polling vs interrupt vs DMA tradeoffs
- Direct memory access fundamentals
- Timer and counter peripherals
- PWM generation and applications
- Watchdog timers

### Analog Interfacing

- Analog-to-digital conversion principles
- ADC resolution, sampling rate, and error sources
- Digital-to-analog conversion principles
- Sensor signal conditioning
- Filtering: RC filters and digital filters
- Amplification and level shifting
- Comparators and threshold detection
- Analog multiplexing

### Embedded Communication Protocols

- UART fundamentals and framing
- SPI protocol and multi-device configurations
- I2C protocol and addressing
- I2C multi-master and clock stretching
- CAN bus fundamentals
- CAN error handling and arbitration
- USB basics for embedded devices
- Ethernet and embedded networking
- Wireless protocols: Bluetooth and BLE
- Wireless protocols: Wi-Fi for embedded
- Low-power wireless: Zigbee, LoRa, Thread
- Protocol selection criteria
- Bus analyzers and protocol debugging

### Embedded C Programming

- C language fundamentals for embedded targets
- Data types and memory footprint awareness
- Pointers and memory addressing
- Structs, unions, and bit-fields
- Volatile, const, and static qualifiers
- Bitwise operations and register manipulation
- Function pointers and callbacks
- Memory sections: text, data, bss, heap, stack
- Stack usage and overflow prevention
- Dynamic memory allocation risks in embedded
- Writing portable and MISRA-compliant code
- Compiler optimization flags and their effects
- Linker scripts and memory placement

### Embedded C++ and Modern Alternatives

- C++ features suitable for embedded systems
- Templates and zero-cost abstractions
- Avoiding exceptions and RTTI overhead
- Rust for embedded systems overview
- Ownership and memory safety in constrained environments
- Language interoperability with C

### Toolchains and Build Systems

- Cross-compilation concepts
- GCC-based embedded toolchains
- Assembler basics and inline assembly
- Linker operation and memory layout
- Makefiles for embedded projects
- CMake for embedded builds
- Build configuration and conditional compilation
- Static libraries and object files
- Version control workflows for firmware
- Continuous integration for embedded projects

### Debugging and Testing Embedded Systems

- JTAG and SWD debugging interfaces
- In-circuit debuggers and programmers
- Breakpoints, watchpoints, and step execution
- Logic analyzers for hardware debugging
- Semihosting and printf-style debugging
- Fault handlers and crash dump analysis
- Unit testing embedded code
- Hardware-in-the-loop testing
- Mocking hardware for host-based testing
- Static analysis tools
- Code coverage in embedded contexts
- Field debugging and remote diagnostics

### Real-Time Operating Systems

- RTOS vs bare-metal decision criteria
- Task scheduling algorithms
- Preemptive vs cooperative multitasking
- Task priorities and priority inversion
- Semaphores and mutexes
- Message queues and mailboxes
- Event flags and signals
- Memory management in RTOS environments
- Interrupt handling within an RTOS
- Popular RTOS options: FreeRTOS, Zephyr, ThreadX
- RTOS configuration and porting
- Deadlock and race condition avoidance

### Embedded Linux

- Embedded Linux architecture overview
- Bootloaders: U-Boot and alternatives
- Kernel configuration and cross-compiling
- Device tree fundamentals
- Root filesystem construction
- Build systems: Yocto and Buildroot
- Linux device drivers overview
- Character, block, and network drivers
- Kernel modules and driver loading
- Init systems and process management
- System services and daemons
- Package management for embedded targets

### Device Drivers and Hardware Abstraction

- Hardware abstraction layer design
- Board support packages
- Peripheral driver architecture
- Driver initialization and configuration patterns
- Interrupt service routine design
- Buffer management and circular buffers
- Sensor driver implementation patterns
- Actuator and motor driver design
- Display and graphics driver basics

### Power Management

- Power consumption analysis and budgeting
- Sleep, standby, and deep-sleep modes
- Dynamic voltage and frequency scaling
- Peripheral clock gating
- Battery technologies and characteristics
- Battery management systems
- Energy harvesting techniques
- Power supply design basics
- Voltage regulators: linear and switching
- Measuring and profiling power consumption

### Printed Circuit Board Design

- Schematic capture fundamentals
- Component selection and footprints
- PCB layout principles
- Layer stackup and routing strategies
- Signal integrity in PCB design
- Power distribution network design
- EMI and EMC considerations
- Thermal management on PCBs
- Design for manufacturability
- Design for testability
- Prototyping and PCB fabrication process
- Bring-up and hardware validation

### Sensors and Actuators

- Common sensor types and interfaces
- Temperature, humidity, and pressure sensors
- Motion sensors: accelerometers and gyroscopes
- Proximity and optical sensors
- Sensor fusion techniques
- Calibration and drift compensation
- DC motors, stepper motors, and servos
- Motor control algorithms
- Relays and solid-state switching
- Actuator driver circuits

### Connectivity and IoT Integration

- IoT architecture patterns
- MQTT and lightweight messaging protocols
- CoAP and HTTP for constrained devices
- Cloud platform integration for embedded devices
- Over-the-air update mechanisms
- Device provisioning and identity
- Edge computing on embedded devices
- Gateway architectures
- Time synchronization in distributed embedded systems

### Embedded Security

- Threat modeling for embedded devices
- Secure boot mechanisms
- Cryptographic primitives for constrained devices
- Hardware security modules and secure elements
- Trusted execution environments
- Firmware signing and verification
- Secure over-the-air update design
- Side-channel attack awareness
- Physical tamper resistance
- Key management and storage
- Common vulnerability classes in firmware
- Security certification standards

### Safety-Critical and Regulated Systems

- Functional safety concepts
- Safety standards overview: IEC 61508 and derivatives
- Automotive standards: ISO 26262 and AUTOSAR
- Medical device standards: IEC 62304
- Redundancy and fault-tolerant design
- Failure mode and effects analysis
- Verification and validation processes
- Traceability and documentation requirements

### Advanced Embedded Architectures

- Multicore embedded systems
- Heterogeneous computing: CPU, DSP, GPU cores
- FPGA fundamentals and use cases
- Hardware description languages: Verilog and VHDL
- SoC and system-in-package design
- Custom silicon and ASIC considerations
- Memory-mapped peripherals and bus architectures
- Cache coherency in embedded multicore systems

### Machine Learning on Embedded Devices

- TinyML concepts and constraints
- Model quantization and compression
- Embedded inference frameworks
- Hardware accelerators for ML workloads
- On-device training limitations and approaches
- Data pipeline design for edge ML

### Performance Optimization

- Profiling embedded code
- Identifying and eliminating bottlenecks
- Memory footprint reduction techniques
- Code size optimization
- Execution speed optimization
- Cache-aware programming
- DMA-driven data movement optimization
- Interrupt latency minimization

### Production and Product Lifecycle

- Design for manufacturing and assembly
- Firmware provisioning at manufacturing
- Calibration and end-of-line testing
- Certification processes: FCC, CE, and regional equivalents
- Environmental and reliability testing
- Field update and maintenance strategy
- End-of-life and obsolescence management
- Documentation for production handoff

### Professional Practice and Career Development

- Reading and interpreting component datasheets
- Engaging with vendor application notes
- Collaborating with hardware and firmware teams
- Contributing to open-source embedded projects
- Building a personal project portfolio
- Industry certifications and continuing education
- Staying current with emerging embedded technologies
