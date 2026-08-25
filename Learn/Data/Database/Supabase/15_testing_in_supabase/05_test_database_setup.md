## Test Database Setup


A dedicated test database ensures tests run in isolation without affecting production or development data.

### Local Test Database with Docker

```yaml
# docker-compose.test.yml
version: '3.8'
services:
  postgres:
    image: supabase/postgres:15.1.0.117
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "54322:5432"
    volumes:
      - ./test-migrations:/docker-entrypoint-initdb.d
```

```bash
# Start test database
docker-compose -f docker-compose.test.yml up -d

# Run migrations
psql -h localhost -p 54322 -U postgres -d test_db -f migrations/001_initial.sql
```

### Supabase CLI Test Project

```bash
# Initialize local Supabase project
supabase init

# Start local instance
supabase start

# Apply migrations
supabase db push

# Get connection details
supabase status
```

```javascript
// test-setup.js
import { createClient } from '@supabase/supabase-js'
import { execSync } from 'child_process'

export const setupTestDatabase = async () => {
  // Reset database
  execSync('supabase db reset --local', { stdio: 'inherit' })

  // Create client
  const supabase = createClient(
    process.env.SUPABASE_LOCAL_URL || 'http://localhost:54321',
    process.env.SUPABASE_LOCAL_ANON_KEY
  )

  return supabase
}

// jest.setup.js
beforeAll(async () => {
  global.supabase = await setupTestDatabase()
})
```

### Database Snapshots

```javascript
// snapshot.js
import { execSync } from 'child_process'
import fs from 'fs'

export class DatabaseSnapshot {
  constructor(connectionString) {
    this.connectionString = connectionString
    this.snapshotPath = './test-snapshots'
  }

  async create(name) {
    if (!fs.existsSync(this.snapshotPath)) {
      fs.mkdirSync(this.snapshotPath)
    }

    execSync(
      `pg_dump ${this.connectionString} > ${this.snapshotPath}/${name}.sql`,
      { stdio: 'inherit' }
    )
  }

  async restore(name) {
    execSync(
      `psql ${this.connectionString} < ${this.snapshotPath}/${name}.sql`,
      { stdio: 'inherit' }
    )
  }
}
```

```javascript
// Usage in tests
import { DatabaseSnapshot } from './snapshot'

describe('Test Suite with Snapshots', () => {
  const snapshot = new DatabaseSnapshot(process.env.TEST_DATABASE_URL)

  beforeAll(async () => {
    await snapshot.create('clean-state')
  })

  afterEach(async () => {
    await snapshot.restore('clean-state')
  })

  // Tests here
})
```

### Isolated Test Transactions

```javascript
// transaction-wrapper.js
export const withTransaction = async (supabase, testFn) => {
  const { data, error } = await supabase.rpc('begin_test_transaction')
  
  try {
    await testFn(supabase)
  } finally {
    await supabase.rpc('rollback_test_transaction')
  }
}
```

```sql
-- Transaction management functions
CREATE OR REPLACE FUNCTION begin_test_transaction()
RETURNS void AS $$
BEGIN
  -- Create savepoint
  EXECUTE 'SAVEPOINT test_transaction';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rollback_test_transaction()
RETURNS void AS $$
BEGIN
  -- Rollback to savepoint
  EXECUTE 'ROLLBACK TO SAVEPOINT test_transaction';
END;
$$ LANGUAGE plpgsql;
```

