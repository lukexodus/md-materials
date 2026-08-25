## `std::time`


The `std::time` module in Rust provides functionality for working with time, including durations, timestamps, and system time. It is essential for measuring elapsed time, scheduling operations, and handling time-related logic.

---

**Key Components in `std::time`**

The module contains two main types:

1. **`Duration`** – Represents a span of time.
2. **`SystemTime`** – Represents the system clock time.

---

### **1. `Duration` – Measuring Time Intervals**

#### **Creating a Duration**

A `Duration` represents a length of time in seconds and nanoseconds.

```rust
use std::time::Duration;

fn main() {
    let five_seconds = Duration::new(5, 0);
    let two_millis = Duration::from_millis(2);
    let one_micro = Duration::from_micros(1);
    
    println!("5 seconds: {:?}", five_seconds);
    println!("2 milliseconds: {:?}", two_millis);
    println!("1 microsecond: {:?}", one_micro);
}
```

---

#### **Common Duration Methods**

|Method|Description|
|---|---|
|`Duration::new(secs, nanos)`|Creates a duration from seconds and nanoseconds|
|`Duration::from_secs(secs)`|Creates a duration from seconds|
|`Duration::from_millis(ms)`|Creates a duration from milliseconds|
|`Duration::from_micros(μs)`|Creates a duration from microseconds|
|`Duration::from_nanos(ns)`|Creates a duration from nanoseconds|
|`duration.as_secs()`|Returns the duration in whole seconds|
|`duration.as_millis()`|Returns the duration in milliseconds|
|`duration.as_micros()`|Returns the duration in microseconds|
|`duration.as_nanos()`|Returns the duration in nanoseconds|

---

#### **Adding and Subtracting Durations**

`Duration` supports arithmetic operations like addition and subtraction.

```rust
use std::time::Duration;

fn main() {
    let duration1 = Duration::from_secs(5);
    let duration2 = Duration::from_millis(500);
    
    let total = duration1 + duration2;
    println!("Total duration: {:?}", total);
}
```

---

### **2. `SystemTime` – Getting the Current Time**

`SystemTime` represents an absolute point in time.

#### **Getting the Current Time**

```rust
use std::time::SystemTime;

fn main() {
    let now = SystemTime::now();
    println!("Current system time: {:?}", now);
}
```

---

#### **Calculating Time Elapsed Since an Event**

You can measure elapsed time using `SystemTime::elapsed()`.

```rust
use std::time::{Duration, SystemTime};

fn main() {
    let start = SystemTime::now();
    
    // Simulate some work
    std::thread::sleep(Duration::from_secs(2));
    
    match start.elapsed() {
        Ok(elapsed) => println!("Elapsed time: {:?}", elapsed),
        Err(e) => println!("Error: {:?}", e),
    }
}
```

---

#### **Comparing `SystemTime` Values**

Use `duration_since()` to compute the difference between two times.

```rust
use std::time::{Duration, SystemTime};

fn main() {
    let now = SystemTime::now();
    let earlier = now - Duration::from_secs(30);

    match now.duration_since(earlier) {
        Ok(duration) => println!("Time difference: {:?}", duration),
        Err(e) => println!("Error: {:?}", e),
    }
}
```

**Handling Errors:**  
`duration_since()` will return an error if the given time is in the future. To avoid errors, use `elapsed()` on `SystemTime::now()`.

---

### **3. `Instant` – High-Precision Timers**

Unlike `SystemTime`, which can be adjusted (e.g., by the OS), `Instant` is a monotonic clock and is used for measuring time intervals accurately.

#### **Measuring Execution Time**

```rust
use std::time::Instant;

fn main() {
    let start = Instant::now();

    // Simulate some work
    std::thread::sleep(std::time::Duration::from_secs(2));

    let elapsed = start.elapsed();
    println!("Elapsed time: {:?}", elapsed);
}
```

---

### **4. `UNIX_EPOCH` – Getting Timestamps**

Rust provides `UNIX_EPOCH` as a reference point for timestamps.

```rust
use std::time::{SystemTime, UNIX_EPOCH};

fn main() {
    let since_epoch = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");

    println!("Seconds since UNIX epoch: {}", since_epoch.as_secs());
}

```

**Less Common Methods in `std::time`**

There are additional useful but less commonly used methods:

|Method|Type|Description|
|---|---|---|
|`Duration::saturating_add(other)`|`Duration`|Adds two durations, preventing overflow|
|`Duration::saturating_sub(other)`|`Duration`|Subtracts two durations, preventing negative values|
|`SystemTime::checked_add(duration)`|`SystemTime`|Adds a duration to `SystemTime`, returning `None` on overflow|
|`SystemTime::checked_sub(duration)`|`SystemTime`|Subtracts a duration from `SystemTime`, returning `None` on overflow|
|`Instant::saturating_duration_since(other)`|`Instant`|Returns duration since another instant, preventing negative values|

---

