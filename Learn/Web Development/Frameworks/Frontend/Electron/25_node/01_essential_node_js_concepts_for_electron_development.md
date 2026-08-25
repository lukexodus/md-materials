## Essential Node.js Concepts for Electron Development


Building solid Electron applications requires understanding several core Node.js concepts that underpin how Electron works. Here are the fundamental ones:

### Process and Child Process

**process (Global Object)**

The `process` object provides information about and control over the current Node.js process. In Electron, understanding `process` is crucial because you're working with multiple processes (main and renderer).

```javascript
// Check which process you're in
console.log(process.type); // 'browser' (main) or 'renderer'

// Environment variables
console.log(process.env.NODE_ENV);

// Platform detection
if (process.platform === 'darwin') {
  // macOS-specific code
}

// Exit the process
process.exit(0);

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  console.error('Uncaught error:', error);
});
```

**child_process Module**

Allows you to spawn an d manage child processes. Useful when your Electron app needs to run external commands or scripts.

```javascript
const { spawn, exec } = require('child_process');

// Spawn a long-running process
const pythonProcess = spawn('python', ['script.py']);

pythonProcess.stdout.on('data', (data) => {
  console.log(`Output: ${data}`);
});

// Execute a simple command
exec('ls -la', (error, stdout, stderr) => {
  if (error) {
    console.error(`Error: ${error.message}`);
    return;
  }
  console.log(stdout);
});
```

### Streams

Streams handle data flowing through your application piece by piece, rather than loading everything into memory at once. Critical for file operations, network requests, and any large data processing.

**Types of Streams**

Readable streams (read data from a source), Writable streams (write data to a destination), Duplex streams (both readable and writable), and Transform streams (modify data as it passes through).

```javascript
const fs = require('fs');

// Reading a large file efficiently
const readStream = fs.createReadStream('large-file.txt', {
  encoding: 'utf8',
  highWaterMark: 16 * 1024 // 16KB chunks
});

readStream.on('data', (chunk) => {
  console.log(`Received ${chunk.length} bytes`);
});

readStream.on('end', () => {
  console.log('Finished reading');
});

// Piping streams together
const writeStream = fs.createWriteStream('output.txt');
readStream.pipe(writeStream);
```

**Why This Matters in Electron**

When building file processing features, handling large downloads, or streaming media, streams prevent memory overload and keep your app responsive.

### Buffer

Buffers handle raw binary data, which is essential when working with files, network protocols, or any non-text data.

```javascript
// Creating buffers
const buf1 = Buffer.from('Hello', 'utf8');
const buf2 = Buffer.alloc(10); // 10 bytes of zeros
const buf3 = Buffer.allocUnsafe(10); // Faster but uninitialized

// Working with binary data
const imageBuffer = fs.readFileSync('image.png');
console.log(imageBuffer.length); // Size in bytes

// Converting between formats
const base64 = imageBuffer.toString('base64');
const backToBuffer = Buffer.from(base64, 'base64');

// Concatenating buffers
const combined = Buffer.concat([buf1, buf2]);
```

**Electron Use Cases**

Handling file uploads/downloads, working with images before display, processing audio/video data, or implementing custom protocols.

### Path Module

The `path` module provides utilities for working with file and directory paths in a cross-platform way. Essential since Electron apps run on Windows, macOS, and Linux with different path conventions.

```javascript
const path = require('path');

// Join path segments correctly for the OS
const filePath = path.join(__dirname, 'assets', 'icon.png');
// On Windows: C:\app\assets\icon.png
// On Unix: /app/assets/icon.png

// Get file extension
path.extname('document.pdf'); // '.pdf'

// Get filename without extension
path.basename('document.pdf', '.pdf'); // 'document'

// Get directory name
path.dirname('/user/docs/file.txt'); // '/user/docs'

// Resolve absolute path
const absolute = path.resolve('..', 'data', 'config.json');

// Normalize paths (clean up .., ., etc.)
path.normalize('/user/../admin/data'); // '/admin/data'
```

### File System (fs)

The `fs` module enables interaction with the file system. Nearly every Electron app needs to read or write files.

```javascript
const fs = require('fs');
const fsPromises = require('fs').promises;

// Synchronous (blocks execution)
const data = fs.readFileSync('config.json', 'utf8');

// Asynchronous with callbacks
fs.readFile('config.json', 'utf8', (err, data) => {
  if (err) throw err;
  console.log(data);
});

// Promise-based (modern approach)
async function readConfig() {
  try {
    const data = await fsPromises.readFile('config.json', 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading config:', error);
  }
}

// Writing files
await fsPromises.writeFile('output.txt', 'Hello World', 'utf8');

// Checking if file exists
const exists = fs.existsSync('file.txt');

// Creating directories
await fsPromises.mkdir('new-folder', { recursive: true });

// Watching for file changes
fs.watch('config.json', (eventType, filename) => {
  console.log(`${filename} changed: ${eventType}`);
});
```

### Promises and async/await

Modern asynchronous programming patterns that make code more readable than callback-based approaches.

```javascript
// Creating a promise
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Using async/await
async function loadData() {
  try {
    console.log('Loading...');
    await delay(1000);
    
    const data = await fsPromises.readFile('data.json', 'utf8');
    const parsed = JSON.parse(data);
    
    return parsed;
  } catch (error) {
    console.error('Failed to load data:', error);
    throw error;
  }
}

// Parallel operations
async function loadMultipleFiles() {
  const [file1, file2, file3] = await Promise.all([
    fsPromises.readFile('file1.txt', 'utf8'),
    fsPromises.readFile('file2.txt', 'utf8'),
    fsPromises.readFile('file3.txt', 'utf8')
  ]);
  
  return { file1, file2, file3 };
}
```

### Modules and require/import

Understanding Node's module system is fundamental to organizing Electron code.

```javascript
// CommonJS (traditional Node.js)
const fs = require('fs');
const myModule = require('./myModule');

module.exports = {
  myFunction() {
    // ...
  }
};

// ES Modules (modern, requires configuration)
import fs from 'fs';
import { myFunction } from './myModule.js';

export function anotherFunction() {
  // ...
}

export default class MyClass {
  // ...
}
```

**Important for Electron**

The main process typically uses CommonJS, while renderer processes can use either. You need to configure this properly in your build setup.

### Error Handling Patterns

Proper error handling prevents crashes and improves user experience.

```javascript
// Try-catch for synchronous and async/await code
try {
  const data = fs.readFileSync('file.txt');
} catch (error) {
  console.error('Error reading file:', error.message);
}

// Error events on EventEmitters
const stream = fs.createReadStream('file.txt');
stream.on('error', (error) => {
  console.error('Stream error:', error);
});

// Promise rejection handling
someAsyncOperation()
  .catch((error) => {
    console.error('Operation failed:', error);
  });

// Global error handlers
process.on('uncaughtException', (error) => {
  console.error('Uncaught exception:', error);
  // Log to file, show error dialog, etc.
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled promise rejection:', reason);
});
```

### URL and querystring

Working with URLs is common in Electron apps, especially for loading content or handling deep links.

```javascript
const { URL, URLSearchParams } = require('url');

// Parsing URLs
const myUrl = new URL('https://example.com/path?key=value&foo=bar');
console.log(myUrl.hostname); // 'example.com'
console.log(myUrl.pathname); // '/path'
console.log(myUrl.search);   // '?key=value&foo=bar'

// Working with query parameters
const params = new URLSearchParams(myUrl.search);
console.log(params.get('key')); // 'value'
params.append('new', 'param');

// Building URLs
const url = new URL('/api/data', 'https://example.com');
url.searchParams.set('id', '123');
console.log(url.href); // 'https://example.com/api/data?id=123'
```

### Timers

While similar to browser timers, understanding Node's event loop and how timers work is important for performance.

```javascript
// setTimeout - run once after delay
const timeoutId = setTimeout(() => {
  console.log('Executed after 1 second');
}, 1000);

clearTimeout(timeoutId); // Cancel if needed

// setInterval - run repeatedly
const intervalId = setInterval(() => {
  console.log('Executed every 2 seconds');
}, 2000);

clearInterval(intervalId); // Stop when done

// setImmediate - run after I/O events
setImmediate(() => {
  console.log('Runs after I/O');
});

// process.nextTick - run before any I/O
process.nextTick(() => {
  console.log('Runs before any I/O');
});
```

### os Module

Get system information, which is useful for platform-specific features or diagnostics.

```javascript
const os = require('os');

// Platform information
console.log(os.platform()); // 'darwin', 'win32', 'linux'
console.log(os.arch());     // 'x64', 'arm64'
console.log(os.type());     // 'Darwin', 'Windows_NT', 'Linux'

// System resources
console.log(os.totalmem()); // Total memory in bytes
console.log(os.freemem());  // Free memory in bytes
console.log(os.cpus());     // CPU core information

// User information
console.log(os.homedir());  // User's home directory
console.log(os.tmpdir());   // Temporary directory
console.log(os.userInfo()); // Current user details
```

### Practical Integration Example

Here's how several of these concepts work together in a typical Electron app feature:

```javascript
const { app } = require('electron');
const fs = require('fs').promises;
const path = require('path');
const { EventEmitter } = require('events');

class DataManager extends EventEmitter {
  constructor() {
    super();
    this.dataPath = path.join(app.getPath('userData'), 'app-data.json');
  }
  
  async loadData() {
    try {
      this.emit('loading');
      
      const exists = await fs.access(this.dataPath)
        .then(() => true)
        .catch(() => false);
      
      if (!exists) {
        this.emit('loaded', {});
        return {};
      }
      
      const content = await fs.readFile(this.dataPath, 'utf8');
      const data = JSON.parse(content);
      
      this.emit('loaded', data);
      return data;
      
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }
  
  async saveData(data) {
    try {
      this.emit('saving');
      
      const json = JSON.stringify(data, null, 2);
      await fs.writeFile(this.dataPath, json, 'utf8');
      
      this.emit('saved');
      
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }
}

// Usage
const manager = new DataManager();

manager.on('loading', () => console.log('Loading data...'));
manager.on('loaded', (data) => console.log('Data loaded:', data));
manager.on('error', (error) => console.error('Error:', error));

async function init() {
  const data = await manager.loadData();
  data.lastAccess = new Date().toISOString();
  await manager.saveData(data);
}
```

### net Module

The `net` module provides an asynchronous network API for creating TCP servers and clients. Useful for building Electron apps that need network communication, custom protocols, or server functionality.

```javascript
const net = require('net');

// Creating a TCP server
const server = net.createServer((socket) => {
  console.log('Client connected');
  
  socket.on('data', (data) => {
    console.log('Received:', data.toString());
    socket.write('Echo: ' + data);
  });
  
  socket.on('end', () => {
    console.log('Client disconnected');
  });
  
  socket.on('error', (err) => {
    console.error('Socket error:', err);
  });
});

server.listen(8080, () => {
  console.log('Server listening on port 8080');
});

// Creating a TCP client
const client = net.createConnection({ port: 8080 }, () => {
  console.log('Connected to server');
  client.write('Hello server!');
});

client.on('data', (data) => {
  console.log('Server response:', data.toString());
  client.end();
});
```

**Electron Use Cases**

Building local servers for debugging tools, creating inter-app communication systems, implementing custom network protocols, or building developer tools that monitor network traffic.

### http/https Modules

For making HTTP requests or creating HTTP servers within your Electron app.

```javascript
const https = require('https');
const http = require('http');

// Making an HTTP request
https.get('https://api.example.com/data', (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    const parsed = JSON.parse(data);
    console.log(parsed);
  });
}).on('error', (err) => {
  console.error('Request error:', err);
});

// POST request with more control
const postData = JSON.stringify({ key: 'value' });

const options = {
  hostname: 'api.example.com',
  port: 443,
  path: '/submit',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

const req = https.request(options, (res) => {
  res.on('data', (chunk) => {
    console.log(chunk.toString());
  });
});

req.on('error', (e) => {
  console.error('Problem with request:', e.message);
});

req.write(postData);
req.end();

// Creating a simple HTTP server
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from Electron app!\n');
});

server.listen(3000);
```

### crypto Module

Provides cryptographic functionality for security-sensitive operations like hashing, encryption, and random number generation.

```javascript
const crypto = require('crypto');

// Generating random bytes
const randomBytes = crypto.randomBytes(16);
console.log(randomBytes.toString('hex'));

// Hashing data (one-way)
const hash = crypto.createHash('sha256');
hash.update('password123');
const hashed = hash.digest('hex');
console.log('SHA-256:', hashed);

// Encrypting data (two-way)
const algorithm = 'aes-256-cbc';
const key = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);

function encrypt(text) {
  const cipher = crypto.createCipheriv(algorithm, key, iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return encrypted;
}

function decrypt(encrypted) {
  const decipher = crypto.createDecipheriv(algorithm, key, iv);
  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}

const encrypted = encrypt('Sensitive data');
const decrypted = decrypt(encrypted);

// Creating secure tokens
const token = crypto.randomBytes(32).toString('base64');

// HMAC for message authentication
const hmac = crypto.createHmac('sha256', 'secret-key');
hmac.update('message to authenticate');
const signature = hmac.digest('hex');
```

**Electron Use Cases**

User authentication, encrypting local data storage, generating secure session tokens, password hashing, or implementing license verification systems.

### util Module

Provides utility functions, including promisification of callback-based functions and formatting.

```javascript
const util = require('util');
const fs = require('fs');

// Promisify callback-based functions
const readFileAsync = util.promisify(fs.readFile);

async function readConfig() {
  const data = await readFileAsync('config.json', 'utf8');
  return JSON.parse(data);
}

// Formatting strings (like printf)
const formatted = util.format('%s:%d', 'localhost', 8080);
console.log(formatted); // 'localhost:8080'

// Type checking
console.log(util.types.isDate(new Date())); // true
console.log(util.types.isPromise(Promise.resolve())); // true
console.log(util.types.isArrayBuffer(new ArrayBuffer())); // true

// Deprecation warnings
const deprecatedFunction = util.deprecate(
  () => console.log('Old way'),
  'This function is deprecated. Use newFunction() instead.'
);

// Deep object inspection
const complexObject = { a: 1, b: { c: 2, d: [3, 4] } };
console.log(util.inspect(complexObject, { depth: null, colors: true }));
```

### zlib Module

For compression and decompression, useful for handling compressed files or reducing data size.

```javascript
const zlib = require('zlib');
const fs = require('fs');

// Compress data
const input = 'This is some data to compress. '.repeat(100);

zlib.gzip(input, (err, compressed) => {
  if (err) throw err;
  
  console.log('Original size:', Buffer.byteLength(input));
  console.log('Compressed size:', compressed.length);
  
  // Decompress
  zlib.gunzip(compressed, (err, decompressed) => {
    if (err) throw err;
    console.log('Decompressed:', decompressed.toString());
  });
});

// Compress a file using streams
const gzip = zlib.createGzip();
const source = fs.createReadStream('input.txt');
const destination = fs.createWriteStream('input.txt.gz');

source.pipe(gzip).pipe(destination);

// Promise-based compression
const { promisify } = require('util');
const gzipAsync = promisify(zlib.gzip);

async function compressData(data) {
  const compressed = await gzipAsync(data);
  return compressed;
}
```

**Electron Use Cases**

Compressing log files, reducing backup sizes, handling compressed downloads, or optimizing data transfer in custom protocols.

### dns Module

For DNS lookups and resolution, useful for network-aware applications.

```javascript
const dns = require('dns');
const { promisify } = require('util');

const lookup = promisify(dns.lookup);
const resolve4 = promisify(dns.resolve4);

// Look up IP address
async function getIP(hostname) {
  try {
    const { address } = await lookup(hostname);
    console.log('IP address:', address);
    return address;
  } catch (err) {
    console.error('DNS lookup failed:', err);
  }
}

getIP('google.com');

// Resolve all IPv4 addresses
async function getAllIPs(hostname) {
  try {
    const addresses = await resolve4(hostname);
    console.log('All IPs:', addresses);
  } catch (err) {
    console.error('Resolution failed:', err);
  }
}

// Reverse DNS lookup
dns.reverse('8.8.8.8', (err, hostnames) => {
  if (err) throw err;
  console.log('Hostnames:', hostnames);
});
```

### Worker Threads

For CPU-intensive operations without blocking the main thread. [Inference: This is particularly valuable in Electron to prevent UI freezing]

```javascript
const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');

if (isMainThread) {
  // Main thread code
  const worker = new Worker(__filename, {
    workerData: { start: 1, end: 1000000 }
  });
  
  worker.on('message', (result) => {
    console.log('Result from worker:', result);
  });
  
  worker.on('error', (err) => {
    console.error('Worker error:', err);
  });
  
  worker.on('exit', (code) => {
    if (code !== 0) {
      console.error(`Worker stopped with exit code ${code}`);
    }
  });
  
} else {
  // Worker thread code
  function heavyComputation(start, end) {
    let sum = 0;
    for (let i = start; i <= end; i++) {
      sum += i;
    }
    return sum;
  }
  
  const result = heavyComputation(workerData.start, workerData.end);
  parentPort.postMessage(result);
}
```

**Electron Use Cases**

Image processing, video encoding, large data parsing, cryptographic operations, or any CPU-intensive task that would freeze the UI if run on the main thread.

### Timers and setImmediate Details

Understanding the Node.js event loop phases helps write more efficient code.

```javascript
// Event loop order demonstration
console.log('1: Synchronous');

setImmediate(() => {
  console.log('2: setImmediate');
});

process.nextTick(() => {
  console.log('3: nextTick');
});

setTimeout(() => {
  console.log('4: setTimeout 0ms');
}, 0);

Promise.resolve().then(() => {
  console.log('5: Promise');
});

console.log('6: Synchronous');

// Output order:
// 1: Synchronous
// 6: Synchronous
// 3: nextTick
// 5: Promise
// 4: setTimeout 0ms
// 2: setImmediate
```

**Understanding Event Loop Phases** [Inference based on Node.js documentation]

The event loop processes tasks in phases: timers, pending callbacks, idle/prepare, poll, check (setImmediate), and close callbacks. `process.nextTick()` and Promise callbacks execute between phases.

### readline Module

For reading input line by line, useful for CLI tools or processing text files.

```javascript
const readline = require('readline');
const fs = require('fs');

// Reading from a file line by line
const fileStream = fs.createReadStream('large-file.txt');

const rl = readline.createInterface({
  input: fileStream,
  crlfDelay: Infinity // Recognize all CR LF instances
});

rl.on('line', (line) => {
  console.log(`Line: ${line}`);
});

rl.on('close', () => {
  console.log('Finished reading file');
});

// Interactive command line interface
const cliInterface = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

cliInterface.question('What is your name? ', (answer) => {
  console.log(`Hello, ${answer}!`);
  cliInterface.close();
});

// Reading multiple inputs
async function getUserInput() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  
  const question = (query) => new Promise((resolve) => {
    rl.question(query, resolve);
  });
  
  const name = await question('Name: ');
  const age = await question('Age: ');
  
  rl.close();
  return { name, age };
}
```

### assert Module

For writing tests and validating assumptions in your code.

```javascript
const assert = require('assert');

// Basic assertions
assert.strictEqual(1 + 1, 2); // Passes
// assert.strictEqual(1 + 1, 3); // Throws AssertionError

// Deep equality
const obj1 = { a: 1, b: { c: 2 } };
const obj2 = { a: 1, b: { c: 2 } };
assert.deepStrictEqual(obj1, obj2); // Passes

// Checking if value is truthy
assert.ok(true);
assert.ok('non-empty string');

// Testing for errors
assert.throws(
  () => {
    throw new Error('Wrong value');
  },
  Error
);

// Custom error messages
assert.strictEqual(5, 5, 'Values must be equal');

// Async assertions
async function testAsync() {
  const result = await someAsyncOperation();
  assert.strictEqual(result, 'expected');
}
```

### vm Module

For running JavaScript code in isolated contexts. [Inference: Useful for sandboxing or plugin systems]

```javascript
const vm = require('vm');

// Basic code execution
const result = vm.runInNewContext('2 + 2');
console.log(result); // 4

// With a custom context
const sandbox = {
  x: 10,
  y: 20,
  console: console
};

vm.createContext(sandbox);

const code = `
  const sum = x + y;
  console.log('Sum:', sum);
  sum;
`;

const scriptResult = vm.runInContext(code, sandbox);
console.log('Script result:', scriptResult); // 30

// Reusable scripts
const script = new vm.Script('x * 2');

sandbox.x = 5;
console.log(script.runInContext(sandbox)); // 10

sandbox.x = 10;
console.log(script.runInContext(sandbox)); // 20
```

**Electron Use Cases**

Running untrusted user scripts safely, implementing plugin systems, creating REPL environments, or building code playgrounds.

### Performance Monitoring (perf_hooks)

For measuring performance in your application.

```javascript
const { performance, PerformanceObserver } = require('perf_hooks');

// Measure execution time
const start = performance.now();

// Some operation
for (let i = 0; i < 1000000; i++) {
  Math.sqrt(i);
}

const end = performance.now();
console.log(`Operation took ${end - start}ms`);

// Using marks and measures
performance.mark('start-operation');

// Do something
setTimeout(() => {
  performance.mark('end-operation');
  performance.measure('My Operation', 'start-operation', 'end-operation');
  
  const measure = performance.getEntriesByName('My Operation')[0];
  console.log(`Duration: ${measure.duration}ms`);
}, 1000);

// Observing performance entries
const obs = new PerformanceObserver((items) => {
  items.getEntries().forEach((entry) => {
    console.log(`${entry.name}: ${entry.duration}ms`);
  });
});

obs.observe({ entryTypes: ['measure'] });
```

### Cluster Module

For creating multiple Node.js processes to handle load. [Inference: Less common in Electron but useful for background services]

```javascript
const cluster = require('cluster');
const http = require('http');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  console.log(`Master process ${process.pid} is running`);
  
  // Fork workers
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
  
  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    // Restart the worker
    cluster.fork();
  });
  
} else {
  // Workers can share TCP connections
  http.createServer((req, res) => {
    res.writeHead(200);
    res.end(`Process ${process.pid} handled request\n`);
  }).listen(8000);
  
  console.log(`Worker ${process.pid} started`);
}
```

### querystring Module

For parsing and formatting URL query strings (alternative to URLSearchParams).

```javascript
const querystring = require('querystring');

// Parse query string
const parsed = querystring.parse('name=John&age=30&city=NYC');
console.log(parsed); // { name: 'John', age: '30', city: 'NYC' }

// Stringify object
const query = querystring.stringify({
  name: 'Jane',
  age: 25,
  interests: ['coding', 'music']
});
console.log(query); // 'name=Jane&age=25&interests=coding&interests=music'

// Custom separators
const custom = querystring.parse('name:John;age:30', ';', ':');
console.log(custom); // { name: 'John', age: '30' }

// URL encoding
const encoded = querystring.escape('hello world!');
console.log(encoded); // 'hello%20world!'

const decoded = querystring.unescape(encoded);
console.log(decoded); // 'hello world!'
```

### Putting It All Together

Here's a more complex example showing how multiple concepts work together in an Electron app feature:

```javascript
const { EventEmitter } = require('events');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const zlib = require('zlib');
const { promisify } = require('util');

const gzipAsync = promisify(zlib.gzip);
const gunzipAsync = promisify(zlib.gunzip);

class SecureDataStore extends EventEmitter {
  constructor(dataDir, encryptionKey) {
    super();
    this.dataDir = dataDir;
    this.key = Buffer.from(encryptionKey, 'hex');
  }
  
  async save(id, data) {
    try {
      this.emit('saving', id);
      
      // Serialize
      const json = JSON.stringify(data);
      
      // Compress
      const compressed = await gzipAsync(json);
      
      // Encrypt
      const iv = crypto.randomBytes(16);
      const cipher = crypto.createCipheriv('aes-256-cbc', this.key, iv);
      const encrypted = Buffer.concat([
        iv,
        cipher.update(compressed),
        cipher.final()
      ]);
      
      // Save to file
      const filePath = path.join(this.dataDir, `${id}.dat`);
      await fs.writeFile(filePath, encrypted);
      
      this.emit('saved', id);
      
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }
  
  async load(id) {
    try {
      this.emit('loading', id);
      
      // Read file
      const filePath = path.join(this.dataDir, `${id}.dat`);
      const encrypted = await fs.readFile(filePath);
      
      // Decrypt
      const iv = encrypted.slice(0, 16);
      const data = encrypted.slice(16);
      const decipher = crypto.createDecipheriv('aes-256-cbc', this.key, iv);
      const decrypted = Buffer.concat([
        decipher.update(data),
        decipher.final()
      ]);
      
      // Decompress
      const decompressed = await gunzipAsync(decrypted);
      
      // Parse
      const result = JSON.parse(decompressed.toString());
      
      this.emit('loaded', id, result);
      return result;
      
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }
}

// Usage
const encryptionKey = crypto.randomBytes(32).toString('hex');
const store = new SecureDataStore('/path/to/data', encryptionKey);

store.on('saving', (id) => console.log(`Saving ${id}...`));
store.on('saved', (id) => console.log(`Saved ${id}`));
store.on('error', (err) => console.error('Error:', err));

async function demo() {
  await store.save('user-123', { 
    username: 'john',
    settings: { theme: 'dark' }
  });
  
  const data = await store.load('user-123');
  console.log('Loaded:', data);
}
```

These additional concepts expand your toolkit for building sophisticated Electron applications that handle security, networking, performance optimization, and complex data processing tasks.

