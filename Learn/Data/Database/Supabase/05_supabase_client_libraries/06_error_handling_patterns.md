## Error handling patterns


Proper error handling ensures robust applications and good user experience.

### Error structure

Supabase errors follow a consistent structure:

```typescript
{
  error: {
    message: string,    // Human-readable error message
    details: string,    // Additional details
    hint: string,       // Helpful hint for resolution
    code: string        // Error code
  },
  data: null,
  count: null,
  status: number,       // HTTP status code
  statusText: string    // HTTP status text
}
```

### Basic error handling

**Simple try-catch:**

```typescript
try {
  const { data, error } = await supabase
    .from('posts')
    .select('*')
  
  if (error) throw error
  
  // Process data
  console.log(data)
} catch (error) {
  console.error('Error fetching posts:', error.message)
}
```

**Inline error checking:**

```typescript
const { data, error } = await supabase
  .from('posts')
  .select('*')

if (error) {
  console.error('Error:', error)
  return // or handle appropriately
}

// Safe to use data here
console.log(data)
```

### Common error types

**Authentication errors:**

```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'wrongpassword'
})

if (error) {
  switch (error.message) {
    case 'Invalid login credentials':
      // Wrong email/password
      showError('Incorrect email or password')
      break
    case 'Email not confirmed':
      // User hasn't verified email
      showError('Please verify your email first')
      break
    default:
      showError('Login failed')
  }
}
```

**Database query errors:**

```typescript
const { data, error } = await supabase
  .from('nonexistent_table')
  .select('*')

if (error) {
  // error.code might be '42P01' (undefined table)
  // error.message: 'relation "public.nonexistent_table" does not exist'
  
  if (error.code === '42P01') {
    console.error('Table does not exist')
  } else if (error.code === '42501') {
    console.error('Insufficient privileges')
  } else {
    console.error('Database error:', error.message)
  }
}
```

**RLS policy violations:**

```typescript
const { data, error } = await supabase
  .from('private_posts')
  .insert({ title: 'Test', user_id: 'other-user-id' })

if (error) {
  // error.code: '42501'
  // error.message: 'new row violates row-level security policy'
  
  if (error.code === '42501') {
    showError('You do not have permission to perform this action')
  }
}
```

**Network errors:**

```typescript
const { data, error } = await supabase
  .from('posts')
  .select('*')

if (error) {
  // Network-related errors
  if (error.message.includes('fetch') || error.message.includes('network')) {
    showError('Network error. Please check your connection.')
  }
}
```

**Storage errors:**

```typescript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('avatar.png', file)

if (error) {
  // error.message examples:
  // 'The resource already exists'
  // 'The object exceeded the maximum allowed size'
  // 'Bucket not found'
  
  if (error.message.includes('already exists')) {
    showError('File already exists')
  } else if (error.message.includes('size')) {
    showError('File is too large')
  } else if (error.message.includes('not found')) {
    showError('Storage bucket not found')
  }
}
```

### Advanced error handling patterns

**Custom error wrapper:**

```typescript
class DatabaseError extends Error {
  code: string
  details: string
  hint: string

  constructor(error: any) {
    super(error.message)
    this.name = 'DatabaseError'
    this.code = error.code
    this.details = error.details
    this.hint = error.hint
  }
}

async function queryWithErrorHandling<T>(
  query: Promise<{ data: T | null; error: any }>
): Promise<T> {
  const { data, error } = await query
  
  if (error) {
    throw new DatabaseError(error)
  }
  
  if (!data) {
    throw new Error('No data returned')
  }
  
  return data
}

// Usage
try {
  const posts = await queryWithErrorHandling(
    supabase.from('posts').select('*')
  )
  console.log(posts)
} catch (error) {
  if (error instanceof DatabaseError) {
    console.error('Database error:', error.message)
    console.error('Code:', error.code)
    console.error('Hint:', error.hint)
  }
}
```

**Result type pattern:**

```typescript
type Result<T> = 
  | { success: true; data: T }
  | { success: false; error: string }

async function fetchPosts(): Promise<Result<Post[]>> {
  const { data, error } = await supabase
    .from('posts')
    .select('*')
  
  if (error) {
    return { success: false, error: error.message }
  }
  
  return { success: true, data: data || [] }
}

// Usage
const result = await fetchPosts()

if (result.success) {
  console.log('Posts:', result.data)
} else {
  console.error('Error:', result.error)
}
```

**React error boundary integration:**

```typescript
import { Component, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
}

class SupabaseErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error) {
    // Log to error reporting service
    console.error('Supabase error caught:', error)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div>
          <h2>Something went wrong</h2>
          <details>
            <summary>Error details</summary>
            <pre>{this.state.error?.message}</pre>
          </details>
        </div>
      )
    }

    return this.props.children
  }
}

// Usage
function App() {
  return (
    <SupabaseErrorBoundary>
      <DataComponent />
    </SupabaseErrorBoundary>
  )
}
```

**Retry logic:**

```typescript
async function fetchWithRetry<T>(
  queryFn: () => Promise<{ data: T | null; error: any }>,
  maxRetries = 3,
  delay = 1000
): Promise<T> {
  let lastError: any
  
  for (let i = 0; i < maxRetries; i++) {
    const { data, error } = await queryFn()
    
    if (!error && data) {
      return data
    }
    
    lastError = error
    
    // Don't retry on certain errors
    if (error?.code === '42501') { // RLS violation
      break
    }
    
    if (i < maxRetries - 1) {
      await new Promise(resolve => setTimeout(resolve, delay * (i + 1)))
    }
  }
  
  throw new Error(`Failed after ${maxRetries} retries: ${lastError?.message}`)
}

// Usage
try {
  const posts = await fetchWithRetry(() =>
    supabase.from('posts').select('*')
  )
  console.log(posts)
} catch (error) {
  console.error('All retries failed:', error)
}
```

**Global error handler:**

```typescript
type ErrorHandler = (error: any, context?: string) => void

class SupabaseErrorHandler {
  private handlers: ErrorHandler[] = []
  
  addHandler(handler: ErrorHandler) {
    this.handlers.push(handler)
  }
  
  handle(error: any, context?: string) {
    this.handlers.forEach(handler => handler(error, context))
  }
}

const errorHandler = new SupabaseErrorHandler()

// Add logging
errorHandler.addHandler((error, context) => {
  console.error(`[${context}]`, error)
})

// Add user notification
errorHandler.addHandler((error, context) => {
  toast.error(`Error in ${context}: ${error.message}`)
})

// Add analytics
errorHandler.addHandler((error, context) => {
  analytics.track('supabase_error', {
    context,
    message: error.message,
    code: error.code
  })
})

// Usage
const { data, error } = await supabase.from('posts').select('*')
if (error) {
  errorHandler.handle(error, 'fetchPosts')
}
```

### React hooks with error handling

**Custom query hook:**

```typescript
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'

interface UseQueryResult<T> {
  data: T | null
  error: string | null
  loading: boolean
  refetch: () => void
}

function useSupabaseQuery<T>(
  query: () => Promise<{ data: T | null; error: any }>
): UseQueryResult<T> {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  const fetchData = async () => {
    setLoading(true)
    setError(null)
    
    try {
      const { data: result, error: queryError } = await query()
      
      if (queryError) {
        setError(queryError.message)
      } else {
        setData(result)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [])

  return { data, error, loading, refetch: fetchData }
}

// Usage
function PostsList() {
  const { data: posts, error, loading, refetch } = useSupabaseQuery(() =>
    supabase.from('posts').select('*')
  )

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>
  
  return (
    <div>
      {posts?.map(post => <div key={post.id}>{post.title}</div>)}
      <button onClick={refetch}>Refresh</button>
    </div>
  )
}
```

**Custom mutation hook:**

```typescript
import { useState } from 'react'

interface UseMutationResult<TData, TVariables> {
  mutate: (variables: TVariables) => Promise<void>
  data: TData | null
  error: string | null
  loading: boolean
  reset: () => void
}

function useSupabaseMutation<TData, TVariables>(
  mutationFn: (variables: TVariables) => Promise<{ data: TData | null; error: any }>
): UseMutationResult<TData, TVariables> {
  const [data, setData] = useState<TData | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const mutate = async (variables: TVariables) => {
    setLoading(true)
    setError(null)
    
    try {
      const { data: result, error: mutationError } = await mutationFn(variables)
      
      if (mutationError) {
        setError(mutationError.message)
        throw new Error(mutationError.message)
      } else {
        setData(result)
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error'
      setError(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  const reset = () => {
    setData(null)
    setError(null)
    setLoading(false)
  }

  return { mutate, data, error, loading, reset }
}

// Usage
function CreatePost() {
  const { mutate, error, loading } = useSupabaseMutation<Post, { title: string }>(
    (variables) =>
      supabase.from('posts').insert({ title: variables.title }).select().single()
  )

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    
    try {
      await mutate({ title: formData.get('title') as string })
      alert('Post created!')
    } catch (err) {
      // Error already set in state
      console.error('Failed to create post')
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="title" required />
      <button disabled={loading}>
        {loading ? 'Creating...' : 'Create Post'}
      </button>
      {error && <div className="error">{error}</div>}
    </form>
  )
}
```

### Error logging and monitoring

**Integration with Sentry:**

```typescript
import * as Sentry from '@sentry/browser'

function logSupabaseError(error: any, context: string) {
  Sentry.captureException(error, {
    tags: {
      component: 'supabase',
      context
    },
    extra: {
      code: error.code,
      details: error.details,
      hint: error.hint
    }
  })
}

// Usage
const { data, error } = await supabase.from('posts').select('*')
if (error) {
  logSupabaseError(error, 'fetchPosts')
}
```

**Custom error logger:**

```typescript
interface ErrorLog {
  timestamp: Date
  error: any
  context: string
  userId?: string
}

class ErrorLogger {
  private logs: ErrorLog[] = []
  
  log(error: any, context: string) {
    const log: ErrorLog = {
      timestamp: new Date(),
      error: {
        message: error.message,
        code: error.code,
        details: error.details
      },
      context,
      userId: supabase.auth.getUser().data.user?.id
    }
    
    this.logs.push(log)
    
    // Send to backend
    this.sendToBackend(log)
    
    // Keep only last 100 logs in memory
    if (this.logs.length > 100) {
      this.logs.shift()
    }
  }
  
  private async sendToBackend(log: ErrorLog) {
    try {
      await fetch('/api/logs/error', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(log)
      })
    } catch (err) {
      // Silently fail - don't want logging errors to break app
      console.warn('Failed to send error log:', err)
    }
  }
  
  getLogs() {
    return this.logs
  }
}

const logger = new ErrorLogger()

// Usage
const { data, error } = await supabase.from('posts').select('*')
if (error) {
  logger.log(error, 'fetchPosts')
}
```

### User-friendly error messages

**Error message mapper:**

```typescript
const errorMessages: Record<string, string> = {
  // Auth errors
  'Invalid login credentials': 'The email or password you entered is incorrect.',
  'Email not confirmed': 'Please check your email and confirm your account.',
  'User already registered': 'An account with this email already exists.',
  
  // Database errors
  '42501': 'You do not have permission to perform this action.',
  '23505': 'This record already exists.',
  '23503': 'Cannot delete this record because it is referenced by other data.',
  
  // Storage errors
  'The resource already exists': 'A file with this name already exists.',
  'Bucket not found': 'The storage location was not found.',
  
  // Network errors
  'Failed to fetch': 'Network error. Please check your internet connection.',
  'NetworkError': 'Unable to connect. Please try again.',
}

function getUserFriendlyError(error: any): string {
  // Check by error code first
  if (error.code && errorMessages[error.code]) {
    return errorMessages[error.code]
  }
  
  // Check by error message
  for (const [key, message] of Object.entries(errorMessages)) {
    if (error.message?.includes(key)) {
      return message
    }
  }
  
  // Default fallback
  return 'An unexpected error occurred. Please try again.'
}

// Usage
const { data, error } = await supabase.auth.signInWithPassword({
  email,
  password
})

if (error) {
  const friendlyMessage = getUserFriendlyError(error)
  showToast(friendlyMessage, 'error')
}
```

### Validation before queries

**Prevent common errors:**

```typescript
function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

async function signIn(email: string, password: string) {
  // Validate before sending request
  if (!validateEmail(email)) {
    return { error: { message: 'Please enter a valid email address' } }
  }
  
  if (password.length < 6) {
    return { error: { message: 'Password must be at least 6 characters' } }
  }
  
  // Now make the request
  return await supabase.auth.signInWithPassword({ email, password })
}
```

**Type guards:**

```typescript
function isSupabaseError(error: any): error is { message: string; code: string } {
  return error && typeof error.message === 'string'
}

const { data, error } = await supabase.from('posts').select('*')

if (error) {
  if (isSupabaseError(error)) {
    console.error('Supabase error:', error.message, error.code)
  } else {
    console.error('Unknown error:', error)
  }
}
```

