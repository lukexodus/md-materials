## Multi-Factor Authentication (MFA)


Additional security layer requiring users to provide a second form of verification beyond password. Supabase supports Time-based One-Time Password (TOTP) authentication.

**Key points:**

- Uses TOTP standard (RFC 6238) compatible with authenticator apps
- Factors stored encrypted in `auth.mfa_factors` table
- Can require MFA for specific users or all users
- Challenge records stored in `auth.mfa_challenges` table
- Backup codes available for account recovery
- Verification required within time window (default 30 seconds)

**Example:** Enrolling MFA factor

```javascript
const { data, error } = await supabase.auth.mfa.enroll({
  factorType: 'totp',
  friendlyName: 'My Phone'
})

// Returns QR code and secret for authenticator app
const { id, type, totp } = data
```

**Example:** Verifying and activating MFA

```javascript
const { data, error } = await supabase.auth.mfa.challenge({
  factorId: 'factor-id-here'
})

const { data: verifyData, error: verifyError } = await supabase.auth.mfa.verify({
  factorId: 'factor-id-here',
  challengeId: data.id,
  code: '123456'
})
```

**Example:** Sign-in with MFA

```javascript
// First authenticate with password
await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
})

// Then complete MFA challenge
const { data: factorsData } = await supabase.auth.mfa.listFactors()
const factor = factorsData.totp[0]

const { data: challengeData } = await supabase.auth.mfa.challenge({
  factorId: factor.id
})

const { data, error } = await supabase.auth.mfa.verify({
  factorId: factor.id,
  challengeId: challengeData.id,
  code: '123456'
})
```

