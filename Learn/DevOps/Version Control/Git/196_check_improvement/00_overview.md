## Overview

du -sh .git/objects/pack/
```

### Pruning and Optimizing Repositories

Beyond standard garbage collection, additional techniques can further optimize Git repositories.

**Key Points**

- Pruning removes unnecessary remote-tracking branches
- Reflog cleanup removes local reference history
- Repository optimization involves both size and performance
- Advanced techniques can recover significant space

#### Pruning Remote References

Remote-tracking branches that no longer exist on the remote server can be removed:

```bash
