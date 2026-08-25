## Mocking Supabase Client


Mocking the Supabase client enables fast unit tests without database dependencies and allows testing error scenarios.

### Jest Mock Setup

```javascript
// __mocks__/@supabase/supabase-js.js
export const createClient = jest.fn(() => ({
  from: jest.fn(() => ({
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn(),
  })),
  auth: {
    signInWithPassword: jest.fn(),
    signUp: jest.fn(),
    signOut: jest.fn(),
    getSession: jest.fn(),
  },
  rpc: jest.fn(),
  storage: {
    from: jest.fn(() => ({
      upload: jest.fn(),
      download: jest.fn(),
      remove: jest.fn(),
    })),
  },
}))
```

### Using Mocks in Tests

```javascript
// service.test.js
jest.mock('@supabase/supabase-js')
import { createClient } from '@supabase/supabase-js'
import { UserService } from './user-service'

describe('UserService', () => {
  let mockSupabase
  let userService

  beforeEach(() => {
    mockSupabase = createClient()
    userService = new UserService(mockSupabase)
  })

  afterEach(() => {
    jest.clearAllMocks()
  })

  test('getUserById returns user data', async () => {
    const mockUser = { id: 1, name: 'John Doe', email: 'john@example.com' }
    
    mockSupabase.from().select().eq().single.mockResolvedValue({
      data: mockUser,
      error: null
    })

    const result = await userService.getUserById(1)

    expect(mockSupabase.from).toHaveBeenCalledWith('users')
    expect(mockSupabase.from().select).toHaveBeenCalled()
    expect(mockSupabase.from().eq).toHaveBeenCalledWith('id', 1)
    expect(result).toEqual(mockUser)
  })

  test('getUserById handles errors', async () => {
    const mockError = { message: 'User not found' }
    
    mockSupabase.from().select().eq().single.mockResolvedValue({
      data: null,
      error: mockError
    })

    await expect(userService.getUserById(999)).rejects.toThrow('User not found')
  })
})
```

### Manual Mock Implementation

```javascript
// supabase-mock.js
export class SupabaseMock {
  constructor() {
    this.data = {
      users: [],
      orders: [],
    }
  }

  from(table) {
    return {
      select: (columns = '*') => ({
        eq: (column, value) => ({
          single: async () => {
            const item = this.data[table].find(row => row[column] === value)
            return { data: item || null, error: item ? null : { message: 'Not found' } }
          },
          then: async (resolve) => {
            const items = this.data[table].filter(row => row[column] === value)
            resolve({ data: items, error: null })
          }
        }),
        then: async (resolve) => {
          resolve({ data: this.data[table], error: null })
        }
      }),
      insert: (rows) => ({
        select: () => ({
          then: async (resolve) => {
            const newRows = Array.isArray(rows) ? rows : [rows]
            this.data[table].push(...newRows)
            resolve({ data: newRows, error: null })
          }
        })
      }),
      update: (updates) => ({
        eq: (column, value) => ({
          then: async (resolve) => {
            this.data[table] = this.data[table].map(row =>
              row[column] === value ? { ...row, ...updates } : row
            )
            resolve({ data: null, error: null })
          }
        })
      }),
      delete: () => ({
        eq: (column, value) => ({
          then: async (resolve) => {
            this.data[table] = this.data[table].filter(row => row[column] !== value)
            resolve({ data: null, error: null })
          }
        })
      })
    }
  }

  reset() {
    Object.keys(this.data).forEach(key => {
      this.data[key] = []
    })
  }
}
```

### Using Manual Mock

```javascript
import { SupabaseMock } from './supabase-mock'

describe('UserService with Manual Mock', () => {
  let supabase
  let userService

  beforeEach(() => {
    supabase = new SupabaseMock()
    supabase.data.users = [
      { id: 1, name: 'John Doe', email: 'john@example.com' },
      { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
    ]
    userService = new UserService(supabase)
  })

  test('getAllUsers returns all users', async () => {
    const users = await userService.getAllUsers()
    expect(users).toHaveLength(2)
  })

  test('createUser adds new user', async () => {
    await userService.createUser({
      id: 3,
      name: 'Bob Johnson',
      email: 'bob@example.com'
    })

    expect(supabase.data.users).toHaveLength(3)
    expect(supabase.data.users[2].name).toBe('Bob Johnson')
  })
})
```

