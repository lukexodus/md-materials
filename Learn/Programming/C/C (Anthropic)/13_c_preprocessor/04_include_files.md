## Include Files


The `#include` directive inserts the contents of another file into the current source file at the point of inclusion. This mechanism enables code reuse, library interfaces, and modular programming.

**Include Syntax**

- `#include <filename>` - searches system directories
- `#include "filename"` - searches current directory first, then system directories

**System Headers** Standard library headers use angle brackets:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
```

**User Headers** Project-specific headers typically use quotes:

```c
#include "myheader.h"
#include "utils.h"
#include "../common/shared.h"
```

**Include Guards** Prevent multiple inclusion of the same header:

```c
#ifndef MYHEADER_H
#define MYHEADER_H
// header content
#endif
```

**Modern Include Guard Alternative**

```c
#pragma once
// header content
```

**Key Points**

- Include is textual insertion, not linking
- Circular includes must be avoided
- Include paths can be specified to compiler
- Headers should be self-contained when possible

**Examples**

```c
// config.h
#ifndef CONFIG_H
#define CONFIG_H

#ifdef PRODUCTION
    #define MAX_USERS 10000
    #define LOG_LEVEL 1
#else
    #define MAX_USERS 100
    #define LOG_LEVEL 3
#endif

#endif

// main.c
#include "config.h"
#include <stdio.h>

int main() {
    printf("Max users: %d\n", MAX_USERS);
    return 0;
}
```

