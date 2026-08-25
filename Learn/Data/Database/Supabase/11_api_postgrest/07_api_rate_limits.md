## API Rate Limits


Supabase applies rate limiting to protect infrastructure and ensure fair usage across projects.

**Default rate limits [Unverified - these values may vary by plan and change over time]:**

- Free tier: ~500 requests per minute per IP address
- Pro tier: Higher limits with burst capacity
- Enterprise: Custom limits negotiated

**Rate limit headers:** Responses include rate limit information:

```
X-RateLimit-Limit: 500
X-RateLimit-Remaining: 487
X-RateLimit-Reset: 1640000000
```

**What counts toward limits:**

- REST API requests via PostgREST
- Realtime subscriptions connections (separate limit)
- Authentication operations
- Storage API operations
- Edge Function invocations

**What doesn't count:**

- Database queries from backend services using direct connection
- Queries within database functions/triggers

**Handling rate limits:**

When exceeded, the API returns HTTP 429 status:

```json
{
  "message": "API rate limit exceeded",
  "code": "429"
}
```

**Mitigation strategies:**

- Implement exponential backoff retry logic
- Cache frequently accessed data client-side
- Use webhooks/realtime instead of polling
- Batch operations where possible
- Upgrade to higher tier for increased limits
- Use connection pooling for server-side requests
- Filter and select only needed columns to reduce payload

**Monitoring:** Track rate limit headers in your application to implement preemptive throttling before hitting limits.

