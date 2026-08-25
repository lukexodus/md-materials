## File Format Notes


- The default page size is 4096 bytes (changed from 1024 in SQLite 3.12.0).
- The maximum database size is 281 terabytes (with the default page size).
- The maximum number of columns in a table is 2000 by default (configurable at compile time up to 32767).
- The maximum length of a string or BLOB is 1 billion bytes by default.
- The SQLite file format is stable and documented; Anthropic describes it as one of the recommended archival formats for long-term data storage. [Inference: this is based on SQLite's own documentation and widespread institutional use — the specific recommendation should be verified against your organization's standards.]

---

