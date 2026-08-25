## `userData` vs `appData`


### Path Scope

**`userData`** is app-specific and already includes your application name in the path:

- Windows: `C:\Users\{username}\AppData\Roaming\{app name}`
- macOS: `~/Library/Application Support/{app name}`
- Linux: `~/.config/{app name}`

**`appData`** is the generic system directory shared by all applications:

- Windows: `C:\Users\{username}\AppData\Roaming`
- macOS: `~/Library/Application Support`
- Linux: `~/.config`

### Typical Usage

**`userData`** (recommended for most cases):

- Application settings and configuration files
- User preferences
- Local databases (SQLite, LevelDB, etc.)
- Cache files
- Logs specific to your app
- Any data your app needs to persist between sessions

**`appData`**:

- When you need to manually construct paths to other applications' data
- Cross-app integrations where you need to access another app's directory
- Rare cases where you want to manage the folder structure yourself

### Practical Example

```javascript
// ✓ Recommended - userData handles app folder automatically
const configPath = path.join(app.getPath('userData'), 'config.json')
// Results in: C:\Users\John\AppData\Roaming\MyApp\config.json

// ✗ Not recommended - requires manual app folder management
const configPath = path.join(app.getPath('appData'), 'MyApp', 'config.json')
// Results in: C:\Users\John\AppData\Roaming\MyApp\config.json (same, but more work)
```

### Key Takeaway

Use **`userData`** for your app's data - it's the designated, app-sandboxed location. Use **`appData`** only when you specifically need the parent directory for cross-app operations.

---

