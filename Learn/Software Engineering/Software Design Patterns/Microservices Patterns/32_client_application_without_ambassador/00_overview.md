## Overview

import requests
import time

class PaymentClient:
    def __init__(self):
        self.api_url = "https://payment-api.example.com"
        self.max_retries = 3
        self.timeout = 5
    
    def process_payment(self, payment_data):
        for attempt in range(self.max_retries):
            try:
                response = requests.post(
                    f"{self.api_url}/payments",
                    json=payment_data,
                    timeout=self.timeout
                )
                if response.status_code == 200:
                    # Log success
                    print(f"Payment processed: {response.json()}")
                    return response.json()
                elif response.status_code >= 500:
                    # Retry on server errors
                    if attempt < self.max_retries - 1:
                        time.sleep(2 ** attempt)  # Exponential backoff
                        continue
                else:
                    # Client error, don't retry
                    raise Exception(f"Payment failed: {response.text}")
            except requests.Timeout:
                if attempt < self.max_retries - 1:
                    time.sleep(2 ** attempt)
                    continue
                raise Exception("Payment service timeout")
        
        raise Exception("Payment failed after retries")
```

With the Ambassador pattern, the client becomes much simpler:

```python
