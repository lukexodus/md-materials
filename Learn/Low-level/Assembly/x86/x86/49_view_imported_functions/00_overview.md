## Overview

readelf -d binary | grep NEEDED    # ELF libraries
objdump -p binary | grep NEEDED    # ELF dependencies
dumpbin /IMPORTS binary.exe        # PE imports

