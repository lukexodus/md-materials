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

