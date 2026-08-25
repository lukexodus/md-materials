## Overview

dependencies:
  supabase_flutter: ^2.0.0
  flutter_secure_storage: ^9.0.0
```

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
```

### Deep Linking Configuration

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <application>
    <activity>
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
          android:scheme="myapp"
          android:host="login-callback" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

### Authentication Service

```dart
// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(
      provider,
      redirectTo: 'myapp://login-callback',
    );
  }
}
```

### State Management with Provider

```dart
// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _user = Supabase.instance.client.auth.currentUser;
    _isLoading = false;
    notifyListeners();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _user = response.user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    _user = null;
    notifyListeners();
  }
}
```

### GoRouter Authentication

```dart
// lib/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final router = GoRouter(
  redirect: (context, state) {
    final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isAuthenticated && !isLoginRoute) {
      return '/login';
    }
    if (isAuthenticated && isLoginRoute) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);
```

### Real-time Data Widget

```dart
// lib/widgets/realtime_messages.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeMessages extends StatefulWidget {
  const RealtimeMessages({Key? key}) : super(key: key);

  @override
  State<RealtimeMessages> createState() => _RealtimeMessagesState();
}

class _RealtimeMessagesState extends State<RealtimeMessages> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupRealtimeSubscription();
  }

  Future<void> _loadMessages() async {
    final response = await _supabase
        .from('messages')
        .select()
        .order('created_at', ascending: false);
    
    setState(() {
      _messages = List<Map<String, dynamic>>.from(response);
    });
  }

  void _setupRealtimeSubscription() {
    _channel = _supabase
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            setState(() {
              _messages.insert(0, payload.newRecord);
            });
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _supabase.removeChannel(_channel!);
    super.dispose();
}

@override 
Widget build(BuildContext context) {
  return ListView.builder(
    itemCount: _messages.length,
    itemBuilder: (context, index) {
      final message = _messages[index];
      return ListTile(
        title: Text(message['content'] ?? ''),
        subtitle: Text(message['created_at'] ?? ''),
      );
    },
  );
}
````

### File Upload with Progress

```dart
// lib/services/storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
    Function(double)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    
    await _supabase.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: _getContentType(file.path),
      ),
    );

    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  String _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  Future<List<FileObject>> listFiles(String bucket, String path) async {
    return await _supabase.storage.from(bucket).list(path: path);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await _supabase.storage.from(bucket).remove([path]);
  }
}
````

## Server-Side Rendering Considerations

**Key Points:**

- Cookie-based session management for SSR frameworks
- Request/response context handling for authentication
- Hydration mismatches between server and client
- Edge runtime compatibility considerations

### Session Management Pattern

Server-side rendering requires passing cookies between server and client contexts to maintain authentication state. The session token must be accessible on both the server during initial render and the client during hydration.

```typescript
// Pattern for Next.js App Router
// Server Component
const supabase = createClient() // Uses cookies() from next/headers
const { data } = await supabase.from('posts').select()

// Client Component
'use client'
const supabase = createClient() // Uses browser's cookie storage
```

### Avoiding Hydration Mismatches

When authentication state differs between server render and client hydration, React will throw hydration errors. [Inference: This occurs because the server renders with one user state while the client initializes with a different state]:

```typescript
// Problematic pattern
export default function Page() {
  const { user } = useAuth() // May differ between server/client
  
  return <div>{user ? 'Logged in' : 'Logged out'}</div>
}

// Better pattern
export default function Page() {
  const [mounted, setMounted] = useState(false)
  const { user } = useAuth()
  
  useEffect(() => setMounted(true), [])
  
  if (!mounted) return null // Skip server render
  
  return <div>{user ? 'Logged in' : 'Logged out'}</div>
}
```

### Edge Runtime Compatibility

[Inference: Edge runtimes have limitations compared to Node.js environments]:

```typescript
// edge-compatible configuration
export const runtime = 'edge'

// Avoid Node.js-specific APIs
// ❌ import fs from 'fs'
// ❌ import crypto from 'crypto'

// Use Web APIs instead
// ✅ fetch API
// ✅ Web Crypto API
```

### Data Fetching Strategies

**Server-Side Data Fetching:**

```typescript
// Next.js - Server Component
export default async function PostsPage() {
  const supabase = createClient()
  const { data: posts } = await supabase.from('posts').select()
  
  return <PostsList posts={posts} />
}
```

**Client-Side Data Fetching:**

```typescript
// Client Component with SWR
'use client'
import useSWR from 'swr'

export function PostsList() {
  const { data: posts } = useSWR('posts', async () => {
    const supabase = createClient()
    const { data } = await supabase.from('posts').select()
    return data
  })
  
  return <div>{/* Render posts */}</div>
}
```

### Caching Strategies

[Inference: SSR frameworks typically cache server-rendered pages for performance]:

```typescript
// Next.js 15 - Force dynamic rendering
export const dynamic = 'force-dynamic'

// Or use revalidation
export const revalidate = 60 // Revalidate every 60 seconds

export default async function Page() {
  const supabase = createClient()
  const { data } = await supabase.from('posts').select()
  
  return <PostsList posts={data} />
}
```

### Authentication Flow in SSR

```typescript
// middleware.ts - Next.js
export async function middleware(request: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req: request, res })
  
  // Refresh session if expired
  const { data: { session } } = await supabase.auth.getSession()
  
  // Protect routes
  if (!session && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  
  return res
}
```

### Server Actions Integration

```typescript
// app/actions/posts.ts - Next.js Server Actions
'use server'

import { createClient } from '@/utils/supabase/server'
import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  const supabase = createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('Not authenticated')
  
  const title = formData.get('title') as string
  const content = formData.get('content') as string
  
  const { error } = await supabase
    .from('posts')
    .insert({ title, content, user_id: user.id })
  
  if (error) throw error
  
  revalidatePath('/posts')
}
```

## Static Site Generation

**Key Points:**

- Authentication requires client-side hydration
- Public data can be fetched at build time
- Incremental Static Regeneration for dynamic content
- Edge functions for authentication-dependent pages

### Build-Time Data Fetching

```typescript
// Next.js - Static Generation
export async function generateStaticParams() {
  const supabase = createClient()
  const { data: posts } = await supabase.from('posts').select('slug')
  
  return posts?.map((post) => ({
    slug: post.slug,
  })) ?? []
}

export default async function Post({ params }: { params: { slug: string } }) {
  const supabase = createClient()
  const { data: post } = await supabase
    .from('posts')
    .select()
    .eq('slug', params.slug)
    .single()
  
  return <article>{/* Render post */}</article>
}
```

### Incremental Static Regeneration

```typescript
// Revalidate every 3600 seconds (1 hour)
export const revalidate = 3600

export default async function BlogPage() {
  const supabase = createClient()
  const { data: posts } = await supabase
    .from('posts')
    .select()
    .order('created_at', { ascending: false })
    .limit(10)
  
  return <PostsList posts={posts} />
}
```

### Client-Side Authentication

```typescript
// Static page with client-side auth
export default function DashboardPage() {
  return (
    <Suspense fallback={<Loading />}>
      <ClientDashboard />
    </Suspense>
  )
}

function ClientDashboard() {
  'use client'
  const supabase = createClient()
  const [user, setUser] = useState(null)
  const [data, setData] = useState(null)
  
  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user)
      if (user) {
        supabase.from('user_data').select().then(({ data }) => {
          setData(data)
        })
      }
    })
  }, [])
  
  if (!user) return <Navigate to="/login" />
  
  return <div>{/* Render dashboard */}</div>
}
```

### Gatsby Integration

```javascript
// gatsby-config.js
require('dotenv').config()

module.exports = {
  plugins: [
    {
      resolve: 'gatsby-source-custom-api',
      options: {
        url: process.env.GATSBY_SUPABASE_URL,
        rootKey: 'data',
        schemas: {
          posts: `
            query {
              posts {
                id
                title
                content
                created_at
              }
            }
          `,
        },
      },
    },
  ],
}
```

```javascript
// src/pages/index.js
import React from 'react'
import { graphql } from 'gatsby'

export default function IndexPage({ data }) {
  return (
    <div>
      {data.allPosts.nodes.map(post => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.content}</p>
        </article>
      ))}
    </div>
  )
}

export const query = graphql`
  query {
    allPosts {
      nodes {
        id
        title
        content
        created_at
      }
    }
  }
`
```

### Astro Integration

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  import.meta.env.PUBLIC_SUPABASE_URL,
  import.meta.env.PUBLIC_SUPABASE_ANON_KEY
)
```

```astro
---
// src/pages/posts/[slug].astro
import { supabase } from '../../lib/supabase'

export async function getStaticPaths() {
  const { data: posts } = await supabase.from('posts').select('slug')
  
  return posts.map(post => ({
    params: { slug: post.slug },
  }))
}

const { slug } = Astro.params
const { data: post } = await supabase
  .from('posts')
  .select()
  .eq('slug', slug)
  .single()
---

<article>
  <h1>{post.title}</h1>
  <div>{post.content}</div>
</article>
```

### Hybrid Rendering Approach

[Inference: Combining static generation with dynamic client-side features provides optimal performance while maintaining interactivity]:

```typescript
// Static shell with dynamic content
export default async function Page() {
  // Static layout and navigation
  return (
    <Layout>
      <StaticHeader />
      <Suspense fallback={<Skeleton />}>
        <DynamicContent />
      </Suspense>
      <StaticFooter />
    </Layout>
  )
}

function DynamicContent() {
  'use client'
  // Client-side data fetching for personalized content
  const { data } = useSupabaseQuery()
  return <div>{/* Render dynamic data */}</div>
}
```

**Example: E-commerce Site**

- Product catalog: Static generation at build time
- User cart: Client-side state with Supabase real-time
- Inventory counts: Incremental Static Regeneration
- User authentication: Client-side only

**Example: Blog Platform**

- Published posts: Static generation
- Draft previews: Server-side rendering
- Comments: Client-side real-time subscriptions
- Author dashboard: Client-side with authentication

**Conclusion:**

Framework integration with Supabase requires understanding each framework's rendering model, authentication flow, and state management patterns. Server-side rendering frameworks need careful cookie handling, while static site generation requires hybrid approaches combining build-time data fetching with client-side authentication. Mobile frameworks prioritize offline capabilities and platform-specific features like biometric authentication and deep linking. Selecting the appropriate integration pattern depends on application requirements for real-time features, authentication complexity, and performance characteristics.

**Related topics:** OAuth provider configuration, database type generation for TypeScript, real-time presence features, file upload optimization, offline-first architecture patterns, cross-platform state synchronization, server components vs client components trade-offs, edge function integration with frameworks.

---

# Monitoring & Debugging in Supabase

Supabase provides comprehensive monitoring and debugging capabilities to help you maintain application health, identify performance bottlenecks, and troubleshoot issues effectively. These tools span database operations, API usage, authentication events, storage metrics, and serverless function execution.

## Dashboard Metrics and Analytics

The Supabase dashboard provides a centralized view of your project's operational metrics across multiple dimensions.

**Key Points:**

- **API Usage Metrics**: Track total requests, requests per second, response times, and error rates for your API endpoints
- **Database Activity**: Monitor active connections, query execution counts, and database size growth over time
- **Authentication Metrics**: View sign-ups, sign-ins, failed authentication attempts, and active user sessions
- **Storage Metrics**: Track uploaded files, total storage consumed, and bandwidth usage
- **Real-time Metrics**: Monitor active WebSocket connections and message throughput for real-time subscriptions
- **Time Range Selection**: Analyze metrics across different time periods (hourly, daily, weekly, monthly)
- **Visual Representations**: Graphs and charts provide quick insights into trends and anomalies

The dashboard automatically aggregates data and presents it in an accessible format without requiring additional configuration.

## Query Performance Monitoring

Understanding how your database queries perform is critical for maintaining responsive applications.

**Key Points:**

- **Query Statistics**: Access detailed information about query execution through `pg_stat_statements` extension
- **Execution Time Tracking**: Identify slow queries by examining average, minimum, and maximum execution times
- **Query Frequency**: See how often specific queries run to identify optimization opportunities
- **Explain Plans**: Use PostgreSQL's `EXPLAIN` and `EXPLAIN ANALYZE` to understand query execution plans
- **Index Usage**: Monitor index hit ratios and identify missing indexes that could improve performance
- **Cache Hit Ratio**: Track how often data is served from memory versus disk
- **Long-Running Queries**: Identify queries that exceed acceptable execution thresholds

**Example:**

```sql
-- Enable pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- View slowest queries
SELECT 
  query,
  calls,
  mean_exec_time,
  total_exec_time,
  rows
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check current running queries
SELECT 
  pid,
  now() - query_start AS duration,
  state,
  query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;
```

## Log Inspection

Supabase provides access to various log types for comprehensive debugging.

**Key Points:**

- **API Logs**: Track HTTP requests to your Supabase API including method, path, status code, and response time
- **Database Logs**: Access PostgreSQL logs for connection events, query errors, and performance warnings
- **Authentication Logs**: Monitor login attempts, password resets, and token operations
- **Real-time Logs**: Debug WebSocket connections and subscription events
- **Function Logs**: View console output and errors from Edge Functions
- **Storage Logs**: Track file upload/download operations and access patterns
- **Filtering Capabilities**: Search logs by timestamp, log level (info, warning, error), or specific keywords
- **Log Retention**: [Inference] Log retention periods vary by plan tier

**Example:**

```javascript
// Function logs can be viewed in dashboard
// Add structured logging in your Edge Functions
console.log(JSON.stringify({
  level: 'info',
  message: 'User action completed',
  userId: user.id,
  timestamp: new Date().toISOString()
}));
```

## Error Tracking

Proactive error monitoring helps you identify and resolve issues before they impact users significantly.

**Key Points:**

- **Database Errors**: Track constraint violations, type mismatches, and query syntax errors
- **API Errors**: Monitor 4xx and 5xx response codes from your API endpoints
- **Authentication Errors**: Identify failed login attempts, expired tokens, and permission denials
- **Rate Limit Violations**: Track instances where rate limits are exceeded
- **Function Errors**: Capture runtime errors, timeouts, and memory issues in Edge Functions
- **Error Grouping**: Similar errors are grouped together for easier analysis
- **Error Context**: View request parameters, user context, and stack traces when available

## Database Health Monitoring

Maintaining database health ensures consistent application performance and reliability.

**Key Points:**

- **CPU Utilization**: Monitor database CPU usage to identify compute bottlenecks
- **Memory Usage**: Track RAM consumption and identify memory-intensive operations
- **Disk I/O**: Monitor read/write operations and identify I/O bottlenecks
- **Replication Lag**: [Inference] For projects with read replicas, monitor replication delay
- **Vacuum Operations**: Track autovacuum activity to ensure table bloat is controlled
- **Table Sizes**: Monitor individual table growth and identify unexpectedly large tables
- **Index Bloat**: Identify indexes that may need rebuilding due to excessive size

**Example:**

```sql
-- Check table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 20;

-- Check database cache hit ratio (should be > 99%)
SELECT 
  sum(heap_blks_read) AS heap_read,
  sum(heap_blks_hit) AS heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) AS cache_hit_ratio
FROM pg_stattistic_user_tables;
```

## Connection Monitoring

Database connections are a finite resource that must be carefully managed.

**Key Points:**

- **Active Connections**: View current number of active database connections
- **Connection Limits**: Understand your plan's connection limit and current utilization
- **Connection Sources**: Identify which services or clients are consuming connections
- **Idle Connections**: Detect connections that remain open but inactive
- **Connection Pooling**: Supabase uses PgBouncer for connection pooling in transaction mode
- **Connection Errors**: Track connection failures and timeout issues
- **Pool Saturation**: Monitor when connection pool approaches maximum capacity

**Example:**

```sql
-- View current connections
SELECT 
  datname,
  usename,
  application_name,
  client_addr,
  state,
  query_start
FROM pg_stat_activity
WHERE datname IS NOT NULL;

-- Count connections by state
SELECT 
  state,
  count(*) 
FROM pg_stat_activity 
GROUP BY state;
```

## Storage Usage Tracking

Monitoring storage helps manage costs and prevent capacity issues.

**Key Points:**

- **Total Storage Used**: Track cumulative storage across database and file storage
- **Storage by Bucket**: View storage consumption per bucket in Supabase Storage
- **File Count**: Monitor number of files stored in each bucket
- **Bandwidth Usage**: Track upload and download bandwidth consumption
- **Large Files**: Identify unusually large files that may warrant optimization
- **Growth Trends**: Analyze storage growth over time to forecast capacity needs
- **Storage Limits**: Monitor usage against plan limits

**Example:**

```sql
-- Check database size
SELECT 
  pg_size_pretty(pg_database_size(current_database())) AS database_size;

-- Query storage bucket sizes via Supabase API
// Using JavaScript client
const { data, error } = await supabase
  .storage
  .getBucket('bucket-name');
```

## Function Execution Logs

Edge Functions require specialized monitoring for serverless execution patterns.

**Key Points:**

- **Invocation Count**: Track how frequently each function is called
- **Execution Duration**: Monitor function runtime to identify slow operations
- **Cold Starts**: [Inference] Track initialization time for functions after idle periods
- **Memory Usage**: Monitor memory consumption during function execution
- **Error Rates**: Identify functions with high failure rates
- **Timeout Events**: Detect functions that exceed execution time limits
- **Console Output**: View `console.log()` statements and debugging information
- **Request/Response Payloads**: [Inference] Examine input parameters and output data for debugging

**Example:**

```typescript
// Edge Function with structured logging
Deno.serve(async (req) => {
  const startTime = Date.now();
  
  try {
    console.log('Function invoked', { 
      method: req.method,
      url: req.url 
    });
    
    // Function logic
    const result = await processRequest(req);
    
    console.log('Function completed', { 
      duration: Date.now() - startTime,
      status: 'success'
    });
    
    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    console.error('Function error', { 
      error: error.message,
      stack: error.stack,
      duration: Date.now() - startTime
    });
    
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});
```

## Third-Party Monitoring Tools Integration

Supabase can integrate with external monitoring platforms for advanced observability.

**Key Points:**

- **Prometheus Integration**: [Inference] Export metrics in Prometheus format for custom monitoring
- **Datadog**: Integrate with Datadog for centralized logging and APM
- **Sentry**: Connect Sentry for error tracking and performance monitoring
- **LogDNA/LogTail**: Stream logs to external logging platforms
- **Custom Webhooks**: [Inference] Configure webhooks to send events to external systems
- **API Monitoring**: Use tools like Pingdom or UptimeRobot to monitor API availability
- **Database Monitoring**: Connect tools like pganalyze or Metis for deep PostgreSQL insights

**Example:**

```javascript
// Sentry integration in Edge Function
import * as Sentry from 'https://deno.land/x/sentry/index.mjs';

Sentry.init({
  dsn: 'your-sentry-dsn',
  tracesSampleRate: 1.0,
});

Deno.serve(async (req) => {
  try {
    // Your function logic
  } catch (error) {
    Sentry.captureException(error);
    throw error;
  }
});
```

---

**Related topics you may want to explore:**

- Performance optimization strategies for PostgreSQL in Supabase
- Setting up alerts and notifications for critical metrics
- Database backup and point-in-time recovery
- Implementing observability best practices in production environments
- Rate limiting and quota management

---


# Production Deployment

Production deployment in Supabase involves configuring your project for reliability, security, and performance in a live environment. This requires careful planning across environment management, infrastructure configuration, data protection, and operational monitoring.

## Environment Management

Supabase projects can be organized into separate environments to isolate development work from production data and traffic. The typical structure includes development, staging, and production environments.

**Development environments** serve as sandboxes where developers can test features, experiment with schema changes, and debug issues without affecting real users. These environments typically use separate Supabase projects with their own databases and API endpoints.

**Staging environments** mirror production configurations as closely as possible, serving as final testing grounds before releases. Database schemas, security policies, and infrastructure settings should match production to catch environment-specific issues.

**Production environments** host live user data and handle real traffic. These require the highest standards for security, reliability, and performance monitoring.

Each environment maintains its own API keys, connection strings, and configuration variables. Migration workflows typically involve testing changes in development, validating in staging, then carefully deploying to production with rollback plans ready.

## Custom Domains

Supabase projects initially receive default subdomains for API and database access. Custom domains provide branded URLs and can be configured for both the API endpoint and authentication redirects.

Custom domain setup involves updating DNS records to point to Supabase infrastructure. You configure CNAME records at your DNS provider pointing to your Supabase project's default domain. The API endpoint might use `api.yourdomain.com` while authentication could use `auth.yourdomain.com`.

After DNS propagation, you update your application code to reference the custom domains instead of default Supabase URLs. Environment variables should store these endpoints for easy configuration management across deployments.

## SSL/TLS Configuration

Supabase automatically provisions and manages SSL/TLS certificates for all projects, including custom domains. This encryption secures data in transit between clients and Supabase services.

Default Supabase domains come with SSL certificates pre-configured. When adding custom domains, Supabase handles certificate provisioning through automated certificate authorities, typically completing within minutes to hours after DNS verification.

All API requests, database connections, and authentication flows use HTTPS/TLS by default. Connection strings for direct database access should use SSL mode to ensure encrypted connections. The minimum TLS version and cipher suites are managed by Supabase infrastructure.

## Backup Strategies

Supabase provides automated backup systems, but production deployments require understanding backup coverage, retention periods, and restoration procedures.

**Automated backups** run daily on Pro tier and above, capturing full database snapshots. These backups are stored securely and retained according to your plan's retention period—typically 7 days for Pro tier, with longer retention on Team and Enterprise plans.

**Custom backup strategies** supplement automated backups for critical data. This includes exporting specific tables, creating logical dumps using `pg_dump`, or replicating data to external storage systems. Regular exports provide additional recovery options independent of Supabase infrastructure.

**Backup verification** ensures backups are valid and restorable. Periodic restoration tests to staging environments confirm backup integrity and document recovery procedures. Testing helps teams understand recovery time objectives and identify potential issues before emergencies.

Database schema changes, migration history, and configuration settings should also be version-controlled separately from data backups, typically in Git repositories alongside application code.

## Point-in-Time Recovery

Point-in-time recovery (PITR) enables restoring databases to any specific moment within the retention window, not just daily backup snapshots. This feature is available on higher-tier Supabase plans.

PITR works through continuous archiving of write-ahead logs (WAL), capturing every database transaction. When recovery is needed, you specify a target timestamp, and Supabase reconstructs the database state at that exact moment by replaying transactions.

This capability proves critical when data corruption or incorrect updates are discovered hours after occurrence. Rather than losing a full day's work by restoring the previous night's backup, PITR can restore to moments before the problem, minimizing data loss.

Recovery time objectives vary based on database size and how far back you're restoring. Planning should account for potential downtime during recovery operations and include procedures for notifying users during restoration.

## Disaster Recovery Planning

Disaster recovery plans document procedures for responding to catastrophic failures, including data loss, infrastructure outages, security breaches, or regional service disruptions.

**Recovery objectives** define acceptable data loss (Recovery Point Objective - RPO) and downtime (Recovery Time Objective - RTO). A production system might target RPO of 1 hour and RTO of 4 hours, meaning accepting at most 1 hour of lost data and 4 hours to restore service.

**Geographic redundancy** protects against regional failures. [Inference] While Supabase handles infrastructure redundancy within regions, cross-region disaster recovery typically requires replicating data to separate Supabase projects or external systems. This provides fallback options if an entire region becomes unavailable.

**Runbooks** document step-by-step recovery procedures for various failure scenarios. These include contact information, access credentials (stored securely), decision trees for determining appropriate responses, and checklists ensuring no steps are missed during high-pressure situations.

**Regular drills** validate disaster recovery plans by simulating failures and executing recovery procedures. These exercises identify gaps in documentation, test backup restoration, and train team members on emergency procedures.

## Scaling Considerations

Supabase projects must scale to handle growing user bases, increasing data volumes, and expanding feature sets. Scaling involves both vertical scaling (more powerful resources) and horizontal strategies (distributing load).

**Database scaling** begins with upgrading compute resources through Supabase plan tiers. Higher tiers provide more CPU, memory, and dedicated resources. Monitoring query performance helps identify optimization opportunities before requiring hardware upgrades.

**Connection pooling** efficiently manages database connections at scale. Supabase includes built-in connection pooling through PgBouncer, allowing thousands of client connections to share a smaller pool of actual database connections. Applications should use pooled connection strings rather than direct database connections for better scalability.

**Read replicas** [Unverified] may be available on higher Supabase tiers, distributing read queries across multiple database instances while writes go to the primary. This architecture suits read-heavy applications where most operations query existing data rather than creating updates.

**Edge Functions** handle serverless compute workloads, automatically scaling based on demand. Computationally intensive tasks or external API integrations run in Edge Functions rather than database functions, keeping database resources focused on data operations.

**Storage optimization** includes archiving old data, implementing data retention policies, and using appropriate indexes. Large tables benefit from partitioning strategies that improve query performance by organizing data into manageable segments.

## Cost Optimization

Production costs require ongoing attention to balance performance needs with budget constraints. Supabase pricing includes compute resources, storage, bandwidth, and additional services.

**Resource monitoring** identifies usage patterns and optimization opportunities. The Supabase dashboard provides metrics on database size, API requests, bandwidth consumption, and compute utilization. Unusual spikes might indicate inefficient queries, unnecessary data transfers, or potential issues requiring investigation.

**Query optimization** reduces resource consumption by ensuring efficient database operations. Proper indexing, avoiding N+1 queries, and using appropriate data types all contribute to lower resource usage. Slow query logs help identify problematic operations consuming disproportionate resources.

**Storage management** controls costs through data retention policies, compression, and appropriate use of Supabase Storage versus database storage. Large files belong in Supabase Storage (object storage) rather than database columns, both for cost efficiency and performance.

**Bandwidth optimization** minimizes data transfer costs through efficient API design. Pagination limits response sizes, field selection returns only needed columns, and caching strategies reduce redundant requests. Edge caching can serve frequently accessed content without hitting origin servers.

**Plan selection** should match actual usage patterns. Starting with appropriate tiers and adjusting based on real usage prevents both overpaying for unused capacity and experiencing service limitations from undersized plans.

## Monitoring Production Health

Continuous monitoring detects issues before they impact users and provides visibility into system behavior during incidents.

**Metrics collection** tracks key performance indicators including API response times, error rates, database query performance, connection pool utilization, and resource consumption. The Supabase dashboard provides built-in metrics, while external monitoring tools can aggregate data across your entire infrastructure stack.

**Alerting thresholds** notify teams when metrics exceed acceptable ranges. Alerts might trigger when error rates spike, response times degrade, database connections approach pool limits, or disk usage crosses critical thresholds. Alert fatigue from overly sensitive thresholds reduces effectiveness, so tuning alerts to catch genuine issues without excessive noise is important.

**Log aggregation** centralizes application logs, database logs, and infrastructure logs for correlation during investigations. Supabase provides access to logs through the dashboard and API. Shipping logs to external systems enables long-term retention, advanced analysis, and unified views across multiple services.

**Error tracking** captures application exceptions and errors with context including stack traces, user sessions, and environmental conditions. Integration with error tracking services provides automated grouping, impact assessment, and notification workflows.

**Uptime monitoring** regularly tests service availability from external locations. Synthetic monitoring simulates user workflows, detecting failures in API endpoints, authentication flows, or database connectivity before real users encounter problems.

**Performance profiling** during incidents or degraded performance helps identify bottlenecks. Database query analysis tools, API request tracing, and resource profiling pinpoint specific operations causing problems. Having profiling tools configured before emergencies enables faster investigation during critical situations.

**Important related topics**: Database performance tuning in Supabase, implementing Row Level Security policies for production, Supabase Edge Functions deployment patterns, implementing database migrations with zero downtime, PostgreSQL-specific production optimization strategies.

---

#  Advanced Topics

## Database Extensions

Supabase provides access to numerous PostgreSQL extensions that extend database functionality beyond standard SQL capabilities. Extensions are pre-packaged modules that add specialized features, from scheduling tasks to handling vector data for machine learning applications.

### Available Extensions

Supabase enables several dozen PostgreSQL extensions by default and allows activation of others through the dashboard. Core extensions include:

**pg_cron** - Task scheduling directly within PostgreSQL. Executes SQL commands on schedules using cron syntax without external job runners.

**pgvector** - Vector similarity search for embeddings. Stores high-dimensional vectors and performs nearest neighbor searches for AI/ML applications.

**postgis** - Geographic information system capabilities. Handles spatial data types, geographic queries, and coordinate system transformations.

**pg_stat_statements** - Query performance tracking. Records execution statistics for all SQL statements to identify slow queries.

**uuid-ossp** - UUID generation functions. Creates various UUID versions for unique identifiers.

**pg_trgm** - Trigram matching for fuzzy text search. Enables similarity comparisons and index-accelerated pattern matching.

**pgjwt** - JWT token creation and validation within PostgreSQL. Generates and verifies JSON Web Tokens using database functions.

**http** - HTTP client functionality. Makes outbound HTTP requests directly from SQL queries.

**pg_net** - Asynchronous networking. Performs non-blocking HTTP requests and webhook calls from database functions.

### Enabling Extensions

Extensions activate through the Supabase dashboard or SQL:

```sql
-- Via SQL
CREATE EXTENSION IF NOT EXISTS pgvector;
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Check enabled extensions
SELECT * FROM pg_extension;
```

Through the dashboard: Database → Extensions → Enable desired extension.

[Inference] Most extensions require no additional configuration after enabling, though some like pg_cron may need schema permissions adjusted.

### pg_cron for Scheduled Tasks

pg_cron executes SQL on recurring schedules without external infrastructure.

```sql
-- Enable extension
CREATE EXTENSION pg_cron;

-- Schedule daily cleanup at 3 AM
SELECT cron.schedule(
  'daily-cleanup',
  '0 3 * * *',
  $$DELETE FROM logs WHERE created_at < NOW() - INTERVAL '30 days'$$
);

-- Schedule hourly aggregation
SELECT cron.schedule(
  'hourly-stats',
  '0 * * * *',
  $$
    INSERT INTO hourly_metrics (hour, user_count)
    SELECT DATE_TRUNC('hour', NOW()), COUNT(DISTINCT user_id)
    FROM activity_logs
    WHERE created_at >= NOW() - INTERVAL '1 hour'
  $$
);

-- List scheduled jobs
SELECT * FROM cron.job;

-- Unschedule a job
SELECT cron.unschedule('daily-cleanup');

-- View job run history
SELECT * FROM cron.job_run_details 
ORDER BY start_time DESC 
LIMIT 10;
```

Cron syntax follows standard format: minute, hour, day-of-month, month, day-of-week.

**Common patterns:**
- `'*/15 * * * *'` - Every 15 minutes
- `'0 */6 * * *'` - Every 6 hours
- `'0 0 * * 0'` - Weekly on Sunday midnight
- `'0 2 1 * *'` - First day of month at 2 AM

[Unverified] pg_cron jobs run with the permissions of the role that created them. Job execution failures appear in `cron.job_run_details` with error messages.

### pgvector for Vector Embeddings

pgvector stores and queries high-dimensional vectors for semantic search, recommendations, and AI applications.

```sql
-- Enable extension
CREATE EXTENSION vector;

-- Create table with vector column
CREATE TABLE documents (
  id BIGSERIAL PRIMARY KEY,
  content TEXT,
  embedding VECTOR(1536),  -- Dimension matches your model
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for fast similarity search
CREATE INDEX ON documents 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Insert document with embedding
INSERT INTO documents (content, embedding)
VALUES (
  'PostgreSQL is a powerful database',
  '[0.1, 0.2, 0.3, ...]'::vector
);

-- Find similar documents (cosine similarity)
SELECT 
  id,
  content,
  1 - (embedding <=> '[0.15, 0.25, 0.35, ...]'::vector) AS similarity
FROM documents
ORDER BY embedding <=> '[0.15, 0.25, 0.35, ...]'::vector
LIMIT 10;

-- L2 distance (Euclidean)
SELECT content
FROM documents
ORDER BY embedding <-> '[0.1, 0.2, ...]'::vector
LIMIT 5;

-- Inner product
SELECT content
FROM documents
ORDER BY embedding <#> '[0.1, 0.2, ...]'::vector DESC
LIMIT 5;
```

**Distance operators:**
- `<=>` Cosine distance (1 - cosine similarity)
- `<->` L2/Euclidean distance
- `<#>` Negative inner product

**Index types:**

**IVFFlat** - Divides vectors into lists, searches nearest lists. Faster but approximate.
```sql
CREATE INDEX ON documents 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

**HNSW** - Hierarchical graph structure, better recall than IVFFlat.
```sql
CREATE INDEX ON documents 
USING hnsw (embedding vector_cosine_ops);
```

[Inference] The `lists` parameter for IVFFlat typically uses `rows / 1000` as a starting point. Higher values increase accuracy but slow queries. HNSW generally provides better accuracy-speed tradeoffs for most workloads.

### Integration with Embeddings APIs

Typical workflow combines Supabase with embedding models:

```javascript
import { createClient } from '@supabase/supabase-js'
import OpenAI from 'openai'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)
const openai = new OpenAI({ apiKey: OPENAI_KEY })

// Generate embedding
async function generateEmbedding(text) {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: text
  })
  return response.data[0].embedding
}

// Store document with embedding
async function storeDocument(content) {
  const embedding = await generateEmbedding(content)
  
  const { data, error } = await supabase
    .from('documents')
    .insert({
      content,
      embedding
    })
  
  return { data, error }
}

// Semantic search
async function searchSimilar(query, limit = 5) {
  const embedding = await generateEmbedding(query)
  
  const { data, error } = await supabase.rpc('match_documents', {
    query_embedding: embedding,
    match_threshold: 0.7,
    match_count: limit
  })
  
  return { data, error }
}
```

Database function for semantic search:

```sql
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding VECTOR(1536),
  match_threshold FLOAT,
  match_count INT
)
RETURNS TABLE (
  id BIGINT,
  content TEXT,
  similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    documents.id,
    documents.content,
    1 - (documents.embedding <=> query_embedding) AS similarity
  FROM documents
  WHERE 1 - (documents.embedding <=> query_embedding) > match_threshold
  ORDER BY documents.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;
```

## Full-Text Search with Extensions

PostgreSQL provides built-in full-text search capabilities enhanced by extensions for fuzzy matching, highlighting, and ranking.

### Built-in Full-Text Search

PostgreSQL's native full-text search uses tsvector and tsquery types:

```sql
-- Add tsvector column
ALTER TABLE articles 
ADD COLUMN content_search TSVECTOR
GENERATED ALWAYS AS (
  to_tsvector('english', title || ' ' || body)
) STORED;

-- Create GIN index for fast search
CREATE INDEX articles_search_idx 
ON articles 
USING GIN (content_search);

-- Simple search
SELECT title, body
FROM articles
WHERE content_search @@ to_tsquery('english', 'postgresql & database');

-- Ranked search
SELECT 
  title,
  ts_rank(content_search, query) AS rank
FROM articles, 
     to_tsquery('english', 'postgresql | postgres') query
WHERE content_search @@ query
ORDER BY rank DESC;

-- Headline extraction (snippets)
SELECT 
  title,
  ts_headline('english', body, query, 'MaxWords=50, MinWords=30') AS snippet
FROM articles,
     to_tsquery('english', 'machine & learning') query
WHERE content_search @@ query;
```

**Text search configurations** support multiple languages: `'english'`, `'spanish'`, `'french'`, `'german'`, etc. Each handles language-specific stemming and stop words.

### pg_trgm for Fuzzy Search

pg_trgm enables similarity-based matching and typo tolerance:

```sql
-- Enable extension
CREATE EXTENSION pg_trgm;

-- Create trigram index
CREATE INDEX articles_title_trgm_idx 
ON articles 
USING GIN (title gin_trgm_ops);

-- Fuzzy search with ILIKE
SELECT title
FROM articles
WHERE title ILIKE '%postgrsql%';  -- Finds "PostgreSQL" despite typo

-- Similarity search
SELECT 
  title,
  similarity(title, 'PostgreSQL Database') AS sim
FROM articles
WHERE similarity(title, 'PostgreSQL Database') > 0.3
ORDER BY sim DESC;

-- Word similarity (better for partial matches)
SELECT title
FROM articles
WHERE title % 'postgres'  -- % operator uses similarity
ORDER BY similarity(title, 'postgres') DESC;

-- Trigram distance
SELECT 
  title,
  title <-> 'postgresql guide' AS distance
FROM articles
ORDER BY distance
LIMIT 10;
```

**Similarity operators:**
- `%` - Similarity operator (>= threshold)
- `<->` - Distance operator (lower is more similar)
- `similarity(text, text)` - Returns similarity score (0-1)

### Combined Approach

Hybrid search combines full-text and fuzzy matching:

```sql
-- Search function with multiple strategies
CREATE OR REPLACE FUNCTION search_articles(
  search_term TEXT,
  similarity_threshold FLOAT DEFAULT 0.3
)
RETURNS TABLE (
  id BIGINT,
  title TEXT,
  body TEXT,
  relevance FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  WITH fts_results AS (
    SELECT 
      a.id,
      a.title,
      a.body,
      ts_rank(a.content_search, query) * 2 AS score
    FROM articles a,
         to_tsquery('english', search_term) query
    WHERE a.content_search @@ query
  ),
  fuzzy_results AS (
    SELECT 
      a.id,
      a.title,
      a.body,
      similarity(a.title || ' ' || a.body, search_term) AS score
    FROM articles a
    WHERE similarity(a.title || ' ' || a.body, search_term) > similarity_threshold
  )
  SELECT 
    COALESCE(f.id, fz.id) AS id,
    COALESCE(f.title, fz.title) AS title,
    COALESCE(f.body, fz.body) AS body,
    COALESCE(f.score, 0) + COALESCE(fz.score, 0) AS relevance
  FROM fts_results f
  FULL OUTER JOIN fuzzy_results fz ON f.id = fz.id
  ORDER BY relevance DESC;
END;
$$;
```

### Search with RLS

Full-text search respects Row Level Security:

```sql
-- Enable RLS
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

-- Policy for search
CREATE POLICY "Users see published articles"
ON articles
FOR SELECT
USING (
  status = 'published' 
  OR author_id = auth.uid()
);

-- Search automatically filters by policy
SELECT title
FROM articles
WHERE content_search @@ to_tsquery('english', 'supabase');
```

## Multi-Tenancy Patterns

Multi-tenancy isolates customer data within shared infrastructure. Supabase supports multiple approaches depending on isolation requirements and scale.

### Row Level Security Pattern

Most common pattern uses RLS to partition data by tenant within shared tables:

```sql
-- Users table with tenant association
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL,
  email TEXT,
  role TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants NOT NULL,
  title TEXT NOT NULL,
  content TEXT,
  created_by UUID REFERENCES auth.users,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Helper function to get user's tenant
CREATE OR REPLACE FUNCTION auth.user_tenant_id()
RETURNS UUID
LANGUAGE sql STABLE
AS $$
  SELECT tenant_id 
  FROM profiles 
  WHERE user_id = auth.uid()
  LIMIT 1;
$$;

-- RLS policies
CREATE POLICY "Users access own tenant profiles"
ON profiles FOR ALL
USING (tenant_id = auth.user_tenant_id());

CREATE POLICY "Users access own tenant documents"
ON documents FOR ALL
USING (tenant_id = auth.user_tenant_id());

-- Indexes for tenant filtering
CREATE INDEX profiles_tenant_id_idx ON profiles(tenant_id);
CREATE INDEX documents_tenant_id_idx ON documents(tenant_id);
```

**Key points:**
- All tables include `tenant_id` foreign key
- RLS policies filter by tenant automatically
- Indexes on `tenant_id` maintain query performance
- User-tenant association stored in profiles table

[Inference] The helper function `auth.user_tenant_id()` should be marked as `STABLE` rather than `IMMUTABLE` since it depends on `auth.uid()` which can change between transactions. The function caches within a single query execution.

### Schema-Based Multi-Tenancy

Separate PostgreSQL schemas per tenant provide stronger isolation:

```sql
-- Create tenant schema
CREATE SCHEMA tenant_acme;
CREATE SCHEMA tenant_globex;

-- Create tables in tenant schema
CREATE TABLE tenant_acme.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tenant_globex.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to set search path
CREATE OR REPLACE FUNCTION set_tenant_schema()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  tenant_schema TEXT;
BEGIN
  -- Get tenant schema from user metadata
  SELECT raw_user_meta_data->>'tenant_schema'
  INTO tenant_schema
  FROM auth.users
  WHERE id = auth.uid();
  
  -- Set search path
  EXECUTE format('SET search_path TO %I, public', tenant_schema);
END;
$$;

-- Use in application
-- Call set_tenant_schema() at connection start
SELECT set_tenant_schema();

-- Now queries automatically use correct schema
SELECT * FROM documents;  -- Accesses tenant_acme.documents or tenant_globex.documents
```

**Advantages:**
- Stronger data isolation
- Simpler queries (no tenant_id filters)
- Can apply schema-level permissions
- Easier to backup/restore individual tenants

**Disadvantages:**
- More complex schema management
- [Inference] Connection pooling becomes less efficient since connections can't be reused across tenants without changing search_path
- Query planning may be less efficient across many schemas

### Database-Per-Tenant

[Unverified] Supabase Enterprise may support provisioning separate database instances per tenant, though this is not documented in standard plans. This provides maximum isolation but significantly increases infrastructure complexity and cost.

For standard Supabase projects, this pattern is not available. Consider RLS or schema-based approaches instead.

### Tenant Context in Edge Functions

Edge Functions need explicit tenant context:

```typescript
import { createClient } from '@supabase/supabase-js'

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    {
      global: {
        headers: { Authorization: req.headers.get('Authorization')! }
      }
    }
  )
  
  // Get user's tenant
  const { data: profile } = await supabase
    .from('profiles')
    .select('tenant_id')
    .eq('user_id', (await supabase.auth.getUser()).data.user?.id)
    .single()
  
  // Query with tenant context (RLS applies automatically)
  const { data: documents } = await supabase
    .from('documents')
    .select('*')
  
  return new Response(JSON.stringify(documents), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

### Tenant Isolation Verification

Test tenant isolation with multiple users:

```sql
-- Create test function
CREATE OR REPLACE FUNCTION test_tenant_isolation()
RETURNS TABLE (
  test_name TEXT,
  passed BOOLEAN,
  details TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Test 1: User can only see own tenant data
  RETURN QUERY
  WITH user_count AS (
    SELECT COUNT(DISTINCT tenant_id) as tenant_count
    FROM documents
  )
  SELECT 
    'Single tenant visibility'::TEXT,
    tenant_count = 1,
    format('User sees %s tenants', tenant_count)
  FROM user_count;
  
  -- Add more isolation tests
END;
$$;
```

## Webhooks and Event-Driven Architecture

Supabase supports database webhooks and event-driven patterns using PostgreSQL triggers and extensions.

### Database Webhooks

Database webhooks send HTTP requests when data changes:

```sql
-- Enable http extension
CREATE EXTENSION IF NOT EXISTS http;

-- Enable pg_net for async requests
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Create webhook function
CREATE OR REPLACE FUNCTION notify_webhook()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  webhook_url TEXT := 'https://your-app.com/webhooks/database';
  payload JSONB;
BEGIN
  -- Build payload
  payload := jsonb_build_object(
    'table', TG_TABLE_NAME,
    'operation', TG_OP,
    'record', row_to_json(NEW),
    'old_record', row_to_json(OLD),
    'timestamp', NOW()
  );
  
  -- Async HTTP request (non-blocking)
  PERFORM net.http_post(
    url := webhook_url,
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := payload
  );
  
  RETURN NEW;
END;
$$;

-- Attach trigger
CREATE TRIGGER orders_webhook
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION notify_webhook();
```

**Synchronous webhooks** using http extension (blocks transaction):

```sql
CREATE OR REPLACE FUNCTION sync_webhook()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  response http_response;
BEGIN
  SELECT * INTO response
  FROM http_post(
    'https://api.example.com/webhook',
    jsonb_build_object('data', row_to_json(NEW))::text,
    'application/json'
  );
  
  -- Check response
  IF response.status != 200 THEN
    RAISE EXCEPTION 'Webhook failed: %', response.status;
  END IF;
  
  RETURN NEW;
END;
$$;
```

[Unverified] Synchronous webhooks can timeout and block transactions. Asynchronous webhooks using pg_net are generally preferred for reliability, though they don't provide immediate response feedback.

### Database Change Listeners

Supabase Realtime provides change listeners without custom triggers:

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

// Listen to all changes
const channel = supabase
  .channel('db-changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'orders'
    },
    (payload) => {
      console.log('Change:', payload)
      // Process change event
    }
  )
  .subscribe()

// Listen to specific events
supabase
  .channel('inserts-only')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'orders'
    },
    (payload) => {
      console.log('New order:', payload.new)
    }
  )
  .subscribe()

// Filter by column value
supabase
  .channel('high-value-orders')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'orders',
      filter: 'total=gt.1000'
    },
    (payload) => {
      console.log('High value order:', payload.new)
    }
  )
  .subscribe()
```

### Event Sourcing Pattern

Store events as immutable log, derive state:

```sql
-- Events table
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  aggregate_id UUID NOT NULL,
  aggregate_type TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_data JSONB NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for aggregate queries
CREATE INDEX events_aggregate_idx 
ON events(aggregate_id, created_at);

-- Projection: current order state
CREATE TABLE orders_current (
  id UUID PRIMARY KEY,
  status TEXT,
  total DECIMAL,
  customer_id UUID,
  updated_at TIMESTAMPTZ
);

-- Function to apply events
CREATE OR REPLACE FUNCTION apply_order_event()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.event_type = 'order_created' THEN
    INSERT INTO orders_current (id, status, total, customer_id, updated_at)
    VALUES (
      NEW.aggregate_id,
      'pending',
      (NEW.event_data->>'total')::DECIMAL,
      (NEW.event_data->>'customer_id')::UUID,
      NEW.created_at
    );
    
  ELSIF NEW.event_type = 'order_confirmed' THEN
    UPDATE orders_current
    SET status = 'confirmed', updated_at = NEW.created_at
    WHERE id = NEW.aggregate_id;
    
  ELSIF NEW.event_type = 'order_shipped' THEN
    UPDATE orders_current
    SET status = 'shipped', updated_at = NEW.created_at
    WHERE id = NEW.aggregate_id;
    
  END IF;
  
  RETURN NEW;
END;
$$;

-- Trigger to maintain projection
CREATE TRIGGER apply_events
AFTER INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION apply_order_event();
```

Application code:

```javascript
// Append event (never update)
async function createOrder(orderData) {
  const { data } = await supabase
    .from('events')
    .insert({
      aggregate_id: orderData.id,
      aggregate_type: 'order',
      event_type: 'order_created',
      event_data: orderData
    })
  
  return data
}

// Read current state from projection
async function getOrder(orderId) {
  const { data } = await supabase
    .from('orders_current')
    .select('*')
    .eq('id', orderId)
    .single()
  
  return data
}

// Rebuild projection from events
async function rebuildProjection(orderId) {
  const { data: events } = await supabase
    .from('events')
    .select('*')
    .eq('aggregate_id', orderId)
    .order('created_at')
  
  // Replay events to rebuild state
  // (handled by trigger in this example)
}
```

### Queue Pattern with pg_cron

Implement job queues using tables and scheduled processors:

```sql
-- Jobs table
CREATE TABLE job_queue (
  id BIGSERIAL PRIMARY KEY,
  job_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  status TEXT DEFAULT 'pending',
  attempts INT DEFAULT 0,
  max_attempts INT DEFAULT 3,
  error TEXT,
  scheduled_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for processing
CREATE INDEX job_queue_pending_idx 
ON job_queue(status, scheduled_at)
WHERE status = 'pending';

-- Process jobs function
CREATE OR REPLACE FUNCTION process_pending_jobs()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  job RECORD;
BEGIN
  FOR job IN
    SELECT * FROM job_queue
    WHERE status = 'pending'
      AND scheduled_at <= NOW()
    ORDER BY scheduled_at
    LIMIT 100
    FOR UPDATE SKIP LOCKED
  LOOP
    BEGIN
      -- Mark as processing
      UPDATE job_queue
      SET status = 'processing', started_at = NOW()
      WHERE id = job.id;
      
      -- Process based on job type
      IF job.job_type = 'send_email' THEN
        PERFORM net.http_post(
          'https://email-service.com/send',
          job.payload
        );
      ELSIF job.job_type = 'generate_report' THEN
        -- Process report
        NULL;
      END IF;
      
      -- Mark completed
      UPDATE job_queue
      SET status = 'completed', completed_at = NOW()
      WHERE id = job.id;
      
    EXCEPTION WHEN OTHERS THEN
      -- Handle failure
      UPDATE job_queue
      SET 
        status = CASE 
          WHEN attempts + 1 >= max_attempts THEN 'failed'
          ELSE 'pending'
        END,
        attempts = attempts + 1,
        error = SQLERRM,
        scheduled_at = NOW() + (INTERVAL '1 minute' * POWER(2, attempts))
      WHERE id = job.id;
    END;
  END LOOP;
END;
$$;

-- Schedule processor
SELECT cron.schedule(
  'process-jobs',
  '* * * * *',  -- Every minute
  'SELECT process_pending_jobs()'
);
```

Enqueue jobs from application:

```javascript
async function enqueueJob(jobType, payload, scheduledAt = new Date()) {
  const { data } = await supabase
    .from('job_queue')
    .insert({
      job_type: jobType,
      payload: payload,
      scheduled_at: scheduledAt.toISOString()
    })
  
  return data
}

// Enqueue email
await enqueueJob('send_email', {
  to: 'user@example.com',
  subject: 'Welcome',
  body: 'Thanks for signing up'
})

// Schedule future job
await enqueueJob('send_reminder', {
  user_id: '123'
}, new Date(Date.now() + 24 * 60 * 60 * 1000))
```

## GraphQL with pg_graphql

pg_graphql exposes PostgreSQL databases as GraphQL APIs automatically based on schema.

### Enabling pg_graphql

```sql
CREATE EXTENSION IF NOT EXISTS pg_graphql;
```

Supabase projects include pg_graphql by default with GraphQL endpoint at `https://<project-ref>.supabase.co/graphql/v1`.

### Automatic Schema Generation

pg_graphql introspects database schema and generates GraphQL types:

```sql
-- Database schema
CREATE TABLE authors (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE books (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  author_id BIGINT REFERENCES authors,
  published_date DATE,
  isbn TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

Generated GraphQL schema automatically includes:

```graphql
type Author {
  id: BigInt!
  name: String!
  bio: String
  createdAt: Datetime
  books: [Book!]!  ## Relationship inferred from foreign key
}

type Book {
  id: BigInt!
  title: String!
  authorId: BigInt
  publishedDate: Date
  isbn: String
  createdAt: Datetime
  author: Author  ## Relationship inferred from foreign key
}

type Query {
  authorsCollection(
    filter: AuthorFilter
    orderBy: [AuthorOrderBy!]
    first: Int
    last: Int
    before: Cursor
    after: Cursor
  ): AuthorConnection
  
  booksCollection(...): BookConnection
}

type Mutation {
  insertIntoAuthorsCollection(objects: [AuthorInsertInput!]!): AuthorInsertResponse
  updateAuthorsCollection(set: AuthorUpdateInput!, filter: AuthorFilter): AuthorUpdateResponse
  deleteFromAuthorsCollection(filter: AuthorFilter!): AuthorDeleteResponse
  ## Similar for books...
}
```

### Querying with GraphQL

```javascript
const query = `
  query GetAuthors {
    authorsCollection(
      filter: { name: { ilike: "%tolkien%" } }
      orderBy: { name: AscNullsLast }
      first: 10
    ) {
      edges {
        node {
          id
          name
          bio
          books: booksCollection {
            edges {
              node {
                id
                title
                publishedDate
              }
            }
          }
        }
      }
    }
  }
`

const response = await fetch(
  'https://<project-ref>.supabase.co/graphql/v1',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_ANON_KEY
    },
    body: JSON.stringify({ query })
  }
)

const { data } = await response.json()
```

### Mutations

```graphql
mutation CreateAuthor {
  insertIntoAuthorsCollection(
    objects: [
      { name: "J.R.R. Tolkien", bio: "Author of The Lord of the Rings" }
    ]
  ) {
    records {
      id
      name
    }
  }
}

mutation UpdateAuthor {
  updateAuthorsCollection(
    set: { bio: "Updated bio" }
    filter: { id: { eq: 1 } }
  ) {
    records {
      id
      name
      bio
    }
  }
}

mutation DeleteAuthor {
  deleteFromAuthorsCollection(
    filter: { id: { eq: 1 } }
  ) {
    records {
      id
    }
  }
}
```

### Row Level Security

pg_graphql respects RLS policies automatically:

```sql
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public books are viewable by everyone" ON books FOR SELECT USING (status = 'published');

CREATE POLICY "Authors can update own books" ON books FOR UPDATE USING (author_id IN ( SELECT id FROM authors WHERE user_id = auth.uid() ));

````

GraphQL queries execute with the authenticated user's permissions. Pass JWT in Authorization header:

```javascript
const response = await fetch(
  'https://<project-ref>.supabase.co/graphql/v1',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${userJWT}`
    },
    body: JSON.stringify({ query })
  }
)
````

### Customizing GraphQL Behavior

Control GraphQL exposure with SQL comments:

```sql
-- Hide table from GraphQL
COMMENT ON TABLE internal_logs IS '@graphql({"exclude": true})';

-- Rename type
COMMENT ON TABLE books IS '@graphql({"name": "Publication"})';

-- Hide column
COMMENT ON COLUMN users.password_hash IS '@graphql({"exclude": true})';

-- Custom description
COMMENT ON TABLE authors IS '@graphql({"description": "Book authors and their works"})';
```

### Filtering and Ordering

pg_graphql supports comprehensive filtering:

```graphql
query FilteredBooks {
  booksCollection(
    filter: {
      and: [
        { publishedDate: { gte: "2000-01-01" } }
        { publishedDate: { lte: "2020-12-31" } }
        { or: [
          { title: { ilike: "%lord%" } }
          { title: { ilike: "%ring%" } }
        ]}
      ]
    }
    orderBy: [
      { publishedDate: DescNullsLast }
      { title: AscNullsFirst }
    ]
  ) {
    edges {
      node {
        title
        publishedDate
      }
    }
  }
}
```

**Filter operators:**

- `eq`, `neq` - Equality
- `gt`, `gte`, `lt`, `lte` - Comparisons
- `in`, `nin` - Array membership
- `like`, `ilike` - Pattern matching
- `is` - Null checks
- `and`, `or`, `not` - Logical operators

### Pagination

Cursor-based pagination using Relay specification:

```graphql
query PaginatedAuthors($cursor: Cursor) {
  authorsCollection(
    first: 10
    after: $cursor
  ) {
    edges {
      cursor
      node {
        id
        name
      }
    }
    pageInfo {
      hasNextPage
      hasPreviousPage
      startCursor
      endCursor
    }
  }
}
```

```javascript
async function fetchAllAuthors() {
  let allAuthors = []
  let cursor = null
  let hasNext = true
  
  while (hasNext) {
    const { data } = await fetch(GRAPHQL_ENDPOINT, {
      method: 'POST',
      headers: { /* ... */ },
      body: JSON.stringify({
        query: PaginatedAuthors,
        variables: { cursor }
      })
    }).then(r => r.json())
    
    const collection = data.authorsCollection
    allAuthors.push(...collection.edges.map(e => e.node))
    
    hasNext = collection.pageInfo.hasNextPage
    cursor = collection.pageInfo.endCursor
  }
  
  return allAuthors
}
```

### Aggregations

[Inference] pg_graphql may support aggregate functions through custom queries, though automatic aggregation generation is not extensively documented. Use database functions for complex aggregations:

```sql
CREATE OR REPLACE FUNCTION books_by_author_count()
RETURNS TABLE (
  author_id BIGINT,
  author_name TEXT,
  book_count BIGINT
)
LANGUAGE sql STABLE
AS $$
  SELECT 
    a.id,
    a.name,
    COUNT(b.id)
  FROM authors a
  LEFT JOIN books b ON b.author_id = a.id
  GROUP BY a.id, a.name
  ORDER BY COUNT(b.id) DESC;
$$;
```

Query via GraphQL:

```graphql
query AuthorStats {
  booksByAuthorCountCollection {
    edges {
      node {
        authorId
        authorName
        bookCount
      }
    }
  }
}
```

## Custom PostgreSQL Configurations

Supabase allows customization of PostgreSQL settings for performance tuning and specific workload optimization.

### Available Configuration Options

Access configuration through the Supabase dashboard under Database → Configuration or via SQL:

```sql
-- View current settings
SELECT name, setting, unit, context
FROM pg_settings
WHERE name IN (
  'max_connections',
  'shared_buffers',
  'effective_cache_size',
  'work_mem',
  'maintenance_work_mem',
  'statement_timeout',
  'idle_in_transaction_session_timeout'
)
ORDER BY name;

-- Show all settings
SELECT * FROM pg_settings ORDER BY name;
```

### Common Performance Settings

[Unverified] Exact configuration options available for modification may vary by Supabase plan tier. Enterprise plans typically allow more extensive customization.

**Connection settings:**

```sql
-- Maximum concurrent connections (requires restart)
ALTER SYSTEM SET max_connections = 100;

-- Connection timeout (milliseconds)
ALTER SYSTEM SET statement_timeout = '30s';

-- Idle transaction timeout
ALTER SYSTEM SET idle_in_transaction_session_timeout = '10min';
```

**Memory settings:**

```sql
-- Shared buffers (25% of RAM typical)
ALTER SYSTEM SET shared_buffers = '2GB';

-- Effective cache size (50-75% of RAM)
ALTER SYSTEM SET effective_cache_size = '6GB';

-- Work memory per operation
ALTER SYSTEM SET work_mem = '64MB';

-- Maintenance operations memory
ALTER SYSTEM SET maintenance_work_mem = '512MB';
```

**Query planning:**

```sql
-- Random page cost (lower for SSD)
ALTER SYSTEM SET random_page_cost = 1.1;

-- Parallel query workers
ALTER SYSTEM SET max_parallel_workers_per_gather = 4;
ALTER SYSTEM SET max_parallel_workers = 8;

-- Enable JIT compilation for complex queries
ALTER SYSTEM SET jit = on;
```

### Session-Level Configuration

Set parameters for specific sessions without system-wide changes:

```sql
-- Set for current session
SET work_mem = '256MB';
SET statement_timeout = '60s';

-- Set for transaction
BEGIN;
SET LOCAL work_mem = '512MB';
-- Complex query here
COMMIT;
```

From application code:

```javascript
const { data } = await supabase.rpc('complex_query', {}, {
  // Session config via custom headers (if supported)
})

// Or use connection pooler with custom settings
const client = new Client({
  connectionString: SUPABASE_CONNECTION_STRING,
  options: '-c statement_timeout=30000'
})
```

### Monitoring Configuration Impact

Track configuration effectiveness:

```sql
-- Query performance stats
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  max_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Cache hit ratio (should be >99%)
SELECT 
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit) as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM pg_statio_user_tables;

-- Connection usage
SELECT 
  count(*) as connections,
  state,
  wait_event_type
FROM pg_stat_activity
GROUP BY state, wait_event_type;

-- Unused indexes (candidates for removal)
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%pkey'
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Database Size Management

Configure autovacuum for optimal space management:

```sql
-- Global autovacuum settings
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.1;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.05;

-- Per-table autovacuum
ALTER TABLE large_table SET (
  autovacuum_vacuum_scale_factor = 0.05,
  autovacuum_analyze_scale_factor = 0.02
);

-- Manual vacuum
VACUUM ANALYZE large_table;

-- Full vacuum (reclaims space, requires lock)
VACUUM FULL large_table;

-- Check table bloat
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
  n_dead_tup,
  n_live_tup,
  round(n_dead_tup * 100.0 / NULLIF(n_live_tup + n_dead_tup, 0), 2) as dead_ratio
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

### Write-Ahead Log (WAL) Configuration

```sql
-- WAL settings for durability vs performance
ALTER SYSTEM SET wal_compression = on;
ALTER SYSTEM SET wal_buffers = '16MB';

-- Checkpoint frequency
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET max_wal_size = '2GB';
ALTER SYSTEM SET min_wal_size = '1GB';

-- Monitor WAL generation
SELECT 
  pg_current_wal_lsn(),
  pg_walfile_name(pg_current_wal_lsn());
```

### Custom Configuration Functions

Create functions to apply configuration sets:

```sql
-- Development mode: more verbose logging
CREATE OR REPLACE FUNCTION set_dev_config()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  SET log_statement = 'all';
  SET log_duration = on;
  SET log_min_duration_statement = 0;
  SET client_min_messages = 'debug';
END;
$$;

-- Production mode: optimized performance
CREATE OR REPLACE FUNCTION set_prod_config()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  SET log_statement = 'none';
  SET log_duration = off;
  SET log_min_duration_statement = 1000;
  SET client_min_messages = 'warning';
END;
$$;
```

## Database Replication

PostgreSQL replication provides high availability, disaster recovery, and read scaling.

### Replication in Supabase

[Unverified] Supabase manages physical replication automatically for high availability. The replication configuration and topology are managed by Supabase infrastructure and not directly configurable by users in standard plans.

For custom replication setups, consider:

### Logical Replication for Data Distribution

Logical replication replicates specific tables/schemas to other databases:

```sql
-- On source database (publisher)
CREATE PUBLICATION data_sync FOR TABLE orders, customers;

-- Or publish all tables
CREATE PUBLICATION all_tables FOR ALL TABLES;

-- Add/remove tables
ALTER PUBLICATION data_sync ADD TABLE products;
ALTER PUBLICATION data_sync DROP TABLE customers;

-- View publications
SELECT * FROM pg_publication;
SELECT * FROM pg_publication_tables;
```

```sql
-- On destination database (subscriber)
CREATE SUBSCRIPTION data_sync
CONNECTION 'host=source-db.supabase.co port=5432 dbname=postgres user=replication_user password=xxx'
PUBLICATION data_sync;

-- View subscriptions
SELECT * FROM pg_subscription;

-- Monitor replication lag
SELECT 
  application_name,
  state,
  sent_lsn,
  write_lsn,
  flush_lsn,
  replay_lsn,
  sync_state
FROM pg_stat_replication;
```

[Inference] Logical replication requires network connectivity between databases and appropriate authentication. In Supabase, this typically requires using connection pooler or direct database connections with proper firewall rules configured.

### Read Replicas

[Unverified] Supabase Enterprise plans may offer managed read replicas for scaling read workloads across geographic regions. This is not available in standard plans through user configuration.

For read scaling without managed replicas, consider:

**Connection pooling** with PgBouncer (included in Supabase):

```javascript
// Use pooler for read-heavy workloads
const supabase = createClient(
  'https://PROJECT.supabase.co',
  'ANON_KEY',
  {
    db: {
      schema: 'public'
    },
    global: {
      headers: { 'x-connection-pooled': 'true' }
    }
  }
)
```

### Replication Monitoring

Track replication status:

```sql
-- Replication slots
SELECT 
  slot_name,
  slot_type,
  database,
  active,
  restart_lsn,
  confirmed_flush_lsn
FROM pg_replication_slots;

-- WAL sender processes
SELECT 
  pid,
  usename,
  application_name,
  client_addr,
  state,
  sent_lsn,
  write_lsn,
  flush_lsn,
  replay_lsn,
  sync_priority,
  sync_state,
  pg_wal_lsn_diff(sent_lsn, replay_lsn) as lag_bytes
FROM pg_stat_replication;

-- Subscription status
SELECT 
  subname,
  pid,
  received_lsn,
  latest_end_lsn,
  last_msg_send_time,
  last_msg_receipt_time,
  latest_end_time
FROM pg_stat_subscription;
```

### Point-in-Time Recovery (PITR)

Supabase provides automated backups with PITR:

```sql
-- View backup status through Supabase dashboard
-- Database → Backups

-- Manual backup before major changes
-- (Performed through Supabase dashboard)
```

[Unverified] PITR recovery windows and backup retention policies depend on Supabase plan tier. Enterprise plans typically offer extended retention and more granular recovery options.

### Replication Conflict Handling

For multi-master scenarios (not default in Supabase):

```sql
-- Last-write-wins with timestamps
CREATE TABLE distributed_data (
  id UUID PRIMARY KEY,
  data JSONB,
  version INT DEFAULT 1,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by TEXT
);

-- Conflict resolution function
CREATE OR REPLACE FUNCTION resolve_conflict()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Keep newer version based on timestamp
  IF NEW.updated_at > OLD.updated_at THEN
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
$$;

CREATE TRIGGER conflict_resolution
BEFORE UPDATE ON distributed_data
FOR EACH ROW
EXECUTE FUNCTION resolve_conflict();
```

## International Considerations

Deploy and scale Supabase applications globally with region selection, compliance, and localization.

### Geographic Regions

Supabase offers multiple deployment regions:

**Available regions (as of knowledge cutoff):**

- North America: us-east-1, us-west-1
- Europe: eu-west-1, eu-central-1
- Asia Pacific: ap-southeast-1, ap-northeast-1

[Unverified] Additional regions may be available. Check Supabase dashboard during project creation for current region options.

**Region selection considerations:**

**Latency** - Choose region closest to primary user base. Each 1000km adds ~10ms round-trip latency.

**Data residency** - Select regions matching data governance requirements (GDPR, CCPA, etc.).

**Availability** - Multiple availability zones within regions provide redundancy.

### Multi-Region Architecture

For global applications:

**Primary region + Edge Functions:**

```typescript
// Edge Function automatically deployed globally
Deno.serve(async (req) => {
  // Edge runs close to user
  const userLocation = req.headers.get('x-vercel-ip-country')
  
  // Database request goes to primary region
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!
  )
  
  const { data } = await supabase
    .from('content')
    .select('*')
    .eq('region', userLocation)
  
  return new Response(JSON.stringify(data))
})
```

**Multi-region with replication:**

[Unverified] Multi-region replication requires Enterprise plan and manual setup. Standard approach uses single primary region with Edge Functions for global compute.

### Data Compliance

Configure projects for regulatory compliance:

**GDPR (European Union):**

```sql
-- Data retention policies
CREATE TABLE user_data (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '2 years'
);

-- Automated deletion function
CREATE OR REPLACE FUNCTION delete_expired_data()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM user_data
  WHERE expires_at < NOW();
END;
$$;

-- Schedule with pg_cron
SELECT cron.schedule(
  'gdpr-cleanup',
  '0 2 * * *',
  'SELECT delete_expired_data()'
);

-- Right to erasure function
CREATE OR REPLACE FUNCTION erase_user_data(target_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM user_data WHERE user_id = target_user_id;
  DELETE FROM activity_logs WHERE user_id = target_user_id;
  UPDATE auth.users 
  SET email = 'deleted@example.com', 
      raw_user_meta_data = '{}'
  WHERE id = target_user_id;
END;
$$;
```

**CCPA (California):**

```sql
-- Data export function
CREATE OR REPLACE FUNCTION export_user_data(target_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_export JSONB;
BEGIN
  SELECT jsonb_build_object(
    'profile', (SELECT row_to_json(p) FROM profiles p WHERE user_id = target_user_id),
    'orders', (SELECT json_agg(o) FROM orders o WHERE user_id = target_user_id),
    'activity', (SELECT json_agg(a) FROM activity_logs a WHERE user_id = target_user_id)
  ) INTO user_export;
  
  RETURN user_export;
END;
$$;
```

**Data residency verification:**

```sql
-- Track data location
CREATE TABLE data_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT,
  record_id UUID,
  region TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit trigger
CREATE OR REPLACE FUNCTION audit_data_location()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO data_audit (table_name, record_id, region)
  VALUES (
    TG_TABLE_NAME,
    NEW.id,
    current_setting('app.deployment_region', true)
  );
  RETURN NEW;
END;
$$;
```

### Internationalization (i18n)

Store and query multi-language content:

```sql
-- Translation table pattern
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sku TEXT UNIQUE NOT NULL,
  price DECIMAL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE product_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES products NOT NULL,
  language_code TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  UNIQUE(product_id, language_code)
);

CREATE INDEX product_translations_lang_idx 
ON product_translations(language_code);

-- Query with language preference
CREATE OR REPLACE FUNCTION get_products_i18n(preferred_lang TEXT, fallback_lang TEXT DEFAULT 'en')
RETURNS TABLE (
  id UUID,
  sku TEXT,
  price DECIMAL,
  name TEXT,
  description TEXT
)
LANGUAGE sql STABLE
AS $$
  SELECT 
    p.id,
    p.sku,
    p.price,
    COALESCE(pt_pref.name, pt_fall.name) as name,
    COALESCE(pt_pref.description, pt_fall.description) as description
  FROM products p
  LEFT JOIN product_translations pt_pref 
    ON pt_pref.product_id = p.id 
    AND pt_pref.language_code = preferred_lang
  LEFT JOIN product_translations pt_fall 
    ON pt_fall.product_id = p.id 
    AND pt_fall.language_code = fallback_lang;
$$;
```

Application code:

```javascript
async function getProducts(language) {
  const { data } = await supabase
    .rpc('get_products_i18n', {
      preferred_lang: language,
      fallback_lang: 'en'
    })
  
  return data
}

// Usage
const products = await getProducts('es')  // Spanish with English fallback
```

**JSONB translation pattern:**

```sql
-- Alternative: translations in JSONB
CREATE TABLE products (
  id UUID PRIMARY KEY,
  sku TEXT,
  price DECIMAL,
  translations JSONB  -- {"en": {"name": "...", "desc": "..."}, "es": {...}}
);

-- Query function
CREATE OR REPLACE FUNCTION get_translation(translations JSONB, lang TEXT, field TEXT, fallback TEXT DEFAULT 'en')
RETURNS TEXT
LANGUAGE sql IMMUTABLE
AS $$
  SELECT COALESCE(
    translations->lang->>field,
    translations->fallback->>field
  );
$$;

-- Usage
SELECT 
  id,
  sku,
  get_translation(translations, 'es', 'name') as name,
  get_translation(translations, 'es', 'description') as description
FROM products;
```

### Locale-Specific Formatting

Handle currency, dates, numbers:

```sql
-- Store prices in base currency
CREATE TABLE products (
  id UUID PRIMARY KEY,
  name TEXT,
  price_usd DECIMAL NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Currency conversion table
CREATE TABLE exchange_rates (
  currency_code TEXT PRIMARY KEY,
  rate_to_usd DECIMAL NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert prices
CREATE OR REPLACE FUNCTION convert_price(amount_usd DECIMAL, target_currency TEXT)
RETURNS DECIMAL
LANGUAGE sql STABLE
AS $$
  SELECT amount_usd * rate_to_usd
  FROM exchange_rates
  WHERE currency_code = target_currency;
$$;

-- Format for display (client-side)
```

```javascript
// Client-side formatting
function formatPrice(amount, currency, locale) {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency: currency
  }).format(amount)
}

// Usage
const { data: products } = await supabase
  .from('products')
  .select('*, price_eur:convert_price(price_usd, "EUR")')

products.forEach(p => {
  console.log(formatPrice(p.price_eur, 'EUR', 'de-DE'))
})
```

### Time Zone Handling

PostgreSQL stores TIMESTAMPTZ in UTC, displays in session timezone:

```sql
-- Always use TIMESTAMPTZ for time-aware columns
CREATE TABLE events (
  id UUID PRIMARY KEY,
  name TEXT,
  scheduled_at TIMESTAMPTZ NOT NULL,  -- Stores in UTC
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Query in specific timezone
SET timezone = 'America/New_York';
SELECT scheduled_at FROM events;  -- Displays in EST/EDT

-- Convert timezone in query
SELECT 
  scheduled_at,
  scheduled_at AT TIME ZONE 'Asia/Tokyo' as tokyo_time,
  scheduled_at AT TIME ZONE 'Europe/London' as london_time
FROM events;

-- Filter by local date
SELECT * FROM events
WHERE (scheduled_at AT TIME ZONE 'America/Los_Angeles')::DATE = '2025-10-15';
```

Application code:

```javascript
// Store dates in ISO format (UTC)
const { data } = await supabase
  .from('events')
  .insert({
    name: 'Conference',
    scheduled_at: new Date('2025-12-15T14:00:00Z').toISOString()
  })

// Display in user's timezone (automatic in browser)
const event = data[0]
const localTime = new Date(event.scheduled_at)
console.log(localTime.toLocaleString('en-US', { 
  timeZone: 'America/New_York' 
}))
```

## Enterprise Features

[Unverified] Enterprise features require Supabase Enterprise plan. Availability and specific features may vary. Contact Supabase sales for accurate information.

### Enterprise Authentication

**SAML SSO:** Configure enterprise SSO through Supabase dashboard under Authentication → Providers → SAML 2.0.

```javascript
// Initiate SAML login
const { data, error } = await supabase.auth.signInWithSSO({
  domain: 'company.com'
})

// Or with provider
const { data, error } = await supabase.auth.signInWithSSO({
  providerId: 'uuid-of-saml-provider'
})
```

**SCIM provisioning:** [Unverified] SCIM (System for Cross-domain Identity Management) may be available for automated user provisioning from identity providers like Okta, Azure AD.

**Advanced MFA:**

```javascript
// Enforce MFA
const { data } = await supabase.auth.mfa.enroll({
  factorType: 'totp'
})

// Challenge MFA
const { data: verified } = await supabase.auth.mfa.challenge({
  factorId: data.id
})
```

### Role-Based Access Control (RBAC)

Advanced permission systems:

```sql
-- Custom roles beyond RLS
CREATE ROLE app_admin;
CREATE ROLE app_manager;
CREATE ROLE app_user;

-- Grant schema permissions
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_user;
GRANT INSERT, UPDATE ON specific_table TO app_manager;
GRANT ALL ON ALL TABLES IN SCHEMA public TO app_admin;

-- Row-level policies with roles
CREATE POLICY "Managers see all departments"
ON employees FOR SELECT
TO app_manager
USING (true);

CREATE POLICY "Users see own department"
ON employees FOR SELECT
TO app_user
USING (department_id = auth.user_department_id());
```

### Audit Logging

Comprehensive activity tracking:

```sql
-- Audit table
CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID,
  action TEXT NOT NULL,
  table_name TEXT,
  record_id UUID,
  old_data JSONB,
  new_data JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Generic audit trigger
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO audit_log (
    user_id,
    action,
    table_name,
    record_id,
    old_data,
    new_data,
    ip_address
  ) VALUES (
    auth.uid(),
    TG_OP,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD) END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) END,
    inet_client_addr()
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Apply to sensitive tables
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger();
```

### Service Level Agreements

[Unverified] Enterprise plans typically include:

- 99.9%+ uptime SLA
- Dedicated support channels
- Custom backup retention
- Priority incident response
- Custom rate limits

### Dedicated Infrastructure

[Unverified] Enterprise customers may access:

- Dedicated compute resources
- Custom database instance sizing
- Reserved connection pools
- Isolated network configurations

### Advanced Security

**IP allowlisting:** Configure through dashboard or support to restrict database access to specific IP ranges.

**SOC 2 compliance:** [Unverified] Supabase infrastructure maintains SOC 2 Type II certification. Enterprise customers receive compliance documentation.

**Custom encryption:**

```sql
-- pgcrypto for field-level encryption
CREATE EXTENSION pgcrypto;

-- Encrypt sensitive data
CREATE TABLE user_secrets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  encrypted_data BYTEA,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Encrypt
INSERT INTO user_secrets (user_id, encrypted_data)
VALUES (
  auth.uid(),
  pgp_sym_encrypt('sensitive data', current_setting('app.encryption_key'))
);

-- Decrypt
SELECT pgp_sym_decrypt(encrypted_data, current_setting('app.encryption_key'))
FROM user_secrets
WHERE user_id = auth.uid();
```

**Related topics for further exploration:**

- Database migration strategies from other platforms to Supabase
- Performance optimization for large-scale applications
- Custom authentication flows and JWT handling
- Real-time subscriptions architecture and scaling
- Storage bucket policies and CDN configuration

---

