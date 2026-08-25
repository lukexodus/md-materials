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

