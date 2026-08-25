## Third-Party API Integration


Edge Functions serve as backends for integrating external services, handling API authentication, rate limiting, and data transformation without exposing credentials to clients.

**Making external API calls:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const apiKey = Deno.env.get('OPENAI_API_KEY')
  
  const { prompt } = await req.json()
  
  const response = await fetch('https://api.openai.com/v1/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: 'text-davinci-003',
      prompt: prompt,
      max_tokens: 100
    })
  })
  
  const data = await response.json()
  return new Response(JSON.stringify(data))
})
```

**Handling API responses:**

Transform third-party API responses into formats suitable for your application:

```typescript
serve(async (req) => {
  const response = await fetch('https://api.weather.com/data', {
    headers: { 'X-API-Key': Deno.env.get('WEATHER_API_KEY')! }
  })
  
  const weatherData = await response.json()
  
  // Transform to simplified format
  const transformed = {
    temperature: weatherData.main.temp,
    condition: weatherData.weather[0].main,
    humidity: weatherData.main.humidity
  }
  
  return new Response(JSON.stringify(transformed))
})
```

**Error handling with external APIs:**

```typescript
serve(async (req) => {
  try {
    const response = await fetch('https://api.stripe.com/v1/charges', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('STRIPE_SECRET_KEY')}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'amount=1000&currency=usd&source=tok_visa'
    })
    
    if (!response.ok) {
      const error = await response.json()
      return new Response(
        JSON.stringify({ error: error.message }), 
        { status: response.status }
      )
    }
    
    const charge = await response.json()
    return new Response(JSON.stringify({ success: true, charge }))
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Payment processing failed' }),
      { status: 500 }
    )
  }
})
```

**Webhook handling:**

Process webhooks from external services:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // Verify webhook signature
  const signature = req.headers.get('stripe-signature')
  const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')
  
  const body = await req.text()
  
  // Stripe signature verification logic
  // [Implementation details omitted for brevity]
  
  const event = JSON.parse(body)
  
  if (event.type === 'payment_intent.succeeded') {
    // Update database with payment confirmation
    const supabase = createClient(...)
    await supabase
      .from('payments')
      .update({ status: 'completed' })
      .eq('stripe_id', event.data.object.id)
  }
  
  return new Response(JSON.stringify({ received: true }), { status: 200 })
})
```

**Rate limiting and retry logic:**

[Inference] Implement custom retry mechanisms for external API calls that may fail temporarily:

```typescript
async function fetchWithRetry(url: string, options: any, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, options)
      if (response.ok) return response
      
      if (response.status === 429) { // Rate limited
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)))
        continue
      }
      
      return response
    } catch (error) {
      if (i === retries - 1) throw error
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)))
    }
  }
}
```

