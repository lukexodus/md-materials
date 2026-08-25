## The ASAR Archive


### What is ASAR?

ASAR (Atom Shell Archive) is a simple archive format that concatenates files into a single file. It's similar to TAR but designed for Electron.

**Benefits:**

- Faster file access (one file instead of thousands)
- Reduced package size
- Minor obfuscation (not encryption)
- Prevents casual inspection of source code

### ASAR Structure

Inside `app.asar`:

```
app.asar
├── package.json
├── main.js
├── preload.js
├── renderer/
│   ├── index.html
│   ├── styles.css
│   └── renderer.js
└── node_modules/
    └── [dependencies]
```

### Unpacked Files

Some files cannot be in ASAR:

- Native Node modules (.node files)
- Files that need to be executable
- Files accessed by external processes

These go into `app.asar.unpacked/` and can be accessed normally.

