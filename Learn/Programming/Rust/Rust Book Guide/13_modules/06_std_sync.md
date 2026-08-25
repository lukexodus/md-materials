## `std::sync`


- **`Arc`** – A thread-safe reference-counting pointer.
- **`Weak`** – A non-owning reference to an `Arc`.
- **`Mutex`** – A mutual exclusion primitive for protecting shared data.
- **`MutexGuard`** – A RAII implementation for `Mutex`, ensuring it is unlocked when dropped.
- **`RwLock`** – A reader-writer lock that allows multiple readers or one writer at a time.
- **`RwLockReadGuard`** – A RAII implementation for the read lock of an `RwLock`.
- **`RwLockWriteGuard`** – A RAII implementation for the write lock of an `RwLock`.
- **`Condvar`** – A condition variable used for thread synchronization.
- **`Once`** – Ensures a piece of code runs only once in a thread-safe manner.
- **`OnceLock`** – A thread-safe, one-time initialization value (more flexible than `Once`).
- **`OnceCell`** – A lazily-initialized, thread-safe storage that can be written once.
- **`Barrier`** – A synchronization primitive that blocks threads until a certain number have reached the barrier.
- [[#`std::sync::atomic`]] – Provides atomic types such as `AtomicBool`, `AtomicUsize`, etc., for lock-free concurrency.

