## **2. Creating and Running Coroutines**


A coroutine is defined using `async def` and is executed using `await`.

```python
import asyncio

async def greet():
    print("Hello,")
    await asyncio.sleep(2)  # Simulates an I/O operation
    print("World!")

asyncio.run(greet())  # Runs the coroutine
```

### **Explanation:**

- The `await asyncio.sleep(2)` suspends execution for 2 seconds.
- The event loop allows other tasks to run during the wait time.

---

