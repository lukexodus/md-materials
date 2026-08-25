## process.memoryUsage()


This is a Node.js method that returns an object describing the memory usage of the current Node.js process, measured in bytes.

### Return Object Properties

**rss (Resident Set Size)** - Total memory allocated for the process, including all C++ and JavaScript objects and code.

**heapTotal** - Total size of the allocated heap.

**heapUsed** - Actual memory used during the execution of the process.

**external** - Memory used by C++ objects bound to JavaScript objects managed by V8.

**arrayBuffers** - Memory allocated for ArrayBuffers and SharedArrayBuffers.

### Basic Usage

```javascript
const memUsage = process.memoryUsage();
console.log(memUsage);

// Output example:
// {
//   rss: 36864000,
//   heapTotal: 6537216,
//   heapUsed: 4818568,
//   external: 1089863,
//   arrayBuffers: 26906
// }
```

### Converting to Megabytes

```javascript
const formatMemoryUsage = (data) => {
  const formatted = {};
  for (let key in data) {
    formatted[key] = `${Math.round(data[key] / 1024 / 1024 * 100) / 100} MB`;
  }
  return formatted;
};

console.log(formatMemoryUsage(process.memoryUsage()));
```

### Monitoring Memory Over Time

```javascript
setInterval(() => {
  const mem = process.memoryUsage();
  console.log(`Heap Used: ${(mem.heapUsed / 1024 / 1024).toFixed(2)} MB`);
}, 1000);
```

This is commonly used for debugging memory leaks or optimizing application performance.​​​​​​​​​​​​​​​​

---

