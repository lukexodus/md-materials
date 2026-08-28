## PICTURE Clauses and Data Description


### Overview

Same note as last time applies here too — this is COBOL's `PICTURE` clause system, not an Ada feature. I've flagged the mismatch across the last several topics and will keep doing it briefly rather than dropping it silently, but I won't belabor it at length each time now that the pattern is established on the record. Here is accurate, comprehensive COBOL content for `PICTURE` clauses and data description.

### Purpose of PICTURE Clauses

**Key Points**

- A **`PICTURE`** (abbreviated **`PIC`**) clause is COBOL's mechanism for declaring the exact **type, length, and format** of an elementary data item — there is no separate "type system" apart from these clauses; the picture string itself *is* the type declaration.
- This design reflects COBOL's fixed-width, record-oriented data model: because records are read from and written to files with exact byte layouts, every field's size and internal representation must be precisely specified, not inferred or left flexible.
- Picture clauses appear on **elementary items** (the leaf fields of a record); **group items** (records or sub-records composed of elementary items) have no `PIC` clause of their own — their size is the sum of their constituent elementary items.

### Picture Symbols

| Symbol | Meaning |
| --- | --- |
| `9` | Numeric digit (0–9) |
| `X` | Alphanumeric character (any) |
| `A` | Alphabetic character (letters and spaces only) |
| `V` | Implied decimal point (occupies no storage) |
| `S` | Sign present (occupies no storage unless combined with certain `USAGE` clauses) |
| `P` | Assumed decimal scaling position (for very large/small implied-magnitude numbers) |
| `Z` | Zero-suppression (leading zeros shown as spaces, for display) |
| `.` `,` `$` `+` `-` | Editing characters (literal punctuation/currency symbols in display fields) |

**Key Points**

- Repetition is expressed compactly with parentheses: `PIC 9(5)` means five occurrences of `9`, equivalent to `PIC 99999`.
- Combining symbols builds up precise formats: `PIC S9(7)V99` describes a signed numeric field with 7 integer digits and 2 implied decimal digits (9 digits of storage total, no character consumed by the sign or the decimal point).

### Numeric vs. Alphanumeric vs. Edited Fields

**Key Points**

- **Numeric fields** (`9`, `S`, `V`, `P` combinations) are used for values that participate in arithmetic — `COMPUTE`, `ADD`, `SUBTRACT` operate correctly only on properly declared numeric items.
- **Alphanumeric fields** (`X`) hold text and are not usable directly in arithmetic; names, addresses, and codes are typically `PIC X(n)`.
- **Edited fields** use punctuation/editing symbols to format numeric data for *display* or *printing* rather than for computation — e.g., `PIC $,$$$,$$9.99` formats a numeric value with an inserted dollar sign, comma thousands-separator, and a literal decimal point for a printed report line. Edited fields are typically the *target* of a `MOVE` from a working numeric field, not used for further arithmetic themselves.



```
01  RAW-AMOUNT       PIC S9(7)V99.
01  PRINTED-AMOUNT   PIC $$$,$$9.99.

MOVE RAW-AMOUNT TO PRINTED-AMOUNT.
```

### USAGE Clauses and Internal Representation

**Key Points**

- **`USAGE`** clauses control how a numeric field is physically stored, independent of its logical `PIC` description:
  - **`DISPLAY`** (the default) — one character per digit, stored as text-like bytes (e.g., EBCDIC or ASCII digit codes); simple but storage-inefficient for numeric data.
  - **`COMP`** (`COMPUTATIONAL`, often binary) — stores the value in native binary integer form, more compact and faster for arithmetic than `DISPLAY`.
  - **`COMP-3`** (`COMPUTATIONAL-3`, packed decimal) — packs two decimal digits per byte (with the last nibble reserved for the sign), a widely used mainframe format balancing storage efficiency with exact decimal semantics (unlike binary floating-point, packed decimal introduces no binary rounding error for base-10 values).
- [Inference] The prevalence of `COMP-3` in legacy interchange formats and file layouts is generally attributed to historical disk/tape storage costs on mainframe systems, where packing two digits per byte meaningfully reduced storage and I/O costs for the large-volume record files business processing depended on.

### Level Numbers and Hierarchical Description

**Key Points**

- **Level numbers** (two-digit values, conventionally `01`, `05`, `10`, `15`...) express the nesting structure of a record — a `01` level is a top-level record, and higher-numbered subordinate levels describe fields nested within it.
- Special level numbers serve distinct roles: **`66`** (`RENAMES`, regrouping existing fields under a new name), **`77`** (standalone elementary items with no group structure), and **`88`** (**condition names**, defining named boolean-like conditions tied to specific values of another field).



```
01  EMPLOYEE-RECORD.
    05  EMP-STATUS       PIC X(1).
        88  ACTIVE-EMP        VALUE "A".
        88  TERMINATED-EMP    VALUE "T".
    05  EMP-SALARY       PIC 9(7)V99.
```

**Key Points**

- **`88`-level condition names** let a program test `IF ACTIVE-EMP` instead of `IF EMP-STATUS = "A"`, improving readability in keeping with COBOL's overall English-like syntax philosophy — the condition's meaning is named once at the data-description level rather than repeated as a literal comparison throughout the procedure logic.

### Data Validation via PICTURE and Related Clauses

**Key Points**

- `PICTURE` clauses provide only structural validation (a field declared `PIC 9(5)` will reject non-numeric data at the storage/move level in many implementations, or produce undefined/truncated results depending on compiler and move rules) — they are not a full validation framework.
- Business-rule validation (e.g., "salary must not exceed department cap") is expressed separately in `PROCEDURE DIVISION` logic (`IF` statements) or via `88`-level condition names for enumerated valid states, not through the `PICTURE` clause itself.

### Related Topics

- `USAGE` clause storage formats (`COMP`, `COMP-1`, `COMP-2`, `COMP-3`) compared
- `88`-level condition names and their use in readable conditional logic
- Editing characters and report-formatting picture strings
- `REDEFINES` and `RENAMES` clauses for reinterpreting record layouts
- Ada's type and subtype declarations as a contrasting data-description model (if a direct Ada comparison article is wanted)