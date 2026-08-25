## Error Handling and Logging


Robust error handling and logging enable debugging, monitoring, and maintaining Edge Functions in production environments.

**Basic error handling:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    const { data } = await req.json()
    
    if (!data) {
      return new Response(
        JSON.stringify({ error: 'Missing required data' }),
        { status: 400 }
      )
    }
    
    // Process request
    const result = await processData(data)
    
    return new Response(JSON.stringify({ success: true, result }))
    
  } catch (error) {
    console.error('Function error:', error)
    
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500 }
    )
  }
})
```

**Structured logging:**

Console logs in Edge Functions appear in the Supabase dashboard's function logs:

```typescript
serve(async (req) => {
  const startTime = Date.now()
  
  console.log('Function invoked', {
    method: req.method,
    url: req.url,
    timestamp: new Date().toISOString()
  })
  
  try {
    const result = await performOperation()
    
    console.log('Operation completed', {
      duration: Date.now() - startTime,
      resultSize: JSON.stringify(result).length
    })
    
    return new Response(JSON.stringify(result))
    
  } catch (error) {
    console.error('Operation failed', {
      error: error.message,
      stack: error.stack,
      duration: Date.now() - startTime
    })
    
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    )
  }
})
```

**Custom error classes:**

```typescript
class ValidationError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'ValidationError'
  }
}

class DatabaseError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'DatabaseError'
  }
}

serve(async (req) => {
  try {
    const { email } = await req.json()
    
    if (!email || !email.includes('@')) {
      throw new ValidationError('Invalid email format')
    }
    
    const supabase = createClient(...)
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
    
    if (error) {
      throw new DatabaseError(`Database query failed: ${error.message}`)
    }
    
    return new Response(JSON.stringify(data))
    
  } catch (error) {
    if (error instanceof ValidationError) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 400 }
      )
    }
    
    if (error instanceof DatabaseError) {
      console.error('Database error:', error)
      return new Response(
        JSON.stringify({ error: 'Service temporarily unavailable' }),
        { status: 503 }
      )
    }
    
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500 }
    )
  }
})
```

**Request validation patterns:**

```typescript
function validateRequest(data: any) {
  const errors = []
  
  if (!data.email) {
    errors.push({ field: 'email', message: 'Email is required' })
  }
  
  if (!data.name || data.name.length < 2) {
    errors.push({ field: 'name', message: 'Name must be at least 2 characters' })
  }
  
  if (data.age && (data.age < 0 || data.age > 120)) {
    errors.push({ field: 'age', message: 'Age must be between 0 and 120' })
  }
  
  return errors
}

serve(async (req) => {
  try {
    const data = await req.json()
    
    const validationErrors = validateRequest(data)
    if (validationErrors.length > 0) {
      return new Response(
        JSON.stringify({ errors: validationErrors }),
        { status: 422 }
      )
    }
    
    // Process valid data
    const result = await saveData(data)
    return new Response(JSON.stringify(result))
    
  } catch (error) {
    console.error('Request processing error:', error)
    return new Response(
      JSON.stringify({ error: 'Failed to process request' }),
      { status: 500 }
    )
  }
})
```

**Monitoring and observability:**

Log key metrics for monitoring function performance:

```typescript
serve(async (req) => {
  const requestId = crypto.randomUUID()
  const startTime = Date.now()
  
  console.log('Request started', {
    requestId,
    method: req.method,
    path: new URL(req.url).pathname,
    timestamp: new Date().toISOString()
  })
  
  try {
    const result = await handleRequest(req)
    
    const duration = Date.now() - startTime
    console.log('Request completed', {
      requestId,
      duration,
      status: 200
    })
    
    return new Response(JSON.stringify(result), {
      headers: {
        'X-Request-ID': requestId,
        'X-Response-Time': `${duration}ms`
      }
    })
    
  } catch (error) {
    const duration = Date.now() - startTime
    console.error('Request failed', {
      requestId,
      duration,
      error: error.message,
      stack: error.stack
    })
    
    return new Response(
      JSON.stringify({ error: error.message, requestId }),
      { 
        status: 500,
        headers: { 'X-Request-ID': requestId }
      }
    )
  }
})
```

**Database error handling:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  try {
    const { userId } = await req.json()
    
    const { data, error } = await supabase
      .from('users')
      .select('*, orders(*)')
      .eq('id', userId)
      .single()
    
    if (error) {
      console.error('Database query error', {
        code: error.code,
        message: error.message,
        details: error.details,
        hint: error.hint
      })
      
      // Handle specific Postgres error codes
      if (error.code === 'PGRST116') {
        return new Response(
          JSON.stringify({ error: 'User not found' }),
          { status: 404 }
        )
      }
      
      return new Response(
        JSON.stringify({ error: 'Database operation failed' }),
        { status: 500 }
      )
    }
    
    return new Response(JSON.stringify(data))
    
  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500 }
    )
  }
})
```

**External API error handling:**

```typescript
serve(async (req) => {
  try {
    const response = await fetch('https://api.external-service.com/data', {
      headers: { 'Authorization': `Bearer ${Deno.env.get('API_KEY')}` },
      signal: AbortSignal.timeout(5000) // 5 second timeout
    })
    
    if (!response.ok) {
      const errorBody = await response.text()
      console.error('External API error', {
        status: response.status,
        statusText: response.statusText,
        body: errorBody
      })
      
      return new Response(
        JSON.stringify({ 
          error: 'External service unavailable',
          details: response.statusText
        }),
        { status: 502 }
      )
    }
    
    const data = await response.json()
    return new Response(JSON.stringify(data))
    
  } catch (error) {
    if (error.name === 'TimeoutError') {
      console.error('External API timeout')
      return new Response(
        JSON.stringify({ error: 'Request timeout' }),
        { status: 504 }
      )
    }
    
    console.error('External API call failed:', error)
    return new Response(
      JSON.stringify({ error: 'Failed to fetch data' }),
      { status: 500 }
    )
  }
})
```

**Graceful degradation:**

```typescript
serve(async (req) => {
  let enrichedData = null
  
  try {
    // Attempt to enrich data from external service
    const response = await fetch('https://enrichment-api.com/data')
    if (response.ok) {
      enrichedData = await response.json()
    } else {
      console.warn('Enrichment service unavailable, continuing without enrichment')
    }
  } catch (error) {
    console.warn('Failed to enrich data:', error.message)
    // Continue without enrichment rather than failing completely
  }
  
  const supabase = createClient(...)
  const { data: baseData } = await supabase
    .from('items')
    .select('*')
  
  // Merge enriched data if available
  const result = enrichedData 
    ? baseData.map(item => ({ ...item, enrichment: enrichedData[item.id] }))
    : baseData
  
  return new Response(JSON.stringify(result))
})
```

**Retry logic with exponential backoff:**

```typescript
async function fetchWithRetry(
  url: string, 
  options: RequestInit, 
  maxRetries = 3
): Promise<Response> {
  let lastError: Error
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      console.log(`Attempt ${attempt + 1} of ${maxRetries}`)
      
      const response = await fetch(url, options)
      
      if (response.ok || response.status < 500) {
        return response
      }
      
      lastError = new Error(`HTTP ${response.status}: ${response.statusText}`)
      
    } catch (error) {
      lastError = error
      console.warn(`Attempt ${attempt + 1} failed:`, error.message)
    }
    
    if (attempt < maxRetries - 1) {
      const delay = Math.pow(2, attempt) * 1000 // Exponential backoff
      console.log(`Retrying in ${delay}ms...`)
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }
  
  throw lastError
}

serve(async (req) => {
  try {
    const response = await fetchWithRetry(
      'https://unreliable-api.com/data',
      { headers: { 'Authorization': `Bearer ${Deno.env.get('API_KEY')}` } }
    )
    
    const data = await response.json()
    return new Response(JSON.stringify(data))
    
  } catch (error) {
    console.error('All retry attempts failed:', error)
    return new Response(
      JSON.stringify({ error: 'Service temporarily unavailable' }),
      { status: 503 }
    )
  }
})
```

**Logging to external services:**

[Inference] Functions can send logs to external monitoring services like Sentry, Datadog, or LogTail for centralized error tracking:

```typescript
async function logToSentry(error: Error, context: any) {
  const sentryDsn = Deno.env.get('SENTRY_DSN')
  if (!sentryDsn) return
  
  try {
    await fetch('https://sentry.io/api/endpoint', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: error.message,
        stack: error.stack,
        context,
        timestamp: new Date().toISOString()
      })
    })
  } catch (err) {
    console.error('Failed to log to Sentry:', err)
  }
}

serve(async (req) => {
  try {
    const result = await riskyOperation()
    return new Response(JSON.stringify(result))
    
  } catch (error) {
    await logToSentry(error, {
      url: req.url,
      method: req.method,
      userAgent: req.headers.get('user-agent')
    })
    
    return new Response(
      JSON.stringify({ error: 'Operation failed' }),
      { status: 500 }
    )
  }
})
```

**Health check endpoints:**

```typescript
serve(async (req) => {
  const url = new URL(req.url)
  
  if (url.pathname === '/health') {
    const supabase = createClient(...)
    
    try {
      // Check database connectivity
      const { error } = await supabase
        .from('_health_check')
        .select('count')
        .limit(1)
      
      if (error) throw error
      
      return new Response(
        JSON.stringify({ 
          status: 'healthy',
          timestamp: new Date().toISOString()
        }),
        { status: 200 }
      )
      
    } catch (error) {
      console.error('Health check failed:', error)
      return new Response(
        JSON.stringify({ 
          status: 'unhealthy',
          error: error.message
        }),
        { status: 503 }
      )
    }
  }
  
  // Regular request handling
  return handleRequest(req)
})
```

**Performance tracking:**

```typescript
class PerformanceTracker {
  private metrics: Map<string, number[]> = new Map()
  
  track(operation: string, duration: number) {
    if (!this.metrics.has(operation)) {
      this.metrics.set(operation, [])
    }
    this.metrics.get(operation)!.push(duration)
  }
  
  getStats(operation: string) {
    const durations = this.metrics.get(operation) || []
    if (durations.length === 0) return null
    
    const sorted = [...durations].sort((a, b) => a - b)
    return {
      count: durations.length,
      avg: durations.reduce((a, b) => a + b, 0) / durations.length,
      min: sorted[0],
      max: sorted[sorted.length - 1],
      p50: sorted[Math.floor(sorted.length * 0.5)],
      p95: sorted[Math.floor(sorted.length * 0.95)]
    }
  }
}

const tracker = new PerformanceTracker()

serve(async (req) => {
  const startDb = Date.now()
  const { data } = await supabase.from('users').select('*')
  tracker.track('db_query', Date.now() - startDb)
  
  const startApi = Date.now()
  await fetch('https://api.example.com/data')
  tracker.track('external_api', Date.now() - startApi)
  
  console.log('Performance stats:', {
    db_query: tracker.getStats('db_query'),
    external_api: tracker.getStats('external_api')
  })
  
  return new Response(JSON.stringify(data))
})
```

**Important related topics:** Database connection pooling strategies, implementing rate limiting in Edge Functions, using Supabase Realtime with Edge Functions, authentication and JWT verification patterns, file upload handling, implementing idempotency for payment operations, WebSocket support in Edge Functions, streaming responses for large datasets, implementing request caching strategies, multi-region deployment considerations.

---

