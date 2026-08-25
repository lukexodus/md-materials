## Common Issues


### Native Modules

**Issue**: Native modules don't work after packaging

**Solution**: Add to `asarUnpack` or use `extraResources`

### File Not Found

**Issue**: Files can't be found in packaged app

**Solution**: Use proper path resolution with `app.getAppPath()` or `process.resourcesPath`

### Write Permissions

**Issue**: Can't write files in packaged app

**Solution**: Write to `app.getPath('userData')` instead of app directory

### Dynamic Requires

**Issue**: `require()` with variables fails in ASAR

**Solution**: Use `__non_webpack_require__` or unpack the files

