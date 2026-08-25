## Connecting DBeaver to SQLite by Host or URL


### Important: SQLite Doesn't Work Over Network by Default

SQLite is **not a network database**. It reads and writes directly to local files. You **cannot** connect to SQLite over HTTP, TCP, or any network protocol using standard SQLite.

However, there are workarounds depending on your setup.

---

### Option 1: Remote File Access via SSH (Recommended)

If the `syllabot.db` file is on a remote machine, access it via SSH tunneling.

#### Setup SSH Tunnel in DBeaver

1. **File** → **New** → **Database Connection**
2. Select **SQLite**
3. **Path:** Enter the remote file path (e.g., `/home/user/syllabot.db`)
4. Click the **SSH** tab
5. Enable **Use SSH Tunnel**
6. Fill in:
   - **Host:** Your remote server hostname or IP
   - **Port:** 22 (default SSH)
   - **Username:** Your SSH username
   - **Authentication:** Password or public key
7. **Test Connection**
8. **Finish**

DBeaver tunnels the file access over SSH, and you interact with it as if it were local.

---

### Option 2: SCP/SFTP to Pull File Locally

If you just need to work with the file once:

```bash
## Download from remote host
scp user@remote-host:/path/to/syllabot.db ./syllabot.db

## Then open locally in DBeaver as usual
dbeaver &
```

After you're done, upload changes back:

```bash
scp ./syllabot.db user@remote-host:/path/to/syllabot.db
```

---

### Option 3: Mount Remote Filesystem (SSHFS)

Mount the remote directory locally, then access it like a normal file.

```bash
## Install sshfs (if not already installed)
sudo pacman -S sshfs

## Create mount point
mkdir -p ~/mnt/remote

## Mount remote filesystem
sshfs user@remote-host:/path/to/dir ~/mnt/remote

## Open in DBeaver
dbeaver &
## Then browse to ~/mnt/remote/syllabot.db

## Unmount when done
fusermount -u ~/mnt/remote
```

---

### Option 4: SQLite Server Wrapper (Advanced)

If you need true remote access, wrap SQLite with a lightweight HTTP or TCP server.

#### Using `sqlite-web` (Python)

Install:

```bash
pip install sqlite-web
```

On the remote machine, start the server:

```bash
sqlite_web syllabot.db --port 8080 --host 0.0.0.0
```

Then access in your browser:

```
http://remote-host:8080
```

Or use an API:

```bash
curl "http://remote-host:8080/api/query" \
  -H "Content-Type: application/json" \
  -d '{"sql": "SELECT * FROM users LIMIT 10"}'
```

**Note:** DBeaver cannot directly connect to `sqlite-web`. You'd use the web interface or a script.

---

### Option 5: PostgreSQL/MySQL Proxy (Overkill)

If you need full database client support, convert to a real network database:

1. Export SQLite to PostgreSQL:
   ```bash
   pgloader sqlite:///path/to/syllabot.db postgresql://user:pass@localhost/syllabot
   ```

2. Connect DBeaver to PostgreSQL normally by host/port.

This is rarely necessary for SQLite unless you need multi-user write access.

---

### Option 6: Docker Container with Shared Volume

If the database is in a Docker container:

```bash
## Run container with volume mount
docker run -v /path/to/syllabot.db:/data/syllabot.db my-app

## On host, DBeaver connects to the mounted file
## Path: /path/to/syllabot.db
```

---

### Quick Comparison

| Method | Pros | Cons |
|---|---|---|
| **SSH Tunnel** | Secure, transparent, no file copy | Slightly more setup |
| **SCP/SFTP** | Simple, one-time access | Manual sync, no real-time updates |
| **SSHFS Mount** | Behaves like local filesystem | Network latency, mount/unmount needed |
| **sqlite-web** | Web interface, REST API | DBeaver can't use it directly |
| **Proxy to PG** | Full network DB features | Overkill, adds complexity |

---

### Most Practical: SSH Tunnel Setup Step-by-Step

1. **Verify SSH access works:**
   ```bash
   ssh user@remote-host "ls -l /path/to/syllabot.db"
   ```

2. **In DBeaver:**
   - **File** → **New** → **Database Connection**
   - **SQLite**
   - **Path:** `/path/to/syllabot.db` (remote path)
   - **SSH** tab → **Use SSH Tunnel** ✓
   - **Host:** `remote-host`
   - **Port:** `22`
   - **Username:** `user`
   - **Auth:** Password or key
   - **Test Connection**

3. Done. You now interact with the remote file as if it were local.

---

### If You Have a URL (Web-Hosted SQLite)

If someone gave you a **URL** like `http://example.com/download/syllabot.db`:

```bash
## Download the file
wget http://example.com/download/syllabot.db

## Or
curl -O http://example.com/download/syllabot.db

## Then open locally in DBeaver
```

DBeaver cannot directly open URLs — SQLite files must be on disk (local or mounted).

---

