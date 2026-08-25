## CI/CD Integration


Continuous integration ensures tests run automatically on every code change, maintaining code quality and catching issues early.

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  SUPABASE_URL: ${{ secrets.SUPABASE_TEST_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_TEST_ANON_KEY }}
  SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_TEST_SERVICE_KEY }}

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: supabase/postgres:15.1.0.117
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
        with:
          version: latest

      - name: Start Supabase local
        run: supabase start

      - name: Run database migrations
        run: supabase db push

      - name: Seed test database
        run: npm run seed:test

      - name: Run unit tests
        run: npm run test:unit

      - name: Run integration tests
        run: npm run test:integration

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
          flags: unittests
          name: codecov-umbrella

      - name: Stop Supabase
        if: always()
        run: supabase stop
```

### GitLab CI Configuration

```yaml
# .gitlab-ci.yml
variables:
  POSTGRES_DB: test_db
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres
  POSTGRES_HOST_AUTH_METHOD: trust

stages:
  - setup
  - test
  - cleanup

before_script:
  - npm ci

services:
  - postgres:15

setup_database:
  stage: setup
  image: supabase/postgres:15.1.0.117
  script:
    - psql -h postgres -U postgres -d test_db -f migrations/001_initial.sql
    - psql -h postgres -U postgres -d test_db -f seeds/test-data.sql
  only:
    - merge_requests
    - main

unit_tests:
  stage: test
  image: node:18
  script:
    - npm run test:unit -- --coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

integration_tests:
  stage: test
  image: node:18
  services:
    - postgres:15
  variables:
    DATABASE_URL: postgresql://postgres:postgres@postgres:5432/test_db
  script:
    - npm run test:integration
  dependencies:
    - setup_database

e2e_tests:
  stage: test
  image: node:18
  services:
    - postgres:15
  script:
    - npm run test:e2e
  dependencies:
    - setup_database
  only:
    - merge_requests
    - main

cleanup:
  stage: cleanup
  script:
    - echo "Cleaning up test resources"
  when: always
```

### CircleCI Configuration

```yaml
# .circleci/config.yml
version: 2.1

orbs:
  node: circleci/node@5.0.2

jobs:
  test:
    docker:
      - image: cimg/node:18.16
      - image: supabase/postgres:15.1.0.117
        environment:
          POSTGRES_DB: test_db
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres

    steps:
      - checkout
      
      - node/install-packages:
          pkg-manager: npm

      - run:
          name: Wait for database
          command: |
            dockerize -wait tcp://localhost:5432 -timeout 1m

      - run:
          name: Run migrations
          command: |
            psql -h localhost -U postgres -d test_db -f migrations/001_initial.sql

      - run:
          name: Seed database
          command: npm run seed:test

      - run:
          name: Run tests
          command: npm run test:ci

      - store_test_results:
          path: test-results

      - store_artifacts:
          path: coverage

workflows:
  test_and_deploy:
    jobs:
      - test:
          filters:
            branches:
              only:
                - main
                - develop
```

### Package.json Test Scripts

```json
{
  "scripts": {
    "test": "jest",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "test:e2e": "jest --testPathPattern=e2e",
    "test:ci": "jest --ci --coverage --maxWorkers=2",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "seed:test": "node scripts/seed-test-db.js",
    "db:reset": "supabase db reset --local",
    "db:setup": "npm run db:reset && npm run seed:test"
  }
}
```

### Pre-commit Hooks

```yaml
# .husky/pre-commit
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npm run test:unit
```

```json
// package.json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "jest --bail --findRelatedTests"
    ]
  }
}
```

### Docker Compose for CI

```yaml
# docker-compose.ci.yml
version: '3.8'

services:
  postgres:
    image: supabase/postgres:15.1.0.117
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  test-runner:
    build: .
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://postgres:postgres@postgres:5432/test_db
      SUPABASE_URL: ${SUPABASE_URL}
      SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY}
    command: npm run test:ci
```

