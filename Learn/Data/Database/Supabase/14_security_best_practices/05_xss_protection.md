## XSS Protection


Cross-Site Scripting (XSS) attacks inject malicious scripts into web applications, potentially stealing user data, session tokens, or performing unauthorized actions. XSS protection requires careful handling of user-generated content in your frontend application.

**Supabase's role:**

Supabase stores data as-is without modification and returns exactly what was stored. The database does not automatically sanitize or escape content. XSS protection is primarily a frontend responsibility, though database design can support security measures.

**Frontend protection strategies:**

**Framework-native escaping:**

Modern frameworks provide automatic XSS protection:

```javascript
// React - automatically escapes by default
function UserProfile({ user }) {
  return (
    <div>
      <h1>{user.name}</h1>  {/* Automatically escaped */}
      <p>{user.bio}</p>      {/* Automatically escaped */}
    </div>
  );
}

// Vue - automatically escapes
<template>
  <div>
    <h1>{{ user.name }}</h1>  <!-- Automatically escaped -->
    <p>{{ user.bio }}</p>      <!-- Automatically escaped -->
  </div>
</template>
```

**Dangerous HTML rendering:**

When you must render HTML content, use sanitization libraries:

```javascript
import DOMPurify from 'dompurify';

function ArticleContent({ article }) {
  // Sanitize before rendering
  const sanitizedHTML = DOMPurify.sanitize(article.html_content, {
    ALLOWED_TAGS: ['p', 'b', 'i', 'em', 'strong', 'a', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: ['href', 'title']
  });
  
  return (
    <div dangerouslySetInnerHTML={{ __html: sanitizedHTML }} />
  );
}
```

**Content Security Policy (CSP):**

Implement CSP headers to restrict script execution:

```html
<!-- In your HTML head or via server headers -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' https://trusted-cdn.com;
               style-src 'self' 'unsafe-inline';
               img-src 'self' data: https:;">
```

**Input sanitization at storage:**

While XSS protection happens at rendering, you can sanitize on storage as defense-in-depth:

```javascript
import DOMPurify from 'dompurify';

// Sanitize before storing
const sanitizedContent = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p'],
  ALLOWED_ATTR: ['href']
});

await supabase
  .from('posts')
  .insert({ content: sanitizedContent });
```

**Attribute-based attacks:**

Be cautious with user-controlled attributes:

```javascript
// UNSAFE - user can inject javascript: URLs
<a href={userProvidedURL}>Link</a>

// SAFE - validate URL scheme
function SafeLink({ url, children }) {
  const isSafe = url.startsWith('http://') || url.startsWith('https://');
  const safeUrl = isSafe ? url : '#';
  
  return <a href={safeUrl}>{children}</a>;
}
```

**Database patterns supporting XSS protection:**

Store content type metadata:

```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  content TEXT NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('plaintext', 'markdown', 'html')),
  -- Store original + sanitized versions
  content_raw TEXT,
  content_sanitized TEXT
);
```

**Markdown over HTML:**

When possible, accept Markdown instead of raw HTML and render with a safe parser:

```javascript
import ReactMarkdown from 'react-markdown';

function Post({ post }) {
  return (
    <ReactMarkdown>
      {post.markdown_content}
    </ReactMarkdown>
  );
}
```

**Protection checklist:**

- Never use `dangerouslySetInnerHTML`, `v-html`, or equivalent without sanitization
- Always sanitize user-generated HTML with DOMPurify or similar
- Implement Content Security Policy headers
- Validate and whitelist URL schemes for user-provided links
- Use framework-native escaping for dynamic content
- Prefer Markdown or plain text over HTML when possible
- Escape content in attributes (`title`, `alt`, etc.)
- Be especially careful with user-controlled JavaScript event handlers

**Session token protection:**

Store authentication tokens securely to prevent XSS-based theft:

```javascript
// Supabase handles this automatically, storing tokens in httpOnly contexts
// [Inference: Exact storage mechanism may vary by client library and platform]

// Don't store sensitive tokens in localStorage if XSS risk exists
// Prefer httpOnly cookies or secure framework-managed storage
```

