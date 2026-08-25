## Overview

git fetch --deepen=50
```

**Benefits**:

- Dramatically faster initial clone
- Reduced disk space usage
- Sufficient for many day-to-day development tasks

**Limitations**:

- Cannot push to a shallow clone (unless `--depth=1`)
- Limited ability to view history
- Some Git operations may not work as expected

#### Partial Clones

Partial clones allow skipping certain objects during clone:

```bash
