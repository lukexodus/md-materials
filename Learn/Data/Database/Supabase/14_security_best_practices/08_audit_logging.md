## Audit Logging


Audit logging tracks who accessed what data and when, providing accountability, security monitoring, and compliance support.

**Database-level audit logging:**

Create audit tables to track data changes:

```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data JSONB,
  new_data JSONB,
  user_id UUID,
  ip_address INET,
  user_agent TEXT,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for common queries
CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_user ON audit_log(user_id, timestamp DESC);
CREATE INDEX idx_audit_log_timestamp ON audit_log(timestamp DESC);
```

**Automatic audit triggers:**

```sql
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log (table_name, record_id, action, new_data, user_id)
    VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', to_jsonb(NEW), auth.uid());
    RETURN NEW;
    
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, user_id)
    VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), auth.uid());
    RETURN NEW;
    
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (table_name, record_id, action, old_data, user_id)
    VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', to_jsonb(OLD), auth.uid());
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply to sensitive tables
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_financial_records
AFTER INSERT OR UPDATE OR DELETE ON transactions
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
```

**Selective field auditing:**

For tables with sensitive data, audit only specific fields:

```sql
CREATE FUNCTION audit_sensitive_fields()
RETURNS TRIGGER AS $$
DECLARE
  old_sensitive JSONB;
  new_sensitive JSONB;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    -- Only log changes to sensitive fields
    old_sensitive := jsonb_build_object(
      'email', OLD.email,
      'phone', OLD.phone,
      'ssn', OLD.ssn
    );
    new_sensitive := jsonb_build_object(
      'email', NEW.email,
      'phone', NEW.phone,
      'ssn', NEW.ssn
    );
    
    -- Only insert if sensitive fields changed
    IF old_sensitive IS DISTINCT FROM new_sensitive THEN
      INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, user_id)
      VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', old_sensitive, new_sensitive, auth.uid());
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Authentication event logging:**

Track authentication events:

```sql
CREATE TABLE auth_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  event_type TEXT NOT NULL CHECK (event_type IN (
    'login', 'logout', 'signup', 'password_reset', 
    'password_change', 'failed_login', 'mfa_enabled', 'mfa_disabled'
)),
  ip_address INET,
  user_agent TEXT,
  success BOOLEAN NOT NULL,
  error_message TEXT,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_auth_audit_user ON auth_audit_log(user_id, timestamp DESC);
CREATE INDEX idx_auth_audit_event ON auth_audit_log(event_type, timestamp DESC);
CREATE INDEX idx_auth_audit_failed ON auth_audit_log(success, timestamp DESC) WHERE success = FALSE;
```

**Capturing request metadata:**

Use Edge Functions to log API access with additional context:

```javascript
// Edge Function with audit logging
Deno.serve(async (req) => {
  const startTime = Date.now();
  const user = await getUserFromRequest(req);
  const ipAddress = req.headers.get('x-forwarded-for') || 
                    req.headers.get('x-real-ip');
  const userAgent = req.headers.get('user-agent');
  
  try {
    // Process request
    const result = await processRequest(req, user);
    
    // Log successful access
    await logAuditEvent({
      userId: user?.id,
      action: 'api_access',
      resource: new URL(req.url).pathname,
      success: true,
      ipAddress,
      userAgent,
      responseTime: Date.now() - startTime
    });
    
    return new Response(JSON.stringify(result));
  } catch (error) {
    // Log failed access
    await logAuditEvent({
      userId: user?.id,
      action: 'api_access',
      resource: new URL(req.url).pathname,
      success: false,
      errorMessage: error.message,
      ipAddress,
      userAgent,
      responseTime: Date.now() - startTime
    });
    
    throw error;
  }
});
```

**Read access logging:**

Since triggers don't fire on SELECT, implement read logging through functions:

```sql
CREATE FUNCTION get_sensitive_record(record_id UUID)
RETURNS TABLE (/* columns */) AS $$
BEGIN
  -- Log the access
  INSERT INTO audit_log (table_name, record_id, action, user_id)
  VALUES ('sensitive_data', record_id, 'SELECT', auth.uid());
  
  -- Return the data
  RETURN QUERY
  SELECT * FROM sensitive_data WHERE id = record_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Audit log retention:**

Implement retention policies to manage audit log size:

```sql
-- Archive old audit logs
CREATE TABLE audit_log_archive (
  LIKE audit_log INCLUDING ALL
);

-- Partition by time for efficient archiving
CREATE TABLE audit_log_2024_q1 PARTITION OF audit_log
  FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- Function to archive old logs
CREATE FUNCTION archive_old_audit_logs(older_than INTERVAL)
RETURNS INTEGER AS $$
DECLARE
  rows_archived INTEGER;
BEGIN
  WITH archived AS (
    DELETE FROM audit_log
    WHERE timestamp < NOW() - older_than
    RETURNING *
  )
  INSERT INTO audit_log_archive
  SELECT * FROM archived;
  
  GET DIAGNOSTICS rows_archived = ROW_COUNT;
  RETURN rows_archived;
END;
$$ LANGUAGE plpgsql;

-- Schedule with pg_cron (if available)
-- SELECT cron.schedule('archive-audit-logs', '0 2 * * 0', 
--   'SELECT archive_old_audit_logs(''1 year'')');
```

**Querying audit logs:**

Useful audit queries:

```sql
-- Recent changes to specific record
SELECT * FROM audit_log
WHERE table_name = 'users' AND record_id = 'specific-uuid'
ORDER BY timestamp DESC;

-- All actions by specific user
SELECT 
  table_name,
  action,
  timestamp,
  new_data
FROM audit_log
WHERE user_id = 'user-uuid'
ORDER BY timestamp DESC;

-- Failed authentication attempts
SELECT 
  user_id,
  ip_address,
  COUNT(*) as attempts,
  MAX(timestamp) as last_attempt
FROM auth_audit_log
WHERE event_type = 'failed_login'
  AND timestamp > NOW() - INTERVAL '1 hour'
GROUP BY user_id, ip_address
HAVING COUNT(*) > 5;

-- Data access patterns
SELECT 
  user_id,
  table_name,
  COUNT(*) as access_count,
  COUNT(DISTINCT record_id) as unique_records
FROM audit_log
WHERE action = 'SELECT'
  AND timestamp > NOW() - INTERVAL '24 hours'
GROUP BY user_id, table_name
ORDER BY access_count DESC;
```

**Performance considerations:**

- Use asynchronous logging to avoid slowing down main operations [Inference: May require background jobs or message queues]
- Implement table partitioning for large audit tables
- Index frequently queried columns (user_id, timestamp, table_name)
- Archive old logs to separate tables
- Consider storing audit logs in separate database for critical systems
- Summarize old audit data rather than keeping full details indefinitely

**Compliance requirements:**

Different regulations require specific audit capabilities:

- **GDPR**: Log access to personal data, data exports, deletions
- **HIPAA**: Track all access to protected health information
- **SOC 2**: Comprehensive logging of security-relevant events
- **PCI DSS**: Log access to cardholder data with retention requirements

**Security for audit logs:**

Protect audit logs themselves:

```sql
-- Restrict access to audit logs
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only admins can view audit logs"
ON audit_log FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- Prevent modification of audit logs
CREATE POLICY "No one can modify audit logs"
ON audit_log FOR UPDATE
USING (false);

CREATE POLICY "No one can delete audit logs"
ON audit_log FOR DELETE
USING (false);

-- Make audit trigger function SECURITY DEFINER to bypass RLS
-- Already shown in audit_trigger_function above
```

