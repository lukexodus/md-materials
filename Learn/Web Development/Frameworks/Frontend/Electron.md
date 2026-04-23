### Comprehensive Electron.js Syllabus

Electron.js enables building cross-platform desktop applications using web technologies (JavaScript, HTML, CSS) by embedding Chromium and Node.js. Here's a modular, topics-only syllabus for mastering Electron.js:[1][2][3][4]

#### Module 1: Fundamentals & Setup
- What is Electron.js and architecture overview
- Development environment setup
- Project initialization with npm
- Package.json configuration
- Installing Electron as dev dependency
- Entry point file (main.js) structure
- Running Electron applications
- Electron Forge toolkit introduction

#### Module 2: Core Concepts
- Main process vs Renderer process
- Chromium and Node.js integration
- Application lifecycle management
- BrowserWindow creation and configuration
- Window properties (width, height, webPreferences)
- Loading local files vs remote URLs
- Platform-specific operations (Windows, macOS, Linux)
- Process platform detection

#### Module 3: Preload Scripts & Context Isolation
- Preload script purpose and architecture
- Context Bridge API
- Exposing APIs to renderer process
- Security considerations and isolation
- Node.js modules in preload scripts
- Path resolution and file linking

#### Module 4: Inter-Process Communication (IPC)
- IPC renderer fundamentals
- IPC main fundamentals
- ipcRenderer.send() vs ipcRenderer.invoke()
- ipcMain.on() vs ipcMain.handle()
- Sending data from renderer to main
- Sending data from main to renderer
- Event handling and listeners
- Async/await patterns with IPC
- Data serialization constraints

#### Module 5: Native APIs
- Dialog module (file selection, save dialogs)
- Menu creation and customization
- Context menus implementation
- Application menus and menu bars
- System tray integration
- Notifications API
- Clipboard operations
- Shell module for external resources

#### Module 6: File System Operations
- Reading and writing files
- File path management
- Directory operations
- File deletion and manipulation
- Watching file system changes
- Native file dialogs integration

#### Module 7: Window Management
- Multiple window creation
- Window events and lifecycle
- Parent-child window relationships
- Window communication
- Frameless windows
- Window customization
- Modal windows
- Browser window options

#### Module 8: Debugging & Development Tools
- Renderer process debugging (DevTools)
- Main process debugging
- Console logging strategies
- Error handling
- Hot reload and development workflow
- Performance profiling

#### Module 9: Frontend Integration
- React.js integration
- Vue.js integration
- Angular integration
- Next.js with Electron
- Bootstrap and CSS frameworks
- Tailwind CSS styling
- Component libraries
- State management (Redux, Context API)

#### Module 10: Advanced Features
- Auto-updater module
- Crash reporting
- Native add-ons
- System integration
- Protocol handlers
- Deep linking
- Keyboard shortcuts and accelerators
- Power monitor

#### Module 11: Security
- Security best practices
- Content Security Policy (CSP)
- Node integration security
- Remote module security
- Context isolation enforcement
- Secure IPC patterns
- Vulnerability prevention

#### Module 12: Storage & Data
- Local storage
- IndexedDB integration
- SQLite databases
- File-based storage
- Session management
- Cookies and web storage

#### Module 13: Networking
- HTTP requests
- Network detection
- Platform-specific network issues
- WebSockets
- API integration
- Fetch and axios usage

#### Module 14: Packaging & Distribution
- Application packaging tools
- Platform-specific installers (.dmg, .msi, .rpm)
- Code signing
- Windows installers
- macOS disk images
- Linux packages
- Electron Builder
- Electron Packager

#### Module 15: App Store Deployment
- Mac App Store submission
- Microsoft Store deployment
- Snap Store for Linux
- App store requirements
- Certification processes
- Update mechanisms

#### Module 16: Testing
- Unit testing strategies
- Integration testing
- End-to-end testing with Playwright
- Testing Library integration
- Mocking IPC communication
- Automated testing workflows

#### Module 17: Build Tools & Optimization
- Webpack configuration
- Build optimization
- Code splitting
- Asset management
- TypeScript integration
- Babel configuration
- Production builds

#### Module 18: Real-World Projects
- Image manager application
- Note-taking desktop app
- Task tracker application
- Multi-panel applications
- API-based applications
- Database-driven applications
- Full-featured desktop applications[2][3][4][5][6]

Sources
[1] Best Electron JS Courses & Certificates [2026] | Coursera https://www.coursera.org/courses?query=electron+js
[2] ElectronJS | Online Courses, Learning Paths, and Certifications https://www.pluralsight.com/professional-services/software-development/electronjs
[3] 7 Best Electron JS Tutorials & Courses - [JAN 2026] https://coursesity.com/blog/best-electron-js-tutorials/
[4] Electron JS Tutorial For Beginners - From Scratch To Advanced https://www.youtube.com/watch?v=XLg6cR37Gpw
[5] Electron Training Course - Framework Training https://www.frameworktraining.co.uk/courses/coding/javascript-js-libraries-frameworks/electron-training-course-js-app-development
[6] Electron, v3 - Build Cross-Platform Desktop Apps https://frontendmasters.com/courses/electron-v3/
[7] Electron: Build cross-platform desktop apps with JavaScript, HTML ... https://electronjs.org
[8] Full Stack Developer Course Syllabus 2026: Fees, Duration, Details https://www.wscubetech.com/blog/full-stack-developer-course-syllabus/
[9] How To Learn JavaScript For Beginners - YouTube https://www.youtube.com/watch?v=rt11z-V-IhY
[10] JavaScript Framework Mastery 6 Month Roadmap | PDF - Scribd https://www.scribd.com/document/941289419/JavaScript-Framework-Mastery-6-Month-Roadmap

---

Electron.js is an open-source framework that enables developers to build cross-platform desktop applications using web technologies—JavaScript, HTML, and CSS. By embedding Chromium (the rendering engine) and Node.js into a single binary, Electron allows you to maintain one JavaScript codebase and create applications that work natively on Windows, macOS, and Linux without requiring native development experience.[1][2][4]

# Fundamentals & Setup

### Architecture Overview

Electron's architecture operates on a **multi-process model** with two primary components:[5][11]

**Main Process**
- Runs the entry point script (typically main.js)
- Controls application lifecycle and system-level operations
- Creates and manages BrowserWindow instances
- Accesses native APIs for menus, dialogs, notifications, and system tray
- Has full Node.js capabilities for file system access and OS interactions[7][12]

**Renderer Process**
- Each BrowserWindow runs in its own isolated renderer process
- Executes web content (HTML, CSS, JavaScript) using Chromium
- Runs like a standard web page with access to web APIs and HTML5 features
- Can access Node.js APIs when explicitly enabled (though discouraged for security)
- Multiple renderer processes can exist simultaneously for different windows[12][7]

**Inter-Process Communication (IPC)**
- Facilitates secure communication between main and renderer processes
- Uses ipcMain and ipcRenderer modules for message passing
- Supports both synchronous and asynchronous patterns[12]

**Preload Scripts & Context Bridge**
- Acts as a secure intermediary between isolated renderer contexts and Node.js
- Exposes specific APIs to the renderer while maintaining security isolation
- Implements the principle of least privilege[12]

This architecture combines Chromium's rendering capabilities with Node.js's system-level access, creating a unified runtime that transforms web applications into fully functional desktop software. The framework handles platform-specific complexities, providing consistent cross-platform behavior while allowing integration with native system features.[6][7]

Sources
[1] Introduction https://electronjs.org/docs/latest/
[2] Electron: Build cross-platform desktop apps with JavaScript ... https://electronjs.org
[3] Electron (software framework) https://en.wikipedia.org/wiki/Electron_(software_framework)
[4] Why Electron https://electronjs.org/docs/latest/why-electron
[5] Why Electron JS Works Best for Desktop App Development? https://www.manektech.com/blog/what-is-electron-js-benefits-of-using-electron-js-in-desktop-application-development
[6] Electron.js: Great Tool to Design Powerful Multi-Platform ... http://www.webdatarocks.com/blog/electron-js-great-tool-to-design-powerful-multi-platform-desktop-apps/
[7] Electron.js: Desktop Application Examples in 2026 https://swovo.com/blog/electron-js-desktop-application-examples-in-2024/
[8] What Is ElectronJS and When to Use It [Key Insights for 2025] https://brainhub.eu/library/what-is-electron-js
[9] Introduction to ElectronJS https://www.geeksforgeeks.org/javascript/introduction-to-electronjs/
[10] what is Electron and why does it seems like everyone ... https://www.reddit.com/r/webdev/comments/rojn8w/newbie_question_what_is_electron_and_why_does_it/
[11] Best Electron JS Courses & Certificates [2026] | Coursera https://www.coursera.org/courses?query=electron+js
[12] ElectronJS | Online Courses, Learning Paths, and Certifications https://www.pluralsight.com/professional-services/software-development/electronjs

---

### Development Environment Setup

To develop Electron applications, you need to install Node.js and configure your project with the necessary tools and dependencies.[1][2]

#### Prerequisites

**Node.js and npm Installation**
- Install the latest Long-Term Support (LTS) version of Node.js from nodejs.org[3][1]
- npm (Node Package Manager) comes bundled with Node.js automatically[1]
- On macOS, use package managers like Homebrew or nvm to avoid directory permission issues[2][1]
- Verify installation by running `node -v` and `npm -v` in your terminal to check installed versions[1]

**Code Editor**
- Install a code editor such as Visual Studio Code, Atom, or any editor you prefer[4]
- VS Code is commonly recommended for JavaScript development[4]

#### Project Initialization

**Create Project Directory**
- Create a new folder for your Electron project and navigate to it in the terminal[3]
- Run `npm init -y` to initialize a new Node.js project and generate package.json[5][3]
- The package.json file will manage your project's dependencies and configuration[3]

**Install Electron**
- Install Electron as a development dependency using: `npm install electron --save-dev`[6][7][3]
- Alternatively, use Yarn: `yarn add electron --dev`[6]
- Electron will be added to the `devDependencies` section of your package.json[6]
- Ensure the `postinstall` lifecycle script runs correctly (avoid using `--ignore-scripts` flag)[6]

**Package Manager Considerations**
- For Yarn 3 users: Add `nodeLinker: "node-modules"` to `.yarnrc.yaml` file[8][6]
- For pnpm users: Set `nodeLinker: hoisted` in configuration[6]
- These settings ensure proper module installation for Electron[6]

#### Configuration

**Package.json Setup**
- Add a `start` script to the `scripts` section: `"start": "electron ."`[5]
- Specify the entry point in the `main` property (typically `main.js` or `index.js`)[6]
- This configuration allows you to run your app using `npm start`[5]

**Important Note**
- While Node.js is required for development, Electron bundles its own Node.js runtime[2][1]
- End users do not need Node.js installed to run your packaged application[2][1]

Sources
[1] Prerequisites https://electronjs.org/docs/latest/tutorial/tutorial-prerequisites
[2] Prerequisites https://www.electronjs.org/docs/latest/tutorial/tutorial-prerequisites
[3] How to Use Electron.js to Create Cross-Platform Desktop ... https://dev.to/abdulrafaykhan_dev/how-to-use-electronjs-to-create-cross-platform-desktop-applications-7ol
[4] How to Use Electron.js for Building Desktop Applications ... https://dev.to/bellatrick/how-to-use-electronjs-for-building-desktop-applications-with-javascript-html-and-css-4kpn
[5] How To Create Your First Cross-Platform Desktop ... https://www.digitalocean.com/community/tutorials/how-to-create-your-first-cross-platform-desktop-application-with-electron-on-macos
[6] Building your First App https://electronjs.org/docs/latest/tutorial/tutorial-first-app
[7] electron https://www.npmjs.com/package/electron
[8] electron-builder https://www.electron.build/index.html
[9] Electron Desktop App Development Guide for Business in 2026 https://www.forasoft.com/blog/article/electron-desktop-app-development-guide-for-business
[10] How to include Chrome DevTools in Electron? https://stackoverflow.com/questions/30294600/how-to-include-chrome-devtools-in-electron

---

### Project Initialization with npm

Electron projects are scaffolded using npm, with package.json serving as the configuration entry point. The initialization process sets up the project structure and necessary dependencies.[1]

#### Creating and Initializing the Project

**Create Project Directory**
- Create a new folder for your Electron application: `mkdir my-electron-app && cd my-electron-app`[1]
- Navigate into the directory using your terminal[1]

**Run npm init**
- Execute `npm init` to initialize a new npm package[2][1]
- Alternatively, use `npm init -y` to skip the prompts and generate a default package.json automatically[2]
- The command will prompt you to configure several fields in your package.json file[1]

#### Package.json Configuration

**Entry Point Setup**
- Set the `main` field to `main.js` (or your preferred entry point filename)[3][1]
- This specifies which JavaScript file Electron will execute when starting your app[1]
- The entry point file contains your main process code[1]
- Example: `"main": "main.js"` or `"main": "dist/main.js"` if using a build folder[4][3]

**Add Start Script**
- In the `scripts` section, add: `"start": "electron ."`[1]
- This allows you to run your app using `npm start` command[1]
- The period (.) tells Electron to look for the entry point specified in the `main` field[1]

**Install Electron Dependency**
- Run `npm install electron --save-dev` to add Electron to your project[2][1]
- Electron will be added to the `devDependencies` section of package.json[1]
- A `node_modules` folder will be created containing Electron and its dependencies[1]

#### Alternative Initialization Methods

**Using Electron Forge**
- Use `npx create-electron-app my-app` for a pre-configured project setup[5]
- Electron Forge provides scaffolding with bundling support and module ecosystem[5]

**Using Quick Start Templates**
- Run `npm create @quick-start/electron` for template-based initialization[6]
- Follow prompts to select frameworks like Vue, React, or vanilla JavaScript[6]
- Also available with Yarn (`yarn create @quick-start/electron`) or pnpm (`pnpm create @quick-start/electron`)[6]

#### Final Package.json Structure

Your package.json should include the entry point, start script, and Electron in devDependencies. The Electron executable runs the JavaScript entry point specified in the `main` property during development.[1]

Sources
[1] Building your First App https://electronjs.org/docs/latest/tutorial/tutorial-first-app
[2] How to Use Electron.js to Create Cross-Platform Desktop ... https://dev.to/abdulrafaykhan_dev/how-to-use-electronjs-to-create-cross-platform-desktop-applications-7ol
[3] Change electron-builder entrypoint to main.js or resolve missing ... https://github.com/electron-userland/electron-builder/issues/8041
[4] I got "Error: packageJSON.main must be set to a valid entry point for ... https://stackoverflow.com/questions/70680280/i-got-error-packagejson-main-must-be-set-to-a-valid-entry-point-for-your-elect
[5] Electron Forge: Getting Started https://www.electronforge.io
[6] @quick-start/create-electron - npm https://www.npmjs.com/package/@quick-start/create-electron
[7] Electron: Build cross-platform desktop apps with JavaScript ... https://electronjs.org
[8] Advanced Installation Instructions https://electronjs.org/docs/latest/tutorial/installation
[9] Source Code Directory Structure https://electronjs.org/docs/latest/development/source-code-directory-structure
[10] electron-app/docs/STRUCTURE.md at main https://github.com/daltonmenezes/electron-app/blob/main/docs/STRUCTURE.md

---

### Package.json Configuration

The package.json file serves as the configuration manifest for Electron applications, defining metadata, dependencies, scripts, and build settings.[1][2]

#### Essential Fields

**Basic Metadata**
- `name`: The application name (required field)[2]
- `version`: Current version of your application (e.g., "1.0.0")[3][4]
- `description`: Brief description of what your application does[3]
- `author`: Developer or company name[5][2]
- `license`: Software license identifier (e.g., "MIT", "ISC", or "UNLICENSED" for proprietary code)[6][2]

**Entry Point and Scripts**
- `main`: Specifies the entry point JavaScript file for the main process (typically "main.js")[7][1]
- `scripts`: Contains npm commands for running and building your app[1]
  - `"start": "electron ."` - Launches the Electron app in development mode[1]
  - Build scripts for packaging and distribution[8]

**Repository Information**
- `repository`: Git repository URL or object containing type and URL[2]
- `homepage`: Project homepage or documentation URL[3]

#### Dependencies

**devDependencies**
- Contains Electron and build tools needed only during development[1][3]
- Example: `"electron": "^28.0.0"`, `"electron-builder": "^24.0.0"`[1]
- Not included in the final packaged application[3]

**dependencies**
- Production dependencies that will be bundled with your application[9][3]
- Include runtime libraries and modules needed by the app[3]

**Single vs Two Package.json Structure**
- Modern Electron projects typically use a single package.json at the root[9][3]
- Two package.json structure (one at root, one in /app) is deprecated as of electron-builder v8+[9]
- Single structure simplifies dependency management and version synchronization[9][3]

#### Build Configuration

**electron-builder Settings**
- Add a `build` key at the top level of package.json for packaging configuration[2]
- `appId`: Unique identifier in reverse-DNS notation (e.g., "com.example.myapp")[2]
- `productName`: Human-readable application name shown to users[9]
- `copyright`: Copyright notice (defaults to "Copyright © year ${author}")[2]
- `files`: Array specifying which files to include in the packaged app[2][9]

**Privacy and Publishing**
- `private`: Set to `true` to prevent accidental publication to npm registry[6]

#### Example Configuration

A typical Electron package.json includes the entry point, start script, metadata fields, Electron in devDependencies, and optional build configuration for electron-builder.[1][9][2]

Sources
[1] Building your First App | Electron https://electronjs.org/docs/latest/tutorial/tutorial-first-app
[2] Common Configuration - electron-builder https://www.electron.build/configuration.html
[3] Confused by 2 package.json structure · Issue #600 - GitHub https://github.com/electron-userland/electron-builder/issues/600
[4] How to provide the package.json version to an electron ... https://stackoverflow.com/questions/79294349/how-to-provide-the-package-json-version-to-an-electron-app-tsc-options
[5] How to edit package.json 'author' field when porting a library? https://www.reddit.com/r/node/comments/tyjrqa/how_to_edit_packagejson_author_field_when_porting/
[6] What should I put in the license field of package.json if my ... https://stackoverflow.com/questions/32214751/what-should-i-put-in-the-license-field-of-package-json-if-my-code-is-only-for-us
[7] Building your First App https://www.electronjs.org/docs/latest/tutorial/tutorial-first-app
[8] How can I set up electron-builder.js in my project's directory? https://stackoverflow.com/questions/72952943/how-can-i-set-up-electron-builder-js-in-my-projects-directory
[9] Should the project move away from the 2 package.json structure? https://github.com/electron-react-boilerplate/electron-react-boilerplate/issues/1827
[10] Application Packaging | Electron https://electronjs.org/docs/latest/tutorial/application-distribution

---

### Installing Electron as Dev Dependency

Electron must be installed as a development dependency using the `--save-dev` flag, which adds it to the `devDependencies` section of package.json.[1][2]

#### Installation Commands

**Using npm**
- `npm install electron --save-dev`[2][3][1]
- Short form: `npm i -D electron@latest`[4]
- Optional: Add `--save-exact` flag for versions prior to 2.0 (not needed for v2.0+)[5]

**Using Yarn**
- `yarn add electron --dev`[6][7]

**Using pnpm**
- `pnpm add electron --save-dev`[6]

#### Why DevDependency and Not Dependency?

**Packaging Behavior**
- Build tools like electron-builder automatically package Electron with your app regardless of whether it's in `dependencies` or `devDependencies`[4]
- The packaged application includes the entire Electron runtime during the build process[4]
- End users don't need Electron installed separately because it's bundled into the executable[4]

**Build Tool Requirements**
- electron-builder explicitly enforces that Electron must only be in `devDependencies`[8]
- Attempting to list Electron in `dependencies` will cause build errors: "Package 'electron' is only allowed in 'devDependencies'"[8]
- This is the standard practice followed by major projects like VS Code[8]

**Development vs Production**
- Electron is needed during development to run and test your app[9]
- During packaging, the builder creates a standalone executable with Electron embedded[4]
- `devDependencies` are not installed when users run `npm install --production`, which is appropriate since they receive the pre-packaged binary[4]

#### How Installation Works

When you run the install command, npm detects your operating system and downloads a prebuilt Electron binary compiled for your system's architecture. This precompiled binary has been available since Electron version 1.3.1, eliminating the need for compilation during installation.[3]

#### Package Manager Special Configurations

For Yarn 3 users, add `nodeLinker: "node-modules"` to `.yarnrc.yaml` because electron-builder requires node_modules structure instead of Yarn's default Plug'n'Play (PnP).[7][6]

Sources
[1] electron - NPM https://www.npmjs.com/package/electron
[2] Advanced Installation Instructions https://www.electronjs.org/docs/latest/tutorial/installation
[3] npm install electron https://www.electronjs.org/blog/npm-install-electron
[4] Should I install Electron as a dependency or a devDependency for distribution? https://stackoverflow.com/questions/60894994/should-i-install-electron-as-a-dependency-or-a-devdependency-for-distribution
[5] electron https://www.npmjs.com/package/electron/v/9.0.0
[6] electron-builder https://www.electron.build/index.html
[7] electron-builder - Yarn Classic https://classic.yarnpkg.com/en/package/electron-builder
[8] Package "electron" is only allowed in "devDependencies". Please remove it from the "dependencies" · Issue #7191 · electron-userland/electron-builder https://github.com/electron-userland/electron-builder/issues/7191
[9] Why does Electron need to be saved as a developer dependency? https://stackoverflow.com/questions/50803207/why-does-electron-need-to-be-saved-as-a-developer-dependency/50803712
[10] NPM installation of electron appears to be stuck? https://www.reddit.com/r/electronjs/comments/ehdcs6/npm_installation_of_electron_appears_to_be_stuck/

---

### Entry Point File (main.js) Structure

The main.js file serves as the entry point for Electron applications and controls the main process, which runs in a Node.js environment. This file manages application lifecycle, window creation, and system-level operations.[1][2]

#### Basic Structure Components

**Module Imports**
- Import Electron modules at the top: `const { app, BrowserWindow } = require('electron')`[2][3]
- Import additional Node.js modules as needed (path, fs, etc.)[4]
- The `app` module controls application lifecycle[3][5]
- The `BrowserWindow` class creates application windows[6][2]

**Window Creation Function**
- Define a `createWindow()` function to instantiate BrowserWindow[5][1][3]
- Configure window properties (width, height, webPreferences) in the constructor options[2][6]
- Load content using `win.loadFile('index.html')` for local files or `win.loadURL()` for remote URLs[6][2]
- Example: `const win = new BrowserWindow({ width: 800, height: 600 })`[2][6]

**Application Lifecycle Events**
- Call `app.whenReady().then(() => { createWindow() })` to create windows after app initialization[1]
- BrowserWindows can only be created after the app module's `ready` event is emitted[1][6][2]
- Alternative syntax: `app.on('ready', createWindow)`[3][5]
- Use `app.whenReady()` helper to avoid subtle pitfalls with direct event listening[1]

**Platform-Specific Window Management**
- Handle different OS behaviors using `process.platform` checks[1]
- Three possible platforms: `win32` (Windows), `linux` (Linux), `darwin` (macOS)[1]
- Listen to events from app and BrowserWindow modules to implement platform conventions[1]

#### Event Handlers

**Window Lifecycle Management**
- Monitor window events to control application behavior[6][1]
- Use `ready-to-show` event to prevent visual flash when displaying windows[6]
- Example: `win.once('ready-to-show', () => { win.show() })` with initial `show: false` option[6]

**Process Organization**
- Main process files reside in dedicated folders (e.g., `src/main`)[7]
- Preload scripts in separate directory for IPC context bridge setup[7]
- Renderer process files (HTML, CSS, frontend JS) organized separately[7]

The main.js structure follows an event-driven architecture where the app module emits lifecycle events, and BrowserWindow instances are created and managed in response to these events.[3][1]

Sources
[1] Building your First App | Electron https://electronjs.org/docs/latest/tutorial/tutorial-first-app
[2] BrowserWindow https://www.electronjs.org/docs/latest/api/browser-window
[3] Trying Out Electron JS - DEV Community https://dev.to/99darshan/trying-out-electron-js-1i7h
[4] Save Files in ElectronJS - GeeksforGeeks https://www.geeksforgeeks.org/javascript/save-files-in-electronjs/
[5] Create an electron app from Scratch | by Ankit Lalan - Dev Genius https://blog.devgenius.io/create-an-electron-app-from-scratch-3b7e5b63d00f
[6] electron/docs/api/browser-window.md at main · electron/electron https://github.com/electron/electron/blob/main/docs/api/browser-window.md
[7] electron-app/docs/STRUCTURE.md at main - GitHub https://github.com/daltonmenezes/electron-app/blob/main/docs/STRUCTURE.md
[8] How should I structure my Electron App? : r/electronjs - Reddit https://www.reddit.com/r/electronjs/comments/gdql2w/how_should_i_structure_my_electron_app/
[9] Confused about how to structure an Electron app - Stack Overflow https://stackoverflow.com/questions/62810850/confused-about-how-to-structure-an-electron-app
[10] File Manager Electronjs application example - Dustin Pfister https://dustinpfister.github.io/2022/11/25/electronjs-example-file-manager/


---

### Running Electron Applications

Electron applications are executed in development mode using npm scripts or direct CLI commands. The standard approach uses the npm start command configured in package.json.[1][2]

#### Using npm Start

**Standard Method**
- Run `npm start` in your project directory[2][3]
- This executes the script defined in package.json: `"start": "electron ."`[3][1]
- The period (`.`) tells Electron to look for the entry point specified in the `main` field of package.json[1][2]
- This is the recommended method for development[2]

**Using Yarn**
- Execute `yarn start` if using Yarn package manager[2]
- Functions identically to npm start[2]

#### Direct Electron Commands

**Using npx**
- Run `npx electron .` from your project root[4]
- The `npx` command executes packages from node_modules without typing the full path[4]
- Available in newer versions of npm[4]

**Using Local Binary**
- Execute `./node_modules/.bin/electron .` for direct access to the local Electron binary[4]
- This is the full path that npm start internally calls[4]
- Works without setting up npm scripts[4]

**Global Installation Method**
- Install Electron globally: `npm install electron -g`[4]
- Run `electron main.js` or `electron .` directly from command line[4]
- Not recommended for production projects as it creates version inconsistencies across environments[5][4]

#### Development Mode Characteristics

**How It Works**
- The `electron .` command runs Electron in development mode[1][2]
- Electron looks for the main script file specified in package.json's `main` field[1]
- The application will throw an error if no valid entry point is found[2]
- Local dependencies from node_modules are used instead of global installations[5]

**Development Tools**
- Electron apps in development mode have access to Chrome DevTools for debugging[6]
- Hot reload and file watching can be configured with additional tools like electron-run[7]
- electron-run can detect code changes and prompt for app restart during development[7]

#### Running with TypeScript

**Using electron-run**
- Install `electron-run` for TypeScript support: `npm i electron-run`[7]
- Automatically transpiles TypeScript main process code[7]
- Saves transformed code to `node_modules/.electron-run`[7]
- Supports automatic reload prompts when code changes[7]

#### Prerequisites for Running

Before running your Electron app, ensure your project has a valid package.json with the `main` field pointing to your entry file, and a start script configured in the scripts section.[3][1][2]

Sources
[1] Building your First App https://www.electronjs.org/docs/latest/tutorial/tutorial-first-app
[2] Quick Start | Electron https://www.electronjs.org/docs/latest/tutorial/quick-start/
[3] Why doesn't npm start run electron app? https://stackoverflow.com/questions/44370512/why-doesnt-npm-start-run-electron-app
[4] After npm reads package.json, what runs Electron? https://stackoverflow.com/questions/55115019/after-npm-reads-package-json-what-runs-electron
[5] Getting started ... or not? · Issue #5386 · electron/electron https://github.com/electron/electron/issues/5386
[6] Add a command line arg to cli to detect development mode https://github.com/electron-userland/electron-prebuilt/issues/116
[7] electron-run https://www.npmjs.com/package/electron-run
[8] How to execute an exe file (System application) using ... https://ourcodeworld.com/articles/read/154/how-to-execute-an-exe-file-system-application-using-electron-framework
[9] Electron Build Commands https://quasar.dev/quasar-cli-vite/developing-electron-apps/build-commands/
[10] Run cmd.exe and make some command with Electron.js https://stackoverflow.com/questions/57054359/run-cmd-exe-and-make-some-command-with-electron-js

---

### Electron Forge Toolkit Introduction

Electron Forge is an all-in-one official tool for packaging, building, and distributing Electron applications. Developed by the Electron maintainers, it unifies the build tooling ecosystem into a single extensible interface that works out of the box.[1][3][5][6]

#### What Electron Forge Provides

**Core Features**
- Application packaging and code signing[5][7]
- Platform-specific installers for Windows, macOS, and Linux (DMG, deb, MSI, PKG, AppX)[9][5]
- Automated publishing flow for cloud providers (GitHub, S3, Bitbucket)[5]
- Native Node.js module rebuilding using @electron/rebuild[2][6][9]
- Universal macOS builds via @electron/universal[7][9]
- Easy-to-use boilerplate templates with webpack and Vite support[7][5]
- Extensible JavaScript plugin API for custom build logic[1][5]

#### Why Use Electron Forge

**Simplified Workflow**
- Combines multiple single-purpose tools (electron-packager, electron-rebuild, @electron/osx-sign) into one cohesive package[9][1]
- Eliminates the need to manually configure and integrate separate build tools[2][9]
- Provides a unified workflow from project setup through packaging to distribution[6][2]
- Handles complex tasks like native module rebuilding automatically[2]

**Beginner-Friendly**
- Simplifies the entire Electron development process with sensible defaults[6][2]
- Requires minimal configuration to get started[6]
- Everything "just works" out of the box[6]

**Official and Up-to-Date**
- Maintained by the Electron organization since version 6 (moved from electron-userland in 2022)[10][5]
- Receives new features as soon as they're supported in Electron (ASAR integrity, universal builds)[9]
- Built with first-party Electron tooling in mind[9]

#### Project Goals

Electron Forge follows three core principles: making Electron development start with a single command, ensuring build tooling works automatically without manual setup, and handling the entire lifecycle from creation to release through one core dependency.[6]

#### Architecture

**Multi-Package Design**
- Composed of smaller packages with clear responsibilities[5][9]
- Makes code flow easier to follow and understand[5][9]
- Extensible API allows custom plugins, makers, and publishers for advanced use cases[1][5]

#### Getting Started

Create a new Electron project with templates using `npx create-electron-app my-app`. The CLI supports templates for webpack, Vite, TypeScript, and popular frameworks like React and Angular.[7][1][2]

#### Forge vs Electron Builder

While electron-builder is a feature-rich alternative, Electron Forge is the official Electron build tool and is generally more beginner-friendly. Forge handles build complexities and provides a streamlined workflow covering the entire development lifecycle.[10][2]

Sources
[1] Electron Forge: Getting Started https://www.electronforge.io
[2] The Ultimate Guide to React Electron Forge: A Step-by-Step Tutorial https://www.dhiwise.com/post/the-ultimate-guide-to-react-electron-forge
[3] Distributing Apps With Electron Forge https://www.electronjs.org/docs/latest/tutorial/forge-overview
[4] 使用 Electron Forge 分发应用 | Electron 中文网 https://electron.nodejs.cn/docs/latest/tutorial/forge-overview/
[5] Introducing Electron Forge 6 | Electron https://www.electronjs.org/blog/forge-v6-release
[6] GitHub - electron/forge: :electron: A complete tool for building and publishing Electron applications https://github.com/electron/forge
[7] Introduction to Electron Forge | Mamezou Developer Portal https://developer.mamezou-tech.com/en/blogs/2024/01/29/electron-forge-introduction/
[8] electron-forge https://www.npmjs.com/package/electron-forge
[9] Why Electron Forge? https://www.electronforge.io/core-concepts/why-electron-forge
[10] Electron Forge https://electron-vite.github.io/faq/electron-forge.html


---

# Core Concepts

### Main Process vs Renderer Process

Electron uses a multi-process architecture inherited from Chromium that separates application logic into two distinct types of processes: main and renderer. This architectural design improves performance, stability, and security by isolating processes.[1][7]

#### Main Process

**Role and Responsibilities**
- Runs the entry point script specified in package.json (typically main.js)[4]
- Controls the entire application lifecycle and manages all BrowserWindow instances[5][1]
- Creates web pages by instantiating BrowserWindow objects[7][5]
- Accesses native operating system APIs for menus, dialogs, notifications, system tray, and global shortcuts[6][1]
- Manages platform infrastructure code and system-level operations[1]
- Only one main process exists per Electron application[3][1]

**Process Type**
- When you call `process.type` in the main process, it returns "browser"[4]
- Console logs from the main process appear in the terminal running the app[6][4]
- All files required from main.js run in the main process[4]

#### Renderer Process

**Role and Responsibilities**
- Each BrowserWindow instance spawns its own separate renderer process[5][7]
- Responsible for rendering web content (HTML, CSS, JavaScript) using Chromium[7]
- Runs application-specific code (what your app actually does)[1]
- Behaves according to web standards and has access to web APIs[7]
- JavaScript files included from index.html or other HTML documents run in the renderer process[4]

**Process Type**
- When you call `process.type` in a renderer process, it returns "renderer"[4]
- Console logs from renderer processes appear in Chromium's DevTools, not the terminal[6][4]

**Process Isolation**
- Multiple renderer processes can run simultaneously, one for each window[3][5]
- Each renderer process is isolated and doesn't interfere with other renderer processes[3][5]
- A crash in one renderer process does not affect other renderer processes or the main process[5]
- Renderer processes are independent—they don't share resources or state[1]

#### Key Differences

**Separation of Concerns**
- Main process: Platform infrastructure (window creation, native APIs, system integration)[1]
- Renderer process: Application logic and UI rendering[2][1]
- This is a "hard" separation—processes run independently and don't share state by default[1]

**Resource Access**
- Node.js modules are available in both processes, but state isn't shared between them[1]
- If you set state in a module in the main process, requiring that same module in a renderer creates an entirely different instance without that state[1]
- Calling native GUI-related APIs directly from renderer processes is restricted for security reasons[5]

**Performance Considerations**
- CPU-intensive work shouldn't run in the main process as it will block all renderer processes[1]
- Heavy processing shouldn't run in the UI renderer either as it locks up the interface[1]
- For intensive tasks, use invisible renderer windows or worker processes[1]

#### Inter-Process Communication (IPC)

Since processes are isolated, Electron provides IPC mechanisms (ipcMain and ipcRenderer) to enable communication between main and renderer processes. This allows renderer processes to request that the main process perform privileged operations like creating new windows, accessing native APIs, or using Node.js modules securely.[5][4]

Sources
[1] Distinction between the renderer and main processes in Electron https://stackoverflow.com/questions/37669727/distinction-between-the-renderer-and-main-processes-in-electron
[2] Main vs Renderer Process | Tuui https://www.tuui.com/electron-how-to/main-and-renderer-process
[3] Electron js Tutorial - 3 - Main and Renderer Process https://www.youtube.com/watch?v=yeYiuUONO9I
[4] Main process and Renderer process in Electron https://www.christianengvall.se/main-and-renderer-process-in-electron/
[5] Electron - Why do we need to communicate between the main process and the renderer processes? https://stackoverflow.com/questions/67344365/electron-why-do-we-need-to-communicate-between-the-main-process-and-the-render
[6] Electron js tutorial for beginners  #3 Main and Render Process https://www.youtube.com/watch?v=Z2IzeYiN310
[7] Process Model https://www.electronjs.org/docs/latest/tutorial/process-model
[8] Any reason not to put all logic in the renderer and use Electron only to launch window? https://www.reddit.com/r/electronjs/comments/10m92uo/any_reason_not_to_put_all_logic_in_the_renderer/
[9] main -> renderer communication - Help me understand the syntax, please. https://www.reddit.com/r/electronjs/comments/13mcc3v/main_renderer_communication_help_me_understand/
[10] Main Process & Renderer Overview - Electron, v3 https://frontendmasters.com/courses/electron-v3/main-process-renderer-overview/

---

### Chromium and Node.js Integration

Electron combines Chromium (the open-source rendering engine behind Google Chrome) and Node.js runtime into a single binary, enabling web technologies to build native desktop applications. This integration merges web platform capabilities with operating system-level access in one unified environment.[1][2][3]

#### How the Integration Works

**Embedding Architecture**
- Electron embeds both Chromium and Node.js into its binary distribution[4][1]
- Chromium handles the rendering of HTML, CSS, and JavaScript for the user interface[2][3]
- Node.js provides backend runtime capabilities and access to system-level APIs[5][2]
- The integration creates a "single context" where both technologies work together without requiring tools like Browserify[6]

**Process Model**
- The main process is essentially a Node.js process that runs on startup[7]
- Chromium's browser process executes a Node.js module at initialization[7]
- Renderer processes (running Chromium) can access Node.js modules by calling `require()`[7]
- This architecture inherits Chromium's multi-process model with added Node.js integration[8][7]

#### Benefits of Integration

**Unified Development Environment**
- Write both frontend UI and backend logic using JavaScript[3][2]
- Access web APIs and HTML5 features through Chromium[4]
- Access file system, operating system features, and native modules through Node.js[2][5]
- Use any package from the npm ecosystem or write custom native add-ons[1]

**Cross-Platform Consistency**
- Chromium provides a stable, consistent rendering target across all platforms[1][4]
- Eliminates browser compatibility issues and heterogeneous UI landscapes[4]
- Apps run identically on macOS, Windows, and Linux without platform-specific code[1]

**Modern Web Platform Features**
- Bundled Chromium ensures access to the newest web platform features[1]
- Regular updates synchronized with Chromium releases provide security fixes immediately[1]
- Developers can build for a single browser target (Chromium) instead of multiple browsers[3][4]

#### How Chromium and Node.js Communicate

**Shared JavaScript Context**
- Both Chromium and Node.js share the same JavaScript runtime environment in renderer processes[6]
- Node.js modules can be required directly from renderer process code[7]
- No need for separate bundling or transformation tools to bridge the two environments[6]

**Separation in Main Process**
- The main process runs pure Node.js code for application lifecycle management[8][7]
- Renderer processes run Chromium with Node.js integration for UI and logic[8][7]

#### Technical Components

Electron's framework consists of three core components: Chromium's rendering library (Libchromiumcontent), the Node.js JavaScript runtime, and a JavaScript engine written in C++. These components work together to execute application code without requiring a web server—files are prepackaged with the app and interpreted locally by Node.js and Chromium.[2][3]

#### Trade-offs

While this integration provides powerful capabilities, Electron apps consume more resources than native implementations because they embed entire Chromium and Node.js environments. However, continuous improvements are working to mitigate these concerns and enhance performance efficiency.[4]

Sources
[1] Electron: Build cross-platform desktop apps with JavaScript ... https://electronjs.org
[2] What is Electron.js? | How Does Electron Work https://www.axon.dev/blog/what-is-electron-js-how-does-electron-work
[3] ElectronJS - User Guide to Build Cross-Platform Applications https://www.ideas2it.com/blogs/introduction-to-building-cross-platform-applications-with-electron
[4] Advanced Electron.js architecture https://blog.logrocket.com/advanced-electron-js-architecture/
[5] How to Use Electron.js to Create Cross-Platform Desktop ... https://dev.to/abdulrafaykhan_dev/how-to-use-electronjs-to-create-cross-platform-desktop-applications-7ol
[6] What does it mean for Electron to combine Node.js and ... https://stackoverflow.com/questions/38166617/what-does-it-mean-for-electron-to-combine-node-js-and-chromium-contexts
[7] The Electron process architecture is the Chromium process ... https://jameshfisher.com/2020/10/14/the-electron-process-architecture-is-the-chromium-process-architecture/
[8] Electron vs Node.js: Best Pick for 2025 Cross-Platform ... https://www.index.dev/blog/electron-vs-nodejs
[9] Loading Nodejs Module at runtime in electron app https://stackoverflow.com/questions/62405815/loading-nodejs-module-at-runtime-in-electron-app
[10] What does it mean for Electron to combine Node.js and Chromium contexts? https://stackoverflow.com/questions/38166617/what-does-it-mean-for-electron-to-combine-node-js-and-chromium-contexts/38166865


---

### Application Lifecycle Management

The main process controls your application's lifecycle through Electron's `app` module, which provides events and methods to manage application startup, window behavior, and shutdown. The app module is a core component that runs exclusively in the main process.[1][2][3][4][5]

#### Key Lifecycle Events

**ready**
- Emitted when Electron has finished initialization[2][5]
- BrowserWindows can only be created after this event fires[2]
- Use `app.whenReady()` to get a Promise that fulfills when Electron is initialized[6][2]
- Alternative: `app.on('ready', callback)` or check `app.isReady()`[6][2]
- The ready event fires only after the main process finishes running the first tick of the event loop[2][6]

**window-all-closed**
- Emitted when all windows have been closed[7][6][2]
- Default behavior: quit the app if you don't subscribe to this event[5][7][2]
- By subscribing to this event, you control whether the app quits or stays open[7][2]
- Platform-specific handling: macOS apps typically remain active until the user explicitly quits (Cmd + Q)[8]
- Not emitted if the user pressed Cmd + Q or developer called `app.quit()`[5][7][2]

**activate** (macOS-specific)
- Emitted when the application is activated from the dock[8]
- Used to recreate windows when the dock icon is clicked but no windows are open[8]

**did-become-active** (macOS-specific)
- Emitted every time the app becomes active[6][2]
- Different from `activate`: fires on all activations, not just dock icon clicks[2][6]
- Also emitted when switching to the app via macOS App Switcher[6][2]

**before-quit**
- Emitted before the application starts closing its windows[7][2][6]
- Call `event.preventDefault()` to prevent application termination[7][2][6]
- If quit was initiated by `autoUpdater.quitAndInstall()`, `before-quit` is emitted after closing all windows[2][6]
- Not emitted on Windows if the app is closed due to system shutdown/restart or user logout[6][2]

**will-quit**
- Emitted when all windows have been closed and the application will quit[7][2][6]
- Call `event.preventDefault()` to prevent default termination behavior[2][6][7]
- Not emitted on Windows if the app is closed due to system shutdown/restart or user logout[6][2]

**quit**
- Emitted when the application is quitting[9]
- Final event in the lifecycle sequence[9]

#### Lifecycle Methods

**app.quit()**
- Attempts to close all windows[10][2][6]
- Emits `before-quit` event first, then closes windows[10]
- If all windows successfully close, emits `will-quit` event and terminates the app by default[10][7]
- Guarantees that `beforeunload` and `unload` event handlers execute correctly[10][7]
- A window can cancel quitting by returning false in the `beforeunload` handler[7]

**app.relaunch()**
- Relaunches the app when current instance exits[2][6]
- Does not automatically quit the app—you must call `app.quit()` or `app.exit()` manually[6][2]
- Calling multiple times creates multiple instances[2][6]

#### Platform-Specific Behavior

**macOS Edge Cases**
- Keep the app open without windows: listen to `window-all-closed` without calling `app.quit()`[8]
- Open new window when activated from dock: listen to `activate` event and call `createWindow()` if no windows exist[8]

#### Example Lifecycle Management

A typical lifecycle implementation listens for `ready` to create windows, handles `window-all-closed` to quit on Windows/Linux but stay active on macOS, and responds to `activate` on macOS to recreate windows.[3][8][2]

Sources
[1] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[2] app https://electronjs.org/docs/latest/api/app
[3] Building your First App https://electronjs.org/docs/latest/tutorial/tutorial-first-app
[4] Electron js tutorial for beginners # Important App life cycle ... https://www.youtube.com/watch?v=ECq-mMdKepc
[5] app | FAQ https://imfly.github.io/electron-docs-gitbook/en/api/app.html
[6] app | Electron https://www.electronjs.org/docs/latest/api/app
[7] app · Electron documentation https://tinydew4.gitbooks.io/electron/api/app.html
[8] Create a Todo List app with Electron, JavaScript and AG Grid https://blog.ag-grid.com/using-ag-grid-in-electron-applications/
[9] Managing Application Lifecycle — Electron | Bsmarted https://bsmarted.com/en/topics/electron/managing-application-lifecycle
[10] Closing all app windows when using Electron - Stack Overflow https://stackoverflow.com/questions/44589278/closing-all-app-windows-when-using-electron


---

### BrowserWindow Creation and Configuration

BrowserWindow is Electron's class for creating and controlling browser windows, available only in the main process. Each BrowserWindow instance creates a new window with properties defined through constructor options.[1][2][3][4]

#### Creating a BrowserWindow

**Basic Syntax**
- Import the BrowserWindow class: `const { BrowserWindow } = require('electron')`[2][3][5]
- Instantiate with `new BrowserWindow([options])` where options is an optional configuration object[1][2]
- Must be created in the main process, not renderer processes[6]
- Can only be created after the `app.whenReady()` event fires[7][8]

**Simple Example**
```javascript
const win = new BrowserWindow({ width: 800, height: 600 })
```


#### Window Configuration Options

**Dimension Options**
- `width` (Integer): Window's width in pixels (default: 800)[6][1]
- `height` (Integer): Window's height in pixels (default: 600)[1][6]
- `minWidth` / `minHeight`: Minimum window dimensions[1]
- `maxWidth` / `maxHeight`: Maximum window dimensions[1]

**Display Options**
- `show` (Boolean): Whether window should be shown when created (default: true)[3][1]
- Setting `show: false` allows you to control when the window appears using `win.show()`[3]
- Useful to prevent visual flash during window initialization[3]

**Frame and Chrome Options**
- `frame` (Boolean): Whether to show window frame (default: true)[1]
- Setting `frame: false` creates a frameless window without chrome[3][1]
- Frameless windows allow custom window controls[3]

**Parent-Child Relationships**
- `parent` (BrowserWindow): Specify a parent window to create child windows[1]
- Child windows always show on top of their parent[1]

#### webPreferences Configuration

The `webPreferences` object is the most critical configuration section for security and functionality.[9][7]

**Context Isolation**
- `contextIsolation` (Boolean): Should be set to `true` for security best practices[7]
- Isolates Electron APIs from web content loaded in the window[7]
- Required by some plugins and security-conscious applications[7]

**Preload Scripts**
- `preload` (String): Path to a script that runs before the renderer process loads[7]
- Provides a secure way to expose APIs to the renderer[7]
- Example: `webPreferences: { preload: path.join(__dirname, 'preload.js') }`[7]

**Node Integration**
- `nodeIntegration` (Boolean): Whether to enable Node.js APIs in the renderer (default: false)[1]
- Should generally remain `false` for security reasons[1]

**Multiple webPreferences**
When setting multiple webPreferences options, pass them as properties of the webPreferences object:[7]
```javascript
new BrowserWindow({
  webPreferences: {
    contextIsolation: true,
    preload: './my-preload.js',
    additionalArguments: '--my-argument'
  }
})
```


#### Loading Content

**Load Local Files**
- `win.loadFile('index.html')` for local HTML files[7]
- `win.loadURL(\`file://${__dirname}/app/index.html\`)` using file:// protocol[5]

**Load Remote URLs**
- `win.loadURL('https://github.com')` for web content[5][3]

#### Opening Windows from Renderer

Windows can be created from renderer processes using `window.open()`, but customization requires `webContents.setWindowOpenHandler()` in the main process. BrowserWindow constructor options for renderer-created windows are set through this handler with increasing precedence.[9]

#### Inheritance

BrowserWindow extends BaseWindow, which provides fundamental window creation and control capabilities. Built-in Electron classes like BrowserWindow cannot be subclassed in user code.[4][2]

Sources
[1] BrowserWindow | FAQ - GitHub Pages https://imfly.github.io/electron-docs-gitbook/en/api/browser-window.html
[2] BrowserWindow https://www.electronjs.org/docs/latest/api/browser-window
[3] BrowserWindow | electron-gitbook - xwartz https://xwartz.gitbooks.io/electron-gitbook/content/en/api/browser-window.html
[4] BaseWindow | Electron https://www.electronjs.org/docs/latest/api/base-window
[5] BrowserWindow | Electron https://docset.yxpai.com/Electron/docs/api/browser-window.html
[6] How to fix BrowserWindow is not a constructor error when creating child window in Electron renderer process https://stackoverflow.com/questions/45639628/how-to-fix-browserwindow-is-not-a-constructor-error-when-creating-child-window-i
[7] Electron Plugin - App Config https://app-config.dev/guide/electron.html
[8] Electron BrowserWindow & WebContents Objects https://www.youtube.com/watch?v=0CJY-IHoNto
[9] Opening windows from the renderer https://www.electronjs.org/docs/latest/api/window-open
[10] Electron Platform Guide - Apache Cordova https://cordova.apache.org/docs/en/11.x/guide/platforms/electron/


---

### Window Properties (width, height, webPreferences)

BrowserWindow accepts numerous configuration properties in its constructor that control window dimensions, appearance, behavior, and security settings. These properties are passed as an options object when creating a new window instance.[1][2]

#### Dimension Properties

**Basic Size Options**
- `width` (Integer): Window's width in pixels (default: 800)[2][5][1]
- `height` (Integer): Window's height in pixels (default: 600)[5][1][2]
- Example: `new BrowserWindow({ width: 800, height: 600 })`[9][2]

**Size Constraints**
- `minWidth` / `minHeight` (Integer): Minimum window dimensions[1]
- `maxWidth` / `maxHeight` (Integer): Maximum window dimensions that restrict resizing[7][1]
- Example: `{ maxWidth: 600, maxHeight: 400 }` limits the window even if users try to resize[7]

**Resizing Behavior**
- `resizable` (Boolean): Whether the window can be manually resized by the user (default: true)[2][5][1]
- Setting `resizable: false` prevents users from changing window dimensions[8][5]

#### Position Properties

**Window Location**
- `x` (Integer): Horizontal position from screen left edge in pixels[5]
- `y` (Integer): Vertical position from screen top edge in pixels[5]
- Default behavior: Window appears centered on screen[5]
- Example: `{ x: 0, y: 0 }` positions window at top-left corner[5]

#### Display and Visibility Properties

**Appearance Control**
- `show` (Boolean): Whether window should be visible when created (default: true)[1][2]
- Setting `show: false` with `ready-to-show` event prevents visual flicker[2]
- `backgroundColor` (String): Window background color as hexadecimal, RGB, HSL, or CSS color name[2]
- Example values: `'#2e2c29'`, `'rgb(255, 145, 145)'`, `'hsl(230, 100%, 50%)'`, `'blueviolet'`[2]

**Frame and Chrome**
- `frame` (Boolean): Whether to show window frame/chrome (default: true)[1]
- `title` (String): Default window title; overridden by HTML `<title>` tag if present[5]
- `alwaysOnTop` (Boolean): Whether window should stay on top of other windows (default: false)[1]

**Window Capabilities**
- `minimizable` (Boolean): Whether window has minimize button (default: true)[5]
- `maximizable` (Boolean): Whether window has maximize button (default: true)[5]
- `closable` (Boolean): Whether window is closable; not implemented on Linux (default: true)[1]
- `fullscreen` (Boolean): Whether window should show in fullscreen (default: false)[1]

#### webPreferences Configuration

The `webPreferences` object is crucial for security and functionality configuration.[1]

**Security Settings**
- `nodeIntegration` (Boolean): Whether to enable Node.js integration in the renderer (default: false)
- `contextIsolation` (Boolean): Whether to run Electron APIs in separate context from web content (recommended: true)
- `sandbox` (Boolean): Whether to enable Chromium OS-level sandbox

**Preload Scripts**
- `preload` (String): Path to script that runs before renderer process loads
- Has access to both Node.js APIs and DOM
- Used to safely expose APIs to the renderer via Context Bridge
- Example: `webPreferences: { preload: path.join(__dirname, 'preload.js') }`

**Additional Preferences**
- `devTools` (Boolean): Whether to enable DevTools (default: true)
- `additionalArguments` (String[]): Additional command-line arguments passed to the renderer process

#### Modal Windows

**Parent-Child Relationships**
- `parent` (BrowserWindow): Specifies a parent window for creating child windows[2][1]
- `modal` (Boolean): Creates a modal window that disables the parent[7][2]
- Both `parent` and `modal` properties must be set together for modal behavior[7][2]
- Example: `new BrowserWindow({ parent: top, modal: true, show: false })`[2]

#### Instance Properties

After creating a BrowserWindow, you can access instance properties like `win.webContents` (the WebContents object for web page operations) and `win.id` (unique window identifier).[2][1]

Sources
[1] BrowserWindow | FAQ - GitHub Pages https://imfly.github.io/electron-docs-gitbook/en/api/browser-window.html
[2] BrowserWindow https://www.electronjs.org/docs/latest/api/browser-window
[3] Electron js tutorial for beginners #4 Browser Window Properties https://www.youtube.com/watch?v=rFJ44zdbpvo
[4] Electron Tutorial 6: BrowserWindow https://www.youtube.com/watch?v=UG9lka9mOwM
[5] Electron – チュートリアルその3 BrowserWindow のプロパティ https://pystyle.info/electron-tutorial-browser-window-properties/
[6] GitHub - ungoldman/electron-browser-window-options: Reference for default Electron BrowserWindow options. https://github.com/ungoldman/electron-browser-window-options
[7] Electron js Tutorial - 4 - BrowserWindow https://www.youtube.com/watch?v=zq7GrAym-KI
[8] Getting Started w/ Electron #2 - BrowserWindow Class https://www.youtube.com/watch?v=94kNEMbiZeo
[9] Electron BrowserWindow & WebContents Objects - Electron Basics Tutorial https://www.youtube.com/watch?v=0CJY-IHoNto
[10] Window Customization | Electronelectronjs.org › docs › latest › tutorial › window-customization https://www.electronjs.org/docs/latest/tutorial/window-customization


---

### Loading Local Files vs Remote URLs

Electron provides two primary methods for loading content into BrowserWindow: `loadFile()` for local HTML files and `loadURL()` for remote addresses or local server resources. Understanding when and how to use each method is essential for proper application development.[1][2][3]

#### loadFile() - Local Files

**Purpose and Usage**
- Specifically designed for loading local HTML files from the file system[2]
- Syntax: `win.loadFile(filePath[, options])`[3]
- Example: `mainWindow.loadFile('index.html')`[2]
- Path can be absolute or relative to the application root directory[2]
- Returns a Promise that resolves when the page finishes loading[3]

**Benefits**
- Better performance since it directly reads local files without network latency[2]
- No CORS (Cross-Origin Resource Sharing) restrictions[2]
- Simpler syntax for local resources[2]
- Recommended approach for loading local files[2]

#### loadURL() - Remote URLs and Servers

**Purpose and Usage**
- Used for loading remote network resources via HTTP/HTTPS protocols[1][2]
- Also works for local development servers[4][5]
- Syntax: `win.loadURL(url[, options])`[1][3]
- Example: `mainWindow.loadURL('http://localhost:3000')`[4]
- Can accept remote addresses like `'https://example.com'`[2]

**Advanced Features**
- Supports POST requests with URL-encoded data[3]
- Can include custom headers via `extraHeaders` option[3]
- Can send `postData` with request body[3]
- Example with POST:
```javascript
win.loadURL('http://localhost:8000/post', {
  postData: [{ type: 'rawData', bytes: Buffer.from('hello=world') }],
  extraHeaders: 'Content-Type: application/x-www-form-urlencoded'
})
```


**Considerations**
- Subject to CORS policies when loading remote resources[2]
- Must ensure target server's CORS configuration allows access[2]
- Performance affected by network latency[2]

#### Development vs Production Patterns

**Conditional Loading**
- Common pattern: Use `loadURL()` for development server and `loadFile()` for production build[4]
- Example:
```javascript
const isDev = require('electron-is-dev')
mainWindow.loadURL(
  isDev 
    ? 'http://localhost:3000' 
    : `file://${path.join(__dirname, '../build/index.html')}`
)
```


**Loading Local Files with loadURL()**
- You can use `loadURL()` with `file://` protocol for local files[2]
- Example: `loadURL('file://path/to/index.html')`[2]
- However, `loadFile()` is recommended as it simplifies the operation[2]

#### Security Considerations

**file:// Protocol Risks**
- The `file://` protocol has elevated privileges in Electron compared to web browsers[6]
- Pages running on `file://` have unilateral access to every file on the machine[6]
- XSS vulnerabilities can exploit this to load arbitrary files from user's system[6]
- Consider using custom protocols to limit file access to specific directories[6]

**Node.js Integration Warnings**
- When using `http://` or `https://` with Node integration enabled, Electron warns about security risks[7]
- Every JavaScript loaded by the page may contain Node.js code with file system access[7]
- This could potentially execute harmful operations[7]
- Best practice: Disable `nodeIntegration` and use preload scripts with context isolation[7]

#### Method Availability

Both `loadFile()` and `loadURL()` are available on both the BrowserWindow class and the WebContents class, providing flexibility in how you load content into windows.[8]

#### Common Issues

**Path Errors**
- Ensure path format is correct to avoid loading failures[2]
- Mixing up when to use `loadFile()` vs `loadURL()` often causes path-related errors[2]

**Best Practice**
- For remote resources → use `loadURL()`[2]
- For local files → use `loadFile()`[2]
- Always load external resources using secure protocols (HTTPS) rather than HTTP[6]

Sources
[1] BrowserWindow https://electronjs.org/docs/latest/api/browser-window
[2] Electron中loadURL和loadFile的区别是什么？如何正确使用它们加载页面？ https://ask.csdn.net/questions/8400176
[3] BrowserWindow https://www.electronjs.org/docs/latest/api/browser-window
[4] How can I use loadUrl or loadFile in production with ... https://stackoverflow.com/questions/67356048/how-can-i-use-loadurl-or-loadfile-in-production-with-electron-and-cra
[5] Cross-Platform Desktop App with Electron/React/Typescript https://javascript.plainenglish.io/cross-platform-desktop-app-with-electron-react-typescript-3a85eaba909a
[6] Security https://electronjs.org/docs/latest/tutorial/security
[7] Security issues in Electron using http:// protocol instead of file https://stackoverflow.com/questions/52423993/security-issues-in-electron-using-http-protocol-instead-of-file
[8] Electron BrowserWindow & WebContents Objects - Electron Basics Tutorial https://www.youtube.com/watch?v=0CJY-IHoNto
[9] win.loadFile (local file) is stuck if application is called by ... https://github.com/electron/electron/issues/32044
[10] Electron Breaks Brain https://maxwellforbes.com/garage/electron-breaks-brain/

---

### Platform-Specific Operations (Windows, macOS, Linux)

Electron applications run on multiple operating systems, each with unique behaviors and conventions that require platform-specific handling. Developers can detect and implement platform-specific code using Node.js's `process.platform` property.[1][2]

#### Platform Detection

**process.platform Values**
- `win32` - Windows (all versions, including 64-bit)[2][3][1]
- `darwin` - macOS (formerly OS X)[3][1][2]
- `linux` - Linux distributions[1][2][3]
- `freebsd` - FreeBSD[2]
- `openbsd` - OpenBSD[3][2]
- `sunos` - SunOS/Solaris[3]
- `aix` - AIX[3]

**Implementation Pattern**
```javascript
const os = require('os');

const platforms = {
  WINDOWS: 'WINDOWS',
  MAC: 'MAC',
  LINUX: 'LINUX'
};

const platformsNames = {
  win32: platforms.WINDOWS,
  darwin: platforms.MAC,
  linux: platforms.LINUX
};
```


#### Common Platform-Specific Behaviors

**Window Management**
- macOS apps typically stay running when all windows are closed[2]
- Windows/Linux apps quit when all windows are closed[2]
- Example implementation:
```javascript
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit(); // Only quit on Windows/Linux
  }
});
```


**Application Activation (macOS)**
- macOS users expect apps to reopen windows when clicking the dock icon[2]
- Use the `activate` event to recreate windows on macOS[2]
- Not needed on Windows/Linux as apps quit completely when windows close[2]

#### Version Detection

**Windows Version Checking**
You can use `os.release()` to detect specific Windows versions:[3]
- Windows 10: version 10.0
- Windows 8.1: version 6.3
- Windows 8: version 6.2
- Windows 7: version 6.1

Example:
```javascript
const releaseTest = {
  [platforms.WINDOWS]: (version) => {
    const [majorVersion, minorVersion] = version.split('.');
    if (majorVersion === '10') return 'WIN10';
    if (majorVersion === '6' && minorVersion === '3') return 'WIN8';
    return 'WIN7';
  }
};
```


#### Platform-Specific Dependencies

**Handling Native Modules**
- Some npm packages have platform-specific binaries or dependencies[4]
- Native addons must be rebuilt for each target platform[5]
- Use conditional requires or dependency checks for platform-specific libraries[4]
- Example: Different database drivers for Windows vs Linux[4]

**Binary Installation**
- When building on a different platform, specify the target: `npm install --platform=win32`[6]
- This ensures correct prebuilt binaries are downloaded[6]

#### Packaging for Multiple Platforms

**Electron Packager**
Specify target platforms when packaging:[1][6]
```bash
npx electron-packager . appname --platform=darwin,linux,win32 --arch=ia32,x64
```


**Electron Forge**
Add platform-specific make commands to package.json:[2]
```json
{
  "make-mac": "npx @electron-forge/cli make --platform darwin",
  "make-win": "npx @electron-forge/cli make --platform win32",
  "make-linux": "npx @electron-forge/cli make --platform linux"
}
```


**Output Formats by Platform**
- macOS: `.app` bundle or `.dmg` disk image[7][2]
- Windows: `.exe` executable or `.msi` installer[7][2]
- Linux: `.rpm`, `.deb`, or AppImage packages[7][2]

#### Platform-Specific UI Considerations

**Native Look and Feel**
- Electron uses web technologies which may not provide fully native UI by default[8]
- Libraries like Photon and Spectron provide native-like components[8]
- Custom styling may be needed to match each platform's design guidelines[8]

**Accessibility Features**
- Electron doesn't provide built-in platform-specific accessibility APIs[8]
- Developers must manually implement accessibility features for each platform[8]
- Native frameworks typically have better accessibility integration[8]

#### Testing Platform-Specific Code

**Cross-Platform Testing**
- Test on all target platforms to ensure consistent behavior[8]
- Pay attention to platform-specific nuances: file system differences, font rendering, UI scaling[8]
- Use automated testing tools to streamline multi-platform testing[8]

**Build Requirements**
- macOS builds generally require a Mac (for code signing)[1]
- Windows and Linux builds can be generated from most host platforms[1]
- Consider CI/CD pipelines with platform-specific runners for automated builds[8]

Sources
[1] Electron Packager https://github.com/electron/packager
[2] How to Package Your Multi-platform Electron App - Turtle-Techies https://www.turtle-techies.com/how-to-package-your-multiplatform-electron-app/
[3] Writing OS-specific code in Electron https://www.freecodecamp.org/news/how-to-write-os-specific-code-in-electron-bf6379c62ff6/
[4] Handling platform-specific dependencies in electron app https://stackoverflow.com/questions/65383546/handling-platform-specific-dependencies-in-electron-app
[5] Native Code and Electron https://electronjs.org/docs/latest/tutorial/native-code-and-electron
[6] A Comprehensive Guide to Building and Packaging an Electron App https://stevenklambert.com/writing/comprehensive-guide-building-packaging-electron-app/
[7] Electron: Build cross-platform desktop apps with JavaScript ... https://electronjs.org
[8] ElectronJS For Cross-Platform Software Development - Intuji https://intuji.com/electronjs-for-cross-platform-development/
[9] How to build desktop applications with Electron JS and ... https://www.facebook.com/groups/ReactJsDevelopersGroup/posts/2954107651430117/
[10] Electron vs. Tauri: Which cross-platform framework is for you? https://www.infoworld.com/article/3547072/electron-vs-tauri-which-cross-platform-framework-is-for-you.html


---

### Process Platform Detection

Platform detection in Electron uses Node.js's `process.platform` property, which returns a string identifying the operating system where the application is running. This is essential for implementing platform-specific behavior and logic.[1][2][3]

#### Accessing process.platform

**Basic Usage**
- Access via `process.platform` (no require needed, it's a global)[4][1]
- Returns a string value representing the OS platform[2][3]
- Value is set at compile time when Node.js binary is built[3][2]
- Example: `console.log(process.platform);`[5][2]

#### Platform Values

**Common Platform Identifiers**
- `'win32'` - Windows (all versions, including 64-bit)[6][1][2]
- `'darwin'` - macOS/iOS and Darwin-based systems[1][2][3]
- `'linux'` - Linux distributions[2][3][5]
- `'aix'` - IBM AIX platform[3][2]
- `'freebsd'` - FreeBSD[2][3]
- `'openbsd'` - OpenBSD[3][2]
- `'sunos'` - SunOS/Solaris[2]
- `'android'` - Android (in some Node.js implementations)[2]

#### Important Notes

**Windows Detection Caveat**
- Windows always returns `'win32'` even on 64-bit systems[7][6][1]
- This is because `'win32'` refers to the Windows API name, not the architecture[8]
- `'win32'` contrasts with the older 16-bit Windows API from the mid-90s[8]
- To detect 64-bit vs 32-bit architecture, use `process.arch` instead[7][8]

**Architecture vs Platform**
- `process.platform` - Operating system type (Windows, macOS, Linux)[4][2]
- `process.arch` - CPU architecture (x64, ia32, arm, etc.)[7][8]
- Example: 32-bit Electron on 64-bit Windows still reports `process.platform === 'win32'`[7]

#### Implementation Patterns

**Switch Statement Pattern**
```javascript
const process = require('process');

var platform = process.platform;
switch(platform) {
  case 'aix':
    console.log("IBM AIX platform");
    break;
  case 'darwin':
    console.log("Darwin platform (MacOS, iOS etc)");
    break;
  case 'freebsd':
    console.log("FreeBSD Platform");
    break;
  case 'linux':
    console.log("Linux Platform");
    break;
  case 'openbsd':
    console.log("OpenBSD platform");
    break;
  case 'sunos':
    console.log("SunOS platform");
    break;
  case 'win32':
    console.log("Windows platform");
    break;
  default:
    console.log("Unknown platform");
}
```


**Conditional Check Pattern**
```javascript
if (process.platform === 'darwin') {
  // macOS-specific code
} else if (process.platform === 'win32') {
  // Windows-specific code
} else if (process.platform === 'linux') {
  // Linux-specific code
}
```


**Regex Pattern for Windows**
```javascript
if (/^win/i.test(process.platform)) {
  // Windows detected
} else {
  // Linux, Mac, or other
}
```


**Warning**: Don't use substring matching with "win" as "darwin" also contains "win"[8]

#### Alternative: os.platform()

**Using os Module**
- Can also use `os.platform()` from Node.js os module[5]
- Syntax: `const os = require('os'); console.log(os.platform());`[5]
- Returns the same value as `process.platform`[6][5]
- Both methods are equivalent for platform detection[5]

#### Electron-Specific Considerations

**Process Object Availability**
- The process object is available in both Main Process and Renderer Process[9]
- Access is identical in both contexts[9]
- Additional Electron-specific methods are available on the process object[9]

**Electron Process Methods**
- `process.getSystemVersion()` - Returns actual OS version (not kernel version on macOS)[9]
- `process.getSystemMemoryInfo()` - System memory information[9]
- These complement standard Node.js process properties[9]

#### Practical Use Cases

Platform detection is commonly used for:
- Conditional window management (quit behavior on macOS vs Windows/Linux)[1]
- Platform-specific file paths and directory structures[2]
- Native module loading based on OS[2]
- UI/UX adjustments for platform conventions[2]
- Choosing appropriate system commands or APIs[4]

Sources
[1] How do I determine the current operating system with Node.js https://stackoverflow.com/questions/8683895/how-do-i-determine-the-current-operating-system-with-node-js
[2] Node.js process.platform Property - GeeksforGeeks https://www.geeksforgeeks.org/node-js/node-js-process-platform-property/
[3] Process.platform - Node documentation - Deno Docs https://docs.deno.com/api/node/process/~/Process.platform
[4] Node.js Process Management - W3Schools https://www.w3schools.com/nodejs/nodejs_process_management.asp
[5] Node.js - os.platform() Method - Tutorials Point https://www.tutorialspoint.com/nodejs/nodejs_os_platform_method.htm
[6] How do I determine the current operating system with Node.js https://stackoverflow.com/questions/8683895/how-do-i-determine-the-current-operating-system-with-node-js/8684009
[7] Detect os platform version x64 vs. ia32 [Linux, Win] · Issue #6044 https://github.com/electron/electron/issues/6044
[8] os.platform() includes win32...what about win64? https://www.reddit.com/r/node/comments/7xx4u7/osplatform_includes_win32what_about_win64/
[9] Process Object in ElectronJS - GeeksforGeeks https://www.geeksforgeeks.org/javascript/process-object-in-electronjs/
[10] Process | Node.js v25.3.0 Documentation https://nodejs.org/api/process.html


---

# Preload Scripts & Context Isolation

### Preload Script Purpose and Architecture

A preload script contains code that runs before a web page loads into the browser window, serving as a secure bridge between Electron's main process and renderer process. It operates in a unique context with access to both DOM APIs and a limited Node.js environment.[1][4][6]

#### Purpose

**Security Bridge**
- Allows secure exposure of privileged APIs to the renderer process without full Node.js access[3][1]
- Solves the security problem: renderer processes don't run Node.js by default for safety[1]
- Prevents malicious web content from accessing operating system-level functionality directly[4][1]
- Acts as a controlled gateway for communication between isolated processes[1]

**Key Use Cases**
- Exposing whitelisted Node.js functionality to the renderer[3][4]
- Setting up inter-process communication (IPC) interfaces[3][1]
- Augmenting the renderer with privileged features that require OS access[1]
- Injecting global objects and functions into the renderer's window object[6][1]

#### Architecture

**Execution Context**
- Runs in a special context that has access to both HTML DOM and Node.js APIs[5][1]
- Executes before any DOM content or other JavaScript files load[5][6]
- Injected similar to a Chrome extension's content scripts[1]
- From Electron 20 onwards, preload scripts are sandboxed by default with limited Node.js access[1]

**Process Isolation**
- Preload scripts are isolated from the renderer's main world through Context Isolation[2][10]
- This prevents leaking privileged APIs into web content's code[2]
- Without context isolation, malicious JavaScript could alter exposed functions[10]
- Isolation ensures that renderer code cannot directly access the preload script's scope[2]

#### Implementation Architecture

**Configuration**
Specify the preload script in BrowserWindow's webPreferences:[4][1]
```javascript
const mainWindow = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    contextIsolation: true // recommended for security
  }
});
```


**Using contextBridge**
The contextBridge API is the secure method to expose functionality:[3][1]
```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  send: (channel, data) => {
    // whitelist channels
    let validChannels = ['toMain'];
    if (validChannels.includes(channel)) {
      ipcRenderer.send(channel, data);
    }
  }
});
```


**Renderer Access**
The exposed API becomes available in the renderer:[4][3]
```javascript
// renderer.js
window.api.send('toMain', { message: 'Hello' });
```


#### Security Best Practices

**Never Expose Entire Modules**
- Never directly expose the entire `ipcRenderer` module[3][1]
- This would give the renderer ability to send arbitrary IPC messages[1]
- Creates a powerful attack vector for malicious code[1]
- Always expose whitelisted wrappers around specific functionality[3]

**Whitelist Channels**
- Only allow specific, validated channels for IPC communication[3]
- Validate and sanitize data passed through exposed functions[3]
- Limit exposed functionality to the minimum required[4]

**Enable Context Isolation**
- Always set `contextIsolation: true` in webPreferences[4][3]
- This is the default since Electron 12 and recommended for all apps[2]
- Prevents renderer JavaScript from accessing preload script variables[2]

#### Code Organization

**Separation of Concerns**
Preload scripts enable proper separation between processes:[3]
- **Main process**: Event handling, OS-level operations, file system access
- **Preload process**: Expose user-defined endpoints, bridge IPC communication
- **Renderer process**: UI logic, DOM manipulation, user interactions

**Example Structure**
```javascript
// preload.js - expose wrapper functions
const { contextBridge } = require('electron');
const crypto = require('crypto');

contextBridge.exposeInMainWorld('nodeCrypto', {
  sha256sum(data) {
    const hash = crypto.createHash('sha256');
    hash.update(data);
    return hash.digest('hex');
  }
});
```


#### File Location

Preload scripts are typically located at `/src-electron/electron-preload.js` or in the project root. The path is specified relative to the main process file.[4][1]

#### Execution Timing

Preload scripts run before the renderer process loads, giving them the ability to set up the environment and inject APIs before any user code executes. This timing is critical for establishing secure communication channels and exposing controlled functionality.[6][1]

Sources
[1] Using Preload Scripts https://electronjs.org/docs/latest/tutorial/tutorial-preload
[2] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[3] How to use preload.js properly in Electron https://stackoverflow.com/questions/57807459/how-to-use-preload-js-properly-in-electron
[4] Electron Preload Script https://quasar.dev/quasar-cli-vite/developing-electron-apps/electron-preload-script/
[5] Getting Started w/ Electron #3 - Preload Scripts https://www.youtube.com/watch?v=RuNnmDwgXCQ
[6] Development https://electron-vite.org/guide/dev
[7] s Service Worker Preload Scripts | Mamezou Developer Portal https://developer.mamezou-tech.com/en/blogs/2025/03/31/electron-v35-service-worker-preload-scripts/
[8] Define preload script inline in main.js webPreferences https://github.com/electron/electron/issues/28981
[9] How to use preload script in Electron Webview with React https://dev.to/dani/how-to-use-preload-script-in-electron-webview-with-react-2h2f
[10] Preloading Insecurity In Your Electron https://doyensec.com/resources/Asia-19-Carettoni-Preloading-Insecurity-In-Your-Electron.pdf


---

### Context Bridge API

The Context Bridge is Electron's module that creates a safe, bi-directional, synchronous bridge across isolated contexts, allowing preload scripts to securely expose APIs to the renderer process. It runs in the renderer process and is the recommended method for exposing privileged functionality to web pages.[1][5][6]

#### Core Methods

**exposeInMainWorld(apiKey, api)**
- The primary method for exposing APIs to the renderer's main world[5][1]
- `apiKey` (string): The name under which the API will be accessible on `window`[1]
- `api` (any): The API object containing methods and properties to expose[1]
- Accessed in renderer as `window[apiKey]`[5][1]

**Basic Example**
```javascript
// Preload (Isolated World)
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld(
  'electron',
  {
    doThing: () => ipcRenderer.send('do-a-thing')
  }
)

// Renderer (Main World)
window.electron.doThing()
```


**exposeInIsolatedWorld(worldId, apiKey, api)**
- Exposes API to a specific isolated world by ID[5][1]
- `worldId` (Integer): The ID of the world (0 = default, 999 = Electron's contextIsolation, 1000+ recommended for custom worlds)[1][5]
- Useful for advanced isolation scenarios and custom contexts[1]

**executeInMainWorld(executionScript)**
- Executes JavaScript code in the main world context[1]
- Allows running code in the renderer's context from preload[1]

#### Why Context Bridge Matters

**Security Enhancement**
- Prevents direct exposure of powerful APIs like `ipcRenderer` to the renderer[2][4]
- Protects against malicious web content accessing Node.js or Electron APIs[2]
- Allows selective, whitelisted API exposure instead of full module access[4][2]
- Functions are proxied while data values are copied and frozen for immutability[2][5][1]

**Context Isolation**
- Works with Context Isolation feature to separate Electron APIs from web content[6]
- When `contextIsolation` is enabled, preload scripts run in isolated context[6]
- Context Bridge safely bridges the gap between isolated preload and main renderer contexts[6]
- Without it, APIs cannot be exposed when context isolation is enabled[6]

#### Supported Data Types

**Type Support Table**
The bridge supports specific types for parameters and return values:[5][1]

- ✅ Primitives: `string`, `number`, `boolean`
- ✅ `Function` (proxied to other context)
- ✅ `Promise` (resolved or rejected)
- ✅ `Array` (containing supported types)
- ✅ Plain objects (with supported property types)
- ✅ Nested objects (with supported types)
- ❌ Custom prototypes
- ❌ Symbols
- ❌ `ipcRenderer` directly (as of recent Electron versions)[5]

#### Value Handling

**Copying vs Proxying**
- Function values are **proxied** to the other context[2][5][1]
- All other values are **copied and frozen**[2][5][1]
- Data/primitives sent via the API become immutable[2][1]
- Updates on either side of the bridge do not result in updates on the other side[5][1]

#### Complex API Example

```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld(
  'electron',
  {
    doThing: () => ipcRenderer.send('do-a-thing'),
    myPromises: [Promise.resolve(), Promise.reject(new Error('whoops'))],
    anAsyncFunction: async () => 123,
    data: {
      myFlags: ['a', 'b', 'c'],
      bootTime: 1234
    },
    nestedAPI: {
      evenDeeper: {
        youCanDoThisAsMuchAsYouWant: {
          fn: () => ({ returnData: 123 })
        }
      }
    }
  }
)
```


#### Real-World Usage Pattern

**Preload Script**
```javascript
const { contextBridge } = require('electron')
const crypto = require('node:crypto')

contextBridge.exposeInMainWorld('nodeCrypto', {
  sha256sum(data) {
    const hash = crypto.createHash('sha256')
    hash.update(data)
    return hash.digest('hex')
  }
})
```


**Renderer Access**
```javascript
const hashed = window.nodeCrypto.sha256sum('my data')
```


#### Context Detection Pattern

```javascript
import { contextBridge } from 'electron'
import { electronAPI } from '@electron-toolkit/preload'

if (process.contextIsolated) {
  try {
    contextBridge.exposeInMainWorld('electron', electronAPI)
  } catch (error) {
    console.error(error)
  }
} else {
  window.electron = electronAPI
}
```


#### Limitations

- Cannot send custom prototypes or symbols over the bridge[6]
- `ipcRenderer` can no longer be sent directly over contextBridge (breaking change in recent versions)[5]
- Must wrap IPC functionality in custom functions instead of exposing entire modules[2]
- All non-function values are immutable after crossing the bridge[1][5]

#### Best Practices

Always use Context Bridge instead of the deprecated approach of directly modifying `window` in preload scripts. This ensures security and compatibility with context isolation enabled.[6][2]

Sources
[1] contextBridge https://electronjs.org/docs/latest/api/context-bridge
[2] Electron 'contextBridge' - javascript https://stackoverflow.com/questions/59993468/electron-contextbridge
[3] electron/lib/renderer/api/context-bridge.ts at main https://github.com/electron/electron/blob/master/lib/renderer/api/context-bridge.ts
[4] 04 - Electronjs contextBridge and how to use main process ... https://www.youtube.com/watch?v=NkQxyW5mlZI
[5] contextBridge https://www.electronjs.org/docs/latest/api/context-bridge
[6] Context Isolation https://electronjs.org/docs/latest/tutorial/context-isolation
[7] Development https://electron-vite.org/guide/dev
[8] The Context Bridge class in electronjs - Dustin Pfister https://dustinpfister.github.io/2022/02/21/electronjs-context-bridge/
[9] Can't seem to get ipcRenderer / contextBridge working and ... https://www.reddit.com/r/electronjs/comments/17xd549/cant_seem_to_get_ipcrenderer_contextbridge/
[10] here - GitHub https://raw.githubusercontent.com/electron/electron/main/docs/breaking-changes.md


---

### Exposing APIs to Renderer Process

Exposing APIs to the renderer process in Electron requires careful implementation to maintain security while providing necessary functionality. The recommended approach uses preload scripts with the Context Bridge API to selectively expose whitelisted methods.[1][2][3]

#### The Security Problem

**Why Direct Access Is Disabled**
- Renderer processes have no Node.js or Electron module access by default[2][3]
- This protects against malicious web content accessing privileged system APIs[4]
- Enabling `nodeIntegration` in the renderer exposes your app to serious vulnerabilities[4]
- Attackers could run arbitrary scripts with full system access if Node.js is exposed[4]

#### The Secure Solution: Preload Scripts + Context Bridge

**Step 1: Configure BrowserWindow**
Set up proper security options in your window configuration:[5][6]
```javascript
mainWindow = new BrowserWindow({
  width: 800,
  height: 600,
  webPreferences: {
    nodeIntegration: false, // Keep disabled for security
    contextIsolation: true, // Isolate preload from renderer
    enableRemoteModule: false, // Disable remote module
    preload: path.join(__dirname, 'preload.js')
  }
})
```


**Step 2: Create Preload Script with Exposed APIs**
Define which APIs the renderer can access:[6][1][2]
```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile'),
  ping: () => ipcRenderer.invoke('ping'),
  onUpdateCounter: (callback) => ipcRenderer.on('update-counter', callback)
})
```


**Step 3: Use Exposed API in Renderer**
Access the API through the global window object:[2][6]
```javascript
// renderer.js
const btn = document.getElementById('btn')
btn.addEventListener('click', async () => {
  const filePath = await window.electronAPI.openFile()
})
```


#### Best Practices for Exposing APIs

**Never Expose Entire Modules**
- Don't directly expose `ipcRenderer.invoke` or other complete APIs[2]
- Limit renderer's access to Electron APIs as much as possible[2]
- Only expose specific, whitelisted functionality[2]

**Example - Wrong Approach:**
```javascript
// ❌ INSECURE - Don't do this
contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: require('electron').ipcRenderer
})
```


**Example - Correct Approach:**
```javascript
// ✅ SECURE - Expose specific functions only
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile')
})
```


**Avoid Callback Leakage**
- Don't pass callbacks directly to `ipcRenderer.on`[2]
- This would leak `ipcRenderer` via `event.sender`[2]
- Use custom handlers that invoke callbacks safely[2]

**Example - Secure Callback Pattern:**
```javascript
contextBridge.exposeInMainWorld('electronAPI', {
  onUpdateCounter: (callback) => {
    ipcRenderer.on('update-counter', (_event, value) => callback(value))
  }
})
```


#### Development Efficiency Tool

**Using @electron-toolkit/preload**
For faster development, use the official toolkit:[1]
```javascript
import { contextBridge } from 'electron'
import { electronAPI } from '@electron-toolkit/preload'

if (process.contextIsolated) {
  try {
    contextBridge.exposeInMainWorld('electron', electronAPI)
  } catch (error) {
    console.error(error)
  }
} else {
  window.electron = electronAPI
}
```


This provides easy access to `ipcRenderer`, `webFrame`, and `process` in the renderer.[1]

#### Real-World Example: Authentication & API Calls

**Preload API Definition**
```javascript
// main/preload.js
const { contextBridge, ipcRenderer } = require("electron");

const electronAPI = {
  getProfile: () => ipcRenderer.invoke('auth:get-profile'),
  logOut: () => ipcRenderer.send('auth:log-out'),
  getPrivateData: () => ipcRenderer.invoke('api:get-private-data')
};

process.once("loaded", () => {
  contextBridge.exposeInMainWorld('electronAPI', electronAPI);
});
```


**Renderer Usage**
```javascript
// renderer process
const profile = await window.electronAPI.getProfile()
const privateData = await window.electronAPI.getPrivateData()
```


#### Context Isolation Requirement

Context isolation creates a clear separation between the renderer and main process. When enabled (default in modern Electron):[6]
- Preload scripts run in an isolated context[6]
- Renderer cannot access preload variables directly[6]
- Must use Context Bridge to expose APIs[6]
- Ensures security even if malicious code runs in renderer[6]

#### Common Patterns

**Two-Way IPC (Invoke Pattern)**
Use `ipcRenderer.invoke()` for request-response communication:[2]
```javascript
// Preload
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile')
})

// Renderer
const result = await window.electronAPI.openFile()
```


**One-Way IPC (Send Pattern)**
Use `ipcRenderer.send()` for fire-and-forget messages:[6][2]
```javascript
// Preload
contextBridge.exposeInMainWorld('electronAPI', {
  logOut: () => ipcRenderer.send('auth:log-out')
})

// Renderer
window.electronAPI.logOut()
```


#### Security Checklist

When exposing APIs to the renderer process:[7][4][2]
- ✅ Keep `nodeIntegration: false`
- ✅ Enable `contextIsolation: true`
- ✅ Use preload scripts with Context Bridge
- ✅ Whitelist specific functions only
- ✅ Validate all data from renderer
- ✅ Never expose complete modules
- ✅ Disable `enableRemoteModule`
- ❌ Never enable Node integration in renderer
- ❌ Never expose `ipcRenderer` directly

Sources
[1] Development | electron-vite https://electron-vite.org/guide/dev
[2] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[3] Using Preload Scripts https://www.electronjs.org/docs/latest/tutorial/tutorial-preload
[4] Best approach to make API calls to server for Electron app [closed] https://stackoverflow.com/questions/79081625/best-approach-to-make-api-calls-to-server-for-electron-app
[5] electron - expose api using contextBridge.exposeInMainWorld - not working in embedded html renderer - window.api undefined https://www.reddit.com/r/node/comments/klghgm/electron_expose_api_using/
[6] Build and Secure an Electron App - OpenID, OAuth, Node.js ... - Auth0 https://auth0.com/blog/securing-electron-applications-with-openid-connect-and-oauth-2/
[7] Security | Electron https://electronjs.org/docs/latest/tutorial/security
[8] Process Model | Electron https://electronjs.org/docs/latest/tutorial/process-model
[9] Penetration Testing of Electron-based Applications - DeepStrike https://deepstrike.io/blog/penetration-testing-of-electron-based-applications
[10] Electron 'contextBridge' https://stackoverflow.com/questions/59993468/electron-contextbridge


---

### Security Considerations and Isolation

Electron applications require careful security configuration because they combine web content with access to Node.js and system-level APIs, creating potential attack vectors if not properly isolated. The framework provides multiple security layers that must be correctly enabled.[1][2]

#### Context Isolation

**What It Is**
- Ensures preload scripts and Electron's internal logic run in a separate JavaScript context from loaded web content[3][4]
- Creates different `window` objects for preload scripts versus the website[3]
- Prevents websites from accessing Electron internals or preload script APIs directly[5][3]

**Why It's Critical**
- Protects against prototype pollution attacks where malicious code modifies JavaScript globals like `Array.prototype.push` or `JSON.parse`[1][5]
- Prevents web content from accessing powerful APIs exposed in preload scripts[4][3]
- Even with `nodeIntegration: false`, context isolation is required for true security[4]
- XSS vulnerabilities become far more dangerous without context isolation[2]

**Configuration**
- Enabled by default since Electron 12[6][1][3]
- Recommended security setting for all applications[3][4]
- Set in webPreferences: `contextIsolation: true`[1][4]
- Never disable context isolation: `contextIsolation: false` is a critical vulnerability[4]

#### Node Integration

**Default Behavior**
- `nodeIntegration: false` by default since Electron 5[7]
- Prevents renderer processes from using Node.js APIs like `require()`[7]
- Disabling node integration also disables process sandboxing for that process[1]

**Security Implications**
- Enabling `nodeIntegration: true` is extremely dangerous[8]
- Allows arbitrary code execution if combined with XSS vulnerabilities[2][8]
- Past CVEs like CVE-2018-1000136 involved nodeIntegration bypass leading to remote code execution[8]
- Client-side attacks in Electron are HIGH severity because of native OS API access[2]

#### Process Sandboxing

**Sandbox Configuration**
- The sandbox should be enabled by default: `sandbox: true`[7]
- Provides OS-level isolation for renderer processes[7]
- Proposed as default in modern Electron versions[7]

**How It Works**
- If `nodeIntegration` is off, there's no way to `require()` native modules or perform filesystem actions[7]
- Adding sandbox doesn't impose additional restrictions when Node integration is disabled[7]
- If `nodeIntegration: true`, sandbox won't activate unless explicitly requested[7]
- Note: `nodeIntegration: true` has no effect when `sandbox: true`[7]

**Recommended Configuration**
```javascript
const mainWindow = new BrowserWindow({
  webPreferences: {
    nodeIntegration: false,
    contextIsolation: true,
    sandbox: true
  }
});
```


#### Additional Security Settings

**Complete Security Configuration**
The following webPreferences should be set for maximum security:[9]
- `nodeIntegration: false` - Disable Node.js in renderer
- `contextIsolation: true` - Isolate preload context
- `sandbox: true` - Enable OS-level sandboxing
- `webSecurity: true` - Enable same-origin policy
- `allowRunningInsecureContent: false` - Block mixed content

#### Common Vulnerabilities

**Injection-Based Attacks**
- XSS vulnerabilities in Electron apps are HIGH severity[2]
- Can allow attackers to invoke OS commands through native API calls[2]
- Over 55+ CVEs registered against Electron apps due to misconfigurations[2]
- Always sanitize user input and validate data from external sources[2]

**nodeIntegration Bypass**
- Historical vulnerability (CVE-2018-1000136) allowed re-enabling nodeIntegration[8]
- Affected Electron versions < 1.7.13, < 1.8.4, or < 2.0.0-beta.3[8]
- Could achieve remote code execution via XSS + webview tag[8]
- Applications using `webviewTag: false` were protected[8]

**Navigation and New Window Vulnerabilities**
- Creation of new browser windows or navigation to untrusted origins can lead to severe vulnerabilities[10]
- Middle-click causes Electron to open links in new windows, potentially executing arbitrary JavaScript[10]
- Limit navigation flows to trusted origins only[10]

**Sandbox Bypass Risks**
- Preload scripts can bypass sandbox using remote module or internal IPC[10]
- Example: `require('electron').remote.app` or `ipcRenderer.sendSync('ELECTRON_BROWSER_GET_BUILTIN', 'app')`[10]
- Always audit preload script code for sandbox escape attempts[10]

#### Security Best Practices

**Enable All Isolation Features**
1. Keep `nodeIntegration: false`[4][1][7]
2. Enable `contextIsolation: true`[3][1][4]
3. Enable `sandbox: true`[9][7]
4. Use preload scripts with Context Bridge for API exposure[1]
5. Never expose complete modules like `ipcRenderer`[10]

**Additional Hardening**
- Disable debugging features in production[10]
- Review all `appendArgument` and `appendSwitch` calls[10]
- Set `webviewTag: false` if not needed[8]
- Implement Content Security Policy (CSP)[2]
- Validate and sanitize all user input[2]

**Data Security**
- Use platform secure storage (Keychain, DPAPI, libsecret, or keytar)[9]
- Encrypt sensitive data at rest[9]
- Enforce owner-only file permissions[9]
- Require authentication for IPC or HTTP endpoints[9]

#### Why Isolation Matters

Without proper isolation, a single XSS vulnerability can escalate to complete system compromise because the attacker gains access to Node.js APIs and native system calls. Modern Electron security assumes defense-in-depth: multiple layers (no Node integration + context isolation + sandboxing) work together to protect applications even when individual components fail.[4][2][7]

Sources
[1] Security https://electronjs.org/docs/latest/tutorial/security
[2] Hunting Common Misconfigurations in Electron Apps - Part 1 https://www.cobalt.io/blog/common-misconfigurations-electron-apps-part-1
[3] Context Isolation https://electronjs.org/docs/latest/tutorial/context-isolation
[4] Context isolation is disabled in Electron - JS-S1020 https://deepsource.com/directory/javascript/issues/JS-S1020
[5] electron/docs/tutorial/security.md at master https://github.com/lecoursen/electron/blob/master/docs/tutorial/security.md
[6] Should I use Context Isolation with my Electron App https://stackoverflow.com/questions/63826089/should-i-use-context-isolation-with-my-electron-app
[7] Enable `sandbox: true` by default for `BrowserWindow` · Issue #28466 https://github.com/electron/electron/issues/28466
[8] CVE-2018-1000136 - Electron nodeIntegration Bypass - LevelBlue https://levelblue.com/blogs/spiderlabs-blog/cve-2018-1000136-electron-nodeintegration-bypass
[9] Penetration Testing of Electron-based Applications https://deepstrike.io/blog/penetration-testing-of-electron-based-applications
[10] Electron Security Checklist https://doyensec.com/resources/us-17-Carettoni-Electronegativity-A-Study-Of-Electron-Security-wp.pdf


---

### Node.js Modules in Preload Scripts

Preload scripts have special access to Node.js modules that renderer processes don't, but this access is limited and has changed significantly in recent Electron versions. Understanding what's available is critical for secure application development.[1][2][3]

#### Node.js Access in Preload Scripts

**What Preload Scripts Can Access**
- Preload scripts run in a privileged environment with access to Node.js built-in modules[4][1]
- Can use `require()` to import Node.js modules and npm packages[3][1]
- Have access to Electron's renderer process modules[3]
- Can bridge Node.js functionality to the renderer via Context Bridge[5][6]

**Why This Matters**
- Renderer processes don't have Node.js access by default for security reasons[1][4][3]
- Preload scripts serve as the secure bridge to expose needed Node.js functionality[7][1]
- This separation prevents untrusted web content from accessing system-level APIs directly[7]

#### Sandboxed Preload Scripts (Electron 20+)

**Breaking Change**
Since Electron 20, preload scripts are sandboxed by default, severely limiting Node.js module access.[2][8][9]

**Limited API Access in Sandbox**
When sandboxing is enabled, preload scripts have a `require` function with access to only a limited set of APIs:[9][3]

| Category | Available APIs |
|----------|----------------|
| Electron modules | Renderer process modules only |
| Node.js modules | `events`, `timers`, `url` |
| Polyfilled globals | `Buffer`, `process`, `clearImmediate`, `setImmediate` |

[3]

**What You Cannot Access**
- Full Node.js modules like `fs` (file system), `path`, `crypto`, etc. are NOT available by default[8][9]
- Third-party npm packages like `inversify` cannot be loaded in sandboxed preload[2]
- Any module requiring full Node.js environment will fail to load[9][2]

#### Working with Sandboxed Preload Scripts

**Option 1: Disable Sandbox (Not Recommended)**
Temporarily disable sandboxing to access full Node.js modules:[8][2]
```javascript
const mainWindow = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    sandbox: false // Allows full Node.js access
  }
});
```


**Warning**: This reduces security and is not recommended for production[2]

**Option 2: Move Node.js Logic to Main Process (Recommended)**
- Keep preload scripts minimal and sandboxed[9][2]
- Move all Node.js module usage to the main process[2][9]
- Use IPC to communicate between main and renderer processes[9]
- Expose only specific functionality via Context Bridge[2]

#### Proper Usage Pattern

**Example: Using Node.js Modules Securely**

**Main Process** (full Node.js access):
```javascript
// main.js
const { ipcMain } = require('electron');
const fs = require('fs');

ipcMain.handle('read-file', async (event, filePath) => {
  return fs.readFileSync(filePath, 'utf-8');
});
```


**Preload Script** (expose IPC wrapper):
```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('fileAPI', {
  readFile: (filePath) => ipcRenderer.invoke('read-file', filePath)
});
```


**Renderer Process** (use exposed API):
```javascript
// renderer.js
const content = await window.fileAPI.readFile('/path/to/file.txt');
```


#### Available Node.js Modules (Non-Sandboxed)

When `sandbox: false`, preload scripts can access:[5][1]
- Core Node.js modules: `fs`, `path`, `crypto`, `os`, `child_process`, etc.
- Electron modules: `ipcRenderer`, `webFrame`, `clipboard`, etc.
- Any npm package installed in node_modules
- Custom Node.js modules from your project

**Example with File System Module**:
```javascript
// preload.js (sandbox: false required)
const { contextBridge } = require('electron');
const fs = require('fs');
const path = require('path');

contextBridge.exposeInMainWorld('nodeCrypto', {
  sha256sum(data) {
    const crypto = require('crypto');
    const hash = crypto.createHash('sha256');
    hash.update(data);
    return hash.digest('hex');
  }
});
```


#### Best Practices

**Security-First Approach**
1. Keep sandbox enabled (`sandbox: true`)[9][2]
2. Use only the limited Node.js APIs available in sandboxed preload[3]
3. Move complex Node.js operations to the main process[2][9]
4. Communicate via IPC with whitelisted channels[9]
5. Never expose entire modules to renderer[5]

**Migration from Legacy Code**
If you have existing preload scripts using full Node.js modules:[2]
- Identify which Node.js modules are being used
- Refactor logic to main process
- Create IPC handlers for each operation
- Update preload to expose IPC wrappers only
- Test with sandbox enabled

#### Common Errors

**Module Not Found Error**
```
Error: module not found: fs
```
This occurs when trying to `require('fs')` in a sandboxed preload script. Solution: Either disable sandbox or move the logic to main process.[8][9]

**Preload Script Load Failure**
If your preload script fails to load after enabling sandbox, it's likely using Node.js modules not available in the sandbox. Check which modules are being required and refactor accordingly.[2]

Sources
[1] Using Preload Scripts https://www.electronjs.org/docs/latest/tutorial/tutorial-preload
[2] [Bug]: Unable to load preload script due enable sandbox ... https://github.com/electron/electron/issues/36437
[3] Using Preload Scripts | Electron http://electronproject.org/tutorial-preload.html
[4] Using Preload Scripts | Electron https://www.electrondelta.com/tutorial-preload.html
[5] How to use preload.js properly in Electron https://stackoverflow.com/questions/57807459/how-to-use-preload-js-properly-in-electron
[6] How to use preload.js properly in Electron https://stackoverflow.com/questions/57807459/how-to-use-preload-js-properly-in-electron/59814127
[7] Preload Script | electron/electron-quick-start | DeepWiki https://deepwiki.com/electron/electron-quick-start/6-preload-script
[8] Unable to require path and fs modules in preload script https://www.reddit.com/r/electronjs/comments/wydus6/unable_to_require_path_and_fs_modules_in_preload/
[9] electron preload cannot load https://stackoverflow.com/questions/79593680/electron-preload-cannot-load
[10] Deutsch https://www.electronjs.org/de/docs/latest/tutorial/tutorial-preload


---

### Path Resolution and File Linking

Path resolution in Electron requires understanding the different contexts where code executes and using appropriate Node.js path utilities to ensure cross-platform compatibility. Proper path handling is essential for loading files, resources, and linking scripts across main, preload, and renderer processes.[1][2]

#### Core Path Concepts

**__dirname and __filename**
- `__dirname` - Path to the directory containing the currently executing script[2][1]
- `__filename` - Full path to the currently executing script file[2]
- Available in main process and non-sandboxed preload scripts[3][4]
- **Not available** in renderer processes by default (context isolation)[3]
- **Not available** in sandboxed preload scripts (Electron 20+)[4][5]

**Production Build Considerations**
- When using bundlers (webpack, esbuild), `__dirname` and `__filename` may not provide expected values[2]
- Built files are often placed in `dist/electron-*` folders, changing the directory structure[2]
- In packaged apps, files are typically inside `resources/app.asar` archive[6]

#### Path Resolution Methods

**Using path.join() for Cross-Platform Compatibility**
```javascript
const path = require('path');
const { app, BrowserWindow } = require('electron');

// Combine path segments properly
const preloadPath = path.join(__dirname, 'preload.js');
```


- `path.join()` combines multiple path segments into a single path string[1]
- Automatically handles platform-specific path separators (\ on Windows, / on Unix)[1]
- Recommended for all file path construction[1]

**Preload Script Path Resolution**
```javascript
const mainWindow = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js')
  }
});
```


This pattern ensures the preload script path is resolved relative to the main process file location.[1]

#### Electron App Paths

**app.getAppPath()**
- Returns the current application directory[7][6]
- Points to the folder containing your app's entry point[6]
- In development: Returns project root directory[6]
- In production: Returns `resources/app.asar` path[6]

**Example Usage:**
```javascript
const { app } = require('electron');
console.log(app.getAppPath());
// Development: /home/user/projects/myapp
// Production: /opt/MyApp/resources/app.asar
```


**app.getPath(name)**
Returns paths to special directories:[7]
- `home` - User's home directory
- `appData` - Per-user application data directory
- `userData` - Directory for storing app's configuration files
- `temp` - Temporary file directory
- `exe` - Current executable file
- `module` - libchromiumcontent library
- `desktop` - User's Desktop directory
- `documents` - User's Documents directory
- `downloads` - User's Downloads directory
- `music` - User's Music directory
- `pictures` - User's Pictures directory
- `videos` - User's Videos directory

#### Accessing Resources and Assets

**Development vs Production Paths**
When linking to assets from HTML or loading resources, paths differ between environments:[8]

**Development:**
```javascript
// Relative paths work in development
<link rel="stylesheet" href="assets/style.css">
```

**Production (Packaged App):**
```javascript
// Need to resolve paths relative to app resources
const resourcePath = path.join(process.resourcesPath, 'assets', 'style.css');
```


**Using extraResources for Assets**
Configure electron-builder to include assets in the resources folder:[8]
```json
{
  "build": {
    "files": [
      "node_modules/",
      "index.html",
      "main.js"
    ],
    "extraResources": [
      {
        "from": "../assets/",
        "to": "assets/"
      }
    ]
  }
}
```


#### Renderer Process Path Access

**The Problem**
Renderer processes don't have access to `__dirname` by default due to context isolation.[3]

**Solution: Expose Paths via Preload**
```javascript
// preload.js
const { contextBridge } = require('electron');
const path = require('path');

contextBridge.exposeInMainWorld('paths', {
  appPath: __dirname,
  join: (...args) => path.join(...args)
});
```


**Renderer Usage:**
```javascript
// renderer.js
const filePath = window.paths.join(window.paths.appPath, 'data', 'file.txt');
```

#### Workarounds for Missing __dirname

**In Sandboxed Preload Scripts**
Since `__dirname` is not available in sandboxed preload, use alternatives:[5][4]

**Option 1: Use import.meta.url (ES modules)**
```javascript
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
```


**Option 2: Use path.dirname**
```javascript
import path from 'path';

webPreferences: {
  preload: path.dirname + "/preload.js"
}
```


**Note:** The best approach is to keep preload scripts in predictable locations and use hardcoded relative paths or move path-dependent logic to the main process.

#### Best Practices

**1. Always Use path.join()**
Never concatenate paths with string operators:[1]
```javascript
// ❌ Bad - breaks on different platforms
const filePath = __dirname + '/data/file.txt';

// ✅ Good - cross-platform compatible
const filePath = path.join(__dirname, 'data', 'file.txt');
```

**2. Resolve Paths at Build Time**
For bundled applications, resolve critical paths during build configuration rather than runtime.[2]

**3. Use app.getPath() for User Directories**
Store user data in appropriate OS-specific locations:[7]
```javascript
const userDataPath = app.getPath('userData');
const configPath = path.join(userDataPath, 'config.json');
```

**4. Handle Development vs Production**
Create path helpers that work in both environments:[6]
```javascript
const isDev = !app.isPackaged;
const resourcesPath = isDev 
  ? path.join(__dirname, 'assets')
  : path.join(process.resourcesPath, 'assets');
```

Sources
[1] Using Preload Scripts - Electron https://electronjs.org/docs/latest/tutorial/tutorial-preload
[2] Electron Accessing Files - Quasar Framework https://quasar.dev/quasar-cli-vite/developing-electron-apps/electron-accessing-files/
[3] Unable to access __dirname variable in Renderer Process, in an ... https://stackoverflow.com/questions/63628494/unable-to-access-dirname-variable-in-renderer-process-in-an-electronjs-app
[4] Target: electron-preload outputs non-working js #16617 - GitHub https://github.com/webpack/webpack/issues/16617
[5] Unable to load preload script · Issue #2931 · electron/forge - GitHub https://github.com/electron/forge/issues/2931
[6] Where is Electron's app.getAppPath() pointing to? https://stackoverflow.com/questions/40511744/where-is-electrons-app-getapppath-pointing-to
[7] app https://electronjs.org/docs/latest/api/app
[8] Build with relative paths · Issue #5725 · electron-userland ... https://github.com/electron-userland/electron-builder/issues/5725
[9] Development | electron-vite https://electron-vite.org/guide/dev
[10] How can I get the path that the application is running with typescript? https://stackoverflow.com/questions/37213696/how-can-i-get-the-path-that-the-application-is-running-with-typescript/37215237


---

# Inter-Process Communication (IPC)

### IPC Renderer Fundamentals

The `ipcRenderer` module enables asynchronous communication from renderer processes to the main process in Electron applications. It's an EventEmitter that provides methods for sending messages, receiving responses, and listening to events from the main process.[1][2][3]

#### Core Concept

**What It Is**
- Part of Electron's Inter-Process Communication (IPC) system[4][1]
- Available only in renderer processes (not main process)[2][1]
- Works in conjunction with `ipcMain` module in the main process[2][4]
- Must be exposed through preload scripts when context isolation is enabled[3][5]

**Security Requirement**
- Never expose `ipcRenderer` directly to the renderer[5][3]
- Always use preload scripts with Context Bridge to expose whitelisted methods[3][5]
- This prevents malicious code from accessing all IPC channels[5]

#### Primary Methods

**ipcRenderer.send(channel, ...args)**
- Sends a one-way asynchronous message to the main process[1][4][2]
- Does not expect a return value[6][4]
- Main process listens with `ipcMain.on()`[4][6]
- Arguments are serialized with Structured Clone Algorithm[1]

**Example - One-Way Communication:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('electronAPI', {
  setTitle: (title) => ipcRenderer.send('set-title', title)
})

// Renderer
window.electronAPI.setTitle('New Title')

// Main process
ipcMain.on('set-title', (event, title) => {
  const webContents = event.sender
  const win = BrowserWindow.fromWebContents(webContents)
  win.setTitle(title)
})
```


**ipcRenderer.invoke(channel, ...args)**
- Sends a message and expects an asynchronous result[7][3][1]
- Returns a Promise that resolves with the response from main process[3][1]
- Main process handles with `ipcMain.handle()`[4][3]
- Recommended for request-response patterns[7][3]

**Example - Two-Way Communication:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile')
})

// Renderer
const filePath = await window.electronAPI.openFile()

// Main process
ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog()
  if (!canceled) {
    return filePaths[0]
  }
})
```


**ipcRenderer.on(channel, listener)**
- Listens for messages from the main process[2][7][1]
- The listener callback receives `(event, ...args)` parameters[2]
- Can be called multiple times for continuous updates[7]
- Used for receiving broadcasts or continuous data streams from main process[7]

**Example - Receiving from Main:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('electronAPI', {
  onUpdateCounter: (callback) => ipcRenderer.on('update-counter', (_event, value) => callback(value))
})

// Renderer
window.electronAPI.onUpdateCounter((value) => {
  console.log(`Counter: ${value}`)
})

// Main process
setInterval(() => {
  mainWindow.webContents.send('update-counter', counter++)
}, 1000)
```


**ipcRenderer.once(channel, listener)**
- Adds a one-time listener for an event[1][2]
- Listener is automatically removed after being invoked once[1][2]
- Useful for single-response scenarios[2]

#### Additional Methods

**ipcRenderer.removeListener(channel, listener)**
- Removes the specified listener from the listener array[1][2]

**ipcRenderer.removeAllListeners(channel)**
- Removes all listeners for the specified channel[2]

**ipcRenderer.sendSync(channel, ...args)** (Deprecated)
- Sends a synchronous message to the main process and blocks until reply[2]
- **Not recommended** - blocks the renderer process[7]
- Use `invoke()` instead for better performance[7]

**ipcRenderer.postMessage(channel, message, [transfer])**
- Sends a message with optional MessagePort transfer[1]
- Used for advanced scenarios involving MessageChannel[1]

#### Communication Patterns

**Pattern 1: One-Way (send + on)**
Use when you don't need a response:[6][4]
- Renderer sends: `ipcRenderer.send()`
- Main receives: `ipcMain.on()`
- Use cases: Triggering actions, sending notifications, updating state[6]

**Pattern 2: Two-Way (invoke + handle)**
Use when you need a response:[4][7]
- Renderer sends: `ipcRenderer.invoke()`
- Main handles: `ipcMain.handle()`
- Returns Promise with result
- Use cases: File dialogs, database queries, API calls[5][7]

**Pattern 3: Main to Renderer (webContents.send + on)**
Main process broadcasts to renderer:[4][7]
- Main sends: `win.webContents.send()`
- Renderer receives: `ipcRenderer.on()`
- Use cases: Progress updates, real-time data, notifications[7]

#### send() vs invoke()

**Key Differences**:[7]

| Feature | send() + on() | invoke() + handle() |
|---------|--------------|---------------------|
| Response | No direct return | Returns Promise |
| Main handler | ipcMain.on() | ipcMain.handle() |
| Multiple calls | Can receive multiple times | One request, one response |
| Use case | Continuous updates | Single request-response |
| Examples | Progress bar, live data | File operations, queries |

#### Security Best Practices

**Secure Exposure Pattern:**
```javascript
// ❌ INSECURE - Don't do this
contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: require('electron').ipcRenderer
})

// ✅ SECURE - Whitelist specific channels
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile'),
  saveFile: (data) => ipcRenderer.invoke('dialog:saveFile', data)
})
```


**Prevent Callback Leakage:**
```javascript
// Don't pass event to callback - it contains ipcRenderer reference
contextBridge.exposeInMainWorld('electronAPI', {
  onUpdate: (callback) => ipcRenderer.on('update', (_event, value) => callback(value))
})
```


#### Accessing ipcRenderer

**Modern Approach (Context Isolation Enabled):**
Must be exposed via preload script using Context Bridge.[8][3][5]

**Legacy Approach (Not Recommended):**
Direct access in renderer if `nodeIntegration: true` (security risk).[8]

The ipcRenderer module is the foundation for secure, efficient communication between isolated renderer processes and the privileged main process in Electron applications.[4][1]

Sources
[1] ipcRenderer https://www.electronjs.org/docs/latest/api/ipc-renderer
[2] ipcRenderer | electron https://freesoftwaredevlopment.github.io/electron/docs/api/ipc-renderer.html
[3] electron/docs/api/ipc-renderer.md at main · electron/electron https://github.com/electron/electron/blob/main/docs/api/ipc-renderer.md
[4] Inter-Process Communication https://www.electronjs.org/docs/latest/tutorial/ipc
[5] Electron – 3 Methods for Inter Process Communications (IPC) https://www.intertech.com/electron-3-methods-for-inter-process-communications-ipc/
[6] Electron: Communicate from Renderer to Main Process https://fyfirman.com/blog/communicate-from-renderer-to-main-process
[7] What is the difference between IPC send / on and invoke / handle in electron? https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron/59889863
[8] Using the electron ipcRenderer from a front-end javascript file https://stackoverflow.com/questions/62433323/using-the-electron-ipcrenderer-from-a-front-end-javascript-file
[9] [Electron] IPC には新しい ipcRenderer.invoke() メソッドを ... https://qiita.com/jrsyo/items/abe19dff2d950132d9cd
[10] Bridging the Gap: Communicating Between the "Browser ... https://scott.willeke.com/bridging-the-gap-communicating-between-the-browser-renderer-and-the-main-process-in-an-electron-app/

---

### IPC Main Fundamentals

The `ipcMain` module handles asynchronous and synchronous communication from renderer processes to the main process in Electron applications. It's an Event Emitter that runs exclusively in the main process and provides methods for receiving messages and sending responses.[1][2][3]

#### Core Concept

**What It Is**
- IPC (Inter-Process Communication) module for the main process[2][3][1]
- Works in conjunction with `ipcRenderer` in renderer processes[4][5]
- Acts as a messaging bridge between isolated processes[5]
- Extends Node.js EventEmitter class[3][6]

**Purpose**
- Receives messages sent from renderer processes[2][3]
- Handles requests for main process operations (file system, native APIs, etc.)[4]
- Sends responses back to renderer processes[5][4]
- Broadcasts updates to one or more renderer processes[5]

#### Primary Methods

**ipcMain.on(channel, listener)**
- Listens for one-way messages from renderer processes[7][1][4]
- Used with `ipcRenderer.send()` from the renderer[4]
- Does not return a value to the renderer[4]
- Listener receives `(event, ...args)` parameters[1]
- Can respond using `event.sender.send()`[8]

**Example - One-Way Communication:**
```javascript
// Main process
const { ipcMain } = require('electron')

ipcMain.on('set-title', (event, title) => {
  const webContents = event.sender
  const win = BrowserWindow.fromWebContents(webContents)
  win.setTitle(title)
})
```


**ipcMain.handle(channel, listener)**
- Handles invoke-able IPC requests that expect a response[3][1]
- Used with `ipcRenderer.invoke()` from the renderer[1][4]
- Listener must return a value or Promise[3][1]
- Returns result automatically to the calling renderer[1]
- Recommended for request-response patterns[4]

**Example - Two-Way Communication:**
```javascript
// Main process
const { ipcMain, dialog } = require('electron')

ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog()
  if (!canceled) {
    return filePaths[0]
  }
})
```


**ipcMain.handleOnce(channel, listener)**
- Handles a single invoke-able IPC message, then removes the listener[3]
- Similar to `ipcMain.handle()` but automatically unregisters after first call[3]
- Useful for one-time operations[3]

**ipcMain.removeHandler(channel)**
- Removes any handler for the specified channel[1][3]
- Important for cleanup when handlers are no longer needed[3]

**ipcMain.removeListener(channel, listener)**
- Removes the specified listener from the listener array[1]

**ipcMain.removeAllListeners([channel])**
- Removes all listeners for the specified channel, or all listeners if no channel specified[1]

#### Event Object Properties

When handlers receive events, the event object contains useful properties:[1]

**event.processId**
- Internal ID of the renderer process that sent the message[1]

**event.frameId**
- ID of the renderer frame that sent the message[1]

**event.sender**
- Returns the `webContents` that sent the message[8][1]
- Use to send replies: `event.sender.send('reply-channel', data)`[8]

**event.senderFrame**
- The frame that sent the message[1]

**event.ports** (for postMessage)
- Array of MessagePorts sent with the message[1]

**event.returnValue** (synchronous only)
- Set this to send synchronous reply[8]

#### Communication Patterns

**Pattern 1: One-Way (send → on)**
Renderer sends message without expecting a response:[7][4]

```javascript
// Renderer (via preload)
ipcRenderer.send('set-title', 'New Title')

// Main
ipcMain.on('set-title', (event, title) => {
  // Process the message
  console.log(title)
})
```


**Pattern 2: Two-Way (invoke → handle)**
Renderer sends request and awaits response:[4]

```javascript
// Renderer (via preload)
const result = await ipcRenderer.invoke('perform-action', data)

// Main
ipcMain.handle('perform-action', async (event, data) => {
  // Process and return result
  return { success: true, result: processedData }
})
```


**Pattern 3: Main to Renderer**
Main process broadcasts to renderer:[5][8]

```javascript
// Main process
mainWindow.webContents.send('update-counter', newValue)

// Renderer listens with ipcRenderer.on('update-counter', callback)
```


#### Synchronous vs Asynchronous

**Asynchronous (Recommended)**
- Use `ipcMain.on()` for one-way async messages[2]
- Use `ipcMain.handle()` for request-response async messages[1]
- Non-blocking, better performance[2]

**Synchronous (Deprecated)**
- Use `ipcMain.on()` with `event.returnValue`[8]
- Blocks the renderer process until response is received[2]
- Not recommended - use `invoke/handle` pattern instead[4]

**Example - Synchronous (Legacy):**
```javascript
// Main
ipcMain.on('synchronous-message', (event, arg) => {
  console.log(arg) // prints "ping"
  event.returnValue = 'pong'
})

// Renderer
const result = ipcRenderer.sendSync('synchronous-message', 'ping')
```


#### Error Handling

**handle() Error Behavior**
- Errors thrown in `handle()` are serialized and sent to renderer[3]
- Only the `message` property from the original error is provided[3]
- Stack traces and other error properties are not transmitted[3]
- Renderer receives the error in rejected Promise[3]

**Example:**
```javascript
// Main
ipcMain.handle('risky-operation', async () => {
  throw new Error('Something went wrong')
})

// Renderer
try {
  await ipcRenderer.invoke('risky-operation')
} catch (error) {
  console.error(error.message) // "Something went wrong"
  // Stack trace not available
}
```

#### Best Practices

**Channel Naming**
- Use descriptive, namespaced channel names[4]
- Examples: `'dialog:openFile'`, `'window:minimize'`, `'data:fetch'`[4]
- Prevents channel name collisions[4]

**Security**
- Validate all data received from renderer processes[3]
- Don't trust renderer input - it could be compromised[3]
- Whitelist allowed channels in preload scripts[4]

**Memory Management**
- Remove listeners when no longer needed[1][3]
- Use `handleOnce()` for one-time operations[3]
- Clean up handlers when windows are closed[3]

The `ipcMain` module is the foundation for secure, bidirectional communication between the main process and renderer processes in Electron applications.[5][2][1]

Sources
[1] ipcMain https://www.electronjs.org/docs/latest/api/ipc-main
[2] Electron - Inter Process Communication https://www.tutorialspoint.com/electron/electron_inter_process_communication.htm
[3] ipcMain - Electron https://electronjs.org/docs/latest/api/ipc-main
[4] Inter-Process Communication https://www.electronjs.org/docs/latest/tutorial/ipc
[5] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[6] Communicating Between The... https://www.nickolinger.com/blog/electron-interprocess-communication/
[7] Inter-Process Communication | Electron http://electronproject.org/ipc.html
[8] ipcMain | Electron - GitHub Pages https://zeke.github.io/electron.atom.io/docs/api/ipc-main/
[9] ipcMain - Electron https://docs.w3cub.com/electron/api/ipc-main
[10] electron/docs/api/ipc-main.md at main · electron/electron https://github.com/electron/electron/blob/main/docs/api/ipc-main.md


---

### ipcRenderer.send() vs ipcRenderer.invoke()

The key difference between `ipcRenderer.send()` and `ipcRenderer.invoke()` is that `send()` returns void (no return value) while `invoke()` returns a Promise that resolves with the response from the main process.[1][7]

#### ipcRenderer.send()

**Characteristics**
- Sends one-way asynchronous messages to the main process[2][6]
- Returns `void` - does not expect or wait for a response[1]
- Used with `ipcMain.on()` in the main process[4][2]
- Non-blocking fire-and-forget communication[2]

**When to Use**
- Triggering actions that don't need a return value[1]
- Sending notifications or updates to main process[1]
- Starting operations where you don't need confirmation[2]
- Async updates over time (countdown, progress bar, data updates)[1]

**Example:**
```javascript
// Renderer (via preload)
ipcRenderer.send('set-title', 'New Title')

// Main process
ipcMain.on('set-title', (event, title) => {
  const webContents = event.sender
  const win = BrowserWindow.fromWebContents(webContents)
  win.setTitle(title)
})
```


**Getting a Response (Manual Pattern)**
If you need a response with `send()`, you must manually set up a return channel:[2]

```javascript
// Renderer
ipcRenderer.send('asynchronous-message', 'ping')
ipcRenderer.on('asynchronous-reply', (_event, arg) => {
  console.log(arg) // prints "pong"
})

// Main
ipcMain.on('asynchronous-message', (event, arg) => {
  event.sender.send('asynchronous-reply', 'pong')
})
```


**Downsides of Manual Response Pattern:**
- No obvious way to pair the reply message to the original message[2]
- For frequent messages, requires additional code to track each call and response[2]
- More complex and error-prone than `invoke()`[2]

#### ipcRenderer.invoke()

**Characteristics**
- Sends message and expects an asynchronous result[6][7]
- Returns `Promise<any>` that resolves with the main process response[6][1]
- Used with `ipcMain.handle()` in the main process[4][2]
- Supports async/await syntax[8][1]
- Throws error if handler doesn't exist[1]

**When to Use**
- Request-response patterns where you need a return value[7][1]
- Getting data from main process (file paths, settings, database queries)[1]
- Operations that need confirmation or results[2]
- Single request-response interactions[1]

**Example:**
```javascript
// Renderer (via preload)
const filePath = await ipcRenderer.invoke('dialog:openFile')

// Main process
ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog()
  if (!canceled) {
    return filePaths[0]
  }
})
```


**Benefits:**
- Cleaner, more ergonomic API for request-response[1]
- Response value returned directly as Promise[2][1]
- Works seamlessly with async/await[8][1]
- Automatic error handling - errors thrown in handler reject the Promise[6]

#### Comparison Table

| Feature | send() + on() | invoke() + handle() |
|---------|---------------|---------------------|
| Return value | void (none) | Promise<any> |
| Main handler | ipcMain.on() | ipcMain.handle() |
| Response | Manual via event.sender.send() | Automatic return value |
| Communication type | One-way (or manual two-way) | Two-way built-in |
| Use async/await | No | Yes |
| Error handling | Manual | Automatic via Promise rejection |
| Error when missing handler | No | Yes, throws error |
| Best for | Fire-and-forget, continuous updates | Request-response, single operations |

[7][1][2]

#### send() with Multiple Responses

**Unique Capability of send()/on()**
The renderer can receive data multiple times from the same channel using `send()` + `on()` as long as the main process is running:[1]

```javascript
// Renderer
ipcRenderer.on('progress-update', (_event, percent) => {
  console.log(`Progress: ${percent}%`)
})

// Main - sends multiple updates
for (let i = 0; i <= 100; i += 10) {
  mainWindow.webContents.send('progress-update', i)
  await delay(500)
}
```


This pattern is ideal for:
- Progress bars and loading indicators[1]
- Real-time data updates[1]
- Countdown timers[1]
- Live streaming data[1]

#### invoke() Limitations

**Single Response Only**
`invoke()` is designed for one request, one response. It cannot handle continuous updates like `send()` can.[1]

**No Main-to-Renderer invoke()**
There's no equivalent for `ipcRenderer.invoke()` for main-to-renderer IPC. If the main process needs a response from the renderer, use `send()` + `on()` pattern manually.[2]

#### Which to Choose?

**Use send():**
- When you don't need a response[2][1]
- For continuous/repeated updates from main to renderer[1]
- When implementing custom timeout logic[1]

**Use invoke():**
- When you need a single response value[2][1]
- For cleaner async/await code[8][1]
- When you want automatic error handling[6]
- For most request-response scenarios[2]

The `invoke()`/`handle()` API was introduced to improve ergonomics around the existing `send()`/`on()` pattern for returning values to the sender. Both approaches are functionally capable of the same things, but `invoke()` provides better developer experience for request-response patterns.[1]

Sources
[1] What is the difference between IPC send / on and invoke / handle in ... https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron
[2] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[3] what's the difference with invoke handle in Electron v7 #25 - GitHub https://github.com/sindresorhus/electron-better-ipc/issues/25
[4] Electron – 3 Methods for Inter Process Communications (IPC) https://www.intertech.com/electron-3-methods-for-inter-process-communications-ipc/
[5] What is the difference between IPC send / on and invoke / handle in electron? https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron/59889863
[6] ipcRenderer - Electron https://electronjs.org/docs/latest/api/ipc-renderer
[7] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[8] Electron JS Tutorial: ipcRenderer - All communication methods of ... https://www.youtube.com/watch?v=W7X177Af8Ls
[9] invoke - imodeljs-common - iTwin.js https://www.itwinjs.org/v2/reference/imodeljs-common/ipcsocket/ipcsocketfrontend/invoke/
[10] Best way to deal with ipc : r/electronjs - Reddit https://www.reddit.com/r/electronjs/comments/19adtpv/best_way_to_deal_with_ipc/


---

### ipcMain.on() vs ipcMain.handle()

The main difference between `ipcMain.on()` and `ipcMain.handle()` is how they return values: `on()` requires manually sending responses back through the event object, while `handle()` automatically returns values via Promise resolution.[1][5]

#### ipcMain.on()

**Characteristics**
- Listens for messages sent via `ipcRenderer.send()`[2][3]
- Does not automatically return values to the renderer[2]
- Can be used for both one-way and two-way communication[5]
- Supports synchronous communication via `event.returnValue`[5]
- Part of the traditional send/on IPC pattern[1]

**One-Way Communication (No Response):**
```javascript
// Main process
ipcMain.on('set-title', (event, title) => {
  const win = BrowserWindow.fromWebContents(event.sender)
  win.setTitle(title)
  // No response sent back
})
```


**Two-Way Asynchronous (Manual Response):**
```javascript
// Main process
ipcMain.on('asyncPing', (event, args) => {
  console.log("asyncPing received")
  // Manually send response back
  event.sender.send('asyncPong', 'response data')
})
```


**Synchronous Communication (Deprecated):**
```javascript
// Main process
ipcMain.on('syncPing', (event, args) => {
  console.log('syncPing received')
  // Set return value for synchronous communication
  event.returnValue = 'syncPong'
})
```


**Downsides:**
- Manual response requires setting up separate channels[1]
- No obvious way to pair reply messages with original requests[3]
- More code and complexity for request-response patterns[3]
- No built-in error handling[2]

#### ipcMain.handle()

**Characteristics**
- Handles requests sent via `ipcRenderer.invoke()`[3][2]
- Returns values automatically through Promise resolution[2]
- Always asynchronous, supports async/await[5][2]
- Throws error if handler doesn't exist when invoked[1]
- Part of the modern invoke/handle IPC pattern[1]

**Basic Usage:**
```javascript
// Main process
ipcMain.handle('handlePing', (event, args) => {
  console.log('handlePing received')
  // Simply return the value
  return 'handlePong'
})

// Renderer (via preload)
const response = await ipcRenderer.invoke('handlePing')
console.log(response) // 'handlePong'
```


**Async Operations:**
```javascript
// Main process
ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog()
  if (!canceled) {
    return filePaths[0]
  }
})

// Renderer (via preload)
const filePath = await ipcRenderer.invoke('dialog:openFile')
```


**Error Handling:**
```javascript
// Main process
ipcMain.handle('handlePingWithError', () => {
  throw new Error("Something Went Wrong")
})

// Renderer (via preload)
try {
  await ipcRenderer.invoke('handlePingWithError')
} catch (error) {
  console.error(error.message) // "Something Went Wrong"
}
```


**Note:** Errors are serialized - only the `message` property is sent to renderer, not the full stack trace.[2]

**Benefits:**
- Cleaner API similar to Express.js route handlers[5]
- Automatic Promise-based return mechanism[2]
- Works seamlessly with async/await[5][1]
- Built-in error handling via Promise rejection[5]
- Easier to reason about request-response flow[1]

#### Comparison Table

| Feature | ipcMain.on() | ipcMain.handle() |
|---------|--------------|------------------|
| Triggered by | ipcRenderer.send() | ipcRenderer.invoke() |
| Return value | Manual via event.sender.send() | Automatic via return statement |
| Response type | void (manual response) | Promise<any> |
| Async support | Manual async handling | Built-in async/await |
| Error handling | Manual | Automatic via Promise rejection |
| Synchronous support | Yes (event.returnValue) | No (always async) |
| Use case | Fire-and-forget, continuous updates | Request-response, single operations |
| Channel isolation | Shares EventEmitter namespace | Separate _invokeHandlers map |

[4][1][2][5]

#### Channel Name Isolation

You can safely register the same channel name for both `ipcMain.on()` and `ipcMain.handle()`:[4]

```javascript
// Both can coexist with the same channel name
ipcMain.handle('test', async (event, args) => {
  let result = await somePromise()
  return result
})

ipcMain.on('test', async (event, args) => {
  event.returnValue = await somePromise()
})
```


They maintain separate internal storage:
- `ipcMain.on()` uses Node.js EventEmitter's internal event structure[4]
- `ipcMain.handle()` stores handlers in a separate `_invokeHandlers` Map[4]
- Triggered by different renderer methods: `send/sendSync` vs `invoke`[4]

#### When to Use Each

**Use ipcMain.on():**
- One-way communication (no response needed)[3]
- Multiple responses over time from main to renderer[1]
- Custom timeout logic[1]
- Broadcasting updates to renderer processes[1]
- Legacy codebases using send/on pattern[1]

**Use ipcMain.handle():**
- Request-response patterns requiring a return value[3][5]
- Single operation that returns data[1]
- Cleaner async/await code[5][1]
- Automatic error handling needs[5]
- Modern Electron applications (recommended approach)[1]

#### Purpose and Evolution

The `invoke()`/`handle()` API was introduced as a new ergonomic improvement over the existing `send()`/`on()` pattern specifically for returning values to the sender. While both approaches are functionally capable of achieving the same results, `handle()` provides significantly better developer experience for request-response scenarios through automatic Promise handling and cleaner syntax.[5][1]

Sources
[1] What is the difference between IPC send / on and invoke / handle in electron? https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron/59889863
[2] ipcMain https://www.electronjs.org/docs/latest/api/ipc-main
[3] Inter-Process Communication https://www.electronjs.org/docs/latest/tutorial/ipc
[4] Electron: Can same channel name use for ipcMain.on and ipcMain.handle? https://stackoverflow.com/questions/64881837/electron-can-same-channel-name-use-for-ipcmain-on-and-ipcmain-handle
[5] Electron – 3 Methods for Inter Process Communications (IPC) https://www.intertech.com/electron-3-methods-for-inter-process-communications-ipc/
[6] Inter-Process Communication (IPC) in ElectronJS https://www.geeksforgeeks.org/node-js/inter-process-communication-ipc-in-electronjs/
[7] Best way to deal with ipc https://www.reddit.com/r/electronjs/comments/19adtpv/best_way_to_deal_with_ipc/
[8] Simplifying IPC in Electron https://texts.blog/2022/04/20/simplifying-ipc-in-electron/
[9] main -> renderer communication - Help me understand the syntax, please. https://www.reddit.com/r/electronjs/comments/13mcc3v/main_renderer_communication_help_me_understand/
[10] ipcMain - Electron http://electronproject.org/ipc-main.html

---

### Sending Data from Renderer to Main

Sending data from renderer to main process in Electron requires using the IPC (Inter-Process Communication) system through preload scripts and the Context Bridge API. The renderer cannot directly access main process functionality due to security isolation.[1][2]

#### Setup Requirements

**1. Configure BrowserWindow with Preload Script**
```javascript
// main.js
const mainWindow = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    contextIsolation: true,
    nodeIntegration: false
  }
});
```


**2. Create Preload Script to Expose IPC**
```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  sendData: (data) => ipcRenderer.send('data-from-renderer', data),
  invokeAction: (data) => ipcRenderer.invoke('action-from-renderer', data)
});
```


#### Method 1: One-Way Communication (send/on)

**Use Case:** Sending data without expecting a return value.[1]

**Renderer Process:**
```javascript
// renderer.js
const start = () => {
  window.electronAPI.sendData({
    active: true,
    startedAt: new Date()
  });
};
```


**Main Process:**
```javascript
// main.js
const { ipcMain } = require('electron');

ipcMain.on('data-from-renderer', (event, data) => {
  console.log('Received from renderer:', data);
  // Process the data
  // No automatic response
});
```


#### Method 2: Request-Response Communication (invoke/handle)

**Use Case:** Sending data and expecting a response.[2]

**Preload Script:**
```javascript
// preload.js
contextBridge.exposeInMainWorld('api', {
  getData: (key) => ipcRenderer.invoke('get-data', key),
  setData: (key, value) => ipcRenderer.invoke('set-data', key, value)
});
```


**Renderer Process:**
```javascript
// renderer.js
async function saveData() {
  const result = await window.api.setData('username', 'John Doe');
  console.log(result); // Response from main
}

async function loadData() {
  const value = await window.api.getData('username');
  console.log(value); // 'John Doe'
}
```


**Main Process:**
```javascript
// main.js
ipcMain.handle('get-data', (event, key) => {
  return store.get(key); // Return data
});

ipcMain.handle('set-data', (event, key, value) => {
  store.set(key, value);
  return { success: true };
});
```


#### Data Serialization

**Supported Data Types**
Electron's IPC uses the HTML standard **Structured Clone Algorithm** to serialize objects. Only certain types can be passed through IPC channels:[3]

**✅ Serializable Types:**
- Primitives: string, number, boolean, null, undefined
- Arrays (containing serializable types)
- Plain objects (with serializable properties)
- Date objects
- RegExp objects
- Blob, File, FileList
- ArrayBuffer, TypedArray
- Map, Set
- Buffers[4]

**❌ Not Serializable:**
- DOM objects (Element, Location, DOMMatrix)
- Node.js objects backed by C++ classes (process.env, Stream members)
- Electron objects backed by C++ classes (WebContents, BrowserWindow, WebFrame)
- Functions
- Symbols
- Custom class instances with prototypes[3]

#### Passing Complex Data Structures

**Arrays of Objects:**
```javascript
// Renderer
const postDetails = [
  { id: 1, score: 100, title: 'Post 1' },
  { id: 2, score: 200, title: 'Post 2' }
];

window.electronAPI.sendData(postDetails);
```


**Note:** Arrays of objects are serializable, but if serialization errors occur, you can manually stringify:[4]
```javascript
// If automatic serialization fails
const serialized = JSON.stringify(postDetails);
window.electronAPI.sendData(serialized);

// Main process
ipcMain.on('data-from-renderer', (event, data) => {
  const parsed = JSON.parse(data);
});
```


#### Multiple Arguments

You can send multiple arguments in a single IPC call:[5]

**Renderer:**
```javascript
ipcRenderer.send('hello', ['one', 'two', 'three']);
```

**Main:**
```javascript
ipcMain.on('hello', (e, data) => {
  console.log(data); // ['one', 'two', 'three']
  e.reply('nice', data);
});
```


#### Complete Example: Productivity Tracker

**Preload Script:**
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('productivity', {
  start: (data) => ipcRenderer.send('productivity-changed', data),
  stop: (data) => ipcRenderer.send('productivity-changed', data)
});
```


**Renderer:**
```javascript
const start = () => {
  window.productivity.start({
    active: true,
    startedAt: new Date()
  });
};

const stop = () => {
  window.productivity.stop({
    active: false
  });
};
```


**Main Process:**
```javascript
ipcMain.on('productivity-changed', (event, data) => {
  if (data.active) {
    tray.setImage(activeIcon);
  } else {
    tray.setImage(inactiveIcon);
  }
});
```


#### Best Practices

**1. Never Expose Full IPC Modules**
```javascript
// ❌ INSECURE
contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: require('electron').ipcRenderer
});

// ✅ SECURE - Whitelist specific functions
contextBridge.exposeInMainWorld('api', {
  sendData: (data) => ipcRenderer.send('channel', data)
});
```

**2. Validate Data in Main Process**
Always validate and sanitize data received from renderer:[2]
```javascript
ipcMain.handle('set-data', (event, key, value) => {
  if (typeof key !== 'string' || !value) {
    throw new Error('Invalid parameters');
  }
  store.set(key, value);
  return { success: true };
});
```

**3. Use Descriptive Channel Names**
Use namespaced channel names to avoid collisions:[2]
```javascript
// Good examples
'data:fetch'
'user:update'
'file:save'
```

**4. Handle Errors Gracefully**
```javascript
// Renderer
try {
  const result = await window.api.saveData(data);
} catch (error) {
  console.error('Failed to save:', error.message);
}
```

The key to secure data transfer from renderer to main is using the preload script with Context Bridge to create a controlled, whitelisted API surface.[1][2]

Sources
[1] Electron: Communicate from Renderer to Main Process https://fyfirman.com/blog/communicate-from-renderer-to-main-process
[2] Electron: Executing Main Process Code from Renderer https://ncoughlin.com/posts/electron-executing-main-process-code-from-renderer
[3] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[4] Can Electron IPC Handle Arrays of Objects? Encountering ... - Reddit https://www.reddit.com/r/electronjs/comments/1ag3dub/can_electron_ipc_handle_arrays_of_objects/
[5] How can we send messages from the main process to renderer process in Electron https://stackoverflow.com/questions/52124675/how-can-we-send-messages-from-the-main-process-to-renderer-process-in-electron
[6] main -> renderer communication - Help me understand the syntax, please. https://www.reddit.com/r/electronjs/comments/13mcc3v/main_renderer_communication_help_me_understand/
[7] Inter-Process Communication https://www.electronjs.org/docs/latest/tutorial/ipc
[8] ipcRenderer https://www.electronjs.org/docs/latest/api/ipc-renderer
[9] Passing data from main to renderer (electron-js) - Stack Overflow https://stackoverflow.com/questions/73128159/passing-data-from-main-to-renderer-electron-js
[10] How to send information from one window to another in Electron ... https://ourcodeworld.com/articles/read/536/how-to-send-information-from-one-window-to-another-in-electron-framework

---

### Sending Data from Main to Renderer

The main process sends data to renderer processes using the `webContents.send()` method, which is part of the webContents object associated with each BrowserWindow. The renderer receives messages through listeners set up in preload scripts.[1][2][3][4]

#### Using webContents.send()

**Basic Syntax**
`webContents.send(channel, ...args)` sends an asynchronous message to the renderer process via a specified channel.[3][4]

**Main Process - Sending:**
```javascript
const { BrowserWindow } = require('electron');

const mainWindow = new BrowserWindow({ width: 800, height: 600 });

// Send data to renderer
mainWindow.webContents.send('update-counter', 42);
```


**Preload Script - Setting Up Receiver:**
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  onUpdateCounter: (callback) => {
    ipcRenderer.on('update-counter', (_event, value) => callback(value));
  }
});
```


**Renderer Process - Receiving:**
```javascript
window.electronAPI.onUpdateCounter((value) => {
  console.log(`Counter value: ${value}`);
  document.getElementById('counter').textContent = value;
});
```

#### Complete Example: Settings Configuration

**Main Process:**
```javascript
const { app, BrowserWindow } = require('electron');

let mainWindow;

app.whenReady().then(() => {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true
    }
  });

  mainWindow.loadFile('index.html');

  // Send settings after page loads
  mainWindow.webContents.on('did-finish-load', () => {
    const settings = {
      theme: 'dark',
      language: 'en',
      fontSize: 14
    };
    mainWindow.webContents.send('sendSettings', settings);
  });
});
```


**Preload Script:**
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('bridge', {
  receiveSettings: (callback) => {
    ipcRenderer.on('sendSettings', (_event, settings) => {
      callback(settings);
    });
  }
});
```


**Renderer:**
```javascript
window.bridge.receiveSettings((settings) => {
  console.log('Received settings:', settings);
  applySettings(settings);
});
```


#### Timing Considerations

**Wait for Page Load**
Always send data after the page has finished loading to ensure the renderer is ready to receive:[3]

```javascript
mainWindow.webContents.on('did-finish-load', () => {
  mainWindow.webContents.send('ping', 'whoooooooh!');
});
```


**Common Events for Timing:**
- `did-finish-load` - Page and resources finished loading
- `dom-ready` - DOM is ready but resources may still be loading
- `ready-to-show` - Window is ready to be displayed

#### Broadcasting to Multiple Windows

**Sending to Specific Window:**
```javascript
const win1 = new BrowserWindow({ /*...*/ });
const win2 = new BrowserWindow({ /*...*/ });

// Send only to win1
win1.webContents.send('message', 'Hello Window 1');

// Send only to win2
win2.webContents.send('message', 'Hello Window 2');
```


**Sending to All Windows:**
```javascript
const { BrowserWindow } = require('electron');

function broadcastToAll(channel, data) {
  BrowserWindow.getAllWindows().forEach((window) => {
    window.webContents.send(channel, data);
  });
}

broadcastToAll('update-data', { value: 100 });
```


#### Two-Way Communication Pattern

**Main Initiates, Renderer Responds:**
```javascript
// Main process
ipcMain.on('request-data', (event) => {
  // Send data back to the specific renderer that requested it
  event.sender.send('data-response', { result: 'some data' });
});

// Or use event.reply() as a shorthand
ipcMain.on('request-data', (event) => {
  event.reply('data-response', { result: 'some data' });
});
```


**Preload:**
```javascript
contextBridge.exposeInMainWorld('api', {
  requestData: () => ipcRenderer.send('request-data'),
  onDataResponse: (callback) => {
    ipcRenderer.on('data-response', (_event, data) => callback(data));
  }
});
```

**Renderer:**
```javascript
// Request data
window.api.requestData();

// Listen for response
window.api.onDataResponse((data) => {
  console.log('Received:', data);
});
```

#### Alternative: executeJavaScript()

**Direct Code Execution**
You can execute JavaScript directly in the renderer context:[2]

```javascript
win.webContents.on('did-finish-load', () => {
  win.webContents.executeJavaScript("console.log('hello from main');");
  
  // Set variables
  win.webContents.executeJavaScript(`
    window.mySettings = ${JSON.stringify(settings)};
  `);
});
```


**Note:** This approach is less secure than IPC and should be used cautiously. It directly executes code in the renderer without going through the preload security layer.

#### Continuous Updates Pattern

**Real-Time Data Stream:**
```javascript
// Main process - send periodic updates
let counter = 0;
setInterval(() => {
  mainWindow.webContents.send('update-counter', counter++);
}, 1000);
```


**Use Cases:**
- Progress bars
- Real-time notifications
- Live data feeds
- Status updates
- Timer/countdown displays

#### Best Practices

**1. Use Descriptive Channel Names**
```javascript
// Good - namespaced and descriptive
mainWindow.webContents.send('settings:updated', data);
mainWindow.webContents.send('download:progress', percentage);
mainWindow.webContents.send('user:login-status', status);
```

**2. Always Use Preload Scripts**
Never expose `ipcRenderer` directly to the renderer:[2]
```javascript
// ✅ SECURE - Whitelist in preload
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => ipcRenderer.on('update', (_event, data) => callback(data))
});
```

**3. Remove Event Listeners**
Clean up listeners when components unmount or windows close:
```javascript
// Renderer cleanup
const unsubscribe = () => {
  window.removeEventListener('beforeunload', cleanup);
};
```

**4. Validate Data**
Even data from main process should be validated in the renderer to prevent bugs:
```javascript
window.api.onSettings((settings) => {
  if (!settings || typeof settings !== 'object') {
    console.error('Invalid settings received');
    return;
  }
  applySettings(settings);
});
```

The key to main-to-renderer communication is using `webContents.send()` from the main process and setting up secure listeners through preload scripts using Context Bridge.[1][2][3]

Sources
[1] How can we send messages from the main process to renderer process in Electron https://stackoverflow.com/questions/52124675/how-can-we-send-messages-from-the-main-process-to-renderer-process-in-electron
[2] Passing data from main to renderer (electron-js) https://stackoverflow.com/questions/73128159/passing-data-from-main-to-renderer-electron-js
[3] webContents | electron - GitHub Pages https://freesoftwaredevlopment.github.io/electron/docs/api/web-contents.html
[4] webContents | Electron https://www.electronjs.org/docs/latest/api/web-contents
[5] Send data from main.js of electronjs app to the client system ... https://dustinpfister.github.io/2022/03/21/electronjs-webcontents-send/
[6] How to send data to an renderer and then get a return value? · Issue #3642 · electron/electron https://github.com/electron/electron/issues/3642
[7] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[8] webContents · GitBook http://electron.ebookchain.org/en/api/web-contents.html
[9] Inter-Process Communication (IPC) in ElectronJS https://www.geeksforgeeks.org/node-js/inter-process-communication-ipc-in-electronjs/
[10] webContents | electron-gitbook - xwartz https://xwartz.gitbooks.io/electron-gitbook/content/en/api/web-contents.html

---

### Event Handling and Listeners

Event handling in Electron's IPC system uses the EventEmitter pattern, where listeners are attached to channels to receive messages. Proper management of event listeners is critical to prevent memory leaks and ensure application stability.[1][2][3][4]

#### Adding Event Listeners

**ipcRenderer.on(channel, listener)**
Listens for events on a specific channel:[2]
```javascript
// Preload script
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => {
    ipcRenderer.on('update-data', (_event, data) => {
      callback(data);
    });
  }
});
```

**ipcRenderer.once(channel, listener)**
Adds a one-time listener that automatically removes itself after being invoked:[5][2]
```javascript
// Listener is invoked only once, then removed
ipcRenderer.once('single-event', (_event, data) => {
  console.log('This will only execute once');
});
```

**ipcMain.on(channel, listener)**
Main process listens for events from renderer:[6][7]
```javascript
ipcMain.on('message-from-renderer', (event, data) => {
  console.log('Received:', data);
});
```

**ipcMain.once(channel, listener)**
Main process one-time listener:[7][6]
```javascript
ipcMain.once('init-message', (event, data) => {
  console.log('Initialization complete');
  // Automatically removed after first call
});
```

#### Removing Event Listeners

**removeListener() / off()**
Removes a specific listener from a channel:[1][2]
```javascript
// Store reference to the listener function
const handleUpdate = (event, data) => {
  console.log('Update received:', data);
};

// Add listener
ipcRenderer.on('update', handleUpdate);

// Remove specific listener later
ipcRenderer.removeListener('update', handleUpdate);
// Or use alias:
ipcRenderer.off('update', handleUpdate);
```


**removeAllListeners([channel])**
Removes all listeners from a channel, or all channels if no channel specified:[2][5]
```javascript
// Remove all listeners from specific channel
ipcRenderer.removeAllListeners('update-data');

// Remove all listeners from all channels
ipcRenderer.removeAllListeners();
```


**ipcMain.removeHandler(channel)**
Removes invoke handler from main process:[7]
```javascript
ipcMain.removeHandler('get-data');
```

#### Memory Leak Prevention

**The Problem**
IPC listeners that aren't properly cleaned up cause memory leaks:[3][4][8]
- Each component re-render can add a new listener without removing the old one[8]
- Unregistered listeners accumulate over time[3]
- Memory usage grows indefinitely, especially with frequent IPC calls[4]
- RSS (memory) increases even if heap doesn't show leaks[3]

**Common Memory Leak Pattern:**
```javascript
// ❌ BAD: Creates new listener on each render
function Component() {
  ipcRenderer.on('data-update', handler);
  // Never removed - memory leak!
}
```


**Correct Pattern with Cleanup:**
```javascript
// ✅ GOOD: Remove listener on unmount
function Component() {
  const handler = (event, data) => {
    console.log(data);
  };
  
  ipcRenderer.on('data-update', handler);
  
  // Cleanup function
  return () => {
    ipcRenderer.removeListener('data-update', handler);
  };
}
```


#### React/Framework Integration

**Using useEffect in React:**
```javascript
import { useEffect } from 'react';

function MyComponent() {
  useEffect(() => {
    const handleUpdate = (event, data) => {
      console.log('Received:', data);
    };
    
    // Add listener when component mounts
    ipcRenderer.on('update-data', handleUpdate);
    
    // Remove listener when component unmounts
    return () => {
      ipcRenderer.removeListener('update-data', handleUpdate);
    };
  }, []); // Empty dependency array = runs once on mount
  
  return <div>My Component</div>;
}
```


**Via Context Bridge:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => {
    ipcRenderer.on('update', (_event, data) => callback(data));
  },
  removeUpdateListener: (callback) => {
    ipcRenderer.removeListener('update', callback);
  }
});

// React component
useEffect(() => {
  const handleUpdate = (data) => {
    setData(data);
  };
  
  window.api.onUpdate(handleUpdate);
  
  return () => {
    window.api.removeUpdateListener(handleUpdate);
  };
}, []);
```

#### Debugging Listener Issues

**Check Listener Count:**
```javascript
// Monitor number of listeners on a channel
const count = ipcRenderer.listenerCount('event-name');
console.log(`Active listeners: ${count}`);
```


**Warning Signs:**
- Increasing listener count on same channel[3]
- Growing RSS memory without heap growth[3]
- Duplicate event handling[1]
- Events firing multiple times per action[1]

#### Common Issues and Solutions

**Issue: Multiple Listeners on Same Channel**
```javascript
// Problem: Listener added multiple times
componentDidMount() {
  ipcRenderer.on('data-bridge', handler); // Added every mount
}
```


**Solution 1: Remove Before Adding:**
```javascript
componentDidMount() {
  // Remove any existing listeners first
  ipcRenderer.removeAllListeners('data-bridge');
  // Then add the listener
  ipcRenderer.on('data-bridge', handler);
}
```


**Solution 2: Use once() for Single Execution:**
```javascript
// Automatically removes after first invocation
ipcRenderer.once('data-bridge', handler);
```

**Issue: removeListener() Not Working**
The listener reference must be exactly the same:[9][1]
```javascript
// ❌ Won't work - different function references
ipcRenderer.on('event', (e, d) => console.log(d));
ipcRenderer.removeListener('event', (e, d) => console.log(d));

// ✅ Works - same reference
const handler = (e, d) => console.log(d);
ipcRenderer.on('event', handler);
ipcRenderer.removeListener('event', handler);
```


**Issue: Memory Leak with webContents.send**
Frequent `webContents.send()` calls with active `ipcRenderer.on()` listeners can cause memory leaks:[4]
```javascript
// Problem occurs when calling send() very frequently (e.g., every 100ms)
mainWindow.webContents.send('update', data);
```

**Solution:** Throttle or debounce frequent updates, and ensure listeners are properly cleaned up.[4]

#### Best Practices

**1. Always Clean Up Listeners**
```javascript
// Store reference for cleanup
const listeners = [];

function addListener(channel, handler) {
  ipcRenderer.on(channel, handler);
  listeners.push({ channel, handler });
}

function cleanup() {
  listeners.forEach(({ channel, handler }) => {
    ipcRenderer.removeListener(channel, handler);
  });
}
```


**2. Use once() for Single Events**
If you only need to handle an event once, use `once()` to avoid manual cleanup:[2]
```javascript
ipcRenderer.once('init-complete', (event, data) => {
  // Automatically removed after execution
});
```

**3. Monitor Memory Usage**
Track RSS and listener counts in development:[3]
```javascript
setInterval(() => {
  console.log('RSS:', process.memoryUsage().rss);
  console.log('Listeners:', ipcRenderer.listenerCount('channel-name'));
}, 5000);
```

**4. Implement Lifecycle Cleanup**
Remove listeners when windows close or components unmount:[3]
```javascript
window.addEventListener('beforeunload', () => {
  ipcRenderer.removeAllListeners();
});
```

Proper event listener management is essential for building stable, memory-efficient Electron applications. Always pair listener registration with cleanup to prevent resource leaks.[4][3]

Sources
[1] How to unregister from ipcRenderer.on event listener? https://stackoverflow.com/questions/57418499/how-to-unregister-from-ipcrenderer-on-event-listener
[2] ipcRenderer - Electron https://electronjs.org/docs/latest/api/ipc-renderer
[3] Debugging and Troubleshooting Common Electron Issues https://blog.openreplay.com/debugging-troubleshooting-electron-issues/
[4] Memory leak when passing IPC events over contextBridge https://github.com/electron/electron/issues/27039
[5] ipcRenderer | electron - GitHub Pages https://freesoftwaredevlopment.github.io/electron/docs/api/ipc-renderer.html
[6] ipcMain · Electron documentation https://tinydew4.gitbooks.io/electron/api/ipc-main.html
[7] ipcMain - Electron https://electronjs.org/docs/latest/api/ipc-main
[8] How to Prevent Event Emitter Memory Leaks in Your ReactJS Application https://www.youtube.com/watch?v=dRToKpcS4Ho
[9] `ipcRenderer.off` does not remove the listener · Issue #45224 - GitHub https://github.com/electron/electron/issues/45224
[10] What best practices for cleaning up event handler references? https://stackoverflow.com/questions/3258064/what-best-practices-for-cleaning-up-event-handler-references


---

### Async/Await Patterns with IPC

Electron's `invoke()`/`handle()` API is specifically designed for async/await patterns, making asynchronous request-response communication ergonomic and Promise-based. This modern approach simplifies handling asynchronous operations between processes.[1][2][3]

#### Basic invoke/handle Pattern

**The invoke() Method**
`ipcRenderer.invoke()` returns a Promise that resolves with the response from the main process:[3][4]
- Must be used inside an async function or with `.then()`[3]
- Waits for response from main process[3]
- Supports async/await syntax natively[2]

**The handle() Method**
`ipcMain.handle()` can be an async function that returns a value:[5][1]
- Automatically handles Promise resolution[1]
- Return value is sent back to renderer[1]
- Errors are automatically caught and rejected[6]

#### Complete Example

**Preload Script:**
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  doInvoke: (channel, data) => {
    const validChannels = ['some-channel'];
    if (validChannels.includes(channel)) {
      return ipcRenderer.invoke(channel, data);
    }
  }
});
```


**Main Process:**
```javascript
const { ipcMain } = require('electron');

ipcMain.handle('some-channel', async (event, data) => {
  const result = await doSomeWork(data);
  return result;
});

async function doSomeWork(data) {
  console.log(data); // logs 'test-string'
  // Simulate async operation
  await new Promise(resolve => setTimeout(resolve, 1000));
  return data + 's';
}
```


**Renderer Process (with async/await):**
```javascript
async function handleKeyup() {
  try {
    const response = await window.api.doInvoke('some-channel', 'test-string');
    console.log(response); // logs 'test-strings'
  } catch (error) {
    console.error('Error:', error.message);
  }
}
```


**Renderer Process (with .then()):**
```javascript
window.api.doInvoke('some-channel', 'test-string')
  .then(result => {
    console.log(result); // logs 'test-strings'
  })
  .catch(error => {
    console.error('Error:', error.message);
  });
```


#### Common Pattern: Database Operations

**Main Process:**
```javascript
ipcMain.handle('db:get-user', async (event, userId) => {
  const user = await database.users.findById(userId);
  return user;
});

ipcMain.handle('db:save-user', async (event, userData) => {
  const savedUser = await database.users.create(userData);
  return { success: true, user: savedUser };
});
```

**Renderer:**
```javascript
async function loadUser(userId) {
  const user = await window.api.getUser(userId);
  displayUser(user);
}

async function saveUser(userData) {
  const result = await window.api.saveUser(userData);
  if (result.success) {
    console.log('User saved:', result.user);
  }
}
```

#### Error Handling

**Errors in handle() are Serialized**
Errors thrown in `ipcMain.handle()` are automatically caught and sent to the renderer as rejected Promises:[6]

**Main Process:**
```javascript
ipcMain.handle('risky-operation', async (event, data) => {
  if (!data.valid) {
    throw new Error('Invalid data provided');
  }
  return await performOperation(data);
});
```

**Renderer:**
```javascript
try {
  const result = await window.api.riskyOperation({ valid: false });
} catch (error) {
  console.error(error.message); // 'Invalid data provided'
  // Note: Only error.message is transmitted, not the full stack
}
```


#### Advanced Pattern: Request/Response Architecture

**Type-Safe IPC with Promises:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('api', {
  send: (channel, data) => {
    return new Promise((resolve, reject) => {
      const responseChannel = `${channel}-response`;
      
      // Listen for response once
      ipcRenderer.once(responseChannel, (_event, response) => {
        if (response.error) {
          reject(new Error(response.error));
        } else {
          resolve(response.data);
        }
      });
      
      // Send request
      ipcRenderer.send(channel, data);
    });
  }
});
```


This pattern allows async/await with the traditional `send()`/`on()` pattern.[7]

#### Multiple Async Operations

**Sequential Execution:**
```javascript
async function processMultiple() {
  const user = await window.api.getUser(1);
  const posts = await window.api.getUserPosts(user.id);
  const comments = await window.api.getPostComments(posts[0].id);
  
  return { user, posts, comments };
}
```

**Parallel Execution:**
```javascript
async function loadDashboard() {
  const [user, settings, notifications] = await Promise.all([
    window.api.getUser(),
    window.api.getSettings(),
    window.api.getNotifications()
  ]);
  
  return { user, settings, notifications };
}
```

#### Why invoke/handle Over send/on for Async?

**Benefits of invoke/handle**:[2][1]
1. Built-in Promise support - works seamlessly with async/await
2. Automatic response pairing - no need to manage separate response channels
3. Error handling via Promise rejection
4. Cleaner, more maintainable code
5. Throws error if handler doesn't exist

**send/on limitations for async**:[1]
- No built-in way to pair responses with requests
- Manual channel management for responses
- More complex code for simple request-response
- No automatic error handling

#### When to Use send/on Instead

Use `send()`/`on()` when you need:[2]
- Fire-and-forget messages (no response needed)
- Multiple responses over time (progress updates, streaming data)
- Custom timeout logic
- Broadcasting from main to multiple renderers

#### Timeout Pattern with invoke

**Adding Timeout to invoke:**
```javascript
async function invokeWithTimeout(channel, data, timeoutMs = 5000) {
  return Promise.race([
    window.api.invoke(channel, data),
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Request timeout')), timeoutMs)
    )
  ]);
}

// Usage
try {
  const result = await invokeWithTimeout('slow-operation', data, 3000);
} catch (error) {
  console.error('Operation failed or timed out:', error.message);
}
```

#### Best Practices

**1. Always Handle Errors**
```javascript
// ✅ Good
try {
  const result = await window.api.getData();
  processResult(result);
} catch (error) {
  handleError(error);
}

// ❌ Bad - unhandled promise rejection
const result = await window.api.getData();
```

**2. Use Descriptive Channel Names**
```javascript
// Clear intent
await window.api.invoke('user:fetch', userId);
await window.api.invoke('settings:save', settings);
await window.api.invoke('file:read', filePath);
```

**3. Return Structured Responses**
```javascript
ipcMain.handle('operation', async (event, data) => {
  try {
    const result = await performOperation(data);
    return { success: true,  result };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
```

**4. Validate Input in Main Process**
```javascript
ipcMain.handle('save-data', async (event, data) => {
  if (!data || typeof data !== 'object') {
    throw new Error('Invalid data format');
  }
  return await saveToDatabase(data);
});
```

The `invoke()`/`handle()` pattern with async/await is the recommended modern approach for request-response IPC in Electron, providing cleaner syntax and better error handling than traditional methods.[2][3][1]

Sources
[1] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[2] What is the difference between IPC send / on and invoke / handle in electron? https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron/59889863
[3] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[4] useIpcRendererInvoke | VueUse https://v9-13-0.vueuse.org/electron/useipcrendererinvoke/
[5] IpcMain : add support for async callbacks · Issue #386 - GitHub https://github.com/ElectronNET/Electron.NET/issues/386
[6] How to pass exceptions in Electron.js from main process to renderer ... https://dev.to/oryaacov/how-to-pass-exceptions-in-electronjs-from-main-process-to-rendered-and-other-way-around-1b69
[7] Electron IPC Response/Request architecture with TypeScript https://blog.logrocket.com/electron-ipc-response-request-architecture-with-typescript/
[8] Await Promise in Electron ipcRenderer.invoke via context bridge https://stackoverflow.com/questions/75791003/await-promise-in-electron-ipcrenderer-invoke-via-context-bridge
[9] Electron – 3 Methods for Inter Process Communications (IPC) https://www.intertech.com/electron-3-methods-for-inter-process-communications-ipc/
[10] Advanced Inter-Process Communication Patterns | Chapter 7 https://seino-prince.com/book/2b3b4ab5-d136-81fb-8232-c0df9dc6329f/chapter/2b3b4ab5-d136-81cd-aa15-e1545aff73bd/section/2b3b4ab5-d136-81e2-bda2-c3b31cb70e35

---

### Data Serialization Constraints

Electron's IPC uses the **HTML standard Structured Clone Algorithm** to serialize objects passed between processes, which imposes strict limitations on what types of data can be transmitted.[1][2][3]

#### Serialization Algorithm

**Structured Clone Algorithm**
- Same serialization used by `window.postMessage` in browsers[3]
- Automatically handles serialization and deserialization[4][5]
- Creates deep copies, not references[6]
- Prototype chains are not preserved[5][3]

#### Serializable Data Types

**✅ Supported Types:**
- **Primitives**: `string`, `number`, `boolean`, `null`, `undefined`, `BigInt`
- **Objects**: Plain objects (Object literals)
- **Arrays**: Arrays containing serializable types
- **Dates**: `Date` objects
- **RegExp**: Regular expressions
- **Typed Arrays**: `Int8Array`, `Uint8Array`, `Float32Array`, etc.
- **ArrayBuffer**: Binary data buffers
- **Map**: Map objects
- **Set**: Set objects
- **Blob**: Binary large objects[3]
- **Buffer**: Node.js buffers[4]

[1][3]

**Example - Valid Data:**
```javascript
// All of these can be sent via IPC
ipcRenderer.send('channel', {
  string: 'hello',
  number: 42,
  boolean: true,
  array: [1, 2, 3],
  nested: { key: 'value' },
  date: new Date(),
  regexp: /test/,
  map: new Map([['key', 'value']]),
  set: new Set([1, 2, 3]),
  buffer: Buffer.from('data')
});
```

#### Non-Serializable Types

**❌ Not Supported:**

**DOM Objects:**
- `Element` (HTML elements)
- `Location`
- `DOMMatrix`
- `ImageBitmap`
- `File` (DOM File objects)
- `DOMRect`

[1][3]

**Node.js Objects Backed by C++ Classes:**
- `process.env`
- Some members of `Stream`
- Native C++ addon objects

[2][1]

**Electron Objects Backed by C++ Classes:**
- `WebContents`
- `BrowserWindow`
- `WebFrame`
- Other Electron API objects

[2][3][1]

**JavaScript Objects with Special Behavior:**
- **Functions**: Cannot be serialized[7][5]
- **Symbols**: Not serializable[7]
- **Classes/Prototypes**: Prototype chains are lost[3]
- **Circular references**: May cause issues

[5][7]

#### Common Serialization Errors

**Error: "An object could not be cloned"**
This error occurs when trying to send non-serializable [7]

```javascript
// ❌ This will fail
const data = {
  callback: () => console.log('test'), // Functions not allowed
  element: document.getElementById('myDiv'), // DOM objects not allowed
  window: browserWindow // Electron objects not allowed
};

ipcRenderer.send('channel', data);
// Error: An object could not be cloned
```


**Error: "Failed to serialize arguments"**
Indicates the data structure contains non-serializable elements:[4]

```javascript
// ❌ Array containing non-serializable objects
const posts = [
  { id: 1, callback: someFunction }, // Function not allowed
  { id: 2, element: domNode } // DOM object not allowed
];

ipcRenderer.send('posts', posts);
// Error: Failed to serialize arguments
```


#### Workarounds for Unsupported Types

**1. Functions - Use Channels Instead**
Instead of passing functions, define callback channels:[7]

```javascript
// ❌ Bad - trying to pass function
ipcRenderer.send('process', { callback: myFunction });

// ✅ Good - use channel for callback
ipcRenderer.send('process', { callbackChannel: 'my-callback' });
ipcRenderer.on('my-callback', (event, result) => {
  myFunction(result);
});
```

**2. Complex Objects - Serialize Manually**
Use `JSON.stringify()` for objects that fail automatic serialization:[4]

```javascript
// If automatic serialization fails
const complexData = [/* complex array of objects */];

// Manually serialize
ipcRenderer.send('data', JSON.stringify(complexData));

// Main process - deserialize
ipcMain.on('data', (event, jsonString) => {
  const data = JSON.parse(jsonString);
});
```


**3. Class Instances - Send Plain Objects**
Convert class instances to plain objects before sending:

```javascript
class User {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }
  
  greet() { return `Hello, ${this.name}`; }
}

const user = new User('John', 30);

// ❌ Bad - sends class instance (methods lost)
ipcRenderer.send('user', user);

// ✅ Good - send plain object
ipcRenderer.send('user', {
  name: user.name,
  age: user.age
});
```

**4. Buffers for Binary Data**
Use Node.js Buffers for binary data transfer:[4]

```javascript
// Reading file as buffer
const fileBuffer = fs.readFileSync('/path/to/file');

// Send buffer via IPC (supported)
ipcRenderer.send('file-data', fileBuffer);
```


#### Arrays of Objects

Arrays of serializable objects **are supported**:[4]

```javascript
// ✅ This works fine
const posts = [
  { id: 1, title: 'Post 1', score: 100 },
  { id: 2, title: 'Post 2', score: 200 }
];

ipcRenderer.send('posts', posts);
```


If you get serialization errors with arrays, check that:
- All objects in the array contain only serializable types
- No functions, DOM objects, or Electron objects are present
- No circular references exist

#### Important Limitations

**1. Prototype Chains Not Preserved**
Objects lose their prototype chain when serialized:[5][3]

```javascript
class MyClass {
  method() { return 'test'; }
}

const instance = new MyClass();

// After sending via IPC, the object becomes a plain object
// instance.method() will not exist on the receiving side
```

**2. No Reference Passing**
IPC creates deep copies, not references:[6]

```javascript
// Changes to original won't affect sent data
const obj = { count: 0 };
ipcRenderer.send('data', obj);
obj.count = 100; // Doesn't affect the copy sent via IPC
```

**3. Main Process Limitations**
The main process doesn't have DOM support, so DOM-specific objects cannot be decoded even if they could be serialized.[3]

#### Best Practices

**1. Send Plain Data Structures**
```javascript
// ✅ Good - plain data
const data = {
  id: 123,
  values: [1, 2, 3],
  meta { type: 'user' }
};
```

**2. Validate Before Sending**
```javascript
function isSerialized(obj) {
  try {
    structuredClone(obj); // Test if object can be cloned
    return true;
  } catch {
    return false;
  }
}

if (isSerialized(data)) {
  ipcRenderer.send('channel', data);
} else {
  console.error('Data not serializable');
}
```

**3. Handle Serialization Errors**
```javascript
try {
  ipcRenderer.send('channel', data);
} catch (error) {
  console.error('Serialization failed:', error.message);
  // Fallback: send JSON string
  ipcRenderer.send('channel', JSON.stringify(data));
}
```

Understanding serialization constraints is crucial for reliable IPC communication in Electron applications. Always ensure your data structures contain only supported types to avoid runtime errors.[2][1][3]

Sources
[1] Inter-Process Communication https://electronjs.org/docs/latest/tutorial/ipc
[2] Inter-Process Communication - Electron https://www.electronjs.org/docs/latest/tutorial/ipc
[3] ipcRenderer https://electronjs.org/docs/latest/api/ipc-renderer
[4] Can Electron IPC Handle Arrays of Objects? Encountering ... https://www.reddit.com/r/electronjs/comments/1ag3dub/can_electron_ipc_handle_arrays_of_objects/
[5] Electron interprocess communication https://www.nickolinger.com/blog/electron-interprocess-communication/
[6] Architecture / IPC Question (Newb) https://www.reddit.com/r/electronjs/comments/17rdpwi/architecture_ipc_question_newb/
[7] Electron reply error: An object could not be cloned https://stackoverflow.com/questions/70839472/electron-reply-error-an-object-could-not-be-cloned
[8] Limitations of executeJavaScript Should Be Documented #9288 https://github.com/electron/electron/issues/9288
[9] sindresorhus/electron-better-ipc - GitHub https://github.com/sindresorhus/electron-better-ipc
[10] Electron IPC and nodeIntegration - javascript - Stack Overflow https://stackoverflow.com/questions/52236641/electron-ipc-and-nodeintegration


---

# Native APIs

### Dialog Module

The Electron.js dialog module provides access to native system dialogs for file operations, alerts, and other interactions. It runs in the Main process and enables cross-platform file selection, saving, message boxes, and error dialogs.[1]

#### File Opening Dialogs

The module offers both synchronous and asynchronous methods for opening files.[1]

**Asynchronous (Recommended)**
```javascript
const { dialog } = require('electron')

dialog.showOpenDialog(mainWindow, {
  properties: ['openFile', 'multiSelections']
}).then(result => {
  console.log(result.canceled)
  console.log(result.filePaths)
}).catch(err => {
  console.log(err)
})
```

This returns a Promise resolving to an object with `canceled` (boolean) and `filePaths` (string array) properties.[1]

**Synchronous**
```javascript
const filePaths = dialog.showOpenDialogSync({
  properties: ['openFile', 'multiSelections']
})
```

Returns `string[] | undefined` - the selected file paths, or `undefined` if cancelled [1].

#### Save Dialogs

Save dialogs follow the same pattern with async/sync variants.[1]

**Asynchronous**
```javascript
dialog.showSaveDialog(mainWindow, options).then(result => {
  console.log(result.filePath)
})
```

Returns a Promise with `canceled` (boolean) and `filePath` (string) properties. On macOS, the asynchronous version is recommended to avoid issues when expanding/collapsing the dialog.[1]

**Synchronous**
```javascript
const filePath = dialog.showSaveDialogSync(options)
```

Returns a string containing the chosen path, or empty string if cancelled.[1]

#### File Filters

Both open and save dialogs support file type filtering through the `filters` option:[1]

```javascript
{
  filters: [
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] },
    { name: 'Movies', extensions: ['mkv', 'avi', 'mp4'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}
```

Extensions should be specified without wildcards or dots - `'png'` is correct, but `'.png'` and `'*.png'` are invalid.[1]

#### Dialog Properties

The `properties` array controls dialog behavior:[1]

- `openFile` - Allow files to be selected
- `openDirectory` - Allow directories to be selected
- `multiSelections` - Allow multiple paths to be selected
- `showHiddenFiles` - Show hidden files in dialog
- `createDirectory` (macOS) - Allow creating new directories
- `promptToCreate` (Windows) - Prompt for creation if entered path doesn't exist

On Windows and Linux, dialogs cannot be both file and directory selectors simultaneously - setting `['openFile', 'openDirectory']` will show a directory selector.[1]

#### Modal Windows

The optional `window` parameter attaches the dialog to a parent window, making it modal:[1]

```javascript
dialog.showOpenDialog(mainWindow, options)
```

On macOS, dialogs are presented as sheets attached to the window if a `BaseWindow` reference is provided, or as modals if no window is specified.[1]

Sources
[1] dialog https://www.electronjs.org/docs/latest/api/dialog
[2] dialog | Electron https://www.electronjs.org/de/docs/latest/api/dialog
[3] dialog · Electron documentation https://tinydew4.gitbooks.io/electron/content/api/dialog.html
[4] dialog | Electron 中文网 https://electron.nodejs.cn/docs/latest/api/dialog/
[5] electron/docs/api/dialog.md at main · electron/electron https://github.com/electron/electron/blob/main/docs/api/dialog.md
[6] eightnineight/electron-dialog https://www.npmjs.com/package/@eightnineight/electron-dialog?activeTab=readme
[7] How to show an open file native dialog with Electron? https://stackoverflow.com/questions/45849190/how-to-show-an-open-file-native-dialog-with-electron
[8] dialog · GitBook http://electron.ebookchain.org/en/api/dialog.html
[9] showOpenDialog / showSaveDialog opens _behind_ the ... https://github.com/electron/electron/issues/32857
[10] Dialog · ElectronNET/Electron.NET Wiki https://github.com/ElectronNET/Electron.NET/wiki/Dialog


---

### Menu Creation and Customization

Electron's Menu class provides a cross-platform API for creating native application menus, context menus, tray menus, and dock menus. The Menu class operates in the Main process and consists of multiple MenuItem instances that can be nested.[1][2]

#### Building Menus

Electron offers two approaches to construct menus.[1]

**Template Helper (Recommended)**
```javascript
const { Menu } = require('electron')

const menu = Menu.buildFromTemplate([{
  label: 'Menu',
  submenu: [
    { label: 'Hello' },
    { type: 'separator' },
    { label: 'Electron', type: 'checkbox', checked: true }
  ]
}])

Menu.setApplicationMenu(menu)
```

**Manual Construction**
```javascript
const submenu = new Menu()
submenu.append(new MenuItem({ label: 'Hello' }))
submenu.append(new MenuItem({ type: 'separator' }))
submenu.append(new MenuItem({ label: 'Electron', type: 'checkbox', checked: true }))

const menu = new Menu()
menu.append(new MenuItem({ label: 'Menu', submenu }))
Menu.setApplicationMenu(menu)
```

The template helper reduces boilerplate by passing MenuItem constructor options in a single array rather than appending each item individually.[1]

#### Menu Item Types

Menu items can have different types that grant specific appearance and functionality.[1]

- `normal` - Default type for standard menu items
- `checkbox` - Toggles the `checked` property when clicked
- `radio` - Toggles `checked` and turns off adjacent radio items at the same submenu level
- `separator` - Visual divider between menu sections (does not require a label)
- `submenu` - Automatically assigned when the `submenu` property is present
- `palette` - Creates horizontal item alignment (macOS 14+)
- `header` - Section header for grouping items (macOS 14+)

Adjacent radio items are determined by being at the same submenu level without a separator between them.[1]

#### Roles

Roles provide predefined behaviors for common menu actions, offering the best native experience across platforms.[1]

**Common Roles**
- Edit: `undo`, `redo`, `cut`, `copy`, `paste`, `pasteAndMatchStyle`, `selectAll`, `delete`
- Window: `minimize`, `close`, `quit`, `reload`, `forceReload`, `toggleDevTools`, `togglefullscreen`, `resetZoom`, `zoomIn`, `zoomOut`
- Default menus: `fileMenu`, `editMenu`, `viewMenu`, `windowMenu`

Role strings are case-insensitive (`toggleDevTools`, `toggledevtools`, and `TOGGLEDEVTOOLS` are equivalent). When using a role, the `label` and `accelerator` properties are optional and will default to platform-appropriate values.[1]

#### Accelerators

Keyboard shortcuts can be assigned using the `accelerator` property:[1]

```javascript
{
  label: 'Reload',
  accelerator: 'CmdOrCtrl+R',
  click: (item, focusedWindow) => {
    if (focusedWindow) focusedWindow.reload()
  }
}
```

Platform-specific accelerators use `CmdOrCtrl` for cross-platform compatibility (Command on macOS, Control on Windows/Linux).[3]

#### Advanced Customization

**Programmatic Positioning**

Control item placement using `id`, `before`, `after`, `beforeGroupContaining`, and `afterGroupContaining` attributes:[1]

```javascript
[
  { id: '1', label: 'one', after: ['3'] },
  { id: '2', label: 'two', before: ['1'] },
  { id: '3', label: 'three' }
]
// Results in: three, two, one
```

**Icons**

Assign images to menu items using the `icon` property with NativeImage instances:[1]

```javascript
const { nativeImage, MenuItem } = require('electron')
const icon = nativeImage.createFromPath('path/to/image.png')

const item = new MenuItem({
  label: 'Custom Icon',
  icon: icon
})
```

**Sublabels (macOS 14.4+)**

Add descriptive subtitles below menu item labels:[1]

```javascript
{
  label: 'Log Message',
  sublabel: 'This will use the console.log utility',
  click: () => { console.log('Logging via menu...') }
}
```

**Tooltips (macOS)**

Display hover information using the `toolTip` property:[1]

```javascript
{
  label: 'Hover Over Me',
  toolTip: 'This is additional info that appears on hover'
}
```

#### Setting Menus

**Application Menu**

Set the top-level application menu using `Menu.setApplicationMenu()`:[2]

```javascript
app.on('ready', () => {
  const menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu(menu)
})
```

On Windows and Linux, use `&` in top-level item names to create Alt-key accelerators (e.g., `&File` creates Alt-F). Passing `null` removes the menu entirely.[2]

**Context Menus**

Display context menus using the `popup()` method:[2]

```javascript
menu.popup({ window: mainWindow })
```

Context menus are typically triggered on right-click events and appear at the cursor position.[3]

Sources
[1] dialog · Electron documentation https://tinydew4.gitbooks.io/electron/content/api/dialog.html
[2] dialog | Electron 中文网 https://electron.nodejs.cn/docs/latest/api/dialog/
[3] Menu · Electron documentation https://tinydew4.gitbooks.io/electron/content/api/menu.html
[4] Menu | Electron https://electronjs.org/docs/latest/api/menu
[5] Menus | Electron https://electronjs.org/docs/latest/tutorial/menus
[6] Application Menu | Electron https://electronjs.org/ru/docs/latest/tutorial/application-menu
[7] Electron Application Menu Working Example - Stack Overflow https://stackoverflow.com/questions/41258906/electron-application-menu-working-example
[8] The Complete Electron JS Menu Tutorial (Top Menus, Context ... https://www.youtube.com/watch?v=4aIanHYViOM
[9] Menus https://www.electronjs.org/docs/latest/tutorial/menus
[10] How to Create Custom Desktop Menus in Electron : r/electronjs https://www.reddit.com/r/electronjs/comments/1fpalmw/how_to_create_custom_desktop_menus_in_electron/
[11] Create Electron Menu in TypeScript? - Stack Overflow https://stackoverflow.com/questions/45811603/create-electron-menu-in-typescript
[12] Menu - Electron http://electronproject.org/menu.html

---

### Context Menus Implementation

Context menus are right-click pop-up menus that appear when users trigger specific events in Electron applications. Electron doesn't provide default context menus, but they can be created using the `menu.popup()` function and event listeners.[1]

#### Implementation Approaches

Context menus can be implemented through two primary methods in Electron.[1]

##### Using the `context-menu` Event (WebContents)

The Main process can listen to the `context-menu` event on WebContents, which provides detailed context information:[2][1]

**Main Process**
```javascript
const { app, BrowserWindow, Menu } = require('electron')

let mainWindow

app.whenReady().then(() => {
  mainWindow = new BrowserWindow({
    webPreferences: {
      contextIsolation: true
    }
  })

  mainWindow.webContents.on('context-menu', (event, params) => {
    const template = buildMenuTemplate(params)
    const contextMenu = Menu.buildFromTemplate(template)
    contextMenu.popup({ window: mainWindow })
  })
})

function buildMenuTemplate(params) {
  return [
    { label: 'Copy', role: 'copy', enabled: params.editFlags.canCopy },
    { label: 'Paste', role: 'paste', enabled: params.editFlags.canPaste },
    { type: 'separator' },
    { label: 'Inspect', click: () => { 
      mainWindow.webContents.inspectElement(params.x, params.y) 
    }}
  ]
}
```

The `params` object contains rich context information including clicked element type (`mediaType`, `linkURL`, `srcURL`), selection status, and edit flags.[3][2]

##### Using the DOM `contextmenu` Event (Renderer)

The Renderer process can listen to the DOM `contextmenu` event and communicate with Main via IPC:[4][1]

**Renderer Process (Preload/Renderer)**
```javascript
const { ipcRenderer } = require('electron/renderer')

window.addEventListener('contextmenu', (e) => {
  e.preventDefault()
  ipcRenderer.send('show-context-menu')
})

ipcRenderer.on('context-menu-command', (e, command) => {
  // Handle menu command
  console.log(`Command received: ${command}`)
})
```

**Main Process**
```javascript
const { ipcMain, Menu, BrowserWindow } = require('electron')

ipcMain.on('show-context-menu', (event) => {
  const template = [
    {
      label: 'Menu Item 1',
      click: () => { event.sender.send('context-menu-command', 'menu-item-1') }
    },
    { type: 'separator' },
    { label: 'Menu Item 2', type: 'checkbox', checked: true }
  ]
  
  const menu = Menu.buildFromTemplate(template)
  menu.popup({ window: BrowserWindow.fromWebContents(event.sender) })
})
```

This approach requires manual event prevention and IPC setup but provides more control over when context menus appear.[4][1]

#### Dynamic Context Menus

Context menus can be dynamically configured based on the clicked element by passing element-specific data through IPC:[5]

**Renderer Process**
```javascript
window.addEventListener('contextmenu', (e) => {
  e.preventDefault()
  
  const elementData = {
    id: e.target.id,
    tagName: e.target.tagName,
    classList: Array.from(e.target.classList)
  }
  
  ipcRenderer.send('show-context-menu', elementData)
})
```

**Main Process**
```javascript
ipcMain.on('show-context-menu', (event, elementData) => {
  const template = [
    {
      label: `Edit ${elementData.tagName}`,
      enabled: elementData.id === 'p1' // Enable only for specific element
    },
    {
      label: 'Delete',
      visible: elementData.classList.includes('deletable')
    }
  ]
  
  const menu = Menu.buildFromTemplate(template)
  menu.popup({ window: BrowserWindow.fromWebContents(event.sender) })
})
```

Menu items can be conditionally enabled or hidden using the `enabled` and `visible` properties based on element properties.[3][5]

#### Context-Specific Menu Items

The `params` object from the `context-menu` event enables media-specific menus:[3]

```javascript
mainWindow.webContents.on('context-menu', (event, params) => {
  const template = []
  
  if (params.mediaType === 'image') {
    template.push({
      label: 'Save Image',
      click: () => { /* save image logic */ }
    })
  }
  
  if (params.linkURL) {
    template.push({
      label: 'Open Link',
      click: () => { require('electron').shell.openExternal(params.linkURL) }
    })
  }
  
  if (params.selectionText) {
    template.push({
      label: `Search for "${params.selectionText}"`,
      click: () => { /* search logic */ }
    })
  }
  
  const menu = Menu.buildFromTemplate(template)
  menu.popup()
})
```

This allows menus to adapt based on images, links, selected text, or video elements.[2][3]

#### Third-Party Libraries

The `electron-context-menu` package simplifies context menu implementation with pre-built actions:[6][7]

```javascript
const { app } = require('electron')
const contextMenu = require('electron-context-menu')

contextMenu({
  prepend: (actions, params, browserWindow) => [
    {
      label: 'Custom Action',
      visible: params.mediaType === 'image'
    },
    actions.separator(),
    actions.copyLink({
      transform: content => `modified_link_${content}`
    })
  ],
  showInspectElement: true
})
```

This library provides built-in actions like `copy`, `paste`, `copyLink`, `saveImage`, and `inspect` with customizable transforms.[7][6][3]

Sources
[1] Context Menu https://electronjs.org/docs/latest/tutorial/context-menu
[2] How to Display Context Menus in Electron Applications https://developer.mamezou-tech.com/en/blogs/2025/01/07/build-context-menu-in-electron-app/
[3] How to implement a native context menu (with inspect element) in ... https://ourcodeworld.com/articles/read/874/how-to-implement-a-native-context-menu-with-inspect-element-in-electron-framework
[4] Menu | Electron https://electrondelta.com/menu.html
[5] Electron: Dynamic context menu - javascript - Stack Overflow https://stackoverflow.com/questions/62745948/electron-dynamic-context-menu
[6] sindresorhus/electron-context-menu https://github.com/sindresorhus/electron-context-menu
[7] electron-context-menu https://www.npmjs.com/package/electron-context-menu
[8] The Complete Electron JS Menu Tutorial (Top Menus, Context Menus & Accelerators) https://www.youtube.com/watch?v=4aIanHYViOM
[9] Top 10 Examples of electron-context-menu code in ... https://www.clouddefense.ai/code/javascript/example/electron-context-menu
[10] An Example of how to show context-menu in Electron - GitHub Gist https://gist.github.com/0ecaf45852ad7e3cd7c4bae077798c48

---

### Application Menus and Menu Bars

Application menus are the top-level menus in Electron apps that display differently based on platform. On macOS, the menu appears in the system menu bar, while on Windows and Linux, it appears at the top of each BaseWindow.[1]

#### Creating Application Menus

Application menus are set using `Menu.setApplicationMenu()` and must be called after the `ready` event.[2][1]

**Basic Setup**
```javascript
const { app, Menu } = require('electron/main')

app.on('ready', () => {
  const template = [
    {
      label: 'File',
      submenu: [
        { role: 'quit' }
      ]
    }
  ]
  
  const menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu(menu)
})
```

Each top-level menu item **must be a submenu** in Electron's application menu structure. If `setApplicationMenu()` is never called, Electron provides a default menu automatically.[3][4][1]

#### Cross-Platform Menu Templates

Application menus require platform-specific handling, especially for macOS.[5][1]

**Full Cross-Platform Template**
```javascript
const { app, Menu, shell } = require('electron/main')
const isMac = process.platform === 'darwin'

const template = [
  // App Menu (macOS only)
  ...(isMac ? [{
    label: app.name,
    submenu: [
      { role: 'about' },
      { type: 'separator' },
      { role: 'services' },
      { type: 'separator' },
      { role: 'hide' },
      { role: 'hideOthers' },
      { role: 'unhide' },
      { type: 'separator' },
      { role: 'quit' }
    ]
  }] : []),
  
  // File Menu
  {
    label: 'File',
    submenu: [
      isMac ? { role: 'close' } : { role: 'quit' }
    ]
  },
  
  // Edit Menu
  {
    label: 'Edit',
    submenu: [
      { role: 'undo' },
      { role: 'redo' },
      { type: 'separator' },
      { role: 'cut' },
      { role: 'copy' },
      { role: 'paste' },
      ...(isMac ? [
        { role: 'pasteAndMatchStyle' },
        { role: 'delete' },
        { role: 'selectAll' },
        { type: 'separator' },
        {
          label: 'Speech',
          submenu: [
            { role: 'startSpeaking' },
            { role: 'stopSpeaking' }
          ]
        }
      ] : [
        { role: 'delete' },
        { type: 'separator' },
        { role: 'selectAll' }
      ])
    ]
  },
  
  // View Menu
  {
    label: 'View',
    submenu: [
      { role: 'reload' },
      { role: 'forceReload' },
      { role: 'toggleDevTools' },
      { type: 'separator' },
      { role: 'resetZoom' },
      { role: 'zoomIn' },
      { role: 'zoomOut' },
      { type: 'separator' },
      { role: 'togglefullscreen' }
    ]
  },
  
  // Window Menu
  {
    label: 'Window',
    submenu: [
      { role: 'minimize' },
      { role: 'zoom' },
      ...(isMac ? [
        { type: 'separator' },
        { role: 'front' },
        { type: 'separator' },
        { role: 'window' }
      ] : [
        { role: 'close' }
      ])
    ]
  },
  
  // Help Menu
  {
    role: 'help',
    submenu: [
      {
        label: 'Learn More',
        click: async () => {
          await shell.openExternal('https://electronjs.org')
        }
      }
    ]
  }
]

const menu = Menu.buildFromTemplate(template)
Menu.setApplicationMenu(menu)
```

The conditional spread operator (`...`) enables platform-specific menu items without code duplication.[1]

#### Standard Menu Roles

Electron provides shorthand roles that create entire submenu structures automatically.[1]

**Using Default Submenus**
```javascript
const template = [
  ...(process.platform === 'darwin' ? [{ role: 'appMenu' }] : []),
  { role: 'fileMenu' },
  { role: 'editMenu' },
  { role: 'viewMenu' },
  { role: 'windowMenu' },
  {
    role: 'help',
    submenu: [
      {
        label: 'Learn More',
        click: async () => {
          await shell.openExternal('https://electronjs.org')
        }
      }
    ]
  }
]
```

The default submenu roles (`fileMenu`, `editMenu`, `viewMenu`, `windowMenu`) automatically include platform-appropriate menu items. The `appMenu` role creates the macOS-specific app menu with the application name.[6][1]

#### macOS-Specific Behavior

macOS menus have unique characteristics compared to Windows and Linux.[5][1]

- The first submenu **always** displays the application name as its label, regardless of the specified `label` property[2][1]
- Standard menus like Services and Windows are recognized via roles (`services`, `window`, `help`)[5]
- The `help` role creates a top-level Help submenu with a built-in search bar that searches all menu items[1]
- The `appMenu` role should be used conditionally to populate the app-name menu[1]

#### Window-Specific Menus

On Windows and Linux, individual windows can have their own application menus.[3][1]

**Setting Per-Window Menus**
```javascript
const { BrowserWindow, Menu } = require('electron/main')

const win = new BrowserWindow()

const menu = Menu.buildFromTemplate([
  {
    label: 'my custom menu',
    submenu: [
      { role: 'copy' },
      { role: 'paste' }
    ]
  }
])

win.setMenu(menu)
```

This allows different windows to have different menu configurations. On macOS, `setApplicationMenu()` controls the global menu bar, while Windows and Linux set menus per-window.[7][3][1]

**Removing Window Menus**
```javascript
win.removeMenu()
```

This removes the application menu from a specific window on Windows and Linux.[1]

#### Keyboard Accelerators

On Windows and Linux, the `&` character in top-level menu labels creates Alt-key shortcuts.[8]

```javascript
{
  label: '&File',  // Creates Alt+F shortcut
  submenu: [...]
}
```

The underlined letter after `&` becomes the accelerator key when combined with Alt.[8]

#### Removing the Application Menu

Passing `null` to `setApplicationMenu()` removes the entire application menu:[7]

```javascript
Menu.setApplicationMenu(null)
```

This completely hides the menu bar, giving applications a cleaner, borderless appearance.[7]

Sources
[1] eightnineight/electron-dialog https://www.npmjs.com/package/@eightnineight/electron-dialog?activeTab=readme
[2] Electron Application Menu Working Example https://stackoverflow.com/questions/41258906/electron-application-menu-working-example
[3] Application Menu - Electron https://www.electronjs.org/docs/latest/tutorial/application-menu
[4] electron-default-menu - NPM https://www.npmjs.com/package/electron-default-menu
[5] Menu | Electron https://electrondelta.com/menu.html
[6] Menus | Electron https://electronjs.org/docs/latest/tutorial/menus
[7] Menu - Electron http://electronproject.org/menu.html
[8] How to add custom menu in menubar in mac with electron? https://stackoverflow.com/questions/37784164/how-to-add-custom-menu-in-menubar-in-mac-with-electron
[9] Application Menu https://www.electronjs.org/de/docs/latest/tutorial/application-menu
[10] How to Create Custom Desktop Menus in Electron | DoltHub Blog https://www.dolthub.com/blog/2024-09-25-how-to-create-custom-menus-in-electron/
[11] Building Cross-Platform Desktop Apps with Electron.NET - mescius https://developer.mescius.com/blogs/building-cross-platform-desktop-apps-with-electron-dot-net


---

### System Tray Integration

The Tray class adds icons and context menus to the system's notification area, running in the Main process. On macOS, the icon appears in the top-right menu bar extras area, on Windows in the taskbar notification area, and on Linux in locations that vary by desktop environment.[1][2]

#### Creating a Tray Icon

Tray icons are created using the Tray class constructor with either a NativeImage instance or a file path.[2][1]

**Basic Setup**
```javascript
const { app, Tray, Menu, nativeImage } = require('electron')

let tray = null

app.whenReady().then(() => {
  tray = new Tray('/path/to/icon.png')
  
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Item1', type: 'radio' },
    { label: 'Item2', type: 'radio' },
    { label: 'Item3', type: 'radio', checked: true }
  ])
  
  tray.setToolTip('My Application')
  tray.setContextMenu(contextMenu)
})
```

The tray reference must be saved globally to prevent garbage collection. The Tray can only be instantiated after the `ready` event fires.[3][1][2]

#### Platform-Specific Icon Guidelines

Icon requirements differ across operating systems.[1]

**macOS**
- Use Template Images (filenames ending in "Template") for automatic color inversion[1]
- Recommended sizes: 16x16 (72dpi) and 32x32@2x (144dpi)[1]
- Retina displays require @2x images at 144dpi to avoid graininess[1]
- When bundling, ensure filenames aren't mangled or hashed by build tools[1]

**Windows**
- ICO format recommended for best visual effects[1]
- Supports optional GUID parameter for persistent tray positioning[1]

**Linux**
- Uses StatusNotifierItem by default, falls back to GtkStatusIcon when unavailable[1]
- Click event behavior varies by desktop environment (single vs double click)[1]

#### Attaching Context Menus

Tray context menus are set using `setContextMenu()` and automatically handle click events without requiring manual `popup()` calls.[2]

```javascript
const contextMenu = Menu.buildFromTemplate([
  {
    label: 'Show App',
    click: () => {
      mainWindow.show()
    }
  },
  { type: 'separator' },
  { role: 'quit' }
])

tray.setContextMenu(contextMenu)
```

On Linux, `setContextMenu()` must be called again after modifying individual MenuItem properties for changes to take effect:[1]

```javascript
contextMenu.items[1].checked = false
tray.setContextMenu(contextMenu) // Required on Linux
```

The `enabled` and `visible` properties are not available for top-level menu items in macOS tray menus.[2]

#### Dynamic Icon and Title Updates

The Tray API provides methods to update appearance dynamically.[2][1]

```javascript
const red = nativeImage.createFromDataURL('image/...')
const green = nativeImage.createFromDataURL('image/...')

const contextMenu = Menu.buildFromTemplate([
  {
    label: 'Set Green Icon',
    type: 'checkbox',
    click: ({ checked }) => {
      checked ? tray.setImage(green) : tray.setImage(red)
    }
  },
  {
    label: 'Set Title',
    type: 'checkbox',
    click: ({ checked }) => {
      checked ? tray.setTitle('Title') : tray.setTitle('')
    }
  }
])
```

The `setTitle()` method displays text next to the tray icon on macOS and supports ANSI colors. On macOS, use `setPressedImage()` to specify an image displayed when the icon is clicked.[1]

#### Minimizing to Tray

To keep the app running when all windows close, prevent the default quit behavior:[3][2]

```javascript
app.on('window-all-closed', () => {
  // Prevent app from quitting - keeps tray icon alive
})
```

The tray icon can restore windows through menu items:

```javascript
{
  label: 'Open App',
  click: () => {
    const wins = BrowserWindow.getAllWindows()
    if (wins.length === 0) {
      createWindow()
    } else {
      wins[0].focus()
    }
  }
}
```

This pattern allows apps to run in the background with tray access.[3][2]

#### Tray Events

The Tray class emits various interaction events.[1]

**Common Events**
- `click` - Tray icon clicked (behavior varies on Linux)
- `right-click` (macOS, Windows) - Right mouse button clicked
- `double-click` (macOS, Windows) - Icon double-clicked
- `mouse-enter` (macOS, Windows) - Mouse enters icon area
- `mouse-leave` (macOS, Windows) - Mouse exits icon area

**macOS-Specific Events**
- `drop-files` - Files dragged onto tray icon
- `drop-text` - Text dragged onto tray icon
- `drag-enter` / `drag-leave` - Drag operation events

**Windows-Specific Events**
- `balloon-show` / `balloon-click` / `balloon-closed` - Balloon notification events
- `middle-click` - Middle mouse button clicked

```javascript
tray.on('click', (event, bounds) => {
  console.log('Tray clicked at', bounds)
})
```

The `mouse-up` and `mouse-down` events on macOS won't fire if a context menu is set.[1]

In this context, `bounds` is a **geometry object** that describes **where the tray icon is located on the screen at the moment of the click**.

Brief background.  
Electron’s `Tray` integrates with the operating system’s system tray (menu bar on macOS, notification area on Windows/Linux). When the tray icon is clicked, Electron passes positional information so you can align UI elements—most commonly a popup window or menu—relative to the tray icon.

What `bounds` contains.  
`bounds` is an object with the following shape:

```js
{
  x: number,
  y: number,
  width: number,
  height: number
}
```

Meaning of each field.  
• `x`, `y`: The screen coordinates (in **device-independent pixels**) of the tray icon’s top-left corner.  
• `width`, `height`: The size of the tray icon’s clickable area.

Conceptual analogy.  
Think of `bounds` as the **bounding box drawn around the tray icon** on your monitor. It tells you where that box sits and how big it is, so you can place something next to it accurately.

Why Electron provides this.  
The tray location is:  
• Different across platforms.  
• Different depending on taskbar position (bottom, top, left, right).  
• Dynamic (can move between displays or change with DPI).

By giving you `bounds`, Electron saves you from guessing or hardcoding positions.

Typical use case.

```js
tray.on('click', (event, bounds) => {
  popupWindow.setPosition(
    Math.round(bounds.x),
    Math.round(bounds.y + bounds.height),
    false
  )
  popupWindow.show()
})
```

Here, the popup is positioned just below the tray icon.

Platform-specific notes.  
• macOS: `bounds` corresponds to the menu bar icon’s rect. This is the most reliable platform for tray positioning.  
• Windows: `bounds` maps to the notification area icon, but values can vary depending on taskbar settings and DPI scaling.  
• Linux: Support depends on the desktop environment; some provide less precise bounds.

Important cautions.

1. `bounds` should be treated as **advisory**, not absolute truth.
2. Always account for multi-monitor setups.
3. Avoid assuming the tray is always at the bottom or top of the screen.

In summary.  
`bounds` tells you **where the tray icon is and how big it is** at click time. It exists primarily to help you anchor windows or menus relative to the tray icon in a platform-safe way.

#### Advanced Methods

**Manual Context Menu Display**
```javascript
tray.popUpContextMenu(menu, { x: 100, y: 100 })
```

This displays a custom menu at specified coordinates (Windows only for position parameter).[1]

**Windows Balloon Notifications**
```javascript
tray.displayBalloon({
  icon: nativeImage.createFromPath('/path/to/icon.png'),
  title: 'Notification Title',
  content: 'Notification message content'
})
```

Balloon notifications are Windows-specific with events for show, click, and close.[4][1]

**GUID for Persistent Positioning**

On Windows and macOS, pass a GUID string to the constructor to maintain tray icon position between app relaunches:[1]

```javascript
const tray = new Tray('/path/to/icon', 'your-unique-guid-here')
```

The GUID must adhere to UUID format and becomes permanently associated with code-signed executables.[1]

Sources
[1] How to show an open file native dialog with Electron? https://stackoverflow.com/questions/45849190/how-to-show-an-open-file-native-dialog-with-electron
[2] dialog · GitBook http://electron.ebookchain.org/en/api/dialog.html
[3] how to show the app electronjs in the systemTray - DEV Community https://dev.to/fwldom/how-to-show-the-app-electronjs-in-the-systemtray-4250
[4] Tray · Electron documentation https://tinydew4.gitbooks.io/electron/content/api/tray.html
[5] Tray | Electron https://electronjs.org/docs/latest/api/tray
[6] Tray Menu - Electron https://electronjs.org/docs/latest/tutorial/tray
[7] Build an Electron Application with System Tray access - YouTube https://www.youtube.com/watch?v=g6RAttYljPE
[8] Tray · ElectronNET/Electron.NET Wiki - GitHub https://github.com/ElectronNET/Electron.NET/wiki/Tray
[9] Notifications (Windows, Linux, macOS) - Electron http://docs3.w3cub.com/electron/tutorial/notifications/
[10] Tray Menu https://www.electronjs.org/docs/latest/tutorial/tray
[11] Electron: Creating Tray Menu - DEV Community https://dev.to/franamorim/tutorial-alarm-widget-with-electron-react-2-34dd
[12] Desktop Environment Integration · Electron docs gitbook - imfly https://imfly.gitbooks.io/electron-docs-gitbook/content/en/tutorial/desktop-environment-integration.html

---

### Notifications API

Electron provides cross-platform notification APIs that differ based on process type. Main process notifications use the `Notification` module, while renderer process notifications use the standard HTML5 Notification API.[1]

#### Main Process Notifications

The Electron Notification class creates native OS desktop notifications with custom options.[2]

**Basic Implementation**
```javascript
const { Notification } = require('electron')

const notification = new Notification({
  title: 'Basic Notification',
  body: 'Notification from the Main process'
})

notification.show()
```

Unlike the HTML5 API, Electron's Notification objects **must call `show()`** explicitly to display. Simply instantiating them does not trigger display.[1][2]

**Checking Support**
```javascript
if (Notification.isSupported()) {
  // Notifications are supported on this system
  new Notification({ title: 'Hello', body: 'World' }).show()
}
```

The static `isSupported()` method verifies whether desktop notifications are available on the current system.[3][2]

#### Renderer Process Notifications

The renderer process uses the standard HTML5 Notification API available in web browsers.[4][1]

```javascript
const NOTIFICATION_TITLE = 'Title'
const NOTIFICATION_BODY = 'Notification from the Renderer process'

const notification = new Notification(NOTIFICATION_TITLE, { 
  body: NOTIFICATION_BODY,
  icon: '/path/to/icon.png'
})

notification.onclick = () => {
  console.log('Notification clicked')
}
```

HTML5 notifications display immediately upon instantiation without requiring an explicit `show()` call. The API is only available in the renderer process.[5][6][4]

#### Notification Options

Both APIs support various configuration options.[2]

**Common Options**
- `title` - Notification heading
- `subtitle` (macOS) - Secondary heading below title
- `body` - Main notification message text
- `icon` - Image displayed with notification
- `silent` - Boolean to suppress notification sound
- `sound` (macOS) - Name of sound file to play
- `timeoutType` (Linux, Windows) - Can be `'default'` or `'never'` for persistent notifications
- `urgency` (Linux) - Can be `'normal'`, `'critical'`, or `'low'`
- `actions` - Array of NotificationAction objects
- `closeButtonText` - Custom text for close button

```javascript
const notification = new Notification({
  title: 'Advanced Notification',
  subtitle: 'With extra features',
  body: 'This notification has custom settings',
  icon: nativeImage.createFromPath('/path/to/icon.png'),
  silent: false,
  sound: 'Ping',
  timeoutType: 'never',
  actions: [
    { type: 'button', text: 'Action 1' },
    { type: 'button', text: 'Action 2' }
  ]
})
```

#### Notification Events

The Main process Notification class emits several events for handling user interactions.[2]

**Available Events**
- `show` - Fired when notification appears (can fire multiple times if `show()` called repeatedly)
- `click` - User clicked the notification
- `close` - Notification dismissed manually or via timeout
- `reply` (macOS) - User submitted inline reply text
- `action` (macOS) - Action button clicked, provides action index
- `failed` (Windows) - Error occurred during `show()` execution

```javascript
notification.on('show', () => {
  console.log('Notification displayed')
})

notification.on('click', () => {
  console.log('User clicked notification')
  mainWindow.show()
})

notification.on('close', () => {
  console.log('Notification dismissed')
})

notification.on('reply', (event, reply) => {
  console.log('User replied:', reply)
})

notification.on('action', (event, index) => {
  console.log('Action clicked:', index)
})
```

The `close` event is not guaranteed to fire in all dismissal scenarios. On Windows, notifications remaining in the Action Center after the initial close event will not emit `close` again when removed via `notification.close()`.[2]

#### macOS-Specific Features

macOS supports additional notification capabilities.[1][2]

**Inline Replies**
```javascript
const notification = new Notification({
  title: 'Message Received',
  body: 'You have a new message',
  hasReply: true,
  replyPlaceholder: 'Type your response...'
})

notification.on('reply', (event, reply) => {
  console.log('User replied:', reply)
})

notification.show()
```

The `hasReply` option adds an inline text field for quick responses.[2]

**Custom Sounds**

Specify sound names from System Preferences > Sound or custom sound files located in specific directories:[2]

```javascript
const notification = new Notification({
  title: 'Custom Sound',
  body: 'Playing custom notification sound',
  sound: 'Ping' // or 'custom-sound.aiff'
})
```

Sound files must be in `~/Library/Sounds`, `/Library/Sounds`, `/Network/Library/Sounds`, `/System/Library/Sounds`, or the app bundle's Resources folder.[2]

**Size Limitations**

Notifications are limited to 256 bytes on macOS and will be truncated if exceeded.[4][1]

#### Windows-Specific Requirements

Windows requires additional setup for notifications to function properly.[6][1]

**Start Menu Shortcut**

Applications need a Start Menu shortcut with an AppUserModelID and ToastActivatorCLSID. During development, pin `node_modules\electron\dist\electron.exe` to the Start Menu and call:[6][1]

```javascript
app.setAppUserModelId(process.execPath)
```

In production using Squirrel.Windows or electron-winstaller, Electron handles this automatically.[1]

**Advanced Notifications**

For custom templates, images, and interactive elements, use third-party modules like `electron-windows-notifications` or `electron-windows-interactive-notifications`.[1]

**Querying Permission State**

The `windows-notification-state` module detects whether Windows will display notifications or silently discard them.[4][1]

#### Linux Implementation

Linux notifications use `libnotify` and work across desktop environments supporting the Desktop Notifications Specification (GNOME, KDE, Unity, Cinnamon, etc.).[1]

**Urgency Levels**
```javascript
const notification = new Notification({
  title: 'Critical Alert',
  body: 'This is an urgent notification',
  urgency: 'critical' // 'low', 'normal', or 'critical'
})
```

The `urgency` property controls notification priority and persistence.[2]

#### Permission Handling

The HTML5 Notification API includes permission methods, though Electron's implementation has known issues where `Notification.permission` may always return `'granted'`:[7]

```javascript
// Standard HTML5 permission request
Notification.requestPermission().then(permission => {
  if (permission === 'granted') {
    new Notification('Permission granted!')
  }
})
```

For production apps requiring accurate permission state detection, use platform-specific modules like `windows-notification-state` or `macos-notification-state`.[1]

Sources
[1] Dialog · ElectronNET/Electron.NET Wiki https://github.com/ElectronNET/Electron.NET/wiki/Dialog
[2] showOpenDialog / showSaveDialog opens _behind_ the ... https://github.com/electron/electron/issues/32857
[3] Notification | Electron https://electronjs.org/docs/latest/api/notification
[4] Notifications (Windows, Linux, macOS) | Electron - GitHub Pages https://zeke.github.io/electron.atom.io/docs/tutorial/notifications/
[5] Using native desktop notification with Electron Framework https://ourcodeworld.com/articles/read/204/using-native-desktop-notification-with-electron-framework
[6] Using Notification API for Electron App - Stack Overflow https://stackoverflow.com/questions/31606454/using-notification-api-for-electron-app
[7] Notification.permission always shows "granted" · Issue #11221 https://github.com/electron/electron/issues/11221
[8] Notification · ElectronNET/Electron.NET Wiki - GitHub https://github.com/ElectronNET/Electron.NET/wiki/Notification
[9] Notifications | Electron https://electronjs.org/docs/latest/tutorial/notifications
[10] Electron - Notifications - Tutorials Point https://www.tutorialspoint.com/electron/electron_notifications.htm
[11] How to do desktop notifications? · Issue #2421 · electron ... - GitHub https://github.com/electron/electron/issues/2421
[12] HTML5 notifications in electron apps with Angular https://thorsten-hans.com/html5-notifications-in-electron-apps-with-angular/


---

## Clipboard Operations

The clipboard module provides methods for performing copy and paste operations on the system clipboard. It runs in both Main and Renderer processes (non-sandboxed only).[1][2]

### Text Operations

The clipboard supports reading and writing plain text content.[1]

**Writing Text**
```javascript
const { clipboard } = require('electron')

clipboard.writeText('hello i am a bit of text!')
```

**Reading Text**
```javascript
const text = clipboard.readText()
console.log(text)
// hello i am a bit of text!
```

Both methods accept an optional `type` parameter that can be `'clipboard'` (default) or `'selection'` (Linux only). The selection clipboard is specific to X Window systems and represents text selected with the mouse.[3][1]

### HTML Markup Operations

HTML content can be written and read from the clipboard.[2][1]

**Writing HTML**
```javascript
const { clipboard } = require('electron')

clipboard.writeHTML('<b>Hi</b>')
```

**Reading HTML**
```javascript
const html = clipboard.readHTML()
console.log(html)
// <meta charset='utf-8'><b>Hi</b>
```

The `readHTML()` method returns markup when available, though behavior may vary by platform. On some systems, plain text written via `writeHTML()` may be returned as plain text rather than markup.[4][2]

### Image Operations

The clipboard can handle images using NativeImage objects.[2][1]

**Writing Images**
```javascript
const { clipboard, nativeImage } = require('electron')

const image = nativeImage.createFromPath('/path/to/image.png')
clipboard.writeImage(image)
```

**Reading Images**
```javascript
const image = clipboard.readImage()
console.log(image.isEmpty()) // false if image exists
```

The `readImage()` method returns a `NativeImage` object representing clipboard image content.[1][2]

### Rich Text Format (RTF)

RTF content can be read and written for rich text editing applications.[1]

**Writing RTF**
```javascript
clipboard.writeRTF('{\\rtf1\\ansi{\\fonttbl\\f0\\fswiss Helvetica;}\\f0\\pard\nThis is some {\\b bold} text.\\par\n}')
```

**Reading RTF**
```javascript
const rtf = clipboard.readRTF()
console.log(rtf)
```

RTF operations preserve text formatting across clipboard transfers.[1]

### Bookmarks (macOS)

Bookmarks store URLs with associated titles for drag-and-drop operations.[2][1]

**Writing Bookmarks**
```javascript
clipboard.writeBookmark('Electron Homepage', 'https://electronjs.org')
```

**Reading Bookmarks**
```javascript
const bookmark = clipboard.readBookmark()
console.log(bookmark.title) // 'Electron Homepage'
console.log(bookmark.url)   // 'https://electronjs.org'
```

This feature is macOS-specific and returns an object with `title` and `url` properties.[1]

### Find Pasteboard (macOS)

macOS provides a separate find pasteboard for search-related operations.[2]

**Writing to Find Pasteboard**
```javascript
clipboard.writeFindText('search term')
```

**Reading from Find Pasteboard**
```javascript
const findText = clipboard.readFindText()
console.log(findText) // 'search term'
```

The find pasteboard holds information about the current state of the active application's find panel.[2]

### Buffer Operations

Custom data formats can be written using buffers.[1]

**Writing Buffers**
```javascript
const buffer = Buffer.from('this is binary', 'utf8')
clipboard.writeBuffer('public/utf8-plain-text', buffer)
```

**Reading Buffers**
```javascript
const ret = clipboard.readBuffer('public/utf8-plain-text')
console.log(ret.toString('utf8')) // 'this is binary'
```

The `format` parameter specifies a custom MIME type or format identifier.[1]

### Composite Write Operations

The `write()` method enables writing multiple formats simultaneously.[4][1]

```javascript
const { clipboard, nativeImage } = require('electron')

clipboard.write({
  text: 'Plain text version',
  html: '<b>HTML version</b>',
  image: nativeImage.createFromPath('/path/to/image.png'),
  rtf: '{\\rtf1\\ansi RTF version}',
  bookmark: 'https://electronjs.org'
})
```

This atomically writes all provided formats to the clipboard. Applications can then read the format most appropriate for their needs.[4][2][1]

### Clearing the Clipboard

Remove all clipboard content using the `clear()` method.[1]

```javascript
clipboard.clear()
```

An optional `type` parameter can specify `'selection'` or `'clipboard'` (default).[1]

### Checking Available Formats

Determine which formats are currently available in the clipboard.[1]

```javascript
const formats = clipboard.availableFormats()
console.log(formats)
// ['text/plain', 'text/html', 'image/png']
```

The `availableFormats()` method returns an array of MIME type strings. The optional `type` parameter can be `'selection'` or `'clipboard'`.[1]

**Checking Specific Format**
```javascript
const hasText = clipboard.has('text/plain')
console.log(hasText) // true or false
```

The `has()` method checks if a specific format exists.[1]

### Linux Selection Clipboard

Linux systems support a separate selection clipboard for mouse-highlighted text.[3][1]

```javascript
const { clipboard } = require('electron')

clipboard.writeText('Example String', 'selection')
console.log(clipboard.readText('selection'))
// Example String
```

All clipboard methods accept `'selection'` as the second parameter on Linux to interact with the selection clipboard instead of the standard clipboard.[3][1]

### Context Isolation Considerations

When using context isolation in the renderer process, clipboard access requires exposure through the `contextBridge` API.[2]

**Preload Script**
```javascript
const { contextBridge, clipboard } = require('electron')

contextBridge.exposeInMainWorld('clipboard', {
  readText: () => clipboard.readText(),
  writeText: (text) => clipboard.writeText(text)
})
```

**Renderer Process**
```javascript
// Now accessible via window.clipboard
window.clipboard.writeText('Hello World')
const text = window.clipboard.readText()
```

This ensures secure clipboard access in sandboxed renderer processes.[2]

Sources
[1] clipboard | Electron https://www.electronjs.org/docs/latest/api/clipboard/
[2] clipboard | Electron https://electronjs.org/docs/latest/api/clipboard
[3] clipboard · GitBook http://electron.ebookchain.org/en/api/clipboard.html
[4] Clipboard API in ElectronJS - GeeksforGeeks https://www.geeksforgeeks.org/javascript/clipboard-api-in-electronjs/
[5] clipboard https://www.electronjs.org/docs/latest/api/clipboard
[6] Accessing Clipboard Files in Electron: A Complete Guide https://jsdev.space/clipboard-electron/
[7] Sending File to the Renderer - Electron, v3 - Frontend Masters https://frontendmasters.com/courses/electron-v3/sending-file-to-the-renderer/
[8] In Electron Framework, Can I access clipboard? https://stackoverflow.com/questions/31130150/in-electron-framework-can-i-access-clipboard/31175073
[9] Mastering the use of the Clipboard with Electron Framework https://ourcodeworld.com/articles/read/203/mastering-the-use-of-the-clipboard-with-electron-framework
[10] Access Electron API from a completely different system process https://stackoverflow.com/questions/51224896/access-electron-api-from-a-completely-different-system-process


---

## Shell Module for External Resources

The shell module provides functions for desktop integration, allowing interaction with files and URLs using default applications. It runs in both Main and Renderer processes (non-sandboxed only).[1][2]

### Opening External URLs

The `openExternal()` method opens URLs in the system's default application.[2][1]

```javascript
const { shell } = require('electron')

shell.openExternal('https://github.com')
```

This opens URLs in the default browser for HTTP/HTTPS, or in the appropriate application for protocol handlers like `mailto:`, `tel:`, or custom schemes. Windows URLs are limited to 2081 characters.[3][2]

**With Options**
```javascript
shell.openExternal('https://example.com', {
  activate: true,
  workingDirectory: '/path/to/dir'
}).then(() => {
  console.log('URL opened successfully')
}).catch(err => {
  console.error('Failed to open URL:', err)
})
```

The method returns a `Promise<void>` that resolves when the operation completes. The `activate` option (macOS) determines whether to bring the opened application to the foreground.[2][3]

### Opening Local Files and Folders

The `openPath()` method opens files or folders with the default system application.[1][2]

```javascript
const { shell } = require('electron')

// Open a file with its default application
shell.openPath('/path/to/document.pdf').then((error) => {
  if (error) {
    console.error('Failed to open path:', error)
  }
})

// Open a folder in file explorer
shell.openPath('/path/to/folder')
```

This replaces the deprecated `openItem()` method and returns a `Promise<string>` that resolves with an error message if the operation fails, or an empty string on success.[4][5][2]

### Showing Items in File Manager

The `showItemInFolder()` method reveals a file in its containing folder and selects it if possible.[5][2]

```javascript
const { shell } = require('electron')

shell.showItemInFolder('/path/to/file.txt')
```

This opens the file manager (Explorer on Windows, Finder on macOS, file manager on Linux) and highlights the specified file. On Linux, the implementation uses XDGOpen to show the parent directory.[6][7][5]

### Moving Items to Trash

The `trashItem()` method moves files or folders to the OS-specific trash location.[3][2]

```javascript
const { shell } = require('electron')

shell.trashItem('/path/to/file').then(() => {
  console.log('Item moved to trash')
}).catch(err => {
  console.error('Failed to trash item:', err)
})
```

This returns a `Promise<void>` that rejects if an error occurs. The destination varies by platform: Trash on macOS, Recycle Bin on Windows, and desktop-environment-specific locations on Linux.[2][3]

### Playing System Beep

The `beep()` method plays the system's default beep sound.[7][8]

```javascript
const { shell } = require('electron')

shell.beep()
```

This provides audio feedback using the native system sound.[8][7]

### Windows Shortcut Management

Windows-specific methods create and manage desktop shortcuts.[2]

**Writing Shortcuts**
```javascript
const { shell } = require('electron')

shell.writeShortcutLink('C:\\Users\\Username\\Desktop\\MyApp.lnk', {
  target: 'C:\\path\\to\\app.exe',
  cwd: 'C:\\path\\to',
  args: '--flag',
  description: 'My Application',
  icon: 'C:\\path\\to\\icon.ico',
  iconIndex: 0,
  appUserModelId: 'com.mycompany.myapp'
})
```

The optional `operation` parameter can be `'create'`, `'update'`, or `'replace'` (defaults to `'create'`).[7][2]

**Reading Shortcuts**
```javascript
const shortcutDetails = shell.readShortcutLink('C:\\Users\\Username\\Desktop\\MyApp.lnk')

console.log(shortcutDetails.target)
console.log(shortcutDetails.args)
```

Returns an object containing shortcut properties including `target`, `cwd`, `args`, `description`, `icon`, `iconIndex`, and `appUserModelId`.[2]

### Security Considerations

Shell methods can be exploited if user-controlled input is passed without validation.[9][6]

**Unsafe Usage**
```javascript
// VULNERABLE: User input passed directly
shell.openExternal(userProvidedURL)
```

This allows attackers to inject malicious URLs with dangerous protocols like `javascript:` or `file:`.[6][9]

**Safe Usage with Allowlist**
```javascript
function openExternalSafely(url) {
  try {
    const parsed = new URL(url)
    
    // Allowlist safe protocols
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      console.error('Blocked unsafe protocol:', parsed.protocol)
      return
    }
    
    shell.openExternal(url)
  } catch (err) {
    console.error('Invalid URL:', err)
  }
}

openExternalSafely(userProvidedURL)
```

Always validate and sanitize URLs before passing them to `openExternal()` or `openPath()`.[9][6]

### Usage in Renderer Process

When using the shell module in sandboxed renderer processes, expose methods through the preload script.[10]

**Main Process**
```javascript
const { ipcMain, shell } = require('electron')

ipcMain.handle('showItemInFolder', (event, fullPath) => {
  shell.showItemInFolder(fullPath)
})

ipcMain.handle('openPath', (event, path) => {
  return shell.openPath(path)
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('electronAPI', {
  showItemInFolder: (fullPath) => ipcRenderer.invoke('showItemInFolder', fullPath),
  openPath: (path) => ipcRenderer.invoke('openPath', path)
})
```

**Renderer Process**
```javascript
window.electronAPI.showItemInFolder('/path/to/file')
window.electronAPI.openPath('/path/to/folder')
```

This approach ensures secure IPC communication between processes while maintaining shell functionality.[10]

Sources
[1] shell - Electron https://www.electronjs.org/docs/latest/api/shell
[2] Menu | Electron https://electronjs.org/docs/latest/api/menu
[3] shell https://electronjs.org/docs/latest/api/shell
[4] javascript - Open external application with electron https://stackoverflow.com/questions/74814215/open-external-application-with-electron
[5] Electron open file/directory in specific application https://stackoverflow.com/questions/43991267/electron-open-file-directory-in-specific-application
[6] Electron APIs Misuse: An Attacker's First Choice https://blog.doyensec.com/2021/02/16/electron-apis-misuse.html
[7] shell | Electron https://zeke.github.io/electron.atom.io/docs/api/shell/
[8] shell | FAQ https://imfly.github.io/electron-docs-gitbook/en/api/shell.html
[9] Penetration Testing of Electron-based Applications https://deepstrike.io/blog/penetration-testing-of-electron-based-applications
[10] [Bug]: shell.openPath open windows explorer in the ... https://github.com/electron/electron/issues/36765
[11] shell.showItemInFolder in MAC OS opens Finder very slow https://github.com/electron/electron/issues/17835


---

# File System Operations

## Reading and Writing Files

Electron applications can read and write files using Node.js's built-in `fs` (File System) module. The `fs` module is available in both Main and Renderer processes, though modern Electron requires careful handling in sandboxed renderers.[1][2][3]

### Reading Files

The `fs` module provides both synchronous and asynchronous methods for reading files. Asynchronous operations are recommended to avoid blocking the UI thread.[3][1]

**Asynchronous Reading (Callback)**
```javascript
const fs = require('fs')

fs.readFile('path/to/file.txt', 'utf8', (err, data) => {
  if (err) {
    console.error('Error reading file:', err)
    return
  }
  console.log('File content:', data)
})
```

The encoding parameter (`'utf8'`) interprets the file as text. Omitting it returns a Buffer object for binary data.[4][1]

**Promise-Based Reading**
```javascript
const fs = require('fs').promises

async function readFileAsync() {
  try {
    const data = await fs.readFile('path/to/file.txt', 'utf8')
    console.log('File content:', data)
  } catch (err) {
    console.error('Error reading file:', err)
  }
}

readFileAsync()
```

The `fs.promises` API provides modern async/await syntax.[5]

**Synchronous Reading**
```javascript
const fs = require('fs')

try {
  const data = fs.readFileSync('path/to/file.txt', 'utf8')
  console.log(data)
} catch (err) {
  console.error('Error reading file:', err)
}
```

Synchronous methods block execution until complete and should be used sparingly.[1][4]

### Writing Files

The `fs.writeFile()` method creates new files or overwrites existing ones.[6][1]

**Asynchronous Writing (Callback)**
```javascript
const fs = require('fs')

const content = 'This is the content I want to save.'

fs.writeFile('path/to/output.txt', content, 'utf8', (err) => {
  if (err) {
    console.error('Error writing file:', err)
    return
  }
  console.log('File has been written successfully!')
})
```

The encoding parameter defaults to `'utf8'` for text files.[6][1]

**Promise-Based Writing**
```javascript
const fs = require('fs').promises

async function writeFileAsync() {
  try {
    await fs.writeFile('path/to/output.txt', 'Hello, World!', 'utf8')
    console.log('File written successfully')
  } catch (err) {
    console.error('Error writing file:', err)
  }
}

writeFileAsync()
```

**Synchronous Writing**
```javascript
const fs = require('fs')

try {
  fs.writeFileSync('path/to/output.txt', 'Data to write', 'utf8')
  console.log('File written')
} catch (err) {
  console.error('Error writing file:', err)
}
```

### Appending to Files

Use `fs.appendFile()` to add content without overwriting existing data.[4]

```javascript
const fs = require('fs')

fs.appendFile('path/to/file.txt', '\nNew line of text', 'utf8', (err) => {
  if (err) {
    console.error('Error appending to file:', err)
    return
  }
  console.log('Content appended successfully')
})
```

This adds data to the end of the file or creates a new file if it doesn't exist.[4]

### Working with JSON Files

JSON files are commonly used for configuration and data storage.[7][6]

**Reading JSON**
```javascript
const fs = require('fs')

fs.readFile('./config.json', 'utf8', (err, data) => {
  if (err) {
    console.error('Error reading JSON:', err)
    return
  }
  
  const jsonData = JSON.parse(data)
  console.log(jsonData)
})
```

**Writing JSON**
```javascript
const fs = require('fs')

const dataToSave = {
  name: 'My App',
  version: '1.0.0',
  settings: { theme: 'dark' }
}

const jsonString = JSON.stringify(dataToSave, null, 2)

fs.writeFile('./config.json', jsonString, 'utf8', (err) => {
  if (err) {
    console.error('Error writing JSON:', err)
    return
  }
  console.log('JSON file saved')
})
```

The `JSON.stringify()` second parameter is a replacer function (null means no filtering), and the third parameter controls indentation for readability.[7][6]

### Reading Binary Files

Binary files like images require omitting the encoding parameter.[7]

```javascript
const fs = require('fs')

fs.readFile('path/to/image.jpg', (err, data) => {
  if (err) {
    console.error('Error reading image:', err)
    return
  }
  
  // data is a Buffer object containing raw binary data
  console.log('Image size:', data.length, 'bytes')
  
  // Can be converted to base64 for embedding
  const base64 = data.toString('base64')
})
```

### File Paths

Use the `path` module to construct cross-platform file paths.[8][6]

```javascript
const path = require('path')
const fs = require('fs')

// Join path segments
const filePath = path.join(__dirname, 'data', 'config.json')

// Get app data directory (user-specific storage)
const { app } = require('electron')
const userDataPath = app.getPath('userData')
const configPath = path.join(userDataPath, 'settings.json')

fs.writeFile(configPath, '{}', (err) => {
  if (err) console.error(err)
})
```

The `path.join()` method handles platform-specific separators automatically.[8]

### Using fs in Renderer Process (Modern Electron)

In Electron v20+, renderer processes are sandboxed by default and cannot directly access Node.js modules. File operations must go through IPC communication.[2]

**Main Process**
```javascript
const { ipcMain } = require('electron')
const fs = require('fs').promises

ipcMain.handle('read-file', async (event, filePath) => {
  try {
    const data = await fs.readFile(filePath, 'utf8')
    return { success: true, data }
  } catch (err) {
    return { success: false, error: err.message }
  }
})

ipcMain.handle('write-file', async (event, filePath, content) => {
  try {
    await fs.writeFile(filePath, content, 'utf8')
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message }
  }
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileSystem', {
  readFile: (filePath) => ipcRenderer.invoke('read-file', filePath),
  writeFile: (filePath, content) => ipcRenderer.invoke('write-file', filePath, content)
})
```

**Renderer Process**
```javascript
// Read file
window.fileSystem.readFile('/path/to/file.txt').then(result => {
  if (result.success) {
    console.log('File content:', result.data)
  } else {
    console.error('Error:', result.error)
  }
})

// Write file
window.fileSystem.writeFile('/path/to/file.txt', 'New content').then(result => {
  if (result.success) {
    console.log('File written successfully')
  } else {
    console.error('Error:', result.error)
  }
})
```

This approach maintains security while allowing controlled file system access.[2]

### Packaged Application Considerations

When packaging Electron apps with tools like electron-builder, include necessary files in the build configuration.[6]

**package.json**
```json
{
  "build": {
    "files": [
      "dist/**/*",
      "file.json"
    ]
  }
}
```

This ensures files are copied into the packaged application. Use `app.getPath('userData')` for user-specific files that should persist outside the installation directory.[8][6]

Sources
[1] Reading and Writing Files in Your Electron App | Chapter 5 https://seino-prince.com/book/2b3b4ab5-d136-81fb-8232-c0df9dc6329f/chapter/2b3b4ab5-d136-8177-b4be-ff54485dad44/section/2b3b4ab5-d136-81d4-9367-c84d0ad04bbe
[2] Electron: Executing Main Process Code from Renderer https://ncoughlin.com/posts/electron-executing-main-process-code-from-renderer
[3] Distinction between the renderer and main processes in Electron https://stackoverflow.com/questions/37669727/distinction-between-the-renderer-and-main-processes-in-electron
[4] How to Read and Write Files Using the fs Module in Node Js https://www.almabetter.com/bytes/tutorials/nodejs/fs-module-in-nodejs
[5] File system | Node.js v25.3.0 Documentation https://nodejs.org/api/fs.html
[6] Electron package - how to write/read files https://stackoverflow.com/questions/46027816/electron-package-how-to-write-read-files
[7] Accessing Local Files In Electron App : r/node https://www.reddit.com/r/node/comments/1bneas0/accessing_local_files_in_electron_app/
[8] Reading & Writing Files in Electron JS - Electron Tutorial https://www.youtube.com/watch?v=1rDvNDvZrnA
[9] Meteor + Electron - filesystem (fs) - help https://forums.meteor.com/t/meteor-electron-filesystem-fs/26262
[10] How to use writeFile and readFile together in node js https://stackoverflow.com/questions/46621069/how-to-use-writefile-and-readfile-together-in-node-js/46621124

---

## File Path Management

Electron applications require robust file path management to handle cross-platform differences and locate system directories. The `path` module and `app.getPath()` method provide essential tools for constructing and accessing file paths.[1][2]

### Standard System Paths

The `app.getPath(name)` method returns platform-specific directories where applications should store data.[2][1]

**Common Path Types**
```javascript
const { app } = require('electron')

// User data directory - recommended for app configuration and data
const userDataPath = app.getPath('userData')
// Windows: C:\Users\{username}\AppData\Roaming\{app name}
// macOS: ~/Library/Application Support/{app name}
// Linux: ~/.config/{app name}

// Application data directory
const appDataPath = app.getPath('appData')
// Windows: C:\Users\{username}\AppData\Roaming
// macOS: ~/Library/Application Support
// Linux: ~/.config

// Temporary files directory
const tempPath = app.getPath('temp')

// User's home directory
const homePath = app.getPath('home')

// Desktop directory
const desktopPath = app.getPath('desktop')

// Documents directory
const documentsPath = app.getPath('documents')

// Downloads directory
const downloadsPath = app.getPath('downloads')

// User's pictures directory
const picturesPath = app.getPath('pictures')

// User's videos directory
const videosPath = app.getPath('videos')

// User's music directory
const musicPath = app.getPath('music')
```

The `userData` path is automatically created by Electron and is the recommended location for storing application-specific data.[1][2]

### Setting Custom Paths

Override default paths using `app.setPath()` before the `ready` event fires.[3]

```javascript
const { app } = require('electron')
const path = require('path')

// Must be called before 'ready' event
app.setPath('userData', path.join(app.getPath('appData'), 'MyCustomFolder'))

app.on('ready', () => {
  console.log(app.getPath('userData'))
  // Now points to custom location
})
```

This allows custom storage locations, though the default directory may still be created initially.[3]

### Path Module for Cross-Platform Compatibility

Node.js's `path` module ensures file paths work across operating systems.[4]

**Joining Path Segments**
```javascript
const path = require('path')

// Automatically uses correct separator (/ or \)
const configPath = path.join(__dirname, 'config', 'settings.json')
// Windows: C:\app\config\settings.json
// Unix: /app/config/settings.json
```

The `path.join()` method handles platform-specific separators and normalizes the resulting path.[4]

**Other Useful Methods**
```javascript
const path = require('path')

// Get directory name from path
const dir = path.dirname('/path/to/file.txt')
// Returns: /path/to

// Get file name with extension
const file = path.basename('/path/to/file.txt')
// Returns: file.txt

// Get file extension
const ext = path.extname('/path/to/file.txt')
// Returns: .txt

// Normalize path (resolve .. and .)
const normalized = path.normalize('/path/to/../file.txt')
// Returns: /path/file.txt

// Resolve to absolute path
const absolute = path.resolve('relative/path.txt')
// Returns absolute path based on current working directory
```

### Using __dirname

The `__dirname` global variable contains the absolute path to the directory containing the current file.[4]

```javascript
const path = require('path')
const fs = require('fs')

// Read file relative to current script location
const filePath = path.join(__dirname, 'data', 'config.json')
const config = JSON.parse(fs.readFileSync(filePath, 'utf8'))
```

This ensures file operations work regardless of the current working directory.[4]

**ES Modules Equivalent**
```javascript
import { fileURLToPath } from 'url'
import path from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const configPath = path.join(__dirname, 'config', 'app.json')
```

ES modules require reconstructing `__dirname` from `import.meta.url`.[4]

### Packaged Application Paths

Packaged Electron apps have different path requirements than development mode.[5]

**Development vs Production**
```javascript
const { app } = require('electron')
const path = require('path')

const isDev = !app.isPackaged

const resourcesPath = isDev
  ? __dirname
  : process.resourcesPath

const iconPath = path.join(resourcesPath, 'assets', 'icon.png')
```

In production, `process.resourcesPath` points to the `app.asar` or `resources` directory inside the packaged application.[5]

**App Path**
```javascript
const appPath = app.getAppPath()
// Development: Project directory
// Production: Path to .asar file or unpacked app directory
```

### Storing User Configuration

Best practice for user configuration files uses `userData` directory.[6][1]

```javascript
const { app } = require('electron')
const path = require('path')
const fs = require('fs')

class Store {
  constructor(configName) {
    const userDataPath = app.getPath('userData')
    this.path = path.join(userDataPath, `${configName}.json`)
    
    // Create directory if it doesn't exist
    if (!fs.existsSync(userDataPath)) {
      fs.mkdirSync(userDataPath, { recursive: true })
    }
    
    // Initialize with empty object if file doesn't exist
    if (!fs.existsSync(this.path)) {
      this.data = {}
      this.save()
    } else {
      this.data = JSON.parse(fs.readFileSync(this.path, 'utf8'))
    }
  }
  
  get(key) {
    return this.data[key]
  }
  
  set(key, value) {
    this.data[key] = value
    this.save()
  }
  
  save() {
    fs.writeFileSync(this.path, JSON.stringify(this.data, null, 2))
  }
}

// Usage
const store = new Store('config')
store.set('windowBounds', { width: 800, height: 600 })
console.log(store.get('windowBounds'))
```

This pattern persists data between application launches.[6]

### Platform-Specific Path Differences

Understanding platform conventions helps with debugging and testing.[2][1]

| Path Type  | Windows                 | macOS                                 | Linux             |
| ---------- | ----------------------- | ------------------------------------- | ----------------- |
| `appData`  | `%APPDATA%`             | `~/Library/Application Support`       | `~/.config`       |
| `userData` | `%APPDATA%\{app}`       | `~/Library/Application Support/{app}` | `~/.config/{app}` |
| `temp`     | `%TEMP%`                | `/var/folders/...`                    | `/tmp`            |
| `home`     | `C:\Users\{user}`       | `/Users/{user}`                       | `/home/{user}`    |
| `desktop`  | `%USERPROFILE%\Desktop` | `~/Desktop`                           | `~/Desktop`       |

### App Name in Paths

The `userData` path uses the app name from `package.json`.[7]

**package.json**
```json
{
  "name": "my-electron-app",
  "productName": "My Electron App"
}
```

During development, `app.getPath('userData')` may return `Electron` instead of the app name. Setting a proper entry point in `package.json` fixes this:[7]

```json
{
  "name": "my-electron-app",
  "main": "src/main.js"
}
```

For packaged applications, `productName` determines the final directory name.[7]

### Cross-Platform Development

Never commit `node_modules` when sharing projects between operating systems.[8]

```gitignore
node_modules/
dist/
out/
*.log
```

Each platform requires its own `npm install` to compile native dependencies correctly. Electron binaries are platform-specific and cannot be shared between Windows, macOS, and Linux.[8]

Sources
[1] Electron store my app datas in 'userData' path https://stackoverflow.com/questions/61039792/electron-store-my-app-datas-in-userdata-path
[2] Electron Local Data Storage Solutions - Kelen https://en.kelen.cc/posts/electron-local-data-storage-solutions
[3] userData directory is created in the default location when ... https://github.com/electron/electron/issues/2668
[4] How To Use __dirname in Node.js - DigitalOcean https://www.digitalocean.com/community/tutorials/nodejs-how-to-use__dirname
[5] __dirname paths do not resolve correctly when electron ... - GitHub https://github.com/webpack/webpack/issues/5424
[6] Example "store" for user data in an Electron app https://gist.github.com/ccnokes/95cb454860dbf8577e88d734c3f31e08
[7] App.getPath("userData") seems to give the wrong path https://stackoverflow.com/questions/35630934/app-getpathuserdata-seems-to-give-the-wrong-path/35643478
[8] Sharing the same project folder between macOS and Windows https://stackoverflow.com/questions/63916585/electron-sharing-the-same-project-folder-between-macos-and-windows
[9] [Bug]: function app.getPath("userData") returns a wrong path in ... https://github.com/electron/electron/issues/39636
[10] Building Cross-Platform Desktop Apps with Electron.NET - mescius https://developer.mescius.com/blogs/building-cross-platform-desktop-apps-with-electron-dot-net


---

## Directory Operations

Electron applications can perform directory operations using Node.js's `fs` module, with support for both synchronous and asynchronous methods. Modern Node.js provides promise-based alternatives through `fs.promises` for cleaner async code.[1][2]

### Creating Directories

The `fs.mkdir()` method creates new directories with optional recursive capabilities.[2][3]

**Asynchronous Creation (Callback)**
```javascript
const fs = require('fs')

fs.mkdir('./new-directory', (err) => {
  if (err) {
    console.error('Error creating directory:', err)
    return
  }
  console.log('Directory created successfully')
})
```

**Promise-Based Creation**
```javascript
const fs = require('fs').promises

async function createDirectory() {
  try {
    await fs.mkdir('./new-directory')
    console.log('Directory created successfully')
  } catch (err) {
    console.error('Error creating directory:', err)
  }
}

createDirectory()
```

**Synchronous Creation**
```javascript
const fs = require('fs')

try {
  fs.mkdirSync('./new-directory')
  console.log('Directory created successfully')
} catch (err) {
  console.error('Error creating directory:', err)
}
```

### Recursive Directory Creation

The `recursive` option creates parent directories automatically if they don't exist.[1][2]

```javascript
const fs = require('fs').promises

async function createNestedDirectories() {
  try {
    // Creates project/, project/data/, and project/data/logs/
    await fs.mkdir('./project/data/logs', { recursive: true })
    console.log('Nested directories created successfully')
  } catch (err) {
    console.error('Error creating directories:', err)
  }
}

createNestedDirectories()
```

Without the `recursive` option, attempting to create nested paths fails if parent directories don't exist. Setting `recursive: true` prevents errors when directories already exist.[2][1]

### Reading Directory Contents

The `fs.readdir()` method retrieves an array of filenames in a directory.[4][5]

**Asynchronous Reading (Callback)**
```javascript
const fs = require('fs')

fs.readdir('./my-directory', (err, files) => {
  if (err) {
    console.error('Error reading directory:', err)
    return
  }
  console.log('Directory contents:', files)
  files.forEach(file => {
    console.log(file)
  })
})
```

**Promise-Based Reading**
```javascript
const fs = require('fs').promises

async function readDirectory() {
  try {
    const files = await fs.readdir('./my-directory')
    console.log('Files:', files)
  } catch (err) {
    console.error('Error reading directory:', err)
  }
}

readDirectory()
```

**Synchronous Reading**
```javascript
const fs = require('fs')

try {
  const files = fs.readdirSync('./my-directory')
  console.log('Files:', files)
} catch (err) {
  console.error('Error reading directory:', err)
}
```

### Getting File Type Information

The `withFileTypes` option returns `Dirent` objects with file type information.[5][4]

```javascript
const fs = require('fs').promises

async function listDirectoryContents() {
  try {
    const entries = await fs.readdir('./my-directory', { withFileTypes: true })
    
    entries.forEach(entry => {
      if (entry.isDirectory()) {
        console.log(`[DIR]  ${entry.name}`)
      } else if (entry.isFile()) {
        console.log(`[FILE] ${entry.name}`)
      }
    })
  } catch (err) {
    console.error('Error reading directory:', err)
  }
}

listDirectoryContents()
```

The `Dirent` object provides methods like `isFile()`, `isDirectory()`, `isSymbolicLink()`, `isBlockDevice()`, `isCharacterDevice()`, `isFIFO()`, and `isSocket()`.[4]

### Recursive Directory Reading

Reading directories recursively requires manual implementation.[6]

```javascript
const fs = require('fs').promises
const path = require('path')

async function readDirRecursive(dirPath) {
  const entries = await fs.readdir(dirPath, { withFileTypes: true })
  const files = []
  
  for (const entry of entries) {
    const fullPath = path.join(dirPath, entry.name)
    
    if (entry.isDirectory()) {
      const subFiles = await readDirRecursive(fullPath)
      files.push(...subFiles)
    } else {
      files.push(fullPath)
    }
  }
  
  return files
}

// Usage
readDirRecursive('./project').then(files => {
  console.log('All files:', files)
}).catch(err => {
  console.error('Error:', err)
})
```

This traverses all subdirectories and returns an array of all file paths.[6]

### Deleting Directories

The `fs.rm()` method removes directories and their contents.[7]

**Deleting Non-Empty Directories**
```javascript
const fs = require('fs').promises

async function deleteDirectory() {
  try {
    await fs.rm('./temp-folder', { recursive: true, force: true })
    console.log('Directory deleted successfully')
  } catch (err) {
    console.error('Error deleting directory:', err)
  }
}

deleteDirectory()
```

The `recursive: true` option enables deletion of non-empty directories, while `force: true` prevents errors if the directory doesn't exist. This method replaces the deprecated `fs.rmdir()`.[7]

**Callback-Based Deletion**
```javascript
const fs = require('fs')

fs.rm('./temp-folder', { recursive: true, force: true }, (err) => {
  if (err) {
    console.error('Error deleting directory:', err)
    return
  }
  console.log('Directory deleted successfully')
})
```

**Synchronous Deletion**
```javascript
const fs = require('fs')

try {
  fs.rmSync('./temp-folder', { recursive: true, force: true })
  console.log('Directory deleted successfully')
} catch (err) {
  console.error('Error deleting directory:', err)
}
```

### Deleting Empty Directories

For empty directories, use `fs.rmdir()` (still supported for empty directories) or `fs.rm()` without recursive.[1]

```javascript
const fs = require('fs').promises

async function deleteEmptyDirectory() {
  try {
    await fs.rmdir('./empty-folder')
    console.log('Empty directory deleted')
  } catch (err) {
    console.error('Error deleting directory:', err)
  }
}

deleteEmptyDirectory()
```

### Checking Directory Existence

Use `fs.stat()` or `fs.access()` to verify directory existence.[2][1]

```javascript
const fs = require('fs').promises

async function directoryExists(path) {
  try {
    const stats = await fs.stat(path)
    return stats.isDirectory()
  } catch (err) {
    return false
  }
}

// Usage
const exists = await directoryExists('./my-directory')
console.log('Directory exists:', exists)
```

**Alternative with fs.access()**
```javascript
const fs = require('fs').promises

async function checkDirectory(path) {
  try {
    await fs.access(path)
    const stats = await fs.stat(path)
    return stats.isDirectory()
  } catch (err) {
    return false
  }
}
```

### Creating Directories with Error Handling

Comprehensive error handling ensures directories are created only when needed.[2]

```javascript
const fs = require('fs').promises

async function ensureDirectory(dirPath) {
  try {
    // Try to read directory stats
    const stats = await fs.stat(dirPath)
    
    if (stats.isDirectory()) {
      console.log('Directory already exists')
      return
    } else {
      throw new Error('Path exists but is not a directory')
    }
  } catch (err) {
    if (err.code === 'ENOENT') {
      // Directory doesn't exist, create it
      await fs.mkdir(dirPath, { recursive: true })
      console.log('Directory created successfully')
    } else {
      throw err
    }
  }
}

ensureDirectory('./project/data')
```

### Renaming/Moving Directories

The `fs.rename()` method moves or renames directories.[1]

```javascript
const fs = require('fs').promises

async function renameDirectory() {
  try {
    await fs.rename('./old-name', './new-name')
    console.log('Directory renamed successfully')
  } catch (err) {
    console.error('Error renaming directory:', err)
  }
}

renameDirectory()
```

This works for both moving and renaming operations.[1]

### Electron Integration Example

Combining directory operations with Electron's app paths.[1]

```javascript
const { app } = require('electron')
const fs = require('fs').promises
const path = require('path')

app.whenReady().then(async () => {
  const userDataPath = app.getPath('userData')
  const dataDir = path.join(userDataPath, 'data')
  const logsDir = path.join(dataDir, 'logs')
  
  try {
    // Ensure directory structure exists
    await fs.mkdir(logsDir, { recursive: true })
    
    // List contents
    const files = await fs.readdir(dataDir)
    console.log('Data directory contents:', files)
    
  } catch (err) {
    console.error('Error managing directories:', err)
  }
})
```

This creates and manages application-specific directories in the user data location.[1]

Sources
[1] Working with folders in Node.js https://nodejs.org/en/learn/manipulating-files/working-with-folders-in-nodejs
[2] Optimizing Directory Creation in Node.js with fsPromises.mkdir() https://runebook.dev/en/articles/node/fs/fspromisesmkdirpath-options
[3] Node fs.mkdir() Method https://www.geeksforgeeks.org/node-js/node-js-fs-mkdir-method/
[4] Node.js fs.readdir() Method https://www.geeksforgeeks.org/node-js/node-js-fs-readdir-method/
[5] How to Use fs.readdir in Node.js? https://www.browserstack.com/guide/fs-readdir-in-node-js
[6] Node.js fs.readdir recursive directory search https://stackoverflow.com/questions/5827612/node-js-fs-readdir-recursive-directory-search/42441762
[7] How to delete directories in Node.js https://coreui.io/answers/how-to-delete-directories-in-nodejs/
[8] File system | Node.js v25.3.0 Documentation https://nodejs.org/api/fs.html
[9] Delete a Non-Empty Directory Using the rm Command https://www.eukhost.com/kb/how-to-delete-a-non-empty-directory-using-the-rm-command/
[10] Node.js fs.promise.readdir() Method - GeeksforGeeks https://www.geeksforgeeks.org/node-js/node-js-fs-promise-readdir-method/


---

## File Deletion and Manipulation

Node.js's `fs` module provides comprehensive methods for deleting, renaming, moving, and inspecting files in Electron applications. These operations support both synchronous and asynchronous patterns.[1][2][3][4]

### Deleting Files

The `fs.unlink()` method removes files or symbolic links from the file system.[2][1]

**Asynchronous Deletion (Callback)**
```javascript
const fs = require('fs')

fs.unlink('path/to/file.txt', (err) => {
  if (err) {
    console.error('Error deleting file:', err)
    return
  }
  console.log('File deleted successfully')
})
```

**Promise-Based Deletion**
```javascript
const fs = require('fs').promises

async function deleteFile() {
  try {
    await fs.unlink('path/to/file.txt')
    console.log('File deleted successfully')
  } catch (err) {
    console.error('Error deleting file:', err)
  }
}

deleteFile()
```

**Synchronous Deletion**
```javascript
const fs = require('fs')

try {
  fs.unlinkSync('path/to/file.txt')
  console.log('File deleted successfully')
} catch (err) {
  console.error('Error deleting file:', err)
}
```

The `unlink()` method only works for files and symbolic links, not directories. For directories, use `fs.rmdir()` or `fs.rm()`.[5][2]

### Checking File Existence Before Deletion

Verify file existence to prevent errors when deleting.[1][5]

```javascript
const fs = require('fs').promises

async function deleteFileIfExists(filePath) {
  try {
    await fs.access(filePath)
    await fs.unlink(filePath)
    console.log('File deleted successfully')
  } catch (err) {
    if (err.code === 'ENOENT') {
      console.log('File does not exist')
    } else {
      console.error('Error deleting file:', err)
    }
  }
}

deleteFileIfExists('path/to/file.txt')
```

Using `fs.access()` checks if the file exists before attempting deletion.[1]

### Renaming and Moving Files

The `fs.rename()` method handles both renaming and moving files.[4][6]

**Renaming Files**
```javascript
const fs = require('fs')

fs.rename('old-name.txt', 'new-name.txt', (err) => {
  if (err) {
    console.error('Error renaming file:', err)
    return
  }
  console.log('File renamed successfully')
})
```

**Moving Files**
```javascript
const fs = require('fs').promises
const path = require('path')

async function moveFile(oldPath, newPath) {
  try {
    await fs.rename(oldPath, newPath)
    console.log('File moved successfully')
  } catch (err) {
    console.error('Error moving file:', err)
  }
}

moveFile('path/to/file.txt', 'new-folder/file.txt')
```

If a file already exists at the destination path, `rename()` overwrites it.[6]

### Cross-Device File Moving

The `rename()` method fails when moving files across different devices or partitions (error code `EXDEV`). In this case, copy the file and delete the original:[4]

```javascript
const fs = require('fs')

function moveFile(oldPath, newPath, callback) {
  fs.rename(oldPath, newPath, (err) => {
    if (err) {
      if (err.code === 'EXDEV') {
        // Cross-device move - copy then delete
        copyFile(oldPath, newPath, (copyErr) => {
          if (copyErr) {
            callback(copyErr)
            return
          }
          
          fs.unlink(oldPath, (unlinkErr) => {
            callback(unlinkErr)
          })
        })
      } else {
        callback(err)
      }
    } else {
      callback(null)
    }
  })
}

function copyFile(source, target, callback) {
  const readStream = fs.createReadStream(source)
  const writeStream = fs.createWriteStream(target)
  
  readStream.on('error', callback)
  writeStream.on('error', callback)
  writeStream.on('finish', callback)
  
  readStream.pipe(writeStream)
}

// Usage
moveFile('/source/path/file.txt', '/destination/path/file.txt', (err) => {
  if (err) {
    console.error('Error moving file:', err)
  } else {
    console.log('File moved successfully')
  }
})
```

### Copying Files

Node.js provides `fs.copyFile()` for efficient file copying.[4]

**Asynchronous Copy**
```javascript
const fs = require('fs')

fs.copyFile('source.txt', 'destination.txt', (err) => {
  if (err) {
    console.error('Error copying file:', err)
    return
  }
  console.log('File copied successfully')
})
```

**Promise-Based Copy**
```javascript
const fs = require('fs').promises

async function copyFile(source, destination) {
  try {
    await fs.copyFile(source, destination)
    console.log('File copied successfully')
  } catch (err) {
    console.error('Error copying file:', err)
  }
}

copyFile('source.txt', 'destination.txt')
```

**Synchronous Copy**
```javascript
const fs = require('fs')

try {
  fs.copyFileSync('source.txt', 'destination.txt')
  console.log('File copied successfully')
} catch (err) {
  console.error('Error copying file:', err)
}
```

### Retrieving File Metadata

The `fs.stat()` method returns detailed file information.[7][8]

```javascript
const fs = require('fs')

fs.stat('myFile.txt', (err, stats) => {
  if (err) {
    console.error('Error accessing file:', err)
    return
  }
  
  console.log('File size:', stats.size, 'bytes')
  console.log('Created:', stats.birthtime)
  console.log('Modified:', stats.mtime)
  console.log('Accessed:', stats.atime)
  console.log('Changed:', stats.ctime)
  console.log('Is file:', stats.isFile())
  console.log('Is directory:', stats.isDirectory())
  console.log('Is symbolic link:', stats.isSymbolicLink())
})
```

**Promise-Based Stats**
```javascript
const fs = require('fs').promises

async function getFileStats(filePath) {
  try {
    const stats = await fs.stat(filePath)
    
    return {
      size: stats.size,
      created: stats.birthtime,
      modified: stats.mtime,
      isFile: stats.isFile(),
      isDirectory: stats.isDirectory()
    }
  } catch (err) {
    console.error('Error getting file stats:', err)
  }
}

// Usage
const fileInfo = await getFileStats('myFile.txt')
console.log(fileInfo)
```

### Stats Object Properties

The `Stats` object provides comprehensive file metadata.[8]

| Property | Description |
|----------|-------------|
| `stats.size` | File size in bytes (0 for directories) |
| `stats.birthtime` | File creation time |
| `stats.mtime` | Last modification time |
| `stats.atime` | Last access time |
| `stats.ctime` | Last metadata change time |
| `stats.isFile()` | Returns true if path is a file |
| `stats.isDirectory()` | Returns true if path is a directory |
| `stats.isSymbolicLink()` | Returns true if path is a symbolic link |
| `stats.isBlockDevice()` | Returns true if block device |
| `stats.isCharacterDevice()` | Returns true if character device |
| `stats.isFIFO()` | Returns true if FIFO pipe |
| `stats.isSocket()` | Returns true if socket |

### Checking File Existence

Use `fs.stat()` to verify file existence.[7]

```javascript
const fs = require('fs')

fs.stat('myFile.txt', (err, stats) => {
  if (err && err.code === 'ENOENT') {
    console.log('File does not exist')
  } else if (err) {
    console.error('Error accessing file:', err)
  } else {
    console.log('File exists')
  }
})
```

**Promise-Based Existence Check**
```javascript
const fs = require('fs').promises

async function fileExists(filePath) {
  try {
    await fs.stat(filePath)
    return true
  } catch (err) {
    if (err.code === 'ENOENT') {
      return false
    }
    throw err
  }
}

// Usage
const exists = await fileExists('myFile.txt')
console.log('File exists:', exists)
```

### Using BigInt for Large Files

For files larger than 2GB, use the `bigint` option to avoid integer overflow.[8]

```javascript
const fs = require('fs')

fs.stat('large-file.bin', { bigint: true }, (err, stats) => {
  if (err) {
    console.error('Error:', err)
    return
  }
  
  console.log('File size:', stats.size) // Returns BigInt
})
```

### Electron Integration Example

Combining file operations in an Electron app with IPC.[1][4]

**Main Process**
```javascript
const { ipcMain } = require('electron')
const fs = require('fs').promises

ipcMain.handle('delete-file', async (event, filePath) => {
  try {
    await fs.unlink(filePath)
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message }
  }
})

ipcMain.handle('move-file', async (event, oldPath, newPath) => {
  try {
    await fs.rename(oldPath, newPath)
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message }
  }
})

ipcMain.handle('get-file-stats', async (event, filePath) => {
  try {
    const stats = await fs.stat(filePath)
    return {
      success: true,
      stats: {
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime,
        isFile: stats.isFile()
      }
    }
  } catch (err) {
    return { success: false, error: err.message }
  }
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileOps', {
  deleteFile: (filePath) => ipcRenderer.invoke('delete-file', filePath),
  moveFile: (oldPath, newPath) => ipcRenderer.invoke('move-file', oldPath, newPath),
  getFileStats: (filePath) => ipcRenderer.invoke('get-file-stats', filePath)
})
```

**Renderer Process**
```javascript
// Delete file
window.fileOps.deleteFile('/path/to/file.txt').then(result => {
  if (result.success) {
    console.log('File deleted')
  } else {
    console.error('Error:', result.error)
  }
})

// Move file
window.fileOps.moveFile('/old/path.txt', '/new/path.txt').then(result => {
  if (result.success) {
    console.log('File moved')
  }
})

// Get file stats
window.fileOps.getFileStats('/path/to/file.txt').then(result => {
  if (result.success) {
    console.log('File size:', result.stats.size, 'bytes')
  }
})
```

Sources
[1] node.js remove file https://stackoverflow.com/questions/5315138/node-js-remove-file
[2] Node fs.unlink() Method https://www.geeksforgeeks.org/node-js/node-js-fs-unlink-method/
[3] Node.js File System – Utilizing unlink() and unlinkSync() for ... https://dev.to/mccallum91/nodejs-file-system-utilizing-unlink-and-unlinksync-for-file-deletion-595e
[4] How do I move files in node.js? https://stackoverflow.com/questions/8579055/how-do-i-move-files-in-node-js
[5] How to Remove File in Node.js Using fs Module https://www.bacancytechnology.com/qanda/node/remove-file-in-node-js-using-fs-module
[6] Node fs.rename() Method https://www.geeksforgeeks.org/javascript/node-js-fs-rename-method/
[7] Mastering Node.js fs.stat(): Retrieving File Metadata https://runebook.dev/en/articles/node/fs/fsstatpath-options-callback
[8] Node.js fs.stat() Method - GeeksforGeeks https://www.geeksforgeeks.org/node-js/node-js-fs-stat-method/
[9] Trying to delete a file using Node.js. Should I use asynchronously fs.unlink(path, callback) or synchronous fs.unlinkSync(path)? https://stackoverflow.com/questions/66456409/trying-to-delete-a-file-using-node-js-should-i-use-asynchronously-fs-unlinkpat
[10] 7. How to Delete Files and Directories in Node.js | unlink vs rm vs rmdir Explained https://www.youtube.com/watch?v=pWRcazOOf-g


---

## Watching File System Changes

Node.js provides built-in methods for monitoring file and directory changes through the `fs` module. Electron applications can leverage these capabilities or use third-party libraries like `chokidar` for more robust file watching.[1][2]

### fs.watch() Method

The `fs.watch()` method monitors files or directories for changes using native OS capabilities.[3][1]

**Basic Usage**
```javascript
const fs = require('fs')

fs.watch('example.txt', (eventType, filename) => {
  console.log(`Event type: ${eventType}`)
  console.log(`File changed: ${filename}`)
})
```

The callback receives two parameters: `eventType` (either `'rename'` or `'change'`) and `filename` (the name of the file that triggered the event).[1][3]

**Watching Directories**
```javascript
const fs = require('fs')

fs.watch('./my-folder', (eventType, filename) => {
  if (filename) {
    console.log(`${filename} was modified`)
    console.log(`Event type: ${eventType}`)
  }
})
```

The method can watch both files and directories. When watching directories, the `filename` argument indicates which file in the directory changed.[4][3][1]

**With Options**
```javascript
const fs = require('fs')

const watcher = fs.watch('./my-folder', {
  persistent: true,     // Keep process running while watching
  recursive: true,      // Watch subdirectories (macOS/Windows only)
  encoding: 'utf8'      // Character encoding for filename
}, (eventType, filename) => {
  console.log(`${eventType} event on ${filename}`)
})

// Stop watching
watcher.close()
```

The `recursive` option enables watching of subdirectories but is only supported on macOS and Windows.[5][4]

### fs.watchFile() Method

The `fs.watchFile()` method polls files at regular intervals for changes.[4][1]

**Basic Usage**
```javascript
const fs = require('fs')

fs.watchFile('example.txt', (curr, prev) => {
  console.log('Current mtime:', curr.mtime)
  console.log('Previous mtime:', prev.mtime)
  
  if (curr.mtime !== prev.mtime) {
    console.log('File was modified')
  }
})
```

The callback receives two `fs.Stats` objects: current stats and previous stats.[4]

**With Options**
```javascript
const fs = require('fs')

fs.watchFile('example.txt', {
  persistent: true,    // Keep process running
  interval: 5000       // Poll every 5 seconds (default: 5007ms)
}, (curr, prev) => {
  console.log('File changed')
})

// Stop watching
fs.unwatchFile('example.txt')
```

The `interval` option specifies polling frequency in milliseconds.[5][4]

### fs.watch() vs fs.watchFile()

The methods have important differences that affect performance and compatibility.[3][5][4]

| Feature | fs.watch() | fs.watchFile() |
|---------|------------|----------------|
| Performance | Efficient (uses OS events) | Less efficient (constant polling) [4] |
| CPU Usage | Low | Higher due to polling [5] |
| Platform Support | Not all platforms (unstable on some) | Works everywhere [5] |
| Can Watch | Files and directories | Files only [1] |
| Recursive | Yes (macOS/Windows) | No [4] |
| Recommendation | Preferred when supported [4] | Use only if fs.watch() unavailable [3] |

The Node.js documentation recommends using `fs.watch()` instead of `fs.watchFile()` when possible due to better efficiency.[3][4]

### Known fs.watch() Issues

The native `fs.watch()` has several platform-specific limitations.[2]

**Common Problems**
- Doesn't report filenames on macOS in some cases[2]
- Doesn't report events when using certain editors like Sublime on macOS[2]
- Often reports events twice[2]
- Emits most changes as `'rename'` events[2]
- Not all platforms support recursive watching[4]

These issues make third-party solutions more reliable for production applications.[2]

### Using Chokidar Library

Chokidar provides a more robust file watching solution that resolves native `fs.watch()` limitations.[6][2]

**Installation**
```bash
npm install chokidar --save
```

**Basic Usage**
```javascript
const chokidar = require('chokidar')

const watcher = chokidar.watch('./my-folder', {
  ignored: /(^|[\/\\])\../, // Ignore dotfiles
  persistent: true
})

watcher
  .on('add', path => console.log(`File ${path} has been added`))
  .on('change', path => console.log(`File ${path} has been changed`))
  .on('unlink', path => console.log(`File ${path} has been removed`))
  .on('addDir', path => console.log(`Directory ${path} has been added`))
  .on('unlinkDir', path => console.log(`Directory ${path} has been removed`))
  .on('error', error => console.error(`Watcher error: ${error}`))
  .on('ready', () => console.log('Initial scan complete. Ready for changes'))
```

Chokidar provides granular events for different change types [].

**Waiting for Initial Scan**
```javascript
function startWatcher(path) {
  const chokidar = require('chokidar')
  
  const watcher = chokidar.watch(path, {
    ignored: /[\/\\]\./,
    persistent: true
  })
  
  watcher.on('ready', () => {
    console.log('Initial scan complete. Now watching for changes.')
    
    // Only watch for real changes after initial scan
    watcher
      .on('add', path => console.log(`File added: ${path}`))
      .on('change', path => console.log(`File changed: ${path}`))
      .on('unlink', path => console.log(`File removed: ${path}`))
  })
  
  return watcher
}

const watcher = startWatcher('./data')

// Stop watching
watcher.close()
```

The `ready` event fires when the initial scan completes, allowing you to distinguish between existing files and new additions.[2]

### Electron Integration

File watching in Electron typically runs in the Main process with IPC communication to renderers.[6]

**Main Process**
```javascript
const { app, ipcMain } = require('electron')
const chokidar = require('chokidar')

let watcher = null

ipcMain.on('start-watching', (event, folderPath) => {
  if (watcher) {
    watcher.close()
  }
  
  watcher = chokidar.watch(folderPath, {
    ignored: /(^|[\/\\])\../,
    persistent: true
  })
  
  watcher
    .on('add', path => {
      event.sender.send('file-added', path)
    })
    .on('change', path => {
      event.sender.send('file-changed', path)
    })
    .on('unlink', path => {
      event.sender.send('file-removed', path)
    })
    .on('error', error => {
      event.sender.send('watcher-error', error.message)
    })
})

ipcMain.on('stop-watching', () => {
  if (watcher) {
    watcher.close()
    watcher = null
  }
})

app.on('quit', () => {
  if (watcher) {
    watcher.close()
  }
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileWatcher', {
  startWatching: (path) => ipcRenderer.send('start-watching', path),
  stopWatching: () => ipcRenderer.send('stop-watching'),
  onFileAdded: (callback) => ipcRenderer.on('file-added', (event, path) => callback(path)),
  onFileChanged: (callback) => ipcRenderer.on('file-changed', (event, path) => callback(path)),
  onFileRemoved: (callback) => ipcRenderer.on('file-removed', (event, path) => callback(path)),
  onError: (callback) => ipcRenderer.on('watcher-error', (event, error) => callback(error))
})
```

**Renderer Process**
```javascript
// Start watching a folder
window.fileWatcher.startWatching('/path/to/watch')

// Listen for file events
window.fileWatcher.onFileAdded((path) => {
  console.log('New file:', path)
})

window.fileWatcher.onFileChanged((path) => {
  console.log('File changed:', path)
})

window.fileWatcher.onFileRemoved((path) => {
  console.log('File removed:', path)
})

window.fileWatcher.onError((error) => {
  console.error('Watcher error:', error)
})

// Stop watching
window.fileWatcher.stopWatching()
```

This pattern ensures file watching runs in the Main process while keeping renderers informed of changes [].

### Filtering Event Types

Handle specific event types to avoid processing unwanted changes [].

```javascript
const fs = require('fs')

fs.watch('example.txt', (eventType, filename) => {
  if (eventType === 'change') {
    console.log('File content was modified')
  } else if (eventType === 'rename') {
    console.log('File was renamed or deleted')
  }
})
```

The `eventType` can be `'change'` (file contents modified) or `'rename'` (file renamed/created/deleted) [].

Sources
[1] How to monitor a file for modifications in Node.js ? https://www.geeksforgeeks.org/node-js/how-to-monitor-a-file-for-modifications-in-node-js/
[2] Watch Files and Directories with Electron Framework | Our Code World https://ourcodeworld.com/articles/read/160/watch-files-and-directories-with-electron-framework
[3] How to Watch for File Changes in Node.js | thisDaveJ https://thisdavej.com/how-to-watch-for-file-changes-in-node-js/
[4] Understanding fs.watch() and fs.watchFile() in Node.js - Byte Box https://bhung6494.wordpress.com/2018/09/13/understanding-fs-watch-and-fs-watchfile-in-node-js/
[5] Difference between fs.watch() and fs.watchFile() - TECH-NI Blog https://tech.nitoyon.com/en/blog/2013/10/02/node-watch-impl/
[6] How to watch files in Electron App? - node.js - Stack Overflow https://stackoverflow.com/questions/30787590/how-to-watch-files-in-electron-app
[7] Observe file changes with node.js - Stack Overflow https://stackoverflow.com/questions/13698043/observe-file-changes-with-node-js
[8] fs.watchFile - Node.js https://nodejs.org/docs/latest/api/fs.html
[9] File system | Node.js v25.3.0 Documentation https://nodejs.org/api/fs.html
[10] How to Watch File Changes in Node.js - YouTube https://www.youtube.com/watch?v=YSkryJrMvOQ

---

## Native File Dialogs Integration

Electron's dialog module provides access to native system dialogs for opening and saving files. These dialogs are modal and run in the Main process, requiring IPC communication when triggered from renderer processes.[1][2][3][4]

### Opening Files with showOpenDialog()

The `showOpenDialog()` method displays the native file picker dialog and returns selected file paths.[4][1]

**Promise-Based (Recommended)**
```javascript
const { dialog } = require('electron')

dialog.showOpenDialog({
  properties: ['openFile', 'multiSelections']
}).then(result => {
  console.log('Cancelled:', result.canceled)
  console.log('File paths:', result.filePaths)
}).catch(err => {
  console.error('Dialog error:', err)
})
```

The method returns a Promise that resolves to an object with `canceled` (boolean) and `filePaths` (array of strings) properties.[1][4]

**With Parent Window**
```javascript
const { dialog, BrowserWindow } = require('electron')

const mainWindow = BrowserWindow.getFocusedWindow()

dialog.showOpenDialog(mainWindow, {
  title: 'Choose Files',
  buttonLabel: 'Select',
  defaultPath: app.getPath('documents'),
  properties: ['openFile', 'multiSelections']
}).then(result => {
  if (!result.canceled) {
    console.log('Selected files:', result.filePaths)
  }
})
```

Passing a `BrowserWindow` reference makes the dialog modal and attached to that window.[5][4]

### File Filters

The `filters` option restricts file types displayed in the dialog.[6][4][1]

```javascript
dialog.showOpenDialog({
  filters: [
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] },
    { name: 'Movies', extensions: ['mkv', 'avi', 'mp4'] },
    { name: 'Documents', extensions: ['pdf', 'doc', 'docx'] },
    { name: 'All Files', extensions: ['*'] }
  ],
  properties: ['openFile']
})
```

Extensions should be specified **without wildcards or dots** - use `'png'` instead of `'*.png'` or `'.png'`. The `All Files` filter with `['*']` allows selecting any file type.[3][4][6]

**Adding Filters Dynamically**
```javascript
const dialogOptions = {
  defaultPath: 'c:/',
  filters: [
    { name: 'All Files', extensions: ['*'] },
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] }
  ],
  properties: ['openFile']
}

// Check if filter already exists before adding
const customFilter = dialogOptions.filters.find(item => item.name === 'Custom')

if (!customFilter) {
  dialogOptions.filters.push({
    name: 'Custom',
    extensions: ['custom', 'ext']
  })
}

dialog.showOpenDialog(dialogOptions)
```

Electron doesn't check for duplicate filters, so manual verification is needed.[3]

### Dialog Properties

The `properties` array controls dialog behavior.[4][5][1]

```javascript
dialog.showOpenDialog({
  properties: [
    'openFile',          // Allow file selection
    'openDirectory',     // Allow directory selection
    'multiSelections',   // Allow multiple selections
    'showHiddenFiles',   // Show hidden files
    'createDirectory',   // macOS: Allow creating directories
    'promptToCreate',    // Windows: Prompt if path doesn't exist
    'noResolveAliases',  // macOS: Disable alias resolution
    'treatPackageAsDirectory' // macOS: Treat packages as directories
  ]
})
```

**Platform Limitation**: On Windows and Linux, a dialog cannot be both a file selector and directory selector simultaneously. Setting `['openFile', 'openDirectory']` will show a directory selector on these platforms.[5][1][4]

### Saving Files with showSaveDialog()

The `showSaveDialog()` method displays the native save dialog.[7][4]

**Promise-Based**
```javascript
const { dialog } = require('electron')

dialog.showSaveDialog({
  title: 'Save File',
  defaultPath: 'untitled.txt',
  buttonLabel: 'Save',
  filters: [
    { name: 'Text Files', extensions: ['txt'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}).then(result => {
  console.log('Cancelled:', result.canceled)
  console.log('File path:', result.filePath)
  
  if (!result.canceled && result.filePath) {
    // Write file using fs module
    fs.writeFileSync(result.filePath, 'File content')
  }
}).catch(err => {
  console.error('Dialog error:', err)
})
```

The method returns a Promise resolving to an object with `canceled` (boolean) and `filePath` (string) properties.[7][4]

**Synchronous Version**
```javascript
const filePath = dialog.showSaveDialogSync({
  title: 'Save File',
  defaultPath: 'document.pdf',
  filters: [
    { name: 'PDF Files', extensions: ['pdf'] },
    { name: 'All Files', extensions: ['*'] }
  ]
})

if (filePath) {
  console.log('Save to:', filePath)
  // File writing logic
}
```

Returns a string containing the chosen path, or `undefined` if cancelled.[4]

### IPC Integration for Renderer Process

File dialogs run in the Main process, requiring IPC for renderer access.[2][3]

**Main Process**
```javascript
const { ipcMain, dialog } = require('electron')

ipcMain.handle('show-open-dialog', async (event, options) => {
  const result = await dialog.showOpenDialog(options)
  return result
})

ipcMain.handle('show-save-dialog', async (event, options) => {
  const result = await dialog.showSaveDialog(options)
  return result
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileDialog', {
  showOpenDialog: (options) => ipcRenderer.invoke('show-open-dialog', options),
  showSaveDialog: (options) => ipcRenderer.invoke('show-save-dialog', options)
})
```

**Renderer Process**
```javascript
// Open file dialog
const openOptions = {
  properties: ['openFile', 'multiSelections'],
  filters: [
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}

window.fileDialog.showOpenDialog(openOptions).then(result => {
  if (!result.canceled) {
    console.log('Selected files:', result.filePaths)
  }
})

// Save file dialog
const saveOptions = {
  defaultPath: 'document.txt',
  filters: [
    { name: 'Text Files', extensions: ['txt'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}

window.fileDialog.showSaveDialog(saveOptions).then(result => {
  if (!result.canceled) {
    console.log('Save path:', result.filePath)
  }
})
```

This pattern maintains context isolation while enabling dialog access.[2]

### Complete File Operation Example

Combining dialogs with file system operations.[3][7]

**Main Process**
```javascript
const { app, ipcMain, dialog } = require('electron')
const fs = require('fs').promises

ipcMain.handle('open-file', async () => {
  const result = await dialog.showOpenDialog({
    properties: ['openFile'],
    filters: [
      { name: 'Text Files', extensions: ['txt'] },
      { name: 'All Files', extensions: ['*'] }
    ]
  })
  
  if (result.canceled) {
    return { canceled: true }
  }
  
  try {
    const content = await fs.readFile(result.filePaths[0], 'utf8')
    return { 
      canceled: false, 
      filePath: result.filePaths[0],
      content: content 
    }
  } catch (err) {
    return { canceled: false, error: err.message }
  }
})

ipcMain.handle('save-file', async (event, content) => {
  const result = await dialog.showSaveDialog({
    defaultPath: 'untitled.txt',
    filters: [
      { name: 'Text Files', extensions: ['txt'] },
      { name: 'All Files', extensions: ['*'] }
    ]
  })
  
  if (result.canceled) {
    return { canceled: true }
  }
  
  try {
    await fs.writeFile(result.filePath, content, 'utf8')
    return { 
      canceled: false, 
      filePath: result.filePath 
    }
  } catch (err) {
    return { canceled: false, error: err.message }
  }
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileOps', {
  openFile: () => ipcRenderer.invoke('open-file'),
  saveFile: (content) => ipcRenderer.invoke('save-file', content)
})
```

**Renderer Process**
```javascript
// Open and read file
document.getElementById('open-btn').onclick = async () => {
  const result = await window.fileOps.openFile()
  
  if (!result.canceled && !result.error) {
    document.getElementById('editor').value = result.content
    console.log('Opened:', result.filePath)
  } else if (result.error) {
    alert('Error opening file: ' + result.error)
  }
}

// Save file
document.getElementById('save-btn').onclick = async () => {
  const content = document.getElementById('editor').value
  const result = await window.fileOps.saveFile(content)
  
  if (!result.canceled && !result.error) {
    console.log('Saved to:', result.filePath)
  } else if (result.error) {
    alert('Error saving file: ' + result.error)
  }
}
```

### Additional Dialog Options

Both `showOpenDialog()` and `showSaveDialog()` support additional options.[5][4]

```javascript
dialog.showOpenDialog({
  title: 'Custom Dialog Title',
  defaultPath: app.getPath('documents'),
  buttonLabel: 'Choose This',
  message: 'Select files to import', // macOS only
  securityScopedBookmarks: true,     // macOS MAS only
  properties: ['openFile', 'multiSelections']
})
```

The `message` option displays additional text on macOS dialogs. The `securityScopedBookmarks` option is required for Mac App Store sandboxed applications.[4]

Sources
[1] dialog https://electronjs.org/docs/latest/api/dialog
[2] What's the best way to open a file dialog in a React/ ... https://www.reddit.com/r/electronjs/comments/s85pic/whats_the_best_way_to_open_a_file_dialog_in_a/
[3] Filter by extension in Electron file dialog - javascript - Stack Overflow https://stackoverflow.com/questions/48453065/filter-by-extension-in-electron-file-dialog
[4] dialog https://www.electronjs.org/docs/latest/api/dialog
[5] How to select folder or files using electron dialog? https://stackoverflow.com/questions/57867302/how-to-select-folder-or-files-using-electron-dialog
[6] dialog · Electron documentation https://tinydew4.gitbooks.io/electron/api/dialog.html
[7] Electron.NET: Save Dialog & File Writing | by Eric Anderson | ITNEXT https://itnext.io/electron-net-save-dialog-file-writing-6afa20d76c96
[8] dialog.showOpenDialog with openDirectory property ... https://github.com/electron/electron/issues/48217
[9] How to Use Dialog Windows to Save and Open Files ... https://www.youtube.com/watch?v=ItOyqhpp4K0
[10] Dialog · ElectronNET/Electron.NET Wiki - GitHub https://github.com/ElectronNET/Electron.NET/wiki/Dialog
[11] How can I display a Save As dialog in an Electron App? https://stackoverflow.com/questions/32979630/how-can-i-display-a-save-as-dialog-in-an-electron-app

---

# Window Management

## Multiple Window Creation

Electron applications can create and manage multiple BrowserWindow instances simultaneously. Each window runs independently with its own renderer process, requiring proper management and communication patterns.[1][2]

### Creating Multiple Windows

The basic approach involves instantiating new BrowserWindow objects and tracking them in a collection.[2]

**Using a Set to Track Windows**
```javascript
const { app, BrowserWindow } = require('electron')

const windows = new Set()

function createWindow() {
  const newWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })
  
  windows.add(newWindow)
  newWindow.loadFile('index.html')
  
  // Remove window from set when closed
  newWindow.on('closed', () => {
    windows.delete(newWindow)
  })
  
  return newWindow
}

app.on('ready', createWindow)

// Prevent creating new window if windows already exist
app.on('activate', () => {
  if (windows.size === 0) {
    createWindow()
  }
})
```

This pattern prevents memory leaks by removing closed windows from the tracking set.[2]

**Using an Array to Track Windows**
```javascript
const { app, BrowserWindow } = require('electron')

let windows = []

function createWindow() {
  const newWindow = new BrowserWindow({
    width: 1000,
    height: 800
  })
  
  windows.push(newWindow)
  newWindow.loadFile('app.html')
  
  newWindow.on('closed', () => {
    windows = windows.filter(w => w !== newWindow)
  })
}

app.on('ready', () => {
  // Create multiple windows on startup
  for (let i = 0; i < 3; i++) {
    createWindow()
  }
})
```

Arrays allow indexed access to specific windows but require filtering on close.[1]

### Parent-Child Window Relationships

Child windows can be created with a parent reference, making them modal or attached.[3]

**Creating Child Windows**
```javascript
const { BrowserWindow } = require('electron')

let mainWindow
let childWindow

function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600
  })
  
  mainWindow.loadFile('index.html')
}

function createChildWindow() {
  childWindow = new BrowserWindow({
    width: 400,
    height: 300,
    parent: mainWindow,      // Set parent window
    modal: true,             // Make it modal
    show: false              // Don't show until ready
  })
  
  childWindow.loadFile('child.html')
  
  childWindow.once('ready-to-show', () => {
    childWindow.show()
  })
  
  childWindow.on('closed', () => {
    childWindow = null
  })
}
```

Setting `parent` makes the child window always appear on top of the parent. The `modal` property blocks interaction with the parent while the child is open.[3]

### Window Communication via IPC

Windows communicate through the Main process using IPC.[4][3]

**Main Process**
```javascript
const { ipcMain, BrowserWindow } = require('electron')

let mainWindow
let childWindow

ipcMain.on('open-child-window', (event, data) => {
  childWindow = new BrowserWindow({
    width: 500,
    height: 400,
    parent: mainWindow,
    modal: true,
    show: false,
    webPreferences: {
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })
  
  childWindow.loadFile('child.html')
  
  // Send data to child when ready
  childWindow.once('ready-to-show', () => {
    childWindow.webContents.send('data-from-parent', data)
    childWindow.show()
  })
})

// Receive data from child and send to parent
ipcMain.on('send-to-parent', (event, data) => {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send('data-from-child', data)
  }
})
```

The `ready-to-show` event ensures the child window's renderer is ready before sending data.[3]

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('windowAPI', {
  openChildWindow: (data) => ipcRenderer.send('open-child-window', data),
  sendToParent: (data) => ipcRenderer.send('send-to-parent', data),
  onDataFromParent: (callback) => ipcRenderer.on('data-from-parent', (event, data) => callback(data)),
  onDataFromChild: (callback) => ipcRenderer.on('data-from-child', (event, data) => callback(data))
})
```

**Parent Renderer**
```javascript
// Open child window with data
document.getElementById('open-child').onclick = () => {
  const data = { message: 'Hello from parent', timestamp: Date.now() }
  window.windowAPI.openChildWindow(data)
}

// Receive data from child
window.windowAPI.onDataFromChild((data) => {
  console.log('Received from child:', data)
})
```

**Child Renderer**
```javascript
// Receive data from parent
window.windowAPI.onDataFromParent((data) => {
  console.log('Received from parent:', data)
  document.getElementById('message').textContent = data.message
})

// Send data to parent
document.getElementById('send-to-parent').onclick = () => {
  const data = { response: 'Hello from child', value: 42 }
  window.windowAPI.sendToParent(data)
}
```

This pattern maintains security through context isolation while enabling bidirectional communication.[3]

### Using window.opener for Direct Communication

Child windows opened with `window.open()` have access to `window.opener` for direct parent communication.[5]

**Parent Window**
```javascript
// Open child window
let childWindow = window.open('child.html', 'Child Window', 'width=400,height=300')

// Send message to child
function sendToChild() {
  const message = 'Data from parent'
  childWindow.postMessage(message, '*')
}

// Receive message from child
window.addEventListener('message', (event) => {
  console.log('Received from child:', event.data)
})
```

**Child Window**
```javascript
// Receive message from parent
window.addEventListener('message', (event) => {
  console.log('Received from parent:', event.data)
})

// Send message to parent
function sendToParent() {
  const message = 'Data from child'
  window.opener.postMessage(message, '*')
}
```

This approach uses the standard `postMessage` API but requires `nodeIntegration` or careful security configuration.[5]

### Managing Window State

Track window properties to restore state or coordinate behavior.[2]

```javascript
const { app, BrowserWindow } = require('electron')

class WindowManager {
  constructor() {
    this.windows = new Map()
    this.nextId = 1
  }
  
  createWindow(options = {}) {
    const id = this.nextId++
    
    const window = new BrowserWindow({
      width: 800,
      height: 600,
      ...options
    })
    
    this.windows.set(id, {
      window: window,
      id: id,
      created: Date.now()
    })
    
    window.on('closed', () => {
      this.windows.delete(id)
    })
    
    return { id, window }
  }
  
  getWindow(id) {
    return this.windows.get(id)?.window
  }
  
  getAllWindows() {
    return Array.from(this.windows.values()).map(w => w.window)
  }
  
  closeAll() {
    this.windows.forEach(({ window }) => {
      if (!window.isDestroyed()) {
        window.close()
      }
    })
  }
  
  getCount() {
    return this.windows.size
  }
}

const windowManager = new WindowManager()

app.on('ready', () => {
  windowManager.createWindow()
})
```

This class-based approach provides centralized window management with methods for creation, retrieval, and cleanup.[2]

### Using electron-window-manager Package

The `electron-window-manager` npm package simplifies multi-window management.[6][1]

**Installation**
```bash
npm install electron-window-manager --save
```

**Usage**
```javascript
const { app } = require('electron')
const windowManager = require('electron-window-manager')

app.on('ready', () => {
  // Initialize window manager
  windowManager.init()
  
  // Open windows by name
  windowManager.open('home', 'Home Window', '/home.html', null, {
    width: 800,
    height: 600
  })
  
  windowManager.open('settings', 'Settings', '/settings.html', null, {
    width: 600,
    height: 400
  })
})

// In renderer process
const windowManager = require('electron').remote.require('electron-window-manager')

// Create new window from renderer
const newWin = windowManager.createNew('details', 'Details Window')
newWin.loadURL('/details.html')
newWin.open()
```

The package provides event-based communication between windows and centralized configuration.[6][1]

### Broadcasting to All Windows

Send messages to all open windows simultaneously.[4]

```javascript
const { BrowserWindow } = require('electron')

function broadcastToAllWindows(channel, data) {
  const windows = BrowserWindow.getAllWindows()
  
  windows.forEach(window => {
    if (!window.isDestroyed()) {
      window.webContents.send(channel, data)
    }
  })
}

// Usage
ipcMain.on('broadcast-message', (event, message) => {
  broadcastToAllWindows('message-received', message)
})
```

The `BrowserWindow.getAllWindows()` method returns an array of all existing window instances.[4]

### Limiting Maximum Windows

Prevent creating too many windows with a maximum limit.[2]

```javascript
const MAX_WINDOWS = 5
const windows = new Set()

function createWindow() {
  if (windows.size >= MAX_WINDOWS) {
    console.log('Maximum window limit reached')
    return null
  }
  
  const newWindow = new BrowserWindow({
    width: 800,
    height: 600
  })
  
  windows.add(newWindow)
  newWindow.loadFile('index.html')
  
  newWindow.on('closed', () => {
    windows.delete(newWindow)
  })
  
  return newWindow
}
```

This prevents resource exhaustion from excessive window creation.[2]

Sources
[1] Electron best way for multiple windows https://stackoverflow.com/questions/39077295/electron-best-way-for-multiple-windows
[2] How to Handle Multiple Windows in an Electron App - Atomic Spin https://spin.atomicobject.com/multiple-windows-electron-app/
[3] How to send data between parent and child window in Electron https://stackoverflow.com/questions/51789711/how-to-send-data-between-parent-and-child-window-in-electron
[4] getting multiple windows in electronJS which has the same browserwindow instance to display different results https://stackoverflow.com/questions/72391588/getting-multiple-windows-in-electronjs-which-has-the-same-browserwindow-instance
[5] 初心者向き！Electronで親ウィンドウ↔子ウィンドウのデータ ... https://blog.capilano-fw.com/?p=2593
[6] electron-window-manager https://www.npmjs.com/package/electron-window-manager
[7] Creating multi-window Electron apps using React portals https://pietrasiak.com/creating-multi-window-electron-apps-using-react-portals
[8] Electron Tutorial 6: BrowserWindow https://www.youtube.com/watch?v=UG9lka9mOwM
[9] Multiple Windows https://www.reddit.com/r/electronjs/comments/mbn2u7/multiple_windows/
[10] Multiple Windows in Electron https://stackoverflow.com/questions/66947675/multiple-windows-in-electron

---

## Window Events and Lifecycle

Electron's BrowserWindow provides a comprehensive event system that tracks the complete lifecycle of application windows, from creation through destruction. Understanding these events enables developers to build responsive applications with graceful loading states, proper resource cleanup, and optimized user experiences.[1]

### Window Creation and Display Events

The `ready-to-show` event is emitted when the renderer process has rendered the page for the first time while the window remains hidden. This event is crucial for preventing visual flashes during window initialization—developers should create windows with `show: false` and call `show()` only after this event fires. The event typically occurs after `did-finish-load`, though pages with many remote resources may emit it earlier. Note that using this event implies the renderer is considered "visible" and will paint even when `show` is false, and it will never fire if `paintWhenInitiallyHidden: false` is set.[1]

The `show` and `hide` events fire when windows are shown or hidden respectively. The `show` event occurs when the window becomes visible to users, while `hide` triggers when the window is concealed through programmatic calls or user action.[2][1]

### Focus and Blur Events

The `focus` event is emitted when the window gains focus, while the `blur` event fires when the window loses focus. These events are essential for implementing features like auto-pause in media applications or tracking active window state. At the application level, the app module provides `browser-window-focus` and `browser-window-blur` events that fire when any BrowserWindow in the application gains or loses focus, passing the affected window as a parameter.[3][4][2][1]

### Window State Events

Windows can transition between various states, each triggering corresponding events. The `maximize` event fires when the window is maximized, while `unmaximize` occurs when exiting a maximized state. Similarly, `minimize` is emitted when the window is minimized, and `restore` fires when restoring from a minimized state. Fullscreen transitions trigger `enter-full-screen` and `leave-full-screen` events for native fullscreen, plus `enter-html-full-screen` and `leave-html-full-screen` for HTML API-triggered fullscreen.[2][1]

### Resize and Move Events

The `will-resize` event (macOS and Windows) fires before the window is resized, allowing prevention via `event.preventDefault()`. It includes details about the new bounds and the edge being dragged, though it only fires for manual resizing—programmatic calls to `setBounds` or `setSize` do not trigger it. The `resize` event fires after resizing completes, while `resized` (macOS and Windows) emits once when resizing finishes, including after animated `setBounds`/`setSize` calls on macOS.[1]

Similarly, `will-move` (macOS and Windows) fires before manual window movement, while `move` triggers during movement. The `moved` event (macOS and Windows) fires once when movement completes, and on macOS it's aliased to `move`.[1]

### Close and Cleanup Events

The window close lifecycle involves multiple events that provide opportunities for cleanup and user confirmation. The `close` event fires when the window is going to be closed, before the DOM's `beforeunload` and `unload` events. Calling `event.preventDefault()` cancels the close operation. Developers typically use the `beforeunload` handler in the renderer process to decide whether the window should close—returning any value other than `undefined` will cancel the close in Electron.[1]

The `closed` event fires after the window has closed completely. After receiving this event, you must remove references to the window and avoid using it further to prevent memory leaks. The `destroy()` method forces immediate closure without emitting `unload` or `beforeunload` events in the renderer, though it still guarantees the `closed` event fires.[1]

### Responsiveness Events

The `unresponsive` event fires when the web page becomes unresponsive, typically indicating the renderer process is blocked. The `responsive` event fires when an unresponsive page becomes responsive again. These events are critical for implementing user notifications or recovery mechanisms when the renderer hangs.[2][1]

### Application-Level Lifecycle Events

The app module controls the entire application lifecycle through events that manage all windows collectively. The `ready` event fires once when Electron finishes initialization and is the earliest point where BrowserWindow instances can be safely created. The `will-finish-launching` event occurs during basic startup (equivalent to `ready` on Windows and Linux, but earlier on macOS).[3][1]

The `window-all-closed` event fires when all windows have been closed. If no listener is registered, the default behavior is to quit the application, but subscribing to this event gives you control over whether to quit. On macOS, applications commonly stay active even after all windows close, so developers often check the platform before calling `app.quit()`.[3]

The `before-quit` event fires before the application starts closing windows, and `event.preventDefault()` can delay termination. The `will-quit` event occurs after all windows close and the app is about to quit—again, `event.preventDefault()` can prevent termination. Finally, the `quit` event fires when the application is actually quitting. Note that on Windows, none of these quit events fire if the app closes due to system shutdown, restart, or user logout.[3]

### Platform-Specific Events

macOS provides sheet-related events: `sheet-begin` fires when the window opens a sheet, and `sheet-end` fires when closing a sheet. The `new-window-for-tab` event fires when the native new tab button is clicked. Windows provides `session-end` and `query-session-end` events that fire when a session ends due to shutdown, restart, or logout, with the latter allowing delayed shutdown via `event.preventDefault()`.[2][1]

### Content and Title Events

The `page-title-updated` event fires when the document changes its title. It provides the new title string and an `explicitSet` boolean that indicates whether the title was explicitly set or synthesized from the file URL. Calling `event.preventDefault()` prevents the native window title from changing.[1]

Sources
[1] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[2] BrowserWindow https://electronjs.org/docs/latest/api/browser-window
[3] app https://electronjs.org/docs/latest/api/app
[4] app · Electron documentation https://tinydew4.gitbooks.io/electron/api/app.html
[5] Electron - How to know when renderer window is ready https://stackoverflow.com/questions/42284627/electron-how-to-know-when-renderer-window-is-ready
[6] app https://www.electronjs.org/docs/latest/api/app
[7] app | FAQ - GitHub Pages https://imfly.github.io/electron-docs-gitbook/en/api/app.html
[8] Electron js tutorial for beginners # Important App life cycle ... https://www.youtube.com/watch?v=ECq-mMdKepc
[9] BrowserWindow · GitBook http://electron.ebookchain.org/en/api/browser-window.html
[10] Electron - Close initial window but keep child open - Stack Overflow https://stackoverflow.com/questions/48224116/electron-close-initial-window-but-keep-child-open

---

## Parent-Child Window Relationships

Electron provides robust mechanisms for establishing hierarchical relationships between windows, enabling developers to create child windows that maintain specific positional, lifecycle, and behavioral dependencies on their parent windows. These relationships are fundamental for building complex multi-window applications with modal dialogs, preference panels, and contextual sub-windows.[1]

### Creating Child Windows

Child windows are created by passing the `parent` option to the BrowserWindow constructor, referencing an existing parent window instance. When this relationship is established, the child window will always show on top of the parent window, maintaining its z-order position regardless of user interaction. This ensures child windows remain visible and accessible even when users interact with other parts of the application.[2][1]

The parent-child relationship automatically enforces lifecycle coupling—when the parent window closes, all child windows are automatically closed as well. This automatic cleanup prevents orphaned windows and ensures proper resource management without requiring manual tracking of window relationships.[3]

### Modal Windows

Modal windows are a specialized type of child window that disable interaction with the parent window until the modal is closed. Creating a modal requires setting both the `parent` and `modal` options to `true` in the BrowserWindow constructor. Modal windows appear as contextual dropdowns or overlays within the parent window's context, making them ideal for prompting user input or displaying critical information that requires immediate attention.[4][1][3]

Platform-specific behaviors differ significantly for modal windows, particularly regarding their visual presentation and interaction model. Developers should consult platform-specific documentation and test modal behavior on target operating systems to ensure consistent user experiences.[3]

### Window Positioning and Stacking

Child windows maintain a persistent z-order relationship with their parent, always appearing on top of the parent window. When the parent window is moved, child windows do not automatically follow the parent's position—they move independently but remain above the parent in the window stacking order. This behavior allows users to position child windows freely while maintaining visual hierarchy.[2][3]

### Communication Between Parent and Child Windows

Communication between parent and child windows can be achieved through multiple mechanisms depending on the window creation method. For same-origin content created via `window.open()`, the new window is created within the same process, enabling direct access between parent and child windows. The parent can access the child window directly through the returned window object and even render to the sub-window as if it were a `div` element in the parent.[5][1]

When using `window.open()` from the renderer, the parent window can access the child via the returned reference, while the child can access the parent using `window.opener`. The `postMessage()` API enables bidirectional message passing—parents send messages using `childWindow.postMessage(message)`, while children use `window.opener.postMessage(message)` to communicate back to the parent. Both windows listen for messages using `window.addEventListener('message', handler)`.[6]

For windows created in the main process, Inter-Process Communication (IPC) provides a structured communication channel. The main process can send messages to specific windows using `webContents.send()`, while renderers communicate back using `ipcRenderer.send()`. This approach enables centralized coordination of window relationships and data flow through the main process.[7]

### Window Creation from the Renderer

Windows opened from the renderer process using `window.open()` or links with `target="_blank"` are automatically paired with BrowserWindow instances created under the hood. The `webContents.setWindowOpenHandler()` method in the main process provides control over renderer-initiated window creation, allowing customization of BrowserWindow constructor options or denial of window creation altogether.[1]

#### Basic Handler Setup

```javascript
const { BrowserWindow } = require('electron');

const mainWindow = new BrowserWindow({
  webPreferences: {
    nodeIntegration: false,
    contextIsolation: true
  }
});

mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  // Deny window creation for external URLs
  if (!url.startsWith('https://myapp.com')) {
    return { action: 'deny' };
  }
  
  // Allow window creation with custom options
  return {
    action: 'allow',
    overrideBrowserWindowOptions: {
      width: 800,
      height: 600,
      backgroundColor: '#ffffff'
    }
  };
});
```

The handler receives information about the requested window and returns an action object—`{ action: 'deny' }` cancels window creation, while `{ action: 'allow', overrideBrowserWindowOptions: { ... } }` permits creation with specified options.

#### Controlling Window Options

```javascript
// In renderer process
window.open('https://myapp.com/popup', '_blank', 'width=400,height=300');

// In main process handler
mainWindow.webContents.setWindowOpenHandler(({ url, features }) => {
  return {
    action: 'allow',
    overrideBrowserWindowOptions: {
      // These options override renderer's features string
      width: 1000,  // Overrides width=400 from renderer
      height: 800,  // Overrides height=300 from renderer
      frame: false,
      titleBarStyle: 'hidden'
    }
  };
});
```

This mechanism has final authority over window creation because it executes in the main process with full privileges, overriding any options specified in the renderer’s `window.open()` features string.[1]

#### Managing Window Lifecycle

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  if (url.includes('/standalone')) {
    // Window survives even if parent closes
    return {
      action: 'allow',
      outlivesOpener: true,
      overrideBrowserWindowOptions: {
        width: 600,
        height: 400
      }
    };
  }
  
  // Default behavior: window closes with parent
  return {
    action: 'allow',
    outlivesOpener: false  // Automatic cleanup
  };
});
```

The `outlivesOpener` option controls whether child windows persist after their opener closes. Setting `{ action: 'allow', outlivesOpener: true }` creates windows that remain open even when their parent closes, defaulting to `false` for automatic cleanup.[1]

#### Event Handling for New Windows

When a new window is created through `window.open()`, several events fire in sequence to track the window creation lifecycle. The `webContents` object emits a `'did-create-window'` event after the window has been successfully created, providing access to the new window instance.[Inference]

```javascript
mainWindow.webContents.on('did-create-window', (childWindow, details) => {
  console.log('New window created:', details.url);
  console.log('Window options:', details.options);
  
  // Access the child window
  childWindow.on('ready-to-show', () => {
    childWindow.show();
  });
});
```

The `details` object passed to the event handler contains information about how the window was created, including the target URL, referrer, and the disposition (whether it was opened as a new window, popup, or other type).[Inference]

#### Denying Window Creation

To prevent certain windows from opening, return `{ action: 'deny' }` from the `setWindowOpenHandler()` callback. This is useful for blocking popups or restricting navigation to specific domains.

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  // Block all external links
  if (!url.startsWith('https://myapp.com')) {
    return { action: 'deny' };
  }
  
  return { action: 'allow' };
});
```

#### Customizing Window Options

The `overrideBrowserWindowOptions` property allows complete customization of the child window's appearance and behavior, overriding any features specified in the renderer's `window.open()` call.

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url, frameName }) => {
  return {
    action: 'allow',
    overrideBrowserWindowOptions: {
      width: 800,
      height: 600,
      frame: true,
      webPreferences: {
        preload: path.join(__dirname, 'preload.js'),
        contextIsolation: true,
        nodeIntegration: false
      }
    }
  };
});
```

#### Handling Different Window Types

Different window dispositions require different handling strategies. The `details.disposition` property indicates how the window should be opened.[Inference]

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url, disposition }) => {
  if (disposition === 'foreground-tab') {
    // Handle links meant to open in new tab
    shell.openExternal(url);
    return { action: 'deny' };
  }
  
  if (disposition === 'new-window') {
    // Allow popup windows with custom settings
    return {
      action: 'allow',
      overrideBrowserWindowOptions: {
        modal: true,
        parent: mainWindow,
        width: 400,
        height: 300
      }
    };
  }
  
  return { action: 'allow' };
});
```

#### Child Window Lifecycle Management

The `outlivesOpener` option determines whether child windows should close automatically when their parent closes. This is particularly important for modal dialogs or dependent windows.

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  if (url.includes('/dialog')) {
    // Dialog should close with parent
    return {
      action: 'allow',
      outlivesOpener: false,
      overrideBrowserWindowOptions: {
        modal: true,
        parent: mainWindow
      }
    };
  }
  
  // Independent windows survive parent closure
  return {
    action: 'allow',
    outlivesOpener: true
  };
});
```

#### Security Considerations

[Inference] Window creation handlers should validate URLs and apply security restrictions to prevent malicious sites from opening arbitrary windows or accessing sensitive resources.

```javascript
const ALLOWED_DOMAINS = ['myapp.com', 'trusted-partner.com'];

mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  const urlObj = new URL(url);
  
  if (!ALLOWED_DOMAINS.includes(urlObj.hostname)) {
    console.warn('Blocked window creation for untrusted domain:', url);
    return { action: 'deny' };
  }
  
  return {
    action: 'allow',
    overrideBrowserWindowOptions: {
      webPreferences: {
        nodeIntegration: false,
        contextIsolation: true,
        sandbox: true
      }
    }
  };
});
```

### Security and Inheritance

Child windows inherit certain security-related settings from their parent windows. Node integration is always disabled in child windows if disabled in the parent, context isolation is always enabled in children if enabled in the parent, and JavaScript is always disabled in children if disabled in the parent. This inheritance ensures that child windows cannot bypass security restrictions established at the parent level.[1]

### `about:blank` Window Behavior

In Chromium (and therefore Electron), `about:blank` is treated as a *special internal URL*. It is not loaded through the normal browser-side navigation pipeline. Instead, the renderer creates an empty document locally. Because no browser-side navigation occurs, Chromium does not get an opportunity to re-evaluate or override security and process-level settings for the new page.

Electron’s `WebPreferences` (such as `nodeIntegration`, `contextIsolation`, `sandbox`, and `preload`) are bound to the *renderer process* at creation time. Normally, a navigation can trigger logic that decides whether a new renderer process is needed, with different preferences. That logic is skipped for `about:blank`.

An analogy: think of a renderer process as a sealed room whose rules are fixed when the door is built. A normal navigation is like deciding to move into a different room with different rules. `about:blank` is like repainting the walls of the same room—you never leave it, so the rules remain unchanged.

---

#### What “copied from the parent window” actually means

More precisely, when a child window is created and initially loads `about:blank`, Chromium reuses the same renderer process configuration as the opener (parent). Electron has no hook to apply different `WebPreferences` because:

1. No browser-side navigation occurs.
2. No new renderer process is created.
3. The existing process already has its preferences locked in.

So the child window *inherits* the effective preferences of the parent renderer, regardless of what you specified when creating the child `BrowserWindow`.

---

#### Demonstration in Electron

##### Parent window

```js
const parent = new BrowserWindow({
  webPreferences: {
    nodeIntegration: true,
    contextIsolation: false,
  }
});

parent.loadURL('about:blank');
```

##### Child window (attempting override)

```js
const child = new BrowserWindow({
  parent,
  webPreferences: {
    nodeIntegration: false,       // attempt to disable
    contextIsolation: true,        // attempt to enable
    preload: path.join(__dirname, 'preload.js')
  }
});

child.loadURL('about:blank');
```

##### Observation

Inside the child window’s DevTools console:

```js
typeof require
```

**Output:**

```
"function"
```

This confirms `nodeIntegration` is still enabled, even though the child window explicitly requested it to be disabled. The parent’s preferences remain in effect.

---

#### Why Electron cannot “fix” this

Electron sits above Chromium. The decision to skip browser-side navigation for `about:blank` is made inside Chromium itself. Electron does not receive a navigation event where it could:

* Recompute `WebPreferences`
* Swap renderer processes
* Apply a new preload or isolation model

From Electron’s perspective, nothing “navigated.”

---

#### How to force preferences to apply

To ensure that the child window gets its own `WebPreferences`, you must trigger a real navigation that Chromium treats as browser-side.

##### Correct approach

```js
child.loadURL('data:text/html,<html></html>');
```

or

```js
child.loadFile('empty.html');
```

In these cases, Chromium performs a full navigation, allowing Electron to:

* Create a new renderer process if needed
* Apply the child window’s `WebPreferences` correctly

Analogy: instead of repainting the room, you are moving into a new one, so the house rules can change.

---

#### Key takeaways

1. `about:blank` does not trigger browser-side navigation.
2. Renderer process preferences are immutable after creation.
3. Child windows loading `about:blank` effectively inherit the parent’s renderer configuration.
4. Use `data:` URLs or real files if you need different `WebPreferences`.

If you want, I can also explain how this interacts with `window.open`, `nativeWindowOpen`, or site-instance isolation in Chromium.

---

Sources
[1] BrowserWindow | Electron https://electronjs.org/docs/latest/api/browser-window
[2] BaseWindow https://www.electronjs.org/docs/latest/api/base-window
[3] Master Electron: BrowserWindow - Parent & Child Windows - YouTube https://www.youtube.com/watch?v=l75UxvoRyI4
[4] Electron browser window - Stack Overflow https://stackoverflow.com/questions/47673817/electron-browser-window
[5] Opening windows from the renderer | Electron https://electronjs.org/docs/latest/api/window-open
[6] 初心者向き！Electronで親ウィンドウ↔子ウィンドウのデータ ... https://blog.capilano-fw.com/?p=2593
[7] How to Login Electron Application with Child Windows - Steemit https://steemit.com/utopianio/@pckurdu/how-to-login-electron-application-with-child-windows
[8] Access parent window's 'window' object from child window - Electron https://stackoverflow.com/questions/56220640/access-parent-windows-window-object-from-child-window-electron
[9] Set BrowserWindow options defaults for child windows ? · Issue #2781 https://github.com/electron/electron/issues/2781
[10] Creating multi-window Electron apps using React portals https://pietrasiak.com/creating-multi-window-electron-apps-using-react-portals

---

## Window Communication

Electron provides multiple communication mechanisms to enable data exchange between the main process, renderer processes, and different windows. Inter-Process Communication (IPC) forms the foundation of this system, allowing processes with different responsibilities to coordinate effectively while maintaining security boundaries.[1]

### IPC Channel Architecture

IPC in Electron operates through developer-defined "channels" using the `ipcMain` and `ipcRenderer` modules. These channels are arbitrary—developers can name them anything—and bidirectional, allowing the same channel name to be used by both modules. The channel-based approach provides a flexible messaging system where processes communicate by passing messages through these named conduits.[2][3][4][1]

The `ipcMain` module runs exclusively in the main process and listens for events from renderer processes, while `ipcRenderer` operates in renderer processes to send events to the main process. This asymmetric design reflects Electron's process model, where the main process controls application lifecycle and native APIs, while renderers handle UI rendering and user interaction.[3][4]

### Renderer to Main Communication (One-Way)

One-way messages from renderer to main use `ipcRenderer.send()` to transmit data that is received by `ipcMain.on()`. This pattern is commonly used to call main process APIs from web contents, such as changing a window title or triggering file system operations. The renderer sends messages through a preload script that exposes a safe API via `contextBridge`, preventing direct access to IPC modules for security reasons.[1][2]

In the main process, `ipcMain.on()` registers a listener on a specific channel, receiving an `IpcMainEvent` object and any passed arguments. The event object includes a `sender` property containing the `WebContents` instance that sent the message, enabling the main process to identify which window triggered the event and respond accordingly.[1]

### Renderer to Main Communication (Two-Way)

Two-way communication uses `ipcRenderer.invoke()` paired with `ipcMain.handle()` to call main process functions and receive return values. This pattern is ideal for requesting data from the main process, such as opening native dialogs or querying system information. The `invoke()` method returns a Promise that resolves with the handler's return value, enabling seamless asynchronous communication.[2][1]

The `ipcMain.handle()` method registers an async handler function that processes requests and returns values to the renderer. Handlers can be async functions, allowing them to perform long-running operations without blocking the main process. Note that errors thrown in handlers are serialized, with only the error's `message` property transmitted to the renderer—full error objects are not preserved across the IPC boundary.[1]

Legacy alternatives exist but are discouraged—`ipcRenderer.send()` with `event.reply()` requires managing separate response channels and pairing requests with responses manually. The `ipcRenderer.sendSync()` API blocks the renderer process until a response is received, causing severe performance degradation and should be avoided entirely.[1]

### Main to Renderer Communication

Messages from the main process to renderers are sent via the `WebContents.send()` method, which targets a specific renderer process. Each BrowserWindow contains a `webContents` instance that provides the `send()` API for transmitting messages to that window's renderer. This pattern is useful for triggering UI updates from the main process, such as updating counters from menu clicks or notifying renderers of background events.[5][2][1]

In the preload script, `ipcRenderer.on()` sets up listeners for messages from the main process. The preload exposes a callback-based API through `contextBridge` that allows the renderer to register handlers without direct access to `ipcRenderer`. When exposing `ipcRenderer.on()`, developers must wrap the callback to prevent leaking the `ipcRenderer` instance through `event.sender`. The wrapper should invoke the callback with only the desired arguments, maintaining security boundaries.[1]

There is no direct equivalent to `ipcRenderer.invoke()` for main-to-renderer communication, but replies can be sent back to the main process from within `ipcRenderer.on()` callbacks using `ipcRenderer.send()`. This establishes a request-response pattern where the main process initiates communication and the renderer optionally responds.[1]

### Renderer to Renderer Communication

Direct renderer-to-renderer communication is not supported through the standard `ipcMain` and `ipcRenderer` modules. Electron provides two approaches to enable inter-renderer messaging.

The first approach uses the main process as a message broker—one renderer sends a message to the main process, which forwards it to other renderers using `webContents.send()`. This method centralizes message routing and allows the main process to filter, transform, or broadcast messages.

**Example: Main process as message broker**

```javascript
// Renderer 1 (sender)
ipcRenderer.send('message-to-other-renderer', { data: 'Hello' });

// Main process
ipcMain.on('message-to-other-renderer', (event, message) => {
  // Forward to all renderer windows or specific window
  BrowserWindow.getAllWindows().forEach(win => {
    win.webContents.send('renderer-message', message);
  });
});

// Renderer 2 (receiver)
ipcRenderer.on('renderer-message', (event, message) => {
  console.log('Received:', message.data); // "Hello"
});
```

The second approach passes `MessagePort` objects from the main process to both renderers, enabling direct communication after initial setup. This eliminates the main process bottleneck for high-frequency renderer-to-renderer messaging and supports direct peer-to-peer data transfer.

**Example: MessagePort-based direct communication**

```javascript
// Main process - create and transfer ports
const { port1, port2 } = new MessageChannelMain();
renderer1.postMessage('port', null, [port1]);
renderer2.postMessage('port', null, [port2]);

// Renderer 1
ipcRenderer.on('port', (event) => {
  const port = event.ports[0];
  port.postMessage({ data: 'Direct message' });
});

// Renderer 2
ipcRenderer.on('port', (event) => {
  const port = event.ports[0];
  port.onmessage = (event) => {
    console.log('Received directly:', event.data); // { data: 'Direct message' }
  };
});
```

For parent-child windows created via `window.open()` with same-origin content, the parent can access the child window directly through the returned reference, and the child accesses the parent via `window.opener`. The `postMessage()` API enables bidirectional messaging—parents send messages using `childWindow.postMessage(message)`, while children use `window.opener.postMessage(message)`. Both windows listen for messages using `window.addEventListener('message', handler)`.[9]

### MessagePort Communication

MessagePorts provide an alternative IPC mechanism based on the Web Channel Messaging API. Conceptually, a `MessageChannel` is like a private telephone line: it creates two endpoints (`port1` and `port2`), and anything spoken into one is heard only by the other. This allows isolated, bidirectional communication without broadcasting through global IPC channels.

A `MessageChannel` can be created in either the main process or a renderer process. Its ports can then be transferred between processes using `ipcRenderer.postMessage()` and `WebContents.postMessage()`.

#### Basic MessageChannel in a renderer

```js
// renderer.js
const channel = new MessageChannel();
const { port1, port2 } = channel;

port1.onmessage = (event) => {
  console.log('Renderer received:', event.data);
};

port2.postMessage('Hello from port2');
```

Output:

```
Renderer received: Hello from port2
```

This works entirely within one context, but the real value appears when ports are transferred across processes.

---

### Transferring MessagePorts (why `postMessage` matters)

Standard Electron IPC methods like `ipcRenderer.send()` and `ipcRenderer.invoke()` cannot transfer `MessagePort` objects. Only `postMessage()` supports transferring ownership of ports.

Think of it like sending a physical key: `send()` and `invoke()` can send copies of information, but only `postMessage()` can hand over the actual key that unlocks a private channel.

#### Renderer → Main: transferring a port

```js
// renderer.js
const channel = new MessageChannel();

channel.port1.onmessage = (e) => {
  console.log('Renderer got reply:', e.data);
};

ipcRenderer.postMessage('init-port', null, [channel.port2]);

channel.port1.postMessage('Hello main');
```

Main process:

```js
// main.js
ipcMain.on('init-port', (event) => {
  const [port] = event.ports;

  port.on('message', (e) => {
    console.log('Main received:', e.data);
    port.postMessage('Hello renderer');
  });

  port.start();
});
```

Output:

```
Main received: Hello main
Renderer got reply: Hello renderer
```

Notice that the port is transferred only once. After transfer, the sender no longer owns that port.

---

### Connecting two renderers via the main process

This is a key pattern enabled by MessagePorts. Two renderer processes that cannot directly communicate (for example, due to origin isolation) can still talk through a private channel established by the main process.

Analogy: the main process acts like a switchboard operator. It introduces two callers, hands each one the other’s phone line, and then steps away.

Main process:

```js
// main.js
ipcMain.on('connect-renderers', (event) => {
  const channel = new MessageChannelMain();

  const sender = event.sender;
  const otherWindow = getOtherWindowWebContents(); // assume this exists

  sender.postMessage('port', null, [channel.port1]);
  otherWindow.postMessage('port', null, [channel.port2]);
});
```

Renderer A:

```js
ipcRenderer.on('port', (event) => {
  const [port] = event.ports;

  port.onmessage = (e) => {
    console.log('Renderer A got:', e.data);
  };

  port.postMessage('Hello from A');
});
```

Renderer B:

```js
ipcRenderer.on('port', (event) => {
  const [port] = event.ports;

  port.onmessage = (e) => {
    console.log('Renderer B got:', e.data);
  };
});
```

Output:

```
Renderer B got: Hello from A
```

After setup, Renderer A and Renderer B communicate directly. The main process is no longer involved.

---

### MessagePortMain behavior in the main process

When a MessagePort is transferred to the main process, it becomes a `MessagePortMain`. Unlike browser MessagePorts, it uses Node.js-style events.

Instead of:

```js
port.onmessage = ...
```

You use:

```js
port.on('message', handler);
```

Another important difference is buffering. `MessagePortMain` queues messages until `start()` is called. This prevents message loss if messages arrive before listeners are registered.

```js
port.on('message', (e) => {
  console.log('Received:', e.data);
});

port.start();
```

Without `start()`, messages remain queued and are never delivered.

---

### Port closing and lifecycle

Electron extends the standard MessagePort API with a `close` event. This allows each side to detect when the other end has been closed.

Renderer:

```js
port.onclose = () => {
  console.log('Port closed');
};
```

or

```js
port.addEventListener('close', () => {
  console.log('Port closed');
});
```

Main process:

```js
port.on('close', () => {
  console.log('Port closed in main');
});
```

Ports can close explicitly or implicitly. Implicit closure can happen if a port is garbage-collected, which is similar to losing a phone line because the handset was destroyed.

### Advanced MessagePort Patterns

MessageChannels enable sophisticated communication patterns beyond basic IPC. For setting up direct renderer-to-renderer channels, the main process creates a `MessageChannelMain`, then sends each port to different renderers using `webContents.postMessage()`. After setup, renderers communicate directly via their respective ports without main process mediation.[8]

Worker processes can be implemented as hidden BrowserWindows that receive work requests via MessagePorts. The main window requests a worker channel from the main process, which creates a MessageChannel and sends one port to the worker and the other to the main window. This architecture allows CPU-intensive work to execute in a separate Blink context with full access to web APIs while maintaining direct communication with the main window.[8]

Response streams demonstrate MessagePort versatility—instead of single request-response pairs, a renderer can send a request with an attached MessagePort and receive multiple streaming responses. The main process sends multiple messages through the port and closes it when finished, signaling stream completion. This pattern enables progress updates, partial results, and event streams without creating separate IPC channels for each response.[8]

### Context Isolation and Security

When context isolation is enabled, IPC messages from the main process are delivered to the isolated world, not the main world. To communicate directly with the main world, developers can transfer a MessagePort from the main process to the isolated world via preload script, then forward it to the main world using `window.postMessage()`. The main world receives the port and can communicate directly with the main process without stepping through the isolated preload context.[8]

Security best practices mandate never exposing the full `ipcRenderer` API directly to the renderer—instead, use `contextBridge` to expose specific, validated functions. This limits the renderer's access to Electron APIs and prevents malicious code from accessing privileged functionality. When wrapping `ipcRenderer.on()`, avoid passing callbacks directly, as this leaks `ipcRenderer` through `event.sender`.[1]

### Object Serialization

Electron's IPC implementation uses the HTML Structured Clone Algorithm to serialize objects passed between processes. Only certain object types can be transferred through IPC channels—DOM objects (Element, Location, DOMMatrix), Node.js objects backed by C++ classes (process.env, Stream members), and Electron objects backed by C++ classes (WebContents, BrowserWindow, WebFrame) are not serializable with Structured Clone and cannot be sent via IPC.[1]

Sources
[1] Electron - How to know when renderer window is ready https://stackoverflow.com/questions/42284627/electron-how-to-know-when-renderer-window-is-ready
[2] Inter-Process Communication https://electronjs.org/docs/latest/tutorial/ipc
[3] Inter-Process Communication (IPC) in ElectronJS https://www.geeksforgeeks.org/node-js/inter-process-communication-ipc-in-electronjs/
[4] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[5] webContents | Electron https://electronjs.org/docs/latest/api/web-contents
[6] communication between 2 browser windows in electron https://stackoverflow.com/questions/40251411/communication-between-2-browser-windows-in-electron
[7] How to Send Messages Between Electron Windows https://javascript.plainenglish.io/messaging-between-electron-windows-a646b0af7d8d
[8] app https://www.electronjs.org/docs/latest/api/app
[9] 初心者向き！Electronで親ウィンドウ↔子ウィンドウのデータ ... https://blog.capilano-fw.com/?p=2593
[10] MessagePorts in Electron https://electronjs.org/docs/latest/tutorial/message-ports
[11] Electron JS Inter Process Communication ( IPC ) Explained https://www.youtube.com/watch?v=J60XrXk0J1o
[12] sindresorhus/electron-better-ipc https://github.com/sindresorhus/electron-better-ipc
[13] Why is my ipcMain not sending to ipcRenderer in Electron? https://stackoverflow.com/questions/55266463/why-is-my-ipcmain-not-sending-to-ipcrenderer-in-electron


---

## Frameless Windows

Frameless windows in Electron remove all operating system chrome, including toolbars, borders, title bars, and window controls, displaying only the web page content. This enables developers to create custom-styled applications with unique user interfaces that break free from standard platform conventions, ideal for media players, kiosks, or design-forward applications.[1][2]

### Creating Frameless Windows

A frameless window is created by setting the `frame` property to `false` in the BrowserWindow constructor options. This single property removes all OS-provided window chrome, leaving only the rendered web content visible. When creating frameless windows, developers should also specify a `backgroundColor` to ensure proper subpixel anti-aliasing, particularly on Windows.[2][3][4]

```javascript
const { BrowserWindow } = require('electron')

const win = new BrowserWindow({
  width: 800,
  height: 600,
  frame: false,
  backgroundColor: '#FFF'
})
```

After creating a frameless window, developers must implement custom controls for closing, minimizing, maximizing, and dragging, as these standard window operations are no longer accessible through OS-provided UI elements.[3][1]

### Title Bar Styles (macOS)

macOS provides alternative approaches to frameless windows through the `titleBarStyle` option, which offers various levels of chrome removal while preserving some native functionality. The `hidden` value hides the title bar and extends content to fill the full window size, yet still displays window controls ("traffic lights") in the top-left corner. This creates a chromeless appearance while maintaining standard macOS window controls.[5][1]

The `hiddenInset` value provides a similar effect but insets the window controls slightly from the window edge, offering a visually distinct alternative look. The `customButtonsOnHover` option uses custom-drawn close, miniaturize, and fullscreen buttons that appear when hovering in the top-left corner, resolving mouse event issues that can occur with standard toolbar buttons. This option is specifically applicable for frameless windows and requires setting `frame: false`.[1][5]

### Draggable Regions

Frameless windows are non-draggable by default since they lack the OS-provided title bar that normally handles window movement. Developers must explicitly specify draggable regions using the CSS property `-webkit-app-region: drag` to tell Electron which areas should respond to drag gestures. This property is typically applied to custom title bar elements to replicate standard window dragging behavior.[6][7][5]

Non-draggable areas within draggable regions can be excluded using `-webkit-app-region: no-drag`, which is essential for buttons and interactive elements in custom title bars. Only rectangular shapes are currently supported for draggable regions, limiting the complexity of drag-enabled areas. Note that only the `drag` and `no-drag` values are supported—other values are not valid.[7][5][6]

```css
.titlebar {
  -webkit-user-select: none;
  -webkit-app-region: drag;
}

.titlebar-button {
  -webkit-app-region: no-drag;
}
```

Draggable regions can also be set programmatically in JavaScript by setting the `webkitAppRegion` style property on DOM elements. This enables dynamic control over which regions are draggable based on application state or user preferences.[7]

### Text Selection Conflicts

In frameless windows, dragging behavior may conflict with text selection, particularly in title bar areas. When users attempt to drag the title bar, they may accidentally select text instead of moving the window. To prevent this, disable text selection within draggable areas using `-webkit-user-select: none` in CSS. This ensures dragging gestures take priority over text selection in regions designated for window movement.[6][7]

### Custom Window Controls

Since frameless windows remove native window controls, developers must implement custom buttons for closing, minimizing, maximizing, and restoring windows. These controls communicate with the main process through IPC to trigger window operations. Typical implementations create a custom title bar with styled buttons that call BrowserWindow methods like `close()`, `minimize()`, `maximize()`, and `restore()`.[4][3]

Custom controls must be marked with `-webkit-app-region: no-drag` to ensure they remain clickable within the draggable title bar region. This prevents drag gestures from interfering with button clicks. Window control implementations should also handle platform differences, as macOS users expect controls in the top-left corner while Windows users expect them in the top-right.[8][4][6][7]

### Transparent Windows

Transparent windows extend frameless window capabilities by making the entire window background transparent, allowing the desktop or underlying applications to show through. This is achieved by setting both `frame: false` and `transparent: true` in the BrowserWindow constructor. CSS backgrounds using `rgba(0, 0, 0, 0)` or similar transparent values enable selective transparency, creating non-rectangular window shapes or overlay effects.[9][1]

```javascript
const win = new BrowserWindow({
  width: 100,
  height: 100,
  frame: false,
  transparent: true,
  resizable: false
})
```

Transparent windows have several limitations. Users cannot click through transparent areas to interact with underlying applications. Transparent windows are not resizable—setting `resizable: true` may cause the window to stop functioning correctly on some platforms. The CSS `blur()` filter only affects window content and cannot blur content from other applications visible beneath the transparent window.[9]

Platform-specific limitations further constrain transparent windows. On Windows, transparent windows cannot be maximized using the system menu or by double-clicking the title bar due to technical constraints. On macOS, native window shadows are not displayed on transparent windows. Opening DevTools breaks transparency on all platforms.[9]

### Seamless Title Bar Design

Creating seamless custom title bars requires coordinating HTML structure, CSS styling, and JavaScript event handling. The typical approach involves creating a fixed-position div at the top of the page with draggable regions and embedded window control buttons. The title bar should use `position: absolute` or `fixed` with `top: 0` to anchor it at the window's top edge.[4][8]

Background color selection is important for text rendering quality—using `backgroundColor: '#FFF'` in BrowserWindow options enables subpixel anti-aliasing, improving text clarity in the custom title bar. The title bar should also set `user-select: none` to prevent accidental text selection during dragging. For cross-platform compatibility, title bars should adapt their layout based on the detected platform, positioning controls appropriately for Windows and macOS conventions.[8][4][7]

Sources
[1] Frameless Window in ElectronJS https://www.geeksforgeeks.org/javascript/frameless-window-in-electronjs/
[2] Custom Window Styles | Electron https://www.electronjs.org/pt/docs/latest/tutorial/custom-window-styles
[3] Frameless window with controls in electron (Windows) https://stackoverflow.com/questions/35876939/frameless-window-with-controls-in-electron-windows
[4] Electron seamless titlebar tutorial (Windows 10 style) - GitHub https://github.com/binaryfunt/electron-seamless-titlebar-tutorial
[5] Frameless Window | Electron https://zeke.github.io/electron.atom.io/docs/api/frameless-window/
[6] Frameless Window - Electron - W3cubDocs http://docs3.w3cub.com/electron/api/frameless-window/
[7] How do I move a frameless window in Electron without using -webkit ... https://stackoverflow.com/questions/44818508/how-do-i-move-a-frameless-window-in-electron-without-using-webkit-app-region
[8] Custom Title bar for electron app (Windows and MAC) https://ghosty.hashnode.dev/custom-title-bar-for-electron-app-windows-and-mac
[9] app · Electron documentation https://tinydew4.gitbooks.io/electron/api/app.html
[10] Electron Tutorial 7: Frameless Window https://www.youtube.com/watch?v=wiblQhPqXdY
[11] Frameless Window In Electron : Electron Tutorial #2 https://www.youtube.com/watch?v=sh-NtL89pB8


---

## Modal Windows

Modal windows in Electron are specialized child windows that disable interaction with their parent window until closed, forcing users to complete or dismiss the modal before continuing with the parent application. This pattern is essential for critical dialogs, confirmations, preference panels, and workflows requiring focused user attention.[1][2][3]

### Creating Custom Modal Windows

Custom modal windows are created by setting both the `parent` and `modal` options to `true` in the BrowserWindow constructor. The `parent` option receives a reference to the parent BrowserWindow instance, establishing the hierarchical relationship. When `modal: true` is set, the parent window becomes non-interactive while the modal is open, preventing users from clicking or typing in the parent until the modal closes.[2][3][4][1]

```javascript
const { BrowserWindow } = require('electron')

const parent = new BrowserWindow()
const modal = new BrowserWindow({ 
  parent: parent, 
  modal: true, 
  show: false 
})

modal.loadURL('https://github.com')
modal.once('ready-to-show', () => {
  modal.show()
})
```

The best practice is to create modals with `show: false`, load content, then display them after the `ready-to-show` event fires. This prevents visual flashes and ensures the modal appears fully rendered when shown to users.[1]

### Platform-Specific Behaviors

Modal window behavior differs significantly across operating systems, requiring platform-specific testing and potentially conditional code. On macOS, modals appear as sheets attached to their parent window, creating a contextual dropdown effect within the parent window's frame. On Windows and Linux, modals appear as separate windows but maintain the parent-child relationship that prevents parent interaction.[3][4]

Developers should consult platform-specific documentation when implementing modals to understand these behavioral differences and design accordingly. The visual presentation and interaction model may require adjustments to create consistent user experiences across platforms.[3]

### Modal Window Lifecycle

Modal windows maintain a tight coupling with their parent windows through automatic lifecycle management. When the parent window closes, all child windows including modals are automatically closed, ensuring proper cleanup without manual tracking. This prevents orphaned modal windows from remaining open after their parent context no longer exists.[3]

The `isModal()` method returns a boolean indicating whether the current window is a modal window, enabling conditional logic based on modal state. This is useful for implementing different behaviors in code that handles both modal and non-modal windows.[2]

### Modal Window Positioning

Modal windows always appear on top of their parent window, maintaining z-order supremacy regardless of user interactions. When the parent window moves, modal windows do not automatically follow the parent's position on Windows and Linux—they remain at their original screen coordinates while maintaining the on-top relationship. On macOS, sheet-style modals remain attached to the parent window and move with it.[2][3]

The modal window can move freely within the constraints of being above its parent, allowing users to reposition modals for better visibility or workflow organization. However, users cannot interact with the parent window to move it while the modal is open, as the modal blocks all parent input.[4][3]

### Native System Dialogs

Electron provides the `dialog` module for creating native operating system modals for common tasks like file selection, message boxes, and error displays. These native dialogs automatically handle platform-specific styling and behavior, ensuring consistent user experiences with OS conventions.[5][6][7]

The `dialog.showMessageBox()` method displays a customizable message box that can be made modal by passing a BrowserWindow instance as the first parameter. This attaches the dialog to the parent window, making it modal and blocking parent interaction. If no BrowserWindow is provided, the dialog appears as an independent window that doesn't block other windows.[6][7][8]

```javascript
const { dialog, BrowserWindow } = require('electron')

dialog.showMessageBox(mainWindow, {
  type: 'info',
  title: 'Confirmation',
  message: 'Are you sure you want to continue?',
  buttons: ['Yes', 'No']
}).then(result => {
  console.log(result.response) // Index of clicked button
})
```

The method returns a Promise that resolves with an object containing the `response` property (the index of the clicked button) and `checkboxChecked` (the state of an optional checkbox). For synchronous modal behavior, use `dialog.showMessageBoxSync()`, which blocks the process until the dialog closes and returns the button index directly.[7][8]

### Dialog Types and Options

The `type` option in `showMessageBox()` specifies the dialog's appearance, accepting values `none`, `info`, `error`, `question`, and `warning`. Each type displays a corresponding icon and may play platform-specific sounds. On Windows, `question` displays the same icon as `info` unless an explicit icon is set, while on macOS, both `warning` and `error` display the same warning icon.[6]

The `buttons` array specifies button labels, with the first button typically representing the primary action. The `defaultId` option sets which button is selected by default, while `cancelId` specifies which button is triggered when users press Escape or close the dialog. Custom icons can be provided via the `icon` option, accepting NativeImage instances.[8][7]

### File and Directory Dialogs

The `dialog.showOpenDialog()` method displays native file and directory picker dialogs that can be made modal by passing a parent window reference. The `window` argument attaches the dialog to the parent window as a modal, blocking parent interaction until the dialog closes. The method returns a Promise resolving with an object containing `canceled` (boolean), `filePaths` (array of selected paths), and `bookmarks` (security-scoped bookmark data on macOS MAS builds).[7]

```javascript
dialog.showOpenDialog(mainWindow, {
  properties: ['openFile', 'multiSelections'],
  filters: [
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}).then(result => {
  if (!result.canceled) {
    console.log(result.filePaths)
  }
})
```

The `properties` array controls dialog behavior, accepting values like `openFile`, `openDirectory`, `multiSelections`, `createDirectory`, and `showHiddenFiles`. Note that on Windows and Linux, a dialog cannot be both a file and directory selector—if both `openFile` and `openDirectory` are specified, a directory selector is shown.[7]

The `dialog.showSaveDialog()` method presents a save file dialog with similar modal capabilities. It returns a Promise with `canceled`, `filePath`, and `bookmark` properties. On macOS, the asynchronous version is recommended to avoid issues when expanding and collapsing the dialog.[7]

#### MacOS `bookmark` Option

In Electron, the `bookmarks` option of `dialog.showOpenDialog` is specific to **macOS sandboxed (MAS) builds** and is tied to Apple’s **security-scoped bookmarks** mechanism.

Background first.  
On macOS, a sandboxed app is not allowed to freely access arbitrary files. Even if the user selects a file or folder once, that permission normally lasts only for that session. Apple introduced _security-scoped bookmarks_ to let an app persist user-granted access across launches, without breaking sandbox rules.

Think of it like this analogy:  
Selecting a file in an open dialog is like being handed a temporary visitor pass to a building. A security-scoped bookmark is a notarized ID card created from that pass, which you can store and present later to regain access—without asking the guard again.

Now how this appears in Electron.

When you call:

```js
const result = await dialog.showOpenDialog({
  properties: ['openFile'],
  bookmarks: true
});
```

on **macOS MAS builds only**, Electron asks the OS to generate **bookmark data** for each selected path.

The returned result includes:

- `filePaths`: normal file system paths
- `bookmarks`: an array of opaque strings (base64-encoded bookmark data)

Those bookmark strings are what matter for long-term access.

What you do with the bookmarks:

1. Persist them somewhere safe (for example, app config or secure storage).
2. On a future app launch, resolve the bookmark back into a usable path.
3. Start a _security scope_ before accessing the file.
4. Stop the scope when done.

Conceptually:

- `filePaths` → “Where the file is”
- `bookmarks` → “Proof the user allowed access”

Why this is necessary.  
Without bookmarks, a sandboxed MAS app may:

- Fail to reopen previously selected files
- Get permission errors after restart
- Be rejected during App Store review if it works around sandbox rules

Important constraints and clarifications:

- This only works on **macOS App Store (MAS)** builds.
- On non-MAS macOS builds, `bookmarks` is ignored.
- On Windows and Linux, the option does nothing.
- The bookmark data is opaque; you must never parse or modify it.
- Access must always be user-initiated at least once (via dialog).

Common use cases:
- Remembering a user-selected workspace folder
- Persistent access to media libraries
- Reopening project files across app restarts

Mental model summary.  
`dialog.showOpenDialog` gives you permission _once_.  
`bookmarks: true` lets you save that permission in a reusable, sandbox-approved form.

### Synchronous vs Asynchronous Dialogs

In Electron, most dialog APIs are available in both asynchronous and synchronous forms. The difference is primarily about whether the main process waits (blocks) for the user to close the dialog before continuing execution.

An analogy: think of the main process as a cashier.
An asynchronous dialog is like asking a customer a question and continuing to prepare the receipt while waiting for their answer.
A synchronous dialog is like stopping everything at the counter until the customer answers.

#### Asynchronous dialogs (non-blocking)

Asynchronous dialog methods return a Promise. The main process remains responsive while the dialog is open, and the result is delivered later.

Common methods:

* `dialog.showMessageBox()`
* `dialog.showOpenDialog()`
* `dialog.showSaveDialog()`

Example: asynchronous message box.

```js
const { dialog } = require('electron');

async function showAsyncMessageBox() {
  const result = await dialog.showMessageBox({
    type: 'question',
    buttons: ['Yes', 'No'],
    title: 'Confirm',
    message: 'Do you want to continue?',
  });

  console.log(result.response); // index of the clicked button
}

showAsyncMessageBox();
```

Output (example):

```text
0
```

Here, `0` corresponds to the `"Yes"` button. While the dialog is open, the main process can still handle other events.

Asynchronous dialogs are generally preferred because they avoid freezing the app and scale better in complex applications.

#### Synchronous dialogs (blocking)

Synchronous dialog methods block the entire main process until the dialog is closed. Instead of returning a Promise, they return the result immediately.

Common methods:

* `dialog.showMessageBoxSync()`
* `dialog.showOpenDialogSync()`
* `dialog.showSaveDialogSync()`

Example: synchronous message box.

```js
const { dialog } = require('electron');

function showSyncMessageBox() {
  const response = dialog.showMessageBoxSync({
    type: 'question',
    buttons: ['Yes', 'No'],
    title: 'Confirm',
    message: 'Do you want to continue?',
  });

  console.log(response);
}

showSyncMessageBox();
```

Output (example):

```text
1
```

Here, `1` corresponds to the `"No"` button. Execution pauses at `showMessageBoxSync()` until the user responds.

Because the main process is blocked, excessive use of synchronous dialogs can degrade performance and make the app feel unresponsive.

#### When synchronous behavior is necessary

Some browser APIs, such as `alert()` and `confirm()`, are synchronous by design. They require an immediate return value to the caller.

When replacing these APIs in Electron (for example, via `setWindowOpenHandler` or custom preload logic), synchronous dialogs may be required to preserve the expected behavior.

Example: replacing `confirm()` behavior.

```js
const { dialog } = require('electron');

function confirmReplacement(message) {
  const response = dialog.showMessageBoxSync({
    type: 'question',
    buttons: ['OK', 'Cancel'],
    defaultId: 0,
    cancelId: 1,
    message,
  });

  return response === 0;
}

const confirmed = confirmReplacement('Are you sure?');
console.log(confirmed);
```

Output (example):

```text
true
```

In this case, synchronous blocking is intentional and appropriate because the caller expects a boolean result immediately.

### Error Dialogs

Electron provides a dedicated API for reporting fatal or early-stage errors: `dialog.showErrorBox(title, content)`. This method displays a modal error dialog and is intentionally simple.

An analogy: think of `showErrorBox()` as an emergency siren. It is designed to work even before the rest of the building’s systems are fully powered on.

#### Basic usage

`showErrorBox()` takes only two string arguments: a title and the message content.

```js
const { dialog } = require('electron');

dialog.showErrorBox(
  'Startup Error',
  'Failed to load configuration file.'
);
```

There is no return value, and the call is synchronous in behavior from the caller’s perspective.

#### Use before the `ready` event

Unlike most dialog APIs, `showErrorBox()` can be called safely before `app.whenReady()` or the `ready` event. This makes it suitable for reporting errors during very early startup, such as configuration parsing failures or missing critical files.

Example: early startup error handling.

```js
const { app, dialog } = require('electron');
const fs = require('fs');

try {
  fs.readFileSync('/path/to/required/config.json', 'utf8');
} catch (err) {
  dialog.showErrorBox(
    'Fatal Error',
    'The application cannot start because the configuration file is missing.'
  );
  app.exit(1);
}
```

On most platforms, this will show a native error dialog even though no windows have been created yet.

#### Platform-specific behavior on Linux

On Linux, there is an important limitation. If `showErrorBox()` is called before the app is ready, no GUI dialog is shown. Instead, the message is written to `stderr`.

Example behavior on Linux before `ready`:

```text
Fatal Error: The application cannot start because the configuration file is missing.
```

This behavior is intentional and reflects the lack of a guaranteed graphical environment at that stage of startup.

#### No parent window support

Unlike methods such as `showMessageBox()` or `showOpenDialog()`, `showErrorBox()` does not accept a `BrowserWindow` as a parent. The dialog is always independent and modal at the system level.

Example (note the absence of a window argument):

```js
dialog.showErrorBox(
  'Database Error',
  'Unable to connect to the database service.'
);
```

This design reinforces its role as a last-resort error notifier rather than a UI-integrated dialog.

#### When to use `showErrorBox()`

`showErrorBox()` is best used for:

* Fatal startup errors
* Configuration or environment issues detected before windows exist
* Situations where the app cannot continue running

For recoverable errors or user-driven flows, other dialog APIs (such as `showMessageBox()` or `showMessageBoxSync()`) are more appropriate because they provide richer options and better integration with application windows.

### Custom Modal Communication

For custom modal windows created with BrowserWindow, communication between parent and modal typically uses IPC mechanisms. The `electron-modal-window` module provides a simplified API for bidirectional messaging—parents send messages using `m.send(name, args, callback)` and listen with `m.on(name, callback)`, while modals use the same API from within their window context.[9]

#### Sending Messages from Parent to Modal

```javascript
// In parent window
const modal = new Modal('file://modal.html');

modal.send('user-data', { name: 'Alice', id: 123 }, (error, response) => {
  if (error) {
    console.error('Modal closed before responding');
  } else {
    console.log('Modal responded:', response);
  }
});
```

#### Listening for Messages in Modal

```javascript
// In modal window (modal.html)
const ipcRenderer = require('electron').ipcRenderer;

modal.on('user-data', (data, callback) => {
  console.log('Received from parent:', data);
  // Process the data
  const result = processUserData(data);
  // Send response back
  callback(null, result);
});
```

#### Bidirectional Communication

```javascript
// Parent listens for modal events
modal.on('validation-request', (data, callback) => {
  const isValid = validateInput(data);
  callback(null, { valid: isValid });
});

// Modal sends request to parent
modal.send('validation-request', { input: 'test@example.com' }, (error, response) => {
  if (!error && response.valid) {
    console.log('Validation passed');
  }
});
```

The modal's `window` property provides access to the underlying BrowserWindow instance, enabling direct manipulation of window properties and methods:

```javascript
// Access the BrowserWindow instance
modal.window.setSize(800, 600);
modal.window.center();
modal.window.on('close', () => {
  console.log('Modal is closing');
});
```

When the modal closes, any pending callbacks receive errors, allowing parent code to handle modal closure gracefully:

```javascript
modal.send('long-operation', { data: 'processing' }, (error, result) => {
  if (error) {
    console.log('Modal closed before operation completed');
    // Handle cleanup or retry logic
  } else {
    console.log('Operation completed:', result);
  }
});
```

In Electron, a “modal window” is just a child `BrowserWindow` that disables interaction with its parent until it closes. You can build this yourself with core Electron APIs or use a helper library like `electron-modal-window` for extra conveniences.[1][3]

#### Basic core‑Electron modal

In modern Electron, you create a modal window by setting both `parent` and `modal: true` when constructing a window.[3]

```js
const { BrowserWindow } = require('electron');

function openModal(parent) {
  const modal = new BrowserWindow({
    width: 400,
    height: 300,
    parent,          // parent BrowserWindow
    modal: true,     // makes it modal (disables parent)
    resizable: false,
    minimizable: false,
    maximizable: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });

  modal.loadFile('modal.html');
}
```

Key points:[3]
- `parent`: reference to the main/owner window.  
- `modal: true`: disables the parent while the child is open.  
- `win.isModal()` lets you check whether a window is modal.[3]

### Minimal example flow

1. In your main process, keep a reference to `mainWindow`.  
2. From a menu item or IPC call, invoke `openModal(mainWindow)`.  
3. `modal.html` contains your form/UI and sends data back via `ipcRenderer` or closes itself.

#### Using `electron-modal-window` (hyperdivision)

The `electron-modal-window` package wraps this pattern and provides a simple event‑based interface.[1]

Install:

```bash
npm install electron-modal-window
```

In the window that spawns the modal (renderer or preload, depending on your setup):[1]

```js
const modal = require('electron-modal-window');

const m = modal.createModal(`file://${__dirname}/modal.html`, {
  width: 300,
  height: 300,   // any BrowserWindow options
});

m.window;        // underlying BrowserWindow instance[web:1]

m.on('hello', (cb) => {
  // Fired when the modal sends 'hello'
  cb(null, 'world');  // reply to the modal
});
```

Inside `modal.html` JS:[1]

```js
const modal = require('electron-modal-window');

modal.send('hello', (err, val) => {
  if (!err) {
    console.log('they said', val); // 'world'
  }
});

// modal.window is the current BrowserWindow
console.log(modal.window.isModal()); // true (if created as modal)
```

API surface:[1]

- `modal.createModal(url, browserWindowOptions)` → returns `m`.  
  - `m.window`: underlying `BrowserWindow`.[1]
  - `m.on(name, ...args, cb)`: listen for messages from the modal.[1]
  - `m.send(name, ...args, [cb])`: send messages to the modal.[1]
- In the modal:  
  - `modal.on(name, ...args, cb)`: listen for messages from creator.[1]
  - `modal.send(name, ...args, [cb])`: message the creator.[1]
  - `modal.window`: the modal’s own `BrowserWindow`.[1]

#### Alternative: `electron-modal` (balena)

`electron-modal` is another small helper focused on opening modals from the renderer using child windows with promises and an instance interface.[7]

Example from renderer:[7]

```js
const modal = require('electron-modal');
const path = require('path');

modal.open(path.join(__dirname, 'modal.html'), {
  width: 400,
  height: 300,      // any BrowserWindow options
}, {
  title: 'electron-modal example', // arbitrary data passed to modal
}).then((instance) => {
  instance.on('increment', () => {
    console.log('Increment event received!');
  });

  instance.on('decrement', () => {
    console.log('Decrement event received!');
  });
});
```

On the modal side you can:[7]

- Call `modal.show()` / `modal.hide()` / `modal.isVisible()` to control visibility.  
- Use `modal.getData()` to access the data object passed to `open`.[7]

#### Quick comparison

| Aspect                | Core Electron modal                         | `electron-modal-window`                         | `electron-modal`                                  |
|-----------------------|---------------------------------------------|-------------------------------------------------|---------------------------------------------------|
| How it’s created      | `new BrowserWindow({ parent, modal: true })`[3] | `modal.createModal(url, options)`[1]        | `modal.open(html, options, data)`[7]          |
| Transport             | Your own `ipcMain` / `ipcRenderer` wiring   | Built‑in `on` / `send` request‑reply interface[1] | Promise that resolves to modal instance with events[7] |
| Control from modal    | Manual (IPC and `remote`/preload)           | `modal.send`, `modal.on`, `modal.window`[1] | `modal.show`, `modal.hide`, `modal.getData`[7] |
| Extra features        | Full control, but verbose                   | Simple event bridge between parent and modal[1] | Promise‑based opening, structured instance API[7] |


### Sheet Offset (macOS)

On macOS, dialogs presented as sheets attached to windows can have their vertical offset adjusted using `BaseWindow.getCurrentWindow().setSheetOffset(offset)`. This controls the distance from the window frame where sheets appear, enabling fine-tuned positioning of modal dialogs. Sheets provide a more integrated visual experience on macOS compared to separate modal windows.[7]

Sources
[1] BrowserWindow | Electron https://electronjs.org/docs/latest/api/browser-window
[2] BaseWindow https://www.electronjs.org/docs/latest/api/base-window
[3] Master Electron: BrowserWindow - Parent & Child Windows - YouTube https://www.youtube.com/watch?v=l75UxvoRyI4
[4] Electron browser window - Stack Overflow https://stackoverflow.com/questions/47673817/electron-browser-window
[5] How to Create Native OS Specific Popup Windows with Electron ... https://www.youtube.com/watch?v=q8DRUgSlwGc
[6] Custom Messages in ElectronJS https://www.geeksforgeeks.org/javascript/custom-messages-in-electronjs/
[7] app | FAQ - GitHub Pages https://imfly.github.io/electron-docs-gitbook/en/api/app.html
[8] Allow customization of default dialogs · Issue #2522 https://github.com/electron/electron/issues/2522
[9] Easily make electron modal windows - GitHub https://github.com/hyperdivision/electron-modal-window
[10] How do you create a modal in electron js? (javascript, html, css) https://stackoverflow.com/questions/60388871/how-do-you-create-a-modal-in-electron-js-javascript-html-css
[11] Creating multi-window Electron apps using React portals https://pietrasiak.com/creating-multi-window-electron-apps-using-react-portals

---

## BrowserWindow Options

The BrowserWindow constructor accepts a comprehensive options object that controls both the appearance and behavior of application windows. These options are divided into window-level properties inherited from BaseWindow and web page-specific settings configured through the `webPreferences` object.[1][2]

### Dimension and Position Options

Window dimensions are controlled through several related options that define initial size and constraints. The `width` option sets the window's width in pixels, defaulting to 800, while `height` sets the height, defaulting to 600. The `x` and `y` options position the window at specific screen coordinates—`x` controls the left offset from the screen, and `y` controls the top offset. Both `x` and `y` must be provided together; if either is omitted, the window is centered.[2][3]

The `useContentSize` option changes how dimensions are interpreted—when `true`, `width` and `height` represent the web page's size, excluding window frame dimensions. This ensures precise content sizing regardless of frame thickness. Size constraints prevent inappropriate window dimensions: `minWidth` and `minHeight` set minimum dimensions (defaulting to 0), while `maxWidth` and `maxHeight` set maximum dimensions (defaulting to no limit).[3][4][2]

The `center` option automatically positions the window in the screen center, overriding any `x` or `y` values. The `movable` option (macOS and Windows) determines whether users can drag the window to new positions, defaulting to `true`. The `resizable` option controls manual resizing capability, defaulting to `true`.[2][3]

### Window Appearance Options

The `frame` option removes all operating system chrome when set to `false`, creating frameless windows with only web content visible. The `show` option determines immediate visibility—setting it to `false` creates hidden windows that must be shown manually with `show()`, preventing visual flashes during initialization. The `backgroundColor` option sets the window's background color using hexadecimal values or color names, appearing before page load and through transparent areas.[4][2]

Transparency options enable various visual effects. The `transparent` option makes the window background fully transparent, allowing per-pixel transparency through CSS. The `opacity` option (macOS and Windows) creates uniform semi-transparency, accepting values from 0.0 (invisible) to 1.0 (opaque). Note that `transparent` and `opacity` serve different purposes—`transparent` enables selective transparency via CSS, while `opacity` applies uniform transparency to the entire window.[5][2]

The `hasShadow` option controls drop shadow display, defaulting to platform-specific behavior on macOS and Windows with no effect on Linux. The `roundedCorners` option (macOS) enables rounded window corners, defaulting to `true`. The `thickFrame` option (Windows) adds standard window frames and chrome, typically used with `frame: false` to create semi-frameless windows retaining resize handles.[6][2]

### Title Bar Customization

The `title` option sets the default window title as a string. The `titleBarStyle` option (macOS and Windows) customizes title bar appearance with several values. The `default` value shows the standard title bar, `hidden` hides the title bar while showing window controls, `hiddenInset` hides the title bar with inset controls, and `customButtonsOnHover` uses custom-drawn buttons appearing on hover.[7][2]

The `titleBarOverlay` option (Windows and macOS) enables additional title bar customization for frameless windows. When enabled with specific configurations, it allows web content to extend into the title bar area while preserving window controls. The `autoHideMenuBar` option hides the menu bar unless users press Alt, providing cleaner interfaces while maintaining menu accessibility.[2]

copy with with examples. highest header level should only be 3. context electron

Here’s a well-organized explanation of **title bar customization in Electron** with examples, following your formatting constraints.

***

### Title Bar Customization in Electron

Electron provides several options in the `BrowserWindow` constructor to control how the title bar and window frame appear. These options affect both the aesthetics and user interaction across macOS, Windows, and Linux.

#### `title`

The `title` option sets the **default window title**. This title appears in the window’s title bar (if visible) and task switchers.

**Example:**

```js
const win = new BrowserWindow({
  title: "My Electron App",
  width: 800,
  height: 600
});
```

You can later update it dynamically using:

```js
win.setTitle("New Title");
```

#### `titleBarStyle`

The `titleBarStyle` option customizes the **appearance of the title bar** on macOS and Windows. It determines the visibility and behavior of window controls (close, minimize, maximize).

Available values:

- **`default`** – Shows the standard operating system title bar.  
- **`hidden`** – Hides the title bar but keeps the window controls visible.  
- **`hiddenInset`** – Similar to `hidden`, but with controls slightly inset from the window edge.  
- **`customButtonsOnHover`** – Draws custom window buttons that only appear when hovered.

**Example:**

```js
const win = new BrowserWindow({
  width: 800,
  height: 600,
  titleBarStyle: "hiddenInset"
});
```

#### `titleBarOverlay`

Introduced to improve design flexibility, `titleBarOverlay` lets you **extend web content into the title bar area** while keeping the native window controls. It’s especially useful for creating **modern, integrated layouts**.

Only applicable on **macOS and Windows** when using a **frameless window** (`frame: false`).

**Example (Windows/macOS):**

```js
const win = new BrowserWindow({
  width: 900,
  height: 600,
  frame: false,
  titleBarOverlay: {
    color: "#2f3241",
    symbolColor: "#74b1be",
    height: 30
  }
});
```

In your web page, you can then style the top area as part of your layout, using CSS to align with the custom overlay.

#### `autoHideMenuBar`

This option **hides the menu bar** by default, showing it only when the user presses the `Alt` key (Windows/Linux). It’s great for clean, minimal UIs.

**Example:**

```js
const win = new BrowserWindow({
  width: 800,
  height: 600,
  autoHideMenuBar: true
});
```

To always show the menu again:

```js
win.setAutoHideMenuBar(false);
win.setMenuBarVisibility(true);
```

### Window Behavior Options

The `modal` option creates modal windows that disable parent window interaction until closed, requiring the `parent` option to specify the parent BrowserWindow. The `parent` option establishes parent-child relationships, causing child windows to always appear on top of parents and close automatically when parents close.[8][2]

The `alwaysOnTop` option keeps windows above all others, useful for floating palettes or overlay interfaces. The `fullscreen` option starts windows in fullscreen mode, while `kiosk` enters kiosk mode that prevents users from exiting fullscreen. The `fullscreenable` option (macOS) controls whether the maximize button enters fullscreen or merely maximizes the window.[2]

The `skipTaskbar` option (Windows and macOS) prevents windows from appearing in taskbars or docks, appropriate for utility windows. The `focusable` option determines keyboard focus capability, defaulting to `true`—non-focusable windows cannot accept keyboard input but still receive mouse events.[2]

### Advanced Window Options

The `type` option sets platform-specific window types affecting behavior and appearance. On macOS, values include `desktop`, `textured`, `panel`, and `toolbar`. On Windows, `toolbar` creates elevated-appearance windows. On Linux, values include `desktop`, `dock`, `toolbar`, `splash`, and `notification`, each producing different window manager behaviors.[2]

The `enableLargerThanScreen` option (macOS) allows windows larger than screen dimensions, useful for multi-monitor setups or zoomed content. The `acceptFirstMouse` option (macOS) determines whether clicks on inactive windows activate them and pass through to content (true) or require separate activation and interaction clicks (false).[2]

The `tabbingIdentifier` option (macOS) groups windows into native tabs—windows with matching identifiers can be merged into tab groups. The `vibrancy` option (macOS) applies blur and translucency effects with values like `appearance-based`, `light`, `dark`, `titlebar`, `selection`, `menu`, `popover`, `sidebar`, and others. The `backgroundMaterial` option (Windows 11) provides similar effects with values `auto`, `none`, `mica`, `acrylic`, and `tabbed`.[9][2]

### WebPreferences Options

The `webPreferences` object configures the renderer process and web page behavior, nested within the main options object. This critical subsection controls security, Node.js integration, preload scripts, and rendering features.[10][2]

#### Security and Sandboxing

The `nodeIntegration` option enables Node.js APIs in the renderer process, defaulting to `false` for security. The `contextIsolation` option runs Electron APIs and preload scripts in a separate JavaScript context, defaulting to `true` since it prevents loaded content from tampering with preload scripts. The `sandbox` option enables Chromium's OS-level sandbox, defaulting to `true` since Electron 20—it disables Node.js but maintains limited preload script APIs.[11][4][10]

The `webSecurity` option enforces same-origin policy when `true` (default), while `false` disables security for testing. The `allowRunningInsecureContent` option permits HTTPS pages to load HTTP resources when `true`, defaulting to `false`. These security options should be carefully configured based on content trust levels.[12][10]

#### Preload Scripts and Sessions

The `preload` option specifies an absolute file path to a script loaded before other page scripts. Preload scripts always have Node.js API access regardless of `nodeIntegration` settings, making them ideal for exposing safe APIs to renderers via `contextBridge`. The `additionalArguments` option passes strings to `process.argv` in the renderer, useful for transmitting configuration to preload scripts.[4][10][11]

#### Session and Partition Options in Electron

Electron’s `BrowserWindow` constructor supports both the `session` and `partition` options, which control how browser data (like cookies, cache, and storage) is managed. These options define **how different instances of your app isolate or share browsing data**.

##### `session` Option

The `session` option directly assigns a **specific `Session` object** from the `electron.session` module to the window. This gives you complete control over what browser storage or network configuration the window uses.  

If you provide this option, it **overrides** any `partition` setting.

**Example:**

```js
const { app, BrowserWindow, session } = require('electron');

app.whenReady().then(() => {
  // Create a custom session
  const customSession = session.fromPartition('persist:customSession');

  // Assign it explicitly to the new window
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    session: customSession
  });

  win.loadURL('https://example.com');
});
```

In this example:
- A named persistent session (`persist:customSession`) is created.
- The same session is reused for multiple windows if desired, ensuring shared cookies and cache.

##### `partition` Option

Instead of manually creating a session object, you can specify a **partition** string. Electron automatically manages sessions based on this string.

**Partition rules:**
- When the string starts with **`persist:`**, the session is **persistent**, meaning data survives app restarts.
- When it **does not** start with `persist:`, the session is **in-memory only** and will be cleared when the window closes or the app exits.

**Example (Persistent Session):**

```js
const win1 = new BrowserWindow({
  partition: 'persist:sharedSession'
});

const win2 = new BrowserWindow({
  partition: 'persist:sharedSession'
});
```

Both windows will share the same session data (cookies, local storage, etc.), much like two tabs in the same browser profile.

**Example (In-Memory Session):**

```js
const win = new BrowserWindow({
  partition: 'tempSession'
});
```

Here, the session’s data exists only while the window is open. This is ideal for private windows or temporary browsing contexts.

##### Session vs. Partition Precedence

When both `session` and `partition` options are provided:
- The **`session`** option **takes precedence**.
- The `partition` value is ignored in that case.

**Example:**

```js
const win = new BrowserWindow({
  session: session.fromPartition('persist:mainSession'),
  partition: 'persist:otherSession' // Ignored
});
```

This ensures that if you explicitly provide a `Session` object, Electron will use it—regardless of any `partition` setting.

#### Node.js and Worker Integration

Electron provides advanced configuration options that control the availability of Node.js APIs in **web workers** and **subframes (iframes and child windows)**. These features allow developers to use Node.js beyond the main renderer thread — improving flexibility and enabling more complex architectures.

***

##### `nodeIntegrationInWorker`

By default, Electron’s renderer process **does not allow Node.js APIs inside web workers** for security and isolation reasons. The `nodeIntegrationInWorker` option changes this by enabling Node.js integration within **web workers** (created via `new Worker()`).

This can be useful when you want to offload CPU-heavy or asynchronous operations to background threads while still having access to filesystem operations, `crypto`, or other Node modules.

**Default:** `false`

**Example (Node.js enabled in web worker):**

```js
// main.js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    webPreferences: {
      nodeIntegration: true,
      nodeIntegrationInWorker: true // Enable Node.js in web workers
    }
  });

  win.loadFile('index.html');
});
```

```js
// index.html
<script>
  const worker = new Worker('worker.js'); // Worker with Node access
</script>
```

```js
// worker.js
const fs = require('fs'); // Node.js API in worker
fs.writeFileSync('example.txt', 'Hello from worker!');
```

This enables the background worker to perform Node-enabled tasks, such as reading or writing files, without blocking the main renderer thread.

***

##### `nodeIntegrationInSubFrames`

The `nodeIntegrationInSubFrames` option (currently **experimental**) allows **Node.js APIs** to run in **iframes** or **child windows** created within a renderer that itself has Node integration. It also ensures the specified **preload scripts** run for each iframe.

Because this setup expands the JavaScript environment’s power considerably, it should be used cautiously — especially when loading remote or untrusted content.

**Default:** `false`

**Key behavior:**
- When enabled, **iframes and subwindows** can access Node.js modules.
- The `process.isMainFrame` property can be used inside preload scripts to **check whether code is running in the main frame or a subframe**.

**Example (Node.js in iframe):**

```js
// main.js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    webPreferences: {
      nodeIntegration: true,
      nodeIntegrationInSubFrames: true,
      preload: `${__dirname}/preload.js`
    }
  });

  win.loadFile('index.html');
});
```

```js
// preload.js
console.log('Is main frame?', process.isMainFrame); // true or false
if (!process.isMainFrame) {
  const os = require('os');
  console.log('Running in iframe, platform:', os.platform());
}
```

```html
<!-- index.html -->
<iframe src="subframe.html"></iframe>
```

```html
<!-- subframe.html -->
<script>
  // Can access Node.js here if nodeIntegrationInSubFrames is true
  const { remote } = require('electron');
  console.log('Subframe has Node.js access');
</script>
```

***

##### When to Use These Optio9ns

Use these integrations strategically:
- **`nodeIntegrationInWorker`**: Safe for internal app logic, e.g., parallelizing file parsing or data processing.
- **`nodeIntegrationInSubFrames`**: Useful when building full-fledged internal tools or dashboards with modular views—but avoid when displaying external content for security reasons.

#### Developer Tools and Debugging

The `devTools` option enables DevTools access—when `false`, `BrowserWindow.webContents.openDevTools()` cannot open DevTools. Disabling DevTools improves security for production applications by preventing code inspection.[10]

#### Content Rendering Options

The `javascript` option enables JavaScript execution, defaulting to `true`. The `images` option enables image rendering, defaulting to `true`. The `imageAnimationPolicy` option controls GIF and animated image playback with values `animate` (default), `animateOnce`, or `noAnimation`.[10]

The `webgl` option enables WebGL support, defaulting to `true`. The `plugins` option enables plugin support, defaulting to `false`. The `experimentalFeatures` option enables Chromium experimental features, defaulting to `false`.[10]

#### Zoom and Font Options

The `zoomFactor` option sets default page zoom, where `3.0` represents 300%, defaulting to `1.0`. The `defaultFontFamily` object specifies default fonts for various font families: `standard`, `serif`, `sansSerif`, `monospace`, `cursive`, `fantasy`, and `math`, each with platform-specific defaults. The `defaultFontSize` option sets base font size (defaulting to 16), while `defaultMonospaceFontSize` sets monospace font size (defaulting to 13). The `minimumFontSize` option prevents fonts smaller than specified size, defaulting to 0.[12][10]

#### Performance and Throttling

Electron provides several `webPreferences` options to optimize performance and resource usage, particularly when dealing with background windows or repeated script execution. These options help balance responsiveness with efficiency.

***

##### `backgroundThrottling`

The `backgroundThrottling` option controls whether Electron **throttles animations and timers** when a window or tab is not visible (in the background). Throttling reduces CPU and battery usage by slowing down or pausing tasks that don't need to run at full speed when hidden.

**Default:** `true`

**Behavior:**
- When `true`, background pages slow down `requestAnimationFrame`, `setTimeout`, and other timers.
- The **Page Visibility API** (`document.hidden`, `visibilitychange` event) is also affected.
- If **any `webContents` in a `BrowserWindow`** disables throttling, the entire window continues rendering frames at full speed.

**Example (Disable throttling for a real-time dashboard):**

```js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      backgroundThrottling: false // Keep animations/timers running
    }
  });

  win.loadFile('dashboard.html');
});
```

**Use case:**
- **Enable throttling (`true`)**: For static windows, documentation viewers, or forms where background activity isn't critical.
- **Disable throttling (`false`)**: For real-time dashboards, stock tickers, monitoring tools, or music visualizers that need continuous updates even when minimized.

**Example (Check visibility state in renderer):**

```html
<!-- dashboard.html -->
<script>
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      console.log('Window is now hidden');
    } else {
      console.log('Window is now visible');
    }
  });

  // Animation continues even when hidden if backgroundThrottling: false
  function animate() {
    console.log('Animating...');
    requestAnimationFrame(animate);
  }
  animate();
</script>
```

***

##### `v8CacheOptions`

The `v8CacheOptions` option controls how **V8 (Chromium's JavaScript engine) caches compiled code**. Code caching significantly improves **startup performance** by reusing previously compiled JavaScript instead of recompiling it on every launch.

**Default:** `'code'`

**Available values:**

| Value                              | Behavior                                                                             |
| ---------------------------------- | ------------------------------------------------------------------------------------ |
| `'none'`                           | Disables code caching entirely                                                       |
| `'code'`                           | Uses heuristics to cache "hot" code (frequently executed)                            |
| `'bypassHeatCheck'`                | Caches code without waiting for heuristic checks; uses lazy compilation              |
| `'bypassHeatCheckAndEagerCompile'` | Caches all code immediately with eager compilation (fastest startup after first run) |

**Example (Maximize startup speed with eager compilation):**

```js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 900,
    height: 700,
    webPreferences: {
      v8CacheOptions: 'bypassHeatCheckAndEagerCompile' // Aggressive caching
    }
  });

  win.loadFile('index.html');
});
```

**Use case:**
- **`'none'`**: For development or debugging where you want fresh compilation every time.
- **`'code'`** (default): Good balance for most apps—only caches frequently-run code.
- **`'bypassHeatCheck'`**: Speeds up apps with moderate script sizes.
- **`'bypassHeatCheckAndEagerCompile'`**: Best for large apps (IDEs, editors) with heavy JavaScript bundles that load repeatedly.

**Example (Measuring startup improvement):**

```js
// main.js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  console.time('Window Load');

  const win = new BrowserWindow({
    webPreferences: {
      v8CacheOptions: 'bypassHeatCheckAndEagerCompile'
    }
  });

  win.loadFile('index.html');

  win.webContents.on('did-finish-load', () => {
    console.timeEnd('Window Load'); // Check startup time
  });
});
```

After the first launch, subsequent startups should be noticeably faster as V8 reuses compiled code.

***

##### When to Use These Options

**Combine both for optimal performance:**

```js
const win = new BrowserWindow({
  webPreferences: {
    backgroundThrottling: false, // For always-active monitoring apps
    v8CacheOptions: 'bypassHeatCheckAndEagerCompile' // Fast cold starts
  }
});
```

This configuration suits apps that need **constant activity** (like system monitors or chat clients) and benefit from **fast launches**.

#### Platform-Specific Options

The `scrollBounce` option (macOS) enables rubber banding scroll effects, defaulting to `false`. This creates the elastic bounce effect when scrolling beyond content boundaries on macOS.[10]

#### Dialog and Navigation Options

The `safeDialogs` option enables browser-style consecutive dialog protection, preventing infinite alert loops and defaulting to `false`. The `safeDialogsMessage` option customizes the protection message, though it remains in English without localization. The `disableDialogs` option completely disables all dialogs, overriding `safeDialogs` and defaulting to `false`.[10]

The `navigateOnDragDrop` option causes dragging files or links onto pages to navigate, defaulting to `false`. The `autoplayPolicy` option controls media autoplay with values `no-user-gesture-required` (default), `user-gesture-required`, or `document-user-activation-required`.[12

copy but with more short explanations

The `autoplayPolicy` option configures how media (audio/video) is allowed to start playing in an Electron `BrowserWindow`.

- `no-user-gesture-required` (default): Media can autoplay as soon as it’s ready, without any user interaction.
- `user-gesture-required`: Media can only autoplay after a user action in the page (like a click or keypress).
- `document-user-activation-required`: Stricter; the document must have an explicit activation (such as interacting directly with the media or page) before autoplay is allowed.

#### Specialized Rendering Options

The `offscreen` option enables offscreen rendering for headless automation or custom rendering pipelines, defaulting to `false`. The `useSharedTexture` option (experimental) enables GPU-accelerated offscreen rendering via shared textures, defaulting to `false`. The `sharedTexturePixelFormat` option (experimental) specifies output format as `argb` (8-bit RGBA, SRGB SDR, default) or `rgbaf16` (16-bit float RGBA, scRGB HDR).[10]

The `enablePreferredSizeMode` option enables preferred size mode, where the window communicates the minimum size needed to display content without scrolling via `preferred-size-changed` events, defaulting to `false`.[12][10]

#### Feature Flags

The `enableBlinkFeatures` option enables specific Chromium Blink features via comma-separated strings like `CSSVariables,KeyboardEventKey`. The `disableBlinkFeatures` option disables features using the same format. The full list of supported features is found in Chromium's RuntimeEnabledFeatures.json5 file.[13][10]

#### Accessibility and Miscellaneous

The `accessibleTitle` option provides alternative window titles for accessibility tools like screen readers, invisible to regular users. The `spellcheck` option enables the built-in spellchecker, defaulting to `true`. The `enableWebSQL` option enables the deprecated WebSQL API, defaulting to `true`.[10]

The `textAreasAreResizable` option makes textarea elements user-resizable, defaulting to `true`. The `disableHtmlFullscreenWindowResize` option prevents window resizing when entering HTML fullscreen, defaulting to `false`.[10]

The `webviewTag` option enables the `<webview>` tag for embedding isolated guest content, defaulting to `false`. When enabled, preload scripts in webviews have Node.js integration, so developers must validate webview settings using the `will-attach-webview` event to prevent malicious preload scripts.[10]

#### Rendering Initialization

The `paintWhenInitiallyHidden` option determines whether the renderer should be active when created with `show: false`, defaulting to `true`. Setting it to `false` ensures `document.visibilityState` works correctly on first load with hidden windows but prevents the `ready-to-show` event from firing. This option balances correct visibility state reporting against event-driven initialization patterns.[2]

Sources
[1] BrowserWindow https://electronjs.org/docs/latest/api/browser-window
[2] Electron js tutorial for beginners # Important App life cycle ... https://www.youtube.com/watch?v=ECq-mMdKepc
[3] BaseWindowConstructorOptions Object - Electron https://electronjs.org/docs/latest/api/structures/base-window-options
[4] BrowserWindow | FAQ https://imfly.github.io/electron-docs-gitbook/en/api/browser-window.html
[5] app · Electron documentation https://tinydew4.gitbooks.io/electron/api/app.html
[6] [Bug]: window transparency not respected (black/gray ... https://github.com/electron/electron/issues/40515
[7] Frameless Window | Electron https://zeke.github.io/electron.atom.io/docs/api/frameless-window/
[8] Electron browser window - Stack Overflow https://stackoverflow.com/questions/47673817/electron-browser-window
[9] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[10] BrowserWindow · GitBook http://electron.ebookchain.org/en/api/browser-window.html
[11] Electron Plugin https://app-config.dev/guide/electron.html
[12] WebPreferences Object https://electronjs.org/docs/latest/api/structures/web-preferences
[13] BrowserWindowConstructorOptio... https://electronjs.org/docs/latest/api/structures/browser-window-options
[14] Electron.js 11.0.4 - BrowserWindow is not a contructor https://stackoverflow.com/questions/65203027/electron-js-11-0-4-browserwindow-is-not-a-contructor
[15] Add an option to BrowserWindow constructor to set global ... https://github.com/electron/electron/issues/6504
[16] If I run my app in frameless mode, the window is 2 pixels larger than ... https://www.reddit.com/r/electronjs/comments/ignx2h/if_i_run_my_app_in_frameless_mode_the_window_is_2/

---


# Debugging & Development Tools
U
## Renderer Process Debugging (DevTools)

Chromium Developer Tools (DevTools) provide comprehensive debugging capabilities for Electron's renderer processes, offering the same powerful debugging environment available in Chrome for web development. DevTools can inspect and debug all renderer process instances including BrowserWindow, BrowserView, and WebView.[1][2][3]

### Opening DevTools Programmatically

DevTools are accessed programmatically by calling the `openDevTools()` method on the `webContents` property of BrowserWindow instances. This method can be invoked at any point during the window lifecycle, typically in the main process after window creation.[2][3]

```javascript
const { BrowserWindow } = require('electron')

const win = new BrowserWindow()
win.webContents.openDevTools()
```

The `openDevTools()` method opens DevTools in their default configuration, attaching them to the BrowserWindow. For applications that need DevTools available during development but hidden in production, call this method conditionally based on environment checks.[3][2]

### DevTools Configuration Options

The `openDevTools()` method accepts an options object that controls DevTools presentation and behavior. The `mode` option determines how DevTools appear, accepting values `right`, `bottom`, `undocked`, and `detach`. The `right` value docks DevTools to the right side of the window, `bottom` docks them below the content, `undocked` opens them in a separate window, and `detach` opens them in a detachable window.[4][5]

The `activate` option controls whether DevTools receive focus when opened, defaulting to `true`. Setting it to `false` opens DevTools without shifting focus from the main window content, useful for debugging scenarios where focus state affects behavior. The `title` option sets a custom DevTools window title when opened in detached mode.[5]

```javascript
win.webContents.openDevTools({ 
  mode: 'detach',
  activate: false,
  title: 'Debugging Main Window'
})
```

### Keyboard Shortcuts and User Access

DevTools can be opened through keyboard shortcuts in addition to programmatic control. The standard shortcuts are F12, Ctrl+Shift+I (Windows/Linux), or Cmd+Option+I (macOS). These shortcuts work automatically in development builds but can be disabled in production by preventing the corresponding menu items or key events.[6]

Custom keyboard shortcuts can be implemented by listening for key events in the renderer and calling `openDevTools()` through IPC communication with the main process. Right-clicking in the renderer also provides a context menu option to "Inspect" or "Inspect Element," opening DevTools focused on the selected element.[2][6]

```javascript
document.addEventListener('keyup', ({ key, ctrlKey, shiftKey }) => {
  if ((key === 'F12') || (ctrlKey && shiftKey && key === 'I')) {
    require('electron').remote.getCurrentWebContents().openDevTools()
  }
})
```

### Closing and Controlling DevTools

DevTools can be closed programmatically using `webContents.closeDevTools()`, which removes the DevTools panel from view. The `isDevToolsOpened()` method returns a boolean indicating whether DevTools are currently open for a given webContents instance. The `isDevToolsFocused()` method checks whether DevTools have keyboard focus.[5]

The `toggleDevTools()` method provides a convenient way to open or close DevTools based on their current state. This method is ideal for implementing toggle shortcuts that switch DevTools visibility with a single key press.[5]

### DevTools Events

#### DevTools lifecycle events

These events tell you _when DevTools change state_.

##### `devtools-opened`

Emitted when DevTools are opened.

Common uses:  
• Resize or reposition windows  
• Disable certain UI features  
• Log debugging activity

Example:

```js
mainWindow.webContents.on('devtools-opened', () => {
  console.log('DevTools opened');
});
```

Output:

```
DevTools opened
```

---

##### `devtools-closed`

Emitted when DevTools are closed.

Example:

```js
mainWindow.webContents.on('devtools-closed', () => {
  console.log('DevTools closed');
});
```

Output:

```
DevTools closed
```

---

##### `devtools-focused`

Emitted when DevTools gain focus (for example, when the user clicks inside them).

This is useful if you want to know whether keyboard input is going to the page or to DevTools.

Example:

```js
mainWindow.webContents.on('devtools-focused', () => {
  console.log('DevTools focused');
});
```

Output:

```
DevTools focused
```

---

#### DevTools interaction events

These events fire when the user performs actions _inside_ DevTools.

##### `devtools-reload-page`

Emitted when the reload button in DevTools is pressed.

Important distinction:  
This is **not** the same as `did-navigate` or a normal page reload. It specifically means the reload came from DevTools.

Example:

```js
mainWindow.webContents.on('devtools-reload-page', () => {
  console.log('Page reloaded from DevTools');
});
```

Output:

```
Page reloaded from DevTools
```

---

##### `devtools-open-url`

Emitted when a link inside DevTools is opened (for example, “Open in new tab”).

Electron passes the URL as an argument.

Example:

```js
mainWindow.webContents.on('devtools-open-url', (event, url) => {
  console.log('DevTools opened URL:', url);
});
```

Output:

```
DevTools opened URL: https://example.com/script.js
```

This is often used to:  
• Open links in an external browser  
• Prevent navigation to certain URLs  
• Log inspection activity

Example with external browser:

```js
const { shell } = require('electron');

mainWindow.webContents.on('devtools-open-url', (event, url) => {
  event.preventDefault();
  shell.openExternal(url);
});
```

---

##### `devtools-search-query`

Emitted when “Search” is used from the DevTools context menu.

Electron passes the selected search query.

Example:

```js
mainWindow.webContents.on('devtools-search-query', (event, query) => {
  console.log('DevTools search query:', query);
});
```

Output:

```
DevTools search query: ipcRenderer.send
```

This is useful for:  
• Auditing debugging behavior  
• Teaching tools or tutorials  
• Custom analytics in internal apps

---

#### Practical summary

Think of DevTools events as **signals from the debugger itself**.

• Lifecycle events (`opened`, `closed`, `focused`) tell you _state changes_  
• Interaction events (`reload-page`, `open-url`, `search-query`) tell you _what the developer is doing_

Together, they allow you to adapt UI behavior, enforce policies, or observe debugging sessions without modifying the page code itself.

### Disabling DevTools

DevTools access can be completely disabled by setting `webPreferences.devTools: false` in the BrowserWindow constructor options. When disabled, `openDevTools()` has no effect and keyboard shortcuts do not open DevTools. This security measure prevents users from inspecting production application code and is recommended for deployed applications.[8][7]

Production builds should disable DevTools using the `app.isPackaged` flag to differentiate between development and production environments. This ensures DevTools remain available during development while being inaccessible in distributed applications.[7]

```javascript
const win = new BrowserWindow({
  webPreferences: {
    devTools: !app.isPackaged // Disable in packaged/production builds
  }
})
```

### Chrome DevTools Protocol Integration

Advanced debugging scenarios can leverage the Chrome DevTools Protocol (CDP) for programmatic control over debugging capabilities. The `webContents.debugger` API provides access to CDP commands across various domains like Runtime, DOM, Network, and Performance.

#### Attaching the Debugger

The debugger must be attached before sending commands using `webContents.debugger.attach(protocolVersion)`. The protocol version string (like `'1.3'`) specifies which CDP version to use.

```javascript
const { BrowserWindow } = require('electron');

const win = new BrowserWindow({ width: 800, height: 600 });

try {
  win.webContents.debugger.attach('1.3');
  console.log('Debugger attached successfully');
} catch (err) {
  console.log('Debugger attach failed:', err);
}
```

**[Inference]** Attaching may fail if another debugger is already attached or if the webContents is not ready.

#### Sending CDP Commands

Commands are sent via `debugger.sendCommand(method, commandParams)`, which returns a Promise resolving with the command response. The method string follows CDP naming conventions (Domain.method).

```javascript
// Enable network monitoring
win.webContents.debugger.sendCommand('Network.enable');

// Get cookies for a URL
win.webContents.debugger.sendCommand('Network.getCookies', {
  urls: ['https://example.com']
}).then(({ cookies }) => {
  console.log('Cookies:', cookies);
});

// Take a screenshot
win.webContents.debugger.sendCommand('Page.captureScreenshot', {
  format: 'png'
}).then(({ data }) => {
  require('fs').writeFileSync('screenshot.png', data, 'base64');
});
```

#### Listening to Debugger Events

The debugger emits events when messages are received or when it detaches. You can monitor specific CDP events to track browser activity.

```javascript
// Listen for detach events
win.webContents.debugger.on('detach', (event, reason) => {
  console.log('Debugger detached due to:', reason);
});

// Listen for CDP protocol messages
win.webContents.debugger.on('message', (event, method, params) => {
  if (method === 'Network.requestWillBeSent') {
    console.log('Network request:', params.request.url);
  }
  
  if (method === 'Console.messageAdded') {
    console.log('Console message:', params.message.text);
  }
});

// Enable console domain to receive console messages
win.webContents.debugger.sendCommand('Console.enable');
```

#### Common CDP Domains and Use Cases

##### Network Domain

Monitor and control network activity:

```javascript
// Enable network tracking
await win.webContents.debugger.sendCommand('Network.enable');

// Set custom headers
await win.webContents.debugger.sendCommand('Network.setExtraHTTPHeaders', {
  headers: {
    'X-Custom-Header': 'value'
  }
});

// Emulate network conditions
await win.webContents.debugger.sendCommand('Network.emulateNetworkConditions', {
  offline: false,
  latency: 100, // ms
  downloadThroughput: 750 * 1024 / 8, // 750kb/s
  uploadThroughput: 250 * 1024 / 8
});
```

##### Runtime Domain

Execute JavaScript and interact with the runtime:

```javascript
// Evaluate JavaScript expression
const result = await win.webContents.debugger.sendCommand('Runtime.evaluate', {
  expression: 'document.title',
  returnByValue: true
});
console.log('Page title:', result.result.value);

// Call a function with arguments
await win.webContents.debugger.sendCommand('Runtime.callFunctionOn', {
  functionDeclaration: 'function(x, y) { return x + y; }',
  arguments: [{ value: 5 }, { value: 3 }],
  returnByValue: true
});
```

##### Page Domain

Control page behavior and capture screenshots:

```javascript
// Navigate to a URL
await win.webContents.debugger.sendCommand('Page.navigate', {
  url: 'https://example.com'
});

// Get page layout metrics
const metrics = await win.webContents.debugger.sendCommand('Page.getLayoutMetrics');
console.log('Page dimensions:', metrics.contentSize);

// Print to PDF
const { data } = await win.webContents.debugger.sendCommand('Page.printToPDF', {
  landscape: false,
  displayHeaderFooter: false,
  printBackground: true
});
require('fs').writeFileSync('page.pdf', data, 'base64');
```

##### Performance Domain

Monitor performance metrics:

```javascript
// Enable performance monitoring
await win.webContents.debugger.sendCommand('Performance.enable');

// Get performance metrics
const { metrics } = await win.webContents.debugger.sendCommand('Performance.getMetrics');
metrics.forEach(metric => {
  console.log(`${metric.name}: ${metric.value}`);
});
```

#### Target-Specific Debugging

The `webContents.fromDevToolsTargetId(targetId)` method retrieves a WebContents instance associated with a specific Chrome DevTools Protocol target. This enables debugging of specific targets when multiple debugging sessions are active.

```javascript
const { webContents } = require('electron');

// Get all targets
win.webContents.debugger.sendCommand('Target.getTargets').then(({ targetInfos }) => {
  targetInfos.forEach(target => {
    console.log('Target:', target.targetId, target.type, target.url);
    
    // Get WebContents for a specific target
    const targetWebContents = webContents.fromDevToolsTargetId(target.targetId);
    if (targetWebContents) {
      console.log('Found WebContents for target:', target.targetId);
    }
  });
});
```

#### Complete Debugging Example

```javascript
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  // Attach debugger
  try {
    win.webContents.debugger.attach('1.3');
  } catch (err) {
    console.error('Failed to attach debugger:', err);
    return;
  }

  // Handle detach
  win.webContents.debugger.on('detach', (event, reason) => {
    console.log('Debugger detached:', reason);
  });

  // Monitor network requests
  win.webContents.debugger.on('message', (event, method, params) => {
    if (method === 'Network.responseReceived') {
      console.log('Response:', params.response.status, params.response.url);
    }
  });

  // Enable monitoring domains
  async function setupDebugging() {
    await win.webContents.debugger.sendCommand('Network.enable');
    await win.webContents.debugger.sendCommand('Console.enable');
    await win.webContents.debugger.sendCommand('Performance.enable');
  }

  setupDebugging().then(() => {
    win.loadURL('https://example.com');
  });

  // Detach when window closes
  win.on('closed', () => {
    if (win.webContents.debugger.isAttached()) {
      win.webContents.debugger.detach();
    }
  });
});
```

#### Error Handling

```javascript
try {
  await win.webContents.debugger.sendCommand('Network.enable');
} catch (error) {
  console.error('CDP command failed:', error.message);
}

// Check if debugger is attached before sending commands
if (win.webContents.debugger.isAttached()) {
  await win.webContents.debugger.sendCommand('Console.enable');
}
```

**Note:** The Chrome DevTools Protocol documentation provides the full list of available domains and commands. **[Unverified]** The specific CDP version support may vary between Electron versions.

### Development Tools Packages

The `electron-debug` npm package simplifies DevTools integration during development. Installing it with `npm install electron-debug --save-dev` and requiring it in the main process with `require('electron-debug')()` automatically adds DevTools keyboard shortcuts and other debugging conveniences.[2][7]

This package enables features like right-click context menu inspection, automatic DevTools opening on errors, and enhanced debugging shortcuts with minimal configuration. It's particularly useful for rapid development workflows where consistent DevTools access across all windows is desired.[7]

### Debugging Renderer Crashes

When renderer processes crash, DevTools can help diagnose the root cause through crash event handlers. Listening for the `crashed` event on webContents captures crash occurrences and enables logging or automated error reporting.[7]

```javascript
win.webContents.on('crashed', (event, killed) => {
  console.log('Renderer crashed:', { killed })
  // Log crash details, restart renderer, or notify user
})
```

Memory leaks and performance issues are identified using DevTools' Memory and Performance panels. Taking heap snapshots in the Memory tab reveals leaking objects, while the Performance panel profiles CPU usage and identifies bottlenecks. These tools are identical to those in Chrome, with extensive documentation from Google available for reference.[3][7]

### V8 Crash Debugging

If the V8 JavaScript engine crashes, DevTools display the message "DevTools was disconnected from the page. Once page is reloaded, DevTools will automatically reconnect.". Chromium logs can be enabled via the `ELECTRON_ENABLE_LOGGING` environment variable or the `--enable-logging` command line flag to capture detailed crash information.[3]

These logs provide insights into V8 crashes, memory corruption, and other low-level issues that may not be visible through standard DevTools inspection. Analyzing Chromium logs helps diagnose crashes that occur during JavaScript execution or garbage collection.[3]

### Remote Debugging

For debugging renderer processes in production or remote environments, Electron supports remote debugging through CDP. Starting Electron with debugging flags enables remote DevTools connections from Chrome or other CDP-compatible tools. This allows developers to debug deployed applications without modifying the application code.[9]

The `electron://` protocol scheme can be used to list debugging targets and inspect specific processes via CDP. This advanced technique enables monitoring and controlling multiple Electron processes simultaneously through standardized debugging APIs.[9]

### Visual Studio Code Integration

VS Code provides integrated debugging for Electron renderer processes through its built-in debugger. Creating a `.vscode/launch.json` configuration with appropriate settings enables breakpoint debugging directly in the editor. The configuration should specify Node.js as the runtime type and point to the Electron executable.[10][11][7]

```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Renderer Process",
  "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron",
  "program": "${workspaceFolder}/main.js",
  "outputCapture": "std"
}
```

This integration combines DevTools functionality with VS Code's debugging interface, providing features like variable inspection, call stack navigation, and inline value display during debugging sessions.[11][10]

Sources
[1] Application Debugging | Electron https://electronjs.org/docs/latest/tutorial/application-debugging
[2] Tips and Tricks for Debugging Electron Applications - SitePoint https://www.sitepoint.com/debugging-electron-application/
[3] Electron - Close initial window but keep child open - Stack Overflow https://stackoverflow.com/questions/48224116/electron-close-initial-window-but-keep-child-open
[4] webContents https://electronjs.org/docs/latest/api/web-contents
[5] Master Electron: BrowserWindow - Parent & Child Windows - YouTube https://www.youtube.com/watch?v=l75UxvoRyI4
[6] How to include Chrome DevTools in Electron? https://stackoverflow.com/questions/30294600/how-to-include-chrome-devtools-in-electron
[7] Debugging and Troubleshooting Common Electron Issues https://blog.openreplay.com/debugging-troubleshooting-electron-issues/
[8] BrowserWindow · GitBook http://electron.ebookchain.org/en/api/browser-window.html
[9] Electron Debug MCP Server https://github.com/amafjarkasi/electron-mcp-server
[10] Debugging Electron renderer process with VSCode - Stack Overflow https://stackoverflow.com/questions/52844870/debugging-electron-renderer-process-with-vscode
[11] A guide on how to debug an Electron app. - GitHub https://github.com/DrifterAtSea/debugging-electron
[12] Debugging the Main Process | Electron https://electronjs.org/docs/latest/tutorial/debugging-main-process
[13] Debugging Magic with Vue Devtools https://vueschool.io/articles/vuejs-tutorials/debugging-magic-with-vue-devtools/

---

## Main Process Debugging

The main process in Electron cannot be debugged using DevTools in BrowserWindows, as those tools only debug JavaScript executed within renderer windows. Debugging main process code requires external debuggers that connect via the V8 Inspector Protocol, launched using specific command line switches.[1][2]

### Command Line Switches for Debugging

The `--inspect` flag enables debugging by making Electron listen for V8 inspector protocol messages on a specified port. The default port is 9229, though this can be customized by appending the port number to the flag.[2][3]

```bash
electron --inspect=9229 your/app
```

This command starts Electron with debugging enabled, allowing external debuggers to connect on port 9229. The application runs normally while the debugger waits for connections.[2]

The `--inspect-brk` flag works identically to `--inspect` but pauses execution on the first line of JavaScript code before running the application. This enables developers to set breakpoints before application initialization, ensuring early-stage code can be debugged effectively.[3][2]

```bash
electron --inspect-brk=9229 your/app
```

This pause-on-start behavior is essential for debugging issues that occur during app startup, window creation, or the `ready` event handler.[2]

### Chrome DevTools for Main Process

Chrome's built-in debugger can connect to Electron's main process through the `chrome://inspect` interface. After launching Electron with `--inspect`, opening `chrome://inspect` in Chrome displays all available Node.js debugging targets, including the running Electron app. Clicking "inspect" on the Electron target opens a dedicated DevTools window connected to the main process.[1][2]

This DevTools instance provides full debugging capabilities including breakpoints, stepping through code, variable inspection, console access, and profiling. The interface is identical to standard Chrome DevTools but targets the main process instead of a web page.[2]

### Visual Studio Code Debugging

VS Code provides integrated main process debugging through its built-in Node.js debugger. Configuration requires creating a `.vscode/launch.json` file with settings that specify Electron as the runtime executable.[4][5][2]

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Main Process",
      "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron",
      "program": "${workspaceFolder}/main.js",
      "outputCapture": "std"
    }
  ]
}
```

The `runtimeExecutable` property points to the local Electron binary installed via npm, while `program` specifies the main process entry point. The `outputCapture: "std"` setting captures stdout and stderr, displaying native module errors and console output in the VS Code debug console.[5][4]

On Windows, the `runtimeExecutable` path should reference `electron.cmd` instead of the Unix-style binary.[5]

```json
{
  "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron.cmd"
}
```

After configuring launch.json, developers can start debugging by selecting "Debug Main Process" from the Run and Debug panel or pressing F5. VS Code attaches to the main process, enabling breakpoint placement in main.js and related files.[6][4][5][2]

### Debugging Both Main and Renderer Processes

Simultaneous debugging of both main and renderer processes requires multiple debugger configurations. The main process debugger launches Electron with the `--remote-debugging-port=9222` argument, enabling renderer process attachment.[5]

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Main Process",
      "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron",
      "program": "${workspaceFolder}/index.js",
      "runtimeArgs": [
        ".",
        "--remote-debugging-port=9222"
      ]
    },
    {
      "type": "chrome",
      "request": "attach",
      "name": "Attach to Renderer Process",
      "port": 9222,
      "webRoot": "${workspaceFolder}/html"
    }
  ]
}
```

The workflow involves first launching the "Debug Main Process" configuration, then starting the "Attach to Renderer Process" configuration to connect to the renderer. This provides simultaneous debugging access to both processes through VS Code's unified interface.[5]

### Troubleshooting VS Code Debugging

Main process debugging in VS Code can encounter configuration issues, particularly with Electron version compatibility. If the application hangs indefinitely during debugging or fails to start, check that the `runtimeExecutable` path correctly points to the Electron binary.[7][4]

The `outputCapture: "std"` setting is critical for diagnosing startup issues—without it, native module errors and early console output may not appear in the debug console. Setting breakpoints in lifecycle events like `app.on('ready')` or `app.on('before-quit')` helps identify where execution stops during problematic startups.[4]

Some Electron versions require the `"protocol": "legacy"` setting in launch.json for proper debugging attachment. This compatibility flag adjusts how VS Code communicates with the V8 debugger protocol.[5]

### Production Environment Debugging

Debugging main process issues in production builds requires special consideration since packaged applications typically don't include development tools. Running packaged executables with the `--inspect` or `--remote-debugging-port` flags enables debugging of deployed applications.[8]

```bash
./MyApp.exe --remote-debugging-port=8315
```

This command launches the packaged app with debugging enabled on port 8315, allowing Chrome DevTools to connect for remote inspection. Security concerns arise with production debugging—ensure debugging ports are never exposed publicly and are only used in controlled environments.[8]

### Logging and Early Error Detection

When main process crashes occur before debuggers can attach, enabling comprehensive logging is essential. The `--enable-logging` command line flag or the `ELECTRON_ENABLE_LOGGING` environment variable captures Chromium logs that reveal early initialization errors.[9][4]

Adding `console.log` statements at the beginning of the main process file verifies that execution reaches expected code paths. These logs appear in the terminal when running Electron from the command line or in the VS Code debug console when `outputCapture: "std"` is configured.[4]

### Monitoring Main Process Memory

Memory issues in the main process manifest differently than renderer process leaks, often involving native modules rather than JavaScript objects. Tracking both RSS (Resident Set Size) and heap memory distinguishes native memory issues from JavaScript memory leaks.[4]

If RSS grows while heap memory remains stable, native modules or buffers are likely the cause. IPC listener leaks are common in main process memory issues—unregistered listeners accumulate over application lifetime, consuming memory and potentially causing crashes. The process module provides memory usage information through `process.memoryUsage()`, enabling periodic memory monitoring.[4]

### electron-inspector Package

The `electron-inspector` package wraps `node-inspector` to simplify main process debugging setup. This tool automatically configures `node-inspector` for the specific Electron version, reducing setup complexity.[10]

Installation adds an `inspect-main` script to package.json that launches `electron-inspector`.[10]

```json
{
  "scripts": {
    "inspect-main": "electron-inspector"
  }
}
```

Running `npm run inspect-main` starts Electron in debug mode and prints a URL like `http://127.0.0.1:8080/?port=5858` for browser-based debugging. This approach provides a node-inspector UI for main process debugging without manual configuration.[10]

The `--debug-port` flag specifies which port Electron's debug interface is running on, defaulting to 5858. The `--electron` flag specifies the Electron executable path when using non-standard installations.[10]

### electron-debug Package Integration

The `electron-debug` package simplifies development by automatically configuring debugging conveniences. Installing it with `npm install electron-debug --save-dev` and requiring it in main.js with `require('electron-debug')()` enables features like keyboard shortcuts and automatic DevTools opening.[11][4]

While primarily focused on renderer debugging, this package provides context menu inspection and error handling that assists with diagnosing main process issues indirectly through renderer feedback.[11][4]

### Breakpoint Strategies

Effective main process debugging relies on strategic breakpoint placement. Setting breakpoints in application lifecycle events captures critical transitions: `app.on('ready')` for initialization, `app.on('window-all-closed')` for shutdown, `app.on('before-quit')` for cleanup, and IPC event handlers for inter-process communication.[4]

Breaking on uncaught exceptions using debugger configuration or try-catch blocks reveals error sources that would otherwise crash silently. Conditional breakpoints filter high-frequency events, only pausing when specific conditions are met.[4]

### Minimal Reproduction for Issue Reporting

When main process bugs cannot be resolved locally, creating minimal reproductions isolates the problem for issue reporting. Remove all non-essential code to create the smallest possible application that demonstrates the issue. Test with vanilla Electron by creating a minimal-repro application without frameworks or libraries, verifying whether the issue is Electron-specific or related to application code.[4]

Documentation should include exact RSS and heap measurements, Electron version, Node.js version, operating system details, and crash dumps if available. This information enables maintainers to reproduce and diagnose issues efficiently.[4]

Sources
[1] Debugging the Main Process | Electron https://electronjs.org/docs/latest/tutorial/debugging-main-process
[2] Access parent window's 'window' object from child window - Electron https://stackoverflow.com/questions/56220640/access-parent-windows-window-object-from-child-window-electron
[3] Debugging the Main Process | Electronelectronjs.org › docs › latest › tutorial › debugging-main-process https://www.electronjs.org/docs/latest/tutorial/debugging-main-process
[4] Debugging and Troubleshooting Common Electron Issues https://blog.openreplay.com/debugging-troubleshooting-electron-issues/
[5] How to Debug Electron JavaScript and TypeScript with VS Code https://vscode-debug-specs.github.io/javascript_electron/
[6] How to debug the Electron main process? - Stack Overflow https://stackoverflow.com/questions/71997741/how-to-debug-the-electron-main-process
[7] Unable to debug main process in VS Code as of Electron 9. #24918 https://github.com/electron/electron/issues/24918
[8] How to debug main process in production? : r/electronjs - Reddit https://www.reddit.com/r/electronjs/comments/r3zs1h/how_to_debug_main_process_in_production/
[9] Electron - Close initial window but keep child open - Stack Overflow https://stackoverflow.com/questions/48224116/electron-close-initial-window-but-keep-child-open
[10] enlight/electron-inspector: Debugger UI for the main Electron process https://github.com/enlight/electron-inspector
[11] Tips and Tricks for Debugging Electron Applications - SitePoint https://www.sitepoint.com/debugging-electron-application/
[12] A guide on how to debug an Electron app. - GitHub https://github.com/DrifterAtSea/debugging-electron

---

## Console Logging Strategies

Console logging in Electron requires understanding the dual-process architecture where main and renderer processes have separate console outputs and logging requirements. Strategic logging implementation ensures visibility in development while maintaining performance and security in production.[1][2][3][4]

### Process-Specific Console Output

The main process console output appears in the terminal where Electron was launched, while renderer process console output displays in DevTools. When `console.log()` is called in `main.js`, output goes to the terminal or command prompt. When called in renderer code, output appears in the browser DevTools console for that window.[5][1]

This separation means developers must check different locations depending on which process generated the log. Main process logs require running Electron from a terminal to capture output, while renderer logs require opening DevTools for the respective window.[6][1]

### Basic Console Methods

Standard console methods work identically in both processes, following the browser console API. The `console.log()` method outputs general information, `console.warn()` displays warnings with yellow highlighting, `console.error()` shows errors with red highlighting and stack traces, and `console.info()` provides informational messages. The `console.debug()` method outputs debug-level information that can be filtered in DevTools.[1]

Advanced methods include `console.table()` for formatting arrays and objects as tables, `console.group()` and `console.groupEnd()` for collapsible log groups, `console.time()` and `console.timeEnd()` for performance timing, and `console.trace()` for stack trace generation. These methods provide powerful debugging capabilities without additional libraries.[1]

### electron-log Package

The `electron-log` package provides unified logging across main and renderer processes with automatic file output, requiring no complex configuration. Installation via `npm install electron-log` adds comprehensive logging capabilities with sensible defaults.[2][4]

By default, electron-log writes logs to platform-specific locations: `~/.config/{app name}/logs/main.log` on Linux, `~/Library/Logs/{app name}/main.log` on macOS, and `%USERPROFILE%\AppData\Roaming\{app name}\logs\main.log` on Windows. This automatic file management eliminates manual path configuration for typical use cases.[4][2]

### Main Process Logging with electron-log

In the main process, import the logger from `electron-log/main` and initialize it to enable renderer process access. The `initialize()` method sets up IPC channels that allow renderers to send logs to the main process for file writing.[2][4]

```javascript
import log from 'electron-log/main';

log.initialize();

log.info('Log from the main process');
log.warn('Warning message');
log.error('Error message');
```

The logger supports multiple log levels: `error`, `warn`, `info`, `verbose`, `debug`, and `silly`. Each level can be independently controlled per transport, enabling fine-grained control over what gets logged where.[4][2]

### Renderer Process Logging with electron-log

In renderer processes with bundlers, import from `electron-log/renderer` to access the logger. Without bundlers, use the global `__electronLog` variable containing log functions like `info`, `warn`, and `error`.[2][4]

```javascript
import log from 'electron-log/renderer';
log.info('Log from the renderer process');
```

Renderer logs are automatically sent to the main process via IPC transport, where they're written to both the console and file system. This unified approach ensures all logs from all processes accumulate in a single file for comprehensive debugging.[4][2]

### Transport Configuration

Transports are functions that handle log messages, with console and file transports active by default. Each transport has independent `level` and `format` options that control what gets logged and how it appears.[2][4]

The console transport prints messages to the application console in the main process or DevTools in renderers. Its format defaults to `'%c{h}:{i}:{s}.{ms}%c › {text}'` in the main process and `'{h}:{i}:{s}.{ms} › {text}'` in renderers, with a `level` of `'silly'` (all messages). The `useStyles` option forces styling on or off.[4][2]

The file transport (main process only) writes messages to disk with a default format of `'[{y}-{m}-{d} {h}:{i}:{s}.{ms}] [{level}] {text}'`. The log file path is customized via `resolvePathFn`:[2][4]

```javascript
log.transports.file.resolvePathFn = () => path.join(APP_DATA, 'logs/main.log');
```

### IPC Transport Behavior

IPC transport enables cross-process logging visibility. In the main process, it displays logs in renderer DevTools consoles, defaulting to `'silly'` level in development and `false` (disabled) in production. In renderer processes, IPC transport sends logs to the main process for console and file output.[4][2]

Enabling IPC transport in production requires explicitly setting the level:

```javascript
log.transports.ipc.level = 'info';
```

This balances the need for production logging visibility against performance overhead from IPC communication.[2]

### Disabling Transports

Transports are disabled by setting their `level` property to `false`. This is useful for production builds where console output or file logging may be unnecessary or undesirable.[4][2]

```javascript
log.transports.file.level = false;
log.transports.console.level = false;
```

Selective transport disabling optimizes performance by eliminating unnecessary I/O operations.[2]

### Overriding console Methods

Redirecting standard `console.log()` calls to electron-log captures logs from third-party libraries and legacy code. The simplest approach replaces individual methods:[4][2]

```javascript
console.log = log.log;
```

For comprehensive override, assign all log functions:

```javascript
Object.assign(console, log.functions);
```

This ensures all console calls benefit from electron-log's file writing, formatting, and transport features.[7][2]

### Log Levels and Severity

Proper log level usage ensures meaningful logs without noise. The `error` level captures actionable failures requiring immediate attention, `warn` indicates potential issues that may escalate, `info` records significant application events, `verbose` provides detailed operational information, `debug` captures diagnostic data for development, and `silly` logs everything including trivial details.[3][2]

Production builds typically set levels to `info` or `warn`, filtering out verbose debug information that overwhelms log files. Development environments use `debug` or `silly` to maximize visibility.[3]

```javascript
if (app.isPackaged) {
  log.transports.file.level = 'info';
  log.transports.console.level = 'warn';
} else {
  log.transports.file.level = 'silly';
  log.transports.console.level = 'silly';
}
```

### Structured Logging with Formatting

Colors enhance console readability using CSS-style formatting. The syntax `%c` introduces color changes:[2][4]

```javascript
log.info('%cRed text. %cGreen text', 'color: red', 'color: green');
```

Available colors include unset, black, red, green, yellow, blue, magenta, cyan, white, and gray. DevTools consoles support additional CSS properties for advanced styling.[4][2]

Structured logging improves log parsing and analysis by using consistent formats. Instead of string concatenation, use format specifiers or object logging:[3]

```javascript
// Less structured
log.info('User ' + userId + ' logged in from ' + ipAddress);

// More structured
log.info('User login', { userId, ipAddress, timestamp: Date.now() });
```

### Scopes for Context

Logging scopes add context labels to messages, distinguishing logs from different subsystems. Creating scoped loggers with `log.scope('label')` prefixes all messages with the scope name:[2][4]

```javascript
const userLog = log.scope('user');
userLog.info('message with user scope');
// Prints: 12:12:21.962 (user) › message with user scope
```

By default, scope labels are padded for alignment, disabled via `log.scope.labelPadding = false`. Scopes enable filtering logs by subsystem in large applications.[4][2]

### Error Handling and Crash Logging

electron-log captures unhandled errors and rejected promises automatically. Calling `log.errorHandler.startCatching()` installs global handlers that log uncaught exceptions before the application crashes:[2][4]

```javascript
log.errorHandler.startCatching();
```

This ensures critical errors are recorded even when they would otherwise terminate the process silently. Options customize error handling behavior, such as preventing default error dialogs.[4][2]

### Event Logging

Critical Electron events can be automatically logged to track application health. The `log.eventLogger.startLogging()` method monitors events like `certificate-error`, `child-process-gone`, `render-process-gone` from the `app` module, `crashed` and `gpu-process-crashed` from `webContents`, and `did-fail-load`, `plugin-crashed`, `preload-error` from all WebContents instances.[2][4]

```javascript
log.eventLogger.startLogging();
```

Event logging provides visibility into crashes, load failures, and security issues without manual event listener registration.[4][2]

### Conditional and Buffered Logging

Buffering allows deferring the decision to write logs until after operations complete. This enables verbose logging of operations that only writes logs if the operation fails:[2][4]

```javascript
log.buffering.begin();
try {
  log.debug('Starting complex operation');
  // Perform operation
  log.debug('Operation step completed');
  
  log.buffering.reject(); // Operation succeeded, discard logs
} catch (e) {
  log.buffering.commit(); // Operation failed, write buffered logs
  log.error('Operation failed', e);
}
```

This pattern keeps log files concise while preserving detailed traces when debugging failures.[4][2]

### Custom File Paths

Custom log file paths support scenarios like per-user logs or temporary diagnostic files. The `resolvePathFn` property on the file transport determines the log file location:[8][9]

```javascript
const path = require('path');
log.transports.file.resolvePathFn = () => path.join(__dirname, 'logs', 'main.log');
```

Renderer process logs can be directed to separate files by configuring the main process to distinguish log sources. However, renderer logs pass through IPC to the main process, which controls final file writing.[8][2]

### Production Logging Considerations

Production builds require careful logging configuration to balance diagnostic value against performance and privacy. Asynchronous logging prevents main thread blocking—electron-log handles this automatically. Rate limiting or sampling prevents high-frequency loops from flooding logs.[9][3]

Sensitive data must be filtered from logs to comply with privacy regulations and security best practices. Implement log sanitization functions that redact passwords, tokens, and personal information before logging.[3]

File size management prevents unbounded log growth. While electron-log doesn't provide built-in rotation, external log rotation tools or custom code can archive old logs periodically.[9]

### Alternative Logging Libraries

Winston provides enterprise-grade logging with advanced features like log rotation, multiple transports, and custom formatters. Creating a Winston logger requires invoking `winston.createLogger()` with transport configurations:[10][11]

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'app.log' })
  ]
});

logger.info('Application started');
```

Winston supports custom log levels, dynamic metadata, query interfaces, and streaming. It integrates with Electron applications but requires more configuration than electron-log.[11][10]

### Remote Logging

Remote transport sends logs to external servers for centralized monitoring. Configuring the remote transport with a URL enables JSON POST requests containing log messages:[2][4]

```javascript
log.transports.remote.level = 'warn';
log.transports.remote.url = 'https://logging-service.example.com/logs';
```

This enables real-time error monitoring in production without accessing user machines. Remote logging should respect user privacy and comply with data protection regulations.[3][2]

Sources
[1] Using console.log() in Electron app https://stackoverflow.com/questions/31759367/using-console-log-in-electron-app
[2] GitHub - megahertz/electron-log: Simple logging module Electron/Node.js/NW.js application. No dependencies. No complicated configuration. https://github.com/megahertz/electron-log
[3] 9 Logging Best Practices You Should Know https://www.dash0.com/guides/logging-best-practices
[4] Set BrowserWindow options defaults for child windows ? · Issue #2781 https://github.com/electron/electron/issues/2781
[5] Electron handle console.log messages in main process https://stackoverflow.com/questions/51360870/electron-handle-console-log-messages-in-main-process
[6] console.log not working in main process in electron https://www.reddit.com/r/node/comments/6f6ula/consolelog_not_working_in_main_process_in_electron/
[7] How to log console.log to file from renderer? · Issue #274 - GitHub https://github.com/SimulatedGREG/electron-vue/issues/274
[8] How to output renderer log to custom filePath · megahertz electron-log · Discussion #411 https://github.com/megahertz/electron-log/discussions/411
[9] Electron app - logging to file in production https://stackoverflow.com/questions/41522769/electron-app-logging-to-file-in-production
[10] 5 Best Node.js Logging Libraries https://www.highlight.io/blog/nodejs-logging-libraries
[11] electron updater.Class.RpmUpdater https://www.electron.build/electron-updater.Class.RpmUpdater.html

---

## Error Handling

Error handling in Electron spans both main and renderer processes, each requiring distinct approaches to catch and manage exceptions effectively. Proper error handling prevents silent failures, provides user feedback for crashes, and enables diagnostic logging for troubleshooting.[1][2][3][4]

### Uncaught Exceptions in Main Process

The main process catches uncaught exceptions using Node.js's standard `process.on('uncaughtException')` event handler. When registered, this handler receives all errors that would otherwise crash the application, allowing custom error processing.[5][1]

```javascript
process.on('uncaughtException', (error) => {
  console.error('Uncaught exception in main process:', error);
  // Log to file, display error dialog, or send to error tracking service
});
```

By default, Electron displays an error dialog when uncaught exceptions occur, but registering an `uncaughtException` handler overrides this behavior. The handler must implement its own error reporting mechanisms, such as logging to files, displaying custom dialogs, or sending reports to remote services.[6][1][5]

Note that continuing execution after uncaught exceptions is generally unsafe—the application state may be corrupted. Best practice is to log the error and gracefully shut down the application.[1]

### Unhandled Promise Rejections in Main Process

Unhandled promise rejections require a separate event handler beyond `uncaughtException`. The `process.on('unhandledRejection')` event captures promise rejections that lack `.catch()` handlers.[3][4]

```javascript
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled promise rejection:', reason);
  console.error('Promise:', promise);
});
```

This handler receives two arguments: `reason` (the rejection value, typically an Error object) and `promise` (the Promise that was rejected). Without this handler, unhandled rejections may go unnoticed, causing silent failures that are difficult to diagnose.[3]

### Renderer Process Error Handling

Renderer processes handle errors using standard browser error handling mechanisms. The `window.onerror` global handler catches uncaught exceptions in renderer JavaScript:[2][3]

```javascript
window.onerror = (message, source, lineno, colno, error) => {
  console.error('Renderer error:', { message, source, lineno, colno, error });
  return true; // Prevents default error dialog
};
```

The handler receives the error message, source file, line number, column number, and Error object. Returning `true` from the handler prevents the browser's default error reporting.[2]

Unhandled promise rejections in renderers are caught using `window.addEventListener('unhandledrejection')`:

```javascript
window.addEventListener('unhandledrejection', (event) => {
  console.error('Unhandled promise rejection in renderer:', event.reason);
  event.preventDefault(); // Prevents default browser handling
});
```

### electron-unhandled Package

The `electron-unhandled` package simplifies error handling across both main and renderer processes with unified configuration. Installing via `npm install electron-unhandled` and calling `unhandled()` in both processes catches all uncaught errors and promise rejections.[4][2][3]

```javascript
import unhandled from 'electron-unhandled';

unhandled();
```

This single function call sets up handlers for `uncaughtException`, `unhandledRejection` in the main process, and `error`, `unhandledrejection` events in renderer processes. The package must be called at minimum in the main process, though calling it in all processes ensures comprehensive error coverage.[4][3]

### Error Dialog Configuration

electron-unhandled displays error dialogs to users when errors occur, configurable through options. The `showDialog` option controls dialog presentation, defaulting to `true` in production and `false` in development.[3][4]

```javascript
unhandled({
  showDialog: true,
  logger: console.error
});
```

The `logger` option specifies a custom logging function that receives errors, defaulting to `console.error`. This enables integration with logging libraries like electron-log or remote error tracking services.[4][3]

### Error Reporting Button

The `reportButton` option adds a "Report…" button to error dialogs, executing a custom function when clicked. This function receives the error as its first argument, enabling automated issue creation or error submission.[3][4]

```javascript
import unhandled from 'electron-unhandled';
import { openNewGitHubIssue } from 'electron-util';
import { debugInfo } from 'electron-util/main';

unhandled({
  reportButton: (error) => {
    openNewGitHubIssue({
      user: 'your-username',
      repo: 'your-repo',
      body: `
## Error Stack

\`\`\`
${error.stack}
\`\`\`

## System Info

${debugInfo()}`
    });
  }
});
```

This creates a seamless error reporting workflow where users can submit bug reports with a single click. The `electron-util` package provides helper functions for opening GitHub issues with pre-populated content.[4][3]

### Manual Error Logging

The `logError(error, options)` function manually logs errors using the same configuration as automatic error handling. This is useful for logging caught errors that require user notification or special handling.[3][4]

```javascript
import { logError } from 'electron-unhandled';

try {
  // Risky operation
} catch (error) {
  logError(error, { title: 'Operation Failed' });
}
```

The `title` option customizes the error dialog title, overriding the default `${appName} encountered an error`.[4][3]

### WebContents Error Events

The webContents instance emits events for renderer-specific errors that occur during page loading and navigation. The `did-fail-load` event fires when navigation fails, providing an `errorCode`, `errorDescription`, and `validatedURL`. The `did-fail-provisional-load` event fires when provisional navigation fails.[7][8]

```javascript
win.webContents.on('did-fail-load', (event, errorCode, errorDescription, validatedURL) => {
  console.error(`Failed to load ${validatedURL}: ${errorDescription} (${errorCode})`);
});
```

These events enable custom error pages or retry logic when resources fail to load.[8]

### Crash Detection Events

Renderer process crashes trigger the `crashed` event on webContents, receiving a boolean `killed` parameter indicating whether the process was killed by the OS or exited normally. This event enables crash recovery logic, such as reloading the renderer or notifying users.[9][7]

```javascript
win.webContents.on('crashed', (event, killed) => {
  console.error('Renderer process crashed', { killed });
  
  // Reload the renderer or show error page
  if (killed) {
    win.webContents.reload();
  }
});
```

The `render-process-gone` event (app module) fires when any renderer process crashes, disappears, or is killed, providing detailed exit information through the `details` parameter. This event is more comprehensive than the webContents `crashed` event.[7][9] For instance:

```javascript
app.on('render-process-gone', (event, webContents, details) => {
  console.log('Renderer process gone:', details.reason)
  // details.reason could be 'clean-exit', 'abnormal-exit', 'killed', 'crashed', 'oom', 'launch-failed', 'integrity-failure'
  console.log('Exit code:', details.exitCode)
})
```

[Inference] The reason values likely indicate: `clean-exit` - process exited normally (exit code 0), `abnormal-exit` - process exited with non-zero code, `killed` - process was forcefully terminated (by user or system), `crashed` - process crashed due to an exception or error, `oom` - process terminated due to out-of-memory condition, `launch-failed` - process failed to start, `integrity-failure` - process failed code integrity checks.

Another example showing how to handle specific crash reasons:

```javascript
app.on('render-process-gone', (event, webContents, details) => {
  if (details.reason === 'oom') {
    console.error('Renderer ran out of memory')
  } else if (details.reason === 'crashed') {
    console.error('Renderer crashed unexpectedly')
    webContents.reload() // attempt recovery
  }
})
```

The `child-process-gone` event fires when child processes created by Electron crash or are killed, useful for monitoring utility processes.[7] For example:

```javascript
app.on('child-process-gone', (event, details) => {
  console.log('Child process type:', details.type) // 'GPU', 'Utility', etc.
  console.log('Reason:', details.reason)
  console.log('Exit code:', details.exitCode)
  console.log('Service name:', details.name) // if it's a utility process
})
```

### Main Process Crash Handling

Main process crashes cannot be caught by Node.js error handlers since they represent catastrophic failures. The Electron `crashReporter` module sends crash reports to remote servers when the main or renderer processes crash.[9][7]

```javascript
const { crashReporter } = require('electron');

crashReporter.start({
  productName: 'YourAppName',
  companyName: 'YourCompany',
  submitURL: 'https://your-domain.com/crash-reports',
  autoSubmit: true
});
```

The `submitURL` receives POST requests containing crash dumps, process type, app version, OS information, and custom parameters. This enables post-mortem debugging of crashes that occur in production.[7]

### Orphaned Processes Issue

Main process crashes can leave renderer and crash reporter processes running in the background, consuming resources indefinitely. This issue occurs particularly when using the `remote` module or when crashes happen during specific window lifecycle operations.[9]

Manually killing orphaned processes via task manager is the only remedy, highlighting the importance of main process stability and crash prevention. Using process monitoring tools to detect orphaned Electron processes enables automated cleanup.[9]

### IPC Error Handling

IPC communication errors require special handling since they span process boundaries. When throwing errors in `ipcMain.handle()` handlers, only the error's `message` property is transmitted to the renderer—the full error object is not preserved.[10][5]

```javascript
// Main process
ipcMain.handle('risky-operation', async (event, data) => {
  try {
    return await performOperation(data);
  } catch (error) {
    console.error('IPC handler error:', error);
    throw new Error(error.message); // Only message crosses IPC boundary
  }
});

// Renderer process
try {
  await ipcRenderer.invoke('risky-operation', data);
} catch (error) {
  console.error('Operation failed:', error.message);
}
```

For more comprehensive error transmission, serialize error details into a structured object and return it as a regular value rather than throwing.[5]

### Console Message Errors

The `console-message` event on webContents captures all console output from renderers, including errors. The event provides `level` (string: 'info', 'warning', 'error', 'debug'), `message`, `lineNumber`, `sourceId`, and `frame`.[11][8]

```javascript
win.webContents.on('console-message', ({ level, message, lineNumber, sourceId }) => {
  if (level === 'error') {
    console.error(`Renderer console error at ${sourceId}:${lineNumber}: ${message}`);
  }
});
```

This enables centralized error logging that captures renderer console errors in the main process.[8][11]

### Error Recovery Strategies

Graceful degradation handles errors by providing reduced functionality rather than complete failure. When critical features fail, display informative error messages and offer alternative workflows.[2]

Automatic renderer reload recovers from renderer crashes by calling `webContents.reload()` after the `crashed` event fires. This approach works for transient errors but may cause infinite reload loops if the crash is determ9inistic.[7]

Safe mode or fallback configurations disable problematic features after repeated crashes, allowing users to access the application in a limited state. Tracking crash frequency and triggering safe mode after a threshold prevents crash loops.[2]

### Testing Error Handling

Deliberately triggering errors verifies error handling implementations. Calling `process.crash()` in either the main or renderer process forces an immediate crash for testing crash reporters and recovery logic.[9][7]

```javascript
// Trigger main process crash for testing
process.crash();
```

Throwing unhandled errors and unhandled promise rejections tests error handlers:

```javascript
// Test uncaught exception handler
throw new Error('Test error');

// Test unhandled rejection handler
Promise.reject(new Error('Test rejection'));
```

These tests verify that error handlers correctly log errors, display dialogs, and execute recovery procedures.[2][3]

### Production Error Considerations

Production error handling balances user experience against debugging information. Error dialogs should be user-friendly without exposing technical details that confuse non-technical users. Detailed error information should be logged to files or remote services for developer access.[2][3]

Privacy considerations require sanitizing error messages and stack traces before sending to remote servers, ensuring sensitive data isn't inadvertently transmitted. Rate limiting prevents error storms from overwhelming logging services or crash reporting endpoints.[2]

Sources
[1] How to catch errors occured in the main process? #2479 https://github.com/electron/electron/issues/2479
[2] Error Handling in ElectronJS - GeeksforGeeks https://www.geeksforgeeks.org/javascript/error-handling-in-electronjs/
[3] GitHub - sindresorhus/electron-unhandled: Catch unhandled errors and promise rejections in your Electron app https://github.com/sindresorhus/electron-unhandled
[4] Creating multi-window Electron apps using React portals https://pietrasiak.com/creating-multi-window-electron-apps-using-react-portals
[5] Electron ipcMain how to gracefully handle throwing an error https://stackoverflow.com/questions/66341659/electron-ipcmain-how-to-gracefully-handle-throwing-an-error
[6] It should crash on uncaughtException · Issue #1536 · electron/electron https://github.com/electron/electron/issues/1536
[7] Serverless crash reporting for Electron apps - Teamwork.com https://engineroom.teamwork.com/serverless-crash-reporting-for-electron-apps-fe6e62e5982a
[8] webContents | Electron https://electronjs.org/docs/latest/api/web-contents
[9] Some processes remain alive in the background after main ... - GitHub https://github.com/electron/electron/issues/21681
[10] Electron - How to know when renderer window is ready https://stackoverflow.com/questions/42284627/electron-how-to-know-when-renderer-window-is-ready
[11] Breaking Changes | Electron https://electronjs.org/docs/latest/breaking-changes
[12] Handling uncaught exceptions on browser (node) side · Issue #1012 · electron/electron https://github.com/electron/electron/issues/1012

---

## Hot Reload and Development Workflow

Hot reload capability accelerates Electron development by automatically reflecting source code changes in the running application without manual restarts. This eliminates the repetitive stop-start cycle during development, enabling faster iteration and more efficient workflows.[1][2][3]

### Understanding Hot Reload vs Live Reload

Hot reload preserves application state while applying code changes, allowing developers to continue from their current position in the application without losing context. Live reload (or hot restart) completely restarts the application, losing all current state but ensuring a fresh execution environment. Most Electron development workflows combine both approaches—reloading renderer processes for UI changes and restarting the main process for backend logic changes.[2][3][4][5][1]

The distinction matters because renderer process reloads are nearly instantaneous (10-20ms with modern tools), while main process restarts take longer due to complete application reinitialization. Optimizing development workflows requires understanding which changes require which reload strategy.[4][5]

### electron-reload Package

The `electron-reload` package provides automatic reloading by watching source file changes and refreshing BrowserWindow instances when files are modified. Installation via `npm install electron-reload --save-dev` adds the package as a development dependency.[6][1][2]

```javascript
const path = require('path')
const env = process.env.NODE_ENV || 'development';

// If development environment
if (env === 'development') {
  require('electron-reload')(__dirname, {
    electron: path.join(__dirname, 'node_modules', '.bin', 'electron'),
    hardResetMethod: 'exit'
  });
}
```

The first parameter specifies the directory to watch, typically `__dirname` for the project root. The `electron` option points to the Electron binary path, enabling the package to restart the application when main process files change. The `hardResetMethod: 'exit'` option completely exits the process before restarting, ensuring clean restarts.[1][2][6]

By default, electron-reload watches for changes in `.js`, `.html`, `.css`, and other web-related files. Custom file extensions can be configured through additional options.[1]

### electron-reloader Package

The `electron-reloader` package (requiring Electron 5+) provides more sophisticated reload behavior, distinguishing between main process and renderer process changes. Main process changes trigger full application restarts, while renderer changes only reload the affected BrowserWindow.[1]

```javascript
try {
  require('electron-reloader')(module);
} catch (_) {}
```

This approach wraps the require in a try-catch because electron-reloader should only be installed as a development dependency, and production builds won't have it available. The package automatically detects which files belong to which process and applies appropriate reload strategies.[1]

### electronmon Utility

The `electronmon` package simplifies development workflows by replacing the `electron` command with automatic restart and reload capabilities. It requires no application code changes or configuration, making it the easiest entry point for hot reload functionality.[3][7]

```bash
npx electronmon .
```

This command launches the Electron application with file watching enabled. Changes to main process files trigger complete application restarts, while renderer process file changes reload only the affected windows.[7][3]

Configuration is optional but available through the `electronmon` object in `package.json`. The `patterns` array adds custom glob patterns to watch or ignore:[3]

```json
{
  "electronmon": {
    "patterns": ["!test/**", "!docs/**"]
  }
}
```

Patterns starting with `!` exclude files from watching. The default patterns are `['**/*', '!node_modules', '!node_modules/**/*', '!.*', '!**/*.map']`, ignoring node_modules, hidden files, and source maps.[7][3]

### nodemon Integration

The standard Node.js tool `nodemon` can monitor Electron applications with appropriate configuration. Installing nodemon globally via `npm install -g nodemon` makes it available across all projects.[8]

A `nodemon.json` configuration file in the project root customizes watching behavior:[8]

```json
{
  "ignore": ["assets/*"],
  "ext": "js,html,css",
  "exec": "electron ."
}
```

The `ignore` array excludes directories from monitoring, `ext` specifies watched file extensions, and `exec` defines the command to run. Launching with `nodemon --exec electron .` starts the application with automatic restart on file changes.[8]

Adding a script to `package.json` simplifies repeated commands:[8]

```json
{
  "scripts": {
    "watch": "nodemon --exec electron ."
  }
}
```

Running `npm run watch` launches the application with nodemon monitoring.[8]

### Webpack with Hot Module Replacement

Webpack-based Electron projects achieve hot module replacement (HMR) through webpack-dev-server, enabling component-level updates without full page reloads. Electron Forge's Webpack plugin enables HMR by default for all renderer processes in development mode.[5][9]

HMR updates occur in 10-20ms compared to Webpack's traditional 500-1600ms reload times, maintaining application state while applying code changes. However, HMR cannot function in preload scripts—webpack watches and recompiles them, but full window reloads are required to apply preload changes.[9][5]

Main process updates require manual restart by typing `rs` in the console where Electron Forge was launched. This signals Forge to restart the application with updated main process code.[9]

### Vite and electron-vite

Vite provides extremely fast development servers with native ES module support and sub-200ms cold starts. The `electron-vite` build tool integrates Vite with Electron, providing hot reloading for all processes.[10][4][5]

Hot reloading in electron-vite watches main process and preload script changes via Rollup watcher. Main process changes trigger rebuilds and application restarts, while preload changes rebuild and trigger renderer reloads.[4][10]

Enabling hot reload uses the CLI option `--watch` or `-w`:

```bash
electron-vite dev --watch
```

Alternatively, set `build.watch: {}` in the configuration file for persistent hot reload. The CLI approach is preferred for flexibility.[10][4]

Hot reloading is only available during development and cannot be used in production builds. The uncontrollable timing of reloads means it isn't always beneficial—electron-vite recommends using the CLI flag to enable it selectively.[4][10]

### TypeScript Development Workflow

TypeScript projects require compilation before Electron execution, complicating hot reload. The `concurrently` package runs multiple commands simultaneously, enabling TypeScript watch compilation alongside Electron execution.[6]

Installing dependencies:

```bash
npm install --save-dev concurrently
npm install electron-reload
```

Package.json scripts coordinate compilation and execution:[6]

```json
{
  "scripts": {
    "build": "tsc",
    "start": "npm run build && electron .",
    "dev": "concurrently \"tsc -w\" \"electron .\""
  }
}
```

The `dev` script runs `tsc -w` (TypeScript watch mode) and `electron .` concurrently. Adding electron-reload to the TypeScript entry point enables automatic reloading when compiled JavaScript changes:[6]

```typescript
import electronReload from "electron-reload";
electronReload(__dirname, {});
```

Running `npm run dev` starts both TypeScript compilation and Electron with automatic reloads on save.[6]

### Framework-Specific Considerations

Vue.js applications with Electron require careful configuration to enable HMR in both the Vue components and Electron shell. Vue CLI's development server provides HMR for components, while electron-reload or electron-reloader handles Electron-specific reloading.[11]

The typical approach loads the Vue development server URL in BrowserWindow during development rather than loading built files:

```javascript
if (process.env.NODE_ENV === 'development') {
  win.loadURL('http://localhost:8080');
} else {
  win.loadFile('dist/index.html');
}
```

This enables Vue's HMR while the Vue development server runs, and electron-reload handles main process changes.[11]

### Development vs Production Conditionals

Hot reload should only activate in development environments to avoid performance overhead and unexpected behavior in production. Checking `process.env.NODE_ENV` conditionally loads reload packages:[1][6]

```javascript
if (process.env.NODE_ENV !== 'production') {
  require('electron-reload')(__dirname);
}
```

Setting `NODE_ENV=production` before packaging prevents reload code from executing in distributed applications. Package managers like electron-builder and electron-packager automatically exclude devDependencies from production builds, but environment checks provide additional safety.[1]

### Performance Optimization

Watch patterns should exclude large directories like `node_modules`, `dist`, and build artifacts to minimize file system overhead. Overly broad watching degrades performance and causes spurious reloads.[3][8]

Debouncing file change events prevents rapid successive reloads when multiple files change simultaneously. Most reload tools implement debouncing automatically, but custom implementations should include delays between detecting changes and triggering reloads.[8]

Browser caching during development can interfere with hot reload, making changes appear not to apply. Disabling cache in DevTools (Network tab → "Disable cache") ensures fresh resources load on every reload.[2]

### API-Based Reload Control

electronmon exposes a programmatic API for advanced reload control beyond automatic file watching. The API allows manual triggering of reloads, restarts, and app closure:[7][3]

```javascript
const electronmon = require('electronmon');

(async () => {
  const app = await electronmon({ cwd: __dirname });
  
  // Programmatic control
  await app.reload();   // Reload renderers
  await app.restart();  // Restart entire app
  await app.close();    // Close and wait for changes
  await app.destroy();  // Stop monitoring
})();
```

The `reload()` method reloads all open BrowserWindows without restarting the main process. The `restart()` method restarts the entire Electron process. The `close()` method closes Electron and waits for file changes before restarting. The `destroy()` method stops monitoring entirely.[3][7]

### Debug Output and Logging

Most reload tools provide logging levels to diagnose file watching issues. electronmon supports `verbose`, `info`, `error`, and `quiet` log levels via the `logLevel` option:[3]

```javascript
electronmon({ logLevel: 'verbose' });
```

Verbose mode displays every file change detected and the resulting reload action, helping debug configuration issues.[3]

### Multi-Window Applications

Applications with multiple BrowserWindows require careful reload coordination to avoid inconsistent states. electron-reload and similar tools reload all open windows simultaneously when renderer files change.[2][1]

For applications where windows have different codebases, configure separate watch patterns for each window's files. Custom reload implementations can selectively reload specific windows based on which files changed.[1]

Sources
[1] Hot Reload in ElectronJS https://www.geeksforgeeks.org/javascript/hot-reload-in-electronjs/
[2] Hot Reload in ElectronJs - Tutorials Point https://www.tutorialspoint.com/hot-reload-in-electronjs
[3] BaseWindow https://www.electronjs.org/docs/latest/api/base-window
[4] Hot Reloading | electron-vite https://electron-vite.org/guide/hot-reloading
[5] What Is Vite? - Improve Your Front-End Workflow - Strapi https://strapi.io/blog/vite-es-modules-hmr-front-end-workflow
[6] HOT RELOADING w/Electron & TypeScript Tutorial in 4 Minutes https://www.youtube.com/watch?v=cNWpbm3MNDQ
[7] catdad/electronmon: run, watch, and restart electron apps using magic https://github.com/catdad/electronmon
[8] How to auto-reload Electron JS projects on file modification https://www.youtube.com/watch?v=nB4ulB8efck
[9] Webpack Plugin | Electron Forge https://www.electronforge.io/config/plugins/webpack
[10] Electron browser window - Stack Overflow https://stackoverflow.com/questions/47673817/electron-browser-window
[11] How does one get Hot Reload to work with an Electron / Vue.js app? https://www.reddit.com/r/electronjs/comments/gdzl86/how_does_one_get_hot_reload_to_work_with_an/
[12] electron main process hot reload or live reload https://stackoverflow.com/questions/54323531/electron-main-process-hot-reload-or-live-reload


---

## Performance Profiling

Performance profiling in Electron requires understanding that "performance" encompasses memory usage, CPU utilization, disk I/O, and responsiveness to user input. The most successful strategy for building performant Electron applications is to profile running code, identify resource-hungry bottlenecks, and optimize them iteratively.[1][2]

### Chrome Developer Tools Performance Tab

The Chrome DevTools Performance tab provides the primary tool for analyzing Electron renderer process performance. Opening DevTools and navigating to the Performance tab enables recording performance profiles that capture CPU usage, rendering metrics, and JavaScript execution traces.[2][3][4][5][6]

Recording a profile involves clicking "Start profiling and reload page" or the record button, performing the operations to analyze, then clicking "Stop". DevTools captures performance metrics during recording, processing the data into a timeline view with multiple sections. The main area displays a timeline divided into swimlanes—one for CPU usage and one for each thread. A single time axis runs across the top, enabling correlation of events across different threads.[4][5][6]

The Performance tab shows where bottlenecks occur by highlighting which functions consume the most CPU time, which render operations take longest, and where frame drops happen. Color-coded sections differentiate scripting (JavaScript execution), rendering, painting, and system activities. This visual representation makes performance issues immediately apparent.[5][6]

### Key Performance Metrics

Critical metrics to monitor include Time to Interactive (TTI), which measures when the application becomes fully responsive to user input. Resource usage tracking monitors CPU, memory, and disk utilization to identify resource-intensive operations. Render times and rerender frequency reveal inefficient UI updates. Frames per second (FPS) measurement ensures smooth animations—targeting 60 FPS for optimal user experience.[3]

IPC latency measurement identifies slow inter-process communication that degrades responsiveness. High IPC latency often indicates blocking synchronous calls or excessive message frequency.[3]

### CPU Profiling

CPU profiling identifies which functions consume execution time, revealing optimization opportunities. Node.js provides command-line profiling via the `--cpu-prof` flag that generates `.cpuprofile` files analyzable in Chrome DevTools.[1][2]

```bash
node --cpu-prof -e "require('request')"
```

This command profiles the loading of the `request` module, creating a CPU profile in the current directory. Loading the `.cpuprofile` file in Chrome DevTools' Performance tab displays a flame graph showing function call hierarchy and execution time distribution.[2][1]

For main process profiling, launch Electron with the `--inspect` flag to enable remote debugging, then attach Chrome DevTools or VS Code debugger for CPU profiling. This approach provides the same profiling capabilities as standalone Node.js applications.[4]

### Memory Profiling

Heap memory profiling identifies memory leaks and excessive memory consumption. The `--heap-prof` flag generates `.heapprofile` files containing memory allocation data.[1][2]

```bash
node --heap-prof -e "require('request')"
```

Analyzing heap profiles in Chrome DevTools' Memory tab reveals which objects consume memory and where allocations occur. The Memory tab offers three profiling types: heap snapshots, allocation instrumentation on timeline, and allocation sampling.[2][4][1]

Heap snapshots capture complete memory state at a specific moment, enabling comparison between snapshots to identify growing memory usage. Taking snapshots before and after operations reveals memory that should have been freed but wasn't, indicating leaks.[4]

### Chrome Tracing Tool

The Chrome Tracing tool provides advanced multi-process performance analysis for Electron applications. Unlike the Performance tab which profiles individual processes, tracing captures activity across all Electron processes—main, renderers, GPU—on a unified timeline.[2][4]

Configuring tracing involves creating a JSON configuration file specifying which categories to trace:[4]

```json
{
  "trace_config": {
    "included_categories": ["*"]
  },
  "startup_duration": 10,
  "result_file": "trace-output.json"
}
```

Launching Electron with the configuration enables tracing:[4]

```bash
electron --trace-config-file=./trace-config.json
```

The application runs for the specified duration, then writes captured trace data to the output file. Loading the trace file at `chrome://tracing` in Chrome displays the comprehensive multi-process timeline.[4]

Each process appears in its own swimlane with thread-level detail. This unified view enables identifying cross-process performance issues, such as IPC bottlenecks or GPU process delays affecting renderer responsiveness.[4]

### Electron contentTracing API

The `contentTracing` module provides programmatic control over Chromium's tracing system. This enables starting and stopping traces from within the application, capturing specific user workflows or problematic operations.[3]

```javascript
const { contentTracing } = require('electron');

app.on('ready', async () => {
  await contentTracing.startRecording({
    included_categories: ['*']
  });
  
  // Perform operations to profile
  
  const path = await contentTracing.stopRecording();
  console.log('Trace saved to:', path);
});
```

The API provides finer control than command-line tracing, enabling conditional profiling based on application state or user actions.[3]

### MemoryInfra Tracing

The Chrome tracing tool includes MemoryInfra, a timeline-based memory profiling system that provides deep visibility into memory usage across all processes. Unlike heap profiling which focuses on JavaScript objects, MemoryInfra captures native memory allocations, GPU memory, and other non-heap memory.[4]

Enabling MemoryInfra requires including specific tracing categories in the trace configuration. The resulting trace visualizes memory allocation patterns over time, correlating memory changes with application events.[4]

### Module Loading Performance

Profiling module loading reveals expensive `require()` calls that slow application startup. Generating CPU and heap profiles for specific module loads quantifies their cost:[1][2]

```bash
node --cpu-prof --heap-prof -e "require('request')"
```

In one example, loading the `request` module took almost half a second and consumed significant memory, while `node-fetch` took less than 50ms with dramatically less memory. Such comparisons guide module selection for optimal performance.[1][2]

### Monitoring Production Applications

Production monitoring tools provide real-time performance insights from deployed applications running on user machines. Sentry offers JavaScript profiling that captures function-level performance data from real users at a 100Hz sampling rate. Unlike Chrome DevTools which only profile local development, Sentry profiles production applications to reveal real-world performance issues.[7][8]

The profiler collects function calls and their locations, aggregating them to show the most common code paths. This highlights optimization opportunities based on actual user behavior rather than developer testing scenarios.[8]

Other monitoring solutions like New Relic provide distributed tracing, P9x metrics (percentile-based performance metrics), environment information, and filesystem metrics. These tools enable tracking IPC performance, network conditions, and OS-level resource utilization across millions of deployed instances.[7]

### Blocking Operations Detection

Identifying blocking operations in the main and renderer processes prevents UI freezes. The main process must never block the UI thread with long-running operations—blocking the UI thread freezes the entire application until processing completes.[2][1]

Performance profiling reveals blocking operations through long task markers in the timeline. Tasks exceeding 50ms appear highlighted, indicating responsiveness issues. The call stack for long tasks shows which functions are blocking execution.[5][2]

Synchronous IPC calls and blocking file I/O operations commonly cause main thread blocking. Profiling identifies these patterns, enabling replacement with asynchronous alternatives.[1][2]

### Renderer Process Profiling

Renderer processes require different profiling strategies than the main process. Opening DevTools for a specific window provides isolated renderer profiling. The Performance tab captures rendering operations, JavaScript execution, layout calculations, and paint events specific to that renderer.[3][4]

Modern web performance APIs like `requestIdleCallback()` enable intelligent task scheduling that defers low-priority work until the browser is idle. Web Workers offload CPU-intensive tasks to separate threads, preventing main thread blocking. Profiling reveals when these techniques would improve responsiveness.[2][1]

### Native Module Performance

Native modules written in C, C++, or Rust can dramatically outperform JavaScript implementations for CPU-intensive operations. In one case study, replacing a JavaScript CRC32 implementation with a Rust native module reduced processing time from 800ms to 75ms—a 10x performance improvement.[9]

Profiling CPU-bound operations that manipulate large amounts of data identifies candidates for native module optimization. The profiling data quantifies the performance gap, justifying the development effort required for native implementations.[9]

### Network Performance Analysis

The Network tab in DevTools identifies unnecessary network requests and slow resource loading. Disabling cache and reloading the application records all network activity with timing information.[1][2]

Focusing on the largest files first reveals resources that could be bundled with the application rather than fetched over the network. Network throttling simulates slower connections, revealing resources that block startup unnecessarily. Eliminating or bundling these resources improves perceived performance, especially for users with poor connectivity.[2][1]

### Performance Budgets and Benchmarks

Establishing performance budgets defines acceptable thresholds for metrics like startup time, memory usage, and operation latency. Continuous benchmarking against these budgets prevents performance regression during development.[3]

Automated performance tests execute critical workflows while measuring metrics, failing builds that exceed performance budgets. This proactive approach maintains performance quality throughout the development lifecycle rather than addressing issues reactively.[3]

### Framework-Specific Profiling

React applications benefit from React DevTools Profiler, which captures component render times and identifies unnecessary rerenders. React Scan provides real-time visualization of component updates, highlighting performance antipatterns.[3]

These framework-specific tools complement Chrome DevTools by providing domain-specific insights that general-purpose profilers cannot. Using both together creates comprehensive performance visibility.[3]

### Reducing Profiling Overhead

Profiling itself consumes resources and can affect measurements. Sentry's JavaScript profiler runs at 100Hz with 10ms sample periods compared to DevTools' 1000Hz and 1ms periods. This lower sampling rate minimizes profiling overhead in production while still capturing meaningful data.[8]

For development profiling, running performance tests in Incognito mode prevents browser extensions from affecting measurements. Closing unnecessary applications and background processes ensures profiling captures application performance rather than system contention.[5]

Sources
[1] Performance | Electron https://electronjs.org/docs/latest/tutorial/performance
[2] 初心者向き！Electronで親ウィンドウ↔子ウィンドウのデータ ... https://blog.capilano-fw.com/?p=2593
[3] Building High-Performance Electron Apps - Johnny Le https://johnnyle.io/read/electron-performance
[4] Analysing multi-window Electron application performance using ... https://blog.scottlogic.com/2019/05/21/analysing-electron-performance-chromium-tracing.html
[5] Profile Site Speed With The DevTools Performance Tab https://www.debugbear.com/blog/devtools-performance
[6] Analyze runtime performance | Chrome DevTools https://developer.chrome.com/docs/devtools/performance
[7] Tools for monitoring electron applications - Stack Overflow https://stackoverflow.com/questions/65359065/tools-for-monitoring-electron-applications
[8] Set Up Profiling | Sentry for Electron https://docs.sentry.io/platforms/javascript/guides/electron/profiling/
[9] Electron App Performance - How to Optimize It - Brainhub https://brainhub.eu/library/electron-app-performance
[10] need advice on how improve a electron app performance : r/electronjs https://www.reddit.com/r/electronjs/comments/zkpuo3/need_advice_on_how_improve_a_electron_app/
[11] Electron and the V8 Memory Cage https://electronjs.org/blog/v8-memory-cage

---

# Frontend Integration

## React.js Integration

React integrates with Electron to provide component-based UI development for desktop applications, combining React's declarative rendering with Electron's native platform capabilities. The integration requires configuring build tools to compile JSX and establishing communication patterns between React components and Electron's main process.[1][2][3][4]

### Setting Up with Electron Forge and Webpack

Electron Forge's Webpack template provides the foundation for React integration. Creating a new project with Webpack support enables subsequent React configuration:[5][1]

```bash
npm init electron-app@latest my-react-app -- --template=webpack
```

After project creation, install Babel packages to handle JSX transformation:[2][1][5]

```bash
npm install --save-dev @babel/core @babel/preset-react babel-loader
```

Configure `babel-loader` with the React preset in `webpack.rules.js`:[1][5]

```javascript
module.exports = [
  {
    test: /\.jsx?$/,
    use: {
      loader: 'babel-loader',
      options: {
        exclude: /node_modules/,
        presets: ['@babel/preset-react']
      }
    }
  }
];
```

Install React and ReactDOM as runtime dependencies:[5][1]

```bash
npm install react react-dom
```

### Setting Up with Vite

Vite provides faster development builds and hot module replacement compared to Webpack. Electron Forge supports Vite through its Vite template:[4][6][7]

```bash
npm create @quick-start/electron@latest my-vite-app
```

During setup, select "Electron" then "React" when prompted for the framework. The project is created with TypeScript by default.[6]

Alternatively, create an Electron app with the Vite template and manually add React. Install React dependencies:[4]

```bash
npm install react react-dom
```

Install the Vite React plugin for JSX support:[4]

```bash
npm install --save-dev @vitejs/plugin-react
```

Configure `vite.renderer.config.mjs` to use the React plugin:[4]

```javascript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
});
```

### Rendering React Components

React components render into the Electron renderer process using ReactDOM's `createRoot` API. Create a root element in `index.html`:[8][1][5][4]

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>My Electron React App</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
```

In the renderer entry file (e.g., `renderer.jsx`), import React and render the root component:[8][4]

```jsx
import React from 'react';
import { createRoot } from 'react-dom/client';

const App = () => {
  return <h2>Hello from React!</h2>;
};

const root = createRoot(document.getElementById('root'));
root.render(<App />);
```

This establishes the React rendering pipeline within the Electron window.[8][4]

### Component Architecture

React components in Electron follow standard React patterns but must account for the multi-process architecture. The main process controls the Electron lifecycle and native APIs, while React components run exclusively in renderer processes.[3][4]

Create modular components in separate files for maintainability:[4]

```jsx
// components/Profile.jsx
import React from 'react';

export const Profile = ({ name, title }) => {
  return (
    <div>
      <h2>{name}</h2>
      <p>{title}</p>
    </div>
  );
};
```

Import and use components in the main App component:[4]

```jsx
import React from 'react';
import { Profile } from './components/Profile';

const App = () => {
  return (
    <div>
      <h1>My Electron App</h1>
      <Profile name="John Doe" title="Developer" />
    </div>
  );
};
```

### IPC Communication with React

React components communicate with the main process through IPC using the contextBridge API exposed via preload scripts. This maintains security by preventing direct access to Electron APIs from renderer code.[9][10][11]

Define the preload script to expose safe APIs:[11][9]

```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  setTitle: (title) => ipcRenderer.send('set-title', title),
  openFile: () => ipcRenderer.invoke('dialog:openFile'),
  onUpdateCounter: (callback) => ipcRenderer.on('update-counter', (_event, value) => callback(value))
});
```

Never expose the entire `ipcRenderer` API—always wrap specific methods to limit renderer access. This prevents security vulnerabilities where malicious code could access privileged Electron functionality.[10][9][11]

In React components, access the exposed API through the global `window` object:[9][11]

```jsx
import React, { useState } from 'react';

const TitleUpdater = () => {
  const [title, setTitle] = useState('');
  
  const handleSubmit = async () => {
    await window.electronAPI.setTitle(title);
  };
  
  return (
    <div>
      <input 
        value={title} 
        onChange={(e) => setTitle(e.target.value)} 
      />
      <button onClick={handleSubmit}>Set Title</button>
    </div>
  );
};
```

### Two-Way IPC Communication

Two-way IPC enables React components to receive updates from the main process. Using `ipcRenderer.invoke()` provides request-response patterns, while `ipcRenderer.on()` enables continuous message streams.[10][11][9]

For invoke-based communication, the preload exposes the invoke function:[11]

```javascript
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile')
});
```

The main process handles the request:[11]

```javascript
const { ipcMain, dialog } = require('electron');

ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog();
  if (!canceled) {
    return filePaths[0];
  }
});
```

React components await the result:[11]

```jsx
const FileOpener = () => {
  const [filePath, setFilePath] = useState(null);
  
  const handleOpenFile = async () => {
    const path = await window.electronAPI.openFile();
    setFilePath(path);
  };
  
  return (
    <div>
      <button onClick={handleOpenFile}>Open File</button>
      {filePath && <p>Selected: {filePath}</p>}
    </div>
  );
};
```

For continuous updates from main to renderer, use event listeners:[9][11]

```javascript
// Preload script
contextBridge.exposeInMainWorld('electronAPI', {
  onUpdateCounter: (callback) => ipcRenderer.on('update-counter', (_event, value) => callback(value))
});
```

React components register listeners using useEffect:[11]

```jsx
import React, { useState, useEffect } from 'react';

const Counter = () => {
  const [counter, setCounter] = useState(0);
  
  useEffect(() => {
    window.electronAPI.onUpdateCounter((value) => {
      setCounter(value);
    });
  }, []);
  
  return <div>Counter: {counter}</div>;
};
```

### Avoiding ipcRenderer.sendSync

The `ipcRenderer.sendSync()` method blocks the renderer process until receiving a response, causing severe performance degradation. Always use `ipcRenderer.invoke()` for request-response patterns instead.[10][11]

```javascript
// BAD - Blocks renderer thread
const result = ipcRenderer.sendSync('synchronous-message', 'data');

// GOOD - Non-blocking asynchronous call
const result = await ipcRenderer.invoke('asynchronous-message', 'data');
```

The performance difference is substantial—synchronous IPC can freeze the UI for hundreds of milliseconds, while asynchronous IPC maintains responsiveness.[10][11]

### TypeScript Integration

TypeScript adds type safety to Electron-React applications. Electron Forge's TypeScript template includes preconfigured TypeScript support.[8]

Define types for the exposed Electron API:

```typescript
// preload.d.ts
export interface ElectronAPI {
  setTitle: (title: string) => void;
  openFile: () => Promise<string | undefined>;
}

declare global {
  interface Window {
    electronAPI: ElectronAPI;
  }
}
```

Use typed APIs in React components:

```tsx
const TitleUpdater: React.FC = () => {
  const [title, setTitle] = useState<string>('');
  
  const handleSubmit = async () => {
    window.electronAPI.setTitle(title);
  };
  
  return (/* JSX */);
};
```

### Create React App Integration

Create React App (CRA) can integrate with Electron, though it requires additional configuration compared to Electron Forge. Create a React app first:[3]

```bash
npx create-react-app my-electron-react-app
cd my-electron-react-app
```

Install Electron as a development dependency:[3]

```bash
npm install --save-dev electron electron-builder
```

Create `main.js` in the `public` folder for Electron's main process code. Update `package.json` to specify the main entry point and add build scripts:[3]

```json
{
  "main": "public/main.js",
  "homepage": "./",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "electron:dev": "concurrently \"npm start\" \"wait-on http://localhost:3000 && electron .\"",
    "electron:build": "npm run build && electron-builder"
  }
}
```

The `electron:dev` script runs the React development server and Electron concurrently, waiting for the server to start before launching Electron. Install `concurrently` and `wait-on` packages to enable this workflow.[3]

### Hot Module Replacement

Vite provides fast HMR that updates React components without full page reloads. Changes to React components reflect immediately in the running Electron window. This dramatically improves development velocity compared to Webpack's slower rebuild cycles.[7][4]

HMR preserves component state during updates, enabling rapid UI iteration without losing application context. The `@vitejs/plugin-react` enables React-specific HMR optimizations.[7][4]

### State Management

React state management in Electron follows standard patterns using hooks, Context API, or external libraries like Redux. Application-wide state that persists across window reloads typically stores in the main process or local storage.[12]

For cross-window state synchronization, the main process acts as the source of truth, distributing state updates to all renderer windows via IPC. This ensures consistency when multiple windows display the same data.[12]

### Packaging and Distribution

Build React code before packaging the Electron application. The production build optimizes React bundles for size and performance:[3]

```bash
npm run build
```

Configure electron-builder to include the built React files in the packaged application. The `build` section in `package.json` specifies files to include and platform-specific settings.[3]

Sources
[1] React - Electron Forge https://www.electronforge.io/guides/framework-integration/react
[2] Electron with React: The Ultimate guide to create cross platform ... https://dev.to/navdeepm20/electron-with-react-create-cross-platform-desktop-app-easily-1a13
[3] Electron with React: A Step-by-Step Integration Guide https://www.infinijith.com/blog/react/electron-react
[4] Create a Desktop App with Electron, React, and Vite Using Electron Forge https://www.youtube.com/watch?v=XmSQtyPjbxY
[5] Opening windows from the renderer | Electron https://electronjs.org/docs/latest/api/window-open
[6] Electron-vite + React + Tailwindcss v4 https://stackoverflow.com/questions/79562593/electron-vite-react-tailwindcss-v4
[7] Blog: Electron and Vite.js with React.js - Martin Roček https://www.rocek.dev/blog/react_vite_a_electron
[8] React with TypeScript - Electron Forge https://www.electronforge.io/guides/framework-integration/react-with-typescript
[9] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[10] Deep Dive - IPC w/ Electron & Context Bridge - Which IPC method is correct for you? https://www.youtube.com/watch?v=Tewl2YdBd6w
[11] Electron - How to know when renderer window is ready https://stackoverflow.com/questions/42284627/electron-how-to-know-when-renderer-window-is-ready
[12] How can I use electron with react? https://www.reddit.com/r/electronjs/comments/1h5f3f9/how_can_i_use_electron_with_react/

---

## Tailwind CSS Styling in Electron.js

Tailwind CSS integrates seamlessly with Electron applications, providing a utility-first CSS framework for building modern, responsive desktop UIs. The combination leverages Electron's web-based architecture with Tailwind's rapid styling approach, eliminating the need for custom CSS files while maintaining design consistency.[1][2]

### Integration Approaches

There are multiple methods to integrate Tailwind CSS into Electron projects, each suited to different build setups and developer preferences.[2][1]

#### Tailwind CLI Method

The Tailwind CLI approach offers the simplest setup for Electron applications without requiring complex build tools like Webpack. First, install Tailwind CSS and its CLI tool as development dependencies using `npm install tailwindcss @tailwindcss/cli`. Create an `input.css` file containing `@import "tailwindcss";` to generate all utility classes. Configure a build script in `package.json` with `"watch:css": "npx @tailwindcss/cli -i ./input.css -o ./output.css --watch"` to automatically rebuild CSS when files change. Finally, link the compiled `output.css` file in your `index.html` within the `<head>` tag.[1]

#### Electron Forge with Vite

For projects using Electron Forge with the Vite template, Tailwind integrates through the Vite build system. Install Tailwind CSS v4 as a Vite plugin by configuring `vite.config.js` or `electron.vite.config.js`. Add `@import "tailwindcss";` at the top of your main CSS file (typically `src/renderer/src/assets/main.css`) to enable utility generation during development and build time. This approach leverages Vite's fast hot module replacement for efficient development workflows.[3][4]

#### Webpack Configuration

Electron React Boilerplate and similar webpack-based projects require PostCSS loader integration. Install Tailwind CSS using `npm install -D tailwindcss postcss autoprefixer`. Modify the webpack renderer configuration file (usually `.erb/configs/webpack.config.renderer.dev.ts`) to add a rule for processing CSS with `postcss-loader`. Create a `postcss.config.js` file in the project root containing Tailwind and autoprefixer plugins. Generate a `tailwind.config.js` file to define content paths where Tailwind should scan for class names. Add the three Tailwind directives (`@tailwind base;`, `@tailwind components;`, `@tailwind utilities;`) to your main CSS file (such as `src/renderer/App.css`).[5][6][2]

### Configuration Files

#### tailwind.config.js

The Tailwind configuration file defines which files Tailwind should scan to generate CSS. The `content` property must include all HTML, JSX, and template files where Tailwind classes appear. For Electron projects, typical content paths include `"./src/**/*.{html,js,jsx,ts,tsx}"` to cover all renderer process files. You can extend Tailwind's default theme, add custom colors, spacing values, or plugins through this configuration.[2]

#### postcss.config.js

When using webpack or PostCSS-based builds, create a `postcss.config.js` file that specifies Tailwind as a plugin. This file typically exports an object with a `plugins` array containing `tailwindcss` and `autoprefixer`. The PostCSS configuration processes your CSS files during the build, transforming Tailwind directives into actual CSS.[6][2]

### Styling Patterns

#### Utility-First Approach

Tailwind's utility-first methodology applies single-purpose classes directly to HTML elements, eliminating most custom CSS. Instead of writing separate stylesheets, you compose designs using classes like `flex`, `items-center`, `bg-gray-100`, `text-blue-500`, `rounded-lg`, and `hover:bg-purple-700`. This approach speeds up UI development by keeping layout and styling in the same file, which aligns well with Electron's HTML-based renderer structure.[5][1]

#### Responsive Design

Tailwind provides responsive modifiers that apply styles at specific breakpoints. Use prefixes like `sm:`, `md:`, `lg:`, and `xl:` before utility classes to create adaptive layouts. For example, `class="w-full md:w-1/2 lg:w-1/3"` adjusts element width based on screen size. This ensures Electron applications maintain usability across different window sizes and display resolutions.[1]

#### Component Composition

Complex UI elements are built by combining multiple utility classes. A styled button might use `class="py-3 px-4 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-transparent bg-purple-600 text-white hover:bg-purple-700 focus:outline-hidden cursor-pointer disabled:opacity-50"`. While this creates verbose HTML, it provides precise control and eliminates context-switching between HTML and CSS files.[5]

### Component Libraries

#### FlyonUI Integration

FlyonUI is an open-source Tailwind component library that provides semantic classes and JavaScript plugins for interactive components. Install it using `npm install -D flyonui@latest`. Configure FlyonUI as a plugin in `input.css` by adding `@plugin "flyonui";`, `@import "./node_modules/flyonui/variants.css";`, and `@source "./node_modules/flyonui/dist/index.js"`. Include the FlyonUI JavaScript file before the closing `</body>` tag with `<script src="../node_modules/flyonui/flyonui.js"></script>` to enable interactive behaviors for modals, dropdowns, and accordions. Use semantic classes like `btn btn-primary` instead of verbose utility combinations for cleaner, more maintainable markup.[5]

#### ShadCN UI with Electron

ShadCN UI can be integrated with Electron-Vite projects for pre-built, accessible components. This combination requires proper path alias configuration in `vite.config.js` to resolve component imports correctly. ShadCN components work alongside Tailwind v4, providing a collection of copy-paste components that maintain full customization control.[4]

### Development Workflow

#### Hot Reloading

The Tailwind CLI watch mode (`--watch` flag) automatically recompiles CSS whenever source files change. Run `npm run watch:css` in a separate terminal window while developing to maintain live style updates. For Vite-based setups, hot module replacement handles CSS updates instantly without full page reloads.[3][1][5]

#### Production Optimization

Tailwind automatically purges unused CSS classes during production builds by scanning the files specified in the `content` configuration. This tree-shaking process dramatically reduces CSS file size from potentially several megabytes to just the classes actually used in your application. Ensure your `tailwind.config.js` correctly specifies all template files to prevent accidentally removing needed styles.[6]

#### Content Security Policy

Electron applications often implement Content Security Policy (CSP) headers for security. Tailwind-generated CSS works with strict CSP configurations since it produces standard external stylesheets rather than inline styles. Include CSP meta tags like `<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'">` in your HTML head.[5]

### Common Issues and Solutions

#### CSS Not Loading in Production

Production builds may fail to include Tailwind styles if the output CSS file isn't properly bundled. Verify that `output.css` is referenced correctly in your HTML and included in Electron's build configuration. Check that the production build process runs the Tailwind compilation step before packaging.[6]

#### Large CSS File Sizes

Unoptimized Tailwind CSS files can reach 3MB or more when all utilities are included. Configure the `content` paths accurately in `tailwind.config.js` to enable proper purging of unused styles. Run production builds with `NODE_ENV=production` to trigger Tailwind's minification and purging.[6]

#### Sass Loader Conflicts

When integrating Tailwind with webpack configurations that include sass-loader, conflicts may arise. Remove or modify existing sass-loader rules in your webpack configuration if SassErrors occur during build. Tailwind processes CSS through PostCSS, which may conflict with Sass preprocessing in the same pipeline.[2]

### Advanced Customization

#### Theme Extension

Extend Tailwind's default theme through `tailwind.config.js` to match your application's design system. Add custom colors, fonts, spacing scales, or breakpoints in the `theme.extend` object. Custom values integrate seamlessly with Tailwind's utility generation, creating classes like `bg-brand-primary` or `text-custom-lg`.[2]

#### Custom Plugins

Create custom Tailwind plugins to generate specialized utility classes for your Electron application. Plugins can add new variants, base styles, or component classes using Tailwind's plugin API. This extensibility allows you to maintain consistency while addressing application-specific styling needs.[2]

#### Dark Mode Support

Tailwind includes built-in dark mode support through the `dark:` variant prefix. Configure dark mode strategy in `tailwind.config.js` using either `'media'` (respects system preferences) or `'class'` (manual toggle via class name). Apply dark mode styles with classes like `dark:bg-gray-900 dark:text-white` to create adaptive themes for your Electron application.[1]

Sources
[1] How to Integrate Tailwind with Electron https://www.freecodecamp.org/news/integrate-tailwind-with-electron/
[2] How to integrate Tailwind CSS in Electron? https://blog.saeloun.com/2023/02/24/integrate-tailwind-css-with-electron/
[3] Setting Up Tailwind CSS in Electron with Vite ... https://www.youtube.com/watch?v=5mcYCsU_mKo
[4] 2025 Setup Guide: Electron-Vite + Tailwind-Shadcn UI https://blog.mohitnagaraj.in/blog/202505/Electron_Shadcn_Guide
[5] Installing Tailwind CSS with Vite https://tailwindcss.com/docs
[6] Adding Tailwind to Electron https://thoughtbot.com/blog/adding-tailwind-to-electron
[7] Electron & Tailwind CSS Integration https://github.com/themeselection/ts-electron-tailwind
[8] Styling with utility classes - Core concepts https://tailwindcss.com/docs/styling-with-utility-classes
[9] How to include tailwindcss styles in Electron app using ... https://stackoverflow.com/questions/79299989/how-to-include-tailwindcss-styles-in-electron-app-using-electron-builer
[10] How to use TailwindCSS with Electron - Debug & Release https://www.debugandrelease.com/how-to-use-tailwindcss-with-electron/

---

## Component Libraries in Electron.js

Component libraries provide pre-built, reusable UI elements that accelerate Electron application development while maintaining design consistency and accessibility standards. These libraries integrate seamlessly with Electron's renderer process, leveraging modern web technologies to create desktop experiences that feel native across Windows, macOS, and Linux platforms.[1][2][3][4]

### React-Based Component Libraries

React component libraries dominate the Electron ecosystem due to React's component architecture and vast community support.[5][6]

#### Material-UI (MUI)

Material-UI implements Google's Material Design system as production-ready React components. The library offers comprehensive components including buttons, forms, navigation elements, data displays, and feedback mechanisms. Integration with Electron React Boilerplate requires installing `@material-ui/core` via npm and wrapping the root component with `MuiThemeProvider` to enable theming and styling. Material-UI includes built-in responsiveness, customizable themes through `createTheme()`, and typography system integration that respects platform-specific fonts. The library provides over 50 foundational components that can be customized using CSS-in-JS styling solutions or styled-components. For Electron projects, ensure Roboto font links are added to `index.html` and configure webpack to properly handle Material-UI's CSS dependencies.[7][8][9][10][11]

#### Ant Design

Ant Design delivers an enterprise-grade React component library specifically suited for data-intensive desktop applications. The framework officially supports Electron environments and provides sophisticated components like tables with virtual scrolling, complex form validation, and advanced data visualization widgets. Installation follows standard npm procedures with `npm install antd`, and components can be imported individually to reduce bundle size through tree-shaking. Ant Design's design language emphasizes efficiency and clarity, making it ideal for productivity tools, admin dashboards, and business applications running on Electron. The library includes internationalization support for 50+ languages and comprehensive TypeScript definitions for type-safe development.[3][12]

#### Blueprint.js

Blueprint.js targets complex data-dense interfaces commonly found in desktop applications. Developed by Palantir, this library specializes in components like multi-select inputs, date range pickers, tree views, and context menus that match desktop application conventions. Blueprint uses a more desktop-oriented design language compared to Material Design's mobile-first approach, with components optimized for mouse and keyboard interactions. The library provides dark theme support out of the box, which is essential for developer tools and creative applications. Blueprint's overlay system handles modals, popovers, and tooltips with precise positioning logic that works well within Electron's window constraints.[4][3]

#### Fluent UI 2

Fluent UI 2 represents Microsoft's modern design system, delivering React components that mirror Windows 11's visual language. This library excels for Electron applications targeting Windows users, providing native-feeling controls including ribbons, command bars, navigation views, and Windows-style dialogs. Fluent UI 2 includes extensive accessibility features meeting WCAG standards, with keyboard navigation, screen reader support, and high-contrast mode compatibility built into every component. The design system provides components for progress indicators (Shimmer, Spinner), galleries and pickers (DatePicker, Calendar, ColorPicker, PeoplePicker), and specialized controls for commands and navigation. Installation requires `@fluentui/react-components`, and the library supports theming through design tokens that can be customized to match brand identities. While optimized for Windows 11, Fluent UI 2 maintains cross-platform compatibility with macOS and Linux.[13][14][4]

#### React Desktop

React Desktop specifically targets native-looking desktop UIs for Electron applications. The library provides platform-specific components that mimic macOS and Windows 10/11 native controls, automatically rendering appropriate styles based on the detected operating system. Components include native-style windows, title bars, toolbars, checkboxes, and radio buttons that respect system appearance settings. This library bridges the gap between web technologies and desktop expectations, allowing developers to create applications that feel genuinely native rather than web-based. React Desktop works particularly well for applications that prioritize platform integration over custom branding.[15]

### CSS-First Component Libraries

CSS-focused libraries provide styling and components without heavy JavaScript dependencies, reducing bundle size and improving performance in Electron applications.[2][3]

#### DaisyUI

DaisyUI serves as a Tailwind CSS plugin that adds semantic component classes and 35+ built-in themes to Electron projects. The library is purely CSS-based with zero JavaScript runtime dependencies, maintaining Electron's performance characteristics while accelerating UI development. DaisyUI provides semantic class names like `btn btn-primary`, `card`, `modal`, and `navbar` that replace verbose Tailwind utility combinations. The theming system enables easy light/dark mode switching and custom branding through CSS variables, essential for desktop applications that should respect system appearance preferences. Installation involves adding DaisyUI as a Tailwind plugin in `tailwind.config.js`, making it immediately available throughout the Electron application's renderer process. Components include buttons, forms, data display elements, navigation menus, and overlays that create cohesive cross-platform desktop experiences.[2]

#### Xel

Xel provides native-looking UI elements through custom HTML elements and CSS, designed specifically for Electron and similar frameworks. The library mimics platform-specific design languages including macOS, Windows, and Material Design through different theme configurations. Xel's approach uses web components (custom elements), allowing it to work with any JavaScript framework or vanilla JavaScript implementations. Components include buttons, sliders, tabs, menus, and dialogs that automatically adapt to match the user's operating system appearance.[3]

### Vue-Based Component Libraries

Vue.js developers building Electron applications have access to Vue-specific component libraries optimized for desktop development.[16]

#### Quasar Framework

Quasar extends beyond a simple component library, providing a complete framework with CLI tools specifically designed for Electron development. The framework includes built-in Electron mode that handles build configuration, auto-updating, and platform-specific packaging automatically. Quasar provides over 70 Material Design-based components, a responsive grid system, and extensive utility functions for common desktop application needs. The CLI supports development modes for Progressive Web Apps (PWA), Server-Side Rendering (SSR), Static Site Generation (SSG), Cordova, and Electron from a single codebase. Quasar's Electron mode includes features like splash screens, window state management, and tray icon support through integrated APIs.[16]

#### Vuetify

Vuetify implements Material Design specifications for Vue applications, offering a component-rich library suitable for Electron renderer processes. The library provides comprehensive components including data tables, navigation drawers, app bars, and form inputs with built-in validation. Vuetify's theming system allows extensive customization of colors, typography, and spacing through JavaScript configuration objects. While Vuetify focuses primarily on components rather than complete Electron integration, it pairs well with Electron-Vue templates for building sophisticated desktop interfaces.[16]

### Framework-Agnostic Solutions

Some libraries work across multiple frameworks or with vanilla JavaScript, providing flexibility for diverse Electron project architectures.[1][3]

#### Tailwind CSS

Tailwind CSS functions as both a utility-first CSS framework and a foundation for building custom component systems in Electron applications. Rather than providing pre-built components, Tailwind offers low-level utility classes that developers compose into custom designs. This approach enables consistent styling without the opinionated appearance of traditional component libraries. Tailwind integrates with PostCSS for build-time CSS generation and includes PurgeCSS integration to eliminate unused styles, keeping Electron bundle sizes minimal. The framework works with any JavaScript framework or vanilla HTML/CSS, making it suitable for Electron projects regardless of frontend architecture.[1][3]

#### Bootstrap

Bootstrap remains a viable option for Electron applications requiring rapid prototyping with familiar components. The framework provides extensive pre-styled components including grids, buttons, forms, modals, and navigation elements. Bootstrap 5 removed jQuery dependencies, reducing JavaScript bundle size for Electron applications. The responsive grid system adapts to varying Electron window sizes, though desktop applications benefit from disabling mobile breakpoints that may not apply.[1]

### Selection Criteria

#### Performance Considerations

Component library bundle size directly impacts Electron application startup time and memory footprint. CSS-first libraries like DaisyUI and Tailwind minimize JavaScript overhead, while comprehensive React libraries like Material-UI and Ant Design increase bundle sizes but provide more sophisticated component logic. Tree-shaking and code splitting help mitigate bundle size issues by importing only required components. Electron applications benefit from production build optimization that removes development dependencies and minifies JavaScript.[12][4][5][2][3]

#### Platform Integration

Libraries like React Desktop and Fluent UI 2 prioritize native appearance, making Electron applications feel like traditional desktop software. Material-UI and Ant Design provide consistent cross-platform experiences with custom design languages that don't attempt to mimic specific operating systems. Choose native-looking libraries when users expect platform-specific conventions, and choose custom design systems when brand consistency matters more than OS mimicry.[4][7][12][15]

#### Development Experience

Component libraries with comprehensive documentation, TypeScript support, and active communities reduce development friction. Material-UI and Ant Design offer extensive examples, codesandbox demos, and troubleshooting resources. Framework-specific libraries like Quasar provide integrated CLI tools that streamline Electron build processes and reduce configuration overhead. Evaluate whether a library's learning curve justifies its feature set based on project complexity and team experience.[9][5][7][12][4][16]

#### Accessibility

Electron desktop applications must meet accessibility standards for keyboard navigation, screen reader support, and high-contrast modes. Fluent UI 2 and Material-UI prioritize WCAG compliance with built-in ARIA attributes and keyboard interaction patterns. Blueprint.js includes focus management and keyboard shortcuts designed for complex desktop interfaces. Verify that chosen component libraries provide accessible components rather than relying solely on visual appeal.[9][13][3][4]

### Integration Patterns

#### Theme Customization

Most component libraries expose theming APIs that customize colors, typography, spacing, and border radii. Material-UI uses `createTheme()` to define design tokens that cascade throughout the component tree. DaisyUI and Tailwind leverage CSS variables that can be swapped at runtime for dark mode and custom themes. Fluent UI 2 uses design tokens compatible with Microsoft's Fluent Design System across web and native platforms. Implement theme switching that respects system appearance preferences using Electron's `nativeTheme` API.[13][2][9]

#### Custom Component Development

Build custom components on top of library primitives when unique functionality is required. Extend Material-UI components through composition and style overrides using `styled()` or `sx` props. Wrap library components with application-specific logic, validation, or styling while preserving accessibility features. Use component libraries as design systems that inform custom development rather than rigid constraints.[3][4][9]

#### Mixing Libraries

Combine lightweight CSS frameworks like Tailwind with specialized React component libraries for optimal flexibility. Use Tailwind for layout and spacing utilities while leveraging Material-UI or Ant Design for complex interactive components like date pickers and data tables. Ensure consistent theming when mixing libraries by mapping design tokens between systems. Avoid mixing multiple comprehensive component libraries that provide overlapping components, as this increases bundle size and creates styling conflicts.[2][4][9][3]

Sources
[1] Electron: Build cross-platform desktop apps with JavaScript, HTML ... https://electronjs.org
[2] Electron component library - DaisyUI https://daisyui.com/electron-component-library/?lang=en
[3] Best UI frameworks/libraries to use with Electron other than React? https://www.reddit.com/r/electronjs/comments/lesfqf/best_ui_frameworkslibraries_to_use_with_electron/
[4] Best Electron App UI Libraries (2023) https://www.astrolytics.io/blog/best-electron-ui-libraries-2023
[5] Electron.js: Desktop Application Examples in 2026 - Swovo https://swovo.com/blog/electron-js-desktop-application-examples-in-2024/
[6] Absolutely Awesome React Components & Libraries - GitHub https://github.com/brillout/awesome-react-components
[7] React components that implement Material Design https://mui.com/material-ui/
[8] How can I use Material UI with Electron React Boilerplate? https://stackoverflow.com/questions/60451987/how-can-i-use-material-ui-with-electron-react-boilerplate
[9] MUI: The React component library you always wanted https://mui.com
[10] Get started with Electron & React by building a Photo Viewer ... https://blog.cloudboost.io/get-started-with-electron-react-by-building-a-photo-viewer-the-ui-7af1e68ed1d2
[11] How to properly set up material-ui with electron-react-boilerplate https://stackoverflow.com/questions/60473495/how-to-properly-set-up-material-ui-with-electron-react-boilerplate
[12] Is any possibilities to use ANT UI Design in Electron ... https://stackoverflow.com/questions/45912549/is-any-possibilities-to-use-ant-ui-design-in-electron-desktop-app-framework
[13] Fluent UI https://fabrity.com/blog/fluent-ui/
[14] Start developing - Fluent 2 Design System https://fluent2.microsoft.design/get-started/develop
[15] Native looking UI components for Electron application - Stack Overflow https://stackoverflow.com/questions/31641732/native-looking-ui-components-for-electron-application
[16] What is the most common electron GUI js framework that used for ... https://www.reddit.com/r/electronjs/comments/l9dziv/what_is_the_most_common_electron_gui_js_framework/
[17] Electron UI is a Component Library - GitHub https://github.com/Ashishgupta08/ELECTRON-UI
[18] Best way to build desktop apps? Should I use electron? https://www.reddit.com/r/AskProgramming/comments/12gv7jf/best_way_to_build_desktop_apps_should_i_use/
[19] Best Practices for Web UI in Desktop Apps | Chapter 3 https://seino-prince.com/book/2b3b4ab5-d136-81fb-8232-c0df9dc6329f/chapter/2b3b4ab5-d136-818e-926e-c048eb6ac629/section/2b3b4ab5-d136-81b0-8b6b-cc23f34025a8


---

## State Management in Electron.js

State management in Electron applications requires coordinating data across isolated processes—the main process and multiple renderer processes—which introduces unique architectural challenges not present in typical web applications. Effective state management ensures consistent application state, predictable data flow, and synchronized UI updates across all windows and processes while respecting Electron's security constraints.[1][2][3][4]

### Process Architecture Challenges

#### Main vs Renderer Process Isolation

Electron's architecture separates the main process (Node.js environment) from renderer processes (Chromium browser environments), with inter-process communication (IPC) as the only bridge between them. The main process manages application lifecycle, native menus, system tray, and file system operations, while renderer processes handle UI rendering and user interactions. This isolation means state stored in one process cannot be directly accessed from another without explicit IPC messaging. Security best practices mandate `contextIsolation: true`, `nodeIntegration: false`, and `sandbox: true`, which further restricts direct process communication.[3][4][5][6][7][1]

#### Multiple Renderer Windows

Electron applications frequently spawn multiple browser windows, each running an independent renderer process with its own JavaScript context and memory space. Without state management infrastructure, each window maintains isolated state that can drift out of sync, causing inconsistent user experiences. Managing shared state across windows, tray popups, and preference panels requires centralized coordination.[6][1][3]

### Redux Integration

Redux provides predictable state management through a single store with immutable updates, making it a natural fit for coordinating Electron's multi-process architecture.[8][1]

#### Electron-Redux

Electron-Redux synchronizes Redux stores across main and renderer processes through a Redux store enhancer that automatically broadcasts actions via IPC. Install the library using `yarn add electron-redux` or `npm install electron-redux`. For basic setups without middleware, apply `stateSyncEnhancer()` to `createStore()` in both main and renderer processes. When using middleware like redux-saga or redux-observable that dispatch actions, use `composeWithStateSync()` instead, which wraps enhancers similar to Redux's `compose()` function. Actions dispatched in any process are automatically forwarded to all registered stores, maintaining loose synchronization. All actions must be FSA-compliant with `type` and `payload` properties, and payloads must be serializable since they traverse IPC boundaries.[1][6]

#### Action Scoping

By default, Electron-Redux broadcasts all actions to every registered store, but some state should remain process-local (like `isPanelOpen` UI flags). The library provides a `stopForwarding()` decorator that marks actions as local, preventing propagation from renderer to main store. Actions starting with `@@` and `redux-form` actions are blocked from broadcasting by default, with customizable blocked action lists through configuration options. This scoping mechanism optimizes performance by avoiding unnecessary IPC overhead for renderer-specific state updates.[6]

#### Redux Middleware Integration

Electron-Redux works with standard Redux middleware including redux-thunk, redux-saga, and redux-observable. Place middleware in the main process store to access full Node.js APIs for file system operations, database queries, and external API calls. Renderer processes can dispatch async actions that trigger main process middleware, enabling centralized side-effect management with complete system access. Note that redux-thunk isn't FSA-compliant initially, but produces compatible actions once async operations resolve.[3][8][6]

#### Menu Integration

Electron native menus run in the main process but need to update application state in response to clicks. With Redux state management, menu click handlers dispatch actions to the main store, which synchronizes changes to all renderer windows. Import the store into the main process file where menus are defined, then dispatch actions directly: `store.dispatch({ type: 'OPEN_FILE', payload: filePath })`.[9]

### Zustand Integration

Zustand offers a minimal, hook-based state management alternative to Redux with less boilerplate and better TypeScript integration.[2][10]

#### Zutron/Zubridge

Zutron (now migrated to `@zubridge/electron`) enables seamless Zustand usage across Electron's IPC boundary. The library creates a master Zustand store in the main process and synchronized replica stores in each renderer process. Actions dispatched from renderer processes via the `useDispatch()` hook traverse IPC to the main store, which updates state and broadcasts changes back to all renderer stores. In the main process, access state directly using Zustand's vanilla API (`getState()`, `setState()`, `subscribe()`) or the `useStore()` hook. Renderer processes access state through Zutron's `useStore()` hook and dispatch actions using `useDispatch()`. The library supports multiple Zustand usage patterns including Redux-style reducers, separate handlers, and store-based handlers.[7][2]

#### Architecture

Zutron maintains unidirectional synchronization from main to renderer processes, with actions flowing upstream and state updates flowing downstream. This architecture respects Electron's latest security recommendations by working within `contextIsolation: true` constraints. The library integrates with `BrowserWindow`, `BrowserView`, and `WebContentsView`, automatically handling windows and views created at runtime. Zutron abstracts IPC plumbing entirely, providing a single-store workflow that feels identical to standard Zustand usage.[2][7]

#### Performance Benefits

Zustand minimizes re-renders through selector-based subscriptions that only update components depending on changed state slices. This performance focus makes Zustand particularly suitable for Electron applications where excessive IPC communication can introduce latency. The library's small footprint (under 1KB minified) reduces bundle size compared to Redux, improving application startup time.[10]

### React Context API

React Context provides built-in state management for React-based Electron applications without external dependencies.[3]

#### Single Renderer Process

For applications with a single renderer window, Context API works identically to web applications. Create context providers at the app root using `React.createContext()` and `useContext()` hooks to access shared state. This approach suffices for simple applications where all UI exists in one window.[3]

#### Multi-Process Limitations

Context API cannot share state across process boundaries—each renderer window maintains independent context instances. For multi-window applications, Context must be combined with IPC mechanisms to synchronize state between processes. Use Context for renderer-local UI state while employing Redux, Zustand, or custom IPC for cross-process state.[3]

#### IPC Bridge Pattern

Implement a custom IPC bridge by creating Context providers that subscribe to IPC events and update local state when the main process broadcasts changes. Use `contextBridge.exposeInMainWorld()` in the preload script to expose IPC methods safely. Define `ipcMain.handle()` listeners in the main process to manage state and broadcast updates using `webContents.send()`. This pattern maintains Context's developer experience while enabling cross-process synchronization.[4]

### Recoil

Recoil provides atom-based state management designed specifically for React's concurrent mode with fine-grained reactivity.[11][10]

#### Atom and Selector Model

Recoil organizes state into atoms (independent state units) and selectors (derived state or async queries). Each atom represents a piece of state that components can subscribe to, ensuring only dependent components re-render when that atom updates. Selectors compute derived values or fetch asynchronous data, with automatic caching and dependency tracking. This granular approach scales well for complex applications with many independent state pieces.[10][11]

#### Electron Considerations

Recoil lacks built-in Electron multi-process support similar to Electron-Redux or Zutron. Atoms and selectors work within a single renderer process but require custom IPC integration for cross-process synchronization. Consider Recoil for complex single-window Electron applications where fine-grained reactivity and async state management justify the setup overhead.[11][2][10][3]

#### Async Data Handling

Recoil's async selectors simplify data fetching and caching patterns common in desktop applications. Selectors can return promises that resolve to state values, with built-in loading and error states. This eliminates boilerplate for managing async operations compared to Redux thunks or sagas.[11]

### Alternative Solutions

#### Reduxtron

Reduxtron provides end-to-end Electron state management with a Redux store in the main process. The library follows Electron safety recommendations with `sandbox: true`, `nodeIntegration: false`, and `contextIsolation: true` support. All application pieces (frontend, tray, main process) communicate using Redux-style actions, subscriptions, and `getState()` calls. Middleware in the main process accesses full Node.js APIs for file system operations, databases, and external services. The library eliminates manual IPC message handling while maintaining type-safe action and state definitions. Reduxtron served as the architectural inspiration for Zutron, sharing similar design principles for main-process-centric state management.[7][3]

#### Electron-Store

Electron-Store provides persistent key-value storage rather than runtime state management, suitable for user preferences and configuration. The package stores data as JSON files in the user's app data directory with atomic writes to prevent corruption. Access the store from the main process using `store.set()`, `store.get()`, and `store.delete()` methods. Expose store methods to renderer processes through IPC handlers defined in the preload script using `contextBridge.exposeInMainWorld()`. Create `ipcMain.handle()` listeners for each store operation, allowing renderer processes to invoke storage operations via `ipcRenderer.invoke()`. Electron-Store complements runtime state managers by persisting application state across sessions.[4]

#### Electron-Shared-State

This individual-led library provides single-function state sharing across Electron processes. However, it requires `nodeIntegration: true` and `contextIsolation: false`, violating Electron's security best practices. Consider alternatives like Electron-Redux or Zutron that maintain security while providing similar functionality.[3]

### State Management Patterns

#### Main Process as Source of Truth

Designate the main process store as the single source of truth, with renderer processes maintaining synchronized replicas. This pattern centralizes business logic, file operations, and API calls in the main process where Node.js APIs are available. Renderer processes become pure UI layers that dispatch actions upward and render state downward. This architecture simplifies testing, reduces duplication, and ensures consistency across multiple windows.[7][3]

#### Selective State Synchronization

Not all state needs cross-process synchronization—distinguish between global application state and local UI state. Global state includes user data, application settings, and domain entities that multiple windows need to access. Local state encompasses transient UI concerns like form input values, modal visibility, and scroll positions specific to individual windows. Use scoped actions or separate stores to prevent unnecessary IPC traffic from local state changes.[6][3]

#### Middleware for Side Effects

Place Redux or Zustand middleware in the main process to handle side effects with full system access. Implement middleware for data persistence (writing to files or databases), network requests, native notifications, and system integrations. Renderer processes dispatch intent actions that trigger middleware logic, which updates state after completing operations. This separation keeps renderer processes lightweight and testable while centralizing complex logic.[3]

### Security Considerations

#### Context Isolation

Modern Electron security requires `contextIsolation: true`, preventing renderer processes from directly accessing Node.js or Electron APIs. State management libraries must use the preload script and `contextBridge.exposeInMainWorld()` to safely expose store methods. Zutron and Reduxtron follow these patterns, while older solutions may require security configuration that weakens isolation.[2][4][3]

#### Serialization Requirements

All state traversing IPC boundaries must be JSON-serializable since Electron's IPC uses structured cloning. Avoid storing functions, class instances, symbols, or circular references in synchronized state. Custom serialization/deserialization can extend JSON support for specific types like dates or BigInts, but requires careful implementation.[6]

#### Payload Validation

Validate action payloads in the main process before updating state to prevent renderer processes from injecting malicious data. Implement schema validation using libraries like Zod or Yup for actions that modify sensitive state or trigger file system operations. Treat renderer processes as untrusted clients even within the same application.[4][3]

### Development Workflow

#### Redux DevTools

Electron-Redux integrates with Redux DevTools for time-travel debugging and action inspection. Install the Redux DevTools Extension or use the standalone app to monitor state changes across all processes. DevTools show action origins (main vs specific renderer) and state diffs for each dispatched action.[8][1]

#### Hot Module Replacement

State management libraries work with webpack or Vite HMR to preserve state during development. Configure HMR to reload reducers without resetting state, enabling rapid iteration on business logic. Ensure the main process also supports HMR or implement automatic restart on source changes.[8]

#### Testing Strategies

Test Redux reducers and Zustand stores in isolation using standard testing libraries like Jest. Mock IPC communication for integration tests that verify action synchronization between processes. Use Spectron or Playwright to write end-to-end tests that validate state management across real Electron windows.[8][3]

### Performance Optimization

#### Debouncing State Updates

High-frequency state updates (like cursor position or scroll offset) can overwhelm IPC channels. Debounce or throttle updates using lodash utilities or RxJS operators before dispatching actions. Consider keeping high-frequency state entirely local to the renderer unless synchronization is essential.[3]

#### Selective Subscriptions

Use selectors or computed properties to subscribe to specific state slices rather than the entire store. Zustand and Recoil excel at fine-grained subscriptions that minimize unnecessary re-renders. In Redux, use `useSelector` with equality checks or memoized selectors via Reselect.[10][11][8]

#### Batch Actions

When multiple related state changes occur simultaneously, batch them into a single action to reduce IPC round trips. Redux middleware can intercept multiple actions and combine them before synchronization. This optimization significantly improves performance for operations that update several state slices.[1][3]

Sources
[1] Use redux in the main and browser processes in electron - GitHub https://github.com/klarna/electron-redux
[2] goosewobbler/zutron: Streamlined Electron State Management https://github.com/goosewobbler/zutron
[3] GitHub - vitordino/reduxtron: :electron: end-to-end electron state management https://github.com/vitordino/reduxtron
[4] Electron: Executing Main Process Code from Renderer https://ncoughlin.com/posts/electron-executing-main-process-code-from-renderer
[5] 04 - Electronjs contextBridge and how to use main process functions ... https://www.youtube.com/watch?v=NkQxyW5mlZI
[6] Setting Up Tailwind CSS in Electron with Vite ... https://www.youtube.com/watch?v=5mcYCsU_mKo
[7] Installing Tailwind CSS with Vite https://tailwindcss.com/docs
[8] Electron.js: Desktop Application Examples in 2026 - Swovo https://swovo.com/blog/electron-js-desktop-application-examples-in-2024/
[9] How to change the Redux state based on an Electron menu click? https://stackoverflow.com/questions/35529532/how-to-change-the-redux-state-based-on-an-electron-menu-click
[10] Advanced State Management: Comparing Recoil, Zustand, and Jotai https://dev.to/joshuawasike/advanced-state-management-comparing-recoil-zustand-and-jotai-8fe
[11] Zustand vs Recoil: A Comprehensive Comparison for State ... https://reactmasters.hashnode.dev/zustand-vs-recoil-a-comprehensive-comparison-for-state-management-in-react
[12] A Store System built with Electron, React, Material-UI, Redux, Redux ... https://www.reddit.com/r/reactjs/comments/acjd9m/a_store_system_built_with_electron_react/


---

# Advanced Features


---

# Security


---

# Storage & Data


---

# Networking


---

# Packaging & Distribution



---

# App Store Deployment



---

# Testing


---

# Build Tools & Optimization


---

# Real-World Projects

---

# Minimal Electron Example

## Main Process

```javascript
// main.js - Main Process
const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  mainWindow.loadFile('index.html');
}

// Handle messages from renderer via preload
ipcMain.handle('ping', async (event, message) => {
  console.log('Main received:', message);
  return `Main process received: ${message}`;
});

ipcMain.on('async-message', (event, message) => {
  console.log('Main received async:', message);
  event.reply('async-reply', `Main replies: ${message}`);
});

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
```

## Preload Script

```javascript
// preload.js - Preload Script (Bridge)
const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process
// to use ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // Two-way communication: renderer -> main -> renderer
  sendPing: (message) => ipcRenderer.invoke('ping', message),
  
  // One-way communication: renderer -> main
  sendAsync: (message) => ipcRenderer.send('async-message', message),
  
  // Listen for messages from main process
  onAsyncReply: (callback) => {
    ipcRenderer.on('async-reply', (event, message) => callback(message));
  }
});
```

## Renderer HTML

```javascript
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'">
  <title>Electron IPC Example</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 600px;
      margin: 50px auto;
      padding: 20px;
    }
    button {
      background: #4CAF50;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      margin: 5px;
    }
    button:hover {
      background: #45a049;
    }
    .output {
      margin-top: 20px;
      padding: 15px;
      background: #f5f5f5;
      border-radius: 4px;
      min-height: 100px;
    }
    .message {
      margin: 5px 0;
      padding: 8px;
      background: white;
      border-left: 3px solid #4CAF50;
    }
  </style>
</head>
<body>
  <h1>Electron Process Communication</h1>
  
  <div>
    <h2>Invoke (with response):</h2>
    <button id="pingBtn">Send Ping to Main</button>
  </div>
  
  <div>
    <h2>Send (async, with callback):</h2>
    <button id="asyncBtn">Send Async Message</button>
  </div>
  
  <div class="output" id="output">
    <strong>Output:</strong>
    <div id="messages"></div>
  </div>

  <script src="renderer.js"></script>
</body>
</html>
```

## Renderer Script

```javascript
// renderer.js - Renderer Process
const messagesDiv = document.getElementById('messages');

function addMessage(text) {
  const msgDiv = document.createElement('div');
  msgDiv.className = 'message';
  msgDiv.textContent = `${new Date().toLocaleTimeString()}: ${text}`;
  messagesDiv.appendChild(msgDiv);
}

// Use invoke for request-response pattern
document.getElementById('pingBtn').addEventListener('click', async () => {
  addMessage('Renderer: Sending ping...');
  
  try {
    const response = await window.electronAPI.sendPing('Hello from renderer!');
    addMessage(`Renderer received: ${response}`);
  } catch (error) {
    addMessage(`Error: ${error.message}`);
  }
});

// Use send for one-way async messages
document.getElementById('asyncBtn').addEventListener('click', () => {
  addMessage('Renderer: Sending async message...');
  window.electronAPI.sendAsync('Async hello from renderer!');
});

// Listen for replies from main process
window.electronAPI.onAsyncReply((message) => {
  addMessage(`Async reply received: ${message}`);
});

addMessage('Renderer process ready!');
```

## package.json

```javascript
{
  "name": "electron-ipc-example",
  "version": "1.0.0",
  "description": "Minimal example showing main, preload, and renderer interaction",
  "main": "main.js",
  "scripts": {
    "start": "electron ."
  },
  "devDependencies": {
    "electron": "^28.0.0"
  }
}
```

## File Structure:

- **main.js** - Main process (Node.js environment)
- **preload.js** - Preload script (secure bridge)
- **index.html** - Renderer HTML
- **renderer.js** - Renderer process (browser environment)
- **package.json** - Project configuration

## How It Works:

1. **Main Process** (main.js):
    
    - Creates the window with preload script
    - Listens for IPC messages using `ipcMain.handle()` and `ipcMain.on()`
2. **Preload Script** (preload.js):
    
    - Acts as a secure bridge
    - Exposes safe APIs to renderer via `contextBridge`
    - Prevents direct Node.js access from renderer
3. **Renderer Process** (renderer.js):
    
    - Uses APIs exposed by preload script
    - Cannot directly access Node.js or Electron APIs

## To Run:

```bash
npm install
npm start
```

The example shows two communication patterns:

- **invoke/handle**: Request-response (async/await)
- **send/on**: One-way async messages with callbacks

---

# Packaged Electron App

## Overview

A packaged Electron app bundles your application code, the Electron runtime, and Node.js into a single distributable format. The structure varies by platform (Windows, macOS, Linux) and packaging tool used.

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

## Resource Access in Packaged Apps

### File Paths

In development:

```javascript
// This works in development
const filePath = path.join(__dirname, 'data.json');
```

In production (packaged):

```javascript
// Use app.getAppPath() for ASAR files
const { app } = require('electron');
const filePath = path.join(app.getAppPath(), 'data.json');

// For unpacked files
const unpackedPath = path.join(
  process.resourcesPath,
  'app.asar.unpacked',
  'native-module.node'
);
```

### User Data Directory

Never write to the app installation directory. Use:

```javascript
const { app } = require('electron');
const userDataPath = app.getPath('userData');
// ~/Library/Application Support/MyApp (macOS)
// %APPDATA%/MyApp (Windows)
// ~/.config/MyApp (Linux)
```

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

## Inspecting a Packaged App

### Extract ASAR Contents

```bash
# Install asar globally
npm install -g asar

# Extract ASAR file
asar extract app.asar extracted/

# List ASAR contents
asar list app.asar
```

### Debug Packaged App

```javascript
// In main.js, enable DevTools for packaged app
if (!app.isPackaged) {
  // Development
  mainWindow.webContents.openDevTools();
} else {
  // Production - enable if needed for debugging
  // mainWindow.webContents.openDevTools();
}
```

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

## Security Considerations

[Inference] Common security practices in Electron packaging:

- ASAR provides minimal obfuscation, not real security
- Sensitive data should not be hardcoded
- Use code signing to prevent tampering
- Consider code obfuscation tools for additional protection
- Store secrets in secure system stores, not in the app bundle

## Summary

A packaged Electron app transforms your development structure into a platform-specific bundle containing your code (usually in ASAR format), the Electron runtime, and all necessary dependencies. Understanding this structure helps with debugging, optimizing package size, and properly accessing resources in production.

---

# Electron APIs

## `webContents`

### **What is webContents?**

webContents is an EventEmitter responsible for rendering and controlling a web page and is a property of the BrowserWindow object.

**Basic access example:**
```javascript
const { BrowserWindow } = require('electron')

const win = new BrowserWindow({ width: 800, height: 1500 })
win.loadURL('https://github.com')

const contents = win.webContents
console.log(contents)
```

---

### **Core Concepts**

#### **1. Module-Level Methods**

These methods can be accessed from the webContents module directly:

```javascript
const { webContents } = require('electron')

// Get all WebContents instances
webContents.getAllWebContents()

// Get focused WebContents
webContents.getFocusedWebContents()

// Get WebContents by ID
webContents.fromId(id)
```

---

### **Navigation Events**

Several events can be used to monitor navigations as they occur within a webContents.

#### **Document Navigation Events** (in order):
1. `did-start-navigation`
2. `will-frame-navigate`
3. `will-navigate` (main frame only)
4. `will-redirect` (if redirect occurs)
5. `did-redirect-navigation` (if redirect occurs)
6. `did-frame-navigate`
7. `did-navigate` (main frame only)

#### **In-Page Navigation Events**:
1. `did-start-navigation`
2. `did-navigate-in-page`

In-page navigations don't cause the page to reload, but instead navigate to a location within the current page, such as when anchor links are clicked or when the DOM hashchange event is triggered.

---

### **Key Instance Events**

#### **Loading Events**
- `did-finish-load` - Navigation completed
- `did-fail-load` - Load failed
- `did-start-loading` - Tab spinner starts
- `did-stop-loading` - Tab spinner stops
- `dom-ready` - Document loaded

#### **User Interaction Events**
- `before-input-event` - Before keyboard events
- `context-menu` - Right-click menu
- `found-in-page` - Search results available

#### **Window Events**
- `did-create-window` - New window created via window.open
- `will-prevent-unload` - beforeunload handler attempting to cancel

#### **Process Events**
- `render-process-gone` - Renderer crashed or killed
- `unresponsive` - Page becomes unresponsive
- `responsive` - Page becomes responsive again

#### **DevTools Events**
- `devtools-opened`
- `devtools-closed`
- `devtools-focused`

#### **Media Events**
- `media-started-playing`
- `media-paused`
- `audio-state-changed`

---

### **Essential Instance Methods**

#### **Page Loading**

```javascript
// Load URL
await contents.loadURL('https://example.com', {
  httpReferrer: 'https://referrer.com',
  userAgent: 'Custom UA',
  extraHeaders: 'pragma: no-cache\n'
})

// Load local file
await contents.loadFile('src/index.html')

// Download file
contents.downloadURL('https://example.com/file.zip')

// Get current URL
const url = contents.getURL()

// Get page title
const title = contents.getTitle()
```

#### **Navigation**

```javascript
// Navigation history (deprecated - use navigationHistory API instead)
contents.canGoBack()
contents.canGoForward()
contents.goBack()
contents.goForward()

// Reload
contents.reload()
contents.reloadIgnoringCache()

// Stop loading
contents.stop()
```

#### **Code Execution**

```javascript
// Execute JavaScript
const result = await contents.executeJavaScript('1 + 1')

// Execute in isolated world
await contents.executeJavaScriptInIsolatedWorld(999, [
  { code: 'console.log("hello")' }
])
```

#### **CSS Injection**

```javascript
// Insert CSS
const key = await contents.insertCSS('body { background: red; }', {
  cssOrigin: 'user' // or 'author'
})

// Remove CSS
await contents.removeInsertedCSS(key)
```

#### **IPC Communication**

```javascript
// Send to renderer
contents.send('channel-name', data)

// Send to specific frame
contents.sendToFrame(frameId, 'channel-name', data)

// Post message with MessagePort
const { port1, port2 } = new MessageChannelMain()
contents.postMessage('port', { message: 'hello' }, [port1])
```

#### **Page Capture**

```javascript
// Capture screenshot
const image = await contents.capturePage({
  x: 0, y: 0, width: 800, height: 600
})

// Save page
await contents.savePage('/tmp/page.html', 'HTMLComplete')
// Save types: 'HTMLOnly', 'HTMLComplete', 'MHTML'
```

#### **Printing**

```javascript
// Print to printer
contents.print({
  silent: false,
  printBackground: true,
  deviceName: 'My-Printer',
  color: true,
  margins: { marginType: 'default' },
  landscape: false,
  scaleFactor: 1,
  pagesPerSheet: 1
}, (success, failureReason) => {
  console.log(success ? 'Printed!' : failureReason)
})

// Print to PDF
const pdfData = await contents.printToPDF({
  landscape: false,
  displayHeaderFooter: false,
  printBackground: false,
  scale: 1,
  pageSize: 'A4',
  margins: { top: 0, bottom: 0, left: 0, right: 0 },
  pageRanges: '1-5',
  preferCSSPageSize: false
})
```

#### **Search**

```javascript
// Find in page
const requestId = contents.findInPage('search term', {
  forward: true,
  findNext: false,
  matchCase: false
})

// Listen for results
contents.on('found-in-page', (event, result) => {
  if (result.finalUpdate) {
    contents.stopFindInPage('clearSelection')
  }
})
```

#### **Zoom**

```javascript
// Set zoom factor (1.0 = 100%)
contents.setZoomFactor(1.5)

// Get zoom factor
const factor = contents.getZoomFactor()

// Set zoom level (0 = 100%, each increment = 20%)
contents.setZoomLevel(2) // 140%

// Get zoom level
const level = contents.getZoomLevel()

// Set visual zoom limits
await contents.setVisualZoomLevelLimits(1, 3)
```

#### **DevTools**

```javascript
// Open DevTools
contents.openDevTools({ mode: 'detach', activate: true })

// Close DevTools
contents.closeDevTools()

// Toggle DevTools
contents.toggleDevTools()

// Check if open
const isOpen = contents.isDevToolsOpened()

// Inspect element
contents.inspectElement(x, y)

// Add workspace
contents.addWorkSpace(__dirname)
```

#### **Editing Commands**

```javascript
contents.undo()
contents.redo()
contents.cut()
contents.copy()
contents.paste()
contents.pasteAndMatchStyle()
contents.delete()
contents.selectAll()
contents.unselect()
```

#### **Focus & State**

```javascript
// Focus
contents.focus()
const isFocused = contents.isFocused()

// Loading state
const isLoading = contents.isLoading()
const isLoadingMainFrame = contents.isLoadingMainFrame()
const isWaitingForResponse = contents.isWaitingForResponse()

// Check if destroyed
const isDestroyed = contents.isDestroyed()

// Check if crashed
const isCrashed = contents.isCrashed()

// Force crash (for recovery)
contents.forcefullyCrashRenderer()
```

#### **Audio Control**

```javascript
// Mute
contents.setAudioMuted(true)

// Check mute state
const isMuted = contents.isAudioMuted()

// Check if playing audio
const isAudible = contents.isCurrentlyAudible()
```

#### **Advanced Features**

```javascript
// Device emulation
contents.enableDeviceEmulation({
  screenPosition: 'mobile',
  screenSize: { width: 375, height: 667 },
  deviceScaleFactor: 2
})
contents.disableDeviceEmulation()

// Send input events
contents.sendInputEvent({
  type: 'mouseDown',
  x: 100,
  y: 100,
  button: 'left'
})

// Set user agent
contents.setUserAgent('Custom User Agent')

// WebRTC IP handling
contents.setWebRTCIPHandlingPolicy('default_public_interface_only')
```

#### **Offscreen Rendering**

```javascript
// Check offscreen state
const isOffscreen = contents.isOffscreen()

// Control painting
contents.startPainting()
contents.stopPainting()
const isPainting = contents.isPainting()

// Set frame rate
contents.setFrameRate(60)
const fps = contents.getFrameRate()

// Listen for frames
contents.on('paint', (event, dirty, image) => {
  // image is a NativeImage
  // dirty is a Rectangle with repainted area
})
```

---

### **Instance Properties**

Key properties of WebContents include:

- **`id`** - Integer - Unique ID of this WebContents
- **`session`** - Session used by this webContents
- **`navigationHistory`** - NavigationHistory instance
- **`hostWebContents`** - WebContents that might own this WebContents
- **`devToolsWebContents`** - WebContents for DevTools (may be null)
- **`debugger`** - Debugger instance
- **`backgroundThrottling`** - boolean - Whether to throttle animations when backgrounded
- **`mainFrame`** - WebFrameMain - Top frame of page's frame hierarchy
- **`opener`** - WebFrameMain | null - Frame that opened this WebContents
- **`ipc`** - IpcMain-like interface for this specific WebContents

---

### **Common Use Cases**

#### **1. Handling New Windows**

```javascript
contents.setWindowOpenHandler(({ url, frameName, features }) => {
  if (url.startsWith('https://trusted-domain.com')) {
    return { action: 'allow' }
  }
  return { action: 'deny' }
})

contents.on('did-create-window', (window, details) => {
  console.log('New window created:', details.url)
})
```

#### **2. Secure IPC**

```javascript
// Main process
contents.send('update-data', { value: 42 })

// Listen to specific WebContents
contents.ipc.on('channel', (event, data) => {
  console.log('Received from this WebContents:', data)
})
```

#### **3. Certificate Errors**

```javascript
contents.on('certificate-error', (event, url, error, certificate, callback) => {
  event.preventDefault()
  // Perform custom validation
  callback(isValid)
})
```

#### **4. Page Recovery**

```javascript
contents.on('unresponsive', async () => {
  const { response } = await dialog.showMessageBox({
    message: 'Page is unresponsive',
    buttons: ['Reload', 'Wait']
  })
  
  if (response === 0) {
    contents.forcefullyCrashRenderer()
    contents.reload()
  }
})
```

---

### **Important Notes**

1. **Context Isolation**: When using executeJavaScriptInIsolatedWorld, world ID 999 is used by Electron's contextIsolation feature

2. **Event Prevention**: Calling event.preventDefault() on cancellable navigation events will prevent the navigation

3. **Frame vs Main Frame**: will-navigate and did-navigate only fire when the mainFrame navigates. For iframe navigation, use will-frame-navigate and did-frame-navigate

4. **Zoom Policy**: The zoom policy at the Chromium level is same-origin, meaning zoom level propagates across all instances of windows with the same domain

5. **Printing**: Calling window.print() in web page is equivalent to calling webContents.print with default settings

---

## `IpcMainEvent` and `event.sender`
### **What is event.sender?**

event.sender is a property of the IpcMainEvent object that returns the webContents that sent the message. It's essentially a reference to the WebContents instance of the renderer process that initiated the IPC communication.

---

### **The IpcMainEvent Object**

When you handle IPC messages in the main process, the event object contains several important properties:

The IpcMainEvent object extends Event and includes the following properties:

```javascript
{
  type: 'frame',                    // String - Event type
  processId: 1234,                  // Integer - Renderer process ID
  frameId: 5678,                    // Integer - Renderer frame ID
  returnValue: undefined,           // For synchronous messages
  sender: WebContents,              // The webContents that sent the message
  senderFrame: WebFrameMain | null, // The frame that sent the message
  ports: [],                        // MessagePortMain[] - transferred ports
  reply: Function                   // Function to reply to sender
}
```

---

### **event.sender vs event.reply()**

#### **Key Difference**

event.reply() is a helper method that will automatically handle messages coming from frames that aren't the main frame (e.g. iframes) whereas event.sender.send() will always send to the main frame.

#### **When to Use Each**

**Use `event.reply()`** (Recommended):
```javascript
ipcMain.on('channel', (event, data) => {
  // Replies to the exact frame that sent the message
  event.reply('response-channel', 'response data')
})
```

**Use `event.sender.send()`**:
```javascript
ipcMain.on('channel', (event, data) => {
  // Always sends to the main frame
  event.sender.send('response-channel', 'response data')
})
```

---

### **Common Use Cases**

#### **1. Basic Asynchronous Reply**

To send an asynchronous message back to the sender, you can use event.sender.send():

```javascript
// Main process
const { ipcMain } = require('electron')

ipcMain.on('asynchronous-message', (event, arg) => {
  console.log(arg) // prints "ping"
  event.sender.send('asynchronous-reply', 'pong')
})

// Renderer process
const { ipcRenderer } = require('electron')

ipcRenderer.on('asynchronous-reply', (event, arg) => {
  console.log(arg) // prints "pong"
})

ipcRenderer.send('asynchronous-message', 'ping')
```

#### **2. Synchronous Reply**

To reply to a synchronous message, you need to set event.returnValue:

```javascript
// Main process
ipcMain.on('synchronous-message', (event, arg) => {
  console.log(arg) // prints "ping"
  event.returnValue = 'pong'
})

// Renderer process
const reply = ipcRenderer.sendSync('synchronous-message', 'ping')
console.log(reply) // prints "pong"
```

#### **3. Accessing sender WebContents**

Since `event.sender` is a WebContents instance, you have access to all WebContents methods:

```javascript
ipcMain.on('get-window-info', (event) => {
  const sender = event.sender
  
  // Get information
  const url = sender.getURL()
  const title = sender.getTitle()
  const id = sender.id
  
  // Manipulate the window
  sender.openDevTools()
  sender.setZoomFactor(1.5)
  
  // Send data back
  event.reply('window-info', { url, title, id })
})
```

#### **4. Sending to Specific Frame**

```javascript
ipcMain.on('message-from-iframe', (event, data) => {
  // Get frame information
  const frameId = event.frameId
  const processId = event.processId
  
  // Reply to specific frame
  event.sender.sendToFrame(frameId, 'response', 'data')
  
  // Or use event.reply() which handles this automatically
  event.reply('response', 'data')
})
```

#### **5. Broadcasting to All Windows**

```javascript
ipcMain.on('broadcast-request', (event, message) => {
  // Get all webContents
  const { webContents } = require('electron')
  
  webContents.getAllWebContents().forEach(wc => {
    // Don't send back to the sender
    if (wc.id !== event.sender.id) {
      wc.send('broadcast', message)
    }
  })
  
  // Acknowledge to sender
  event.reply('broadcast-sent', true)
})
```

#### **6. Validating Sender**

```javascript
ipcMain.on('secure-operation', (event, data) => {
  const sender = event.sender
  const url = sender.getURL()
  
  // Validate the sender
  if (url.startsWith('file://') || url.startsWith('https://trusted-domain.com')) {
    // Process the request
    event.reply('operation-result', processData(data))
  } else {
    console.warn('Unauthorized IPC request from:', url)
    event.reply('operation-error', 'Unauthorized')
  }
})
```

---

### **Important Properties of event.sender**

Since `event.sender` is a WebContents instance, you can use:

```javascript
ipcMain.on('channel', (event) => {
  const sender = event.sender
  
  // Identification
  sender.id                    // Unique ID
  sender.getURL()              // Current URL
  sender.getTitle()            // Page title
  
  // State
  sender.isLoading()           // Is loading?
  sender.isFocused()           // Is focused?
  sender.isDestroyed()         // Is destroyed?
  sender.isCrashed()           // Is crashed?
  
  // Navigation
  sender.loadURL(url)
  sender.reload()
  sender.goBack()
  sender.goForward()
  
  // Communication
  sender.send(channel, ...args)
  sender.sendToFrame(frameId, channel, ...args)
  
  // Control
  sender.focus()
  sender.setZoomFactor(factor)
  sender.openDevTools()
  sender.executeJavaScript(code)
})
```

---

### **Security Considerations**

#### **1. Never Expose event.sender to Renderer**

Don't just pass the callback to ipcRenderer.on as this will leak ipcRenderer via event.sender. Use a custom handler that invokes the callback only with the desired arguments.

**Bad (Security Risk):**
```javascript
// Preload script - DON'T DO THIS
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => {
    // This exposes the entire event object including sender
    ipcRenderer.on('update', callback)
  }
})
```

**Good (Secure):**
```javascript
// Preload script - DO THIS
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => {
    // Only pass the data, not the event
    ipcRenderer.on('update', (_event, data) => {
      callback(data)
    })
  }
})
```

#### **2. Validate Sender Origin**

```javascript
ipcMain.on('sensitive-operation', (event, data) => {
  const senderURL = event.sender.getURL()
  const allowedOrigins = ['file://', 'https://myapp.com']
  
  const isAllowed = allowedOrigins.some(origin => 
    senderURL.startsWith(origin)
  )
  
  if (!isAllowed) {
    console.error('Unauthorized IPC request from:', senderURL)
    return
  }
  
  // Process the request
  processSensitiveOperation(data)
})
```

#### **3. Check if Sender Still Exists**

```javascript
ipcMain.on('delayed-operation', async (event, data) => {
  const result = await longRunningOperation(data)
  
  // Check if sender still exists before replying
  if (!event.sender.isDestroyed()) {
    event.reply('operation-complete', result)
  }
})
```

---

### **Advanced Patterns**

#### **1. Tracking Multiple Senders**

```javascript
const senderMap = new Map()

ipcMain.on('register-window', (event, windowName) => {
  senderMap.set(windowName, event.sender)
  
  // Clean up when destroyed
  event.sender.on('destroyed', () => {
    senderMap.delete(windowName)
  })
})

// Later, send to specific window
function sendToWindow(windowName, channel, data) {
  const sender = senderMap.get(windowName)
  if (sender && !sender.isDestroyed()) {
    sender.send(channel, data)
  }
}
```

#### **2. Request-Response with Timeout**

```javascript
ipcMain.on('request-with-timeout', async (event, data) => {
  try {
    const result = await Promise.race([
      processRequest(data),
      new Promise((_, reject) => 
        setTimeout(() => reject('Timeout'), 5000)
      )
    ])
    
    if (!event.sender.isDestroyed()) {
      event.reply('request-result', { success: true, result })
    }
  } catch (error) {
    if (!event.sender.isDestroyed()) {
      event.reply('request-result', { success: false, error: error.message })
    }
  }
})
```

#### **3. Bidirectional Communication**

```javascript
// Main process
ipcMain.on('start-monitoring', (event) => {
  const senderId = event.sender.id
  
  const interval = setInterval(() => {
    if (event.sender.isDestroyed()) {
      clearInterval(interval)
      return
    }
    
    event.sender.send('monitoring-update', {
      timestamp: Date.now(),
      data: getMonitoringData()
    })
  }, 1000)
  
  event.sender.once('destroyed', () => {
    clearInterval(interval)
  })
})
```

---

### **Common Mistakes to Avoid**

#### **1. Using sender after it's destroyed**

```javascript
// BAD
ipcMain.on('async-operation', async (event) => {
  await longOperation()
  event.sender.send('result', data) // sender might be destroyed!
})

// GOOD
ipcMain.on('async-operation', async (event) => {
  const result = await longOperation()
  if (!event.sender.isDestroyed()) {
    event.sender.send('result', data)
  }
})
```

#### **2. Confusing sender.send() with event.reply()**

```javascript
// For iframe communication, prefer event.reply()
ipcMain.on('iframe-message', (event, data) => {
  // This goes to main frame only
  event.sender.send('response', data) 
  
  // This goes back to the exact frame that sent it
  event.reply('response', data) // ✓ Better for iframes
})
```

#### **3. Memory leaks with event listeners**

```javascript
// BAD - Creates a new listener every time
ipcMain.on('setup', (event) => {
  event.sender.on('will-navigate', () => {
    // This listener is never removed!
  })
})

// GOOD - Clean up properly
ipcMain.on('setup', (event) => {
  const handler = () => {
    console.log('Navigating...')
  }
  
  event.sender.on('will-navigate', handler)
  event.sender.once('destroyed', () => {
    event.sender.off('will-navigate', handler)
  })
})
```

---

### **Summary**

**event.sender is:**
- A WebContents instance representing the sender
- Used to reply to IPC messages
- Has full access to WebContents API
- Should be checked for destruction before use
- Should NOT be exposed to the renderer process

**Prefer event.reply() over event.sender.send() for:**
- Better iframe support
- Automatic frame routing
- Cleaner code

**Always:**
- Validate sender origin for security
- Check if sender is destroyed before replying
- Never expose event or event.sender to renderer

---

## IpcRendererEvent in Electron

`IpcRendererEvent` is an event object passed to listener callbacks in Electron's renderer process when using IPC (Inter-Process Communication).

### Basic Usage

When you set up an IPC listener in the renderer process, the callback receives an `IpcRendererEvent` as its first parameter:

```javascript
const { ipcRenderer } = require('electron');

ipcRenderer.on('channel-name', (event, ...args) => {
  // event is an IpcRendererEvent object
  // args are the additional arguments sent with the message
});
```

### Key Properties

The `IpcRendererEvent` object includes:

- **`sender`** - A reference to the `ipcRenderer` that sent the message (allows you to send messages back)
- **`senderId`** - The webContents ID that sent the message
- **`ports`** - An array of MessagePorts transferred with the message (for advanced IPC patterns)

### Common Patterns

**Replying to messages:**

```javascript
ipcRenderer.on('request', (event, data) => {
  // Process data
  event.sender.send('response', result);
});
```

**Using with invoke/handle pattern:**

```javascript
// Main process
ipcMain.handle('get-data', async (event, arg) => {
  // event is IpcMainInvokeEvent here
  return someData;
});

// Renderer process
const data = await ipcRenderer.invoke('get-data', arg);
```

This is part of Electron's security model for controlled communication between the main and renderer processes.

---

## desktopCapturer

The `desktopCapturer` is an Electron API module that allows you to capture audio and video from desktop sources such as screens and windows.

### Basic Usage

```javascript
const { desktopCapturer } = require('electron');

// Get available sources
desktopCapturer.getSources({ types: ['window', 'screen'] })
  .then(async sources => {
    for (const source of sources) {
      console.log(source.name, source.id);
    }
  });
```

### Key Methods

**`desktopCapturer.getSources(options)`**

- Returns a Promise that resolves with an array of `DesktopCapturerSource` objects
- `options.types` - Array of strings specifying source types: `'screen'` and/or `'window'`
- `options.thumbnailSize` - Size of the thumbnail (optional)
- `options.fetchWindowIcons` - Boolean to fetch window icons (optional)

### DesktopCapturerSource Object Properties

- `id` - String identifier for the source (used with `getUserMedia`)
- `name` - Screen or window title
- `thumbnail` - NativeImage thumbnail
- `display_id` - Display identifier
- `appIcon` - Application icon (if `fetchWindowIcons` was true)

### Using with WebRTC

```javascript
async function getStream(sourceId) {
  const stream = await navigator.mediaDevices.getUserMedia({
    audio: false,
    video: {
      mandatory: {
        chromeMediaSource: 'desktop',
        chromeMediaSourceId: sourceId
      }
    }
  });
  return stream;
}
```

[Unverified] The exact API surface and all implementation details may have changed in recent Electron versions beyond my knowledge cutoff. I recommend checking the official Electron documentation at <https://www.electronjs.org/docs> for the most current information.​​​​​​​​​​​​​​​​

---

## All Default Events of Electron Objects

### Window Events (BrowserWindow)

#### Lifecycle Events

- **ready-to-show** - Window can be displayed without visual flash
- **show** - Window is shown
- **hide** - Window is hidden
- **close** - Window is going to be closed
- **closed** - Window has been closed
- **session-end** - Window session is going to end (Windows only)

#### Focus Events

- **focus** - Window gains focus
- **blur** - Window loses focus
- **maximize** - Window is maximized
- **unmaximize** - Window exits maximized state
- **minimize** - Window is minimized
- **restore** - Window is restored from minimized state
- **enter-full-screen** - Window enters full-screen state
- **leave-full-screen** - Window leaves full-screen state
- **enter-html-full-screen** - Window enters HTML full-screen (triggered by HTML API)
- **leave-html-full-screen** - Window leaves HTML full-screen

#### Interaction Events

- **resize** - Window is being resized
- **resized** - Window has been resized (macOS/Windows)
- **will-resize** - Window is about to be resized (macOS/Windows)
- **move** - Window is being moved
- **moved** - Window has been moved (macOS/Windows)
- **will-move** - Window is about to be moved (macOS/Windows)

#### State Events

- **responsive** - Unresponsive page becomes responsive
- **unresponsive** - Page becomes unresponsive
- **always-on-top-changed** - Always-on-top state changed
- **app-command** - App command invoked (Windows)
- **scroll-touch-begin** - Scroll touch event began (macOS)
- **scroll-touch-end** - Scroll touch event ended (macOS)
- **scroll-touch-edge** - Scroll touch event reached edge (macOS)
- **swipe** - Trackpad swipe gesture (macOS)
- **rotate-gesture** - Rotate gesture on trackpad (macOS)
- **sheet-begin** - Window opens a sheet (macOS)
- **sheet-end** - Window closes a sheet (macOS)
- **new-window-for-tab** - Native new tab button clicked (macOS)
- **system-context-menu** - System context menu triggered (Windows)

### WebContents Events

#### Navigation Events

- **did-start-loading** - Tab spinner starts spinning
- **did-stop-loading** - Tab spinner stops spinning
- **did-start-navigation** - Navigation started
- **will-navigate** - Navigation about to happen
- **did-navigate** - Main frame navigation done
- **did-frame-navigate** - Any frame navigation done
- **did-navigate-in-page** - In-page navigation occurred
- **will-redirect** - Server redirect during navigation
- **did-redirect-navigation** - Redirect received during navigation
- **navigation-entry-committed** - Navigation entry committed

#### Loading Events

- **dom-ready** - DOM of top-level frame loaded
- **page-title-updated** - Page title updated
- **page-favicon-updated** - Page favicon updated
- **did-finish-load** - Navigation finished
- **did-fail-load** - Navigation failed
- **did-frame-finish-load** - Frame finished loading
- **did-fail-provisional-load** - Provisional load failed

#### Content Events

- **new-window** - Page requests new window (deprecated)
- **webview-attached** - WebView attached to page
- **will-attach-webview** - WebView about to attach
- **did-attach-webview** - WebView attached
- **console-message** - Console message logged
- **preload-error** - Preload script threw error
- **ipc-message** - Async IPC message from renderer
- **ipc-message-sync** - Sync IPC message from renderer
- **desktop-capturer-get-sources** - desktopCapturer.getSources() called
- **render-process-gone** - Renderer process crashed/killed
- **unresponsive** - Page becomes unresponsive
- **responsive** - Unresponsive page responsive again
- **plugin-crashed** - Plugin process crashed
- **destroyed** - WebContents destroyed

#### Media Events

- **media-started-playing** - Media starts playing
- **media-paused** - Media paused
- **did-change-theme-color** - Page theme color changed
- **update-target-url** - Mouse hovers over link
- **cursor-changed** - Cursor type changed
- **context-menu** - New context menu needs display

#### Security Events

- **certificate-error** - Failed to verify certificate
- **select-client-certificate** - Client certificate requested
- **login** - Authentication requested
- **found-in-page** - Result for findInPage available
- **select-bluetooth-device** - Bluetooth device selection needed
- **paint** - New frame generated
- **devtools-opened** - DevTools opened
- **devtools-closed** - DevTools closed
- **devtools-focused** - DevTools focused
- **devtools-reload-page** - DevTools reload requested
- **will-prevent-unload** - beforeunload handler invoked
- **crashed** - Renderer process crashed (deprecated)
- **before-input-event** - Input event about to be sent

#### Download Events

- **did-create-window** - New window created by renderer

### App Events

#### Lifecycle Events

- **will-finish-launching** - App finishing basic startup
- **ready** - Electron initialization complete
- **window-all-closed** - All windows closed
- **before-quit** - Before application quits
- **will-quit** - All windows closed, app will quit
- **quit** - Application is quitting
- **activate** - Application activated (macOS)
- **did-become-active** - Application became active (macOS)
- **continue-activity** - Handoff activity wants to resume (macOS)
- **will-continue-activity** - Handoff activity about to resume (macOS)
- **continue-activity-error** - Handoff activity failed (macOS)
- **activity-was-continued** - Handoff activity resumed on another device (macOS)
- **update-activity-state** - Handoff about to resume on another device (macOS)
- **new-window-for-tab** - User clicked new tab button (macOS)

#### System Events

- **browser-window-created** - New BrowserWindow created
- **web-contents-created** - New WebContents created
- **certificate-error** - Failed to verify certificate
- **select-client-certificate** - Client certificate requested
- **login** - Authentication requested
- **gpu-info-update** - GPU info update available
- **gpu-process-crashed** - GPU process crashed
- **renderer-process-crashed** - Renderer process crashed (deprecated)
- **render-process-gone** - Renderer process gone
- **child-process-gone** - Child process gone
- **accessibility-support-changed** - Accessibility support changed (macOS/Windows)
- **session-created** - New Session created
- **second-instance** - Second instance executed (with single instance lock)

#### Platform-Specific Events

- **open-file** - User wants to open file (macOS)
- **open-url** - User wants to open URL (macOS)
- **did-resign-active** - App stopped being active (macOS)

### Session Events

#### Request Events

- **will-download** - Download about to start
- **extension-loaded** - Extension loaded (after ready)
- **extension-unloaded** - Extension unloaded
- **extension-ready** - Extension loaded (at ready)
- **preconnect** - Preconnect hint from rendering process
- **spellcheck-dictionary-initialized** - Spellcheck dictionary file initialized
- **spellcheck-dictionary-download-begin** - Spellcheck dictionary download began
- **spellcheck-dictionary-download-success** - Spellcheck dictionary downloaded
- **spellcheck-dictionary-download-failure** - Spellcheck dictionary download failed
- **select-serial-port** - Serial port selection requested (when `serial` permission requested)
- **serial-port-added** - Serial port added
- **serial-port-removed** - Serial port removed
- **select-hid-device** - HID device selection requested
- **hid-device-added** - HID device added
- **hid-device-removed** - HID device removed
- **hid-device-revoked** - HID device access revoked
- **select-usb-device** - USB device selection requested
- **usb-device-added** - USB device added
- **usb-device-removed** - USB device removed
- **usb-device-revoked** - USB device access revoked

### Additional Object Events

#### Tray Events

- **click** - Tray icon clicked
- **right-click** - Tray icon right-clicked (macOS/Windows)
- **double-click** - Tray icon double-clicked (macOS/Windows)
- **balloon-show** - Tray balloon shown (Windows)
- **balloon-click** - Tray balloon clicked (Windows)
- **balloon-closed** - Tray balloon closed (Windows)
- **drop** - Dragged items dropped on tray (macOS)
- **drop-files** - Dragged files dropped on tray (macOS)
- **drop-text** - Dragged text dropped on tray (macOS)
- **drag-enter** - Drag operation entered tray (macOS)
- **drag-leave** - Drag operation exited tray (macOS)
- **drag-end** - Drag operation ended on tray (macOS)
- **mouse-enter** - Mouse entered tray icon (macOS)
- **mouse-leave** - Mouse left tray icon (macOS)
- **mouse-move** - Mouse moved in tray icon (macOS)
- **mouse-up** - Mouse up on tray icon (macOS)
- **mouse-down** - Mouse down on tray icon (macOS)

#### IncomingMessage Events (HTTP Response)

- **data** - Response data chunk
- **end** - Response body ended
- **aborted** - Request aborted mid-stream
- **error** - Error encountered

#### DownloadItem Events

- **updated** - Download updated (progress)
- **done** - Download completed/failed/cancelled

#### TouchBar Events (macOS)

- **escape-touch** - Escape touch bar item touched

-----

**Note:** This list reflects the Electron API as of my knowledge cutoff (January 2025). Event availability may vary by Electron version and operating system. Some events are platform-specific (macOS, Windows, Linux). Always consult the official Electron documentation for your specific version.​​​​​​​​​​​​​​​​



## Using Submenus in Electron Menu

### Basic Submenu Structure

The `submenu` property automatically creates a nested menu when present. You don’t need to explicitly set a `type` - Electron handles this automatically.

```javascript
const { Menu } = require('electron');

const template = [
  {
    label: 'File',
    submenu: [
      {
        label: 'New File',
        click: () => { console.log('New file'); }
      },
      {
        label: 'Open',
        click: () => { console.log('Open'); }
      },
      { type: 'separator' },
      {
        label: 'Exit',
        click: () => { app.quit(); }
      }
    ]
  },
  {
    label: 'Edit',
    submenu: [
      { role: 'undo' },
      { role: 'redo' },
      { type: 'separator' },
      { role: 'cut' },
      { role: 'copy' },
      { role: 'paste' }
    ]
  }
];

const menu = Menu.buildFromTemplate(template);
Menu.setApplicationMenu(menu);
```

### Nested Submenus (Multi-Level)

Submenus can contain other submenus for deeper nesting.

```javascript
const template = [
  {
    label: 'File',
    submenu: [
      {
        label: 'Recent Files',
        submenu: [  // Second level submenu
          { label: 'document1.txt' },
          { label: 'document2.txt' },
          { label: 'document3.txt' }
        ]
      },
      {
        label: 'Export',
        submenu: [  // Another second level submenu
          { label: 'Export as PDF' },
          { label: 'Export as HTML' },
          {
            label: 'Export as Image',
            submenu: [  // Third level submenu
              { label: 'PNG' },
              { label: 'JPEG' },
              { label: 'SVG' }
            ]
          }
        ]
      }
    ]
  }
];
```

### Dynamic Submenu Creation

```javascript
function createRecentFilesSubmenu(files) {
  return files.map(file => ({
    label: file,
    click: () => { openFile(file); }
  }));
}

const recentFiles = ['file1.txt', 'file2.txt', 'file3.txt'];

const template = [
  {
    label: 'File',
    submenu: [
      {
        label: 'Recent Files',
        submenu: createRecentFilesSubmenu(recentFiles)
      }
    ]
  }
];
```

### Context Menu with Submenu

```javascript
const { Menu } = require('electron');

function showContextMenu() {
  const contextMenu = Menu.buildFromTemplate([
    {
      label: 'Format',
      submenu: [
        { label: 'Bold', accelerator: 'CmdOrCtrl+B' },
        { label: 'Italic', accelerator: 'CmdOrCtrl+I' },
        { label: 'Underline', accelerator: 'CmdOrCtrl+U' }
      ]
    },
    { type: 'separator' },
    {
      label: 'Align',
      submenu: [
        { label: 'Left' },
        { label: 'Center' },
        { label: 'Right' }
      ]
    }
  ]);

  contextMenu.popup();
}

// In renderer or when handling right-click
window.addEventListener('contextmenu', (e) => {
  e.preventDefault();
  showContextMenu();
});
```

### Updating Submenu Dynamically

```javascript
const { Menu } = require('electron');

let mainMenu;

function updateRecentFiles(newFiles) {
  const template = [
    {
      label: 'File',
      submenu: [
        {
          label: 'Recent Files',
          submenu: newFiles.map(file => ({
            label: file,
            click: () => { openFile(file); }
          }))
        },
        { type: 'separator' },
        { label: 'Exit', role: 'quit' }
      ]
    }
  ];

  mainMenu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(mainMenu);
}

// Update the menu when files change
updateRecentFiles(['newfile1.txt', 'newfile2.txt']);
```

### Submenu with Mixed Item Types

```javascript
const template = [
  {
    label: 'View',
    submenu: [
      { 
        label: 'Reload', 
        accelerator: 'CmdOrCtrl+R',
        click: (item, focusedWindow) => {
          if (focusedWindow) focusedWindow.reload();
        }
      },
      { type: 'separator' },
      { 
        label: 'Toggle Developer Tools',
        accelerator: 'Alt+CmdOrCtrl+I',
        click: (item, focusedWindow) => {
          if (focusedWindow) focusedWindow.toggleDevTools();
        }
      },
      { type: 'separator' },
      {
        label: 'Zoom',
        submenu: [
          { label: 'Zoom In', accelerator: 'CmdOrCtrl+Plus' },
          { label: 'Zoom Out', accelerator: 'CmdOrCtrl+-' },
          { label: 'Reset Zoom', accelerator: 'CmdOrCtrl+0' }
        ]
      }
    ]
  }
];
```

### Complete Application Menu Example

```javascript
const { app, Menu, BrowserWindow } = require('electron');

function createMenu() {
  const isMac = process.platform === 'darwin';

  const template = [
    // App menu (macOS only)
    ...(isMac ? [{
      label: app.name,
      submenu: [
        { role: 'about' },
        { type: 'separator' },
        { role: 'services' },
        { type: 'separator' },
        { role: 'hide' },
        { role: 'hideOthers' },
        { role: 'unhide' },
        { type: 'separator' },
        { role: 'quit' }
      ]
    }] : []),

    // File menu
    {
      label: 'File',
      submenu: [
        {
          label: 'New',
          submenu: [
            { label: 'New Window', accelerator: 'CmdOrCtrl+N' },
            { label: 'New Tab', accelerator: 'CmdOrCtrl+T' }
          ]
        },
        { type: 'separator' },
        isMac ? { role: 'close' } : { role: 'quit' }
      ]
    },

    // Edit menu
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

app.whenReady().then(() => {
  createMenu();
  // Create window, etc.
});
```

The `submenu` property accepts an array of menu items, and Electron automatically handles the visual presentation and behavior of nested menus across different platforms.​​​​​​​​​​​​​​​​

---

## Programmatic Positioning in Electron Menus

### Basic Positioning Attributes

Electron provides four attributes to control menu item placement: `id`, `before`, `after`, `beforeGroupContaining`, and `afterGroupContaining`.

### Using `before` and `after`

```javascript
const { Menu } = require('electron');

const template = [
  { id: '1', label: 'one', after: ['3'] },
  { id: '2', label: 'two', before: ['1'] },
  { id: '3', label: 'three' }
];

const menu = Menu.buildFromTemplate(template);
// Results in order: three, two, one
```

### How It Works

**Step 1:** Item ‘1’ says “place me after item ‘3’”

**Step 2:** Item ‘2’ says “place me before item ‘1’”

**Step 3:** Item ‘3’ has no positioning constraints

**Final order:** 3 → 2 → 1

### Multiple References

```javascript
const template = [
  { id: 'file', label: 'File' },
  { id: 'edit', label: 'Edit', after: ['file'] },
  { id: 'view', label: 'View', after: ['edit'] },
  { id: 'help', label: 'Help', after: ['view'] }
];

// Results in: File, Edit, View, Help
```

### Using Arrays for Multiple Positioning

```javascript
const template = [
  { id: 'save', label: 'Save' },
  { id: 'new', label: 'New', before: ['open', 'save'] },
  { id: 'open', label: 'Open' }
];

// 'new' will be placed before both 'open' and 'save'
// Results in: New, Open, Save
```

### Group Positioning with `beforeGroupContaining`

```javascript
const template = [
  { id: 'copy', label: 'Copy' },
  { id: 'paste', label: 'Paste' },
  { type: 'separator' },
  { id: 'selectAll', label: 'Select All' },
  { 
    id: 'undo', 
    label: 'Undo',
    beforeGroupContaining: ['copy']
  },
  { 
    id: 'redo', 
    label: 'Redo',
    after: ['undo']
  }
];

// Results in: Undo, Redo, [separator], Copy, Paste, [separator], Select All
```

### Group Positioning with `afterGroupContaining`

```javascript
const template = [
  { id: 'file1', label: 'File 1' },
  { id: 'file2', label: 'File 2' },
  { type: 'separator' },
  { id: 'edit1', label: 'Edit 1' },
  {
    id: 'recent',
    label: 'Recent Files',
    afterGroupContaining: ['file2']
  }
];

// 'recent' appears after the group containing 'file2'
// Results in: File 1, File 2, Recent Files, [separator], Edit 1
```

### Complex Example: Building an Edit Menu

```javascript
const template = [
  { id: 'cut', label: 'Cut' },
  { id: 'copy', label: 'Copy' },
  { id: 'paste', label: 'Paste' },
  { type: 'separator', id: 'sep1' },
  { id: 'selectAll', label: 'Select All' },
  
  // Insert undo/redo at the beginning
  { 
    id: 'undo', 
    label: 'Undo',
    beforeGroupContaining: ['cut']
  },
  { 
    id: 'redo', 
    label: 'Redo',
    after: ['undo']
  },
  
  // Insert delete after paste
  {
    id: 'delete',
    label: 'Delete',
    after: ['paste']
  }
];

const menu = Menu.buildFromTemplate(template);
// Results in:
// Undo
// Redo
// [separator]
// Cut
// Copy
// Paste
// Delete
// [separator]
// Select All
```

### Dynamic Menu with Positioning

```javascript
function buildFileMenu(recentFiles) {
  const template = [
    { id: 'new', label: 'New File' },
    { id: 'open', label: 'Open', after: ['new'] },
    { id: 'save', label: 'Save', after: ['open'] },
    { type: 'separator', id: 'sep1', after: ['save'] },
    { id: 'exit', label: 'Exit' }
  ];

  // Add recent files before exit
  recentFiles.forEach((file, index) => {
    template.push({
      id: `recent-${index}`,
      label: file,
      beforeGroupContaining: ['exit']
    });
  });

  return Menu.buildFromTemplate(template);
}

const menu = buildFileMenu(['file1.txt', 'file2.txt']);
// Results in:
// New File
// Open
// Save
// [separator]
// file1.txt
// file2.txt
// Exit
```

### Platform-Specific Positioning

```javascript
const { Menu } = require('electron');
const isMac = process.platform === 'darwin';

const template = [
  { id: 'file', label: 'File' },
  { id: 'edit', label: 'Edit', after: ['file'] },
  { id: 'view', label: 'View', after: ['edit'] },
  { id: 'window', label: 'Window', after: ['view'] }
];

// On macOS, add app menu at the beginning
if (isMac) {
  template.unshift({
    id: 'app',
    label: 'MyApp',
    beforeGroupContaining: ['file']
  });
}

const menu = Menu.buildFromTemplate(template);
```

### Inserting Items into Existing Submenus

```javascript
const template = [
  {
    label: 'Edit',
    submenu: [
      { id: 'cut', label: 'Cut' },
      { id: 'copy', label: 'Copy' },
      { id: 'paste', label: 'Paste' },
      { type: 'separator' },
      {
        id: 'find',
        label: 'Find',
        beforeGroupContaining: ['cut']  // Moves to top
      },
      {
        id: 'replace',
        label: 'Replace',
        after: ['find']
      }
    ]
  }
];

// Submenu results in:
// Find
// Replace
// [separator]
// Cut
// Copy
// Paste
```

### Debugging Position Issues

```javascript
const template = [
  { id: '1', label: 'First', after: ['2'] },
  { id: '2', label: 'Second', after: ['3'] },
  { id: '3', label: 'Third' }
];

const menu = Menu.buildFromTemplate(template);

// Access items to verify order
menu.items.forEach((item, index) => {
  console.log(`Position ${index}: ${item.label}`);
});
// Output:
// Position 0: Third
// Position 1: Second
// Position 2: First
```

### Key Points

- Items without positioning attributes appear in the order they’re defined
- `before` and `after` accept arrays to specify multiple reference points
- `beforeGroupContaining` and `afterGroupContaining` position relative to groups separated by separators
- All positioning is resolved when `Menu.buildFromTemplate()` is called
- If circular dependencies exist, Electron resolves them based on its internal algorithm (behavior in such cases is [Unverified])

---

## Context Menu Params

In Electron, a context menu is typically implemented by listening to the `context-menu` event on a `webContents` instance. Electron provides a `params` object to that event, which describes *what the user right-clicked on* and *the state of the page at that moment*.

Think of `params` as a diagnostic report handed to you at right-click time: it tells you “where the click happened” and “what actions make sense here,” so you can decide which menu items to show.

Background on the term:
A *context menu* is a menu whose options depend on context—similar to how right-clicking text in a word processor shows copy/paste, while right-clicking an image shows save or copy image.

Below is a canonical Electron example.

Main process example:

```js
import { app, BrowserWindow, Menu } from 'electron';

app.whenReady().then(() => {
  const win = new BrowserWindow({
    webPreferences: {
      preload: 'preload.js',
    },
  });

  win.loadURL('https://example.com');

  win.webContents.on('context-menu', (event, params) => {
    const template = [];

    if (params.linkURL) {
      template.push({
        label: 'Open Link in Browser',
        click: () => {
          require('electron').shell.openExternal(params.linkURL);
        },
      });
    }

    if (params.mediaType === 'image') {
      template.push({
        label: 'Save Image',
        click: () => {
          console.log('Image URL:', params.srcURL);
        },
      });
    }

    if (params.selectionText) {
      template.push({
        label: 'Copy',
        role: 'copy',
      });
    }

    if (params.isEditable) {
      template.push(
        { type: 'separator' },
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'paste' }
      );
    }

    if (template.length > 0) {
      const menu = Menu.buildFromTemplate(template);
      menu.popup({ window: win });
    }
  });
});
```

Key fields in `params` and what they mean:

* `mediaType`: What was clicked (`none`, `image`, `video`, `audio`, `canvas`, `file`).
* `linkURL`: URL if the click was on a hyperlink.
* `srcURL`: Source URL of media (for images, videos, etc.).
* `selectionText`: Text currently selected, if any.
* `isEditable`: True if the click occurred inside an input, textarea, or content-editable element.
* `x`, `y`: Coordinates of the click within the page.

Analogy:
Imagine a security guard checking a visitor’s badge before opening doors. `params` is the badge—it tells you whether the click came from text, an image, or an input field, so you only “open the doors” (menu options) that make sense.

Important practical note:
Context menus are normally implemented in the **main process**, because `Menu` and `menu.popup()` are main-process APIs. You can forward the event from preload or renderer if needed, but the menu itself is created in main.


---

## DOM `contextmenu` vs webContents `context-menu`

In Electron there are two fundamentally different ways to implement context menus, and the trade-off you quoted (“requires manual event prevention and IPC setup but provides more control”) applies specifically to the **DOM `contextmenu` approach**.

I will contrast them directly, then summarize when each is appropriate.

First, some background on the terms.

The **DOM `contextmenu` event** is a standard browser event fired in the renderer whenever a user right-clicks (or long-presses). It lives entirely in the web page’s JavaScript environment.

The **`webContents` `context-menu` event** is an Electron-specific event fired in the **main process**, emitted by Chromium after it analyzes what was clicked.

You can think of it this way:

* DOM `contextmenu`: “The page noticed a right-click.”
* `webContents.context-menu`: “Chromium already classified the click and is reporting it to Electron.”

---

### 1. DOM `contextmenu` (renderer-level)

Renderer example:

```js
document.addEventListener('contextmenu', (e) => {
  e.preventDefault();

  const target = e.target;

  window.api.showContextMenu({
    tagName: target.tagName,
    isEditable: target.isContentEditable,
    selection: window.getSelection()?.toString(),
  });
});
```

Main process:

```js
ipcMain.handle('show-context-menu', (event, data) => {
  // Build menu manually
});
```

Characteristics:

* You **must call `event.preventDefault()`** to suppress the default Chromium menu.
* You **must send data manually via IPC**.
* You must **infer context yourself** (element type, selection, attributes).

Control level:

* Very high.
* You decide *exactly* when a menu appears.
* You can conditionally suppress menus (e.g., only on specific elements).
* Works even when you want *non-standard* triggers (custom right-click logic, long-press, keyboard).

Analogy:
This is like intercepting a knock at the door before anyone looks through the peephole—you decide whether to open, ignore, or show a custom interaction.

Costs:

* More boilerplate.
* Higher risk of missing edge cases (images, links, spellcheck, media).
* Must maintain IPC contracts.

---

### 2. `webContents.on('context-menu')` (Chromium-level)

Main process example:

```js
win.webContents.on('context-menu', (event, params) => {
  if (params.mediaType === 'image') {
    // show image menu
  }
});
```

Characteristics:

* No DOM event handling required.
* No IPC required.
* Electron gives you a **rich `params` object**:

  * `mediaType`
  * `linkURL`
  * `srcURL`
  * `selectionText`
  * `isEditable`
  * spellcheck info
  * coordinates

Control level:

* Medium to high.
* You can still customize menus dynamically.
* But you react *after* Chromium decides the click is valid.

Analogy:
This is like letting the doorman identify the visitor first, then choosing how to respond based on a detailed report.

Benefits:

* Far less code.
* Much harder to get wrong.
* Matches native Chromium behavior.
* Best default choice.

Limitations:

* Only fires on actual right-clicks.
* Cannot easily implement nonstandard triggers.
* Harder to suppress menus selectively at the DOM level.

---

### 3. Why DOM context menus give “more control”

That statement is accurate because DOM-based handling lets you:

* Block context menus on specific elements or regions.
* Implement app-specific logic (e.g., permissions, modes).
* Replace right-click behavior entirely.
* Trigger menus from non-mouse interactions.

However, that control comes at the cost of:

* Manual event suppression.
* Manual context extraction.
* IPC complexity.

---

### 4. Direct comparison summary

* Use **`webContents.context-menu`** when:

  * You want native-like behavior.
  * You need access to Chromium’s click classification.
  * You want simplicity and reliability.

* Use **DOM `contextmenu`** when:

  * You need absolute control over when menus appear.
  * You want custom interaction models.
  * You want renderer-driven UX logic.

Hybrid approach (common in large apps):

* Use DOM `contextmenu` only for special cases.
* Let `webContents.context-menu` handle everything else.


---

## nativeImage

The `nativeImage` module in Electron provides utilities for creating and manipulating images. It handles various image formats and sources, including files, buffers, and data URLs.

### Creating Native Images

You can create native images from several sources:

```javascript
const { nativeImage } = require('electron')

// From a file path
const image1 = nativeImage.createFromPath('/path/to/image.png')

// From a buffer
const buffer = fs.readFileSync('/path/to/image.png')
const image2 = nativeImage.createFromBuffer(buffer)

// From a data URL
const image3 = nativeImage.createFromDataURL('data:image/png;base64,iVBORw0KG...')

// Create an empty image
const image4 = nativeImage.createEmpty()
```

### Common Methods

**Getting image properties:**

```javascript
const size = image.getSize()  // Returns { width: number, height: number }
const aspectRatio = image.getAspectRatio()  // Returns width/height
const isEmpty = image.isEmpty()  // Returns boolean
```

**Converting and exporting:**

```javascript
// Convert to different formats
const pngBuffer = image.toPNG()
const jpegBuffer = image.toJPEG(quality)  // quality: 0-100
const dataURL = image.toDataURL()
const bitmap = image.toBitmap()

// Get native handle (platform-specific)
const nativeHandle = image.getNativeHandle()
```

**Resizing and cropping:**

```javascript
// Resize image
const resized = image.resize({ 
  width: 100, 
  height: 100,
  quality: 'best'  // 'good', 'better', 'best'
})

// Crop image
const cropped = image.crop({ 
  x: 10, 
  y: 10, 
  width: 50, 
  height: 50 
})
```

### High DPI Support

Electron’s `nativeImage` handles high-DPI displays automatically:

```javascript
// Add representations for different scale factors
const image = nativeImage.createEmpty()
image.addRepresentation({
  scaleFactor: 1.0,
  buffer: buffer1x
})
image.addRepresentation({
  scaleFactor: 2.0,
  buffer: buffer2x
})
```

This snippet demonstrates how **Electron’s `nativeImage` supports high-DPI (HiDPI / Retina) displays** by storing multiple image representations at different scale factors.

Brief background on high-DPI.
On high-DPI displays, one “CSS pixel” maps to multiple physical pixels. For example, on a 2× display, a 16×16 logical icon is actually rendered using a 32×32 bitmap. If you provide only a 1× bitmap, the OS scales it up, which causes blur.

What `nativeImage` is doing conceptually.
A `nativeImage` is not a single bitmap. It is more like a **folder of the same image at different resolutions**, each labeled with the scale factor it is meant for. The OS then picks the most appropriate one at render time.

Analogy.
Think of it like road signs printed in different sizes. The highway authority stores multiple versions of the same sign. Drivers do not choose which one to read; the system installs the correct size for the road. Similarly, Electron hands all versions to the OS, and the OS chooses.

Explanation of the code.

```javascript
const image = nativeImage.createEmpty()
```

This creates an empty `NativeImage` container with no bitmap data yet.

```javascript
image.addRepresentation({
  scaleFactor: 1.0,
  buffer: buffer1x
})
```

This adds the **standard-DPI version** of the image.
• `scaleFactor: 1.0` means “1 device pixel per logical pixel.”
• `buffer1x` must contain raw pixel data at the base resolution.

```javascript
image.addRepresentation({
  scaleFactor: 2.0,
  buffer: buffer2x
})
```

This adds the **HiDPI version**.
• `scaleFactor: 2.0` means “2 device pixels per logical pixel.”
• `buffer2x` should be exactly double the width and height of the 1× image.

How Electron uses this internally.
When the image is used (tray icon, window icon, menu item, etc.), Electron:
1. Detects the display’s scale factor.
2. Chooses the closest matching representation.
3. Hands that bitmap to the OS without rescaling when possible.

Why this matters.
• Sharp icons on Retina / 4K displays.
• No manual DPI detection logic in your app.
• Correct behavior when a window is moved between monitors with different scale factors.

Important constraints.
1. The buffers must be raw image data in a supported format (usually PNG decoded into pixels, or bitmap data from `nativeImage`).
2. Width and height must align with the scale factor (e.g., 16×16 @1×, 32×32 @2×).
3. If a matching scale factor is missing, Electron will fall back and scale, reducing quality.

When you need to do this manually.
You typically do this only when:
• Constructing images dynamically.
• Loading images from nonstandard sources (binary streams, native addons).
• Building tray or dock icons programmatically.

If you are loading icons from files, Electron already does this automatically when you provide correctly named assets (for example, `icon.png`, `icon@2x.png` on macOS).

In summary, this pattern explicitly teaches `nativeImage` how to behave like a first-class, DPI-aware OS image by supplying multiple resolutions and letting the system choose correctly.

### Template Images (macOS)

On macOS, you can create template images that adapt to the system theme:

```javascript
const image = nativeImage.createFromPath('/path/to/icon.png')
image.setTemplateImage(true)
```

This snippet is specific to **macOS** and uses a concept called a **template image**.

Brief background on template images.  
On macOS, certain UI icons are not drawn with fixed colors. Instead, the system treats them as **masks** and automatically tints them based on context, such as light mode, dark mode, active/inactive state, or accessibility contrast settings.

What `setTemplateImage(true)` means.  
Calling `image.setTemplateImage(true)` tells macOS:  
“This image should be treated as a symbolic shape, not as a fully colored picture.”

Conceptual analogy.  
Think of a rubber stamp rather than a photograph.  
A photograph has fixed colors. A rubber stamp has only shape, and the ink color is chosen at the moment it is pressed. A template image is the rubber stamp.

Explanation of the code.

```javascript
const image = nativeImage.createFromPath('/path/to/icon.png')
```

This loads an image from disk into a `NativeImage`.

```javascript
image.setTemplateImage(true)
```

This marks the image as a template. From this point on:  
• The system ignores most original colors.  
• The alpha channel (transparency) defines the shape.  
• macOS applies the appropriate tint automatically.

Where template images are typically used.  
• Menu bar (status bar) icons.  
• Toolbar icons.  
• Sidebar icons in native-looking UIs.

Practical requirements for the image asset.

1. Use a **monochrome** image (usually black with transparency).
2. Avoid gradients, shadows, or multiple colors.
3. Ensure clean alpha edges; the shape quality directly affects rendering.

What happens if you do not use a template image.  
If you use a regular image:  
• It will keep its colors.  
• It may look incorrect in dark mode.  
• It will not automatically reflect active/inactive state changes.

Platform limitation.  
This behavior is **macOS-only**.  
On Windows and Linux, `setTemplateImage(true)` has no effect, because the concept does not exist in their native UI systems.

How this interacts with high-DPI.  
Template images still benefit from multiple scale factors (`@2x`, `@3x`). The system chooses the correct resolution first, then applies tinting.

In summary.  
`setTemplateImage(true)` tells macOS to treat your icon as a **theme-aware symbol**. You provide the shape; the system provides the color, ensuring correct appearance across light mode, dark mode, and different UI states.

### Practical Examples

**Setting an app icon:**

```javascript
const { app, nativeImage } = require('electron')

const icon = nativeImage.createFromPath('app-icon.png')
app.dock.setIcon(icon)  // macOS
```

**Creating a tray icon:**

```javascript
const { Tray, nativeImage } = require('electron')

const trayIcon = nativeImage.createFromPath('tray-icon.png')
const tray = new Tray(trayIcon)
```

**Processing images:**

```javascript
// Load, resize, and save
const original = nativeImage.createFromPath('large.png')
const thumbnail = original.resize({ width: 200, height: 200 })
const thumbnailBuffer = thumbnail.toPNG()
fs.writeFileSync('thumbnail.png', thumbnailBuffer)
```

The module integrates with other Electron APIs like `BrowserWindow` (for window icons), `Tray` (for system tray icons), and `Notification` (for notification icons).​​​​​​​​​​​​​​​​

---

## Resize setSize, setBounds

In **Electron**, there are two common ways to change a `BrowserWindow`’s dimensions: `setBounds` and `setSize`. They overlap but have different scopes and flexibility.

---

### 1. `setSize(width, height[, animate])`

* **Purpose:** Directly sets the window’s width and height.
* **Syntax:**

```js
win.setSize(width, height, animate);
```

* `width` / `height`: integers, pixels.

* `animate` (optional): `true` on macOS to animate the resize.

* **Example:**

```js
const { BrowserWindow } = require('electron');

let win = new BrowserWindow({ width: 800, height: 600 });

win.setSize(1024, 768); // resize window to 1024x768
```

* **Notes:**

  * Only changes size, not position.
  * Faster and simpler for just resizing.

---

### 2. `setBounds(bounds[, animate])`

* **Purpose:** Sets both **size and position** of the window in one call.
* **Syntax:**

```js
win.setBounds(bounds, animate);
```

* `bounds` is an object:

```js
{
  x: 100,    // left position on screen
  y: 100,    // top position on screen
  width: 1024,
  height: 768
}
```

* **Example:**

```js
win.setBounds({ x: 200, y: 100, width: 1280, height: 720 });
```

* **Notes:**

  * More flexible if you need to move and resize simultaneously.
  * On multi-monitor setups, coordinates relate to the primary display.

---

### Key Differences

| Feature                  | `setSize` | `setBounds` |
| ------------------------ | --------- | ----------- |
| Resize only              | ✅         | ✅           |
| Resize + move            | ❌         | ✅           |
| Accepts object           | ❌         | ✅           |
| Simpler for quick resize | ✅         | ❌           |
| Animation support        | ✅ (macOS) | ✅ (macOS)   |

---

**Analogy:**

* `setSize` is like **changing the dimensions of a picture frame without moving it**.
* `setBounds` is like **picking up the frame, moving it somewhere, and resizing it at the same time**.

---

# Concepts

## Process vs Frame

In Electron, the terms **“process”** and **“frame”** refer to different levels of execution and rendering. Understanding the distinction is key to grasping Electron’s architecture.

---

### 1. Process

Electron separates its runtime into multiple **processes**, similar to Chrome:
- **Main process**
    - Single process for the entire app.
    - Has full Node.js and Electron API access.
    - Controls windows, menus, file system, native modules, etc.
    - Runs your main script (e.g., `main.js`).
- **Renderer process**
    - Each `BrowserWindow` gets its own renderer process.
    - Runs HTML/CSS/JS for that window.
    - By default, **does not have Node.js access** if `nodeIntegration: false`.
    - Multiple tabs/windows = multiple renderer processes.
- **Utility processes**
    - Electron may spawn additional hidden processes for GPU, extensions, or sandboxing.
        

**Key point:** “Process” is a **running instance of Node.js/V8 with memory isolation**.

---

### 2. Frame

- A **frame** is a **subsection of a renderer process**, usually corresponding to an HTML `<iframe>` or web frame.
- A single renderer process can have **multiple frames**:
    

```html
<iframe src="https://example.com"></iframe>
```
- Each frame has:
    - Its own JavaScript context (`window`, `document`)
    - Its own isolated world if `contextIsolation` is used
    - Its own `window.postMessage` messaging scope
- In Electron terms:
    - `webContents` generally represents a **top-level frame** of a window.
    - You can access sub-frames via `webContents.mainFrame.frames` or `frame.frames`.
    - `executeJavaScriptInIsolatedWorld` can target specific frames.

---

### 3. How they relate

|Term|Scope|Notes|
|---|---|---|
|Process|OS-level isolated memory space|Main vs renderer; renderer per window; multiple renderers possible|
|Frame|Browser context inside renderer|Top frame or iframe; multiple frames per renderer; can have isolated JS contexts|

**Analogy:**
- **Process** = the entire building.
- **Frame** = a room inside the building.
- You can have multiple rooms (frames) in a building (process), and multiple buildings (renderer processes) in the city (Electron app).

---

### 4. Practical Electron implications

- `event.sender` (in `ipcMain`) → refers to **the renderer process’s webContents**, i.e., the whole process hosting the frame that sent the IPC.
- `frame` objects allow you to:
    - Target a specific iframe in `executeJavaScriptInIsolatedWorld`
    - Inspect or inject scripts into sub-frames
    - Send messages specifically to a frame without touching the whole renderer process

---

## isDestroyed vs isCrashed

In Electron, `webContents` exposes two different status-check methods: **`isDestroyed()`** and **`isCrashed()`**. They are related to the renderer process but measure **different conditions**.

---

### 1. `webContents.isDestroyed()`

* **What it checks:** Whether the `webContents` object itself has been **destroyed or dereferenced**.
* **When true:**

  * You called `win.destroy()` on the `BrowserWindow`
  * The window was closed and its `webContents` no longer exists
* **Implication:** You cannot interact with this `webContents` anymore; all methods will throw errors.

Example:

```js
const { BrowserWindow } = require('electron')
const win = new BrowserWindow()

console.log(win.webContents.isDestroyed()) // false
win.destroy()
console.log(win.webContents.isDestroyed()) // true
```

Analogy:

* `isDestroyed()` = “Is this window object **gone from memory**?”

---

### 2. `webContents.isCrashed()`

* **What it checks:** Whether the **renderer process** running inside this `webContents` has crashed.
* **When true:**

  * The renderer (the web page) has crashed due to an exception, segmentation fault, or GPU issue
  * The `webContents` object **still exists**, but the page is dead
* **Implication:** You may need to reload the page or recreate the renderer

Example:

```js
win.webContents.on('render-process-gone', (event, details) => {
  console.log('Renderer gone:', details)
  console.log('isCrashed?', win.webContents.isCrashed())
})
```

Analogy:

* `isCrashed()` = “Is the engine running this window **broken**, even if the window object still exists?”

---

### 3. Key differences

| Method          | Checks                                 | WebContents exists? | Example event                               |
| --------------- | -------------------------------------- | ------------------- | ------------------------------------------- |
| `isDestroyed()` | Object has been destroyed / cleaned up | No                  | `closed`                                    |
| `isCrashed()`   | Renderer process crashed               | Yes                 | `render-process-gone` with reason `crashed` |

* `isDestroyed()` → **object lifecycle**
* `isCrashed()` → **renderer process health**

---

In practice:

```js
if (!win.webContents.isDestroyed()) {
  if (win.webContents.isCrashed()) {
    win.reload() // recover from crash
  } else {
    win.webContents.send('ping', 'hello')
  }
}
```

This ensures you **don’t send messages to a dead or non-existent webContents**.

---

## `nodeIntegration` vs `contextIsolation`

Because **`nodeIntegration: false` only removes Node.js globals**, while **`contextIsolation: true` creates a hard JavaScript boundary**, they solve different threat classes. Without context isolation, the renderer and preload still share the same execution context, which allows privilege escalation even though Node.js is “disabled”.

Below is a precise explanation, with a concrete exploit-style example and an analogy.

---

### 1. What `nodeIntegration: false` actually does

With `nodeIntegration: false`:
- `require`, `process`, `fs`, etc. are **not injected into `window`**
- Renderer JavaScript looks like a normal browser environment
    

But:
- The **preload script still runs with full Node.js access**
- The preload runs **in the same JS world** as the renderer if `contextIsolation` is off
    

So the renderer cannot _start_ with Node.js, but it can **steal it**.

---

### 2. What happens without `contextIsolation`

**Preload (unsafe)**

```js
// preload.js
window.api = {
  readFile: (path) => require('fs').readFileSync(path, 'utf8')
}
```

**Renderer (attacker-controlled XSS)**

```js
// runs in page context
const original = window.api.readFile

window.api.readFile = (...args) => {
  console.log('Intercepted:', args)
  return original('/etc/passwd')
}
```

Why this works:
- Preload and renderer share the **same `window` object**
- Renderer can:
    - Replace functions
    - Redefine prototypes
    - Intercept privileged calls
    - Access closures indirectly
        

This is **privilege escalation**, not just information access.

---

### 3. What `contextIsolation: true` changes

With `contextIsolation: true`:
- Preload runs in a **separate JavaScript world**
- Renderer and preload do **not share `window`**
- Communication happens only through **explicitly bridged values**
    

Rewriting the preload safely:

```js
const { contextBridge } = require('electron')

contextBridge.exposeInMainWorld('api', {
  readFile: (path) => require('fs').readFileSync(path, 'utf8')
})
```

Now:
- Renderer sees a **copy of the function reference**
- Cannot overwrite internal logic
- Cannot intercept Node.js calls
- Cannot reach `require`, even indirectly
    

Analogy:  
Without context isolation, the renderer and preload sit at the **same desk**.  
With context isolation, they are separated by **bulletproof glass** and only pass sealed envelopes.

---

### 4. Why this is called “true security”

Security failures in Electron almost never come from:
- “Node.js was available”
    

They come from:
- Shared global state
- Prototype pollution
- Function replacement
- Closure capture
    

`nodeIntegration: false` removes the gun.  
Without `contextIsolation`, the attacker can still **grab the keys**.

---

### 5. Capability-based security model

With both enabled:
- Renderer gets **capabilities**, not power
- Each exposed function is:
    - Explicit
    - Auditable
    - Minimal
- No ambient authority exists
    

This matches modern security design used by:
- Browsers
- Sandboxed OS processes
- Microkernels

---

### 6. Final summary

- `nodeIntegration: false`  
    → “Do not give the renderer Node.js by default”
- `contextIsolation: true`  
    → “Do not let the renderer touch privileged code at all”
    

You need **both** because they protect against **different attack vectors**.

If you want, I can next show:
- A **real CVE-style exploit** that worked with nodeIntegration off but contextIsolation off
- A **diagram of JS worlds**
- How Electron internally enforces the isolation boundary

---

## Structured Clone Algorithm

The **Structured Clone Algorithm** is the mechanism browsers and Electron use to **copy complex JavaScript objects between contexts**, like between **main, renderer, worker threads, or even postMessage**. It’s what allows Electron’s IPC (`ipcRenderer.send`, `postMessage`) or `MessageChannel` to safely transfer data without giving direct access to the original objects.

Here’s the key breakdown:

---

### 1. **What it does**

- Makes a **deep copy** of objects so the sender and receiver don’t share memory.
- Preserves many JS types including:
    - Primitives (`string`, `number`, `boolean`, `null`, `undefined`, `bigint`, `symbol` not preserved fully)
    - Objects, Arrays
    - `Map`, `Set`
    - `Date`, `RegExp`, `Blob`, `File`, `ArrayBuffer`, `TypedArray`
    - `Error` objects
    - `ImageBitmap` and some other browser-specific objects
- **Cannot** clone functions, DOM nodes, or objects with circular references **without special handling** (though some contexts handle limited circular references).

---

### 2. **Why Electron uses it**

Electron uses it when sending messages between:
- **Main ↔ Renderer** (`ipcMain` / `ipcRenderer`)
- **Renderer ↔ Preload**
- **Web Workers or MessagePorts**

Because each process runs in its **own memory space**, you cannot directly pass an object; structured cloning safely duplicates it.

Example:

```javascript
// Renderer
ipcRenderer.send('data', { x: 10, y: [1, 2, 3] });

// Main
ipcMain.on('data', (_, obj) => {
  console.log(obj); // { x: 10, y: [1, 2, 3] }
});
```
- `obj` is a **clone** of what was sent. Modifying it in main will not affect the renderer object.

---

### 3. **Special Cases**

Some types are **transferred** instead of cloned using **Transferable objects** (like `ArrayBuffer`), which moves ownership rather than copying. This is faster for large buffers.

```javascript
const buffer = new ArrayBuffer(1024);
worker.postMessage(buffer, [buffer]); // buffer is now empty in main thread
```
- Normal structured clone would copy the buffer instead of transferring.

---

### 4. **Limitations**

- Functions and closures are not cloned.
- Symbols lose identity (`Symbol('x') !== Symbol('x')` after cloning).
- DOM nodes and other host-specific objects cannot be cloned.
- Circular references are supported in most modern environments, but older versions may fail.

---

**Analogy:**  
Think of structured clone like **photocopying a document**. You can give the copy to someone else without letting them touch the original. Certain objects (like functions or live DOM nodes) are like “handwritten notes with invisible ink”—they can’t be photocopied.

---

If you want, I can also make a **table of all object types supported vs unsupported** in Electron’s structured clone, which is very practical when designing IPC messages. Do you want me to make that?

## **webContents**

### **What is webContents?**

webContents is an EventEmitter responsible for rendering and controlling a web page and is a property of the BrowserWindow object.

**Basic access example:**
```javascript
const { BrowserWindow } = require('electron')

const win = new BrowserWindow({ width: 800, height: 1500 })
win.loadURL('https://github.com')

const contents = win.webContents
console.log(contents)
```

---

### **Core Concepts**

#### **1. Module-Level Methods**

These methods can be accessed from the webContents module directly:

```javascript
const { webContents } = require('electron')

// Get all WebContents instances
webContents.getAllWebContents()

// Get focused WebContents
webContents.getFocusedWebContents()

// Get WebContents by ID
webContents.fromId(id)
```

---

### **Navigation Events**

Several events can be used to monitor navigations as they occur within a webContents.

#### **Document Navigation Events** (in order):
1. `did-start-navigation`
2. `will-frame-navigate`
3. `will-navigate` (main frame only)
4. `will-redirect` (if redirect occurs)
5. `did-redirect-navigation` (if redirect occurs)
6. `did-frame-navigate`
7. `did-navigate` (main frame only)

#### **In-Page Navigation Events**:
1. `did-start-navigation`
2. `did-navigate-in-page`

In-page navigations don't cause the page to reload, but instead navigate to a location within the current page, such as when anchor links are clicked or when the DOM hashchange event is triggered.

---

### **Key Instance Events**

#### **Loading Events**
- `did-finish-load` - Navigation completed
- `did-fail-load` - Load failed
- `did-start-loading` - Tab spinner starts
- `did-stop-loading` - Tab spinner stops
- `dom-ready` - Document loaded

#### **User Interaction Events**
- `before-input-event` - Before keyboard events
- `context-menu` - Right-click menu
- `found-in-page` - Search results available

#### **Window Events**
- `did-create-window` - New window created via window.open
- `will-prevent-unload` - beforeunload handler attempting to cancel

#### **Process Events**
- `render-process-gone` - Renderer crashed or killed
- `unresponsive` - Page becomes unresponsive
- `responsive` - Page becomes responsive again

#### **DevTools Events**
- `devtools-opened`
- `devtools-closed`
- `devtools-focused`

#### **Media Events**
- `media-started-playing`
- `media-paused`
- `audio-state-changed`

---

### **Essential Instance Methods**

#### **Page Loading**

```javascript
// Load URL
await contents.loadURL('https://example.com', {
  httpReferrer: 'https://referrer.com',
  userAgent: 'Custom UA',
  extraHeaders: 'pragma: no-cache\n'
})

// Load local file
await contents.loadFile('src/index.html')

// Download file
contents.downloadURL('https://example.com/file.zip')

// Get current URL
const url = contents.getURL()

// Get page title
const title = contents.getTitle()
```

#### **Navigation**

```javascript
// Navigation history (deprecated - use navigationHistory API instead)
contents.canGoBack()
contents.canGoForward()
contents.goBack()
contents.goForward()

// Reload
contents.reload()
contents.reloadIgnoringCache()

// Stop loading
contents.stop()
```

#### **Code Execution**

```javascript
// Execute JavaScript
const result = await contents.executeJavaScript('1 + 1')

// Execute in isolated world
await contents.executeJavaScriptInIsolatedWorld(999, [
  { code: 'console.log("hello")' }
])
```

#### **CSS Injection**

```javascript
// Insert CSS
const key = await contents.insertCSS('body { background: red; }', {
  cssOrigin: 'user' // or 'author'
})

// Remove CSS
await contents.removeInsertedCSS(key)
```

#### **IPC Communication**

```javascript
// Send to renderer
contents.send('channel-name', data)

// Send to specific frame
contents.sendToFrame(frameId, 'channel-name', data)

// Post message with MessagePort
const { port1, port2 } = new MessageChannelMain()
contents.postMessage('port', { message: 'hello' }, [port1])
```

#### **Page Capture**

```javascript
// Capture screenshot
const image = await contents.capturePage({
  x: 0, y: 0, width: 800, height: 600
})

// Save page
await contents.savePage('/tmp/page.html', 'HTMLComplete')
// Save types: 'HTMLOnly', 'HTMLComplete', 'MHTML'
```

#### **Printing**

```javascript
// Print to printer
contents.print({
  silent: false,
  printBackground: true,
  deviceName: 'My-Printer',
  color: true,
  margins: { marginType: 'default' },
  landscape: false,
  scaleFactor: 1,
  pagesPerSheet: 1
}, (success, failureReason) => {
  console.log(success ? 'Printed!' : failureReason)
})

// Print to PDF
const pdfData = await contents.printToPDF({
  landscape: false,
  displayHeaderFooter: false,
  printBackground: false,
  scale: 1,
  pageSize: 'A4',
  margins: { top: 0, bottom: 0, left: 0, right: 0 },
  pageRanges: '1-5',
  preferCSSPageSize: false
})
```

#### **Search**

```javascript
// Find in page
const requestId = contents.findInPage('search term', {
  forward: true,
  findNext: false,
  matchCase: false
})

// Listen for results
contents.on('found-in-page', (event, result) => {
  if (result.finalUpdate) {
    contents.stopFindInPage('clearSelection')
  }
})
```

#### **Zoom**

```javascript
// Set zoom factor (1.0 = 100%)
contents.setZoomFactor(1.5)

// Get zoom factor
const factor = contents.getZoomFactor()

// Set zoom level (0 = 100%, each increment = 20%)
contents.setZoomLevel(2) // 140%

// Get zoom level
const level = contents.getZoomLevel()

// Set visual zoom limits
await contents.setVisualZoomLevelLimits(1, 3)
```

#### **DevTools**

```javascript
// Open DevTools
contents.openDevTools({ mode: 'detach', activate: true })

// Close DevTools
contents.closeDevTools()

// Toggle DevTools
contents.toggleDevTools()

// Check if open
const isOpen = contents.isDevToolsOpened()

// Inspect element
contents.inspectElement(x, y)

// Add workspace
contents.addWorkSpace(__dirname)
```

#### **Editing Commands**

```javascript
contents.undo()
contents.redo()
contents.cut()
contents.copy()
contents.paste()
contents.pasteAndMatchStyle()
contents.delete()
contents.selectAll()
contents.unselect()
```

#### **Focus & State**

```javascript
// Focus
contents.focus()
const isFocused = contents.isFocused()

// Loading state
const isLoading = contents.isLoading()
const isLoadingMainFrame = contents.isLoadingMainFrame()
const isWaitingForResponse = contents.isWaitingForResponse()

// Check if destroyed
const isDestroyed = contents.isDestroyed()

// Check if crashed
const isCrashed = contents.isCrashed()

// Force crash (for recovery)
contents.forcefullyCrashRenderer()
```

#### **Audio Control**

```javascript
// Mute
contents.setAudioMuted(true)

// Check mute state
const isMuted = contents.isAudioMuted()

// Check if playing audio
const isAudible = contents.isCurrentlyAudible()
```

#### **Advanced Features**

```javascript
// Device emulation
contents.enableDeviceEmulation({
  screenPosition: 'mobile',
  screenSize: { width: 375, height: 667 },
  deviceScaleFactor: 2
})
contents.disableDeviceEmulation()

// Send input events
contents.sendInputEvent({
  type: 'mouseDown',
  x: 100,
  y: 100,
  button: 'left'
})

// Set user agent
contents.setUserAgent('Custom User Agent')

// WebRTC IP handling
contents.setWebRTCIPHandlingPolicy('default_public_interface_only')
```

#### **Offscreen Rendering**

```javascript
// Check offscreen state
const isOffscreen = contents.isOffscreen()

// Control painting
contents.startPainting()
contents.stopPainting()
const isPainting = contents.isPainting()

// Set frame rate
contents.setFrameRate(60)
const fps = contents.getFrameRate()

// Listen for frames
contents.on('paint', (event, dirty, image) => {
  // image is a NativeImage
  // dirty is a Rectangle with repainted area
})
```

---

### **Instance Properties**

Key properties of WebContents include:

- **`id`** - Integer - Unique ID of this WebContents
- **`session`** - Session used by this webContents
- **`navigationHistory`** - NavigationHistory instance
- **`hostWebContents`** - WebContents that might own this WebContents
- **`devToolsWebContents`** - WebContents for DevTools (may be null)
- **`debugger`** - Debugger instance
- **`backgroundThrottling`** - boolean - Whether to throttle animations when backgrounded
- **`mainFrame`** - WebFrameMain - Top frame of page's frame hierarchy
- **`opener`** - WebFrameMain | null - Frame that opened this WebContents
- **`ipc`** - IpcMain-like interface for this specific WebContents

---

### **Common Use Cases**

#### **1. Handling New Windows**

```javascript
contents.setWindowOpenHandler(({ url, frameName, features }) => {
  if (url.startsWith('https://trusted-domain.com')) {
    return { action: 'allow' }
  }
  return { action: 'deny' }
})

contents.on('did-create-window', (window, details) => {
  console.log('New window created:', details.url)
})
```

#### **2. Secure IPC**

```javascript
// Main process
contents.send('update-data', { value: 42 })

// Listen to specific WebContents
contents.ipc.on('channel', (event, data) => {
  console.log('Received from this WebContents:', data)
})
```

#### **3. Certificate Errors**

```javascript
contents.on('certificate-error', (event, url, error, certificate, callback) => {
  event.preventDefault()
  // Perform custom validation
  callback(isValid)
})
```

#### **4. Page Recovery**

```javascript
contents.on('unresponsive', async () => {
  const { response } = await dialog.showMessageBox({
    message: 'Page is unresponsive',
    buttons: ['Reload', 'Wait']
  })
  
  if (response === 0) {
    contents.forcefullyCrashRenderer()
    contents.reload()
  }
})
```

---

### **Important Notes**

1. **Context Isolation**: When using executeJavaScriptInIsolatedWorld, world ID 999 is used by Electron's contextIsolation feature

2. **Event Prevention**: Calling event.preventDefault() on cancellable navigation events will prevent the navigation

3. **Frame vs Main Frame**: will-navigate and did-navigate only fire when the mainFrame navigates. For iframe navigation, use will-frame-navigate and did-frame-navigate

4. **Zoom Policy**: The zoom policy at the Chromium level is same-origin, meaning zoom level propagates across all instances of windows with the same domain

5. **Printing**: Calling window.print() in web page is equivalent to calling webContents.print with default settings
---

I'll search for comprehensive information about `event.sender` in Electron's IPC system.Perfect! Now I have comprehensive information about `event.sender` in Electron's IPC system. Let me provide you with a detailed overview.

---

## **`IpcMainEvent` and `event.sender`**

### **What is event.sender?**

event.sender is a property of the IpcMainEvent object that returns the webContents that sent the message. It's essentially a reference to the WebContents instance of the renderer process that initiated the IPC communication.

---

### **The IpcMainEvent Object**

When you handle IPC messages in the main process, the event object contains several important properties:

The IpcMainEvent object extends Event and includes the following properties:

```javascript
{
  type: 'frame',                    // String - Event type
  processId: 1234,                  // Integer - Renderer process ID
  frameId: 5678,                    // Integer - Renderer frame ID
  returnValue: undefined,           // For synchronous messages
  sender: WebContents,              // The webContents that sent the message
  senderFrame: WebFrameMain | null, // The frame that sent the message
  ports: [],                        // MessagePortMain[] - transferred ports
  reply: Function                   // Function to reply to sender
}
```

---

### **event.sender vs event.reply()**

#### **Key Difference**

event.reply() is a helper method that will automatically handle messages coming from frames that aren't the main frame (e.g. iframes) whereas event.sender.send() will always send to the main frame.

#### **When to Use Each**

**Use `event.reply()`** (Recommended):
```javascript
ipcMain.on('channel', (event, data) => {
  // Replies to the exact frame that sent the message
  event.reply('response-channel', 'response data')
})
```

**Use `event.sender.send()`**:
```javascript
ipcMain.on('channel', (event, data) => {
  // Always sends to the main frame
  event.sender.send('response-channel', 'response data')
})
```

---

### **Common Use Cases**

#### **1. Basic Asynchronous Reply**

To send an asynchronous message back to the sender, you can use event.sender.send():

```javascript
// Main process
const { ipcMain } = require('electron')

ipcMain.on('asynchronous-message', (event, arg) => {
  console.log(arg) // prints "ping"
  event.sender.send('asynchronous-reply', 'pong')
})

// Renderer process
const { ipcRenderer } = require('electron')

ipcRenderer.on('asynchronous-reply', (event, arg) => {
  console.log(arg) // prints "pong"
})

ipcRenderer.send('asynchronous-message', 'ping')
```

#### **2. Synchronous Reply**

To reply to a synchronous message, you need to set event.returnValue:

```javascript
// Main process
ipcMain.on('synchronous-message', (event, arg) => {
  console.log(arg) // prints "ping"
  event.returnValue = 'pong'
})

// Renderer process
const reply = ipcRenderer.sendSync('synchronous-message', 'ping')
console.log(reply) // prints "pong"
```

#### **3. Accessing sender WebContents**

Since `event.sender` is a WebContents instance, you have access to all WebContents methods:

```javascript
ipcMain.on('get-window-info', (event) => {
  const sender = event.sender
  
  // Get information
  const url = sender.getURL()
  const title = sender.getTitle()
  const id = sender.id
  
  // Manipulate the window
  sender.openDevTools()
  sender.setZoomFactor(1.5)
  
  // Send data back
  event.reply('window-info', { url, title, id })
})
```

#### **4. Sending to Specific Frame**

```javascript
ipcMain.on('message-from-iframe', (event, data) => {
  // Get frame information
  const frameId = event.frameId
  const processId = event.processId
  
  // Reply to specific frame
  event.sender.sendToFrame(frameId, 'response', 'data')
  
  // Or use event.reply() which handles this automatically
  event.reply('response', 'data')
})
```

#### **5. Broadcasting to All Windows**

```javascript
ipcMain.on('broadcast-request', (event, message) => {
  // Get all webContents
  const { webContents } = require('electron')
  
  webContents.getAllWebContents().forEach(wc => {
    // Don't send back to the sender
    if (wc.id !== event.sender.id) {
      wc.send('broadcast', message)
    }
  })
  
  // Acknowledge to sender
  event.reply('broadcast-sent', true)
})
```

#### **6. Validating Sender**

```javascript
ipcMain.on('secure-operation', (event, data) => {
  const sender = event.sender
  const url = sender.getURL()
  
  // Validate the sender
  if (url.startsWith('file://') || url.startsWith('https://trusted-domain.com')) {
    // Process the request
    event.reply('operation-result', processData(data))
  } else {
    console.warn('Unauthorized IPC request from:', url)
    event.reply('operation-error', 'Unauthorized')
  }
})
```

---

### **Important Properties of event.sender**

Since `event.sender` is a WebContents instance, you can use:

```javascript
ipcMain.on('channel', (event) => {
  const sender = event.sender
  
  // Identification
  sender.id                    // Unique ID
  sender.getURL()              // Current URL
  sender.getTitle()            // Page title
  
  // State
  sender.isLoading()           // Is loading?
  sender.isFocused()           // Is focused?
  sender.isDestroyed()         // Is destroyed?
  sender.isCrashed()           // Is crashed?
  
  // Navigation
  sender.loadURL(url)
  sender.reload()
  sender.goBack()
  sender.goForward()
  
  // Communication
  sender.send(channel, ...args)
  sender.sendToFrame(frameId, channel, ...args)
  
  // Control
  sender.focus()
  sender.setZoomFactor(factor)
  sender.openDevTools()
  sender.executeJavaScript(code)
})
```

---

### **Security Considerations**

#### **1. Never Expose event.sender to Renderer**

Don't just pass the callback to ipcRenderer.on as this will leak ipcRenderer via event.sender. Use a custom handler that invokes the callback only with the desired arguments.

**Bad (Security Risk):**
```javascript
// Preload script - DON'T DO THIS
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => {
    // This exposes the entire event object including sender
    ipcRenderer.on('update', callback)
  }
})
```

**Good (Secure):**
```javascript
// Preload script - DO THIS
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => {
    // Only pass the data, not the event
    ipcRenderer.on('update', (_event, data) => {
      callback(data)
    })
  }
})
```

#### **2. Validate Sender Origin**

```javascript
ipcMain.on('sensitive-operation', (event, data) => {
  const senderURL = event.sender.getURL()
  const allowedOrigins = ['file://', 'https://myapp.com']
  
  const isAllowed = allowedOrigins.some(origin => 
    senderURL.startsWith(origin)
  )
  
  if (!isAllowed) {
    console.error('Unauthorized IPC request from:', senderURL)
    return
  }
  
  // Process the request
  processSensitiveOperation(data)
})
```

#### **3. Check if Sender Still Exists**

```javascript
ipcMain.on('delayed-operation', async (event, data) => {
  const result = await longRunningOperation(data)
  
  // Check if sender still exists before replying
  if (!event.sender.isDestroyed()) {
    event.reply('operation-complete', result)
  }
})
```

---

### **Advanced Patterns**

#### **1. Tracking Multiple Senders**

```javascript
const senderMap = new Map()

ipcMain.on('register-window', (event, windowName) => {
  senderMap.set(windowName, event.sender)
  
  // Clean up when destroyed
  event.sender.on('destroyed', () => {
    senderMap.delete(windowName)
  })
})

// Later, send to specific window
function sendToWindow(windowName, channel, data) {
  const sender = senderMap.get(windowName)
  if (sender && !sender.isDestroyed()) {
    sender.send(channel, data)
  }
}
```

#### **2. Request-Response with Timeout**

```javascript
ipcMain.on('request-with-timeout', async (event, data) => {
  try {
    const result = await Promise.race([
      processRequest(data),
      new Promise((_, reject) => 
        setTimeout(() => reject('Timeout'), 5000)
      )
    ])
    
    if (!event.sender.isDestroyed()) {
      event.reply('request-result', { success: true, result })
    }
  } catch (error) {
    if (!event.sender.isDestroyed()) {
      event.reply('request-result', { success: false, error: error.message })
    }
  }
})
```

#### **3. Bidirectional Communication**

```javascript
// Main process
ipcMain.on('start-monitoring', (event) => {
  const senderId = event.sender.id
  
  const interval = setInterval(() => {
    if (event.sender.isDestroyed()) {
      clearInterval(interval)
      return
    }
    
    event.sender.send('monitoring-update', {
      timestamp: Date.now(),
      data: getMonitoringData()
    })
  }, 1000)
  
  event.sender.once('destroyed', () => {
    clearInterval(interval)
  })
})
```

---

### **Common Mistakes to Avoid**

#### **1. Using sender after it's destroyed**

```javascript
// BAD
ipcMain.on('async-operation', async (event) => {
  await longOperation()
  event.sender.send('result', data) // sender might be destroyed!
})

// GOOD
ipcMain.on('async-operation', async (event) => {
  const result = await longOperation()
  if (!event.sender.isDestroyed()) {
    event.sender.send('result', data)
  }
})
```

#### **2. Confusing sender.send() with event.reply()**

```javascript
// For iframe communication, prefer event.reply()
ipcMain.on('iframe-message', (event, data) => {
  // This goes to main frame only
  event.sender.send('response', data) 
  
  // This goes back to the exact frame that sent it
  event.reply('response', data) // ✓ Better for iframes
})
```

#### **3. Memory leaks with event listeners**

```javascript
// BAD - Creates a new listener every time
ipcMain.on('setup', (event) => {
  event.sender.on('will-navigate', () => {
    // This listener is never removed!
  })
})

// GOOD - Clean up properly
ipcMain.on('setup', (event) => {
  const handler = () => {
    console.log('Navigating...')
  }
  
  event.sender.on('will-navigate', handler)
  event.sender.once('destroyed', () => {
    event.sender.off('will-navigate', handler)
  })
})
```

---

### **Summary**

**event.sender is:**
- A WebContents instance representing the sender
- Used to reply to IPC messages
- Has full access to WebContents API
- Should be checked for destruction before use
- Should NOT be exposed to the renderer process

**Prefer event.reply() over event.sender.send() for:**
- Better iframe support
- Automatic frame routing
- Cleaner code

**Always:**
- Validate sender origin for security
- Check if sender is destroyed before replying
- Never expose event or event.sender to renderer

---



## Provisional Load

**Event:** `did-fail-provisional-load`  
**Emitted on:** `webContents` of a `BrowserWindow`  
**When it occurs:** When a **navigation fails at the provisional load stage**—basically, the browser tried to start loading a URL, but it failed **before committing** the load.

**Common reasons for failure:**

- Invalid URL (e.g., `htp://example.com`)
- Network issues (DNS failure, no internet)
- Blocked by security policies (CSP, HTTPS issues)
- Window or tab being closed before the page loaded
    

**Listener example:**

```javascript
const { BrowserWindow } = require('electron');

const win = new BrowserWindow({ /* options */ });

win.webContents.on('did-fail-provisional-load', (event, url, isMainFrame, errorCode, errorDescription) => {
  console.log(`Failed to load: ${url}`);
  console.log(`Error code: ${errorCode} - ${errorDescription}`);
  console.log(`Is main frame? ${isMainFrame}`);
});
```

**Parameters:**

1. `event` – the event object
    
2. `url` – URL that failed to load
    
3. `isMainFrame` – `true` if the main frame failed, `false` for an iframe
    
4. `errorCode` – numeric code of the failure (e.g., `-105` for `ERR_NAME_NOT_RESOLVED`)
    
5. `errorDescription` – human-readable error message
    

**Key distinction:**

- `did-fail-provisional-load` happens **before the page starts committing**.
    
- `did-fail-load` happens **after the load started but failed**.
    

So, if you want to handle network errors **before anything renders**, listen to `did-fail-provisional-load`. If you want to catch **mid-load failures**, use `did-fail-load`.


---

## Handoff

In the context of macOS and Electron, **Handoff** is part of Apple’s **Continuity** features that allow an activity started on one device to continue on another, like Safari tabs, emails, or app actions. Electron doesn’t have built-in high-level support for Handoff, but you can work with it using the **`NSUserActivity` API** through a native macOS bridge (Objective-C/Swift) or a Node native module.

Here’s a structured explanation:

---

### 1. **Understanding Handoff / NSUserActivity**

* `NSUserActivity` represents an activity a user is doing (reading, editing, viewing, etc.).
* You assign it a **unique activity type**, a **title**, and optionally **user info** (metadata).
* Other devices detect this activity if they are signed into the same iCloud account, and they can continue the task.

Key properties:

* `activityType`: string identifier (e.g., `com.yourapp.edit-document`)
* `title`: user-facing description
* `userInfo`: dictionary with extra metadata
* `requiredUserInfoKeys`: keys that must be included for handoff
* `webpageURL`: optional, for linking Handoff to a web page

You also **call `becomeCurrent`** when the activity is active and `invalidate` when it’s done.

---

### 2. **Integrating with Electron**

Electron cannot directly access `NSUserActivity`, so you have to bridge native code:

**Options:**

1. **Native macOS module**

   * Create a small native macOS app module in Objective-C/Swift.
   * Expose a Node.js addon or CLI interface to Electron.
   * Example workflow:

     * Electron triggers a `startActivity(activityType, title, userInfo)` call.
     * Native code creates an `NSUserActivity` and calls `becomeCurrent`.
     * When done, call `invalidate`.

2. **Electron + AppleScript / Automator (simpler, limited)**

   * Use AppleScript to trigger macOS system activities.
   * Limited control and harder for dynamic activity data.

3. **Third-party modules**

   * There may be community Node modules for Handoff or NSUserActivity (though uncommon).
   * Usually require building a native macOS binary.

---

### 3. **Example: Conceptual Native Bridge**

**Swift (macOS app or framework)**

```swift
import Cocoa

@objc class HandoffBridge: NSObject {
    var activity: NSUserActivity?

    @objc func startActivity(type: String, title: String, info: [String: Any]) {
        activity = NSUserActivity(activityType: type)
        activity?.title = title
        activity?.userInfo = info
        activity?.becomeCurrent()
    }

    @objc func endActivity() {
        activity?.invalidate()
        activity = nil
    }
}
```

**Electron (Node.js call)**

```javascript
const { execFile } = require('child_process');

// Trigger native binary that starts NSUserActivity
execFile('/path/to/handoff-bridge', ['start', 'com.yourapp.view', 'Viewing Document', '{"docId":42}']);
```

---

### 4. **Listening on the Other Device**

* macOS devices automatically detect `NSUserActivity` over iCloud.
* When your app launches, you need to handle continuation:

```swift
func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == "com.yourapp.view-document" {
        let docId = userActivity.userInfo?["docId"]
        // Open the document in your app
    }
    return true
}
```

---

### 5. **Key Considerations**

* Handoff works only between Apple devices signed into the same iCloud account.
* Requires **App Sandbox** entitlements for macOS apps if distributed via the App Store.
* Electron’s `.app` bundle must include the native code in `Contents/Frameworks` or `Contents/Resources`.

---

## RSS

RSS (Resident Set Size) is the total memory currently held in physical RAM by a process. It includes JavaScript heap, native allocations (C/C++), memory-mapped files, buffers, and Electron/Chromium internals.

The JavaScript heap is only the memory managed by V8’s garbage collector. Heap snapshots and heap graphs only reflect this portion.

An analogy: think of the heap as the furniture inside a warehouse, and RSS as the entire warehouse building plus everything stored around it. You can remove furniture and still have a growing warehouse.

Why IPC listeners cause RSS growth.

IPC listeners (`ipcMain.on`, `ipcRenderer.on`) create native-backed event subscriptions. These are not just JavaScript objects; they involve:

• Native C++ structures in Electron
• References held by the event emitter
• Closures capturing renderer state
• Message channel infrastructure

If a window is closed but its IPC listeners remain registered, Electron still retains native references to them. V8 may reclaim the JavaScript objects, but the native side does not fully release the associated memory.

As a result:
• Heap snapshots look stable
• RSS steadily increases
• Memory is never returned to the OS

This is why you see “no leak” in heap tools but growing RSS.

Why garbage collection does not help.

V8 garbage collection only applies to objects it owns. IPC wiring lives partially outside V8.

Analogy: garbage collection is like cleaning your desk. IPC leaks are like forgetting to cancel a rented storage unit. Cleaning your desk does not return the storage unit.

Common IPC leak patterns.
1. Registering listeners per window but never removing them.

```js
ipcMain.on('status', handler);
```

If this runs every time a window is created, the handlers accumulate.
2. Using anonymous functions, making removal impossible.

```js
ipcMain.on('event', () => { ... });
```

You cannot later call `removeListener` because there is no reference.
3. Renderer listeners that survive reloads.

```js
ipcRenderer.on('update', handler);
```

Hot reloads or window reloads stack listeners silently.
4. `contextBridge.exposeInMainWorld` functions that internally attach IPC listeners repeatedly.

These are especially dangerous because they look “safe” but run multiple times.

Why Electron is especially sensitive.

Electron combines:
• Node.js event emitters
• Chromium processes
• Native IPC channels

RSS memory fragmentation is common. Even when memory is freed internally, it may never be returned to the OS, so RSS continues to climb.

This is expected behavior but becomes a problem when listeners accumulate indefinitely.

How to fix and prevent it.

In the main process, scope listeners to window lifetime.

```js
function registerIpc(win) {
  const handler = (event, data) => { ... };

  ipcMain.on('event', handler);

  win.on('closed', () => {
    ipcMain.removeListener('event', handler);
  });
}
```

Prefer `ipcMain.handle` over `ipcMain.on` for request/response patterns.

```js
ipcMain.handle('get-data', async () => { ... });
```

Handlers are singleton-style and safer.

In the renderer, clean up on unload.

```js
const handler = (_, data) => { ... };

ipcRenderer.on('update', handler);

window.addEventListener('beforeunload', () => {
  ipcRenderer.removeListener('update', handler);
});
```

Avoid registering IPC listeners inside:
• React render paths
• Repeated preload executions
• Window creation loops without guards

How to confirm this diagnosis.

If RSS increases while:
• Heap stays flat
• GC runs successfully
• CPU is normal

And RSS growth correlates with:
• Window creation/destruction
• Reloads
• IPC-heavy traffic

Then this is almost certainly IPC or native resource leakage, not a JavaScript heap leak.

Key takeaway.

IPC listeners that are never removed do not necessarily leak JavaScript memory, but they do leak native memory. That native memory contributes to RSS, which is why RSS grows even when heap analysis shows no leaks.

This distinction—heap vs native—is the critical insight for diagnosing Electron memory issues.

---

## Memory-mapped files

Memory-mapped files are a core reason why RSS can grow in Electron/Node.js processes without showing up as heap leaks.

I will explain what they are, how they relate to RSS, why Electron uses them heavily, and why they are often misdiagnosed as “mystery leaks”.

Background: what “memory-mapped” means.

A memory-mapped file is a file whose contents are mapped directly into a process’s virtual memory space by the operating system. Instead of calling `read()` and copying bytes into a buffer, the OS lets the process treat file contents as if they were memory.

Analogy: rather than photocopying pages from a book onto your desk (heap allocation), the OS lets you open the book and read directly from it on the shelf. The shelf space still belongs to you while the book is open.

Key properties.

• Pages are loaded on demand (page faults)
• Pages live in RSS once touched
• Memory is managed by the OS, not V8
• Appears in RSS, not in JS heap
• May not be immediately released back to the OS

Why RSS increases but heap does not.

Heap tools only track memory allocated by V8. Memory-mapped pages are:

• Allocated by the kernel
• Accounted to the process’s RSS
• Invisible to heap snapshots

So RSS grows, but heap graphs stay flat.

Analogy: the desk (heap) is clean, but the room (RSS) is full of open books.

Where memory-mapped files come from in Electron.

Electron uses memory-mapped files extensively:
1. Chromium resource loading
   HTML, JS, CSS, fonts, images, WASM files
2. `app.asar` access
   ASAR files are accessed via mmap for fast random reads
3. SQLite / IndexedDB
   Databases often use mmap internally
4. V8 code cache and snapshots
   Compiled bytecode and snapshots are memory-mapped
5. Native modules and shared libraries
   `.so`, `.dll`, `.dylib` are mmap’d into memory
6. GPU buffers and shared memory segments
   Often backed by mmap

None of these are “heap allocations”.

Why memory is not returned immediately.

Even when a memory-mapped file is no longer actively used:

• The OS may keep pages resident for caching
• The virtual address space may remain mapped
• RSS may not shrink even though pages are reclaimable

This is normal OS behavior, not necessarily a leak.

Analogy: you close the book, but the librarian keeps it on your desk because you might reopen it soon.

When memory-mapped files become a real leak.

They become problematic when mappings are never released:

• File descriptors not closed
• Windows/processes holding references indefinitely
• IPC listeners keeping file handles alive
• Native modules failing to unmap

In Electron, leaked BrowserWindows and IPC handlers commonly keep mmapped resources alive.

How this ties back to IPC listeners.

An IPC listener can capture:

• A BrowserWindow reference
• A preload module
• A native handle

As long as that listener exists, the window’s mmapped resources remain reachable:

• JS bundle
• ASAR pages
• Renderer code cache

Heap GC may run, but native mmaps remain pinned.

How to verify memory-mapped file usage.

On Linux:

```
pmap -x <pid>
```

or

```
cat /proc/<pid>/smaps
```

Look for:
• Large `File` mappings
• `r--p` or `rw-p` regions
• ASAR, SQLite, or Chromium resource files

On macOS:

```
vmmap <pid>
```

On Windows:
• VMMap (Sysinternals)

If RSS is dominated by `file-backed` mappings, this explains the behavior.

Key takeaway.

Memory-mapped files live outside the JavaScript heap. They increase RSS, persist due to OS caching, and are heavily used by Electron. IPC listeners and window lifecycle bugs often prevent these mappings from being released, creating the appearance of a memory leak even when heap analysis shows nothing wrong.

Understanding mmap vs heap is essential for correctly diagnosing Electron memory growth.

---

## Surviving Listeners Across Reloads

This can happen very easily in Electron, and it is one of the most common IPC-related memory and behavior bugs. I will explain the mechanism precisely, then give concrete prevention patterns.

Why reloads stack `ipcRenderer` listeners.

A renderer reload (`window.location.reload()`, `BrowserWindow.reload()`, DevTools hot reload, or framework HMR) does **not** necessarily restart the entire Electron renderer process. What usually happens is:

• The JavaScript context is re-executed  
• Preload may or may never re-run, depending on configuration  
• The underlying IPC channel remains alive  
• Existing listeners are still registered

`ipcRenderer` is backed by a native EventEmitter that survives reloads unless the process itself exits.

Analogy: reloading is like restarting a program’s “main function” without rebooting the computer. Global hooks stay attached.

What exactly stacks.

Each reload executes:

```js
ipcRenderer.on('update', handler);
```

again.

If the previous listener was never removed, you now have:

• Listener #1 (old)  
• Listener #2 (new)  
• Listener #3 (after another reload)

Every IPC message now fires all of them.

Why this is silent and dangerous.

• No error is thrown  
• Messages still “work”  
• Memory grows gradually  
• Effects multiply (duplicate UI updates, duplicated logs, etc.)

Electron does not warn because `EventEmitter` allows unlimited listeners by default.

How this happens in practice.

Common patterns that cause it:

1. Listener registration in top-level renderer code.
    

```js
// renderer.js
ipcRenderer.on('update', handler);
```

Every reload re-executes this file.

2. Listener registration inside React/Vue/Svelte component bodies without cleanup.
    

```js
useEffect(() => {
  ipcRenderer.on('update', handler);
}, []);
```

On hot reload, effects re-run without unmounting the old tree.

3. Listener registration inside preload exposed APIs that run more than once.
    

```js
contextBridge.exposeInMainWorld('api', {
  onUpdate: (cb) => ipcRenderer.on('update', cb)
});
```

Each call attaches a new listener.

Why garbage collection does not help.

`ipcRenderer.on` registers the handler on a native-backed emitter. Even if the JS function becomes unreachable, the native emitter still holds a reference to it.

Heap GC cannot collect it.

How to prevent this reliably.

1. Always remove listeners explicitly.
    

```js
const handler = (_, data) => { ... };

ipcRenderer.on('update', handler);

window.addEventListener('beforeunload', () => {
  ipcRenderer.removeListener('update', handler);
});
```

This ensures cleanup on reload and navigation.

2. Prefer `once` when appropriate.
    

If you only expect one message:

```js
ipcRenderer.once('update', handler);
```

This auto-removes after first execution.

3. Guard against duplicate registration.
    

```js
let registered = false;

if (!registered) {
  ipcRenderer.on('update', handler);
  registered = true;
}
```

This is crude but effective in simple setups.

4. Use a subscription API that returns an unsubscribe function (best practice).
    

In preload:

```js
contextBridge.exposeInMainWorld('api', {
  onUpdate: (cb) => {
    ipcRenderer.on('update', cb);
    return () => ipcRenderer.removeListener('update', cb);
  }
});
```

In renderer:

```js
const unsubscribe = window.api.onUpdate(handler);

// on reload / unmount
unsubscribe();
```

Analogy: you check in and get a receipt; when you leave, you hand the receipt back.

5. In frameworks, always clean up effects.
    

React example:

```js
useEffect(() => {
  const handler = (_, data) => { ... };

  ipcRenderer.on('update', handler);

  return () => {
    ipcRenderer.removeListener('update', handler);
  };
}, []);
```

This is mandatory, especially with hot module replacement.

6. Detect listener leaks early.
    

Electron is just Node.js under the hood:

```js
ipcRenderer.setMaxListeners(20);
```

If you exceed this, Node will warn you. This is not a fix, but it is an early warning system.

How to confirm this is happening.

Add logging:

```js
console.log(ipcRenderer.listenerCount('update'));
```

Reload the window repeatedly. If the number increases, you are leaking listeners.

Key takeaway.

Renderer reloads re-execute JavaScript but do not necessarily tear down IPC infrastructure. Every `ipcRenderer.on` call must have a corresponding removal path. If not, reloads and hot reloads will silently stack listeners, leading to duplicated behavior and native memory growth that heap tools cannot see.

---



## `did-finish-load` vs `dom-ready` vs `ready-to-show`

The `ready-to-show` event in Electron is a **BrowserWindow lifecycle signal** that indicates the window has completed its **first render** and can be displayed without a white flash.

Background context. In Electron, creating a `BrowserWindow` and loading a URL are asynchronous. The renderer process may finish loading resources (`did-finish-load`) before anything is actually painted to the screen. Showing the window too early often results in a blank or white window for a brief moment.

What `ready-to-show` means. The event fires when Electron determines that the renderer has produced its **first non-empty frame**. In practical terms, this means Chromium has something real to display.

Analogy. Think of a theater stage.  
`did-finish-load` is when the actors arrive and memorize their lines.  
`ready-to-show` is when the curtain is up, lights are on, and the scene is visually ready for the audience.  
Calling `show()` before that is like opening the curtain while the stage is still dark.

Typical usage pattern. The window is created with `show: false`. The application listens for `ready-to-show`, and only then calls `window.show()`. This avoids flicker and improves perceived startup quality.

Key distinctions from related events.

- `did-finish-load`: Indicates that HTML and subresources are loaded, but rendering may still be incomplete.   
- `dom-ready`: Fires earlier; DOM exists, but styles, images, and layout may not be finalized.   
- `ready-to-show`: Focuses specifically on **visual readiness**, not network or DOM state.
    

Important caveats.

- The event may **never fire** if rendering never produces a frame (for example, a blank page or a crash in the renderer). Production apps usually include a fallback timeout. 
- It is **not a guarantee** that all images, fonts, or async data are finished loading—only that something has been painted.
- It is emitted per window, not globally.

When you should use it.

- Splash-screen–free startup flows. 
- Apps that prioritize polish and perceived performance. 
- Windows that are heavy on CSS, fonts, or JavaScript execution at startup.

When you may not need it.

- Utility windows or dev tools.
- Windows shown immediately with minimal UI.
- Cases where a brief blank frame is acceptable.
    
In summary, `ready-to-show` is a **presentation-quality control**, not a loading milestone. Its purpose is to ensure that when a window becomes visible, it already looks intentional rather than unfinished.


---

## Structured Clone

`structuredClone` is a default (built-in) function**, but **only in sufficiently recent JavaScript runtimes**. It is not universally available in all environments or versions.

Background first.
`structuredClone` is a standardized Web API that implements the *Structured Clone Algorithm*. Conceptually, think of it as a very strict photocopier: it copies plain data exactly, but refuses to copy things with live behavior (functions, prototypes, native handles, sockets, DOM nodes, etc.). Electron’s IPC uses essentially the same algorithm under the hood.

Now, environment by environment.

In modern browsers, `structuredClone` is globally available (for example, `window.structuredClone`) in recent Chrome, Firefox, and Safari.

In Node.js, `structuredClone` became a **global function starting in Node 17** and is fully stable in Node 18+. In older Node versions, it does not exist unless you polyfill it.

In Electron, availability depends on the **embedded Node.js and Chromium versions**, and also **where the code runs**:

* In the renderer (Chromium context), it is available if Chromium is new enough.
* In preload and main (Node context), it is available if the bundled Node version is ≥ 17.

So in Electron 22+ (roughly), `structuredClone` is normally available everywhere. In older Electron versions, it may be missing in preload or main.

```js
function isSerialized(obj) {
  try {
    structuredClone(obj);
    return true;
  } catch {
    return false;
  }
}
```

This tests whether the object can pass the structured clone algorithm, which is exactly what `ipcRenderer.send` requires.

However, two important caveats.

First, **this will throw if `structuredClone` itself is undefined**. In older environments, you must guard it:

```js
if (typeof structuredClone !== 'function') {
  throw new Error('structuredClone not available in this runtime');
}
```

Second, **passing `structuredClone` does not guarantee semantic safety**, only structural clonability. For example:

* Dates clone fine.
* Maps and Sets clone fine.
* Class instances lose their prototype and methods.
* Errors clone, but stack traces may differ.

Analogy.
Think of `structuredClone` as checking whether an item can be shipped through customs. Passing inspection means it is allowed to cross the border, not that it will arrive with its original packaging or branding intact.

Practical Electron note.
If your data passes `structuredClone`, it is safe to send via `ipcRenderer.send`. If it fails, Electron will throw a “could not be cloned” error internally. Your pre-check is reasonable, but in production code many developers rely on IPC throwing naturally and log the failure centrally.

If you want, I can:

* Map exact Electron versions to `structuredClone` availability.
* Show a lightweight fallback for older Electron/Node.
* Explain how this relates to your earlier IPC memory and listener issues.

---

## NativeImage and Image Handle

Brief background.  
In Electron, `image` is typically a `NativeImage` object. A `NativeImage` is Electron’s cross-platform wrapper around an operating system image object (for example, an HBITMAP on Windows or an NSImage/CGImage on macOS).

What `getNativeHandle()` does.  
`image.getNativeHandle()` returns a **raw binary handle** to the underlying OS image object. The return value is a **Node.js Buffer**, not a JavaScript object you can meaningfully inspect.

Conceptual analogy.  
Think of `NativeImage` as a “safe, padded box” that Electron gives you to move an image around in JavaScript.  
`getNativeHandle()` is like opening that box and pulling out the **metal part number stamped by the factory**. That number only makes sense to the factory’s machines (the OS and native code), not to normal users (JavaScript).

Platform-specific meaning (high level).  
• Windows: the buffer contains a handle related to a GDI bitmap (e.g., HBITMAP).  
• macOS: the buffer points to a Core Graphics / Cocoa image object.  
• Linux: it maps to the underlying GTK / X11 / Wayland image representation.

Electron deliberately does not normalize this, because native graphics systems differ fundamentally.

Important implications.

1. The buffer is **platform-specific**. Code using it is not portable.
2. The buffer is **not serializable** via IPC in a meaningful way. Sending it across processes will not recreate the native image.
3. It is only useful when calling **native Node addons (C++ / N-API)** or OS APIs that explicitly expect that handle.
4. You must not modify the buffer contents. Treat it as read-only.

When this is appropriate.  
Use `getNativeHandle()` only if you are integrating with:  
• A native Node addon you wrote.  
• A system API that explicitly requires an OS image handle.  
• Low-level OS integrations (e.g., custom window theming, native plugins).

When this is not appropriate.  
Do not use it for:  
• Rendering in the renderer.  
• Passing images over IPC.  
• Persisting images.  
• Any logic that should remain cross-platform.

Practical guidance.  
If your goal is to:  
• Display the image → use `nativeImage.toDataURL()` or `toBitmap()`.  
• Send the image via IPC → send raw pixel data or a data URL.  
• Interact with native code → `getNativeHandle()` is correct, but only on the native side.

In short, `getNativeHandle()` is an **escape hatch** from Electron’s abstraction layer. Use it only when you fully control the native boundary and understand the OS-level expectations.

---

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

## mtime vs ctime

`fs.stat()` returns a `Stats` object that exposes several timestamps. The two that are most often confused are `mtime` and `ctime`, because they sound similar but represent different events.

I will explain them precisely, with background and an analogy.

**Brief background (what “stat” is)**
`stat` comes from the Unix `stat()` system call. It returns metadata about a filesystem object: size, permissions, ownership, and timestamps. These timestamps are maintained by the filesystem, not by Node.js.

**`stats.mtime` — modification time**

`mtime` is the **last time the file’s *contents* were modified**.

It updates when:

* File data is written to
* File contents are truncated or extended

It does *not* update when:

* Permissions change
* Ownership changes
* The filename changes
* The file is moved or renamed

Example:

```js
fs.writeFileSync('a.txt', 'new content');
// mtime changes
```

**`stats.ctime` — change time (not creation time)**

`ctime` is the **last time the file’s *metadata* changed**.

It updates when:

* File contents change (because size is metadata)
* Permissions change (`chmod`)
* Ownership changes (`chown`)
* The file is renamed
* The file is moved within the same filesystem

It does *not* mean “created time” on Unix-like systems.

This is the most common misunderstanding.

**Analogy**

Think of a file as a document in a folder:

* `mtime` is when you last edited the text inside the document.
* `ctime` is when *anything about the document’s record* was updated: edited text, changed the cover, moved it to another folder, or changed who owns it.

Every `mtime` change also updates `ctime`, but not the other way around.

**Important ordering rule**

* If `mtime` changes, `ctime` always changes.
* If `ctime` changes, `mtime` may or may not change.

So `ctime >= mtime` is generally true.

**Platform-specific note (important)**

On **Linux and other Unix systems**:

* `ctime` = change time
* There is no true creation time in POSIX

On **Windows and some macOS filesystems**:

* `ctime` may represent *creation time* instead
* Node.js still exposes it as `ctime` for API consistency

Because of this, you should *not* rely on `ctime` as creation time unless you know the platform and filesystem.

If you need creation time in Node.js, use:

```js
stats.birthtime
```

Even then, its reliability depends on filesystem support.

**Summary**

* `mtime`: when file contents last changed
* `ctime`: when metadata last changed (not creation time on Unix)
* `birthtime`: creation time, if supported
* `ctime` is more general than `mtime`

---

## Parent and Child Preload

It depends on what you want each window to do. There’s no strict rule that parent and child windows must share the same preload script, but there are some best practices.
1. **Separate preloads per window**

   * Each `BrowserWindow` (parent or child) can have its own `preload.js`.
   * This is useful if the parent and child need **different APIs or different access levels**.
   * Example: The parent might have full Node access and IPC bridges, while the child only needs a subset.
2. **Shared preload**

   * If parent and child need the same APIs, you can point both windows to the same preload script.
   * Inside that preload, you can still **branch logic based on window type** if necessary:

```javascript
const { contextBridge, ipcRenderer } = require('electron');

if (window.location.pathname.includes('settings')) {
  contextBridge.exposeInMainWorld('api', {
    doSettingsThing: () => ipcRenderer.send('settings-action')
  });
} else {
  contextBridge.exposeInMainWorld('api', {
    doMainThing: () => ipcRenderer.send('main-action')
  });
}
```
3. **Combination approach**

   * You can have a **common preload module** that exports shared functionality, and then have small per-window preload scripts that `require()` that module and add window-specific APIs.
   * This avoids duplication but keeps each window isolated.

**Rule of thumb:**

* Use separate preloads if the windows have different responsibilities or security needs.
* Share preloads if the functionality is mostly the same and you want to reduce duplication.


---

# Toolkit

## **`@electron-toolkit/preload`**

`@electron-toolkit/preload` is a toolkit package for Electron preload scripts, with the latest version being 3.0.2. It provides an easy way to expose Electron APIs (ipcRenderer, webFrame, webUtils, process) to the renderer process.

## **What is `electronAPI`?**

The `electronAPI` object is a **pre-configured API** that safely exposes common Electron functionality to your renderer process. Instead of manually wrapping each Electron API method, this package does it for you.

## **Installation**

```bash
npm i @electron-toolkit/preload
```

## **Usage in Preload Script**

You can use it in two ways:

### **Method 1: Manual exposure**

```javascript
import { contextBridge } from 'electron'
import { electronAPI } from '@electron-toolkit/preload'

if (process.contextIsolated) {
  try {
    contextBridge.exposeInMainWorld('electron', electronAPI)
  } catch (error) {
    console.error(error)
  }
} else {
  window.electron = electronAPI
}
```

### **Method 2: Using helper function**

```javascript
import { exposeElectronAPI } from '@electron-toolkit/preload'

exposeElectronAPI()
```

## **Available Methods in `electronAPI`**

Based on the package documentation, the electronAPI includes these methods:

### **IPC Communication (from ipcRenderer)**

- `send` - Send asynchronous message
- `sendTo` - Send message to specific webContents
- `sendSync` - Send synchronous message
- `sendToHost` - Send message to host page (for webview)
- `invoke` - Invoke main process handler (returns Promise)
- `postMessage` - Post message with transferables

### **Event Listeners**

- `on` - Listen to channel
- `once` - Listen to channel once
- `removeListener` - Remove specific listener
- `removeAllListeners` - Remove all listeners

### **WebFrame Methods**

- `insertCSS` - Inject CSS into page
- `setZoomFactor` - Set zoom factor
- `setZoomLevel` - Set zoom level

### **WebUtils Methods**

- `getPathForFile` - Get path for File object

### **Process Properties**

- `platform` - Operating system platform
- `versions` - Electron/Node/Chrome versions
- `env` - Environment variables

## **TypeScript Support**

For TypeScript projects, you can add type definitions:

```typescript
import { ElectronAPI } from '@electron-toolkit/preload'

declare global {
  interface Window {
    electron: ElectronAPI
  }
}
```

## **Usage in Renderer Process**

After setting up the preload script, you can use it in your renderer:

```javascript
// Access platform info
console.log(window.electron.platform)

// Use IPC
window.electron.invoke('some-channel', data)
  .then(result => console.log(result))

// Listen to events
window.electron.on('channel-name', (event, data) => {
  console.log(data)
})
```

## **Security Consideration**

It's recommended to use this package for development efficiency, and it follows the best practice of wrapping ipcRenderer calls rather than exposing the module directly.

**[Inference]** The package likely provides a curated, safe subset of Electron APIs rather than exposing everything directly, which helps maintain security in context-isolated environments.

---

# Electron Tools

## Electron.js Core Modules

Electron provides a comprehensive set of built-in modules and APIs for building cross-platform desktop applications. The framework runs in two primary processes: the main process (Node.js environment) and renderer processes (Chromium-based web pages).[1][2]

### Main Process Modules

The main process serves as the application's entry point and provides access to native desktop functionality:[2]

- **app** - Controls the application lifecycle, handling events like ready, active, quit, and other application-level operations[3][4]
- **BrowserWindow** - Creates and controls browser windows, managing window behavior, appearance, and events like focus, blur, show, hide, maximize, and minimize[5][6]
- **ipcMain** - Handles asynchronous and synchronous inter-process communication (IPC) messages sent from renderer processes using event emitters[7][8]
- **Menu** - Builds and manages application menus and context menus[7]
- **dialog** - Provides native system dialogs for file operations and alerts[2]
- **Tray** - Creates and manages system tray icons[2]

### Renderer Process Modules

- **ipcRenderer** - Enables renderer processes to communicate with the main process by sending messages through developer-defined channels[7]
- **webContents** - Renders and controls web pages, accessible from the main process to interact with renderer content[9]

### Utility Process

- **UtilityProcess API** - Spawns child processes from the main process in a Node.js environment, useful for hosting untrusted services or isolating operations[2]

### Preload Scripts

Preload scripts bridge the main and renderer processes, exposing specific APIs to the window global object while maintaining security by running in an isolated context.[1][2]

## Development & Packaging Tools

### Official Electron Tools

- **Electron Forge** - Batteries-included toolkit for building and publishing Electron apps with first-class JavaScript bundling support and an extensible module ecosystem[9]
- **Electron Fiddle** - Sandbox app for creating and experimenting with small Electron projects, allowing you to test different Electron versions quickly[9]
- **Electron Packager (@electron/packager)** - Command-line tool and Node.js library that bundles Electron applications with renamed executables for distribution across platforms[10]
- **electron-builder** - Complete solution for packaging and building distribution-ready apps for macOS, Windows (NSIS, MSI, Squirrel), and Linux (AppImage, snap, deb, rpm) with auto-update support[11]

### Development Utilities

- **electron-debug** - Adds keyboard shortcuts and debug menus for faster troubleshooting during development[12]
- **electron-reloader** - Automatically reloads your application when code changes are detected, eliminating manual rebuilds[12]
- **electron-util** - Collection of useful tools for managing app state, menus, and OS-specific behaviors[12]
- **electron-localshortcut** - Manages keyboard shortcuts for specific windows within your application[12]
- **@electron/rebuild** - Rebuilds native Node.js modules against the packaged Electron version[10]

### Data & Configuration

- **electron-store** - Persistent data storage solution for Electron applications
- **electron-log / electron-timber** - Structured logging libraries for debugging and analytics[12]

### UX Enhancement Modules

- **electron-dl** - Simplifies file downloads with progress indicators and download management[12]
- **electron-context-menu** - Automatically adds native-style right-click context menus[12]
- **electron-pdf-window** - Displays PDF files directly inside Electron applications[12]

### Starter Templates & Boilerplates

- **electron-react-boilerplate** - Production-ready setup combining React and Webpack with Electron[12]
- **vite-electron-builder** - Integrates Vite's fast build process with Electron's packaging features[12]
- **secure-electron-template** - Includes React, Redux, and i18next with built-in security best practices[12]

### Native Code Integration

- **node-addon-api** - C++ wrapper for low-level Node.js API that simplifies building native addons with object-oriented APIs[13]
- **bindings** - Helper module that simplifies loading compiled native addons into Electron applications[13]

### Plugin Ecosystem

- **electron-packager-languages** - Configures available locales for packaged Electron apps, used by Mac App Store and other platforms[10]
- **electron-packager-plugin-non-proprietary-codecs-ffmpeg** - Replaces the standard FFmpeg in Electron with a version without proprietary codecs[10]

## NPM Namespace Structure

Official Electron packages use the `@electron/` and `@electron-forge/` namespaces on npm, distinguishing first-party projects from community packages. These packages require Node.js 22+ as the minimum supported version as of early 2025.[14][15]

Sources
[1] Introduction https://electronjs.org/docs/latest/
[2] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[3] app https://electronjs.org/docs/latest/api/app
[4] Beginner's Guide On Electron | Application development https://cubettech.com/resources/blog/beginners-guide-on-electron/
[5] BrowserWindow https://electronjs.org/docs/latest/api/browser-window
[6] BrowserWindow | Electron https://www.electronjs.org/docs/latest/api/browser-window
[7] Inter-Process Communication https://electronjs.org/docs/latest/tutorial/ipc
[8] ipcMain https://electronjs.org/docs/latest/api/ipc-main
[9] Electron: Build cross-platform desktop apps with JavaScript ... https://electronjs.org
[10] Electron Packager https://github.com/electron/packager
[11] electron-builder https://www.electron.build/index.html
[12] Top Electron Tools & Libraries for Developers 2025 https://www.capitalcompute.com/top-tools-and-libraries-to-use-with-electron-in-2025/
[13] Native Code and Electron https://electronjs.org/docs/latest/tutorial/native-code-and-electron
[14] Ecosystem 2023 Recap https://electronjs.org/blog/ecosystem-2023-eoy-recap
[15] 9 posts tagged with "Ecosystem" https://electronjs.org/blog/tags/ecosystem
[16] Application Packaging https://electronjs.org/docs/latest/tutorial/application-distribution
[17] Electron.js: Desktop Application Examples in 2026 - Swovo https://swovo.com/blog/electron-js-desktop-application-examples-in-2024/
[18] Advanced Electron.js architecture https://blog.logrocket.com/advanced-electron-js-architecture/
[19] Development https://electron-vite.org/guide/dev

---

# Node

## Essential Node.js Concepts for Electron Development

Building solid Electron applications requires understanding several core Node.js concepts that underpin how Electron works. Here are the fundamental ones:

### Process and Child Process

**process (Global Object)**

The `process` object provides information about and control over the current Node.js process. In Electron, understanding `process` is crucial because you're working with multiple processes (main and renderer).

```javascript
// Check which process you're in
console.log(process.type); // 'browser' (main) or 'renderer'

// Environment variables
console.log(process.env.NODE_ENV);

// Platform detection
if (process.platform === 'darwin') {
  // macOS-specific code
}

// Exit the process
process.exit(0);

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  console.error('Uncaught error:', error);
});
```

**child_process Module**

Allows you to spawn an d manage child processes. Useful when your Electron app needs to run external commands or scripts.

```javascript
const { spawn, exec } = require('child_process');

// Spawn a long-running process
const pythonProcess = spawn('python', ['script.py']);

pythonProcess.stdout.on('data', (data) => {
  console.log(`Output: ${data}`);
});

// Execute a simple command
exec('ls -la', (error, stdout, stderr) => {
  if (error) {
    console.error(`Error: ${error.message}`);
    return;
  }
  console.log(stdout);
});
```

### Streams

Streams handle data flowing through your application piece by piece, rather than loading everything into memory at once. Critical for file operations, network requests, and any large data processing.

**Types of Streams**

Readable streams (read data from a source), Writable streams (write data to a destination), Duplex streams (both readable and writable), and Transform streams (modify data as it passes through).

```javascript
const fs = require('fs');

// Reading a large file efficiently
const readStream = fs.createReadStream('large-file.txt', {
  encoding: 'utf8',
  highWaterMark: 16 * 1024 // 16KB chunks
});

readStream.on('data', (chunk) => {
  console.log(`Received ${chunk.length} bytes`);
});

readStream.on('end', () => {
  console.log('Finished reading');
});

// Piping streams together
const writeStream = fs.createWriteStream('output.txt');
readStream.pipe(writeStream);
```

**Why This Matters in Electron**

When building file processing features, handling large downloads, or streaming media, streams prevent memory overload and keep your app responsive.

### Buffer

Buffers handle raw binary data, which is essential when working with files, network protocols, or any non-text data.

```javascript
// Creating buffers
const buf1 = Buffer.from('Hello', 'utf8');
const buf2 = Buffer.alloc(10); // 10 bytes of zeros
const buf3 = Buffer.allocUnsafe(10); // Faster but uninitialized

// Working with binary data
const imageBuffer = fs.readFileSync('image.png');
console.log(imageBuffer.length); // Size in bytes

// Converting between formats
const base64 = imageBuffer.toString('base64');
const backToBuffer = Buffer.from(base64, 'base64');

// Concatenating buffers
const combined = Buffer.concat([buf1, buf2]);
```

**Electron Use Cases**

Handling file uploads/downloads, working with images before display, processing audio/video data, or implementing custom protocols.

### Path Module

The `path` module provides utilities for working with file and directory paths in a cross-platform way. Essential since Electron apps run on Windows, macOS, and Linux with different path conventions.

```javascript
const path = require('path');

// Join path segments correctly for the OS
const filePath = path.join(__dirname, 'assets', 'icon.png');
// On Windows: C:\app\assets\icon.png
// On Unix: /app/assets/icon.png

// Get file extension
path.extname('document.pdf'); // '.pdf'

// Get filename without extension
path.basename('document.pdf', '.pdf'); // 'document'

// Get directory name
path.dirname('/user/docs/file.txt'); // '/user/docs'

// Resolve absolute path
const absolute = path.resolve('..', 'data', 'config.json');

// Normalize paths (clean up .., ., etc.)
path.normalize('/user/../admin/data'); // '/admin/data'
```

### File System (fs)

The `fs` module enables interaction with the file system. Nearly every Electron app needs to read or write files.

```javascript
const fs = require('fs');
const fsPromises = require('fs').promises;

// Synchronous (blocks execution)
const data = fs.readFileSync('config.json', 'utf8');

// Asynchronous with callbacks
fs.readFile('config.json', 'utf8', (err, data) => {
  if (err) throw err;
  console.log(data);
});

// Promise-based (modern approach)
async function readConfig() {
  try {
    const data = await fsPromises.readFile('config.json', 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading config:', error);
  }
}

// Writing files
await fsPromises.writeFile('output.txt', 'Hello World', 'utf8');

// Checking if file exists
const exists = fs.existsSync('file.txt');

// Creating directories
await fsPromises.mkdir('new-folder', { recursive: true });

// Watching for file changes
fs.watch('config.json', (eventType, filename) => {
  console.log(`${filename} changed: ${eventType}`);
});
```

### Promises and async/await

Modern asynchronous programming patterns that make code more readable than callback-based approaches.

```javascript
// Creating a promise
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Using async/await
async function loadData() {
  try {
    console.log('Loading...');
    await delay(1000);
    
    const data = await fsPromises.readFile('data.json', 'utf8');
    const parsed = JSON.parse(data);
    
    return parsed;
  } catch (error) {
    console.error('Failed to load data:', error);
    throw error;
  }
}

// Parallel operations
async function loadMultipleFiles() {
  const [file1, file2, file3] = await Promise.all([
    fsPromises.readFile('file1.txt', 'utf8'),
    fsPromises.readFile('file2.txt', 'utf8'),
    fsPromises.readFile('file3.txt', 'utf8')
  ]);
  
  return { file1, file2, file3 };
}
```

### Modules and require/import

Understanding Node's module system is fundamental to organizing Electron code.

```javascript
// CommonJS (traditional Node.js)
const fs = require('fs');
const myModule = require('./myModule');

module.exports = {
  myFunction() {
    // ...
  }
};

// ES Modules (modern, requires configuration)
import fs from 'fs';
import { myFunction } from './myModule.js';

export function anotherFunction() {
  // ...
}

export default class MyClass {
  // ...
}
```

**Important for Electron**

The main process typically uses CommonJS, while renderer processes can use either. You need to configure this properly in your build setup.

### Error Handling Patterns

Proper error handling prevents crashes and improves user experience.

```javascript
// Try-catch for synchronous and async/await code
try {
  const data = fs.readFileSync('file.txt');
} catch (error) {
  console.error('Error reading file:', error.message);
}

// Error events on EventEmitters
const stream = fs.createReadStream('file.txt');
stream.on('error', (error) => {
  console.error('Stream error:', error);
});

// Promise rejection handling
someAsyncOperation()
  .catch((error) => {
    console.error('Operation failed:', error);
  });

// Global error handlers
process.on('uncaughtException', (error) => {
  console.error('Uncaught exception:', error);
  // Log to file, show error dialog, etc.
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled promise rejection:', reason);
});
```

### URL and querystring

Working with URLs is common in Electron apps, especially for loading content or handling deep links.

```javascript
const { URL, URLSearchParams } = require('url');

// Parsing URLs
const myUrl = new URL('https://example.com/path?key=value&foo=bar');
console.log(myUrl.hostname); // 'example.com'
console.log(myUrl.pathname); // '/path'
console.log(myUrl.search);   // '?key=value&foo=bar'

// Working with query parameters
const params = new URLSearchParams(myUrl.search);
console.log(params.get('key')); // 'value'
params.append('new', 'param');

// Building URLs
const url = new URL('/api/data', 'https://example.com');
url.searchParams.set('id', '123');
console.log(url.href); // 'https://example.com/api/data?id=123'
```

### Timers

While similar to browser timers, understanding Node's event loop and how timers work is important for performance.

```javascript
// setTimeout - run once after delay
const timeoutId = setTimeout(() => {
  console.log('Executed after 1 second');
}, 1000);

clearTimeout(timeoutId); // Cancel if needed

// setInterval - run repeatedly
const intervalId = setInterval(() => {
  console.log('Executed every 2 seconds');
}, 2000);

clearInterval(intervalId); // Stop when done

// setImmediate - run after I/O events
setImmediate(() => {
  console.log('Runs after I/O');
});

// process.nextTick - run before any I/O
process.nextTick(() => {
  console.log('Runs before any I/O');
});
```

### os Module

Get system information, which is useful for platform-specific features or diagnostics.

```javascript
const os = require('os');

// Platform information
console.log(os.platform()); // 'darwin', 'win32', 'linux'
console.log(os.arch());     // 'x64', 'arm64'
console.log(os.type());     // 'Darwin', 'Windows_NT', 'Linux'

// System resources
console.log(os.totalmem()); // Total memory in bytes
console.log(os.freemem());  // Free memory in bytes
console.log(os.cpus());     // CPU core information

// User information
console.log(os.homedir());  // User's home directory
console.log(os.tmpdir());   // Temporary directory
console.log(os.userInfo()); // Current user details
```

### Practical Integration Example

Here's how several of these concepts work together in a typical Electron app feature:

```javascript
const { app } = require('electron');
const fs = require('fs').promises;
const path = require('path');
const { EventEmitter } = require('events');

class DataManager extends EventEmitter {
  constructor() {
    super();
    this.dataPath = path.join(app.getPath('userData'), 'app-data.json');
  }
  
  async loadData() {
    try {
      this.emit('loading');
      
      const exists = await fs.access(this.dataPath)
        .then(() => true)
        .catch(() => false);
      
      if (!exists) {
        this.emit('loaded', {});
        return {};
      }
      
      const content = await fs.readFile(this.dataPath, 'utf8');
      const data = JSON.parse(content);
      
      this.emit('loaded', data);
      return data;
      
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }
  
  async saveData(data) {
    try {
      this.emit('saving');
      
      const json = JSON.stringify(data, null, 2);
      await fs.writeFile(this.dataPath, json, 'utf8');
      
      this.emit('saved');
      
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }
}

// Usage
const manager = new DataManager();

manager.on('loading', () => console.log('Loading data...'));
manager.on('loaded', (data) => console.log('Data loaded:', data));
manager.on('error', (error) => console.error('Error:', error));

async function init() {
  const data = await manager.loadData();
  data.lastAccess = new Date().toISOString();
  await manager.saveData(data);
}
```

### net Module

The `net` module provides an asynchronous network API for creating TCP servers and clients. Useful for building Electron apps that need network communication, custom protocols, or server functionality.

```javascript
const net = require('net');

// Creating a TCP server
const server = net.createServer((socket) => {
  console.log('Client connected');
  
  socket.on('data', (data) => {
    console.log('Received:', data.toString());
    socket.write('Echo: ' + data);
  });
  
  socket.on('end', () => {
    console.log('Client disconnected');
  });
  
  socket.on('error', (err) => {
    console.error('Socket error:', err);
  });
});

server.listen(8080, () => {
  console.log('Server listening on port 8080');
});

// Creating a TCP client
const client = net.createConnection({ port: 8080 }, () => {
  console.log('Connected to server');
  client.write('Hello server!');
});

client.on('data', (data) => {
  console.log('Server response:', data.toString());
  client.end();
});
```

**Electron Use Cases**

Building local servers for debugging tools, creating inter-app communication systems, implementing custom network protocols, or building developer tools that monitor network traffic.

### http/https Modules

For making HTTP requests or creating HTTP servers within your Electron app.

```javascript
const https = require('https');
const http = require('http');

// Making an HTTP request
https.get('https://api.example.com/data', (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    const parsed = JSON.parse(data);
    console.log(parsed);
  });
}).on('error', (err) => {
  console.error('Request error:', err);
});

// POST request with more control
const postData = JSON.stringify({ key: 'value' });

const options = {
  hostname: 'api.example.com',
  port: 443,
  path: '/submit',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

const req = https.request(options, (res) => {
  res.on('data', (chunk) => {
    console.log(chunk.toString());
  });
});

req.on('error', (e) => {
  console.error('Problem with request:', e.message);
});

req.write(postData);
req.end();

// Creating a simple HTTP server
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from Electron app!\n');
});

server.listen(3000);
```

### crypto Module

Provides cryptographic functionality for security-sensitive operations like hashing, encryption, and random number generation.

```javascript
const crypto = require('crypto');

// Generating random bytes
const randomBytes = crypto.randomBytes(16);
console.log(randomBytes.toString('hex'));

// Hashing data (one-way)
const hash = crypto.createHash('sha256');
hash.update('password123');
const hashed = hash.digest('hex');
console.log('SHA-256:', hashed);

// Encrypting data (two-way)
const algorithm = 'aes-256-cbc';
const key = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);

function encrypt(text) {
  const cipher = crypto.createCipheriv(algorithm, key, iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return encrypted;
}

function decrypt(encrypted) {
  const decipher = crypto.createDecipheriv(algorithm, key, iv);
  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}

const encrypted = encrypt('Sensitive data');
const decrypted = decrypt(encrypted);

// Creating secure tokens
const token = crypto.randomBytes(32).toString('base64');

// HMAC for message authentication
const hmac = crypto.createHmac('sha256', 'secret-key');
hmac.update('message to authenticate');
const signature = hmac.digest('hex');
```

**Electron Use Cases**

User authentication, encrypting local data storage, generating secure session tokens, password hashing, or implementing license verification systems.

### util Module

Provides utility functions, including promisification of callback-based functions and formatting.

```javascript
const util = require('util');
const fs = require('fs');

// Promisify callback-based functions
const readFileAsync = util.promisify(fs.readFile);

async function readConfig() {
  const data = await readFileAsync('config.json', 'utf8');
  return JSON.parse(data);
}

// Formatting strings (like printf)
const formatted = util.format('%s:%d', 'localhost', 8080);
console.log(formatted); // 'localhost:8080'

// Type checking
console.log(util.types.isDate(new Date())); // true
console.log(util.types.isPromise(Promise.resolve())); // true
console.log(util.types.isArrayBuffer(new ArrayBuffer())); // true

// Deprecation warnings
const deprecatedFunction = util.deprecate(
  () => console.log('Old way'),
  'This function is deprecated. Use newFunction() instead.'
);

// Deep object inspection
const complexObject = { a: 1, b: { c: 2, d: [3, 4] } };
console.log(util.inspect(complexObject, { depth: null, colors: true }));
```

### zlib Module

For compression and decompression, useful for handling compressed files or reducing data size.

```javascript
const zlib = require('zlib');
const fs = require('fs');

// Compress data
const input = 'This is some data to compress. '.repeat(100);

zlib.gzip(input, (err, compressed) => {
  if (err) throw err;
  
  console.log('Original size:', Buffer.byteLength(input));
  console.log('Compressed size:', compressed.length);
  
  // Decompress
  zlib.gunzip(compressed, (err, decompressed) => {
    if (err) throw err;
    console.log('Decompressed:', decompressed.toString());
  });
});

// Compress a file using streams
const gzip = zlib.createGzip();
const source = fs.createReadStream('input.txt');
const destination = fs.createWriteStream('input.txt.gz');

source.pipe(gzip).pipe(destination);

// Promise-based compression
const { promisify } = require('util');
const gzipAsync = promisify(zlib.gzip);

async function compressData(data) {
  const compressed = await gzipAsync(data);
  return compressed;
}
```

**Electron Use Cases**

Compressing log files, reducing backup sizes, handling compressed downloads, or optimizing data transfer in custom protocols.

### dns Module

For DNS lookups and resolution, useful for network-aware applications.

```javascript
const dns = require('dns');
const { promisify } = require('util');

const lookup = promisify(dns.lookup);
const resolve4 = promisify(dns.resolve4);

// Look up IP address
async function getIP(hostname) {
  try {
    const { address } = await lookup(hostname);
    console.log('IP address:', address);
    return address;
  } catch (err) {
    console.error('DNS lookup failed:', err);
  }
}

getIP('google.com');

// Resolve all IPv4 addresses
async function getAllIPs(hostname) {
  try {
    const addresses = await resolve4(hostname);
    console.log('All IPs:', addresses);
  } catch (err) {
    console.error('Resolution failed:', err);
  }
}

// Reverse DNS lookup
dns.reverse('8.8.8.8', (err, hostnames) => {
  if (err) throw err;
  console.log('Hostnames:', hostnames);
});
```

### Worker Threads

For CPU-intensive operations without blocking the main thread. [Inference: This is particularly valuable in Electron to prevent UI freezing]

```javascript
const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');

if (isMainThread) {
  // Main thread code
  const worker = new Worker(__filename, {
    workerData: { start: 1, end: 1000000 }
  });
  
  worker.on('message', (result) => {
    console.log('Result from worker:', result);
  });
  
  worker.on('error', (err) => {
    console.error('Worker error:', err);
  });
  
  worker.on('exit', (code) => {
    if (code !== 0) {
      console.error(`Worker stopped with exit code ${code}`);
    }
  });
  
} else {
  // Worker thread code
  function heavyComputation(start, end) {
    let sum = 0;
    for (let i = start; i <= end; i++) {
      sum += i;
    }
    return sum;
  }
  
  const result = heavyComputation(workerData.start, workerData.end);
  parentPort.postMessage(result);
}
```

**Electron Use Cases**

Image processing, video encoding, large data parsing, cryptographic operations, or any CPU-intensive task that would freeze the UI if run on the main thread.

### Timers and setImmediate Details

Understanding the Node.js event loop phases helps write more efficient code.

```javascript
// Event loop order demonstration
console.log('1: Synchronous');

setImmediate(() => {
  console.log('2: setImmediate');
});

process.nextTick(() => {
  console.log('3: nextTick');
});

setTimeout(() => {
  console.log('4: setTimeout 0ms');
}, 0);

Promise.resolve().then(() => {
  console.log('5: Promise');
});

console.log('6: Synchronous');

// Output order:
// 1: Synchronous
// 6: Synchronous
// 3: nextTick
// 5: Promise
// 4: setTimeout 0ms
// 2: setImmediate
```

**Understanding Event Loop Phases** [Inference based on Node.js documentation]

The event loop processes tasks in phases: timers, pending callbacks, idle/prepare, poll, check (setImmediate), and close callbacks. `process.nextTick()` and Promise callbacks execute between phases.

### readline Module

For reading input line by line, useful for CLI tools or processing text files.

```javascript
const readline = require('readline');
const fs = require('fs');

// Reading from a file line by line
const fileStream = fs.createReadStream('large-file.txt');

const rl = readline.createInterface({
  input: fileStream,
  crlfDelay: Infinity // Recognize all CR LF instances
});

rl.on('line', (line) => {
  console.log(`Line: ${line}`);
});

rl.on('close', () => {
  console.log('Finished reading file');
});

// Interactive command line interface
const cliInterface = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

cliInterface.question('What is your name? ', (answer) => {
  console.log(`Hello, ${answer}!`);
  cliInterface.close();
});

// Reading multiple inputs
async function getUserInput() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  
  const question = (query) => new Promise((resolve) => {
    rl.question(query, resolve);
  });
  
  const name = await question('Name: ');
  const age = await question('Age: ');
  
  rl.close();
  return { name, age };
}
```

### assert Module

For writing tests and validating assumptions in your code.

```javascript
const assert = require('assert');

// Basic assertions
assert.strictEqual(1 + 1, 2); // Passes
// assert.strictEqual(1 + 1, 3); // Throws AssertionError

// Deep equality
const obj1 = { a: 1, b: { c: 2 } };
const obj2 = { a: 1, b: { c: 2 } };
assert.deepStrictEqual(obj1, obj2); // Passes

// Checking if value is truthy
assert.ok(true);
assert.ok('non-empty string');

// Testing for errors
assert.throws(
  () => {
    throw new Error('Wrong value');
  },
  Error
);

// Custom error messages
assert.strictEqual(5, 5, 'Values must be equal');

// Async assertions
async function testAsync() {
  const result = await someAsyncOperation();
  assert.strictEqual(result, 'expected');
}
```

### vm Module

For running JavaScript code in isolated contexts. [Inference: Useful for sandboxing or plugin systems]

```javascript
const vm = require('vm');

// Basic code execution
const result = vm.runInNewContext('2 + 2');
console.log(result); // 4

// With a custom context
const sandbox = {
  x: 10,
  y: 20,
  console: console
};

vm.createContext(sandbox);

const code = `
  const sum = x + y;
  console.log('Sum:', sum);
  sum;
`;

const scriptResult = vm.runInContext(code, sandbox);
console.log('Script result:', scriptResult); // 30

// Reusable scripts
const script = new vm.Script('x * 2');

sandbox.x = 5;
console.log(script.runInContext(sandbox)); // 10

sandbox.x = 10;
console.log(script.runInContext(sandbox)); // 20
```

**Electron Use Cases**

Running untrusted user scripts safely, implementing plugin systems, creating REPL environments, or building code playgrounds.

### Performance Monitoring (perf_hooks)

For measuring performance in your application.

```javascript
const { performance, PerformanceObserver } = require('perf_hooks');

// Measure execution time
const start = performance.now();

// Some operation
for (let i = 0; i < 1000000; i++) {
  Math.sqrt(i);
}

const end = performance.now();
console.log(`Operation took ${end - start}ms`);

// Using marks and measures
performance.mark('start-operation');

// Do something
setTimeout(() => {
  performance.mark('end-operation');
  performance.measure('My Operation', 'start-operation', 'end-operation');
  
  const measure = performance.getEntriesByName('My Operation')[0];
  console.log(`Duration: ${measure.duration}ms`);
}, 1000);

// Observing performance entries
const obs = new PerformanceObserver((items) => {
  items.getEntries().forEach((entry) => {
    console.log(`${entry.name}: ${entry.duration}ms`);
  });
});

obs.observe({ entryTypes: ['measure'] });
```

### Cluster Module

For creating multiple Node.js processes to handle load. [Inference: Less common in Electron but useful for background services]

```javascript
const cluster = require('cluster');
const http = require('http');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  console.log(`Master process ${process.pid} is running`);
  
  // Fork workers
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
  
  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    // Restart the worker
    cluster.fork();
  });
  
} else {
  // Workers can share TCP connections
  http.createServer((req, res) => {
    res.writeHead(200);
    res.end(`Process ${process.pid} handled request\n`);
  }).listen(8000);
  
  console.log(`Worker ${process.pid} started`);
}
```

### querystring Module

For parsing and formatting URL query strings (alternative to URLSearchParams).

```javascript
const querystring = require('querystring');

// Parse query string
const parsed = querystring.parse('name=John&age=30&city=NYC');
console.log(parsed); // { name: 'John', age: '30', city: 'NYC' }

// Stringify object
const query = querystring.stringify({
  name: 'Jane',
  age: 25,
  interests: ['coding', 'music']
});
console.log(query); // 'name=Jane&age=25&interests=coding&interests=music'

// Custom separators
const custom = querystring.parse('name:John;age:30', ';', ':');
console.log(custom); // { name: 'John', age: '30' }

// URL encoding
const encoded = querystring.escape('hello world!');
console.log(encoded); // 'hello%20world!'

const decoded = querystring.unescape(encoded);
console.log(decoded); // 'hello world!'
```

### Putting It All Together

Here's a more complex example showing how multiple concepts work together in an Electron app feature:

```javascript
const { EventEmitter } = require('events');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const zlib = require('zlib');
const { promisify } = require('util');

const gzipAsync = promisify(zlib.gzip);
const gunzipAsync = promisify(zlib.gunzip);

class SecureDataStore extends EventEmitter {
  constructor(dataDir, encryptionKey) {
    super();
    this.dataDir = dataDir;
    this.key = Buffer.from(encryptionKey, 'hex');
  }
  
  async save(id, data) {
    try {
      this.emit('saving', id);
      
      // Serialize
      const json = JSON.stringify(data);
      
      // Compress
      const compressed = await gzipAsync(json);
      
      // Encrypt
      const iv = crypto.randomBytes(16);
      const cipher = crypto.createCipheriv('aes-256-cbc', this.key, iv);
      const encrypted = Buffer.concat([
        iv,
        cipher.update(compressed),
        cipher.final()
      ]);
      
      // Save to file
      const filePath = path.join(this.dataDir, `${id}.dat`);
      await fs.writeFile(filePath, encrypted);
      
      this.emit('saved', id);
      
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }
  
  async load(id) {
    try {
      this.emit('loading', id);
      
      // Read file
      const filePath = path.join(this.dataDir, `${id}.dat`);
      const encrypted = await fs.readFile(filePath);
      
      // Decrypt
      const iv = encrypted.slice(0, 16);
      const data = encrypted.slice(16);
      const decipher = crypto.createDecipheriv('aes-256-cbc', this.key, iv);
      const decrypted = Buffer.concat([
        decipher.update(data),
        decipher.final()
      ]);
      
      // Decompress
      const decompressed = await gunzipAsync(decrypted);
      
      // Parse
      const result = JSON.parse(decompressed.toString());
      
      this.emit('loaded', id, result);
      return result;
      
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }
}

// Usage
const encryptionKey = crypto.randomBytes(32).toString('hex');
const store = new SecureDataStore('/path/to/data', encryptionKey);

store.on('saving', (id) => console.log(`Saving ${id}...`));
store.on('saved', (id) => console.log(`Saved ${id}`));
store.on('error', (err) => console.error('Error:', err));

async function demo() {
  await store.save('user-123', { 
    username: 'john',
    settings: { theme: 'dark' }
  });
  
  const data = await store.load('user-123');
  console.log('Loaded:', data);
}
```

These additional concepts expand your toolkit for building sophisticated Electron applications that handle security, networking, performance optimization, and complex data processing tasks.

## The Event Loop

The event loop is the core mechanism that enables Node.js (and therefore Electron) to perform non-blocking I/O operations despite JavaScript being single-threaded. Understanding it is crucial for writing efficient, performant Electron applications.

### What is the Event Loop?

The event loop is a continuously running process that monitors the call stack and callback queues, executing code, collecting and processing events, and executing queued sub-tasks. It allows Node.js to offload operations to the system kernel whenever possible, then execute callbacks when those operations complete.

**Single-Threaded but Non-Blocking**

JavaScript runs on a single thread, meaning it can only execute one piece of code at a time. However, the event loop allows asynchronous operations to run "in the background" (actually handled by the system or libuv), freeing the main thread to continue executing other code.

### Event Loop Phases

The event loop operates in distinct phases, each with its own queue of callbacks to execute. The loop processes these phases in order, repeatedly.

**The Six Phases**

```
   ┌───────────────────────────┐
┌─>│           timers          │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │     pending callbacks     │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │       idle, prepare       │
│  └─────────────┬─────────────┘      ┌───────────────┐
│  ┌─────────────┴─────────────┐      │   incoming:   │
│  │           poll            │<─────┤  connections, │
│  └─────────────┬─────────────┘      │   data, etc.  │
│  ┌─────────────┴─────────────┐      └───────────────┘
│  │           check           │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
└──┤      close callbacks      │
   └───────────────────────────┘
```

### Phase-by-Phase Breakdown

**1. Timers Phase**

Executes callbacks scheduled by `setTimeout()` and `setInterval()`. [Inference: Based on Node.js event loop documentation]

```javascript
console.log('Start');

setTimeout(() => {
  console.log('Timer 1 (0ms)');
}, 0);

setTimeout(() => {
  console.log('Timer 2 (10ms)');
}, 10);

console.log('End');

// Output:
// Start
// End
// Timer 1 (0ms)
// Timer 2 (10ms) (after 10ms)
```

The timer phase checks if any timer thresholds have been reached and executes their callbacks. Timers are not guaranteed to execute at the exact time specified—they execute as soon as possible after the threshold is reached.

**2. Pending Callbacks Phase**

Executes I/O callbacks deferred from the previous cycle. These are typically system-level callbacks like TCP errors.

```javascript
const fs = require('fs');

// If a file operation encounters an error,
// the error callback executes in pending callbacks phase
fs.readFile('nonexistent.txt', (err, data) => {
  if (err) {
    console.log('Error callback executed');
  }
});
```

**3. Idle, Prepare Phase**

Used internally by Node.js. [Unverified: External code typically doesn't interact with this phase directly]

**4. Poll Phase**

This is the most important phase. It retrieves new I/O events and executes I/O-related callbacks (except close callbacks, timers, and `setImmediate()`).

```javascript
const fs = require('fs');

console.log('Start');

// File read is I/O - callback executes in poll phase
fs.readFile('file.txt', 'utf8', (err, data) => {
  console.log('File read complete');
});

console.log('End');

// Output:
// Start
// End
// File read complete
```

**Poll Phase Behavior:**

The poll phase will wait for incoming connections, requests, etc. However, it won't wait indefinitely. It will move to the next phase if:

- The poll queue is empty and there are `setImmediate()` callbacks waiting
- Timers have reached their threshold

**5. Check Phase**

Executes `setImmediate()` callbacks. This phase allows you to execute callbacks immediately after the poll phase completes.

```javascript
setImmediate(() => {
  console.log('setImmediate callback');
});

setTimeout(() => {
  console.log('setTimeout callback');
}, 0);

// Output order can vary, but typically:
// setTimeout callback
// setImmediate callback
```

**6. Close Callbacks Phase**

Executes close event callbacks, such as `socket.on('close', ...)`.

```javascript
const net = require('net');

const server = net.createServer();

server.on('close', () => {
  console.log('Server closed');
});

server.listen(3000);
server.close();

// 'Server closed' executes in close callbacks phase
```

### Microtasks: process.nextTick() and Promises

Between each phase of the event loop, Node.js processes two special queues called "microtask queues". These have higher priority than the phase queues.

**process.nextTick() Queue**

Executes before any other phase and before Promises. [Inference: Based on Node.js documentation stating nextTick has highest priority]

```javascript
console.log('1: Script start');

setTimeout(() => {
  console.log('2: setTimeout');
}, 0);

Promise.resolve().then(() => {
  console.log('3: Promise');
});

process.nextTick(() => {
  console.log('4: nextTick');
});

console.log('5: Script end');

// Output:
// 1: Script start
// 5: Script end
// 4: nextTick
// 3: Promise
// 2: setTimeout
```

**Promise Microtask Queue**

Executes after `process.nextTick()` but before the next event loop phase.

```javascript
Promise.resolve().then(() => {
  console.log('Promise 1');
}).then(() => {
  console.log('Promise 2');
});

process.nextTick(() => {
  console.log('nextTick 1');
  process.nextTick(() => {
    console.log('nextTick 2');
  });
});

// Output:
// nextTick 1
// nextTick 2
// Promise 1
// Promise 2
```

### Execution Priority Order

From highest to lowest priority:

1. Synchronous code (current call stack)
2. `process.nextTick()` callbacks
3. Promise microtasks (`.then()`, `.catch()`, `.finally()`)
4. Event loop phase callbacks (timers, I/O, check, close)

```javascript
console.log('Sync 1');

setTimeout(() => console.log('setTimeout'), 0);

setImmediate(() => console.log('setImmediate'));

Promise.resolve()
  .then(() => console.log('Promise 1'))
  .then(() => console.log('Promise 2'));

process.nextTick(() => console.log('nextTick 1'));
process.nextTick(() => console.log('nextTick 2'));

console.log('Sync 2');

// Output:
// Sync 1
// Sync 2
// nextTick 1
// nextTick 2
// Promise 1
// Promise 2
// setTimeout
// setImmediate
```

### setTimeout vs setImmediate

The order of execution between `setTimeout(fn, 0)` and `setImmediate(fn)` can vary depending on context.

**In the Main Module:**

The order is non-deterministic because it depends on process performance.

```javascript
setTimeout(() => {
  console.log('setTimeout');
}, 0);

setImmediate(() => {
  console.log('setImmediate');
});

// Output can be either order
```

**Inside an I/O Cycle:**

`setImmediate()` always executes first because it's checked immediately after the poll phase.

```javascript
const fs = require('fs');

fs.readFile(__filename, () => {
  setTimeout(() => {
    console.log('setTimeout');
  }, 0);
  
  setImmediate(() => {
    console.log('setImmediate');
  });
});

// Output (consistent):
// setImmediate
// setTimeout
```

### Common Patterns and Use Cases

**Deferring Work with process.nextTick()**

Use when you want to ensure code runs before any I/O events but after the current operation completes.

```javascript
function asyncOperation(data, callback) {
  // Ensure callback is always asynchronous
  if (!data) {
    process.nextTick(() => {
      callback(new Error('No data provided'));
    });
    return;
  }
  
  // Do actual async work
  setTimeout(() => {
    callback(null, data.toUpperCase());
  }, 100);
}

// Caller can always expect async behavior
asyncOperation('test', (err, result) => {
  console.log(result);
});

console.log('Called asyncOperation');

// Output:
// Called asyncOperation
// (error or result appears next)
```

**Breaking Up CPU-Intensive Work**

Prevent blocking the event loop by breaking work into chunks.

```javascript
function processLargeArray(array) {
  const chunkSize = 1000;
  let index = 0;
  
  function processChunk() {
    const endIndex = Math.min(index + chunkSize, array.length);
    
    for (let i = index; i < endIndex; i++) {
      // Process array[i]
      heavyOperation(array[i]);
    }
    
    index = endIndex;
    
    if (index < array.length) {
      // Schedule next chunk
      setImmediate(processChunk);
    } else {
      console.log('Processing complete');
    }
  }
  
  processChunk();
}

function heavyOperation(item) {
  // Some CPU-intensive work
  for (let i = 0; i < 1000000; i++) {
    Math.sqrt(i);
  }
}

// This keeps the event loop responsive
processLargeArray(new Array(10000));
```

**Avoiding process.nextTick() Recursion**

Be careful with recursive `process.nextTick()` calls—they can starve the event loop.

```javascript
// BAD: This blocks the event loop
let count = 0;
function recursiveNextTick() {
  if (count < 1000) {
    count++;
    process.nextTick(recursiveNextTick);
  }
}

// The event loop can't proceed to timers/I/O
setTimeout(() => {
  console.log('This will be delayed significantly');
}, 0);

recursiveNextTick();

// BETTER: Use setImmediate for recursion
count = 0;
function recursiveImmediate() {
  if (count < 1000) {
    count++;
    setImmediate(recursiveImmediate);
  }
}

// This allows other phases to run between iterations
recursiveImmediate();
```

### Event Loop in Electron Context

Electron has multiple event loops running simultaneously:

**Main Process Event Loop**

Runs the standard Node.js event loop, handling all Node.js operations.

**Renderer Process Event Loop**

Each renderer process has both:

- A Node.js event loop (if Node integration is enabled)
- A browser event loop (for DOM events, rendering, etc.)

```javascript
// Main process
const { app, BrowserWindow } = require('electron');

app.on('ready', () => {
  // This callback executes in main process event loop
  const win = new BrowserWindow();
  
  // Heavy computation in main process
  setImmediate(() => {
    performHeavyComputation();
  });
});

// Renderer process
// Both Node.js and browser event loops are active
document.getElementById('btn').addEventListener('click', () => {
  // Browser event loop handles this
  console.log('Button clicked');
  
  // Node.js event loop handles this
  const fs = require('fs');
  fs.readFile('file.txt', (err, data) => {
    console.log('File read in renderer');
  });
});
```

### Debugging Event Loop Issues

**Checking Event Loop Lag**

Monitor if the event loop is blocked.

```javascript
const { performance } = require('perf_hooks');

let lastCheck = performance.now();

setInterval(() => {
  const now = performance.now();
  const lag = now - lastCheck - 1000; // Expected: ~1000ms
  
  if (lag > 100) {
    console.warn(`Event loop lag: ${lag}ms`);
  }
  
  lastCheck = now;
}, 1000);
```

**Using async_hooks for Tracking**

Track asynchronous operations to understand what's keeping the event loop busy.

```javascript
const async_hooks = require('async_hooks');
const fs = require('fs');

const activeResources = new Map();

const hook = async_hooks.createHook({
  init(asyncId, type, triggerAsyncId) {
    activeResources.set(asyncId, { type, triggerAsyncId });
  },
  destroy(asyncId) {
    activeResources.delete(asyncId);
  }
});

hook.enable();

// After some time, check what's still active
setTimeout(() => {
  console.log('Active async resources:', activeResources.size);
  for (const [id, resource] of activeResources) {
    console.log(`  ${id}: ${resource.type}`);
  }
}, 5000);
```

### Event Loop Best Practices

**Keep Callbacks Fast**

Long-running synchronous code blocks the entire event loop.

```javascript
// BAD: Blocks event loop
app.get('/slow', (req, res) => {
  let sum = 0;
  for (let i = 0; i < 10000000000; i++) {
    sum += i;
  }
  res.send(`Result: ${sum}`);
});

// GOOD: Break into chunks or use worker threads
const { Worker } = require('worker_threads');

app.get('/fast', (req, res) => {
  const worker = new Worker('./heavy-computation.js');
  worker.on('message', (result) => {
    res.send(`Result: ${result}`);
  });
});
```

**Prefer setImmediate over setTimeout(fn, 0)**

`setImmediate()` is more explicit about intent and slightly more efficient for deferring to the next iteration.

```javascript
// Less clear intent
setTimeout(() => {
  doSomethingAsync();
}, 0);

// Clear intent: run after I/O
setImmediate(() => {
  doSomethingAsync();
});
```

**Use process.nextTick() Sparingly**

Only use `process.nextTick()` when you specifically need to run before I/O events. Overuse can starve I/O.

```javascript
// Good use: ensuring async behavior
function myAsyncFunction(callback) {
  process.nextTick(() => {
    callback(null, result);
  });
}

// Questionable use: probably should be setImmediate
process.nextTick(() => {
  doNonUrgentWork();
});
```

### Visualizing Event Loop Flow

```javascript
console.log('1: Sync start');

setTimeout(() => {
  console.log('6: Timer callback');
  
  Promise.resolve().then(() => {
    console.log('7: Promise in timer');
  });
}, 0);

Promise.resolve()
  .then(() => {
    console.log('3: Promise microtask');
    return Promise.resolve();
  })
  .then(() => {
    console.log('4: Chained promise');
  });

process.nextTick(() => {
  console.log('2: nextTick microtask');
  
  process.nextTick(() => {
    console.log('2.5: Nested nextTick');
  });
});

setImmediate(() => {
  console.log('8: setImmediate callback');
});

console.log('5: Sync end');

// Output:
// 1: Sync start
// 5: Sync end
// 2: nextTick microtask
// 2.5: Nested nextTick
// 3: Promise microtask
// 4: Chained promise
// 6: Timer callback
// 7: Promise in timer
// 8: setImmediate callback
```

Understanding the event loop helps you write code that doesn't block, handles errors properly, and performs well—all critical for building responsive Electron applications.

## EventEmitter

EventEmitter is a core pattern in Node.js (and by extension, Electron) for handling asynchronous events. It's part of Node.js's built-in `events` module and provides a fundamental way for objects to emit named events and for listeners to respond to them.

### What is EventEmitter?

EventEmitter is a class that allows objects to implement the observer pattern. Objects that extend or use EventEmitter can:

- Emit named events
- Register listener functions that execute when specific events occur
- Pass data along with events to listeners

### Basic Concepts

**Events and Listeners**

An event is simply a named occurrence in your program. A listener is a callback function that runs when that event is emitted. The relationship is many-to-many: one event can have multiple listeners, and one listener can respond to multiple events.

**How It Works**

When you call `.emit('eventName')`, all functions registered as listeners for that event name get called synchronously, in the order they were registered.

### Core Methods

**on(eventName, listener)**

Registers a listener function for a specific event. The listener will be called every time the event is emitted.

```javascript
const EventEmitter = require('events');
const emitter = new EventEmitter();

emitter.on('data', (message) => {
  console.log('Received:', message);
});
```

**emit(eventName, [args])**

Triggers an event, calling all registered listeners with the provided arguments.

```javascript
emitter.emit('data', 'Hello World');
// Output: Received: Hello World
```

**once(eventName, listener)**

Registers a listener that will be called at most one time. After the event fires once, the listener is automatically removed.

```javascript
emitter.once('start', () => {
  console.log('Started!');
});

emitter.emit('start'); // Output: Started!
emitter.emit('start'); // No output - listener removed after first call
```

**removeListener(eventName, listener)**

Removes a specific listener from an event. You need a reference to the original function.

```javascript
function handleData(msg) {
  console.log(msg);
}

emitter.on('data', handleData);
emitter.removeListener('data', handleData);
```

**removeAllListeners([eventName])**

Removes all listeners for a specific event, or all listeners for all events if no event name is provided.

### Practical Example

```javascript
const EventEmitter = require('events');

class DataProcessor extends EventEmitter {
  processFile(filename) {
    this.emit('start', filename);
    
    // Simulate processing
    setTimeout(() => {
      const data = { filename, lines: 100 };
      this.emit('progress', 50);
      
      setTimeout(() => {
        this.emit('progress', 100);
        this.emit('complete', data);
      }, 500);
    }, 500);
  }
}

const processor = new DataProcessor();

processor.on('start', (filename) => {
  console.log(`Processing ${filename}...`);
});

processor.on('progress', (percent) => {
  console.log(`${percent}% complete`);
});

processor.on('complete', (data) => {
  console.log(`Finished processing ${data.filename}: ${data.lines} lines`);
});

processor.processFile('data.txt');
```

### Error Handling

EventEmitter has special behavior for `'error'` events. If you emit an error event and there are no listeners registered for it, Node.js will throw an exception and potentially crash your program.

```javascript
// Bad - will crash if error is emitted
const emitter = new EventEmitter();
emitter.emit('error', new Error('Something went wrong'));

// Good - error is caught
emitter.on('error', (err) => {
  console.error('Error occurred:', err.message);
});
emitter.emit('error', new Error('Something went wrong'));
```

### Memory Considerations

By default, EventEmitter warns if you add more than 10 listeners to a single event, as this might indicate a memory leak. You can adjust this with `setMaxListeners()`.

```javascript
emitter.setMaxListeners(20); // Allow up to 20 listeners
```

### Common Patterns

**Chaining Events**

EventEmitters can listen to other EventEmitters, creating chains of event propagation.

```javascript
const source = new EventEmitter();
const processor = new EventEmitter();

source.on('data', (data) => {
  const processed = data.toUpperCase();
  processor.emit('processed', processed);
});

processor.on('processed', (result) => {
  console.log('Result:', result);
});

source.emit('data', 'hello'); // Output: Result: HELLO
```

**Promisifying Events**

You can convert event-based APIs to Promises using utilities like `events.once()` (available in newer Node.js versions).

```javascript
const { once } = require('events');

async function waitForEvent() {
  const emitter = new EventEmitter();
  
  setTimeout(() => emitter.emit('ready'), 1000);
  
  const [value] = await once(emitter, 'ready');
  console.log('Ready!');
}
```

### Why EventEmitter Matters

EventEmitter provides a clean, decoupled way to handle asynchronous operations. Instead of tightly coupling your code with callbacks or forcing everything through a single function, you can emit events that any part of your application can listen to. This makes code more modular, testable, and easier to extend.

In Electron specifically, many core objects like `BrowserWindow`, `app`, and `ipcMain`/`ipcRenderer` extend EventEmitter, allowing you to respond to lifecycle events, user interactions, and inter-process communication through this familiar event-based interface.

---

## The Event Object

When working with EventEmitter in Node.js and Electron, you'll encounter **event objects** that are passed to listener functions. However, it's important to understand that the basic Node.js EventEmitter doesn't automatically create or pass a standardized "event object" - this varies by context.

### Node.js EventEmitter: No Built-in Event Object

In vanilla Node.js EventEmitter, there is no automatic event object. The emitter simply passes whatever arguments you provide to `emit()` directly to the listeners.

```javascript
const EventEmitter = require('events');
const emitter = new EventEmitter();

emitter.on('custom', (arg1, arg2, arg3) => {
  console.log(arg1, arg2, arg3);
});

emitter.emit('custom', 'hello', 42, { data: 'test' });
// Output: hello 42 { data: 'test' }
```

There's no standardized "event object" here - just the arguments you choose to pass.

### Electron's Event Objects

In Electron, many built-in events **do** pass an event object as the first parameter. This object contains metadata and utility methods specific to Electron's architecture.

**Common Properties**

**sender**

A reference to the object that sent the event (often a `WebContents` instance in IPC communication).

```javascript
ipcMain.on('message', (event, data) => {
  console.log(event.sender); // WebContents instance
  event.sender.send('reply', 'Got your message');
});
```

**returnValue** (synchronous IPC only)

Used in synchronous IPC to set the return value.

```javascript
ipcMain.on('sync-message', (event, data) => {
  event.returnValue = 'Synchronous reply';
});
```

Renderer process response:

```javascript
// renderer.js
const { ipcRenderer } = require('electron');

const result = ipcRenderer.sendSync('sync-message', 'ping');
console.log(result); // 'Synchronous reply'
```

What is happening conceptually.

sendSync sends a message to the main process and blocks the renderer thread until the main process assigns event.returnValue.

Important behavioral details.
- ipcRenderer.sendSync() returns the value assigned to event.returnValue.
- The renderer is frozen until the main handler completes.
- Only one value can be returned (not streams, not async results).
- If event.returnValue is never set, the renderer will hang or throw.

Why this is discouraged.
- Synchronous IPC blocks:
- UI rendering
- User input
- JavaScript execution

This is why Electron strongly recommends:

```javascript
ipcRenderer.invoke(...) / ipcMain.handle(...)
```

instead of synchronous IPC.

Equivalent async (recommended) pattern:

```javascript
// main.js
ipcMain.handle('async-message', async (_, data) => {
  return 'Asynchronous reply';
});

// renderer.js
const result = await ipcRenderer.invoke('async-message', 'ping');
console.log(result);
```

**preventDefault()**

Prevents the default behavior of certain events (like window closing, navigation, etc.).

```javascript
win.webContents.on('will-navigate', (event, url) => {
  if (!url.startsWith('https://trusted-domain.com')) {
    event.preventDefault(); // Block navigation
  }
});
```

**reply(...args)** (IPC events)

A convenience method to send a reply back to the sender on the same channel.

```javascript
ipcMain.on('request', (event, data) => {
  event.reply('request', 'Here is your response');
});
```

### Example: IPC Event Object in Electron

```javascript
// Main process
const { ipcMain } = require('electron');

ipcMain.on('user-action', (event, actionData) => {
  console.log('Event sender:', event.sender.id);
  console.log('Action data:', actionData);
  
  // Send reply using event object
  event.reply('action-response', {
    success: true,
    timestamp: Date.now()
  });
});

// Renderer process
const { ipcRenderer } = require('electron');

ipcRenderer.send('user-action', { type: 'click', button: 'submit' });

ipcRenderer.on('action-response', (event, response) => {
  console.log('Response:', response);
  // Note: In renderer, event object has fewer properties
});
```

### Browser DOM Events vs EventEmitter Events

It's worth noting that Electron's renderer process can also work with standard browser DOM events, which have their own event objects with properties like:

- `target`: The element that triggered the event
- `currentTarget`: The element the listener is attached to
- `type`: The event type (e.g., 'click', 'keydown')
- `preventDefault()`: Prevents default browser behavior
- `stopPropagation()`: Stops event bubbling

```javascript
// This is a DOM event, not an EventEmitter event
document.getElementById('btn').addEventListener('click', (event) => {
  console.log(event.target); // The button element
  console.log(event.type);   // 'click'
  event.preventDefault();
});
```

These are **different** from Electron's IPC event objects, even though they share some method names like `preventDefault()`.

### Custom Event Objects

If you're creating your own EventEmitter-based classes, you can choose to pass event objects with whatever structure makes sense for your use case:

```javascript
class CustomEmitter extends EventEmitter {
  doSomething(data) {
    const eventObject = {
      timestamp: Date.now(),
      source: 'CustomEmitter',
      data: data,
      preventDefault: function() {
        this.defaultPrevented = true;
      },
      defaultPrevented: false
    };
    
    this.emit('action', eventObject);
    
    if (!eventObject.defaultPrevented) {
      // Perform default behavior
      console.log('Default behavior executed');
    }
  }
}

const emitter = new CustomEmitter();

emitter.on('action', (event) => {
  console.log('Event data:', event.data);
  console.log('Timestamp:', event.timestamp);
  event.preventDefault(); // Cancel default behavior
});

emitter.doSomething({ value: 42 });
```

### Key Takeaways

The "event object" concept varies depending on context. In basic Node.js EventEmitter, you manually pass whatever arguments you want. In Electron's IPC and window events, you get structured event objects with useful properties and methods. Understanding which context you're in helps you know what properties and methods are available on the event parameter in your listener functions.

---


## process.memoryUsage()

This is a Node.js method that returns an object describing the memory usage of the current Node.js process, measured in bytes.

### Return Object Properties

**rss (Resident Set Size)** - Total memory allocated for the process, including all C++ and JavaScript objects and code.

**heapTotal** - Total size of the allocated heap.

**heapUsed** - Actual memory used during the execution of the process.

**external** - Memory used by C++ objects bound to JavaScript objects managed by V8.

**arrayBuffers** - Memory allocated for ArrayBuffers and SharedArrayBuffers.

### Basic Usage

```javascript
const memUsage = process.memoryUsage();
console.log(memUsage);

// Output example:
// {
//   rss: 36864000,
//   heapTotal: 6537216,
//   heapUsed: 4818568,
//   external: 1089863,
//   arrayBuffers: 26906
// }
```

### Converting to Megabytes

```javascript
const formatMemoryUsage = (data) => {
  const formatted = {};
  for (let key in data) {
    formatted[key] = `${Math.round(data[key] / 1024 / 1024 * 100) / 100} MB`;
  }
  return formatted;
};

console.log(formatMemoryUsage(process.memoryUsage()));
```

### Monitoring Memory Over Time

```javascript
setInterval(() => {
  const mem = process.memoryUsage();
  console.log(`Heap Used: ${(mem.heapUsed / 1024 / 1024).toFixed(2)} MB`);
}, 1000);
```

This is commonly used for debugging memory leaks or optimizing application performance.​​​​​​​​​​​​​​​​

---

## Block Device vs Character Device

### Overview

In Unix-like operating systems, devices are represented as special files in the filesystem. These device files fall into two main categories: block devices and character devices. Each type has distinct characteristics regarding how data is transferred between the device and the system.

### Block Devices

Block devices handle data in fixed-size blocks or chunks. The system buffers the data and allows random access to any block.

**Characteristics:**

- Data is transferred in blocks (typically 512 bytes, 1024 bytes, 4096 bytes, or other fixed sizes)
- Support random access - you can read or write any block without accessing previous blocks
- Buffered I/O - the kernel caches data in memory
- Typically support filesystem operations
- Can be mounted as filesystems

**Common Examples:**

- Hard disk drives (HDDs)
- Solid-state drives (SSDs)
- USB flash drives
- CD/DVD drives
- Virtual block devices

**Device File Representation:**

Block devices appear in `/dev/` with a "b" in the file permissions:

```
brw-rw---- 1 root disk 8, 0 Jan 23 10:00 /dev/sda
```

### Character Devices

Character devices handle data as a stream of characters or bytes, one at a time. Data flows sequentially without buffering at the block level.

**Characteristics:**

- Data is transferred byte-by-byte or in variable-length streams
- Sequential access - data is typically read or written in order
- Unbuffered or minimally buffered I/O
- Direct communication with the device
- Cannot be mounted as filesystems

**Common Examples:**

- Serial ports
- Parallel ports
- Terminals and pseudo-terminals
- Keyboards
- Mice
- Sound cards
- Random number generators (`/dev/random`, `/dev/urandom`)
- Null device (`/dev/null`)

**Device File Representation:**

Character devices appear in `/dev/` with a "c" in the file permissions:

```
crw-rw-rw- 1 root tty 1, 3 Jan 23 10:00 /dev/null
```

### Key Differences

|Aspect|Block Device|Character Device|
|---|---|---|
|Data Transfer|Fixed-size blocks|Byte streams|
|Access Pattern|Random access|Sequential access|
|Buffering|Buffered by kernel|Minimal or no buffering|
|Filesystem Support|Yes|No|
|Examples|Hard drives, SSDs|Terminals, serial ports|

### Technical Details

**Major and Minor Numbers:**

Both device types use major and minor numbers for identification:

- **Major number**: Identifies the device driver
- **Minor number**: Identifies the specific device instance

In the example `/dev/sda` above, "8" is the major number and "0" is the minor number.

**Device Driver Interaction:**

The kernel uses different interfaces for each device type:

- Block devices use the block I/O subsystem with request queues
- Character devices use direct read/write operations through character device drivers

### Practical Implications

**When to Use Block Devices:**

- Storage that requires filesystem organization
- Applications needing random access to data
- Large data transfers where buffering improves performance

**When to Use Character Devices:**

- Real-time data streams
- Interactive devices requiring immediate response
- Simple byte-oriented communication
- Devices where buffering would introduce unwanted latency

---

## Inter-Process Communication: FIFO Pipes and Sockets

### FIFO Pipes (Named Pipes)

FIFO pipes are a form of inter-process communication that allows unrelated processes to exchange data through a special file in the filesystem. Unlike anonymous pipes, FIFOs have a pathname and can be accessed by any process with appropriate permissions.

**Key Characteristics:**

- **Unidirectional communication**: Data flows in one direction only
- **File-based interface**: Created using `mkfifo()` system call or command
- **Persistent**: Exists in the filesystem until explicitly deleted
- **Local only**: Limited to processes on the same machine
- **FIFO ordering**: First data written is first data read
- **Blocking behavior**: Reads block when empty, writes block when full

**Common Use Cases:**

- Simple producer-consumer patterns on the same host
- Shell script communication
- Logging and data pipeline applications

### Sockets

Sockets provide a more flexible communication mechanism that supports both local and network-based inter-process communication. They offer bidirectional data exchange and multiple protocol options.

**Key Characteristics:**

- **Bidirectional communication**: Data can flow in both directions
- **Multiple domains**: Unix domain (local) and Internet domain (network)
- **Protocol options**: Stream (TCP), datagram (UDP), and others
- **Connection models**: Connection-oriented or connectionless
- **Network capable**: Can communicate across different machines
- **More complex API**: Requires socket creation, binding, connecting/listening

**Common Use Cases:**

- Client-server applications
- Network services and protocols
- Local high-performance IPC (Unix domain sockets)
- Distributed systems

### Comparison

| Aspect              | FIFO Pipes       | Sockets                        |
| ------------------- | ---------------- | ------------------------------ |
| Direction           | Unidirectional   | Bidirectional                  |
| Scope               | Local only       | Local or network               |
| Complexity          | Simple           | More complex                   |
| Performance (local) | Fast             | Unix domain sockets comparable |
| Use case            | Simple local IPC | Complex/network IPC            |
|                     |                  |                                |

---

# Web

## **`MessageChannel`**

### **What is MessageChannel?**

MessagePorts are a web feature that allow passing messages between different contexts. It's like window.postMessage, but on different channels.

#### **Basic Concept**

MessagePorts are created in pairs. A connected pair of message ports is called a channel:

```javascript
// MessagePorts are created in pairs
const channel = new MessageChannel()

// Messages sent to port1 will be received by port2 and vice-versa
const port1 = channel.port1
const port2 = channel.port2

// It's OK to send a message before the other end has a listener
// Messages will be queued until a listener is registered
port2.postMessage({ answer: 42 })
```

---

### **MessageChannel in Different Processes**

#### **In the Renderer Process**

In the renderer, the MessagePort class behaves exactly as it does on the web:

```javascript
// Renderer process - uses standard web API
const channel = new MessageChannel()
const port1 = channel.port1
const port2 = channel.port2

port1.onmessage = (event) => {
  console.log(event.data)
}

port2.postMessage('hello')
```

#### **In the Main Process**

The main process is not a web page and has no Blink integration, so it does not have the MessagePort or MessageChannel classes. Electron adds two new classes: MessagePortMain and MessageChannelMain:

```javascript
// Main process - uses Electron-specific classes
const { MessageChannelMain } = require('electron')

const { port1, port2 } = new MessageChannelMain()

// MessagePortMain uses Node.js-style events API
port1.on('message', (event) => {
  console.log(event.data)
})

// MessagePortMain queues messages until .start() is called
port1.start()

port2.postMessage({ answer: 42 })
```

---

### **Key Differences: Main vs Renderer**

| Aspect | Renderer Process | Main Process |
|--------|------------------|--------------|
| **Class Name** | `MessageChannel` | `MessageChannelMain` |
| **Port Class** | `MessagePort` | `MessagePortMain` |
| **Event Handling** | Web-style (`onmessage`, `addEventListener`) | Node.js-style (`.on('message', ...)`) |
| **Message Queue** | Auto-started | Must call `.start()` |

---

### **Transferring MessagePorts**

MessagePort objects can be created in either the renderer or the main process, and passed back and forth using the ipcRenderer.postMessage and WebContents.postMessage methods. Note that the usual IPC methods like send and invoke cannot be used to transfer MessagePorts, only the postMessage methods can transfer MessagePorts.

#### **CRITICAL: Use postMessage, NOT send or invoke**

```javascript
// ✓ CORRECT - Use postMessage
ipcRenderer.postMessage('port', null, [port1])
webContents.postMessage('port', null, [port2])

// ✗ WRONG - Cannot use send or invoke
ipcRenderer.send('port', port1)  // Won't work!
ipcMain.handle('port', () => port1)  // Won't work!
```

---

### **The `close` Event (Electron Extension)**

Electron adds one feature to MessagePort that isn't present on the web: the close event, which is emitted when the other end of the channel is closed. Ports can also be implicitly closed by being garbage-collected.

#### **Listening for Close**

```javascript
// In renderer
port.onclose = () => {
  console.log('Port closed')
}
// OR
port.addEventListener('close', () => {
  console.log('Port closed')
})

// In main process
port.on('close', () => {
  console.log('Port closed')
})
```

---

### **Common Use Cases**

#### **1. Direct Renderer-to-Renderer Communication**

By passing MessagePorts via the main process, you can connect two pages that might not otherwise be able to communicate, allowing renderers to send messages to each other without needing to use the main process as an in-between.

**Main Process:**
```javascript
const { BrowserWindow, app, MessageChannelMain } = require('electron')

app.whenReady().then(async () => {
  const mainWindow = new BrowserWindow({
    show: false,
    webPreferences: {
      contextIsolation: false,
      preload: 'preloadMain.js'
    }
  })
  
  const secondaryWindow = new BrowserWindow({
    show: false,
    webPreferences: {
      contextIsolation: false,
      preload: 'preloadSecondary.js'
    }
  })
  
  // Set up the channel
  const { port1, port2 } = new MessageChannelMain()
  
  // Send one port to each window
  mainWindow.once('ready-to-show', () => {
    mainWindow.webContents.postMessage('port', null, [port1])
  })
  
  secondaryWindow.once('ready-to-show', () => {
    secondaryWindow.webContents.postMessage('port', null, [port2])
  })
})
```

**Preload Scripts (both windows):**
```javascript
const { ipcRenderer } = require('electron')

ipcRenderer.on('port', e => {
  // Port received, make it globally available
  window.electronMessagePort = e.ports[0]
  
  window.electronMessagePort.onmessage = messageEvent => {
    console.log('Received:', messageEvent.data)
  }
})
```

**Renderer (any window):**
```javascript
// Send message to the other renderer
window.electronMessagePort.postMessage('ping')
```

---

#### **2. Worker Process Pattern**

Create a hidden worker window for CPU-intensive tasks:

**Main Process:**
```javascript
const { BrowserWindow, app, MessageChannelMain } = require('electron')

app.whenReady().then(async () => {
  // Hidden worker window
  const worker = new BrowserWindow({
    show: false,
    webPreferences: { nodeIntegration: true }
  })
  await worker.loadFile('worker.html')
  
  // Main app window
  const mainWindow = new BrowserWindow({
    webPreferences: { nodeIntegration: true }
  })
  mainWindow.loadFile('app.html')
  
  // Listen for channel request from main window
  mainWindow.webContents.mainFrame.ipc.on('request-worker-channel', (event) => {
    // Create a new channel
    const { port1, port2 } = new MessageChannelMain()
    
    // Send one end to the worker
    worker.webContents.postMessage('new-client', null, [port1])
    
    // Send the other end to the main window
    event.senderFrame.postMessage('provide-worker-channel', null, [port2])
    
    // Now they can communicate directly!
  })
})
```

**Worker (worker.html):**
```javascript
const { ipcRenderer } = require('electron')

const doWork = (input) => {
  // CPU-intensive operation
  return input * 2
}

// Handle multiple clients
ipcRenderer.on('new-client', (event) => {
  const [ port ] = event.ports
  
  port.onmessage = (event) => {
    const result = doWork(event.data)
    port.postMessage(result)
  }
})
```

**Main App (app.html):**
```javascript
const { ipcRenderer } = require('electron')

// Request a worker channel
ipcRenderer.send('request-worker-channel')

ipcRenderer.once('provide-worker-channel', (event) => {
  const [ port ] = event.ports
  
  // Register result handler
  port.onmessage = (event) => {
    console.log('received result:', event.data)
  }
  
  // Send work to worker
  port.postMessage(21)
})
```

---

#### **3. Response Streams (Multiple Responses)**

Electron's built-in IPC methods only support two modes: fire-and-forget (e.g. send), or request-response (e.g. invoke). Using MessageChannels, you can implement a "response stream", where a single request responds with a stream of data.

**Renderer:**
```javascript
const makeStreamingRequest = (element, callback) => {
  // Create a new channel for this request
  const { port1, port2 } = new MessageChannel()
  
  // Send one end to main process
  ipcRenderer.postMessage(
    'give-me-a-stream',
    { element, count: 10 },
    [port2]
  )
  
  // Receive multiple messages on our end
  port1.onmessage = (event) => {
    callback(event.data)
  }
  
  port1.onclose = () => {
    console.log('stream ended')
  }
}

makeStreamingRequest(42, (data) => {
  console.log('got response data:', data)
})
// Will see "got response data: 42" 10 times
```

**Main Process:**
```javascript
ipcMain.on('give-me-a-stream', (event, msg) => {
  const [replyPort] = event.ports
  
  // Send multiple messages
  for (let i = 0; i < msg.count; i++) {
    replyPort.postMessage(msg.element)
  }
  
  // Close when done
  replyPort.close()
})
```

---

#### **4. Context-Isolated Communication**

When context isolation is enabled, IPC messages from the main process to the renderer are delivered to the isolated world, rather than to the main world. Sometimes you want to deliver messages to the main world directly, without having to step through the isolated world.

**Main Process:**
```javascript
const { BrowserWindow, app, MessageChannelMain } = require('electron')
const path = require('node:path')

app.whenReady().then(async () => {
  const bw = new BrowserWindow({
    webPreferences: {
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })
  bw.loadURL('index.html')
  
  const { port1, port2 } = new MessageChannelMain()
  
  // Send message before listener is registered (will be queued)
  port2.postMessage({ test: 21 })
  
  // Receive messages from renderer
  port2.on('message', (event) => {
    console.log('from renderer main world:', event.data)
  })
  port2.start()
  
  // Send port to preload
  bw.webContents.postMessage('main-world-port', null, [port1])
})
```

**Preload Script:**
```javascript
const { ipcRenderer } = require('electron')

// Wait for window to load
const windowLoaded = new Promise(resolve => {
  window.onload = resolve
})

ipcRenderer.on('main-world-port', async (event) => {
  await windowLoaded
  
  // Transfer port from isolated world to main world
  window.postMessage('main-world-port', '*', event.ports)
})
```

**Renderer (index.html):**
```javascript
window.onmessage = (event) => {
  // Ensure message is from preload, not iframe
  if (event.source === window && event.data === 'main-world-port') {
    const [ port ] = event.ports
    
    // Now we can communicate directly with main process
    port.onmessage = (event) => {
      console.log('from main process:', event.data)
      port.postMessage(event.data.test * 2)
    }
  }
}
```

---

### **MessagePortMain API Reference**

#### **Methods**

```javascript
const { MessageChannelMain } = require('electron')
const { port1, port2 } = new MessageChannelMain()

// Send message
port1.postMessage(value, [transferList])

// Start receiving messages (required in main process)
port1.start()

// Close the port
port1.close()
```

#### **Events**

```javascript
// Message received
port1.on('message', (event) => {
  console.log(event.data)
})

// Port closed
port1.on('close', () => {
  console.log('Port closed')
})
```

---

### **MessagePort API Reference (Renderer)**

#### **Properties & Methods**

```javascript
const channel = new MessageChannel()
const port = channel.port1

// Send message
port.postMessage(value, [transferList])

// Close port
port.close()

// Start receiving (called automatically in renderer)
port.start()
```

#### **Event Handling**

```javascript
// Option 1: onmessage property
port.onmessage = (event) => {
  console.log(event.data)
}

// Option 2: addEventListener
port.addEventListener('message', (event) => {
  console.log(event.data)
})

// Close event
port.onclose = () => {
  console.log('Port closed')
}
```

---

### **Best Practices**

#### **1. Always Use postMessage for Transfer**

```javascript
// ✓ CORRECT
webContents.postMessage('channel', null, [port])
ipcRenderer.postMessage('channel', null, [port])

// ✗ WRONG
webContents.send('channel', port)  // Won't transfer!
ipcRenderer.send('channel', port)   // Won't transfer!
```

#### **2. Call start() in Main Process**

```javascript
// Main process
port.on('message', (event) => {
  console.log(event.data)
})
port.start()  // Required! Messages are queued until this is called
```

#### **3. Handle Port Cleanup**

```javascript
// Listen for close to clean up resources
port.on('close', () => {
  // Clean up any resources
  clearInterval(someInterval)
  removeEventListeners()
})

// Explicitly close when done
port.close()
```

#### **4. Create New Channels for Each Request**

```javascript
// MessageChannels are lightweight - create new ones as needed
const makeRequest = (data) => {
  const { port1, port2 } = new MessageChannel()
  
  ipcRenderer.postMessage('request', data, [port2])
  
  port1.onmessage = (event) => {
    console.log('Response:', event.data)
  }
}
```

#### **5. Use Context Isolation Safely**

```javascript
// Preload script with contextBridge
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('api', {
  connectToWorker: (callback) => {
    ipcRenderer.send('request-worker')
    
    ipcRenderer.once('worker-port', (event) => {
      const [port] = event.ports
      
      port.onmessage = (e) => {
        // Only pass data, not the entire event
        callback(e.data)
      }
    })
  }
})
```

---

### **Common Pitfalls**

#### **1. Forgetting to Call start() in Main Process**

```javascript
// BAD - Messages won't be received
port.on('message', handler)
// port.start() is missing!

// GOOD
port.on('message', handler)
port.start()
```

#### **2. Using send() Instead of postMessage()**

```javascript
// BAD - Port won't transfer
event.sender.send('port', port)

// GOOD
event.sender.postMessage('port', null, [port])
```

#### **3. Not Handling Port Closure**

```javascript
// GOOD - Handle closure
port.on('close', () => {
  console.log('Connection closed')
  // Clean up resources
})
```

---

### **Summary**

**MessageChannel enables:**
- Direct renderer-to-renderer communication
- Worker process patterns
- Streaming responses
- Context-isolated communication
- Avoiding main process as middleman

**Key Points:**
- Use `MessageChannelMain` in main process
- Use `MessageChannel` in renderer
- **Only** `postMessage()` can transfer ports
- Main process ports require `.start()`
- Ports can be closed explicitly or by garbage collection
- Electron adds `close` event not present in web standard

---

## Notifications API

### How Web Notifications Get Displayed

The Web Notifications API displays notifications at the **system level**, outside of the browser viewport and webpage context. When a notification is created, the browser hands it off to the operating system's native notification system, which then renders it according to the platform's UI conventions. [developer.mozilla](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API/Using_the_Notifications_API)

### Display Mechanism

When you create a notification using `new Notification(title, options)`, the browser performs several steps: [developer.mozilla](https://developer.mozilla.org/en-US/docs/Web/API/Notification)

- The browser checks if the user has granted notification permission
- If permission exists, the browser communicates with the OS notification center
- The OS renders the notification using native system UI components
- The notification appears in the same location and style as system notifications from other applications

This means notifications appear in different locations depending on the platform: Windows shows them in the Action Center, macOS in Notification Center, and Linux distributions in their respective notification daemons. [mdn2.netlify](https://mdn2.netlify.app/en-us/docs/web/api/notifications_api/)

### Notification Lifecycle Events

The API exposes four key events that track the notification's display lifecycle: [sitepoint](https://www.sitepoint.com/introduction-web-notifications-api/)

- **onshow**: Fired when the notification is displayed to the user
- **onclick**: Triggered when the user clicks the notification
- **onclose**: Fired when the user or browser closes the notification
- **onerror**: Fired if an error occurs during notification display

### Permission Requirement

Before any notification can be shown, the browser must request permission using `Notification.requestPermission()`. This displays a browser-level permission prompt, and only after the user grants permission can notifications be rendered through the OS notification system. The notification remains displayed according to system settings unless programmatically closed using the `close()` method or dismissed by the user. [sitepoint](https://www.sitepoint.com/browser-notification-api/)

---

## windows.location in Electron

In Electron, `window.location` in a renderer process works almost the same as in a normal browser: it represents the **current URL of the web page loaded in that renderer window**.

It’s an object with properties like:

* `window.location.href` → full URL string (e.g., `file:///path/to/index.html` or `https://example.com`)
* `window.location.pathname` → path portion (e.g., `/index.html`)
* `window.location.origin` → origin (protocol + host, e.g., `file://` or `https://example.com`)
* `window.location.hash` → any fragment after `#`
* `window.location.search` → query parameters after `?`

In Electron, since most windows load local files via `file://`, `window.location` often looks like this:

```text
file:///home/user/project/dist/index.html
```

So if you do:

```javascript
console.log(window.location.pathname);
```

You might see:

```
/home/user/project/dist/index.html
```

This is often used in preload scripts to **branch behavior depending on which HTML page is loaded**, e.g., parent vs child window.

**Important note:** Electron’s `window.location` is read/write, just like in the browser. Changing it navigates the renderer window, which is equivalent to `window.location.href = 'newpage.html'`.

---

## HTML API-triggered Fullscreen

If you want to trigger fullscreen in a web page using an **HTML/JavaScript API**, you use the **Fullscreen API**, which is part of standard web APIs. It allows an element (like a `<div>` or the `<body>`) to enter fullscreen mode programmatically.

Here’s a concise example:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Fullscreen Example</title>
</head>
<body>
  <button id="fsBtn">Go Fullscreen</button>
  <div id="content" style="width: 100%; height: 300px; background-color: lightblue;">
    Fullscreen this content
  </div>

  <script>
    const button = document.getElementById('fsBtn');
    const content = document.getElementById('content');

    button.addEventListener('click', () => {
      if (content.requestFullscreen) {
        content.requestFullscreen();
      } else if (content.webkitRequestFullscreen) { // Safari
        content.webkitRequestFullscreen();
      } else if (content.msRequestFullscreen) { // IE/Edge
        content.msRequestFullscreen();
      }
    });

    // Optional: Listen for exit fullscreen
    document.addEventListener('fullscreenchange', () => {
      if (!document.fullscreenElement) {
        console.log('Exited fullscreen');
      }
    });
  </script>
</body>
</html>
```

**Explanation:**

- `element.requestFullscreen()` triggers fullscreen for the element.
    
- Some browsers (Safari, IE/Edge) require prefixes: `webkitRequestFullscreen`, `msRequestFullscreen`.
    
- `document.fullscreenElement` tells you what element is currently fullscreen.
    
- Fullscreen mode can only be triggered **by user interaction** (like a click), due to browser security restrictions.
    

You can also exit fullscreen programmatically:

```js
if (document.exitFullscreen) {
  document.exitFullscreen();
}
```

This API works in browsers, and in **Electron**, it works too, but you can also use **BrowserWindow** methods like `win.setFullScreen(true)` for native fullscreen.

---

If you want, I can give an **Electron-specific version** where the fullscreen is triggered from the renderer using an IPC call to the main process. That approach integrates better with Electron’s window management. Do you want me to show that?

---

# Best Practices

## Solving Memory Leaks with webContents.send()

### Problem Demonstration

```javascript
// Main Process - Causes memory leak
setInterval(() => {
  mainWindow.webContents.send('update', largeDataObject);
}, 100); // Sending 10 times per second
```

```javascript
// Renderer Process - Memory accumulates
ipcRenderer.on('update', (event, data) => {
  // Processing data without cleanup
  updateUI(data);
});
```

### Solution 1: Throttling Updates

**Throttling** ensures the function executes at most once per specified time period.

```javascript
// Main Process
const throttle = (func, limit) => {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
};

const sendUpdate = throttle((data) => {
  mainWindow.webContents.send('update', data);
}, 1000); // Maximum once per second

// Now use throttled version
setInterval(() => {
  sendUpdate(data);
}, 100);
```

### Solution 2: Debouncing Updates

**Debouncing** delays execution until after a period of inactivity.

```javascript
// Main Process
const debounce = (func, delay) => {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
};

const sendUpdate = debounce((data) => {
  mainWindow.webContents.send('update', data);
}, 500); // Wait 500ms after last call

// Rapid calls will only send the last update
dataStream.on('data', (chunk) => {
  sendUpdate(chunk);
});
```

### Solution 3: Proper Listener Cleanup

```javascript
// Renderer Process - BAD (creates multiple listeners)
function setupListener() {
  ipcRenderer.on('update', (event, data) => {
    updateUI(data);
  });
}

setupListener(); // Called multiple times = memory leak
```

```javascript
// Renderer Process - GOOD (cleanup before adding)
function setupListener() {
  // Remove existing listener first
  ipcRenderer.removeAllListeners('update');
  
  ipcRenderer.on('update', (event, data) => {
    updateUI(data);
  });
}
```

### Solution 4: Using once() for Single-Use Listeners

```javascript
// Renderer Process
ipcRenderer.once('update', (event, data) => {
  // Automatically removed after first execution
  updateUI(data);
});
```

### Solution 5: Complete Implementation with Cleanup

```javascript
// Main Process
class UpdateManager {
  constructor(window) {
    this.window = window;
    this.lastSent = 0;
    this.minInterval = 1000; // Minimum 1 second between updates
  }

  sendUpdate(data) {
    const now = Date.now();
    if (now - this.lastSent >= this.minInterval) {
      this.window.webContents.send('update', data);
      this.lastSent = now;
    }
  }
}

const updateManager = new UpdateManager(mainWindow);

setInterval(() => {
  updateManager.sendUpdate(getData());
}, 100);
```

```javascript
// Renderer Process
class UpdateHandler {
  constructor() {
    this.listener = null;
  }

  start() {
    // Clean up existing listener
    this.stop();
    
    // Create new listener
    this.listener = (event, data) => {
      this.processUpdate(data);
    };
    
    ipcRenderer.on('update', this.listener);
  }

  stop() {
    if (this.listener) {
      ipcRenderer.removeListener('update', this.listener);
      this.listener = null;
    }
  }

  processUpdate(data) {
    // Your update logic here
    updateUI(data);
  }
}

const handler = new UpdateHandler();
handler.start();

// Clean up when component unmounts or window closes
window.addEventListener('beforeunload', () => {
  handler.stop();
});
```

### Solution 6: Using Lodash Throttle/Debounce

```javascript
// Install: npm install lodash

// Main Process
const _ = require('lodash');

const sendUpdate = _.throttle((data) => {
  mainWindow.webContents.send('update', data);
}, 1000, { leading: true, trailing: false });

// Or debounce
const sendUpdateDebounced = _.debounce((data) => {
  mainWindow.webContents.send('update', data);
}, 500);
```

### Memory Monitoring

```javascript
// Check for memory leaks during development
setInterval(() => {
  const mem = process.memoryUsage();
  console.log(`Heap Used: ${(mem.heapUsed / 1024 / 1024).toFixed(2)} MB`);
}, 5000);
```

The key principles are: limit update frequency, clean up listeners properly, and avoid creating duplicate listeners.​​​​​​​​​​​​​​​​

---

# Libraries

## Electron-Redux: Complete Guide for React/Electron Developers New to Redux

### What is Redux?

**Redux** is a state management library that helps you manage application data in a predictable way. Think of it as a central storage container for all your app's data.

#### Core Redux Concepts You Need:

1. **Store**: A single JavaScript object that holds your entire application state
   ```javascript
   // Example store state
   ￼{
     user: { name: "John", loggedIn: true },
     todos: ["Buy milk", "Walk dog"]
   }
   ```

2. **Actions**: Plain JavaScript objects that describe what happened
   ```javascript
   // Action example
   ￼{
     type: 'ADD_TODO',
     payload: 'Buy groceries'
   }
   ```

3. **Reducers**: Pure functions that take current state + action, and return new state
   ```javascript
   ￼function todosReducer(state = [], action) {
     ￼if (action.type === 'ADD_TODO') {
       return [...state, action.payload];
     }
     return state;
   }
   ```

4. **Dispatch**: The method to send actions to the store
   ```javascript
   store.dispatch({ type: 'ADD_TODO', payload: 'Buy groceries' });
   ```

### The Electron-Redux Problem It Solves

**[1]** Information about Electron-Redux based on the description you provided, which I'm treating as documentation reference.