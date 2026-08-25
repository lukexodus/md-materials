## Integration Testing with Supabase


Integration tests verify the complete flow of operations across database, authentication, and client interactions.

### Test Environment Setup

```javascript
// test-config.js
export const testConfig = {
  supabaseUrl: process.env.SUPABASE_TEST_URL,
  supabaseAnonKey: process.env.SUPABASE_TEST_ANON_KEY,
  supabaseServiceKey: process.env.SUPABASE_TEST_SERVICE_KEY
}

// test-helpers.js
import { createClient } from '@supabase/supabase-js'
import { testConfig } from './test-config'

export const createTestClient = () => {
  return createClient(testConfig.supabaseUrl, testConfig.supabaseAnonKey)
}

export const createAdminClient = () => {
  return createClient(testConfig.supabaseUrl, testConfig.supabaseServiceKey)
}

export const cleanupTestData = async (tableName, filters = {}) => {
  const admin = createAdminClient()
  let query = admin.from(tableName).delete()
  
  Object.entries(filters).forEach(([key, value]) => {
    query = query.eq(key, value)
  })
  
  await query
}
```

### End-to-End Flow Testing

```javascript
// integration.test.js
import { createTestClient, createAdminClient, cleanupTestData } from './test-helpers'

describe('Order Creation Flow', () => {
  let client, admin, testUser

  beforeAll(async () => {
    client = createTestClient()
    admin = createAdminClient()

    // Create test user
    const { data } = await admin.auth.admin.createUser({
      email: 'test@example.com',
      password: 'testpass123',
      email_confirm: true
    })
    testUser = data.user

    // Sign in
    await client.auth.signInWithPassword({
      email: 'test@example.com',
      password: 'testpass123'
    })
  })

  afterAll(async () => {
    await cleanupTestData('order_items', { order_id: 999 })
    await cleanupTestData('orders', { id: 999 })
    await admin.auth.admin.deleteUser(testUser.id)
  })

  test('complete order creation and retrieval', async () => {
    // Step 1: Create order
    const { data: order, error: orderError } = await client
      .from('orders')
      .insert({
        id: 999,
        customer_id: testUser.id,
        status: 'pending'
      })
      .select()
      .single()

    expect(orderError).toBeNull()
    expect(order.id).toBe(999)

    // Step 2: Add order items
    const { data: items, error: itemsError } = await client
      .from('order_items')
      .insert([
        { order_id: 999, product_id: 1, quantity: 2, price: 10.00 },
        { order_id: 999, product_id: 2, quantity: 1, price: 20.00 }
      ])
      .select()

    expect(itemsError).toBeNull()
    expect(items).toHaveLength(2)

    // Step 3: Calculate total
    const { data: total, error: totalError } = await client
      .rpc('calculate_order_total', { order_id: 999 })

    expect(totalError).toBeNull()
    expect(total).toBe(40.00)

    // Step 4: Retrieve order with items
    const { data: fullOrder, error: fetchError } = await client
      .from('orders')
      .select(`
        *,
        order_items (
          product_id,
          quantity,
          price
        )
      `)
      .eq('id', 999)
      .single()

    expect(fetchError).toBeNull()
    expect(fullOrder.order_items).toHaveLength(2)
  })
})
```

### Testing Real-time Subscriptions

```javascript
describe('Real-time Subscriptions', () => {
  test('receives insert notifications', async (done) => {
    const client = createTestClient()
    let receivedData = null

    const channel = client
      .channel('test-channel')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages'
        },
        (payload) => {
          receivedData = payload.new
        }
      )
      .subscribe()

    // Wait for subscription to be ready
    await new Promise(resolve => setTimeout(resolve, 1000))

    // Insert test data
    await client.from('messages').insert({
      content: 'Test message',
      user_id: testUser.id
    })

    // Wait for notification
    await new Promise(resolve => setTimeout(resolve, 2000))

    expect(receivedData).not.toBeNull()
    expect(receivedData.content).toBe('Test message')

    await channel.unsubscribe()
    done()
  }, 10000)
})
```

### Testing File Storage

```javascript
describe('Storage Operations', () => {
  const bucketName = 'test-bucket'
  
  beforeAll(async () => {
    const admin = createAdminClient()
    await admin.storage.createBucket(bucketName, { public: false })
  })

  afterAll(async () => {
    const admin = createAdminClient()
    const { data: files } = await admin.storage.from(bucketName).list()
    await Promise.all(
      files.map(file => admin.storage.from(bucketName).remove([file.name]))
    )
    await admin.storage.deleteBucket(bucketName)
  })

  test('upload and download file', async () => {
    const client = createTestClient()
    const fileName = 'test-file.txt'
    const fileContent = 'Hello, Supabase!'

    // Upload
    const { error: uploadError } = await client.storage
      .from(bucketName)
      .upload(fileName, new Blob([fileContent], { type: 'text/plain' }))

    expect(uploadError).toBeNull()

    // Download
    const { data, error: downloadError } = await client.storage
      .from(bucketName)
      .download(fileName)

    expect(downloadError).toBeNull()
    const text = await data.text()
    expect(text).toBe(fileContent)
  })

  test('respects storage policies', async () => {
    const client = createTestClient()
    
    // Attempt to access another user's file
    const { error } = await client.storage
      .from(bucketName)
      .download('unauthorized-file.txt')

    expect(error).not.toBeNull()
  })
})
```

