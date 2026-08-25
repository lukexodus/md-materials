## Virtual Tables


Virtual tables let external data sources appear as SQLite tables. Beyond FTS5, useful built-in and commonly available virtual tables include:

- **rtree** — R-Tree spatial index, useful for geographic bounding-box queries.
- **dbstat** — Exposes internal database statistics as a table.
- **pragma_*** — Many PRAGMAs are queryable as virtual tables (e.g., `pragma_table_info('users')`).

---

