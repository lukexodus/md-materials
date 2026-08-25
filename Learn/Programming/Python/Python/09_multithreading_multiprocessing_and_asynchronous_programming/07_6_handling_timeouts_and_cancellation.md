## **6. Handling Timeouts and Cancellation**


Asynchronous tasks can be **timed out** or **canceled** using `asyncio.wait_for()`.

```python
import asyncio

async def long_running_task():
    await asyncio.sleep(5)
    return "Task Completed"

async def main():
    try:
        result = await asyncio.wait_for(long_running_task(), timeout=2)
        print(result)
    except asyncio.TimeoutError:
        print("Task timed out!")

asyncio.run(main())
```

### **Explanation:**

- `asyncio.wait_for(long_running_task(), timeout=2)` ensures that the task is canceled if it takes longer than 2 seconds.

---

