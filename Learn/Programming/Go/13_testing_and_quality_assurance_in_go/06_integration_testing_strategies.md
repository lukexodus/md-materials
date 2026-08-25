## Integration Testing Strategies


Integration testing validates that different components work correctly together, bridging the gap between unit tests and full system tests.

**Key Points:**

- Test real interactions between components
- Use test databases, external service stubs, or containerized dependencies
- Focus on interface boundaries and data flow
- Balance test isolation with realistic scenarios
- Consider test data management and cleanup strategies

**Example:**

```go
// integration_test.go
package integration

import (
    "context"
    "database/sql"
    "fmt"
    "net/http"
    "net/http/httptest"
    "os"
    "testing"
    "time"

    _ "github.com/lib/pq" // PostgreSQL driver
)

// Integration test setup
type TestSuite struct {
    db     *sql.DB
    server *httptest.Server
    client *http.Client
}

func (ts *TestSuite) SetupSuite() error {
    // Setup test database
    dbURL := os.Getenv("TEST_DATABASE_URL")
    if dbURL == "" {
        dbURL = "postgres://testuser:testpass@localhost/testdb?sslmode=disable"
    }
    
    db, err := sql.Open("postgres", dbURL)
    if err != nil {
        return fmt.Errorf("failed to connect to test database: %w", err)
    }
    ts.db = db
    
    // Setup test server
    handler := NewAPIHandler(db)
    ts.server = httptest.NewServer(handler)
    ts.client = &http.Client{Timeout: 10 * time.Second}
    
    // Run database migrations
    if err := ts.runMigrations(); err != nil {
        return fmt.Errorf("failed to run migrations: %w", err)
    }
    
    return nil
}

func (ts *TestSuite) TearDownSuite() error {
    if ts.server != nil {
        ts.server.Close()
    }
    
    if ts.db != nil {
        // Clean up test data
        ts.db.Exec("TRUNCATE TABLE users, orders CASCADE")
        ts.db.Close()
    }
    
    return nil
}

func (ts *TestSuite) runMigrations() error {
    migrations := []string{
        `CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            created_at TIMESTAMP DEFAULT NOW()
        )`,
        `CREATE TABLE IF NOT EXISTS orders (
            id SERIAL PRIMARY KEY,
            user_id INTEGER REFERENCES users(id),
            amount DECIMAL(10,2) NOT NULL,
            status VARCHAR(50) DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT NOW()
        )`,
    }
    
    for _, migration := range migrations {
        if _, err := ts.db.Exec(migration); err != nil {
            return err
        }
    }
    
    return nil
}

// Database integration tests
func TestDatabaseIntegration(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping integration tests in short mode")
    }
    
    suite := &TestSuite{}
    if err := suite.SetupSuite(); err != nil {
        t.Fatalf("Failed to setup test suite: %v", err)
    }
    defer suite.TearDownSuite()
    
    t.Run("UserCRUDOperations", func(t *testing.T) {
        testUserCRUD(t, suite.db)
    })
    
    t.Run("OrderProcessing", func(t *testing.T) {
        testOrderProcessing(t, suite.db)
    })
    
    t.Run("TransactionalOperations", func(t *testing.T) {
        testTransactionalOperations(t, suite.db)
    })
}

func testUserCRUD(t *testing.T, db *sql.DB) {
    ctx := context.Background()
    
    // Create user
    var userID int
    err := db.QueryRowContext(ctx,
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
        "John Doe", "john@example.com").Scan(&userID)
    if err != nil {
        t.Fatalf("Failed to create user: %v", err)
    }
    
    // Read user
    var name, email string
    var createdAt time.Time
    err = db.QueryRowContext(ctx,
        "SELECT name, email, created_at FROM users WHERE id = $1",
        userID).Scan(&name, &email, &createdAt)
    if err != nil {
        t.Fatalf("Failed to read user: %v", err)
    }
    
    if name != "John Doe" {
        t.Errorf("Name = %s, want %s", name, "John Doe")
    }
    if email != "john@example.com" {
        t.Errorf("Email = %s, want %s", email, "john@example.com")
    }
    
    // Update user
    _, err = db.ExecContext(ctx,
        "UPDATE users SET name = $1 WHERE id = $2",
        "John Smith", userID)
    if err != nil {
        t.Fatalf("Failed to update user: %v", err)
    }
    
    // Verify update
    err = db.QueryRowContext(ctx,
        "SELECT name FROM users WHERE id = $1", userID).Scan(&name)
    if err != nil {
        t.Fatalf("Failed to verify update: %v", err)
    }
    if name != "John Smith" {
        t.Errorf("Updated name = %s, want %s", name, "John Smith")
    }
    
    // Delete user
    _, err = db.ExecContext(ctx, "DELETE FROM users WHERE id = $1", userID)
    if err != nil {
        t.Fatalf("Failed to delete user: %v", err)
    }
    
    // Verify deletion
    err = db.QueryRowContext(ctx,
        "SELECT name FROM users WHERE id = $1", userID).Scan(&name)
    if err != sql.ErrNoRows {
        t.Error("User should be deleted")
    }
}

func testOrderProcessing(t *testing.T, db *sql.DB) {
    ctx := context.Background()
    
    // Create test user
    var userID int
    err := db.QueryRowContext(ctx,
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
        "Test User", "test@example.com").Scan(&userID)
    if err != nil {
        t.Fatalf("Failed to create test user: %v", err)
    }
    defer db.ExecContext(ctx, "DELETE FROM users WHERE id = $1", userID)
    
    // Create order
    var orderID int
    err = db.QueryRowContext(ctx,
        "INSERT INTO orders (user_id, amount, status) VALUES ($1, $2, $3) RETURNING id",
        userID, 99.99, "pending").Scan(&orderID)
    if err != nil {
        t.Fatalf("Failed to create order: %v", err)
    }
    
    // Update order status
    _, err = db.ExecContext(ctx,
        "UPDATE orders SET status = $1 WHERE id = $2",
        "completed", orderID)
    if err != nil {
        t.Fatalf("Failed to update order status: %v", err)
    }
    
    // Verify order with user join
    var userName string
    var orderAmount float64
    var orderStatus string
    err = db.QueryRowContext(ctx, `
        SELECT u.name, o.amount, o.status 
        FROM orders o 
        JOIN users u ON o.user_id = u.id 
        WHERE o.id = $1`,
        orderID).Scan(&userName, &orderAmount, &orderStatus)
    if err != nil {
        t.Fatalf("Failed to query order with user: %v", err)
    }
    
    if userName != "Test User" {
        t.Errorf("User name = %s, want %s", userName, "Test User")
    }
    if orderAmount != 99.99 {
        t.Errorf("Order amount = %f, want %f", orderAmount, 99.99)
    }
    if orderStatus != "completed" {
        t.Errorf("Order status = %s, want %s", orderStatus, "completed")
    }
}

func testTransactionalOperations(t *testing.T, db *sql.DB) {
    ctx := context.Background()
    
    // Test successful transaction
    t.Run("SuccessfulTransaction", func(t *testing.T) {
        tx, err := db.BeginTx(ctx, nil)
        if err != nil {
            t.Fatalf("Failed to begin transaction: %v", err)
        }
        
        var userID int
        err = tx.QueryRowContext(ctx,
            "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
            "Transaction User", "transaction@example.com").Scan(&userID)
        if err != nil {
            tx.Rollback()
            t.Fatalf("Failed to insert user in transaction: %v", err)
        }
        
        _, err = tx.ExecContext(ctx,
            "INSERT INTO orders (user_id, amount) VALUES ($1, $2)",
            userID, 150.00)
        if err != nil {
            tx.Rollback()
            t.Fatalf("Failed to insert order in transaction: %v", err)
        }
        
        if err := tx.Commit(); err != nil {
            t.Fatalf("Failed to commit transaction: %v", err)
        }
        
        // Verify data exists
        var count int
        db.QueryRowContext(ctx,
            "SELECT COUNT(*) FROM users WHERE email = $1",
            "transaction@example.com").Scan(&count)
        if count != 1 {
            t.Error("User should exist after successful transaction")
        }
        
        // Cleanup
        db.ExecContext(ctx, "DELETE FROM users WHERE id = $1", userID)
    })
    
    // Test failed transaction (rollback)
    t.Run("FailedTransaction", func(t *testing.T) {
        tx, err := db.BeginTx(ctx, nil)
        if err != nil {
            t.Fatalf("Failed to begin transaction: %v", err)
        }
        
        var userID int
        err = tx.QueryRowContext(ctx,
            "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
            "Rollback User", "rollback@example.com").Scan(&userID)
        if err != nil {
            tx.Rollback()
            t.Fatalf("Failed to insert user in transaction: %v", err)
        }
        
        // Intentionally cause an error (invalid user_id reference)
        _, err = tx.ExecContext(ctx,
            "INSERT INTO orders (user_id, amount) VALUES ($1, $2)",
            99999, 150.00) // Non-existent user_id
        
        // Rollback on error
        tx.Rollback()
        
        // Verify data was rolled back
        var count int
        db.QueryRowContext(ctx,
            "SELECT COUNT(*) FROM users WHERE email = $1",
            "rollback@example.com").Scan(&count)
        if count != 0 {
            t.Error("User should not exist after transaction rollback")
        }
    })
}

// HTTP API integration tests
func TestAPIIntegration(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping integration tests in short mode")
    }
    
    suite := &TestSuite{}
    if err := suite.SetupSuite(); err != nil {
        t.Fatalf("Failed to setup test suite: %v", err)
    }
    defer suite.TearDownSuite()
    
    t.Run("UserAPIEndpoints", func(t *testing.T) {
        testUserAPI(t, suite)
    })
    
    t.Run("OrderAPIEndpoints", func(t *testing.T) {
        testOrderAPI(t, suite)
    })
    
    t.Run("ErrorHandling", func(t *testing.T) {
        testAPIErrorHandling(t, suite)
    })
}

func testUserAPI(t *testing.T, suite *TestSuite) {
    // Test POST /users
    userData := `{"name":"API Test User","email":"apitest@example.com"}`
    resp, err := suite.client.Post(
        suite.server.URL+"/users",
        "application/json",
        strings.NewReader(userData))
    if err != nil {
        t.Fatalf("Failed to create user via API: %v", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusCreated {
        t.Errorf("POST /users status = %d, want %d", resp.StatusCode, http.StatusCreated)
    }
    
    var createResp struct {
        ID    int    `json:"id"`
        Name  string `json:"name"`
        Email string `json:"email"`
    }
    
    if err := json.NewDecoder(resp.Body).Decode(&createResp); err != nil {
        t.Fatalf("Failed to decode create response: %v", err)
    }
    
    userID := createResp.ID
    
    // Test GET /users/{id}
    resp, err = suite.client.Get(fmt.Sprintf("%s/users/%d", suite.server.URL, userID))
    if err != nil {
        t.Fatalf("Failed to get user via API: %v", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusOK {
        t.Errorf("GET /users/{id} status = %d, want %d", resp.StatusCode, http.StatusOK)
    }
    
    var getResp struct {
        ID    int    `json:"id"`
        Name  string `json:"name"`
        Email string `json:"email"`
    }
    
    if err := json.NewDecoder(resp.Body).Decode(&getResp); err != nil {
        t.Fatalf("Failed to decode get response: %v", err)
    }
    
    if getResp.Name != "API Test User" {
        t.Errorf("User name = %s, want %s", getResp.Name, "API Test User")
    }
    
    // Cleanup
    req, _ := http.NewRequest(http.MethodDelete,
        fmt.Sprintf("%s/users/%d", suite.server.URL, userID), nil)
    suite.client.Do(req)
}

func testOrderAPI(t *testing.T, suite *TestSuite) {
    // Create test user first
    userData := `{"name":"Order Test User","email":"ordertest@example.com"}`
    resp, err := suite.client.Post(
        suite.server.URL+"/users",
        "application/json",
        strings.NewReader(userData))
    if err != nil {
        t.Fatalf("Failed to create user for order test: %v", err)
    }
    defer resp.Body.Close()
    
    var userResp struct {
        ID int `json:"id"`
    }
    json.NewDecoder(resp.Body).Decode(&userResp)
    userID := userResp.ID
    
    // Create order
    orderData := fmt.Sprintf(`{"user_id":%d,"amount":75.50}`, userID)
    resp, err = suite.client.Post(
        suite.server.URL+"/orders",
        "application/json",
        strings.NewReader(orderData))
    if err != nil {
        t.Fatalf("Failed to create order via API: %v", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusCreated {
        t.Errorf("POST /orders status = %d, want %d", resp.StatusCode, http.StatusCreated)
    }
    
    // Test GET /users/{id}/orders
    resp, err = suite.client.Get(
        fmt.Sprintf("%s/users/%d/orders", suite.server.URL, userID))
    if err != nil {
        t.Fatalf("Failed to get user orders via API: %v", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusOK {
        t.Errorf("GET /users/{id}/orders status = %d, want %d", resp.StatusCode, http.StatusOK)
    }
    
    var ordersResp []struct {
        ID     int     `json:"id"`
        Amount float64 `json:"amount"`
        Status string  `json:"status"`
    }
    
    if err := json.NewDecoder(resp.Body).Decode(&ordersResp); err != nil {
        t.Fatalf("Failed to decode orders response: %v", err)
    }
    
    if len(ordersResp) != 1 {
        t.Errorf("Expected 1 order, got %d", len(ordersResp))
    }
    
    if ordersResp[0].Amount != 75.50 {
        t.Errorf("Order amount = %f, want %f", ordersResp[0].Amount, 75.50)
    }
    
    // Cleanup
    req, _ := http.NewRequest(http.MethodDelete,
        fmt.Sprintf("%s/users/%d", suite.server.URL, userID), nil)
    suite.client.Do(req)
}

func testAPIErrorHandling(t *testing.T, suite *TestSuite) {
    // Test invalid JSON
    resp, err := suite.client.Post(
        suite.server.URL+"/users",
        "application/json",
        strings.NewReader(`{"name":"Test","email":}`)) // Invalid JSON
    if err != nil {
        t.Fatalf("Failed to send invalid JSON: %v", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusBadRequest {
        t.Errorf("Invalid JSON status = %d, want %d", resp.StatusCode, http.StatusBadRequest)
    }
    
    // Test missing required fields
    resp, err = suite.client.Post(
        suite.server.URL+"/users",
        "application/json",
        strings.NewReader(`{"name":"Test"}`)) // Missing email
    if err != nil {
        t.Fatalf("Failed to send incomplete data: %v", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusBadRequest {
        t.Errorf("Missing field status = %d, want %d", resp.StatusCode, http.StatusBadRequest)
    }
    
    // Test non-existent resource
    resp, err = suite.client.Get(suite.server.URL + "/users/99999")
    if err != nil {
        t.Fatalf("Failed to request non-existent user: %v", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusNotFound {
        t.Errorf("Non-existent user status = %d, want %d", resp.StatusCode, http.StatusNotFound)
    }
}

// Container-based integration testing
func TestWithDockerContainer(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping container-based integration tests in short mode")
    }
    
    // This would typically use testcontainers-go or similar library
    // [Inference] Container-based testing provides isolated, reproducible environments
    
    containerSetup := func() (*sql.DB, func(), error) {
        // Start PostgreSQL container
        // This is pseudocode - actual implementation would use testcontainers
        container := startPostgreSQLContainer()
        
        db, err := sql.Open("postgres", container.ConnectionString())
        if err != nil {
            return nil, nil, err
        }
        
        cleanup := func() {
            db.Close()
            container.Terminate()
        }
        
        return db, cleanup, nil
    }
    
    db, cleanup, err := containerSetup()
    if err != nil {
        t.Skip("Container setup failed, skipping container-based tests")
    }
    defer cleanup()
    
    // Run tests with containerized database
    testUserCRUD(t, db)
}

// Performance integration tests
func TestIntegrationPerformance(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping performance integration tests in short mode")
    }
    
    suite := &TestSuite{}
    if err := suite.SetupSuite(); err != nil {
        t.Fatalf("Failed to setup test suite: %v", err)
    }
    defer suite.TearDownSuite()
    
    // Test bulk operations performance
    t.Run("BulkUserCreation", func(t *testing.T) {
        start := time.Now()
        
        tx, err := suite.db.Begin()
        if err != nil {
            t.Fatalf("Failed to begin transaction: %v", err)
        }
        defer tx.Rollback()
        
        stmt, err := tx.Prepare("INSERT INTO users (name, email) VALUES ($1, $2)")
        if err != nil {
            t.Fatalf("Failed to prepare statement: %v", err)
        }
        defer stmt.Close()
        
        const numUsers = 1000
        for i := 0; i < numUsers; i++ {
            _, err := stmt.Exec(
                fmt.Sprintf("User %d", i),
                fmt.Sprintf("user%d@example.com", i))
            if err != nil {
                t.Fatalf("Failed to insert user %d: %v", i, err)
            }
        }
        
        if err := tx.Commit(); err != nil {
            t.Fatalf("Failed to commit transaction: %v", err)
        }
        
        duration := time.Since(start)
        t.Logf("Created %d users in %v (%v per user)", numUsers, duration, duration/numUsers)
        
        // Performance assertion - adjust threshold based on requirements
        if duration > 5*time.Second {
            t.Errorf("Bulk creation took %v, expected < 5s", duration)
        }
    })
}
```

**Test Environment Management:**

```go
// test_helpers.go
package integration

import (
    "os"
    "testing"
)

// TestMain provides setup and teardown for the entire test suite
func TestMain(m *testing.M) {
    // Global setup
    setup()
    
    // Run tests
    code := m.Run()
    
    // Global teardown
    teardown()
    
    os.Exit(code)
}

func setup() {
    // Set test environment variables
    os.Setenv("APP_ENV", "test")
    os.Setenv("LOG_LEVEL", "error")
    
    // Initialize test databases, external service mocks, etc.
}

func teardown() {
    // Clean up global resources
}

// Helper functions for common test operations
func createTestUser(db *sql.DB, name, email string) (int, error) {
    var id int
    err := db.QueryRow(
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
        name, email).Scan(&id)
    return id, err
}

func cleanupTestData(db *sql.DB) error {
    tables := []string{"orders", "users"} // Order matters due to foreign keys
    for _, table := range tables {
        if _, err := db.Exec(fmt.Sprintf("TRUNCATE TABLE %s CASCADE", table)); err != nil {
            return err
        }
    }
    return nil
}
```

**Configuration for Different Test Types:**

```bash
# Run only unit tests
go test -short ./...

# Run integration tests
go test -tags=integration ./...

# Run with coverage
go test -cover -coverprofile=coverage.out ./...

# Run benchmarks
go test -bench=. -benchmem ./...

# Run tests with race detection
go test -race ./...

# Parallel test execution
go test -parallel 4 ./...
```

Integration testing bridges the gap between isolated unit tests and full end-to-end testing. [Inference] Well-designed integration tests catch issues that unit tests miss while remaining faster and more reliable than full system tests. The key is to test meaningful component interactions while maintaining test isolation and repeatability.

**Test Data Management Strategies:**

- Database transactions with rollbacks for isolated tests
- Test-specific databases or schemas
- Data factories for generating consistent test data
- Cleanup procedures to prevent test interference
- Seed data for establishing known baseline states

**Important Related Topics:**

- Contract testing for API compatibility verification
- End-to-end testing frameworks and strategies
- Test environment provisioning and management
- Continuous integration pipeline integration
- Performance testing and load testing methodologies
- Chaos engineering and fault injection testing

---

