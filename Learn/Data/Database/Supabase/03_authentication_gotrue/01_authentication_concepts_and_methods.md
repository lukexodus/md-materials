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

