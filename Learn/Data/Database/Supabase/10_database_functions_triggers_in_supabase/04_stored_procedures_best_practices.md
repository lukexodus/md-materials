## Stored Procedures Best Practices


### Naming Conventions

- Use descriptive, verb-based names: `calculate_order_total`, `update_user_profile`
- Prefix by domain or module: `auth_verify_email`, `billing_process_payment`
- Avoid generic names: `process`, `handle`, `do_stuff`

### Parameter Handling

```sql
-- Use named parameters for clarity
CREATE FUNCTION create_order(
  p_user_id uuid,
  p_items jsonb,
  p_shipping_address jsonb
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_order_id uuid;
BEGIN
  -- Use prefixes to distinguish parameter scope
  INSERT INTO orders(user_id, status, shipping_address)
  VALUES (p_user_id, 'pending', p_shipping_address)
  RETURNING id INTO v_order_id;
  
  -- Process items...
  
  RETURN v_order_id;
END;
$$;
```

### Error Handling

```sql
CREATE OR REPLACE FUNCTION transfer_funds(
  from_account uuid,
  to_account uuid,
  amount numeric
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
  from_balance numeric;
BEGIN
  -- Validate input
  IF amount <= 0 THEN
    RAISE EXCEPTION 'Transfer amount must be positive';
  END IF;
  
  -- Check balance
  SELECT balance INTO from_balance
  FROM accounts
  WHERE id = from_account
  FOR UPDATE;
  
  IF from_balance < amount THEN
    RAISE EXCEPTION 'Insufficient funds: % available, % required', from_balance, amount;
  END IF;
  
  -- Perform transfer
  UPDATE accounts SET balance = balance - amount WHERE id = from_account;
  UPDATE accounts SET balance = balance + amount WHERE id = to_account;
  
  RETURN true;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Transfer failed: %', SQLERRM;
    RETURN false;
END;
$$;
```

### Transaction Management

Functions run within transactions automatically. Use savepoints for partial rollbacks:

```sql
CREATE OR REPLACE FUNCTION process_batch_orders(order_ids uuid[])
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE
  order_id uuid;
  success_count int := 0;
  failure_count int := 0;
BEGIN
  FOREACH order_id IN ARRAY order_ids
  LOOP
    BEGIN
      -- Create savepoint for each order
      PERFORM process_single_order(order_id);
      success_count := success_count + 1;
    EXCEPTION
      WHEN OTHERS THEN
        failure_count := failure_count + 1;
        RAISE NOTICE 'Failed to process order %: %', order_id, SQLERRM;
    END;
  END LOOP;
  
  RETURN json_build_object(
    'successful', success_count,
    'failed', failure_count
  );
END;
$$;
```

### Immutability and Volatility

Declare function volatility for query optimization:

```sql
-- IMMUTABLE: Always returns same result for same inputs
CREATE FUNCTION calculate_tax(amount numeric, rate numeric)
RETURNS numeric
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT amount * rate;
$$;

-- STABLE: Same result within single query
CREATE FUNCTION get_current_user_email()
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT email FROM users WHERE id = auth.uid();
$$;

-- VOLATILE: May have side effects (default)
CREATE FUNCTION record_login()
RETURNS void
LANGUAGE plpgsql
VOLATILE
AS $$
BEGIN
  INSERT INTO login_history(user_id, logged_at)
  VALUES (auth.uid(), NOW());
END;
$$;
```

### Documentation

```sql
CREATE OR REPLACE FUNCTION calculate_discount(
  order_total numeric,
  user_tier text
)
RETURNS numeric
LANGUAGE plpgsql
IMMUTABLE
AS $$
/*
  Calculates discount amount based on order total and user tier.
  
  Parameters:
    order_total - Total order amount before discount
    user_tier - User membership tier ('bronze', 'silver', 'gold', 'platinum')
  
  Returns:
    Discount amount (not discounted total)
  
  Example:
    SELECT calculate_discount(100.00, 'gold'); -- Returns 15.00
*/
BEGIN
  RETURN CASE user_tier
    WHEN 'platinum' THEN order_total * 0.20
    WHEN 'gold' THEN order_total * 0.15
    WHEN 'silver' THEN order_total * 0.10
    WHEN 'bronze' THEN order_total * 0.05
    ELSE 0
  END;
END;
$$;

COMMENT ON FUNCTION calculate_discount IS 
  'Applies tiered discount based on user membership level';
```

