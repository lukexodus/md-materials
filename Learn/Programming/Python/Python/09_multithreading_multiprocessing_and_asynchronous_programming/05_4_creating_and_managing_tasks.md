## **4. Creating and Managing Tasks**


`asyncio.create_task()` schedules coroutines as tasks, allowing them to run independently.

```python
import asyncio

async def task(name, duration):
    print(f"{name} started")
    await asyncio.sleep(duration)
    print(f"{name} finished")

async def main():
    task_a = asyncio.create_task(task("Task A", 2))
    task_b = asyncio.create_task(task("Task B", 1))

    await task_a  # Wait for Task A to finish
    await task_b  # Wait for Task B to finish

asyncio.run(main())
```

### **Explanation:**

- `asyncio.create_task()` schedules `task` execution in the background.
- Both tasks start immediately, but Task B finishes first since it has a shorter sleep time.

---

