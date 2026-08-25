## Overview

echo "0 */6 * * * cd /path/to/repo.git && git fetch origin && git push --mirror backup" | crontab -
```

#### Recovery Testing Protocol

```bash
#!/bin/bash
