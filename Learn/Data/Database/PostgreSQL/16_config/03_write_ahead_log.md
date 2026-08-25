## Write-ahead Log


### `wal_level`

In PostgreSQL, the `wal_level` setting in `postgresql.conf` determines the amount of information written to the Write-Ahead Log (WAL), which is critical for crash recovery, replication, and point-in-time recovery (PITR). The choice of `wal_level` impacts performance, disk usage, and replication capabilities.

#### Available `wal_level` Settings
PostgreSQL supports three main `wal_level` values (as of PostgreSQL 17, the latest version in 2025):

1. **minimal**:
   - **Description**: Writes the least amount of WAL data, only what’s needed for crash recovery. Skips logging details for some operations (e.g., `CREATE TABLE AS`, `CREATE INDEX`, bulk `COPY`) by directly writing to data files.
   - **Use Case**: 
     - Systems prioritizing write performance over replication or PITR.
     - Workloads with heavy bulk operations (e.g., data imports) where recovery beyond crash safety isn’t needed.
   - **Pros**:
     - Reduces WAL volume (important for write-heavy workloads).
     - Faster for bulk operations due to less logging.
   - **Cons**:
     - Disables replication (streaming or logical) and PITR, as WAL lacks sufficient data.
     - Not suitable if you need standby servers or backup/restore beyond the last checkpoint.
   - **Performance Impact**: Minimal WAL writes benefit your SSD’s 300 TBW endurance and reduce I/O spikes, especially with your 4-core CPU handling concurrent writes.

2. **replica** (previously called `hot_standby` in older versions):
   - **Description**: Includes all data from `minimal` plus information needed for crash recovery, PITR, and physical replication (e.g., streaming replication to standby servers). Logs full page writes and transaction details.
   - **Use Case**:
     - High-availability setups with physical standby servers.
     - PITR for backup and restore.
     - Most common for production databases requiring failover or recovery.
   - **Pros**:
     - Enables streaming replication and PITR, ensuring data durability and failover options.
     - Balances performance and functionality for general-purpose workloads.
   - **Cons**:
     - Generates more WAL data than `minimal`, increasing I/O on your SSD (e.g., ~520 MB/s writes in TurboWrite, dropping to 300 MB/s after cache).
     - Slightly higher CPU overhead for logging, though your i5-8250U (4 cores, 8 threads) can handle this.

3. **logical**:
   - **Description**: Includes all data from `replica` plus additional information for logical replication and logical decoding (e.g., tracking changes for specific tables). Logs row-level changes for `INSERT`, `UPDATE`, and `DELETE`.
   - **Use Case**:
     - Logical replication setups (e.g., replicating specific tables to another database, possibly different PostgreSQL versions or non-PostgreSQL systems).
     - Change Data Capture (CDC) for ETL processes or auditing.
     - Cross-database or cross-version replication.
   - **Pros**:
     - Supports advanced replication scenarios, like selective table replication or multi-master setups.
     - Enables tools like `pglogical` or Debezium for streaming changes.
   - **Cons**:
     - Highest WAL volume, increasing I/O and disk usage on your 500GB SSD (465GB usable, so monitor storage).
     - Higher CPU overhead for encoding logical changes, which may stress your i5-8250U under heavy write loads.
     - Requires additional setup (e.g., `logical_decoding` plugins, subscriptions).
   - **Performance Impact**: Significant WAL writes, potentially taxing your SSD’s TurboWrite cache during sustained operations. Use `wal_compression = on` (as suggested earlier) to mitigate.

#### Additional Notes on `wal_level`
- **Default**: `replica` (since PostgreSQL 9.6). Safe for most setups, balancing recovery, replication, and performance.
- **Changing `wal_level`**:
  - Requires a server restart (`pg_ctl restart` or service restart on Windows).
  - Increasing `wal_level` (e.g., `minimal` to `replica`) is safe, but decreasing (e.g., `logical` to `replica`) may break existing replication setups.
- **Dependencies**:
  - Logical replication requires `wal_level = logical` and settings like `max_replication_slots` and `max_wal_senders`.
  - PITR requires `wal_level >= replica` and `archive_mode = on`.

#### Testing and Monitoring
1. **Apply Change**:
   - Edit `postgresql.conf`, set `wal_level = replica`, and restart PostgreSQL (`net stop postgresql-x64-<version> && net start postgresql-x64-<version>` on Windows).
2. **Monitor WAL Usage**:
   - Enable `log_checkpoints = on` and `log_min_duration_statement = 1000` to track checkpoint activity and slow queries.
   - Use `pg_stat_wal_receiver` (if replication is set up) or `pg_stat_archiver` (for PITR) to monitor WAL activity.
   - Check SSD I/O with Windows Performance Monitor (PhysicalDisk: “Disk Transfers/sec” for IOPS, “Avg. Disk Queue Length” <2).
3. **Benchmark**:
   - Run `pgbench -c 10 -j 4 -T 60` or your workload to compare performance with `wal_level = minimal` vs. `replica` vs. `logical`.
   - If using `logical`, monitor replication slot activity with `pg_stat_replication_slots`.
4. **Adjust**:
   - If `replica` generates too much WAL (e.g., storage nearing 465GB), consider `minimal` for non-critical systems or optimize `max_wal_size`.
   - If `logical` is needed but I/O spikes, increase `wal_compression` and reduce `max_connections` (set to 100 previously).

**Summary**
- **Alternatives**:
  - `minimal`: For non-critical systems with heavy bulk operations, minimizing I/O.
  - `logical`: For logical replication or CDC, but monitor I/O and storage.
- **Test**: Use `pgbench` and Performance Monitor to validate, especially if switching to `logical`.

---

