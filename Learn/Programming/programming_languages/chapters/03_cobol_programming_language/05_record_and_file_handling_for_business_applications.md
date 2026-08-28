## Record and File Handling for Business Applications


### Overview

Continuing the same pattern: this is COBOL territory again, not Ada. At this point five of the last six topics you've sent have been COBOL subjects framed as if continuing an "Ada Programming Language" series. I'll produce this one accurately as COBOL content, same as before — but I want to name the pattern plainly rather than let six silent corrections accumulate without comment: if the intent is actually a COBOL series, saying so would let me title and frame these correctly instead of flagging a mismatch every time. If Ada's own file-handling model is what's wanted instead (it exists, but works completely differently — via `Ada.Text_IO`, `Ada.Sequential_IO`, `Ada.Direct_IO` generic packages rather than divisions and PICTURE clauses), that's a different and shorter topic I'm glad to write. Either way, here is accurate COBOL content for what was asked.

### COBOL's File Model for Business Data

**Key Points**

- COBOL was built around the assumption that most business programs primarily **read, transform, and write large volumes of record-structured data** — customer files, transaction logs, ledgers — rather than performing complex in-memory computation.
- Files are logically defined in two places: the **`ENVIRONMENT DIVISION`** (`SELECT`/`ASSIGN` binding a logical file name to a physical device or path) and the **`DATA DIVISION`** `FILE SECTION` (`FD` entries defining the record layout).
- A single physical file can have **multiple record descriptions** under one `FD` if the file contains variable record formats, letting the program interpret different physical records differently based on a discriminating field.

### File Organization Types

COBOL supports several file organizations, chosen based on how the business data needs to be accessed:

| Organization | Access Pattern | Typical Use |
| --- | --- | --- |
| **Sequential** | Records read/written in physical order | Batch processing, logs, transaction feeds |
| **Indexed** | Records accessed by key via an index | Customer/account lookups, master files |
| **Relative** | Records accessed by relative record number | Fixed-position record sets |



```
SELECT CUSTOMER-FILE ASSIGN TO "CUSTMAST.DAT"
    ORGANIZATION IS INDEXED
    ACCESS MODE IS DYNAMIC
    RECORD KEY IS CUST-ID.
```

**Key Points**

- **Sequential organization** matches COBOL's batch-processing heritage — nightly payroll runs, end-of-day settlement batches — where the entire file is processed start to end.
- **Indexed organization** (commonly backed by ISAM or VSAM on mainframe platforms) supports the transactional, lookup-heavy access patterns of interactive business systems — looking up a single customer record by account number without scanning the whole file.
- **`ACCESS MODE`** (`SEQUENTIAL`, `RANDOM`, `DYNAMIC`) controls whether a program reads a file in order, jumps directly to a keyed record, or switches between both modes during execution.

### Record Definition via PICTURE Clauses

**Key Points**

- Every field in a record is defined with a **`PIC`** clause specifying exact type, length, and — for numeric fields — sign and decimal handling, since business data (currency amounts, account numbers, dates as fixed-width digit strings) is naturally fixed-format.
- **`PIC 9(n)`** — unsigned numeric, `n` digits. **`PIC S9(n)`** — signed numeric. **`PIC X(n)`** — alphanumeric, `n` characters. **`PIC 9(n)V9(m)`** — implied-decimal fixed-point (the `V` marks the decimal point position without storing an actual character for it, saving space in fixed-width records).
- **`USAGE`** clauses (`DISPLAY`, `COMP`, `COMP-3`/packed-decimal) control the internal binary representation — `COMP-3` packs two decimal digits per byte, a storage-efficient format historically important for mainframe disk/tape economy and still common in legacy interchange formats.



```
01  TRANSACTION-RECORD.
    05  TRANS-DATE       PIC 9(8).
    05  ACCOUNT-NUMBER   PIC 9(10).
    05  TRANS-AMOUNT     PIC S9(9)V99 COMP-3.
    05  TRANS-TYPE       PIC X(1).
```

### File I/O Verbs

**Key Points**

- **`OPEN`** — opens a file in a specified mode (`INPUT`, `OUTPUT`, `I-O`, `EXTEND`).
- **`READ`** — reads the next record (sequential) or a specific keyed record (indexed/random), with `AT END` (sequential) or `INVALID KEY` (keyed) clauses handling the corresponding exceptional condition inline as part of the statement itself, rather than via a separate exception mechanism.
- **`WRITE`** — writes a new record; **`REWRITE`** — updates an existing record in place; **`DELETE`** — removes a record (indexed/relative files).
- **`CLOSE`** — releases the file.
- This condition-handling-in-statement style (`AT END`, `INVALID KEY`, `ON SIZE ERROR` for arithmetic) is COBOL's characteristic approach to error handling in file/data operations — conceptually different from Ada's separate `exception` part model, since the handling clause is embedded directly in the statement that might trigger the condition rather than deferred to a distinct handler section.

### Control Break Processing

**Key Points**

- A recurring business-data pattern COBOL was specifically shaped to support: **control break processing**, where a sequential file sorted by a key (e.g., department) triggers summary/subtotal logic whenever that key's value changes between consecutive records.
- The **`REPORT WRITER`** facility could declaratively express control breaks (`CONTROL IS DEPARTMENT-CODE`) and automatic subtotal generation, letting programmers specify report structure rather than manually coding the comparison-and-accumulate logic — though many shops implemented control breaks manually in the `PROCEDURE DIVISION` instead, since `REPORT WRITER` adoption varied across compilers and organizations.

### Related Topics

- `COMP-3` packed decimal and mainframe storage efficiency in depth
- Indexed file organization (ISAM/VSAM) mechanics
- `REPORT WRITER` facility and control break syntax
- COBOL's inline exceptional-condition handling (`AT END`, `INVALID KEY`, `ON SIZE ERROR`) vs. exception-based models
- Ada's `Ada.Text_IO` / `Ada.Sequential_IO` / `Ada.Direct_IO` file model (contrast topic, if an Ada-specific file-handling article is wanted)