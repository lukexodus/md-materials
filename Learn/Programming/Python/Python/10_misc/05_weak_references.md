## Weak References


### What is a Weak Reference in Python?

A **weak reference** lets you refer to an object **without increasing its reference count**. This means the object can still be garbage-collected even if weak references to it exist.

**Why use weak references?**

* Avoid **memory leaks** in large object graphs.
* Useful in caching and memoization.
* Prevent objects from being kept alive just because some “helper” object references them.

---

### How to Use `weakref`

The `weakref` module provides tools for weak references.

#### Example — Basic Weak Reference

```python
import weakref

class MyClass:
    pass

obj = MyClass()

# Create a weak reference
weak_obj = weakref.ref(obj)

# Call the weak reference to get the object back
print(weak_obj())      # <__main__.MyClass object at 0x...>

# Delete the original object
del obj

# Now the weak reference returns None
print(weak_obj())      # None
```

---

### `weakref` in Collections

If you want to keep a **collection** of weak references, use:

* `weakref.WeakSet` — for a set of weak references
* `weakref.WeakKeyDictionary` — keys are weak references
* `weakref.WeakValueDictionary` — values are weak references

---

#### Example — WeakValueDictionary

A cache that auto-clears items when values are garbage collected:

```python
import weakref

class Data:
    def __init__(self, name):
        self.name = name

cache = weakref.WeakValueDictionary()

d = Data("example")

cache["item"] = d

print(cache["item"].name)  # example

del d

# Now the object is gone
print(cache.get("item"))   # None
```

---

### Weak Reference Callbacks

Weak references can register a **callback** that runs when the object is about to be finalized:

```python
import weakref

class MyClass:
    pass

def on_finalize(wr):
    print("Object has been garbage-collected!")

obj = MyClass()
wr = weakref.ref(obj, on_finalize)

del obj
# prints: Object has been garbage-collected!
```

---

### Why Not Just Use Normal References?

Normal references keep objects alive. For instance:

```python
refs = []
obj = MyClass()
refs.append(obj)
# obj will never be freed as long as refs points to it
```

A weak reference avoids that problem.

---

**Summary:**

* Weak references don’t increase an object’s ref count.
* Object can still be garbage-collected.
* Useful for caches and memory-sensitive structures.
* Provided by Python’s `weakref` module.

---

I'll explain Python's five parameter kinds that `inspect.signature()` uses to classify function parameters.

