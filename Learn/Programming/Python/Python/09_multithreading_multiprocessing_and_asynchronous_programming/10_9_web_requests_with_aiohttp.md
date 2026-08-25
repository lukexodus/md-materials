## **9. Web Requests with `aiohttp`**


To make non-blocking HTTP requests, use `aiohttp`.

```python
import aiohttp
import asyncio

async def fetch(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

async def main():
    url = "https://www.example.com"
    content = await fetch(url)
    print(content[:200])  # Print first 200 characters

asyncio.run(main())
```

### **Explanation:**

- `aiohttp.ClientSession()` manages HTTP requests asynchronously.
- `await response.text()` ensures the response is retrieved asynchronously.

---

