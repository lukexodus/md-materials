## Overview

r                       # Display registers
r rax = 1234            # Modify register
```

**Common Debuggers**:

- **GDB**: GNU Debugger, command-line, Linux/Unix primary, Windows via MinGW
- **LLDB**: LLVM Debugger, command-line, macOS primary, cross-platform
- **WinDbg**: Windows Debugger, Microsoft's official debugger, kernel and user-mode
- **x64dbg**: Open-source, GUI, Windows, designed for reverse engineering
- **OllyDbg**: Popular GUI debugger for Windows (32-bit, older but still used)
- **IDA Pro**: Debugger integrated with disassembler
- **Ghidra**: Debugger integrated with analysis framework
- **radare2**: Command-line debugger and framework

### Tracing and Logging

Capture execution flow and function calls without manually stepping.

**System Call Tracing**: Monitor interactions with OS:

```bash
