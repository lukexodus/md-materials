## Static Generation Patterns


### Build-Time Data Fetching

#### Next.js Static Generation

##### getStaticProps

```javascript
export async function getStaticProps(context) {
  const res = await fetch('https://api.example.com/data');
  const data = await res.json();
  
  return {
    props: { data },
    revalidate: 3600 // ISR: regenerate every hour
  };
}
```

##### Parallel Data Fetching

```javascript
export async function getStaticProps() {
  const [users, posts, comments] = await Promise.all([
    fetch('https://api.example.com/users').then(r => r.json()),
    fetch('https://api.example.com/posts').then(r => r.json()),
    fetch('https://api.example.com/comments').then(r => r.json())
  ]);
  
  return {
    props: { users, posts, comments }
  };
}
```

##### Dynamic Path Generation

```javascript
export async function getStaticPaths() {
  const res = await fetch('https://api.example.com/posts');
  const posts = await res.json();
  
  const paths = posts.map(post => ({
    params: { id: post.id.toString() }
  }));
  
  return {
    paths,
    fallback: 'blocking' // or false, true
  };
}

export async function getStaticProps({ params }) {
  const res = await fetch(`https://api.example.com/posts/${params.id}`);
  const post = await res.json();
  
  return { props: { post } };
}
```

##### App Router (Next.js 13+)

```javascript
// app/posts/[id]/page.js
async function getPost(id) {
  const res = await fetch(`https://api.example.com/posts/${id}`, {
    next: { revalidate: 3600 }
  });
  return res.json();
}

export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts').then(r => r.json());
  return posts.map(post => ({ id: post.id.toString() }));
}

export default async function Page({ params }) {
  const post = await getPost(params.id);
  return <article>{post.content}</article>;
}
```

#### Incremental Static Regeneration (ISR)

##### Time-Based Revalidation

```javascript
export async function getStaticProps() {
  const res = await fetch('https://api.example.com/products');
  const products = await res.json();
  
  return {
    props: { products },
    revalidate: 60 // Regenerate at most once per minute
  };
}
```

##### On-Demand Revalidation

```javascript
// API route: pages/api/revalidate.js
export default async function handler(req, res) {
  if (req.query.secret !== process.env.REVALIDATE_TOKEN) {
    return res.status(401).json({ message: 'Invalid token' });
  }
  
  try {
    await res.revalidate('/products');
    await res.revalidate(`/products/${req.query.id}`);
    return res.json({ revalidated: true });
  } catch (err) {
    return res.status(500).send('Error revalidating');
  }
}
```

##### Tag-Based Revalidation (App Router)

```javascript
// Fetch with tags
async function getData() {
  const res = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] }
  });
  return res.json();
}

// Revalidate by tag
import { revalidateTag } from 'next/cache';

export async function POST(request) {
  const tag = request.nextUrl.searchParams.get('tag');
  revalidateTag(tag);
  return Response.json({ revalidated: true, now: Date.now() });
}
```

### SvelteKit Static Adapter

#### Load Functions

```javascript
// +page.js
export async function load({ fetch, params }) {
  const res = await fetch('https://api.example.com/data');
  const data = await res.json();
  
  return { data };
}

// svelte.config.js
import adapter from '@sveltejs/adapter-static';

export default {
  kit: {
    adapter: adapter({
      pages: 'build',
      assets: 'build',
      fallback: null,
      precompress: false
    })
  }
};
```

#### Prerendering Specific Routes

```javascript
// +page.js
export const prerender = true;

export async function load({ fetch }) {
  const res = await fetch('https://api.example.com/static-content');
  return { content: await res.json() };
}
```

#### Dynamic Route Prerendering

```javascript
// +page.server.js
export const prerender = true;

export async function entries() {
  const res = await fetch('https://api.example.com/posts');
  const posts = await res.json();
  
  return posts.map(post => ({ id: post.id }));
}

export async function load({ params, fetch }) {
  const res = await fetch(`https://api.example.com/posts/${params.id}`);
  return { post: await res.json() };
}
```

### Astro Static Site Generation

#### Data Fetching in Components

```astro
---
// src/pages/posts/[id].astro
export async function getStaticPaths() {
  const response = await fetch('https://api.example.com/posts');
  const posts = await response.json();
  
  return posts.map(post => ({
    params: { id: post.id },
    props: { post }
  }));
}

const { post } = Astro.props;
---

<article>
  <h1>{post.title}</h1>
  <p>{post.content}</p>
</article>
```

#### Parallel Route Generation

```astro
---
export async function getStaticPaths() {
  const [posts, authors] = await Promise.all([
    fetch('https://api.example.com/posts').then(r => r.json()),
    fetch('https://api.example.com/authors').then(r => r.json())
  ]);
  
  return posts.map(post => {
    const author = authors.find(a => a.id === post.authorId);
    return {
      params: { id: post.id },
      props: { post, author }
    };
  });
}
---
```

#### Content Collections with Remote Data

```javascript
// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const posts = defineCollection({
  loader: async () => {
    const response = await fetch('https://api.example.com/posts');
    const data = await response.json();
    return data.map(post => ({
      id: post.id,
      ...post
    }));
  },
  schema: z.object({
    title: z.string(),
    content: z.string(),
    publishedAt: z.string()
  })
});

export const collections = { posts };
```

### Gatsby Source Plugin Pattern

#### Custom Source Plugin

```javascript
// gatsby-node.js
exports.sourceNodes = async ({
  actions,
  createNodeId,
  createContentDigest
}) => {
  const { createNode } = actions;
  
  const response = await fetch('https://api.example.com/posts');
  const posts = await response.json();
  
  posts.forEach(post => {
    createNode({
      ...post,
      id: createNodeId(`Post-${post.id}`),
      parent: null,
      children: [],
      internal: {
        type: 'Post',
        contentDigest: createContentDigest(post)
      }
    });
  });
};
```

#### GraphQL Query in Pages

```javascript
// src/pages/index.js
import { graphql } from 'gatsby';

export const query = graphql`
  query {
    allPost {
      nodes {
        id
        title
        content
      }
    }
  }
`;

export default function Index({ data }) {
  return (
    <ul>
      {data.allPost.nodes.map(post => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

#### Dynamic Page Creation

```javascript
// gatsby-node.js
exports.createPages = async ({ graphql, actions }) => {
  const { createPage } = actions;
  
  const result = await graphql(`
    query {
      allPost {
        nodes {
          id
          slug
        }
      }
    }
  `);
  
  result.data.allPost.nodes.forEach(post => {
    createPage({
      path: `/posts/${post.slug}`,
      component: require.resolve('./src/templates/post.js'),
      context: { id: post.id }
    });
  });
};
```

### Nuxt Static Generation

#### asyncData Pattern

```javascript
// pages/posts/_id.vue
export default {
  async asyncData({ params, $axios }) {
    const post = await $axios.$get(`https://api.example.com/posts/${params.id}`);
    return { post };
  }
};
```

#### generate Property

```javascript
// nuxt.config.js
export default {
  target: 'static',
  generate: {
    async routes() {
      const { data } = await axios.get('https://api.example.com/posts');
      return data.map(post => ({
        route: `/posts/${post.id}`,
        payload: post
      }));
    }
  }
};
```

#### Nuxt 3 useFetch

```javascript
// pages/posts/[id].vue
<script setup>
const route = useRoute();

const { data: post } = await useFetch(
  `https://api.example.com/posts/${route.params.id}`,
  {
    key: `post-${route.params.id}`
  }
);
</script>
```

#### Nuxt 3 Prerendering

```javascript
// nuxt.config.ts
export default defineNuxtConfig({
  nitro: {
    prerender: {
      crawlLinks: true,
      routes: ['/'],
      ignore: ['/api']
    }
  }
});

// server/routes/sitemap.xml.ts
export default defineEventHandler(async (event) => {
  const posts = await $fetch('https://api.example.com/posts');
  return posts.map(post => `/posts/${post.id}`);
});
```

### Remix Loaders

#### Route Loaders

```javascript
// app/routes/posts.$id.tsx
export async function loader({ params }) {
  const response = await fetch(`https://api.example.com/posts/${params.id}`);
  
  if (!response.ok) {
    throw new Response('Not Found', { status: 404 });
  }
  
  return response.json();
}

export default function Post() {
  const post = useLoaderData();
  return <article>{post.content}</article>;
}
```

#### Parallel Route Loading

```javascript
export async function loader({ params }) {
  const [post, author, comments] = await Promise.all([
    fetch(`https://api.example.com/posts/${params.id}`).then(r => r.json()),
    fetch(`https://api.example.com/authors/${params.authorId}`).then(r => r.json()),
    fetch(`https://api.example.com/posts/${params.id}/comments`).then(r => r.json())
  ]);
  
  return { post, author, comments };
}
```

#### Caching Strategy

```javascript
export async function loader({ request }) {
  const url = new URL(request.url);
  const cacheKey = `post-${url.pathname}`;
  
  // Check cache first
  const cached = await cache.get(cacheKey);
  if (cached) return cached;
  
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();
  
  await cache.set(cacheKey, data, { ttl: 3600 });
  return data;
}
```

### Error Handling Patterns

#### Fallback Content

```javascript
export async function getStaticProps() {
  try {
    const res = await fetch('https://api.example.com/data', {
      signal: AbortSignal.timeout(5000)
    });
    
    if (!res.ok) throw new Error('Fetch failed');
    
    const data = await res.json();
    return { props: { data } };
  } catch (error) {
    console.error('Build-time fetch failed:', error);
    return {
      props: { data: null, error: error.message }
    };
  }
}
```

#### notFound Handling

```javascript
export async function getStaticProps({ params }) {
  const res = await fetch(`https://api.example.com/posts/${params.id}`);
  
  if (res.status === 404) {
    return { notFound: true };
  }
  
  if (!res.ok) {
    throw new Error('Failed to fetch data');
  }
  
  const post = await res.json();
  return { props: { post } };
}
```

#### Retry Logic

```javascript
async function fetchWithRetry(url, options = {}, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const res = await fetch(url, options);
      if (res.ok) return res;
      
      if (res.status >= 500 && i < retries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
        continue;
      }
      
      throw new Error(`HTTP ${res.status}`);
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
}

export async function getStaticProps() {
  const res = await fetchWithRetry('https://api.example.com/data');
  const data = await res.json();
  return { props: { data } };
}
```

### Optimization Patterns

#### Deduplication

```javascript
const fetchCache = new Map();

async function fetchDedupe(url, options) {
  const key = `${url}-${JSON.stringify(options)}`;
  
  if (fetchCache.has(key)) {
    return fetchCache.get(key);
  }
  
  const promise = fetch(url, options).then(r => r.json());
  fetchCache.set(key, promise);
  
  try {
    return await promise;
  } finally {
    // Clear cache after response
    setTimeout(() => fetchCache.delete(key), 0);
  }
}

export async function getStaticProps() {
  // Multiple calls to same endpoint return same promise
  const [data1, data2] = await Promise.all([
    fetchDedupe('https://api.example.com/data'),
    fetchDedupe('https://api.example.com/data')
  ]);
  
  return { props: { data: data1 } };
}
```

#### Request Batching

```javascript
class BatchFetcher {
  constructor(baseUrl, delay = 10) {
    this.baseUrl = baseUrl;
    this.delay = delay;
    this.queue = [];
    this.timer = null;
  }
  
  fetch(endpoint) {
    return new Promise((resolve, reject) => {
      this.queue.push({ endpoint, resolve, reject });
      
      if (!this.timer) {
        this.timer = setTimeout(() => this.flush(), this.delay);
      }
    });
  }
  
  async flush() {
    const batch = this.queue.splice(0);
    this.timer = null;
    
    const ids = batch.map(item => item.endpoint.split('/').pop());
    const response = await fetch(`${this.baseUrl}/batch`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ids })
    });
    
    const results = await response.json();
    
    batch.forEach((item, index) => {
      item.resolve(results[index]);
    });
  }
}

const batcher = new BatchFetcher('https://api.example.com');

export async function getStaticPaths() {
  const ids = Array.from({ length: 100 }, (_, i) => i + 1);
  
  const posts = await Promise.all(
    ids.map(id => batcher.fetch(`/posts/${id}`))
  );
  
  return {
    paths: posts.map(post => ({ params: { id: post.id.toString() } })),
    fallback: false
  };
}
```

#### Streaming Responses

```javascript
// Next.js App Router
export async function generateStaticParams() {
  const response = await fetch('https://api.example.com/posts/stream');
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  const ids = [];
  let buffer = '';
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    buffer += decoder.decode(value, { stream: true });
    const lines = buffer.split('\n');
    buffer = lines.pop();
    
    for (const line of lines) {
      if (line.trim()) {
        const post = JSON.parse(line);
        ids.push({ id: post.id.toString() });
      }
    }
  }
  
  return ids;
}
```

### Data Revalidation Strategies

#### Stale-While-Revalidate

```javascript
export async function getStaticProps() {
  const res = await fetch('https://api.example.com/data');
  const data = await res.json();
  
  return {
    props: { data, generatedAt: Date.now() },
    revalidate: 60 // Background regeneration every 60 seconds
  };
}

// Client-side component
export default function Page({ data, generatedAt }) {
  const [currentData, setCurrentData] = useState(data);
  
  useEffect(() => {
    const age = Date.now() - generatedAt;
    
    if (age > 60000) {
      // Stale data, revalidate in background
      fetch('/api/revalidate?path=' + window.location.pathname)
        .catch(console.error);
    }
  }, [generatedAt]);
  
  return <div>{JSON.stringify(currentData)}</div>;
}
```

#### Conditional Revalidation

```javascript
export async function getStaticProps() {
  const res = await fetch('https://api.example.com/data');
  const data = await res.json();
  const etag = res.headers.get('etag');
  
  // Store etag in props
  return {
    props: { data, etag },
    revalidate: 300
  };
}

// Revalidation API route
export default async function handler(req, res) {
  const { etag, path } = req.query;
  
  const response = await fetch('https://api.example.com/data', {
    headers: { 'If-None-Match': etag }
  });
  
  if (response.status === 304) {
    // Not modified, no revalidation needed
    return res.json({ revalidated: false });
  }
  
  await res.revalidate(path);
  return res.json({ revalidated: true });
}
```

#### Time-Based Segments

```javascript
export async function getStaticProps() {
  const res = await fetch('https://api.example.com/data');
  const data = await res.json();
  
  // Different revalidation for different times of day
  const hour = new Date().getHours();
  let revalidate;
  
  if (hour >= 9 && hour <= 17) {
    revalidate = 60; // 1 minute during business hours
  } else if (hour >= 18 && hour <= 23) {
    revalidate = 300; // 5 minutes during evening
  } else {
    revalidate = 3600; // 1 hour during night
  }
  
  return {
    props: { data },
    revalidate
  };
}
```

### Build-Time Configuration

#### Environment-Based Fetching

```javascript
export async function getStaticProps() {
  const apiUrl = process.env.NODE_ENV === 'production'
    ? 'https://api.example.com'
    : 'http://localhost:3001';
  
  const res = await fetch(`${apiUrl}/data`);
  const data = await res.json();
  
  return { props: { data } };
}
```

#### Build-Time Secrets

```javascript
export async function getStaticProps() {
  const res = await fetch('https://api.example.com/data', {
    headers: {
      'Authorization': `Bearer ${process.env.BUILD_API_KEY}`,
      'X-Build-ID': process.env.BUILD_ID
    }
  });
  
  const data = await res.json();
  
  // Remove sensitive data before sending to client
  const sanitized = {
    ...data,
    apiKey: undefined,
    secret: undefined
  };
  
  return { props: { data: sanitized } };
}
```

#### Conditional Route Generation

```javascript
export async function getStaticPaths() {
  const generateAll = process.env.GENERATE_ALL_PAGES === 'true';
  
  if (!generateAll) {
    // Generate only popular pages during development
    return {
      paths: [
        { params: { id: '1' } },
        { params: { id: '2' } }
      ],
      fallback: 'blocking'
    };
  }
  
  // Full generation for production
  const res = await fetch('https://api.example.com/posts');
  const posts = await res.json();
  
  return {
    paths: posts.map(post => ({ params: { id: post.id.toString() } })),
    fallback: false
  };
}
```

---

