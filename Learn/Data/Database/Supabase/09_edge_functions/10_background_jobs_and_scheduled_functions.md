## Background Jobs and Scheduled Functions


Edge Functions can execute scheduled tasks and background processing jobs through external triggers or scheduling services.

**Scheduled execution patterns:**

[Unverified] Supabase may offer native cron-style scheduling for Edge Functions. Alternatively, use external cron services like GitHub Actions, cron-job.org, or EasyCron to trigger functions on schedules.

**GitHub Actions for scheduling:**

```yaml
name: Scheduled Function
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Call Edge Function
        run: |
          curl -X POST \
            https://your-project.supabase.co/functions/v1/daily-cleanup \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_ANON_KEY }}"
```

**Background processing patterns:**

Implement long-running tasks by breaking them into smaller chunks or using external job queues:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  // Fetch pending jobs
  const { data: jobs } = await supabase
    .from('background_jobs')
    .select('*')
    .eq('status', 'pending')
    .limit(10)
  
  // Process each job
  for (const job of jobs || []) {
    try {
      // Perform work
      await processJob(job)
      
      // Mark as completed
      await supabase
        .from('background_jobs')
        .update({ status: 'completed', completed_at: new Date().toISOString() })
        .eq('id', job.id)
    } catch (error) {
      // Mark as failed
      await supabase
        .from('background_jobs')
        .update({ status: 'failed', error: error.message })
        .eq('id', job.id)
    }
  }
  
  return new Response(JSON.stringify({ processed: jobs?.length || 0 }))
})
```

**Async task patterns:**

Trigger background work without waiting for completion:

```typescript
serve(async (req) => {
  const { taskData } = await req.json()
  
  // Store task in database
  const supabase = createClient(...)
  await supabase
    .from('tasks')
    .insert({ data: taskData, status: 'queued' })
  
  // Return immediately
  return new Response(
    JSON.stringify({ message: 'Task queued' }),
    { status: 202 }
  )
})

// Separate function to process tasks
serve(async (req) => {
  const supabase = createClient(...)
  
  const { data: tasks } = await supabase
    .from('tasks')
    .select('*')
    .eq('status', 'queued')
    .limit(5)
  
  for (const task of tasks || []) {
    await processTask(task)
    await supabase
      .from('tasks')
      .update({ status: 'completed' })
      .eq('id', task.id)
  }
  
  return new Response('OK')
})
```

**Email digests and notifications:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const supabase = createClient(...)
  
  // Get users who should receive daily digest
  const { data: users } = await supabase
    .from('users')
    .select('email, preferences')
    .eq('digest_enabled', true)
  
  for (const user of users || []) {
    // Gather user's daily content
    const { data: content } = await supabase
      .from('content')
      .select('*')
      .eq('user_id', user.id)
      .gte('created_at', new Date(Date.now() - 86400000).toISOString())
    
    // Send email via SendGrid, Resend, or other service
    await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('SENDGRID_API_KEY')}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        personalizations: [{ to: [{ email: user.email }] }],
        from: { email: 'digest@yourapp.com' },
        subject: 'Your Daily Digest',
        content: [{ type: 'text/html', value: generateDigestHTML(content) }]
      })
    })
  }
  
  return new Response(JSON.stringify({ sent: users?.length || 0 }))
})
```

