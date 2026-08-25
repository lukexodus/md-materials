## Concurrency and Locking


SQLite supports one writer at a time. The locking hierarchy is:

1. **UNLOCKED** — No lock held.
2. **SHARED** — Reading; multiple connections can hold this simultaneously.
3. **RESERVED** — One connection intends to write; others can still read.
4. **PENDING** — Waiting for existing readers to finish.
5. **EXCLUSIVE** — Writing; no other connection can read or write.

In WAL mode, this model is relaxed: readers and a single writer can coexist.

For applications that genuinely need many concurrent writers, a client-server database (PostgreSQL, MySQL) is more appropriate.

---

