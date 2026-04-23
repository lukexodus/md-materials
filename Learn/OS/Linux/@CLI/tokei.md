# tokei

A fast code statistics tool. Counts lines of code, comments, and blank lines across a project, broken down by language. Significantly faster than alternatives like `cloc`.

---

## Installation

|OS|Command|
|---|---|
|macOS|`brew install tokei`|
|Ubuntu/Debian|`sudo apt install tokei`|
|Arch|`sudo pacman -S tokei`|
|Cargo (any)|`cargo install tokei`|
|Binary|GitHub releases: `github.com/XAMPPRocky/tokei`|

---

## Basic Usage

```bash
tokei                 # current directory
tokei <path>          # specific path
tokei src/ tests/     # multiple paths
tokei .               # explicit current directory
```

**Example output:**

```
===============================================================================
 Language            Files        Lines         Code     Comments       Blanks
===============================================================================
 Rust                   42         8321         6912          710          699
 TOML                    6          312          289            8           15
 Markdown                3          401            0          310           91
 Shell                   4          198          142           34           22
===============================================================================
 Total                  55         9232         7343         1062          827
===============================================================================
```

Columns: **Files** — number of source files. **Lines** — total lines. **Code** — non-blank, non-comment lines. **Comments** — comment lines. **Blanks** — empty lines.

---

## Flags & Options

### Filtering Languages

|Flag|Action|
|---|---|
|`-t <lang,...>`|Only count specified languages|
|`-e <lang,...>`|Exclude specified languages|

```bash
tokei -t Rust,Python         # only Rust and Python
tokei -e Markdown,JSON       # skip Markdown and JSON
tokei -t JavaScript,TypeScript src/
```

Language names are case-insensitive. Use `tokei --list-languages` to see all supported names.

### Output Format

|Flag|Action|
|---|---|
|`-o <format>`|Output format: `cbor`, `json`, `toml`, `yaml`|
|`--compact`|Compact table, no per-language sub-headers|
|`--files` / `-f`|Show per-file breakdown within each language|

```bash
tokei -o json                 # machine-readable JSON output
tokei -o json | jq '.Rust'   # pipe to jq for querying
tokei -f                      # show every individual file
tokei -f src/                 # per-file breakdown for src/ only
```

### Sorting

|Flag|Action|
|---|---|
|`-s <field>`|Sort by: `files`, `lines`, `code`, `comments`, `blanks`|

```bash
tokei -s code                 # sort by lines of code (descending)
tokei -s files                # sort by file count
```

### Depth & Scope

|Flag|Action|
|---|---|
|`--hidden`|Count hidden files and directories (dotfiles)|
|`--no-ignore`|Don't respect `.gitignore` / `.ignore` files|
|`--no-ignore-parent`|Don't use ignore files from parent directories|

```bash
tokei --hidden                # include dotfiles
tokei --no-ignore             # count everything, ignore .gitignore
```

### Counting Thresholds

|Flag|Action|
|---|---|
|`-c <n>`|Set column width for output|
|`--columns <n>`|Alias for `-c`|

---

## Per-File Breakdown

The `-f` flag expands each language section to show individual files:

```bash
tokei -f src/
```

```
===============================================================================
 Rust                           Files        Lines         Code     Comments       Blanks
===============================================================================
 src/main.rs                                  312          289           12           11
 src/parser.rs                                891          761           88           42
 src/lib.rs                                   204          178           14           12
-------------------------------------------------------------------------------
 Total                              3         1407         1228          114           65
===============================================================================
```

Useful for finding unexpectedly large files or files with high comment ratios.

---

## JSON Output & Scripting

tokei's JSON output is well-structured and easy to query:

```bash
tokei -o json
```

```json
{
  "Rust": {
    "blanks": 699,
    "code": 6912,
    "comments": 710,
    "lines": 8321,
    "reports": [ ... ]
  }
}
```

**Practical jq recipes:**

```bash
# Total lines of code across all languages
tokei -o json | jq '[.[].code] | add'

# Lines of code per language, sorted
tokei -o json | jq 'to_entries | sort_by(-.value.code) | .[] | "\(.key): \(.value.code)"' -r

# Just the Rust code count
tokei -o json | jq '.Rust.code'
```

---

## Supported Languages

tokei supports 200+ languages. A few examples:

```bash
tokei --list-languages
```

Includes: Rust, Python, JavaScript, TypeScript, Go, C, C++, Java, Kotlin, Swift, Ruby, PHP, Haskell, Scala, Elixir, Erlang, Clojure, Lua, Shell, Bash, Zsh, Fish, TOML, YAML, JSON, Markdown, HTML, CSS, SCSS, SQL, and many more.

---

## Configuration

tokei respects `.tokeignore` files — same syntax as `.gitignore`. Place one in your project root to permanently exclude paths:

```gitignore
# .tokeignore
vendor/
generated/
*.pb.go
dist/
coverage/
```

It also automatically respects existing `.gitignore` and `.ignore` files unless you pass `--no-ignore`.

---

## Practical Examples

**Quick project summary:**

```bash
tokei
```

**Only application code, skip config and docs:**

```bash
tokei -e Markdown,JSON,TOML,YAML
```

**Find the largest files in a codebase:**

```bash
tokei -f -s lines | head -40
```

**Compare two directories:**

```bash
tokei src/ && tokei tests/
```

**Get total lines of code as a plain number (for scripts or badges):**

```bash
tokei -o json | jq '[.[].code] | add'
```

**Count everything including generated and hidden files:**

```bash
tokei --hidden --no-ignore
```

**Audit a monorepo by subdirectory:**

```bash
for dir in packages/*/; do echo "--- $dir ---"; tokei "$dir"; done
```

---

## Comparison with Alternatives

|Tool|Speed|Languages|Output formats|Actively maintained|
|---|---|---|---|---|
|`tokei`|Very fast (parallel)|200+|JSON, TOML, YAML, CBOR|Yes|
|`cloc`|Slow (Perl)|250+|JSON, XML, CSV|Yes|
|`scc`|Very fast|200+|JSON, CSV, HTML|Yes|
|`loc`|Fast|~100|Basic|No|
|`wc -l`|Instant|None|None|—|

tokei and `scc` are the two modern fast options. `scc` additionally estimates code complexity. `cloc` is the most widely known but considerably slower on large codebases.

---

## Tips

**Use in CI for tracking codebase growth** — pipe JSON output to a script that records totals over time, or use it to fail a build if generated code exceeds a threshold.

**Badge your README** — services like `tokei.rs` can generate a lines-of-code badge from a public GitHub repo directly.

**High comment ratio check** — with `-f -o json` you can identify files where comments exceed code, which may indicate outdated or over-documented files.

**It's parallelized** — tokei processes files concurrently, which is why it's fast on large repos. On a big monorepo it typically finishes in under a second.

**`.tokeignore` is project-local** — commit it to your repo so the whole team gets consistent counts and generated files don't inflate the numbers.