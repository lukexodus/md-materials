## Unit Testing Database Functions


Database functions contain business logic that must be tested in isolation to verify correct behavior across different inputs and edge cases.

### Testing Setup with pgTAP

```sql
-- Enable pgTAP extension
CREATE EXTENSION IF NOT EXISTS pgtap;

-- Create test schema
CREATE SCHEMA IF NOT EXISTS tests;
```

### Basic Function Tests

```sql
-- Function to test
CREATE OR REPLACE FUNCTION calculate_order_total(order_id bigint)
RETURNS numeric AS $$
  SELECT COALESCE(SUM(quantity * price), 0)
  FROM order_items
  WHERE order_id = calculate_order_total.order_id;
$$ LANGUAGE sql;

-- Test function
CREATE OR REPLACE FUNCTION tests.test_calculate_order_total()
RETURNS SETOF TEXT AS $$
BEGIN
  -- Setup test data
  INSERT INTO orders (id, customer_id) VALUES (999, 1);
  INSERT INTO order_items (order_id, product_id, quantity, price)
  VALUES 
    (999, 1, 2, 10.00),
    (999, 2, 3, 15.00);

  -- Test calculation
  RETURN NEXT is(
    calculate_order_total(999),
    65.00::numeric,
    'Order total should be 65.00'
  );

  -- Test empty order
  INSERT INTO orders (id, customer_id) VALUES (998, 1);
  RETURN NEXT is(
    calculate_order_total(998),
    0::numeric,
    'Empty order should return 0'
  );

  -- Cleanup
  DELETE FROM order_items WHERE order_id IN (999, 998);
  DELETE FROM orders WHERE id IN (999, 998);
END;
$$ LANGUAGE plpgsql;

-- Run test
SELECT * FROM runtests('tests'::name);
```

### Testing Function Return Types

```sql
CREATE OR REPLACE FUNCTION tests.test_function_signature()
RETURNS SETOF TEXT AS $$
BEGIN
  RETURN NEXT has_function(
    'public',
    'calculate_order_total',
    ARRAY['bigint'],
    'Function calculate_order_total should exist'
  );

  RETURN NEXT function_returns(
    'public',
    'calculate_order_total',
    ARRAY['bigint'],
    'numeric',
    'Function should return numeric'
  );
END;
$$ LANGUAGE plpgsql;
```

### Testing Error Handling

```sql
CREATE OR REPLACE FUNCTION divide_numbers(a numeric, b numeric)
RETURNS numeric AS $$
BEGIN
  IF b = 0 THEN
    RAISE EXCEPTION 'Division by zero';
  END IF;
  RETURN a / b;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tests.test_divide_numbers()
RETURNS SETOF TEXT AS $$
BEGIN
  -- Test normal operation
  RETURN NEXT is(
    divide_numbers(10, 2),
    5::numeric,
    'Should divide correctly'
  );

  -- Test error condition
  RETURN NEXT throws_ok(
    'SELECT divide_numbers(10, 0)',
    'P0001',
    'Division by zero',
    'Should raise exception for division by zero'
  );
END;
$$ LANGUAGE plpgsql;
```

### Testing with Node.js and Jest

```javascript
// supabase.test.js
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

describe('Database Functions', () => {
  beforeAll(async () => {
    // Setup test data
    await supabase.from('orders').insert({ id: 999, customer_id: 1 })
    await supabase.from('order_items').insert([
      { order_id: 999, product_id: 1, quantity: 2, price: 10.00 },
      { order_id: 999, product_id: 2, quantity: 3, price: 15.00 }
    ])
  })

  afterAll(async () => {
    // Cleanup
    await supabase.from('order_items').delete().eq('order_id', 999)
    await supabase.from('orders').delete().eq('id', 999)
  })

  test('calculate_order_total returns correct sum', async () => {
    const { data, error } = await supabase
      .rpc('calculate_order_total', { order_id: 999 })
    
    expect(error).toBeNull()
    expect(data).toBe(65.00)
  })

  test('calculate_order_total handles empty orders', async () => {
    await supabase.from('orders').insert({ id: 998, customer_id: 1 })
    
    const { data, error } = await supabase
      .rpc('calculate_order_total', { order_id: 998 })
    
    expect(error).toBeNull()
    expect(data).toBe(0)
    
    await supabase.from('orders').delete().eq('id', 998)
  })
})
```

### Testing Complex Functions with Transactions

```javascript
describe('Transaction Functions', () => {
  test('create_order_with_items handles rollback', async () => {
    const { data, error } = await supabase.rpc('create_order_with_items', {
      customer_id: 1,
      items: [
        { product_id: 999999, quantity: 1, price: 10 } // Invalid product
      ]
    })
    
    expect(error).not.toBeNull()
    
    // Verify no partial data was created
    const { data: orders } = await supabase
      .from('orders')
      .select()
      .eq('customer_id', 1)
      .order('created_at', { ascending: false })
      .limit(1)
    
    // [Inference] Assuming the order was not created due to transaction rollback
    expect(orders.length).toBe(0)
  })
})
```

