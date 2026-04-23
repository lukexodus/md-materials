# `memory-cache` Node.js Library — Comprehensive Guide

**Package:** `memory-cache` (npm) **Repository:** `github.com/ptarjan/node-cache` **Author:** ptarjan **License:** BSD-2-Clause **Current version:** 0.2.0 **Status:** Published; no active release cycle as of the time of writing [Unverified — maintenance status may have changed]

---

## Overview

`memory-cache` is a simple in-memory cache for Node.js with zero dependencies. It provides a key-value store that lives in process memory, with optional time-to-live (TTL) expiry per entry and a callback mechanism that fires when entries expire.

It is distinct from the similarly-named `node-cache` package (by a different author), which is a more feature-rich alternative covered briefly in the comparison section below.

---

## Installation

```bash
npm install memory-cache --save
```

---

## Basic Usage

```js
var cache = require('memory-cache');

cache.put('foo', 'bar');
console.log(cache.get('foo')); // 'bar'
```

When `require('memory-cache')` is called, it returns the default singleton instance of `Cache`. The actual `Cache` class is accessible as `require('memory-cache').Cache`.

---

## API Reference

### `put(key, value, [time], [timeoutCallback])`

Stores a value under a key.

- `key` — any string
- `value` — any value
- `time` (optional) — TTL in milliseconds; if omitted, the entry is stored indefinitely
- `timeoutCallback` (optional) — a function `function(key, value)` called after the entry expires

Returns the cached value.

```js
cache.put('session', { user: 'luke' }, 5000, function(key, value) {
  console.log(key + ' expired');
});
```

TTL is implemented via `setTimeout`, which fires the actual removal at the specified interval in milliseconds.

---

### `get(key)`

Retrieves the value associated with `key`.

Returns `null` if the value is not cached or has expired.

```js
cache.get('foo'); // returns value or null
```

---

### `del(key)`

Deletes a key and returns a boolean indicating whether the key was present and deleted.

```js
cache.del('foo'); // true or false
```

---

### `clear()`

Deletes all keys from the cache.

```js
cache.clear();
```

---

### `size()`

Returns the current number of entries in the cache.

```js
cache.size(); // integer
```

---

### `memsize()`

Returns the number of entries actually occupying space in the cache. This will typically equal `size()` unless a `setTimeout`-based removal encountered an error.

This is a diagnostic tool: if `memsize() > size()`, there may be orphaned entries from failed expiry callbacks.

---

### `keys()`

Returns an array of all current cache keys.

```js
cache.keys(); // ['foo', 'bar', ...]
```

---

### `debug(bool)`

Enables or disables debug mode. Hit and miss counts are only tracked when debug mode is on.

```js
cache.debug(true);
```

---

### `hits()`

Returns the number of cache hits. Only meaningful when debug mode is enabled.

---

### `misses()`

Returns the number of cache misses. Only meaningful when debug mode is enabled.

---

### `exportJson()`

Returns a JSON string representing all current cache data. Any `timeoutCallback` functions are not included in the export.

```js
var snapshot = cache.exportJson();
```

Useful for snapshotting state, debugging, or transferring between cache instances.

---

### `importJson(json, [options])`

Merges data from a previous `exportJson()` call into the cache. Existing entries are retained. Duplicate keys are overwritten by default unless `skipDuplicates: true` is passed. Entries that would have expired since export time will expire upon import, but their callbacks will not be invoked. Returns the new size of the cache.

```js
cache.importJson(snapshot, { skipDuplicates: true });
```

**Options:**

- `skipDuplicates` (boolean, default `false`) — if `true`, duplicate keys from the import are ignored rather than overwriting existing entries

---

## Multiple Cache Instances

A new, isolated cache instance can be created using the `Cache` constructor exposed on the module.

```js
var cache = require('memory-cache');
var myCache = new cache.Cache();

cache.put('foo', 'global');
myCache.put('foo', 'local');

console.log(cache.get('foo'));   // 'global'
console.log(myCache.get('foo')); // 'local'
```

This is useful when you need logical separation between caches within the same process — for example, one cache per tenant, or one per data domain.

---

## TTL and Expiry Behavior

TTL is specified in milliseconds per entry, not globally. There is no global default TTL setting.

```js
// Expires in 2 seconds
cache.put('token', 'abc123', 2000);

setTimeout(() => {
  console.log(cache.get('token')); // null — expired
}, 3000);
```

Expiry is handled via `setTimeout`, meaning:

- The Node.js event loop must be running for expiry to fire
- [Inference] Under very high concurrency or event loop saturation, expiry timing may drift from the specified TTL; this is a property of `setTimeout` in Node.js, not a documented guarantee of the library. Behavior is not guaranteed.
- Callbacks registered with `put()` are lost on `exportJson()` / `importJson()` round-trips

---

## Patterns and Practical Use Cases

### Cache-aside pattern

Fetch from cache first; on miss, fetch from source and populate.

```js
function getData(key) {
  var cached = cache.get(key);
  if (cached !== null) return Promise.resolve(cached);

  return fetchFromDB(key).then(function(result) {
    cache.put(key, result, 60000); // cache for 60 seconds
    return result;
  });
}
```

### Memoizing expensive computations

```js
function memoize(fn, ttl) {
  return function(arg) {
    var key = String(arg);
    var hit = cache.get(key);
    if (hit !== null) return hit;
    var result = fn(arg);
    cache.put(key, result, ttl);
    return result;
  };
}
```

### Session or token short-TTL storage

```js
cache.put('auth:' + userId, token, 900000, function(key) {
  console.log('Session expired for:', key);
});
```

### Snapshot and restore

```js
// Save state
var snap = cache.exportJson();
fs.writeFileSync('cache-snapshot.json', snap);

// Later, restore
var raw = fs.readFileSync('cache-snapshot.json', 'utf8');
cache.importJson(raw, { skipDuplicates: false });
```

---

## Limitations and Caveats

- **No persistence.** Cache data lives in process memory only. A process restart loses all data.
- **No size cap.** There is no built-in limit on the number of entries or total memory consumed. Uncontrolled growth can cause out-of-memory errors.
- **No LRU eviction.** Entries are only removed on explicit `del()`, `clear()`, or TTL expiry. There is no least-recently-used eviction strategy.
- **Single-process only.** No shared state across multiple Node.js processes or workers.
- **`setTimeout`-based TTL.** Not suitable for use cases requiring sub-millisecond precision or where event loop blocking is a concern. [Inference — not guaranteed by library documentation.]
- **No TypeScript types bundled.** Types are available separately via `@types/memory-cache` (a community-maintained package). [Unverified — confirm current availability before depending on it.]
- **Callbacks are not serialized.** `exportJson()` drops all `timeoutCallback` references; they will not fire after a re-import.

---

## Maintenance Status

The package was last published 9 years ago at version 0.2.0, with 741 dependents. The repository has had no new releases. [Unverified — the GitHub repository may have open issues or forks that indicate ongoing informal maintenance. Check the repo directly for current status.]

For new projects, the following alternatives may warrant evaluation:

- **`node-cache`** — more actively maintained [Unverified as of today; check npm for recency], supports global TTL defaults, TypeScript-native rewrite, event emitters (`set`, `del`, `expired`, `flush`), and key counting limits
- **`lru-cache`** — LRU eviction, size limits, TypeScript-native
- **`cache-manager`** — multi-store abstraction (memory + Redis + others), tiered caching

---

## Comparison: `memory-cache` vs `node-cache`

|Feature|`memory-cache`|`node-cache`|
|---|---|---|
|Global TTL default|No|Yes (`stdTTL`)|
|Per-entry TTL|Yes (ms)|Yes (seconds)|
|Expiry callback|Yes (per-entry)|Event emitter (`expired`)|
|LRU eviction|No|No|
|Max key limit|No|Yes (`maxKeys`)|
|TypeScript types|Community (`@types/`)|Native (rewritten in TS)|
|Clone on get/set|No|Configurable|
|Export / import|Yes|No|
|Multiple instances|Yes|Yes|
|Dependencies|0|0|
|Event system|No|Yes|

---

## Quick Reference

|Method|Returns|Notes|
|---|---|---|
|`put(k, v, [ms], [cb])`|value|TTL optional, callback optional|
|`get(k)`|value or `null`|Returns `null` on miss or expiry|
|`del(k)`|boolean|`true` if key existed|
|`clear()`|void|Removes all entries|
|`size()`|integer|Logical entry count|
|`memsize()`|integer|Physical entry count|
|`keys()`|array|All active keys|
|`debug(bool)`|void|Enables hit/miss tracking|
|`hits()`|integer|Debug mode only|
|`misses()`|integer|Debug mode only|
|`exportJson()`|string|JSON snapshot; no callbacks|
|`importJson(json, opts)`|integer|Returns new cache size|
|`new cache.Cache()`|Cache instance|Isolated cache instance|