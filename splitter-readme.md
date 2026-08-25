# split-by-headers / split-vault-by-headers

Two bash scripts for splitting large Obsidian-style markdown files into a
chapter/item folder tree, based on heading structure rather than byte size.

- **`split-by-headers.sh`** — splits one markdown file. Works standalone.
- **`split-vault-by-headers.sh`** — finds oversized `.md` files in a
  directory, backs each one up, and runs `split-by-headers.sh` against it.
  Depends on the script above; keep them in the same folder (or pass
  `--splitter PATH`).

Neither script modifies a source file in place. The vault wrapper moves
originals into a `.bak`; the standalone splitter only ever reads its input.

---

## How the split works

- **Chapter** = a real (non-fenced) line matching `^# ` (H1).
- **Item** = a real (non-fenced) line matching `^## ` (H2), nested under
  whichever chapter came before it. Deeper headers (`###`–`######`) are
  _not_ boundaries — they stay inside the item's content exactly as
  written, including any fenced code blocks they contain.
- **Syllabus** = the **first** H1 in the file, but _only_ if its title
  contains "syllabus" (case-insensitive). That whole block, down to the
  next H1, is dropped entirely — not numbered, not kept anywhere. If the
  first H1 doesn't match, nothing is dropped and it becomes chapter 01.
- **Fences** — a line starting with ` ``` ` (leading whitespace ignored)
  toggles fence state. Any `#`/`##`-looking line seen while inside a fence
  is treated as ordinary content, never as a boundary. This matters
  because fenced shell/code examples routinely contain lines like
  `# Install dependencies` that would otherwise be misread as headers.
- **Chapter preamble** — if a chapter has content before its first H2
  (rare; not present in the file this was built and tested against), that
  content is written to `00_<chapter>_overview.md` inside the chapter
  folder rather than being dropped. If a chapter goes straight from H1 to
  H2 with nothing between, no overview file is created.

Output filenames are numbered and slugified: lowercase, non-alphanumeric
runs collapsed to a single `_`, leading/trailing `_` trimmed. Each item
file's body starts with its original heading line (`## Item Title`),
a blank line, then its content verbatim.

---

## `split-by-headers.sh`

```
./split-by-headers.sh SOURCE.md [OUTPUT_DIR] [--dry-run] [--no-subfolder]
```

| Arg              | Meaning                                                                                                                                                                                                       |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `SOURCE.md`      | required — file to split                                                                                                                                                                                      |
| `OUTPUT_DIR`     | optional, default `.`                                                                                                                                                                                         |
| `--dry-run`      | run the full parse, write nothing. Prints the chapter/item tree it would create, with each item's line count.                                                                                                 |
| `--no-subfolder` | write chapter folders straight into `OUTPUT_DIR` instead of into `OUTPUT_DIR/<source_basename>/`. Meant for callers (like the vault wrapper) that already created and named an appropriate folder themselves. |

**Default output shape** (no `--no-subfolder`):

```
OUTPUT_DIR/
└── <source_basename>/
    ├── 01_<chapter_slug>/
    │   ├── 01_<item_slug>.md
    │   └── 02_<item_slug>.md
    └── 02_<chapter_slug>/
        └── ...
```

With `--no-subfolder`, the `01_<chapter_slug>/` folders land directly in
`OUTPUT_DIR` — no extra named layer.

### Example

```bash
./split-by-headers.sh "Typescript__Anthropic_.md" ./out
# Done. Chapters: 12
# Output: ./out/Typescript__Anthropic_

./split-by-headers.sh "Typescript__Anthropic_.md" ./out --dry-run
#   01_introduction_to_typescript/
#     01_setting_up_your_environment.md  (297 lines)
#     02_typescript_basic_types_and_type_annotations.md  (312 lines)
#     ...
# [DRY-RUN] No files written. Would create 12 chapter(s) under: ./out/Typescript__Anthropic_
```

---

## `split-vault-by-headers.sh`

```
./split-vault-by-headers.sh [VAULT_DIR] [--threshold SIZE] [--dry-run] [--splitter PATH]
```

| Arg                | Meaning                                                                                                            |
| ------------------ | ------------------------------------------------------------------------------------------------------------------ |
| `VAULT_DIR`        | optional, default `.`                                                                                              |
| `--threshold SIZE` | human size like `200k` or `1M`, default `200k`. Only `.md` files strictly larger than this are processed.          |
| `--dry-run`        | move nothing, write nothing. Shows what each candidate file's folder, `.bak` path, and chapter/item tree would be. |
| `--splitter PATH`  | path to `split-by-headers.sh`, default: same directory as this script                                              |

For each `.md` file found over the threshold:

1. Creates a folder named after the file (extension stripped).
2. Moves the original into that folder as `<original_filename>.bak`.
3. Runs `split-by-headers.sh --no-subfolder` against the `.bak`, writing
   the chapter tree directly into the same folder.

```
VAULT_DIR/
└── some_note/
    ├── some_note.md.bak          ← original, untouched content
    ├── 01_<chapter_slug>/
    │   └── ...
    └── 02_<chapter_slug>/
        └── ...
```

`.bak` files are always excluded from the size scan, so re-running the
wrapper over an already-processed vault won't re-split anything it's
already handled — the original `.md` no longer exists at that path (it's
been moved and renamed), so there's nothing left there for `find` to
match.

If a candidate file has **no H1 headers at all**, it's still backed up
(your content is never at risk) but nothing is split, and the run prints
an explicit warning naming the file so it doesn't pass silently as
"processed."

### Example

```bash
./split-vault-by-headers.sh ~/vault --dry-run
# Found 3 candidate file(s):
#   749KiB  ~/vault/Typescript__Anthropic_.md
#   ...
# Processing: ~/vault/Typescript__Anthropic_.md  (749KiB)
#   Folder: ~/vault/Typescript__Anthropic_
#   [DRY-RUN] Would move original -> ~/vault/Typescript__Anthropic_/Typescript__Anthropic_.md.bak
#   [DRY-RUN] split-by-headers.sh preview:
#     01_introduction_to_typescript/
#       ...

./split-vault-by-headers.sh ~/vault --threshold 500k
```

---

## Known limits

- **Tested against one real file** (a ~750KB TypeScript syllabus/course
  doc with 12 chapters, 34 items, and fenced code blocks containing
  `#`-prefixed shell comments). The chapter-preamble/overview path, the
  syllabus-skip path, and standard backtick fences were all exercised and
  verified against it. Behavior on files that differ structurally from
  that one — hasn't been checked, not just "probably fine":
  - **Tilde fences** (`~~~`) instead of backtick fences — not handled;
    only ` ``` ` toggles fence state.
  - **A syllabus H1 that isn't the literal first line of the file** (e.g.
    preceded by a blockquote, YAML front-matter, or blank lines with other
    content) — the "first H1" check is positional among H1s, so leading
    non-header content before it is fine, but this hasn't been tested.
  - **Deeply irregular heading nesting** (e.g. an H1 immediately followed
    by an H3 with no H2 in between) — H3+ always attaches to the current
    item or chapter overview; not tested against that specific shape.
- **The `find`-based collision check** in the vault wrapper (skip a file
  if its target folder already has a matching `.bak`) is written but was
  not observed to fire in testing — `.bak` exclusion combined with the
  original being moved/renamed means `find` doesn't re-match a
  fully-processed file in the first place. Not a guarantee to rely on for
  partial-run scenarios (e.g. if a run is interrupted between steps).
