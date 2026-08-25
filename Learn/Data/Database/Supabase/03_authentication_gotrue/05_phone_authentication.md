## Phone Authentication


SMS-based authentication using one-time passwords (OTP) sent to phone numbers. Users enter the code received via SMS to authenticate.

**Key points:**

- Requires SMS provider integration (Twilio, MessageBird, Vonage, etc.)
- Phone numbers stored in E.164 format
- OTP codes are time-limited (default 60 seconds)
- Can be used for sign-up or sign-in
- Phone number must be verified before use
- Rate limiting prevents abuse

**Example:** Sending OTP

```javascript
const { data, error } = await supabase.auth.signInWithOtp({
  phone: '+12025551234',
  options: {
    channel: 'sms' // or 'whatsapp'
  }
})
```

**Example:** Verifying OTP

```javascript
const { data, error } = await supabase.auth.verifyOtp({
  phone: '+12025551234',
  token: '123456',
  type: 'sms'
})
```

