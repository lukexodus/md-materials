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

