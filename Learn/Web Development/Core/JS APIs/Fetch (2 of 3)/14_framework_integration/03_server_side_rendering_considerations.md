## Server-Side Rendering Considerations


### Execution Environment Differences

The fetch API behaves differently between server and client environments. On the server, fetch executes in Node.js (or edge runtime environments), while client-side fetch runs in the browser. Server environments lack browser-specific features like cookies stored in `document.cookie`, `localStorage`, and automatic credential inclusion from the browser's cookie jar.

Server-side fetch requires explicit header management for authentication. Cookies must be forwarded manually from incoming requests to outgoing fetch calls, typically by reading them from request headers and passing them through.

### Next.js Integration

#### App Router Fetch Extensions

Next.js extends the native fetch API with additional caching and revalidation capabilities in the App Router. The framework wraps fetch to provide automatic request deduplication within a single render pass.

```javascript
// Static data fetching with indefinite cache
const response = await fetch('https://api.example.com/data', {
  cache: 'force-cache' // Default behavior
});

// Dynamic data fetching with no caching
const response = await fetch('https://api.example.com/data', {
  cache: 'no-store'
});

// Time-based revalidation
const response = await fetch('https://api.example.com/data', {
  next: { revalidate: 3600 } // Revalidate every hour
});

// Tag-based revalidation
const response = await fetch('https://api.example.com/data', {
  next: { tags: ['products'] }
});
```

The `next.revalidate` option controls cache lifetime at the request level. The `next.tags` option allows on-demand revalidation using `revalidateTag()` or `revalidatePath()` from server actions or route handlers.

#### Request Deduplication

Next.js automatically deduplicates identical fetch requests during server rendering. Multiple components requesting the same URL with identical options result in a single network request, with the response shared across all consumers.

```javascript
// These three fetches result in one network request
async function ComponentA() {
  const data = await fetch('https://api.example.com/user/1');
}

async function ComponentB() {
  const data = await fetch('https://api.example.com/user/1');
}

async function ComponentC() {
  const data = await fetch('https://api.example.com/user/1');
}
```

Deduplication applies only within the same render pass and only to GET requests. POST requests and requests with different headers are not deduplicated.

#### Pages Router Considerations

In the Pages Router, fetch is available but without the automatic caching extensions. Data fetching occurs in `getServerSideProps`, `getStaticProps`, or `getInitialProps`, where you control caching behavior through response headers or the framework's revalidation mechanisms.

```javascript
export async function getServerSideProps(context) {
  const response = await fetch('https://api.example.com/data', {
    headers: {
      cookie: context.req.headers.cookie || ''
    }
  });
  
  return {
    props: {
      data: await response.json()
    }
  };
}
```

### SvelteKit Integration

#### Load Functions

SvelteKit provides `load` functions that run on both server and client during navigation. The framework provides a custom `fetch` function as a parameter to these load functions.

```javascript
// +page.server.js - Server-only load
export async function load({ fetch, cookies, request }) {
  const response = await fetch('https://api.example.com/data', {
    headers: {
      cookie: cookies.serialize()
    }
  });
  
  return {
    data: await response.json()
  };
}

// +page.js - Universal load (runs on both server and client)
export async function load({ fetch, parent }) {
  const response = await fetch('https://api.example.com/data');
  
  return {
    data: await response.json()
  };
}
```

The SvelteKit-provided `fetch` function inherits credentials and headers from the original request during SSR, avoiding the need to manually forward cookies for same-origin requests. It also enables relative URLs that resolve correctly in both environments.

#### Cookie and Header Propagation

SvelteKit automatically forwards cookies from the incoming request to same-origin fetch calls during SSR. For cross-origin requests, you must explicitly include credentials or set appropriate headers.

```javascript
export async function load({ fetch, cookies }) {
  // Same-origin: cookies forwarded automatically
  const response1 = await fetch('/api/data');
  
  // Cross-origin: manual credential handling
  const response2 = await fetch('https://external-api.com/data', {
    credentials: 'include',
    headers: {
      'Authorization': `Bearer ${cookies.get('token')}`
    }
  });
  
  return {
    data1: await response1.json(),
    data2: await response2.json()
  };
}
```

### Remix Integration

#### Loaders and Actions

Remix handles data fetching through `loader` functions that execute on the server during SSR and on subsequent navigations. The framework doesn't extend fetch directly but provides request context.

```javascript
// app/routes/products.$id.jsx
export async function loader({ params, request }) {
  const cookie = request.headers.get('Cookie');
  
  const response = await fetch(`https://api.example.com/products/${params.id}`, {
    headers: {
      'Cookie': cookie || ''
    }
  });
  
  if (!response.ok) {
    throw new Response('Not Found', { status: 404 });
  }
  
  return response.json();
}
```

Remix loaders receive the raw Request object, allowing direct access to headers for forwarding. The loader's return value automatically serializes to JSON and becomes available to the route component through `useLoaderData()`.

#### Mutation Handling

Form submissions and mutations go through `action` functions, which also execute on the server. Actions handle POST, PUT, DELETE, and PATCH requests.

```javascript
export async function action({ request }) {
  const formData = await request.formData();
  const cookie = request.headers.get('Cookie');
  
  const response = await fetch('https://api.example.com/products', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Cookie': cookie || ''
    },
    body: JSON.stringify({
      name: formData.get('name'),
      price: formData.get('price')
    })
  });
  
  if (!response.ok) {
    return { error: 'Failed to create product' };
  }
  
  return redirect('/products');
}
```

### Astro Integration

#### Server-Only Execution

Astro components run only on the server during build or at request time (SSR mode). Fetch calls in Astro component frontmatter execute server-side, with no client-side re-execution.

```astro
---
// This runs on the server only
const response = await fetch('https://api.example.com/data');
const data = await response.json();
---

<div>
  {data.items.map(item => (
    <article>{item.title}</article>
  ))}
</div>
```

For client-side interactivity requiring data fetching, Astro requires explicit client-side scripts or framework components (React, Vue, Svelte) with client directives.

#### API Routes

Astro's API routes provide server endpoints for client-side fetch calls. These routes have access to the incoming request context.

```javascript
// src/pages/api/data.js
export async function GET({ request, cookies }) {
  const token = cookies.get('auth-token');
  
  const response = await fetch('https://api.example.com/data', {
    headers: {
      'Authorization': `Bearer ${token?.value}`
    }
  });
  
  return new Response(JSON.stringify(await response.json()), {
    headers: {
      'Content-Type': 'application/json'
    }
  });
}
```

### Nuxt Integration

#### useAsyncData and useFetch

Nuxt provides composables that wrap fetch with SSR-aware caching and hydration. These composables execute on the server during initial render and handle client-side hydration automatically.

```javascript
// Automatic key generation and caching
const { data, pending, error, refresh } = await useFetch('/api/products');

// Manual key for better control
const { data } = await useAsyncData('products', () => 
  fetch('https://api.example.com/products').then(r => r.json())
);

// With options
const { data } = await useFetch('/api/products', {
  key: 'products-list',
  method: 'POST',
  body: { category: 'electronics' },
  transform: (data) => data.items,
  pick: ['id', 'name', 'price']
});
```

The `useFetch` composable automatically handles cookie forwarding for same-origin requests during SSR. The data fetched on the server gets serialized and sent to the client for hydration, avoiding duplicate requests.

#### Server Routes

Nuxt server routes (in the `server/` directory) handle API requests and have access to event context for cookie and header management.

```javascript
// server/api/products.js
export default defineEventHandler(async (event) => {
  const cookies = parseCookies(event);
  
  const response = await fetch('https://api.example.com/products', {
    headers: {
      'Authorization': `Bearer ${cookies.token}`
    }
  });
  
  return response.json();
});
```

### Authentication and Authorization

#### Token Management

Server-side rendering requires careful handling of authentication tokens. Tokens stored in cookies should be forwarded with fetch requests, while tokens in localStorage (client-only) require alternative strategies.

```javascript
// Next.js App Router
async function ServerComponent() {
  const { cookies } = await import('next/headers');
  const token = cookies().get('auth-token');
  
  const response = await fetch('https://api.example.com/protected', {
    headers: {
      'Authorization': `Bearer ${token?.value}`
    }
  });
  
  return response.json();
}

// SvelteKit
export async function load({ fetch, cookies }) {
  const token = cookies.get('auth-token');
  
  const response = await fetch('https://api.example.com/protected', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return { data: await response.json() };
}
```

#### Session Handling

Framework-specific session management libraries often provide helpers for authenticated fetch requests. These libraries handle token refresh, session validation, and credential forwarding.

```javascript
// Next.js with next-auth
import { getServerSession } from 'next-auth';

export async function GET(request) {
  const session = await getServerSession();
  
  if (!session) {
    return new Response('Unauthorized', { status: 401 });
  }
  
  const response = await fetch('https://api.example.com/data', {
    headers: {
      'Authorization': `Bearer ${session.accessToken}`
    }
  });
  
  return response;
}
```

### Error Handling Patterns

#### Framework-Specific Error Boundaries

Different frameworks provide different mechanisms for handling fetch errors during SSR. Understanding these patterns prevents hydration mismatches and improves error reporting.

```javascript
// Next.js App Router - Error boundaries
// error.jsx
export default function Error({ error, reset }) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}

// Remix - Error boundaries with caught responses
export function ErrorBoundary({ error }) {
  return (
    <div>
      <h1>Error</h1>
      <p>{error.message}</p>
    </div>
  );
}

// SvelteKit - Error page
// +error.svelte
<script>
  import { page } from '$app/stores';
</script>

<h1>{$page.status}: {$page.error.message}</h1>
```

#### Retry and Fallback Strategies

Server-side fetch failures require different handling than client-side failures. Network timeouts, DNS failures, and connection errors should trigger appropriate fallbacks or cached responses.

```javascript
async function fetchWithRetry(url, options = {}, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, {
        ...options,
        signal: AbortSignal.timeout(5000)
      });
      
      if (!response.ok && i < retries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
        continue;
      }
      
      return response;
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
}
```

### Performance Optimization

#### Request Parallelization

Server-side rendering allows parallelizing independent data fetches to reduce total rendering time. Use `Promise.all()` or `Promise.allSettled()` to fetch data concurrently.

```javascript
// Next.js
async function Page() {
  const [user, products, categories] = await Promise.all([
    fetch('https://api.example.com/user').then(r => r.json()),
    fetch('https://api.example.com/products').then(r => r.json()),
    fetch('https://api.example.com/categories').then(r => r.json())
  ]);
  
  return <Layout user={user} products={products} categories={categories} />;
}

// SvelteKit
export async function load({ fetch }) {
  const [userRes, productsRes, categoriesRes] = await Promise.all([
    fetch('/api/user'),
    fetch('/api/products'),
    fetch('/api/categories')
  ]);
  
  return {
    user: await userRes.json(),
    products: await productsRes.json(),
    categories: await categoriesRes.json()
  };
}
```

#### Streaming and Suspense

Modern frameworks support streaming responses, allowing partial page rendering while data loads. This reduces time-to-first-byte and improves perceived performance.

```javascript
// Next.js with Suspense
import { Suspense } from 'react';

async function UserProfile() {
  const user = await fetch('https://api.example.com/user').then(r => r.json());
  return <div>{user.name}</div>;
}

export default function Page() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<div>Loading user...</div>}>
        <UserProfile />
      </Suspense>
    </div>
  );
}
```

Remix and SvelteKit support similar patterns through deferred data loading and streaming responses, allowing progressive enhancement of server-rendered pages.

### Cache Strategies

#### Framework Cache Integration

Frameworks provide different approaches to caching fetch responses during SSR. Understanding these mechanisms prevents stale data issues and optimizes build times.

```javascript
// Next.js - Segment-level caching
export const revalidate = 3600; // Revalidate every hour

export default async function Page() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 60 } // Override segment-level cache
  });
  
  return <div>{/* render data */}</div>;
}

// Nuxt - Cache control
const { data } = await useFetch('/api/data', {
  key: 'my-data',
  getCachedData(key) {
    return useNuxtApp().payload.data[key] || useNuxtApp().static.data[key];
  }
});
```

#### Build-Time vs Runtime Caching

Static site generation frameworks cache fetch results at build time, while SSR frameworks cache at runtime. Choose the appropriate strategy based on data freshness requirements.

```javascript
// Astro - Build-time fetch (SSG)
---
const response = await fetch('https://api.example.com/data');
const data = await response.json();
---

// Next.js - Runtime fetch with ISR
export default async function Page() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 60 }
  }).then(r => r.json());
  
  return <div>{/* render data */}</div>;
}
```

### Hydration Considerations

#### Data Serialization

Data fetched on the server must serialize to the client for hydration. Avoid non-serializable values like functions, dates (without conversion), and circular references.

```javascript
// Next.js - Serialization handling
export default async function Page() {
  const data = await fetch('https://api.example.com/data').then(r => r.json());
  
  // Convert dates to strings for serialization
  const serializedData = {
    ...data,
    createdAt: new Date(data.createdAt).toISOString()
  };
  
  return <Component data={serializedData} />;
}

// Nuxt - Automatic serialization
const { data } = await useAsyncData('products', async () => {
  const response = await fetch('https://api.example.com/products');
  const products = await response.json();
  
  // Transform dates for serialization
  return products.map(p => ({
    ...p,
    createdAt: p.createdAt.toISOString()
  }));
});
```

#### Avoiding Double Fetching

Frameworks must prevent duplicate fetches during hydration. Server-fetched data should populate the client-side state without triggering additional requests.

```javascript
// SvelteKit - Automatic hydration
export async function load({ fetch }) {
  // Fetched on server, hydrated on client
  const response = await fetch('/api/data');
  return {
    data: await response.json()
  };
}

// Remix - Automatic data hydration
export function loader() {
  // Runs on server, result hydrates to client
  return fetch('https://api.example.com/data').then(r => r.json());
}

export default function Route() {
  const data = useLoaderData(); // No additional fetch
  return <div>{/* render data */}</div>;
}
```

### Edge Runtime Considerations

#### Cloudflare Workers and Vercel Edge

Edge runtimes provide a global fetch API but with limitations compared to Node.js. These environments restrict certain Node.js APIs and impose stricter execution time limits.

```javascript
// Vercel Edge Runtime
export const config = {
  runtime: 'edge'
};

export default async function handler(request) {
  const response = await fetch('https://api.example.com/data', {
    headers: {
      'User-Agent': 'Edge Function'
    }
  });
  
  return new Response(response.body, {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 's-maxage=60'
    }
  });
}
```

Edge runtimes optimize for low-latency responses but may have limited support for large request/response bodies and long-running operations.

#### Request/Response Streaming

Edge environments support streaming responses, enabling progressive data delivery for large datasets or real-time updates.

```javascript
export default async function handler() {
  const encoder = new TextEncoder();
  
  const stream = new ReadableStream({
    async start(controller) {
      const response = await fetch('https://api.example.com/stream');
      const reader = response.body.getReader();
      
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        controller.enqueue(value);
      }
      
      controller.close();
    }
  });
  
  return new Response(stream, {
    headers: { 'Content-Type': 'application/json' }
  });
}
```

### Testing SSR Fetch Behavior

#### Mocking Server Environment

Testing server-side fetch requires mocking the server environment and simulating framework-specific contexts. Libraries like MSW (Mock Service Worker) work in both Node.js and browser environments.

```javascript
// Vitest with MSW
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.get('https://api.example.com/data', () => {
    return HttpResponse.json({ items: [] });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('fetches data during SSR', async () => {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();
  expect(data.items).toEqual([]);
});
```

#### Framework Test Utilities

Frameworks provide testing utilities that simulate their SSR environment, including request context and data loading mechanisms.

```javascript
// Next.js testing
import { render } from '@testing-library/react';

test('renders with SSR data', async () => {
  // Mock fetch for component
  global.fetch = vi.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ name: 'Test' })
    })
  );
  
  const { findByText } = render(<ServerComponent />);
  expect(await findByText('Test')).toBeInTheDocument();
});

// SvelteKit testing
import { load } from './+page.server.js';

test('load function fetches data', async () => {
  const mockFetch = vi.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({ items: [] })
    })
  );
  
  const result = await load({ fetch: mockFetch });
  expect(result.data.items).toEqual([]);
});
```

---

