## Overview

drrun -t drcov -- ./program
```

[Inference] Instruction tracing provides complete execution history but generates massive amounts of data. Typically used for specific code regions or with filtering.

### Emulation and Sandboxing

Execute code in controlled, isolated environments.

**Emulators**: Simulate CPU and environment:

**QEMU**: Full-system emulator, runs entire OS, supports many architectures

**Unicorn Engine**: Lightweight CPU emulator based on QEMU, embeddable, scriptable:

```python
from unicorn import *
from unicorn.x86_const import *

