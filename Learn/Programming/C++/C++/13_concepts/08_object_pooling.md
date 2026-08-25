## **Object Pooling**


**Object pooling** is a **design pattern** that helps manage objects efficiently by **reusing** them instead of creating and destroying them repeatedly. It is useful when object creation is expensive in terms of time or memory.

---

### **How Object Pooling Works**

1. **Preallocate** a set of objects in a pool.
2. **Reuse objects** from the pool instead of creating new ones.
3. **Return objects** to the pool after use.
4. **Efficient memory usage** and **faster performance** since objects are not frequently allocated and deallocated.

---

### **Example: Object Pool for Database Connections**

✅ **Example:** A simple object pool that manages database connections.

```cpp
#include <iostream>
#include <vector>
using namespace std;

class Connection {
public:
    Connection() { cout << "Connection Created\n"; }
    void use() { cout << "Using Connection\n"; }
};

class ConnectionPool {
private:
    vector<Connection*> pool;
public:
    ConnectionPool(int size) {
        for (int i = 0; i < size; ++i)
            pool.push_back(new Connection());
    }

    Connection* acquire() {
        if (!pool.empty()) {
            Connection* conn = pool.back();
            pool.pop_back();
            return conn;
        }
        return new Connection(); // Create a new one if pool is empty
    }

    void release(Connection* conn) {
        pool.push_back(conn);
    }

    ~ConnectionPool() {
        for (auto conn : pool) delete conn;
    }
};

int main() {
    ConnectionPool pool(2);

    Connection* c1 = pool.acquire();
    c1->use();

    Connection* c2 = pool.acquire();
    c2->use();

    pool.release(c1);
    pool.release(c2);

    Connection* c3 = pool.acquire();
    c3->use();  // Reuses a previously released connection

    return 0;
}
```

**Output:**

```
Connection Created
Connection Created
Using Connection
Using Connection
Using Connection
```

---

**Key Points**

✅ **Object pooling** improves performance by reusing objects.  
✅ **Preallocating** objects reduces memory allocation overhead.  
✅ **Returning objects** to the pool prevents frequent destruction and recreation.  
✅ Useful for **database connections, thread pools, game objects, network sockets, etc.**

---

