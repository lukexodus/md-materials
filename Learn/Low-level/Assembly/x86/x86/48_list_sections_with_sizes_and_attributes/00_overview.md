## Overview

readelf -S binary        # ELF
objdump -h binary        # Cross-platform
otool -l binary          # Mach-O
```

[Inference] Section sizes and characteristics help prioritize analysis effort - large .text sections indicate substantial code, large .data/.bss sections suggest significant state, and .rsrc sections may contain embedded resources.

**Imports and Exports**: Reveal external dependencies and exposed functionality:

```bash
