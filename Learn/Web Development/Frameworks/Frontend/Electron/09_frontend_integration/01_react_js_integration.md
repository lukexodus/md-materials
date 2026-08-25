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

