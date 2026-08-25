## Secrets Management


Secrets management involves securely storing, accessing, and rotating sensitive credentials, API keys, and configuration values.

**What qualifies as secrets:**

- Database connection strings
- Service role API keys
- Third-party API keys (Stripe, SendGrid, AWS)
- Encryption keys
- OAuth client secrets
- Webhook signing secrets
- Private keys and certificates

**Never store in:**

- Version control (Git repositories)
- Client-side code
- Unencrypted database columns
- Application logs
- Error messages
- URL parameters

**Environment variables:**

The primary method for managing secrets in applications:

```bash
# .env file (never commit this)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
STRIPE_SECRET_KEY=sk_live_...
SENDGRID_API_KEY=SG....

# .env.example file (commit this as template)
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
STRIPE_SECRET_KEY=
```

**Accessing environment variables:**

```javascript
// Node.js
const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Validate presence
if (!serviceRoleKey) {
  throw new Error('SUPABASE_SERVICE_ROLE_KEY not configured');
}
```

**.gitignore configuration:**

```
# .gitignore
.env
.env.local
.env.*.local
*.key
*.pem
secrets/
```

**Secrets management services:**

For production environments, use dedicated secrets management:

**AWS Secrets Manager:**

```javascript
import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

async function getSecret(secretName) {
  const client = new SecretsManagerClient({ region: "us-east-1" });
  const response = await client.send(
    new GetSecretValueCommand({ SecretId: secretName })
  );
  return JSON.parse(response.SecretString);
}

const secrets = await getSecret('prod/supabase/credentials');
const supabase = createClient(secrets.url, secrets.serviceRoleKey);
```

**HashiCorp Vault:**

```javascript
import vault from 'node-vault';

const client = vault({
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN
});

const { data } = await client.read('secret/data/supabase');
const serviceRoleKey = data.data.service_role_key;
```

**Cloud platform secrets:**

```javascript
// Google Cloud Secret Manager
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

const client = new SecretManagerServiceClient();
const [version] = await client.accessSecretVersion({
  name: 'projects/PROJECT_ID/secrets/supabase-key/versions/latest',
});
const secret = version.payload.data.toString();

// Azure Key Vault
import { SecretClient } from "@azure/keyvault-secrets";
import { DefaultAzureCredential } from "@azure/identity";

const credential = new DefaultAzureCredential();
const client = new SecretClient(vaultUrl, credential);
const secret = await client.getSecret("supabase-service-key");
```

**Edge Functions secrets:**

Supabase Edge Functions support environment variables:

```javascript
// Set in Supabase dashboard or CLI
// Access in Edge Function:
Deno.serve(async (req) => {
  const apiKey = Deno.env.get('THIRD_PARTY_API_KEY');
  
  if (!apiKey) {
    return new Response('Configuration error', { status: 500 });
  }
  
  // Use the secret
  const response = await fetch('https://api.example.com/data', {
    headers: { 'Authorization': `Bearer ${apiKey}` }
  });
  
  return response;
});
```

**Database encryption for sensitive data:**

For secrets that must be stored in the database:

```sql
-- Install pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Store encrypted data
CREATE TABLE api_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  service_name TEXT NOT NULL,
  encrypted_key BYTEA NOT NULL,  -- Encrypted API key
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Encryption function
CREATE FUNCTION encrypt_api_key(api_key TEXT, encryption_key TEXT)
RETURNS BYTEA AS $$
  SELECT pgp_sym_encrypt(api_key, encryption_key);
$$ LANGUAGE SQL;

-- Decryption function
CREATE FUNCTION decrypt_api_key(encrypted_data BYTEA, encryption_key TEXT)
RETURNS TEXT AS $$
  SELECT pgp_sym_decrypt(encrypted_data, encryption_key);
$$ LANGUAGE SQL;

-- Usage
INSERT INTO api_credentials (user_id, service_name, encrypted_key)
VALUES (
  auth.uid(),
  'stripe',
  encrypt_api_key('sk_live_...', current_setting('app.encryption_key'))
);
```

**Key rotation:**

Implement regular secret rotation:

```javascript
// Automated key rotation example
async function rotateApiKey() {
  // Generate new key
  const newKey = await generateNewApiKey();
  
  // Update in secrets manager
  await secretsManager.updateSecret({
    SecretId: 'prod/api-key',
    SecretString: newKey
  });
  
  // Update in Supabase if stored there
  await supabase
    .from('service_configs')
    .update({ api_key_version: 'v2', updated_at: new Date() })
    .eq('service', 'third_party');
  
  // Notify monitoring
  await notifyKeyRotation('third_party', 'v2');
  
  // Schedule old key deprecation (allow grace period)
  await scheduleOldKeyDeprecation('v1', 7); // 7 days
}
```

**Accessing secrets in CI/CD:**

```yaml
# GitHub Actions example
name: Deploy
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to production
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          SUPABASE_DB_PASSWORD: ${{ secrets.SUPABASE_DB_PASSWORD }}
        run: |
          npx supabase db push
```

**Best practices:**

- Use different secrets for each environment (dev, staging, production)
- Implement least privilege - grant minimal necessary access
- Rotate secrets regularly (quarterly or after personnel changes)
- Audit secret access and usage
- Never log secrets or include in error messages
- Use short-lived tokens when possible
- Implement secret expiration policies
- Monitor for exposed secrets in code repositories (use tools like GitGuardian, TruffleHog)
- Encrypt secrets at rest and in transit
- Document secret ownership and rotation procedures

**Emergency revocation:**

Have procedures for immediate secret revocation:

```javascript
async function emergencyRevocation(secretId) {
  // Immediately disable the compromised secret
  await secretsManager.putSecretValue({
    SecretId: secretId,
    SecretString: 'REVOKED'
  });
  
  // Generate and deploy new secret
  const newSecret = await generateNewSecret();
  await deployNewSecret(newSecret);
  
  // Notify security team
  await alertSecurityTeam({
    severity: 'critical',
    secret: secretId,
    action: 'revoked',
    timestamp: new Date()
  });
  
  // Log incident
  await logSecurityIncident({
    type: 'secret_compromise',
    secretId,
    revocationTime: new Date()
  });
}
```

