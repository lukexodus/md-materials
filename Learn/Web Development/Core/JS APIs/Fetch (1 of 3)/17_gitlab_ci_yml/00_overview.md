## Overview

deploy:
  stage: deploy
  script:
    - npm run deploy
  variables:
    DATABASE_URL: $DATABASE_URL
    API_KEY: $API_KEY
  only:
    - main
```

**Environment-specific secrets:**

```yaml
