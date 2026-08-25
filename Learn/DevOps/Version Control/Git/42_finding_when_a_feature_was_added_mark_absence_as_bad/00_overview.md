## Overview

git bisect start
git bisect bad v1.0  # Feature not present
git bisect good HEAD  # Feature exists now
git bisect run ./test_for_feature.sh
```

#### Bisect Visualizations

To better understand the bisect process, you can generate visualizations:

```
