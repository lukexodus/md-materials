## mtime vs ctime


`fs.stat()` returns a `Stats` object that exposes several timestamps. The two that are most often confused are `mtime` and `ctime`, because they sound similar but represent different events.

I will explain them precisely, with background and an analogy.

**Brief background (what “stat” is)**
`stat` comes from the Unix `stat()` system call. It returns metadata about a filesystem object: size, permissions, ownership, and timestamps. These timestamps are maintained by the filesystem, not by Node.js.

**`stats.mtime` — modification time**

`mtime` is the **last time the file’s *contents* were modified**.

It updates when:

* File data is written to
* File contents are truncated or extended

It does *not* update when:

* Permissions change
* Ownership changes
* The filename changes
* The file is moved or renamed

Example:

```js
fs.writeFileSync('a.txt', 'new content');
// mtime changes
```

**`stats.ctime` — change time (not creation time)**

`ctime` is the **last time the file’s *metadata* changed**.

It updates when:

* File contents change (because size is metadata)
* Permissions change (`chmod`)
* Ownership changes (`chown`)
* The file is renamed
* The file is moved within the same filesystem

It does *not* mean “created time” on Unix-like systems.

This is the most common misunderstanding.

**Analogy**

Think of a file as a document in a folder:

* `mtime` is when you last edited the text inside the document.
* `ctime` is when *anything about the document’s record* was updated: edited text, changed the cover, moved it to another folder, or changed who owns it.

Every `mtime` change also updates `ctime`, but not the other way around.

**Important ordering rule**

* If `mtime` changes, `ctime` always changes.
* If `ctime` changes, `mtime` may or may not change.

So `ctime >= mtime` is generally true.

**Platform-specific note (important)**

On **Linux and other Unix systems**:

* `ctime` = change time
* There is no true creation time in POSIX

On **Windows and some macOS filesystems**:

* `ctime` may represent *creation time* instead
* Node.js still exposes it as `ctime` for API consistency

Because of this, you should *not* rely on `ctime` as creation time unless you know the platform and filesystem.

If you need creation time in Node.js, use:

```js
stats.birthtime
```

Even then, its reliability depends on filesystem support.

**Summary**

* `mtime`: when file contents last changed
* `ctime`: when metadata last changed (not creation time on Unix)
* `birthtime`: creation time, if supported
* `ctime` is more general than `mtime`

---

