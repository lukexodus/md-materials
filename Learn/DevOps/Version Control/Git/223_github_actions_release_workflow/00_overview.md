## Overview

name: Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Extract version
        id: get_version
        run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_ENV
      
      - name: Build
        run: mvn package -Dversion=$VERSION
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: target/myapp-${{ env.VERSION }}.jar
          generate_release_notes: true
      
      - name: Deploy to production
        run: ./deploy.sh production $VERSION
```

#### Monorepo CI/CD Strategies

Handling CI/CD for monorepos with multiple projects:

- **Path-based triggers**: Run pipelines only for changed components
- **Dependency mapping**: Understand cross-project dependencies
- **Partial testing**: Test only affected components
- **Artifact caching**: Avoid rebuilding unchanged components
- **Targeted deployment**: Deploy only changed services

```yaml
