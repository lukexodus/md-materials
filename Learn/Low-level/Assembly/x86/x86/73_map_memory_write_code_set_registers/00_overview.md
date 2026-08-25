## Overview

emu.mem_map(0x1000, 0x1000)
emu.mem_write(0x1000, b"\x48\x89\xF8\xC3")  # mov rax, rdi; ret
emu.reg_write(UC_X86_REG_RDI, 0x1234)
