## Platform-Specific Structures


### Windows (.exe)

When packaged for Windows, the structure typically looks like:

```
MyApp-win32-x64/
├── MyApp.exe                    # Main executable
├── resources/
│   ├── app.asar                 # Your app code (compressed)
│   └── app.asar.unpacked/       # Files that can't be in ASAR
├── locales/                     # Chromium localization files
├── chrome_100_percent.pak
├── chrome_200_percent.pak
├── d3dcompiler_47.dll
├── ffmpeg.dll
├── icudtl.dat
├── libEGL.dll
├── libGLESv2.dll
├── node.dll
├── resources.pak
├── v8_context_snapshot.bin
├── version
└── [other Chromium/Node files]
```

**Key Components:**

- **MyApp.exe**: The main application launcher that starts Electron
- **resources/app.asar**: Your application code compressed into a single archive file
- **resources/app.asar.unpacked/**: Native modules and files that cannot be packed into ASAR
- **DLL files**: Required libraries for Chromium and Node.js functionality

### macOS (.app)

macOS apps follow the standard .app bundle structure:

```
MyApp.app/
├── Contents/
    ├── Info.plist               # App metadata
    ├── MacOS/
    │   └── MyApp                # Main executable
    ├── Resources/
    │   ├── electron.icns        # App icon
    │   ├── app.asar             # Your app code
    │   └── app.asar.unpacked/
    ├── Frameworks/
    │   ├── Electron Framework.framework/
    │   ├── MyApp Helper.app/
    │   ├── MyApp Helper (GPU).app/
    │   ├── MyApp Helper (Plugin).app/
    │   └── MyApp Helper (Renderer).app/
    └── PkgInfo
```

**Key Components:**

- **Info.plist**: Contains app metadata, bundle identifier, version info
- **MacOS/MyApp**: The main executable binary
- **Resources/app.asar**: Your application code
- **Frameworks/**: Contains the Electron framework and helper processes

### Linux (.AppImage, .deb, .rpm)

Linux distributions vary, but an unpacked AppImage looks like:

```
MyApp-linux-x64/
├── myapp                        # Main executable
├── resources/
│   ├── app.asar
│   └── app.asar.unpacked/
├── locales/
├── chrome-sandbox
├── libEGL.so
├── libGLESv2.so
├── libffmpeg.so
├── libvk_swiftshader.so
├── swiftshader/
└── [other shared libraries]
```

