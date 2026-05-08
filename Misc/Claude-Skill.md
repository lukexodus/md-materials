name: file-reading description: "Use this skill when a file has been uploaded but its content is NOT in your context — only its path at /mnt/user-data/uploads/ is listed in an uploaded_files block. This skill is a router: it tells you which tool to use for each file type (pdf, docx, xlsx, csv, json, images, archives, ebooks) so you read the right amount the right way instead of blindly running cat on a binary. Triggers: any mention of /mnt/user-data/uploads/, an uploaded_files section, a file_path tag, or a user asking about an uploaded file you have not yet read. Do NOT use this skill if the file content is already visible in your context inside a documents block — you already have it." compatibility: "claude.ai, Claude Desktop, Cowork — any surface where uploads land at /mnt/user-data/uploads/" license: Proprietary. LICENSE.txt has complete terms

# Reading Uploaded Files

## Why this skill exists

When a user uploads a file in claude.ai, Claude Desktop, or Cowork, the file is written to `/mnt/user-data/uploads/<filename>` and you are told the path in an `<uploaded_files>` block. **The content is not in your context.** You must go read it.

The naive thing — `cat /mnt/user-data/uploads/whatever` — is wrong for most files:

- On a PDF it prints binary garbage.
- On a 100MB CSV it floods your context with rows you will never use.
- On a DOCX it prints the raw ZIP bytes.
- On an image it does nothing useful at all.

This skill tells you the right first move for each type, and when to hand off to a deeper skill.

## General protocol

1. **Look at the extension.** That is your dispatch key.
2. **Stat before you read.** Large files need sampling, not slurping.
    
    ```bash
    stat -c '%s bytes, %y' /mnt/user-data/uploads/report.pdffile /mnt/user-data/uploads/report.pdf
    ```
    
3. **Read just enough to answer the user's question.** If they asked "how many rows are in this CSV", don't load the whole thing into pandas — `wc -l` gives a fast approximation (it counts newlines, not CSV records, so it may over-count if quoted fields contain embedded newlines).
4. **If a dedicated skill exists, go read it.** The table below tells you when. The dedicated skills cover editing, creating, and advanced operations that this skill does not.

## `extract-text`

For docx, odt, epub, xlsx, pptx, rtf, and ipynb the first move is `extract-text <file>`. It emits markdown for docx/odt/epub (headings, bold, lists, links, tables), tab-separated rows under `## Sheet:` headers for xlsx, text under `## Slide N` headers for pptx, fenced code cells for ipynb, and plain text for rtf. Pass `--format <fmt>` when the extension is wrong or absent (e.g., `--format xlsx` on an `.xlsm`). If it errors on a file, `pandoc <file> -t plain` is a fallback; for xlsx/pptx, fall back to the dedicated skill's Python-based approach (openpyxl / python-pptx).

## Dispatch table

| Extension                         | First move                                           | Dedicated skill                           |
| --------------------------------- | ---------------------------------------------------- | ----------------------------------------- |
| `.pdf`                            | Content inventory (see PDF section)                  | `/mnt/skills/public/pdf-reading/SKILL.md` |
| `.docx`                           | `extract-text`                                       | `/mnt/skills/public/docx/SKILL.md`        |
| `.doc` (legacy)                   | Convert to `.docx` first                             | `/mnt/skills/public/docx/SKILL.md`        |
| `.xlsx`                           | `extract-text`                                       | `/mnt/skills/public/xlsx/SKILL.md`        |
| `.xlsm`                           | `extract-text --format xlsx`                         | `/mnt/skills/public/xlsx/SKILL.md`        |
| `.xls` (legacy)                   | `pd.read_excel(engine="xlrd")` — openpyxl rejects it | `/mnt/skills/public/xlsx/SKILL.md`        |
| `.ods`                            | `pd.read_excel(engine="odf")` — openpyxl rejects it  | `/mnt/skills/public/xlsx/SKILL.md`        |
| `.pptx`                           | `extract-text`                                       | `/mnt/skills/public/pptx/SKILL.md`        |
| `.ppt` (legacy)                   | Convert to `.pptx` first                             | `/mnt/skills/public/pptx/SKILL.md`        |
| `.csv`, `.tsv`                    | `pandas` with `nrows`                                | — (below)                                 |
| `.json`, `.jsonl`                 | `jq` for structure                                   | — (below)                                 |
| `.jpg`, `.png`, `.gif`, `.webp`   | Already in your context as vision input              | — (below)                                 |
| `.zip`, `.tar`, `.tar.gz`         | List contents, do **not** auto-extract               | — (below)                                 |
| `.gz` (single file)               | `zcat \| head` — no manifest to list                 | — (below)                                 |
| `.epub`, `.odt`                   | `extract-text`                                       | — (below)                                 |
| `.rtf`                            | `extract-text`                                       | — (below)                                 |
| `.ipynb`                          | `extract-text`                                       | — (below)                                 |
| `.txt`, `.md`, `.log`, code files | `wc -c` then `head` or full `cat`                    | — (below)                                 |
| Unknown                           | `file` then decide                                   | —                                         |

---

## PDF

**Never** `cat` a PDF — it prints binary garbage.

Quick first move — get the page count and check if text is extractable:

```bash
pdfinfo /mnt/user-data/uploads/report.pdf
pdftotext -f 1 -l 1 /mnt/user-data/uploads/report.pdf - | head -20
```

Then peek at the text content:

```python
from pypdf import PdfReader
r = PdfReader("/mnt/user-data/uploads/report.pdf")
print(f"{len(r.pages)} pages")
print(r.pages[0].extract_text()[:2000])
```

For anything beyond a quick peek — figures, tables, attachments, forms, scanned PDFs, visual inspection, or choosing a reading strategy — go read `/mnt/skills/public/pdf-reading/SKILL.md`. It covers content inventory, text extraction vs. page rasterization, embedded content extraction, and document-type-aware reading strategies.

For PDF form filling, creation, merging, splitting, or watermarking, go read `/mnt/skills/public/pdf/SKILL.md`.

---

## DOCX / DOC

The `docx` skill covers editing, creating, tracked changes, images. Read it if you need any of those. For a quick look:

```bash
extract-text /mnt/user-data/uploads/memo.docx | head -200
```

Legacy `.doc` (not `.docx`) must be converted first — see the `docx` skill.

---

## XLSX / XLS / spreadsheets

The `xlsx` skill covers formulas, formatting, charts, creating. Read it if you need any of those. For a quick look at an `.xlsx`:

```bash
extract-text /mnt/user-data/uploads/data.xlsx | head -100
```

For `.xlsm`, add `--format xlsx` (same zip structure; only the extension differs). When you need a structured preview in Python:

```python
from openpyxl import load_workbook
wb = load_workbook("/mnt/user-data/uploads/data.xlsx", read_only=True)
print("Sheets:", wb.sheetnames)
ws = wb.active
for row in ws.iter_rows(max_row=5, values_only=True):
    print(row)
```

`read_only=True` matters — without it, openpyxl loads the entire workbook into memory, which breaks on large files. Do not trust `ws.max_row` in read-only mode: many non-Excel writers omit the dimension record, so it comes back `None` or wrong. If you need a row count, iterate or use pandas.

**Legacy `.xls`** — openpyxl raises `InvalidFileException`. Use:

```python
import pandas as pd
df = pd.read_excel("/mnt/user-data/uploads/old.xls", engine="xlrd", nrows=5)
```

**`.ods` (OpenDocument)** — openpyxl also rejects this. Use:

```python
import pandas as pd
df = pd.read_excel("/mnt/user-data/uploads/data.ods", engine="odf", nrows=5)
```

---

## PPTX

```bash
extract-text /mnt/user-data/uploads/deck.pptx | head -200
```

**Legacy `.ppt`** — convert to `.pptx` first via LibreOffice; see `/mnt/skills/public/pptx/SKILL.md` for the sandbox-safe `scripts/office/soffice.py` wrapper (bare `soffice` hangs here because the seccomp filter blocks the `AF_UNIX` sockets LibreOffice uses for instance management).

For anything beyond reading, go to `/mnt/skills/public/pptx/SKILL.md`.

---

## CSV / TSV

**Do not** `cat` or `head` these blindly. A CSV with a 50KB quoted cell in row 1 will wreck your `head -5`. Use pandas with `nrows`:

```python
import pandas as pd
df = pd.read_csv("/mnt/user-data/uploads/data.csv", nrows=5)
print(df)
print()
print(df.dtypes)
```

Approximate row count without loading (over-counts if the file has RFC-4180 quoted newlines — the same quoted-cell case this section warned about above):

```bash
wc -l /mnt/user-data/uploads/data.csv
```

Full analysis only after you know the shape:

```python
df = pd.read_csv("/mnt/user-data/uploads/data.csv")
print(df.describe())
```

TSV: same, with `sep="\t"`.

---

## JSON / JSONL

Structure first, content second:

```bash
jq 'type' /mnt/user-data/uploads/data.json
jq 'if type == "array" then length elif type == "object" then keys else . end' /mnt/user-data/uploads/data.json
```

(`keys` errors on scalar JSON roots — a bare `"hello"` or `42` is valid JSON per RFC 7159 — so guard the branch.)

Then drill into what the user actually asked about.

JSONL (one object per line) — do **not** `jq` the whole file; work line by line:

```bash
head -3 /mnt/user-data/uploads/data.jsonl | jq .
wc -l /mnt/user-data/uploads/data.jsonl
```

---

## Images (JPG / PNG / GIF / WEBP)

**You can already see uploaded images.** They are injected into your context as vision inputs alongside the `<uploaded_files>` pointer. You do not need to read them from disk to describe them.

The disk copy is only needed if you are going to **process** the image programmatically:

```python
from PIL import Image
img = Image.open("/mnt/user-data/uploads/photo.jpg")
print(img.size, img.mode, img.format)
```

For OCR on an image (text extraction, not description):

```python
import pytesseract
print(pytesseract.image_to_string(img))
```

Note: the client resizes images larger than 2000×2000 down to that bound and re-encodes as JPEG before upload, so the disk copy may not be the user's original bytes. For most processing this doesn't matter; if the user is asking about original-resolution pixel data, flag it.

---

## Archives (ZIP / TAR / TAR.GZ)

**List first. Extract never — unless the user explicitly asks.** Archives can be huge, contain path traversal, or nest forever.

```bash
unzip -l /mnt/user-data/uploads/bundle.zip
tar -tf /mnt/user-data/uploads/bundle.tar
```

GNU tar auto-detects compression — `tar -tf` works on `.tar`, `.tar.gz`, `.tar.bz2`, `.tar.xz` alike. Don't hard-code `-z`.

If the user wants one file from inside, extract just that one:

```bash
unzip -p /mnt/user-data/uploads/bundle.zip path/inside/file.txt
```

**Standalone `.gz`** (not a tar) compresses a single file — there is no manifest to list. Just peek at the decompressed content:

```bash
zcat /mnt/user-data/uploads/data.json.gz | head -50
```

---

## EPUB / ODT

```bash
extract-text /mnt/user-data/uploads/book.epub | head -200
```

For long ebooks, pipe through `head` — you rarely need the whole thing to answer a question.

---

## RTF / IPYNB

```bash
extract-text /mnt/user-data/uploads/notes.rtf | head -200
extract-text /mnt/user-data/uploads/notebook.ipynb | head -200
```

---

## Plain text / code / logs

Check the size first:

```bash
wc -c /mnt/user-data/uploads/app.log
```

- **Under ~20KB**: `cat` is fine.
- **Over ~20KB**: `head -100` and `tail -100` to orient. If the user asked about something specific, `grep` for it. Load the whole thing only if you genuinely need all of it.

For log files, the user almost always cares about the end:

```bash
tail -200 /mnt/user-data/uploads/app.log
```

---

## Unknown extension

```bash
file /mnt/user-data/uploads/mystery.bin
xxd /mnt/user-data/uploads/mystery.bin | head -5
```

`file` identifies most things. `xxd` head shows magic bytes. If `file` says "data" and the hex doesn't match anything you recognize, ask the user what it is instead of guessing.

---

# Frontend Skill

name: frontend-design description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics. license: Complete terms in LICENSE.txt

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:

- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

## Frontend Aesthetics Guidelines

Focus on:

- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

**IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.