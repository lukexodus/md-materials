## Common Patterns and Use Cases


### Soft Delete Implementation

```sql
CREATE OR REPLACE FUNCTION soft_delete()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE users 
  SET deleted_at = NOW()
  WHERE id = OLD.id;
  RETURN NULL;
END;
$$;

CREATE TRIGGER soft_delete_users
BEFORE DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION soft_delete();
```

### Automatic Slug Generation

```sql
CREATE OR REPLACE FUNCTION generate_slug()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.slug := lower(regexp_replace(NEW.title, '[^a-zA-Z0-9]+', '-', 'g'));
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_post_slug
BEFORE INSERT OR UPDATE OF title ON posts
FOR EACH ROW
WHEN (NEW.slug IS NULL OR NEW.slug = '')
EXECUTE FUNCTION generate_slug();
```

### Hierarchical Data Management

```sql
CREATE OR REPLACE FUNCTION update_category_path()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.parent_id IS NULL THEN
    NEW.path = NEW.id::text;
  ELSE
    SELECT path || '.' || NEW.id::text
    INTO NEW.path
    FROM categories
    WHERE id = NEW.parent_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER maintain_category_path
BEFORE INSERT OR UPDATE ON categories
FOR EACH ROW
EXECUTE FUNCTION update_category_path();
```

### Data Validation Trigger

```sql
CREATE OR REPLACE FUNCTION validate_product_data()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.price < 0 THEN
    RAISE EXCEPTION 'Price cannot be negative';
  END IF;
  
  IF NEW.stock_quantity < 0 THEN
    RAISE EXCEPTION 'Stock quantity cannot be negative';
  END IF;
  
  IF NEW.discount_percentage < 0 OR NEW.discount_percentage > 100 THEN
    RAISE EXCEPTION 'Discount must be between 0 and 100';
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER validate_product
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION validate_product_data();
```

### Maintaining Computed Columns

```sql
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE orders
  SET 
    subtotal = (SELECT SUM(quantity * unit_price) FROM order_items WHERE order_id = NEW.order_id),
    tax = subtotal * 0.08,
    total = subtotal + tax
  WHERE id = NEW.order_id;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER recalculate_order_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total();
```

**Important subtopics for deeper understanding:**

- **Row Level Security (RLS) integration with functions** - How functions interact with Supabase's RLS policies
- **Realtime subscriptions with triggers** - Using triggers to broadcast changes through Supabase Realtime
- **Edge Functions vs Database Functions** - When to use each approach
- **Migration strategies** - Managing function and trigger changes across environments
- **Debugging techniques** - Tools and approaches for troubleshooting function issues

---

