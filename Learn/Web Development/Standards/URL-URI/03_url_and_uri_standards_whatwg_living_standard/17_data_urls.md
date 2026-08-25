## Data URLs


Data URLs embed small data items directly in documents. They use the data: scheme and include the media type and encoding directly in the URL.

The syntax follows: `data:[<mediatype>][;base64],<data>`

**Example:**

```
data:text/plain;charset=UTF-8,Hello%20World
data:text/html,<h1>Hello</h1>
data:image/png;base64,iVBORw0KGgoAAAANS...
```

Data URLs are useful for embedding small images, fonts, or other resources without separate HTTP requests. They increase document size and cannot be cached separately. Base64 encoding increases data size by approximately 33%.

