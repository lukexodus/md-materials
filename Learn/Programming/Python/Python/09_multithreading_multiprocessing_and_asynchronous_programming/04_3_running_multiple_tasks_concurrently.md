## **3. Running Multiple Tasks Concurrently**


Instead of running coroutines sequentially, we can run multiple tasks concurrently using `asyncio.gather()`.

```python
import asyncio

async def task1():
    print("Task 1 started")
    await asyncio.sleep(2)
    print("Task 1 finished")

async def task2():
    print("Task 2 started")
    await asyncio.sleep(1)
    print("Task 2 finished")

async def main():
    await asyncio.gather(task1(), task2())  # Run both tasks concurrently

asyncio.run(main())
```

### **Explanation:**

- `asyncio.gather(task1(), task2())` executes both tasks at the same time.
- Task 2 finishes before Task 1 since it sleeps for 1 second instead of 2.

---

