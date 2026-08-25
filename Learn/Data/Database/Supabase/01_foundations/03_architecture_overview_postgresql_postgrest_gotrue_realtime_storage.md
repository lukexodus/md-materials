## Architecture overview: PostgreSQL, PostgREST, GoTrue, Realtime, Storage


Supabase is not a monolithic platform but rather a curated suite of open-source tools that work together seamlessly. Understanding each component helps you leverage the full power of the platform.

### PostgreSQL (Database Core)

PostgreSQL serves as the foundation of Supabase. Every Supabase project gets a dedicated PostgreSQL database instance.

**What it provides:**

- **Relational data storage** with tables, rows, columns
- **ACID transactions** ensuring data consistency
- **Advanced data types**: JSON/JSONB, arrays, ranges, geometric types, custom types
- **Full-text search** capabilities
- **Triggers and functions** for business logic at the database level
- **Views and materialized views** for complex queries
- **Extensions ecosystem**: PostGIS (geospatial), pg_cron (scheduling), pgvector (vector embeddings), etc.
- **Row Level Security (RLS)** for fine-grained access control
- **Foreign keys and constraints** for data integrity
- **Indexes** for query performance

**Version:** [Inference] Supabase typically runs recent PostgreSQL versions (14, 15, or newer), but the exact version depends on when the project was created and platform updates.

**Direct access:** You can connect to your PostgreSQL database using any PostgreSQL client (psql, pgAdmin, DBeaver) using the connection string provided in the dashboard.

### PostgREST (API Layer)

PostgREST is an open-source web server that automatically generates a RESTful API from your PostgreSQL database schema. When you create or modify tables in Supabase, the API endpoints update automatically.

**How it works:**

- Reads your database schema (tables, views, functions)
- Creates REST endpoints for each table/view
- Maps HTTP methods to SQL operations:
    - GET → SELECT
    - POST → INSERT
    - PATCH → UPDATE
    - DELETE → DELETE
- Translates URL query parameters into SQL queries
- Respects Row Level Security policies

**Example mapping:**

```
Table: posts
Endpoint: /rest/v1/posts

GET /posts → SELECT * FROM posts
GET /posts?id=eq.1 → SELECT * FROM posts WHERE id = 1
POST /posts → INSERT INTO posts
PATCH /posts?id=eq.1 → UPDATE posts WHERE id = 1
DELETE /posts?id=eq.1 → DELETE FROM posts WHERE id = 1
```

**Features:**

- **Filtering**: eq, neq, gt, lt, gte, lte, like, ilike, in, is, etc.
- **Ordering**: order=column.asc or order=column.desc
- **Pagination**: limit and offset
- **Resource embedding**: Foreign key relationships automatically available
- **Stored procedures**: Call database functions via RPC
- **Bulk operations**: Insert/update/delete multiple rows
- **Response shaping**: Select specific columns, rename fields

**Security:** PostgREST enforces RLS policies, so users only access data they're permitted to see.

### GoTrue (Authentication)

GoTrue is Supabase's authentication service, handling user registration, login, session management, and identity verification.

**Authentication methods supported:**

- **Email/password**: Traditional sign-up with email verification
- **Magic links**: Passwordless email-based login
- **Phone/SMS**: OTP (one-time password) authentication
- **OAuth providers**: Google, GitHub, GitLab, Bitbucket, Azure, Facebook, Discord, Twitch, Slack, Spotify, Apple, and more
- **SAML SSO**: Enterprise single sign-on (paid plans)
- **Anonymous users**: Temporary users that can convert to permanent

**Core concepts:**

**User object**: Contains user metadata (email, phone, created_at, etc.) and custom metadata

```json
{
  "id": "uuid",
  "email": "user@example.com",
  "user_metadata": { "name": "John" },
  "app_metadata": { "role": "admin" },
  "created_at": "timestamp"
}
```

**Session**: JWT (JSON Web Token) that proves user identity, includes access_token and refresh_token

**JWT structure**: Contains user ID, email, role, and custom claims that RLS policies can reference

**Session management:**

- Sessions expire after a configurable period (default 1 hour)
- Refresh tokens used to get new access tokens
- Automatic token refresh handled by Supabase client
- Multi-device session support

**Security features:**

- **Email confirmation** required before access (configurable)
- **Password strength** requirements configurable
- **Rate limiting** on auth endpoints
- **PKCE flow** for OAuth (prevents authorization code interception)
- **MFA/2FA** via TOTP (time-based one-time passwords)

**User metadata:**

- **user_metadata**: User-controlled data (profile info)
- **app_metadata**: Admin-controlled data (roles, permissions)

GoTrue integrates directly with PostgreSQL's `auth.users` table and provides helper functions like `auth.uid()` for RLS policies.

### Realtime (Subscriptions)

Supabase Realtime enables applications to listen to database changes, send messages between clients, and track user presence—all over WebSocket connections.

**Three main features:**

**Database Changes (Postgres Changes):**

- Subscribe to INSERT, UPDATE, DELETE events on specific tables
- Filter subscriptions (e.g., only rows where user_id matches)
- Receive the old and new values for updates
- Based on PostgreSQL's logical replication

**How it works:**

1. PostgreSQL Write-Ahead Log (WAL) captures all database changes
2. Realtime server reads WAL via logical replication
3. Changes broadcast to subscribed WebSocket clients
4. RLS policies enforced (users only receive changes they can see)

**Broadcast (PubSub):**

- Send messages between clients without database persistence
- Useful for temporary events (typing indicators, cursor positions)
- Lower latency than database changes
- Messages not stored

**Presence:**

- Track which users are currently online
- Synchronize state across clients (e.g., who's viewing a document)
- Automatic cleanup when users disconnect
- Useful for collaborative features

**Configuration:**

- Must enable Realtime replication for specific tables in dashboard
- Set publication to include INSERT/UPDATE/DELETE events
- Consider performance impact on high-traffic tables

**Use cases:**

- Live chat applications
- Collaborative editing
- Real-time dashboards
- Gaming leaderboards
- Social media feeds
- Notifications

**Limitations:**

- [Inference] Realtime has connection limits depending on your plan
- High-frequency updates may impact performance
- Message size limits apply to Broadcast

### Storage (File Storage)

Supabase Storage provides object storage for files (images, videos, documents, etc.) with built-in integration with the authentication and database systems.

**Core concepts:**

**Buckets**: Containers for organizing files, similar to AWS S3 buckets

- **Public buckets**: Files accessible via URL without authentication
- **Private buckets**: Files require authentication and authorization

**File operations:**

- **Upload**: Single or multipart uploads
- **Download**: Direct download or signed URLs for private files
- **List**: Browse files and folders
- **Delete**: Remove files
- **Move**: Rename or relocate files
- **Copy**: Duplicate files

**Signed URLs**: Temporary URLs for accessing private files

- Expire after specified duration
- Useful for sharing protected content
- No need to expose permanent URLs

**Image transformations**: Automatic on-the-fly image processing

- Resize: width, height
- Quality adjustment
- Format conversion (WebP, AVIF)
- URL-based parameters

**Example:**

```
https://project.supabase.co/storage/v1/object/public/avatars/image.jpg?width=300&height=300
```

**Storage policies**: Similar to RLS but for files

- Control who can upload, download, update, delete files
- Reference user authentication state
- Apply different rules per bucket or path

**Example policy:**

```sql
-- Users can only access their own folder
CREATE POLICY "User folder access"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'private' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

**CDN integration**: Files served through CDN for fast global delivery

**File size limits**: [Inference] Typically 50MB per file on free tier, higher on paid plans

**Storage quotas**: Based on subscription plan (1GB free, scaling up on paid tiers)

**MIME type detection**: Automatic content-type setting based on file extension

**Architecture benefits:**

- Integrated auth (files respect user permissions)
- Database metadata (store file info in PostgreSQL)
- Realtime events (subscribe to upload/delete events)
- Consistent SDK (same client for database, auth, and storage)

### How components work together

**Example user registration and profile flow:**

1. User submits registration form
2. **GoTrue** creates user account and sends verification email
3. **PostgreSQL** stores user in `auth.users` table
4. User clicks verification link
5. **GoTrue** marks email as verified
6. User uploads profile picture
7. **Storage** saves file in avatars bucket (after checking storage policies)
8. **PostgreSQL** stores file metadata and reference in `profiles` table
9. **PostgREST** provides API to fetch user profile with avatar URL
10. **Realtime** notifies connected clients that profile updated

**Data flow diagram [Inference]:**

```
Client Application
       ↓↑
JavaScript Client (supabase-js)
       ↓↑
    ┌──────────────────────────────┐
    │   Supabase Platform          │
    │                              │
    │  PostgREST ←→ PostgreSQL     │
    │  GoTrue ←→ auth schema       │
    │  Realtime ←→ WAL             │
    │  Storage ←→ storage schema   │
    └──────────────────────────────┘
```

This architecture provides:

- **Separation of concerns**: Each tool does one thing well
- **Interoperability**: Components share authentication and authorization
- **Flexibility**: Can use parts independently
- **Standards-based**: Built on PostgreSQL, REST, JWT standards

