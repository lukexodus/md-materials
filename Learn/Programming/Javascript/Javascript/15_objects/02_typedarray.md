## TypedArray


### Introduction

TypedArray objects are array-like objects that provide a mechanism for reading and writing raw binary data in memory buffers. Unlike regular JavaScript arrays, TypedArrays store elements of a specific numeric data type and have fixed lengths. They were introduced to efficiently handle binary data, particularly for use cases like WebGL, audio processing, network protocols, and file manipulation.

### Core Concepts

#### ArrayBuffer

An ArrayBuffer is a low-level representation of a chunk of binary data in memory. It doesn't provide direct access to its contents - you need a view (TypedArray or DataView) to read or modify it.

**Key Points:**

- Represents fixed-length raw binary data buffer
- Cannot be directly manipulated
- Memory is contiguous and of fixed size
- Created with `new ArrayBuffer(byteLength)`

**Example:**

```javascript
// Create a buffer with 16 bytes
const buffer = new ArrayBuffer(16);
console.log(buffer.byteLength); // 16
```

#### TypedArray Views

TypedArrays are views that provide access to an ArrayBuffer with a specific numeric format. Each type represents a different numeric type.

**Key Points:**

- Fixed-length and single-type elements
- Share underlying memory with other views on the same buffer
- Direct mapping to C/C++ primitive types
- Efficient for numeric computations

### Available TypedArray Types

#### Integer Types

|Type|Size|Description|Range|
|---|---|---|---|
|`Int8Array`|1 byte|8-bit signed integer|-128 to 127|
|`Uint8Array`|1 byte|8-bit unsigned integer|0 to 255|
|`Uint8ClampedArray`|1 byte|8-bit unsigned integer (clamped)|0 to 255|
|`Int16Array`|2 bytes|16-bit signed integer|-32768 to 32767|
|`Uint16Array`|2 bytes|16-bit unsigned integer|0 to 65535|
|`Int32Array`|4 bytes|32-bit signed integer|-2³¹ to 2³¹-1|
|`Uint32Array`|4 bytes|32-bit unsigned integer|0 to 2³²-1|
|`BigInt64Array`|8 bytes|64-bit signed integer|-2⁶³ to 2⁶³-1|
|`BigUint64Array`|8 bytes|64-bit unsigned integer|0 to 2⁶⁴-1|

#### Floating Point Types

|Type|Size|Description|Precision|
|---|---|---|---|
|`Float32Array`|4 bytes|32-bit IEEE floating point|7 significant digits|
|`Float64Array`|8 bytes|64-bit IEEE floating point|16 significant digits|

### Creating TypedArrays

TypedArrays can be created in multiple ways:

#### From ArrayBuffer

```javascript
const buffer = new ArrayBuffer(16);
const int32View = new Int32Array(buffer);
console.log(int32View.length); // 4 (16 bytes / 4 bytes per int32)
```

#### With Length

```javascript
const uint8Array = new Uint8Array(8); // Creates a buffer of 8 bytes
```

#### From Array or Array-like

```javascript
const int16Array = new Int16Array([1, 2, 3, 4]);
const fromOtherTyped = new Uint32Array(int16Array);
```

#### From Iterator

```javascript
const iterator = function* () { yield* [1, 2, 3]; }();
const uint8FromIterator = new Uint8Array(iterator);
```

### Common Operations

#### Reading and Writing

**Example:**

```javascript
const buffer = new ArrayBuffer(16);
const view = new Int32Array(buffer);

// Writing
view[0] = 42;
view[1] = 100;

// Reading
console.log(view[0]); // 42
```

#### Slicing

**Example:**

```javascript
const originalArray = new Uint8Array([1, 2, 3, 4, 5]);
const slicedArray = originalArray.slice(1, 3);
console.log(Array.from(slicedArray)); // [2, 3]
```

#### Iteration

**Example:**

```javascript
const array = new Int16Array([1, 2, 3, 4]);

// Using for...of loop
for (const value of array) {
  console.log(value);
}

// Using forEach
array.forEach((value, index) => {
  console.log(`Value at ${index}: ${value}`);
});
```

#### Copying and Setting

**Example:**

```javascript
const source = new Uint8Array([1, 2, 3]);
const target = new Uint8Array(5);

// Set values from another array
target.set(source, 1); // Start copying at index 1
console.log(Array.from(target)); // [0, 1, 2, 3, 0]
```

#### Conversion

**Example:**

```javascript
const typedArray = new Int8Array([1, 2, 3]);

// To regular array
const regularArray = Array.from(typedArray);
// or
const anotherArray = [...typedArray];
```

### Methods and Properties

#### Instance Properties

- `buffer` - Reference to the ArrayBuffer
- `byteLength` - Size in bytes of the array
- `byteOffset` - Offset in bytes from the start of the buffer
- `length` - Number of elements in the array
- `name` - String value of the constructor name

**Example:**

```javascript
const buffer = new ArrayBuffer(32);
const view = new Int16Array(buffer, 4, 5); // offset 4, length 5

console.log(view.buffer === buffer); // true
console.log(view.byteLength); // 10 (5 elements * 2 bytes)
console.log(view.byteOffset); // 4
console.log(view.length); // 5
console.log(view.name); // "Int16Array"
```

#### Array-like Methods

TypedArrays implement many of the same methods as regular Arrays:

- `copyWithin()`
- `entries()`
- `every()`
- `fill()`
- `filter()`
- `find()`
- `findIndex()`
- `forEach()`
- `includes()`
- `indexOf()`
- `join()`
- `keys()`
- `lastIndexOf()`
- `map()`
- `reduce()`
- `reduceRight()`
- `reverse()`
- `slice()`
- `some()`
- `sort()`
- `values()`

**Example:**

```javascript
const array = new Float32Array([1.5, 2.5, 3.5, 4.5]);
const doubled = array.map(x => x * 2);
console.log(Array.from(doubled)); // [3, 5, 7, 9]

array.sort((a, b) => b - a); // Sort in descending order
console.log(Array.from(array)); // [4.5, 3.5, 2.5, 1.5]
```

#### TypedArray-specific Methods

- `set()` - Copy the values from another array into this one
- `subarray()` - Create a new view on the same buffer

**Example:**

```javascript
const original = new Uint8Array([1, 2, 3, 4, 5]);

// Create a view starting at index 2, length 2
const sub = original.subarray(2, 4);
console.log(Array.from(sub)); // [3, 4]

// Modifying the subarray modifies the original buffer
sub[0] = 99;
console.log(Array.from(original)); // [1, 2, 99, 4, 5]
```

### Endianness

Endianness refers to the order in which bytes are arranged in memory for multi-byte values.

**Key Points:**

- Big-endian: most significant byte first
- Little-endian: least significant byte first
- Most systems are little-endian
- TypedArrays use the host system's endianness

**Example:**

```javascript
// Testing system endianness
function isLittleEndian() {
  const buffer = new ArrayBuffer(2);
  new DataView(buffer).setInt16(0, 256, true); // true = little-endian
  return new Int16Array(buffer)[0] === 256;
}

console.log(isLittleEndian() ? "Little Endian" : "Big Endian");
```

### DataView

DataView is an alternative view on ArrayBuffer that allows more control over endianness and reading/writing values at any offset.

**Key Points:**

- More flexible than TypedArrays
- Explicit control over endianness
- Good for mixed data formats
- Slightly more overhead than TypedArrays

**Example:**

```javascript
const buffer = new ArrayBuffer(16);
const view = new DataView(buffer);

// Writing values with explicit endianness
view.setInt16(0, 42, true);  // little-endian
view.setInt16(2, 42, false); // big-endian

// Reading values
console.log(view.getInt16(0, true));  // 42 (little-endian)
console.log(view.getInt16(2, false)); // 42 (big-endian)
```

### Performance Considerations

**Key Points:**

- TypedArrays are significantly faster than regular arrays for numeric operations
- Memory allocated is continuous and predictable
- Avoid frequent reallocation by preallocating sufficient buffer size
- Use the appropriate TypedArray for your data to optimize memory usage
- Consider alignment for optimal performance

**Example:**

```javascript
// Performance comparison
function comparePerformance() {
  const size = 10000000;
  
  console.time('Regular Array');
  const regularArray = new Array(size);
  for (let i = 0; i < size; i++) {
    regularArray[i] = i * 2;
  }
  let sum1 = 0;
  for (let i = 0; i < size; i++) {
    sum1 += regularArray[i];
  }
  console.timeEnd('Regular Array');
  
  console.time('TypedArray');
  const typedArray = new Int32Array(size);
  for (let i = 0; i < size; i++) {
    typedArray[i] = i * 2;
  }
  let sum2 = 0;
  for (let i = 0; i < size; i++) {
    sum2 += typedArray[i];
  }
  console.timeEnd('TypedArray');
}

comparePerformance();
```

### Common Use Cases

#### Binary File Handling

**Example:**

```javascript
// Reading a file as binary data
async function readFileAsArrayBuffer(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsArrayBuffer(file);
  });
}

// Usage with fetch API
async function fetchBinary(url) {
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();
  return buffer;
}
```

#### WebGL Integration

**Example:**

```javascript
// Create a WebGL context
const canvas = document.getElementById('canvas');
const gl = canvas.getContext('webgl');

// Create a buffer and bind vertex data
const vertices = new Float32Array([
  -0.5, -0.5, 0.0,  // bottom left
   0.5, -0.5, 0.0,  // bottom right
   0.0,  0.5, 0.0   // top
]);

const buffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
```

#### Audio Processing

**Example:**

```javascript
// Working with Web Audio API
const audioContext = new AudioContext();
const bufferSize = 4096;
const audioBuffer = audioContext.createBuffer(2, bufferSize, audioContext.sampleRate);

// Get the channels
const leftChannel = audioBuffer.getChannelData(0);  // Float32Array
const rightChannel = audioBuffer.getChannelData(1); // Float32Array

// Process audio data
for (let i = 0; i < bufferSize; i++) {
  // Generate a sine wave
  leftChannel[i] = Math.sin(i * 0.01);
  rightChannel[i] = Math.sin(i * 0.02);
}
```

#### Network Protocols

**Example:**

```javascript
// Creating a binary packet for a custom protocol
function createPacket(command, payload) {
  const headerSize = 8;
  const buffer = new ArrayBuffer(headerSize + payload.byteLength);
  const view = new DataView(buffer);
  
  // Write header
  view.setUint16(0, 0xABCD, true); // Magic number
  view.setUint8(2, command);        // Command byte
  view.setUint8(3, 0);              // Flags
  view.setUint32(4, payload.byteLength, true); // Payload size
  
  // Copy payload
  new Uint8Array(buffer, headerSize).set(new Uint8Array(payload));
  
  return buffer;
}
```

#### Image Processing

**Example:**

```javascript
// Processing image data from canvas
function invertColors(imageData) {
  const data = new Uint8ClampedArray(imageData.data);
  
  for (let i = 0; i < data.length; i += 4) {
    data[i] = 255 - data[i];     // R
    data[i + 1] = 255 - data[i + 1]; // G
    data[i + 2] = 255 - data[i + 2]; // B
    // i + 3 is alpha, leave unchanged
  }
  
  return new ImageData(data, imageData.width, imageData.height);
}

// Usage with canvas
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
const invertedData = invertColors(imageData);
ctx.putImageData(invertedData, 0, 0);
```

### Browser Support

TypedArray is supported in all modern browsers, including:

- Chrome 7+
- Firefox 4+
- Safari 5.1+
- Edge/IE 10+
- Opera 11.6+

### Comparison with Regular Arrays

|Feature|TypedArray|Regular Array|
|---|---|---|
|Element type|Fixed numeric type|Any JavaScript value|
|Length|Fixed at creation|Dynamic|
|Memory layout|Contiguous, packed|Implementation-defined|
|Memory usage|Optimal for numbers|Higher overhead|
|Performance for numeric ops|High|Lower|
|API|Array-like + specialized|Full Array API|
|Use case|Binary data, numeric computation|General purpose|

**Example:**

```javascript
// Memory comparison
const size = 1000000;

// Regular array with numbers takes ~8 bytes per element plus overhead
const regularArray = new Array(size).fill(0);

// Int32Array takes exactly 4 bytes per element
const typedArray = new Int32Array(size); // Takes 4MB exactly
```

### Best Practices

- Choose the appropriate TypedArray for your data type to minimize memory usage
- Preallocate buffers to avoid reallocation
- Use `set()` and `subarray()` rather than creating new views when possible
- Consider endianness when working with multi-byte data across platforms
- Use DataView for mixed-type data access or when endianness matters
- Avoid unnecessary conversion between TypedArrays and regular arrays
- Leverage TypedArray methods for performance when processing large datasets

### Debugging TypedArrays

**Example:**

```javascript
// Helper function to visualize TypedArrays
function inspectTypedArray(array, maxItems = 10) {
  const info = {
    type: array.constructor.name,
    length: array.length,
    byteLength: array.byteLength,
    byteOffset: array.byteOffset,
    buffer: array.buffer,
    values: Array.from(array.slice(0, maxItems))
  };
  
  if (array.length > maxItems) {
    info.values.push('...');
  }
  
  console.table(info);
  return info;
}

// Usage
const array = new Float32Array([1.1, 2.2, 3.3, 4.4, 5.5]);
inspectTypedArray(array);
```

**Conclusion:** TypedArrays are powerful tools for handling binary data efficiently in JavaScript. They offer significant performance improvements for numeric operations and provide low-level memory access while maintaining a familiar array-like API. Understanding when and how to use TypedArrays can greatly enhance your application's performance and capabilities when working with binary data, multimedia processing, network communications, or other performance-critical operations.

### Related Topics

- WebGL and graphics programming
- Web Audio API
- Network programming with WebSockets and Fetch API
- File handling with the File API
- SharedArrayBuffer and Atomics for concurrent memory access
- WebAssembly integration
- Canvas 2D/WebGL image manipulation

---

