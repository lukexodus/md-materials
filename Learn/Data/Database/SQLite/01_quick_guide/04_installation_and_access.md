## Installation and Access


### Command-Line Shell

Most systems include SQLite or make it easily available.

```bash
# Debian/Ubuntu
sudo apt install sqlite3

# macOS (Homebrew)
brew install sqlite

# Windows
# Download the precompiled binaries from sqlite.org
```

Start an interactive session:

```bash
sqlite3 mydata.db
```

If the file does not exist, SQLite creates it on first write.

### In-Memory Databases

```bash
sqlite3 :memory:
```

An in-memory database is destroyed when the connection closes. Useful for testing or temporary work.

---

