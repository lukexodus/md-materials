## Overview

CORS(app, 
     origins=['https://app.example.com', 'https://admin.example.com'],
     methods=['GET', 'POST', 'PUT', 'DELETE'],
     allow_headers=['Content-Type', 'Authorization'],
     expose_headers=['X-Total-Count'],
     supports_credentials=True,
     max_age=86400)

@app.route('/api/data')
def get_data():
    return jsonify({'data': 'example'})
```

**Django:**

```python
