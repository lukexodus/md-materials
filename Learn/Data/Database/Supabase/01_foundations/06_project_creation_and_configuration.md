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

