## Overview

ltrace ./program               # Trace library calls
ltrace -e malloc ./program     # Trace specific functions
```

**API Hooking**: Intercept specific function calls to log or modify behavior:

```c
// Frida example: Hook malloc
Interceptor.attach(Module.findExportByName(null, "malloc"), {
    onEnter: function(args) {
        console.log("malloc(" + args[0] + ")");
    },
    onLeave: function(retval) {
        console.log("-> " + retval);
    }
});
```

[Inference] API hooking enables observing program behavior at function granularity without modifying the binary. Tools like Frida allow dynamic instrumentation through scripting.

**Instruction Tracing**: Record every instruction executed:

```bash
