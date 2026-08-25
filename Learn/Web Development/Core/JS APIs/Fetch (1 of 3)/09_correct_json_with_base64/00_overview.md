## Overview

with open('image.jpg', 'rb') as f:
    image_b64 = base64.b64encode(f.read()).decode()
    
payload = {
    'model': 'claude-sonnet-4-20250514',
    'messages': [{
        'role': 'user',
        'content': [{
            'type': 'image',
            'source': {'type': 'base64', 'media_type': 'image/jpeg', 'data': image_b64}
        }]
    }]
}
requests.post(url, json=payload)
```

#### Mistake 2: Manual Multipart Construction

```python
