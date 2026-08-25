## Using DBeaver with syllabot.db on Your Local Machine


Since the file is already on your machine, this is straightforward.

### Quick Setup

1. **Launch DBeaver**
   ```bash
   dbeaver &
   ```

2. **Create a New Connection**
   - Click **File** → **New** → **Database Connection**
   - Select **SQLite**
   - Click **Next**

3. **Browse to Your File**
   - Click the folder icon next to **Path**
   - Navigate to `syllabot.db`
   - Select it and click **Open**
   - Or paste the full path directly:
     ```
     /home/yourusername/path/to/syllabot.db
     ```

4. **Test and Connect**
   - Click **Test Connection** (optional but recommended)
   - Click **Finish**

The database now appears in the left sidebar.

---

### Finding Your File

If you're not sure where `syllabot.db` is:

```bash
## Search for it
find ~ -name "syllabot.db" 2>/dev/null

## Or check current directory
ls -lh syllabot.db
```

Once you have the full path, use it in DBeaver's path field.

---

### Next Steps (Same as Before)

Once connected:

- **Expand the database** in the left sidebar
- **Double-click any table** to view data
- **Ctrl+Alt+N** to open a new SQL editor
- Run queries like:
  ```sql
  SELECT * FROM users LIMIT 10;
  PRAGMA table_info(messages);
  SELECT COUNT(*) FROM messages;
  ```

---

