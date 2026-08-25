## Slowly Changing Dimensions (SCD)


Slowly Changing Dimensions (SCD) are design patterns used to manage how data changes over time in dimensional models. In distributed data processing and Lakehouse architectures (e.g., Delta Lake, Apache Iceberg), implementing SCDs requires shifting from row-level mutability assumptions (common in RDBMS) to file-level immutability and metadata-driven transaction management. The choice of SCD type directly impacts write amplification, storage costs, and downstream query latency.

### Execution Context: Distributed Immutable Storage

Unlike traditional B-Tree based warehouses, distributed/cloud data warehouses typically use columnar file formats (Parquet, ORC). This fundamentally alters SCD performance characteristics:

- **Write Amplification:** Updating a single column in a single row requires rewriting the entire underlying columnar file (often 128MB–1GB).
    
- **Concurrency:** Implementations rely on Optimistic Concurrency Control (OCC). Multiple concurrent SCD merge operations on the same partition can lead to transaction conflicts.
    
- **Partitioning:** Effective partition pruning is essential. SCD strategies must align with physical partition layouts to avoid full table scans during updates.
    

---

### SCD Type 1: Overwrite (Stateless Updates)

This pattern keeps only the _current_ state of an entity. It does not preserve history.

- **Logic:** For a given Primary Key (PK), if a record exists, update its attributes; if not, insert it.
    
- **Distributed Implementation:**
    
    - **Merge/Upsert:** Utilizes `MERGE INTO` commands.
        
    - **Full Overwrite:** For smaller dimensions, it is often more efficient to completely rewrite the table (Truncate/Load) from the source rather than performing expensive row-level comparisons and merges.
        
    - **Deletes:** Often handled implicitly. If the source provides a full snapshot, records missing from the source can be physically deleted or soft-deleted via a flag.
        
- **Use Case:** Correction of data errors, removal of PII (GDPR "Right to be Forgotten"), or when history is irrelevant (e.g., "Current Weather").
    

### SCD Type 2: Row Versioning (Stateful History)

This is the standard for tracking history. It creates a new row for every change, preserving the previous state.

- **Schema Design:**
    
    - `Surrogate_Key`: Unique identifier for the specific version of the row.
        
    - `Natural_Key`: Business key (e.g., `Customer_ID`).
        
    - `Row_Effective_Date` / `Row_Expiration_Date`: Time range validity.
        
    - `Is_Current`: Boolean flag for fast filtering of current state.
        
- **Distributed Processing Logic:**
    
    1. **Change Detection:** Join incoming batch with the target table on `Natural_Key`. Compare hash of non-key columns (`md5(col1, col2...)`) to detect drift.
        
    2. **Expiring Old Rows:** For changed records, update the `Is_Current` flag to `False` and set `Row_Expiration_Date` to the incoming event timestamp.
        
    3. **Inserting New Rows:** Insert the new record with `Is_Current = True` and `Row_Effective_Date` = incoming event timestamp.
        
- **Late-Arriving Data Challenge:** If an event arrives out of order (e.g., an update from yesterday arrives today), a standard Type 2 pipeline might incorrectly close the _current_ record. Handling this requires "temporal re-stitching"—querying the history chain to insert the late record between two existing historical versions without disrupting the current state.
    
- **Partitioning Strategy:** Partitioning purely by time is often insufficient because updates happen to "current" rows which may be scattered across old time partitions. Partitioning by a high-cardinality `Entity_ID` is usually anti-pattern (too many small files). A common strategy is Z-Ordering by `Natural_Key` to accelerate the lookup phase of the Merge.
    

### SCD Type 3: Previous Value Column

Preserves limited history by adding a column for the specific attribute's previous value (e.g., `Current_Region`, `Previous_Region`).

- **Logic:** When a change is detected, the value in `Current_Region` is moved to `Previous_Region`, and the new value is written to `Current_Region`.
    
- **Distributed Constraints:**
    
    - **Schema Evolution:** Requires distinct columns for every historical generation tracked. Scaling beyond 1 previous version requires altering the table schema (adding `Prev_Prev_Region`), which is brittle in production pipelines.
        
    - **Write Amplification:** Like Type 1, updating columns requires rewriting files.
        
- **Use Case:** Very specific reporting requirements where only the immediate prior state is needed for "Before/After" analysis, and storage minimization is prioritized over full history.
    

### SCD Type 4: History Table (Rapidly Changing Dimensions)

Separates data into two physical tables: a "Current" table and a "History" table.

- **Architecture:**
    
    - **Current Table:** Type 1 (Overwrite). Optimized for high-performance operational reporting. Kept small and compact.
        
    - **History Table:** Append-only log of all changes. Optimized for cold storage and audit queries.
        
- **Performance Benefits:**
    
    - **Read Isolation:** Analytical queries needing only the "now" state do not scan through millions of historical rows.
        
    - **Write Efficiency:** The history table handles high-volume writes as pure appends (no updates/merges needed), which is the fastest operation in object storage (S3/ADLS).
        
- **Use Case:** "Rapidly" Changing Dimensions (e.g., Order Status, Real-time Location) where Type 2 would cause excessive table bloat and performance degradation.
    

### SCD Type 6: Hybrid (1 + 2 + 3)

Combines the approaches to allow querying history with "current" attribute values.

- **Structure:** A Type 2 table (Row Versioning) that _also_ includes a Type 1 column on every row that holds the _current_ value of an attribute.
    
    - Example: A customer moves from NY to CA.
        
        - Row 1 (Old): `Region=NY`, `Current_Region=CA` (Updated), `Valid_To=2023-01-01`
            
        - Row 2 (New): `Region=CA`, `Current_Region=CA` (Inserted), `Valid_To=NULL`
            
- **The Distributed System Anti-Pattern:**
    
    - To maintain the Type 1 `Current_Region` column on _all_ historical rows, the pipeline must update every single version of that entity ever recorded.
        
    - In a Lakehouse, this triggers a rewrite of every file containing history for that customer. If a customer has 1,000 historical changes, a single new update requires rewriting 1,000 historical records.
        
    - **Verdict:** Generally discouraged in modern Data Lakehouses due to extreme write amplification. It is often better to compute this "Current Value" dynamically at query time using Window Functions (`LEAD`/`LAG` or `FIRST_VALUE`) rather than materializing it physically.
        

### Summary of Architectural Trade-offs

|**SCD Type**|**History Preservation**|**Storage Impact**|**Write Cost (Lakehouse)**|**Read Cost (Current State)**|**Read Cost (Time Travel)**|
|---|---|---|---|---|---|
|**Type 1**|None|Low|Medium (Rewrite)|Low|Impossible|
|**Type 2**|Complete|High|High (Merge + Rewrite)|Medium (Filter overhead)|Low|
|**Type 3**|Limited (1 gen)|Low|Medium (Rewrite)|Low|Low (Limited scope)|
|**Type 4**|Complete|Medium|Low (Append + Overwrite)|**Very Low**|Medium (Requires Join)|
|**Type 6**|Complete + Current Context|Very High|**Extreme** (Massive Rewrite)|Low|Low|

### Related Topics

- Change Data Capture (CDC)
    
- Surrogate Key Pipelining
    
- Snapshot Isolation & Time Travel
    
- Z-Ordering and Hilbert Curves
    
- Data Compaction and Vacuuming

---

