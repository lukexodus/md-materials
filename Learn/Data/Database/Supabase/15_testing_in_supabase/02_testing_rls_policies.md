## Testing RLS Policies


Row Level Security policies enforce access control at the database level and require thorough testing to prevent security vulnerabilities.

### RLS Policy Structure

```sql
-- Example policies
CREATE POLICY "Users can view own data"
ON profiles FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
ON profiles FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all data"
ON profiles FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);
```

### Testing RLS with pgTAP

```sql
CREATE OR REPLACE FUNCTION tests.test_rls_user_isolation()
RETURNS SETOF TEXT AS $$
DECLARE
  user1_id uuid := gen_random_uuid();
  user2_id uuid := gen_random_uuid();
BEGIN
  -- Setup test data
  INSERT INTO profiles (user_id, name) VALUES
    (user1_id, 'User 1'),
    (user2_id, 'User 2');

  -- Test as user1
  PERFORM set_config('request.jwt.claims', json_build_object('sub', user1_id)::text, true);
  
  RETURN NEXT is(
    (SELECT COUNT(*) FROM profiles WHERE user_id = user1_id),
    1::bigint,
    'User should see own profile'
  );

  RETURN NEXT is(
    (SELECT COUNT(*) FROM profiles WHERE user_id = user2_id),
    0::bigint,
    'User should not see other profiles'
  );

  -- Cleanup
  DELETE FROM profiles WHERE user_id IN (user1_id, user2_id);
END;
$$ LANGUAGE plpgsql;
```

### Testing RLS with JavaScript

```javascript
// rls.test.js
import { createClient } from '@supabase/supabase-js'

describe('RLS Policies', () => {
  let user1Client, user2Client
  let user1, user2

  beforeAll(async () => {
    // Create test users
    const adminClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    )

    const { data: userData1 } = await adminClient.auth.admin.createUser({
      email: 'user1@test.com',
      password: 'password123',
      email_confirm: true
    })
    user1 = userData1.user

    const { data: userData2 } = await adminClient.auth.admin.createUser({
      email: 'user2@test.com',
      password: 'password123',
      email_confirm: true
    })
    user2 = userData2.user

    // Create authenticated clients
    user1Client = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )
    await user1Client.auth.signInWithPassword({
      email: 'user1@test.com',
      password: 'password123'
    })

    user2Client = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )
    await user2Client.auth.signInWithPassword({
      email: 'user2@test.com',
      password: 'password123'
    })

    // Insert test data
    await user1Client.from('profiles').insert({
      user_id: user1.id,
      name: 'User 1'
    })
    await user2Client.from('profiles').insert({
      user_id: user2.id,
      name: 'User 2'
    })
  })

  afterAll(async () => {
    const adminClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    )
    await adminClient.auth.admin.deleteUser(user1.id)
    await adminClient.auth.admin.deleteUser(user2.id)
  })

  test('users can only view own profiles', async () => {
    const { data, error } = await user1Client
      .from('profiles')
      .select()
    
    expect(error).toBeNull()
    expect(data).toHaveLength(1)
    expect(data[0].user_id).toBe(user1.id)
  })

  test('users cannot update other profiles', async () => {
    const { error } = await user1Client
      .from('profiles')
      .update({ name: 'Hacked' })
      .eq('user_id', user2.id)
    
    expect(error).not.toBeNull()
    
    // Verify data unchanged
    const { data } = await user2Client
      .from('profiles')
      .select()
      .eq('user_id', user2.id)
      .single()
    
    expect(data.name).toBe('User 2')
  })

  test('users can update own profile', async () => {
    const { error } = await user1Client
      .from('profiles')
      .update({ name: 'Updated Name' })
      .eq('user_id', user1.id)
    
    expect(error).toBeNull()
    
    const { data } = await user1Client
      .from('profiles')
      .select()
      .eq('user_id', user1.id)
      .single()
    
    expect(data.name).toBe('Updated Name')
  })
})
```

### Testing Role-Based Policies

```javascript
describe('Role-Based RLS', () => {
  let adminClient, userClient

  beforeAll(async () => {
    // Setup admin and regular user
    const serviceClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    )

    // Create admin user
    const { data: adminData } = await serviceClient.auth.admin.createUser({
      email: 'admin@test.com',
      password: 'password123',
      email_confirm: true,
      user_metadata: { role: 'admin' }
    })

    adminClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )
    await adminClient.auth.signInWithPassword({
      email: 'admin@test.com',
      password: 'password123'
    })

    // Create regular user
    const { data: userData } = await serviceClient.auth.admin.createUser({
      email: 'user@test.com',
      password: 'password123',
      email_confirm: true
    })

    userClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )
    await userClient.auth.signInWithPassword({
      email: 'user@test.com',
      password: 'password123'
    })
  })

  test('admin can view all profiles', async () => {
    const { data, error } = await adminClient
      .from('profiles')
      .select()
    
    expect(error).toBeNull()
    expect(data.length).toBeGreaterThan(1)
  })

  test('regular user cannot view all profiles', async () => {
    const { data, error } = await userClient
      .from('profiles')
      .select()
    
    // Should only see own profile
    expect(data.length).toBe(1)
  })
})
```

### Testing Anonymous Access

```javascript
test('anonymous users cannot access protected data', async () => {
  const anonClient = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  )

  const { data, error } = await anonClient
    .from('profiles')
    .select()
  
  expect(data).toEqual([])
})

test('public data is accessible anonymously', async () => {
  const anonClient = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  )

  const { data, error } = await anonClient
    .from('public_posts')
    .select()
  
  expect(error).toBeNull()
  expect(data.length).toBeGreaterThan(0)
})
```

