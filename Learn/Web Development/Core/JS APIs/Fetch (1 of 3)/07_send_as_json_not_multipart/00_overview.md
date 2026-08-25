## Overview

response = requests.post(
    'https://api.anthropic.com/v1/messages',
    headers={
        'Content-Type': 'application/json',
        'x-api-key': 'sk-ant-...',
        'anthropic-version': '2023-06-01'
    },
    json=payload  # This sets Content-Type correctly
)
```

#### JavaScript Implementation

```javascript
// Read file from input element
const fileInput = document.getElementById('fileInput');
const file = fileInput.files[0];

// Convert to base64
const reader = new FileReader();
reader.onload = async (e) => {
    const base64Data = e.target.result.split(',')[1]; // Remove data:image/jpeg;base64, prefix
    
    const payload = {
        model: 'claude-sonnet-4-20250514',
        max_tokens: 1024,
        messages: [{
            role: 'user',
            content: [
                {
                    type: 'image',
                    source: {
                        type: 'base64',
                        media_type: file.type,
                        data: base64Data
                    }
                },
                {
                    type: 'text',
                    text: 'Analyze this image'
                }
            ]
        }]
    };
    
    const response = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'x-api-key': 'sk-ant-...',
            'anthropic-version': '2023-06-01'
        },
        body: JSON.stringify(payload)
    });
};

reader.readAsDataURL(file);
```

### Common Migration Mistakes

Developers familiar with multipart APIs often make these errors:

#### Mistake 1: Using Multipart Libraries

```python
