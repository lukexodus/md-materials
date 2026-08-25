## **8. Asynchronous File Handling with `aiofiles`**


Standard file operations are blocking. To handle them asynchronously, use `aiofiles`.

```python
import asyncio
import aiofiles

async def read_file():
    async with aiofiles.open('example.txt', 'r') as file:
        content = await file.read()
        print(content)

asyncio.run(read_file())
```

### **Explanation:**

- `aiofiles.open()` allows non-blocking file access.
- `await file.read()` ensures the file read operation is handled asynchronously.

---

