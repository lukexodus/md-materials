#!/usr/bin/env bash
# split-vault-by-headers.sh
#
# Walks a directory for .md files above a size threshold, and for each one:
#   1. creates a folder named after the file (no extension)
#   2. moves the original into that folder as <name>.md.bak
#   3. runs split-by-headers.sh against the .bak, writing the chapter/item
#      tree into that same folder
#
# This is the header-based successor to the byte-count splitter: the
# threshold still decides WHICH files get processed, but the split itself
# is delegated entirely to split-by-headers.sh (chapter = H1, item = H2,
# fence-aware, syllabus-skipping - see that script's own header comment).
#
# Usage:
#   ./split-vault-by-headers.sh [VAULT_DIR] [--threshold SIZE] [--dry-run] [--splitter PATH]
#
#   VAULT_DIR   directory to scan, default: current dir
#   --threshold human size (e.g. 200k, 1M), default: 200k
#   --dry-run   do everything read-only: no folder, no move, no split-by-headers.sh
#               writes. Prints what each file WOULD produce.
#   --splitter  path to split-by-headers.sh, default: same directory as this script
#
# Requires split-by-headers.sh's own --dry-run support (added alongside this
# script) - this wrapper does not duplicate that script's parsing logic, it
# calls it.

set -euo pipefail

# ========== CONFIG ==========
VAULT_DIR="."
SIZE_THRESHOLD="200k"
DRY_RUN=false
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SPLITTER="$SCRIPT_DIR/split-by-headers.sh"
# =============================

pos=()
while [[ $# -gt 0 ]]; do
  case "$1" in
  --threshold)
    SIZE_THRESHOLD="$2"
    shift 2
    ;;
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --splitter)
    SPLITTER="$2"
    shift 2
    ;;
  *)
    pos+=("$1")
    shift
    ;;
  esac
done
if [[ ${#pos[@]} -ge 1 ]]; then
  VAULT_DIR="${pos[0]}"
fi

if [[ ! -d "$VAULT_DIR" ]]; then
  echo "Error: not a directory: $VAULT_DIR" >&2
  exit 1
fi
if [[ ! -f "$SPLITTER" ]]; then
  echo "Error: split-by-headers.sh not found at: $SPLITTER" >&2
  echo "  (pass --splitter PATH if it lives somewhere else)" >&2
  exit 1
fi

# ---------- convert human size (k/M) to bytes ----------
to_bytes() {
  local size="$1"
  if [[ "$size" =~ ^([0-9]+)([kKmM]?)$ ]]; then
    local num="${BASH_REMATCH[1]}"
    local unit="${BASH_REMATCH[2],,}"
    case "$unit" in
    k) echo $((num * 1024)) ;;
    m) echo $((num * 1024 * 1024)) ;;
    *) echo "$num" ;;
    esac
  else
    echo "Invalid size: $size" >&2
    exit 1
  fi
}

THRESHOLD_BYTES=$(to_bytes "$SIZE_THRESHOLD")

echo "Scanning:   $VAULT_DIR"
echo "Threshold:  $SIZE_THRESHOLD ($THRESHOLD_BYTES bytes)"
echo "Splitter:   $SPLITTER"
echo "Dry-run:    $DRY_RUN"
echo

# ---------- find candidate files: over threshold, not already a .bak, and
# not sitting inside a folder this script already created (its own output
# folders share the source's basename and contain a sibling .bak - skip
# re-processing them on a second run over the same vault) ----------
mapfile -t large_files < <(
  find "$VAULT_DIR" -type f -name "*.md" -size +"${THRESHOLD_BYTES}c" \
    ! -name "*.bak" \
    -print0 | xargs -0 -I{} stat -c "%s %n" {} | sort -nr
)

if [[ ${#large_files[@]} -eq 0 ]]; then
  echo "No .md files larger than $SIZE_THRESHOLD found."
  exit 0
fi

echo "Found ${#large_files[@]} candidate file(s):"
for entry in "${large_files[@]}"; do
  size="${entry%% *}"
  file="${entry#* }"
  human=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "$size bytes")
  echo "  $human  $file"
done
echo

processed=0
skipped_no_chapters=0

process_file() {
  local file="$1"
  local size
  size=$(stat -c%s "$file")
  local human
  human=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "$size bytes")

  local dir base name
  dir=$(dirname "$file")
  base=$(basename "$file")
  name="${base%.*}"

  local target_dir="${dir}/${name}"
  local bak="${target_dir}/${base}.bak"
  local bak_name="${base}.bak"

  echo "Processing: $file  ($human)"
  echo "  Folder: $target_dir"

  if [[ "$DRY_RUN" == true ]]; then
    # Preview must mirror exactly what the real run feeds the splitter
    # (the .bak path, not the original) - split-by-headers.sh derives
    # its output folder name by stripping the LAST extension, so
    # "name.md" and "name.md.bak" strip to different folder names.
    # Symlink to a temp path with the .bak name so the preview's
    # reported paths match what a real run would actually create,
    # without touching or copying the original file's content.
    local preview_tmp
    preview_tmp=$(mktemp -d)
    ln -s "$(readlink -f "$file")" "$preview_tmp/$bak_name"
    echo "  [DRY-RUN] Would move original -> $bak"
    echo "  [DRY-RUN] split-by-headers.sh preview:"
    "$SPLITTER" "$preview_tmp/$bak_name" "$target_dir" --dry-run --no-subfolder | sed 's/^/    /'
    rm -rf "$preview_tmp"
    echo
    return
  fi

  if [[ -d "$target_dir" && -e "$bak" ]]; then
    echo "  Warning: $target_dir already has a $base.bak - looks already processed, skipping"
    echo
    return
  fi

  mkdir -p "$target_dir"
  mv "$file" "$bak"
  echo "  Moved original -> $bak"

  # Run the real split. If it produces zero chapters (e.g. the file has
  # no H1 markers at all), that's not a crash - just nothing to write -
  # but it would otherwise leave you with a folder containing only a
  # renamed .bak and no visible sign anything went wrong, so flag it.
  local split_output
  split_output=$("$SPLITTER" "$bak" "$target_dir" --no-subfolder)
  echo "$split_output" | sed 's/^/  /'

  local chapter_count
  chapter_count=$(echo "$split_output" | grep -oP 'Chapters: \K[0-9]+' || echo "0")
  if [[ "$chapter_count" -eq 0 ]]; then
    echo "  Warning: no H1 headers found - $bak was backed up but nothing was split."
    echo "           (original content is safe in the .bak; check the file's formatting)"
    skipped_no_chapters=$((skipped_no_chapters + 1))
  else
    processed=$((processed + 1))
  fi
  echo
}

for entry in "${large_files[@]}"; do
  file="${entry#* }"
  process_file "$file"
done

echo "All done."
if [[ "$DRY_RUN" == true ]]; then
  echo "  [DRY-RUN] Nothing was written or moved."
else
  echo "  Split: $processed file(s)"
  if [[ "$skipped_no_chapters" -gt 0 ]]; then
    echo "  Backed up but NOT split (no H1 headers found): $skipped_no_chapters file(s)"
  fi
  echo
  echo "What happened for each processed file:"
  echo "  - A folder was created with the same name as the original note"
  echo "  - The original was moved into that folder as  filename.md.bak"
  echo "  - The chapter/item tree from split-by-headers.sh was written alongside it"
fi
