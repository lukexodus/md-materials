## Shallow vs Deep Copy


The distinction between shallow and deep copying determines how nested structures are handled when creating copies.

**Shallow Copy**

A shallow copy creates a new outer structure but preserves references to nested objects. Only the top level is copied; nested structures remain shared between original and copy.

```javascript
const original = {
  name: 'Alice',
  scores: [85, 90, 92],
  address: { city: 'Boston', zip: '02101' }
};

const shallow = { ...original };

shallow.name = 'Bob';           // independent change
shallow.scores.push(95);        // mutates original.scores too!
shallow.address.city = 'NYC';   // mutates original.address too!

console.log(original.scores);   // [85, 90, 92, 95] - mutated!
console.log(original.address);  // { city: 'NYC', zip: '02101' } - mutated!
```

Shallow copying is efficient and sufficient when:

- The structure has only primitive values at the first level
- You intentionally want to share nested structures
- You're only modifying top-level properties

**Deep Copy**

A deep copy recursively copies all nested structures, creating completely independent copies at all levels. No references are shared between original and copy.

```javascript
// Manual deep copy for nested arrays/objects
function deepCopy(obj) {
  if (obj === null || typeof obj !== 'object') return obj;
  if (Array.isArray(obj)) return obj.map(deepCopy);
  
  return Object.fromEntries(
    Object.entries(obj).map(([key, value]) => [key, deepCopy(value)])
  );
}

const original = {
  name: 'Alice',
  scores: [85, 90, 92],
  address: { city: 'Boston', zip: '02101' }
};

const deep = deepCopy(original);

deep.scores.push(95);
deep.address.city = 'NYC';

console.log(original.scores);   // [85, 90, 92] - unchanged
console.log(original.address);  // { city: 'Boston', zip: '02101' } - unchanged
```

**Practical Considerations**

Deep copying has trade-offs:

- Performance cost increases with structure depth and size
- May copy more than necessary if only some nested paths need modification
- Circular references require special handling
- Functions and non-serializable values need consideration

For JSON-serializable data, `JSON.parse(JSON.stringify(obj))` provides a quick deep copy, but loses functions, dates, undefined values, and other non-JSON types.

**Selective Deep Copying**

Often the optimal approach is copying only the specific nested path being modified:

```javascript
const original = {
  users: {
    alice: { name: 'Alice', score: 100 },
    bob: { name: 'Bob', score: 85 }
  },
  settings: { theme: 'dark' }
};

// Only copy the path being modified
const updated = {
  ...original,
  users: {
    ...original.users,
    alice: {
      ...original.users.alice,
      score: 105
    }
  }
};

// original.users.bob is still shared (not copied unnecessarily)
```

