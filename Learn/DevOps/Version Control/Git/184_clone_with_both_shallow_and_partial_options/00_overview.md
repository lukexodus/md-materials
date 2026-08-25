## Overview

git clone --depth=1 --filter=blob:none https://github.com/org/repo.git
```

Filter options:

- `blob:none`: Exclude all file content objects
- `blob:limit=<size>`: Exclude blobs larger than size
- `tree:0`: Exclude all tree objects
- `object:type=<type>`: Include only specific object types

**Benefits**:

- Even faster than shallow clones for large repositories
- Objects are downloaded on-demand when needed
- Combines well with shallow clones for maximum performance

**Limitations**:

- Requires Git 2.19+ for basic support
- Full functionality requires Git 2.22+ and compatible servers
- May cause unexpected delays when accessing specific files

### Git Garbage Collection

Git's garbage collection process optimizes the repository's internal storage structure, improving performance for many operations.

**Key Points**

- Git stores objects in loose or packed format
- Garbage collection consolidates, compresses, and optimizes objects
- Automatic GC happens periodically but can be manually triggered
- Aggressive GC provides more optimization but takes longer

#### How Git Stores Objects

1. **Loose objects**: Individual files in `.git/objects/`
2. **Packfiles**: Compressed collections of objects in `.git/objects/pack/`

Over time, repositories accumulate:

- Unreachable objects (from amended commits, rebased branches)
- Redundant objects (similar versions of the same file)
- Inefficiently packed objects

#### Running Garbage Collection

Manual garbage collection can be triggered with:

```bash
