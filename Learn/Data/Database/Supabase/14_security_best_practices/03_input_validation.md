## Input Validation


Input validation prevents malformed, malicious, or unexpected data from entering your database and protects against various attack vectors.

**Database-level constraints:**

PostgreSQL constraints provide the first line of defense:

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  age INTEGER CHECK (age >= 0 AND age <= 150),
  username TEXT NOT NULL CHECK (LENGTH(username) BETWEEN 3 AND 30),
  status TEXT CHECK (status IN ('active', 'suspended', 'deleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Check constraints** enforce business rules at the database level. They execute on every insert and update, rejecting invalid data before it's committed.

**Domain types:**

Create reusable validation logic with custom domains:

```sql
CREATE DOMAIN email_address AS TEXT
CHECK (VALUE ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

CREATE DOMAIN positive_integer AS INTEGER
CHECK (VALUE > 0);

CREATE TABLE products (
  id UUID PRIMARY KEY,
  contact_email email_address,
  quantity positive_integer
);
```

**Triggers for complex validation:**

```sql
CREATE FUNCTION validate_phone_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.phone !~ '^\+?[1-9]\d{1,14}$' THEN
    RAISE EXCEPTION 'Invalid phone number format';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_phone_before_insert
BEFORE INSERT OR UPDATE ON contacts
FOR EACH ROW
EXECUTE FUNCTION validate_phone_number();
```

**Client-side validation:**

While not a security measure (client-side code can be bypassed), client validation improves user experience:

```javascript
// Example validation before Supabase insert
function validateUserInput(data) {
  const errors = {};
  
  if (!data.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
    errors.email = 'Valid email required';
  }
  
  if (!data.username || data.username.length < 3) {
    errors.username = 'Username must be at least 3 characters';
  }
  
  if (data.age && (data.age < 0 || data.age > 150)) {
    errors.age = 'Age must be between 0 and 150';
  }
  
  return Object.keys(errors).length === 0 ? null : errors;
}
```

**Server-side validation with Edge Functions:**

For complex validation logic not suitable for database constraints:

```javascript
// Edge Function for validation
const validateOrder = (order) => {
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must contain at least one item');
  }
  
  if (order.total_amount !== calculateTotal(order.items)) {
    throw new Error('Total amount mismatch');
  }
  
  // Additional business logic validation
};
```

**Validation strategies:**

- **Whitelist over blacklist**: Define what's allowed rather than what's forbidden
- **Type checking**: Ensure data types match expected schemas
- **Length limits**: Prevent excessively long inputs that could cause performance issues
- **Format validation**: Use regular expressions for structured data (emails, phone numbers, URLs)
- **Range validation**: Numeric values within acceptable bounds
- **Referential integrity**: Foreign key constraints validate relationships automatically
- **Sanitization**: Strip or escape potentially dangerous characters where appropriate

**JSON validation:**

For JSONB columns, use JSON Schema validation:

```sql
CREATE TABLE settings (
  id UUID PRIMARY KEY,
  config JSONB NOT NULL,
  CONSTRAINT valid_config CHECK (
    jsonb_typeof(config->'timeout') = 'number'
    AND (config->>'timeout')::int BETWEEN 1 AND 3600
  )
);
```

