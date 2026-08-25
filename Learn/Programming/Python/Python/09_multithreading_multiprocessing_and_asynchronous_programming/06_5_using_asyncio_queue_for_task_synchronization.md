## **5. Using `asyncio.Queue` for Task Synchronization**


An `asyncio.Queue` can be used to manage tasks in a producer-consumer pattern.

```python
import asyncio

async def producer(queue):
    for i in range(5):
        await asyncio.sleep(1)
        await queue.put(i)
        print(f"Produced: {i}")

async def consumer(queue):
    while True:
        item = await queue.get()
        print(f"Consumed: {item}")
        queue.task_done()

async def main():
    queue = asyncio.Queue()
    producer_task = asyncio.create_task(producer(queue))
    consumer_task = asyncio.create_task(consumer(queue))

    await producer_task  # Wait for the producer to finish
    await queue.join()   # Ensure all items are processed
    consumer_task.cancel()  # Stop the consumer

asyncio.run(main())
```

### **Explanation:**

- The producer generates data and adds it to the queue.
- The consumer retrieves and processes data from the queue.
- `queue.join()` ensures all items are processed before stopping.

---

