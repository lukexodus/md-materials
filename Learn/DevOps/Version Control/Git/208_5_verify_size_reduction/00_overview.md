## Overview

du -sh .git
```

### Advanced Git Performance Techniques

For repositories with persistent performance issues, more advanced techniques may be necessary.

**Key Points**

- File system choice affects Git performance
- Server-side optimizations can help all users
- Virtual file systems can handle massive repositories
- Some operations can be offloaded to specialized tools

#### File System Considerations

The file system can significantly impact Git performance:

1. **Recommended file systems**:
    
    - Linux: Ext4, XFS
    - macOS: APFS
    - Windows: NTFS (with proper configuration)
2. **Optimization settings**:
    
    - Disable file access time updates
    - Adjust journaling settings
    - Optimize for smaller files
3. **Storage considerations**:
    
    - SSDs dramatically outperform HDDs for Git
    - NVMe drives provide further performance benefits
    - Network file systems should be avoided for Git operations

#### Server-Side Optimizations

For Git servers and hosting providers:

1. **Repository settings**:
    
    - Enable Git protocol v2
    - Configure reference advertisement limits
    - Implement automatic GC on the server
2. **Hooks and policies**:
    
    - Pre-receive hooks to reject problematic commits
    - Server-side LFS configuration
    - Size limits for individual files
3. **Infrastructure**:
    
    - Dedicated Git caching servers
    - Content delivery networks for clone traffic
    - Geographic distribution for global teams

#### Git Virtual File Systems

For extremely large repositories:

1. **Git Virtual File System (GVFS)**:
    
    - Developed by Microsoft for Windows
    - Only downloads files when needed
    - Presents virtual file system representation
2. **Project Scalar**:
    
    - Newer alternative to GVFS
    - Focuses on performance without virtual filesystem
    - Works with partial clone feature
3. **GitLab Sparse Checkout**:
    
    - Server-side support for sparse checkouts
    - Optimizes clone and checkout operations
    - Integrates with GitLab's CI/CD

#### Repository Analysis Tools

Tools to help diagnose and fix performance issues:

1. **git-sizer**:
    
    ```bash
    git-sizer --verbose
    ```
    
    - Reports repository statistics
    - Identifies problematic areas
    - Suggests optimization approaches
2. **git-filter-repo**:
    
    ```bash
    git-filter-repo --analyze
    ```
    
    - Modern alternative to filter-branch
    - Safer and faster history rewriting
    - Comprehensive repository analysis
3. **git-core-profiler**:
    
    - Low-level profiling of Git operations
    - Helps identify specific performance bottlenecks
    - Useful for Git developers

### Best Practices for Ongoing Performance

Maintaining Git performance is easier than fixing performance problems after they occur.

**Key Points**

- Regular maintenance prevents performance degradation
- Team-wide practices ensure consistent performance
- Monitoring helps catch issues early
- Automation can handle routine optimization

#### Preventive Measures

1. **Repository housekeeping**:
    
    - Schedule regular GC operations
    - Monitor repository size growth
    - Set up size alerts
2. **Developer guidelines**:
    
    - Limit binary file commits
    - Use LFS for large assets
    - Keep branches short-lived
    - Regularly delete merged branches
3. **Git hooks**:
    
    - Pre-commit hooks to prevent large file commits
    - Post-merge hooks for automatic cleanup
    - Pre-push hooks to run GC

#### Automation Scripts

```bash
#!/bin/bash
