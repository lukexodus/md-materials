# Syllabus

## Module 1: Foundations

- What is WebAssembly (WASM)
- History and motivation
- WASM vs JavaScript performance comparison
- Browser support and compatibility
- The WebAssembly ecosystem

## Module 2: Core Concepts

- Binary format (.wasm files)
- Text format (.wat files)
- Stack-based virtual machine
- Linear memory model
- WebAssembly modules
- Imports and exports
- Instance creation

## Module 3: WebAssembly Text Format (WAT)

- WAT syntax basics
- S-expressions structure
- Data types (i32, i64, f32, f64)
- Instructions and opcodes
- Control flow (blocks, loops, conditionals)
- Function definitions
- Local and global variables

## Module 4: JavaScript Integration

- Loading WASM modules
- WebAssembly JavaScript API
- Memory sharing between JS and WASM
- Function calls between JS and WASM
- Type conversions
- Error handling

## Module 5: Memory Management

- Linear memory allocation
- Stack vs heap in WASM
- Memory growth
- Garbage collection considerations
- Memory debugging techniques

## Module 6: Compilation Targets

- C/C++ to WASM (Emscripten)
- Rust to WASM
- AssemblyScript
- Go to WASM
- Other language bindings

## Module 7: Emscripten Toolchain

- Installation and setup
- Compilation flags and options
- SDL and OpenGL porting
- File system emulation
- Debugging C/C++ WASM applications

## Module 8: Rust and WASM

- wasm-pack toolchain
- wasm-bindgen for JS bindings
- Memory management in Rust WASM
- Performance optimization
- Publishing Rust WASM packages

## Module 9: Advanced WASM Features

- SIMD instructions
- Threads and atomics
- Bulk memory operations
- Reference types
- Multi-value returns
- Exception handling (proposal)

## Module 10: Performance Optimization

- Profiling WASM applications
- Code size optimization
- Execution speed optimization
- Memory usage optimization
- Benchmarking techniques

## Module 11: WASM Outside the Browser

- WASI (WebAssembly System Interface)
- Server-side WASM runtimes
- Wasmtime
- Wasmer
- Node.js WASM integration

## Module 12: Security Model

- WASM sandbox security
- Memory safety guarantees
- Side-channel attack considerations
- Secure compilation practices

## Module 13: Debugging and Development Tools

- Browser developer tools for WASM
- Source maps
- WASM disassemblers
- Profiling tools
- Unit testing WASM modules

## Module 14: Real-world Applications

- Game engines and WASM
- Image/video processing
- Cryptographic libraries
- Scientific computing
- Legacy code migration

## Module 15: Future and Ecosystem

- WebAssembly roadmap
- Emerging proposals
- Community and standards process
- Integration with web frameworks
- WASM package management

Each module should include hands-on exercises, practical examples, and progressive complexity building upon previous modules.