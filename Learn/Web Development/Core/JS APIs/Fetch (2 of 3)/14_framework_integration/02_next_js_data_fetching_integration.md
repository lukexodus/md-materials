## Next.js Data Fetching Integration


### App Router Architecture

#### Server Components as Default

Server Components fetch data directly without client-side JavaScript overhead. Use async/await syntax at the component level:

```tsx
async function ProductPage({ params }: { params: { id: string } }) {
  const product = await fetch(`https://api.example.com/products/${params.id}`)
    .then(res => res.json());
  
  return <ProductDetails data={product} />;
}
```

#### Request Memoization

Next.js automatically deduplicates identical fetch requests within a single render pass. Multiple components requesting the same URL receive cached results:

```tsx
// Both calls use the same data - only one network request
async function Header() {
  const user = await fetch('https://api.example.com/user').then(r => r.json());
  return <UserMenu user={user} />;
}

async function Sidebar() {
  const user = await fetch('https://api.example.com/user').then(r => r.json());
  return <UserProfile user={user} />;
}
```

### Caching Strategies

#### Force-Cache (Default)

Aggressive caching stores responses indefinitely until revalidated:

```tsx
fetch('https://api.example.com/data', {
  cache: 'force-cache' // Default behavior
});
```

#### No-Store

Bypass all caching for dynamic, real-time data:

```tsx
async function LiveDashboard() {
  const metrics = await fetch('https://api.example.com/metrics', {
    cache: 'no-store'
  }).then(r => r.json());
  
  return <MetricsDisplay data={metrics} />;
}
```

This marks the entire route as dynamic.

#### Time-Based Revalidation

Set stale-while-revalidate behavior with `next.revalidate`:

```tsx
fetch('https://api.example.com/posts', {
  next: { revalidate: 3600 } // Revalidate after 1 hour
});
```

#### On-Demand Revalidation

Programmatically purge cache using tags:

```tsx
// Tagging requests
fetch('https://api.example.com/posts', {
  next: { tags: ['posts'] }
});

// Revalidation in API route or Server Action
import { revalidateTag } from 'next/cache';

revalidateTag('posts');
```

Path-based revalidation:

```tsx
import { revalidatePath } from 'next/cache';

revalidatePath('/blog');
revalidatePath('/blog/[slug]', 'page'); // Specific dynamic route
revalidatePath('/blog', 'layout'); // All routes under layout
```

### Route Segment Configuration

#### Dynamic Rendering Control

Configure entire route segments via exported constants:

```tsx
// app/dashboard/page.tsx
export const dynamic = 'force-dynamic'; // Always dynamic
export const revalidate = 3600; // ISR with 1-hour revalidation
export const fetchCache = 'force-no-store'; // Override default caching

async function Dashboard() {
  const data = await fetch('https://api.example.com/dashboard');
  return <DashboardView data={data} />;
}
```

Options for `dynamic`:
- `'auto'` - Default, cache when possible
- `'force-dynamic'` - Always dynamic rendering
- `'error'` - Force static, error if dynamic needed
- `'force-static'` - Force static, empty dynamic functions

#### Runtime Selection

Choose execution environment per route:

```tsx
export const runtime = 'edge'; // or 'nodejs' (default)
```

Edge runtime provides lower latency with limitations (no Node.js APIs, smaller bundle size).

### Parallel and Sequential Patterns

#### Parallel Data Fetching

Use `Promise.all()` for independent requests:

```tsx
async function DashboardPage() {
  const [users, posts, analytics] = await Promise.all([
    fetch('https://api.example.com/users').then(r => r.json()),
    fetch('https://api.example.com/posts').then(r => r.json()),
    fetch('https://api.example.com/analytics').then(r => r.json())
  ]);
  
  return <Dashboard users={users} posts={posts} analytics={analytics} />;
}
```

#### Sequential with Dependency

Fetch serially when one request depends on another:

```tsx
async function UserPostsPage({ params }: { params: { id: string } }) {
  const user = await fetch(`https://api.example.com/users/${params.id}`)
    .then(r => r.json());
  
  // Depends on user.organizationId
  const orgData = await fetch(`https://api.example.com/orgs/${user.organizationId}`)
    .then(r => r.json());
  
  return <UserProfile user={user} organization={orgData} />;
}
```

#### Preloading Pattern

Start fetches early, await later:

```tsx
async function BlogPost({ params }: { params: { slug: string } }) {
  // Start both fetches immediately
  const postPromise = fetch(`https://api.example.com/posts/${params.slug}`);
  const commentsPromise = fetch(`https://api.example.com/posts/${params.slug}/comments`);
  
  // Await when needed
  const post = await postPromise.then(r => r.json());
  
  return (
    <article>
      <PostContent data={post} />
      <Comments commentsPromise={commentsPromise} />
    </article>
  );
}
```

### Streaming and Suspense Integration

#### Boundary-Based Loading

Wrap slow-fetching components in Suspense:

```tsx
import { Suspense } from 'react';

function ProductPage() {
  return (
    <div>
      <ProductHeader />
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews /> {/* Slow fetch */}
      </Suspense>
      <Suspense fallback={<RecommendationsSkeleton />}>
        <Recommendations /> {/* Slow fetch */}
      </Suspense>
    </div>
  );
}

async function Reviews() {
  const reviews = await fetch('https://api.example.com/reviews?slow=true', {
    cache: 'no-store'
  }).then(r => r.json());
  
  return <ReviewsList data={reviews} />;
}
```

#### Loading.tsx Convention

Create automatic Suspense boundaries:

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return <DashboardSkeleton />;
}

// app/dashboard/page.tsx - automatically wrapped in Suspense
async function Dashboard() {
  const data = await fetch('https://api.example.com/dashboard');
  return <DashboardView data={data} />;
}
```

### Client-Side Fetching

#### Client Component Fetching

Use `'use client'` directive for interactive data needs:

```tsx
'use client';

import { useState, useEffect } from 'react';

export function SearchResults({ query }: { query: string }) {
  const [results, setResults] = useState([]);
  
  useEffect(() => {
    fetch(`https://api.example.com/search?q=${query}`)
      .then(r => r.json())
      .then(setResults);
  }, [query]);
  
  return <ResultsList items={results} />;
}
```

#### SWR Integration

Specialized React hook library for client-side fetching:

```tsx
'use client';

import useSWR from 'swr';

const fetcher = (url: string) => fetch(url).then(r => r.json());

export function Profile() {
  const { data, error, isLoading, mutate } = useSWR(
    'https://api.example.com/user',
    fetcher,
    {
      revalidateOnFocus: true,
      dedupingInterval: 2000
    }
  );
  
  if (error) return <Error />;
  if (isLoading) return <Skeleton />;
  
  return <ProfileView data={data} onUpdate={mutate} />;
}
```

#### React Query Integration

More comprehensive caching and state management:

```tsx
'use client';

import { useQuery, QueryClient, QueryClientProvider } from '@tanstack/react-query';

export function Providers({ children }: { children: React.ReactNode }) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,
      },
    },
  });
  
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}

function Posts() {
  const { data, error, isLoading } = useQuery({
    queryKey: ['posts'],
    queryFn: () => fetch('https://api.example.com/posts').then(r => r.json()),
  });
  
  if (isLoading) return <Skeleton />;
  if (error) return <Error error={error} />;
  
  return <PostsList posts={data} />;
}
```

### Server Actions for Mutations

#### Form Submissions

Server Actions handle mutations with automatic revalidation:

```tsx
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function createPost(formData: FormData) {
  const title = formData.get('title');
  const content = formData.get('content');
  
  const response = await fetch('https://api.example.com/posts', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title, content })
  });
  
  if (!response.ok) {
    throw new Error('Failed to create post');
  }
  
  revalidatePath('/blog');
  return response.json();
}
```

```tsx
// app/blog/new/page.tsx
import { createPost } from '@/app/actions';

export default function NewPost() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  );
}
```

#### Programmatic Invocation

Call Server Actions from Client Components:

```tsx
'use client';

import { createPost } from '@/app/actions';
import { useTransition } from 'react';

export function CreatePostButton() {
  const [isPending, startTransition] = useTransition();
  
  const handleClick = () => {
    startTransition(async () => {
      const formData = new FormData();
      formData.append('title', 'New Post');
      formData.append('content', 'Content here');
      
      await createPost(formData);
    });
  };
  
  return (
    <button onClick={handleClick} disabled={isPending}>
      {isPending ? 'Creating...' : 'Create Post'}
    </button>
  );
}
```

### Route Handlers for Custom APIs

#### GET Handlers

Create API routes that integrate with Next.js caching:

```tsx
// app/api/posts/route.ts
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const category = searchParams.get('category');
  
  const response = await fetch(
    `https://api.example.com/posts?category=${category}`,
    {
      next: { revalidate: 3600, tags: ['posts'] }
    }
  );
  
  const data = await response.json();
  
  return NextResponse.json(data);
}

export const dynamic = 'force-dynamic'; // or revalidate = 3600
```

#### POST/PUT/DELETE Handlers

Mutations with automatic cache invalidation:

```tsx
// app/api/posts/[id]/route.ts
import { NextResponse } from 'next/server';
import { revalidateTag } from 'next/cache';

export async function PUT(
  request: Request,
  { params }: { params: { id: string } }
) {
  const body = await request.json();
  
  const response = await fetch(
    `https://api.example.com/posts/${params.id}`,
    {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    }
  );
  
  if (!response.ok) {
    return NextResponse.json(
      { error: 'Failed to update' },
      { status: response.status }
    );
  }
  
  revalidateTag('posts');
  
  return NextResponse.json(await response.json());
}
```

#### Dynamic Route Handlers

Handle parameterized endpoints:

```tsx
// app/api/users/[userId]/posts/[postId]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { userId: string; postId: string } }
) {
  const post = await fetch(
    `https://api.example.com/users/${params.userId}/posts/${params.postId}`
  ).then(r => r.json());
  
  return NextResponse.json(post);
}
```

### Error Handling Patterns

#### Try-Catch Boundaries

Handle fetch failures gracefully:

```tsx
async function ProductPage({ params }: { params: { id: string } }) {
  try {
    const product = await fetch(`https://api.example.com/products/${params.id}`)
      .then(async (res) => {
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}: ${res.statusText}`);
        }
        return res.json();
      });
    
    return <ProductDetails data={product} />;
  } catch (error) {
    console.error('Failed to fetch product:', error);
    return <ProductError message="Unable to load product" />;
  }
}
```

#### Error.tsx Convention

Automatic error boundaries for route segments:

```tsx
// app/products/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

#### Not-Found Handling

Custom 404 pages for missing resources:

```tsx
// app/products/[id]/page.tsx
import { notFound } from 'next/navigation';

async function ProductPage({ params }: { params: { id: string } }) {
  const response = await fetch(`https://api.example.com/products/${params.id}`);
  
  if (response.status === 404) {
    notFound(); // Renders not-found.tsx
  }
  
  if (!response.ok) {
    throw new Error('Failed to fetch product');
  }
  
  const product = await response.json();
  return <ProductDetails data={product} />;
}
```

```tsx
// app/products/[id]/not-found.tsx
export default function NotFound() {
  return <div>Product not found</div>;
}
```

### Authentication Integration

#### Middleware-Based Auth

Intercept requests before route execution:

```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('auth-token');
  
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
  
  // Add auth header to all API requests
  const requestHeaders = new Headers(request.headers);
  if (token) {
    requestHeaders.set('Authorization', `Bearer ${token.value}`);
  }
  
  return NextResponse.next({
    request: {
      headers: requestHeaders,
    },
  });
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
};
```

#### Server Component Auth

Access headers and cookies directly:

```tsx
import { cookies, headers } from 'next/headers';

async function UserDashboard() {
  const cookieStore = cookies();
  const token = cookieStore.get('auth-token');
  
  const userData = await fetch('https://api.example.com/user', {
    headers: {
      'Authorization': `Bearer ${token?.value}`,
    },
    cache: 'no-store' // User-specific data shouldn't be cached
  }).then(r => r.json());
  
  return <Dashboard user={userData} />;
}
```

#### Session-Based Fetching

Integrate with authentication libraries:

```tsx
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';

async function ProtectedPage() {
  const session = await getServerSession(authOptions);
  
  if (!session) {
    redirect('/login');
  }
  
  const privateData = await fetch('https://api.example.com/private', {
    headers: {
      'Authorization': `Bearer ${session.accessToken}`,
    },
  }).then(r => r.json());
  
  return <PrivateContent data={privateData} />;
}
```

### Incremental Static Regeneration (ISR)

#### Background Revalidation

Serve stale content while regenerating in background:

```tsx
// Revalidate every 10 minutes
export const revalidate = 600;

async function BlogPost({ params }: { params: { slug: string } }) {
  const post = await fetch(`https://api.example.com/posts/${params.slug}`)
    .then(r => r.json());
  
  return <Article data={post} />;
}
```

#### On-Demand ISR

Trigger regeneration via webhook or API:

```tsx
// app/api/revalidate/route.ts
import { revalidatePath } from 'next/cache';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  const body = await request.json();
  const secret = request.headers.get('x-revalidate-secret');
  
  if (secret !== process.env.REVALIDATE_SECRET) {
    return NextResponse.json({ message: 'Invalid secret' }, { status: 401 });
  }
  
  revalidatePath(`/blog/${body.slug}`);
  
  return NextResponse.json({ revalidated: true });
}
```

Webhook from CMS triggers regeneration after content updates.

#### Stale-While-Revalidate Behavior

[Inference] Next.js likely serves cached content immediately while fetching fresh data in background:

```tsx
fetch('https://api.example.com/data', {
  next: { revalidate: 60 }
});
```

First request after 60 seconds receives cached data; subsequent requests get updated content.

### Request Deduplication Patterns

#### Automatic Deduplication Scope

Next.js deduplicates within a single render pass only. Separate page navigations create new requests:

```tsx
// Same render - deduplicated
async function Layout() {
  const config = await fetch('https://api.example.com/config').then(r => r.json());
  return (
    <>
      <Header config={config} />
      <Sidebar config={config} /> {/* Uses memoized result */}
    </>
  );
}
```

#### React Cache for Extended Memoization

Use `cache()` for custom deduplication logic:

```tsx
import { cache } from 'react';

const getUser = cache(async (id: string) => {
  const response = await fetch(`https://api.example.com/users/${id}`);
  return response.json();
});

async function UserProfile({ id }: { id: string }) {
  const user = await getUser(id);
  return <Profile data={user} />;
}

async function UserPosts({ id }: { id: string }) {
  const user = await getUser(id); // Same memoized result
  return <Posts userId={user.id} />;
}
```

`cache()` persists across component boundaries within the same request.

### Data Mutation Strategies

#### Optimistic Updates Pattern

Update UI before server confirmation:

```tsx
'use client';

import { useState, useTransition } from 'react';
import { updatePost } from '@/app/actions';

export function PostEditor({ initialData }: { initialData: Post }) {
  const [post, setPost] = useState(initialData);
  const [isPending, startTransition] = useTransition();
  
  const handleUpdate = (newContent: string) => {
    // Optimistic update
    setPost(prev => ({ ...prev, content: newContent }));
    
    startTransition(async () => {
      try {
        await updatePost(post.id, newContent);
      } catch (error) {
        // Rollback on failure
        setPost(initialData);
      }
    });
  };
  
  return <Editor content={post.content} onUpdate={handleUpdate} />;
}
```

#### Mutation with Revalidation

Server Actions automatically revalidate affected paths:

```tsx
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';

export async function deletePost(postId: string) {
  await fetch(`https://api.example.com/posts/${postId}`, {
    method: 'DELETE',
  });
  
  revalidatePath('/blog');
  revalidateTag('posts');
}
```

### Performance Optimization

#### Partial Prerendering

[Inference] Static and dynamic content rendered separately:

```tsx
export const experimental_ppr = true;

async function ProductPage({ params }: { params: { id: string } }) {
  return (
    <>
      {/* Static shell renders immediately */}
      <ProductLayout>
        {/* Dynamic content streams in */}
        <Suspense fallback={<PriceSkeleton />}>
          <ProductPrice id={params.id} />
        </Suspense>
        
        <Suspense fallback={<StockSkeleton />}>
          <StockStatus id={params.id} />
        </Suspense>
      </ProductLayout>
    </>
  );
}
```

#### Route Prefetching

Next.js automatically prefetches visible links:

```tsx
import Link from 'next/link';

// Prefetched when link enters viewport
<Link href="/products/123" prefetch={true}>
  View Product
</Link>

// Disable prefetching
<Link href="/products/123" prefetch={false}>
  View Product
</Link>
```

#### Selective Hydration

[Inference] Suspense boundaries may enable progressive hydration:

```tsx
function Page() {
  return (
    <>
      <CriticalContent /> {/* Hydrates first */}
      
      <Suspense fallback={<Skeleton />}>
        <HeavyComponent /> {/* Hydrates after */}
      </Suspense>
    </>
  );
}
```

### Headers and Cookies Access

#### Reading Headers

Access request headers in Server Components:

```tsx
import { headers } from 'next/headers';

async function Page() {
  const headersList = headers();
  const userAgent = headersList.get('user-agent');
  const referer = headersList.get('referer');
  
  const data = await fetch('https://api.example.com/data', {
    headers: {
      'User-Agent': userAgent || '',
    },
  }).then(r => r.json());
  
  return <Content data={data} />;
}
```

#### Cookie Management

Read and set cookies:

```tsx
import { cookies } from 'next/headers';

async function Page() {
  const cookieStore = cookies();
  
  // Read cookie
  const theme = cookieStore.get('theme');
  
  // Set cookie
  cookieStore.set('last-visit', new Date().toISOString(), {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    maxAge: 60 * 60 * 24 * 7, // 1 week
  });
  
  const preferences = await fetch('https://api.example.com/preferences', {
    headers: {
      'Cookie': cookieStore.toString(),
    },
  }).then(r => r.json());
  
  return <PreferencesView data={preferences} theme={theme?.value} />;
}
```

### Edge Runtime Considerations

#### Edge-Compatible Fetching

Edge runtime has restrictions:

```tsx
export const runtime = 'edge';

// ✅ Works in edge
async function EdgePage() {
  const data = await fetch('https://api.example.com/data')
    .then(r => r.json());
  
  return <Content data={data} />;
}

// ❌ Node.js APIs unavailable
// - fs, path modules
// - Native crypto
// - Some npm packages
```

#### Edge-Optimized Patterns

Minimize bundle size and latency:

```tsx
export const runtime = 'edge';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get('id');
  
  // Use edge-friendly libraries
  const response = await fetch(`https://api.example.com/data/${id}`, {
    // Leverage edge caching
    cf: {
      cacheTtl: 300,
      cacheEverything: true,
    },
  });
  
  return new Response(response.body, {
    headers: {
      'Cache-Control': 'public, s-maxage=300',
    },
  });
}
```

### Debugging and Monitoring

#### Logging Fetch Requests

Debug fetch behavior in development:

```tsx
async function Page() {
  const startTime = Date.now();
  
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 3600 }
  }).then(async (res) => {
    console.log(`Fetch completed in ${Date.now() - startTime}ms`);
    console.log('Cache status:', res.headers.get('x-vercel-cache'));
    return res.json();
  });
  
  return <Content data={data} />;
}
```

#### Cache Hit Indicators

Check response headers for cache status:

- `x-nextjs-cache: HIT` - Served from Next.js cache
- `x-nextjs-cache: MISS` - Fresh fetch executed
- `x-nextjs-cache: STALE` - Revalidating in background

#### Performance Monitoring

Track fetch performance in production:

```tsx
async function Page() {
  const start = performance.now();
  
  try {
    const data = await fetch('https://api.example.com/data');
    const duration = performance.now() - start;
    
    // Send to analytics
    if (typeof window !== 'undefined') {
      window.gtag?.('event', 'fetch_timing', {
        url: 'https://api.example.com/data',
        duration,
      });
    }
    
    return <Content data={data} />;
  } catch (error) {
    // Log errors to monitoring service
    console.error('Fetch failed:', error);
    throw error;
  }
}
```

---

