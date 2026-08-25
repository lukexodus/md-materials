## JavaScript/TypeScript client installation


The official JavaScript client (`@supabase/supabase-js`) is the primary way to interact with Supabase from JavaScript and TypeScript applications. It provides a unified interface for database queries, authentication, storage, realtime subscriptions, and Edge Functions.

### Installation methods

**Using npm:**

```bash
npm install @supabase/supabase-js
```

**Using yarn:**

```bash
yarn add @supabase/supabase-js
```

**Using pnpm:**

```bash
pnpm add @supabase/supabase-js
```

**Using bun:**

```bash
bun add @supabase/supabase-js
```

**Via CDN (browser only):**

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  const { createClient } = supabase
</script>
```

### Version considerations

**Major versions:**

**v1.x** (Legacy):

- Older API design
- Different method signatures
- Not recommended for new projects

**v2.x** (Current):

- Improved TypeScript support
- Better error handling
- Modular architecture
- Auto-refresh tokens
- Enhanced realtime features

**Check installed version:**

```bash
npm list @supabase/supabase-js
```

**Update to latest:**

```bash
npm update @supabase/supabase-js
```

### Package size and tree-shaking

The supabase-js library is modular and supports tree-shaking in modern bundlers (Webpack, Vite, Rollup).

**Full package size:** [Inference] Approximately 50-80KB minified and gzipped when all features included

**Reduce bundle size:** Only import what you need:

```typescript
// Instead of importing everything
import { createClient } from '@supabase/supabase-js'

// Import specific modules (if supported)
import { SupabaseClient } from '@supabase/supabase-js'
```

Modern bundlers automatically tree-shake unused code when using ES modules.

### Framework-specific packages

**React (with hooks):**

```bash
npm install @supabase/supabase-js
# No separate React package needed, but community provides helpers
npm install @supabase/auth-helpers-react
```

**Next.js:**

```bash
npm install @supabase/supabase-js
npm install @supabase/auth-helpers-nextjs
```

**SvelteKit:**

```bash
npm install @supabase/supabase-js
npm install @supabase/auth-helpers-sveltekit
```

**Vue:**

```bash
npm install @supabase/supabase-js
# Use standard client, no special package needed
```

**React Native:**

```bash
npm install @supabase/supabase-js
npm install @react-native-async-storage/async-storage
npm install react-native-url-polyfill
```

Additional setup required for React Native (URL polyfill, secure storage).

### Dependencies and peer dependencies

The supabase-js client has minimal dependencies:

- `@supabase/realtime-js` - Realtime subscriptions
- `@supabase/postgrest-js` - Database queries
- `@supabase/storage-js` - File storage
- `@supabase/functions-js` - Edge Functions
- `@supabase/auth-js` - Authentication

These are automatically installed as dependencies.

