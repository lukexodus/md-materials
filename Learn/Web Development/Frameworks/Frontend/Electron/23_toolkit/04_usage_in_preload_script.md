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

