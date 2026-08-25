## Enabling RLS on Tables


RLS must be explicitly enabled on each table. Without enabling RLS, tables remain fully accessible regardless of policies defined.

```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
```

Once enabled, all access to the table is blocked by default. Users cannot read, insert, update, or delete any rows until policies grant them permission.

To disable RLS (not recommended for user-facing tables):

```sql
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
```

**[Inference]** Tables without RLS enabled pose security risks in applications where users authenticate, as any authenticated user could potentially access all data.

