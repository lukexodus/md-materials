## ORM Alternatives and Patterns


Go's database ecosystem includes various ORM (Object-Relational Mapping) solutions and patterns, each with different trade-offs between convenience and control.

### GORM

Full-featured ORM with associations, migrations, and hooks.

**Key Features**

- Auto-migration capabilities
- Association handling (has one, has many, many to many)
- Soft deletes and timestamps
- Hook system for callbacks
- Plugin architecture

**Usage Patterns**

```go
type User struct {
    ID    uint   `gorm:"primaryKey"`
    Name  string
    Email string `gorm:"uniqueIndex"`
    Posts []Post
}

// Auto-migration
db.AutoMigrate(&User{})

// Query building
var users []User
db.Where("age > ?", 18).Find(&users)
```

### Sqlx

Extension of database/sql with additional convenience features.

**Key Features**

- Named parameter binding
- Struct scanning without manual field mapping
- Get/Select methods for common patterns
- Maintains compatibility with database/sql

**Usage Patterns**

```go
// Struct scanning
var user User
err := db.Get(&user, "SELECT * FROM users WHERE id=$1", userID)

// Named parameters
_, err = db.NamedExec("INSERT INTO users (name, email) VALUES (:name, :email)", user)
```

### Squirrel

SQL query builder that generates dynamic SQL.

**Key Features**

- Fluent interface for building queries
- Type-safe query construction
- Support for complex joins and subqueries
- Database-agnostic query building

```go
query := squirrel.Select("id", "name", "email").
    From("users").
    Where(squirrel.Gt{"age": 18}).
    OrderBy("name").
    Limit(10)

sql, args, err := query.ToSql()
```

### Ent

Code generation framework for building data access layers.

**Key Features**

- Schema-first approach with code generation
- Type-safe query building
- Graph traversal capabilities
- Migration generation

### Repository Pattern

Common pattern for abstracting database operations:

```go
type UserRepository interface {
    GetByID(ctx context.Context, id int) (*User, error)
    Create(ctx context.Context, user *User) error
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id int) error
}

type postgresUserRepo struct {
    db *sql.DB
}

func (r *postgresUserRepo) GetByID(ctx context.Context, id int) (*User, error) {
    var user User
    query := "SELECT id, name, email FROM users WHERE id = $1"
    err := r.db.QueryRowContext(ctx, query, id).Scan(&user.ID, &user.Name, &user.Email)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrUserNotFound
        }
        return nil, err
    }
    return &user, nil
}
```

