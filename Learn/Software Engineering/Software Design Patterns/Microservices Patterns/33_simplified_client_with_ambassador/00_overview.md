## Overview

import requests

class PaymentClient:
    def __init__(self):
        # Connect to local ambassador instead of remote service
        self.ambassador_url = "http://localhost:8080"
    
    def process_payment(self, payment_data):
        # Ambassador handles retries, timeouts, logging, etc.
        response = requests.post(
            f"{self.ambassador_url}/payments",
            json=payment_data
        )
        return response.json()
```

The Ambassador service handles all infrastructure concerns:

```python
