## Inter-Process Communication: FIFO Pipes and Sockets


### FIFO Pipes (Named Pipes)

FIFO pipes are a form of inter-process communication that allows unrelated processes to exchange data through a special file in the filesystem. Unlike anonymous pipes, FIFOs have a pathname and can be accessed by any process with appropriate permissions.

**Key Characteristics:**

- **Unidirectional communication**: Data flows in one direction only
- **File-based interface**: Created using `mkfifo()` system call or command
- **Persistent**: Exists in the filesystem until explicitly deleted
- **Local only**: Limited to processes on the same machine
- **FIFO ordering**: First data written is first data read
- **Blocking behavior**: Reads block when empty, writes block when full

**Common Use Cases:**

- Simple producer-consumer patterns on the same host
- Shell script communication
- Logging and data pipeline applications

### Sockets

Sockets provide a more flexible communication mechanism that supports both local and network-based inter-process communication. They offer bidirectional data exchange and multiple protocol options.

**Key Characteristics:**

- **Bidirectional communication**: Data can flow in both directions
- **Multiple domains**: Unix domain (local) and Internet domain (network)
- **Protocol options**: Stream (TCP), datagram (UDP), and others
- **Connection models**: Connection-oriented or connectionless
- **Network capable**: Can communicate across different machines
- **More complex API**: Requires socket creation, binding, connecting/listening

**Common Use Cases:**

- Client-server applications
- Network services and protocols
- Local high-performance IPC (Unix domain sockets)
- Distributed systems

### Comparison

| Aspect              | FIFO Pipes       | Sockets                        |
| ------------------- | ---------------- | ------------------------------ |
| Direction           | Unidirectional   | Bidirectional                  |
| Scope               | Local only       | Local or network               |
| Complexity          | Simple           | More complex                   |
| Performance (local) | Fast             | Unix domain sockets comparable |
| Use case            | Simple local IPC | Complex/network IPC            |
|                     |                  |                                |

---

