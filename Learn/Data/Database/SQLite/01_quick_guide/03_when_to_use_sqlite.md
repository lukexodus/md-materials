## When to Use SQLite


SQLite is appropriate when:

- The application is the only process writing to the database.
- You need a local data store without network overhead.
- You are building an embedded system, mobile app, desktop app, or CLI tool.
- You want a fast, lightweight alternative to flat files (CSV, JSON) with query capabilities.
- You are prototyping before moving to a larger database.

SQLite is **not** ideal when:

- Many clients need concurrent write access over a network.
- You need fine-grained user-level access control.
- Your dataset is many hundreds of gigabytes and write throughput is critical.
- You need replication or high-availability clustering out of the box.

---

