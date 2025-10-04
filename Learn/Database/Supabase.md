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

