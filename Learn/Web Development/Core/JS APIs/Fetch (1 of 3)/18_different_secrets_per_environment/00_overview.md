## Overview

deploy-staging:
  environment: staging
  variables:
    DATABASE_URL: $STAGING_DATABASE_URL
    API_KEY: $STAGING_API_KEY

deploy-production:
  environment: production
  variables:
    DATABASE_URL: $PROD_DATABASE_URL
    API_KEY: $PROD_API_KEY
```

### Credential Rotation

**Automated rotation pattern:**

```javascript
class CredentialRotationManager {
  constructor() {
    this.currentKey = null;
    this.previousKey = null;
    this.rotationInterval = 30 * 24 * 60 * 60 * 1000; // 30 days
  }
  
  async rotateCredentials() {
    // Generate new credentials
    const newKey = await this.generateNewKey();
    
    // Store previous key for grace period
    this.previousKey = this.currentKey;
    this.currentKey = newKey;
    
    // Update in secret manager
    await this.updateSecretManager(newKey);
    
    // Notify dependent services
    await this.notifyServices(newKey);
    
    // Schedule removal of old key after grace period
    setTimeout(() => {
      this.previousKey = null;
    }, 24 * 60 * 60 * 1000); // 24 hour grace period
  }
  
  async validateKey(providedKey) {
    // Accept both current and previous key during grace period
    return providedKey === this.currentKey || 
           (this.previousKey && providedKey === this.previousKey);
  }
  
  async generateNewKey() {
    return crypto.randomBytes(32).toString('hex');
  }
  
  async updateSecretManager(newKey) {
    // Update in AWS Secrets Manager, etc.
    await secretsManager.updateSecret({
      SecretId: 'app/api-key',
      SecretString: newKey
    });
  }
}

// Scheduled rotation
const rotationManager = new CredentialRotationManager();

// Run rotation every 30 days
setInterval(() => {
  rotationManager.rotateCredentials();
}, 30 * 24 * 60 * 60 * 1000);
```

### Database Connection Strings

**Secure storage:**

```javascript
// Instead of hardcoding
// const connectionString = 'postgresql://user:password@localhost:5432/db';

// Use environment variable
const connectionString = process.env.DATABASE_URL;

// Or parse components separately
const dbConfig = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: {
    rejectUnauthorized: true,
    ca: fs.readFileSync(process.env.DB_SSL_CERT)
  }
};

const pool = new Pool(dbConfig);
```

**Connection pooling with credential refresh:**

```javascript
const { Pool } = require('pg');

class SecurePool {
  constructor() {
    this.pool = null;
    this.initializePool();
    
    // Refresh credentials periodically
    setInterval(() => this.refreshCredentials(), 3600000); // 1 hour
  }
  
  async initializePool() {
    const credentials = await this.getCredentials();
    
    this.pool = new Pool({
      host: credentials.host,
      database: credentials.database,
      user: credentials.username,
      password: credentials.password,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });
  }
  
  async getCredentials() {
    // Fetch from secret manager
    return await secretsManager.getSecret('database/credentials');
  }
  
  async refreshCredentials() {
    await this.pool.end();
    await this.initializePool();
  }
  
  async query(text, params) {
    return this.pool.query(text, params);
  }
}

const db = new SecurePool();
```

### Security Best Practices Checklist

**Never do:**

- Store credentials in version control
- Hardcode secrets in source code
- Store passwords in plain text
- Use weak encryption algorithms (MD5, SHA1 for passwords)
- Share credentials in chat/email
- Log sensitive credentials
- Store credentials in client-side code
- Use the same credentials across environments
- Store API keys in public repositories

**Always do:**

- Use environment variables or secret managers
- Rotate credentials regularly
- Use strong hashing for passwords (bcrypt, Argon2)
- Implement proper access controls
- Use HTTPS for credential transmission
- Audit credential access
- Implement credential expiration
- Use different credentials per environment
- Monitor for credential leaks
- Have an incident response plan

**Credential leak detection:**

```javascript
// Add pre-commit hook to check for secrets
// .git/hooks/pre-commit

const fs = require('fs');
const { execSync } = require('child_process');

const patterns = [
  /sk_live_[a-zA-Z0-9]+/,  // Stripe live keys
  /sk_test_[a-zA-Z0-9]+/,  // Stripe test keys
  /AKIA[0-9A-Z]{16}/,      // AWS access key
  /password\s*=\s*['"][^'"]+['"]/i,
  /api[_-]?key\s*=\s*['"][^'"]+['"]/i
];

const stagedFiles = execSync('git diff --cached --name-only')
  .toString()
  .split('\n')
  .filter(Boolean);

for (const file of stagedFiles) {
  if (!fs.existsSync(file)) continue;
  
  const content = fs.readFileSync(file, 'utf8');
  
  for (const pattern of patterns) {
    if (pattern.test(content)) {
      console.error(`⚠️  Potential secret found in ${file}`);
      process.exit(1);
    }
  }
}
```

---

