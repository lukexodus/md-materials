## The SQLite Shell


Once inside the shell, you use two categories of commands:

- **Dot commands** — shell-level directives prefixed with `.`
- **SQL statements** — standard SQL terminated with `;`

### Common Dot Commands

```
.help               List all dot commands
.databases          Show attached databases
.tables             List all tables
.schema tablename   Show CREATE statement for a table
.mode column        Set output to aligned columns
.headers on         Show column headers in output
.output file.txt    Redirect output to a file
.read file.sql      Execute SQL from a file
.quit               Exit the shell
```

---

