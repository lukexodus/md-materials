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

