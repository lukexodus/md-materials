## Reading and Writing Excel Files

### Overview

Pandas provides `read_excel()` and `to_excel()` as the primary interface for Excel I/O, built on top of optional third-party engine libraries rather than a native Pandas implementation. Because Excel files (`.xls`, `.xlsx`, `.xlsm`, `.xlsb`) are complex binary or zipped-XML formats, Pandas delegates the actual parsing/writing to engine packages, and the correct engine must be installed for the relevant file type.

### Required Dependencies

| File type | Read engine | Write engine |
|---|---|---|
| `.xlsx` | `openpyxl` | `openpyxl` |
| `.xls` (legacy) | `xlrd` (old versions only) | not supported by modern xlrd; use `.xlsx` |
| `.xlsb` | `pyxlsb` | not supported |
| `.ods` | `odf` | `odf` |

[Unverified] Exact minimum supported version numbers for each engine are not something I can confirm without checking current documentation, since these change over time.

Install as needed:

```bash
pip install openpyxl
pip install pyxlsb
pip install odfpy
```

### Basic Reading

```python
import pandas as pd

df = pd.read_excel("data.xlsx")
```

By default, `read_excel()` reads the first sheet of the workbook into a DataFrame, inferring column dtypes from cell contents.

### Key Parameters for `read_excel()`

```python
df = pd.read_excel(
    "data.xlsx",
    sheet_name="Sheet1",     # str, int (0-indexed), list, or None
    header=0,                # row to use as column names
    names=None,              # override column names
    index_col=None,          # column(s) to use as row index
    usecols="A:D",           # Excel-style column letters or list of names/indices
    dtype=None,              # force specific dtypes
    skiprows=0,
    nrows=None,
    na_values=None,
    parse_dates=False,
    engine=None               # auto-detected from file extension in most cases
)
```

**Key Points**
- `sheet_name=None` reads *all* sheets and returns a dict of `{sheet_name: DataFrame}`.
- `sheet_name=[0, 1]` (a list) also returns a dict, keyed by the sheet identifiers you passed.
- `usecols` accepts Excel column-letter ranges (`"A:D"`), a list of integer positions, or a list of column names — this is Excel-specific and has no direct CSV equivalent.
- `header=None` treats the first row as data rather than column names, producing default integer column labels.

### Reading Multiple Sheets

```python
sheets = pd.read_excel("workbook.xlsx", sheet_name=None)

for name, sheet_df in sheets.items():
    print(name, sheet_df.shape)
```

For repeated reads from the same file, `pd.ExcelFile` avoids re-opening the file on each call:

```python
xls = pd.ExcelFile("workbook.xlsx")
print(xls.sheet_names)

df1 = pd.read_excel(xls, sheet_name="Sheet1")
df2 = pd.read_excel(xls, sheet_name="Sheet2")
```

[Inference] Using `ExcelFile` this way is generally more efficient than calling `read_excel()` separately per sheet for the same file, since the file is parsed once and reused, but I have not measured this directly and cannot state a specific performance figure.

### Writing to Excel

```python
df.to_excel("output.xlsx", sheet_name="Results", index=False)
```

**Key Points**
- `index=False` omits the DataFrame's row index from the output; without it, the index is written as the first column.
- `to_excel()` requires an engine capable of *writing* the target format (`openpyxl` for `.xlsx`); some read-only engines cannot write.

### Writing Multiple Sheets with `ExcelWriter`

A single `to_excel()` call writes to one sheet. Multiple sheets in one workbook require `pd.ExcelWriter` as a context manager:

```python
with pd.ExcelWriter("output.xlsx", engine="openpyxl") as writer:
    df1.to_excel(writer, sheet_name="Raw", index=False)
    df2.to_excel(writer, sheet_name="Summary", index=False)
```

The `with` block ensures the file handle is properly closed and the workbook is finalized on exit.

### Appending to an Existing Workbook

```python
with pd.ExcelWriter("output.xlsx", engine="openpyxl", mode="a", if_sheet_exists="replace") as writer:
    df_new.to_excel(writer, sheet_name="NewSheet", index=False)
```

`mode="a"` (append) requires an engine that supports it — `openpyxl` does. `if_sheet_exists` controls behavior when the target sheet name already exists (`"error"`, `"replace"`, or `"overlay"`).

[Inference] `mode="a"` support and its exact options can vary by Pandas version; behavior described here reflects commonly documented usage and may not match every installed version exactly.

### Handling Dates and Numeric Precision

Excel stores dates as serial numbers internally. Pandas generally converts recognizable date-formatted cells to `datetime64` automatically, but ambiguous or text-formatted date cells may be read as strings or objects instead.

```python
df = pd.read_excel("data.xlsx", parse_dates=["OrderDate"])
```

[Inference] Relying on `parse_dates` explicitly is more predictable than depending on automatic type inference, though I cannot confirm this holds for every Excel formatting edge case without testing the specific file.

Floating-point values read from Excel may show precision artifacts (e.g., `0.1 + 0.2` style representation issues) — this is a general characteristic of IEEE 754 floating-point storage, not specific to Pandas or Excel.

### Formatting Output with `openpyxl` (Post-Processing)

Pandas' `to_excel()` writes data but does not expose most Excel-native formatting (cell colors, fonts, conditional formatting) through its own API. For that, you typically manipulate the workbook after writing, using `openpyxl` directly:

```python
from openpyxl import load_workbook
from openpyxl.styles import Font

wb = load_workbook("output.xlsx")
ws = wb["Results"]
ws["A1"].font = Font(bold=True)
wb.save("output.xlsx")
```

### Common Errors and Causes

| Error | Likely cause |
|---|---|
| `ImportError: Missing optional dependency 'openpyxl'` | Engine package not installed |
| `XLRDError: Excel xlsx file; not supported` | Using outdated `xlrd` on an `.xlsx` file — `xlrd` dropped `.xlsx` support in later versions [Unverified: exact version cutoff not confirmed here] |
| `ValueError: Worksheet named 'X' not found` | Incorrect `sheet_name` |
| Silent dtype mismatch (numbers read as text) | Source cells formatted as text in Excel |

### Performance Considerations

Excel I/O is markedly slower than CSV or Parquet for large datasets, because parsing XML-based `.xlsx` structure is more computationally expensive than plain-text delimited parsing. [Inference] For datasets beyond roughly tens of thousands of rows, CSV or Parquet formats are commonly preferred for intermediate storage, with Excel reserved for final reporting outputs — this is a general practice observation, not a fixed threshold, and actual performance depends on hardware, engine version, and file complexity.

### Diagram: Excel I/O Data Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 260">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Excel Read/Write Flow (svg_diagram)</text>

  <rect x="20" y="70" width="150" height="60" rx="6" fill="#e8f0fe" stroke="#4a6fa5" />
  <text x="95" y="105" text-anchor="middle" font-size="13" fill="#222">.xlsx file</text>

  <rect x="220" y="70" width="170" height="60" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="305" y="98" text-anchor="middle" font-size="12" fill="#222">Engine</text>
  <text x="305" y="115" text-anchor="middle" font-size="12" fill="#222">(openpyxl / pyxlsb)</text>

  <rect x="440" y="70" width="150" height="60" rx="6" fill="#e5f5e0" stroke="#4a9159" />
  <text x="515" y="105" text-anchor="middle" font-size="13" fill="#222">DataFrame</text>

  <rect x="640" y="70" width="100" height="60" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="690" y="105" text-anchor="middle" font-size="13" fill="#222">Analysis</text>

  <line x1="170" y1="100" x2="215" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />
  <line x1="390" y1="100" x2="435" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />
  <line x1="590" y1="100" x2="635" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />

  <text x="95" y="150" text-anchor="middle" font-size="11" fill="#555">read_excel()</text>
  <text x="515" y="150" text-anchor="middle" font-size="11" fill="#555">to_excel()</text>

  <line x1="515" y1="130" x2="305" y2="180" stroke="#888" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow)" />
  <line x1="305" y1="180" x2="95" y2="130" stroke="#888" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow)" />
  <text x="305" y="200" text-anchor="middle" font-size="11" fill="#555">Write path (via ExcelWriter)</text>

  </svg>

### Related Topics

- Reading and writing Parquet files (columnar format, faster for large data)
- Reading and writing JSON with `pd.read_json` / `to_json`
- Handling mixed dtypes and missing data during Excel import
- Combining multiple Excel sheets into one DataFrame with `pd.concat`
- Writing charts and pivot tables into Excel via `openpyxl` or `xlsxwriter`
- Memory-efficient Excel reading for large workbooks (`read_only` mode in `openpyxl`)