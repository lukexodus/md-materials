## Packaging Configuration


### electron-builder Example

```json
{
  "build": {
    "appId": "com.mycompany.myapp",
    "productName": "MyApp",
    "directories": {
      "output": "dist"
    },
    "files": [
      "src/**/*",
      "node_modules/**/*",
      "package.json"
    ],
    "extraResources": [
      {
        "from": "assets/",
        "to": "assets/",
        "filter": ["**/*"]
      }
    ],
    "asarUnpack": [
      "**/node_modules/native-addon/**/*"
    ],
    "win": {
      "target": "nsis",
      "icon": "build/icon.ico"
    },
    "mac": {
      "target": "dmg",
      "icon": "build/icon.icns",
      "category": "public.app-category.productivity"
    },
    "linux": {
      "target": ["AppImage", "deb"],
      "icon": "build/icon.png",
      "category": "Utility"
    }
  }
}
```

### Key Configuration Options

- **files**: What to include in the package
- **extraResources**: Files copied to resources/ but not in ASAR
- **asarUnpack**: Patterns for files to exclude from ASAR
- **directories.output**: Where packaged apps are saved

