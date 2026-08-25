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

