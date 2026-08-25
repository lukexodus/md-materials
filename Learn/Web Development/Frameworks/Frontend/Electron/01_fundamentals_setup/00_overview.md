## Overview


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

