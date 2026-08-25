## Seed Data Management


Seed data provides consistent test fixtures and ensures reproducible test conditions.

### SQL Seed Files

```sql
-- seeds/test-data.sql
-- Clear existing data
TRUNCATE users, orders, order_items CASCADE;

-- Insert test users
INSERT INTO users (id, email, name, role) VALUES
  (1, 'admin@test.com', 'Admin User', 'admin'),
  (2, 'user@test.com', 'Regular User', 'user'),
  (3, 'test@test.com', 'Test User', 'user');

-- Insert test orders
INSERT INTO orders (id, user_id, status, total, created_at) VALUES
  (1, 2, 'completed', 100.00, '2025-01-01'),
  (2, 2, 'pending', 50.00, '2025-01-15'),
  (3, 3, 'completed', 75.00, '2025-02-01');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
  (1, 1, 2, 25.00),
  (1, 2, 2, 25.00),
  (2, 1, 1, 25.00),
  (2, 3, 1, 25.00),
  (3, 2, 3, 25.00);

-- Insert test products
INSERT INTO products (id, name, price, category, stock) VALUES
  (1, 'Product A', 25.00, 'electronics', 100),
  (2, 'Product B', 25.00, 'books', 50),
  (3, 'Product C', 25.00, 'electronics', 75);
```

### JavaScript Seed Functions

```javascript
// seeds/seed-data.js
export const seedUsers = async (supabase) => {
  const users = [
    { id: 1, email: 'admin@test.com', name: 'Admin User', role: 'admin' },
    { id: 2, email: 'user@test.com', name: 'Regular User', role: 'user' },
    { id: 3, email: 'test@test.com', name: 'Test User', role: 'user' }
  ]

  const { error } = await supabase.from('users').insert(users)
  if (error) throw error
  
  return users
}

export const seedOrders = async (supabase, userIds) => {
  const orders = [
    { id: 1, user_id: userIds[1], status: 'completed', total: 100.00 },
    { id: 2, user_id: userIds[1], status: 'pending', total: 50.00 },
    { id: 3, user_id: userIds[2], status: 'completed', total: 75.00 }
  ]

  const { error } = await supabase.from('orders').insert(orders)
  if (error) throw error
  
  return orders
}

export const seedProducts = async (supabase) => {
  const products = [
    { id: 1, name: 'Product A', price: 25.00, category: 'electronics', stock: 100 },
    { id: 2, name: 'Product B', price: 25.00, category: 'books', stock: 50 },
    { id: 3, name: 'Product C', price: 25.00, category: 'electronics', stock: 75 }
  ]

  const { error } = await supabase.from('products').insert(products)
  if (error) throw error
  
  return products
}

export const seedAll = async (supabase) => {
  const users = await seedUsers(supabase)
  const products = await seedProducts(supabase)
  const orders = await seedOrders(supabase, users.map(u => u.id))
  
  return { users, products, orders }
}
```

### Factory Pattern for Test Data

```javascript
// factories/user.factory.js
import { faker } from '@faker-js/faker'

export class UserFactory {
  static create(overrides = {}) {
    return {
      id: faker.number.int(),
      email: faker.internet.email(),
      name: faker.person.fullName(),
      role: 'user',
      created_at: faker.date.past(),
      ...overrides
    }
  }

  static createMany(count, overrides = {}) {
    return Array.from({ length: count }, () => this.create(overrides))
  }

  static async insert(supabase, overrides = {}) {
    const user = this.create(overrides)
    const { data, error } = await supabase
      .from('users')
      .insert(user)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  static async insertMany(supabase, count, overrides = {}) {
    const users = this.createMany(count, overrides)
    const { data, error } = await supabase
      .from('users')
      .insert(users)
      .select()
    
    if (error) throw error
    return data
  }
}
```

```javascript
// factories/order.factory.js
import { faker } from '@faker-js/faker'

export class OrderFactory {
  static create(overrides = {}) {
    return {
      id: faker.number.int(),
      user_id: overrides.user_id || 1,
      status: faker.helpers.arrayElement(['pending', 'completed', 'cancelled']),
      total: parseFloat(faker.commerce.price()),
      created_at: faker.date.past(),
      ...overrides
    }
  }

  static async insert(supabase, overrides = {}) {
    const order = this.create(overrides)
    const { data, error } = await supabase
      .from('orders')
      .insert(order)
      .select()
      .single()
    
    if (error) throw error
    return data
  }

  static async createWithItems(supabase, userId, itemCount = 3) {
    const order = await this.insert(supabase, { user_id: userId })
    
    const items = Array.from({ length: itemCount }, () => ({
      order_id: order.id,
      product_id: faker.number.int({ min: 1, max: 100 }),
      quantity: faker.number.int({ min: 1, max: 5 }),
      price: parseFloat(faker.commerce.price())
    }))

    const { data: orderItems, error } = await supabase
      .from('order_items')
      .insert(items)
      .select()

    if (error) throw error
    
    return { ...order, items: orderItems }
  }
}
```

### Using Factories in Tests

```javascript
import { UserFactory } from './factories/user.factory'
import { OrderFactory } from './factories/order.factory'

describe('Order Service', () => {
  let testUser, testOrders

  beforeEach(async () => {
    // Create test user with factory
    testUser = await UserFactory.insert(supabase, {
      email: 'test@example.com',
      role: 'user'
    })

    // Create multiple test orders
    testOrders = await Promise.all([
      OrderFactory.insert(supabase, { user_id: testUser.id, status: 'completed' }),
      OrderFactory.insert(supabase, { user_id: testUser.id, status: 'pending' }),
      OrderFactory.insert(supabase, { user_id: testUser.id, status: 'cancelled' })
    ])
  })

  afterEach(async () => {
    await supabase.from('order_items').delete().in('order_id', testOrders.map(o => o.id))
    await supabase.from('orders').delete().in('id', testOrders.map(o => o.id))
    await supabase.from('users').delete().eq('id', testUser.id)
  })

  test('getUserOrders returns correct orders', async () => {
    const orders = await orderService.getUserOrders(testUser.id)
    expect(orders).toHaveLength(3)
  })
})
```

### Seed Data Builder Pattern

```javascript
// seed-builder.js
export class SeedBuilder {
  constructor(supabase) {
    this.supabase = supabase
    this.cleanup = []
  }

  async withUser(data = {}) {
    const user = await UserFactory.insert(this.supabase, data)
    this.cleanup.push({ table: 'users', id: user.id })
    return user
  }

  async withOrder(userId, data = {}) {
    const order = await OrderFactory.insert(this.supabase, { 
      user_id: userId, 
      ...data 
    })
    this.cleanup.push({ table: 'orders', id: order.id })
    return order
  }

  async withProduct(data = {}) {
    const product = await ProductFactory.insert(this.supabase, data)
    this.cleanup.push({ table: 'products', id: product.id })
    return product
  }

  async destroy() {
    // Delete in reverse order to respect foreign keys
    for (const item of this.cleanup.reverse()) {
      await this.supabase.from(item.table).delete().eq('id', item.id)
    }
    this.cleanup = []
  }
}
```

```javascript
// Usage
describe('Complex Scenario', () => {
  let seed

  beforeEach(() => {
    seed = new SeedBuilder(supabase)
  })

  afterEach(async () => {
    await seed.destroy()
  })

  test('full order flow', async () => {
    const user = await seed.withUser({ email: 'buyer@test.com' })
    const product = await seed.withProduct({ name: 'Test Product', price: 50.00 })
    const order = await seed.withOrder(user.id, { status: 'pending' })

    // Test logic here
  })
})
```

