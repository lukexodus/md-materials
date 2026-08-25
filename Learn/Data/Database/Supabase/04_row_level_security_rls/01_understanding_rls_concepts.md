## Understanding RLS Concepts


RLS operates on a per-row basis rather than per-table. When enabled, all rows become inaccessible by default until explicit policies grant access. This security model ensures data isolation between users, making it particularly valuable for multi-tenant applications where users should only access their own data.

RLS policies evaluate against the authenticated user's JWT token claims, which Supabase automatically injects into the PostgreSQL session context. Each policy defines conditions that must be true for a row to be accessible during a specific operation (SELECT, INSERT, UPDATE, DELETE).

The security model follows a whitelist approach: deny everything by default, then explicitly grant access through policies. Multiple policies can apply to the same table, and if any policy returns true for a row, that row becomes accessible for the specified operation.

