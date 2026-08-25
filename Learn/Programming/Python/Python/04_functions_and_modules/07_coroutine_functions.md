## Coroutine Functions


Coroutines are functions defined with `async def` that can be paused and resumed, allowing for asynchronous programming. They use `await` to suspend execution until an awaited operation completes.

```python
import asyncio

async def fetch_data():
    print("Start fetching")
    await asyncio.sleep(1)  # Simulates async operation
    print("Done fetching")
    return "data"

# Running the coroutine
asyncio.run(fetch_data())
```

Key characteristics:
- Defined with `async def`
- Use `await` for asynchronous operations
- Enable concurrent execution without threading
- Must be run in an event loop

Practical example with multiple coroutines:
```python
async def task(name, delay):
    print(f"{name} starting")
    await asyncio.sleep(delay)
    print(f"{name} completed")
    return f"Result from {name}"

async def main():
    # Run multiple coroutines concurrently
    results = await asyncio.gather(
        task("Task 1", 2),
        task("Task 2", 1),
        task("Task 3", 1.5)
    )
    print(results)

asyncio.run(main())
```

---

