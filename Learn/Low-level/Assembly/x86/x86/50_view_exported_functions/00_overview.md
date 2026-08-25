## Overview

nm -D binary                       # ELF exports
dumpbin /EXPORTS library.dll       # PE exports
```

[Inference] Import analysis indicates functionality - network functions (socket, connect, send) suggest network communication, crypto functions (CryptEncrypt, AES_*) indicate encryption, file I/O functions suggest data persistence.

**Strings Extraction**: Embedded strings provide clues about functionality:

```bash
strings binary                     # Extract printable strings
strings -e l binary                # Extract Unicode strings (little-endian)
strings -n 10 binary               # Minimum length 10
```

[Inference] Strings reveal error messages, debug output, file paths, registry keys, URLs, command-line options, and configuration data. Even obfuscated binaries often contain some plaintext strings.

**Resources** (PE): Icons, dialogs, version info, manifests:

```bash
