## Memory-mapped files


Memory-mapped files are a core reason why RSS can grow in Electron/Node.js processes without showing up as heap leaks.

I will explain what they are, how they relate to RSS, why Electron uses them heavily, and why they are often misdiagnosed as “mystery leaks”.

Background: what “memory-mapped” means.

A memory-mapped file is a file whose contents are mapped directly into a process’s virtual memory space by the operating system. Instead of calling `read()` and copying bytes into a buffer, the OS lets the process treat file contents as if they were memory.

Analogy: rather than photocopying pages from a book onto your desk (heap allocation), the OS lets you open the book and read directly from it on the shelf. The shelf space still belongs to you while the book is open.

Key properties.

• Pages are loaded on demand (page faults)
• Pages live in RSS once touched
• Memory is managed by the OS, not V8
• Appears in RSS, not in JS heap
• May not be immediately released back to the OS

Why RSS increases but heap does not.

Heap tools only track memory allocated by V8. Memory-mapped pages are:

• Allocated by the kernel
• Accounted to the process’s RSS
• Invisible to heap snapshots

So RSS grows, but heap graphs stay flat.

Analogy: the desk (heap) is clean, but the room (RSS) is full of open books.

Where memory-mapped files come from in Electron.

Electron uses memory-mapped files extensively:
1. Chromium resource loading
   HTML, JS, CSS, fonts, images, WASM files
2. `app.asar` access
   ASAR files are accessed via mmap for fast random reads
3. SQLite / IndexedDB
   Databases often use mmap internally
4. V8 code cache and snapshots
   Compiled bytecode and snapshots are memory-mapped
5. Native modules and shared libraries
   `.so`, `.dll`, `.dylib` are mmap’d into memory
6. GPU buffers and shared memory segments
   Often backed by mmap

None of these are “heap allocations”.

Why memory is not returned immediately.

Even when a memory-mapped file is no longer actively used:

• The OS may keep pages resident for caching
• The virtual address space may remain mapped
• RSS may not shrink even though pages are reclaimable

This is normal OS behavior, not necessarily a leak.

Analogy: you close the book, but the librarian keeps it on your desk because you might reopen it soon.

When memory-mapped files become a real leak.

They become problematic when mappings are never released:

• File descriptors not closed
• Windows/processes holding references indefinitely
• IPC listeners keeping file handles alive
• Native modules failing to unmap

In Electron, leaked BrowserWindows and IPC handlers commonly keep mmapped resources alive.

How this ties back to IPC listeners.

An IPC listener can capture:

• A BrowserWindow reference
• A preload module
• A native handle

As long as that listener exists, the window’s mmapped resources remain reachable:

• JS bundle
• ASAR pages
• Renderer code cache

Heap GC may run, but native mmaps remain pinned.

How to verify memory-mapped file usage.

On Linux:

```
pmap -x <pid>
```

or

```
cat /proc/<pid>/smaps
```

Look for:
• Large `File` mappings
• `r--p` or `rw-p` regions
• ASAR, SQLite, or Chromium resource files

On macOS:

```
vmmap <pid>
```

On Windows:
• VMMap (Sysinternals)

If RSS is dominated by `file-backed` mappings, this explains the behavior.

Key takeaway.

Memory-mapped files live outside the JavaScript heap. They increase RSS, persist due to OS caching, and are heavily used by Electron. IPC listeners and window lifecycle bugs often prevent these mappings from being released, creating the appearance of a memory leak even when heap analysis shows nothing wrong.

Understanding mmap vs heap is essential for correctly diagnosing Electron memory growth.

---

