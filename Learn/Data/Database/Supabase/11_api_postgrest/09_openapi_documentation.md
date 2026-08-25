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

