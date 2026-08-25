## Git Object Model


### The Core Components of Git

Git's object model forms the foundation of its version control capabilities. At its heart, Git is a content-addressable filesystem, using a simple key-value store to track and manage content. This elegant design allows Git to efficiently handle everything from small personal projects to massive enterprise codebases.

**Key Points**

- Git's object model consists of four primary types: blobs, trees, commits, and references
- All Git objects are content-addressable via SHA-1 hash values
- Git's design prioritizes data integrity and distributed workflows
- Understanding the object model helps with advanced Git operations and troubleshooting

### Blobs, Trees, Commits, and Refs

#### Blobs

Blobs (binary large objects) are the simplest objects in Git, representing the content of files. When you add a file to Git, the system:

1. Takes the file's content
2. Calculates its SHA-1 hash
3. Stores it as a blob object

Blobs have these important characteristics:

- Contain only file data, no metadata or filenames
- Are immutable once created
- Are deduplicated (identical content creates identical blobs)
- Are compressed for storage efficiency

```
$ echo "Hello, Git!" | git hash-object -w --stdin
af5626b4a114abcb82d63db7c8082c3c4756e51b
```

#### Trees

Tree objects represent directories in Git. They organize blobs and other trees into a hierarchical structure, mapping names to SHA-1 identifiers and maintaining file permissions.

Tree objects contain:

- References to blobs (files)
- References to other trees (subdirectories)
- Mode bits indicating whether entries are files, directories, or symlinks
- File/directory names associated with each reference

```
$ git ls-tree HEAD
100644 blob af5626b4a114abcb82d63db7c8082c3c4756e51b    README.md
040000 tree 8d4f3bf5c3e54ce9e6249a5d93d9e25acc33f410    src
```

#### Commits

Commit objects represent snapshots of the project at specific points in time. Each commit contains:

- A reference to the top-level tree representing the project state
- Author and committer information (name, email, timestamp)
- A commit message describing the changes
- References to parent commit(s) (except for the initial commit)

```
$ git cat-file -p HEAD
tree a8f631f6c1e7325c562fe8cbc5be53985a502c7e
parent 7b9dd97c0337a0b105467dcdb38f75b9118c27dd
author Alice <alice@example.com> 1620000000 -0400
committer Alice <alice@example.com> 1620000000 -0400

Add README file
```

#### References (Refs)

References are pointers to specific commits, providing human-readable names for Git's SHA-1 hashes. Common types include:

- Branches: Mutable pointers that move forward as new commits are created
- Tags: Typically immutable pointers to specific commits
- HEAD: Special reference pointing to the current commit or branch
- Remote references: Track the state of branches on remote repositories

References are stored as simple text files containing the SHA-1 hash of the commit they point to.

```
$ cat .git/refs/heads/main
7b9dd97c0337a0b105467dcdb38f75b9118c27dd
```

### The `.git` Directory Structure

When you initialize a Git repository with `git init`, Git creates a `.git` directory containing all the metadata and objects needed to track your project. Understanding this structure provides insights into Git's operation.

#### Key Components

- `objects/`: Contains all Git objects (blobs, trees, commits)
    
    - `objects/pack/`: Contains packfiles for efficient storage
    - `objects/info/`: Additional object metadata
- `refs/`: Stores references
    
    - `refs/heads/`: Local branches
    - `refs/tags/`: Tags
    - `refs/remotes/`: Remote-tracking branches
- `HEAD`: Points to the current branch or commit
    
- `config`: Repository-specific configuration
    
- `description`: Used by GitWeb and similar tools
    
- `hooks/`: Scripts that run at various Git events
    
- `index`: Staging area information
    
- `info/`: Repository metadata
    
- `logs/`: Record of reference updates
    

**Example**

```
.git/
├── HEAD
├── config
├── description
├── hooks/
├── index
├── info/
├── logs/
├── objects/
│   ├── 00/
│   ├── 9a/
│   ├── info/
│   └── pack/
└── refs/
    ├── heads/
    ├── tags/
    └── remotes/
```

### How Git Stores Content

Git's storage mechanism is designed for efficiency, integrity, and performance. When files are added to Git, they undergo several transformations.

#### Content Storage Process

1. **Blob Creation**: File content is hashed with SHA-1 and stored as a blob
2. **Compression**: Objects are zlib-compressed to save space
3. **Path Storage**: Objects are stored in `objects/` subdirectories named by the first two characters of their hash
4. **Deduplication**: Identical content is stored only once, regardless of filename or location
5. **Packfiles**: For efficiency, Git periodically combines multiple objects into packfiles

#### Packfiles and Delta Compression

As repositories grow, Git optimizes storage with packfiles:

- Multiple loose objects are combined into a single file
- Similar objects are stored as deltas (differences) rather than complete copies
- An index file allows efficient access to packfile contents
- Automatically created during garbage collection or when pushing/fetching

```
$ git gc
Counting objects: 2437, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2431/2431), done.
Writing objects: 100% (2437/2437), done.
Total 2437 (delta 1715), reused 0 (delta 0)
```

### Git's Content-Addressable Filesystem

Git's content-addressable design means objects are identified and accessed by the hash of their content rather than by arbitrary names or locations.

#### Key Characteristics

- **Integrity**: Content hashing ensures data integrity; corruption is easily detected
- **Immutability**: Objects cannot be modified once created; changes create new objects
- **Efficiency**: Identical content is stored only once
- **Performance**: Direct lookup by hash is extremely fast
- **Distribution**: Content addressing facilitates distributed workflows

#### The SHA-1 Addressing System

Git objects are named by their SHA-1 hash, a 40-character hexadecimal string. While Git is transitioning to SHA-256 for enhanced security, SHA-1 remains the standard in most implementations.

```
$ git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4
test content
```

### Internal Plumbing Commands

Git provides low-level "plumbing" commands that interact directly with the object database. These commands expose Git's internal workings and are valuable for understanding and troubleshooting.

#### Essential Plumbing Commands

- `git hash-object`: Computes object ID and optionally creates a blob
- `git cat-file`: Displays object content and metadata
- `git update-index`: Manipulates the staging area
- `git write-tree`: Creates a tree object from the staging area
- `git commit-tree`: Creates a commit object
- `git read-tree`: Reads tree information into the staging area
- `git ls-tree`: Lists the contents of a tree object
- `git rev-parse`: Converts various references to their object IDs
- `git show-ref`: Lists references and their targets

**Example Workflow**

Creating objects manually with plumbing commands:

```
# Create a blob
$ echo "Hello, Git!" | git hash-object -w --stdin
af5626b4a114abcb82d63db7c8082c3c4756e51b

# Update the index
$ git update-index --add --cacheinfo 100644 af5626b4a114abcb82d63db7c8082c3c4756e51b hello.txt

# Create a tree
$ git write-tree
d8329fc1cc938780ffdd9f94e0d364e0ea74f579

# Create a commit
$ git commit-tree d8329f -m "Initial commit"
fdf4fc3344e67ab068f836878b6c4951e3b15f3d

# Update HEAD
$ git update-ref HEAD fdf4fc3344e67ab068f836878b6c4951e3b15f3d
```

### The Object Database Lifecycle

Understanding how Git manages its object database over time helps with repository maintenance and troubleshooting.

#### Object Lifecycle Stages

1. **Creation**: Objects are created and stored as loose objects
2. **Reference**: Branch, tag, and HEAD references point to commits
3. **Packing**: Loose objects are periodically packed for efficiency
4. **Pruning**: Unreachable objects may be removed during garbage collection
5. **Transfer**: Objects are shared between repositories during fetch/push

#### Garbage Collection and Maintenance

Git includes tools to maintain the object database:

- `git gc`: Compresses and optimizes the repository
- `git prune`: Removes unreachable objects
- `git fsck`: Verifies the integrity of the object database
- `git count-objects`: Reports statistics about the object database

```
$ git count-objects -v
count: 78
size: 284
in-pack: 2437
packs: 1
size-pack: 2431
prune-packable: 0
garbage: 0
size-garbage: 0
```

### Practical Applications

Understanding Git's object model enables advanced operations and troubleshooting:

- **Repository Recovery**: Restoring lost commits using reflog or filesystem analysis
- **History Editing**: Rewriting history with tools like filter-branch or BFG Repo-Cleaner
- **Custom Tools**: Building specialized tools that work directly with Git objects
- **Performance Tuning**: Optimizing repository structure for specific workflows
- **Git Internals Scripts**: Automating low-level operations for specialized needs

**Related Topics**

- Git data transport protocols and network operations
- Git's reflog and safety mechanisms
- Advanced branch management strategies
- Git hooks for workflow automation
- Git's cryptographic security model

---

