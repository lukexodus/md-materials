## **7. Running Async Code in a Synchronous Program**


In some cases, you may need to run async code inside a synchronous function using `asyncio.run_coroutine_threadsafe()`.

```python
import asyncio

async def background_task():
    while True:
        print("Running in the background...")
        await asyncio.sleep(2)

loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)
task = loop.create_task(background_task())

try:
    loop.run_forever()  # Keep running indefinitely
except KeyboardInterrupt:
    task.cancel()
    loop.close()
```

---

