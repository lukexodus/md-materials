## API Key Management


Supabase projects include two primary API keys with different security profiles and use cases.

**Anon (public) key:**

The anon key is safe to expose in client-side code, mobile apps, and public repositories. It provides access only to data permitted by Row Level Security policies. This key authenticates requests but grants no inherent privileges beyond what RLS policies explicitly allow. When users are unauthenticated, requests using the anon key can only access publicly available data as defined by your policies.

**Service role key:**

The service role key bypasses all Row Level Security policies and should never be exposed in client-side code, version control, or publicly accessible locations. This key has superuser-level access to your database and should only be used in secure server-side environments, backend services, administrative scripts, or CI/CD pipelines. [Inference: Exposing the service role key would grant unrestricted database access to anyone who obtains it]

**Key rotation:**

Rotate API keys if compromised or as periodic security practice. In your Supabase project settings under API, you can generate new keys. After rotation, update all applications and services using the old keys. [Unverified: The exact process for key rotation and whether old keys are immediately invalidated or have a grace period may vary]

**Environment-specific keys:**

Use different Supabase projects for development, staging, and production environments, each with distinct API keys. This prevents development testing from affecting production data and limits the blast radius of potential security incidents.

**Storage practices:**

- Store keys in environment variables, never hardcode them
- Use secrets management systems (AWS Secrets Manager, HashiCorp Vault, Doppler)
- Add `.env` files to `.gitignore` to prevent accidental commits
- Use platform-specific secure storage on mobile (Keychain on iOS, Keystore on Android)
- Implement key access controls limiting which team members can view service role keys

**Monitoring key usage:**

Monitor API logs for unusual patterns indicating compromised keys such as unexpected geographic locations, abnormal request volumes, or unauthorized access attempts. [Inference: Supabase likely provides logging capabilities for this purpose, though specific monitoring features may vary by plan]

