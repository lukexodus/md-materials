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

