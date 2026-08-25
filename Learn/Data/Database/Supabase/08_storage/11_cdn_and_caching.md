## CDN and Caching


Supabase Storage integrates with Content Delivery Networks to distribute files globally and improve access performance through caching.

**CDN distribution:**

Files in public buckets are automatically distributed through Supabase's CDN infrastructure, reducing latency for geographically distributed users.

Setting cache control headers during upload:

```javascript
const { data, error } = await supabase
  .storage
  .from('public-assets')
  .upload('logo.png', file, {
    cacheControl: '3600' // Cache for 1 hour
  });
```

Common cache control values:

```javascript
// No caching
cacheControl: 'no-cache'

// Short-lived cache (5 minutes)
cacheControl: '300'

// Medium cache (1 hour)
cacheControl: '3600'

// Long-lived cache (1 day)
cacheControl: '86400'

// Maximum cache (1 year)
cacheControl: '31536000'

// Cache with must-revalidate
cacheControl: 'max-age=3600, must-revalidate'
```

Setting cache headers for immutable files:

```javascript
const { data, error } = await supabase
  .storage
  .from('public-assets')
  .upload('static-image-v2.png', file, {
    cacheControl: '31536000, immutable' // Cache for 1 year, never revalidate
  });
```

Updating cache control on existing files:

```javascript
const { data, error } = await supabase
  .storage
  .from('public-assets')
  .update('logo.png', file, {
    cacheControl: '7200',
    upsert: true
  });
```

Cache busting through versioned filenames:

```javascript
const timestamp = Date.now();
const filename = `avatar-${timestamp}.png`;

const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload(filename, file, {
    cacheControl: '31536000'
  });
```

Cache busting through query parameters:

```javascript
const { data } = supabase
  .storage
  .from('avatars')
  .getPublicUrl('avatar.png');

const cacheBustedUrl = `${data.publicUrl}?v=${Date.now()}`;
```

**CDN caching behavior:**

- Public buckets: Files cached at CDN edge locations
- Private buckets: Limited caching due to authentication requirements
- Transformed images: Transformations cached after first request
- Signed URLs: Not aggressively cached due to temporary nature

**[Inference]** CDN cache purging or invalidation may not be immediately available through the Supabase client libraries, requiring manual URL versioning strategies for cache busting.

Optimizing for CDN delivery:

```javascript
// Upload with long cache for static assets
await supabase
  .storage
  .from('public-assets')
  .upload('static/logo.png', file, {
    cacheControl: '31536000, immutable'
  });

// Upload with short cache for dynamic content
await supabase
  .storage
  .from('public-assets')
  .upload('feed/latest.jpg', file, {
    cacheControl: '300'
  });
```

**[Unverified]** The specific CDN provider, geographic coverage, and cache hit rates depend on Supabase's infrastructure configuration and may vary across deployment regions.

---

**Related topics for deeper understanding:** S3-compatible storage APIs, PostgreSQL BYTEA and large object handling, image optimization algorithms, content delivery network architecture, OAuth2 token-based file access patterns.

---

