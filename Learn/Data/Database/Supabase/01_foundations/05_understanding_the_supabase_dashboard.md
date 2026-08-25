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

