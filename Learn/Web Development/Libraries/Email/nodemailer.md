# Comprehensive Guide to Nodemailer

Nodemailer is a Node.js module for sending email from server-side JavaScript applications. It supports SMTP, OAuth2, and several transport mechanisms, and handles everything from plain-text messages to complex HTML emails with attachments.

---

## Installation

```bash
npm install nodemailer
```

Nodemailer has zero production dependencies. It requires Node.js 6 or later (current versions require Node.js 12+).

---

## Core Concepts

### Transporter

A **transporter** is the object responsible for sending email. You create one transporter and reuse it for all messages. The transporter encapsulates the connection method (SMTP, sendmail, etc.), credentials, and connection pool settings.

### Message Object

A **message object** is a plain JavaScript object passed to `transporter.sendMail()`. It describes the email: recipients, subject, body, attachments, and so on.

### Transport

A **transport** is the delivery mechanism. The built-in transports are SMTP (most common), sendmail, SES (Amazon Simple Email Service), and a stream transport (for testing). Third-party transport plugins also exist.

---

## Creating a Transporter

### SMTP Transporter

```javascript
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: 'smtp.example.com',
  port: 587,
  secure: false,        // true for port 465 (TLS), false for STARTTLS on 587
  auth: {
    user: 'user@example.com',
    pass: 'yourpassword',
  },
});
```

### Port and Security

|Port|`secure`|Protocol|
|---|---|---|
|465|`true`|SMTPS (TLS from the start)|
|587|`false`|STARTTLS (upgrades to TLS after handshake)|
|25|`false`|Unencrypted (rarely used; often blocked by ISPs)|

### Verifying the Connection

```javascript
transporter.verify((error, success) => {
  if (error) {
    console.error('SMTP connection failed:', error);
  } else {
    console.log('Server is ready to send messages');
  }
});

// Promise form
await transporter.verify();
```

---

## Sending a Basic Email

```javascript
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: 'smtp.example.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

async function sendEmail() {
  const info = await transporter.sendMail({
    from: '"My App" <noreply@example.com>',
    to: 'recipient@example.com',
    subject: 'Hello from Nodemailer',
    text: 'Plain text body.',
    html: '<p>HTML body.</p>',
  });

  console.log('Message sent:', info.messageId);
}

sendEmail().catch(console.error);
```

`sendMail()` returns a Promise that resolves with an `info` object containing `messageId`, `envelope`, `accepted`, `rejected`, and `response`.

---

## Message Fields

### Addressing

```javascript
{
  from: 'Sender Name <sender@example.com>',
  to: 'recipient@example.com',
  cc: 'cc@example.com',
  bcc: 'bcc@example.com',
  replyTo: 'replies@example.com',
}
```

Multiple recipients can be specified as a comma-separated string or an array:

```javascript
to: 'alice@example.com, bob@example.com',
// or
to: ['alice@example.com', 'bob@example.com'],
```

Address objects are also accepted:

```javascript
to: [
  { name: 'Alice', address: 'alice@example.com' },
  { name: 'Bob', address: 'bob@example.com' },
],
```

### Subject and Body

```javascript
{
  subject: 'Your order has shipped',
  text: 'Plain text fallback for clients that do not render HTML.',
  html: '<h1>Your order has shipped</h1><p>Track it at <a href="...">here</a>.</p>',
}
```

Always include both `text` and `html`. Many spam filters penalize HTML-only messages, and some clients display plain text only.

### Headers

```javascript
{
  headers: {
    'X-Custom-Header': 'custom-value',
    'List-Unsubscribe': '<https://example.com/unsubscribe>',
  },
}
```

### Priority

```javascript
{
  priority: 'high',   // 'high', 'normal', or 'low'
}
```

### Message ID and Date

Nodemailer generates these automatically. Override if needed:

```javascript
{
  messageId: 'custom-id@example.com',
  date: new Date('2024-01-15'),
}
```

---

## Attachments

Attachments are specified as an array of objects under the `attachments` key.

### File Path

```javascript
attachments: [
  {
    filename: 'report.pdf',
    path: '/home/user/reports/report.pdf',
  },
]
```

### Buffer or String

```javascript
attachments: [
  {
    filename: 'notes.txt',
    content: 'This is the content of the file.',
    contentType: 'text/plain',
  },
  {
    filename: 'data.json',
    content: Buffer.from(JSON.stringify({ key: 'value' })),
    contentType: 'application/json',
  },
]
```

### Stream

```javascript
const fs = require('fs');

attachments: [
  {
    filename: 'large-file.csv',
    content: fs.createReadStream('/path/to/large-file.csv'),
    contentType: 'text/csv',
  },
]
```

### URL

```javascript
attachments: [
  {
    filename: 'logo.png',
    path: 'https://example.com/logo.png',
  },
]
```

### Inline (Embedded) Images

Use `cid` (Content-ID) to embed images directly in HTML:

```javascript
{
  html: '<p>See the logo: <img src="cid:logo@example.com"/></p>',
  attachments: [
    {
      filename: 'logo.png',
      path: './logo.png',
      cid: 'logo@example.com',   // must match src="cid:..."
    },
  ],
}
```

### Attachment Encoding

```javascript
attachments: [
  {
    filename: 'encoded.txt',
    content: 'SGVsbG8gV29ybGQ=',   // base64 encoded "Hello World"
    encoding: 'base64',
  },
]
```

---

## HTML Email

### Sending HTML

```javascript
{
  html: `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #333;">Welcome!</h1>
      <p>Thanks for signing up.</p>
      <a href="https://example.com/confirm?token=abc123"
         style="background: #007bff; color: white; padding: 10px 20px;
                text-decoration: none; border-radius: 4px;">
        Confirm Email
      </a>
    </div>
  `,
}
```

HTML in email has significant limitations compared to web HTML. Use inline CSS. Avoid CSS grid and flexbox for layout, as many email clients do not support them. Table-based layout remains the most compatible approach for complex designs.

### Using a Template Engine

Nodemailer does not include a template engine, but any Node.js templating library works:

**With Handlebars:**

```javascript
const handlebars = require('handlebars');
const fs = require('fs');

const source = fs.readFileSync('./templates/welcome.hbs', 'utf8');
const template = handlebars.compile(source);

const html = template({
  name: 'Alice',
  confirmUrl: 'https://example.com/confirm?token=abc123',
});

await transporter.sendMail({
  from: 'noreply@example.com',
  to: 'alice@example.com',
  subject: 'Welcome',
  html,
});
```

**With EJS:**

```javascript
const ejs = require('ejs');

const html = await ejs.renderFile('./templates/welcome.ejs', {
  name: 'Alice',
  confirmUrl: 'https://example.com/confirm?token=abc123',
});
```

**With mjml (responsive email markup):**

```javascript
const mjml2html = require('mjml');

const { html, errors } = mjml2html(`
  <mjml>
    <mj-body>
      <mj-section>
        <mj-column>
          <mj-text>Hello, Alice!</mj-text>
        </mj-column>
      </mj-section>
    </mj-body>
  </mjml>
`);

await transporter.sendMail({ html });
```

---

## SMTP Options

### Full SMTP Configuration

```javascript
const transporter = nodemailer.createTransport({
  host: 'smtp.example.com',
  port: 587,
  secure: false,
  auth: {
    user: 'user@example.com',
    pass: 'password',
  },
  tls: {
    // Do not fail on self-signed certificates (development only)
    rejectUnauthorized: false,
    // Minimum TLS version
    minVersion: 'TLSv1.2',
  },
  connectionTimeout: 5000,   // milliseconds; default is 2 minutes
  greetingTimeout: 5000,
  socketTimeout: 5000,
  debug: false,              // Set true to log SMTP traffic
  logger: false,             // Set true to log to console
});
```

### Connection Pooling

Connection pooling reuses a set of SMTP connections instead of opening and closing one per message. This is more efficient for sending many messages.

```javascript
const transporter = nodemailer.createTransport({
  host: 'smtp.example.com',
  port: 465,
  secure: true,
  auth: { user: '...', pass: '...' },
  pool: true,
  maxConnections: 5,      // maximum number of simultaneous connections
  maxMessages: 100,       // maximum number of messages per connection
  rateDelta: 1000,        // time window in ms for rateLimit
  rateLimit: 5,           // max messages per rateDelta window
});

// Close the pool when done
transporter.close();
```

---

## OAuth2 Authentication

### Gmail with OAuth2

Using OAuth2 is more secure than storing a plain password. You need a Google Cloud project with the Gmail API enabled and OAuth2 credentials (client ID, client secret, refresh token).

```javascript
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    type: 'OAuth2',
    user: 'user@gmail.com',
    clientId: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    refreshToken: process.env.GOOGLE_REFRESH_TOKEN,
    accessToken: process.env.GOOGLE_ACCESS_TOKEN,   // optional; will be fetched if omitted
  },
});
```

### Token Refresh

Nodemailer can automatically refresh the access token using the refresh token:

```javascript
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    type: 'OAuth2',
    user: 'user@gmail.com',
    clientId: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    refreshToken: process.env.GOOGLE_REFRESH_TOKEN,
  },
});

// Listen for token updates to persist the new access token
transporter.on('token', (token) => {
  console.log('New access token:', token.accessToken);
  console.log('Expires at:', new Date(token.expires));
  // Persist token.accessToken and token.expires to your storage
});
```

---

## Common Email Providers

### Gmail

```javascript
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'user@gmail.com',
    pass: process.env.GMAIL_APP_PASSWORD,  // App Password, not account password
  },
});
```

Gmail requires an **App Password** when 2-Step Verification is enabled on the account. Regular account passwords will be rejected. Generate one at myaccount.google.com → Security → App passwords.

### Outlook / Hotmail / Microsoft 365

```javascript
const transporter = nodemailer.createTransport({
  host: 'smtp.office365.com',
  port: 587,
  secure: false,
  auth: {
    user: 'user@outlook.com',
    pass: process.env.OUTLOOK_PASS,
  },
  tls: {
    ciphers: 'SSLv3',
  },
});
```

### SendGrid

```javascript
const transporter = nodemailer.createTransport({
  host: 'smtp.sendgrid.net',
  port: 587,
  secure: false,
  auth: {
    user: 'apikey',              // literal string "apikey"
    pass: process.env.SENDGRID_API_KEY,
  },
});
```

### Mailgun

```javascript
const transporter = nodemailer.createTransport({
  host: 'smtp.mailgun.org',
  port: 587,
  secure: false,
  auth: {
    user: process.env.MAILGUN_SMTP_LOGIN,
    pass: process.env.MAILGUN_SMTP_PASSWORD,
  },
});
```

### Amazon SES

Nodemailer has built-in SES support using the AWS SDK:

```javascript
const nodemailer = require('nodemailer');
const { SESClient } = require('@aws-sdk/client-ses');

const ses = new SESClient({
  region: 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

const transporter = nodemailer.createTransport({
  SES: { ses, aws: require('@aws-sdk/client-ses') },
  sendingRate: 14,   // max messages per second (SES sandbox: 1/s)
});
```

---

## Testing

### Ethereal (Fake SMTP)

Ethereal is a free fake SMTP service for testing. Messages are captured and viewable in the browser — they are never actually delivered.

```javascript
async function createTestTransporter() {
  const testAccount = await nodemailer.createTestAccount();

  const transporter = nodemailer.createTransport({
    host: 'smtp.ethereal.email',
    port: 587,
    secure: false,
    auth: {
      user: testAccount.user,
      pass: testAccount.pass,
    },
  });

  return transporter;
}

const transporter = await createTestTransporter();

const info = await transporter.sendMail({
  from: 'test@example.com',
  to: 'recipient@example.com',
  subject: 'Test',
  text: 'Hello',
});

// Get the URL to preview the message in Ethereal's web UI
console.log('Preview URL:', nodemailer.getTestMessageUrl(info));
```

### Stream Transport (Unit Testing)

The stream transport writes messages to a writable stream instead of sending them. Useful for unit tests where you want to inspect the raw MIME output without any network calls.

```javascript
const { PassThrough } = require('stream');

const stream = new PassThrough();
const transporter = nodemailer.createTransport({ streamTransport: true, newline: 'unix' });

const info = await transporter.sendMail({
  from: 'test@example.com',
  to: 'recipient@example.com',
  subject: 'Test',
  text: 'Hello',
});

info.message.pipe(stream);

stream.on('data', (chunk) => {
  console.log(chunk.toString());
});
```

### Mocking with Jest

```javascript
jest.mock('nodemailer');
const nodemailer = require('nodemailer');

const mockSendMail = jest.fn().mockResolvedValue({ messageId: 'mock-id' });
nodemailer.createTransport.mockReturnValue({ sendMail: mockSendMail });

// In your test
expect(mockSendMail).toHaveBeenCalledWith(
  expect.objectContaining({
    to: 'recipient@example.com',
    subject: 'Welcome',
  })
);
```

---

## Sendmail Transport

Use the system's `sendmail` binary if available (Linux/macOS):

```javascript
const transporter = nodemailer.createTransport({
  sendmail: true,
  newline: 'unix',
  path: '/usr/sbin/sendmail',  // default; override if needed
});
```

---

## DKIM Signing

DKIM (DomainKeys Identified Mail) signing adds a cryptographic signature to outgoing messages. Many receiving servers use it to verify the sender's domain and reduce spam scoring.

```javascript
const transporter = nodemailer.createTransport({
  host: 'smtp.example.com',
  port: 587,
  secure: false,
  auth: { user: '...', pass: '...' },
  dkim: {
    domainName: 'example.com',
    keySelector: 'mail',                             // matches DNS TXT record: mail._domainkey
    privateKey: fs.readFileSync('./dkim-private.pem', 'utf8'),
  },
});
```

The corresponding DNS TXT record must exist at `mail._domainkey.example.com` containing the public key.

---

## Error Handling

### sendMail Errors

```javascript
try {
  const info = await transporter.sendMail(message);
  console.log('Sent:', info.messageId);
} catch (error) {
  console.error('Failed to send:', error.message);
  // error.code — SMTP error code (e.g. 'ECONNREFUSED', 'EAUTH')
  // error.response — full SMTP response string
  // error.responseCode — numeric SMTP status code (e.g. 550)
  // error.command — SMTP command that caused the error (e.g. 'AUTH', 'RCPT')
}
```

### Common Error Codes

|Code|Meaning|
|---|---|
|`ECONNREFUSED`|Could not connect to the SMTP host|
|`EAUTH`|Authentication failed (wrong credentials)|
|`ETIMEDOUT`|Connection timed out|
|`EMESSAGE`|Invalid message structure|
|`EENVELOPE`|Invalid envelope (e.g. bad recipient)|

### Checking Accepted / Rejected Recipients

```javascript
const info = await transporter.sendMail(message);

console.log('Accepted:', info.accepted);   // array of accepted addresses
console.log('Rejected:', info.rejected);   // array of rejected addresses
```

---

## Full Working Example

### Email Service Module

```javascript
// email.js
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: Number(process.env.SMTP_PORT) || 587,
  secure: process.env.SMTP_SECURE === 'true',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
  pool: true,
  maxConnections: 5,
});

/**
 * Send a plain or HTML email.
 * @param {object} options
 * @param {string|string[]} options.to
 * @param {string} options.subject
 * @param {string} [options.text]
 * @param {string} [options.html]
 * @param {object[]} [options.attachments]
 */
async function sendEmail({ to, subject, text, html, attachments }) {
  const info = await transporter.sendMail({
    from: `"${process.env.EMAIL_FROM_NAME}" <${process.env.EMAIL_FROM_ADDRESS}>`,
    to,
    subject,
    text,
    html,
    attachments,
  });

  return info;
}

async function sendWelcomeEmail(user) {
  return sendEmail({
    to: user.email,
    subject: `Welcome, ${user.name}!`,
    text: `Hi ${user.name},\n\nThanks for creating an account.\n\nThe Team`,
    html: `
      <p>Hi ${user.name},</p>
      <p>Thanks for creating an account.</p>
      <p>The Team</p>
    `,
  });
}

async function sendPasswordReset(user, resetUrl) {
  return sendEmail({
    to: user.email,
    subject: 'Password Reset Request',
    text: `Reset your password: ${resetUrl}`,
    html: `
      <p>You requested a password reset.</p>
      <p><a href="${resetUrl}">Click here to reset your password</a></p>
      <p>This link expires in 1 hour. If you did not request this, ignore this email.</p>
    `,
  });
}

function close() {
  transporter.close();
}

module.exports = { sendEmail, sendWelcomeEmail, sendPasswordReset, close };
```

### .env File

```env
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=user@example.com
SMTP_PASS=secretpassword
EMAIL_FROM_NAME=My App
EMAIL_FROM_ADDRESS=noreply@example.com
```

---

## Security Considerations

### Never Hard-Code Credentials

Always load SMTP credentials from environment variables or a secrets manager. Do not commit them to version control.

### Use App Passwords

When authenticating with a personal Gmail or Outlook account, use a provider-generated App Password rather than your account password. This limits the scope of access.

### TLS Verification

Do not disable `tls.rejectUnauthorized` in production. It should only be set to `false` in local development against self-signed certificates.

### Rate Limiting

Most SMTP providers enforce sending rate limits. Use the `pool` transport with `rateLimit` to stay within those limits and avoid your account being flagged or suspended.

### Input Sanitization

If any part of the message (subject, body, recipient addresses) is derived from user input, sanitize it. While SMTP header injection is less of a concern when using Nodemailer's structured API than with raw SMTP, HTML injection in the body is still possible if user-supplied strings are interpolated without escaping.

---

## Quick Reference

### Transporter Options

|Option|Description|
|---|---|
|`host`|SMTP server hostname|
|`port`|SMTP port (465 or 587)|
|`secure`|`true` for SMTPS (port 465)|
|`auth.user`|SMTP username|
|`auth.pass`|SMTP password|
|`pool`|Enable connection pooling|
|`maxConnections`|Max pooled connections|
|`rateLimit`|Max messages per `rateDelta` window|
|`tls`|TLS options (pass to `tls.connect`)|

### Message Options

|Field|Description|
|---|---|
|`from`|Sender address|
|`to`|Primary recipient(s)|
|`cc`|CC recipient(s)|
|`bcc`|BCC recipient(s)|
|`replyTo`|Reply-to address|
|`subject`|Email subject|
|`text`|Plain text body|
|`html`|HTML body|
|`attachments`|Array of attachment objects|
|`headers`|Custom headers|
|`priority`|`high`, `normal`, or `low`|

### Attachment Fields

|Field|Description|
|---|---|
|`filename`|Filename shown to recipient|
|`path`|File path or URL|
|`content`|String, Buffer, or Stream|
|`contentType`|MIME type|
|`encoding`|Encoding (e.g. `base64`)|
|`cid`|Content-ID for inline embedding|

### info Object (sendMail result)

|Field|Description|
|---|---|
|`messageId`|Assigned message ID|
|`envelope`|SMTP envelope (`from`, `to`)|
|`accepted`|Addresses accepted by the server|
|`rejected`|Addresses rejected by the server|
|`response`|Last SMTP server response string|