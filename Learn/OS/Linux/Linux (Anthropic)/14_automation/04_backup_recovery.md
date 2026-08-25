## Backup & Recovery


### Backup Strategies

Backup strategies form the foundation of data protection, requiring systematic planning to balance recovery objectives with resource constraints and operational requirements.

#### The 3-2-1 Rule

The industry-standard 3-2-1 backup rule recommends maintaining three copies of critical data: the original plus two backups, stored on two different media types, with one copy kept offsite. This approach provides redundancy against hardware failure, site disasters, and human error.

#### Backup Types and Scheduling

**Full backups** create complete copies of all selected data, providing the simplest recovery process but requiring maximum storage space and time. **Incremental backups** capture only changes since the last backup of any type, minimizing storage requirements but potentially complicating recovery procedures. **Differential backups** include all changes since the last full backup, offering a middle ground between storage efficiency and recovery complexity.

**Recovery Time Objective (RTO)** defines the maximum acceptable downtime after a failure. **Recovery Point Objective (RPO)** specifies the maximum acceptable data loss measured in time. These metrics drive backup frequency and retention policies.

#### Data Classification and Prioritization

Critical system data includes configuration files, databases, and application data requiring frequent backups with short retention periods. User data may have different backup requirements based on change frequency and business importance. System binaries and applications can often be restored from installation media, reducing backup storage requirements.

**Hot backups** capture data from running systems without service interruption but may require application-specific tools to ensure consistency. **Cold backups** require system shutdown or service stopping, guaranteeing data consistency but impacting availability.

#### Retention Policies

Backup retention balances storage costs with recovery requirements. **[Inference]** Common retention schemes include daily backups for one month, weekly backups for three months, and monthly backups for one year, though specific requirements vary by organization and regulatory compliance needs.

**Key points**: Effective backup strategies require regular testing of restore procedures, documentation of recovery processes, and periodic review of changing data protection requirements.

### Backup Tools (tar, rsync)

Linux provides robust built-in tools for backup operations, with tar and rsync serving as fundamental utilities for different backup scenarios.

#### tar (Tape Archive)

The tar utility creates archive files containing multiple files and directories while preserving permissions, ownership, and timestamps.

**Basic tar operations**:

```bash
# Create archive
tar -cvf backup.tar /home/user/documents

# Create compressed archive
tar -czvf backup.tar.gz /home/user/documents

# Extract archive
tar -xvf backup.tar

# List archive contents
tar -tvf backup.tar
```

**Advanced tar features**:

```bash
# Incremental backup using snapshot file
tar -cvf full-backup.tar -g snapshot.snar /data
tar -cvf incremental-backup.tar -g snapshot.snar /data

# Exclude specific files or patterns
tar -czvf backup.tar.gz --exclude="*.tmp" --exclude="cache/*" /home/user

# Split large archives
tar -czvf - /large/directory | split -b 1G - backup.tar.gz.part
```

**Compression options** include gzip (-z), bzip2 (-j), and xz (-J), with xz typically providing the best compression ratio at the cost of processing time.

#### rsync (Remote Sync)

rsync efficiently synchronizes files and directories between locations, transferring only changed portions of files to minimize bandwidth usage.

**Basic rsync operations**:

```bash
# Local synchronization
rsync -av /source/directory/ /destination/directory/

# Remote synchronization
rsync -av /local/directory/ user@remote:/remote/directory/

# Synchronization with deletion
rsync -av --delete /source/ /destination/
```

**Advanced rsync features**:

```bash
# Bandwidth limiting
rsync -av --bwlimit=1000 /source/ user@remote:/destination/

# Progress display and partial transfers
rsync -av --progress --partial /large/files/ /backup/location/

# Exclude patterns and include specific files
rsync -av --exclude="*.log" --include="*.conf" /etc/ /backup/etc/

# Hard link support for space-efficient incremental backups
rsync -av --link-dest=/previous/backup/ /source/ /current/backup/
```

**SSH integration** enables secure remote transfers with compression and encryption:

```bash
rsync -av -e "ssh -p 2222" /local/data/ user@remote:/backup/data/
```

#### Performance Considerations

tar performs well for full backups of entire directory trees but lacks incremental synchronization capabilities. rsync excels at incremental updates and remote synchronization but may have higher overhead for initial full transfers.

**[Inference]** For large datasets, rsync's ability to resume interrupted transfers and skip unchanged files typically provides better performance than tar for routine backup operations.

**Example**: A daily backup strategy might use tar for weekly full backups stored offsite and rsync for daily incremental synchronization to local backup storage.

### Automated Backups

Automated backup systems eliminate human error and ensure consistent data protection through scheduled operations and monitoring.

#### Cron-based Scheduling

The cron daemon provides time-based job scheduling for automated backup execution:

```bash
# Daily backup at 2 AM
0 2 * * * /usr/local/bin/daily-backup.sh

# Weekly full backup on Sundays at 1 AM
0 1 * * 0 /usr/local/bin/weekly-full-backup.sh

# Hourly incremental backup during business hours
0 9-17 * * 1-5 /usr/local/bin/hourly-incremental.sh
```

#### Systemd Timers

Modern Linux distributions often prefer systemd timers over cron for service management integration:

```ini
# backup.timer
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

#### Backup Scripts and Error Handling

Robust backup scripts include error checking, logging, and notification mechanisms:

```bash
#!/bin/bash
BACKUP_DIR="/backup/$(date +%Y-%m-%d)"
LOG_FILE="/var/log/backup.log"

# Create backup directory
mkdir -p "$BACKUP_DIR" || exit 1

# Perform backup with error checking
if rsync -av /important/data/ "$BACKUP_DIR/"; then
    echo "$(date): Backup successful" >> "$LOG_FILE"
else
    echo "$(date): Backup failed" >> "$LOG_FILE"
    mail -s "Backup Failure" admin@company.com < "$LOG_FILE"
    exit 1
fi
```

#### Backup Verification

Automated verification ensures backup integrity through checksum comparison, test restores, or archive validation:

```bash
# Generate checksums during backup
find /source -type f -exec sha256sum {} \; > backup.checksums

# Verify backup integrity
cd /backup && sha256sum -c backup.checksums
```

#### Rotation and Cleanup

Automated cleanup prevents storage exhaustion while maintaining required retention periods:

```bash
# Keep daily backups for 30 days
find /backup/daily -type d -mtime +30 -exec rm -rf {} \;

# Keep weekly backups for 12 weeks
find /backup/weekly -type d -mtime +84 -exec rm -rf {} \;
```

**Key points**: Automated systems require monitoring, alerting, and regular testing to ensure reliability. Scripts should handle edge cases like insufficient disk space, network failures, and permission issues.

### Disaster Recovery Planning

Disaster recovery planning prepares organizations for complete system failures, natural disasters, or security incidents requiring full infrastructure restoration.

#### Risk Assessment and Business Impact Analysis

**[Inference]** Effective disaster recovery begins with identifying potential threats including hardware failures, natural disasters, cyber attacks, and human error. Business impact analysis quantifies the cost of downtime and data loss for different systems and services.

Critical systems require prioritized recovery procedures with minimal RTO and RPO targets. Non-critical systems may have longer acceptable recovery times, allowing resource allocation optimization during disaster response.

#### Recovery Site Strategies

**Hot sites** maintain fully operational duplicate infrastructure with real-time data replication, enabling rapid failover but requiring significant investment. **Warm sites** provide infrastructure with less current data, requiring some restoration time but reducing costs. **Cold sites** offer basic facilities requiring full system restoration.

**Cloud-based disaster recovery** provides scalable infrastructure without physical site maintenance, though network connectivity and data transfer requirements need careful planning.

#### Documentation and Procedures

Comprehensive disaster recovery documentation includes system inventories, configuration details, recovery procedures, and contact information. **[Inference]** Documentation should be accessible offline and stored in multiple locations to ensure availability during disasters.

**Recovery procedures** must include step-by-step instructions for system restoration, data recovery verification, and service validation. Regular procedure updates reflect infrastructure changes and lessons learned from testing.

#### Testing and Validation

Regular disaster recovery testing validates procedures and identifies gaps before actual disasters occur. **Tabletop exercises** review procedures and communication protocols without system disruption. **Partial testing** validates specific components or recovery steps. **Full testing** demonstrates complete disaster recovery capabilities but requires significant resources and potential service disruption.

**Recovery testing metrics** include actual RTO and RPO achievement, procedure accuracy, and staff performance under stress conditions.

#### Data Replication and Synchronization

**Synchronous replication** maintains identical data at multiple sites but may impact performance over long distances. **Asynchronous replication** allows performance optimization but may result in minor data loss during disasters.

**Database-specific replication** tools like MySQL replication, PostgreSQL streaming replication, or MongoDB replica sets provide application-level data protection with consistency guarantees.

#### Communication Plans

Disaster recovery requires coordinated communication with staff, customers, vendors, and stakeholders. **[Inference]** Communication plans should include multiple contact methods, escalation procedures, and public relations considerations for customer-facing services.

**Key points**: Disaster recovery plans require regular updates reflecting infrastructure changes, periodic testing to validate effectiveness, and staff training to ensure proper execution under stress.

**Important related topics**: Cloud backup strategies, database-specific backup and recovery procedures, virtualization backup considerations, regulatory compliance requirements for data retention.

---

