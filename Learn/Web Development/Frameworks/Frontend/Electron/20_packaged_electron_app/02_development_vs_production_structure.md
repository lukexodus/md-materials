## Development vs. Production Structure


### Development Structure

In development, your project typically looks like:

```
my-electron-app/
├── node_modules/
├── src/
│   ├── main.js
│   ├── preload.js
│   └── renderer/
│       ├── index.html
│       ├── styles.css
│       └── renderer.js
├── package.json
└── package-lock.json
```

### Packaged Structure

After packaging, the structure changes significantly based on the target platform.

