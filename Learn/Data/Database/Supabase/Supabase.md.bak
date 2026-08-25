# Comprehensive Supabase Learning Syllabus

## Module 1: Foundations

- What is Supabase and its core philosophy
- Supabase vs other Backend-as-a-Service platforms
- Architecture overview: PostgreSQL, PostgREST, GoTrue, Realtime, Storage
- Setting up a Supabase account
- Understanding the Supabase Dashboard
- Project creation and configuration
- Supabase CLI installation and setup

## Module 2: PostgreSQL Database Fundamentals

- PostgreSQL basics in Supabase context
- Creating and managing tables
- Data types and constraints
- Primary keys and foreign keys
- Indexes and performance optimization
- Database migrations
- SQL Editor usage
- Table relationships (one-to-one, one-to-many, many-to-many)
- Views and materialized views
- Database functions and triggers

## Module 3: Authentication (GoTrue)

- Authentication concepts and methods
- Email/password authentication
- Magic link authentication
- OAuth providers (Google, GitHub, etc.)
- Phone authentication
- Anonymous users
- Multi-factor authentication (MFA)
- Session management
- User metadata and custom claims
- Password reset flows
- Email confirmation flows
- Server-side vs client-side authentication

## Module 4: Row Level Security (RLS)

- Understanding RLS concepts
- Enabling RLS on tables
- Writing RLS policies
- Policy expressions and conditions
- User roles and permissions
- Helper functions for RLS (auth.uid(), auth.jwt())
- Common RLS patterns
- Testing RLS policies
- Debugging RLS issues
- Performance considerations with RLS

## Module 5: Supabase Client Libraries

- JavaScript/TypeScript client installation
- Client initialization and configuration
- Environment variables and API keys
- Client-side vs server-side usage
- Service role vs anon key
- Error handling patterns
- TypeScript type generation
- Other language clients (Python, Dart, etc.)

## Module 6: Database Queries (CRUD Operations)

- SELECT queries and filtering
- INSERT operations
- UPDATE operations
- DELETE operations
- Ordering and pagination
- Filtering operators (eq, neq, gt, lt, like, ilike, etc.)
- Full-text search
- Joins and nested queries
- Aggregations and grouping
- Returning data from mutations
- Bulk operations

## Module 7: Realtime

- Realtime concepts and use cases
- Subscribing to database changes
- Broadcast channels
- Presence tracking
- Realtime filtering
- Performance and scaling considerations
- Unsubscribing and cleanup
- Realtime with RLS
- Custom events via Broadcast
- Conflict resolution strategies

## Module 8: Storage

- Storage buckets creation and management
- Public vs private buckets
- Uploading files
- Downloading files
- Listing files
- Deleting files
- File transformations (images)
- Storage policies and RLS
- Signed URLs
- File size limits and quotas
- CDN and caching

## Module 9: Edge Functions

- Serverless functions overview
- Creating Edge Functions
- Deploying Edge Functions
- Function runtime and environment
- Invoking functions from client
- Function secrets and environment variables
- CORS handling
- Database access from functions
- Third-party API integration
- Background jobs and scheduled functions
- Error handling and logging

## Module 10: Database Functions & Triggers

- Writing PostgreSQL functions
- Function languages (PL/pgSQL, SQL)
- Trigger creation and types
- Before vs after triggers
- Row-level vs statement-level triggers
- Using functions with RPC calls
- Stored procedures best practices
- Function performance optimization

## Module 11: API & PostgREST

- Auto-generated REST API
- API endpoint structure
- Query parameters
- Response formats
- Computed columns
- Resource embedding
- API rate limits
- Custom API routes via functions
- OpenAPI documentation

## Module 12: Advanced Queries

- Complex joins
- Subqueries
- Common Table Expressions (CTEs)
- Window functions
- Recursive queries
- JSON/JSONB operations
- Array operations
- Full-text search with tsvector
- Fuzzy matching
- Geospatial queries (PostGIS)

## Module 13: Performance Optimization

- Query performance analysis
- Index strategies
- Connection pooling
- Caching strategies
- Database statistics
- EXPLAIN and query plans
- N+1 query problems
- Batch operations
- Read replicas (enterprise)
- Database size management

## Module 14: Security Best Practices

- API key management
- RLS policy design
- Input validation
- SQL injection prevention
- XSS protection
- CORS configuration
- Rate limiting
- Audit logging
- Secrets management
- Secure file uploads

## Module 15: Testing

- Unit testing database functions
- Testing RLS policies
- Integration testing with Supabase
- Mocking Supabase client
- Test database setup
- Seed data management
- CI/CD integration
- Testing Edge Functions

## Module 16: Migrations & Version Control

- Database migration strategies
- Migration file creation
- Schema versioning
- Forward and backward migrations
- Data migrations
- Migration rollback strategies
- Team collaboration workflows
- Branching and preview environments

## Module 17: Monitoring & Debugging

- Dashboard metrics and analytics
- Query performance monitoring
- Log inspection
- Error tracking
- Database health monitoring
- Connection monitoring
- Storage usage tracking
- Function execution logs
- Third-party monitoring tools integration

## Module 18: Framework Integration

- Next.js integration patterns
- React integration
- Vue.js integration
- Svelte integration
- React Native mobile apps
- Flutter integration
- Server-side rendering considerations
- Static site generation

## Module 19: Production Deployment

- Environment management (dev, staging, prod)
- Custom domains
- SSL/TLS configuration
- Backup strategies
- Point-in-time recovery
- Disaster recovery planning
- Scaling considerations
- Cost optimization
- Monitoring production health

## Module 20: Advanced Topics

- Database extensions (pg_cron, pgvector, etc.)
- Full-text search with extensions
- Vector embeddings for AI/ML
- Multi-tenancy patterns
- Webhooks and event-driven architecture
- GraphQL with pg_graphql
- Custom PostgreSQL configurations
- Database replication
- International considerations (regions, compliance)
- Enterprise features

## Module 21: Real-World Projects

- Authentication system implementation
- Blog/CMS application
- Real-time chat application
- E-commerce platform
- Social media application
- File sharing platform
- Dashboard/analytics application
- Multi-tenant SaaS application

---

# Foundations

## What is Supabase and its core philosophy

Supabase is an open-source Backend-as-a-Service (BaaS) platform that provides developers with a complete backend infrastructure for building applications. It positions itself as "the open source Firebase alternative" and is built on top of enterprise-grade open-source tools rather than proprietary technology.

**Key points:**

- **Open Source First**: All Supabase tools are open source, allowing self-hosting and community contributions. The codebase is available on GitHub under permissive licenses.
    
- **PostgreSQL Foundation**: Unlike many BaaS platforms that use proprietary databases, Supabase is built entirely on PostgreSQL, the world's most advanced open-source relational database. This means you get full SQL capabilities, ACID compliance, and decades of PostgreSQL ecosystem tools.
    
- **Developer Experience Focus**: Supabase emphasizes excellent developer experience with auto-generated APIs, type-safe clients, comprehensive documentation, and intuitive dashboards.
    
- **No Vendor Lock-in**: Since it's built on standard technologies (PostgreSQL, PostgREST, etc.), you can export your data and migrate away if needed. You can also self-host the entire stack.
    
- **Batteries Included**: Provides authentication, database, storage, realtime subscriptions, and edge functions out of the box—everything needed for modern applications.
    
- **SQL-First Approach**: Rather than hiding the database behind abstractions, Supabase embraces SQL and PostgreSQL features, giving developers full database power.
    

The core philosophy centers around:

1. **Openness and transparency** over proprietary lock-in
2. **Standard technologies** over custom solutions
3. **Developer empowerment** over hand-holding abstractions
4. **Full database access** over limited query languages

## Supabase vs other Backend-as-a-Service platforms

### Supabase vs Firebase

**Database:**

- **Supabase**: PostgreSQL (relational, SQL-based, ACID compliant, supports complex queries, joins, transactions, views, triggers, functions)
- **Firebase**: Firestore/Realtime Database (NoSQL, document-based, limited querying, no joins, eventual consistency)

**Data Structure:**

- **Supabase**: Structured schemas with relationships, foreign keys, constraints
- **Firebase**: Denormalized, nested JSON documents

**Querying:**

- **Supabase**: Full SQL with complex joins, aggregations, CTEs, window functions
- **Firebase**: Limited to simple filters, cannot join collections

**Open Source:**

- **Supabase**: Fully open source, self-hostable
- **Firebase**: Proprietary Google service, cannot self-host

**Pricing Model:**

- **Supabase**: Predictable compute-based pricing, generous free tier with 500MB database, 1GB file storage, 2GB bandwidth
- **Firebase**: Pay-per-operation model that can become expensive with high read/write volumes

**Realtime:**

- **Supabase**: Database change subscriptions, broadcast, presence
- **Firebase**: Document listeners, realtime database

**Vendor Lock-in:**

- **Supabase**: Easy migration (standard PostgreSQL dump/restore)
- **Firebase**: Difficult migration (proprietary format, complex data export)

### Supabase vs AWS Amplify

**Complexity:**

- **Supabase**: Single platform, unified dashboard, straightforward setup
- **Amplify**: Wrapper around multiple AWS services (AppSync, Cognito, DynamoDB, S3), steeper learning curve

**Database:**

- **Supabase**: PostgreSQL with full SQL access
- **Amplify**: DynamoDB (NoSQL) or Aurora Serverless (limited direct access through AppSync)

**API Generation:**

- **Supabase**: Auto-generated RESTful API via PostgREST
- **Amplify**: GraphQL via AWS AppSync (must define schema)

**Configuration:**

- **Supabase**: Web dashboard and SQL migrations
- **Amplify**: CloudFormation templates, CLI configuration, multiple config files

**Cost:**

- **Supabase**: Transparent, project-based pricing
- **Amplify**: Multiple AWS service costs that can be complex to predict

### Supabase vs Hasura

**Primary Function:**

- **Supabase**: Complete BaaS with auth, storage, functions, realtime
- **Hasura**: GraphQL engine focused primarily on API generation

**API Type:**

- **Supabase**: REST (PostgREST) with optional GraphQL
- **Hasura**: GraphQL-first

**Authentication:**

- **Supabase**: Built-in GoTrue auth with multiple providers
- **Hasura**: Requires external auth service integration

**Storage:**

- **Supabase**: Built-in file storage with transformations
- **Hasura**: No built-in storage (requires external solution)

**Managed Service:**

- **Supabase**: Fully managed database hosting included
- **Hasura**: Engine only, must provide your own PostgreSQL database

**Target Audience:**

- **Supabase**: Full-stack developers wanting complete backend
- **Hasura**: Teams needing GraphQL layer over existing databases

### Supabase vs PlanetScale

**Database Type:**

- **Supabase**: PostgreSQL
- **PlanetScale**: MySQL (Vitess)

**Scope:**

- **Supabase**: Complete BaaS (database + auth + storage + functions + realtime)
- **PlanetScale**: Database-only service

**Branching:**

- **Supabase**: Branch environments (paid feature)
- **PlanetScale**: Git-like database branching built-in

**Realtime:**

- **Supabase**: Native realtime subscriptions
- **PlanetScale**: No built-in realtime (requires external solution)

**Features:**

- **Supabase**: Auth, Storage, Edge Functions, Row Level Security
- **PlanetScale**: Focus on database scaling, connection pooling, schema management

### Supabase vs Appwrite

**Similarities:**

- Both are open-source Firebase alternatives
- Both provide auth, database, storage, functions
- Both can be self-hosted

**Database:**

- **Supabase**: PostgreSQL with full SQL access
- **Appwrite**: MariaDB with document-style API (abstracts SQL away)

**API Style:**

- **Supabase**: Auto-generated REST from database schema
- **Appwrite**: SDK-based with predefined methods

**Database Access:**

- **Supabase**: Direct SQL queries, full PostgreSQL features
- **Appwrite**: Limited to SDK methods, less direct database control

**Maturity:**

- **Supabase**: More mature, larger community, better funding
- **Appwrite**: Newer, growing community

**Philosophy:**

- **Supabase**: SQL-first, embrace database complexity
- **Appwrite**: Simplification, hide database complexity

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

## Setting up a Supabase account

**Step-by-step account creation:**

1. **Visit the Supabase website:**
    
    - Navigate to https://supabase.com
    - Click "Start your project" or "Sign up" button
2. **Choose authentication method:**
    
    - **GitHub**: OAuth with GitHub account (recommended for developers)
    - **Email**: Traditional email/password signup
    - **Google**: OAuth with Google account
    - **Azure**: Enterprise SSO option
3. **Authenticate:**
    
    - If using GitHub: Authorize Supabase to access your profile
    - If using email: Enter email and password, verify email address
    - Complete any required verification steps
4. **Account creation:**
    
    - Automatically redirects to Supabase dashboard
    - Account immediately active and ready for project creation

**Account settings and configuration:**

**Profile settings:**

- Display name
- Avatar/profile picture
- Email address (for notifications)
- Password management (if using email auth)

**Organization management:**

- Default personal organization created automatically
- Can create additional organizations for team collaboration
- Organization billing is separate from personal billing
- Members can have different roles (Owner, Admin, Developer)

**Billing setup:**

- Free tier available without credit card
- Upgrade to Pro or Team tier for additional resources
- Add payment method for paid plans
- View usage and billing history

**API access:**

- Personal access tokens for CLI and API access
- Manage tokens in account settings
- Tokens have organization-level permissions

**Security settings:**

- Two-factor authentication (2FA) setup
- Connected accounts management
- Active sessions review
- Security log access

**Free tier limitations [Inference based on typical offering]:**

- 2 organizations
- Unlimited projects (paused after 7 days of inactivity)
- 500MB database space per project
- 1GB file storage per project
- 2GB bandwidth per month
- 50MB file upload size
- 2 CPU cores, 1GB RAM per project
- Email support via community

**Paid tier benefits [Inference]:**

- Higher database storage (8GB+ depending on plan)
- Increased bandwidth and file storage
- No project pausing
- Daily backups (7 day retention)
- Email support with SLA
- Additional compute resources
- Custom domains
- Advanced features (PITR, read replicas, etc.)

## Understanding the Supabase Dashboard

The Supabase Dashboard is the web-based control panel for managing all aspects of your projects. It's divided into several main sections:

### Organization-level navigation

**Top-left menu:**

- **Organization selector**: Switch between different organizations
- **Project list**: View all projects in current organization
- **New project**: Create new Supabase project
- **Organization settings**: Manage members, billing, settings

**Top-right menu:**

- **Documentation link**: Quick access to docs
- **Community/Support**: Discord, forums, support tickets
- **Account menu**: Profile, settings, sign out

### Project-level navigation (Left sidebar)

Once inside a project, the left sidebar contains:

**Home (Dashboard):**

- Project overview and quick stats
- Recent activity
- Quick links to common tasks
- API keys and project URL
- Database connection strings

**Table Editor:**

- Visual interface for creating and editing tables
- Spreadsheet-like data editing
- Add/remove columns
- Set column types and constraints
- Foreign key relationship visualization
- Bulk import/export CSV
- View table statistics

**Key features:**

- Click on cell to edit inline
- Add rows with "+" button
- Filter and sort data
- Search across table data
- Clone tables
- View SQL for operations

**SQL Editor:**

- Write and execute custom SQL queries
- Save frequently used queries
- Query history
- Templates for common operations
- Keyboard shortcuts
- Results displayed in table format
- Export query results
- Share queries with team

**Database:**

Several sub-sections:

**Tables**: List all tables with schemas, relationships **Triggers**: View and manage database triggers **Functions**: List PostgreSQL functions, create new ones **Extensions**: Enable PostgreSQL extensions (PostGIS, pg_cron, pgvector, etc.) **Roles**: Manage database roles (typically not needed for basic usage) **Replication**: Configure replication settings for Realtime **Webhooks**: Set up database webhooks (paid feature) **Backups**: Configure and restore backups (paid feature) **Migrations**: View and manage migration history

**Authentication:**

**Users**: List and manage authenticated users

- Search and filter users
- View user metadata
- Manually delete or ban users
- Send password reset emails
- Add users manually

**Policies**: Manage Row Level Security policies

- View policies per table
- Create new policies
- Test policy expressions
- Policy templates

**Providers**: Configure OAuth providers

- Enable/disable providers (Google, GitHub, etc.)
- Add client ID and secret
- Configure redirect URLs
- Test provider connections

**Email Templates**: Customize auth emails

- Confirmation emails
- Reset password emails
- Magic link emails
- Invitation emails
- Variable substitution

**Settings**: Auth configuration

- Site URL configuration
- JWT expiry settings
- Email confirmation requirements
- Password strength requirements
- Rate limiting settings

**Storage:**

**Buckets**: List and manage storage buckets

- Create public/private buckets
- View bucket usage statistics
- Configure bucket policies
- Delete buckets

**Policies**: Storage-level access policies

- Define who can upload/download
- Path-based rules
- Integration with auth.uid()

**Settings**: Storage configuration

- File size limits
- Allowed MIME types

**Edge Functions:**

**Functions list**: All deployed functions **Deploy new function**: Upload function code **Function logs**: Execution logs and errors **Function settings**: Environment variables, secrets

**Project Settings:**

**General**: Project name, reference ID, region, pause/delete project **Database**: Connection pooler settings, connection strings **API**: API keys (anon, service_role), JWT settings **Auth**: Advanced auth settings **Storage**: Advanced storage settings **Billing**: Plan details, usage metrics, upgrade options **Team**: Invite collaborators, manage roles **Integrations**: Third-party integrations (Vercel, GitHub, etc.)

### Key dashboard features

**API Keys display:** Located on Home page and Settings → API:

- **anon (public) key**: Safe to use in client-side code, respects RLS
- **service_role key**: Full database access, must keep secret, use server-side only

**Project URL:** Your unique project endpoint (e.g., `https://projectref.supabase.co`)

**Connection strings:**

- PostgreSQL direct connection (for database clients)
- Connection pooler (for serverless functions)
- Session mode vs Transaction mode

**Quick actions:**

- Generate TypeScript types from database schema
- Copy project credentials
- View documentation for specific features
- Access logs and monitoring

**Usage metrics:**

- Database size
- Bandwidth usage
- Storage usage
- API requests
- Active connections
- Function invocations

**Activity log:** Track recent changes to project configuration and schema

## Project creation and configuration

### Creating a new project

**Starting a new project:**

1. Click **"New project"** button in dashboard
2. Select organization (personal or team)
3. Fill in project details:

**Project Name:**

- Human-readable name for identification
- Can be changed later
- Shows in dashboard project list

**Database Password:**

- Strong password for PostgreSQL database access
- Store securely (needed for direct database connections)
- Cannot be recovered if lost (must reset)
- Minimum password requirements enforced

**Region:**

- Choose geographic location closest to your users
- Available regions typically include:
    - North America: US East (Virginia), US West (Oregon)
    - Europe: Germany, Ireland
    - Asia: Singapore, Australia, India
    - South America: São Paulo
- **Cannot be changed after creation** [Inference]
- Affects latency and data residency compliance

**Pricing Plan:**

- Free tier (default)
- Pro tier
- Team tier
- Enterprise tier
- Can upgrade/downgrade later

4. Click **"Create new project"**
5. Wait for provisioning (typically 1-2 minutes)
6. Project ready with database, API, and services active

### Initial project configuration

**After project creation, configure:**

**Database connection:**

- Note the connection strings from Settings → Database
- Direct connection: `postgresql://postgres:[YOUR-PASSWORD]@db.projectref.supabase.co:5432/postgres`
- Connection pooler: `postgresql://postgres.[YOUR-PASSWORD]@projectref.pooler.supabase.com:6543/postgres`

**API configuration:**

**API keys** (Settings → API):

```
anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Project URL**: `https://projectref.supabase.co`

**Authentication setup** (Authentication → Settings):

**Site URL**:

- Your application URL (e.g., `https://myapp.com`)
- Used for email redirects
- Can add multiple redirect URLs

**JWT Settings:**

- JWT expiry: Default 3600 seconds (1 hour)
- Refresh token rotation: Enable for security
- JWT secret: Auto-generated, visible in API settings

**Email settings:**

- Use Supabase SMTP (limited, for development)
- Or configure custom SMTP provider
- Customize sender name and email

**Enable auth providers:**

- Go to Authentication → Providers
- Enable desired providers (email, Google, GitHub, etc.)
- Add OAuth credentials from provider dashboards

**Storage configuration:**

Create initial buckets (Storage → Buckets):

- Create "avatars" bucket (public or private)
- Create "documents" bucket (typically private)
- Set up appropriate storage policies

**Database schema initialization:**

Using SQL Editor or Table Editor:

- Create initial tables
- Set up relationships
- Enable Row Level Security
- Create RLS policies
- Add indexes

**Example initial schema:**

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  updated_at TIMESTAMP WITH TIME ZONE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  website TEXT
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Public profiles are viewable by everyone."
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile."
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile."
  ON profiles FOR UPDATE
  USING (auth.uid() = id);
```

### Project settings deep dive

**General settings:**

- **Project name**: Update anytime
- **Organization**: Cannot change after creation
- **Reference ID**: Immutable unique identifier
- **Pause project**: Temporarily disable (free tier only)
- **Delete project**: Permanent removal with confirmation

**Database settings:**

- **Connection pooler**:
    - Transaction mode (recommended for serverless)
    - Session mode (required for certain features)
- **Connection limits**: [Inference] Based on plan tier
- **SSL enforcement**: Always enabled for security
- **IPv6 support**: [Unverified] May vary by region

**API settings:**

- **Auto-generated schema**: Enable/disable auto API generation
- **Request timeout**: Configure API timeout duration
- **Max rows**: Limit maximum rows returned per request
- **Custom claims**: Add custom JWT claims for RLS

**Authentication settings:**

- **Disable email signups**: Force OAuth only
- **Email confirmations**: Require/optional/disable
- **Secure email change**: Require confirmation on new email
- **Auto-confirm users**: Skip email verification (development only)
- **PKCE flow**: Enable for OAuth security
- **Session management**:
    - Maximum concurrent sessions per user
    - Automatic session refresh

**Storage settings:**

- **File size upload limit**: Adjust up to plan maximum
- **Public bucket file serving**: Enable CDN
- **Custom storage backend**: [Unverified] Enterprise feature

**Billing and usage:**

- View current usage metrics
- Set up usage alerts
- Configure billing contacts
- Upgrade/downgrade plans
- Add payment methods

### Environment best practices

**Development workflow:**

**Local development:**

- Create separate "dev" project in Supabase
- Or use Supabase CLI for local development
- Never use production credentials locally

**Staging:**

- Create "staging" project
- Mirror production configuration
- Test migrations before production

**Production:**

- Separate production project
- Stricter access controls
- Enable backups and monitoring
- Configure custom domain
- Set up alerting

**Configuration management:**

- Store project URLs and keys in environment variables
- Never commit credentials to version control
- Use different keys per environment
- Rotate keys periodically

**Example .env structure:**

```
# Development
DEV_SUPABASE_URL=https://devproject.supabase.co
DEV_SUPABASE_ANON_KEY=eyJ...

# Staging
STAGING_SUPABASE_URL=https://stagingproject.supabase.co
STAGING_SUPABASE_ANON_KEY=eyJ...

# Production
PROD_SUPABASE_URL=https://prodproject.supabase.co
PROD_SUPABASE_ANON_KEY=eyJ...
```

## Supabase CLI installation and setup

The Supabase CLI enables local development, database migrations, type generation, and deployment workflows without relying on the dashboard.

### Installation methods

**macOS:**

Using Homebrew (recommended):

```bash
brew install supabase/tap/supabase
```

Verify installation:

```bash
supabase --version
```

**Windows:**

Using Scoop:

```bash
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

Verify installation:

```bash
supabase --version
```

**Linux:**

Using package manager or direct download:

```bash
# Download latest release
wget https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz

# Extract
tar -xzf supabase_linux_amd64.tar.gz

# Move to PATH
sudo mv supabase /usr/local/bin/

# Verify
supabase --version
```

**npm (cross-platform):**

```bash
npm install -g supabase
```

**Updating CLI:**

```bash
# Homebrew
brew upgrade supabase

# Scoop
scoop update supabase

# npm
npm update -g supabase
```

### CLI authentication

**Login to Supabase:**

```bash
supabase login
```

This command:

1. Opens browser for authentication
2. Redirects to Supabase dashboard
3. Generates access token
4. Stores token locally in `~/.supabase/access-token`

**Manual token setup (alternative):**

1. Generate access token in dashboard (Account → Access Tokens)
2. Set environment variable:

```bash
export SUPABASE_ACCESS_TOKEN=your-token-here
```

Or store in `.env` file:

```bash
SUPABASE_ACCESS_TOKEN=your-token-here
```

**Logout:**

```bash
supabase logout
```

### Local development setup

**Initialize project:**

Navigate to your project directory and run:

```bash
supabase init
```

This creates:

- `supabase/` directory structure
- `supabase/config.toml` - configuration file
- `supabase/seed.sql` - seed data
- `supabase/migrations/` - migration files directory

**Start local Supabase:**

```bash
supabase start
```

This command:

- Downloads necessary Docker images (first run only)
- Starts local PostgreSQL database
- Starts local PostgREST API server
- Starts local GoTrue auth server
- Starts local Realtime server
- Starts local Storage server
- Starts Supabase Studio (local dashboard)

**Output provides local URLs:**

```
API URL: http://localhost:54321
GraphQL URL: http://localhost:54321/graphql/v1
DB URL: postgresql://postgres:postgres@localhost:54322/postgres
Studio URL: http://localhost:54323
Inbucket URL: http://localhost:54324
JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Access local Studio:**

Open browser to `http://localhost:54323` to access local Supabase Studio with full dashboard functionality.

**Stop local Supabase:**

```bash
supabase stop
```

**Stop and reset (delete all data):**

```bash
supabase stop --no-backup
```

Or:

```bash
supabase db reset
```

**View local service status:**

```bash
supabase status
```

### Linking to remote projects

**Link CLI to existing Supabase project:**

```bash
supabase link --project-ref your-project-ref
```

Find project ref in dashboard URL: `https://supabase.com/dashboard/project/your-project-ref`

Or list all projects and select:

```bash
supabase link
```

**Prompt asks for:**

- Database password (set during project creation)

**Verify link:**

```bash
supabase projects list
```

**Unlink project:**

```bash
supabase unlink
```

### Database migrations

**Generate migration from database changes:**

After making schema changes in dashboard or local Studio:

```bash
supabase db diff -f migration_name
```

This creates: `supabase/migrations/[timestamp]_migration_name.sql`

**Create empty migration file:**

```bash
supabase migration new migration_name
```

**Apply migrations locally:**

```bash
supabase db reset
```

Or apply specific migration:

```bash
supabase migration up
```

**Push migrations to remote:**

```bash
supabase db push
```

**Pull remote schema to local:**

```bash
supabase db pull
```

**View migration status:**

```bash
supabase migration list
```

**Repair migration history:**

```bash
supabase migration repair [version] --status applied
```

### Type generation

**Generate TypeScript types from database schema:**

```bash
supabase gen types typescript --local > types/supabase.ts
```

Or for remote database:

```bash
supabase gen types typescript --linked > types/supabase.ts
```

For specific schema:

```bash
supabase gen types typescript --schema public --schema auth > types/supabase.ts
```

**Generated types example:**

```typescript
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          username: string | null
          full_name: string | null
          avatar_url: string | null
        }
        Insert: {
          id: string
          username?: string | null
          full_name?: string | null
        }
        Update: {
          username?: string | null
          full_name?: string | null
        }
      }
    }
  }
}
```

**Use in code:**

```typescript
import { Database } from './types/supabase'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient<Database>(url, key)
```

### Edge Functions management

**Create new Edge Function:**

```bash
supabase functions new function-name
```

Creates: `supabase/functions/function-name/index.ts`

**Serve functions locally:**

```bash
supabase functions serve
```

Or specific function:

```bash
supabase functions serve function-name
```

**Deploy function to remote:**

```bash
supabase functions deploy function-name
```

**Deploy all functions:**

```bash
supabase functions deploy
```

**Delete function:**

```bash
supabase functions delete function-name
```

**View function logs:**

```bash
supabase functions logs function-name
```

**Set function secrets:**

```bash
supabase secrets set API_KEY=your-secret-value
```

**List secrets:**

```bash
supabase secrets list
```

**Unset secret:**

```bash
supabase secrets unset API_KEY
```

### Database commands

**Execute SQL file:**

```bash
supabase db execute --file path/to/file.sql
```

**Execute SQL directly:**

```bash
supabase db execute --sql "SELECT * FROM users;"
```

**Dump remote database:**

```bash
supabase db dump -f dump.sql
```

**Dump specific schema:**

```bash
supabase db dump --schema public -f public_dump.sql
```

**Dump data only:**

```bash
supabase db dump --data-only -f data.sql
```

**Connect to local database with psql:**

```bash
supabase db psql
```

**Connect to remote database:**

```bash
supabase db psql --linked
```

### Storage commands

**List storage buckets:**

```bash
supabase storage list
```

**Create bucket:**

```bash
supabase storage create bucket-name
```

**Delete bucket:**

```bash
supabase storage delete bucket-name
```

**List files in bucket:**

```bash
supabase storage ls bucket-name
```

**Upload file:**

```bash
supabase storage cp local-file.txt bucket-name/remote-file.txt
```

**Download file:**

```bash
supabase storage cp bucket-name/remote-file.txt local-file.txt
```

### Configuration file (config.toml)

Located at `supabase/config.toml`, controls local development environment:

**Key sections:**

**Project settings:**

```toml
[project]
project_id = "your-project-ref"
```

**API configuration:**

```toml
[api]
enabled = true
port = 54321
schemas = ["public", "graphql_public"]
extra_search_path = ["public", "extensions"]
max_rows = 1000
```

**Database configuration:**

```toml
[db]
port = 54322
major_version = 15
```

**Authentication configuration:**

```toml
[auth]
enabled = true
site_url = "http://localhost:3000"
additional_redirect_urls = ["http://localhost:3000/auth/callback"]
jwt_expiry = 3600
enable_signup = true

[auth.email]
enable_signup = true
double_confirm_changes = true
enable_confirmations = false

[auth.external.google]
enabled = false
client_id = ""
secret = ""
redirect_uri = "http://localhost:54321/auth/v1/callback"
```

**Storage configuration:**

```toml
[storage]
enabled = true
file_size_limit = "50MiB"
```

**Realtime configuration:**

```toml
[realtime]
enabled = true
```

**Studio configuration:**

```toml
[studio]
enabled = true
port = 54323
```

**Edge Functions configuration:**

```toml
[edge_runtime]
enabled = true
```

**Modify configuration:** Edit `config.toml` and restart local services:

```bash
supabase stop
supabase start
```

### Common CLI workflows

**Daily development workflow:**

1. Start local environment:

```bash
supabase start
```

2. Make schema changes in local Studio (http://localhost:54323)
    
3. Generate migration:
    

```bash
supabase db diff -f add_new_table
```

4. Test migration:

```bash
supabase db reset
```

5. Generate types:

```bash
supabase gen types typescript --local > types/supabase.ts
```

6. Develop application locally
    
7. Stop environment:
    

```bash
supabase stop
```

**Deployment workflow:**

1. Link to remote project:

```bash
supabase link --project-ref your-project-ref
```

2. Push migrations:

```bash
supabase db push
```

3. Deploy Edge Functions:

```bash
supabase functions deploy
```

4. Update production types:

```bash
supabase gen types typescript --linked > types/supabase.ts
```

5. Deploy application code

**Sync local with remote:**

Pull remote schema:

```bash
supabase db pull
```

Pull and create migration:

```bash
supabase db diff -f sync_with_remote --linked
```

**Seed data management:**

Edit `supabase/seed.sql`:

```sql
-- Insert test data
INSERT INTO profiles (id, username, full_name)
VALUES 
  ('uuid-1', 'testuser1', 'Test User 1'),
  ('uuid-2', 'testuser2', 'Test User 2');
```

Apply seeds:

```bash
supabase db reset
```

Or specifically:

```bash
supabase db execute --file supabase/seed.sql
```

### Troubleshooting CLI issues

**Docker not running:**

```
Error: Cannot connect to Docker daemon
```

**Solution:** Start Docker Desktop or Docker daemon

**Port conflicts:**

```
Error: Port 54321 already in use
```

**Solution:** Stop conflicting service or change port in `config.toml`

**Migration conflicts:**

```
Error: migration already applied
```

**Solution:** Repair migration history:

```bash
supabase migration repair [version] --status reverted
```

**Database connection issues:**

```
Error: Failed to connect to database
```

**Solution:** Verify database password, check network connectivity, ensure project is not paused

**Outdated CLI version:**

Update to latest:

```bash
brew upgrade supabase  # macOS
scoop update supabase  # Windows
npm update -g supabase # npm
```

**Reset everything:**

```bash
supabase stop --no-backup
rm -rf supabase/.branches
supabase start
```

**View detailed logs:**

```bash
supabase start --debug
```

**Check service health:**

```bash
docker ps  # View running containers
docker logs supabase_db_[project]  # View database logs
docker logs supabase_kong_[project]  # View API gateway logs
```

### Advanced CLI features

**Database branching** [Inference - paid feature]:

```bash
supabase branches create feature-branch
supabase branches switch feature-branch
supabase branches list
supabase branches delete feature-branch
```

**Testing migrations:**

```bash
supabase test db
```

**Custom PostgreSQL configuration:**

Add to `config.toml`:

```toml
[db.settings]
max_connections = 200
shared_buffers = "256MB"
effective_cache_size = "1GB"
```

**Environment-specific configuration:**

Use multiple config files:

```bash
supabase start --config config.dev.toml
supabase start --config config.prod.toml
```

**Automation and CI/CD:**

Run CLI in CI pipeline:

```bash
# GitHub Actions example
- name: Setup Supabase CLI
  run: npm install -g supabase

- name: Run migrations
  run: supabase db push
  env:
    SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_TOKEN }}
```

**Database snapshots** [Inference]:

```bash
supabase db snapshot create snapshot-name
supabase db snapshot list
supabase db snapshot restore snapshot-name
```

### CLI help and documentation

**View all commands:**

```bash
supabase help
```

**Command-specific help:**

```bash
supabase db help
supabase functions help
supabase migration help
```

**Detailed command help:**

```bash
supabase db push --help
supabase gen types --help
```

**Check CLI version:**

```bash
supabase --version
```

**Update check:**

```bash
supabase update
```

For comprehensive documentation, the CLI includes inline help for every command and subcommand. The official documentation at https://supabase.com/docs/guides/cli provides additional context, examples, and best practices for CLI usage.

Related topics to explore next: **PostgreSQL Database Fundamentals** (creating tables, relationships, constraints), **Authentication (GoTrue)** (implementing user auth in applications), **Row Level Security** (securing data access), or **Database Queries (CRUD Operations)** (interacting with data through the Supabase client).

---

# PostgreSQL Database Fundamentals

PostgreSQL is an open-source relational database management system that serves as the foundation of Supabase. Every Supabase project includes a full PostgreSQL database with additional features like real-time subscriptions, auto-generated APIs, and built-in authentication.

## PostgreSQL Basics in Supabase Context

Supabase provides a managed PostgreSQL database (version 15 as of recent deployments) with extensions pre-installed. Each project runs on dedicated infrastructure with automatic backups, point-in-time recovery, and connection pooling through PgBouncer.

When you create a Supabase project, you receive:

- A dedicated PostgreSQL database instance
- Direct database connection via connection string
- Built-in connection pooler for handling multiple concurrent connections
- Auto-generated REST and GraphQL APIs via PostgREST
- Real-time capabilities through PostgreSQL's replication features
- Row Level Security (RLS) for fine-grained access control

The database can be accessed through multiple interfaces: the Supabase Dashboard's Table Editor and SQL Editor, direct PostgreSQL connections using tools like pgAdmin or psql, and programmatically through Supabase client libraries.

## Creating and Managing Tables

Tables store structured data in rows and columns. In Supabase, tables can be created through the Table Editor GUI or SQL Editor.

**Creating tables via SQL:**

```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Creating tables via Table Editor:** Navigate to Table Editor → New Table, then define columns, data types, and constraints through the interface. The GUI generates the SQL automatically.

**Managing tables:**

```sql
-- Rename table
ALTER TABLE users RENAME TO profiles;

-- Add column
ALTER TABLE users ADD COLUMN phone TEXT;

-- Modify column
ALTER TABLE users ALTER COLUMN email TYPE VARCHAR(255);

-- Drop column
ALTER TABLE users DROP COLUMN phone;

-- Drop table
DROP TABLE users;

-- Drop table if exists (safer)
DROP TABLE IF EXISTS users CASCADE;
```

Supabase automatically creates a `public` schema for user tables. Tables in this schema can be exposed through the auto-generated API if RLS policies allow.

## Data Types and Constraints

PostgreSQL offers extensive data types. Common types used in Supabase:

**Numeric types:**

- `INTEGER` / `INT` - whole numbers (-2,147,483,648 to 2,147,483,647)
- `BIGINT` - large whole numbers
- `SERIAL` / `BIGSERIAL` - auto-incrementing integers
- `NUMERIC(precision, scale)` / `DECIMAL` - exact decimal numbers
- `REAL` / `DOUBLE PRECISION` - floating-point numbers

**Text types:**

- `TEXT` - variable unlimited length (recommended for most use cases)
- `VARCHAR(n)` - variable length with limit
- `CHAR(n)` - fixed length

**Boolean:**

- `BOOLEAN` - true/false/null

**Date and time:**

- `DATE` - date only (no time)
- `TIME` - time only (no date)
- `TIMESTAMP` - date and time without timezone
- `TIMESTAMP WITH TIME ZONE` / `TIMESTAMPTZ` - date and time with timezone (recommended)

**UUID:**

- `UUID` - universally unique identifier (recommended for primary keys in distributed systems)

**JSON:**

- `JSON` - JSON data, stored as text
- `JSONB` - JSON data in binary format (faster, supports indexing, recommended)

**Arrays:**

- `TEXT[]`, `INTEGER[]`, etc. - arrays of any data type

**Special types:**

- `ENUM` - custom enumerated type
- `POINT`, `LINE`, `POLYGON` - geometric types
- `INET`, `CIDR` - network address types

**Constraints ensure data integrity:**

```sql
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,  -- NOT NULL: value required
  price NUMERIC(10, 2) CHECK (price > 0),  -- CHECK: custom validation
  sku TEXT UNIQUE,  -- UNIQUE: no duplicates
  category TEXT DEFAULT 'uncategorized',  -- DEFAULT: fallback value
  stock INTEGER CHECK (stock >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Constraint types:**

- `NOT NULL` - prevents null values
- `UNIQUE` - ensures uniqueness across rows
- `CHECK` - validates data against condition
- `DEFAULT` - provides default value when none specified
- `PRIMARY KEY` - combines NOT NULL and UNIQUE, identifies row
- `FOREIGN KEY` - references another table's primary key

## Primary Keys and Foreign Keys

**Primary keys** uniquely identify each row in a table. Every table should have a primary key.

```sql
-- UUID primary key (recommended in Supabase)
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL
);

-- Auto-incrementing integer primary key
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

-- Composite primary key (multiple columns)
CREATE TABLE order_items (
  order_id UUID,
  product_id UUID,
  quantity INTEGER,
  PRIMARY KEY (order_id, product_id)
);
```

Supabase recommends using UUID primary keys because they're globally unique, work well in distributed systems, prevent enumeration attacks, and can be generated client-side.

**Foreign keys** establish relationships between tables by referencing primary keys in other tables.

```sql
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  author_id UUID REFERENCES users(id),  -- Foreign key to users table
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Foreign key with explicit constraint name and actions
CREATE TABLE comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  content TEXT NOT NULL,
  post_id UUID NOT NULL,
  user_id UUID NOT NULL,
  CONSTRAINT fk_post
    FOREIGN KEY (post_id)
    REFERENCES posts(id)
    ON DELETE CASCADE,  -- Delete comments when post is deleted
  CONSTRAINT fk_user
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE SET NULL  -- Set to NULL when user is deleted
);
```

**Referential actions:**

- `ON DELETE CASCADE` - delete child rows when parent is deleted
- `ON DELETE SET NULL` - set foreign key to null when parent is deleted
- `ON DELETE RESTRICT` - prevent deletion of parent if children exist (default)
- `ON DELETE NO ACTION` - similar to RESTRICT
- `ON UPDATE CASCADE` - update foreign key when parent key changes

## Indexes and Performance Optimization

Indexes dramatically improve query performance by allowing the database to find rows quickly without scanning entire tables.

**Creating indexes:**

```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index (order matters)
CREATE INDEX idx_posts_author_created ON posts(author_id, created_at);

-- Unique index (enforces uniqueness)
CREATE UNIQUE INDEX idx_users_username ON users(username);

-- Partial index (only indexes subset of rows)
CREATE INDEX idx_active_users ON users(email) WHERE active = true;

-- Expression index
CREATE INDEX idx_users_lower_email ON users(LOWER(email));

-- Index on JSONB column
CREATE INDEX idx_metadata ON products USING GIN (metadata);

-- Full-text search index
CREATE INDEX idx_posts_search ON posts USING GIN (to_tsvector('english', title || ' ' || content));
```

Primary keys and unique constraints automatically create indexes. Foreign keys do NOT automatically create indexes on the referencing column, so you should create them manually:

```sql
CREATE INDEX idx_posts_author_id ON posts(author_id);
```

**Index types:**

- `BTREE` (default) - balanced tree, good for equality and range queries
- `HASH` - hash table, only for equality comparisons
- `GIN` (Generalized Inverted Index) - for JSONB, arrays, full-text search
- `GIST` (Generalized Search Tree) - for geometric data, full-text search
- `BRIN` (Block Range Index) - for very large tables with natural ordering

**Performance optimization strategies:**

Monitor query performance with `EXPLAIN ANALYZE`:

```sql
EXPLAIN ANALYZE SELECT * FROM posts WHERE author_id = 'uuid-here';
```

This shows the query execution plan and actual timing. Look for "Seq Scan" (sequential scan) which indicates missing indexes.

**Key optimization techniques:**

- Index foreign keys used in JOIN operations
- Index columns frequently used in WHERE, ORDER BY, and JOIN clauses
- Use composite indexes for queries filtering on multiple columns
- Avoid over-indexing (indexes slow down INSERT/UPDATE/DELETE operations)
- Use `VACUUM` and `ANALYZE` to maintain statistics (Supabase handles this automatically)
- Consider partitioning for very large tables
- Use connection pooling (Supabase includes PgBouncer by default)
- Limit result sets with pagination using LIMIT and OFFSET or cursor-based pagination

**Example:** For a social media application:

```sql
-- Posts table
CREATE INDEX idx_posts_author_created ON posts(author_id, created_at DESC);
CREATE INDEX idx_posts_created ON posts(created_at DESC);

-- Comments table
CREATE INDEX idx_comments_post ON comments(post_id);
CREATE INDEX idx_comments_user ON comments(user_id);

-- Followers table
CREATE INDEX idx_followers_following ON followers(following_id);
CREATE INDEX idx_followers_follower ON followers(follower_id);
```

## Database Migrations

Migrations are version-controlled database schema changes that allow teams to track and apply database modifications systematically.

**Migration workflow in Supabase:**

Supabase CLI manages migrations through SQL files stored in `supabase/migrations/` directory. Each migration file has a timestamp prefix ensuring ordered execution.

**Setting up migrations:**

```bash
# Initialize Supabase in project
supabase init

# Create new migration
supabase migration new create_users_table

# This creates: supabase/migrations/20240101000000_create_users_table.sql
```

**Writing migrations:**

```sql
-- supabase/migrations/20240101000000_create_users_table.sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);
```

**Applying migrations:**

```bash
# Apply migrations locally
supabase db reset

# Apply to remote database
supabase db push

# Generate migration from remote changes
supabase db pull
```

**Migration best practices:**

- Make migrations idempotent using `IF NOT EXISTS` and `IF EXISTS`
- Never modify existing migration files after they're applied
- Create new migrations for schema changes
- Test migrations locally before deploying
- Include both schema changes and data migrations in same file if needed
- Use transactions for complex migrations
- Add meaningful comments explaining changes

**Example migration with rollback:**

```sql
-- Migration: Add user profiles
BEGIN;

CREATE TABLE profiles (
  id UUID REFERENCES users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_username ON profiles(username);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

COMMIT;
```

**Data migrations:**

```sql
-- Migrate existing data to new structure
UPDATE posts
SET author_name = (SELECT full_name FROM users WHERE users.id = posts.author_id)
WHERE author_name IS NULL;
```

## SQL Editor Usage

The Supabase SQL Editor is a web-based interface for executing SQL queries directly against your PostgreSQL database.

**Key features:**

- Syntax highlighting and autocomplete
- Query history and saved queries
- Multiple query execution (separated by semicolons)
- Results export to CSV
- Query templates for common operations
- Keyboard shortcuts (Ctrl/Cmd + Enter to run)

**Accessing SQL Editor:** Navigate to SQL Editor in the Supabase Dashboard sidebar. The editor displays your database schema in the sidebar for reference.

**Running queries:**

```sql
-- Select data
SELECT * FROM users LIMIT 10;

-- Insert data
INSERT INTO posts (title, content, author_id)
VALUES ('Hello World', 'This is my first post', 'uuid-here');

-- Update data
UPDATE users
SET full_name = 'John Doe'
WHERE id = 'uuid-here';

-- Delete data
DELETE FROM posts WHERE created_at < NOW() - INTERVAL '1 year';
```

**Using variables (prepared statements):**

[Unverified: The exact syntax for parameterized queries in Supabase SQL Editor may vary. Verify in Supabase documentation.]

**Query templates:** Supabase provides templates for common operations:

- Create table with RLS
- Create foreign key relationship
- Create storage bucket
- Enable realtime
- Create function

**Best practices:**

- Save frequently used queries for reuse
- Use transactions for multiple related operations
- Test destructive operations with `SELECT` before `UPDATE` or `DELETE`
- Use `LIMIT` when exploring large tables
- Comment complex queries for future reference
- Use proper formatting for readability

**Example workflow:**

```sql
-- 1. Check existing data
SELECT COUNT(*) FROM users;

-- 2. Begin transaction
BEGIN;

-- 3. Make changes
DELETE FROM posts WHERE status = 'draft' AND created_at < NOW() - INTERVAL '30 days';

-- 4. Verify changes
SELECT COUNT(*) FROM posts WHERE status = 'draft';

-- 5. Commit or rollback
COMMIT;
-- Or if something's wrong:
-- ROLLBACK;
```

## Table Relationships

Relationships define how tables connect to each other through foreign keys.

### One-to-One Relationship

One record in Table A relates to exactly one record in Table B.

**Example:** User and Profile

```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL
);

CREATE TABLE profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  bio TEXT,
  avatar_url TEXT
);
```

The primary key of `profiles` is also the foreign key to `users`, ensuring one profile per user.

**Querying:**

```sql
SELECT u.email, p.bio
FROM users u
JOIN profiles p ON u.id = p.user_id;
```

### One-to-Many Relationship

One record in Table A relates to multiple records in Table B.

**Example:** Author and Posts

```sql
CREATE TABLE authors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  author_id UUID REFERENCES authors(id) ON DELETE CASCADE
);

CREATE INDEX idx_posts_author ON posts(author_id);
```

One author can have many posts, but each post has one author.

**Querying:**

```sql
-- Get author with all their posts
SELECT a.name, p.title, p.created_at
FROM authors a
LEFT JOIN posts p ON a.id = p.author_id
WHERE a.id = 'uuid-here'
ORDER BY p.created_at DESC;

-- Count posts per author
SELECT a.name, COUNT(p.id) as post_count
FROM authors a
LEFT JOIN posts p ON a.id = p.author_id
GROUP BY a.id, a.name;
```

### Many-to-Many Relationship

Multiple records in Table A relate to multiple records in Table B, implemented through a junction/join table.

**Example:** Students and Courses

```sql
CREATE TABLE students (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE courses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL
);

-- Junction table
CREATE TABLE enrollments (
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  grade TEXT,
  PRIMARY KEY (student_id, course_id)
);

CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
```

The junction table stores the relationship and can include additional attributes (like `enrolled_at` and `grade`).

**Querying:**

```sql
-- Get all courses for a student
SELECT c.title, e.enrolled_at, e.grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id
WHERE s.id = 'uuid-here';

-- Get all students in a course
SELECT s.name, e.grade
FROM courses c
JOIN enrollments e ON c.id = e.course_id
JOIN students s ON e.student_id = s.id
WHERE c.id = 'uuid-here';

-- Find students enrolled in multiple specific courses
SELECT s.name, COUNT(e.course_id) as course_count
FROM students s
JOIN enrollments e ON s.id = e.student_id
WHERE e.course_id IN ('course-uuid-1', 'course-uuid-2')
GROUP BY s.id, s.name
HAVING COUNT(e.course_id) = 2;
```

**Self-referencing relationships:**

```sql
-- Users following other users
CREATE TABLE follows (
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id != following_id)  -- Prevent self-following
);

CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);
```

## Views and Materialized Views

Views are virtual tables based on SQL queries. They simplify complex queries and provide abstraction layers.

### Standard Views

Views execute their underlying query each time they're accessed.

```sql
-- Create view
CREATE VIEW active_posts AS
SELECT 
  p.id,
  p.title,
  p.content,
  p.created_at,
  u.full_name as author_name,
  u.email as author_email
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published'
  AND p.deleted_at IS NULL;

-- Query view like a table
SELECT * FROM active_posts WHERE author_name = 'John Doe';

-- Drop view
DROP VIEW active_posts;

-- Replace view
CREATE OR REPLACE VIEW active_posts AS
SELECT p.id, p.title, u.full_name as author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published';
```

**Benefits:**

- Simplify complex queries
- Provide data abstraction and security (expose only certain columns)
- No storage overhead (virtual table)
- Always show current data

**Limitations:**

- Can be slow for complex queries
- Not indexed (though underlying tables can be)
- Cannot directly update in most cases

### Materialized Views

Materialized views store query results physically, like a cached table.

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW post_statistics AS
SELECT 
  p.id as post_id,
  p.title,
  COUNT(DISTINCT c.id) as comment_count,
  COUNT(DISTINCT l.id) as like_count,
  MAX(c.created_at) as last_comment_at
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id
LEFT JOIN likes l ON p.id = l.post_id
GROUP BY p.id, p.title;

-- Create index on materialized view
CREATE INDEX idx_post_stats_post ON post_statistics(post_id);

-- Query materialized view
SELECT * FROM post_statistics ORDER BY like_count DESC LIMIT 10;

-- Refresh materialized view (update cached data)
REFRESH MATERIALIZED VIEW post_statistics;

-- Refresh without locking (allows concurrent reads)
REFRESH MATERIALIZED VIEW CONCURRENTLY post_statistics;

-- Drop materialized view
DROP MATERIALIZED VIEW post_statistics;
```

**Benefits:**

- Fast query performance (pre-computed results)
- Can be indexed for further optimization
- Reduces load on source tables

**Limitations:**

- Takes up storage space
- Data can be stale (requires manual refresh)
- Refresh can be slow for large datasets
- CONCURRENTLY refresh requires unique index

**Automatic refresh with triggers:**

```sql
-- Function to refresh materialized view
CREATE OR REPLACE FUNCTION refresh_post_statistics()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY post_statistics;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger on comments table
CREATE TRIGGER refresh_stats_on_comment
AFTER INSERT OR UPDATE OR DELETE ON comments
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_post_statistics();
```

[Inference: Frequent refreshes may impact performance. Consider using job schedulers for periodic refreshes instead of triggers on high-traffic tables.]

**Choosing between views and materialized views:**

- Use standard views for: queries on small datasets, when real-time data is critical, simple transformations
- Use materialized views for: expensive aggregations, complex joins across large tables, reporting and analytics, data that doesn't need real-time accuracy

## Database Functions and Triggers

Functions encapsulate reusable SQL logic, while triggers automatically execute functions in response to database events.

### Database Functions

Functions are stored procedures written in PL/pgSQL or other supported languages.

**Basic function:**

```sql
-- Function to calculate user age
CREATE OR REPLACE FUNCTION calculate_age(birth_date DATE)
RETURNS INTEGER AS $$
BEGIN
  RETURN EXTRACT(YEAR FROM AGE(birth_date));
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT calculate_age('1990-01-01');
```

**Function with table query:**

```sql
-- Function to get user post count
CREATE OR REPLACE FUNCTION get_post_count(user_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
  post_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO post_count
  FROM posts
  WHERE author_id = user_uuid AND deleted_at IS NULL;
  
  RETURN post_count;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT get_post_count('uuid-here');
```

**Function returning table:**

```sql
-- Function to get popular posts
CREATE OR REPLACE FUNCTION get_popular_posts(min_likes INTEGER DEFAULT 10)
RETURNS TABLE (
  post_id UUID,
  title TEXT,
  like_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    COUNT(l.id) as like_count
  FROM posts p
  LEFT JOIN likes l ON p.id = l.post_id
  GROUP BY p.id, p.title
  HAVING COUNT(l.id) >= min_likes
  ORDER BY like_count DESC;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT * FROM get_popular_posts(20);
```

**Function with security definer:**

```sql
-- Function that bypasses RLS (runs with creator's permissions)
CREATE OR REPLACE FUNCTION admin_delete_user(user_uuid UUID)
RETURNS VOID
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM users WHERE id = user_uuid;
END;
$$ LANGUAGE plpgsql;
```

### Triggers

Triggers automatically execute functions when specific database events occur.

**Trigger timing:**

- `BEFORE` - runs before the operation
- `AFTER` - runs after the operation
- `INSTEAD OF` - replaces the operation (for views)

**Trigger events:**

- `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`

**Example: Update timestamp on modification**

```sql
-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on posts table
CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Example: Audit log**

```sql
-- Audit table
CREATE TABLE audit_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  table_name TEXT NOT NULL,
  operation TEXT NOT NULL,
  old_data JSONB,
  new_data JSONB,
  user_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit function
CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, operation, old_data, new_data, user_id)
  VALUES (
    TG_TABLE_NAME,
    TG_OP,
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
    auth.uid()  -- Supabase auth user ID
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply trigger to posts table
CREATE TRIGGER posts_audit
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION audit_changes();
```

**Example: Cascade soft delete**

```sql
-- Soft delete posts when user is soft deleted
CREATE OR REPLACE FUNCTION cascade_soft_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    UPDATE posts
    SET deleted_at = NEW.deleted_at
    WHERE author_id = NEW.id AND deleted_at IS NULL;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER soft_delete_user_posts
  AFTER UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION cascade_soft_delete();
```

**Example: Validate data before insert**

```sql
-- Ensure username is lowercase
CREATE OR REPLACE FUNCTION lowercase_username()
RETURNS TRIGGER AS $$
BEGIN
  NEW.username = LOWER(NEW.username);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_lowercase_username
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION lowercase_username();
```

**Example: Prevent updates on certain conditions**

```sql
-- Prevent editing published posts after 24 hours
CREATE OR REPLACE FUNCTION prevent_old_post_edits()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status = 'published' 
     AND OLD.published_at < NOW() - INTERVAL '24 hours' THEN
    RAISE EXCEPTION 'Cannot edit posts published more than 24 hours ago';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_post_edit_time
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION prevent_old_post_edits();
```

**Managing triggers:**

```sql
-- Disable trigger
ALTER TABLE posts DISABLE TRIGGER update_posts_updated_at;

-- Enable trigger
ALTER TABLE posts ENABLE TRIGGER update_posts_updated_at;

-- Drop trigger
DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;

-- List all triggers
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';
```

**Best practices:**

- Keep trigger logic simple and fast (they run on every operation)
- Use `BEFORE` triggers for validation and data transformation
- Use `AFTER` triggers for logging and cascading actions
- Avoid triggers that modify the same table (can cause infinite loops)
- Consider using constraints instead of triggers when possible
- Document trigger behavior thoroughly
- Test triggers carefully with edge cases

**Key points:**

- PostgreSQL in Supabase provides enterprise-grade features with developer-friendly tooling
- Proper indexing and relationship design are critical for performance at scale
- Row Level Security (RLS) policies work alongside database constraints for security
- Migrations enable version-controlled, reproducible schema changes
- Views simplify complex queries; materialized views cache expensive computations
- Functions and triggers enable sophisticated business logic at the database layer
- The SQL Editor provides immediate access for development and debugging
- Understanding data types, constraints, and relationships forms the foundation for reliable applications

---

# Authentication (GoTrue)

Supabase Authentication is built on GoTrue, an open-source authentication server that handles user registration, login, session management, and various authentication methods. It provides a complete authentication system that integrates seamlessly with Supabase's database and implements JWT-based authentication with PostgreSQL Row Level Security (RLS).

## Authentication Concepts and Methods

GoTrue operates as a stateless JWT-based authentication service. When users authenticate, they receive a JWT access token and a refresh token. The access token contains user metadata and is used to authenticate API requests, while the refresh token is used to obtain new access tokens when they expire.

**Key points:**

- Access tokens are short-lived (default 1 hour) and contain user claims
- Refresh tokens are long-lived and stored securely to obtain new access tokens
- JWTs are cryptographically signed and can be verified by Supabase's database
- User data is stored in `auth.users` table with associated metadata in `auth.identities`
- Sessions are tracked in `auth.sessions` table
- Authentication state can be managed client-side or server-side

The authentication flow typically involves: user submits credentials → GoTrue validates → JWT tokens issued → client stores tokens → tokens used for subsequent authenticated requests → tokens refreshed before expiration.

## Email/Password Authentication

Traditional email and password authentication where users register with an email address and password. Passwords are hashed using bcrypt before storage.

**Key points:**

- Passwords must meet configurable strength requirements
- Email confirmation can be required or optional
- Password hashing uses bcrypt with configurable cost factor
- Users stored in `auth.users` table with encrypted password
- Sign-up creates user record and optionally sends confirmation email

**Example:** Basic sign-up flow

```javascript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'securePassword123',
  options: {
    data: {
      first_name: 'John',
      age: 27
    }
  }
})
```

**Example:** Sign-in flow

```javascript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'securePassword123'
})
```

After successful authentication, the session is automatically managed by the Supabase client, and the access token is included in subsequent database queries.

## Magic Link Authentication

Passwordless authentication where users receive a one-time login link via email. Clicking the link authenticates the user without requiring a password.

**Key points:**

- No password storage required
- Links are single-use and time-limited (default 1 hour)
- Token embedded in link validates the authentication request
- Reduces security risks associated with password management
- Requires email provider configuration

**Example:** Sending magic link

```javascript
const { data, error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'https://yourapp.com/welcome'
  }
})
```

The user clicks the link in their email, which contains a token. GoTrue validates the token and creates a session. The user is redirected to the specified URL with the session established.

## OAuth Providers

Third-party authentication through providers like Google, GitHub, Apple, Azure, Facebook, Discord, and others. Users authenticate through the provider's interface, and Supabase receives identity information.

**Key points:**

- Providers must be enabled and configured in Supabase dashboard
- Requires OAuth client ID and secret from each provider
- Redirect URLs must be configured on provider's platform
- User identity stored in `auth.identities` table
- Can link multiple providers to single user account
- Profile information from provider can be accessed via user metadata

**Example:** OAuth sign-in

```javascript
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'https://yourapp.com/auth/callback',
    scopes: 'email profile',
    queryParams: {
      access_type: 'offline',
      prompt: 'consent'
    }
  }
})
```

The OAuth flow redirects users to the provider's login page, then back to your application with authentication credentials. Supabase handles the token exchange and session creation.

## Phone Authentication

SMS-based authentication using one-time passwords (OTP) sent to phone numbers. Users enter the code received via SMS to authenticate.

**Key points:**

- Requires SMS provider integration (Twilio, MessageBird, Vonage, etc.)
- Phone numbers stored in E.164 format
- OTP codes are time-limited (default 60 seconds)
- Can be used for sign-up or sign-in
- Phone number must be verified before use
- Rate limiting prevents abuse

**Example:** Sending OTP

```javascript
const { data, error } = await supabase.auth.signInWithOtp({
  phone: '+12025551234',
  options: {
    channel: 'sms' // or 'whatsapp'
  }
})
```

**Example:** Verifying OTP

```javascript
const { data, error } = await supabase.auth.verifyOtp({
  phone: '+12025551234',
  token: '123456',
  type: 'sms'
})
```

## Anonymous Users

Temporary users created without credentials, allowing interaction with the application before requiring registration. Anonymous sessions can later be converted to permanent accounts.

**Key points:**

- Creates user with UUID but no identifying information
- Useful for guest experiences or trials
- Can be converted to permanent user by adding email/password or OAuth
- Anonymous users have same RLS capabilities as authenticated users
- Session expires according to standard token lifetime
- Converting preserves user data and ID

**Example:** Creating anonymous user

```javascript
const { data, error } = await supabase.auth.signInAnonymously()
```

**Example:** Converting to permanent user

```javascript
// User must be signed in as anonymous user first
const { data, error } = await supabase.auth.updateUser({
  email: 'user@example.com',
  password: 'newPassword123'
})
```

[Inference: The conversion process likely maintains the same user ID to preserve associated data, though specific implementation details may vary.]

## Multi-Factor Authentication (MFA)

Additional security layer requiring users to provide a second form of verification beyond password. Supabase supports Time-based One-Time Password (TOTP) authentication.

**Key points:**

- Uses TOTP standard (RFC 6238) compatible with authenticator apps
- Factors stored encrypted in `auth.mfa_factors` table
- Can require MFA for specific users or all users
- Challenge records stored in `auth.mfa_challenges` table
- Backup codes available for account recovery
- Verification required within time window (default 30 seconds)

**Example:** Enrolling MFA factor

```javascript
const { data, error } = await supabase.auth.mfa.enroll({
  factorType: 'totp',
  friendlyName: 'My Phone'
})

// Returns QR code and secret for authenticator app
const { id, type, totp } = data
```

**Example:** Verifying and activating MFA

```javascript
const { data, error } = await supabase.auth.mfa.challenge({
  factorId: 'factor-id-here'
})

const { data: verifyData, error: verifyError } = await supabase.auth.mfa.verify({
  factorId: 'factor-id-here',
  challengeId: data.id,
  code: '123456'
})
```

**Example:** Sign-in with MFA

```javascript
// First authenticate with password
await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
})

// Then complete MFA challenge
const { data: factorsData } = await supabase.auth.mfa.listFactors()
const factor = factorsData.totp[0]

const { data: challengeData } = await supabase.auth.mfa.challenge({
  factorId: factor.id
})

const { data, error } = await supabase.auth.mfa.verify({
  factorId: factor.id,
  challengeId: challengeData.id,
  code: '123456'
})
```

## Session Management

Handling of user sessions including creation, persistence, refresh, and termination. Sessions track active authenticated users and manage token lifecycle.

**Key points:**

- Sessions stored in `auth.sessions` table with device and location information
- Client libraries automatically handle session persistence and refresh
- Session refresh occurs before access token expiration
- Multiple sessions per user supported across devices
- Sessions can be individually revoked or all terminated at once
- Session events emitted for state changes (SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED)

**Example:** Listening to auth state changes

```javascript
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    console.log('User signed in', session)
  } else if (event === 'SIGNED_OUT') {
    console.log('User signed out')
  } else if (event === 'TOKEN_REFRESHED') {
    console.log('Token refreshed', session)
  }
})
```

**Example:** Getting current session

```javascript
const { data: { session }, error } = await supabase.auth.getSession()
```

**Example:** Refreshing session manually

```javascript
const { data: { session }, error } = await supabase.auth.refreshSession()
```

**Example:** Signing out

```javascript
// Sign out from current session
await supabase.auth.signOut()

// Sign out from all sessions
await supabase.auth.signOut({ scope: 'global' })
```

## User Metadata and Custom Claims

Additional information stored with user accounts beyond authentication credentials. Metadata is divided into public metadata (accessible to all) and private metadata (only accessible to the user and server).

**Key points:**

- User metadata stored in `raw_user_meta_data` field of `auth.users` table
- App metadata stored in `raw_app_meta_data` (server-controlled only)
- Public metadata included in JWT payload (visible to client)
- Metadata is JSON and can contain nested structures
- Custom claims in JWT used for authorization and RLS policies
- Metadata updated via `updateUser()` method

**Example:** Setting user metadata during sign-up

```javascript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    data: {
      full_name: 'John Doe',
      avatar_url: 'https://example.com/avatar.jpg',
      subscription_tier: 'free'
    }
  }
})
```

**Example:** Updating user metadata

```javascript
const { data, error } = await supabase.auth.updateUser({
  data: {
    full_name: 'Jane Doe',
    preferences: {
      theme: 'dark',
      notifications: true
    }
  }
})
```

**Example:** Accessing metadata in RLS policy

```sql
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Premium users can access feature"
ON premium_content FOR SELECT
USING (
  (auth.jwt() ->> 'user_metadata')::jsonb ->> 'subscription_tier' = 'premium'
);
```

[Note: App metadata must be set server-side through admin API or database functions, not through client SDK]

## Password Reset Flows

Process for users to recover access when they forget their password. Involves sending a secure reset link via email and allowing password change.

**Key points:**

- Reset link contains time-limited token (default 1 hour)
- Tokens are single-use and invalidated after password change
- Reset request does not confirm if email exists (prevents enumeration)
- Custom redirect URLs can be specified for reset completion
- Email templates customizable in Supabase dashboard
- Password reset can be rate-limited to prevent abuse

**Example:** Requesting password reset

```javascript
const { data, error } = await supabase.auth.resetPasswordForEmail(
  'user@example.com',
  {
    redirectTo: 'https://yourapp.com/update-password'
  }
)
```

**Example:** Updating password after reset

```javascript
// After user clicks reset link and is redirected to your app
// The access token is in the URL fragment or handled by client library

const { data, error } = await supabase.auth.updateUser({
  password: 'newSecurePassword123'
})
```

The flow: user requests reset → reset email sent → user clicks link → session established with special recovery token → user provides new password → password updated and normal session created.

## Email Confirmation Flows

Process to verify user email addresses during registration. Ensures users have access to the email address they provided.

**Key points:**

- Confirmation can be required or optional (configurable in dashboard)
- Unconfirmed users cannot sign in if confirmation required
- Confirmation link contains time-limited token
- Tokens single-use and invalidated after confirmation
- Custom redirect URLs supported
- Confirmation can be resent if expired or not received
- Email templates customizable

**Example:** Sign-up with email confirmation

```javascript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    emailRedirectTo: 'https://yourapp.com/welcome'
  }
})

// User receives email with confirmation link
// After clicking link, they are redirected to specified URL
```

**Example:** Resending confirmation email

```javascript
const { data, error } = await supabase.auth.resend({
  type: 'signup',
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'https://yourapp.com/welcome'
  }
})
```

When confirmation is required, the user record is created but `email_confirmed_at` field is null until confirmation. After clicking the link, the field is populated and the user can sign in.

## Server-Side vs Client-Side Authentication

Different approaches to handling authentication depending on application architecture. Choice affects security, performance, and implementation complexity.

**Client-Side Authentication:**

- Authentication handled entirely in browser/mobile app
- Tokens stored in browser storage (localStorage, sessionStorage, cookies)
- Suitable for single-page applications (SPAs) and mobile apps
- JavaScript client library manages token lifecycle automatically
- Direct API calls from client to Supabase
- Easier to implement for simple applications
- Tokens potentially vulnerable to XSS attacks [Inference: if application has XSS vulnerabilities]

**Key points for client-side:**

- Use `@supabase/supabase-js` client library
- Tokens automatically included in requests
- Session automatically refreshed before expiration
- Auth state changes trigger callbacks
- PKCe flow used for OAuth to improve security

**Example:** Client-side initialization

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://your-project.supabase.co',
  'your-anon-key'
)

// Authentication automatically managed
await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
})

// Session stored in localStorage by default
// Tokens automatically attached to subsequent queries
```

**Server-Side Authentication:**

- Authentication processed on server before reaching client
- Tokens stored in secure HTTP-only cookies
- Suitable for server-rendered applications (Next.js, SvelteKit, etc.)
- Requires server-side Supabase client
- Better protection against XSS attacks
- More complex implementation with cookie management
- Requires middleware for session management

**Key points for server-side:**

- Use framework-specific libraries (`@supabase/ssr`, `@supabase/auth-helpers`)
- Cookies set with secure, httpOnly, sameSite flags
- Middleware handles session validation on each request
- Server components can access session directly
- Session refresh handled server-side

**Example:** Server-side with Next.js App Router

```javascript
// middleware.js
import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'

export async function middleware(request) {
  let response = NextResponse.next()
  
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    {
      cookies: {
        get(name) {
          return request.cookies.get(name)?.value
        },
        set(name, value, options) {
          response.cookies.set({ name, value, ...options })
        },
        remove(name, options) {
          response.cookies.set({ name, value: '', ...options })
        }
      }
    }
  )

  await supabase.auth.getSession()
  return response
}
```

**Example:** Server component accessing session

```javascript
// app/page.js
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export default async function Page() {
  const supabase = createServerComponentClient({ cookies })
  const { data: { session } } = await supabase.auth.getSession()
  
  if (!session) {
    redirect('/login')
  }
  
  return <div>Welcome {session.user.email}</div>
}
```

**Comparison considerations:**

- Client-side: simpler implementation, suitable for SPAs, tokens in browser storage
- Server-side: more secure, suitable for SSR, tokens in HTTP-only cookies, requires more setup
- Hybrid approaches possible where server validates critical operations
- Choose based on application architecture and security requirements

[Inference: Server-side authentication generally provides better security posture for applications handling sensitive data, though both approaches can be secure when implemented correctly]

**Related topics:** Row Level Security (RLS) policies for authorization, PostgreSQL roles and permissions, JWT token structure and validation, Custom SMTP configuration for emails, Rate limiting and security configurations, Admin API for server-side user management

---

# Row Level Security (RLS)

Row Level Security (RLS) in Supabase is a PostgreSQL security feature that restricts database row access at the query level based on the current user's context. RLS policies act as invisible WHERE clauses applied to every query, controlling which rows users can view, insert, update, or delete.

## Understanding RLS Concepts

RLS operates on a per-row basis rather than per-table. When enabled, all rows become inaccessible by default until explicit policies grant access. This security model ensures data isolation between users, making it particularly valuable for multi-tenant applications where users should only access their own data.

RLS policies evaluate against the authenticated user's JWT token claims, which Supabase automatically injects into the PostgreSQL session context. Each policy defines conditions that must be true for a row to be accessible during a specific operation (SELECT, INSERT, UPDATE, DELETE).

The security model follows a whitelist approach: deny everything by default, then explicitly grant access through policies. Multiple policies can apply to the same table, and if any policy returns true for a row, that row becomes accessible for the specified operation.

## Enabling RLS on Tables

RLS must be explicitly enabled on each table. Without enabling RLS, tables remain fully accessible regardless of policies defined.

```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
```

Once enabled, all access to the table is blocked by default. Users cannot read, insert, update, or delete any rows until policies grant them permission.

To disable RLS (not recommended for user-facing tables):

```sql
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
```

**[Inference]** Tables without RLS enabled pose security risks in applications where users authenticate, as any authenticated user could potentially access all data.

## Writing RLS Policies

Policies define who can perform which operations on which rows. The basic syntax structure is:

```sql
CREATE POLICY policy_name ON table_name
FOR operation
TO role
USING (condition)
WITH CHECK (condition);
```

The `USING` clause determines which existing rows are visible for SELECT, UPDATE, and DELETE operations. The `WITH CHECK` clause determines which rows can be inserted or which new values are allowed during UPDATE operations.

Basic policy allowing users to read their own profile:

```sql
CREATE POLICY "Users can view own profile"
ON profiles
FOR SELECT
USING (auth.uid() = user_id);
```

Policy allowing users to insert their own profile:

```sql
CREATE POLICY "Users can insert own profile"
ON profiles
FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

Policy allowing users to update their own profile:

```sql
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

## Policy Expressions and Conditions

Policy conditions are PostgreSQL expressions that return boolean values. These expressions can reference table columns, function results, subqueries, and JWT claims.

Simple equality checks:

```sql
USING (user_id = auth.uid())
USING (status = 'published')
```

Complex boolean logic:

```sql
USING (
  user_id = auth.uid() 
  OR visibility = 'public'
  OR auth.uid() IN (
    SELECT user_id FROM collaborators WHERE document_id = documents.id
  )
)
```

Time-based conditions:

```sql
USING (published_at <= now() AND (expires_at IS NULL OR expires_at > now()))
```

JSON field checks:

```sql
USING (metadata->>'is_public' = 'true')
```

Subquery patterns for relationships:

```sql
USING (
  EXISTS (
    SELECT 1 FROM team_members
    WHERE team_members.team_id = projects.team_id
    AND team_members.user_id = auth.uid()
  )
)
```

## User Roles and Permissions

PostgreSQL roles define the database identity executing queries. Supabase uses specific roles for different contexts:

- `anon` - Unauthenticated users (public access)
- `authenticated` - Any logged-in user
- `service_role` - Server-side operations with bypass capabilities

Policies target specific roles using the `TO` clause:

```sql
CREATE POLICY "Public profiles are viewable by everyone"
ON profiles
FOR SELECT
TO anon, authenticated
USING (is_public = true);
```

```sql
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);
```

**[Inference]** The `service_role` bypasses RLS entirely and should only be used in trusted server environments, never exposed to client applications.

## Helper Functions for RLS

Supabase provides helper functions that access the authenticated user's JWT context within policy expressions.

`auth.uid()` returns the current user's UUID from their JWT token:

```sql
USING (user_id = auth.uid())
```

Returns `NULL` for unauthenticated requests, which can be used to differentiate access:

```sql
USING (
  visibility = 'public' 
  OR (auth.uid() IS NOT NULL AND user_id = auth.uid())
)
```

`auth.jwt()` returns the complete JWT payload as JSON, allowing access to custom claims:

```sql
USING (auth.jwt()->>'email' LIKE '%@company.com')
USING (auth.jwt()->>'role' = 'admin')
USING ((auth.jwt()->>'app_metadata')::json->>'subscription' = 'premium')
```

Custom JWT claims must be set during authentication or through user metadata updates:

```sql
USING (
  auth.jwt()->>'user_role' = 'moderator'
  OR auth.jwt()->>'user_role' = 'admin'
)
```

## Common RLS Patterns

**User-owned records pattern:**

```sql
CREATE POLICY "users_own_records"
ON documents
USING (user_id = auth.uid());
```

**Public read, authenticated write pattern:**

```sql
CREATE POLICY "public_read"
ON posts
FOR SELECT
TO anon, authenticated
USING (published = true);

CREATE POLICY "authenticated_insert"
ON posts
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = author_id);
```

**Team/organization access pattern:**

```sql
CREATE POLICY "team_member_access"
ON projects
USING (
  team_id IN (
    SELECT team_id FROM team_members
    WHERE user_id = auth.uid()
  )
);
```

**Role-based access pattern:**

```sql
CREATE POLICY "admin_full_access"
ON sensitive_data
USING (auth.jwt()->>'role' = 'admin');

CREATE POLICY "manager_read_access"
ON sensitive_data
FOR SELECT
USING (
  auth.jwt()->>'role' = 'manager'
  OR auth.jwt()->>'role' = 'admin'
);
```

**Shared resource pattern:**

```sql
CREATE POLICY "shared_documents"
ON documents
USING (
  user_id = auth.uid()
  OR id IN (
    SELECT document_id FROM document_shares
    WHERE shared_with_user_id = auth.uid()
  )
);
```

**Time-based access pattern:**

```sql
CREATE POLICY "scheduled_content"
ON posts
FOR SELECT
USING (
  (publish_at IS NULL OR publish_at <= now())
  AND (unpublish_at IS NULL OR unpublish_at > now())
);
```

**Hierarchical access pattern (cascading permissions):**

```sql
CREATE POLICY "folder_access"
ON files
USING (
  folder_id IN (
    WITH RECURSIVE folder_tree AS (
      SELECT id FROM folders WHERE user_id = auth.uid()
      UNION
      SELECT f.id FROM folders f
      INNER JOIN folder_tree ft ON f.parent_id = ft.id
    )
    SELECT id FROM folder_tree
  )
);
```

## Testing RLS Policies

Testing RLS policies requires verifying that policies correctly grant and deny access under different user contexts.

Manual testing using `set_config`:

```sql
-- Simulate authenticated user
SELECT set_config('request.jwt.claims', '{"sub":"user-uuid-here"}', true);

-- Test query
SELECT * FROM profiles;

-- Reset context
RESET request.jwt.claims;
```

Testing as anonymous user:

```sql
RESET request.jwt.claims;
SELECT * FROM profiles WHERE is_public = true;
```

Testing policy isolation by attempting unauthorized access:

```sql
-- Set user A's context
SELECT set_config('request.jwt.claims', '{"sub":"user-a-uuid"}', true);

-- Attempt to access user B's data (should return empty)
SELECT * FROM profiles WHERE user_id = 'user-b-uuid';
```

Testing with Supabase client (JavaScript):

```javascript
// Test as authenticated user
const { data: userData, error: userError } = await supabase
  .from('profiles')
  .select('*')
  .eq('user_id', user.id);

// Test as anonymous user (sign out first)
await supabase.auth.signOut();
const { data: publicData, error: publicError } = await supabase
  .from('profiles')
  .select('*')
  .eq('is_public', true);
```

**[Unverified]** The specific testing approach and level of test coverage needed depends on your application's security requirements.

## Debugging RLS Issues

When queries return unexpected results or access is denied when it should be granted, systematic debugging reveals policy problems.

Enable detailed PostgreSQL logging:

```sql
SET client_min_messages TO DEBUG;
```

Check if RLS is enabled:

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
```

View all policies on a table:

```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'your_table_name';
```

Test policy conditions directly:

```sql
-- Simulate user context
SELECT set_config('request.jwt.claims', '{"sub":"user-uuid"}', true);

-- Check what auth.uid() returns
SELECT auth.uid();

-- Test policy condition manually
SELECT * FROM your_table 
WHERE (your_policy_condition);
```

Check for policy conflicts (multiple policies where none match):

```sql
-- List all policies for a table
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'documents';
```

Common debugging scenarios:

**Policy returns no rows when it should:**

- Verify `auth.uid()` returns expected UUID
- Check if user_id column matches exactly (data type, null values)
- Ensure RLS is enabled on the table
- Verify the role (anon vs authenticated) matches policy target

**Policy allows unauthorized access:**

- Review `OR` conditions that may be too permissive
- Check for missing `auth.uid() IS NOT NULL` checks
- Verify subqueries don't return unexpected results

**INSERT/UPDATE fails unexpectedly:**

- Check `WITH CHECK` clause separately from `USING` clause
- Verify computed values satisfy the `WITH CHECK` condition
- Test if default column values violate policies

Supabase Dashboard provides a SQL editor where you can execute these debugging queries directly against your database.

## Performance Considerations with RLS

RLS policies execute with every query, potentially impacting performance when policies involve complex conditions or subqueries.

**Subquery performance impact:**

Policies with subqueries execute the subquery for every row evaluated:

```sql
-- Potentially slow if team_members table is large
USING (
  team_id IN (
    SELECT team_id FROM team_members WHERE user_id = auth.uid()
  )
)
```

**[Inference]** Optimizing this pattern may involve denormalizing team membership or using more efficient join patterns, though the specific optimization depends on your data structure and query patterns.

**Index requirements:**

RLS policies benefit from indexes on columns referenced in policy conditions:

```sql
-- Policy uses user_id
CREATE INDEX idx_documents_user_id ON documents(user_id);

-- Policy checks foreign key relationships
CREATE INDEX idx_projects_team_id ON projects(team_id);
CREATE INDEX idx_team_members_user_team ON team_members(user_id, team_id);
```

**Function-based policies:**

Extracting complex policy logic into functions can improve maintainability but may impact performance:

```sql
CREATE FUNCTION user_can_access_document(doc_id uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM documents d
    LEFT JOIN document_shares ds ON ds.document_id = d.id
    WHERE d.id = doc_id
    AND (d.user_id = auth.uid() OR ds.shared_with_user_id = auth.uid())
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE POLICY "function_based_access"
ON documents
USING (user_can_access_document(id));
```

**[Inference]** The `STABLE` keyword indicates the function result won't change within a single query, potentially allowing PostgreSQL to cache results, though actual caching behavior depends on query planning.

**Policy complexity trade-offs:**

Simpler policies generally perform better:

```sql
-- Simpler, faster
USING (user_id = auth.uid())

-- More complex, slower
USING (
  user_id = auth.uid()
  OR id IN (SELECT resource_id FROM permissions WHERE user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM team_members tm 
             JOIN teams t ON t.id = tm.team_id 
             WHERE tm.user_id = auth.uid() 
             AND t.id = team_id)
)
```

**Monitoring policy performance:**

```sql
EXPLAIN ANALYZE
SELECT * FROM documents WHERE team_id = 'some-team-id';
```

The query plan shows how RLS policies affect query execution and which indexes are used.

**[Unverified]** The specific performance impact of RLS policies varies significantly based on data volume, policy complexity, and database configuration.

---

**Related topics for deeper understanding:** Supabase Auth JWT customization, PostgreSQL query optimization, database indexing strategies, multi-tenancy patterns, security policy testing frameworks.

---

# Supabase Client Libraries

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

## Client initialization and configuration

### Basic client creation

**Import and create client:**

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://your-project-ref.supabase.co'
const supabaseAnonKey = 'your-anon-key'

const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

**Required parameters:**

- `supabaseUrl`: Your project URL from dashboard
- `supabaseKey`: Either anon key or service_role key

### Configuration options

**Full configuration object:**

```typescript
const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    storage: customStorageImplementation,
    storageKey: 'supabase.auth.token',
    flowType: 'pkce'
  },
  db: {
    schema: 'public'
  },
  global: {
    headers: {
      'x-custom-header': 'value'
    },
    fetch: customFetchImplementation
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
})
```

### Auth configuration options

**autoRefreshToken** (boolean, default: `true`): Automatically refresh access tokens before expiry

```typescript
auth: {
  autoRefreshToken: true  // Recommended for client-side
}
```

**persistSession** (boolean, default: `true`): Store session in browser localStorage/AsyncStorage

```typescript
auth: {
  persistSession: true  // Keep users logged in
}
```

**detectSessionInUrl** (boolean, default: `true`): Automatically detect auth callback parameters in URL

```typescript
auth: {
  detectSessionInUrl: true  // Handle OAuth redirects
}
```

**storage** (Storage interface): Custom storage implementation

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage'

auth: {
  storage: AsyncStorage  // For React Native
}
```

**storageKey** (string, default: `'supabase.auth.token'`): Key used to store session in storage

```typescript
auth: {
  storageKey: 'my-app.auth.token'  // Custom key
}
```

**flowType** (string, default: `'implicit'`): OAuth flow type - `'implicit'` or `'pkce'`

```typescript
auth: {
  flowType: 'pkce'  // More secure, recommended
}
```

### Database configuration options

**schema** (string, default: `'public'`): Default schema for queries

```typescript
db: {
  schema: 'public'  // Or 'custom_schema'
}
```

### Global configuration options

**headers** (object): Custom headers sent with every request

```typescript
global: {
  headers: {
    'x-application-name': 'MyApp',
    'x-application-version': '1.0.0'
  }
}
```

**fetch** (function): Custom fetch implementation

```typescript
global: {
  fetch: customFetch  // For custom interceptors, logging, etc.
}
```

### Realtime configuration options

**params** (object): Realtime connection parameters

```typescript
realtime: {
  params: {
    eventsPerSecond: 10  // Throttle events
  }
}
```

### TypeScript-enhanced initialization

**With database types:**

```typescript
import { createClient } from '@supabase/supabase-js'
import { Database } from './types/supabase'

const supabase = createClient<Database>(
  supabaseUrl,
  supabaseAnonKey
)

// Now all queries are fully typed
const { data } = await supabase
  .from('profiles')  // Type-checked table name
  .select('username, full_name')  // Type-checked columns
```

### Client instance patterns

**Singleton pattern (recommended):**

Create single client instance shared across application.

`lib/supabase.ts`:

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

Usage:

```typescript
import { supabase } from '@/lib/supabase'

const { data } = await supabase.from('posts').select()
```

**Factory pattern:**

Create new client instances with different configurations.

```typescript
import { createClient, SupabaseClient } from '@supabase/supabase-js'

export function createSupabaseClient(accessToken?: string): SupabaseClient {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      global: {
        headers: accessToken 
          ? { Authorization: `Bearer ${accessToken}` }
          : {}
      }
    }
  )
}
```

**Server-side client factory:**

```typescript
export function createServerClient(serviceRoleKey: string) {
  return createClient(
    process.env.SUPABASE_URL!,
    serviceRoleKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false
      }
    }
  )
}
```

## Environment variables and API keys

### Environment variable setup

**Standard environment variables:**

`.env.local` (for Next.js, Vite, etc.):

```bash
# Public variables (safe for client-side)
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Private variables (server-side only)
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_DB_PASSWORD=your-database-password
```

**Naming conventions:**

Different frameworks use different prefixes for public variables:

**Next.js:** `NEXT_PUBLIC_`

```bash
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

**Vite:** `VITE_`

```bash
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
```

**Create React App:** `REACT_APP_`

```bash
REACT_APP_SUPABASE_URL=...
REACT_APP_SUPABASE_ANON_KEY=...
```

**SvelteKit:** No prefix needed, use `$env/static/public`

```bash
PUBLIC_SUPABASE_URL=...
PUBLIC_SUPABASE_ANON_KEY=...
```

### API key types and usage

**anon (public) key:**

- Safe to expose in client-side code
- Respects Row Level Security (RLS)
- Users can only access data allowed by RLS policies
- Used for client-side operations
- Cannot bypass security rules

```typescript
// Client-side usage
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY  // Safe to expose
)
```

**service_role key:**

- Must NEVER be exposed to client-side
- Bypasses all Row Level Security
- Full admin access to database
- Used for server-side operations only
- Administrative tasks, migrations, system operations

```typescript
// Server-side only
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY  // NEVER expose to client
)
```

### Finding API keys

**In Supabase Dashboard:**

1. Open project
2. Navigate to Settings → API
3. Copy keys from "Project API keys" section

**Two keys displayed:**

- `anon` / `public`: For client-side
- `service_role`: For server-side (hidden by default, click to reveal)

**Project URL:** Also on Settings → API page: `https://your-project-ref.supabase.co`

### Loading environment variables

**Next.js:**

```typescript
// Automatic loading from .env.local
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

**Vite:**

```typescript
const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)
```

**Node.js (with dotenv):**

```typescript
import 'dotenv/config'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
)
```

**SvelteKit:**

```typescript
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public'

const supabase = createClient(
  PUBLIC_SUPABASE_URL,
  PUBLIC_SUPABASE_ANON_KEY
)
```

### Security best practices

**Never commit sensitive keys:**

`.gitignore`:

```
.env
.env.local
.env.*.local
```

**Different keys per environment:**

`.env.development`:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://dev-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=dev-anon-key
```

`.env.production`:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://prod-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=prod-anon-key
```

**Validate environment variables:**

```typescript
function validateEnv() {
  const required = [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY'
  ]
  
  for (const key of required) {
    if (!process.env[key]) {
      throw new Error(`Missing required environment variable: ${key}`)
    }
  }
}

validateEnv()
```

**Type-safe environment variables:**

```typescript
// env.ts
export const env = {
  supabase: {
    url: process.env.NEXT_PUBLIC_SUPABASE_URL as string,
    anonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY as string,
  }
}

// Validate at startup
if (!env.supabase.url || !env.supabase.anonKey) {
  throw new Error('Missing Supabase environment variables')
}
```

**Rotate keys periodically:**

[Inference] While Supabase doesn't require regular key rotation, it's a security best practice:

1. Generate new keys in dashboard (Settings → API)
2. Update environment variables
3. Redeploy applications
4. Revoke old keys (if feature available)

## Client-side vs server-side usage

Understanding when and how to use Supabase client-side versus server-side is crucial for security and proper application architecture.

### Client-side usage

**Characteristics:**

- Runs in browser environment
- Uses anon key (respects RLS)
- Session stored in localStorage/sessionStorage
- Automatic token refresh
- Direct user interaction

**When to use client-side:**

- User authentication flows
- Querying data permitted by RLS
- Realtime subscriptions
- User-initiated CRUD operations
- File uploads by users
- Reading public data

**Example - React component:**

```typescript
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'

function UserProfile() {
  const [profile, setProfile] = useState(null)

  useEffect(() => {
    async function loadProfile() {
      // Client-side query - respects RLS
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', supabase.auth.getUser().data.user?.id)
        .single()
      
      setProfile(data)
    }
    
    loadProfile()
  }, [])

  return <div>{profile?.username}</div>
}
```

**Example - Authentication:**

```typescript
// Sign up - client-side
async function handleSignUp(email: string, password: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  })
  
  if (error) console.error(error)
  else console.log('User created:', data.user)
}

// Sign in - client-side
async function handleSignIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  
  if (error) console.error(error)
  else console.log('Signed in:', data.session)
}
```

**Example - Realtime subscription:**

```typescript
useEffect(() => {
  // Client-side realtime - respects RLS
  const channel = supabase
    .channel('public:posts')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'posts' },
      (payload) => {
        console.log('Change detected:', payload)
      }
    )
    .subscribe()

  return () => {
    supabase.removeChannel(channel)
  }
}, [])
```

### Server-side usage

**Characteristics:**

- Runs on server/serverless functions
- Can use service_role key (bypasses RLS)
- No session persistence needed
- No automatic token refresh
- Backend operations

**When to use server-side:**

- Administrative operations
- Bypassing RLS for system tasks
- Batch operations
- Scheduled jobs/cron tasks
- Server-side rendering with user context
- Webhook processing
- Data migrations

**Example - Next.js API route (service role):**

```typescript
// pages/api/admin/users.ts
import { createClient } from '@supabase/supabase-js'

export default async function handler(req, res) {
  // Server-side admin client - bypasses RLS
  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    }
  )

  // Can access all users regardless of RLS
  const { data: users } = await supabaseAdmin
    .from('profiles')
    .select('*')

  res.json(users)
}
```

**Example - Next.js API route (with user context):**

```typescript
// pages/api/user/profile.ts
import { createClient } from '@supabase/supabase-js'

export default async function handler(req, res) {
  // Get user token from request
  const token = req.headers.authorization?.replace('Bearer ', '')

  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  // Create client with user's token - respects RLS
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      global: {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    }
  )

  // Query runs with user's permissions
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .single()

  if (error) return res.status(400).json({ error: error.message })
  res.json(data)
}
```

**Example - Server-side rendering (Next.js):**

```typescript
// pages/posts/[id].tsx
import { createClient } from '@supabase/supabase-js'
import { GetServerSideProps } from 'next'

export const getServerSideProps: GetServerSideProps = async (context) => {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )

  const { data: post } = await supabase
    .from('posts')
    .select('*')
    .eq('id', context.params?.id)
    .single()

  return {
    props: { post }
  }
}

export default function Post({ post }) {
  return <article>{post.title}</article>
}
```

**Example - Scheduled task (Edge Function):**

```typescript
// supabase/functions/daily-cleanup/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  // Service role for admin operations
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Delete old records (bypasses RLS)
  const { error } = await supabaseAdmin
    .from('temp_data')
    .delete()
    .lt('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString())

  return new Response(
    JSON.stringify({ success: !error }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

### Hybrid patterns

**Server-side with user authentication:**

Use auth helpers to maintain user session server-side while respecting RLS.

**Next.js with auth helpers:**

```typescript
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export default async function ServerComponent() {
  // Server component with user session
  const supabase = createServerComponentClient({ cookies })
  
  // Query respects RLS for current user
  const { data: posts } = await supabase
    .from('posts')
    .select('*')
    .eq('user_id', (await supabase.auth.getUser()).data.user?.id)

  return <div>{posts?.map(p => <div key={p.id}>{p.title}</div>)}</div>
}
```

**SvelteKit load function:**

```typescript
// +page.server.ts
import { createServerClient } from '@supabase/auth-helpers-sveltekit'

export const load = async ({ locals, cookies }) => {
  const supabase = createServerClient(locals.supabase)
  
  const { data: posts } = await supabase
    .from('posts')
    .select('*')
  
  return { posts }
}
```

### Decision matrix

|Scenario|Client-Side|Server-Side|Key Type|
|---|---|---|---|
|User login|✓||anon|
|Fetch user's own data|✓|✓|anon|
|Admin dashboard||✓|service_role|
|Public data query|✓|✓|anon|
|Bulk data import||✓|service_role|
|Real-time subscriptions|✓||anon|
|Scheduled cleanup||✓|service_role|
|SSR with auth||✓|anon (with user token)|
|User file upload|✓||anon|
|System file operations||✓|service_role|

## Service role vs anon key

Understanding the difference between service_role and anon keys is critical for security.

### Anon key characteristics

**Security level:** Limited access

**RLS enforcement:** YES - always respects Row Level Security policies

**Use cases:**

- Client-side applications
- Mobile applications
- Public API access
- User-facing operations

**What anon key CAN do:**

- Query tables with proper RLS policies
- Authenticate users
- Access data permitted by RLS
- Subscribe to realtime changes (filtered by RLS)
- Upload files with storage policies
- Call Edge Functions

**What anon key CANNOT do:**

- Bypass RLS policies
- Access restricted data without proper policies
- Modify system tables
- Change database schema
- Access other users' data (unless policy allows)

**Example - Anon key behavior:**

```typescript
const supabase = createClient(url, anonKey)

// User A is logged in
await supabase.auth.signInWithPassword({ email: 'userA@example.com', password: 'pass' })

// Can only see own profile (if RLS policy allows)
const { data } = await supabase
  .from('profiles')
  .select('*')
// Returns only userA's profile due to RLS

// Cannot access other user's data
const { data: otherProfile } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', 'different-user-id')
// Returns null or error depending on RLS policy
```

**RLS policy example that anon key respects:**

```sql
-- Users can only read their own profile
CREATE POLICY "Users view own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- With anon key, this query only returns the authenticated user's profile
-- Cannot see other users' profiles
```

### Service role key characteristics

**Security level:** Full admin access

**RLS enforcement:** NO - bypasses all Row Level Security policies

**Use cases:**

- Server-side administrative tasks
- Data migrations
- Batch operations
- System maintenance
- Backend services
- Scheduled jobs

**What service_role key CAN do:**

- Access ALL data regardless of RLS
- Modify any table
- Create/alter schema
- Access system tables
- Bypass all security policies
- Perform bulk operations
- Administrative functions

**What service_role key MUST NEVER do:**

- Be exposed to client-side code
- Be committed to version control
- Be shared in public repositories
- Be used in browser/mobile apps

**Example - Service role behavior:**

```typescript
const supabaseAdmin = createClient(url, serviceRoleKey)

// No authentication needed
// Can access ALL profiles regardless of RLS
const { data: allProfiles } = await supabaseAdmin
  .from('profiles')
  .select('*')
// Returns EVERY user's profile

// Can modify any data
await supabaseAdmin
  .from('profiles')
  .update({ verified: true })
  .eq('email', 'someuser@example.com')
// Succeeds even if RLS would normally block this
```

### Security comparison

|Feature|Anon Key|Service Role Key|
|---|---|---|
|Bypasses RLS|No|Yes|
|Safe in client code|Yes|NO - NEVER|
|Requires authentication|For protected resources|No|
|Access scope|Limited by RLS|Full database access|
|Typical usage|Client-side|Server-side only|
|Can modify schema|No|Yes|
|Risk if exposed|Low|CRITICAL|

### Common mistakes and security risks

**CRITICAL MISTAKE - Exposing service role key:**

```typescript
// ❌ NEVER DO THIS
const supabase = createClient(
  'https://project.supabase.co',
  'eyJhbGciOiJIUz...'  // Service role key in client code = SECURITY BREACH
)
```

If service_role key is exposed:

- Anyone can access all database data
- Anyone can modify/delete all data
- All security is bypassed
- Must immediately rotate keys

**Correct approach:**

```typescript
// ✅ Client-side
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!  // Safe to expose
)

// ✅ Server-side only
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!  // Never exposed to client
)
```

### When to use each key

**Use anon key when:**

- Building client-side features
- Users interact directly
- RLS policies control access
- Authentication is handled by Supabase Auth
- Working in browser or mobile app

**Use service_role key when:**

- Running server-side scripts
- Performing administrative tasks
- Bypassing RLS intentionally for system operations
- Batch processing data
- Running in secure server environment
- No user context needed

**Example - Admin dashboard (correct pattern):**

Frontend (uses anon key):

```typescript
// components/AdminDashboard.tsx
async function fetchUsers() {
  // Call secure API route
  const response = await fetch('/api/admin/users', {
    headers: {
      'Authorization': `Bearer ${session.access_token}`
    }
  })
  const users = await response.json()
  return users
}
```

Backend API route (uses service_role key):

```typescript
// pages/api/admin/users.ts
import { createClient } from '@supabase/supabase-js'

export default async function handler(req, res) {
  // Verify user is admin (implement your auth logic)
  const isAdmin = await verifyAdminToken(req.headers.authorization)
  
  if (!isAdmin) {
    return res.status(403).json({ error: 'Forbidden' })
  }

  // Now safe to use service role
  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  const { data: users } = await supabaseAdmin
    .from('profiles')
    .select('*')

  res.json(users)
}
```

### Key rotation

If service_role key is accidentally exposed:

1. **Immediately rotate keys in dashboard:**
    
    - Settings → API → Generate new keys
2. **Update all server-side environment variables**
    
3. **Redeploy affected services**
    
4. **Audit database access logs** [Inference - if available on plan]
    
5. **Review RLS policies** to ensure data integrity
    

Anon key exposure is less critical but still recommended to rotate if concerned.

## Error handling patterns

Proper error handling ensures robust applications and good user experience.

### Error structure

Supabase errors follow a consistent structure:

```typescript
{
  error: {
    message: string,    // Human-readable error message
    details: string,    // Additional details
    hint: string,       // Helpful hint for resolution
    code: string        // Error code
  },
  data: null,
  count: null,
  status: number,       // HTTP status code
  statusText: string    // HTTP status text
}
```

### Basic error handling

**Simple try-catch:**

```typescript
try {
  const { data, error } = await supabase
    .from('posts')
    .select('*')
  
  if (error) throw error
  
  // Process data
  console.log(data)
} catch (error) {
  console.error('Error fetching posts:', error.message)
}
```

**Inline error checking:**

```typescript
const { data, error } = await supabase
  .from('posts')
  .select('*')

if (error) {
  console.error('Error:', error)
  return // or handle appropriately
}

// Safe to use data here
console.log(data)
```

### Common error types

**Authentication errors:**

```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'wrongpassword'
})

if (error) {
  switch (error.message) {
    case 'Invalid login credentials':
      // Wrong email/password
      showError('Incorrect email or password')
      break
    case 'Email not confirmed':
      // User hasn't verified email
      showError('Please verify your email first')
      break
    default:
      showError('Login failed')
  }
}
```

**Database query errors:**

```typescript
const { data, error } = await supabase
  .from('nonexistent_table')
  .select('*')

if (error) {
  // error.code might be '42P01' (undefined table)
  // error.message: 'relation "public.nonexistent_table" does not exist'
  
  if (error.code === '42P01') {
    console.error('Table does not exist')
  } else if (error.code === '42501') {
    console.error('Insufficient privileges')
  } else {
    console.error('Database error:', error.message)
  }
}
```

**RLS policy violations:**

```typescript
const { data, error } = await supabase
  .from('private_posts')
  .insert({ title: 'Test', user_id: 'other-user-id' })

if (error) {
  // error.code: '42501'
  // error.message: 'new row violates row-level security policy'
  
  if (error.code === '42501') {
    showError('You do not have permission to perform this action')
  }
}
```

**Network errors:**

```typescript
const { data, error } = await supabase
  .from('posts')
  .select('*')

if (error) {
  // Network-related errors
  if (error.message.includes('fetch') || error.message.includes('network')) {
    showError('Network error. Please check your connection.')
  }
}
```

**Storage errors:**

```typescript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('avatar.png', file)

if (error) {
  // error.message examples:
  // 'The resource already exists'
  // 'The object exceeded the maximum allowed size'
  // 'Bucket not found'
  
  if (error.message.includes('already exists')) {
    showError('File already exists')
  } else if (error.message.includes('size')) {
    showError('File is too large')
  } else if (error.message.includes('not found')) {
    showError('Storage bucket not found')
  }
}
```

### Advanced error handling patterns

**Custom error wrapper:**

```typescript
class DatabaseError extends Error {
  code: string
  details: string
  hint: string

  constructor(error: any) {
    super(error.message)
    this.name = 'DatabaseError'
    this.code = error.code
    this.details = error.details
    this.hint = error.hint
  }
}

async function queryWithErrorHandling<T>(
  query: Promise<{ data: T | null; error: any }>
): Promise<T> {
  const { data, error } = await query
  
  if (error) {
    throw new DatabaseError(error)
  }
  
  if (!data) {
    throw new Error('No data returned')
  }
  
  return data
}

// Usage
try {
  const posts = await queryWithErrorHandling(
    supabase.from('posts').select('*')
  )
  console.log(posts)
} catch (error) {
  if (error instanceof DatabaseError) {
    console.error('Database error:', error.message)
    console.error('Code:', error.code)
    console.error('Hint:', error.hint)
  }
}
```

**Result type pattern:**

```typescript
type Result<T> = 
  | { success: true; data: T }
  | { success: false; error: string }

async function fetchPosts(): Promise<Result<Post[]>> {
  const { data, error } = await supabase
    .from('posts')
    .select('*')
  
  if (error) {
    return { success: false, error: error.message }
  }
  
  return { success: true, data: data || [] }
}

// Usage
const result = await fetchPosts()

if (result.success) {
  console.log('Posts:', result.data)
} else {
  console.error('Error:', result.error)
}
```

**React error boundary integration:**

```typescript
import { Component, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
}

class SupabaseErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error) {
    // Log to error reporting service
    console.error('Supabase error caught:', error)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div>
          <h2>Something went wrong</h2>
          <details>
            <summary>Error details</summary>
            <pre>{this.state.error?.message}</pre>
          </details>
        </div>
      )
    }

    return this.props.children
  }
}

// Usage
function App() {
  return (
    <SupabaseErrorBoundary>
      <DataComponent />
    </SupabaseErrorBoundary>
  )
}
```

**Retry logic:**

```typescript
async function fetchWithRetry<T>(
  queryFn: () => Promise<{ data: T | null; error: any }>,
  maxRetries = 3,
  delay = 1000
): Promise<T> {
  let lastError: any
  
  for (let i = 0; i < maxRetries; i++) {
    const { data, error } = await queryFn()
    
    if (!error && data) {
      return data
    }
    
    lastError = error
    
    // Don't retry on certain errors
    if (error?.code === '42501') { // RLS violation
      break
    }
    
    if (i < maxRetries - 1) {
      await new Promise(resolve => setTimeout(resolve, delay * (i + 1)))
    }
  }
  
  throw new Error(`Failed after ${maxRetries} retries: ${lastError?.message}`)
}

// Usage
try {
  const posts = await fetchWithRetry(() =>
    supabase.from('posts').select('*')
  )
  console.log(posts)
} catch (error) {
  console.error('All retries failed:', error)
}
```

**Global error handler:**

```typescript
type ErrorHandler = (error: any, context?: string) => void

class SupabaseErrorHandler {
  private handlers: ErrorHandler[] = []
  
  addHandler(handler: ErrorHandler) {
    this.handlers.push(handler)
  }
  
  handle(error: any, context?: string) {
    this.handlers.forEach(handler => handler(error, context))
  }
}

const errorHandler = new SupabaseErrorHandler()

// Add logging
errorHandler.addHandler((error, context) => {
  console.error(`[${context}]`, error)
})

// Add user notification
errorHandler.addHandler((error, context) => {
  toast.error(`Error in ${context}: ${error.message}`)
})

// Add analytics
errorHandler.addHandler((error, context) => {
  analytics.track('supabase_error', {
    context,
    message: error.message,
    code: error.code
  })
})

// Usage
const { data, error } = await supabase.from('posts').select('*')
if (error) {
  errorHandler.handle(error, 'fetchPosts')
}
```

### React hooks with error handling

**Custom query hook:**

```typescript
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'

interface UseQueryResult<T> {
  data: T | null
  error: string | null
  loading: boolean
  refetch: () => void
}

function useSupabaseQuery<T>(
  query: () => Promise<{ data: T | null; error: any }>
): UseQueryResult<T> {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  const fetchData = async () => {
    setLoading(true)
    setError(null)
    
    try {
      const { data: result, error: queryError } = await query()
      
      if (queryError) {
        setError(queryError.message)
      } else {
        setData(result)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [])

  return { data, error, loading, refetch: fetchData }
}

// Usage
function PostsList() {
  const { data: posts, error, loading, refetch } = useSupabaseQuery(() =>
    supabase.from('posts').select('*')
  )

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>
  
  return (
    <div>
      {posts?.map(post => <div key={post.id}>{post.title}</div>)}
      <button onClick={refetch}>Refresh</button>
    </div>
  )
}
```

**Custom mutation hook:**

```typescript
import { useState } from 'react'

interface UseMutationResult<TData, TVariables> {
  mutate: (variables: TVariables) => Promise<void>
  data: TData | null
  error: string | null
  loading: boolean
  reset: () => void
}

function useSupabaseMutation<TData, TVariables>(
  mutationFn: (variables: TVariables) => Promise<{ data: TData | null; error: any }>
): UseMutationResult<TData, TVariables> {
  const [data, setData] = useState<TData | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const mutate = async (variables: TVariables) => {
    setLoading(true)
    setError(null)
    
    try {
      const { data: result, error: mutationError } = await mutationFn(variables)
      
      if (mutationError) {
        setError(mutationError.message)
        throw new Error(mutationError.message)
      } else {
        setData(result)
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error'
      setError(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  const reset = () => {
    setData(null)
    setError(null)
    setLoading(false)
  }

  return { mutate, data, error, loading, reset }
}

// Usage
function CreatePost() {
  const { mutate, error, loading } = useSupabaseMutation<Post, { title: string }>(
    (variables) =>
      supabase.from('posts').insert({ title: variables.title }).select().single()
  )

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    
    try {
      await mutate({ title: formData.get('title') as string })
      alert('Post created!')
    } catch (err) {
      // Error already set in state
      console.error('Failed to create post')
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="title" required />
      <button disabled={loading}>
        {loading ? 'Creating...' : 'Create Post'}
      </button>
      {error && <div className="error">{error}</div>}
    </form>
  )
}
```

### Error logging and monitoring

**Integration with Sentry:**

```typescript
import * as Sentry from '@sentry/browser'

function logSupabaseError(error: any, context: string) {
  Sentry.captureException(error, {
    tags: {
      component: 'supabase',
      context
    },
    extra: {
      code: error.code,
      details: error.details,
      hint: error.hint
    }
  })
}

// Usage
const { data, error } = await supabase.from('posts').select('*')
if (error) {
  logSupabaseError(error, 'fetchPosts')
}
```

**Custom error logger:**

```typescript
interface ErrorLog {
  timestamp: Date
  error: any
  context: string
  userId?: string
}

class ErrorLogger {
  private logs: ErrorLog[] = []
  
  log(error: any, context: string) {
    const log: ErrorLog = {
      timestamp: new Date(),
      error: {
        message: error.message,
        code: error.code,
        details: error.details
      },
      context,
      userId: supabase.auth.getUser().data.user?.id
    }
    
    this.logs.push(log)
    
    // Send to backend
    this.sendToBackend(log)
    
    // Keep only last 100 logs in memory
    if (this.logs.length > 100) {
      this.logs.shift()
    }
  }
  
  private async sendToBackend(log: ErrorLog) {
    try {
      await fetch('/api/logs/error', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(log)
      })
    } catch (err) {
      // Silently fail - don't want logging errors to break app
      console.warn('Failed to send error log:', err)
    }
  }
  
  getLogs() {
    return this.logs
  }
}

const logger = new ErrorLogger()

// Usage
const { data, error } = await supabase.from('posts').select('*')
if (error) {
  logger.log(error, 'fetchPosts')
}
```

### User-friendly error messages

**Error message mapper:**

```typescript
const errorMessages: Record<string, string> = {
  // Auth errors
  'Invalid login credentials': 'The email or password you entered is incorrect.',
  'Email not confirmed': 'Please check your email and confirm your account.',
  'User already registered': 'An account with this email already exists.',
  
  // Database errors
  '42501': 'You do not have permission to perform this action.',
  '23505': 'This record already exists.',
  '23503': 'Cannot delete this record because it is referenced by other data.',
  
  // Storage errors
  'The resource already exists': 'A file with this name already exists.',
  'Bucket not found': 'The storage location was not found.',
  
  // Network errors
  'Failed to fetch': 'Network error. Please check your internet connection.',
  'NetworkError': 'Unable to connect. Please try again.',
}

function getUserFriendlyError(error: any): string {
  // Check by error code first
  if (error.code && errorMessages[error.code]) {
    return errorMessages[error.code]
  }
  
  // Check by error message
  for (const [key, message] of Object.entries(errorMessages)) {
    if (error.message?.includes(key)) {
      return message
    }
  }
  
  // Default fallback
  return 'An unexpected error occurred. Please try again.'
}

// Usage
const { data, error } = await supabase.auth.signInWithPassword({
  email,
  password
})

if (error) {
  const friendlyMessage = getUserFriendlyError(error)
  showToast(friendlyMessage, 'error')
}
```

### Validation before queries

**Prevent common errors:**

```typescript
function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

async function signIn(email: string, password: string) {
  // Validate before sending request
  if (!validateEmail(email)) {
    return { error: { message: 'Please enter a valid email address' } }
  }
  
  if (password.length < 6) {
    return { error: { message: 'Password must be at least 6 characters' } }
  }
  
  // Now make the request
  return await supabase.auth.signInWithPassword({ email, password })
}
```

**Type guards:**

```typescript
function isSupabaseError(error: any): error is { message: string; code: string } {
  return error && typeof error.message === 'string'
}

const { data, error } = await supabase.from('posts').select('*')

if (error) {
  if (isSupabaseError(error)) {
    console.error('Supabase error:', error.message, error.code)
  } else {
    console.error('Unknown error:', error)
  }
}
```

## TypeScript type generation

TypeScript types ensure type safety when working with your database schema.

### Generating types with CLI

**Basic type generation:**

```bash
supabase gen types typescript --local > types/supabase.ts
```

**From linked project:**

```bash
supabase gen types typescript --linked > types/supabase.ts
```

**Specific project:**

```bash
supabase gen types typescript --project-id your-project-ref > types/supabase.ts
```

**Multiple schemas:**

```bash
supabase gen types typescript --schema public --schema auth > types/supabase.ts
```

### Generated type structure

**Example database schema:**

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE posts (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  author_id UUID REFERENCES profiles(id),
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Generated types:**

```typescript
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          username: string
          full_name: string | null
          avatar_url: string | null
          created_at: string
        }
        Insert: {
          id?: string
          username: string
          full_name?: string | null
          avatar_url?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          username?: string
          full_name?: string | null
          avatar_url?: string | null
          created_at?: string
        }
        Relationships: []
      }
      posts: {
        Row: {
          id: number
          title: string
          content: string | null
          author_id: string | null
          published: boolean | null
          created_at: string
        }
        Insert: {
          id?: number
          title: string
          content?: string | null
          author_id?: string | null
          published?: boolean | null
          created_at?: string
        }
        Update: {
          id?: number
          title?: string
          content?: string | null
          author_id?: string | null
          published?: boolean | null
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "posts_author_id_fkey"
            columns: ["author_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}
```

### Using types with client

**Basic typed client:**

```typescript
import { createClient } from '@supabase/supabase-js'
import { Database } from './types/supabase'

const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// Now queries are fully typed
const { data } = await supabase
  .from('profiles')  // ✓ Type-checked table name
  .select('username, full_name')  // ✓ Type-checked column names
  .eq('id', 'uuid')  // ✓ Type-checked

// data is typed as:
// Array<{ username: string; full_name: string | null }> | null
```

**Type inference in queries:**

```typescript
// TypeScript knows the exact shape of returned data
const { data: profile } = await supabase
  .from('profiles')
  .select('username, full_name, avatar_url')
  .eq('id', userId)
  .single()

// profile is typed as:
// {
//   username: string
//   full_name: string | null
//   avatar_url: string | null
// } | null

// Autocomplete works
console.log(profile?.username)  // ✓
console.log(profile?.nonexistent)  // ✗ TypeScript error
```

**Insert with types:**

```typescript
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'My Post',
    content: 'Content here',
    author_id: userId,
    published: true
  })
  // TypeScript validates all fields
  // Missing 'title' would cause error
  // Wrong type for 'published' would cause error
```

**Update with types:**

```typescript
const { data, error } = await supabase
  .from('profiles')
  .update({
    full_name: 'John Doe',
    avatar_url: 'https://example.com/avatar.jpg'
  })
  .eq('id', userId)
  // All fields are optional
  // Only provided fields will be updated
```

### Type helpers

**Extract specific types:**

```typescript
import { Database } from './types/supabase'

// Get Row type for a table
type Profile = Database['public']['Tables']['profiles']['Row']

// Get Insert type for a table
type ProfileInsert = Database['public']['Tables']['profiles']['Insert']

// Get Update type for a table
type ProfileUpdate = Database['public']['Tables']['profiles']['Update']

// Use in functions
function createProfile(profile: ProfileInsert) {
  return supabase.from('profiles').insert(profile)
}

function updateProfile(id: string, updates: ProfileUpdate) {
  return supabase.from('profiles').update(updates).eq('id', id)
}
```

**Custom type aliases:**

```typescript
// types/database.ts
import { Database } from './supabase'

export type Tables<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Row']

export type Inserts<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Insert']

export type Updates<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Update']

// Usage
export type Profile = Tables<'profiles'>
export type Post = Tables<'posts'>
export type PostInsert = Inserts<'posts'>
export type PostUpdate = Updates<'posts'>
```

**Join type inference:**

```typescript
const { data } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    content,
    author:profiles(username, avatar_url)
  `)

// data is typed as:
// Array<{
//   id: number
//   title: string
//   content: string | null
//   author: {
//     username: string
//     avatar_url: string | null
//   } | null
// }> | null
```

### Enum types

**Database enum:**

```sql
CREATE TYPE user_role AS ENUM ('admin', 'moderator', 'user');

ALTER TABLE profiles ADD COLUMN role user_role DEFAULT 'user';
```

**Generated enum type:**

```typescript
export interface Database {
  public: {
    Enums: {
      user_role: 'admin' | 'moderator' | 'user'
    }
    Tables: {
      profiles: {
        Row: {
          role: Database['public']['Enums']['user_role']
          // ...
        }
      }
    }
  }
}

// Extract enum type
type UserRole = Database['public']['Enums']['user_role']

// Use in code
function checkRole(role: UserRole) {
  if (role === 'admin') {
    // ...
  }
}
```

### Function types

**Database function:**

```sql
CREATE FUNCTION get_user_posts(user_id UUID)
RETURNS TABLE(id BIGINT, title TEXT, created_at TIMESTAMPTZ) AS $$
  SELECT id, title, created_at FROM posts WHERE author_id = user_id;
$$ LANGUAGE SQL;
```

**Generated function type:**

```typescript
export interface Database {
  public: {
    Functions: {
      get_user_posts: {
        Args: {
          user_id: string
        }
        Returns: Array<{
          id: number
          title: string
          created_at: string
        }>
      }
    }
  }
}

// Call with types
const { data, error } = await supabase
  .rpc('get_user_posts', {
    user_id: userId  // Type-checked parameter
  })

// data is typed as Return type
```

### Automating type generation

**npm script:**

`package.json`:

```json
{
  "scripts": {
    "types": "supabase gen types typescript --linked > types/supabase.ts",
    "types:local": "supabase gen types typescript --local > types/supabase.ts"
  }
}
```

Run with:

```bash
npm run types
```

**Pre-commit hook:**

`.husky/pre-commit`:

```bash
#!/bin/sh
npm run types
git add types/supabase.ts
```

**CI/CD integration:**

`.github/workflows/types.yml`:

```yaml
name: Update Types

on:
  push:
    paths:
      - 'supabase/migrations/**'

jobs:
  update-types:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install Supabase CLI
        run: npm install -g supabase
      
      - name: Generate Types
        run: |
          supabase gen types typescript --project-id ${{ secrets.SUPABASE_PROJECT_ID }} > types/supabase.ts
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
      
      - name: Commit Types
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add types/supabase.ts
          git commit -m "Update database types" || echo "No changes"
          git push
```

### Type safety best practices

**Always regenerate after schema changes:**

```bash
# After running migrations
supabase db push
npm run types
```

**Use strict TypeScript config:**

`tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true
  }
}
```

**Validate at runtime:**

```typescript
import { z } from 'zod'

const ProfileSchema = z.object({
  id: z.string().uuid(),
  username: z.string(),
  full_name: z.string().nullable(),
  avatar_url: z.string().url().nullable()
})

async function getProfile(id: string) {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', id)
    .single()
  
  if (error) throw error
  
  // Validate at runtime
  return ProfileSchema.parse(data)
}
```

## Other language clients (Python, Dart, etc.)

Supabase provides official and community-maintained clients for multiple programming languages.

### Python client (supabase-py)

**Installation:**

```bash
pip install supabase
```

**Basic usage:**

```python
from supabase import create_client, Client

url: str = "https://your-project-ref.supabase.co"
key: str = "your-anon-key"
supabase: Client = create_client(url, key)

# Query data
response = supabase.table("profiles").select("*").execute()
print(response.data)

# Insert data
data = supabase.table("posts").insert({
    "title": "My Post",
    "content": "Content here"
}).execute()

# Update data
data = supabase.table("posts").update({
    "title": "Updated Title"
}).eq("id", 1).execute()

# Delete data
data = supabase.table("posts").delete().eq("id", 1).execute()
```

**Authentication:**

```python
# Sign up
user = supabase.auth.sign_up({
    "email": "user@example.com",
    "password": "password123"
})

# Sign in
session = supabase.auth.sign_in_with_password({
    "email": "user@example.com",
    "password": "password123"
})

# Get current user
user = supabase.auth.get_user()

# Sign out
supabase.auth.sign_out()
```

**Storage:**

```python
# Upload file
with open("file.pdf", "rb") as f:
    supabase.storage.from_("documents").upload("file.pdf", f)

# Download file
res = supabase.storage.from_("documents").download("file.pdf")

# List files
files = supabase.storage.from_("documents").list()

# Delete file
supabase.storage.from_("documents").remove(["file.pdf"])
```

### Dart/Flutter client (supabase-flutter)

**Installation:**

`pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

**Initialization:**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://your-project-ref.supabase.co',
    anonKey: 'your-anon-key',
  );
  
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
```

**Query data:**

```dart
final response = await supabase
  .from('profiles')
  .select()
  .eq('id', userId);

final profiles = response as List<dynamic>;
```

**Insert data:**

```dart
await supabase.from('posts').insert({
  'title': 'My Post',
  'content': 'Content here',
  'author_id': userId,
});
```

**Authentication:**

```dart
// Sign up
final AuthResponse res = await supabase.auth.signUp(
  email: 'email@example.com',
  password: 'password123',
);

// Sign in
final AuthResponse res = await supabase.auth.signInWithPassword(
  email: 'email@example.com',
  password: 'password123',
);

// Get current user
final User?
user = supabase.auth.currentUser;

// Sign out await supabase.auth.signOut();

// Listen to auth state changes supabase.auth.onAuthStateChange.listen((data) { final AuthChangeEvent event = data.event; final Session? session = data.session;

if (event == AuthChangeEvent.signedIn) { print('User signed in'); } });
````

**Realtime subscriptions:**
```dart
final channel = supabase
  .channel('public:posts')
  .on(
    RealtimeListenTypes.postgresChanges,
    ChannelFilter(
      event: 'INSERT',
      schema: 'public',
      table: 'posts',
    ),
    (payload, [ref]) {
      print('New post: ${payload}');
    },
  )
  .subscribe();

// Unsubscribe when done
await supabase.removeChannel(channel);
````

**Storage:**

```dart
// Upload file
final file = File('path/to/file.jpg');
await supabase.storage
  .from('avatars')
  .upload('public/avatar.jpg', file);

// Download file
final bytes = await supabase.storage
  .from('avatars')
  .download('public/avatar.jpg');

// Get public URL
final url = supabase.storage
  .from('avatars')
  .getPublicUrl('public/avatar.jpg');
```

### Kotlin client (supabase-kt)

**Installation (Gradle):**

```kotlin
dependencies {
    implementation("io.github.jan-tennert.supabase:postgrest-kt:VERSION")
    implementation("io.github.jan-tennert.supabase:gotrue-kt:VERSION")
    implementation("io.github.jan-tennert.supabase:storage-kt:VERSION")
    implementation("io.github.jan-tennert.supabase:realtime-kt:VERSION")
}
```

**Initialization:**

```kotlin
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.postgrest.Postgrest
import io.github.jan.supabase.gotrue.GoTrue

val supabase = createSupabaseClient(
    supabaseUrl = "https://your-project-ref.supabase.co",
    supabaseKey = "your-anon-key"
) {
    install(Postgrest)
    install(GoTrue)
}
```

**Query data:**

```kotlin
@Serializable
data class Profile(
    val id: String,
    val username: String,
    val full_name: String?
)

val profiles = supabase.from("profiles")
    .select()
    .decodeList<Profile>()
```

**Insert data:**

```kotlin
@Serializable
data class PostInsert(
    val title: String,
    val content: String?,
    val author_id: String
)

supabase.from("posts").insert(
    PostInsert(
        title = "My Post",
        content = "Content",
        author_id = userId
    )
)
```

**Authentication:**

```kotlin
// Sign up
supabase.gotrue.signUpWith(Email) {
    email = "user@example.com"
    password = "password123"
}

// Sign in
supabase.gotrue.loginWith(Email) {
    email = "user@example.com"
    password = "password123"
}

// Get session
val session = supabase.gotrue.currentSessionOrNull()

// Sign out
supabase.gotrue.logout()
```

### Swift client (supabase-swift)

**Installation (Swift Package Manager):**

Add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0")
]
```

**Initialization:**

```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://your-project-ref.supabase.co")!,
    supabaseKey: "your-anon-key"
)
```

**Query data:**

```swift
struct Profile: Codable {
    let id: UUID
    let username: String
    let fullName: String?
}

let profiles: [Profile] = try await supabase
    .from("profiles")
    .select()
    .execute()
    .value
```

**Insert data:**

```swift
struct PostInsert: Codable {
    let title: String
    let content: String?
    let authorId: UUID
}

try await supabase
    .from("posts")
    .insert(PostInsert(
        title: "My Post",
        content: "Content",
        authorId: userId
    ))
    .execute()
```

**Authentication:**

```swift
// Sign up
try await supabase.auth.signUp(
    email: "user@example.com",
    password: "password123"
)

// Sign in
try await supabase.auth.signIn(
    email: "user@example.com",
    password: "password123"
)

// Get session
let session = try await supabase.auth.session

// Sign out
try await supabase.auth.signOut()
```

### C# client (supabase-csharp)

**Installation (NuGet):**

```bash
dotnet add package supabase-csharp
```

**Initialization:**

```csharp
using Supabase;

var url = "https://your-project-ref.supabase.co";
var key = "your-anon-key";
var options = new SupabaseOptions
{
    AutoConnectRealtime = true
};

var supabase = new Supabase.Client(url, key, options);
await supabase.InitializeAsync();
```

**Query data:**

```csharp
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("profiles")]
public class Profile : BaseModel
{
    [PrimaryKey("id")]
    public Guid Id { get; set; }
    
    [Column("username")]
    public string Username { get; set; }
    
    [Column("full_name")]
    public string FullName { get; set; }
}

var response = await supabase
    .From<Profile>()
    .Get();

var profiles = response.Models;
```

**Insert data:**

```csharp
var newPost = new Post
{
    Title = "My Post",
    Content = "Content here",
    AuthorId = userId
};

await supabase.From<Post>().Insert(newPost);
```

**Authentication:**

```csharp
// Sign up
var session = await supabase.Auth.SignUp("user@example.com", "password123");

// Sign in
var session = await supabase.Auth.SignIn("user@example.com", "password123");

// Get current user
var user = supabase.Auth.CurrentUser;

// Sign out
await supabase.Auth.SignOut();
```

### Go client (supabase-go)

**Installation:**

```bash
go get github.com/supabase-community/supabase-go
```

**Initialization:**

```go
package main

import (
    "github.com/supabase-community/supabase-go"
)

func main() {
    client, err := supabase.NewClient(
        "https://your-project-ref.supabase.co",
        "your-anon-key",
        nil,
    )
    if err != nil {
        panic(err)
    }
}
```

**Query data:**

```go
type Profile struct {
    ID       string  `json:"id"`
    Username string  `json:"username"`
    FullName *string `json:"full_name"`
}

var profiles []Profile
err := client.DB.From("profiles").Select("*").Execute(&profiles)
if err != nil {
    panic(err)
}
```

**Insert data:**

```go
type PostInsert struct {
    Title    string  `json:"title"`
    Content  *string `json:"content"`
    AuthorID string  `json:"author_id"`
}

post := PostInsert{
    Title:    "My Post",
    Content:  stringPtr("Content here"),
    AuthorID: userID,
}

err := client.DB.From("posts").Insert(post).Execute(nil)
if err != nil {
    panic(err)
}
```

**Authentication:**

```go
// Sign up
user, err := client.Auth.SignUp(supabase.UserCredentials{
    Email:    "user@example.com",
    Password: "password123",
})

// Sign in
session, err := client.Auth.SignIn(supabase.UserCredentials{
    Email:    "user@example.com",
    Password: "password123",
})

// Sign out
err := client.Auth.SignOut(session.AccessToken)
```

### Ruby client (supabase-rb)

**Installation:**

```bash
gem install supabase
```

**Initialization:**

```ruby
require 'supabase'

supabase = Supabase::Client.new(
  supabase_url: 'https://your-project-ref.supabase.co',
  supabase_key: 'your-anon-key'
)
```

**Query data:**

```ruby
response = supabase
  .from('profiles')
  .select('*')
  .execute

profiles = response.body
```

**Insert data:**

```ruby
response = supabase
  .from('posts')
  .insert({
    title: 'My Post',
    content: 'Content here',
    author_id: user_id
  })
  .execute
```

**Authentication:**

```ruby
# Sign up
user = supabase.auth.sign_up(
  email: 'user@example.com',
  password: 'password123'
)

# Sign in
session = supabase.auth.sign_in(
  email: 'user@example.com',
  password: 'password123'
)

# Sign out
supabase.auth.sign_out(session['access_token'])
```

### PHP client (supabase-php)

**Installation (Composer):**

```bash
composer require supabase/supabase-php
```

**Initialization:**

```php
<?php
require 'vendor/autoload.php';

use Supabase\CreateClientOptions;
use Supabase\SupabaseClient;

$supabase = new SupabaseClient(
    'https://your-project-ref.supabase.co',
    'your-anon-key'
);
```

**Query data:**

```php
$response = $supabase
    ->from('profiles')
    ->select('*')
    ->execute();

$profiles = $response->data;
```

**Insert data:**

```php
$response = $supabase
    ->from('posts')
    ->insert([
        'title' => 'My Post',
        'content' => 'Content here',
        'author_id' => $userId
    ])
    ->execute();
```

**Authentication:**

```php
// Sign up
$user = $supabase->auth->signUp(
    'user@example.com',
    'password123'
);

// Sign in
$session = $supabase->auth->signInWithPassword(
    'user@example.com',
    'password123'
);

// Get user
$user = $supabase->auth->getUser($session->access_token);

// Sign out
$supabase->auth->signOut($session->access_token);
```

### Rust client (postgrest-rs)

**Installation (Cargo.toml):**

```toml
[dependencies]
postgrest = "1.0"
```

**Basic usage:**

```rust
use postgrest::Postgrest;

#[tokio::main]
async fn main() {
    let client = Postgrest::new("https://your-project-ref.supabase.co/rest/v1")
        .insert_header("apikey", "your-anon-key");

    let resp = client
        .from("profiles")
        .select("*")
        .execute()
        .await
        .unwrap();

    let body = resp.text().await.unwrap();
    println!("{}", body);
}
```

**Insert data:**

```rust
let resp = client
    .from("posts")
    .insert(r#"{"title": "My Post", "content": "Content"}"#)
    .execute()
    .await
    .unwrap();
```

### Community clients

**Elixir (supabase-elixir):**

```elixir
# mix.exs
defp deps do
  [
    {:supabase, "~> 0.3"}
  ]
end

# Usage
{:ok, response} = Supabase.init(%{
  base_url: "https://your-project-ref.supabase.co",
  api_key: "your-anon-key"
})
|> Supabase.from("profiles")
|> Supabase.select()
|> Supabase.execute()
```

**Deno (supabase-js):**

```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
)

const { data, error } = await supabase
  .from('profiles')
  .select('*')
```

### Client feature comparison

|Feature|JS/TS|Python|Dart|Swift|Kotlin|C#|Go|Ruby|PHP|
|---|---|---|---|---|---|---|---|---|---|
|Database queries|✓|✓|✓|✓|✓|✓|✓|✓|✓|
|Authentication|✓|✓|✓|✓|✓|✓|✓|✓|✓|
|Storage|✓|✓|✓|✓|✓|✓|Limited|Limited|Limited|
|Realtime|✓|✓|✓|✓|✓|✓|Limited|Limited|Limited|
|Edge Functions|✓|✓|✓|✓|✓|Limited|Limited|Limited|Limited|
|Type generation|✓|Manual|Manual|Manual|Manual|Manual|Manual|Manual|Manual|
|Official support|✓|✓|✓|Community|Community|Community|Community|Community|Community|

### Client selection criteria

**Choose JavaScript/TypeScript if:**

- Building web applications
- Need full feature support
- Want automatic type generation
- Official support and frequent updates

**Choose Python if:**

- Building data processing pipelines
- Backend services in Python
- Machine learning integrations
- Scripting and automation

**Choose Dart/Flutter if:**

- Building mobile apps (iOS/Android)
- Need cross-platform mobile solution
- Flutter ecosystem

**Choose Swift if:**

- Native iOS/macOS applications
- Need best iOS performance
- Apple platform integration

**Choose Kotlin if:**

- Native Android applications
- JVM-based backend services
- Kotlin multiplatform projects

**Choose C# if:**

- .NET/ASP.NET applications
- Unity game development
- Windows desktop applications

**Choose Go if:**

- High-performance backend services
- Microservices architecture
- CLI tools

**Choose Ruby if:**

- Ruby on Rails applications
- Existing Ruby infrastructure

**Choose PHP if:**

- Legacy PHP applications
- WordPress integrations
- Shared hosting environments

### Installation troubleshooting

**Common issues across clients:**

**Missing dependencies:** Ensure all peer dependencies are installed per client documentation.

**Authentication errors:** Verify API keys and project URL are correct.

**CORS errors (browser-based clients):** Configure CORS in Supabase dashboard (Authentication → URL Configuration).

**Network timeouts:** Check network connectivity and firewall settings.

**SSL certificate errors:** Ensure system certificates are up to date.

**Type mismatches (typed clients):** Regenerate types after schema changes.

For language-specific issues, consult the respective client repository's issue tracker and documentation.

Related topics: **Authentication (GoTrue)** for implementing user authentication, **Database Queries (CRUD Operations)** for data manipulation, **Row Level Security** for securing data access with policies, **Realtime** for implementing real-time features.

---

# Database Queries (CRUD Operations)

CRUD operations—Create, Read, Update, Delete—form the foundation of database interactions. In Supabase, these operations can be performed through raw SQL, the Supabase JavaScript client, or auto-generated REST APIs. Understanding both SQL and client library approaches provides flexibility for different use cases.

## SELECT Queries and Filtering

SELECT queries retrieve data from tables based on specified criteria.

**Basic SELECT syntax:**

```sql
-- Select all columns
SELECT * FROM posts;

-- Select specific columns
SELECT id, title, created_at FROM posts;

-- Select with alias
SELECT 
  id,
  title as post_title,
  author_id as author
FROM posts;

-- Select distinct values
SELECT DISTINCT category FROM posts;

-- Select with computed columns
SELECT 
  title,
  LENGTH(content) as content_length,
  created_at,
  EXTRACT(YEAR FROM created_at) as year
FROM posts;
```

**WHERE clause for filtering:**

```sql
-- Equality
SELECT * FROM posts WHERE status = 'published';

-- Multiple conditions with AND
SELECT * FROM posts 
WHERE status = 'published' 
  AND author_id = 'uuid-here';

-- Multiple conditions with OR
SELECT * FROM posts 
WHERE status = 'published' 
  OR status = 'featured';

-- Combining AND/OR with parentheses
SELECT * FROM posts 
WHERE (status = 'published' OR status = 'featured')
  AND created_at > NOW() - INTERVAL '7 days';

-- NULL checks
SELECT * FROM posts WHERE deleted_at IS NULL;
SELECT * FROM posts WHERE featured_image IS NOT NULL;

-- IN operator
SELECT * FROM posts WHERE category IN ('tech', 'science', 'education');

-- NOT IN
SELECT * FROM posts WHERE status NOT IN ('draft', 'archived');

-- BETWEEN
SELECT * FROM posts 
WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';

-- LIKE for pattern matching (case-sensitive)
SELECT * FROM posts WHERE title LIKE '%PostgreSQL%';
SELECT * FROM posts WHERE title LIKE 'How to%';  -- Starts with
SELECT * FROM posts WHERE email LIKE '%@gmail.com';  -- Ends with

-- ILIKE for case-insensitive pattern matching
SELECT * FROM posts WHERE title ILIKE '%postgresql%';

-- Pattern matching wildcards:
-- % matches any sequence of characters
-- _ matches any single character
SELECT * FROM users WHERE phone LIKE '555-____';
```

**Comparison operators:**

```sql
-- Greater than / Less than
SELECT * FROM products WHERE price > 100;
SELECT * FROM products WHERE stock < 10;

-- Greater than or equal / Less than or equal
SELECT * FROM users WHERE age >= 18;
SELECT * FROM orders WHERE total <= 50.00;

-- Not equal
SELECT * FROM posts WHERE status != 'draft';
SELECT * FROM posts WHERE status <> 'draft';  -- Alternative syntax
```

**Supabase JavaScript client SELECT:**

```javascript
// Select all columns
const { data, error } = await supabase
  .from('posts')
  .select('*');

// Select specific columns
const { data, error } = await supabase
  .from('posts')
  .select('id, title, created_at');

// Select with filtering
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .gt('created_at', '2024-01-01');

// Select with multiple filters
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .gte('likes', 10)
  .order('created_at', { ascending: false });

// Select with OR conditions
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .or('status.eq.published,status.eq.featured');

// Select with NULL checks
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .is('deleted_at', null);

const { data, error } = await supabase
  .from('posts')
  .select('*')
  .not('featured_image', 'is', null);
```

## INSERT Operations

INSERT operations add new rows to tables.

**SQL INSERT syntax:**

```sql
-- Insert single row
INSERT INTO posts (title, content, author_id, status)
VALUES ('My First Post', 'This is the content', 'uuid-here', 'draft');

-- Insert with default values
INSERT INTO posts (title, content, author_id)
VALUES ('Another Post', 'More content', 'uuid-here');
-- status will use DEFAULT value if defined

-- Insert multiple rows
INSERT INTO posts (title, content, author_id) VALUES
  ('Post 1', 'Content 1', 'uuid-1'),
  ('Post 2', 'Content 2', 'uuid-2'),
  ('Post 3', 'Content 3', 'uuid-3');

-- Insert from SELECT (copy data from another table)
INSERT INTO archived_posts (id, title, content, author_id)
SELECT id, title, content, author_id
FROM posts
WHERE created_at < NOW() - INTERVAL '1 year';

-- Insert and return inserted row
INSERT INTO posts (title, content, author_id)
VALUES ('New Post', 'Fresh content', 'uuid-here')
RETURNING *;

-- Insert and return specific columns
INSERT INTO posts (title, content, author_id)
VALUES ('New Post', 'Fresh content', 'uuid-here')
RETURNING id, created_at;
```

**Handling conflicts with UPSERT (INSERT ... ON CONFLICT):**

```sql
-- Insert or do nothing if conflict
INSERT INTO users (id, email, full_name)
VALUES ('uuid-here', 'user@example.com', 'John Doe')
ON CONFLICT (email) DO NOTHING;

-- Insert or update if conflict (UPSERT)
INSERT INTO users (id, email, full_name, updated_at)
VALUES ('uuid-here', 'user@example.com', 'John Doe', NOW())
ON CONFLICT (email) 
DO UPDATE SET 
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- Upsert with condition
INSERT INTO page_views (page_id, view_count)
VALUES ('page-uuid', 1)
ON CONFLICT (page_id)
DO UPDATE SET 
  view_count = page_views.view_count + 1,
  updated_at = NOW();
```

**Supabase JavaScript client INSERT:**

```javascript
// Insert single row
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'My First Post',
    content: 'This is the content',
    author_id: 'uuid-here',
    status: 'draft'
  })
  .select();  // Returns inserted row

// Insert without returning data
const { error } = await supabase
  .from('posts')
  .insert({
    title: 'My First Post',
    content: 'This is the content',
    author_id: 'uuid-here'
  });

// Insert multiple rows
const { data, error } = await supabase
  .from('posts')
  .insert([
    { title: 'Post 1', content: 'Content 1', author_id: 'uuid-1' },
    { title: 'Post 2', content: 'Content 2', author_id: 'uuid-2' },
    { title: 'Post 3', content: 'Content 3', author_id: 'uuid-3' }
  ])
  .select();

// Upsert (insert or update if exists)
const { data, error } = await supabase
  .from('users')
  .upsert({
    id: 'uuid-here',
    email: 'user@example.com',
    full_name: 'John Doe'
  })
  .select();

// Upsert with onConflict option
const { data, error } = await supabase
  .from('users')
  .upsert(
    { email: 'user@example.com', full_name: 'John Doe' },
    { onConflict: 'email' }
  )
  .select();

// Insert with ignoreDuplicates option
const { data, error } = await supabase
  .from('users')
  .upsert(
    { email: 'user@example.com', full_name: 'John Doe' },
    { onConflict: 'email', ignoreDuplicates: true }
  )
  .select();
```

## UPDATE Operations

UPDATE operations modify existing rows in tables.

**SQL UPDATE syntax:**

```sql
-- Update single column
UPDATE posts 
SET status = 'published' 
WHERE id = 'uuid-here';

-- Update multiple columns
UPDATE posts 
SET 
  status = 'published',
  published_at = NOW(),
  updated_at = NOW()
WHERE id = 'uuid-here';

-- Update with computation
UPDATE products 
SET price = price * 1.1  -- Increase price by 10%
WHERE category = 'electronics';

-- Update from another table's data
UPDATE posts p
SET author_name = u.full_name
FROM users u
WHERE p.author_id = u.id;

-- Update with subquery
UPDATE posts
SET view_count = (
  SELECT COUNT(*) 
  FROM page_views 
  WHERE page_views.post_id = posts.id
)
WHERE id = 'uuid-here';

-- Update and return updated rows
UPDATE posts
SET status = 'published', published_at = NOW()
WHERE status = 'draft' AND created_at < NOW() - INTERVAL '7 days'
RETURNING *;

-- Conditional update
UPDATE users
SET status = CASE
  WHEN last_login < NOW() - INTERVAL '90 days' THEN 'inactive'
  WHEN last_login < NOW() - INTERVAL '30 days' THEN 'dormant'
  ELSE 'active'
END
WHERE status != 'banned';
```

**Supabase JavaScript client UPDATE:**

```javascript
// Update single row by ID
const { data, error } = await supabase
  .from('posts')
  .update({ status: 'published', published_at: new Date().toISOString() })
  .eq('id', 'uuid-here')
  .select();

// Update multiple rows
const { data, error } = await supabase
  .from('posts')
  .update({ status: 'archived' })
  .eq('author_id', 'uuid-here')
  .lt('created_at', '2023-01-01')
  .select();

// Update with multiple filters
const { data, error } = await supabase
  .from('posts')
  .update({ featured: true })
  .eq('status', 'published')
  .gte('likes', 100)
  .select();

// Update without returning data
const { error } = await supabase
  .from('posts')
  .update({ view_count: 150 })
  .eq('id', 'uuid-here');

// Increment numeric value
const { data, error } = await supabase.rpc('increment_view_count', {
  post_id: 'uuid-here'
});
// Requires database function:
// CREATE FUNCTION increment_view_count(post_id UUID)
// RETURNS void AS $$
//   UPDATE posts SET view_count = view_count + 1 WHERE id = post_id;
// $$ LANGUAGE sql;
```

## DELETE Operations

DELETE operations remove rows from tables.

**SQL DELETE syntax:**

```sql
-- Delete specific row
DELETE FROM posts WHERE id = 'uuid-here';

-- Delete multiple rows
DELETE FROM posts WHERE status = 'draft' AND created_at < NOW() - INTERVAL '30 days';

-- Delete with subquery
DELETE FROM comments
WHERE post_id IN (
  SELECT id FROM posts WHERE status = 'deleted'
);

-- Delete from multiple tables (using CASCADE foreign keys)
DELETE FROM users WHERE id = 'uuid-here';
-- Automatically deletes related posts, comments if foreign keys set with ON DELETE CASCADE

-- Delete and return deleted rows
DELETE FROM posts
WHERE status = 'spam'
RETURNING *;

-- Delete all rows (use with caution)
DELETE FROM temporary_logs;

-- Truncate table (faster than DELETE, resets sequences)
TRUNCATE TABLE temporary_logs;
TRUNCATE TABLE temporary_logs RESTART IDENTITY;  -- Reset auto-increment
TRUNCATE TABLE temporary_logs CASCADE;  -- Also truncate dependent tables
```

**Soft delete pattern:**

```sql
-- Add deleted_at column
ALTER TABLE posts ADD COLUMN deleted_at TIMESTAMPTZ;

-- Soft delete (mark as deleted)
UPDATE posts 
SET deleted_at = NOW() 
WHERE id = 'uuid-here';

-- Query excluding soft-deleted rows
SELECT * FROM posts WHERE deleted_at IS NULL;

-- Create view for active records
CREATE VIEW active_posts AS
SELECT * FROM posts WHERE deleted_at IS NULL;

-- Restore soft-deleted row
UPDATE posts 
SET deleted_at = NULL 
WHERE id = 'uuid-here';

-- Hard delete soft-deleted rows older than 30 days
DELETE FROM posts 
WHERE deleted_at < NOW() - INTERVAL '30 days';
```

**Supabase JavaScript client DELETE:**

```javascript
// Delete single row
const { error } = await supabase
  .from('posts')
  .delete()
  .eq('id', 'uuid-here');

// Delete multiple rows
const { error } = await supabase
  .from('posts')
  .delete()
  .eq('status', 'draft')
  .lt('created_at', '2023-01-01');

// Delete with multiple filters
const { error } = await supabase
  .from('comments')
  .delete()
  .eq('post_id', 'uuid-here')
  .eq('flagged', true);

// Delete and return deleted rows
const { data, error } = await supabase
  .from('posts')
  .delete()
  .eq('status', 'spam')
  .select();

// Soft delete implementation
const { error } = await supabase
  .from('posts')
  .update({ deleted_at: new Date().toISOString() })
  .eq('id', 'uuid-here');
```

## Ordering and Pagination

Ordering and pagination control how result sets are sorted and divided into manageable chunks.

**SQL ORDER BY:**

```sql
-- Order by single column ascending
SELECT * FROM posts ORDER BY created_at ASC;

-- Order by single column descending
SELECT * FROM posts ORDER BY created_at DESC;

-- Order by multiple columns
SELECT * FROM posts 
ORDER BY status ASC, created_at DESC;

-- Order with NULL handling
SELECT * FROM posts 
ORDER BY featured_image NULLS LAST;  -- NULLs at end
SELECT * FROM posts 
ORDER BY featured_image NULLS FIRST;  -- NULLs at beginning

-- Order by computed value
SELECT *, (likes + shares * 2) as engagement
FROM posts
ORDER BY engagement DESC;

-- Order by case expression
SELECT * FROM posts
ORDER BY 
  CASE status
    WHEN 'featured' THEN 1
    WHEN 'published' THEN 2
    WHEN 'draft' THEN 3
    ELSE 4
  END;
```

**SQL LIMIT and OFFSET (pagination):**

```sql
-- Limit results
SELECT * FROM posts ORDER BY created_at DESC LIMIT 10;

-- Pagination with OFFSET
SELECT * FROM posts 
ORDER BY created_at DESC 
LIMIT 10 OFFSET 0;  -- Page 1

SELECT * FROM posts 
ORDER BY created_at DESC 
LIMIT 10 OFFSET 10;  -- Page 2

SELECT * FROM posts 
ORDER BY created_at DESC 
LIMIT 10 OFFSET 20;  -- Page 3

-- General pagination formula: OFFSET = (page_number - 1) * page_size
```

**Cursor-based pagination (more efficient for large datasets):**

```sql
-- First page
SELECT * FROM posts 
WHERE deleted_at IS NULL
ORDER BY created_at DESC, id DESC
LIMIT 10;

-- Next page (using last item's created_at and id as cursor)
SELECT * FROM posts 
WHERE deleted_at IS NULL
  AND (created_at < '2024-01-15 10:30:00' 
       OR (created_at = '2024-01-15 10:30:00' AND id < 'last-uuid'))
ORDER BY created_at DESC, id DESC
LIMIT 10;
```

**Supabase JavaScript client ordering and pagination:**

```javascript
// Order by single column
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .order('created_at', { ascending: false });

// Order by multiple columns
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .order('status', { ascending: true })
  .order('created_at', { ascending: false });

// Order with NULL handling
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .order('featured_image', { ascending: true, nullsFirst: false });

// Basic pagination with range
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .range(0, 9)  // Returns rows 0-9 (first 10 items)
  .order('created_at', { ascending: false });

// Page 2
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .range(10, 19)  // Returns rows 10-19
  .order('created_at', { ascending: false });

// Pagination helper function
async function getPaginatedPosts(page, pageSize) {
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;
  
  const { data, error, count } = await supabase
    .from('posts')
    .select('*', { count: 'exact' })  // Include total count
    .range(from, to)
    .order('created_at', { ascending: false });
    
  return {
    data,
    error,
    currentPage: page,
    pageSize,
    totalItems: count,
    totalPages: Math.ceil(count / pageSize)
  };
}

// Cursor-based pagination
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .lt('created_at', lastItemTimestamp)
  .order('created_at', { ascending: false })
  .limit(10);
```

## Filtering Operators

Supabase provides various operators for filtering data through both SQL and the JavaScript client.

**Equality operators:**

```javascript
// Equal
.eq('status', 'published')
// SQL: WHERE status = 'published'

// Not equal
.neq('status', 'draft')
// SQL: WHERE status != 'draft'
```

**Comparison operators:**

```javascript
// Greater than
.gt('likes', 100)
// SQL: WHERE likes > 100

// Greater than or equal
.gte('age', 18)
// SQL: WHERE age >= 18

// Less than
.lt('stock', 10)
// SQL: WHERE stock < 10

// Less than or equal
.lte('price', 50.00)
// SQL: WHERE price <= 50.00
```

**Pattern matching:**

```javascript
// LIKE (case-sensitive pattern matching)
.like('title', '%PostgreSQL%')
// SQL: WHERE title LIKE '%PostgreSQL%'

// ILIKE (case-insensitive pattern matching)
.ilike('email', '%@gmail.com')
// SQL: WHERE email ILIKE '%@gmail.com'
```

**NULL operators:**

```javascript
// IS NULL
.is('deleted_at', null)
// SQL: WHERE deleted_at IS NULL

// IS NOT NULL
.not('featured_image', 'is', null)
// SQL: WHERE featured_image IS NOT NULL
```

**Array and range operators:**

```javascript
// IN (matches any value in array)
.in('category', ['tech', 'science', 'education'])
// SQL: WHERE category IN ('tech', 'science', 'education')

// NOT IN
.not('status', 'in', '(draft,archived)')
// SQL: WHERE status NOT IN ('draft', 'archived')

// Contains (for arrays and ranges)
.contains('tags', ['javascript', 'postgresql'])
// SQL: WHERE tags @> ARRAY['javascript', 'postgresql']

// Contained by
.containedBy('tags', ['javascript', 'postgresql', 'python'])
// SQL: WHERE tags <@ ARRAY['javascript', 'postgresql', 'python']

// Range overlaps
.overlaps('availability_dates', '[2024-01-01,2024-12-31]')
// SQL: WHERE availability_dates && '[2024-01-01,2024-12-31]'
```

**Full-text search operators:**

```javascript
// Text search (uses PostgreSQL's full-text search)
.textSearch('content', 'database & query')
// SQL: WHERE to_tsvector('english', content) @@ to_tsquery('english', 'database & query')

// Plain text search (automatically handles formatting)
.textSearch('content', 'database query', { type: 'plain' })

// Phrase search
.textSearch('content', 'database query', { type: 'phrase' })

// Websearch format (Google-like syntax)
.textSearch('content', '"exact phrase" -exclude +include', { type: 'websearch' })
```

**JSON operators:**

```javascript
// Access JSON field
.eq('metadata->color', 'blue')
// SQL: WHERE metadata->>'color' = 'blue'

// Deep JSON path
.eq('metadata->dimensions->width', 100)
// SQL: WHERE metadata#>>'{dimensions,width}' = '100'

// JSON contains
.contains('metadata', { color: 'blue' })
// SQL: WHERE metadata @> '{"color":"blue"}'
```

**Logical operators:**

```javascript
// AND (default behavior, chain multiple filters)
const { data } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .gte('likes', 10);
// SQL: WHERE status = 'published' AND likes >= 10

// OR
.or('status.eq.published,status.eq.featured')
// SQL: WHERE (status = 'published' OR status = 'featured')

// Complex OR with AND
.or('status.eq.published,and(status.eq.draft,author_id.eq.uuid-here)')
// SQL: WHERE (status = 'published' OR (status = 'draft' AND author_id = 'uuid-here'))

// NOT
.not('status', 'eq', 'draft')
// SQL: WHERE NOT (status = 'draft')
```

**Filter modifier operators:**

```javascript
// Filter on foreign table
const { data } = await supabase
  .from('posts')
  .select('*, author:users!inner(*)')
  .eq('author.status', 'active');
// Inner join and filter on users.status

// Filter on nested relation
const { data } = await supabase
  .from('posts')
  .select('*, comments!inner(count)')
  .gte('comments.count', 5);
```

**Complete filtering example:**

```javascript
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .gte('created_at', '2024-01-01')
  .or('featured.eq.true,likes.gte.100')
  .ilike('title', '%postgresql%')
  .not('category', 'in', '(spam,deleted)')
  .is('deleted_at', null)
  .order('created_at', { ascending: false })
  .range(0, 9);
```

## Full-Text Search

Full-text search enables efficient searching of text content using PostgreSQL's built-in text search capabilities.

**Setting up full-text search in SQL:**

```sql
-- Add tsvector column for search index
ALTER TABLE posts ADD COLUMN search_vector tsvector;

-- Create function to update search vector
CREATE OR REPLACE FUNCTION update_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector = 
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.tags::text, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update search vector
CREATE TRIGGER posts_search_vector_update
  BEFORE INSERT OR UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_search_vector();

-- Create GIN index for fast searching
CREATE INDEX posts_search_idx ON posts USING GIN (search_vector);

-- Update existing rows
UPDATE posts SET search_vector = 
  setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
  setweight(to_tsvector('english', COALESCE(content, '')), 'B') ||
  setweight(to_tsvector('english', COALESCE(tags::text, '')), 'C');
```

**Full-text search queries in SQL:**

```sql
-- Basic full-text search
SELECT * FROM posts
WHERE search_vector @@ to_tsquery('english', 'postgresql & database');

-- Search with ranking
SELECT 
  *,
  ts_rank(search_vector, to_tsquery('english', 'postgresql & database')) as rank
FROM posts
WHERE search_vector @@ to_tsquery('english', 'postgresql & database')
ORDER BY rank DESC;

-- Phrase search
SELECT * FROM posts
WHERE search_vector @@ phraseto_tsquery('english', 'database management system');

-- Plain text search (handles special characters automatically)
SELECT * FROM posts
WHERE search_vector @@ plainto_tsquery('english', 'postgresql database');

-- Websearch syntax (Google-like: quotes for phrases, - for exclusion)
SELECT * FROM posts
WHERE search_vector @@ websearch_to_tsquery('english', '"full text" search -mysql');

-- Search with highlighting
SELECT 
  id,
  title,
  ts_headline('english', content, 
    to_tsquery('english', 'postgresql & database'),
    'StartSel=<mark>, StopSel=</mark>, MaxWords=50, MinWords=25'
  ) as highlighted_content
FROM posts
WHERE search_vector @@ to_tsquery('english', 'postgresql & database');

-- Fuzzy search with similarity (requires pg_trgm extension)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

SELECT *, similarity(title, 'postgressql') as sim
FROM posts
WHERE title % 'postgressql'  -- % is similarity operator
ORDER BY sim DESC;
```

**Full-text search operators:**

- `&` - AND (both terms must be present)
- `|` - OR (either term must be present)
- `!` - NOT (term must not be present)
- `<->` - followed by (terms must be adjacent)
- `<N>` - distance (terms must be within N words)

```sql
-- Examples
'postgresql & database'  -- Both words must appear
'postgresql | mysql'  -- Either word must appear
'database & !mysql'  -- database must appear, mysql must not
'database <-> management'  -- Words must be adjacent
'database <2> system'  -- Words must be within 2 positions
```

**Supabase JavaScript client full-text search:**

```javascript
// Basic text search
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', 'postgresql & database');

// Plain text search
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', 'postgresql database', { type: 'plain' });

// Phrase search
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', 'database management system', { type: 'phrase' });

// Websearch syntax
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', '"full text" search -mysql', { type: 'websearch' });

// Search with additional filters
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', 'postgresql')
  .eq('status', 'published')
  .gte('created_at', '2024-01-01')
  .order('created_at', { ascending: false });

// Search across multiple columns without tsvector column
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .or('title.ilike.%postgresql%,content.ilike.%postgresql%');
```

**Custom search function with ranking:**

```sql
-- Create function for ranked search
CREATE OR REPLACE FUNCTION search_posts(search_query text)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    p.content,
    ts_rank(p.search_vector, websearch_to_tsquery('english', search_query)) as rank
  FROM posts p
  WHERE p.search_vector @@ websearch_to_tsquery('english', search_query)
    AND p.deleted_at IS NULL
  ORDER BY rank DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- Call from JavaScript
const { data, error } = await supabase.rpc('search_posts', {
  search_query: 'postgresql database'
});
```

## Joins and Nested Queries

Joins combine data from multiple tables, while nested queries embed related data in the response.

**SQL JOIN types:**

```sql
-- INNER JOIN (only matching rows from both tables)
SELECT 
  p.id,
  p.title,
  u.full_name as author_name
FROM posts p
INNER JOIN users u ON p.author_id = u.id;

-- LEFT JOIN (all rows from left table, matching rows from right)
SELECT 
  p.id,
  p.title,
  u.full_name as author_name
FROM posts p
LEFT JOIN users u ON p.author_id = u.id;

-- RIGHT JOIN (all rows from right table, matching rows from left)
SELECT 
  u.id,
  u.full_name,
  p.title
FROM posts p
RIGHT JOIN users u ON p.author_id = u.id;

-- FULL OUTER JOIN (all rows from both tables)
SELECT 
  u.full_name,
  p.title
FROM users u
FULL OUTER JOIN posts p ON u.id = p.author_id;

-- CROSS JOIN (Cartesian product - every combination)
SELECT 
  c.name as category,
  t.name as tag
FROM categories c
CROSS JOIN tags t;
```

**Multiple joins:**

```sql
SELECT 
  p.id,
  p.title,
  u.full_name as author_name,
  c.name as category_name,
  COUNT(l.id) as like_count
FROM posts p
INNER JOIN users u ON p.author_id = u.id
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN likes l ON p.id = l.post_id
WHERE p.status = 'published'
GROUP BY p.id, p.title, u.full_name, c.name;
```

**Self join (joining table to itself):**

```sql
-- Find users who live in the same city
SELECT 
  u1.full_name as user1,
  u2.full_name as user2,
  u1.city
FROM users u1
INNER JOIN users u2 ON u1.city = u2.city AND u1.id < u2.id;

-- Employee and manager relationship
SELECT 
  e.full_name as employee,
  m.full_name as manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

**Subqueries in SELECT:**

```sql
-- Subquery in SELECT clause
SELECT 
  p.id,
  p.title,
  (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as comment_count,
  (SELECT MAX(created_at) FROM comments c WHERE c.post_id = p.id) as last_comment_at
FROM posts p;

-- Subquery in WHERE clause
SELECT * FROM posts
WHERE author_id IN (
  SELECT id FROM users WHERE status = 'verified'
);

-- Correlated subquery (references outer query)
SELECT * FROM posts p
WHERE EXISTS (
  SELECT 1 FROM comments c 
  WHERE c.post_id = p.id AND c.created_at > NOW() - INTERVAL '7 days'
);

-- NOT EXISTS
SELECT * FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM posts p WHERE p.author_id = u.id
);

-- Subquery with ANY/ALL
SELECT * FROM products
WHERE price > ALL (
  SELECT price FROM products WHERE category = 'budget'
);

SELECT * FROM products
WHERE price < ANY (
  SELECT price FROM products WHERE category = 'premium'
);
```

**Common Table Expressions (CTEs):**

```sql
-- Single CTE
WITH popular_posts AS (
  SELECT * FROM posts
  WHERE likes >= 100
)
SELECT 
  p.*,
  u.full_name as author_name
FROM popular_posts p
JOIN users u ON p.author_id = u.id;

-- Multiple CTEs
WITH 
  active_users AS (
    SELECT * FROM users 
    WHERE last_login > NOW() - INTERVAL '30 days'
  ),
  user_stats AS (
    SELECT 
      author_id,
      COUNT(*) as post_count,
      AVG(likes) as avg_likes
    FROM posts
    GROUP BY author_id
  )
SELECT 
  u.full_name,
  us.post_count,
  us.avg_likes
FROM active_users u
JOIN user_stats us ON u.id = us.author_id
ORDER BY us.post_count DESC;

-- Recursive CTE (for hierarchical data)
WITH RECURSIVE category_tree AS (
  -- Base case: top-level categories
  SELECT id, name, parent_id, 0 as level
  FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
  -- Recursive case: child categories
  SELECT c.id, c.name, c.parent_id, ct.level + 1
  FROM categories c
  JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree ORDER BY level, name;
```

**Supabase JavaScript client joins (nested queries):**

```javascript
// Basic join (one-to-one or many-to-one)
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    author:users (
      id,
      full_name,
      email
    )
  `);
// Returns: { id, title, author: { id, full_name, email } }

// Multiple joins
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    author:users (
      full_name
    ),
    category:categories (
      name
    )
  `);

// One-to-many relationship
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    comments (
      id,
      content,
      user:users (
        full_name
      )
    )
  `);
// Returns: { id, title, comments: [{ id, content, user: { full_name } }] }

// Many-to-many through junction table
const { data, error } = await supabase
  .from('students')
  .select(`
    id,
    name,
    enrollments (
      enrolled_at,
      grade,
      course:courses (
        title,
        credits
      )
    )
  `);

// Filtering on joined table
const { data, error } = await supabase
  .from('posts')
  .select(`
    *,
    author:users!inner (
      full_name
    )
  `)
  .eq('author.status', 'verified');
// !inner forces INNER JOIN instead of LEFT JOIN

// Count related records
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    comments (count)
  `);
// Returns: { id, title, comments: [{ count: 5 }] }

// Nested filtering
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    comments!inner (
      id,
      content
    )
  `)
  .eq('comments.flagged', false)
  .gte('comments.created_at', '2024-01-01');

// Deep nesting (3+ levels)
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    comments (
      id,
      content,
      user:users (
        full_name,
        profile:profiles (
          avatar_url,
          bio
        )
      )
    )
  `);

// Using foreign key hint when multiple foreign keys exist
const { data, error } = await supabase
  .from('messages')
  .select(`
    id,
    content,
    sender:users!messages_sender_id_fkey (
      full_name
    ),
    recipient:users!messages_recipient_id_fkey (
      full_name
    )
  `);
```

**RPC for complex joins:**

```sql
-- Create function for complex query
CREATE OR REPLACE FUNCTION get_post_with_stats(post_uuid UUID)
RETURNS TABLE (
  id UUID,
  title TEXT,
  author_name TEXT,
  comment_count BIGINT,
  like_count BIGINT,
  recent_comments JSON
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    u.full_name,
    COUNT(DISTINCT c.id) as comment_count,
    COUNT(DISTINCT l.id) as like_count,
    (
      SELECT json_agg(json_build_object(
        'content', c2.content,
        'author', u2.full_name,
        'created_at', c2.created_at
      ))
      FROM comments c2
      JOIN users u2 ON c2.user_id = u2.id
      WHERE c2.post_id = p.id
      ORDER BY c2.created_at DESC
      LIMIT 5
    ) as recent_comments
  FROM posts p
  JOIN users u ON p.author_id = u.id
  LEFT JOIN comments c ON p.id = c.post_id
  LEFT JOIN likes l ON p.id = l.post_id
  WHERE p.id = post_uuid
  GROUP BY p.id, p.title, u.full_name;
END;
$$ LANGUAGE plpgsql;

-- Call from JavaScript
const { data, error } = await supabase.rpc('get_post_with_stats', {
  post_uuid: 'uuid-here'
});
```

## Aggregations and Grouping

Aggregations compute summary values across multiple rows, while grouping organizes data into categories.

**Aggregate functions:**

```sql
-- COUNT: number of rows
SELECT COUNT(*) FROM posts;
SELECT COUNT(DISTINCT author_id) FROM posts;  -- Unique authors

-- SUM: total of numeric values
SELECT SUM(price) FROM orders;

-- AVG: average value
SELECT AVG(rating) FROM reviews;

-- MIN/MAX: minimum and maximum values
SELECT MIN(created_at), MAX(created_at) FROM posts;

-- String aggregation
SELECT string_agg(tag, ', ') FROM post_tags WHERE post_id = 'uuid-here';

-- JSON aggregation
SELECT json_agg(title) FROM posts;
SELECT json_agg(json_build_object('id', id, 'title', title)) FROM posts;

-- Array aggregation
SELECT array_agg(category) FROM posts;
```

**GROUP BY clause:**

```sql
-- Count posts per author
SELECT 
  author_id,
  COUNT(*) as post_count
FROM posts
GROUP BY author_id;

-- Multiple aggregations
SELECT 
  author_id,
  COUNT(*) as post_count,
  AVG(likes) as avg_likes,
  MAX(created_at) as latest_post
FROM posts
GROUP BY author_id;

-- Group by multiple columns
SELECT 
  category,
  status,
  COUNT(*) as count
FROM posts
GROUP BY category, status;

-- Group with joins
SELECT 
  u.full_name,
  COUNT(p.id) as post_count,
  SUM(p.likes) as total_likes
FROM users u
LEFT JOIN posts p ON u.id = p.author_id
GROUP BY u.id, u.full_name;

-- HAVING clause (filter after aggregation)
SELECT 
  author_id,
  COUNT(*) as post_count
FROM posts
GROUP BY author_id
HAVING COUNT(*) >= 10;

-- Complex HAVING
SELECT 
  category,
  AVG(likes) as avg_likes
FROM posts
WHERE status = 'published'
GROUP BY category
HAVING AVG(likes) > 50 AND COUNT(*) >= 5;
```

**Window functions (aggregations without grouping):**

```sql
-- Running total
SELECT 
  id,
  title,
  likes,
  SUM(likes) OVER (ORDER BY created_at) as running_total
FROM posts;

-- Rank posts by likes
SELECT 
  title,
  likes,
  RANK() OVER (ORDER BY likes DESC) as rank,
  DENSE_RANK() OVER (ORDER BY likes DESC) as dense_rank,
  ROW_NUMBER() OVER (ORDER BY likes DESC) as row_num
FROM posts;

-- Partition by category
SELECT 
  category,
  title,
  likes,
  AVG(likes) OVER (PARTITION BY category) as category_avg,
  likes - AVG(likes) OVER (PARTITION BY category) as diff_from_avg
FROM posts;

-- Top N per group
SELECT * FROM (
  SELECT 
    category,
    title,
    likes,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY likes DESC) as rn
  FROM posts
) ranked
WHERE rn <= 3;

-- Moving average
SELECT 
  created_at::date as date,
  COUNT(*) as daily_posts,
  AVG(COUNT(*)) OVER (
    ORDER BY created_at::date 
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) as seven_day_avg
FROM posts
GROUP BY created_at::date;

-- LAG and LEAD (access previous/next rows)
SELECT 
  title,
  created_at,
  LAG(created_at) OVER (ORDER BY created_at) as previous_post_date,
  LEAD(created_at) OVER (ORDER BY created_at) as next_post_date,
  created_at - LAG(created_at) OVER (ORDER BY created_at) as time_since_last
FROM posts;
```

**ROLLUP and CUBE (hierarchical aggregations):**

```sql
-- ROLLUP (hierarchical subtotals)
SELECT 
  category,
  status,
  COUNT(*) as count
FROM posts
GROUP BY ROLLUP(category, status);
-- Returns counts for:
-- (category, status), (category, NULL), (NULL, NULL)

-- CUBE (all possible combinations)
SELECT 
  category,
  status,
  COUNT(*) as count
FROM posts
GROUP BY CUBE(category, status);
-- Returns counts for:
-- (category, status), (category, NULL), (NULL, status), (NULL, NULL)

-- GROUPING SETS (custom combinations)
SELECT 
  category,
  status,
  COUNT(*) as count
FROM posts
GROUP BY GROUPING SETS (
  (category, status),
  (category),
  ()
);
```

**Supabase JavaScript client aggregations:**

[Inference: The JavaScript client's aggregation capabilities are more limited than raw SQL. For complex aggregations, using RPC functions is often necessary.]

```javascript
// Count records
const { count, error } = await supabase
  .from('posts')
  .select('*', { count: 'exact', head: true });

// Count with filter
const { count, error } = await supabase
  .from('posts')
  .select('*', { count: 'exact', head: true })
  .eq('status', 'published');

// Count related records
const { data, error } = await supabase
  .from('users')
  .select(`
    id,
    full_name,
    posts (count)
  `);

// Using RPC for complex aggregations
const { data, error } = await supabase.rpc('get_post_statistics');

// Example RPC function:
// CREATE FUNCTION get_post_statistics()
// RETURNS TABLE (
//   category TEXT,
//   post_count BIGINT,
//   avg_likes NUMERIC,
//   total_likes BIGINT
// ) AS $$
//   SELECT 
//     category,
//     COUNT(*) as post_count,
//     AVG(likes) as avg_likes,
//     SUM(likes) as total_likes
//   FROM posts
//   WHERE status = 'published'
//   GROUP BY category
//   ORDER BY post_count DESC;
// $$ LANGUAGE sql;
```

## Returning Data from Mutations

PostgreSQL's RETURNING clause allows INSERT, UPDATE, and DELETE operations to return data from affected rows.

**SQL RETURNING clause:**

```sql
-- Insert and return inserted row
INSERT INTO posts (title, content, author_id)
VALUES ('New Post', 'Content here', 'uuid-here')
RETURNING *;

-- Insert and return specific columns
INSERT INTO posts (title, content, author_id)
VALUES ('New Post', 'Content here', 'uuid-here')
RETURNING id, created_at;

-- Insert multiple and return all
INSERT INTO posts (title, content, author_id) VALUES
  ('Post 1', 'Content 1', 'uuid-1'),
  ('Post 2', 'Content 2', 'uuid-2')
RETURNING *;

-- Update and return updated rows
UPDATE posts
SET status = 'published', published_at = NOW()
WHERE status = 'draft' AND created_at < NOW() - INTERVAL '7 days'
RETURNING id, title, published_at;

-- Update and return computed values
UPDATE products
SET price = price * 1.1
RETURNING id, name, price as new_price, price / 1.1 as old_price;

-- Delete and return deleted rows
DELETE FROM posts
WHERE status = 'spam'
RETURNING id, title, author_id;

-- Complex RETURNING with joins (using CTEs)
WITH deleted AS (
  DELETE FROM comments
  WHERE created_at < NOW() - INTERVAL '1 year'
  RETURNING *
)
SELECT 
  d.*,
  u.full_name as author_name
FROM deleted d
JOIN users u ON d.user_id = u.id;
```

**Supabase JavaScript client returning data:**

```javascript
// Insert and return
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'New Post',
    content: 'Content here',
    author_id: 'uuid-here'
  })
  .select();  // Returns inserted row

// Insert specific columns only
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'New Post',
    content: 'Content here',
    author_id: 'uuid-here'
  })
  .select('id, title, created_at');

// Insert multiple and return
const { data, error } = await supabase
  .from('posts')
  .insert([
    { title: 'Post 1', content: 'Content 1', author_id: 'uuid-1' },
    { title: 'Post 2', content: 'Content 2', author_id: 'uuid-2' }
  ])
  .select();

// Insert with nested select
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'New Post',
    content: 'Content here',
    author_id: 'uuid-here'
  })
  .select(`
    id,
    title,
    author:users (
      full_name,
      email
    )
  `);

// Update and return
const { data, error } = await supabase
  .from('posts')
  .update({ status: 'published', published_at: new Date().toISOString() })
  .eq('id', 'uuid-here')
  .select();

// Update multiple and return
const { data, error } = await supabase
  .from('posts')
  .update({ featured: true })
  .gte('likes', 100)
  .select('id, title, likes');

// Delete and return
const { data, error } = await supabase
  .from('posts')
  .delete()
  .eq('status', 'spam')
  .select();

// Upsert and return
const { data, error } = await supabase
  .from('users')
  .upsert({
    id: 'uuid-here',
    email: 'user@example.com',
    full_name: 'John Doe'
  })
  .select();

// Don't return data (faster for bulk operations)
const { error } = await supabase
  .from('posts')
  .insert({ title: 'New Post', content: 'Content' });
// No .select() call
```

**Using returned data:**

```javascript
// Single insert
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'New Post',
    content: 'Content here',
    author_id: userId
  })
  .select()
  .single();  // Returns single object instead of array

if (error) {
  console.error('Error:', error);
} else {
  console.log('Created post ID:', data.id);
  console.log('Created at:', data.created_at);
}

// Multiple inserts
const { data, error } = await supabase
  .from('comments')
  .insert(commentsArray)
  .select();

if (data) {
  const insertedIds = data.map(comment => comment.id);
  console.log('Inserted IDs:', insertedIds);
}

// Update with returned data
const { data, error } = await supabase
  .from('posts')
  .update({ view_count: 150 })
  .eq('id', postId)
  .select()
  .single();

if (data) {
  // Use updated data to update UI
  updateUI(data);
}
```

## Bulk Operations

Bulk operations efficiently handle multiple rows in a single database transaction.

**SQL bulk inserts:**

```sql
-- Insert multiple rows
INSERT INTO posts (title, content, author_id) VALUES
  ('Post 1', 'Content 1', 'uuid-1'),
  ('Post 2', 'Content 2', 'uuid-2'),
  ('Post 3', 'Content 3', 'uuid-3'),
  ('Post 4', 'Content 4', 'uuid-4');

-- Insert from SELECT
INSERT INTO archived_posts
SELECT * FROM posts
WHERE created_at < NOW() - INTERVAL '1 year';

-- Insert with ON CONFLICT (bulk upsert)
INSERT INTO user_settings (user_id, setting_key, setting_value) VALUES
  ('uuid-1', 'theme', 'dark'),
  ('uuid-2', 'theme', 'light'),
  ('uuid-3', 'theme', 'dark')
ON CONFLICT (user_id, setting_key)
DO UPDATE SET 
  setting_value = EXCLUDED.setting_value,
  updated_at = NOW();
```

**SQL bulk updates:**

```sql
-- Update multiple rows
UPDATE posts
SET status = 'published', published_at = NOW()
WHERE status = 'draft' AND created_at < NOW() - INTERVAL '7 days';

-- Update from VALUES (PostgreSQL 14+)
UPDATE posts
SET likes = updates.new_likes
FROM (VALUES
  ('uuid-1'::uuid, 150),
  ('uuid-2'::uuid, 200),
  ('uuid-3'::uuid, 175)
) AS updates(id, new_likes)
WHERE posts.id = updates.id;

-- Update from temporary table
CREATE TEMP TABLE post_updates (
  id UUID,
  new_status TEXT,
  new_likes INTEGER
);

INSERT INTO post_updates VALUES
  ('uuid-1', 'featured', 150),
  ('uuid-2', 'published', 200);

UPDATE posts
SET 
  status = post_updates.new_status,
  likes = post_updates.new_likes
FROM post_updates
WHERE posts.id = post_updates.id;

DROP TABLE post_updates;

-- Conditional bulk update with CASE
UPDATE posts
SET priority = CASE
  WHEN likes >= 1000 THEN 'high'
  WHEN likes >= 100 THEN 'medium'
  ELSE 'low'
END
WHERE status = 'published';
```

**SQL bulk deletes:**

```sql
-- Delete multiple rows
DELETE FROM posts
WHERE status = 'spam' OR deleted_at < NOW() - INTERVAL '30 days';

-- Delete with subquery
DELETE FROM comments
WHERE post_id IN (
  SELECT id FROM posts WHERE status = 'deleted'
);

-- Delete and archive
WITH deleted AS (
  DELETE FROM posts
  WHERE status = 'spam'
  RETURNING *
)
INSERT INTO spam_archive
SELECT * FROM deleted;

-- Bulk delete with USING
DELETE FROM comments c
USING posts p
WHERE c.post_id = p.id AND p.status = 'deleted';
```

**Supabase JavaScript client bulk operations:**

```javascript
// Bulk insert
const { data, error } = await supabase
  .from('posts')
  .insert([
    { title: 'Post 1', content: 'Content 1', author_id: 'uuid-1' },
    { title: 'Post 2', content: 'Content 2', author_id: 'uuid-2' },
    { title: 'Post 3', content: 'Content 3', author_id: 'uuid-3' },
    // ... up to thousands of rows
  ])
  .select();

// Bulk insert without returning data (faster)
const { error } = await supabase
  .from('posts')
  .insert(largeArrayOfPosts);

// Bulk upsert
const { data, error } = await supabase
  .from('user_settings')
  .upsert([
    { user_id: 'uuid-1', setting_key: 'theme', setting_value: 'dark' },
    { user_id: 'uuid-2', setting_key: 'theme', setting_value: 'light' },
    { user_id: 'uuid-3', setting_key: 'language', setting_value: 'en' }
  ])
  .select();

// Bulk update (updates all matching rows)
const { data, error } = await supabase
  .from('posts')
  .update({ status: 'archived' })
  .in('id', ['uuid-1', 'uuid-2', 'uuid-3'])
  .select();

// Bulk delete
const { error } = await supabase
  .from('comments')
  .delete()
  .in('id', commentIdsToDelete);

// Process large datasets in batches
async function bulkInsertWithBatching(items, batchSize = 1000) {
  const results = [];
  
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const { data, error } = await supabase
      .from('posts')
      .insert(batch)
      .select();
    
    if (error) {
      console.error(`Error inserting batch ${i / batchSize + 1}:`, error);
      throw error;
    }
    
    results.push(...data);
  }
  
  return results;
}

// Usage
const posts = [...]; // Large array of posts
const inserted = await bulkInsertWithBatching(posts);
```

**Transaction-based bulk operations:**

```sql
-- Ensure all operations succeed or all fail
BEGIN;

INSERT INTO orders (user_id, total_amount)
VALUES ('uuid-here', 100.00)
RETURNING id INTO order_id;

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
  (order_id, 'product-1', 2, 25.00),
  (order_id, 'product-2', 1, 50.00);

UPDATE products
SET stock = stock - 2
WHERE id = 'product-1';

UPDATE products
SET stock = stock - 1
WHERE id = 'product-2';

COMMIT;
-- If any statement fails, use ROLLBACK;
```

**RPC for complex bulk operations:**

```sql
-- Create function for bulk upsert with custom logic
CREATE OR REPLACE FUNCTION bulk_upsert_posts(posts JSON)
RETURNS TABLE (
  id UUID,
  title TEXT,
  action TEXT
) AS $$
DECLARE
  post JSON;
BEGIN
  FOR post IN SELECT * FROM json_array_elements(posts)
  LOOP
    INSERT INTO posts (id, title, content, author_id)
    VALUES (
      (post->>'id')::UUID,
      post->>'title',
      post->>'content',
      (post->>'author_id')::UUID
    )
    ON CONFLICT (id)
    DO UPDATE SET
      title = EXCLUDED.title,
      content = EXCLUDED.content,
      updated_at = NOW()
    RETURNING posts.id, posts.title, 
      CASE WHEN xmax = 0 THEN 'inserted' ELSE 'updated' END;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Call from JavaScript
const { data, error } = await supabase.rpc('bulk_upsert_posts', {
  posts: JSON.stringify(postsArray)
});
```

**Performance considerations for bulk operations:**

[Inference: These are general database optimization principles. Specific performance characteristics may vary based on your infrastructure and data.]

- Use batch sizes of 500-1000 rows for optimal performance
- Disable triggers temporarily for very large bulk inserts if appropriate
- Use COPY command for importing millions of rows (faster than INSERT)
- Drop indexes before bulk insert, recreate after (for very large datasets)
- Use UNLOGGED tables for temporary bulk operations (not crash-safe)
- Consider partitioning for tables with billions of rows
- Monitor connection pool usage during bulk operations

```sql
-- Example: Efficient bulk import
BEGIN;

-- Disable triggers if safe
ALTER TABLE posts DISABLE TRIGGER ALL;

-- Drop non-essential indexes
DROP INDEX IF EXISTS idx_posts_created;
DROP INDEX IF EXISTS idx_posts_status;

-- Bulk insert
COPY posts (title, content, author_id) FROM '/path/to/data.csv' CSV HEADER;

-- Recreate indexes
CREATE INDEX idx_posts_created ON posts(created_at);
CREATE INDEX idx_posts_status ON posts(status);

-- Re-enable triggers
ALTER TABLE posts ENABLE TRIGGER ALL;

-- Update statistics
ANALYZE posts;

COMMIT;
```

**Key points:**

- CRUD operations form the foundation of database interactions in Supabase
- Filtering operators provide precise control over data retrieval
- Full-text search requires proper indexing with tsvector and GIN indexes
- Joins and nested queries enable complex data relationships
- Aggregations compute summary statistics across grouped data
- RETURNING clauses provide immediate feedback from mutations
- Bulk operations optimize performance for multiple-row transactions
- Always consider RLS policies when designing queries
- Use appropriate indexes to optimize query performance
- Batch large operations to avoid timeout and memory issues

---

# Realtime

Supabase Realtime is a server that enables real-time functionality by broadcasting database changes, custom messages, and user presence information to connected clients via WebSockets. Built on Phoenix Channels (Elixir), it provides low-latency bidirectional communication between clients and the Supabase backend, allowing applications to react instantly to data changes and user interactions.

## Realtime Concepts and Use Cases

Realtime operates through persistent WebSocket connections that allow servers to push updates to clients without polling. The system consists of three primary features: database change streaming (Postgres Changes), custom message broadcasting (Broadcast), and user presence tracking (Presence).

**Key points:**

- WebSocket connections maintain persistent bidirectional channels between client and server
- Single connection can handle multiple subscriptions to different channels
- Messages delivered with minimal latency (typically under 100ms)
- Automatic reconnection handling with exponential backoff
- Connection state managed by client library
- Supports both public and authenticated channels

**Common use cases:**

- Collaborative applications (document editing, whiteboards, project management)
- Chat and messaging systems
- Live dashboards and analytics
- Multiplayer games and interactive experiences
- Notification systems and activity feeds
- Live commenting and reactions
- Real-time data synchronization across devices
- Auction and bidding platforms
- Live sports scores and trading platforms
- Customer support chat systems

**Example:** Basic channel subscription

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://your-project.supabase.co',
  'your-anon-key'
)

const channel = supabase
  .channel('custom-channel-name')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'messages' },
    (payload) => {
      console.log('Change received!', payload)
    }
  )
  .subscribe()
```

The architecture involves clients connecting to Realtime servers, which maintain subscriptions and forward relevant events. Database changes are captured via Postgres logical replication, while Broadcast and Presence events are handled directly by the Realtime server.

## Subscribing to Database Changes

Postgres Changes allow clients to listen for INSERT, UPDATE, DELETE, or all changes on specific tables. Changes are captured using PostgreSQL's logical replication feature and streamed through the Realtime server.

**Key points:**

- Requires Realtime replication enabled on table (via Supabase dashboard or SQL)
- Changes published after transaction commit, not during
- Can filter by specific columns or row values
- Respects Row Level Security policies for authenticated users
- Payload includes old and new row data for updates
- Event types: INSERT, UPDATE, DELETE, or wildcard '*'
- Schema filtering limits subscriptions to specific schemas

**Example:** Listening to all changes on a table

```javascript
const channel = supabase
  .channel('db-changes')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'todos' },
    (payload) => {
      console.log('Change detected:', payload)
      // payload.eventType: 'INSERT' | 'UPDATE' | 'DELETE'
      // payload.new: new row data (for INSERT and UPDATE)
      // payload.old: old row data (for UPDATE and DELETE)
      // payload.table: table name
      // payload.schema: schema name
      // payload.commit_timestamp: when change was committed
    }
  )
  .subscribe()
```

**Example:** Listening to specific event types

```javascript
// Only INSERTs
const insertChannel = supabase
  .channel('inserts-only')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'messages' },
    (payload) => {
      console.log('New message:', payload.new)
    }
  )
  .subscribe()

// Only UPDATEs
const updateChannel = supabase
  .channel('updates-only')
  .on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'tasks' },
    (payload) => {
      console.log('Updated from:', payload.old)
      console.log('Updated to:', payload.new)
    }
  )
  .subscribe()

// Only DELETEs
const deleteChannel = supabase
  .channel('deletes-only')
  .on('postgres_changes',
    { event: 'DELETE', schema: 'public', table: 'users' },
    (payload) => {
      console.log('Deleted user:', payload.old)
    }
  )
  .subscribe()
```

**Example:** Multiple subscriptions on single channel

```javascript
const channel = supabase
  .channel('multi-table')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'messages' },
    handleNewMessage
  )
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'notifications' },
    handleNewNotification
  )
  .on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'users' },
    handleUserUpdate
  )
  .subscribe()
```

**Enabling replication on a table (SQL):**

```sql
-- Enable replication for a table
ALTER TABLE public.todos REPLICA IDENTITY FULL;

-- Publish table changes to Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.todos;
```

[Note: REPLICA IDENTITY FULL required to receive old row data on UPDATE and DELETE events. Default REPLICA IDENTITY DEFAULT only includes primary key values.]

## Broadcast Channels

Broadcast allows sending ephemeral messages between connected clients without database persistence. Messages are delivered to all clients subscribed to the same channel topic.

**Key points:**

- Messages not stored in database (ephemeral)
- Low-latency delivery directly through WebSocket
- Supports arbitrary JSON payloads
- Can broadcast to specific channel or all subscribers
- Self-receive option determines if sender receives own messages
- Useful for temporary state and coordination
- No message ordering guarantees across clients [Inference: due to network variations]

**Example:** Basic broadcast setup

```javascript
// Client A: Sending messages
const channel = supabase
  .channel('room-1')
  .on('broadcast', { event: 'cursor-move' }, (payload) => {
    console.log('Cursor moved:', payload)
  })
  .subscribe()

// Send a broadcast message
await channel.send({
  type: 'broadcast',
  event: 'cursor-move',
  payload: { x: 100, y: 200, user: 'Alice' }
})
```

**Example:** Chat application

```javascript
const chatChannel = supabase
  .channel('chat-room-123')
  .on('broadcast', { event: 'message' }, ({ payload }) => {
    displayMessage(payload.username, payload.text, payload.timestamp)
  })
  .subscribe()

// Send chat message
async function sendMessage(text) {
  await chatChannel.send({
    type: 'broadcast',
    event: 'message',
    payload: {
      username: currentUser.name,
      text: text,
      timestamp: new Date().toISOString()
    }
  })
}
```

**Example:** Collaborative cursor tracking

```javascript
const cursorChannel = supabase
  .channel('canvas-cursors', {
    config: {
      broadcast: { self: false } // Don't receive own cursor events
    }
  })
  .on('broadcast', { event: 'cursor' }, ({ payload }) => {
    updateCursor(payload.userId, payload.x, payload.y, payload.color)
  })
  .subscribe()

// Throttled cursor position updates
let lastSent = 0
canvas.addEventListener('mousemove', (e) => {
  const now = Date.now()
  if (now - lastSent > 50) { // Throttle to 20 updates/second
    cursorChannel.send({
      type: 'broadcast',
      event: 'cursor',
      payload: {
        userId: currentUser.id,
        x: e.clientX,
        y: e.clientY,
        color: currentUser.cursorColor
      }
    })
    lastSent = now
  }
})
```

**Example:** Custom event types for different interactions

```javascript
const collaborationChannel = supabase
  .channel('document-collab')
  .on('broadcast', { event: 'selection' }, ({ payload }) => {
    highlightSelection(payload.userId, payload.start, payload.end)
  })
  .on('broadcast', { event: 'typing' }, ({ payload }) => {
    showTypingIndicator(payload.userId, payload.isTyping)
  })
  .on('broadcast', { event: 'comment' }, ({ payload }) => {
    addComment(payload.position, payload.text, payload.author)
  })
  .subscribe()
```

## Presence Tracking

Presence tracks which users are currently connected to a channel, automatically handling joins, leaves, and synchronization of user state across all connected clients.

**Key points:**

- Automatically tracks user connections and disconnections
- Each client can share arbitrary state (status, metadata, etc.)
- State synchronized across all channel subscribers
- Heartbeat mechanism detects disconnections
- Updates trigger callbacks on all connected clients
- Handles network interruptions and reconnections
- Each client identified by unique key within channel

**Example:** Basic presence setup

```javascript
const presenceChannel = supabase
  .channel('room-presence')
  .on('presence', { event: 'sync' }, () => {
    const state = presenceChannel.presenceState()
    console.log('Online users:', state)
  })
  .on('presence', { event: 'join' }, ({ key, newPresences }) => {
    console.log('User joined:', key, newPresences)
  })
  .on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
    console.log('User left:', key, leftPresences)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await presenceChannel.track({
        user_id: currentUser.id,
        username: currentUser.name,
        online_at: new Date().toISOString()
      })
    }
  })
```

**Example:** Live user list with avatars

```javascript
const userListChannel = supabase
  .channel('online-users')
  .on('presence', { event: 'sync' }, () => {
    const state = userListChannel.presenceState()
    
    // Extract all users from presence state
    const users = Object.keys(state).flatMap(key => 
      state[key].map(presence => presence)
    )
    
    renderUserList(users)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await userListChannel.track({
        user_id: currentUser.id,
        username: currentUser.name,
        avatar_url: currentUser.avatar,
        status: 'active'
      })
    }
  })

function renderUserList(users) {
  const container = document.getElementById('user-list')
  container.innerHTML = users.map(user => `
    <div class="user">
      <img src="${user.avatar_url}" alt="${user.username}">
      <span>${user.username}</span>
      <span class="status ${user.status}">${user.status}</span>
    </div>
  `).join('')
}
```

**Example:** Updating presence state

```javascript
// Update user status
async function setUserStatus(status) {
  await presenceChannel.track({
    user_id: currentUser.id,
    username: currentUser.name,
    status: status, // 'active', 'away', 'busy'
    last_activity: new Date().toISOString()
  })
}

// Update on user activity
let activityTimer
document.addEventListener('mousemove', () => {
  setUserStatus('active')
  clearTimeout(activityTimer)
  activityTimer = setTimeout(() => {
    setUserStatus('away')
  }, 300000) // 5 minutes
})
```

**Example:** Collaborative editing with active editors

```javascript
const editorChannel = supabase
  .channel('document-editors')
  .on('presence', { event: 'sync' }, () => {
    const editors = editorChannel.presenceState()
    updateEditorList(editors)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await editorChannel.track({
        user_id: currentUser.id,
        username: currentUser.name,
        cursor_position: 0,
        selected_text: null,
        color: generateUserColor(currentUser.id)
      })
    }
  })

// Update cursor position in real-time
editor.on('cursorActivity', async () => {
  const cursor = editor.getCursor()
  await editorChannel.track({
    user_id: currentUser.id,
    username: currentUser.name,
    cursor_position: cursor.line * 1000 + cursor.ch,
    color: currentUserColor
  })
})
```

**Example:** Gaming lobby presence

```javascript
const lobbyChannel = supabase
  .channel('game-lobby-1')
  .on('presence', { event: 'sync' }, () => {
    const players = lobbyChannel.presenceState()
    const playerCount = Object.keys(players).length
    updateLobbyUI(players, playerCount)
  })
  .on('presence', { event: 'join' }, ({ newPresences }) => {
    showNotification(`${newPresences[0].username} joined the lobby`)
  })
  .on('presence', { event: 'leave' }, ({ leftPresences }) => {
    showNotification(`${leftPresences[0].username} left the lobby`)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await lobbyChannel.track({
        user_id: currentUser.id,
        username: currentUser.name,
        ready: false,
        team: null,
        character: null
      })
    }
  })

// Update player ready state
async function toggleReady() {
  const currentState = lobbyChannel.presenceState()[currentUser.id][0]
  await lobbyChannel.track({
    ...currentState,
    ready: !currentState.ready
  })
}
```

## Realtime Filtering

Filtering limits which database changes are delivered to clients based on column values, reducing unnecessary data transfer and processing.

**Key points:**

- Filters applied server-side before message delivery
- Supports equality filters on specific columns
- Multiple filters can be combined (AND logic)
- Reduces bandwidth and client-side processing
- Filter values must match exactly (no wildcards or ranges)
- Filters work with RLS policies (both must pass)

**Example:** Filter by specific column value

```javascript
// Only receive messages for specific room
const roomChannel = supabase
  .channel('messages-room-5')
  .on('postgres_changes',
    { 
      event: 'INSERT', 
      schema: 'public', 
      table: 'messages',
      filter: 'room_id=eq.5'
    },
    (payload) => {
      displayMessage(payload.new)
    }
  )
  .subscribe()
```

**Example:** Multiple filters

```javascript
// Only receive high-priority notifications for current user
const notificationChannel = supabase
  .channel('my-urgent-notifications')
  .on('postgres_changes',
    { 
      event: 'INSERT', 
      schema: 'public', 
      table: 'notifications',
      filter: `user_id=eq.${currentUser.id}`
    },
    (payload) => {
      if (payload.new.priority === 'high') {
        showUrgentNotification(payload.new)
      }
    }
  )
  .subscribe()
```

**Example:** User-specific updates

```javascript
// Listen to changes on own profile only
const profileChannel = supabase
  .channel('my-profile-updates')
  .on('postgres_changes',
    { 
      event: 'UPDATE', 
      schema: 'public', 
      table: 'profiles',
      filter: `id=eq.${currentUser.id}`
    },
    (payload) => {
      updateLocalProfile(payload.new)
    }
  )
  .subscribe()
```

**Example:** Status-specific monitoring

```javascript
// Monitor only pending orders
const ordersChannel = supabase
  .channel('pending-orders')
  .on('postgres_changes',
    { 
      event: '*', 
      schema: 'public', 
      table: 'orders',
      filter: 'status=eq.pending'
    },
    (payload) => {
      if (payload.eventType === 'INSERT') {
        addOrderToQueue(payload.new)
      } else if (payload.eventType === 'UPDATE') {
        // Order status changed, may need to remove from queue
        if (payload.new.status !== 'pending') {
          removeOrderFromQueue(payload.old.id)
        }
      }
    }
  )
  .subscribe()
```

[Note: Filters use PostgREST filter syntax. Supported operators include eq (equals), neq (not equals), gt (greater than), lt (less than), gte (greater than or equal), lte (less than or equal), in (in list), and is (is null/not null).]

## Performance and Scaling Considerations

Realtime connections consume server resources and require careful management for applications with many concurrent users or high message volumes.

**Key points:**

- Each WebSocket connection maintained by Realtime server
- Connection limit depends on plan (Free: 200 concurrent, Pro: 500+, Enterprise: custom)
- Message rate limits prevent abuse (varies by plan)
- Database change events can create load on Postgres replication
- Throttling broadcast messages reduces bandwidth consumption
- Channel names should be specific to avoid unnecessary subscriptions
- Multiplexing multiple subscriptions over single connection improves efficiency
- Heartbeat packets maintain connection health

**Connection optimization strategies:**

- Reuse single channel for multiple related subscriptions
- Unsubscribe from channels when no longer needed
- Use filters to limit data delivered to clients
- Batch updates when possible rather than sending individual changes
- Consider throttling high-frequency events (cursor movements, etc.)
- Implement reconnection logic with exponential backoff
- Monitor connection count and usage in Supabase dashboard

**Example:** Efficient channel reuse

```javascript
// Good: Single channel with multiple subscriptions
const multiChannel = supabase
  .channel('app-updates')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'messages', filter: 'room_id=eq.1' },
    handleMessage
  )
  .on('broadcast', { event: 'typing' }, handleTyping)
  .on('presence', { event: 'sync' }, handlePresence)
  .subscribe()

// Less efficient: Multiple channels
const messageChannel = supabase.channel('messages').on(...).subscribe()
const typingChannel = supabase.channel('typing').on(...).subscribe()
const presenceChannel = supabase.channel('presence').on(...).subscribe()
```

**Example:** Throttling high-frequency events

```javascript
// Throttle cursor position updates
function throttle(func, delay) {
  let timeoutId
  let lastExecTime = 0
  
  return function(...args) {
    const currentTime = Date.now()
    const timeSinceLastExec = currentTime - lastExecTime
    
    if (timeSinceLastExec >= delay) {
      func.apply(this, args)
      lastExecTime = currentTime
    } else {
      clearTimeout(timeoutId)
      timeoutId = setTimeout(() => {
        func.apply(this, args)
        lastExecTime = Date.now()
      }, delay - timeSinceLastExec)
    }
  }
}

const throttledCursorUpdate = throttle((x, y) => {
  channel.send({
    type: 'broadcast',
    event: 'cursor',
    payload: { x, y, userId: currentUser.id }
  })
}, 100) // Maximum 10 updates per second

canvas.addEventListener('mousemove', (e) => {
  throttledCursorUpdate(e.clientX, e.clientY)
})
```

**Example:** Connection monitoring

```javascript
let connectionStatus = 'disconnected'
let reconnectAttempts = 0
const maxReconnectAttempts = 5

const channel = supabase
  .channel('monitored-channel')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'data' }, handleChange)
  .subscribe((status, error) => {
    if (status === 'SUBSCRIBED') {
      connectionStatus = 'connected'
      reconnectAttempts = 0
      console.log('Connected to Realtime')
    } else if (status === 'CHANNEL_ERROR') {
      connectionStatus = 'error'
      console.error('Channel error:', error)
      
      if (reconnectAttempts < maxReconnectAttempts) {
        reconnectAttempts++
        const delay = Math.min(1000 * Math.pow(2, reconnectAttempts), 30000)
        console.log(`Reconnecting in ${delay}ms...`)
        setTimeout(() => {
          channel.subscribe()
        }, delay)
      }
    } else if (status === 'TIMED_OUT') {
      connectionStatus = 'timeout'
      console.warn('Connection timed out')
    } else if (status === 'CLOSED') {
      connectionStatus = 'closed'
      console.log('Connection closed')
    }
  })
```

**Scaling considerations:**

- [Inference: Database replication slots consume resources; enabling replication on many tables may impact performance]
- Message throughput limited by network bandwidth and Realtime server capacity
- Large payloads increase latency and bandwidth usage
- Consider message queuing systems for extremely high volumes
- Geographic distribution of users affects latency
- Horizontal scaling available on Enterprise plans

## Unsubscribing and Cleanup

Proper cleanup of subscriptions prevents memory leaks and reduces server load when channels are no longer needed.

**Key points:**

- Unsubscribing closes WebSocket channel and stops message delivery
- Client library automatically handles reconnection cancellation
- Multiple callbacks on same channel all removed on unsubscribe
- Presence state automatically cleared on unsubscribe
- Cleanup should occur on component unmount or navigation
- Unsubscribed channels can be resubscribed later

**Example:** Basic unsubscribe

```javascript
const channel = supabase
  .channel('temp-channel')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'data' }, handleChange)
  .subscribe()

// Later, when no longer needed
await supabase.removeChannel(channel)
```

**Example:** React component cleanup

```javascript
import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'

function MessagesComponent({ roomId }) {
  const [messages, setMessages] = useState([])

  useEffect(() => {
    const channel = supabase
      .channel(`room-${roomId}`)
      .on('postgres_changes',
        { 
          event: 'INSERT', 
          schema: 'public', 
          table: 'messages',
          filter: `room_id=eq.${roomId}`
        },
        (payload) => {
          setMessages(prev => [...prev, payload.new])
        }
      )
      .subscribe()

    // Cleanup function
    return () => {
      supabase.removeChannel(channel)
    }
  }, [roomId]) // Re-subscribe when roomId changes

  return (
    <div>
      {messages.map(msg => <div key={msg.id}>{msg.text}</div>)}
    </div>
  )
}
```

**Example:** Multiple channel cleanup

```javascript
const channels = []

function subscribeToRooms(roomIds) {
  roomIds.forEach(roomId => {
    const channel = supabase
      .channel(`room-${roomId}`)
      .on('postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'messages', filter: `room_id=eq.${roomId}` },
        handleMessage
      )
      .subscribe()
    
    channels.push(channel)
  })
}

function cleanupAllChannels() {
  channels.forEach(channel => {
    supabase.removeChannel(channel)
  })
  channels.length = 0 // Clear array
}

// On app shutdown or navigation
window.addEventListener('beforeunload', cleanupAllChannels)
```

**Example:** Conditional cleanup based on user action

```javascript
let activeChannel = null

function joinRoom(roomId) {
  // Cleanup previous room subscription if exists
  if (activeChannel) {
    supabase.removeChannel(activeChannel)
  }

  // Subscribe to new room
  activeChannel = supabase
    .channel(`room-${roomId}`)
    .on('postgres_changes',
      { event: '*', schema: 'public', table: 'messages', filter: `room_id=eq.${roomId}` },
      handleMessage
    )
    .on('presence', { event: 'sync' }, updateUserList)
    .subscribe(async (status) => {
      if (status === 'SUBSCRIBED') {
        await activeChannel.track({
          user_id: currentUser.id,
          username: currentUser.name
        })
      }
    })
}

function leaveRoom() {
  if (activeChannel) {
    supabase.removeChannel(activeChannel)
    activeChannel = null
  }
}
```

**Example:** Removing all channels

```javascript
// Remove all active channels at once
await supabase.removeAllChannels()
```

## Realtime with RLS

Row Level Security policies apply to Realtime subscriptions, ensuring users only receive database changes for data they're authorized to access.

**Key points:**

- RLS policies evaluated for each database change event
- Users only receive changes for rows matching their RLS policies
- Both SELECT and target operation policies checked (INSERT, UPDATE, DELETE)
- Anonymous users subject to RLS policies for anon role
- Authenticated users evaluated against auth.uid() in policies
- Filters and RLS policies combined (both must pass)
- RLS evaluation happens before message delivery

**Example:** Basic RLS policy for user-specific data

```sql
-- Users can only see their own messages
CREATE POLICY "Users can view own messages"
ON messages FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Users can see new messages they create
CREATE POLICY "Users can insert own messages"
ON messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
```

With this policy, users subscribing to message changes only receive events for their own messages:

```javascript
// User A (ID: user-a-123) subscribes
const channel = supabase
  .channel('my-messages')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'messages' },
    (payload) => {
      // Only receives events for messages where user_id = 'user-a-123'
      console.log('My message changed:', payload)
    }
  )
  .subscribe()
```

**Example:** Shared resource with role-based access

```sql
-- Team members can view messages in their team's rooms
CREATE POLICY "Team members see room messages"
ON messages FOR SELECT
TO authenticated
USING (
  room_id IN (
    SELECT room_id 
    FROM room_members 
    WHERE user_id = auth.uid()
  )
);
```

```javascript
// User receives messages from all rooms they're a member of
const channel = supabase
  .channel('team-messages')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'messages' },
    (payload) => {
      // Only receives if user is member of payload.new.room_id
      addMessageToUI(payload.new)
    }
  )
  .subscribe()
```

**Example:** Public and private data separation

```sql
-- Everyone can see public posts
CREATE POLICY "Anyone can view public posts"
ON posts FOR SELECT
TO authenticated, anon
USING (visibility = 'public');

-- Only author can see draft posts
CREATE POLICY "Authors can view own drafts"
ON posts FOR SELECT
TO authenticated
USING (visibility = 'draft' AND auth.uid() = author_id);
```

```javascript
// Anonymous user subscription
const publicChannel = supabase
  .channel('public-posts')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'posts' },
    (payload) => {
      // Only receives public posts (visibility = 'public')
      displayPost(payload.new)
    }
  )
  .subscribe()

// Authenticated user subscription
const myDraftsChannel = supabase
  .channel('my-drafts')
  .on('postgres_changes',
    { 
      event: 'UPDATE', 
      schema: 'public', 
      table: 'posts',
      filter: `author_id=eq.${currentUser.id}`
    },
    (payload) => {
      // Receives all updates to own posts (public and drafts)
      updatePostInUI(payload.new)
    }
  )
  .subscribe()
```

**Example:** Complex RLS with metadata checks

```sql
-- Users can see messages where they are participants
CREATE POLICY "Participants see conversation messages"
ON messages FOR SELECT
TO authenticated
USING (
  conversation_id IN (
    SELECT c.id 
    FROM conversations c
    WHERE (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
       OR c.participant_ids @> ARRAY[auth.uid()]::uuid[]
  )
);
```

**Important RLS considerations with Realtime:**

- [Inference: RLS evaluation adds latency to message delivery, though typically minimal]
- Complex RLS policies may impact Realtime performance at scale
- Policy changes require reconnection to take effect [Unverified: reconnection requirement]
- Testing RLS with Realtime requires authenticated sessions
- Broadcast and Presence respect channel-level authorization, not RLS

## Custom Events via Broadcast

Broadcast enables application-specific custom events for real-time coordination and ephemeral state sharing between clients without database involvement.

**Key points:**

- Events defined by arbitrary string identifiers
- Payload can be any JSON-serializable data
- No server-side validation or processing of event structure
- Multiple event types can coexist on single channel
- Event handlers registered per event type
- Useful for coordinating UI state, temporary interactions, and peer-to-peer communication

**Example:** Multi-event collaboration system

```javascript
const docChannel = supabase
  .channel('document-123')
  .on('broadcast', { event: 'text-insert' }, ({ payload }) => {
    insertTextAtPosition(payload.position, payload.text, payload.userId)
  })
  .on('broadcast', { event: 'text-delete' }, ({ payload }) => {
    deleteTextRange(payload.start, payload.end, payload.userId)
  })
  .on('broadcast', { event: 'format-apply' }, ({ payload }) => {
    applyFormatting(payload.range, payload.format, payload.userId)
  })
  .on('broadcast', { event: 'selection-change' }, ({ payload }) => {
    showUserSelection(payload.userId, payload.start, payload.end)
  })
  .on('broadcast', { event: 'comment-add' }, ({ payload }) => {
    addCommentMarker(payload.position, payload.commentId, payload.userId)
  })
  .subscribe()

// Sending different event types
function insertText(pos, text) {
  docChannel.send({
    type: 'broadcast',
    event: 'text-insert',
    payload: {
      position: pos,
      text: text,
      userId: currentUser.id,
      timestamp: Date.now()
    }
  })
}

function addComment(pos, comment) {
  docChannel.send({
    type: 'broadcast',
    event: 'comment-add',
    payload: {
      position: pos,
      commentId: generateId(),
      userId: currentUser.id,
      text: comment,
      timestamp: Date.now()
    }
  })
}
```

**Example:** Game state synchronization

```javascript
const gameChannel = supabase
  .channel('game-session-456')
  .on('broadcast', { event: 'player-move' }, ({ payload }) => {
  updatePlayerPosition(payload.playerId, payload.x, payload.y, payload.direction)
  })
  .on('broadcast', { event: 'player-action' }, ({ payload }) => {
    executePlayerAction(payload.playerId, payload.action, payload.target)
  })
  .on('broadcast', { event: 'game-event' }, ({ payload }) => {
    handleGameEvent(payload.eventType, payload.data)
  })
  .on('broadcast', { event: 'chat-message' }, ({ payload }) => {
    displayChatMessage(payload.playerId, payload.message)
  })
  .subscribe()

// Game loop sending player position
setInterval(() => {
  if (playerHasMoved) {
    gameChannel.send({
      type: 'broadcast',
      event: 'player-move',
      payload: {
        playerId: localPlayer.id,
        x: localPlayer.x,
        y: localPlayer.y,
        direction: localPlayer.direction,
        velocity: localPlayer.velocity
      }
    })
    playerHasMoved = false
  }
}, 50) // 20 updates per second

// Player performs action
function performAction(actionType, target) {
  gameChannel.send({
    type: 'broadcast',
    event: 'player-action',
    payload: {
      playerId: localPlayer.id,
      action: actionType,
      target: target,
      timestamp: Date.now()
    }
  })
}
```

**Example:** Drawing application with tool events
```javascript
const canvasChannel = supabase
  .channel('canvas-789', {
    config: {
      broadcast: { self: false }
    }
  })
  .on('broadcast', { event: 'draw-start' }, ({ payload }) => {
    startRemoteDrawing(payload.userId, payload.x, payload.y, payload.tool)
  })
  .on('broadcast', { event: 'draw-move' }, ({ payload }) => {
    continueRemoteDrawing(payload.userId, payload.x, payload.y)
  })
  .on('broadcast', { event: 'draw-end' }, ({ payload }) => {
    endRemoteDrawing(payload.userId)
  })
  .on('broadcast', { event: 'tool-change' }, ({ payload }) => {
    updateUserTool(payload.userId, payload.tool, payload.color, payload.size)
  })
  .on('broadcast', { event: 'object-add' }, ({ payload }) => {
    addObjectToCanvas(payload.objectType, payload.properties)
  })
  .on('broadcast', { event: 'object-transform' }, ({ payload }) => {
    transformObject(payload.objectId, payload.transform)
  })
  .subscribe()

let isDrawing = false
let currentPath = []

canvas.addEventListener('mousedown', (e) => {
  isDrawing = true
  currentPath = [{ x: e.clientX, y: e.clientY }]
  
  canvasChannel.send({
    type: 'broadcast',
    event: 'draw-start',
    payload: {
      userId: currentUser.id,
      x: e.clientX,
      y: e.clientY,
      tool: currentTool,
      color: currentColor,
      size: brushSize
    }
  })
})

canvas.addEventListener('mousemove', (e) => {
  if (!isDrawing) return
  
  currentPath.push({ x: e.clientX, y: e.clientY })
  
  canvasChannel.send({
    type: 'broadcast',
    event: 'draw-move',
    payload: {
      userId: currentUser.id,
      x: e.clientX,
      y: e.clientY
    }
  })
})

canvas.addEventListener('mouseup', () => {
  if (!isDrawing) return
  isDrawing = false
  
  canvasChannel.send({
    type: 'broadcast',
    event: 'draw-end',
    payload: {
      userId: currentUser.id,
      path: currentPath
    }
  })
})
```

**Example:** Form collaboration with field locking
```javascript
const formChannel = supabase
  .channel('form-edit-101')
  .on('broadcast', { event: 'field-focus' }, ({ payload }) => {
    lockField(payload.fieldId, payload.userId, payload.username)
  })
  .on('broadcast', { event: 'field-blur' }, ({ payload }) => {
    unlockField(payload.fieldId, payload.userId)
  })
  .on('broadcast', { event: 'field-change' }, ({ payload }) => {
    updateFieldPreview(payload.fieldId, payload.value, payload.userId)
  })
  .on('broadcast', { event: 'validation-error' }, ({ payload }) => {
    showFieldError(payload.fieldId, payload.error)
  })
  .subscribe()

// Notify others when focusing on a field
document.querySelectorAll('input, textarea, select').forEach(field => {
  field.addEventListener('focus', () => {
    formChannel.send({
      type: 'broadcast',
      event: 'field-focus',
      payload: {
        fieldId: field.id,
        userId: currentUser.id,
        username: currentUser.name
      }
    })
  })
  
  field.addEventListener('blur', () => {
    formChannel.send({
      type: 'broadcast',
      event: 'field-blur',
      payload: {
        fieldId: field.id,
        userId: currentUser.id
      }
    })
  })
  
  field.addEventListener('input', throttle(() => {
    formChannel.send({
      type: 'broadcast',
      event: 'field-change',
      payload: {
        fieldId: field.id,
        value: field.value,
        userId: currentUser.id
      }
    })
  }, 500))
})
```

**Example:** Notification system with custom priorities
```javascript
const notificationChannel = supabase
  .channel('app-notifications')
  .on('broadcast', { event: 'notification' }, ({ payload }) => {
    switch(payload.priority) {
      case 'critical':
        showCriticalAlert(payload.title, payload.message)
        playAlertSound()
        break
      case 'high':
        showNotificationToast(payload.title, payload.message, 'warning')
        break
      case 'normal':
        showNotificationToast(payload.title, payload.message, 'info')
        break
      case 'low':
        addToNotificationList(payload)
        break
    }
  })
  .on('broadcast', { event: 'notification-dismiss' }, ({ payload }) => {
    dismissNotification(payload.notificationId)
  })
  .on('broadcast', { event: 'notification-read' }, ({ payload }) => {
    markNotificationRead(payload.notificationId)
  })
  .subscribe()

// Send notification to all users
function broadcastNotification(title, message, priority = 'normal') {
  notificationChannel.send({
    type: 'broadcast',
    event: 'notification',
    payload: {
      id: generateId(),
      title: title,
      message: message,
      priority: priority,
      timestamp: Date.now(),
      senderId: currentUser.id
    }
  })
}
```

## Conflict Resolution Strategies

When multiple clients modify shared state simultaneously, conflicts arise. Strategies needed to maintain consistency and resolve competing updates.

**Key points:**
- Realtime itself does not provide automatic conflict resolution
- Application must implement conflict resolution logic
- Common strategies: Last Write Wins, Operational Transformation, CRDTs, Version Vectors
- Database timestamps can help determine update order
- Optimistic updates require rollback mechanisms
- Broadcast events arrive in order per sender [Inference: but may interleave between senders]

**Last Write Wins (LWW) Strategy:**

Simple approach where the most recent update overwrites previous values. Uses timestamps to determine recency.

**Example:** Last Write Wins implementation
```javascript
const documentState = {
  content: '',
  lastModified: 0,
  modifiedBy: null
}

const docChannel = supabase
  .channel('document-lww')
  .on('broadcast', { event: 'content-update' }, ({ payload }) => {
    // Only apply if update is newer than current state
    if (payload.timestamp > documentState.lastModified) {
      documentState.content = payload.content
      documentState.lastModified = payload.timestamp
      documentState.modifiedBy = payload.userId
      renderDocument(documentState.content)
    } else {
      console.log('Ignoring stale update from', payload.userId)
    }
  })
  .subscribe()

function updateDocument(newContent) {
  const timestamp = Date.now()
  
  // Optimistic update
  documentState.content = newContent
  documentState.lastModified = timestamp
  documentState.modifiedBy = currentUser.id
  
  // Broadcast to others
  docChannel.send({
    type: 'broadcast',
    event: 'content-update',
    payload: {
      content: newContent,
      timestamp: timestamp,
      userId: currentUser.id
    }
  })
}
```

**Operational Transformation (OT) Strategy:**

Transforms operations to account for concurrent changes. Commonly used in collaborative text editors.

**Example:** Simple OT for text operations
```javascript
class Operation {
  constructor(type, position, content, userId) {
    this.type = type // 'insert' or 'delete'
    this.position = position
    this.content = content
    this.userId = userId
    this.timestamp = Date.now()
  }
}

// Transform operation against another operation
function transform(op1, op2) {
  if (op1.type === 'insert' && op2.type === 'insert') {
    if (op1.position < op2.position) {
      return op2 // No change needed
    } else if (op1.position > op2.position) {
      // Adjust position to account for op2's insertion
      return new Operation(
        op2.type,
        op2.position,
        op2.content,
        op2.userId
      )
    } else {
      // Same position, use timestamp to decide order
      if (op1.timestamp < op2.timestamp) {
        return new Operation(
          op2.type,
          op2.position + op1.content.length,
          op2.content,
          op2.userId
        )
      }
    }
  }
  
  if (op1.type === 'delete' && op2.type === 'insert') {
    if (op2.position <= op1.position) {
      return new Operation(
        op2.type,
        op2.position,
        op2.content,
        op2.userId
      )
    } else if (op2.position > op1.position + op1.content.length) {
      return new Operation(
        op2.type,
        op2.position - op1.content.length,
        op2.content,
        op2.userId
      )
    }
  }
  
  // Additional transformation rules for delete/delete, etc.
  return op2
}

const editorChannel = supabase
  .channel('editor-ot')
  .on('broadcast', { event: 'operation' }, ({ payload }) => {
    const remoteOp = new Operation(
      payload.type,
      payload.position,
      payload.content,
      payload.userId
    )
    
    // Transform against pending local operations
    let transformedOp = remoteOp
    for (const localOp of pendingOperations) {
      transformedOp = transform(localOp, transformedOp)
    }
    
    // Apply transformed operation
    applyOperation(transformedOp)
  })
  .subscribe()

let pendingOperations = []

function insertText(position, text) {
  const op = new Operation('insert', position, text, currentUser.id)
  pendingOperations.push(op)
  
  applyOperation(op)
  
  editorChannel.send({
    type: 'broadcast',
    event: 'operation',
    payload: op
  })
  
  // Remove from pending after acknowledgment
  setTimeout(() => {
    pendingOperations = pendingOperations.filter(o => o !== op)
  }, 1000)
}
```

[Note: Full OT implementation is complex and requires careful handling of many edge cases. Libraries like ShareDB or Yjs provide robust OT/CRDT implementations.]

**CRDT (Conflict-free Replicated Data Types) Strategy:**

Data structures designed to merge concurrent updates without conflicts. Guaranteed eventual consistency.

**Example:** Simple CRDT counter
```javascript
class CRDTCounter {
  constructor(userId) {
    this.userId = userId
    this.counts = {} // { userId: count }
  }
  
  increment(amount = 1) {
    if (!this.counts[this.userId]) {
      this.counts[this.userId] = 0
    }
    this.counts[this.userId] += amount
    return this.getValue()
  }
  
  merge(remoteCounts) {
    for (const [userId, count] of Object.entries(remoteCounts)) {
      this.counts[userId] = Math.max(
        this.counts[userId] || 0,
        count
      )
    }
    return this.getValue()
  }
  
  getValue() {
    return Object.values(this.counts).reduce((sum, c) => sum + c, 0)
  }
}

const counter = new CRDTCounter(currentUser.id)

const counterChannel = supabase
  .channel('shared-counter')
  .on('broadcast', { event: 'counter-update' }, ({ payload }) => {
    counter.merge(payload.counts)
    updateCounterDisplay(counter.getValue())
  })
  .subscribe()

function incrementCounter() {
  const newValue = counter.increment()
  updateCounterDisplay(newValue)
  
  counterChannel.send({
    type: 'broadcast',
    event: 'counter-update',
    payload: {
      counts: counter.counts
    }
  })
}
```

**Version Vector Strategy:**

Track causality between updates using version vectors. Detects concurrent modifications.

**Example:** Version vector conflict detection
```javascript
class VersionVector {
  constructor() {
    this.vector = {} // { userId: version }
  }
  
  increment(userId) {
    this.vector[userId] = (this.vector[userId] || 0) + 1
  }
  
  merge(otherVector) {
    for (const [userId, version] of Object.entries(otherVector)) {
      this.vector[userId] = Math.max(
        this.vector[userId] || 0,
        version
      )
    }
  }
  
  compare(otherVector) {
    let hasGreater = false
    let hasLess = false
    
    const allUserIds = new Set([
      ...Object.keys(this.vector),
      ...Object.keys(otherVector.vector)
    ])
    
    for (const userId of allUserIds) {
      const thisVersion = this.vector[userId] || 0
      const otherVersion = otherVector.vector[userId] || 0
      
      if (thisVersion > otherVersion) hasGreater = true
      if (thisVersion < otherVersion) hasLess = true
    }
    
    if (!hasGreater && !hasLess) return 'equal'
    if (hasGreater && !hasLess) return 'greater'
    if (!hasGreater && hasLess) return 'less'
    return 'concurrent' // Conflict detected
  }
  
  clone() {
    const cloned = new VersionVector()
    cloned.vector = { ...this.vector }
    return cloned
  }
}

const localVersion = new VersionVector()
let documentContent = ''

const versionChannel = supabase
  .channel('versioned-document')
  .on('broadcast', { event: 'update' }, ({ payload }) => {
    const remoteVersion = new VersionVector()
    remoteVersion.vector = payload.version
    
    const comparison = localVersion.compare(remoteVersion)
    
    if (comparison === 'less') {
      // Remote is newer, apply it
      documentContent = payload.content
      localVersion.merge(payload.version)
      renderDocument(documentContent)
    } else if (comparison === 'concurrent') {
      // Conflict detected, need resolution strategy
      handleConflict(documentContent, payload.content, localVersion, remoteVersion)
    } else {
      // Local is equal or newer, ignore
      console.log('Ignoring older update')
    }
  })
  .subscribe()

function updateContent(newContent) {
  documentContent = newContent
  localVersion.increment(currentUser.id)
  
  versionChannel.send({
    type: 'broadcast',
    event: 'update',
    payload: {
      content: newContent,
      version: localVersion.vector,
      userId: currentUser.id
    }
  })
}

function handleConflict(localContent, remoteContent, localVer, remoteVer) {
  // Strategy: Show conflict UI and let user choose
  showConflictDialog({
    local: { content: localContent, version: localVer },
    remote: { content: remoteContent, version: remoteVer },
    onResolve: (chosenContent) => {
      documentContent = chosenContent
      localVersion.merge(remoteVer.vector)
      localVersion.increment(currentUser.id)
      
      versionChannel.send({
        type: 'broadcast',
        event: 'update',
        payload: {
          content: chosenContent,
          version: localVersion.vector,
          userId: currentUser.id
        }
      })
    }
  })
}
```

**Database-backed conflict resolution:**

Using database as source of truth with optimistic updates and rollback.

**Example:** Optimistic update with database verification
```javascript
let localState = { items: [] }
let pendingUpdates = new Map()

const syncChannel = supabase
  .channel('inventory-sync')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'inventory' },
    (payload) => {
      // Database change is source of truth
      if (payload.eventType === 'UPDATE') {
        const pendingId = `${payload.new.id}-${payload.new.updated_at}`
        
        if (!pendingUpdates.has(pendingId)) {
          // Not our update, remote change detected
          const item = localState.items.find(i => i.id === payload.new.id)
          if (item) {
            // Check for conflict
            if (item.version !== payload.old.version) {
              handleInventoryConflict(item, payload.new)
            } else {
              // No conflict, apply remote change
              updateLocalItem(payload.new)
            }
          }
        } else {
          // Our update was confirmed
          pendingUpdates.delete(pendingId)
        }
      }
    }
  )
  .subscribe()

async function updateItemQuantity(itemId, newQuantity) {
  const item = localState.items.find(i => i.id === itemId)
  const originalQuantity = item.quantity
  const originalVersion = item.version
  
  // Optimistic update
  item.quantity = newQuantity
  renderInventory(localState.items)
  
  try {
    // Attempt database update with version check
    const { data, error } = await supabase
      .from('inventory')
      .update({ 
        quantity: newQuantity,
        version: originalVersion + 1,
        updated_at: new Date().toISOString()
      })
      .eq('id', itemId)
      .eq('version', originalVersion) // Ensures no concurrent modification
      .select()
      .single()
    
    if (error || !data) {
      // Version mismatch or other error, rollback
      item.quantity = originalQuantity
      renderInventory(localState.items)
      
      // Fetch latest version
      const { data: latest } = await supabase
        .from('inventory')
        .select('*')
        .eq('id', itemId)
        .single()
      
      handleInventoryConflict(
        { ...item, quantity: originalQuantity },
        latest
      )
    } else {
      // Success, track pending update
      const pendingId = `${data.id}-${data.updated_at}`
      pendingUpdates.set(pendingId, { itemId, newQuantity })
      
      // Update local version
      item.version = data.version
    }
  } catch (err) {
    // Network error, rollback
    item.quantity = originalQuantity
    renderInventory(localState.items)
    showError('Update failed, please try again')
  }
}

function handleInventoryConflict(localItem, remoteItem) {
  showConflictDialog({
    message: `Item "${localItem.name}" was modified by another user`,
    local: `Your quantity: ${localItem.quantity}`,
    remote: `Their quantity: ${remoteItem.quantity}`,
    options: [
      {
        label: 'Keep yours',
        action: () => updateItemQuantity(localItem.id, localItem.quantity)
      },
      {
        label: 'Use theirs',
        action: () => updateLocalItem(remoteItem)
      },
      {
        label: 'Enter new value',
        action: () => promptForQuantity(localItem.id)
      }
    ]
  })
}
```

**Related topics:** WebSocket connection management, PostgreSQL logical replication configuration, Phoenix Channels architecture, Client-side state management patterns, Network partition handling, Eventual consistency models, Distributed systems conflict resolution

---

# Storage

Supabase Storage provides S3-compatible object storage for managing files within your application. Storage organizes files into buckets, applies Row Level Security policies for access control, and offers file transformation capabilities for images. The system integrates with Supabase Auth to enforce permissions at the file level.

## Storage Buckets Creation and Management

Buckets are containers that organize and isolate files. Each bucket maintains its own security policies and configuration settings.

Creating a bucket via SQL:

```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);
```

Creating a bucket via JavaScript client:

```javascript
const { data, error } = await supabase
  .storage
  .createBucket('avatars', {
    public: false,
    fileSizeLimit: 1048576, // 1MB in bytes
    allowedMimeTypes: ['image/png', 'image/jpeg']
  });
```

Retrieving bucket details:

```javascript
const { data, error } = await supabase
  .storage
  .getBucket('avatars');
```

Updating bucket configuration:

```javascript
const { data, error } = await supabase
  .storage
  .updateBucket('avatars', {
    public: false,
    fileSizeLimit: 2097152 // 2MB
  });
```

Deleting a bucket:

```javascript
const { data, error } = await supabase
  .storage
  .deleteBucket('avatars');
```

Listing all buckets:

```javascript
const { data, error } = await supabase
  .storage
  .listBuckets();
```

Emptying a bucket (removing all files):

```javascript
const { data, error } = await supabase
  .storage
  .emptyBucket('avatars');
```

Bucket naming constraints follow object storage conventions: lowercase alphanumeric characters, hyphens, and underscores only.

## Public vs Private Buckets

Public buckets allow unauthenticated access to files without authentication tokens. Private buckets require authentication and policy evaluation for every access.

**Public bucket characteristics:**

- Files accessible via direct URLs without authentication
- Suitable for assets like logos, public images, or downloadable resources
- Still respect RLS policies if configured
- URLs remain stable and cacheable

Creating a public bucket:

```javascript
const { data, error } = await supabase
  .storage
  .createBucket('public-assets', { public: true });
```

Public file URL structure:

```
https://[project-ref].supabase.co/storage/v1/object/public/[bucket-name]/[file-path]
```

**Private bucket characteristics:**

- Require authentication headers or signed URLs for access
- Default security posture for sensitive files
- Policy evaluation on every request
- URLs require authorization tokens

Creating a private bucket:

```javascript
const { data, error } = await supabase
  .storage
  .createBucket('user-documents', { public: false });
```

Converting bucket visibility:

```javascript
const { data, error } = await supabase
  .storage
  .updateBucket('avatars', { public: true });
```

**[Inference]** Changing a bucket from private to public exposes all existing files to unauthenticated access, which could create security risks if files contain sensitive information.

## Uploading Files

File uploads support multiple methods including direct file objects, blobs, ArrayBuffers, and base64 encoded strings.

Standard file upload:

```javascript
const file = event.target.files[0];
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload(`public/${user.id}/avatar.png`, file);
```

Upload with custom options:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('user-avatar.png', file, {
    cacheControl: '3600',
    upsert: false,
    contentType: 'image/png'
  });
```

Upload to a nested path:

```javascript
const filePath = `${user.id}/documents/report-2024.pdf`;
const { data, error } = await supabase
  .storage
  .from('user-documents')
  .upload(filePath, file);
```

Upsert (overwrite existing file):

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('profile.jpg', file, { upsert: true });
```

Upload from base64:

```javascript
const base64String = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUg...';
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('image.png', decode(base64String), {
    contentType: 'image/png'
  });
```

Upload response structure:

```javascript
{
  data: {
    path: 'user-123/avatar.png',
    id: 'uuid-string',
    fullPath: 'avatars/user-123/avatar.png'
  },
  error: null
}
```

Handling upload errors:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload(filePath, file);

if (error) {
  if (error.message.includes('Duplicate')) {
    // File already exists
  } else if (error.message.includes('size')) {
    // File too large
  } else {
    // Other error
  }
}
```

## Downloading Files

Files are retrieved through direct downloads or by generating accessible URLs for client-side rendering.

Download as blob:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .download('user-123/avatar.png');

// data is a Blob object
const url = URL.createObjectURL(data);
```

Download with progress tracking:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .download('large-file.pdf', {
    onDownloadProgress: (progressEvent) => {
      const percentCompleted = Math.round(
        (progressEvent.loaded * 100) / progressEvent.total
      );
      console.log(percentCompleted);
    }
  });
```

Get public URL (for public buckets):

```javascript
const { data } = supabase
  .storage
  .from('avatars')
  .getPublicUrl('user-123/avatar.png');

// data.publicUrl contains the direct URL
```

Public URL with transformation (images):

```javascript
const { data } = supabase
  .storage
  .from('avatars')
  .getPublicUrl('user-123/avatar.png', {
    transform: {
      width: 200,
      height: 200
    }
  });
```

Creating authenticated URLs for private buckets:

```javascript
const { data, error } = await supabase
  .storage
  .from('private-documents')
  .createSignedUrl('document.pdf', 60); // Expires in 60 seconds
```

Downloading and displaying an image:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .download('avatar.png');

if (data) {
  const url = URL.createObjectURL(data);
  document.getElementById('avatar').src = url;
}
```

## Listing Files

File listing operations retrieve metadata about stored objects within buckets and folders.

List all files in a bucket:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .list();
```

List files in a specific folder:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .list('user-123/reports');
```

List with options:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .list('user-123', {
    limit: 100,
    offset: 0,
    sortBy: { column: 'name', order: 'asc' }
  });
```

Search files by prefix:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .list('user-123', {
    search: 'invoice'
  });
```

Response structure:

```javascript
[
  {
    name: 'avatar.png',
    id: 'uuid',
    updated_at: '2024-01-15T10:30:00.000Z',
    created_at: '2024-01-15T10:30:00.000Z',
    last_accessed_at: '2024-01-15T10:30:00.000Z',
    metadata: {
      eTag: '"abc123"',
      size: 524288,
      mimetype: 'image/png',
      cacheControl: 'max-age=3600'
    }
  }
]
```

Recursive listing through folders:

```javascript
async function listAllFiles(bucket, folder = '') {
  const files = [];
  const { data, error } = await supabase
    .storage
    .from(bucket)
    .list(folder);
  
  for (const item of data) {
    const path = folder ? `${folder}/${item.name}` : item.name;
    if (item.id === null) {
      // It's a folder
      const subFiles = await listAllFiles(bucket, path);
      files.push(...subFiles);
    } else {
      // It's a file
      files.push(path);
    }
  }
  
  return files;
}
```

## Deleting Files

File deletion removes objects permanently from storage buckets.

Delete a single file:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .remove(['user-123/avatar.png']);
```

Delete multiple files:

```javascript
const filePaths = [
  'user-123/old-avatar.png',
  'user-123/temp-file.txt',
  'user-123/document.pdf'
];

const { data, error } = await supabase
  .storage
  .from('documents')
  .remove(filePaths);
```

Delete all files in a folder:

```javascript
// First list all files
const { data: files, error: listError } = await supabase
  .storage
  .from('documents')
  .list('user-123/temp');

// Extract file paths
const filePaths = files.map(file => `user-123/temp/${file.name}`);

// Delete all files
const { data, error } = await supabase
  .storage
  .from('documents')
  .remove(filePaths);
```

Delete with error handling:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .remove(['avatar.png']);

if (error) {
  if (error.message.includes('not found')) {
    // File doesn't exist
  } else if (error.message.includes('permission')) {
    // Insufficient permissions
  }
}
```

**[Inference]** Deleting files is permanent and cannot be undone unless you have implemented your own versioning or backup system.

## File Transformations (Images)

Supabase Storage provides on-the-fly image transformations for resizing, formatting, and optimizing images without storing multiple versions.

Basic resize transformation:

```javascript
const { data } = supabase
  .storage
  .from('avatars')
  .getPublicUrl('avatar.png', {
    transform: {
      width: 200,
      height: 200
    }
  });
```

Resize with quality control:

```javascript
const { data } = supabase
  .storage
  .from('photos')
  .getPublicUrl('photo.jpg', {
    transform: {
      width: 800,
      height: 600,
      resize: 'cover', // or 'contain', 'fill'
      quality: 80
    }
  });
```

Format conversion:

```javascript
const { data } = supabase
  .storage
  .from('images')
  .getPublicUrl('image.png', {
    transform: {
      format: 'webp'
    }
  });
```

Available transformation options:

- `width`: Target width in pixels
- `height`: Target height in pixels
- `resize`: Fit mode (`cover`, `contain`, `fill`)
- `quality`: Output quality (1-100)
- `format`: Output format (`webp`, `jpeg`, `png`, `avif`)

Transformation resize modes:

**cover** - Resizes to fill dimensions, cropping excess:

```javascript
transform: { width: 400, height: 300, resize: 'cover' }
```

**contain** - Resizes to fit within dimensions, maintaining aspect ratio:

```javascript
transform: { width: 400, height: 300, resize: 'contain' }
```

**fill** - Resizes to exact dimensions, potentially distorting:

```javascript
transform: { width: 400, height: 300, resize: 'fill' }
```

Signed URLs with transformations:

```javascript
const { data, error } = await supabase
  .storage
  .from('private-photos')
  .createSignedUrl('photo.jpg', 3600, {
    transform: {
      width: 500,
      height: 500,
      resize: 'cover'
    }
  });
```

Responsive image generation:

```javascript
const sizes = [400, 800, 1200];
const urls = sizes.map(width => {
  const { data } = supabase
    .storage
    .from('photos')
    .getPublicUrl('hero.jpg', {
      transform: { width, quality: 85 }
    });
  return data.publicUrl;
});
```

**[Unverified]** Transformation performance and caching behavior may vary based on image size, format, and CDN configuration.

## Storage Policies and RLS

Storage buckets use PostgreSQL Row Level Security policies applied to the `storage.objects` table, controlling file access based on user authentication and custom conditions.

The `storage.objects` table structure includes:

- `bucket_id`: Bucket identifier
- `name`: File path within bucket
- `owner`: User ID of file uploader
- `created_at`: Upload timestamp
- `updated_at`: Last modification timestamp
- `metadata`: JSON object with file metadata

Basic policy allowing users to upload files:

```sql
CREATE POLICY "Users can upload own files"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

Policy allowing users to read their own files:

```sql
CREATE POLICY "Users can read own files"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

Policy allowing users to update their own files:

```sql
CREATE POLICY "Users can update own files"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

Policy allowing users to delete their own files:

```sql
CREATE POLICY "Users can delete own files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

Helper function `storage.foldername()` extracts folder segments from file paths:

```sql
-- For path 'user-123/subfolder/file.png'
-- storage.foldername(name) returns ['user-123', 'subfolder']
```

Public read policy (for public assets):

```sql
CREATE POLICY "Public assets are publicly accessible"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'public-assets');
```

Policy based on file ownership:

```sql
CREATE POLICY "Owner can manage files"
ON storage.objects
FOR ALL
TO authenticated
USING (auth.uid() = owner);
```

Team-based access policy:

```sql
CREATE POLICY "Team members can access team files"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'team-documents'
  AND (storage.foldername(name))[1] IN (
    SELECT team_id::text FROM team_members
    WHERE user_id = auth.uid()
  )
);
```

File type restriction policy:

```sql
CREATE POLICY "Only images allowed"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (metadata->>'mimetype' LIKE 'image/%')
);
```

Size restriction policy:

```sql
CREATE POLICY "Limit file size"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'documents'
  AND (metadata->>'size')::int < 10485760 -- 10MB
);
```

**[Inference]** Storage policies execute for every file operation, potentially impacting performance for buckets with complex access rules or large numbers of files.

## Signed URLs

Signed URLs provide temporary, authenticated access to files in private buckets without requiring the client to maintain authentication state.

Creating a signed URL:

```javascript
const { data, error } = await supabase
  .storage
  .from('private-documents')
  .createSignedUrl('document.pdf', 3600); // Expires in 3600 seconds (1 hour)

// data.signedUrl contains the temporary URL
```

Signed URL with transformations:

```javascript
const { data, error } = await supabase
  .storage
  .from('private-photos')
  .createSignedUrl('photo.jpg', 3600, {
    transform: {
      width: 400,
      height: 300,
      resize: 'cover',
      quality: 85
    }
  });
```

Creating multiple signed URLs:

```javascript
const files = ['file1.pdf', 'file2.pdf', 'file3.pdf'];
const { data, error } = await supabase
  .storage
  .from('documents')
  .createSignedUrls(files, 3600);

// data is an array of signed URL objects
```

Response structure:

```javascript
{
  data: {
    signedUrl: 'https://[project].supabase.co/storage/v1/object/sign/[bucket]/[path]?token=[token]',
    path: 'documents/file.pdf'
  },
  error: null
}
```

Signed URL expiration options:

```javascript
// Short-lived (5 minutes)
createSignedUrl('file.pdf', 300)

// Medium-lived (1 hour)
createSignedUrl('file.pdf', 3600)

// Long-lived (24 hours)
createSignedUrl('file.pdf', 86400)
```

Using signed URLs in applications:

```javascript
// Generate signed URL server-side
const { data } = await supabase
  .storage
  .from('private-videos')
  .createSignedUrl('video.mp4', 7200);

// Send to client
return { videoUrl: data.signedUrl };

// Client displays video
<video src={videoUrl} controls />
```

Download file using signed URL:

```javascript
const { data } = await supabase
  .storage
  .from('reports')
  .createSignedUrl('monthly-report.pdf', 600);

// Trigger download in browser
const link = document.createElement('a');
link.href = data.signedUrl;
link.download = 'report.pdf';
link.click();
```

**[Inference]** Signed URLs expire after the specified duration, requiring regeneration for continued access, which may require application logic to refresh URLs before expiration.

## File Size Limits and Quotas

Storage systems impose limits on file sizes and total storage capacity to manage resources and costs.

**Default file size limits:**

Free tier projects: 50MB per file Pro tier projects: 50MB per file (configurable) Enterprise: Custom limits

Setting bucket-specific size limits:

```javascript
const { data, error } = await supabase
  .storage
  .createBucket('documents', {
    public: false,
    fileSizeLimit: 10485760 // 10MB in bytes
  });
```

Updating bucket size limits:

```javascript
const { data, error } = await supabase
  .storage
  .updateBucket('documents', {
    fileSizeLimit: 52428800 // 50MB
  });
```

Enforcing size limits via RLS policy:

```sql
CREATE POLICY "Enforce file size limit"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (metadata->>'size')::bigint <= 5242880 -- 5MB
);
```

**Storage quotas:**

Free tier: 1GB total storage Pro tier: 100GB included, then pay per GB Enterprise: Custom allocations

**[Unverified]** Specific quota limits and pricing may change based on Supabase's current pricing structure and plan offerings.

Checking storage usage (via SQL):

```sql
SELECT 
  bucket_id,
  COUNT(*) as file_count,
  SUM((metadata->>'size')::bigint) as total_bytes
FROM storage.objects
GROUP BY bucket_id;
```

Client-side file size validation:

```javascript
const maxSize = 5 * 1024 * 1024; // 5MB

function validateFileSize(file) {
  if (file.size > maxSize) {
    throw new Error('File exceeds maximum size of 5MB');
  }
}

// Before upload
const file = event.target.files[0];
validateFileSize(file);

const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('avatar.png', file);
```

Handling quota exceeded errors:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .upload('large-file.zip', file);

if (error) {
  if (error.message.includes('quota')) {
    // Storage quota exceeded
  } else if (error.message.includes('size')) {
    // File size limit exceeded
  }
}
```

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

# Edge Functions

Edge Functions in Supabase are server-side TypeScript functions that run on globally distributed edge servers, providing low-latency execution close to your users. Built on Deno Deploy infrastructure, they enable serverless computing with automatic scaling, built-in security, and seamless integration with your Supabase project.

## Serverless Functions Overview

Edge Functions execute code on-demand without managing servers. They run in isolated environments across multiple geographic regions, automatically scaling based on traffic. Each function operates independently with its own execution context, making them ideal for API endpoints, webhooks, data transformations, and background processing.

The functions use the Deno runtime, which provides native TypeScript support, secure-by-default execution, and Web Standard APIs. Unlike traditional serverless platforms, Edge Functions have minimal cold start times and can access Supabase services directly through pre-configured clients.

**Key characteristics:**

- **Geographic distribution**: Functions deploy to multiple edge locations globally, reducing latency by executing close to users
- **Automatic scaling**: Infrastructure scales from zero to handle millions of requests without configuration
- **Isolated execution**: Each invocation runs in a secure V8 isolate with resource limits and timeout controls
- **Native integrations**: Direct access to Supabase Auth, Database, Storage, and other services through environment variables
- **Standards-based**: Uses standard Web APIs (fetch, Request, Response) for compatibility and portability

## Creating Edge Functions

Edge Functions are created using the Supabase CLI. Each function exists as a TypeScript file in your project's `supabase/functions` directory with a specific structure that exports a default handler.

**Basic function structure:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { name } = await req.json()
  const data = {
    message: `Hello ${name}!`,
  }

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})
```

**Creation process:**

Create a new function using the CLI command `supabase functions new function-name`. This generates a directory structure with a default index.ts file. The function name becomes part of its URL endpoint and should use kebab-case naming.

Functions must export a handler that accepts a Request object and returns a Response object, following the standard Fetch API specification. This handler processes incoming HTTP requests and generates appropriate responses.

**Function organization:**

- Each function resides in `supabase/functions/[function-name]/index.ts`
- Shared code can be placed in `supabase/functions/_shared/` for imports across multiple functions
- Local dependencies use relative imports with `.ts` extensions
- External dependencies import from URLs (Deno-style) with version pinning

**Example with multiple operations:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { method } = req
  const url = new URL(req.url)
  
  if (method === "GET") {
    return new Response(JSON.stringify({ status: "active" }))
  }
  
  if (method === "POST") {
    const body = await req.json()
    // Process POST data
    return new Response(JSON.stringify({ received: body }))
  }
  
  return new Response("Method not allowed", { status: 405 })
})
```

## Deploying Edge Functions

Deployment pushes your local function code to Supabase's edge infrastructure, making it available at a unique URL endpoint. Functions deploy individually or in batches, with versioning and rollback capabilities.

**Deployment commands:**

Deploy a specific function: `supabase functions deploy function-name`

Deploy all functions: `supabase functions deploy`

Each deployment creates a new version while maintaining the same public URL. The platform handles zero-downtime deployments by gradually routing traffic to the new version.

**Deployment workflow:**

Link your local project to a Supabase project using `supabase link --project-ref your-project-ref`. This establishes the connection between your local environment and the remote project where functions will deploy.

After linking, the deploy command bundles your TypeScript code, resolves dependencies, and uploads everything to the edge infrastructure. The CLI provides real-time feedback on the deployment status.

**Verification and testing:**

After deployment, test the function using its generated URL: `https://your-project-ref.supabase.co/functions/v1/function-name`

Functions appear in the Supabase Dashboard under Edge Functions, where you can view logs, invocation metrics, and configuration settings.

**Example deployment output:**

```
Deploying function hello-world...
Bundle size: 12.3 KB
Function URL: https://abcdefgh.supabase.co/functions/v1/hello-world
Deployed successfully in 3.2s
```

**Version management:**

Each deployment is immutable. To update a function, deploy again with modified code. The previous version remains in history but becomes inactive. [Inference] Rollback capabilities may be available through the dashboard or CLI, though specific rollback commands are not confirmed in this context.

## Function Runtime and Environment

Edge Functions execute in the Deno runtime, providing a secure, modern JavaScript/TypeScript environment with specific capabilities and constraints.

**Runtime specifications:**

- **Language support**: Native TypeScript and JavaScript (ES2022+) without transpilation requirements
- **V8 isolates**: Each invocation runs in an isolated V8 environment preventing cross-contamination
- **Execution limits**: Default timeout of 150 seconds per invocation; configurable resource limits for memory and CPU
- **Standard APIs**: Full support for Web APIs including fetch, Request, Response, Headers, URL, crypto, and streams

**Deno-specific features:**

Deno's security model requires explicit permissions for file system, network, and environment access. Edge Functions run with pre-configured permissions appropriate for serverless execution. The runtime does not support Node.js built-in modules directly; use Deno-compatible alternatives or npm specifiers.

Import maps can configure module resolution, though Edge Functions typically use direct URL imports for dependencies. Version pinning in imports ensures reproducible builds.

**Environment characteristics:**

Functions are stateless between invocations. Each request starts with a clean execution context. Persistent data must be stored in databases, storage buckets, or external services. Global variables reset between invocations and cannot reliably share state.

Cold starts occur when a function hasn't been invoked recently in a specific region. Warm invocations reuse existing isolates for faster execution. [Inference] The platform likely optimizes for minimal cold start times through V8 isolate pooling.

**Supported Web Standards:**

- Fetch API for HTTP requests
- Streams API for processing large data
- Web Crypto API for cryptographic operations
- TextEncoder/TextDecoder for text processing
- URLPattern for route matching
- AbortController for cancellation

**Example using Web Standards:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // Using Web Crypto API
  const data = new TextEncoder().encode("sensitive data")
  const hashBuffer = await crypto.subtle.digest("SHA-256", data)
  const hash = Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('')
  
  return new Response(JSON.stringify({ hash }))
})
```

## Invoking Functions from Client

Client applications call Edge Functions through HTTP requests to their unique endpoints. Supabase provides client libraries with built-in methods for simplified invocation.

**Using JavaScript client:**

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

const { data, error } = await supabase.functions.invoke('function-name', {
  body: { name: 'User' }
})
```

The `invoke` method handles authentication automatically, passing the user's JWT token in request headers when users are authenticated. This allows functions to verify user identity and enforce authorization rules.

**Direct HTTP requests:**

Functions accept standard HTTP requests from any client capable of making fetch calls:

```typescript
const response = await fetch(
  'https://your-project-ref.supabase.co/functions/v1/function-name',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${ANON_KEY}`
    },
    body: JSON.stringify({ name: 'User' })
  }
)

const data = await response.json()
```

**Authentication and authorization:**

Include the `Authorization` header with either the anon key (for public access) or a user's JWT token (for authenticated requests). Functions can extract user information from the JWT to implement authorization logic.

**Request customization:**

Pass custom headers, query parameters, and request bodies based on your function's requirements:

```typescript
const { data, error } = await supabase.functions.invoke('function-name', {
  body: { key: 'value' },
  headers: { 'X-Custom-Header': 'value' },
  method: 'POST'
})
```

**Response handling:**

Functions return standard HTTP responses. The client library parses JSON responses automatically. Handle errors by checking the error object or response status codes:

```typescript
const { data, error } = await supabase.functions.invoke('function-name')

if (error) {
  console.error('Function error:', error.message)
  return
}

console.log('Function result:', data)
```

**Example with error handling:**

```typescript
try {
  const { data, error } = await supabase.functions.invoke('process-payment', {
    body: {
      amount: 1000,
      currency: 'USD'
    }
  })
  
  if (error) throw error
  
  console.log('Payment processed:', data.transactionId)
} catch (err) {
  console.error('Payment failed:', err.message)
}
```

## Function Secrets and Environment Variables

Edge Functions access configuration and sensitive data through environment variables, which are managed separately from code for security and flexibility.

**Setting environment variables:**

Variables are configured using the Supabase CLI or dashboard. Secrets like API keys should never be committed to code. Use the command `supabase secrets set SECRET_NAME=value` to configure secrets for your functions.

**Accessing variables in functions:**

Environment variables are available through `Deno.env.get()`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const apiKey = Deno.env.get('THIRD_PARTY_API_KEY')
  
  if (!apiKey) {
    return new Response('Configuration error', { status: 500 })
  }
  
  // Use the API key
  const response = await fetch('https://api.example.com/data', {
    headers: { 'Authorization': `Bearer ${apiKey}` }
  })
  
  return response
})
```

**Built-in environment variables:**

Supabase automatically provides several environment variables to functions:

- `SUPABASE_URL`: Your project's API URL
- `SUPABASE_ANON_KEY`: Public anonymous key for client requests
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key with full database access (use carefully)

**Security considerations:**

Service role keys bypass Row Level Security policies and should only be used for administrative operations. Never expose service role keys to clients. Use the anon key for client-facing operations and rely on RLS policies for security.

**Local development:**

Create a `.env` file in your project root for local testing. The Supabase CLI loads these variables when running functions locally with `supabase functions serve`:

```
THIRD_PARTY_API_KEY=your-dev-api-key
CUSTOM_CONFIG=value
```

**Example with multiple secrets:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const stripeKey = Deno.env.get('STRIPE_SECRET_KEY')
  const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')
  const sendgridKey = Deno.env.get('SENDGRID_API_KEY')
  
  // Verify all required secrets are present
  if (!stripeKey || !webhookSecret || !sendgridKey) {
    return new Response('Missing required configuration', { status: 500 })
  }
  
  // Use secrets for operations
})
```

## CORS Handling

Cross-Origin Resource Sharing (CORS) controls which web applications can call your Edge Functions. Proper CORS configuration is essential for browser-based clients.

**Default CORS behavior:**

Edge Functions do not automatically handle CORS. Browsers block requests from different origins unless the function explicitly allows them through response headers.

**Implementing CORS:**

Add CORS headers to function responses manually:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Process actual request
  const data = { message: 'Success' }
  
  return new Response(
    JSON.stringify(data),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200 
    }
  )
})
```

**Preflight requests:**

Browsers send OPTIONS requests before actual requests for cross-origin calls. Functions must respond to OPTIONS requests with appropriate CORS headers and a 200 status code.

**Restrictive CORS:**

For production environments, specify exact origins instead of wildcards:

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://yourdomain.com',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Max-Age': '86400', // Cache preflight for 24 hours
}
```

**Credentials and authentication:**

When using credentials (cookies, authorization headers), set `Access-Control-Allow-Credentials: true` and specify an exact origin (wildcards not allowed with credentials):

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://app.yourdomain.com',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Headers': 'authorization, content-type',
}
```

**Helper function for CORS:**

```typescript
function corsResponse(data: any, status = 200) {
  return new Response(
    JSON.stringify(data),
    {
      status,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        'Content-Type': 'application/json',
      }
    }
  )
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return corsResponse('ok')
  }
  
  const result = { success: true }
  return corsResponse(result)
})
```

## Database Access from Functions

Edge Functions access your Supabase Postgres database through the Supabase JavaScript client, with full support for queries, mutations, and real-time subscriptions.

**Initializing the database client:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )
  
  // Query database
  const { data, error } = await supabaseClient
    .from('users')
    .select('*')
    .limit(10)
  
  return new Response(JSON.stringify(data))
})
```

**Using service role for admin operations:**

For operations requiring elevated privileges (bypassing RLS), use the service role key:

```typescript
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

// This bypasses RLS policies
const { data, error } = await supabaseAdmin
  .from('private_data')
  .select('*')
```

**Respecting user context:**

Pass the user's authorization token to respect Row Level Security policies:

```typescript
const authHeader = req.headers.get('Authorization')
const supabaseClient = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_ANON_KEY') ?? '',
  { global: { headers: { Authorization: authHeader! } } }
)

// Queries respect RLS policies based on the authenticated user
const { data } = await supabaseClient
  .from('user_data')
  .select('*')
```

**Complex database operations:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  // Insert with related data
  const { data: order, error } = await supabase
    .from('orders')
    .insert({
      customer_id: 123,
      total: 99.99,
      status: 'pending'
    })
    .select()
    .single()
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }
  
  // Insert order items
  await supabase
    .from('order_items')
    .insert([
      { order_id: order.id, product_id: 1, quantity: 2 },
      { order_id: order.id, product_id: 3, quantity: 1 }
    ])
  
  return new Response(JSON.stringify({ order }))
})
```

**Calling Postgres functions:**

Execute stored procedures or custom SQL functions:

```typescript
const { data, error } = await supabaseClient
  .rpc('calculate_order_total', { order_id: 123 })

if (error) {
  return new Response(JSON.stringify({ error: error.message }), { status: 500 })
}

return new Response(JSON.stringify({ total: data }))
```

**Transaction handling:**

[Inference] Edge Functions can execute multiple database operations atomically by using Postgres stored procedures that implement transaction logic, as the JavaScript client doesn't provide explicit transaction APIs.

## Third-Party API Integration

Edge Functions serve as backends for integrating external services, handling API authentication, rate limiting, and data transformation without exposing credentials to clients.

**Making external API calls:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const apiKey = Deno.env.get('OPENAI_API_KEY')
  
  const { prompt } = await req.json()
  
  const response = await fetch('https://api.openai.com/v1/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: 'text-davinci-003',
      prompt: prompt,
      max_tokens: 100
    })
  })
  
  const data = await response.json()
  return new Response(JSON.stringify(data))
})
```

**Handling API responses:**

Transform third-party API responses into formats suitable for your application:

```typescript
serve(async (req) => {
  const response = await fetch('https://api.weather.com/data', {
    headers: { 'X-API-Key': Deno.env.get('WEATHER_API_KEY')! }
  })
  
  const weatherData = await response.json()
  
  // Transform to simplified format
  const transformed = {
    temperature: weatherData.main.temp,
    condition: weatherData.weather[0].main,
    humidity: weatherData.main.humidity
  }
  
  return new Response(JSON.stringify(transformed))
})
```

**Error handling with external APIs:**

```typescript
serve(async (req) => {
  try {
    const response = await fetch('https://api.stripe.com/v1/charges', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('STRIPE_SECRET_KEY')}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'amount=1000&currency=usd&source=tok_visa'
    })
    
    if (!response.ok) {
      const error = await response.json()
      return new Response(
        JSON.stringify({ error: error.message }), 
        { status: response.status }
      )
    }
    
    const charge = await response.json()
    return new Response(JSON.stringify({ success: true, charge }))
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Payment processing failed' }),
      { status: 500 }
    )
  }
})
```

**Webhook handling:**

Process webhooks from external services:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // Verify webhook signature
  const signature = req.headers.get('stripe-signature')
  const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')
  
  const body = await req.text()
  
  // Stripe signature verification logic
  // [Implementation details omitted for brevity]
  
  const event = JSON.parse(body)
  
  if (event.type === 'payment_intent.succeeded') {
    // Update database with payment confirmation
    const supabase = createClient(...)
    await supabase
      .from('payments')
      .update({ status: 'completed' })
      .eq('stripe_id', event.data.object.id)
  }
  
  return new Response(JSON.stringify({ received: true }), { status: 200 })
})
```

**Rate limiting and retry logic:**

[Inference] Implement custom retry mechanisms for external API calls that may fail temporarily:

```typescript
async function fetchWithRetry(url: string, options: any, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, options)
      if (response.ok) return response
      
      if (response.status === 429) { // Rate limited
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)))
        continue
      }
      
      return response
    } catch (error) {
      if (i === retries - 1) throw error
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)))
    }
  }
}
```

## Background Jobs and Scheduled Functions

Edge Functions can execute scheduled tasks and background processing jobs through external triggers or scheduling services.

**Scheduled execution patterns:**

[Unverified] Supabase may offer native cron-style scheduling for Edge Functions. Alternatively, use external cron services like GitHub Actions, cron-job.org, or EasyCron to trigger functions on schedules.

**GitHub Actions for scheduling:**

```yaml
name: Scheduled Function
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Call Edge Function
        run: |
          curl -X POST \
            https://your-project.supabase.co/functions/v1/daily-cleanup \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_ANON_KEY }}"
```

**Background processing patterns:**

Implement long-running tasks by breaking them into smaller chunks or using external job queues:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  // Fetch pending jobs
  const { data: jobs } = await supabase
    .from('background_jobs')
    .select('*')
    .eq('status', 'pending')
    .limit(10)
  
  // Process each job
  for (const job of jobs || []) {
    try {
      // Perform work
      await processJob(job)
      
      // Mark as completed
      await supabase
        .from('background_jobs')
        .update({ status: 'completed', completed_at: new Date().toISOString() })
        .eq('id', job.id)
    } catch (error) {
      // Mark as failed
      await supabase
        .from('background_jobs')
        .update({ status: 'failed', error: error.message })
        .eq('id', job.id)
    }
  }
  
  return new Response(JSON.stringify({ processed: jobs?.length || 0 }))
})
```

**Async task patterns:**

Trigger background work without waiting for completion:

```typescript
serve(async (req) => {
  const { taskData } = await req.json()
  
  // Store task in database
  const supabase = createClient(...)
  await supabase
    .from('tasks')
    .insert({ data: taskData, status: 'queued' })
  
  // Return immediately
  return new Response(
    JSON.stringify({ message: 'Task queued' }),
    { status: 202 }
  )
})

// Separate function to process tasks
serve(async (req) => {
  const supabase = createClient(...)
  
  const { data: tasks } = await supabase
    .from('tasks')
    .select('*')
    .eq('status', 'queued')
    .limit(5)
  
  for (const task of tasks || []) {
    await processTask(task)
    await supabase
      .from('tasks')
      .update({ status: 'completed' })
      .eq('id', task.id)
  }
  
  return new Response('OK')
})
```

**Email digests and notifications:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const supabase = createClient(...)
  
  // Get users who should receive daily digest
  const { data: users } = await supabase
    .from('users')
    .select('email, preferences')
    .eq('digest_enabled', true)
  
  for (const user of users || []) {
    // Gather user's daily content
    const { data: content } = await supabase
      .from('content')
      .select('*')
      .eq('user_id', user.id)
      .gte('created_at', new Date(Date.now() - 86400000).toISOString())
    
    // Send email via SendGrid, Resend, or other service
    await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('SENDGRID_API_KEY')}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        personalizations: [{ to: [{ email: user.email }] }],
        from: { email: 'digest@yourapp.com' },
        subject: 'Your Daily Digest',
        content: [{ type: 'text/html', value: generateDigestHTML(content) }]
      })
    })
  }
  
  return new Response(JSON.stringify({ sent: users?.length || 0 }))
})
```

## Error Handling and Logging

Robust error handling and logging enable debugging, monitoring, and maintaining Edge Functions in production environments.

**Basic error handling:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    const { data } = await req.json()
    
    if (!data) {
      return new Response(
        JSON.stringify({ error: 'Missing required data' }),
        { status: 400 }
      )
    }
    
    // Process request
    const result = await processData(data)
    
    return new Response(JSON.stringify({ success: true, result }))
    
  } catch (error) {
    console.error('Function error:', error)
    
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500 }
    )
  }
})
```

**Structured logging:**

Console logs in Edge Functions appear in the Supabase dashboard's function logs:

```typescript
serve(async (req) => {
  const startTime = Date.now()
  
  console.log('Function invoked', {
    method: req.method,
    url: req.url,
    timestamp: new Date().toISOString()
  })
  
  try {
    const result = await performOperation()
    
    console.log('Operation completed', {
      duration: Date.now() - startTime,
      resultSize: JSON.stringify(result).length
    })
    
    return new Response(JSON.stringify(result))
    
  } catch (error) {
    console.error('Operation failed', {
      error: error.message,
      stack: error.stack,
      duration: Date.now() - startTime
    })
    
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    )
  }
})
```

**Custom error classes:**

```typescript
class ValidationError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'ValidationError'
  }
}

class DatabaseError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'DatabaseError'
  }
}

serve(async (req) => {
  try {
    const { email } = await req.json()
    
    if (!email || !email.includes('@')) {
      throw new ValidationError('Invalid email format')
    }
    
    const supabase = createClient(...)
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
    
    if (error) {
      throw new DatabaseError(`Database query failed: ${error.message}`)
    }
    
    return new Response(JSON.stringify(data))
    
  } catch (error) {
    if (error instanceof ValidationError) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 400 }
      )
    }
    
    if (error instanceof DatabaseError) {
      console.error('Database error:', error)
      return new Response(
        JSON.stringify({ error: 'Service temporarily unavailable' }),
        { status: 503 }
      )
    }
    
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500 }
    )
  }
})
```

**Request validation patterns:**

```typescript
function validateRequest(data: any) {
  const errors = []
  
  if (!data.email) {
    errors.push({ field: 'email', message: 'Email is required' })
  }
  
  if (!data.name || data.name.length < 2) {
    errors.push({ field: 'name', message: 'Name must be at least 2 characters' })
  }
  
  if (data.age && (data.age < 0 || data.age > 120)) {
    errors.push({ field: 'age', message: 'Age must be between 0 and 120' })
  }
  
  return errors
}

serve(async (req) => {
  try {
    const data = await req.json()
    
    const validationErrors = validateRequest(data)
    if (validationErrors.length > 0) {
      return new Response(
        JSON.stringify({ errors: validationErrors }),
        { status: 422 }
      )
    }
    
    // Process valid data
    const result = await saveData(data)
    return new Response(JSON.stringify(result))
    
  } catch (error) {
    console.error('Request processing error:', error)
    return new Response(
      JSON.stringify({ error: 'Failed to process request' }),
      { status: 500 }
    )
  }
})
```

**Monitoring and observability:**

Log key metrics for monitoring function performance:

```typescript
serve(async (req) => {
  const requestId = crypto.randomUUID()
  const startTime = Date.now()
  
  console.log('Request started', {
    requestId,
    method: req.method,
    path: new URL(req.url).pathname,
    timestamp: new Date().toISOString()
  })
  
  try {
    const result = await handleRequest(req)
    
    const duration = Date.now() - startTime
    console.log('Request completed', {
      requestId,
      duration,
      status: 200
    })
    
    return new Response(JSON.stringify(result), {
      headers: {
        'X-Request-ID': requestId,
        'X-Response-Time': `${duration}ms`
      }
    })
    
  } catch (error) {
    const duration = Date.now() - startTime
    console.error('Request failed', {
      requestId,
      duration,
      error: error.message,
      stack: error.stack
    })
    
    return new Response(
      JSON.stringify({ error: error.message, requestId }),
      { 
        status: 500,
        headers: { 'X-Request-ID': requestId }
      }
    )
  }
})
```

**Database error handling:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  try {
    const { userId } = await req.json()
    
    const { data, error } = await supabase
      .from('users')
      .select('*, orders(*)')
      .eq('id', userId)
      .single()
    
    if (error) {
      console.error('Database query error', {
        code: error.code,
        message: error.message,
        details: error.details,
        hint: error.hint
      })
      
      // Handle specific Postgres error codes
      if (error.code === 'PGRST116') {
        return new Response(
          JSON.stringify({ error: 'User not found' }),
          { status: 404 }
        )
      }
      
      return new Response(
        JSON.stringify({ error: 'Database operation failed' }),
        { status: 500 }
      )
    }
    
    return new Response(JSON.stringify(data))
    
  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500 }
    )
  }
})
```

**External API error handling:**

```typescript
serve(async (req) => {
  try {
    const response = await fetch('https://api.external-service.com/data', {
      headers: { 'Authorization': `Bearer ${Deno.env.get('API_KEY')}` },
      signal: AbortSignal.timeout(5000) // 5 second timeout
    })
    
    if (!response.ok) {
      const errorBody = await response.text()
      console.error('External API error', {
        status: response.status,
        statusText: response.statusText,
        body: errorBody
      })
      
      return new Response(
        JSON.stringify({ 
          error: 'External service unavailable',
          details: response.statusText
        }),
        { status: 502 }
      )
    }
    
    const data = await response.json()
    return new Response(JSON.stringify(data))
    
  } catch (error) {
    if (error.name === 'TimeoutError') {
      console.error('External API timeout')
      return new Response(
        JSON.stringify({ error: 'Request timeout' }),
        { status: 504 }
      )
    }
    
    console.error('External API call failed:', error)
    return new Response(
      JSON.stringify({ error: 'Failed to fetch data' }),
      { status: 500 }
    )
  }
})
```

**Graceful degradation:**

```typescript
serve(async (req) => {
  let enrichedData = null
  
  try {
    // Attempt to enrich data from external service
    const response = await fetch('https://enrichment-api.com/data')
    if (response.ok) {
      enrichedData = await response.json()
    } else {
      console.warn('Enrichment service unavailable, continuing without enrichment')
    }
  } catch (error) {
    console.warn('Failed to enrich data:', error.message)
    // Continue without enrichment rather than failing completely
  }
  
  const supabase = createClient(...)
  const { data: baseData } = await supabase
    .from('items')
    .select('*')
  
  // Merge enriched data if available
  const result = enrichedData 
    ? baseData.map(item => ({ ...item, enrichment: enrichedData[item.id] }))
    : baseData
  
  return new Response(JSON.stringify(result))
})
```

**Retry logic with exponential backoff:**

```typescript
async function fetchWithRetry(
  url: string, 
  options: RequestInit, 
  maxRetries = 3
): Promise<Response> {
  let lastError: Error
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      console.log(`Attempt ${attempt + 1} of ${maxRetries}`)
      
      const response = await fetch(url, options)
      
      if (response.ok || response.status < 500) {
        return response
      }
      
      lastError = new Error(`HTTP ${response.status}: ${response.statusText}`)
      
    } catch (error) {
      lastError = error
      console.warn(`Attempt ${attempt + 1} failed:`, error.message)
    }
    
    if (attempt < maxRetries - 1) {
      const delay = Math.pow(2, attempt) * 1000 // Exponential backoff
      console.log(`Retrying in ${delay}ms...`)
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }
  
  throw lastError
}

serve(async (req) => {
  try {
    const response = await fetchWithRetry(
      'https://unreliable-api.com/data',
      { headers: { 'Authorization': `Bearer ${Deno.env.get('API_KEY')}` } }
    )
    
    const data = await response.json()
    return new Response(JSON.stringify(data))
    
  } catch (error) {
    console.error('All retry attempts failed:', error)
    return new Response(
      JSON.stringify({ error: 'Service temporarily unavailable' }),
      { status: 503 }
    )
  }
})
```

**Logging to external services:**

[Inference] Functions can send logs to external monitoring services like Sentry, Datadog, or LogTail for centralized error tracking:

```typescript
async function logToSentry(error: Error, context: any) {
  const sentryDsn = Deno.env.get('SENTRY_DSN')
  if (!sentryDsn) return
  
  try {
    await fetch('https://sentry.io/api/endpoint', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: error.message,
        stack: error.stack,
        context,
        timestamp: new Date().toISOString()
      })
    })
  } catch (err) {
    console.error('Failed to log to Sentry:', err)
  }
}

serve(async (req) => {
  try {
    const result = await riskyOperation()
    return new Response(JSON.stringify(result))
    
  } catch (error) {
    await logToSentry(error, {
      url: req.url,
      method: req.method,
      userAgent: req.headers.get('user-agent')
    })
    
    return new Response(
      JSON.stringify({ error: 'Operation failed' }),
      { status: 500 }
    )
  }
})
```

**Health check endpoints:**

```typescript
serve(async (req) => {
  const url = new URL(req.url)
  
  if (url.pathname === '/health') {
    const supabase = createClient(...)
    
    try {
      // Check database connectivity
      const { error } = await supabase
        .from('_health_check')
        .select('count')
        .limit(1)
      
      if (error) throw error
      
      return new Response(
        JSON.stringify({ 
          status: 'healthy',
          timestamp: new Date().toISOString()
        }),
        { status: 200 }
      )
      
    } catch (error) {
      console.error('Health check failed:', error)
      return new Response(
        JSON.stringify({ 
          status: 'unhealthy',
          error: error.message
        }),
        { status: 503 }
      )
    }
  }
  
  // Regular request handling
  return handleRequest(req)
})
```

**Performance tracking:**

```typescript
class PerformanceTracker {
  private metrics: Map<string, number[]> = new Map()
  
  track(operation: string, duration: number) {
    if (!this.metrics.has(operation)) {
      this.metrics.set(operation, [])
    }
    this.metrics.get(operation)!.push(duration)
  }
  
  getStats(operation: string) {
    const durations = this.metrics.get(operation) || []
    if (durations.length === 0) return null
    
    const sorted = [...durations].sort((a, b) => a - b)
    return {
      count: durations.length,
      avg: durations.reduce((a, b) => a + b, 0) / durations.length,
      min: sorted[0],
      max: sorted[sorted.length - 1],
      p50: sorted[Math.floor(sorted.length * 0.5)],
      p95: sorted[Math.floor(sorted.length * 0.95)]
    }
  }
}

const tracker = new PerformanceTracker()

serve(async (req) => {
  const startDb = Date.now()
  const { data } = await supabase.from('users').select('*')
  tracker.track('db_query', Date.now() - startDb)
  
  const startApi = Date.now()
  await fetch('https://api.example.com/data')
  tracker.track('external_api', Date.now() - startApi)
  
  console.log('Performance stats:', {
    db_query: tracker.getStats('db_query'),
    external_api: tracker.getStats('external_api')
  })
  
  return new Response(JSON.stringify(data))
})
```

**Important related topics:** Database connection pooling strategies, implementing rate limiting in Edge Functions, using Supabase Realtime with Edge Functions, authentication and JWT verification patterns, file upload handling, implementing idempotency for payment operations, WebSocket support in Edge Functions, streaming responses for large datasets, implementing request caching strategies, multi-region deployment considerations.

---

# Database Functions & Triggers in Supabase

Database functions and triggers are powerful PostgreSQL features that allow you to execute server-side logic directly within your database. Supabase provides full access to PostgreSQL's function and trigger capabilities, enabling you to implement complex business logic, automate data operations, and maintain data integrity.

## PostgreSQL Functions

PostgreSQL functions are reusable code blocks that can be executed on the database server. They encapsulate logic, perform calculations, manipulate data, and return results.

### Function Structure

A basic PostgreSQL function consists of:

- Function name and parameters
- Return type specification
- Function body with logic
- Language declaration

```sql
CREATE OR REPLACE FUNCTION function_name(param1 type, param2 type)
RETURNS return_type
LANGUAGE plpgsql
AS $$
BEGIN
  -- function logic here
  RETURN result;
END;
$$;
```

### Function Languages

**PL/pgSQL (Procedural Language/PostgreSQL)**

PL/pgSQL is the most commonly used procedural language for PostgreSQL functions. It supports variables, control structures, exception handling, and complex logic.

```sql
CREATE OR REPLACE FUNCTION calculate_order_total(order_id uuid)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
  total numeric := 0;
  tax_rate numeric := 0.08;
BEGIN
  SELECT SUM(quantity * price)
  INTO total
  FROM order_items
  WHERE order_items.order_id = calculate_order_total.order_id;
  
  RETURN total * (1 + tax_rate);
END;
$$;
```

**Key features:**

- Variable declarations in DECLARE block
- Control structures (IF, CASE, LOOP, WHILE, FOR)
- Exception handling with BEGIN...EXCEPTION blocks
- Dynamic SQL with EXECUTE
- Record and row type support

**SQL Language**

SQL language functions contain only SQL statements without procedural logic. They are simpler and often more performant for straightforward queries.

```sql
CREATE OR REPLACE FUNCTION get_active_users()
RETURNS TABLE(id uuid, email text, created_at timestamptz)
LANGUAGE sql
AS $$
  SELECT id, email, created_at
  FROM users
  WHERE is_active = true
  ORDER BY created_at DESC;
$$;
```

**Characteristics:**

- No procedural constructs
- Direct SQL query execution
- Better optimization by query planner
- Immutable or stable function volatility classification possible

**Other Languages**

PostgreSQL supports additional languages through extensions:

- PL/Python (requires extension)
- PL/Perl (requires extension)
- PL/V8 (JavaScript, requires extension)

[Unverified] Supabase hosted instances may have limitations on which procedural languages are available beyond PL/pgSQL and SQL.

## Triggers

Triggers automatically execute functions in response to specific database events (INSERT, UPDATE, DELETE, TRUNCATE). They enforce business rules, maintain data integrity, and automate workflows.

### Trigger Creation

```sql
CREATE TRIGGER trigger_name
{BEFORE | AFTER | INSTEAD OF} {INSERT | UPDATE | DELETE}
ON table_name
[FOR EACH {ROW | STATEMENT}]
[WHEN (condition)]
EXECUTE FUNCTION function_name();
```

**Example: Automatic timestamp update**

```sql
CREATE OR REPLACE FUNCTION update_modified_timestamp()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_modified_timestamp();
```

### Trigger Types and Timing

**BEFORE Triggers**

Execute before the triggering operation. They can:

- Modify NEW row values before insertion/update
- Prevent operations by returning NULL
- Validate data before changes occur
- Transform input data

```sql
CREATE OR REPLACE FUNCTION validate_email()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
    RAISE EXCEPTION 'Invalid email format: %', NEW.email;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER check_email_format
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION validate_email();
```

**AFTER Triggers**

Execute after the triggering operation completes. They are used for:

- Logging changes
- Cascading operations to related tables
- Sending notifications
- Maintaining audit trails

```sql
CREATE OR REPLACE FUNCTION log_user_changes()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO audit_log(table_name, operation, old_data, new_data, changed_at)
  VALUES (
    TG_TABLE_NAME,
    TG_OP,
    row_to_json(OLD),
    row_to_json(NEW),
    NOW()
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER audit_user_changes
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_changes();
```

**INSTEAD OF Triggers**

Only available on views. They replace the default operation with custom logic.

```sql
CREATE VIEW user_summary AS
SELECT id, email, profile_data->>'name' as name
FROM users;

CREATE OR REPLACE FUNCTION update_user_summary()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE users
  SET 
    email = NEW.email,
    profile_data = jsonb_set(profile_data, '{name}', to_jsonb(NEW.name))
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER instead_of_update_summary
INSTEAD OF UPDATE ON user_summary
FOR EACH ROW
EXECUTE FUNCTION update_user_summary();
```

### Row-Level vs Statement-Level Triggers

**FOR EACH ROW**

Executes once per affected row. Access to OLD and NEW row variables.

```sql
CREATE TRIGGER row_level_example
AFTER UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION track_price_changes();
```

**Use cases:**

- Individual row validation
- Per-row audit logging
- Row-specific calculations
- Maintaining row-level history

**FOR EACH STATEMENT**

Executes once per SQL statement, regardless of rows affected.

```sql
CREATE TRIGGER statement_level_example
AFTER INSERT ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_sales_summary();
```

**Use cases:**

- Aggregate operations
- Cache invalidation
- Batch notifications
- Performance optimization for bulk operations

**Key differences:**

- Row-level: OLD and NEW available, executes per row
- Statement-level: No row context, executes once per statement
- Row-level has higher overhead for bulk operations
- Statement-level more efficient for operations affecting many rows

### Trigger Special Variables

Within trigger functions, PostgreSQL provides special variables:

- `NEW`: New row data (INSERT/UPDATE)
- `OLD`: Old row data (UPDATE/DELETE)
- `TG_OP`: Operation type ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')
- `TG_TABLE_NAME`: Table name that triggered the function
- `TG_TABLE_SCHEMA`: Schema of the triggering table
- `TG_WHEN`: Timing ('BEFORE', 'AFTER', 'INSTEAD OF')
- `TG_LEVEL`: Level ('ROW', 'STATEMENT')

```sql
CREATE OR REPLACE FUNCTION flexible_audit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log(operation, table_name, old_data)
    VALUES (TG_OP, TG_TABLE_NAME, row_to_json(OLD));
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log(operation, table_name, old_data, new_data)
    VALUES (TG_OP, TG_TABLE_NAME, row_to_json(OLD), row_to_json(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log(operation, table_name, new_data)
    VALUES (TG_OP, TG_TABLE_NAME, row_to_json(NEW));
    RETURN NEW;
  END IF;
END;
$$;
```

## Using Functions with RPC Calls

Supabase allows you to call PostgreSQL functions directly from your client code using RPC (Remote Procedure Call). This exposes server-side logic through your API.

### Creating RPC-Callable Functions

```sql
CREATE OR REPLACE FUNCTION get_user_stats(user_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result json;
BEGIN
  SELECT json_build_object(
    'total_orders', COUNT(DISTINCT o.id),
    'total_spent', COALESCE(SUM(o.total), 0),
    'last_order_date', MAX(o.created_at)
  )
  INTO result
  FROM orders o
  WHERE o.user_id = get_user_stats.user_id;
  
  RETURN result;
END;
$$;
```

### Calling Functions from Supabase Client

```javascript
// JavaScript/TypeScript
const { data, error } = await supabase
  .rpc('get_user_stats', { user_id: '123e4567-e89b-12d3-a456-426614174000' })

// With multiple parameters
const { data, error } = await supabase
  .rpc('search_products', { 
    search_term: 'laptop',
    min_price: 500,
    max_price: 2000
  })
```

### Function Security Modifiers

**SECURITY DEFINER vs SECURITY INVOKER**

```sql
-- SECURITY DEFINER: Runs with function creator's privileges
CREATE OR REPLACE FUNCTION admin_delete_user(user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM users WHERE id = user_id;
END;
$$;

-- SECURITY INVOKER: Runs with caller's privileges (default)
CREATE OR REPLACE FUNCTION get_my_profile()
RETURNS json
LANGUAGE sql
SECURITY INVOKER
AS $$
  SELECT row_to_json(users.*)
  FROM users
  WHERE id = auth.uid();
$$;
```

**SECURITY DEFINER considerations:**

- Use sparingly for administrative operations
- Always set `search_path` to prevent search path manipulation attacks
- Validate all inputs carefully
- Grant execute permissions explicitly

### Return Types for RPC

**Scalar values:**

```sql
CREATE FUNCTION get_total_users() RETURNS bigint
LANGUAGE sql AS $$
  SELECT COUNT(*) FROM users;
$$;
```

**Table returns:**

```sql
CREATE FUNCTION search_users(query text)
RETURNS TABLE(id uuid, email text, name text)
LANGUAGE sql AS $$
  SELECT id, email, profile->>'name' as name
  FROM users
  WHERE email ILIKE '%' || query || '%';
$$;
```

**JSON returns:**

```sql
CREATE FUNCTION get_dashboard_data()
RETURNS json
LANGUAGE sql AS $$
  SELECT json_build_object(
    'users', (SELECT COUNT(*) FROM users),
    'orders', (SELECT COUNT(*) FROM orders),
    'revenue', (SELECT SUM(total) FROM orders)
  );
$$;
```

## Stored Procedures Best Practices

### Naming Conventions

- Use descriptive, verb-based names: `calculate_order_total`, `update_user_profile`
- Prefix by domain or module: `auth_verify_email`, `billing_process_payment`
- Avoid generic names: `process`, `handle`, `do_stuff`

### Parameter Handling

```sql
-- Use named parameters for clarity
CREATE FUNCTION create_order(
  p_user_id uuid,
  p_items jsonb,
  p_shipping_address jsonb
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_order_id uuid;
BEGIN
  -- Use prefixes to distinguish parameter scope
  INSERT INTO orders(user_id, status, shipping_address)
  VALUES (p_user_id, 'pending', p_shipping_address)
  RETURNING id INTO v_order_id;
  
  -- Process items...
  
  RETURN v_order_id;
END;
$$;
```

### Error Handling

```sql
CREATE OR REPLACE FUNCTION transfer_funds(
  from_account uuid,
  to_account uuid,
  amount numeric
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
  from_balance numeric;
BEGIN
  -- Validate input
  IF amount <= 0 THEN
    RAISE EXCEPTION 'Transfer amount must be positive';
  END IF;
  
  -- Check balance
  SELECT balance INTO from_balance
  FROM accounts
  WHERE id = from_account
  FOR UPDATE;
  
  IF from_balance < amount THEN
    RAISE EXCEPTION 'Insufficient funds: % available, % required', from_balance, amount;
  END IF;
  
  -- Perform transfer
  UPDATE accounts SET balance = balance - amount WHERE id = from_account;
  UPDATE accounts SET balance = balance + amount WHERE id = to_account;
  
  RETURN true;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Transfer failed: %', SQLERRM;
    RETURN false;
END;
$$;
```

### Transaction Management

Functions run within transactions automatically. Use savepoints for partial rollbacks:

```sql
CREATE OR REPLACE FUNCTION process_batch_orders(order_ids uuid[])
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE
  order_id uuid;
  success_count int := 0;
  failure_count int := 0;
BEGIN
  FOREACH order_id IN ARRAY order_ids
  LOOP
    BEGIN
      -- Create savepoint for each order
      PERFORM process_single_order(order_id);
      success_count := success_count + 1;
    EXCEPTION
      WHEN OTHERS THEN
        failure_count := failure_count + 1;
        RAISE NOTICE 'Failed to process order %: %', order_id, SQLERRM;
    END;
  END LOOP;
  
  RETURN json_build_object(
    'successful', success_count,
    'failed', failure_count
  );
END;
$$;
```

### Immutability and Volatility

Declare function volatility for query optimization:

```sql
-- IMMUTABLE: Always returns same result for same inputs
CREATE FUNCTION calculate_tax(amount numeric, rate numeric)
RETURNS numeric
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT amount * rate;
$$;

-- STABLE: Same result within single query
CREATE FUNCTION get_current_user_email()
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT email FROM users WHERE id = auth.uid();
$$;

-- VOLATILE: May have side effects (default)
CREATE FUNCTION record_login()
RETURNS void
LANGUAGE plpgsql
VOLATILE
AS $$
BEGIN
  INSERT INTO login_history(user_id, logged_at)
  VALUES (auth.uid(), NOW());
END;
$$;
```

### Documentation

```sql
CREATE OR REPLACE FUNCTION calculate_discount(
  order_total numeric,
  user_tier text
)
RETURNS numeric
LANGUAGE plpgsql
IMMUTABLE
AS $$
/*
  Calculates discount amount based on order total and user tier.
  
  Parameters:
    order_total - Total order amount before discount
    user_tier - User membership tier ('bronze', 'silver', 'gold', 'platinum')
  
  Returns:
    Discount amount (not discounted total)
  
  Example:
    SELECT calculate_discount(100.00, 'gold'); -- Returns 15.00
*/
BEGIN
  RETURN CASE user_tier
    WHEN 'platinum' THEN order_total * 0.20
    WHEN 'gold' THEN order_total * 0.15
    WHEN 'silver' THEN order_total * 0.10
    WHEN 'bronze' THEN order_total * 0.05
    ELSE 0
  END;
END;
$$;

COMMENT ON FUNCTION calculate_discount IS 
  'Applies tiered discount based on user membership level';
```

## Function Performance Optimization

### Use Appropriate Return Types

```sql
-- Inefficient: Returning all data as text
CREATE FUNCTION get_user_inefficient(user_id uuid)
RETURNS text AS $$
  SELECT email::text || ',' || created_at::text FROM users WHERE id = user_id;
$$ LANGUAGE sql;

-- Efficient: Proper return type
CREATE FUNCTION get_user_efficient(user_id uuid)
RETURNS TABLE(email text, created_at timestamptz) AS $$
  SELECT email, created_at FROM users WHERE id = user_id;
$$ LANGUAGE sql;
```

### Minimize Context Switches

```sql
-- Inefficient: Multiple queries in PL/pgSQL
CREATE FUNCTION get_order_summary_slow(order_id uuid)
RETURNS json
LANGUAGE plpgsql AS $$
DECLARE
  user_email text;
  item_count int;
  total numeric;
BEGIN
  SELECT u.email INTO user_email
  FROM orders o JOIN users u ON o.user_id = u.id
  WHERE o.id = order_id;
  
  SELECT COUNT(*) INTO item_count
  FROM order_items WHERE order_items.order_id = get_order_summary_slow.order_id;
  
  SELECT SUM(quantity * price) INTO total
  FROM order_items WHERE order_items.order_id = get_order_summary_slow.order_id;
  
  RETURN json_build_object('email', user_email, 'items', item_count, 'total', total);
END;
$$;

-- Efficient: Single SQL query
CREATE FUNCTION get_order_summary_fast(order_id uuid)
RETURNS json
LANGUAGE sql AS $$
  SELECT json_build_object(
    'email', u.email,
    'items', COUNT(oi.id),
    'total', SUM(oi.quantity * oi.price)
  )
  FROM orders o
  JOIN users u ON o.user_id = u.id
  LEFT JOIN order_items oi ON oi.order_id = o.id
  WHERE o.id = get_order_summary_fast.order_id
  GROUP BY u.email;
$$;
```

### Use SQL Language When Possible

SQL language functions allow better optimization by the query planner compared to PL/pgSQL:

```sql
-- PL/pgSQL version
CREATE FUNCTION get_active_count_plpgsql()
RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE
  result bigint;
BEGIN
  SELECT COUNT(*) INTO result FROM users WHERE is_active = true;
  RETURN result;
END;
$$;

-- Faster SQL version
CREATE FUNCTION get_active_count_sql()
RETURNS bigint
LANGUAGE sql AS $$
  SELECT COUNT(*) FROM users WHERE is_active = true;
$$;
```

### Index Support

Functions can benefit from indexes when used in WHERE clauses:

```sql
-- Create function
CREATE FUNCTION get_user_age(birth_date date)
RETURNS int
LANGUAGE sql
IMMUTABLE AS $$
  SELECT EXTRACT(YEAR FROM AGE(birth_date))::int;
$$;

-- Create index using function
CREATE INDEX idx_user_age ON users(get_user_age(birth_date));

-- Query benefits from index
SELECT * FROM users WHERE get_user_age(birth_date) > 18;
```

### Avoid Dynamic SQL When Static Suffices

```sql
-- Slower: Dynamic SQL
CREATE FUNCTION get_table_count_dynamic(table_name text)
RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE
  result bigint;
BEGIN
  EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO result;
  RETURN result;
END;
$$;

-- Faster: Static SQL (when table is known)
CREATE FUNCTION get_users_count()
RETURNS bigint
LANGUAGE sql AS $$
  SELECT COUNT(*) FROM users;
$$;
```

### Batch Operations

```sql
-- Inefficient: Row-by-row processing
CREATE FUNCTION update_prices_slow()
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  product record;
BEGIN
  FOR product IN SELECT * FROM products LOOP
    UPDATE products 
    SET price = price * 1.1 
    WHERE id = product.id;
  END LOOP;
END;
$$;

-- Efficient: Set-based operation
CREATE FUNCTION update_prices_fast()
RETURNS void
LANGUAGE sql AS $$
  UPDATE products SET price = price * 1.1;
$$;
```

### Function Inlining

[Inference] Simple SQL functions may be inlined by the query planner, improving performance:

```sql
-- Likely to be inlined
CREATE FUNCTION is_premium_user(user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE AS $$
  SELECT tier = 'premium' FROM users WHERE id = user_id;
$$;

-- Used in queries efficiently
SELECT * FROM orders WHERE is_premium_user(user_id) AND created_at > NOW() - INTERVAL '30 days';
```

### Monitoring Function Performance

```sql
-- Enable timing for function analysis
EXPLAIN ANALYZE SELECT my_function(param);

-- Check function execution stats
SELECT 
  schemaname,
  funcname,
  calls,
  total_time,
  self_time,
  total_time / calls as avg_time
FROM pg_stat_user_functions
WHERE funcname = 'your_function_name';
```

## Common Patterns and Use Cases

### Soft Delete Implementation

```sql
CREATE OR REPLACE FUNCTION soft_delete()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE users 
  SET deleted_at = NOW()
  WHERE id = OLD.id;
  RETURN NULL;
END;
$$;

CREATE TRIGGER soft_delete_users
BEFORE DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION soft_delete();
```

### Automatic Slug Generation

```sql
CREATE OR REPLACE FUNCTION generate_slug()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.slug := lower(regexp_replace(NEW.title, '[^a-zA-Z0-9]+', '-', 'g'));
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_post_slug
BEFORE INSERT OR UPDATE OF title ON posts
FOR EACH ROW
WHEN (NEW.slug IS NULL OR NEW.slug = '')
EXECUTE FUNCTION generate_slug();
```

### Hierarchical Data Management

```sql
CREATE OR REPLACE FUNCTION update_category_path()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.parent_id IS NULL THEN
    NEW.path = NEW.id::text;
  ELSE
    SELECT path || '.' || NEW.id::text
    INTO NEW.path
    FROM categories
    WHERE id = NEW.parent_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER maintain_category_path
BEFORE INSERT OR UPDATE ON categories
FOR EACH ROW
EXECUTE FUNCTION update_category_path();
```

### Data Validation Trigger

```sql
CREATE OR REPLACE FUNCTION validate_product_data()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.price < 0 THEN
    RAISE EXCEPTION 'Price cannot be negative';
  END IF;
  
  IF NEW.stock_quantity < 0 THEN
    RAISE EXCEPTION 'Stock quantity cannot be negative';
  END IF;
  
  IF NEW.discount_percentage < 0 OR NEW.discount_percentage > 100 THEN
    RAISE EXCEPTION 'Discount must be between 0 and 100';
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER validate_product
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION validate_product_data();
```

### Maintaining Computed Columns

```sql
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE orders
  SET 
    subtotal = (SELECT SUM(quantity * unit_price) FROM order_items WHERE order_id = NEW.order_id),
    tax = subtotal * 0.08,
    total = subtotal + tax
  WHERE id = NEW.order_id;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER recalculate_order_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total();
```

**Important subtopics for deeper understanding:**

- **Row Level Security (RLS) integration with functions** - How functions interact with Supabase's RLS policies
- **Realtime subscriptions with triggers** - Using triggers to broadcast changes through Supabase Realtime
- **Edge Functions vs Database Functions** - When to use each approach
- **Migration strategies** - Managing function and trigger changes across environments
- **Debugging techniques** - Tools and approaches for troubleshooting function issues

---

# API & PostgREST

Supabase automatically generates a RESTful API for your PostgreSQL database using PostgREST. Every table, view, and function in your database becomes instantly accessible through HTTP endpoints without writing backend code.

## Auto-generated REST API

When you create a table in Supabase, PostgREST automatically generates a complete REST API with full CRUD operations. The API reflects your database schema in real-time—adding columns, tables, or modifying structures immediately updates the API without deployment or configuration. The API follows REST conventions with standard HTTP methods (GET, POST, PATCH, DELETE) mapped to database operations.

The auto-generation includes:

- Table and view endpoints for data access
- Stored function endpoints for custom logic
- Automatic OpenAPI/Swagger documentation
- Type-safe responses matching your schema
- Built-in authentication and authorization via Row Level Security (RLS)

## API Endpoint Structure

Supabase API endpoints follow a consistent pattern:

```
https://[project-ref].supabase.co/rest/v1/[table-name]
```

The project reference ID is unique to your Supabase project and found in your project settings. Each table becomes a resource endpoint at `/rest/v1/[table-name]`.

**Endpoint patterns:**

- **Collection endpoint**: `/rest/v1/users` - operates on multiple records
- **Single resource**: `/rest/v1/users?id=eq.123` - filters to specific record(s)
- **Foreign key relationships**: `/rest/v1/posts?select=*,author:users(*)` - embedded resources
- **Function endpoints**: `/rest/v1/rpc/function_name` - stored procedure calls

All requests require authentication headers:

```
apikey: your-anon-key
Authorization: Bearer your-anon-key-or-user-jwt
```

For authenticated requests, replace the anon key with the user's JWT token obtained after login.

## Query Parameters

PostgREST provides powerful query parameters for filtering, ordering, pagination, and data shaping.

**Filtering operators:**

- `eq` - equals: `?name=eq.John`
- `neq` - not equals: `?status=neq.deleted`
- `gt`, `gte`, `lt`, `lte` - comparison: `?age=gte.18`
- `like`, `ilike` - pattern matching: `?email=ilike.*@gmail.com`
- `in` - multiple values: `?status=in.(active,pending)`
- `is` - null checks: `?deleted_at=is.null`
- `fts` - full-text search: `?content=fts.search term`
- `cs`, `cd` - contains/contained by (arrays/JSON): `?tags=cs.{postgres,api}`
- `ov` - overlaps (arrays): `?categories=ov.{tech,news}`
- `not` - negation: `?status=not.eq.banned`

**Ordering:**

- `?order=created_at.desc` - descending order
- `?order=name.asc.nullsfirst` - ascending with null handling
- `?order=priority.desc,created_at.asc` - multiple columns

**Pagination:**

- Range-based: Headers `Range: 0-9` returns first 10 records with `Content-Range` response
- Offset/limit: `?limit=10&offset=20`
- Cursor-based: `?id=gt.100&limit=10&order=id.asc`

**Column selection:**

- Specific columns: `?select=id,name,email`
- Renaming: `?select=user_id:id,full_name:name`
- Aggregations: `?select=count,avg(price),sum(quantity)`

**Logical operators:**

- AND (default): `?status=eq.active&verified=eq.true`
- OR: `?or=(status.eq.active,status.eq.pending)`
- NOT: `?not.and=(status.eq.banned,role.eq.admin)`
- Complex: `?and=(status.eq.active,or(role.eq.admin,verified.eq.true))`

## Response Formats

PostgREST returns JSON by default with configurable representations.

**Standard JSON response:**

```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-01-15T10:30:00Z"
  }
]
```

**Response headers:**

- `Content-Type: application/json` - response format
- `Content-Range: 0-9/100` - pagination info (start-end/total)
- `Content-Profile: public` - database schema used
- `Preference-Applied: return=representation` - confirms preference handling

**Single object return:** Add `Accept: application/vnd.pgrst.object+json` header to return a single object instead of array. [Inference: This throws an error if query returns zero or multiple rows, based on PostgREST's typical behavior]

**CSV format:** Set `Accept: text/csv` header to receive comma-separated values.

**Response preferences:** Set `Prefer` header to control response behavior:

- `return=representation` - return the modified data
- `return=minimal` - return only status code (faster)
- `return=headers-only` - return only headers
- `resolution=merge-duplicates` - handle upsert conflicts
- `resolution=ignore-duplicates` - skip duplicate inserts
- `count=exact` - include exact total count (slower)
- `count=planned` - use query planner estimate (faster)
- `count=estimated` - use statistics estimate

## Computed Columns

Computed columns are database views or generated columns that appear as regular columns in API responses but derive their values from calculations or transformations.

**Database views as computed fields:**

```sql
CREATE VIEW user_profiles AS
SELECT 
  users.id,
  users.name,
  users.email,
  COUNT(posts.id) as post_count,
  MAX(posts.created_at) as last_post_date
FROM users
LEFT JOIN posts ON posts.user_id = users.id
GROUP BY users.id;
```

The view becomes queryable: `GET /rest/v1/user_profiles`

**Generated columns:**

```sql
ALTER TABLE products
ADD COLUMN total_price NUMERIC GENERATED ALWAYS AS (price * quantity) STORED;
```

The `total_price` automatically appears in API responses and updates when dependencies change.

**Functions as computed columns:**

```sql
CREATE FUNCTION full_name(users)
RETURNS text AS $$
  SELECT $1.first_name || ' ' || $1.last_name;
$$ LANGUAGE SQL STABLE;
```

Access via: `?select=*,full_name`

**Use cases:**

- Aggregating related data (counts, sums, averages)
- Concatenating fields (full names, addresses)
- Formatting dates or numbers
- Security-filtered views (showing only permitted data)
- Complex calculations without client-side processing

## Resource Embedding

Resource embedding allows fetching related data in a single request through foreign key relationships, eliminating N+1 query problems.

**Basic embedding syntax:**

```
GET /rest/v1/posts?select=*,author:users(*)
```

Returns posts with nested author objects:

```json
[
  {
    "id": 1,
    "title": "Post Title",
    "author": {
      "id": 5,
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  }
]
```

**Selecting embedded columns:**

```
?select=id,title,author:users(id,name)
```

Returns only specified columns from the related resource.

**Multiple relationships:**

```
?select=*,author:users(*),comments(*),category:categories(*)
```

**Deep nesting:**

```
?select=*,comments(*,author:users(*))
```

Embeds comments with each comment's author nested within.

**Many-to-many relationships:** For junction tables (e.g., `posts_tags` linking `posts` and `tags`):

```
?select=*,tags:posts_tags(tag:tags(*))
```

**Filtering embedded resources:**

```
?select=*,comments(*)&comments.status=eq.approved
```

Shows only approved comments within posts.

**Embedding parent resources (reverse direction):**

```
GET /rest/v1/users?select=*,posts(*)
```

Returns users with all their posts embedded.

**Limitations:**

- [Inference: Deep nesting can impact performance; typically limited to 2-3 levels is recommended based on common database query optimization practices]
- Requires proper foreign key constraints in database schema
- RLS policies apply to embedded resources independently

## API Rate Limits

Supabase applies rate limiting to protect infrastructure and ensure fair usage across projects.

**Default rate limits [Unverified - these values may vary by plan and change over time]:**

- Free tier: ~500 requests per minute per IP address
- Pro tier: Higher limits with burst capacity
- Enterprise: Custom limits negotiated

**Rate limit headers:** Responses include rate limit information:

```
X-RateLimit-Limit: 500
X-RateLimit-Remaining: 487
X-RateLimit-Reset: 1640000000
```

**What counts toward limits:**

- REST API requests via PostgREST
- Realtime subscriptions connections (separate limit)
- Authentication operations
- Storage API operations
- Edge Function invocations

**What doesn't count:**

- Database queries from backend services using direct connection
- Queries within database functions/triggers

**Handling rate limits:**

When exceeded, the API returns HTTP 429 status:

```json
{
  "message": "API rate limit exceeded",
  "code": "429"
}
```

**Mitigation strategies:**

- Implement exponential backoff retry logic
- Cache frequently accessed data client-side
- Use webhooks/realtime instead of polling
- Batch operations where possible
- Upgrade to higher tier for increased limits
- Use connection pooling for server-side requests
- Filter and select only needed columns to reduce payload

**Monitoring:** Track rate limit headers in your application to implement preemptive throttling before hitting limits.

## Custom API Routes via Functions

PostgreSQL functions become RPC endpoints in Supabase, enabling custom API routes with complex business logic.

**Creating a custom endpoint:**

```sql
CREATE OR REPLACE FUNCTION calculate_order_total(order_id INT)
RETURNS NUMERIC AS $$
  SELECT SUM(quantity * price) 
  FROM order_items 
  WHERE order_items.order_id = $1;
$$ LANGUAGE SQL STABLE;
```

**Calling the function:**

```
POST /rest/v1/rpc/calculate_order_total
Content-Type: application/json

{
  "order_id": 123
}
```

**Function with multiple parameters:**

```sql
CREATE FUNCTION search_products(
  search_term TEXT,
  min_price NUMERIC DEFAULT 0,
  max_price NUMERIC DEFAULT 999999
)
RETURNS SETOF products AS $$
  SELECT * FROM products
  WHERE name ILIKE '%' || search_term || '%'
  AND price BETWEEN min_price AND max_price;
$$ LANGUAGE SQL STABLE;
```

Call with: `POST /rest/v1/rpc/search_products` with JSON body containing parameters.

**Function types:**

- **VOLATILE**: Default, can modify database state
- **STABLE**: Doesn't modify database, results consistent within single query
- **IMMUTABLE**: Deterministic, same input always produces same output

Use STABLE or IMMUTABLE when possible for better performance and caching.

**Return types:**

- Scalar values: `RETURNS TEXT`, `RETURNS INT`
- Single row: `RETURNS TABLE(col1 type, col2 type)`
- Multiple rows: `RETURNS SETOF table_name`
- JSON: `RETURNS JSON` or `RETURNS JSONB`
- Void: `RETURNS VOID` for operations without return value

**Security:** Functions inherit the privileges of the user calling them unless defined with `SECURITY DEFINER`, which executes with the privileges of the function creator.

```sql
CREATE FUNCTION admin_only_operation()
RETURNS VOID
SECURITY DEFINER
SET search_path = public
AS $$
  -- Runs with elevated privileges
  DELETE FROM sensitive_data WHERE expired = true;
$$ LANGUAGE SQL;
```

[Inference: `SECURITY DEFINER` should be used cautiously as it can bypass RLS policies]

**Use cases:**

- Complex calculations not expressible in single queries
- Multi-step transactions requiring atomicity
- Custom authentication or authorization logic
- Data aggregation and reporting
- Integration with external services (via extensions)
- Batch operations with custom validation

## OpenAPI Documentation

Supabase automatically generates OpenAPI (Swagger) documentation for your entire API based on your database schema.

**Accessing documentation:**

```
https://[project-ref].supabase.co/rest/v1/?apikey=[your-anon-key]
```

The endpoint returns OpenAPI 3.0 specification as JSON describing all available endpoints, schemas, and operations.

**What's included:**

- All table and view endpoints with CRUD operations
- All RPC function endpoints with parameter schemas
- Request/response schemas derived from PostgreSQL types
- Foreign key relationships as embedded resources
- Column constraints and data types
- Table and column descriptions from PostgreSQL comments

**Adding descriptions:**

Add PostgreSQL comments to enhance documentation:

```sql
COMMENT ON TABLE users IS 'Application users with authentication credentials';
COMMENT ON COLUMN users.email IS 'User email address, must be unique';
```

These comments appear in the OpenAPI documentation.

**Visualizing documentation:**

Import the OpenAPI JSON into tools like:

- Swagger UI for interactive API exploration
- Postman for API testing and collection management
- Redoc for clean, readable documentation
- API development tools supporting OpenAPI 3.0

**Schema generation:**

PostgreSQL types map to OpenAPI schemas:

- `TEXT`, `VARCHAR` → `string`
- `INTEGER`, `BIGINT` → `integer`
- `NUMERIC`, `REAL` → `number`
- `BOOLEAN` → `boolean`
- `TIMESTAMP`, `DATE` → `string` with `format: date-time`
- `JSON`, `JSONB` → `object`
- `ARRAY` types → `array` with appropriate items type

**Security schemas:**

The OpenAPI spec includes security definitions:

- `apikey` in header for anonymous access
- `bearer` authentication for user JWT tokens

**Benefits:**

- Auto-generated client SDKs using OpenAPI generators
- Automatic API testing and validation
- Contract-first development workflows
- Integration with API gateways and management tools
- Up-to-date documentation without manual maintenance

---

**Key related topics you may want to explore:**

- **Row Level Security (RLS)** - securing API endpoints with database policies
- **Supabase Client Libraries** - using generated JavaScript/TypeScript/Python clients instead of raw REST
- **Database Triggers & Webhooks** - reacting to data changes via API
- **Edge Functions** - custom serverless API routes beyond database functions
- **Realtime Subscriptions** - listening to database changes via WebSocket

---

# Advanced Queries in Supabase

Supabase provides access to PostgreSQL's full querying capabilities, enabling sophisticated data retrieval and manipulation patterns that go beyond basic CRUD operations.

## Complex Joins

Joins combine data from multiple tables based on related columns. Supabase supports all PostgreSQL join types through both the JavaScript client and direct SQL.

### Inner Joins

```javascript
const { data, error } = await supabase
  .from('orders')
  .select(`
    id,
    total,
    customers (
      name,
      email
    )
  `)
```

### Multiple Table Joins

```javascript
const { data, error } = await supabase
  .from('order_items')
  .select(`
    quantity,
    orders (
      id,
      order_date,
      customers (
        name
      )
    ),
    products (
      name,
      price
    )
  `)
```

### Left/Right Joins via RPC

```sql
CREATE OR REPLACE FUNCTION get_all_customers_with_orders()
RETURNS TABLE (
  customer_id bigint,
  customer_name text,
  order_count bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    COUNT(o.id) as order_count
  FROM customers c
  LEFT JOIN orders o ON c.id = o.customer_id
  GROUP BY c.id, c.name;
END;
$$ LANGUAGE plpgsql;
```

```javascript
const { data, error } = await supabase.rpc('get_all_customers_with_orders')
```

## Subqueries

Subqueries are nested SELECT statements used within another query. They're useful for filtering, calculations, or complex conditions.

### Scalar Subqueries

```sql
CREATE OR REPLACE FUNCTION get_above_average_products()
RETURNS TABLE (
  id bigint,
  name text,
  price numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.name, p.price
  FROM products p
  WHERE p.price > (SELECT AVG(price) FROM products);
END;
$$ LANGUAGE plpgsql;
```

### Correlated Subqueries

```sql
CREATE OR REPLACE FUNCTION get_customer_latest_orders()
RETURNS TABLE (
  customer_id bigint,
  order_id bigint,
  order_date timestamp
) AS $$
BEGIN
  RETURN QUERY
  SELECT o1.customer_id, o1.id, o1.order_date
  FROM orders o1
  WHERE o1.order_date = (
    SELECT MAX(o2.order_date)
    FROM orders o2
    WHERE o2.customer_id = o1.customer_id
  );
END;
$$ LANGUAGE plpgsql;
```

### EXISTS/NOT EXISTS

```sql
SELECT * FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o 
  WHERE o.customer_id = c.id 
  AND o.total > 1000
);
```

## Common Table Expressions (CTEs)

CTEs create temporary named result sets that exist only during query execution. They improve readability and enable recursive operations.

### Basic CTE

```sql
CREATE OR REPLACE FUNCTION analyze_sales()
RETURNS TABLE (
  category text,
  total_revenue numeric,
  avg_order_value numeric
) AS $$
BEGIN
  RETURN QUERY
  WITH order_totals AS (
    SELECT 
      p.category,
      o.id as order_id,
      SUM(oi.quantity * oi.price) as order_total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.id
    JOIN orders o ON oi.order_id = o.id
    GROUP BY p.category, o.id
  )
  SELECT 
    category,
    SUM(order_total) as total_revenue,
    AVG(order_total) as avg_order_value
  FROM order_totals
  GROUP BY category;
END;
$$ LANGUAGE plpgsql;
```

### Multiple CTEs

```sql
WITH 
  customer_stats AS (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
  ),
  revenue_stats AS (
    SELECT customer_id, SUM(total) as total_spent
    FROM orders
    GROUP BY customer_id
  )
SELECT 
  c.name,
  cs.order_count,
  rs.total_spent
FROM customers c
JOIN customer_stats cs ON c.id = cs.customer_id
JOIN revenue_stats rs ON c.id = rs.customer_id;
```

## Window Functions

Window functions perform calculations across sets of rows related to the current row without collapsing the result set like GROUP BY does.

### ROW_NUMBER, RANK, DENSE_RANK

```sql
CREATE OR REPLACE FUNCTION rank_products_by_sales()
RETURNS TABLE (
  product_id bigint,
  product_name text,
  total_quantity bigint,
  sales_rank bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    SUM(oi.quantity) as total_quantity,
    ROW_NUMBER() OVER (ORDER BY SUM(oi.quantity) DESC) as sales_rank
  FROM products p
  JOIN order_items oi ON p.id = oi.product_id
  GROUP BY p.id, p.name;
END;
$$ LANGUAGE plpgsql;
```

### PARTITION BY

```sql
SELECT 
  customer_id,
  order_date,
  total,
  AVG(total) OVER (PARTITION BY customer_id) as customer_avg,
  total - AVG(total) OVER (PARTITION BY customer_id) as diff_from_avg
FROM orders;
```

### LAG and LEAD

```sql
SELECT 
  product_id,
  sale_date,
  quantity,
  LAG(quantity, 1) OVER (PARTITION BY product_id ORDER BY sale_date) as prev_quantity,
  LEAD(quantity, 1) OVER (PARTITION BY product_id ORDER BY sale_date) as next_quantity
FROM sales;
```

### Running Totals

```sql
SELECT 
  order_date,
  total,
  SUM(total) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total
FROM orders;
```

## Recursive Queries

Recursive CTEs allow querying hierarchical or graph-structured data by repeatedly executing a query until a condition is met.

### Organization Hierarchy

```sql
CREATE OR REPLACE FUNCTION get_employee_hierarchy(root_employee_id bigint)
RETURNS TABLE (
  id bigint,
  name text,
  manager_id bigint,
  level int
) AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE employee_tree AS (
    -- Base case
    SELECT e.id, e.name, e.manager_id, 1 as level
    FROM employees e
    WHERE e.id = root_employee_id
    
    UNION ALL
    
    -- Recursive case
    SELECT e.id, e.name, e.manager_id, et.level + 1
    FROM employees e
    JOIN employee_tree et ON e.manager_id = et.id
  )
  SELECT * FROM employee_tree;
END;
$$ LANGUAGE plpgsql;
```

### Category Tree

```sql
WITH RECURSIVE category_path AS (
  SELECT 
    id, 
    name, 
    parent_id,
    name::text as path,
    1 as depth
  FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
  SELECT 
    c.id,
    c.name,
    c.parent_id,
    cp.path || ' > ' || c.name,
    cp.depth + 1
  FROM categories c
  JOIN category_path cp ON c.parent_id = cp.id
)
SELECT * FROM category_path;
```

### Graph Traversal

```sql
WITH RECURSIVE connections AS (
  SELECT user_id, friend_id, 1 as degree
  FROM friendships
  WHERE user_id = 123
  
  UNION
  
  SELECT f.user_id, f.friend_id, c.degree + 1
  FROM friendships f
  JOIN connections c ON f.user_id = c.friend_id
  WHERE c.degree < 3
)
SELECT DISTINCT friend_id, MIN(degree) as closest_degree
FROM connections
GROUP BY friend_id;
```

## JSON/JSONB Operations

PostgreSQL's JSONB type enables efficient storage and querying of JSON data with indexing support.

### Querying JSON Fields

```javascript
// Select specific JSON field
const { data, error } = await supabase
  .from('users')
  .select('id, metadata->phone')
  .eq('metadata->country', 'US')

// Deep nested access
const { data, error } = await supabase
  .from('products')
  .select('name')
  .eq('specs->dimensions->weight', '500g')
```

### JSON Operators in SQL

```sql
-- Extract field as text
SELECT metadata->>'name' as name FROM users;

-- Extract nested path
SELECT metadata#>>'{address,city}' as city FROM users;

-- Check key existence
SELECT * FROM users WHERE metadata ? 'premium';

-- Check multiple keys
SELECT * FROM users WHERE metadata ?& ARRAY['email', 'phone'];

-- Check any key exists
SELECT * FROM users WHERE metadata ?| ARRAY['email', 'phone'];
```

### JSON Aggregation

```sql
-- Build JSON object
SELECT json_build_object(
  'id', id,
  'name', name,
  'orders', (
    SELECT json_agg(json_build_object('id', id, 'total', total))
    FROM orders
    WHERE customer_id = customers.id
  )
) as customer_data
FROM customers;

-- JSONB aggregation
SELECT 
  category,
  jsonb_agg(jsonb_build_object(
    'name', name,
    'price', price
  )) as products
FROM products
GROUP BY category;
```

### Updating JSONB

```sql
-- Add/update field
UPDATE users 
SET metadata = jsonb_set(metadata, '{last_login}', '"2025-10-04"');

-- Remove field
UPDATE users 
SET metadata = metadata - 'temporary_token';

-- Concatenate
UPDATE users 
SET metadata = metadata || '{"verified": true}'::jsonb;
```

### JSONB Indexing

```sql
-- GIN index for containment operations
CREATE INDEX idx_metadata_gin ON users USING GIN (metadata);

-- Index specific path
CREATE INDEX idx_metadata_country ON users ((metadata->>'country'));
```

## Array Operations

PostgreSQL arrays store multiple values in a single column with powerful querying capabilities.

### Array Creation and Querying

```javascript
// Insert array
const { data, error } = await supabase
  .from('posts')
  .insert({ 
    title: 'My Post', 
    tags: ['javascript', 'supabase', 'postgres'] 
  })

// Query with array contains
const { data, error } = await supabase
  .from('posts')
  .select()
  .contains('tags', ['javascript'])

// Overlap check
const { data, error } = await supabase
  .from('posts')
  .select()
  .overlaps('tags', ['javascript', 'python'])
```

### Array Functions in SQL

```sql
-- Array length
SELECT array_length(tags, 1) FROM posts;

-- Array append
UPDATE posts SET tags = array_append(tags, 'new-tag');

-- Array remove
UPDATE posts SET tags = array_remove(tags, 'old-tag');

-- Array concatenation
UPDATE posts SET tags = tags || ARRAY['tag1', 'tag2'];

-- Unnest (expand to rows)
SELECT unnest(tags) as tag FROM posts WHERE id = 1;

-- Array aggregation
SELECT array_agg(name) as all_names FROM users;
```

### Array Operators

```sql
-- Contains
SELECT * FROM posts WHERE tags @> ARRAY['postgres'];

-- Contained by
SELECT * FROM posts WHERE ARRAY['postgres'] <@ tags;

-- Overlap
SELECT * FROM posts WHERE tags && ARRAY['javascript', 'python'];

-- Array element access
SELECT tags[1] as first_tag FROM posts;

-- Array slicing
SELECT tags[1:3] FROM posts;
```

### Array Indexing

```sql
-- GIN index for array containment
CREATE INDEX idx_tags_gin ON posts USING GIN (tags);
```

## Full-Text Search with tsvector

PostgreSQL's full-text search converts text to lexemes (normalized words) and enables ranked search results.

### Basic Setup

```sql
-- Add tsvector column
ALTER TABLE articles ADD COLUMN search_vector tsvector;

-- Generate tsvector
UPDATE articles 
SET search_vector = to_tsvector('english', title || ' ' || body);

-- Create trigger for automatic updates
CREATE TRIGGER articles_search_update
BEFORE INSERT OR UPDATE ON articles
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', title, body);

-- Create GIN index
CREATE INDEX idx_articles_search ON articles USING GIN (search_vector);
```

### Querying

```sql
-- Basic search
CREATE OR REPLACE FUNCTION search_articles(search_query text)
RETURNS TABLE (
  id bigint,
  title text,
  rank real
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.title,
    ts_rank(a.search_vector, to_tsquery('english', search_query)) as rank
  FROM articles a
  WHERE a.search_vector @@ to_tsquery('english', search_query)
  ORDER BY rank DESC;
END;
$$ LANGUAGE plpgsql;
```

```javascript
const { data, error } = await supabase
  .rpc('search_articles', { search_query: 'postgres & supabase' })
```

### Advanced Query Operators

```sql
-- AND operation
to_tsquery('postgres & supabase')

-- OR operation
to_tsquery('postgres | mysql')

-- NOT operation
to_tsquery('postgres & !mysql')

-- Phrase search
to_tsquery('postgres <-> supabase')

-- Proximity search (within 3 words)
to_tsquery('postgres <3> supabase')

-- Prefix search
to_tsquery('post:*')
```

### Highlighting Results

```sql
SELECT 
  id,
  title,
  ts_headline('english', body, to_tsquery('english', 'postgres'), 
    'StartSel=<mark>, StopSel=</mark>') as highlighted_body
FROM articles
WHERE search_vector @@ to_tsquery('english', 'postgres');
```

### Weighted Search

```sql
-- Assign weights (A = highest, D = lowest)
UPDATE articles 
SET search_vector = 
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(body, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(tags::text, '')), 'C');

-- Rank with weights
SELECT ts_rank('{0.1, 0.2, 0.4, 1.0}', search_vector, query) as rank
FROM articles, to_tsquery('postgres') query
WHERE search_vector @@ query;
```

## Fuzzy Matching

Fuzzy matching finds approximate string matches using similarity algorithms, useful for typo tolerance and flexible searching.

### pg_trgm Extension

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Similarity search
SELECT name, similarity(name, 'PostgreSQL') as sim
FROM products
WHERE similarity(name, 'PostgreSQL') > 0.3
ORDER BY sim DESC;

-- Trigram index
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);
```

### Similarity Operators

```sql
-- Similar to (using threshold)
SELECT * FROM users WHERE email % 'john@example.com';

-- Word similarity
SELECT word_similarity('base', 'database') as sim;

-- Strict word similarity
SELECT strict_word_similarity('base', 'database') as sim;

-- Distance (inverse of similarity)
SELECT name <-> 'PostgreSQL' as distance
FROM products
ORDER BY distance
LIMIT 10;
```

### Fuzzy Search Function

```sql
CREATE OR REPLACE FUNCTION fuzzy_search_products(search_term text, threshold real DEFAULT 0.3)
RETURNS TABLE (
  id bigint,
  name text,
  similarity_score real
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    similarity(p.name, search_term) as similarity_score
  FROM products p
  WHERE similarity(p.name, search_term) > threshold
  ORDER BY similarity_score DESC;
END;
$$ LANGUAGE plpgsql;
```

```javascript
const { data, error } = await supabase
  .rpc('fuzzy_search_products', { 
    search_term: 'PostgreSQL', 
    threshold: 0.3 
  })
```

### Levenshtein Distance

```sql
-- Enable fuzzystrmatch extension
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- Calculate edit distance
SELECT levenshtein('PostgreSQL', 'Postgres');

-- Levenshtein with costs
SELECT levenshtein('PostgreSQL', 'Postgres', 1, 1, 2); -- ins, del, sub costs

-- Soundex matching
SELECT soundex('Smith') = soundex('Smyth');
```

## Geospatial Queries (PostGIS)

PostGIS extends PostgreSQL with geospatial capabilities for storing and querying geographic data.

### Setup

```sql
-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add geometry column
ALTER TABLE locations 
ADD COLUMN geom geometry(Point, 4326);

-- Create spatial index
CREATE INDEX idx_locations_geom ON locations USING GIST (geom);
```

### Storing Geographic Data

```javascript
// Insert location
const { data, error } = await supabase
  .rpc('insert_location', {
    name: 'Coffee Shop',
    latitude: 40.7128,
    longitude: -74.0060
  })
```

```sql
CREATE OR REPLACE FUNCTION insert_location(
  name text,
  latitude double precision,
  longitude double precision
)
RETURNS bigint AS $$
DECLARE
  new_id bigint;
BEGIN
  INSERT INTO locations (name, geom)
  VALUES (name, ST_SetSRID(ST_MakePoint(longitude, latitude), 4326))
  RETURNING id INTO new_id;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;
```

### Distance Queries

```sql
CREATE OR REPLACE FUNCTION find_nearby_locations(
  lat double precision,
  lon double precision,
  radius_meters double precision
)
RETURNS TABLE (
  id bigint,
  name text,
  distance_meters double precision
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.name,
    ST_Distance(
      l.geom::geography,
      ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography
    ) as distance_meters
  FROM locations l
  WHERE ST_DWithin(
    l.geom::geography,
    ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography,
    radius_meters
  )
  ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;
```

```javascript
const { data, error } = await supabase
  .rpc('find_nearby_locations', {
    lat: 40.7128,
    lon: -74.0060,
    radius_meters: 5000
  })
```

### Spatial Relationships

```sql
-- Point in polygon
SELECT * FROM locations
WHERE ST_Within(
  geom,
  ST_GeomFromText('POLYGON((...))', 4326)
);

-- Intersects
SELECT * FROM zones z1, zones z2
WHERE ST_Intersects(z1.geom, z2.geom);

-- Contains
SELECT * FROM regions
WHERE ST_Contains(
  geom,
  ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326)
);

-- Nearest neighbor
SELECT name, ST_Distance(geom, ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326)) as dist
FROM locations
ORDER BY geom <-> ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326)
LIMIT 5;
```

### Working with Polygons

```sql
-- Create polygon
INSERT INTO zones (name, geom)
VALUES (
  'Downtown',
  ST_GeomFromText('POLYGON((
    -74.0060 40.7128,
    -74.0050 40.7128,
    -74.0050 40.7138,
    -74.0060 40.7138,
    -74.0060 40.7128
  ))', 4326)
);

-- Calculate area (in square meters)
SELECT name, ST_Area(geom::geography) as area_sqm
FROM zones;

-- Buffer (create area around point)
SELECT ST_Buffer(geom::geography, 1000)::geometry as buffered_geom
FROM locations;
```

### GeoJSON Export

```sql
SELECT 
  name,
  ST_AsGeoJSON(geom)::json as geojson
FROM locations;
```

### Advanced Spatial Operations

```sql
-- Centroid
SELECT ST_Centroid(geom) FROM zones;

-- Convex hull
SELECT ST_ConvexHull(ST_Collect(geom)) FROM locations;

-- Union of geometries
SELECT ST_Union(geom) FROM zones WHERE category = 'residential';

-- Intersection
SELECT ST_Intersection(z1.geom, z2.geom)
FROM zones z1, zones z2
WHERE z1.id != z2.id;

-- Line of sight
SELECT ST_MakeLine(
  (SELECT geom FROM locations WHERE id = 1),
  (SELECT geom FROM locations WHERE id = 2)
);
```

**Key Points:**

- Complex joins enable data combination from multiple tables using Supabase's nested select syntax or PostgreSQL functions
- Subqueries provide filtering and calculations within larger queries, supporting scalar and correlated patterns
- CTEs improve query readability and enable recursive operations for hierarchical data
- Window functions calculate across row sets without collapsing results, useful for rankings and running calculations
- Recursive queries traverse hierarchical structures like organization charts, category trees, and graphs
- JSONB operations allow flexible schema design with efficient indexing and querying of JSON data
- Array operations enable multi-value storage with containment, overlap, and aggregation capabilities
- Full-text search with tsvector provides ranked search results with stemming, phrase matching, and highlighting
- Fuzzy matching using pg_trgm enables typo-tolerant searches with similarity scoring
- PostGIS extends PostgreSQL with comprehensive geospatial capabilities for location-based queries

**Important subtopics to explore:**

- Query performance optimization (EXPLAIN, indexes, query planning)
- Database functions and stored procedures (PL/pgSQL, security definers)
- Materialized views for complex query caching
- Database triggers for automated data workflows
- Real-time subscriptions with PostgreSQL's LISTEN/NOTIFY
- Row Level Security (RLS) integration with advanced queries

---

# Performance Optimization in Supabase

Performance optimization is essential for building scalable applications with Supabase. PostgreSQL provides robust tools for analyzing and improving database performance, from query optimization to infrastructure-level improvements. Understanding these concepts helps you build applications that remain responsive as data grows.

## Query Performance Analysis

Query performance analysis involves identifying slow queries, understanding their execution characteristics, and determining optimization opportunities.

### Identifying Slow Queries

PostgreSQL tracks query statistics through the `pg_stat_statements` extension. In Supabase, you can enable and query this extension to find performance bottlenecks.

```sql
-- Enable pg_stat_statements (may require admin privileges)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Find slowest queries by total time
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  max_exec_time,
  stddev_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Find queries with highest average execution time
SELECT 
  query,
  calls,
  mean_exec_time,
  total_exec_time
FROM pg_stat_statements
WHERE calls > 100
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Find queries called most frequently
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 20;
```

### Monitoring Query Patterns

```sql
-- Analyze queries by pattern
SELECT 
  LEFT(query, 50) as query_start,
  COUNT(*) as similar_queries,
  SUM(calls) as total_calls,
  AVG(mean_exec_time) as avg_execution_time
FROM pg_stat_statements
GROUP BY LEFT(query, 50)
ORDER BY avg_execution_time DESC;

-- Check cache hit ratio
SELECT 
  SUM(blks_hit) as cache_hits,
  SUM(blks_read) as disk_reads,
  SUM(blks_hit) / NULLIF(SUM(blks_hit) + SUM(blks_read), 0) * 100 as cache_hit_ratio
FROM pg_stat_database
WHERE datname = current_database();
```

### Query Timing

```sql
-- Enable timing for individual queries
\timing on

-- Measure specific query execution
SELECT COUNT(*) FROM users WHERE created_at > NOW() - INTERVAL '30 days';

-- Use pg_stat_statements for aggregate timing
SELECT 
  calls,
  total_exec_time / 1000.0 as total_seconds,
  mean_exec_time as avg_milliseconds,
  query
FROM pg_stat_statements
WHERE query ILIKE '%users%'
ORDER BY total_exec_time DESC;
```

## EXPLAIN and Query Plans

EXPLAIN shows how PostgreSQL executes queries, revealing the query planner's strategy and helping identify optimization opportunities.

### Basic EXPLAIN

```sql
-- Show query plan
EXPLAIN 
SELECT u.email, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2024-01-01'
GROUP BY u.email;
```

**Example output interpretation:**

```
HashAggregate  (cost=1234.56..1456.78 rows=1000 width=40)
  Group Key: u.email
  ->  Hash Left Join  (cost=123.45..234.56 rows=5000 width=32)
        Hash Cond: (u.id = o.user_id)
        ->  Seq Scan on users u  (cost=0.00..100.00 rows=1000 width=24)
              Filter: (created_at > '2024-01-01'::date)
        ->  Hash  (cost=100.00..100.00 rows=10000 width=16)
              ->  Seq Scan on orders o  (cost=0.00..100.00 rows=10000 width=16)
```

### EXPLAIN ANALYZE

EXPLAIN ANALYZE executes the query and provides actual runtime statistics:

```sql
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE category_id = 5 
AND price > 100
ORDER BY created_at DESC
LIMIT 10;
```

**Key metrics:**

- **Planning Time**: Time spent planning the query
- **Execution Time**: Actual time to execute
- **Actual rows vs Estimated rows**: Shows estimation accuracy
- **Buffers**: Shows disk I/O activity

```sql
-- Include buffer information
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM large_table WHERE indexed_column = 'value';
```

### Understanding Query Plan Nodes

**Seq Scan (Sequential Scan)**

```sql
EXPLAIN SELECT * FROM users WHERE email LIKE '%@example.com';
-- Shows: Seq Scan on users
```

Reads entire table. Appropriate for small tables or when most rows match. Consider indexing if filtering on specific columns.

**Index Scan**

```sql
CREATE INDEX idx_users_email ON users(email);
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';
-- Shows: Index Scan using idx_users_email on users
```

Uses index to find specific rows. Efficient for selective queries.

**Index Only Scan**

```sql
CREATE INDEX idx_users_email_created ON users(email, created_at);
EXPLAIN SELECT email, created_at FROM users WHERE email = 'user@example.com';
-- Shows: Index Only Scan using idx_users_email_created on users
```

Retrieves all data from index without accessing table. Most efficient when possible.

**Bitmap Index Scan**

```sql
EXPLAIN SELECT * FROM users WHERE age > 25 AND age < 35;
-- May show: Bitmap Index Scan on idx_users_age
```

[Inference] Used when multiple rows match or combining multiple indexes. Builds bitmap of matching pages before fetching.

**Nested Loop Join**

```sql
EXPLAIN 
SELECT * FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.id = 123;
-- May show: Nested Loop
```

Iterates through one table and looks up matches in another. Efficient for small result sets.

**Hash Join**

```sql
EXPLAIN 
SELECT * FROM orders o
JOIN products p ON o.product_id = p.id;
-- May show: Hash Join
```

Builds hash table of one side, probes with other. Good for larger joins.

**Merge Join**

```sql
EXPLAIN 
SELECT * FROM table1 t1
JOIN table2 t2 ON t1.sorted_col = t2.sorted_col;
-- May show: Merge Join
```

Requires both sides sorted. Efficient for large sorted datasets.

### Analyzing Specific Issues

```sql
-- Check if indexes are being used
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders 
WHERE user_id = 'abc123' 
AND created_at > NOW() - INTERVAL '7 days';

-- Look for:
-- - "Seq Scan" when index expected
-- - High "actual time" values
-- - "Buffers: shared read=" indicating disk I/O
-- - Large difference between estimated and actual rows

-- Check join performance
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.email, o.total
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 'pending';
```

### Query Plan Visualization

[Inference] Various tools can visualize EXPLAIN output for easier analysis:

- pgAdmin's graphical explain
- Online tools like explain.dalibo.com or explain.depesz.com
- PostgreSQL extensions for visual query plans

## Index Strategies

Indexes are data structures that improve query performance by allowing rapid data lookup. Proper indexing is critical for database performance.

### When to Create Indexes

**Create indexes for:**

- Columns frequently used in WHERE clauses
- Foreign key columns used in JOINs
- Columns used in ORDER BY or GROUP BY
- Columns with high cardinality (many distinct values)

**Avoid indexes for:**

- Small tables (under a few thousand rows)
- Columns with low cardinality (few distinct values like boolean fields)
- Columns rarely queried
- Tables with frequent writes and rare reads

### B-tree Indexes (Default)

Standard index type for most operations: equality, range queries, sorting.

```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index (column order matters)
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

-- Partial index (indexes subset of rows)
CREATE INDEX idx_active_users ON users(email) 
WHERE is_active = true AND deleted_at IS NULL;

-- Expression index
CREATE INDEX idx_users_lower_email ON users(LOWER(email));

-- Index with sort order
CREATE INDEX idx_posts_published_desc ON posts(published_at DESC);
```

### Composite Index Column Order

Column order in composite indexes significantly impacts effectiveness:

```sql
-- Good: Most selective column first
CREATE INDEX idx_orders_status_user_date ON orders(user_id, status, created_at);

-- This index efficiently supports:
SELECT * FROM orders WHERE user_id = 123;  -- Uses index
SELECT * FROM orders WHERE user_id = 123 AND status = 'pending';  -- Uses index
SELECT * FROM orders WHERE user_id = 123 AND status = 'pending' AND created_at > '2024-01-01';  -- Uses index

-- But NOT:
SELECT * FROM orders WHERE status = 'pending';  -- Cannot use index efficiently
SELECT * FROM orders WHERE created_at > '2024-01-01';  -- Cannot use index efficiently
```

**Rule of thumb:** Order columns by selectivity (most selective first) and query pattern frequency.

### Specialized Index Types

**GIN (Generalized Inverted Index)**

For full-text search, JSONB, arrays:

```sql
-- JSONB index
CREATE INDEX idx_users_metadata ON users USING GIN(metadata);

-- Query
SELECT * FROM users WHERE metadata @> '{"role": "admin"}';

-- Array index
CREATE INDEX idx_tags ON posts USING GIN(tags);

-- Query
SELECT * FROM posts WHERE tags @> ARRAY['postgresql', 'database'];

-- Full-text search
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', title || ' ' || content));

-- Query
SELECT * FROM posts 
WHERE to_tsvector('english', title || ' ' || content) @@ to_tsquery('postgresql & performance');
```

**GiST (Generalized Search Tree)**

For geometric data, full-text search, range types:

```sql
-- Range types
CREATE INDEX idx_event_timerange ON events USING GIST(time_range);

-- Query
SELECT * FROM events 
WHERE time_range && tstzrange('2024-01-01', '2024-01-31');

-- Geometric data
CREATE INDEX idx_locations_point ON locations USING GIST(coordinates);
```

**BRIN (Block Range Index)**

For very large tables with naturally ordered data:

```sql
-- Efficient for time-series or sequential data
CREATE INDEX idx_logs_timestamp ON logs USING BRIN(created_at);

-- Much smaller than B-tree but less precise
-- Good for append-only tables with hundreds of millions of rows
```

**Hash Indexes**

For equality comparisons only (rarely used):

```sql
-- Only supports = operator
CREATE INDEX idx_hash_user_id ON sessions USING HASH(user_id);
```

[Unverified] Hash indexes may have limitations compared to B-tree indexes in terms of recovery and replication in some PostgreSQL configurations.

### Index Maintenance

```sql
-- View index usage statistics
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Find unused indexes
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexname NOT LIKE 'pg_toast%'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Check index bloat
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Rebuild bloated index
REINDEX INDEX idx_name;

-- Rebuild all indexes on a table
REINDEX TABLE table_name;
```

### Covering Indexes

Include additional columns to enable index-only scans:

```sql
-- Without covering
CREATE INDEX idx_orders_user ON orders(user_id);
SELECT user_id, total FROM orders WHERE user_id = 123;
-- Requires table access for 'total'

-- With covering (INCLUDE clause)
CREATE INDEX idx_orders_user_covering ON orders(user_id) INCLUDE (total, created_at);
SELECT user_id, total, created_at FROM orders WHERE user_id = 123;
-- Index-only scan possible
```

### Partial Indexes

Index only relevant rows to save space and improve performance:

```sql
-- Index only active users
CREATE INDEX idx_active_users_email ON users(email) 
WHERE is_active = true;

-- Index only recent orders
CREATE INDEX idx_recent_orders ON orders(user_id, created_at)
WHERE created_at > NOW() - INTERVAL '90 days';

-- Index only unpaid invoices
CREATE INDEX idx_unpaid_invoices ON invoices(user_id)
WHERE status = 'unpaid';
```

### Index Monitoring Best Practices

```sql
-- Create monitoring query for regular execution
WITH index_stats AS (
  SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    pg_relation_size(indexrelid) as size_bytes
  FROM pg_stat_user_indexes
)
SELECT 
  *,
  CASE 
    WHEN idx_scan = 0 THEN 'UNUSED'
    WHEN idx_scan < 100 THEN 'RARELY_USED'
    ELSE 'ACTIVE'
  END as usage_category
FROM index_stats
WHERE size_bytes > 1000000  -- Larger than 1MB
ORDER BY idx_scan ASC, size_bytes DESC;
```

## Connection Pooling

Connection pooling manages database connections efficiently by reusing existing connections rather than creating new ones for each request.

### Why Connection Pooling Matters

Each PostgreSQL connection consumes memory and CPU. Creating connections is expensive:

- Connection overhead: ~10-50ms per connection
- Memory per connection: ~2-10MB
- PostgreSQL has connection limits

Without pooling, high-traffic applications quickly exhaust available connections or waste resources constantly creating/destroying connections.

### Supabase Connection Pooling

Supabase provides built-in connection pooling through PgBouncer with two modes:

**Transaction Mode (Recommended)**

```javascript
// Connection string format
const connectionString = 'postgresql://postgres:[PASSWORD]@[PROJECT_REF].pooler.supabase.com:6543/postgres'

// Using with Supabase client
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://[PROJECT_REF].supabase.co',
  '[ANON_KEY]'
)
```

Transaction mode releases connections after each transaction, allowing maximum connection reuse. [Inference] This mode is suitable for most serverless and API applications.

**Session Mode**

```javascript
// Port 5432 for session mode
const connectionString = 'postgresql://postgres:[PASSWORD]@[PROJECT_REF].pooler.supabase.com:5432/postgres'
```

Session mode maintains connection for entire client session. Required for:

- Prepared statements
- Advisory locks
- Listen/Notify
- Temporary tables

### Connection Pool Configuration

```javascript
// Using postgres.js with pooling
import postgres from 'postgres'

const sql = postgres(connectionString, {
  max: 10,                    // Maximum pool size
  idle_timeout: 20,           // Seconds before idle connection closed
  connect_timeout: 10,        // Seconds to wait for connection
  max_lifetime: 60 * 30,      // Maximum connection lifetime (30 min)
})
```

### Pool Size Recommendations

[Inference] Calculate appropriate pool size:

- **Formula**: `connections = ((core_count * 2) + effective_spindle_count)`
- **Serverless**: 1-5 connections per function instance
- **Traditional servers**: 10-20 connections per application server
- **Total**: Sum of all applications should not exceed PostgreSQL's `max_connections`

```sql
-- Check current connection limit
SHOW max_connections;

-- Monitor active connections
SELECT 
  COUNT(*) as total_connections,
  COUNT(*) FILTER (WHERE state = 'active') as active,
  COUNT(*) FILTER (WHERE state = 'idle') as idle,
  COUNT(*) FILTER (WHERE state = 'idle in transaction') as idle_in_transaction
FROM pg_stat_activity
WHERE datname = current_database();

-- View connections by application
SELECT 
  application_name,
  state,
  COUNT(*)
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY application_name, state
ORDER BY COUNT(*) DESC;
```

### Connection Pooling Anti-patterns

**Avoid:**

```javascript
// BAD: Creating new pool for each request
app.get('/users', async (req, res) => {
  const pool = new Pool({ connectionString })  // Don't do this!
  const result = await pool.query('SELECT * FROM users')
  await pool.end()
  res.json(result.rows)
})

// BAD: Not releasing connections
const client = await pool.connect()
await client.query('SELECT * FROM users')
// Missing: client.release()
```

**Correct approach:**

```javascript
// GOOD: Reuse pool instance
const pool = new Pool({ connectionString })

app.get('/users', async (req, res) => {
  const result = await pool.query('SELECT * FROM users')
  res.json(result.rows)
})

// GOOD: Always release connections
const client = await pool.connect()
try {
  await client.query('BEGIN')
  await client.query('INSERT INTO users ...')
  await client.query('COMMIT')
} catch (e) {
  await client.query('ROLLBACK')
  throw e
} finally {
  client.release()  // Always release
}
```

### Monitoring Connection Pool Health

```sql
-- Create monitoring function
CREATE OR REPLACE FUNCTION get_connection_stats()
RETURNS TABLE(
  total_connections bigint,
  active_connections bigint,
  idle_connections bigint,
  idle_in_transaction bigint,
  waiting_connections bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*),
    COUNT(*) FILTER (WHERE state = 'active'),
    COUNT(*) FILTER (WHERE state = 'idle'),
    COUNT(*) FILTER (WHERE state = 'idle in transaction'),
    COUNT(*) FILTER (WHERE wait_event_type IS NOT NULL)
  FROM pg_stat_activity
  WHERE datname = current_database();
END;
$$ LANGUAGE plpgsql;

-- Check for connection leaks (idle in transaction)
SELECT 
  pid,
  usename,
  application_name,
  state,
  NOW() - state_change as duration,
  query
FROM pg_stat_activity
WHERE state = 'idle in transaction'
  AND NOW() - state_change > INTERVAL '5 minutes';
```

## Caching Strategies

Caching reduces database load by storing frequently accessed data in faster storage layers.

### Application-Level Caching

**In-memory caching with Redis/Upstash:**

```javascript
import { createClient } from '@supabase/supabase-js'
import Redis from 'ioredis'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)
const redis = new Redis(REDIS_URL)

async function getUser(userId) {
  // Check cache first
  const cached = await redis.get(`user:${userId}`)
  if (cached) {
    return JSON.parse(cached)
  }
  
  // Cache miss: fetch from database
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .single()
  
  if (data) {
    // Cache for 5 minutes
    await redis.setex(`user:${userId}`, 300, JSON.stringify(data))
  }
  
  return data
}
```

**Cache invalidation:**

```javascript
// Invalidate on update
async function updateUser(userId, updates) {
  const { data, error } = await supabase
    .from('users')
    .update(updates)
    .eq('id', userId)
    .select()
    .single()
  
  if (data) {
    // Invalidate cache
    await redis.del(`user:${userId}`)
    // Or update cache
    await redis.setex(`user:${userId}`, 300, JSON.stringify(data))
  }
  
  return data
}
```

### Query Result Caching

```javascript
// Cache expensive queries
async function getDashboardStats(userId) {
  const cacheKey = `dashboard:${userId}`
  const cached = await redis.get(cacheKey)
  
  if (cached) return JSON.parse(cached)
  
  // Expensive aggregation query
  const { data } = await supabase.rpc('get_dashboard_stats', { 
    p_user_id: userId 
  })
  
  // Cache for 15 minutes
  await redis.setex(cacheKey, 900, JSON.stringify(data))
  return data
}
```

### PostgreSQL Built-in Caching

PostgreSQL maintains several cache layers automatically:

**Shared Buffer Cache:**

```sql
-- Check cache hit ratio (should be > 99%)
SELECT 
  SUM(heap_blks_read) as heap_read,
  SUM(heap_blks_hit) as heap_hit,
  SUM(heap_blks_hit) / (SUM(heap_blks_hit) + SUM(heap_blks_read)) * 100 as cache_hit_ratio
FROM pg_statio_user_tables;

-- View cached table data
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
  heap_blks_hit,
  heap_blks_read,
  heap_blks_hit::float / NULLIF((heap_blks_hit + heap_blks_read), 0) * 100 as hit_ratio
FROM pg_statio_user_tables
ORDER BY heap_blks_read DESC
LIMIT 20;
```

### Materialized Views

Materialized views cache complex query results:

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW user_order_summary AS
SELECT 
  u.id,
  u.email,
  COUNT(o.id) as total_orders,
  SUM(o.total) as total_spent,
  MAX(o.created_at) as last_order_date,
  AVG(o.total) as avg_order_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.email;

-- Create index on materialized view
CREATE INDEX idx_mv_user_order_summary ON user_order_summary(id);

-- Query materialized view (fast)
SELECT * FROM user_order_summary WHERE id = '123';

-- Refresh materialized view
REFRESH MATERIALIZED VIEW user_order_summary;

-- Refresh without locking (allows concurrent reads)
REFRESH MATERIALIZED VIEW CONCURRENTLY user_order_summary;
```

**Automated refresh:**

```sql
-- Create function to refresh materialized view
CREATE OR REPLACE FUNCTION refresh_user_summary()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY user_order_summary;
END;
$$ LANGUAGE plpgsql;

-- Schedule using pg_cron extension (if available)
-- SELECT cron.schedule('refresh-user-summary', '*/30 * * * *', 'SELECT refresh_user_summary()');
```

[Unverified] pg_cron availability may vary depending on Supabase plan and configuration.

### Cache Warming

```sql
-- Preload frequently accessed data into cache
SELECT pg_prewarm('users');
SELECT pg_prewarm('orders');

-- Check what's in cache
SELECT 
  c.relname,
  count(*) AS buffers,
  pg_size_pretty(count(*) * 8192) as size
FROM pg_buffercache b
INNER JOIN pg_class c ON b.relfilenode = pg_relation_filenode(c.oid)
WHERE b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database()))
GROUP BY c.relname
ORDER BY count(*) DESC
LIMIT 20;
```

### Caching Best Practices

**Cache appropriate data:**

- Reference data that changes infrequently
- Expensive computed results
- Frequently accessed user data
- API responses

**Avoid caching:**

- Data requiring real-time accuracy
- User-specific sensitive data (without proper encryption)
- Data that changes frequently relative to cache duration

**Set appropriate TTLs:**

```javascript
const CACHE_DURATIONS = {
  STATIC_DATA: 3600,      // 1 hour
  USER_PROFILE: 300,      // 5 minutes
  DASHBOARD_STATS: 900,   // 15 minutes
  SEARCH_RESULTS: 60,     // 1 minute
}
```

## N+1 Query Problems

N+1 queries occur when an application executes one query to fetch a list, then N additional queries to fetch related data for each item. This pattern severely impacts performance.

### Identifying N+1 Problems

**Anti-pattern example:**

```javascript
// BAD: N+1 query problem
const { data: users } = await supabase
  .from('users')
  .select('id, email')
  .limit(10)

// This executes 10 additional queries!
for (const user of users) {
  const { data: orders } = await supabase
    .from('orders')
    .select('*')
    .eq('user_id', user.id)
  
  user.orders = orders
}
```

This results in 11 queries total (1 + 10).

### Solutions

**Use JOIN or nested select:**

```javascript
// GOOD: Single query with join
const { data: users } = await supabase
  .from('users')
  .select(`
    id,
    email,
    orders (
      id,
      total,
      created_at
    )
  `)
  .limit(10)
```

**Use IN clause with batching:**

```javascript
// GOOD: Two queries total
const { data: users } = await supabase
  .from('users')
  .select('id, email')
  .limit(10)

const userIds = users.map(u => u.id)

const { data: orders } = await supabase
  .from('orders')
  .select('*')
  .in('user_id', userIds)

// Group orders by user in application
const ordersByUser = orders.reduce((acc, order) => {
  if (!acc[order.user_id]) acc[order.user_id] = []
  acc[order.user_id].push(order)
  return acc
}, {})

users.forEach(user => {
  user.orders = ordersByUser[user.id] || []
})
```

### PostgreSQL-Level Detection

```sql
-- Monitor for patterns indicating N+1
SELECT 
  LEFT(query, 100) as query_pattern,
  calls,
  mean_exec_time,
  total_exec_time
FROM pg_stat_statements
WHERE calls > 1000
  AND query LIKE '%WHERE%=%'
ORDER BY calls DESC;
```

### Complex N+1 Example

```javascript
// BAD: Multiple levels of N+1
async function getBadUserData() {
  const users = await db.query('SELECT * FROM users LIMIT 10')
  
  for (const user of users) {
    user.orders = await db.query('SELECT * FROM orders WHERE user_id = ?', [user.id])
    
    for (const order of user.orders) {
      order.items = await db.query('SELECT * FROM order_items WHERE order_id = ?', [order.id])
      // 10 users * 5 orders * query = 50 additional queries
    }
  }
  
  return users
}

// GOOD: Single optimized query
async function getGoodUserData() {
  const { data } = await supabase
    .from('users')
    .select(`
      *,
      orders (
        *,
        order_items (
          *,
          product:products (
            id,
            name,
            price
          )
        )
      )
    `)
    .limit(10)
  
  return data
}
```

### Using Database Functions for Complex Queries

```sql
-- Create function to return nested data
CREATE OR REPLACE FUNCTION get_user_with_orders(p_user_id uuid)
RETURNS json AS $$
BEGIN
  RETURN (
    SELECT json_build_object(
      'user', row_to_json(u.*),
      'orders', COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'order', row_to_json(o.*),
              'items', (
                SELECT json_agg(row_to_json(oi.*))
                FROM order_items oi
                WHERE oi.order_id = o.id
              )
            )
          )
          FROM orders o
          WHERE o.user_id = u.id
        ),
        '[]'::json
      )
    )
    FROM users u
    WHERE u.id = p_user_id
  );
END;
$$ LANGUAGE plpgsql;

-- Call from application
const { data } = await supabase.rpc('get_user_with_orders', {
  p_user_id: userId
})
```

## Batch Operations

Batch operations process multiple records in single queries, dramatically improving performance over iterative operations.

### Batch Inserts

```javascript
// BAD: Individual inserts
for (const user of users) {
  await supabase
    .from('users')
    .insert({ email: user.email, name: user.name })
}

// GOOD: Batch insert
await supabase
  .from('users')
  .insert(users.map(u => ({ email: u.email, name: u.name })))
```

```sql
-- SQL batch insert
INSERT INTO users (email, name, role)
VALUES 
  ('user1@example.com', 'User One', 'member'),
  ('user2@example.com', 'User Two', 'member'),
  ('user3@example.com', 'User Three', 'admin')
ON CONFLICT (email) DO UPDATE
SET name = EXCLUDED.name, role = EXCLUDED.role;
```

### Batch Updates

```javascript
// BAD: Individual updates
for (const orderId of orderIds) {
  await supabase
    .from('orders')
    .update({ status: 'shipped' })
    .eq('id', orderId)
}

// GOOD: Batch update
await supabase
  .from('orders')
  .update({ status: 'shipped' })
  .in('id', orderIds)
```

```sql
-- SQL batch update with CASE
UPDATE products
SET price = CASE id
  WHEN '550e8400-e29b-41d4-a716-446655440001' THEN 99.99
  WHEN '550e8400-e29b-41d4-a716-446655440002' THEN 149.99
  WHEN '550e8400-e29b-41d4-a716-446655440003' THEN 199.99
END
WHERE id IN (
  '550e8400-e29b-41d4-a716-446655440001',
  '550e8400-e29b-41d4-a716-446655440002',
  '550e8400-e29b-41d4-a716-446655440003'
);

-- Update from temporary table
CREATE TEMP TABLE price_updates (
  product_id uuid,
  new_price numeric
);

INSERT INTO price_updates VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 99.99),
  ('550e8400-e29b-41d4-a716-446655440002', 149.99);

UPDATE products p
SET price = pu.new_price
FROM price_updates pu
WHERE p.id = pu.product_id;
```

### Batch Deletes

```javascript
// BAD: Individual deletes
for (const id of idsToDelete) {
  await supabase
    .from('old_records')
    .delete()
    .eq('id', id)
}

// GOOD: Batch delete
await supabase
  .from('old_records')
  .delete()
  .in('id', idsToDelete)
```

```sql
-- SQL batch delete
DELETE FROM logs
WHERE created_at < NOW() - INTERVAL '90 days';

-- Batch delete with JOIN
DELETE FROM order_items oi
USING orders o
WHERE oi.order_id = o.id
  AND o.status = 'cancelled'
  AND o.created_at < NOW() - INTERVAL '30 days';
```

### COPY for Bulk Data Loading

```sql
-- Most efficient for large data imports
COPY users (email, name, created_at)
FROM '/path/to/users.csv'
WITH (FORMAT csv, HEADER true);

-- Or from program
COPY users (email, name)
FROM STDIN
WITH (FORMAT csv);
```

```javascript
// Using node-postgres COPY
import { pipeline } from 'stream'
import { from as copyFrom } from 'pg-copy-streams'

const client = await pool.connect()
const stream = client.query(copyFrom('COPY users (email, name) FROM STDIN CSV'))

const dataStream = /* your data source stream */
await pipeline(dataStream, stream)
client.release()
```

### Batch Processing Patterns

**Chunked processing:**
```javascript
// Process large dataset in chunks
async function processBatchInChunks(items, chunkSize = 1000) {
  for (let i = 0; i < items.length; i += chunkSize) {
    const chunk = items.slice(i, i + chunkSize)
    
    await supabase
      .from('table')
      .insert(chunk)
    
    console.log(`Processed ${i + chunk.length} of ${items.length}`)
  }
}
```

**Parallel batch operations:**
```javascript
// Process multiple batches concurrently
async function parallelBatchProcess(items, batchSize = 1000, concurrency = 5) {
  const batches = []
  for (let i = 0; i < items.length; i += batchSize) {
    batches.push(items.slice(i, i + batchSize))
  }
  
  // Process batches with limited concurrency
  for (let i = 0; i < batches.length; i += concurrency) {
    const batchGroup = batches.slice(i, i + concurrency)
    
    await Promise.all(
      batchGroup.map(batch =>
        supabase.from('table').insert(batch)
      )
    )
    
    console.log(`Completed ${Math.min(i + concurrency, batches.length)} of ${batches.length} batches`)
  }
}
```

### Batch Upsert (Insert or Update)

```javascript
// Supabase batch upsert
await supabase
  .from('products')
  .upsert(
    products.map(p => ({
      id: p.id,
      name: p.name,
      price: p.price,
      updated_at: new Date().toISOString()
    })),
    { onConflict: 'id' }
  )
```

```sql
-- SQL upsert with DO UPDATE
INSERT INTO products (id, name, price, stock)
VALUES 
  ('prod-1', 'Product 1', 99.99, 100),
  ('prod-2', 'Product 2', 149.99, 50)
ON CONFLICT (id) DO UPDATE
SET 
  name = EXCLUDED.name,
  price = EXCLUDED.price,
  stock = products.stock + EXCLUDED.stock,
  updated_at = NOW();
```

### Using UNNEST for Batch Operations

```sql
-- Batch insert using UNNEST
INSERT INTO users (email, name, role)
SELECT * FROM UNNEST(
  ARRAY['user1@example.com', 'user2@example.com', 'user3@example.com'],
  ARRAY['User One', 'User Two', 'User Three'],
  ARRAY['member', 'member', 'admin']
) AS t(email, name, role);

-- Batch update using UNNEST
UPDATE products p
SET price = u.new_price
FROM UNNEST(
  ARRAY['prod-1', 'prod-2', 'prod-3']::uuid[],
  ARRAY[99.99, 149.99, 199.99]::numeric[]
) AS u(product_id, new_price)
WHERE p.id = u.product_id;
```

### Batch Performance Comparison

```sql
-- Measure batch vs individual operations
DO $$
DECLARE
  start_time timestamp;
  end_time timestamp;
  i integer;
BEGIN
  -- Individual inserts
  start_time := clock_timestamp();
  FOR i IN 1..1000 LOOP
    INSERT INTO test_table (value) VALUES (i);
  END LOOP;
  end_time := clock_timestamp();
  RAISE NOTICE 'Individual inserts: %', end_time - start_time;
  
  -- Batch insert
  start_time := clock_timestamp();
  INSERT INTO test_table (value)
  SELECT generate_series(1001, 2000);
  end_time := clock_timestamp();
  RAISE NOTICE 'Batch insert: %', end_time - start_time;
END $$;
```

[Inference] Batch operations are typically 10-100x faster than individual operations, depending on network latency, transaction overhead, and data size.

## Database Statistics

PostgreSQL maintains statistics about table contents to help the query planner make optimal decisions. Accurate statistics are essential for good query performance.

### Understanding Statistics

```sql
-- View table statistics
SELECT 
  schemaname,
  tablename,
  n_live_tup as live_rows,
  n_dead_tup as dead_rows,
  n_mod_since_analyze as modifications_since_analyze,
  last_vacuum,
  last_autovacuum,
  last_analyze,
  last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_mod_since_analyze DESC;

-- View column statistics
SELECT 
  tablename,
  attname as column_name,
  n_distinct,
  correlation,
  most_common_vals,
  most_common_freqs
FROM pg_stats
WHERE schemaname = 'public'
  AND tablename = 'users';
```

### Manual Statistics Update

```sql
-- Analyze specific table
ANALYZE users;

-- Analyze specific columns
ANALYZE users (email, created_at);

-- Analyze all tables
ANALYZE;

-- Verbose analyze (shows detailed info)
ANALYZE VERBOSE users;
```

### Autovacuum and Autoanalyze

PostgreSQL automatically runs VACUUM and ANALYZE through the autovacuum daemon:

```sql
-- Check autovacuum settings
SHOW autovacuum;
SHOW autovacuum_analyze_threshold;
SHOW autovacuum_analyze_scale_factor;

-- View autovacuum activity
SELECT 
  schemaname,
  tablename,
  last_autovacuum,
  last_autoanalyze,
  n_dead_tup,
  n_mod_since_analyze
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY last_autoanalyze ASC NULLS FIRST;
```

### Statistics Configuration

```sql
-- Adjust statistics target for specific columns
ALTER TABLE users ALTER COLUMN email SET STATISTICS 1000;
-- Default is 100, higher = more accurate but slower ANALYZE

-- Reset to default
ALTER TABLE users ALTER COLUMN email SET STATISTICS -1;

-- Set statistics target for entire table
ALTER TABLE users SET (autovacuum_analyze_scale_factor = 0.05);
```

### Monitoring Statistics Staleness

```sql
-- Find tables with stale statistics
SELECT 
  schemaname,
  tablename,
  n_live_tup as rows,
  n_mod_since_analyze as changes_since_analyze,
  ROUND(100.0 * n_mod_since_analyze / NULLIF(n_live_tup, 0), 2) as pct_changed,
  last_autoanalyze
FROM pg_stat_user_tables
WHERE n_live_tup > 1000
  AND n_mod_since_analyze > n_live_tup * 0.1
ORDER BY n_mod_since_analyze DESC;
```

### Statistics and Query Planning

```sql
-- See how statistics affect query plans
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users WHERE created_at > NOW() - INTERVAL '7 days';

-- Check if planner estimates are accurate
-- Compare "rows=X" (estimate) vs "actual rows=Y"

-- If estimates are way off, analyze the table
ANALYZE users;

-- Rerun explain to see improved estimates
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users WHERE created_at > NOW() - INTERVAL '7 days';
```

### Extended Statistics

For correlated columns, create extended statistics:

```sql
-- Create extended statistics for correlated columns
CREATE STATISTICS users_city_state_stats (dependencies)
ON city, state FROM users;

-- Create multivariate statistics
CREATE STATISTICS products_category_price_stats (ndistinct, dependencies)
ON category_id, price FROM products;

-- Analyze to populate extended statistics
ANALYZE users;
ANALYZE products;

-- View extended statistics
SELECT * FROM pg_statistic_ext;
```

[Inference] Extended statistics help the planner understand correlations between columns, improving estimates for multi-column WHERE clauses.

## Read Replicas

[Unverified] Read replicas are available in Supabase's Pro and Enterprise plans. They provide horizontally scaled read capacity by replicating data from the primary database to one or more replica databases.

### Read Replica Benefits

- Distribute read load across multiple databases
- Reduce load on primary database
- Improve query performance for read-heavy workloads
- Geographic distribution for lower latency
- Dedicated resources for analytics or reporting

### Using Read Replicas

```javascript
// Primary connection (reads and writes)
const supabasePrimary = createClient(PRIMARY_URL, ANON_KEY)

// Read replica connection (reads only)
const supabaseReplica = createClient(REPLICA_URL, ANON_KEY)

// Write to primary
await supabasePrimary
  .from('users')
  .insert({ email: 'new@example.com' })

// Read from replica
const { data } = await supabaseReplica
  .from('users')
  .select('*')
  .limit(100)
```

### Replication Lag Considerations

[Inference] Read replicas operate asynchronously, meaning there's typically a small delay (replication lag) between writes to primary and visibility on replicas:

```javascript
// Handle replication lag
async function createAndVerify(data) {
  // Write to primary
  const { data: created } = await supabasePrimary
    .from('users')
    .insert(data)
    .select()
    .single()
  
  // Read from primary immediately after write
  // to avoid replication lag issues
  const { data: verified } = await supabasePrimary
    .from('users')
    .select('*')
    .eq('id', created.id)
    .single()
  
  return verified
}

// For non-critical reads, use replica
async function getUsers(filters) {
  return await supabaseReplica
    .from('users')
    .select('*')
    .match(filters)
}
```

### Read Replica Patterns

**Pattern 1: Route by operation type**
```javascript
class DatabaseRouter {
  constructor(primary, replica) {
    this.primary = primary
    this.replica = replica
  }
  
  async read(table, query) {
    return await this.replica.from(table).select(query)
  }
  
  async write(table, data) {
    return await this.primary.from(table).insert(data)
  }
  
  async update(table, id, data) {
    return await this.primary.from(table).update(data).eq('id', id)
  }
}
```

**Pattern 2: Dedicated analytics queries**
```javascript
// Heavy analytics on replica to avoid affecting primary
async function getAnalyticsReport() {
  const { data } = await supabaseReplica.rpc('generate_sales_report', {
    start_date: '2024-01-01',
    end_date: '2024-12-31'
  })
  
  return data
}
```

**Pattern 3: Geographic distribution**
```javascript
// Use replica closest to user
const getUserRegion = (userLocation) => {
  // Determine nearest replica based on user location
}

const replicaUrl = getUserRegion(userLocation)
const supabase = createClient(replicaUrl, ANON_KEY)
```

### Monitoring Replication

```sql
-- Check replication lag (on primary)
SELECT 
  client_addr,
  state,
  sent_lsn,
  write_lsn,
  flush_lsn,
  replay_lsn,
  sync_state,
  pg_wal_lsn_diff(sent_lsn, replay_lsn) as lag_bytes
FROM pg_stat_replication;

-- Monitor replication slots
SELECT 
  slot_name,
  slot_type,
  active,
  pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) as retained_bytes
FROM pg_replication_slots;
```

## Database Size Management

Managing database size is crucial for performance, cost control, and operational efficiency.

### Monitoring Database Size

```sql
-- Overall database size
SELECT 
  pg_database.datname,
  pg_size_pretty(pg_database_size(pg_database.datname)) as size
FROM pg_database
ORDER BY pg_database_size(pg_database.datname) DESC;

-- Table sizes with indexes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
  pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - 
                 pg_relation_size(schemaname||'.'||tablename)) as indexes_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Largest tables
SELECT 
  tablename,
  pg_size_pretty(pg_total_relation_size(tablename::regclass)) as size,
  pg_total_relation_size(tablename::regclass) as bytes
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(tablename::regclass) DESC
LIMIT 20;

-- Largest indexes
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC
LIMIT 20;
```

### Table Bloat

Table bloat occurs when tables contain dead rows not yet reclaimed by VACUUM:

```sql
-- Detect table bloat
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
  n_dead_tup as dead_rows,
  n_live_tup as live_rows,
  ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) as bloat_pct
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY n_dead_tup DESC;

-- Manual vacuum to reclaim space
VACUUM FULL users;  -- Rewrites entire table, locks table
VACUUM users;       -- Marks space as reusable, doesn't return to OS
```

### Index Bloat

```sql
-- Estimate index bloat
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as size,
  idx_scan as scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Rebuild bloated indexes
REINDEX TABLE users;
REINDEX INDEX idx_users_email;
```

### Data Archival Strategies

**Time-based partitioning for archival:**
```sql
-- Create partitioned table
CREATE TABLE logs (
  id bigserial,
  message text,
  created_at timestamptz NOT NULL
) PARTITION BY RANGE (created_at);

-- Create partitions
CREATE TABLE logs_2024_01 PARTITION OF logs
  FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE logs_2024_02 PARTITION OF logs
  FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Archive old partitions
-- Detach partition
ALTER TABLE logs DETACH PARTITION logs_2024_01;

-- Export to archive
COPY logs_2024_01 TO '/archive/logs_2024_01.csv' WITH CSV HEADER;

-- Drop old partition
DROP TABLE logs_2024_01;
```

**Soft delete for data retention:**
```sql
-- Add deleted_at column
ALTER TABLE users ADD COLUMN deleted_at timestamptz;

-- Create index for active records
CREATE INDEX idx_users_active ON users(id) WHERE deleted_at IS NULL;

-- Soft delete
UPDATE users SET deleted_at = NOW() WHERE id = 'user-id';

-- Periodically hard delete old soft-deleted records
DELETE FROM users 
WHERE deleted_at < NOW() - INTERVAL '90 days';
```

### Compression

**TOAST compression:**
PostgreSQL automatically compresses large values using TOAST (The Oversized-Attribute Storage Technique):

```sql
-- Check TOAST settings
SELECT 
  relname,
  reltoastrelid,
  pg_size_pretty(pg_total_relation_size(reltoastrelid)) as toast_size
FROM pg_class
WHERE reltoastrelid <> 0
ORDER BY pg_total_relation_size(reltoastrelid) DESC;

-- Modify column storage
ALTER TABLE documents ALTER COLUMN content SET STORAGE EXTENDED;  -- Compress + move to TOAST
ALTER TABLE documents ALTER COLUMN content SET STORAGE EXTERNAL;  -- Move to TOAST, no compression
ALTER TABLE documents ALTER COLUMN content SET STORAGE MAIN;      -- Keep inline, compress if needed
```

**Column-level compression (PostgreSQL 14+):**
```sql
-- Use compression for specific column
ALTER TABLE documents ALTER COLUMN content SET COMPRESSION lz4;

-- Check compression method
SELECT 
  attname,
  attcompression
FROM pg_attribute
WHERE attrelid = 'documents'::regclass
  AND attnum > 0;
```

### Data Retention Policies

```sql
-- Create function for data cleanup
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $$
BEGIN
  -- Delete old logs
  DELETE FROM logs WHERE created_at < NOW() - INTERVAL '30 days';
  
  -- Delete old sessions
  DELETE FROM sessions WHERE expires_at < NOW();
  
  -- Archive old orders
  INSERT INTO archived_orders
  SELECT * FROM orders 
  WHERE created_at < NOW() - INTERVAL '2 years';
  
  DELETE FROM orders 
  WHERE created_at < NOW() - INTERVAL '2 years';
  
  -- Log cleanup activity
  INSERT INTO maintenance_log (activity, executed_at)
  VALUES ('data_cleanup', NOW());
END;
$$ LANGUAGE plpgsql;

-- Schedule cleanup (using pg_cron if available)
-- SELECT cron.schedule('nightly-cleanup', '0 2 * * *', 'SELECT cleanup_old_data()');
```

### Monitoring Growth Trends

```sql
-- Create table to track size over time
CREATE TABLE database_size_history (
  id serial PRIMARY KEY,
  table_name text,
  table_size bigint,
  index_size bigint,
  total_size bigint,
  recorded_at timestamptz DEFAULT NOW()
);

-- Function to record sizes
CREATE OR REPLACE FUNCTION record_table_sizes()
RETURNS void AS $$
BEGIN
  INSERT INTO database_size_history (table_name, table_size, index_size, total_size)
  SELECT 
    tablename,
    pg_relation_size(schemaname||'.'||tablename),
    pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename),
    pg_total_relation_size(schemaname||'.'||tablename)
  FROM pg_tables
  WHERE schemaname = 'public';
END;
$$ LANGUAGE plpgsql;

-- Query growth trends
SELECT 
  table_name,
  pg_size_pretty(MAX(total_size) FILTER (WHERE recorded_at > NOW() - INTERVAL '1 day')) as current_size,
  pg_size_pretty(MAX(total_size) FILTER (WHERE recorded_at > NOW() - INTERVAL '8 days' AND recorded_at < NOW() - INTERVAL '7 days')) as week_ago,
  pg_size_pretty(MAX(total_size) - MIN(total_size)) as growth
FROM database_size_history
WHERE recorded_at > NOW() - INTERVAL '8 days'
GROUP BY table_name
ORDER BY MAX(total_size) DESC;
```

### Storage Optimization Best Practices

**Choose appropriate data types:**
```sql
-- Bad: Wastes space
CREATE TABLE products (
  id text,                    -- UUID as text: 36 bytes
  price numeric(20, 10),      -- Overly precise
  in_stock boolean            -- 1 byte but aligned
);

-- Good: Optimized
CREATE TABLE products (
  id uuid,                    -- UUID type: 16 bytes
  price integer,              -- Cents as integer: 4 bytes
  in_stock boolean
);
```

**Normalize appropriately:**
```sql
-- Denormalized: Repeated data
CREATE TABLE orders (
  id uuid PRIMARY KEY,
  customer_email text,
  customer_name text,
  customer_address text
  -- Customer data repeated in every order
);

-- Normalized: Reference data
CREATE TABLE customers (
  id uuid PRIMARY KEY,
  email text,
  name text,
  address text
);

CREATE TABLE orders (
  id uuid PRIMARY KEY,
  customer_id uuid REFERENCES customers(id)
  -- Reference instead of duplication
);
```

**Use appropriate indexes:**
```sql
-- Remove redundant indexes
-- If you have idx_users_email_name(email, name)
-- Then idx_users_email(email) is redundant

-- Find duplicate indexes
SELECT 
  pg_size_pretty(SUM(pg_relation_size(idx))::bigint) as size,
  (array_agg(idx))[1] as idx1,
  (array_agg(idx))[2] as idx2
FROM (
  SELECT 
    indexrelid::regclass as idx,
    indrelid,
    indkey::text
  FROM pg_index
) sub
GROUP BY indrelid, indkey
HAVING COUNT(*) > 1;
```

**Important related topics:**
- **Vacuum strategies and configuration** - Fine-tuning autovacuum for your workload
- **Query optimization techniques** - Advanced strategies beyond basic indexing
- **Monitoring and alerting setup** - Building comprehensive performance monitoring
- **Connection pool tuning** - Optimizing pool parameters for your specific needs
- **Performance testing methodologies** - Load testing and benchmarking approaches

---

# Security Best Practices

Security in Supabase requires a multi-layered approach combining database-level protections, API security, client-side safeguards, and operational practices. Supabase provides built-in security features, but proper configuration and implementation are critical to protecting your application and user data.

## API Key Management

Supabase projects include two primary API keys with different security profiles and use cases.

**Anon (public) key:**

The anon key is safe to expose in client-side code, mobile apps, and public repositories. It provides access only to data permitted by Row Level Security policies. This key authenticates requests but grants no inherent privileges beyond what RLS policies explicitly allow. When users are unauthenticated, requests using the anon key can only access publicly available data as defined by your policies.

**Service role key:**

The service role key bypasses all Row Level Security policies and should never be exposed in client-side code, version control, or publicly accessible locations. This key has superuser-level access to your database and should only be used in secure server-side environments, backend services, administrative scripts, or CI/CD pipelines. [Inference: Exposing the service role key would grant unrestricted database access to anyone who obtains it]

**Key rotation:**

Rotate API keys if compromised or as periodic security practice. In your Supabase project settings under API, you can generate new keys. After rotation, update all applications and services using the old keys. [Unverified: The exact process for key rotation and whether old keys are immediately invalidated or have a grace period may vary]

**Environment-specific keys:**

Use different Supabase projects for development, staging, and production environments, each with distinct API keys. This prevents development testing from affecting production data and limits the blast radius of potential security incidents.

**Storage practices:**

- Store keys in environment variables, never hardcode them
- Use secrets management systems (AWS Secrets Manager, HashiCorp Vault, Doppler)
- Add `.env` files to `.gitignore` to prevent accidental commits
- Use platform-specific secure storage on mobile (Keychain on iOS, Keystore on Android)
- Implement key access controls limiting which team members can view service role keys

**Monitoring key usage:**

Monitor API logs for unusual patterns indicating compromised keys such as unexpected geographic locations, abnormal request volumes, or unauthorized access attempts. [Inference: Supabase likely provides logging capabilities for this purpose, though specific monitoring features may vary by plan]

## RLS Policy Design

Row Level Security policies enforce authorization at the database level, ensuring users can only access data they're permitted to see regardless of how they connect to the database.

**Enabling RLS:**

```sql
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
```

Without policies defined, enabling RLS blocks all access. You must explicitly create policies granting permissions.

**Policy structure:**

Policies consist of:

- **Operation**: SELECT, INSERT, UPDATE, DELETE, or ALL
- **Role**: Which database role the policy applies to (typically `authenticated` or `anon`)
- **USING clause**: Boolean expression determining which rows are visible (for SELECT/UPDATE/DELETE)
- **WITH CHECK clause**: Boolean expression validating new/modified rows (for INSERT/UPDATE)

**Basic ownership pattern:**

```sql
CREATE POLICY "Users can view own data"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

**Public read, authenticated write:**

```sql
CREATE POLICY "Anyone can read posts"
ON posts FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "Authenticated users can insert posts"
ON posts FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = author_id);
```

**Role-based access:**

```sql
CREATE POLICY "Admins can do everything"
ON sensitive_data FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
);
```

**Multi-tenancy pattern:**

```sql
CREATE POLICY "Users see only their organization's data"
ON documents FOR SELECT
TO authenticated
USING (
  organization_id IN (
    SELECT organization_id FROM user_organizations
    WHERE user_id = auth.uid()
  )
);
```

**Time-based access:**

```sql
CREATE POLICY "View published posts only"
ON posts FOR SELECT
TO anon, authenticated
USING (
  status = 'published'
  AND published_at <= NOW()
);
```

**Design principles:**

- **Deny by default**: Enable RLS on all tables and explicitly grant permissions
- **Test thoroughly**: RLS policies can be complex; test with different user roles and scenarios
- **Avoid performance bottlenecks**: Complex subqueries in policies can slow down queries; consider denormalizing data or using indexed columns
- **Use consistent patterns**: Apply similar policy structures across related tables
- **Document policies**: Add comments explaining business logic behind complex policies
- **Separate concerns**: Create distinct policies for each operation rather than using ALL when possible

**Helper functions:**

Create reusable functions for common checks:

```sql
CREATE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE SQL STABLE SECURITY DEFINER;

CREATE POLICY "Admins manage users"
ON users FOR ALL
TO authenticated
USING (is_admin());
```

**Common pitfalls:**

- Forgetting to enable RLS on new tables
- Using USING clause when WITH CHECK is needed (allows reading data but prevents modifying it appropriately)
- Creating overly complex policies that degrade performance
- Not testing policies with actual user sessions
- Assuming policies cascade to related tables (each table needs its own policies)

## Input Validation

Input validation prevents malformed, malicious, or unexpected data from entering your database and protects against various attack vectors.

**Database-level constraints:**

PostgreSQL constraints provide the first line of defense:

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  age INTEGER CHECK (age >= 0 AND age <= 150),
  username TEXT NOT NULL CHECK (LENGTH(username) BETWEEN 3 AND 30),
  status TEXT CHECK (status IN ('active', 'suspended', 'deleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Check constraints** enforce business rules at the database level. They execute on every insert and update, rejecting invalid data before it's committed.

**Domain types:**

Create reusable validation logic with custom domains:

```sql
CREATE DOMAIN email_address AS TEXT
CHECK (VALUE ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

CREATE DOMAIN positive_integer AS INTEGER
CHECK (VALUE > 0);

CREATE TABLE products (
  id UUID PRIMARY KEY,
  contact_email email_address,
  quantity positive_integer
);
```

**Triggers for complex validation:**

```sql
CREATE FUNCTION validate_phone_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.phone !~ '^\+?[1-9]\d{1,14}$' THEN
    RAISE EXCEPTION 'Invalid phone number format';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_phone_before_insert
BEFORE INSERT OR UPDATE ON contacts
FOR EACH ROW
EXECUTE FUNCTION validate_phone_number();
```

**Client-side validation:**

While not a security measure (client-side code can be bypassed), client validation improves user experience:

```javascript
// Example validation before Supabase insert
function validateUserInput(data) {
  const errors = {};
  
  if (!data.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
    errors.email = 'Valid email required';
  }
  
  if (!data.username || data.username.length < 3) {
    errors.username = 'Username must be at least 3 characters';
  }
  
  if (data.age && (data.age < 0 || data.age > 150)) {
    errors.age = 'Age must be between 0 and 150';
  }
  
  return Object.keys(errors).length === 0 ? null : errors;
}
```

**Server-side validation with Edge Functions:**

For complex validation logic not suitable for database constraints:

```javascript
// Edge Function for validation
const validateOrder = (order) => {
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must contain at least one item');
  }
  
  if (order.total_amount !== calculateTotal(order.items)) {
    throw new Error('Total amount mismatch');
  }
  
  // Additional business logic validation
};
```

**Validation strategies:**

- **Whitelist over blacklist**: Define what's allowed rather than what's forbidden
- **Type checking**: Ensure data types match expected schemas
- **Length limits**: Prevent excessively long inputs that could cause performance issues
- **Format validation**: Use regular expressions for structured data (emails, phone numbers, URLs)
- **Range validation**: Numeric values within acceptable bounds
- **Referential integrity**: Foreign key constraints validate relationships automatically
- **Sanitization**: Strip or escape potentially dangerous characters where appropriate

**JSON validation:**

For JSONB columns, use JSON Schema validation:

```sql
CREATE TABLE settings (
  id UUID PRIMARY KEY,
  config JSONB NOT NULL,
  CONSTRAINT valid_config CHECK (
    jsonb_typeof(config->'timeout') = 'number'
    AND (config->>'timeout')::int BETWEEN 1 AND 3600
  )
);
```

## SQL Injection Prevention

SQL injection occurs when untrusted input is concatenated into SQL queries, allowing attackers to manipulate query logic. Supabase's architecture provides strong protection against SQL injection when used correctly.

**How Supabase prevents SQL injection:**

PostgREST and Supabase client libraries use parameterized queries exclusively. User input is never directly concatenated into SQL statements. All filters, values, and parameters are passed as bound parameters, which PostgreSQL treats as data, not executable code.

**Safe query examples:**

Using Supabase client library (JavaScript):

```javascript
// Safe - parameters are bound, not concatenated
const { data, error } = await supabase
  .from('users')
  .select('*')
  .eq('email', userInput); // userInput is safely parameterized

// Safe - insertion with bound values
const { data, error } = await supabase
  .from('posts')
  .insert({ 
    title: userTitle,  // Safely parameterized
    content: userContent 
  });
```

**Unsafe patterns to avoid:**

When writing custom database functions or using direct SQL:

```sql
-- UNSAFE - vulnerable to SQL injection
CREATE FUNCTION search_users(search_term TEXT)
RETURNS SETOF users AS $$
BEGIN
  RETURN QUERY EXECUTE 
    'SELECT * FROM users WHERE name LIKE ''%' || search_term || '%''';
  -- If search_term contains SQL, it will execute
END;
$$ LANGUAGE plpgsql;
```

**Safe function implementation:**

```sql
-- SAFE - uses parameterized query
CREATE FUNCTION search_users(search_term TEXT)
RETURNS SETOF users AS $$
BEGIN
  RETURN QUERY 
    SELECT * FROM users 
    WHERE name ILIKE '%' || search_term || '%';
  -- Concatenation here is safe; search_term is treated as data
END;
$$ LANGUAGE plpgsql;
```

For dynamic SQL when necessary, use `EXECUTE` with `USING`:

```sql
CREATE FUNCTION dynamic_query(table_name TEXT, search_value TEXT)
RETURNS TABLE(result JSONB) AS $$
BEGIN
  -- Validate table_name against whitelist first
  IF table_name NOT IN ('users', 'posts', 'comments') THEN
    RAISE EXCEPTION 'Invalid table name';
  END IF;
  
  RETURN QUERY EXECUTE 
    format('SELECT row_to_json(t) FROM %I AS t WHERE name = $1', table_name)
  USING search_value;  -- Safely bound parameter
END;
$$ LANGUAGE plpgsql;
```

**Protection layers:**

- **Client libraries**: Automatically parameterize all queries
- **PostgREST**: Converts REST API calls to parameterized PostgreSQL queries
- **Row Level Security**: Even if injection were possible, RLS limits accessible data
- **Database functions**: Write secure functions using parameterized queries
- **Input validation**: Validate and constrain input before it reaches the database

**Direct database access:**

If connecting directly to PostgreSQL (not through Supabase APIs), always use parameterized queries:

```javascript
// Node.js with pg library - Safe
const result = await pool.query(
  'SELECT * FROM users WHERE email = $1',
  [userEmail]  // Parameterized
);

// UNSAFE - never do this
const result = await pool.query(
  `SELECT * FROM users WHERE email = '${userEmail}'`
);
```

**Best practices:**

- Always use Supabase client libraries or PostgREST API for queries
- Never construct SQL strings by concatenating user input
- If writing custom database functions, use parameters or `EXECUTE ... USING`
- Validate and whitelist dynamic identifiers (table names, column names) when absolutely necessary
- Apply principle of least privilege through RLS and database roles
- Regularly audit custom SQL code for injection vulnerabilities

[Inference: While Supabase's architecture makes SQL injection extremely difficult through normal usage, custom database functions and direct database connections require careful implementation]

## XSS Protection

Cross-Site Scripting (XSS) attacks inject malicious scripts into web applications, potentially stealing user data, session tokens, or performing unauthorized actions. XSS protection requires careful handling of user-generated content in your frontend application.

**Supabase's role:**

Supabase stores data as-is without modification and returns exactly what was stored. The database does not automatically sanitize or escape content. XSS protection is primarily a frontend responsibility, though database design can support security measures.

**Frontend protection strategies:**

**Framework-native escaping:**

Modern frameworks provide automatic XSS protection:

```javascript
// React - automatically escapes by default
function UserProfile({ user }) {
  return (
    <div>
      <h1>{user.name}</h1>  {/* Automatically escaped */}
      <p>{user.bio}</p>      {/* Automatically escaped */}
    </div>
  );
}

// Vue - automatically escapes
<template>
  <div>
    <h1>{{ user.name }}</h1>  <!-- Automatically escaped -->
    <p>{{ user.bio }}</p>      <!-- Automatically escaped -->
  </div>
</template>
```

**Dangerous HTML rendering:**

When you must render HTML content, use sanitization libraries:

```javascript
import DOMPurify from 'dompurify';

function ArticleContent({ article }) {
  // Sanitize before rendering
  const sanitizedHTML = DOMPurify.sanitize(article.html_content, {
    ALLOWED_TAGS: ['p', 'b', 'i', 'em', 'strong', 'a', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: ['href', 'title']
  });
  
  return (
    <div dangerouslySetInnerHTML={{ __html: sanitizedHTML }} />
  );
}
```

**Content Security Policy (CSP):**

Implement CSP headers to restrict script execution:

```html
<!-- In your HTML head or via server headers -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' https://trusted-cdn.com;
               style-src 'self' 'unsafe-inline';
               img-src 'self' data: https:;">
```

**Input sanitization at storage:**

While XSS protection happens at rendering, you can sanitize on storage as defense-in-depth:

```javascript
import DOMPurify from 'dompurify';

// Sanitize before storing
const sanitizedContent = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p'],
  ALLOWED_ATTR: ['href']
});

await supabase
  .from('posts')
  .insert({ content: sanitizedContent });
```

**Attribute-based attacks:**

Be cautious with user-controlled attributes:

```javascript
// UNSAFE - user can inject javascript: URLs
<a href={userProvidedURL}>Link</a>

// SAFE - validate URL scheme
function SafeLink({ url, children }) {
  const isSafe = url.startsWith('http://') || url.startsWith('https://');
  const safeUrl = isSafe ? url : '#';
  
  return <a href={safeUrl}>{children}</a>;
}
```

**Database patterns supporting XSS protection:**

Store content type metadata:

```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  content TEXT NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('plaintext', 'markdown', 'html')),
  -- Store original + sanitized versions
  content_raw TEXT,
  content_sanitized TEXT
);
```

**Markdown over HTML:**

When possible, accept Markdown instead of raw HTML and render with a safe parser:

```javascript
import ReactMarkdown from 'react-markdown';

function Post({ post }) {
  return (
    <ReactMarkdown>
      {post.markdown_content}
    </ReactMarkdown>
  );
}
```

**Protection checklist:**

- Never use `dangerouslySetInnerHTML`, `v-html`, or equivalent without sanitization
- Always sanitize user-generated HTML with DOMPurify or similar
- Implement Content Security Policy headers
- Validate and whitelist URL schemes for user-provided links
- Use framework-native escaping for dynamic content
- Prefer Markdown or plain text over HTML when possible
- Escape content in attributes (`title`, `alt`, etc.)
- Be especially careful with user-controlled JavaScript event handlers

**Session token protection:**

Store authentication tokens securely to prevent XSS-based theft:

```javascript
// Supabase handles this automatically, storing tokens in httpOnly contexts
// [Inference: Exact storage mechanism may vary by client library and platform]

// Don't store sensitive tokens in localStorage if XSS risk exists
// Prefer httpOnly cookies or secure framework-managed storage
```

## CORS Configuration

Cross-Origin Resource Sharing (CORS) controls which domains can access your Supabase API from browsers. Proper CORS configuration prevents unauthorized websites from making requests to your backend.

**Default behavior:**

[Unverified: Supabase's default CORS configuration] likely allows requests from any origin for the REST API when using the anon key. This enables rapid development but should be restricted for production applications.

**Configuring allowed origins:**

In your Supabase project dashboard under Settings > API, configure allowed origins:

- Development: `http://localhost:3000`, `http://localhost:5173`
- Production: `https://yourdomain.com`, `https://app.yourdomain.com`
- Wildcards: Use cautiously, like `https://*.yourdomain.com` for subdomains

**CORS headers:**

When configured, Supabase returns appropriate headers:

```
Access-Control-Allow-Origin: https://yourdomain.com
Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: authorization, x-client-info, apikey, content-type
Access-Control-Max-Age: 86400
```

**Security implications:**

**Overly permissive CORS** (allowing all origins with `*`) can expose your API:

- Malicious websites can make authenticated requests if users have valid sessions
- Data can be exfiltrated from users' browsers
- CSRF-like attacks become possible

**Restrictive CORS** limits attack surface by ensuring only your trusted domains can access the API.

**Multiple domains:**

For applications across multiple domains (e.g., marketing site and app):

```
Allowed origins:
- https://www.mysite.com
- https://app.mysite.com  
- https://admin.mysite.com
```

**Mobile and native applications:**

Mobile apps don't encounter CORS restrictions as CORS is a browser-specific security mechanism. React Native, Flutter, and native mobile apps can call Supabase APIs without CORS configuration. However, the anon key should still be protected through RLS policies.

**Edge Functions and CORS:**

For custom Edge Functions, manually configure CORS headers:

```javascript
// Edge Function with CORS
Deno.serve(async (req) => {
  // Handle preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': 'https://yourdomain.com',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    });
  }
  
  // Process request
  const data = await processRequest(req);
  
  // Return with CORS headers
  return new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': 'https://yourdomain.com',
    },
  });
});
```

**Development vs production:**

Use environment-specific configurations:

- **Development**: Allow `localhost` with various ports
- **Staging**: Allow staging domain only
- **Production**: Allow production domains only

Avoid using wildcard origins in production environments.

**Testing CORS:**

Test CORS configuration by making requests from different origins:

```javascript
// From browser console on unauthorized domain
fetch('https://your-project.supabase.co/rest/v1/users', {
  headers: {
    'apikey': 'your-anon-key'
  }
})
.then(r => console.log('Success:', r))
.catch(e => console.log('Blocked by CORS:', e));
```

**Best practices:**

- Explicitly list allowed origins rather than using wildcards
- Restrict to HTTPS origins in production (not `http://`)
- Regularly audit and remove unused origins
- Use environment variables for origin configuration across environments
- Remember CORS is defense-in-depth, not primary security (rely on authentication and RLS)
- Document why each origin is allowed

## Rate Limiting

Rate limiting prevents abuse, protects infrastructure, and ensures fair resource allocation across users.

**Built-in rate limits:**

Supabase implements rate limiting at multiple layers:

**API request limits [Unverified - specific values may vary by plan]:**

- REST API requests per minute per IP address
- Realtime connection limits per project
- Authentication operations per hour
- Storage API operations per second

**Plan-based limits:**

- **Free tier**: Lower limits suitable for development and small projects
- **Pro tier**: Higher limits with burst capacity
- **Team/Enterprise**: Custom limits negotiated based on needs

**Rate limit response:**

When exceeded, the API returns:

```
HTTP/1.1 429 Too Many Requests
Content-Type: application/json

{
  "message": "API rate limit exceeded",
  "hint": "Retry after some time"
}
```

Response headers indicate current status:

```
X-RateLimit-Limit: 500
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1640000060
Retry-After: 60
```

**Application-level rate limiting:**

Implement additional rate limiting in Edge Functions:

```javascript
// Simple in-memory rate limiter (for single-instance Edge Functions)
const rateLimits = new Map();

function checkRateLimit(userId, maxRequests = 10, windowMs = 60000) {
  const now = Date.now();
  const userLimits = rateLimits.get(userId) || { count: 0, resetTime: now + windowMs };
  
  // Reset if window expired
  if (now > userLimits.resetTime) {
    userLimits.count = 0;
    userLimits.resetTime = now + windowMs;
  }
  
  userLimits.count++;
  rateLimits.set(userId, userLimits);
  
  if (userLimits.count > maxRequests) {
    return {
      allowed: false,
      retryAfter: Math.ceil((userLimits.resetTime - now) / 1000)
    };
  }
  
  return { allowed: true };
}
```

**Database-level rate limiting:**

Track and limit actions using database tables:

```sql
CREATE TABLE rate_limits (
  user_id UUID NOT NULL,
  action TEXT NOT NULL,
  count INTEGER NOT NULL DEFAULT 1,
  window_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, action, window_start)
);

CREATE FUNCTION check_rate_limit(
  p_user_id UUID,
  p_action TEXT,
  p_max_requests INTEGER,
  p_window_interval INTERVAL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Clean old windows
  DELETE FROM rate_limits
  WHERE window_start < NOW() - p_window_interval;
  
  -- Get current count
  SELECT COALESCE(SUM(count), 0) INTO v_count
  FROM rate_limits
  WHERE user_id = p_user_id
    AND action = p_action
    AND window_start >= NOW() - p_window_interval;
  
  -- Check limit
  IF v_count >= p_max_requests THEN
    RETURN FALSE;
  END IF;
  
  -- Increment count
  INSERT INTO rate_limits (user_id, action, window_start, count)
  VALUES (p_user_id, p_action, DATE_TRUNC('minute', NOW()), 1)
  ON CONFLICT (user_id, action, window_start)
  DO UPDATE SET count = rate_limits.count + 1;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

**Client-side strategies:**

**Exponential backoff:**

```javascript
async function fetchWithRetry(fetchFn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const result = await fetchFn();
      return result;
    } catch (error) {
      if (error.status === 429) {
        const retryAfter = error.headers?.['retry-after'] || Math.pow(2, i);
        await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
        continue;
      }
      throw error;
    }
  }
  throw new Error('Max retries exceeded');
}
```

**Request throttling:**

```javascript
// Throttle requests using a queue
class RequestQueue {
  constructor(maxRequestsPerSecond) {
    this.queue = [];
    this.processing = false;
    this.interval = 1000 / maxRequestsPerSecond;
  }
  
  async enqueue(request) {
    return new Promise((resolve, reject) => {
      this.queue.push({ request, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.processing || this.queue.length === 0) return;
    
    this.processing = true;
    const { request, resolve, reject } = this.queue.shift();
    
    try {
      const result = await request();
      resolve(result);
    } catch (error) {
      reject(error);
    }
    
    setTimeout(() => {
      this.processing = false;
      this.process();
    }, this.interval);
  }
}
```

**Mitigation strategies:**

- Cache frequently accessed data client-side
- Use Realtime subscriptions instead of polling
- Batch operations when possible
- Implement pagination for large datasets
- Use efficient queries with proper filtering and selection
- Upgrade to higher-tier plans for increased limits
- Distribute load across multiple API keys for microservices [Inference: This may violate terms of service; verify documentation]

**Monitoring:**

Track rate limit headers in your application:

```javascript
const { data, error } = await supabase.from('users').select('*');

// Check response headers (if accessible in your client library)
const remaining = response.headers['x-ratelimit-remaining'];
const resetTime = response.headers['x-ratelimit-reset'];

if (remaining < 10) {
  console.warn('Approaching rate limit');
}
```

## Audit Logging

Audit logging tracks who accessed what data and when, providing accountability, security monitoring, and compliance support.

**Database-level audit logging:**

Create audit tables to track data changes:

```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data JSONB,
  new_data JSONB,
  user_id UUID,
  ip_address INET,
  user_agent TEXT,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for common queries
CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_user ON audit_log(user_id, timestamp DESC);
CREATE INDEX idx_audit_log_timestamp ON audit_log(timestamp DESC);
```

**Automatic audit triggers:**

```sql
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log (table_name, record_id, action, new_data, user_id)
    VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', to_jsonb(NEW), auth.uid());
    RETURN NEW;
    
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, user_id)
    VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), auth.uid());
    RETURN NEW;
    
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (table_name, record_id, action, old_data, user_id)
    VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', to_jsonb(OLD), auth.uid());
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply to sensitive tables
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_financial_records
AFTER INSERT OR UPDATE OR DELETE ON transactions
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
```

**Selective field auditing:**

For tables with sensitive data, audit only specific fields:

```sql
CREATE FUNCTION audit_sensitive_fields()
RETURNS TRIGGER AS $$
DECLARE
  old_sensitive JSONB;
  new_sensitive JSONB;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    -- Only log changes to sensitive fields
    old_sensitive := jsonb_build_object(
      'email', OLD.email,
      'phone', OLD.phone,
      'ssn', OLD.ssn
    );
    new_sensitive := jsonb_build_object(
      'email', NEW.email,
      'phone', NEW.phone,
      'ssn', NEW.ssn
    );
    
    -- Only insert if sensitive fields changed
    IF old_sensitive IS DISTINCT FROM new_sensitive THEN
      INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, user_id)
      VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', old_sensitive, new_sensitive, auth.uid());
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Authentication event logging:**

Track authentication events:

```sql
CREATE TABLE auth_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  event_type TEXT NOT NULL CHECK (event_type IN (
    'login', 'logout', 'signup', 'password_reset', 
    'password_change', 'failed_login', 'mfa_enabled', 'mfa_disabled'
)),
  ip_address INET,
  user_agent TEXT,
  success BOOLEAN NOT NULL,
  error_message TEXT,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_auth_audit_user ON auth_audit_log(user_id, timestamp DESC);
CREATE INDEX idx_auth_audit_event ON auth_audit_log(event_type, timestamp DESC);
CREATE INDEX idx_auth_audit_failed ON auth_audit_log(success, timestamp DESC) WHERE success = FALSE;
```

**Capturing request metadata:**

Use Edge Functions to log API access with additional context:

```javascript
// Edge Function with audit logging
Deno.serve(async (req) => {
  const startTime = Date.now();
  const user = await getUserFromRequest(req);
  const ipAddress = req.headers.get('x-forwarded-for') || 
                    req.headers.get('x-real-ip');
  const userAgent = req.headers.get('user-agent');
  
  try {
    // Process request
    const result = await processRequest(req, user);
    
    // Log successful access
    await logAuditEvent({
      userId: user?.id,
      action: 'api_access',
      resource: new URL(req.url).pathname,
      success: true,
      ipAddress,
      userAgent,
      responseTime: Date.now() - startTime
    });
    
    return new Response(JSON.stringify(result));
  } catch (error) {
    // Log failed access
    await logAuditEvent({
      userId: user?.id,
      action: 'api_access',
      resource: new URL(req.url).pathname,
      success: false,
      errorMessage: error.message,
      ipAddress,
      userAgent,
      responseTime: Date.now() - startTime
    });
    
    throw error;
  }
});
```

**Read access logging:**

Since triggers don't fire on SELECT, implement read logging through functions:

```sql
CREATE FUNCTION get_sensitive_record(record_id UUID)
RETURNS TABLE (/* columns */) AS $$
BEGIN
  -- Log the access
  INSERT INTO audit_log (table_name, record_id, action, user_id)
  VALUES ('sensitive_data', record_id, 'SELECT', auth.uid());
  
  -- Return the data
  RETURN QUERY
  SELECT * FROM sensitive_data WHERE id = record_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Audit log retention:**

Implement retention policies to manage audit log size:

```sql
-- Archive old audit logs
CREATE TABLE audit_log_archive (
  LIKE audit_log INCLUDING ALL
);

-- Partition by time for efficient archiving
CREATE TABLE audit_log_2024_q1 PARTITION OF audit_log
  FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- Function to archive old logs
CREATE FUNCTION archive_old_audit_logs(older_than INTERVAL)
RETURNS INTEGER AS $$
DECLARE
  rows_archived INTEGER;
BEGIN
  WITH archived AS (
    DELETE FROM audit_log
    WHERE timestamp < NOW() - older_than
    RETURNING *
  )
  INSERT INTO audit_log_archive
  SELECT * FROM archived;
  
  GET DIAGNOSTICS rows_archived = ROW_COUNT;
  RETURN rows_archived;
END;
$$ LANGUAGE plpgsql;

-- Schedule with pg_cron (if available)
-- SELECT cron.schedule('archive-audit-logs', '0 2 * * 0', 
--   'SELECT archive_old_audit_logs(''1 year'')');
```

**Querying audit logs:**

Useful audit queries:

```sql
-- Recent changes to specific record
SELECT * FROM audit_log
WHERE table_name = 'users' AND record_id = 'specific-uuid'
ORDER BY timestamp DESC;

-- All actions by specific user
SELECT 
  table_name,
  action,
  timestamp,
  new_data
FROM audit_log
WHERE user_id = 'user-uuid'
ORDER BY timestamp DESC;

-- Failed authentication attempts
SELECT 
  user_id,
  ip_address,
  COUNT(*) as attempts,
  MAX(timestamp) as last_attempt
FROM auth_audit_log
WHERE event_type = 'failed_login'
  AND timestamp > NOW() - INTERVAL '1 hour'
GROUP BY user_id, ip_address
HAVING COUNT(*) > 5;

-- Data access patterns
SELECT 
  user_id,
  table_name,
  COUNT(*) as access_count,
  COUNT(DISTINCT record_id) as unique_records
FROM audit_log
WHERE action = 'SELECT'
  AND timestamp > NOW() - INTERVAL '24 hours'
GROUP BY user_id, table_name
ORDER BY access_count DESC;
```

**Performance considerations:**

- Use asynchronous logging to avoid slowing down main operations [Inference: May require background jobs or message queues]
- Implement table partitioning for large audit tables
- Index frequently queried columns (user_id, timestamp, table_name)
- Archive old logs to separate tables
- Consider storing audit logs in separate database for critical systems
- Summarize old audit data rather than keeping full details indefinitely

**Compliance requirements:**

Different regulations require specific audit capabilities:

- **GDPR**: Log access to personal data, data exports, deletions
- **HIPAA**: Track all access to protected health information
- **SOC 2**: Comprehensive logging of security-relevant events
- **PCI DSS**: Log access to cardholder data with retention requirements

**Security for audit logs:**

Protect audit logs themselves:

```sql
-- Restrict access to audit logs
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only admins can view audit logs"
ON audit_log FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- Prevent modification of audit logs
CREATE POLICY "No one can modify audit logs"
ON audit_log FOR UPDATE
USING (false);

CREATE POLICY "No one can delete audit logs"
ON audit_log FOR DELETE
USING (false);

-- Make audit trigger function SECURITY DEFINER to bypass RLS
-- Already shown in audit_trigger_function above
```

## Secrets Management

Secrets management involves securely storing, accessing, and rotating sensitive credentials, API keys, and configuration values.

**What qualifies as secrets:**

- Database connection strings
- Service role API keys
- Third-party API keys (Stripe, SendGrid, AWS)
- Encryption keys
- OAuth client secrets
- Webhook signing secrets
- Private keys and certificates

**Never store in:**

- Version control (Git repositories)
- Client-side code
- Unencrypted database columns
- Application logs
- Error messages
- URL parameters

**Environment variables:**

The primary method for managing secrets in applications:

```bash
# .env file (never commit this)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
STRIPE_SECRET_KEY=sk_live_...
SENDGRID_API_KEY=SG....

# .env.example file (commit this as template)
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
STRIPE_SECRET_KEY=
```

**Accessing environment variables:**

```javascript
// Node.js
const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Validate presence
if (!serviceRoleKey) {
  throw new Error('SUPABASE_SERVICE_ROLE_KEY not configured');
}
```

**.gitignore configuration:**

```
# .gitignore
.env
.env.local
.env.*.local
*.key
*.pem
secrets/
```

**Secrets management services:**

For production environments, use dedicated secrets management:

**AWS Secrets Manager:**

```javascript
import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

async function getSecret(secretName) {
  const client = new SecretsManagerClient({ region: "us-east-1" });
  const response = await client.send(
    new GetSecretValueCommand({ SecretId: secretName })
  );
  return JSON.parse(response.SecretString);
}

const secrets = await getSecret('prod/supabase/credentials');
const supabase = createClient(secrets.url, secrets.serviceRoleKey);
```

**HashiCorp Vault:**

```javascript
import vault from 'node-vault';

const client = vault({
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN
});

const { data } = await client.read('secret/data/supabase');
const serviceRoleKey = data.data.service_role_key;
```

**Cloud platform secrets:**

```javascript
// Google Cloud Secret Manager
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

const client = new SecretManagerServiceClient();
const [version] = await client.accessSecretVersion({
  name: 'projects/PROJECT_ID/secrets/supabase-key/versions/latest',
});
const secret = version.payload.data.toString();

// Azure Key Vault
import { SecretClient } from "@azure/keyvault-secrets";
import { DefaultAzureCredential } from "@azure/identity";

const credential = new DefaultAzureCredential();
const client = new SecretClient(vaultUrl, credential);
const secret = await client.getSecret("supabase-service-key");
```

**Edge Functions secrets:**

Supabase Edge Functions support environment variables:

```javascript
// Set in Supabase dashboard or CLI
// Access in Edge Function:
Deno.serve(async (req) => {
  const apiKey = Deno.env.get('THIRD_PARTY_API_KEY');
  
  if (!apiKey) {
    return new Response('Configuration error', { status: 500 });
  }
  
  // Use the secret
  const response = await fetch('https://api.example.com/data', {
    headers: { 'Authorization': `Bearer ${apiKey}` }
  });
  
  return response;
});
```

**Database encryption for sensitive data:**

For secrets that must be stored in the database:

```sql
-- Install pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Store encrypted data
CREATE TABLE api_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  service_name TEXT NOT NULL,
  encrypted_key BYTEA NOT NULL,  -- Encrypted API key
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Encryption function
CREATE FUNCTION encrypt_api_key(api_key TEXT, encryption_key TEXT)
RETURNS BYTEA AS $$
  SELECT pgp_sym_encrypt(api_key, encryption_key);
$$ LANGUAGE SQL;

-- Decryption function
CREATE FUNCTION decrypt_api_key(encrypted_data BYTEA, encryption_key TEXT)
RETURNS TEXT AS $$
  SELECT pgp_sym_decrypt(encrypted_data, encryption_key);
$$ LANGUAGE SQL;

-- Usage
INSERT INTO api_credentials (user_id, service_name, encrypted_key)
VALUES (
  auth.uid(),
  'stripe',
  encrypt_api_key('sk_live_...', current_setting('app.encryption_key'))
);
```

**Key rotation:**

Implement regular secret rotation:

```javascript
// Automated key rotation example
async function rotateApiKey() {
  // Generate new key
  const newKey = await generateNewApiKey();
  
  // Update in secrets manager
  await secretsManager.updateSecret({
    SecretId: 'prod/api-key',
    SecretString: newKey
  });
  
  // Update in Supabase if stored there
  await supabase
    .from('service_configs')
    .update({ api_key_version: 'v2', updated_at: new Date() })
    .eq('service', 'third_party');
  
  // Notify monitoring
  await notifyKeyRotation('third_party', 'v2');
  
  // Schedule old key deprecation (allow grace period)
  await scheduleOldKeyDeprecation('v1', 7); // 7 days
}
```

**Accessing secrets in CI/CD:**

```yaml
# GitHub Actions example
name: Deploy
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to production
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          SUPABASE_DB_PASSWORD: ${{ secrets.SUPABASE_DB_PASSWORD }}
        run: |
          npx supabase db push
```

**Best practices:**

- Use different secrets for each environment (dev, staging, production)
- Implement least privilege - grant minimal necessary access
- Rotate secrets regularly (quarterly or after personnel changes)
- Audit secret access and usage
- Never log secrets or include in error messages
- Use short-lived tokens when possible
- Implement secret expiration policies
- Monitor for exposed secrets in code repositories (use tools like GitGuardian, TruffleHog)
- Encrypt secrets at rest and in transit
- Document secret ownership and rotation procedures

**Emergency revocation:**

Have procedures for immediate secret revocation:

```javascript
async function emergencyRevocation(secretId) {
  // Immediately disable the compromised secret
  await secretsManager.putSecretValue({
    SecretId: secretId,
    SecretString: 'REVOKED'
  });
  
  // Generate and deploy new secret
  const newSecret = await generateNewSecret();
  await deployNewSecret(newSecret);
  
  // Notify security team
  await alertSecurityTeam({
    severity: 'critical',
    secret: secretId,
    action: 'revoked',
    timestamp: new Date()
  });
  
  // Log incident
  await logSecurityIncident({
    type: 'secret_compromise',
    secretId,
    revocationTime: new Date()
  });
}
```

## Secure File Uploads

File uploads introduce security risks including malware distribution, unauthorized access, storage abuse, and code execution vulnerabilities.

**Supabase Storage security:**

Supabase Storage provides built-in security features:

- **Authentication required**: Files are protected by RLS policies
- **Size limits**: Configurable maximum file sizes
- **MIME type validation**: Restrict allowed file types
- **Public vs private buckets**: Control access patterns

**Creating secure buckets:**

```javascript
// Create a private bucket
const { data, error } = await supabase
  .storage
  .createBucket('user-documents', {
    public: false,  // Requires authentication
    fileSizeLimit: 52428800,  // 50MB limit
    allowedMimeTypes: ['application/pdf', 'image/jpeg', 'image/png']
  });
```

**Storage RLS policies:**

Apply Row Level Security to storage objects:

```sql
-- Policy: Users can only upload to their own folder
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user-documents'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can only read their own files
CREATE POLICY "Users can view own files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'user-documents'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can delete their own files
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'user-documents'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Public read for avatar bucket
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

**Client-side upload validation:**

```javascript
async function secureUpload(file, userId) {
  // Validate file size (5MB limit)
  const maxSize = 5 * 1024 * 1024;
  if (file.size > maxSize) {
    throw new Error('File too large. Maximum size is 5MB.');
  }
  
  // Validate file type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
  if (!allowedTypes.includes(file.type)) {
    throw new Error('Invalid file type. Only images and PDFs allowed.');
  }
  
  // Validate file extension matches MIME type
  const extension = file.name.split('.').pop().toLowerCase();
  const mimeToExt = {
    'image/jpeg': ['jpg', 'jpeg'],
    'image/png': ['png'],
    'image/gif': ['gif'],
    'application/pdf': ['pdf']
  };
  
  const validExtensions = mimeToExt[file.type] || [];
  if (!validExtensions.includes(extension)) {
    throw new Error('File extension does not match file type.');
  }
  
  // Generate safe filename
  const timestamp = Date.now();
  const randomString = Math.random().toString(36).substring(7);
  const safeFilename = `${userId}/${timestamp}-${randomString}.${extension}`;
  
  // Upload to Supabase Storage
  const { data, error } = await supabase.storage
    .from('user-documents')
    .upload(safeFilename, file, {
      cacheControl: '3600',
      upsert: false
    });
  
  if (error) throw error;
  
  return data;
}
```

**Server-side validation with Edge Functions:**

```javascript
// Edge Function for server-side validation
import { createClient } from '@supabase/supabase-js';

Deno.serve(async (req) => {
  const formData = await req.formData();
  const file = formData.get('file');
  
  if (!file) {
    return new Response('No file provided', { status: 400 });
  }
  
  // Read file header to verify actual file type (magic bytes)
  const buffer = await file.arrayBuffer();
  const bytes = new Uint8Array(buffer);
  
  // Check file signature (magic bytes)
  const signatures = {
    'image/jpeg': [[0xFF, 0xD8, 0xFF]],
    'image/png': [[0x89, 0x50, 0x4E, 0x47]],
    'application/pdf': [[0x25, 0x50, 0x44, 0x46]]
  };
  
  let validSignature = false;
  for (const [mimeType, sigs] of Object.entries(signatures)) {
    for (const sig of sigs) {
      if (sig.every((byte, i) => bytes[i] === byte)) {
        validSignature = true;
        break;
      }
    }
  }
  
  if (!validSignature) {
    return new Response('Invalid file type', { status: 400 });
  }
  
  // Proceed with upload
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL'),
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  );
  
  const filename = `verified/${crypto.randomUUID()}`;
  const { data, error } = await supabase.storage
    .from('secure-uploads')
    .upload(filename, buffer, {
      contentType: file.type
    });
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
  
  return new Response(JSON.stringify({ path: data.path }), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```

**Malware scanning:**

[Inference: Supabase doesn't include built-in malware scanning; this requires external integration]

```javascript
// Integration with malware scanning service
async function scanAndUpload(file, userId) {
  // Upload to temporary location
  const tempPath = `temp/${crypto.randomUUID()}`;
  await supabase.storage
    .from('temp-uploads')
    .upload(tempPath, file);
  
  // Get download URL
  const { data: { publicUrl } } = supabase.storage
    .from('temp-uploads')
    .getPublicUrl(tempPath);
  
  // Scan with external service (e.g., VirusTotal, ClamAV)
  const scanResult = await scanFile(publicUrl);
  
  if (scanResult.malicious) {
    // Delete infected file
    await supabase.storage
      .from('temp-uploads')
      .remove([tempPath]);
    
    throw new Error('File failed security scan');
  }
  
  // Move to permanent location
  const finalPath = `${userId}/${Date.now()}-${file.name}`;
  await supabase.storage
    .from('user-documents')
    .move(`temp-uploads/${tempPath}`, `user-documents/${finalPath}`);
  
  return finalPath;
}
```

**Image processing and sanitization:**

```javascript
// Process images to strip metadata and resize
import sharp from 'sharp';

async function processAndUploadImage(file, userId) {
  const buffer = await file.arrayBuffer();
  
  // Process image: resize, strip metadata, convert format
  const processed = await sharp(buffer)
    .resize(1920, 1080, { fit: 'inside', withoutEnlargement: true })
    .jpeg({ quality: 85 })  // Convert to JPEG
    .withMetadata(false)    // Strip EXIF data
    .toBuffer();
  
  const filename = `${userId}/${Date.now()}.jpg`;
  
  const { data, error } = await supabase.storage
    .from('images')
    .upload(filename, processed, {
      contentType: 'image/jpeg',
      cacheControl: '3600'
    });
  
  return data;
}
```

**Preventing path traversal:**

```javascript
// Sanitize filenames to prevent path traversal
function sanitizeFilename(filename) {
  // Remove path separators and special characters
  return filename
    .replace(/[^a-zA-Z0-9.-]/g, '_')  // Replace special chars
    .replace(/\.+/g, '.')             // Prevent multiple dots
    .substring(0, 255);               // Limit length
}

// Use with user-provided filenames
const userFilename = sanitizeFilename(file.name);
const securePath = `${userId}/${Date.now()}-${userFilename}`;
```

**Quota management:**

```sql
-- Track user storage usage
CREATE TABLE storage_quotas (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  bytes_used BIGINT NOT NULL DEFAULT 0,
  bytes_limit BIGINT NOT NULL DEFAULT 1073741824,  -- 1GB default
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to check and update quota
CREATE FUNCTION check_storage_quota(
  p_user_id UUID,
  p_file_size BIGINT
)
RETURNS BOOLEAN AS $$
DECLARE
  v_quota RECORD;
BEGIN
  SELECT * INTO v_quota
  FROM storage_quotas
  WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    -- Create default quota
    INSERT INTO storage_quotas (user_id, bytes_used)
    VALUES (p_user_id, 0);
    v_quota.bytes_used := 0;
    v_quota.bytes_limit := 1073741824;
  END IF;
  
  -- Check if upload would exceed quota
  IF v_quota.bytes_used + p_file_size > v_quota.bytes_limit THEN
    RETURN FALSE;
  END IF;
  
  -- Update usage
  UPDATE storage_quotas
  SET bytes_used = bytes_used + p_file_size,
      updated_at = NOW()
  WHERE user_id = p_user_id;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

**Secure file serving:**

```javascript
// Generate temporary signed URLs
async function getSecureFileUrl(filePath, expiresIn = 3600) {
  const { data, error } = await supabase.storage
    .from('user-documents')
    .createSignedUrl(filePath, expiresIn);
  
  if (error) throw error;
  
  return data.signedUrl;  // URL expires after specified time
}

// Verify user has access before generating URL
async function getFileForUser(filePath, userId) {
  // Check ownership
  const [folderUserId] = filePath.split('/');
  
  if (folderUserId !== userId) {
    throw new Error('Unauthorized access');
  }
  
  return await getSecureFileUrl(filePath);
}
```

**Content Disposition headers:**

Prevent XSS through file downloads:

```javascript
// Set Content-Disposition to force download
const { data, error } = await supabase.storage
  .from('user-documents')
  .download(filePath, {
    download: true  // Forces download instead of inline display
  });
```

**Best practices:**

- Always validate file types on server-side (client validation can be bypassed)
- Use magic byte detection, not just file extensions or MIME types
- Implement file size limits appropriate to your use case
- Store files with generated names, not user-provided names
- Scan uploaded files for malware when handling user content
- Strip metadata from images (can contain sensitive information)
- Use signed URLs with expiration for private files
- Implement storage quotas per user or organization
- Separate upload location from serving location
- Use Content-Disposition headers to control how files are handled
- Log all upload and access activities
- Regularly audit and clean up unused files

---

**Key related topics:**

- **Database Backups & Recovery** - protecting data through automated backups
- **Supabase Auth Configuration** - securing authentication flows and user management
- **Network Security** - SSL/TLS configuration and secure connections
- **Compliance Frameworks** - implementing GDPR, HIPAA, SOC 2 requirements
- **Incident Response** - procedures for handling security breaches

---

# Testing in Supabase

Testing Supabase applications requires validating database functions, security policies, client integrations, and serverless functions to ensure data integrity and correct application behavior.

## Unit Testing Database Functions

Database functions contain business logic that must be tested in isolation to verify correct behavior across different inputs and edge cases.

### Testing Setup with pgTAP

```sql
-- Enable pgTAP extension
CREATE EXTENSION IF NOT EXISTS pgtap;

-- Create test schema
CREATE SCHEMA IF NOT EXISTS tests;
```

### Basic Function Tests

```sql
-- Function to test
CREATE OR REPLACE FUNCTION calculate_order_total(order_id bigint)
RETURNS numeric AS $$
  SELECT COALESCE(SUM(quantity * price), 0)
  FROM order_items
  WHERE order_id = calculate_order_total.order_id;
$$ LANGUAGE sql;

-- Test function
CREATE OR REPLACE FUNCTION tests.test_calculate_order_total()
RETURNS SETOF TEXT AS $$
BEGIN
  -- Setup test data
  INSERT INTO orders (id, customer_id) VALUES (999, 1);
  INSERT INTO order_items (order_id, product_id, quantity, price)
  VALUES 
    (999, 1, 2, 10.00),
    (999, 2, 3, 15.00);

  -- Test calculation
  RETURN NEXT is(
    calculate_order_total(999),
    65.00::numeric,
    'Order total should be 65.00'
  );

  -- Test empty order
  INSERT INTO orders (id, customer_id) VALUES (998, 1);
  RETURN NEXT is(
    calculate_order_total(998),
    0::numeric,
    'Empty order should return 0'
  );

  -- Cleanup
  DELETE FROM order_items WHERE order_id IN (999, 998);
  DELETE FROM orders WHERE id IN (999, 998);
END;
$$ LANGUAGE plpgsql;

-- Run test
SELECT * FROM runtests('tests'::name);
```

### Testing Function Return Types

```sql
CREATE OR REPLACE FUNCTION tests.test_function_signature()
RETURNS SETOF TEXT AS $$
BEGIN
  RETURN NEXT has_function(
    'public',
    'calculate_order_total',
    ARRAY['bigint'],
    'Function calculate_order_total should exist'
  );

  RETURN NEXT function_returns(
    'public',
    'calculate_order_total',
    ARRAY['bigint'],
    'numeric',
    'Function should return numeric'
  );
END;
$$ LANGUAGE plpgsql;
```

### Testing Error Handling

```sql
CREATE OR REPLACE FUNCTION divide_numbers(a numeric, b numeric)
RETURNS numeric AS $$
BEGIN
  IF b = 0 THEN
    RAISE EXCEPTION 'Division by zero';
  END IF;
  RETURN a / b;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tests.test_divide_numbers()
RETURNS SETOF TEXT AS $$
BEGIN
  -- Test normal operation
  RETURN NEXT is(
    divide_numbers(10, 2),
    5::numeric,
    'Should divide correctly'
  );

  -- Test error condition
  RETURN NEXT throws_ok(
    'SELECT divide_numbers(10, 0)',
    'P0001',
    'Division by zero',
    'Should raise exception for division by zero'
  );
END;
$$ LANGUAGE plpgsql;
```

### Testing with Node.js and Jest

```javascript
// supabase.test.js
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

describe('Database Functions', () => {
  beforeAll(async () => {
    // Setup test data
    await supabase.from('orders').insert({ id: 999, customer_id: 1 })
    await supabase.from('order_items').insert([
      { order_id: 999, product_id: 1, quantity: 2, price: 10.00 },
      { order_id: 999, product_id: 2, quantity: 3, price: 15.00 }
    ])
  })

  afterAll(async () => {
    // Cleanup
    await supabase.from('order_items').delete().eq('order_id', 999)
    await supabase.from('orders').delete().eq('id', 999)
  })

  test('calculate_order_total returns correct sum', async () => {
    const { data, error } = await supabase
      .rpc('calculate_order_total', { order_id: 999 })
    
    expect(error).toBeNull()
    expect(data).toBe(65.00)
  })

  test('calculate_order_total handles empty orders', async () => {
    await supabase.from('orders').insert({ id: 998, customer_id: 1 })
    
    const { data, error } = await supabase
      .rpc('calculate_order_total', { order_id: 998 })
    
    expect(error).toBeNull()
    expect(data).toBe(0)
    
    await supabase.from('orders').delete().eq('id', 998)
  })
})
```

### Testing Complex Functions with Transactions

```javascript
describe('Transaction Functions', () => {
  test('create_order_with_items handles rollback', async () => {
    const { data, error } = await supabase.rpc('create_order_with_items', {
      customer_id: 1,
      items: [
        { product_id: 999999, quantity: 1, price: 10 } // Invalid product
      ]
    })
    
    expect(error).not.toBeNull()
    
    // Verify no partial data was created
    const { data: orders } = await supabase
      .from('orders')
      .select()
      .eq('customer_id', 1)
      .order('created_at', { ascending: false })
      .limit(1)
    
    // [Inference] Assuming the order was not created due to transaction rollback
    expect(orders.length).toBe(0)
  })
})
```

## Testing RLS Policies

Row Level Security policies enforce access control at the database level and require thorough testing to prevent security vulnerabilities.

### RLS Policy Structure

```sql
-- Example policies
CREATE POLICY "Users can view own data"
ON profiles FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
ON profiles FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all data"
ON profiles FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);
```

### Testing RLS with pgTAP

```sql
CREATE OR REPLACE FUNCTION tests.test_rls_user_isolation()
RETURNS SETOF TEXT AS $$
DECLARE
  user1_id uuid := gen_random_uuid();
  user2_id uuid := gen_random_uuid();
BEGIN
  -- Setup test data
  INSERT INTO profiles (user_id, name) VALUES
    (user1_id, 'User 1'),
    (user2_id, 'User 2');

  -- Test as user1
  PERFORM set_config('request.jwt.claims', json_build_object('sub', user1_id)::text, true);
  
  RETURN NEXT is(
    (SELECT COUNT(*) FROM profiles WHERE user_id = user1_id),
    1::bigint,
    'User should see own profile'
  );

  RETURN NEXT is(
    (SELECT COUNT(*) FROM profiles WHERE user_id = user2_id),
    0::bigint,
    'User should not see other profiles'
  );

  -- Cleanup
  DELETE FROM profiles WHERE user_id IN (user1_id, user2_id);
END;
$$ LANGUAGE plpgsql;
```

### Testing RLS with JavaScript

```javascript
// rls.test.js
import { createClient } from '@supabase/supabase-js'

describe('RLS Policies', () => {
  let user1Client, user2Client
  let user1, user2

  beforeAll(async () => {
    // Create test users
    const adminClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    )

    const { data: userData1 } = await adminClient.auth.admin.createUser({
      email: 'user1@test.com',
      password: 'password123',
      email_confirm: true
    })
    user1 = userData1.user

    const { data: userData2 } = await adminClient.auth.admin.createUser({
      email: 'user2@test.com',
      password: 'password123',
      email_confirm: true
    })
    user2 = userData2.user

    // Create authenticated clients
    user1Client = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )
    await user1Client.auth.signInWithPassword({
      email: 'user1@test.com',
      password: 'password123'
    })

    user2Client = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )
    await user2Client.auth.signInWithPassword({
      email: 'user2@test.com',
      password: 'password123'
    })

    // Insert test data
    await user1Client.from('profiles').insert({
      user_id: user1.id,
      name: 'User 1'
    })
    await user2Client.from('profiles').insert({
      user_id: user2.id,
      name: 'User 2'
    })
  })

  afterAll(async () => {
    const adminClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    )
    await adminClient.auth.admin.deleteUser(user1.id)
    await adminClient.auth.admin.deleteUser(user2.id)
  })

  test('users can only view own profiles', async () => {
    const { data, error } = await user1Client
      .from('profiles')
      .select()
    
    expect(error).toBeNull()
    expect(data).toHaveLength(1)
    expect(data[0].user_id).toBe(user1.id)
  })

  test('users cannot update other profiles', async () => {
    const { error } = await user1Client
      .from('profiles')
      .update({ name: 'Hacked' })
      .eq('user_id', user2.id)
    
    expect(error).not.toBeNull()
    
    // Verify data unchanged
    const { data } = await user2Client
      .from('profiles')
      .select()
      .eq('user_id', user2.id)
      .single()
    
    expect(data.name).toBe('User 2')
  })

  test('users can update own profile', async () => {
    const { error } = await user1Client
      .from('profiles')
      .update({ name: 'Updated Name' })
      .eq('user_id', user1.id)
    
    expect(error).toBeNull()
    
    const { data } = await user1Client
      .from('profiles')
      .select()
      .eq('user_id', user1.id)
      .single()
    
    expect(data.name).toBe('Updated Name')
  })
})
```

### Testing Role-Based Policies

```javascript
describe('Role-Based RLS', () => {
  let adminClient, userClient

  beforeAll(async () => {
    // Setup admin and regular user
    const serviceClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    )

    // Create admin user
    const { data: adminData } = await serviceClient.auth.admin.createUser({
      email: 'admin@test.com',
      password: 'password123',
      email_confirm: true,
      user_metadata: { role: 'admin' }
    })

    adminClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )
    await adminClient.auth.signInWithPassword({
      email: 'admin@test.com',
      password: 'password123'
    })

    // Create regular user
    const { data: userData } = await serviceClient.auth.admin.createUser({
      email: 'user@test.com',
      password: 'password123',
      email_confirm: true
    })

    userClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )
    await userClient.auth.signInWithPassword({
      email: 'user@test.com',
      password: 'password123'
    })
  })

  test('admin can view all profiles', async () => {
    const { data, error } = await adminClient
      .from('profiles')
      .select()
    
    expect(error).toBeNull()
    expect(data.length).toBeGreaterThan(1)
  })

  test('regular user cannot view all profiles', async () => {
    const { data, error } = await userClient
      .from('profiles')
      .select()
    
    // Should only see own profile
    expect(data.length).toBe(1)
  })
})
```

### Testing Anonymous Access

```javascript
test('anonymous users cannot access protected data', async () => {
  const anonClient = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  )

  const { data, error } = await anonClient
    .from('profiles')
    .select()
  
  expect(data).toEqual([])
})

test('public data is accessible anonymously', async () => {
  const anonClient = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  )

  const { data, error } = await anonClient
    .from('public_posts')
    .select()
  
  expect(error).toBeNull()
  expect(data.length).toBeGreaterThan(0)
})
```

## Integration Testing with Supabase

Integration tests verify the complete flow of operations across database, authentication, and client interactions.

### Test Environment Setup

```javascript
// test-config.js
export const testConfig = {
  supabaseUrl: process.env.SUPABASE_TEST_URL,
  supabaseAnonKey: process.env.SUPABASE_TEST_ANON_KEY,
  supabaseServiceKey: process.env.SUPABASE_TEST_SERVICE_KEY
}

// test-helpers.js
import { createClient } from '@supabase/supabase-js'
import { testConfig } from './test-config'

export const createTestClient = () => {
  return createClient(testConfig.supabaseUrl, testConfig.supabaseAnonKey)
}

export const createAdminClient = () => {
  return createClient(testConfig.supabaseUrl, testConfig.supabaseServiceKey)
}

export const cleanupTestData = async (tableName, filters = {}) => {
  const admin = createAdminClient()
  let query = admin.from(tableName).delete()
  
  Object.entries(filters).forEach(([key, value]) => {
    query = query.eq(key, value)
  })
  
  await query
}
```

### End-to-End Flow Testing

```javascript
// integration.test.js
import { createTestClient, createAdminClient, cleanupTestData } from './test-helpers'

describe('Order Creation Flow', () => {
  let client, admin, testUser

  beforeAll(async () => {
    client = createTestClient()
    admin = createAdminClient()

    // Create test user
    const { data } = await admin.auth.admin.createUser({
      email: 'test@example.com',
      password: 'testpass123',
      email_confirm: true
    })
    testUser = data.user

    // Sign in
    await client.auth.signInWithPassword({
      email: 'test@example.com',
      password: 'testpass123'
    })
  })

  afterAll(async () => {
    await cleanupTestData('order_items', { order_id: 999 })
    await cleanupTestData('orders', { id: 999 })
    await admin.auth.admin.deleteUser(testUser.id)
  })

  test('complete order creation and retrieval', async () => {
    // Step 1: Create order
    const { data: order, error: orderError } = await client
      .from('orders')
      .insert({
        id: 999,
        customer_id: testUser.id,
        status: 'pending'
      })
      .select()
      .single()

    expect(orderError).toBeNull()
    expect(order.id).toBe(999)

    // Step 2: Add order items
    const { data: items, error: itemsError } = await client
      .from('order_items')
      .insert([
        { order_id: 999, product_id: 1, quantity: 2, price: 10.00 },
        { order_id: 999, product_id: 2, quantity: 1, price: 20.00 }
      ])
      .select()

    expect(itemsError).toBeNull()
    expect(items).toHaveLength(2)

    // Step 3: Calculate total
    const { data: total, error: totalError } = await client
      .rpc('calculate_order_total', { order_id: 999 })

    expect(totalError).toBeNull()
    expect(total).toBe(40.00)

    // Step 4: Retrieve order with items
    const { data: fullOrder, error: fetchError } = await client
      .from('orders')
      .select(`
        *,
        order_items (
          product_id,
          quantity,
          price
        )
      `)
      .eq('id', 999)
      .single()

    expect(fetchError).toBeNull()
    expect(fullOrder.order_items).toHaveLength(2)
  })
})
```

### Testing Real-time Subscriptions

```javascript
describe('Real-time Subscriptions', () => {
  test('receives insert notifications', async (done) => {
    const client = createTestClient()
    let receivedData = null

    const channel = client
      .channel('test-channel')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages'
        },
        (payload) => {
          receivedData = payload.new
        }
      )
      .subscribe()

    // Wait for subscription to be ready
    await new Promise(resolve => setTimeout(resolve, 1000))

    // Insert test data
    await client.from('messages').insert({
      content: 'Test message',
      user_id: testUser.id
    })

    // Wait for notification
    await new Promise(resolve => setTimeout(resolve, 2000))

    expect(receivedData).not.toBeNull()
    expect(receivedData.content).toBe('Test message')

    await channel.unsubscribe()
    done()
  }, 10000)
})
```

### Testing File Storage

```javascript
describe('Storage Operations', () => {
  const bucketName = 'test-bucket'
  
  beforeAll(async () => {
    const admin = createAdminClient()
    await admin.storage.createBucket(bucketName, { public: false })
  })

  afterAll(async () => {
    const admin = createAdminClient()
    const { data: files } = await admin.storage.from(bucketName).list()
    await Promise.all(
      files.map(file => admin.storage.from(bucketName).remove([file.name]))
    )
    await admin.storage.deleteBucket(bucketName)
  })

  test('upload and download file', async () => {
    const client = createTestClient()
    const fileName = 'test-file.txt'
    const fileContent = 'Hello, Supabase!'

    // Upload
    const { error: uploadError } = await client.storage
      .from(bucketName)
      .upload(fileName, new Blob([fileContent], { type: 'text/plain' }))

    expect(uploadError).toBeNull()

    // Download
    const { data, error: downloadError } = await client.storage
      .from(bucketName)
      .download(fileName)

    expect(downloadError).toBeNull()
    const text = await data.text()
    expect(text).toBe(fileContent)
  })

  test('respects storage policies', async () => {
    const client = createTestClient()
    
    // Attempt to access another user's file
    const { error } = await client.storage
      .from(bucketName)
      .download('unauthorized-file.txt')

    expect(error).not.toBeNull()
  })
})
```

## Mocking Supabase Client

Mocking the Supabase client enables fast unit tests without database dependencies and allows testing error scenarios.

### Jest Mock Setup

```javascript
// __mocks__/@supabase/supabase-js.js
export const createClient = jest.fn(() => ({
  from: jest.fn(() => ({
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn(),
  })),
  auth: {
    signInWithPassword: jest.fn(),
    signUp: jest.fn(),
    signOut: jest.fn(),
    getSession: jest.fn(),
  },
  rpc: jest.fn(),
  storage: {
    from: jest.fn(() => ({
      upload: jest.fn(),
      download: jest.fn(),
      remove: jest.fn(),
    })),
  },
}))
```

### Using Mocks in Tests

```javascript
// service.test.js
jest.mock('@supabase/supabase-js')
import { createClient } from '@supabase/supabase-js'
import { UserService } from './user-service'

describe('UserService', () => {
  let mockSupabase
  let userService

  beforeEach(() => {
    mockSupabase = createClient()
    userService = new UserService(mockSupabase)
  })

  afterEach(() => {
    jest.clearAllMocks()
  })

  test('getUserById returns user data', async () => {
    const mockUser = { id: 1, name: 'John Doe', email: 'john@example.com' }
    
    mockSupabase.from().select().eq().single.mockResolvedValue({
      data: mockUser,
      error: null
    })

    const result = await userService.getUserById(1)

    expect(mockSupabase.from).toHaveBeenCalledWith('users')
    expect(mockSupabase.from().select).toHaveBeenCalled()
    expect(mockSupabase.from().eq).toHaveBeenCalledWith('id', 1)
    expect(result).toEqual(mockUser)
  })

  test('getUserById handles errors', async () => {
    const mockError = { message: 'User not found' }
    
    mockSupabase.from().select().eq().single.mockResolvedValue({
      data: null,
      error: mockError
    })

    await expect(userService.getUserById(999)).rejects.toThrow('User not found')
  })
})
```

### Manual Mock Implementation

```javascript
// supabase-mock.js
export class SupabaseMock {
  constructor() {
    this.data = {
      users: [],
      orders: [],
    }
  }

  from(table) {
    return {
      select: (columns = '*') => ({
        eq: (column, value) => ({
          single: async () => {
            const item = this.data[table].find(row => row[column] === value)
            return { data: item || null, error: item ? null : { message: 'Not found' } }
          },
          then: async (resolve) => {
            const items = this.data[table].filter(row => row[column] === value)
            resolve({ data: items, error: null })
          }
        }),
        then: async (resolve) => {
          resolve({ data: this.data[table], error: null })
        }
      }),
      insert: (rows) => ({
        select: () => ({
          then: async (resolve) => {
            const newRows = Array.isArray(rows) ? rows : [rows]
            this.data[table].push(...newRows)
            resolve({ data: newRows, error: null })
          }
        })
      }),
      update: (updates) => ({
        eq: (column, value) => ({
          then: async (resolve) => {
            this.data[table] = this.data[table].map(row =>
              row[column] === value ? { ...row, ...updates } : row
            )
            resolve({ data: null, error: null })
          }
        })
      }),
      delete: () => ({
        eq: (column, value) => ({
          then: async (resolve) => {
            this.data[table] = this.data[table].filter(row => row[column] !== value)
            resolve({ data: null, error: null })
          }
        })
      })
    }
  }

  reset() {
    Object.keys(this.data).forEach(key => {
      this.data[key] = []
    })
  }
}
```

### Using Manual Mock

```javascript
import { SupabaseMock } from './supabase-mock'

describe('UserService with Manual Mock', () => {
  let supabase
  let userService

  beforeEach(() => {
    supabase = new SupabaseMock()
    supabase.data.users = [
      { id: 1, name: 'John Doe', email: 'john@example.com' },
      { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
    ]
    userService = new UserService(supabase)
  })

  test('getAllUsers returns all users', async () => {
    const users = await userService.getAllUsers()
    expect(users).toHaveLength(2)
  })

  test('createUser adds new user', async () => {
    await userService.createUser({
      id: 3,
      name: 'Bob Johnson',
      email: 'bob@example.com'
    })

    expect(supabase.data.users).toHaveLength(3)
    expect(supabase.data.users[2].name).toBe('Bob Johnson')
  })
})
```

## Test Database Setup

A dedicated test database ensures tests run in isolation without affecting production or development data.

### Local Test Database with Docker

```yaml
# docker-compose.test.yml
version: '3.8'
services:
  postgres:
    image: supabase/postgres:15.1.0.117
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "54322:5432"
    volumes:
      - ./test-migrations:/docker-entrypoint-initdb.d
```

```bash
# Start test database
docker-compose -f docker-compose.test.yml up -d

# Run migrations
psql -h localhost -p 54322 -U postgres -d test_db -f migrations/001_initial.sql
```

### Supabase CLI Test Project

```bash
# Initialize local Supabase project
supabase init

# Start local instance
supabase start

# Apply migrations
supabase db push

# Get connection details
supabase status
```

```javascript
// test-setup.js
import { createClient } from '@supabase/supabase-js'
import { execSync } from 'child_process'

export const setupTestDatabase = async () => {
  // Reset database
  execSync('supabase db reset --local', { stdio: 'inherit' })

  // Create client
  const supabase = createClient(
    process.env.SUPABASE_LOCAL_URL || 'http://localhost:54321',
    process.env.SUPABASE_LOCAL_ANON_KEY
  )

  return supabase
}

// jest.setup.js
beforeAll(async () => {
  global.supabase = await setupTestDatabase()
})
```

### Database Snapshots

```javascript
// snapshot.js
import { execSync } from 'child_process'
import fs from 'fs'

export class DatabaseSnapshot {
  constructor(connectionString) {
    this.connectionString = connectionString
    this.snapshotPath = './test-snapshots'
  }

  async create(name) {
    if (!fs.existsSync(this.snapshotPath)) {
      fs.mkdirSync(this.snapshotPath)
    }

    execSync(
      `pg_dump ${this.connectionString} > ${this.snapshotPath}/${name}.sql`,
      { stdio: 'inherit' }
    )
  }

  async restore(name) {
    execSync(
      `psql ${this.connectionString} < ${this.snapshotPath}/${name}.sql`,
      { stdio: 'inherit' }
    )
  }
}
```

```javascript
// Usage in tests
import { DatabaseSnapshot } from './snapshot'

describe('Test Suite with Snapshots', () => {
  const snapshot = new DatabaseSnapshot(process.env.TEST_DATABASE_URL)

  beforeAll(async () => {
    await snapshot.create('clean-state')
  })

  afterEach(async () => {
    await snapshot.restore('clean-state')
  })

  // Tests here
})
```

### Isolated Test Transactions

```javascript
// transaction-wrapper.js
export const withTransaction = async (supabase, testFn) => {
  const { data, error } = await supabase.rpc('begin_test_transaction')
  
  try {
    await testFn(supabase)
  } finally {
    await supabase.rpc('rollback_test_transaction')
  }
}
```

```sql
-- Transaction management functions
CREATE OR REPLACE FUNCTION begin_test_transaction()
RETURNS void AS $$
BEGIN
  -- Create savepoint
  EXECUTE 'SAVEPOINT test_transaction';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rollback_test_transaction()
RETURNS void AS $$
BEGIN
  -- Rollback to savepoint
  EXECUTE 'ROLLBACK TO SAVEPOINT test_transaction';
END;
$$ LANGUAGE plpgsql;
```

## Seed Data Management

Seed data provides consistent test fixtures and ensures reproducible test conditions.

### SQL Seed Files

```sql
-- seeds/test-data.sql
-- Clear existing data
TRUNCATE users, orders, order_items CASCADE;

-- Insert test users
INSERT INTO users (id, email, name, role) VALUES
  (1, 'admin@test.com', 'Admin User', 'admin'),
  (2, 'user@test.com', 'Regular User', 'user'),
  (3, 'test@test.com', 'Test User', 'user');

-- Insert test orders
INSERT INTO orders (id, user_id, status, total, created_at) VALUES
  (1, 2, 'completed', 100.00, '2025-01-01'),
  (2, 2, 'pending', 50.00, '2025-01-15'),
  (3, 3, 'completed', 75.00, '2025-02-01');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
  (1, 1, 2, 25.00),
  (1, 2, 2, 25.00),
  (2, 1, 1, 25.00),
  (2, 3, 1, 25.00),
  (3, 2, 3, 25.00);

-- Insert test products
INSERT INTO products (id, name, price, category, stock) VALUES
  (1, 'Product A', 25.00, 'electronics', 100),
  (2, 'Product B', 25.00, 'books', 50),
  (3, 'Product C', 25.00, 'electronics', 75);
```

### JavaScript Seed Functions

```javascript
// seeds/seed-data.js
export const seedUsers = async (supabase) => {
  const users = [
    { id: 1, email: 'admin@test.com', name: 'Admin User', role: 'admin' },
    { id: 2, email: 'user@test.com', name: 'Regular User', role: 'user' },
    { id: 3, email: 'test@test.com', name: 'Test User', role: 'user' }
  ]

  const { error } = await supabase.from('users').insert(users)
  if (error) throw error
  
  return users
}

export const seedOrders = async (supabase, userIds) => {
  const orders = [
    { id: 1, user_id: userIds[1], status: 'completed', total: 100.00 },
    { id: 2, user_id: userIds[1], status: 'pending', total: 50.00 },
    { id: 3, user_id: userIds[2], status: 'completed', total: 75.00 }
  ]

  const { error } = await supabase.from('orders').insert(orders)
  if (error) throw error
  
  return orders
}

export const seedProducts = async (supabase) => {
  const products = [
    { id: 1, name: 'Product A', price: 25.00, category: 'electronics', stock: 100 },
    { id: 2, name: 'Product B', price: 25.00, category: 'books', stock: 50 },
    { id: 3, name: 'Product C', price: 25.00, category: 'electronics', stock: 75 }
  ]

  const { error } = await supabase.from('products').insert(products)
  if (error) throw error
  
  return products
}

export const seedAll = async (supabase) => {
  const users = await seedUsers(supabase)
  const products = await seedProducts(supabase)
  const orders = await seedOrders(supabase, users.map(u => u.id))
  
  return { users, products, orders }
}
```

### Factory Pattern for Test Data

```javascript
// factories/user.factory.js
import { faker } from '@faker-js/faker'

export class UserFactory {
  static create(overrides = {}) {
    return {
      id: faker.number.int(),
      email: faker.internet.email(),
      name: faker.person.fullName(),
      role: 'user',
      created_at: faker.date.past(),
      ...overrides
    }
  }

  static createMany(count, overrides = {}) {
    return Array.from({ length: count }, () => this.create(overrides))
  }

  static async insert(supabase, overrides = {}) {
    const user = this.create(overrides)
    const { data, error } = await supabase
      .from('users')
      .insert(user)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  static async insertMany(supabase, count, overrides = {}) {
    const users = this.createMany(count, overrides)
    const { data, error } = await supabase
      .from('users')
      .insert(users)
      .select()
    
    if (error) throw error
    return data
  }
}
```

```javascript
// factories/order.factory.js
import { faker } from '@faker-js/faker'

export class OrderFactory {
  static create(overrides = {}) {
    return {
      id: faker.number.int(),
      user_id: overrides.user_id || 1,
      status: faker.helpers.arrayElement(['pending', 'completed', 'cancelled']),
      total: parseFloat(faker.commerce.price()),
      created_at: faker.date.past(),
      ...overrides
    }
  }

  static async insert(supabase, overrides = {}) {
    const order = this.create(overrides)
    const { data, error } = await supabase
      .from('orders')
      .insert(order)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  static async createWithItems(supabase, userId, itemCount = 3) {
    const order = await this.insert(supabase, { user_id: userId })
    
    const items = Array.from({ length: itemCount }, () => ({
      order_id: order.id,
      product_id: faker.number.int({ min: 1, max: 100 }),
      quantity: faker.number.int({ min: 1, max: 5 }),
      price: parseFloat(faker.commerce.price())
    }))

    const { data: orderItems, error } = await supabase
      .from('order_items')
      .insert(items)
      .select()

    if (error) throw error
    
    return { ...order, items: orderItems }
  }
}
```

### Using Factories in Tests

```javascript
import { UserFactory } from './factories/user.factory'
import { OrderFactory } from './factories/order.factory'

describe('Order Service', () => {
  let testUser, testOrders

  beforeEach(async () => {
    // Create test user with factory
    testUser = await UserFactory.insert(supabase, {
      email: 'test@example.com',
      role: 'user'
    })

    // Create multiple test orders
    testOrders = await Promise.all([
      OrderFactory.insert(supabase, { user_id: testUser.id, status: 'completed' }),
      OrderFactory.insert(supabase, { user_id: testUser.id, status: 'pending' }),
      OrderFactory.insert(supabase, { user_id: testUser.id, status: 'cancelled' })
    ])
  })

  afterEach(async () => {
    await supabase.from('order_items').delete().in('order_id', testOrders.map(o => o.id))
    await supabase.from('orders').delete().in('id', testOrders.map(o => o.id))
    await supabase.from('users').delete().eq('id', testUser.id)
  })

  test('getUserOrders returns correct orders', async () => {
    const orders = await orderService.getUserOrders(testUser.id)
    expect(orders).toHaveLength(3)
  })
})
```

### Seed Data Builder Pattern

```javascript
// seed-builder.js
export class SeedBuilder {
  constructor(supabase) {
    this.supabase = supabase
    this.cleanup = []
  }

  async withUser(data = {}) {
    const user = await UserFactory.insert(this.supabase, data)
    this.cleanup.push({ table: 'users', id: user.id })
    return user
  }

  async withOrder(userId, data = {}) {
    const order = await OrderFactory.insert(this.supabase, { 
      user_id: userId, 
      ...data 
    })
    this.cleanup.push({ table: 'orders', id: order.id })
    return order
  }

  async withProduct(data = {}) {
    const product = await ProductFactory.insert(this.supabase, data)
    this.cleanup.push({ table: 'products', id: product.id })
    return product
  }

  async destroy() {
    // Delete in reverse order to respect foreign keys
    for (const item of this.cleanup.reverse()) {
      await this.supabase.from(item.table).delete().eq('id', item.id)
    }
    this.cleanup = []
  }
}
```

```javascript
// Usage
describe('Complex Scenario', () => {
  let seed

  beforeEach(() => {
    seed = new SeedBuilder(supabase)
  })

  afterEach(async () => {
    await seed.destroy()
  })

  test('full order flow', async () => {
    const user = await seed.withUser({ email: 'buyer@test.com' })
    const product = await seed.withProduct({ name: 'Test Product', price: 50.00 })
    const order = await seed.withOrder(user.id, { status: 'pending' })

    // Test logic here
  })
})
```

## CI/CD Integration

Continuous integration ensures tests run automatically on every code change, maintaining code quality and catching issues early.

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  SUPABASE_URL: ${{ secrets.SUPABASE_TEST_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_TEST_ANON_KEY }}
  SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_TEST_SERVICE_KEY }}

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: supabase/postgres:15.1.0.117
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
        with:
          version: latest

      - name: Start Supabase local
        run: supabase start

      - name: Run database migrations
        run: supabase db push

      - name: Seed test database
        run: npm run seed:test

      - name: Run unit tests
        run: npm run test:unit

      - name: Run integration tests
        run: npm run test:integration

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
          flags: unittests
          name: codecov-umbrella

      - name: Stop Supabase
        if: always()
        run: supabase stop
```

### GitLab CI Configuration

```yaml
# .gitlab-ci.yml
variables:
  POSTGRES_DB: test_db
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres
  POSTGRES_HOST_AUTH_METHOD: trust

stages:
  - setup
  - test
  - cleanup

before_script:
  - npm ci

services:
  - postgres:15

setup_database:
  stage: setup
  image: supabase/postgres:15.1.0.117
  script:
    - psql -h postgres -U postgres -d test_db -f migrations/001_initial.sql
    - psql -h postgres -U postgres -d test_db -f seeds/test-data.sql
  only:
    - merge_requests
    - main

unit_tests:
  stage: test
  image: node:18
  script:
    - npm run test:unit -- --coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

integration_tests:
  stage: test
  image: node:18
  services:
    - postgres:15
  variables:
    DATABASE_URL: postgresql://postgres:postgres@postgres:5432/test_db
  script:
    - npm run test:integration
  dependencies:
    - setup_database

e2e_tests:
  stage: test
  image: node:18
  services:
    - postgres:15
  script:
    - npm run test:e2e
  dependencies:
    - setup_database
  only:
    - merge_requests
    - main

cleanup:
  stage: cleanup
  script:
    - echo "Cleaning up test resources"
  when: always
```

### CircleCI Configuration

```yaml
# .circleci/config.yml
version: 2.1

orbs:
  node: circleci/node@5.0.2

jobs:
  test:
    docker:
      - image: cimg/node:18.16
      - image: supabase/postgres:15.1.0.117
        environment:
          POSTGRES_DB: test_db
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres

    steps:
      - checkout
      
      - node/install-packages:
          pkg-manager: npm

      - run:
          name: Wait for database
          command: |
            dockerize -wait tcp://localhost:5432 -timeout 1m

      - run:
          name: Run migrations
          command: |
            psql -h localhost -U postgres -d test_db -f migrations/001_initial.sql

      - run:
          name: Seed database
          command: npm run seed:test

      - run:
          name: Run tests
          command: npm run test:ci

      - store_test_results:
          path: test-results

      - store_artifacts:
          path: coverage

workflows:
  test_and_deploy:
    jobs:
      - test:
          filters:
            branches:
              only:
                - main
                - develop
```

### Package.json Test Scripts

```json
{
  "scripts": {
    "test": "jest",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "test:e2e": "jest --testPathPattern=e2e",
    "test:ci": "jest --ci --coverage --maxWorkers=2",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "seed:test": "node scripts/seed-test-db.js",
    "db:reset": "supabase db reset --local",
    "db:setup": "npm run db:reset && npm run seed:test"
  }
}
```

### Pre-commit Hooks

```yaml
# .husky/pre-commit
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npm run test:unit
```

```json
// package.json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "jest --bail --findRelatedTests"
    ]
  }
}
```

### Docker Compose for CI

```yaml
# docker-compose.ci.yml
version: '3.8'

services:
  postgres:
    image: supabase/postgres:15.1.0.117
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  test-runner:
    build: .
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://postgres:postgres@postgres:5432/test_db
      SUPABASE_URL: ${SUPABASE_URL}
      SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY}
    command: npm run test:ci
```

## Testing Edge Functions

Edge Functions are serverless functions deployed to Supabase's edge network, requiring specialized testing approaches.

### Edge Function Structure

```typescript
// supabase/functions/hello/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { name } = await req.json()
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    const { data, error } = await supabase
      .from('greetings')
      .insert({ name, message: `Hello, ${name}!` })
      .select()
      .single()

    if (error) throw error

    return new Response(
      JSON.stringify(data),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

### Local Edge Function Testing

```typescript
// supabase/functions/hello/index.test.ts
import { assertEquals } from 'https://deno.land/std@0.168.0/testing/asserts.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || 'http://localhost:54321'
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') || 'your-anon-key'

Deno.test('hello function returns greeting', async () => {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/hello`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    },
    body: JSON.stringify({ name: 'World' })
  })

  const data = await response.json()
  
  assertEquals(response.status, 200)
  assertEquals(data.message, 'Hello, World!')
})

Deno.test('hello function handles missing name', async () => {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/hello`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    },
    body: JSON.stringify({})
  })

  assertEquals(response.status, 400)
})
```

### Running Edge Function Tests

```bash
# Start Supabase locally
supabase start

# Serve function locally
supabase functions serve hello --env-file .env.local

# Run tests
deno test --allow-net --allow-env supabase/functions/hello/index.test.ts
```

### Mocking Edge Function Dependencies

```typescript
// supabase/functions/_shared/supabase-mock.ts
export class SupabaseMock {
  private mockData: Record<string, any[]> = {}

  from(table: string) {
    return {
      insert: (data: any) => ({
        select: () => ({
          single: async () => {
            const record = Array.isArray(data) ? data[0] : data
            this.mockData[table] = this.mockData[table] || []
            this.mockData[table].push(record)
            return { data: record, error: null }
          }
        })
      }),
      select: () => ({
        eq: (column: string, value: any) => ({
          single: async () => {
            const items = this.mockData[table] || []
            const item = items.find(i => i[column] === value)
            return { data: item || null, error: item ? null : { message: 'Not found' } }
          }
        })
      })
    }
  }

  reset() {
    this.mockData = {}
  }
}
```

### Integration Testing Edge Functions

```javascript
// tests/edge-functions.test.js
import { createClient } from '@supabase/supabase-js'

describe('Edge Functions Integration', () => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  )

  test('hello function creates database record', async () => {
    const { data, error } = await supabase.functions.invoke('hello', {
      body: { name: 'Test User' }
    })

    expect(error).toBeNull()
    expect(data.message).toBe('Hello, Test User!')

    // Verify database record
    const { data: greeting } = await supabase
      .from('greetings')
      .select()
      .eq('name', 'Test User')
      .single()

    expect(greeting).not.toBeNull()
    expect(greeting.message).toBe('Hello, Test User!')

    // Cleanup
    await supabase.from('greetings').delete().eq('name', 'Test User')
  })

  test('authenticated function requires auth', async () => {
    const anonClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )

    const { error } = await anonClient.functions.invoke('protected-function')

    expect(error).not.toBeNull()
    expect(error.message).toContain('auth')
  })
})
```

### Testing Edge Function Authorization

```typescript
// supabase/functions/protected/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response(
      JSON.stringify({ error: 'Authorization required' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } }
    )
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    {
      global: {
        headers: { Authorization: authHeader }
      }
    }
  )

  const { data: { user }, error } = await supabase.auth.getUser()

  if (error || !user) {
    return new Response(
      JSON.stringify({ error: 'Invalid token' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } }
    )
  }

  return new Response(
    JSON.stringify({ message: `Hello, ${user.email}!` }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

```typescript
// Test with authentication
Deno.test('protected function requires valid JWT', async () => {
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

  // Sign in test user
  const { data: authData } = await supabase.auth.signInWithPassword({
    email: 'test@example.com',
    password: 'testpass123'
  })

  const response = await fetch(`${SUPABASE_URL}/functions/v1/protected`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${authData.session.access_token}`
    }
  })

  assertEquals(response.status, 200)
})
```

### Edge Function CI/CD

```yaml
# .github/workflows/edge-functions.yml
name: Edge Functions Tests

on:
  push:
    paths:
      - 'supabase/functions/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Deno
        uses: denoland/setup-deno@v1
        with:
          deno-version: v1.x

      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1

      - name: Start Supabase
        run: supabase start

      - name: Run Edge Function tests
        run: |
          for func in supabase/functions/*/index.test.ts; do
            deno test --allow-all "$func"
          done

      - name: Deploy Edge Functions
        if: github.ref == 'refs/heads/main'
        run: |
          supabase functions deploy
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          SUPABASE_PROJECT_ID: ${{ secrets.SUPABASE_PROJECT_ID }}
```

**Key Points:**

- Unit tests validate database functions using pgTAP in PostgreSQL or Jest/Vitest in JavaScript
- RLS policy testing requires creating authenticated test clients and verifying access controls across different user contexts
- Integration tests verify complete workflows including database operations, authentication, and real-time features
- Mocking the Supabase client enables fast unit tests without database dependencies
- Dedicated test databases with Docker or Supabase CLI provide isolation from production environments
- Seed data through SQL files, JavaScript functions, or factory patterns ensures consistent test fixtures
- CI/CD pipelines automate test execution on GitHub Actions, GitLab CI, or CircleCI
- Edge Functions require Deno-based testing with local serving and deployment validation

**Important subtopics to explore:**

- Performance testing and load testing strategies
- Visual regression testing for UI components
- Contract testing for API boundaries
- Snapshot testing for data structures
- Test coverage analysis and reporting
- Security testing and penetration testing approaches

---

# Migrations & Version Control

Database migrations in Supabase provide systematic, version-controlled approaches to evolving database schemas over time. They enable teams to track, apply, and reverse database changes while maintaining data integrity across development, staging, and production environments. Supabase uses SQL-based migrations managed through the CLI, integrating with Git workflows for collaborative development.

## Database Migration Strategies

Migration strategies determine how database schema changes are planned, tested, and deployed across environments. Effective strategies balance safety, reversibility, and team coordination.

**Migration-first development:**

Changes to database schema begin as migration files rather than manual SQL execution. This ensures all modifications are tracked, reviewable, and reproducible. Every schema change—whether adding tables, modifying columns, or adjusting constraints—should exist as a migration file committed to version control.

**Incremental vs. comprehensive migrations:**

Incremental migrations apply small, focused changes in sequence. Each migration handles a single logical change (adding one table, modifying one column). This approach simplifies debugging and rollback but creates more migration files over time.

Comprehensive migrations group related changes into single migration files. This reduces the total number of migrations but makes individual changes harder to isolate and reverse.

**Development workflow patterns:**

Create migrations locally using `supabase migration new migration-name`. This generates a timestamped SQL file in `supabase/migrations/`. Write the schema changes, test locally using `supabase db reset` to apply all migrations to a fresh database, then commit the migration file to version control.

**Environment progression:**

Migrations flow through environments: local development → staging → production. Each environment maintains its own migration history table tracking which migrations have been applied. The `supabase db push` command applies pending migrations to remote databases.

**Zero-downtime strategies:**

For production systems requiring continuous availability, implement migrations in phases:

1. **Additive phase**: Add new columns/tables without removing old ones
2. **Dual-write phase**: Application writes to both old and new structures
3. **Migration phase**: Backfill data from old to new structures
4. **Switchover phase**: Application reads from new structures
5. **Cleanup phase**: Remove old structures in subsequent migration

**Example zero-downtime migration:**

```sql
-- Migration 1: Add new column (additive)
ALTER TABLE users ADD COLUMN email_normalized TEXT;

-- Migration 2: Backfill data
UPDATE users SET email_normalized = LOWER(TRIM(email));

-- Migration 3: Add constraint and index
ALTER TABLE users ALTER COLUMN email_normalized SET NOT NULL;
CREATE UNIQUE INDEX idx_users_email_normalized ON users(email_normalized);

-- Migration 4: Remove old column (cleanup, after application updated)
-- ALTER TABLE users DROP COLUMN email;
```

**Testing strategies:**

Test migrations in isolation before deployment. Use `supabase db reset` to rebuild your local database from scratch, verifying migrations apply cleanly. Create seed data to validate schema changes don't break expected data patterns.

**Documentation practices:**

Include comments in migration files explaining the purpose and any special considerations:

```sql
-- Migration: Add user preferences table
-- Purpose: Store user-specific settings separate from core user data
-- Dependencies: Requires users table
-- Rollback notes: Safe to rollback if no preferences data exists

CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  theme TEXT DEFAULT 'light',
  notifications_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Coordination strategies:**

For teams, establish migration ownership. Assign one developer to create and test each migration. Use pull request reviews specifically focused on migration correctness, ensuring reviewers verify both forward and backward compatibility.

## Migration File Creation

Migration files are SQL scripts with timestamps that define schema changes. The Supabase CLI generates these files with proper naming conventions and structure.

**Creating new migrations:**

```bash
supabase migration new create_products_table
```

This generates a file like `supabase/migrations/20241004120000_create_products_table.sql` with a timestamp prefix ensuring chronological ordering.

**File naming conventions:**

Migration names should be descriptive and use snake_case. Names become part of the migration history and help identify changes quickly:

- `create_orders_table.sql`
- `add_email_index_to_users.sql`
- `modify_products_price_precision.sql`
- `create_audit_triggers.sql`

**Basic migration structure:**

```sql
-- Create products table with basic fields
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_created_at ON products(created_at DESC);

-- Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public read access" ON products
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert" ON products
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

**Multiple table migrations:**

```sql
-- Create related tables in a single migration
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_category ON products(category_id);
```

**Adding columns to existing tables:**

```sql
-- Add social media fields to users table
ALTER TABLE users ADD COLUMN twitter_handle TEXT;
ALTER TABLE users ADD COLUMN linkedin_url TEXT;
ALTER TABLE users ADD COLUMN github_username TEXT;

-- Add constraints
ALTER TABLE users ADD CONSTRAINT twitter_handle_format 
  CHECK (twitter_handle IS NULL OR twitter_handle ~ '^@?[A-Za-z0-9_]{1,15}$');
```

**Creating indexes:**

```sql
-- Add performance indexes
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_status ON orders(status) WHERE status != 'completed';

-- Composite indexes for common queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Full-text search indexes
CREATE INDEX idx_products_search ON products USING GIN (to_tsvector('english', name || ' ' || description));
```

**Creating functions and triggers:**

```sql
-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Creating views:**

```sql
-- Create materialized view for reporting
CREATE MATERIALIZED VIEW order_summary AS
SELECT 
  DATE_TRUNC('day', created_at) AS order_date,
  COUNT(*) AS total_orders,
  SUM(total_amount) AS total_revenue,
  AVG(total_amount) AS avg_order_value
FROM orders
WHERE status = 'completed'
GROUP BY DATE_TRUNC('day', created_at);

-- Add index to materialized view
CREATE INDEX idx_order_summary_date ON order_summary(order_date DESC);
```

**Setting up Row Level Security:**

```sql
-- Enable RLS on table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view published posts" ON posts
  FOR SELECT USING (status = 'published' OR author_id = auth.uid());

CREATE POLICY "Users can insert their own posts" ON posts
  FOR INSERT WITH CHECK (author_id = auth.uid());

CREATE POLICY "Users can update their own posts" ON posts
  FOR UPDATE USING (author_id = auth.uid());

CREATE POLICY "Users can delete their own posts" ON posts
  FOR DELETE USING (author_id = auth.uid());
```

**Creating enum types:**

```sql
-- Create custom enum types
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');
CREATE TYPE user_role AS ENUM ('user', 'moderator', 'admin');

-- Use enum in table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  status order_status DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Foreign key relationships:**

```sql
-- Create tables with proper foreign key constraints
CREATE TABLE authors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);

CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES authors(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  isbn TEXT UNIQUE
);

-- Junction table for many-to-many
CREATE TABLE book_categories (
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (book_id, category_id)
);
```

## Schema Versioning

Schema versioning tracks the state of your database structure over time. Supabase maintains a migration history table that records which migrations have been applied.

**Migration history tracking:**

Supabase stores applied migrations in the `supabase_migrations.schema_migrations` table. Each row contains the migration version (timestamp), name, and execution details. This table enables the system to determine which migrations need to be applied.

**Version numbering:**

Migrations use timestamp-based versioning: `YYYYMMDDHHMMSS`. This format ensures chronological ordering and prevents version conflicts when multiple developers create migrations simultaneously. The timestamp reflects when the migration file was created, not when it was applied.

**Viewing migration status:**

Check which migrations have been applied locally:

```bash
supabase migration list
```

This displays migration files and their application status. Applied migrations show with indicators, while pending migrations appear unmarked.

**Local vs. remote version synchronization:**

Local and remote databases may have different migration states. Before pushing migrations to production, verify the remote database's current state:

```bash
supabase db pull
```

This fetches the remote schema and identifies differences between local migrations and the remote database state.

**Handling version conflicts:**

When multiple developers create migrations simultaneously, timestamp conflicts rarely occur but can happen. If two migrations have identical timestamps, rename one migration file with a later timestamp:

```bash
mv supabase/migrations/20241004120000_add_field.sql \
   supabase/migrations/20241004120001_add_field.sql
```

**Version control integration:**

Commit migration files to Git immediately after creation. Include both the migration file and any related code changes in the same commit or pull request, ensuring database and application code remain synchronized.

**Baseline migrations:**

[Inference] For existing databases, create a baseline migration capturing the current schema state. This migration serves as the starting point for future changes:

```sql
-- Baseline migration: existing schema as of 2024-10-04
-- Generated from existing database structure

CREATE TABLE users (...);
CREATE TABLE products (...);
-- ... existing schema
```

**Schema drift detection:**

Schema drift occurs when manual changes are made directly to databases bypassing migrations. Detect drift by comparing the migration-generated schema with the actual database schema:

```bash
supabase db diff
```

This identifies tables, columns, or constraints present in the database but not defined in migrations, or vice versa.

**Migration squashing:**

[Inference] Long-running projects accumulate many migrations. Consider periodically squashing old migrations into a single baseline migration. This reduces the number of files and speeds up database recreation, though it loses granular history.

**Semantic versioning for major changes:**

While migrations use timestamp versioning, document major schema overhauls in release notes. Associate migration sets with application version numbers to track which migrations correspond to which application releases.

## Forward and Backward Migrations

Forward migrations apply schema changes, while backward migrations (rollbacks) reverse them. Designing reversible migrations enables safe rollback when issues arise.

**Forward migration patterns:**

Forward migrations should be idempotent when possible, allowing safe re-application. Use conditional checks:

```sql
-- Safe to run multiple times
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);

-- Add column only if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'phone'
  ) THEN
    ALTER TABLE users ADD COLUMN phone TEXT;
  END IF;
END $$;
```

**Reversible operations:**

Some operations are naturally reversible:

- `CREATE TABLE` ↔ `DROP TABLE`
- `ADD COLUMN` ↔ `DROP COLUMN`
- `CREATE INDEX` ↔ `DROP INDEX`
- `ALTER TABLE ADD CONSTRAINT` ↔ `ALTER TABLE DROP CONSTRAINT`

**Irreversible operations:**

Certain operations cannot be safely reversed:

- `DROP COLUMN` (data loss)
- `DROP TABLE` (data loss)
- Data type changes that truncate values
- Constraint additions that reject existing data

**Creating rollback migrations:**

Create explicit rollback migrations for changes requiring reversal:

```sql
-- Forward migration: 20241004120000_add_user_roles.sql
CREATE TYPE user_role AS ENUM ('user', 'admin');
ALTER TABLE users ADD COLUMN role user_role DEFAULT 'user';

-- Rollback migration: 20241004120001_rollback_user_roles.sql
ALTER TABLE users DROP COLUMN role;
DROP TYPE user_role;
```

**Backward-compatible changes:**

Design migrations that don't break existing application code:

```sql
-- Bad: Breaking change - renames column immediately
ALTER TABLE users RENAME COLUMN email TO email_address;

-- Good: Backward-compatible approach
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN email_address TEXT;

-- Step 2: Backfill data
UPDATE users SET email_address = email;

-- Step 3: In later migration (after application updated), remove old column
-- ALTER TABLE users DROP COLUMN email;
```

**Safe column removal:**

Before removing columns, ensure no application code references them:

```sql
-- Migration 1: Mark column as deprecated (add comment)
COMMENT ON COLUMN users.legacy_field IS 'DEPRECATED: Remove after 2024-12-01';

-- Migration 2: After confirming no usage, remove column
ALTER TABLE users DROP COLUMN legacy_field;
```

**Constraint modifications:**

Add constraints with consideration for existing data:

```sql
-- May fail if existing data violates constraint
-- ALTER TABLE products ADD CONSTRAINT price_positive CHECK (price > 0);

-- Safe approach: Add constraint as NOT VALID, then validate
ALTER TABLE products ADD CONSTRAINT price_positive CHECK (price > 0) NOT VALID;

-- Clean up invalid data first
UPDATE products SET price = 0.01 WHERE price <= 0;

-- Now validate the constraint
ALTER TABLE products VALIDATE CONSTRAINT price_positive;
```

**Function versioning:**

When modifying functions, create new versions rather than replacing:

```sql
-- Forward migration
CREATE OR REPLACE FUNCTION calculate_total_v2(order_id UUID)
RETURNS DECIMAL AS $$
  -- New implementation
$$ LANGUAGE sql;

-- Backward migration
CREATE OR REPLACE FUNCTION calculate_total_v2(order_id UUID)
RETURNS DECIMAL AS $$
  -- Revert to previous implementation
$$ LANGUAGE sql;
```

**Testing rollbacks:**

Test rollback procedures in development environments:

```bash
# Apply migration
supabase db reset

# Verify schema
supabase db diff

# Apply rollback migration
supabase migration new rollback_feature_x

# Verify rollback worked correctly
supabase db diff
```

## Data Migrations

Data migrations transform or move data within databases, distinct from schema migrations that alter structure. They handle data cleanup, format changes, and bulk updates.

**Simple data updates:**

```sql
-- Update existing records to new format
UPDATE users 
SET email = LOWER(TRIM(email))
WHERE email != LOWER(TRIM(email));

-- Populate new column from existing data
UPDATE products
SET slug = LOWER(REGEXP_REPLACE(name, '[^a-zA-Z0-9]+', '-', 'g'))
WHERE slug IS NULL;
```

**Conditional data migrations:**

```sql
-- Migrate data only for specific conditions
UPDATE orders
SET shipping_cost = 0
WHERE total_amount > 100 AND shipping_cost IS NULL;

-- Set default values based on existing data
UPDATE users
SET subscription_tier = CASE
  WHEN total_purchases > 1000 THEN 'premium'
  WHEN total_purchases > 100 THEN 'standard'
  ELSE 'basic'
END
WHERE subscription_tier IS NULL;
```

**Batch processing for large datasets:**

```sql
-- Process data in batches to avoid long locks
DO $$
DECLARE
  batch_size INTEGER := 1000;
  processed INTEGER := 0;
  total INTEGER;
BEGIN
  SELECT COUNT(*) INTO total FROM users WHERE legacy_field IS NOT NULL;
  
  LOOP
    UPDATE users
    SET new_field = TRANSFORM_FUNCTION(legacy_field)
    WHERE id IN (
      SELECT id FROM users 
      WHERE legacy_field IS NOT NULL 
      LIMIT batch_size
    );
    
    processed := processed + batch_size;
    
    EXIT WHEN NOT FOUND OR processed >= total;
    
    -- Add delay between batches to reduce load
    PERFORM pg_sleep(0.1);
  END LOOP;
END $$;
```

**Moving data between tables:**

```sql
-- Migrate data to new normalized structure
INSERT INTO addresses (user_id, street, city, country)
SELECT 
  id,
  address_street,
  address_city,
  address_country
FROM users
WHERE address_street IS NOT NULL;

-- Update foreign key references
UPDATE users u
SET address_id = a.id
FROM addresses a
WHERE a.user_id = u.id;
```

**Data transformation migrations:**

```sql
-- Convert JSON column to separate fields
ALTER TABLE products ADD COLUMN price DECIMAL(10,2);
ALTER TABLE products ADD COLUMN currency TEXT;

UPDATE products
SET 
  price = (metadata->>'price')::DECIMAL,
  currency = metadata->>'currency'
WHERE metadata IS NOT NULL;
```

**Aggregating data:**

```sql
-- Create summary records from detailed data
INSERT INTO monthly_sales_summary (year, month, total_revenue, order_count)
SELECT 
  EXTRACT(YEAR FROM created_at) AS year,
  EXTRACT(MONTH FROM created_at) AS month,
  SUM(total_amount) AS total_revenue,
  COUNT(*) AS order_count
FROM orders
WHERE created_at >= '2024-01-01'
GROUP BY EXTRACT(YEAR FROM created_at), EXTRACT(MONTH FROM created_at)
ON CONFLICT (year, month) DO UPDATE SET
  total_revenue = EXCLUDED.total_revenue,
  order_count = EXCLUDED.order_count;
```

**Deduplication migrations:**

```sql
-- Remove duplicate records, keeping the newest
DELETE FROM products
WHERE id NOT IN (
  SELECT DISTINCT ON (sku) id
  FROM products
  ORDER BY sku, created_at DESC
);

-- Or using window functions
DELETE FROM products
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY sku ORDER BY created_at DESC) AS rn
    FROM products
  ) t
  WHERE rn > 1
);
```

**Data validation after migration:**

```sql
-- Verify migration results
DO $$
DECLARE
  invalid_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO invalid_count
  FROM users
  WHERE email NOT LIKE '%@%';
  
  IF invalid_count > 0 THEN
    RAISE EXCEPTION 'Data migration failed: % invalid emails found', invalid_count;
  END IF;
END $$;
```

**Backfilling with data enrichment:**

```sql
-- Enrich existing records with calculated values
UPDATE products
SET 
  search_vector = to_tsvector('english', name || ' ' || COALESCE(description, '')),
  popularity_score = (
    SELECT COUNT(*) FROM order_items WHERE product_id = products.id
  )
WHERE search_vector IS NULL;
```

**Safe data removal:**

```sql
-- Soft delete before hard delete
UPDATE users 
SET deleted_at = NOW()
WHERE last_login < NOW() - INTERVAL '2 years'
  AND deleted_at IS NULL;

-- After verification period, hard delete
DELETE FROM users
WHERE deleted_at < NOW() - INTERVAL '90 days';
```

## Migration Rollback Strategies

Rollback strategies enable recovery when migrations cause issues in production. Planning rollback approaches before deploying migrations reduces risk and downtime.

**Immediate rollback approach:**

Create explicit rollback migrations in advance:

```bash
# Create forward migration
supabase migration new add_feature_x

# Immediately create rollback migration
supabase migration new rollback_feature_x
```

Write rollback SQL that reverses the forward migration completely:

```sql
-- Forward: 20241004120000_add_feature_x.sql
CREATE TABLE feature_data (...);
ALTER TABLE users ADD COLUMN feature_flag BOOLEAN DEFAULT false;

-- Rollback: 20241004120001_rollback_feature_x.sql
ALTER TABLE users DROP COLUMN feature_flag;
DROP TABLE feature_data;
```

**Database backups before migrations:**

Always create database backups before applying migrations to production:

```bash
# Backup production database
pg_dump -h your-db-host -U postgres -d your_database > backup_pre_migration.sql

# Apply migration
supabase db push

# If problems occur, restore backup
psql -h your-db-host -U postgres -d your_database < backup_pre_migration.sql
```

**Point-in-time recovery:**

[Unverified] Supabase projects may support point-in-time recovery, allowing database restoration to any moment before a problematic migration. Check your project's backup settings and retention periods.

**Gradual rollout strategy:**

Apply migrations to subsets of data first:

```sql
-- Phase 1: Apply to 10% of users
UPDATE users
SET new_feature_enabled = true
WHERE id IN (
  SELECT id FROM users 
  WHERE MOD(HASHTEXT(id::TEXT), 10) = 0
);

-- Monitor for issues before proceeding

-- Phase 2: Apply to remaining users
UPDATE users
SET new_feature_enabled = true
WHERE new_feature_enabled = false;
```

**Feature flags in migrations:**

Include feature flags in schema changes, allowing application-level rollback without database changes:

```sql
ALTER TABLE users ADD COLUMN use_new_system BOOLEAN DEFAULT false;

-- Application can toggle behavior without migration rollback
-- If issues occur, disable at application level
```

**Two-phase rollback:**

For complex migrations, implement rollback in phases:

```sql
-- Phase 1: Disable new functionality
ALTER TABLE products DISABLE TRIGGER new_feature_trigger;

-- Phase 2: After confirming stability, remove completely
DROP TRIGGER new_feature_trigger ON products;
ALTER TABLE products DROP COLUMN new_feature_data;
```

**Rollback testing:**

Test rollback procedures in staging environments:

```bash
# Staging environment
supabase link --project-ref staging-project

# Apply migration
supabase migration new test_feature
supabase db push

# Test application with migration

# Apply rollback
supabase migration new rollback_test_feature
supabase db push

# Verify application still functions
```

**Documentation for rollback procedures:**

Document rollback steps in migration files:

```sql
/*
ROLLBACK PROCEDURE:
1. Apply rollback migration: 20241004120001_rollback_user_preferences.sql
2. Restart application servers to clear caches
3. Verify users.preferences column removed
4. Monitor error logs for 30 minutes

ROLLBACK RISK: Medium
- No data loss (column is nullable)
- Application gracefully handles missing column

RECOVERY TIME: ~5 minutes
*/

ALTER TABLE users DROP COLUMN preferences;
```

**Partial rollback strategies:**

Sometimes full rollback isn't necessary. Remove only problematic portions:

```sql
-- Forward migration added multiple elements
CREATE TABLE new_feature (...);
ALTER TABLE users ADD COLUMN feature_flag BOOLEAN;
CREATE INDEX idx_user_feature ON users(feature_flag);

-- Partial rollback: Keep table but remove index if causing performance issues
DROP INDEX idx_user_feature;
```

**Monitoring-driven rollback:**

Establish monitoring thresholds that trigger rollback:

- Error rate increases above baseline
- Query performance degrades beyond acceptable limits
- Application metrics show user impact

Automate rollback triggers based on these metrics in your deployment pipeline.

## Team Collaboration Workflows

Team collaboration on database migrations requires coordination to prevent conflicts and maintain database integrity across multiple developers and environments.

**Migration ownership:**

Assign each migration to a specific developer responsible for creation, testing, and deployment. This person ensures the migration is correct and handles issues during deployment.

**Pull request reviews:**

Require code reviews for all migrations before merging:

- **Schema review**: Verify table structures, relationships, and constraints are correct
- **Performance review**: Check for missing indexes, potentially slow queries
- **Backward compatibility**: Ensure changes don't break existing application code
- **Rollback plan**: Confirm rollback strategy is documented and tested

**Branch naming conventions:**

Use consistent branch naming for migration work:

```
feature/add-user-preferences-table
migration/optimize-product-indexes
hotfix/fix-orders-constraint
```

**Merge order coordination:**

When multiple developers create migrations simultaneously, coordinate merge order to maintain chronological migration sequence:

1. First developer merges migration A (timestamp: 120000)
2. Second developer rebases, ensuring migration B has later timestamp (120001)
3. Second developer merges migration B

**Communication protocols:**

Establish communication channels for migration coordination:

- Announce migration plans before creating them
- Share migration status in team chat during deployment
- Document breaking changes prominently
- Create calendar entries for scheduled production migrations

**Shared development database:**

[Inference] Teams may maintain a shared development database separate from individual local databases. This environment tests migration interactions before staging deployment.

**Migration review checklist:**

```markdown
## Migration Review Checklist

- [ ] Migration file follows naming convention
- [ ] SQL syntax is valid
- [ ] Indexes added for foreign keys and frequent queries
- [ ] RLS policies defined if applicable
- [ ] Backward compatible with current application code
- [ ] Rollback strategy documented
- [ ] Tested locally with `supabase db reset`
- [ ] No hardcoded production values
- [ ] Comments explain complex logic
- [ ] Related application code changes included
```

**Handling migration conflicts:**

When two developers create migrations with conflicting changes:

```bash
# Developer A creates migration adding column 'status'
# Developer B creates migration adding column 'state'

# Resolution:
1. Discuss which change should proceed
2. Developer B updates migration to use agreed-upon column name
3. Update application code accordingly
4. Merge in sequence
```

**Pairing for complex migrations:**

Schedule pair programming sessions for complex migrations involving data transformations or significant schema changes. Two perspectives reduce errors and improve design.

**Migration documentation requirements:**

Maintain a MIGRATIONS.md file documenting major changes:

```markdown
# Migration History

## 2024-10-04: User Preferences System
- **Migration**: `20241004120000_add_user_preferences.sql`
- **Purpose**: Add user customization options
- **Breaking Changes**: None
- **Rollback**: `20241004120001_rollback_user_preferences.sql`
- **Deployment Notes**: Applied to production 2024-10-05 03:00 UTC

## 2024-10-01: Product Search Optimization
- **Migration**: `20241001150000_add_product_search_index.sql`
- **Purpose**: Improve search query performance
- **Performance Impact**: Index creation takes ~2 minutes
- **Deployment Notes**: Deployed during maintenance window
```

**Testing coordination:**

Establish shared testing protocols:

- All migrations must pass in local environment
- Migrations must succeed in staging before production approval
- Integration tests must pass with new schema
- Performance tests verify no degradation

**Emergency migration procedures:**

Define fast-track procedures for critical hotfix migrations:

1. Create migration with clear HOTFIX prefix
2. Expedited review by senior developer
3. Deploy to staging for minimal validation
4. Deploy to production with rollback plan ready
5. Monitor closely for 1 hour post-deployment

## Branching and Preview Environments

Branching strategies and preview environments enable parallel development of database changes while maintaining stability in shared environments.

**Git branching strategies:**

**Feature branch workflow:**

```bash
# Create feature branch
git checkout -b feature/add-notifications-system

# Create migration
supabase migration new create_notifications_table

# Develop and test locally
supabase db reset

# Commit migration
git add supabase/migrations/
git commit -m "Add notifications system migration"

# Push and create PR
git push origin feature/add-notifications-system
```

**Long-running branches:**

For features requiring multiple migrations over time:

```bash
# Create long-lived feature branch
git checkout -b feature/multi-tenant-support

# Create migrations incrementally
supabase migration new add_tenant_id_column
# ... develop ...
supabase migration new migrate_tenant_data
# ... develop ...
supabase migration new add_tenant_constraints

# Periodically merge main into feature branch
git merge main

# Final merge when complete
```

**Migration conflicts resolution:**

When rebasing or merging branches with migrations:

```bash
# Rebase feature branch onto main
git rebase main

# If migration timestamps conflict, rename
mv supabase/migrations/20241004120000_my_migration.sql \
   supabase/migrations/20241004130000_my_migration.sql

# Update application code if needed
git add .
git rebase --continue
```

**Preview environments:**

[Unverified] Supabase may support creating preview databases for pull requests, allowing each feature branch to have its own database instance.

**Manual preview environment setup:**

Create separate Supabase projects for preview environments:

```bash
# Link to preview project
supabase link --project-ref preview-project-ref

# Apply migrations to preview
supabase db push

# Test application against preview database
SUPABASE_URL=https://preview-project.supabase.co npm run dev
```

**Seeding preview environments:**

Create seed scripts for preview databases:

```sql
-- supabase/seed.sql
INSERT INTO users (id, email, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'test@example.com', 'Test User'),
  ('22222222-2222-2222-2222-222222222222', 'admin@example.com', 'Admin User');

INSERT INTO products (name, price) VALUES
  ('Test Product 1', 99.99),
  ('Test Product 2', 49.99);
```

Apply seeds to preview:

```bash
supabase db reset  # Applies migrations and seeds
```

**Environment-specific migrations:**

[Inference] Avoid creating environment-specific migrations. Instead, use configuration or feature flags to handle environment differences. All environments should use identical migration sets.

**Parallel development isolation:**

Each developer maintains their own local database:

```bash
# Developer 1 - local development
supabase start  # Starts local Supabase
supabase db reset  # Applies all migrations

# Developer 2 - separate local instance
supabase start  # Independent local database
supabase db reset  # Same migrations, different data
```

**Preview database lifecycle:**

Establish lifecycle policies for preview environments:

- Create preview database when PR is opened
- Apply branch's migrations automatically
- Destroy preview database when PR is merged/closed
- Limit preview database retention to 7-14 days

**Continuous integration with migrations:**

Configure CI/CD pipelines to test migrations:

```yaml
# .github/workflows/test-migrations.yml
name: Test Migrations

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
      
      - name: Start Supabase
        run: supabase start
      
      - name: Run migrations
        run: supabase db reset
      
      - name: Verify schema
        run: supabase db diff --schema public
      
      - name: Run tests
        run: npm test
```

**Schema comparison across branches:**

Compare schema between branches before merging:

```bash
# Check out main branch
git checkout main
supabase db reset
pg_dump --schema-only > main_schema.sql

# Check out feature branch
git checkout feature/my-feature
supabase db reset
pg_dump --schema-only > feature_schema.sql

# Compare schemas
diff main_schema.sql feature_schema.sql
```

**Branch protection for migrations:**

Configure repository branch protection rules:

- Require migration review approval from database-experienced team members
- Require CI tests to pass before merging
- Prevent direct pushes to main branch
- Require up-to-date branches before merging

**Preview environment URLs:**

When using preview environments, generate predictable URLs for testing:

```
Main: https://main-project.supabase.co
Feature: https://feature-123-preview.supabase.co
PR #45: https://pr-45-preview.supabase.co
```

**Environment synchronization:**

Keep environments synchronized with production schema:

```bash
# Pull production schema to update local
supabase db pull --project-ref production-ref

# Generate migration from differences
supabase db diff --file sync_with_production

# Review and commit sync migration
git add supabase/migrations/
git commit -m "Sync with production schema"
```

**Migration testing in CI/CD:**

```yaml
# .github/workflows/migration-tests.yml
name: Migration Tests

on:
  pull_request:
    paths:
      - 'supabase/migrations/**'

jobs:
  test-migrations:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Supabase
        uses: supabase/setup-cli@v1
      
      - name: Start local Supabase
        run: supabase start
      
      - name: Test forward migrations
        run: supabase db reset
      
      - name: Run integration tests
        run: npm run test:integration
      
      - name: Test migration idempotency
        run: supabase db reset
      
      - name: Validate schema
        run: |
          supabase db diff > schema_diff.txt
          if [ -s schema_diff.txt ]; then
            echo "Schema drift detected"
            cat schema_diff.txt
            exit 1
          fi
```

**Collaborative migration planning:**

Use planning documents for major migrations:

```markdown
# Migration Plan: User Multi-Factor Authentication

## Goal
Add MFA support to user authentication system

## Migration Sequence

### Migration 1: Add MFA tables
- `user_mfa_methods` table
- `user_mfa_backup_codes` table
- Indexes and foreign keys

### Migration 2: Add user MFA preferences
- Add `mfa_enabled` column to users
- Add `mfa_required` column to users
- Default to false for backward compatibility

### Migration 3: Create MFA functions
- `generate_backup_codes()` function
- `verify_mfa_code()` function
- `rotate_mfa_secret()` function

## Timeline
- Week 1: Development and local testing
- Week 2: Staging deployment and testing
- Week 3: Production deployment (off-peak hours)

## Rollback Strategy
Each migration has corresponding rollback migration prepared

## Testing Requirements
- Unit tests for MFA functions
- Integration tests for authentication flow
- Load testing with MFA enabled

## Dependencies
- Application code changes in PR #234
- Updated authentication documentation

## Team Assignments
- Database: @developer1
- Backend: @developer2
- Frontend: @developer3
- QA: @tester1
```

**Preview environment automation:**

[Inference] Automate preview environment creation with scripts:

```bash
#!/bin/bash
# scripts/create-preview-env.sh

PR_NUMBER=$1
BRANCH_NAME=$2

# Create preview project (if using Supabase API)
PREVIEW_REF="pr-${PR_NUMBER}-preview"

echo "Creating preview environment for PR #${PR_NUMBER}"

# Link to preview project
supabase link --project-ref ${PREVIEW_REF}

# Apply migrations
supabase db reset

# Apply seed data
psql $DATABASE_URL < supabase/seed.sql

echo "Preview environment ready at https://${PREVIEW_REF}.supabase.co"
```

**Cross-team migration reviews:**

For migrations affecting multiple teams:

```markdown
## Cross-Team Migration Review

**Migration**: Add analytics events table
**Affected Teams**: Backend, Data Engineering, Analytics

### Backend Team Review
- [ ] Schema design approved
- [ ] Performance impact assessed
- [ ] Integration points identified

### Data Engineering Review
- [ ] ETL pipeline compatibility verified
- [ ] Data warehouse sync requirements noted
- [ ] Partitioning strategy approved

### Analytics Team Review
- [ ] Event schema matches requirements
- [ ] Reporting queries validated
- [ ] Dashboard updates planned
```

**Handling emergency schema fixes:**

Process for urgent production schema fixes:

```bash
# Create hotfix branch from main
git checkout main
git pull
git checkout -b hotfix/fix-critical-constraint

# Create migration
supabase migration new hotfix_remove_invalid_constraint

# Write minimal fix
cat > supabase/migrations/20241004150000_hotfix_remove_invalid_constraint.sql << EOF
-- HOTFIX: Remove invalid constraint causing production errors
-- Ticket: URGENT-123
-- Deployed: 2024-10-04 15:00 UTC

ALTER TABLE orders DROP CONSTRAINT IF EXISTS invalid_status_check;

-- Add correct constraint
ALTER TABLE orders ADD CONSTRAINT valid_status_check 
  CHECK (status IN ('pending', 'processing', 'completed', 'cancelled'));
EOF

# Test locally
supabase db reset

# Fast-track review
git add supabase/migrations/
git commit -m "HOTFIX: Remove invalid constraint"
git push origin hotfix/fix-critical-constraint

# Create PR with URGENT label
# Deploy immediately after approval
```

**Branch cleanup procedures:**

Clean up migrations from abandoned branches:

```bash
# List branches with migrations
git branch --all | grep feature/

# Check if branch is stale
git log feature/old-feature --since="30 days ago"

# If abandoned, document and delete
echo "Branch feature/old-feature abandoned, migrations never deployed" >> MIGRATION_LOG.md
git branch -D feature/old-feature
git push origin --delete feature/old-feature
```

**Environment promotion workflow:**

Promote migrations through environments systematically:

```
Local → Staging → Production

1. Developer creates migration locally
2. PR merged to main
3. Auto-deploy to staging
4. QA testing in staging
5. Scheduled production deployment
6. Post-deployment monitoring
```

**Staging environment parity:**

Maintain staging environment that mirrors production:

```bash
# Periodic staging refresh from production
pg_dump production_db | psql staging_db

# Apply any new migrations
supabase link --project-ref staging-project
supabase db push

# Anonymize sensitive data
psql staging_db << EOF
UPDATE users SET 
  email = 'user_' || id || '@example.com',
  phone = NULL;
UPDATE orders SET customer_notes = 'Test data';
EOF
```

**Documenting deployment procedures:**

Create deployment runbooks for migrations:

```markdown
# Production Migration Deployment - User MFA System

## Pre-Deployment Checklist
- [ ] Staging testing completed successfully
- [ ] Rollback migration prepared and tested
- [ ] Database backup created
- [ ] Team notified of deployment window
- [ ] Monitoring dashboards open

## Deployment Steps

1. **Verify current state** (15:00 UTC)
   ``bash
   supabase migration list --project-ref production
   ``

2. **Create backup** (15:05 UTC)
    
    `bash
    ./scripts/backup-production.sh
    ``
    
3. **Apply migration** (15:10 UTC)
    
    ``bash
    supabase db push --project-ref production
    ``
    
4. **Verify schema** (15:15 UTC)
    
    `bash
    supabase db diff --project-ref production
    `
    
5. **Run validation queries** (15:20 UTC)
    
    ```sql
    SELECT COUNT(*) FROM user_mfa_methods;
    SELECT * FROM users WHERE mfa_enabled = true LIMIT 5;
    ``
    
2. **Deploy application code** (15:25 UTC)
   
    - Deploy backend services
    - Deploy frontend assets
    - Verify health checks
      
3. **Monitor for 30 minutes** (15:30-16:00 UTC)
   
    - Check error rates
    - Monitor query performance
    - Verify user reports

## Rollback Procedure

If issues detected:

1. **Stop deployment**
    
    ``bash
    ./scripts/stop-deployment.sh
    ``
    
2. **Apply rollback migration**
    
    `bash
    supabase migration new rollback_mfa_system
    supabase db push --project-ref production
    ``
    
3. **Revert application code**
    
    ``bash
    ./scripts/deploy-previous-version.sh
    ``
    
4. **Verify rollback**
    
    - Confirm old schema restored
    - Test core functionality
    - Monitor error rates

## Post-Deployment

- [ ] Update MIGRATIONS.md with deployment notes
- [ ] Close deployment ticket
- [ ] Schedule retrospective if issues occurred
- [ ] Archive backup after 30 days
```

**Important related topics:** Schema validation and constraint design patterns, managing database permissions and roles through migrations, implementing audit logging for schema changes, database performance testing strategies for migrations, handling timezone and data type migrations, coordinating frontend and backend deployments with database changes, disaster recovery procedures for failed migrations, implementing database seeding strategies for different environments, managing secrets and environment variables across branches, schema documentation generation and maintenance.

---

# Framework Integration

## Next.js Integration Patterns

**Key Points:**

- Supabase provides official support for Next.js through `@supabase/ssr` package
- Integration differs between App Router and Pages Router architectures
- Requires careful handling of client/server component boundaries
- Cookie-based session management for server-side operations

### App Router Implementation

The App Router uses React Server Components by default, requiring separate client configurations:

```typescript
// utils/supabase/server.ts
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          cookieStore.set({ name, value, ...options })
        },
        remove(name: string, options: CookieOptions) {
          cookieStore.set({ name, value: '', ...options })
        },
      },
    }
  )
}
```

```typescript
// utils/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Pages Router Implementation

Pages Router uses a middleware-based approach for authentication:

```typescript
// utils/supabase-server.ts
import { createServerSupabaseClient } from '@supabase/auth-helpers-nextjs'
import type { NextApiRequest, NextApiResponse } from 'next'

export const createClient = (req: NextApiRequest, res: NextApiResponse) => {
  return createServerSupabaseClient({ req, res })
}
```

### Middleware Configuration

Authentication state synchronization across requests:

```typescript
// middleware.ts
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })
  await supabase.auth.getSession()
  return res
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

### Route Handlers and API Routes

```typescript
// app/api/data/route.ts
import { createClient } from '@/utils/supabase/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const supabase = createClient()
  const { data, error } = await supabase.from('users').select()
  
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
  
  return NextResponse.json({ data })
}
```

### Protected Routes Pattern

```typescript
// app/dashboard/page.tsx
import { redirect } from 'next/navigation'
import { createClient } from '@/utils/supabase/server'

export default async function DashboardPage() {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    redirect('/login')
  }
  
  return <div>Protected Dashboard Content</div>
}
```

### Real-time Subscriptions in Client Components

```typescript
'use client'

import { createClient } from '@/utils/supabase/client'
import { useEffect, useState } from 'react'

export function RealtimeComponent() {
  const [messages, setMessages] = useState([])
  const supabase = createClient()

  useEffect(() => {
    const channel = supabase
      .channel('messages')
      .on('postgres_changes', 
        { event: 'INSERT', schema: 'public', table: 'messages' },
        (payload) => setMessages(prev => [...prev, payload.new])
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  return <div>{/* Render messages */}</div>
}
```

## React Integration

**Key Points:**

- Direct client-side integration using `@supabase/supabase-js`
- Context-based authentication state management
- Custom hooks for common operations
- Real-time subscription lifecycle management

### Basic Setup

```typescript
// supabaseClient.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.REACT_APP_SUPABASE_URL!
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### Authentication Context

```typescript
// contexts/AuthContext.tsx
import { createContext, useContext, useEffect, useState } from 'react'
import { Session, User } from '@supabase/supabase-js'
import { supabase } from '../supabaseClient'

interface AuthContextType {
  user: User | null
  session: Session | null
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setSession(session)
        setUser(session?.user ?? null)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return (
    <AuthContext.Provider value={{ user, session, signIn, signOut }}>
      {!loading && children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}
```

### Custom Data Fetching Hook

```typescript
// hooks/useSupabaseQuery.ts
import { useEffect, useState } from 'react'
import { supabase } from '../supabaseClient'

export function useSupabaseQuery<T>(
  query: () => Promise<{ data: T | null; error: any }>
) {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    query()
      .then(({ data, error }) => {
        setData(data)
        setError(error)
      })
      .finally(() => setLoading(false))
  }, [])

  return { data, error, loading }
}
```

### Protected Route Component

```typescript
// components/ProtectedRoute.tsx
import { Navigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user } = useAuth()
  
  if (!user) {
    return <Navigate to="/login" replace />
  }
  
  return <>{children}</>
}
```

## Vue.js Integration

**Key Points:**

- Composables for reactive Supabase operations
- Pinia store integration for state management
- Vue Router navigation guards for authentication
- TypeScript support with proper type inference

### Composable Setup

```typescript
// composables/useSupabase.ts
import { createClient } from '@supabase/supabase-js'
import { ref, computed } from 'vue'
import type { User, Session } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export function useAuth() {
  const user = ref<User | null>(null)
  const session = ref<Session | null>(null)
  const loading = ref(true)

  const isAuthenticated = computed(() => !!user.value)

  const initialize = async () => {
    const { data: { session: currentSession } } = await supabase.auth.getSession()
    session.value = currentSession
    user.value = currentSession?.user ?? null
    loading.value = false

    supabase.auth.onAuthStateChange((_event, newSession) => {
      session.value = newSession
      user.value = newSession?.user ?? null
    })
  }

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    if (error) throw error
    return data
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return {
    user,
    session,
    loading,
    isAuthenticated,
    initialize,
    signIn,
    signOut,
  }
}
```

### Pinia Store Integration

```typescript
// stores/auth.ts
import { defineStore } from 'pinia'
import { supabase } from '@/composables/useSupabase'
import type { User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    loading: false,
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
  },

  actions: {
    async initialize() {
      const { data: { session } } = await supabase.auth.getSession()
      this.user = session?.user ?? null

      supabase.auth.onAuthStateChange((_event, session) => {
        this.user = session?.user ?? null
      })
    },

    async signIn(email: string, password: string) {
      this.loading = true
      try {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })
        if (error) throw error
      } finally {
        this.loading = false
      }
    },

    async signOut() {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
    },
  },
})
```

### Router Guards

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/dashboard',
      component: () => import('@/views/Dashboard.vue'),
      meta: { requiresAuth: true },
    },
    // other routes
  ],
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else {
    next()
  }
})

export default router
```

### Component Usage

```vue
<!-- components/UserProfile.vue -->
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/composables/useSupabase'

interface Profile {
  id: string
  username: string
  avatar_url: string
}

const profile = ref<Profile | null>(null)
const loading = ref(true)

onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  
  if (user) {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()
    
    profile.value = data
  }
  
  loading.value = false
})
</script>

<template>
  <div v-if="loading">Loading...</div>
  <div v-else-if="profile">
    <h2>{{ profile.username }}</h2>
    <img :src="profile.avatar_url" />
  </div>
</template>
```

## Svelte Integration

**Key Points:**

- Svelte stores for reactive authentication state
- SvelteKit-specific server/client patterns
- Form actions for server-side mutations
- Type-safe database queries with generated types

### Client Setup

```typescript
// lib/supabaseClient.ts
import { createClient } from '@supabase/supabase-js'
import { writable } from 'svelte/store'
import type { User, Session } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export const user = writable<User | null>(null)
export const session = writable<Session | null>(null)

supabase.auth.getSession().then(({ data: { session: currentSession } }) => {
  session.set(currentSession)
  user.set(currentSession?.user ?? null)
})

supabase.auth.onAuthStateChange((_event, newSession) => {
  session.set(newSession)
  user.set(newSession?.user ?? null)
})
```

### SvelteKit Server-Side Integration

```typescript
// src/hooks.server.ts
import { createServerClient } from '@supabase/ssr'
import type { Handle } from '@sveltejs/kit'

export const handle: Handle = async ({ event, resolve }) => {
  event.locals.supabase = createServerClient(
    process.env.PUBLIC_SUPABASE_URL!,
    process.env.PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get: (key) => event.cookies.get(key),
        set: (key, value, options) => {
          event.cookies.set(key, value, options)
        },
        remove: (key, options) => {
          event.cookies.delete(key, options)
        },
      },
    }
  )

  event.locals.getSession = async () => {
    const {
      data: { session },
    } = await event.locals.supabase.auth.getSession()
    return session
  }

  return resolve(event, {
    filterSerializedResponseHeaders(name) {
      return name === 'content-range'
    },
  })
}
```

### Page Load Function

```typescript
// routes/dashboard/+page.server.ts
import { redirect } from '@sveltejs/kit'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = async ({ locals: { supabase, getSession } }) => {
  const session = await getSession()

  if (!session) {
    throw redirect(303, '/login')
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', session.user.id)
    .single()

  return {
    session,
    profile,
  }
}
```

### Form Actions

```typescript
// routes/login/+page.server.ts
import { fail, redirect } from '@sveltejs/kit'
import type { Actions } from './$types'

export const actions: Actions = {
  login: async ({ request, locals: { supabase } }) => {
    const formData = await request.formData()
    const email = formData.get('email') as string
    const password = formData.get('password') as string

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      return fail(400, { email, error: error.message })
    }

    throw redirect(303, '/dashboard')
  },
}
```

### Component with Real-time Subscription

```svelte
<!-- routes/messages/+page.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte'
  import { supabase } from '$lib/supabaseClient'
  
  let messages: any[] = []
  let channel: any

  onMount(() => {
    loadMessages()
    
    channel = supabase
      .channel('messages')
      .on('postgres_changes', 
        { event: 'INSERT', schema: 'public', table: 'messages' },
        (payload) => {
          messages = [...messages, payload.new]
        }
      )
      .subscribe()
  })

  onDestroy(() => {
    if (channel) {
      supabase.removeChannel(channel)
    }
  })

  async function loadMessages() {
    const { data } = await supabase
      .from('messages')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (data) messages = data
  }
</script>

<div>
  {#each messages as message}
    <div>{message.content}</div>
  {/each}
</div>
```

## React Native Mobile Apps

**Key Points:**

- AsyncStorage for persistent session storage
- Deep linking for OAuth callbacks
- Biometric authentication integration
- Offline-first patterns with local caching

### Project Setup

```typescript
// lib/supabase.ts
import 'react-native-url-polyfill/auto'
import { createClient } from '@supabase/supabase-js'
import AsyncStorage from '@react-native-async-storage/async-storage'

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
})
```

### Authentication Context

```typescript
// contexts/AuthContext.tsx
import { createContext, useContext, useEffect, useState } from 'react'
import { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'

interface AuthContextType {
  session: Session | null
  loading: boolean
}

const AuthContext = createContext<AuthContextType>({
  session: null,
  loading: true,
})

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setLoading(false)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setSession(session)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  return (
    <AuthContext.Provider value={{ session, loading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
```

### OAuth with Deep Linking (Expo)

```typescript
// app.json configuration
{
  "expo": {
    "scheme": "myapp",
    "plugins": [
      [
        "expo-build-properties",
        {
          "android": {
            "usesCleartextTraffic": true
          }
        }
      ]
    ]
  }
}
```

```typescript
// screens/Auth.tsx
import { supabase } from '../lib/supabase'
import * as WebBrowser from 'expo-web-browser'
import { makeRedirectUri } from 'expo-auth-session'

WebBrowser.maybeCompleteAuthSession()

const redirectTo = makeRedirectUri()

async function signInWithGithub() {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'github',
    options: {
      redirectTo,
      skipBrowserRedirect: true,
    },
  })

  if (error) throw error

  const res = await WebBrowser.openAuthSessionAsync(
    data.url,
    redirectTo
  )

  if (res.type === 'success') {
    const { url } = res
    const params = new URLSearchParams(url.split('#')[1])
    const accessToken = params.get('access_token')
    
    if (accessToken) {
      await supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: params.get('refresh_token')!,
      })
    }
  }
}
```

### Biometric Authentication

```typescript
// hooks/useBiometrics.ts
import * as LocalAuthentication from 'expo-local-authentication'
import { useEffect, useState } from 'react'
import AsyncStorage from '@react-native-async-storage/async-storage'

export function useBiometrics() {
  const [isAvailable, setIsAvailable] = useState(false)

  useEffect(() => {
    checkBiometrics()
  }, [])

  async function checkBiometrics() {
    const compatible = await LocalAuthentication.hasHardwareAsync()
    const enrolled = await LocalAuthentication.isEnrolledAsync()
    setIsAvailable(compatible && enrolled)
  }

  async function authenticate() {
    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: 'Authenticate to access your account',
      fallbackLabel: 'Use passcode',
    })
    return result.success
  }

  async function enableBiometrics(credentials: { email: string; password: string }) {
    await AsyncStorage.setItem('biometrics_enabled', 'true')
    await AsyncStorage.setItem('credentials', JSON.stringify(credentials))
  }

  return {
    isAvailable,
    authenticate,
    enableBiometrics,
  }
}
```

### Offline Data Sync

```typescript
// hooks/useOfflineSync.ts
import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import AsyncStorage from '@react-native-async-storage/async-storage'
import NetInfo from '@react-native-community/netinfo'

export function useOfflineSync<T>(
  table: string,
  cacheKey: string
) {
  const [data, setData] = useState<T[]>([])
  const [isOnline, setIsOnline] = useState(true)

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      setIsOnline(state.isConnected ?? false)
    })

    loadData()
    return unsubscribe
  }, [])

  async function loadData() {
    // Try loading from cache first
    const cached = await AsyncStorage.getItem(cacheKey)
    if (cached) {
      setData(JSON.parse(cached))
    }

    // Fetch fresh data if online
    if (isOnline) {
      const { data: freshData } = await supabase
        .from(table)
        .select('*')
      
      if (freshData) {
        setData(freshData)
        await AsyncStorage.setItem(cacheKey, JSON.stringify(freshData))
      }
    }
  }

  return { data, isOnline, refresh: loadData }
}
```

## Flutter Integration

**Key Points:**

- Official `supabase_flutter` package with platform-specific handling
- Deep linking configuration for iOS and Android
- Provider or Riverpod for state management
- GoRouter integration for authentication routing

### Project Setup

```yaml
# pubspec.yaml
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

